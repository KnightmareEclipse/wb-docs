-- Rechnungsfreigabe (Domäne 5) — Beleg, Freigabeschritt, Aufteilung, Lieferant.
-- Lesepfad: `expense_claims` ist der Beleg; er trägt Betrag, Zweck und den
-- Zahlweg. `expense_claim_items` sind seine Teile — bei einem gewöhnlichen
-- Beleg genau einer, bei einer Aufteilung mehrere, jeder mit eigener
-- Führungskraft, eigenem Projekt und eigener Entscheidung. Daneben stehen die
-- Anhänge, die Fahrtangaben und die drei Wertelisten.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus.
-- Dieser Prozess kennt kein Kind, keine Familie und keine Klasse. Bewusst KEINE
-- Nachzieh-Aufgabe daneben: „der freigegebene Beleg ist ihre Aufgabe, abgehakt
-- heißt gebucht, und eine zweite Nachzieh-Aufgabe daneben entsteht nicht" (12).
-- Bewusst KEINE Zuständigkeitsliste Projekt→Führungskraft: „Das Haus ist klein
-- genug, dass jeder weiß, wen er wählt."


-- ---------------------------------------------------------------------------
-- Wertelisten
-- ---------------------------------------------------------------------------

-- Herkunft: 12 (Rechnungsfreigabe) — „Der Zahlungsempfänger ist ein Eintrag,
-- kein Text: Jeder Einreicher darf einen anlegen, den er nicht findet …, und
-- die Buchhaltung berichtigt einen Eintrag oder führt zwei zusammen." Kein
-- Löschanker im üblichen Sinn: „Ein Eintrag der Empfängerliste bleibt, solange
-- ein Beleg auf ihn verweist — auch wenn dahinter eine Person steht und keine
-- Firma." Bewusst KEINE gemeinsame Parteien-Tabelle mit `persons`: „Zwei
-- verschiedene Sachverhalte, nie eine gemeinsame Parteien-Tabelle"
-- (grenzkarte.md).
CREATE TABLE payees (
    payee_id   integer GENERATED ALWAYS AS IDENTITY,
    name       text NOT NULL,
    -- Gesetzt, wo zwei Einträge zusammengeführt wurden; die Belege ziehen mit,
    -- weil sie auf den Eintrag verweisen und nicht den Namen kopieren.
    merged_into_payee_id integer,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,

    CONSTRAINT pk_payees      PRIMARY KEY (payee_id),
    CONSTRAINT uq_payees_name UNIQUE (name),
    CONSTRAINT fk_payees_merged FOREIGN KEY (merged_into_payee_id) REFERENCES payees (payee_id),
    CONSTRAINT ck_payees_name   CHECK (name <> ''),
    CONSTRAINT ck_payees_merge  CHECK (merged_into_payee_id <> payee_id),
    CONSTRAINT ck_payees_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 12 (Rechnungsfreigabe) — „die Liste der Projekte und
-- Buchungskonten pflegt die Buchhaltung; sie folgt dem Kontenrahmen in Optigem,
-- weil dort gebucht wird". Kein Löschanker: keine Personendaten.
CREATE TABLE cost_projects (
    cost_project_id integer GENERATED ALWAYS AS IDENTITY,
    code            text NOT NULL,
    name            text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active        boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    created_by      text NOT NULL,

    CONSTRAINT pk_cost_projects      PRIMARY KEY (cost_project_id),
    CONSTRAINT uq_cost_projects_code UNIQUE (code),
    CONSTRAINT ck_cost_projects_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

CREATE TABLE ledger_accounts (
    ledger_account_id integer GENERATED ALWAYS AS IDENTITY,
    code              text NOT NULL,
    name              text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active          boolean NOT NULL DEFAULT true,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_ledger_accounts      PRIMARY KEY (ledger_account_id),
    CONSTRAINT uq_ledger_accounts_code UNIQUE (code),
    CONSTRAINT ck_ledger_accounts_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Vorlagen
-- ---------------------------------------------------------------------------

-- Herkunft: 12 (Rechnungsfreigabe) — „Vorlagen legen zwei Stellen an, jede bei
-- dem, was sie ohnehin verantwortet: die Buchhaltung die Buchungsvorlagen, weil
-- ihr Projekte und Konten gehören, die Geschäftsführung die
-- Aufteilungsvorlagen." Löschanker: keiner, keine Personendaten. Eine Zeile
-- trägt beide Sorten, weil sie dieselbe Form haben; welche es ist, sagt die
-- Zahl ihrer Anteile.
CREATE TABLE claim_templates (
    claim_template_id integer GENERATED ALWAYS AS IDENTITY,
    name              text NOT NULL,
    -- „Eine geänderte Vorlage gilt ab dem nächsten Beleg; laufende ändern sich
    -- nicht" — deshalb hat die Vorlage keinen Gültigkeitstag, sondern die
    -- Beleg-Zeile kopiert ihren Stand.
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_claim_templates      PRIMARY KEY (claim_template_id),
    CONSTRAINT uq_claim_templates_name UNIQUE (name),
    CONSTRAINT ck_claim_templates_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 12 (Rechnungsfreigabe) — „Läuft er über eine Aufteilungsvorlage,
-- entfällt dieser Umlauf: Der Schlüssel steht fest, die Zustimmung der anderen
-- steht in der Vorlage." Löschanker: keiner. Ein Anteil je Zeile; eine Vorlage
-- mit genau einer Zeile ist eine Buchungsvorlage.
CREATE TABLE claim_template_shares (
    claim_template_share_id integer GENERATED ALWAYS AS IDENTITY,
    claim_template_id       integer NOT NULL,
    cost_project_id         integer NOT NULL,
    ledger_account_id       integer,
    -- Anteil in Basispunkten, damit sich Drittel ohne Rundungsverlust
    -- ausdrücken lassen; „was beim Runden übrig bleibt, fällt auf den größten
    -- Anteil" und wird nicht gespeichert. Dass die Anteile einer Vorlage
    -- zusammen 10000 ergeben — der Schlüssel teilt den Beleg vollständig auf —,
    -- prüft die Anwendung: eine Summe über mehrere Zeilen trägt kein CHECK.
    share_basis_points      integer NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_claim_template_shares PRIMARY KEY (claim_template_share_id),
    CONSTRAINT fk_claim_template_shares_template
        FOREIGN KEY (claim_template_id) REFERENCES claim_templates (claim_template_id) ON DELETE CASCADE,
    CONSTRAINT fk_claim_template_shares_project
        FOREIGN KEY (cost_project_id) REFERENCES cost_projects (cost_project_id),
    CONSTRAINT fk_claim_template_shares_account
        FOREIGN KEY (ledger_account_id) REFERENCES ledger_accounts (ledger_account_id),
    CONSTRAINT uq_claim_template_shares UNIQUE (claim_template_id, cost_project_id),
    CONSTRAINT ck_claim_template_shares_amount
        CHECK (share_basis_points BETWEEN 1 AND 10000),
    CONSTRAINT ck_claim_template_shares_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Der Beleg
-- ---------------------------------------------------------------------------

-- Herkunft: 12 (Rechnungsfreigabe) — „Zwei Belegarten und keine dritte:
-- Rechnung und Fahrtkosten, letztere als Ticket oder als gefahrene Strecke."
-- Löschanker: keiner — „Es verschwindet nichts von selbst … die Angaben zum
-- Beleg bleiben zehn Jahre in Weltenbaum, die Anhänge in SharePoint, und was
-- danach mit einem Jahrgang geschieht, entscheidet die Geschäftsführung von
-- Hand." Der Beleg überlebt
-- seinen Einreicher. Bewusst KEINE Frist und keine Eskalationsstufe: „Kein
-- Beleg verfällt, keine Aufgabe verfällt, es wird nicht eskaliert."
CREATE TABLE expense_claims (
    expense_claim_id  uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Der Einreicher als Mitarbeitender, nicht als Person: „Einreicher ist jede
    -- Person mit einer Mitarbeiterrolle, die der Schule wie die der KITA."
    submitter_employee_id uuid,
    -- „Der Beleg überlebt seinen Einreicher: Scheidet er aus, bleibt sein Name
    -- daran." Solange es den Mitarbeitendeneintrag gibt, steht der Name dort und
    -- hier nicht; der Lösch-Lauf trägt ihn ein, bevor er den Eintrag löscht, und
    -- der CHECK unten erzwingt diese Reihenfolge.
    submitter_employee_name text,
    claim_type        text NOT NULL,
    -- Lückenlos ab der Freigabe: „ihre lückenlose Nummer für die Buchhaltung".
    -- Bis dahin leer, denn ein abgelehnter Beleg bekommt keine. Der Schlüssel
    -- unten hält sie je Kalenderjahr eindeutig; lückenlos macht sie die
    -- Anwendung, die sie bei der Freigabe zieht — in reinem SQL ist eine
    -- Folge ohne Lücke nicht ausdrückbar, und eine Sequenz hätte welche.
    claim_number      integer,
    -- Das Kalenderjahr der Einreichung — „der einzige Zeitbezug" dieses Blocks,
    -- und der einzige Prozess, der nicht im Schuljahr rechnet.
    calendar_year     smallint NOT NULL,
    payee_id          integer,
    -- Gutschriften sind erlaubt, der Betrag darf negativ sein. Bei Fahrtkosten
    -- ist er ableitbar — „entweder Ticketbetrag samt Beleg oder die Strecke,
    -- die mit dem Kilometersatz multipliziert wird" (12); `travel_details`
    -- führt ihn deshalb mit und hält ihn per zusammengesetztem Fremdschlüssel
    -- an dieser Zeile fest (rules.md Abschnitt 1, Ausnahme).
    amount_cents      integer NOT NULL,
    purpose           text NOT NULL,
    -- An mich, an Dritte, direkt an die Firma, Spende mit oder ohne Nachweis,
    -- oder: wird abgebucht.
    payment_route     text NOT NULL,
    -- Nur bei „an Dritte", und auch dort nur, wenn die Buchhaltung sie nicht
    -- schon hat; für „an mich" wird bewusst keine erhoben.
    third_party_account_holder text,
    third_party_iban  text,
    claim_template_id integer,
    -- „solange keine Führungskraft ihn oder einen seiner Teile freigegeben hat"
    withdrawn_at      timestamptz,
    -- Der Abschluss durch die Buchhaltung: „abgehakt heißt gebucht".
    booked_at         timestamptz,
    booked_by         text,
    -- Storniert mit Pflichtbegründung; „ein Storno trifft bei einem
    -- aufgeteilten Beleg alle Teile".
    voided_at         timestamptz,
    voided_reason     text,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_expense_claims PRIMARY KEY (expense_claim_id),
    CONSTRAINT fk_expense_claims_submitter
        FOREIGN KEY (submitter_employee_id) REFERENCES employees (employee_id)
        ON DELETE SET NULL,
    -- Der Einreicher ist Pflicht: entweder der Mitarbeitendeneintrag oder, wenn
    -- der fort ist, sein Name. Nie keines von beiden.
    CONSTRAINT ck_expense_claims_submitter
        CHECK (submitter_employee_id IS NOT NULL
               OR (submitter_employee_name IS NOT NULL AND submitter_employee_name <> '')),
    CONSTRAINT fk_expense_claims_payee FOREIGN KEY (payee_id) REFERENCES payees (payee_id),
    CONSTRAINT fk_expense_claims_template
        FOREIGN KEY (claim_template_id) REFERENCES claim_templates (claim_template_id),
    CONSTRAINT uq_expense_claims_number UNIQUE (calendar_year, claim_number),
    -- „Ein Beleg gehört zu dem Jahr, in dem er eingereicht wurde" (12): das
    -- Jahr folgt aus `created_at` und steht hier nur mit, weil
    -- `uq_expense_claims_number` es braucht. Damit fällt es unter die Ausnahme
    -- aus rules.md Abschnitt 1 — und die verlangt, dass der mitgeführte Wert an
    -- sein Original gebunden bleibt. Ohne diesen CHECK landete ein heute
    -- angelegter Beleg im Nummernkreis eines fremden Jahres. Dieselbe Bindung
    -- wie `ck_parent_work_entries_school_year` in elternbonus-schema.sql.
    -- Die Zeitzone steht fest im CHECK und folgt nicht der Sitzung:
    -- `EXTRACT(year FROM timestamptz)` ist STABLE und nicht IMMUTABLE, das Jahr
    -- hinge sonst daran, wer gerade prüft. Ein Beleg vom 31. Dezember 23:30 UTC
    -- ginge in einer UTC-Sitzung als altes Jahr durch und wäre danach in einer
    -- Berliner Sitzung nicht mehr änderbar — und weil COPY die CHECKs prüft,
    -- ließe sich das Backup in einen Server mit anderer Zeitzone nicht
    -- zurückspielen (rules.md Abschnitt 8). `timezone(text, timestamptz)`, das
    -- `AT TIME ZONE` aufruft, ist dagegen IMMUTABLE.
    -- `ck_parent_work_entries_school_year` braucht das nicht: darunter steht
    -- eine `date`-Spalte.
    CONSTRAINT ck_expense_claims_calendar_year
        CHECK (calendar_year
               = EXTRACT(year FROM created_at AT TIME ZONE 'Europe/Berlin')::smallint),
    -- Trägt den zusammengesetzten Fremdschlüssel von `expense_claim_items` und
    -- ist deshalb zusätzlich zum Primärschlüssel nötig: die Sperre gegen die
    -- eigene Freigabe braucht Einreicher, Belegart und Zahlweg in derselben
    -- Zeile wie die Führungskraft (rules.md Abschnitt 1, Ausnahme).
    CONSTRAINT uq_expense_claims_submitter
        UNIQUE (expense_claim_id, submitter_employee_id, claim_type, payment_route),
    -- Trägt den zusammengesetzten Fremdschlüssel von `travel_details` und ist
    -- deshalb zusätzlich zum Primärschlüssel nötig (rules.md Abschnitt 1,
    -- Ausnahme).
    CONSTRAINT uq_expense_claims_amount UNIQUE (expense_claim_id, amount_cents),
    CONSTRAINT ck_expense_claims_type CHECK (claim_type IN ('invoice', 'travel')),
    CONSTRAINT ck_expense_claims_purpose CHECK (purpose <> ''),
    CONSTRAINT ck_expense_claims_route
        CHECK (payment_route IN ('to_me', 'to_third_party', 'to_company',
                                 'donation_with_receipt', 'donation_without_receipt',
                                 'direct_debit')),
    -- Kontoinhaber und IBAN gibt es nur bei „an Dritte".
    CONSTRAINT ck_expense_claims_third_party
        CHECK (payment_route = 'to_third_party'
               OR (third_party_account_holder IS NULL AND third_party_iban IS NULL)),
    -- „Bei der Rechnung: Zahlungsempfänger … (alles Pflicht)"; eine Fahrt nach
    -- Strecke trägt keinen.
    CONSTRAINT ck_expense_claims_payee
        CHECK (claim_type = 'travel' OR payee_id IS NOT NULL),
    CONSTRAINT ck_expense_claims_booked
        CHECK ((booked_at IS NULL) = (booked_by IS NULL)),
    CONSTRAINT ck_expense_claims_booked_by CHECK (booked_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_expense_claims_voided
        CHECK ((voided_at IS NULL) = (voided_reason IS NULL)),
    -- „Ein abgelehnter, stornierter oder zurückgezogener Beleg lebt nicht wieder
    -- auf" — und gebucht wird keiner von ihnen.
    CONSTRAINT ck_expense_claims_end
        CHECK (num_nonnulls(withdrawn_at, booked_at, voided_at) <= 1),
    CONSTRAINT ck_expense_claims_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt den Dublettenhinweis: „wenn Empfänger und Betrag eines anderen Belegs
-- innerhalb von 30 Tagen übereinstimmen".
CREATE INDEX ix_expense_claims_duplicate ON expense_claims (payee_id, amount_cents, created_at);

-- Herkunft: 12 (Rechnungsfreigabe) — „Aufteilen statt entscheiden: auf
-- mindestens zwei Projekte, und die Teilbeträge müssen den Betrag genau
-- treffen. Jede beteiligte Führungskraft entscheidet über ihren Teil wie über
-- einen eigenen Beleg." Löschanker: geht mit dem Beleg. Ein gewöhnlicher Beleg
-- hat genau eine Zeile hier — dieselbe Struktur trägt beide Fälle, statt
-- Freigabe und Aufteilung getrennt zu bauen.
-- Dass die Teilbeträge den Betrag „genau treffen", prüft die Anwendung: eine
-- Summe über mehrere Zeilen trägt kein CHECK, und ein Trigger kommt in diesem
-- Schema nicht vor. Ebenso die Mindestzahl von zwei Projekten je Aufteilung.
CREATE TABLE expense_claim_items (
    expense_claim_item_id uuid NOT NULL DEFAULT gen_random_uuid(),
    expense_claim_id      uuid NOT NULL,
    -- Die gewählte Führungskraft. Sie hängt an einem Menschen und nicht an
    -- einer Rolle — einer der beiden benannten Fälle in hebel.md.
    approver_employee_id  uuid,
    -- Wie beim Einreicher: der Name bleibt am Teil, wenn der
    -- Mitarbeitendeneintrag auf seiner eigenen Frist geht.
    approver_employee_name text,
    -- Einreicher, Belegart und Zahlweg des Belegs, hier mitgeführt, damit der
    -- CHECK unten sie sehen kann; `fk_expense_claim_items_submitter_claim` hält
    -- sie mit ihrer Quelle zusammen (rules.md Abschnitt 1, ausdrückliche
    -- Ausnahme). Ohne sie stünde die einzige Kontrolle des einzigen Prozesses,
    -- in dem Geld an Mitarbeitende geht, in keiner Zeile.
    submitter_employee_id uuid,
    claim_type            text NOT NULL,
    payment_route         text NOT NULL,
    amount_cents          integer NOT NULL,
    -- Vorgeschlagen aus der Vorlage oder von der Hand, die den Beleg angelegt
    -- hat; die Führungskraft bestätigt oder ändert.
    cost_project_id       integer,
    -- „Vor dem Buchen darf sie das Buchungskonto berichtigen, das Projekt nicht."
    ledger_account_id     integer,
    -- „‚im Budget ja/nein' ist eine Feststellung, keine Schranke."
    within_budget         boolean,
    internal_note         text,
    approved_at           timestamptz,
    -- „jede Korrektur, Ablehnung und Stornierung trägt eine Pflichtbegründung"
    -- (12) — die Ablehnung hier, die Stornierung am Beleg (`voided_reason`),
    -- die Weiterleitung als vierte aus demselben Satz des Ablaufs.
    rejected_at           timestamptz,
    rejected_reason       text,
    -- 12, Schritt 2: „korrigieren (Angaben oder Betrag ändern, Grund Pflicht)".
    -- Sie steht neben und nicht in `ck_expense_claim_items_decision`, weil sie
    -- nichts entscheidet: „Zwei Wege davor entscheiden nichts, sie ändern nur,
    -- worüber und wer entschieden wird" — ein korrigierter Teil wird danach
    -- freigegeben oder abgelehnt wie jeder andere. Der Zeitpunkt ist der der
    -- letzten Korrektur; die Abfolge trägt die Änderungsspur
    -- (querschnitt-schema.sql), die Alt- und Neuwert je Feld hält.
    corrected_at          timestamptz,
    corrected_reason      text,
    -- Gesetzt, wenn dieser Teil an eine andere Führungskraft ging; die neue
    -- Zeile trägt sie, diese bleibt als Spur stehen.
    forwarded_at          timestamptz,
    forwarded_reason      text,
    -- Der Zeitpunkt der letzten Handlung, nicht des Einreichens: „Ein gestern
    -- freigegebener Beleg liegt seit einem Tag bei der Buchhaltung."
    last_action_at        timestamptz NOT NULL DEFAULT now(),
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_expense_claim_items PRIMARY KEY (expense_claim_item_id),
    CONSTRAINT fk_expense_claim_items_claim
        FOREIGN KEY (expense_claim_id) REFERENCES expense_claims (expense_claim_id) ON DELETE CASCADE,
    CONSTRAINT fk_expense_claim_items_submitter_claim
        FOREIGN KEY (expense_claim_id, submitter_employee_id, claim_type, payment_route)
        REFERENCES expense_claims (expense_claim_id, submitter_employee_id, claim_type, payment_route)
        ON DELETE CASCADE,
    -- Damit der Einreicher hier mit dem Beleg zugleich leer wird, wenn sein
    -- Mitarbeitendeneintrag geht — sonst liefe die Kopie ihrer Quelle nach.
    CONSTRAINT fk_expense_claim_items_submitter
        FOREIGN KEY (submitter_employee_id) REFERENCES employees (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_expense_claim_items_approver
        FOREIGN KEY (approver_employee_id) REFERENCES employees (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT ck_expense_claim_items_approver
        CHECK (approver_employee_id IS NOT NULL
               OR (approver_employee_name IS NOT NULL AND approver_employee_name <> '')),
    CONSTRAINT fk_expense_claim_items_project
        FOREIGN KEY (cost_project_id) REFERENCES cost_projects (cost_project_id),
    CONSTRAINT fk_expense_claim_items_account
        FOREIGN KEY (ledger_account_id) REFERENCES ledger_accounts (ledger_account_id),
    -- Ein Teil ist freigegeben, abgelehnt, weitergeleitet oder offen — nie
    -- zweierlei zugleich.
    CONSTRAINT ck_expense_claim_items_decision
        CHECK (num_nonnulls(approved_at, rejected_at, forwarded_at) <= 1),
    CONSTRAINT ck_expense_claim_items_rejected
        CHECK ((rejected_at IS NULL) = (rejected_reason IS NULL)),
    -- „Grund Pflicht" (12, Schritt 2): dieselbe Bauform wie bei Ablehnung und
    -- Weiterleitung. Es ist der einzige Weg im Haus, auf dem jemand einen
    -- fremden Betrag ändert, ohne dass der Einreicher zustimmt — „Zum
    -- Einreicher zurück geht nichts".
    CONSTRAINT ck_expense_claim_items_corrected
        CHECK ((corrected_at IS NULL) = (corrected_reason IS NULL)),
    CONSTRAINT ck_expense_claim_items_forwarded
        CHECK ((forwarded_at IS NULL) = (forwarded_reason IS NULL)),
    -- Freigegeben heißt: mit Projekt, denn „wem die Ausgabe gehört, bleibt die
    -- Entscheidung der Führungskraft".
    CONSTRAINT ck_expense_claim_items_approved
        CHECK (approved_at IS NULL OR cost_project_id IS NOT NULL),
    -- 12: „Die eigene Person ist als Führungskraft wählbar, außer das Geld geht
    -- an ihn selbst: Wer sich etwas erstatten lässt, gibt es nicht selbst frei,
    -- und dieselbe Sperre gilt fürs Weiterleiten und Aufteilen … Weil eine
    -- Fahrtkostenabrechnung immer eine Erstattung ist, trifft sie das
    -- ausnahmslos." Am Teil und nicht am Beleg, weil Weiterleiten und Aufteilen
    -- je eine eigene Zeile erzeugen und der Umweg sonst offen bliebe. Ist der
    -- Mitarbeitendeneintrag des Einreichers fort, greift sie nicht mehr — dann
    -- ist auch die Führungskraft nur noch ein Name.
    CONSTRAINT ck_expense_claim_items_self_approval
        CHECK (approver_employee_id IS NULL
               OR submitter_employee_id IS NULL
               OR approver_employee_id <> submitter_employee_id
               OR (claim_type <> 'travel' AND payment_route <> 'to_me')),
    CONSTRAINT ck_expense_claim_items_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Warteschlange je Führungskraft und ihr Alter.
CREATE INDEX ix_expense_claim_items_waiting
    ON expense_claim_items (approver_employee_id, last_action_at)
    WHERE approved_at IS NULL AND rejected_at IS NULL AND forwarded_at IS NULL;

-- Herkunft: 12 (Rechnungsfreigabe) — „Bei Fahrtkosten: Datum der Fahrt,
-- Abfahrts- und Ankunftsort, Zweck — dann entweder Ticketbetrag samt Beleg oder
-- die Strecke, die mit dem Kilometersatz multipliziert wird." Löschanker: geht
-- mit dem Beleg. Eigene Tabelle statt sechs immer leerer Spalten an jeder
-- Rechnung (rules.md Abschnitt 7).
CREATE TABLE travel_details (
    travel_detail_id  uuid NOT NULL DEFAULT gen_random_uuid(),
    expense_claim_id  uuid NOT NULL,
    travelled_on      date NOT NULL,
    -- Der Betrag des Belegs, hier mitgeführt, damit der CHECK unten ihn gegen
    -- seine Herkunft halten kann: „entweder Ticketbetrag samt Beleg oder die
    -- Strecke, die mit dem Kilometersatz multipliziert wird" (12). Ohne ihn
    -- stand der Betrag an `expense_claims` neben seiner eigenen Ableitung und
    -- war an nichts gebunden — 9.999,99 € über 1 km gingen durch. Der
    -- zusammengesetzte Fremdschlüssel hält ihn an der Belegzeile fest (rules.md
    -- Abschnitt 1, Ausnahme) und ist damit der einzige seiner Art in diesen
    -- vierzehn Dateien: Er bindet zwei Zeilen, die denselben einen Betrag
    -- tragen, und nicht eine Summe an einen Summanden.
    amount_cents      integer NOT NULL,
    origin            text NOT NULL,
    destination       text NOT NULL,
    -- Entweder Ticketbetrag oder Strecke; „im zweiten Fall gibt es keinen
    -- Anhang, weil es keinen gibt".
    ticket_amount_cents integer,
    distance_km       integer,
    -- Der Kilometersatz, der zum Einreichen galt; er steht als Wert im System
    -- und wird hier festgehalten, weil eine spätere Änderung nichts umrechnet.
    mileage_rate_cents integer,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_travel_details PRIMARY KEY (travel_detail_id),
    CONSTRAINT fk_travel_details_claim
        FOREIGN KEY (expense_claim_id, amount_cents)
        REFERENCES expense_claims (expense_claim_id, amount_cents) ON DELETE CASCADE,
    CONSTRAINT uq_travel_details UNIQUE (expense_claim_id),
    CONSTRAINT ck_travel_details_origin      CHECK (origin <> ''),
    CONSTRAINT ck_travel_details_destination CHECK (destination <> ''),
    -- Ticket oder Strecke, nie beides und nie keines.
    CONSTRAINT ck_travel_details_mode
        CHECK ((ticket_amount_cents IS NOT NULL) <> (distance_km IS NOT NULL)),
    -- Nach Strecke gerechnet heißt: mit dem Satz, der damals galt.
    CONSTRAINT ck_travel_details_rate
        CHECK ((distance_km IS NULL) = (mileage_rate_cents IS NULL)),
    -- „die Strecke ist auf 2000 km je Fahrt begrenzt".
    CONSTRAINT ck_travel_details_distance CHECK (distance_km BETWEEN 1 AND 2000),
    -- Der Betrag ist genau das eine oder das andere und nichts dazwischen (12).
    -- Der Fremdschlüssel oben bindet ihn an den Beleg, dieser CHECK an seine
    -- Herkunft; erst beide zusammen schließen die Lücke.
    CONSTRAINT ck_travel_details_amount
        CHECK (amount_cents = coalesce(ticket_amount_cents,
                                       distance_km * mileage_rate_cents)),
    CONSTRAINT ck_travel_details_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 12 (Rechnungsfreigabe) — „Der angehängte Beleg selbst ist das
-- Dokument … Anhänge lassen sich nach dem Absenden nicht austauschen." Löschanker:
-- keiner — die Anhänge bleiben in SharePoint, „was danach mit einem Jahrgang
-- geschieht, entscheidet die Geschäftsführung von Hand". Bewusst KEINE Q2-Zeile:
-- Q2 trägt Dokumente mit Kindbezug, ein Kassenzettel hat keinen.
-- Die Anhänge liegen in einer eigenen Site mit eigenen Rechten, getrennt von
-- der Schülerakte: „Sekretariat und Schulleitung haben hier keine
-- Sonderstellung — abweichend von der Standardantwort sehen sie nur ihre
-- eigenen Belege und die, die auf sie zeigen" (12) — in der Bibliothek der
-- Akte sähen beide alles. Im Schema ist das eine zweite Zeile in `sharepoint_libraries`
-- und sonst nichts.
-- Dass bei der Rechnung „mindestens ein angehängter Beleg (alles Pflicht)"
-- dabei ist, prüft die Anwendung: die Zeile hier entsteht nach dem Beleg, und
-- die Fahrt nach Strecke hat gar keinen — „im zweiten Fall gibt es keinen
-- Anhang, weil es keinen gibt" (12).
CREATE TABLE expense_claim_attachments (
    expense_claim_attachment_id uuid NOT NULL DEFAULT gen_random_uuid(),
    expense_claim_id            uuid NOT NULL,
    sharepoint_library_id       integer NOT NULL,
    graph_item_id               text NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    created_by                  text NOT NULL,

    CONSTRAINT pk_expense_claim_attachments PRIMARY KEY (expense_claim_attachment_id),
    CONSTRAINT fk_expense_claim_attachments_claim
        FOREIGN KEY (expense_claim_id) REFERENCES expense_claims (expense_claim_id) ON DELETE CASCADE,
    CONSTRAINT fk_expense_claim_attachments_library
        FOREIGN KEY (sharepoint_library_id) REFERENCES sharepoint_libraries (sharepoint_library_id),
    CONSTRAINT uq_expense_claim_attachments UNIQUE (sharepoint_library_id, graph_item_id),
    CONSTRAINT ck_expense_claim_attachments_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------
-- Keine. Block 12 lässt nichts offen, was das Schema betrifft; die
-- Belegerkennung aus dem Foto ist ausdrücklich „ein eigenes Vorhaben" und trägt
-- heute keine Spalte.
