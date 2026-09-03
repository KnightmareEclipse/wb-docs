-- Akademie (Domäne 6, zweiter Teil) — AG, Kurs und Reihe als ein Angebot.
-- Lesepfad: `academy_categories` gliedert das Verzeichnis, `academy_offerings`
-- trägt das einzelne Angebot samt Zeitraum, Platzzahl und Beträgen; daran
-- hängen seine Verantwortlichen (`academy_offering_leads`) und seine Zielgruppe
-- (`academy_offering_audiences`), freigegeben wird es von einer Person aus
-- `academy_approvers`. Angemeldet wird zum Angebot als Ganzem
-- (`academy_registrations`) — je Kind oder, im Erwachsenen-Zweig, je Person —,
-- und der Kostenübernahme-Code (`academy_cost_coverage_codes`) tritt dort an
-- die Stelle der Zahlung.
--
-- Setzt stammdaten-schema.sql, querschnitt-schema.sql und anmeldung-schema.sql
-- voraus; die letzte, weil der Trigger unten den laufenden Hortvertrag liest.
-- Bewusst KEINE Angebotsart und KEINE Terminliste: „Eine Angabe ‚Art des
-- Angebots' gibt es deshalb nicht … wer die drei Fälle unterscheiden will,
-- liest den Zeitraum", und „angemeldet wird zum Angebot als Ganzem" (21).
-- Bewusst KEINE Gesundheitsangaben, kein Fotoeinverständnis und keine
-- Betreuungsanmerkung: „Der Gesundheitsbestand wird hier nicht geführt", aber
-- über diese Domäne erhoben — bei einem fremden Kind entsteht er mit der
-- Anmeldung, bei einem Kind der Schule geben die Eltern den vorhandenen Bestand
-- „für dieses Angebot frei" (21). Wohin diese Freigabe zeigt, steht noch nicht:
-- `gesundheit-schema.sql` kennt heute die zwei dauerhaften Sichtkreise `school`
-- und `care`, und „was noch fehlt, ist der Anlassgeber" — die Akademie ist einer
-- von zwei Anlässen, die auf ihn warten. Die eigene Frist des fremden Kindes
-- steht bis dahin in ferien-schema.sql; hier rechnet sie vom Ende des letzten
-- Angebots.
-- Bewusst KEINE Warteliste und kein Nachrücken: „ist ein Angebot voll, ist es
-- voll", und ein Nein gibt es nicht als Eintrag.


-- ---------------------------------------------------------------------------
-- Kategorie, Angebot und sein Zuschnitt
-- ---------------------------------------------------------------------------

-- Herkunft: 21 (Akademie) — „Die Kategorie ist ein Wert im System, gepflegt von
-- der Geschäftsführung. Sie gliedert das Verzeichnis und sonst nichts: An ihr
-- hängt kein Ablauf, keine Berechtigung und kein Preis." Kein Löschanker: keine
-- Personendaten. Bewusst OHNE Anfangsbestand (Betreiber, 03.09.2026): Welche
-- Kategorien es gibt, ist noch nicht entschieden — und weil sie am Angebot
-- Pflicht ist, braucht das erste Angebot die erste Kategorie.
CREATE TABLE academy_categories (
    academy_category_id integer GENERATED ALWAYS AS IDENTITY,
    -- Der Code ist die Verankerung im Anwendungscode und wird nie umbenannt;
    -- der Name darf jederzeit wandern (rules.md Abschnitt 3).
    code                text NOT NULL,
    name                text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus jedem
    -- Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn zeigt
    -- (rules.md Abschnitt 3).
    is_active           boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    created_by          text NOT NULL,

    CONSTRAINT pk_academy_categories      PRIMARY KEY (academy_category_id),
    CONSTRAINT uq_academy_categories_code UNIQUE (code),
    CONSTRAINT ck_academy_categories_code CHECK (code <> ''),
    CONSTRAINT ck_academy_categories_name CHECK (name <> ''),
    CONSTRAINT ck_academy_categories_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 21 (Akademie) — „Ein Angebot trägt damit eine Kategorie, ein Thema,
-- einen Zeitraum, eine Zielgruppe, eine Platzzahl, einen Betrag und ein
-- Anmeldefenster." Löschanker: keiner, keine Personendaten — „ein abgesagtes
-- Angebot bleibt sichtbar stehen, damit hinterher unterscheidbar ist, ob es
-- lief oder ausfiel". Bewusst KEINE Bilder und kein öffentlicher Text daneben:
-- „Bilder zur Ausschreibung gehören zum öffentlichen Teil des Portals und nicht
-- zum Angebot"; die Ausschreibung selbst sind Titel und Beschreibung hier.
CREATE TABLE academy_offerings (
    academy_offering_id uuid NOT NULL DEFAULT gen_random_uuid(),
    academy_category_id integer NOT NULL,
    -- „Zwei Zweige unter einem Dach: Seminarangebote für Erwachsene und
    -- Kursangebote für Kinder und Jugendliche" (Geschäftsführung, 03.09.2026).
    -- Der Zweig ist keine Angebotsart, sondern sagt, woran die Anmeldung hängt:
    -- am Kind oder an einer Person. Er steht deshalb hier und wird von
    -- `uq_academy_offerings_id_branch` an die Anmeldung gebunden.
    -- [A!] Die beiden Zweige sind eine Domäne mit einem Häkchen. —
    -- Alternative: eine eigene Domäne für die Erwachsenen-Seminare; Preis: jede
    -- Tabelle dieser Datei stünde zweimal, obwohl beide Zweige jeden Schritt
    -- von 21 teilen und sich allein im Teilnehmer unterscheiden.
    for_adults          boolean NOT NULL DEFAULT false,
    -- Das Thema: Titel und Beschreibung sind die Ausschreibung und „für alle
    -- sichtbar, auch ohne Anmeldung".
    title               text NOT NULL,
    description         text,
    -- Der Zeitraum trägt allein, was andere Systeme in einer Angebotsart
    -- führen: ein Tag beim Einzeltermin, erster bis letzter Tag bei Reihe und
    -- Schuljahr.
    starts_on           date NOT NULL,
    ends_on             date NOT NULL,
    -- „In Worten, wann es stattfindet" — „dienstags 14–15 Uhr". Freiwillig:
    -- beim Einzeltermin sagt der Zeitraum es schon.
    schedule_text       text,
    -- „Der Chor ist für die eigenen Kinder, die Kochwerkstatt für alle" — hier
    -- je Angebot statt je Terminart wie im Ferienprogramm
    -- (`ferien-schema.sql`). Gilt nur im Kinder-Zweig; im Erwachsenen-Zweig ist
    -- jeder Teilnehmer schulfremd. Durchgesetzt wird es vom Trigger unten,
    -- weil „bekannt" in zwei anderen Domänen steht.
    allows_external_children boolean NOT NULL DEFAULT true,
    -- Pflicht und **hart**: „Wo zwölf Kinder an sechs Herdplatten stehen, ist
    -- das dreizehnte eins zu viel, und daran ändert der Zufall zweier
    -- gleichzeitiger Anmeldungen nichts" — anders als die Platzzahl des
    -- Ferientermins, die nur anzeigt. Durchgesetzt vom Trigger unten.
    places              smallint NOT NULL,
    -- Der Betrag, den die anbietende Stelle setzt — die dritte benannte
    -- Ausnahme vom Geld-Hebel (hebel.md). Bewusst OHNE Gültigkeitstag: er
    -- gehört diesem einen Angebot und lebt nicht länger als es; was beim
    -- Absenden galt, hält die Anmeldung fest.
    amount_cents        integer NOT NULL,
    -- Der Zusatzbetrag: „für das, was an diesem einen Angebot anfällt und nicht
    -- die Gebühr ist — die Lebensmittel der Kochwerkstatt, anderswo Material,
    -- Eintritt oder Fahrt" (21). Getrennt geführt, weil ihn oft eine andere
    -- Stelle kennt als die, die die Gebühr setzt: „Bei der Kochwerkstatt weiß es
    -- die Hauswirtschaftsleitung." Er ist der Nachfolger des
    -- Ferienaufschlags, wird zur Gebühr addiert statt daneben berechnet, und
    -- ist meistens null. Sein Etikett sagt, wofür er ist: Ein zweiter Betrag
    -- ohne Namen stünde in der Ausschreibung, ohne dass jemand ihn erklären
    -- könnte. Deshalb ist es Pflicht, sobald er nicht null ist — und bleibt
    -- leer, wo es ihn nicht gibt.
    surcharge_cents     integer NOT NULL DEFAULT 0,
    surcharge_label     text,
    -- Im Preis enthalten und nie gesondert berechnet; wo es gesetzt ist, steht
    -- das Kind an diesem Tag auf der Mensaliste (11) — dieselbe Bedeutung wie
    -- vormals am Ferienmodul.
    includes_lunch      boolean NOT NULL DEFAULT false,
    registration_opens_at  timestamptz NOT NULL,
    -- Das gesetzte Datum; jederzeit vorziehbar oder verschiebbar wie das des
    -- Ferienprogramms (10).
    registration_closes_at timestamptz,
    -- „Schließt die Anmeldung — zum gesetzten Datum oder jederzeit von Hand."
    closed_at           timestamptz,
    -- Die Sperre der Eltern als Zahl und Uhrzeit: „bis 9 Uhr am Kurstag
    -- kostenlos" ist null Tage und 09:00, „bis 3 Tage davor" drei Tage ohne
    -- Uhrzeit. Gezählt wird zum ersten Tag des Angebots. **Leere Uhrzeit heißt
    -- 0 Uhr** — der ganze Fristtag ist dann gesperrt; leere Tageszahl heißt
    -- „keine Sperre". Den Eltern wird nie der Abstand gezeigt, sondern der
    -- daraus gerechnete Termin.
    cancellation_deadline_days smallint,
    cancellation_deadline_time time,
    -- Der Code des Textes, unter dem die Abmeldebedingungen dieses Angebots in
    -- `contract_texts` (querschnitt-schema.sql) stehen — nicht der Text selbst,
    -- damit er einen Gültigkeitstag trägt und eine angekündigte Fassung neben
    -- der geltenden stehen kann (hebel.md). Das System rechnet aus ihm nichts:
    -- Es zeigt ihn, und die anbietende Stelle trägt den einbehaltenen Betrag
    -- ein.
    cancellation_terms_code text NOT NULL,
    -- Die Freigabe: „Bis zur Freigabe steht das Angebot nirgends … und niemand
    -- kann sich anmelden." Zwei Zeitpunkte tragen die drei Zustände
    -- (grenzkarte.md, „Drei Zustände"): freigegeben, mit einem Satz
    -- zurückgegeben, oder noch nicht entschieden. Wer zurückgegeben bekommt,
    -- legt geändert wieder vor — dann wird `returned_at` geleert. Ist die
    -- Freigabe abgeschaltet (`configured_values`, ein Wert im System und kein
    -- fest verdrahteter Schritt), setzt sie der Lauf selbst mit `system:`.
    -- „Sie erfährt davon als Aufgabe" (21 Z2) — die Aufgabe ist keine Zeile in
    -- `sync_tasks`, sondern folgt aus diesen beiden Spalten: offen ist, was
    -- weder freigegeben noch zurückgegeben ist. Dieselbe Form wie die beiden
    -- Putzdienst-Aufgaben, die aus `allocation_released_at` und
    -- `attendance_recorded_at` folgen (querschnitt-schema.sql).
    approved_at         timestamptz,
    approved_by         text,
    returned_at         timestamptz,
    return_reason       text,
    -- „Umgekehrt sagt auch sie ab — eine einzelne Anmeldung oder das ganze
    -- Angebot samt Grund in einem Satz" (21). Hier steht die Absage des ganzen
    -- Angebots; die der einzelnen Anmeldung ist ihre Abmeldung, eingetragen von
    -- der anbietenden Stelle. Die Zeile bleibt stehen.
    cancelled_at        timestamptz,
    cancellation_reason text,
    created_at          timestamptz NOT NULL DEFAULT now(),
    created_by          text NOT NULL,

    CONSTRAINT pk_academy_offerings PRIMARY KEY (academy_offering_id),
    CONSTRAINT fk_academy_offerings_category
        FOREIGN KEY (academy_category_id) REFERENCES academy_categories (academy_category_id),
    -- Trägt den zusammengesetzten Fremdschlüssel der Anmeldung: er bindet den
    -- Zweig des Angebots an den Teilnehmer (rules.md Abschnitt 1).
    CONSTRAINT uq_academy_offerings_id_branch UNIQUE (academy_offering_id, for_adults),
    CONSTRAINT ck_academy_offerings_title       CHECK (title <> ''),
    CONSTRAINT ck_academy_offerings_description CHECK (description <> ''),
    CONSTRAINT ck_academy_offerings_schedule    CHECK (schedule_text <> ''),
    CONSTRAINT ck_academy_offerings_terms       CHECK (cancellation_terms_code <> ''),
    CONSTRAINT ck_academy_offerings_period      CHECK (ends_on >= starts_on),
    CONSTRAINT ck_academy_offerings_window
        CHECK (registration_closes_at IS NULL OR registration_closes_at > registration_opens_at),
    CONSTRAINT ck_academy_offerings_places  CHECK (places > 0),
    CONSTRAINT ck_academy_offerings_amount  CHECK (amount_cents >= 0),
    CONSTRAINT ck_academy_offerings_surcharge CHECK (surcharge_cents >= 0),
    CONSTRAINT ck_academy_offerings_surcharge_label
        CHECK ((surcharge_cents > 0) = (surcharge_label IS NOT NULL)
               AND surcharge_label <> ''),
    -- Eine Uhrzeit ohne Tageszahl beschriebe eine Frist, die es nicht gibt.
    CONSTRAINT ck_academy_offerings_deadline
        CHECK (cancellation_deadline_time IS NULL OR cancellation_deadline_days IS NOT NULL),
    CONSTRAINT ck_academy_offerings_deadline_days
        CHECK (cancellation_deadline_days IS NULL OR cancellation_deadline_days >= 0),
    CONSTRAINT ck_academy_offerings_approved
        CHECK ((approved_at IS NULL) = (approved_by IS NULL)),
    -- „Wer zurückgibt, sagt warum" — und ein zurückgegebenes Angebot ist nicht
    -- zugleich freigegeben.
    CONSTRAINT ck_academy_offerings_returned
        CHECK ((returned_at IS NULL) = (return_reason IS NULL)),
    CONSTRAINT ck_academy_offerings_return_reason CHECK (return_reason <> ''),
    CONSTRAINT ck_academy_offerings_decision
        CHECK (approved_at IS NULL OR returned_at IS NULL),
    CONSTRAINT ck_academy_offerings_cancellation
        CHECK ((cancelled_at IS NULL) = (cancellation_reason IS NULL)),
    CONSTRAINT ck_academy_offerings_cancellation_reason CHECK (cancellation_reason <> ''),
    -- Freigegeben wird von einer benannten Person oder, wo die Freigabe
    -- abgeschaltet ist, vom Lauf.
    CONSTRAINT ck_academy_offerings_approved_by CHECK (approved_by ~ '^(entra:|system:)'),
    -- „Anlegen darf jede und jeder Mitarbeitende" — Eltern nicht.
    CONSTRAINT ck_academy_offerings_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 21 (Akademie) — „Eine neue Rolle entsteht dafür nicht; wer ein
-- Angebot führt, ist an ihm benannt", eine oder mehrere Personen und jederzeit
-- änderbar (Betreiber, 03.09.2026). An ihnen hängt, wer die Teilnehmerliste
-- sieht, wer den Gesundheitsausschnitt bekommt und wer die Löschankündigung
-- erhält (hebel.md). Löschanker: geht mit dem Angebot und mit der
-- Mitarbeitendenzeile. Eine Rolle stünde hier nicht: Sie träfe alle, die sie
-- tragen, und der Kreis ist je Angebot ein anderer.
CREATE TABLE academy_offering_leads (
    academy_offering_lead_id uuid NOT NULL DEFAULT gen_random_uuid(),
    academy_offering_id      uuid NOT NULL,
    -- Die Mitarbeitendenzeile und nicht die Person: „die Hauswirtschaftsleitung
    -- ihre Kochwerkstatt, eine Lehrkraft ihren Chor" — dieselbe Form wie die
    -- gewählte Führungskraft am Beleg (rechnungsfreigabe-schema.sql).
    employee_id              uuid NOT NULL,
    created_at               timestamptz NOT NULL DEFAULT now(),
    created_by               text NOT NULL,

    CONSTRAINT pk_academy_offering_leads PRIMARY KEY (academy_offering_lead_id),
    CONSTRAINT fk_academy_offering_leads_offering
        FOREIGN KEY (academy_offering_id)
        REFERENCES academy_offerings (academy_offering_id) ON DELETE CASCADE,
    CONSTRAINT fk_academy_offering_leads_employee
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id) ON DELETE CASCADE,
    CONSTRAINT uq_academy_offering_leads UNIQUE (academy_offering_id, employee_id),
    CONSTRAINT ck_academy_offering_leads_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 21 (Akademie) — „Wen es anspricht — derselbe Zuschnitt wie beim
-- Einsatz des Elternbonus (14): ohne Angabe alle, mit Angabe benannte Klassen
-- und Zuschnitte aus Schulart und Stufenspanne nebeneinander. Ein zweiter
-- Mechanismus dafür entsteht nicht." Bauform, Begründung und Zeitverhalten
-- stehen an `parent_work_session_audiences` (elternbonus-schema.sql) und werden
-- hier nicht wiederholt. Löschanker: geht mit dem Angebot und mit der Klasse.
-- Im Erwachsenen-Zweig bleibt sie leer: „ohne Angabe alle" — eine Klasse trifft
-- dort niemanden.
CREATE TABLE academy_offering_audiences (
    academy_offering_audience_id uuid NOT NULL DEFAULT gen_random_uuid(),
    academy_offering_id uuid NOT NULL,
    -- Entweder diese eine Klasse …
    class_id            integer,
    -- … oder ein Zuschnitt: Schulart, Stufe ab, Stufe bis — jedes für sich
    -- freiwillig, aber mindestens eines davon.
    school_branch_id    integer,
    grade_from          smallint,
    grade_to            smallint,
    created_at          timestamptz NOT NULL DEFAULT now(),
    created_by          text NOT NULL,

    CONSTRAINT pk_academy_offering_audiences PRIMARY KEY (academy_offering_audience_id),
    CONSTRAINT fk_academy_offering_audiences_offering
        FOREIGN KEY (academy_offering_id)
        REFERENCES academy_offerings (academy_offering_id) ON DELETE CASCADE,
    CONSTRAINT fk_academy_offering_audiences_class
        FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE,
    CONSTRAINT fk_academy_offering_audiences_branch
        FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    CONSTRAINT uq_academy_offering_audiences
        UNIQUE NULLS NOT DISTINCT (academy_offering_id, class_id, school_branch_id,
                                   grade_from, grade_to),
    CONSTRAINT ck_academy_offering_audiences_form
        CHECK ((class_id IS NOT NULL
                AND school_branch_id IS NULL AND grade_from IS NULL AND grade_to IS NULL)
               OR (class_id IS NULL
                   AND num_nonnulls(school_branch_id, grade_from, grade_to) > 0)),
    CONSTRAINT ck_academy_offering_audiences_grades
        CHECK (grade_from IS NULL OR grade_to IS NULL OR grade_to >= grade_from),
    CONSTRAINT ck_academy_offering_audiences_created_by
        CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 21 (Akademie) — „Bei der freigebenden Stelle die Freigabe — die
-- einzige Entscheidung in diesem Block, die einen Vorgang anhält." Wer das ist,
-- sind benannte Personen und keine Rolle (Geschäftsführung, 03.09.2026): Eine
-- Rolle träfe alle, die sie tragen, hier prüft eine benannte Person Rahmen und
-- Wording. Löschanker: geht mit der Mitarbeitendenzeile. Bewusst KEINE Zuordnung
-- je Angebot oder Kategorie: „eine zentrale Person prüft", nicht die jeweilige
-- Leitung.
-- [A!] Die Freigabeberechtigung steht als Personenliste und nicht als Rolle. —
-- Alternative: eine neue Rolle, wie hebel.md es sonst verlangt („Rechte je
-- Person gibt es nicht"); Preis: sie träfe jeden, der sie trägt, und die
-- Entscheidung vom 03.09.2026 will genau das nicht.
CREATE TABLE academy_approvers (
    academy_approver_id integer GENERATED ALWAYS AS IDENTITY,
    employee_id         uuid NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    created_by          text NOT NULL,

    CONSTRAINT pk_academy_approvers PRIMARY KEY (academy_approver_id),
    CONSTRAINT fk_academy_approvers_employee
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id) ON DELETE CASCADE,
    CONSTRAINT uq_academy_approvers UNIQUE (employee_id),
    CONSTRAINT ck_academy_approvers_created_by CHECK (created_by ~ '^(entra:|system:)')
);


-- ---------------------------------------------------------------------------
-- Kostenübernahme und Anmeldung
-- ---------------------------------------------------------------------------

-- Herkunft: 21 (Akademie) — „Sekretariat oder anbietende Stelle erzeugt einen
-- Kostenübernahme-Code für eine Mailadresse und ein Angebot, dazu ein Satz, an
-- wen berechnet wird; er tritt an die Stelle der Zahlung, gilt für diese eine
-- Anmeldung und verfällt nach 14 Tagen." Derselbe Mechanismus wie im
-- Ferienprogramm; Begründung von Ablauf und Einlösen steht an
-- `holiday_cost_coverage_codes` (ferien-schema.sql) und wird hier nicht
-- wiederholt. Löschanker: nicht eingelöst mit seiner Frist, eingelöst mit
-- seiner Anmeldung.
CREATE TABLE academy_cost_coverage_codes (
    academy_cost_coverage_code_id uuid NOT NULL DEFAULT gen_random_uuid(),
    academy_offering_id           uuid NOT NULL,
    -- Gilt nur für die Adresse, für die er erzeugt wurde; eine Familie muss es
    -- dafür noch nicht geben.
    email                         text NOT NULL,
    code_hash                     text NOT NULL,
    -- „ein Satz, an wen berechnet wird" — Landratsamt oder Jugendamt.
    invoice_note                  text NOT NULL,
    created_at                    timestamptz NOT NULL DEFAULT now(),
    created_by                    text NOT NULL,

    CONSTRAINT pk_academy_cost_coverage_codes PRIMARY KEY (academy_cost_coverage_code_id),
    CONSTRAINT fk_academy_cost_coverage_codes_offering
        FOREIGN KEY (academy_offering_id) REFERENCES academy_offerings (academy_offering_id),
    -- Trägt den zusammengesetzten Fremdschlüssel der Anmeldung: er bindet den
    -- Code an das Angebot, für das er erzeugt wurde (rules.md Abschnitt 1).
    CONSTRAINT uq_academy_cost_coverage_codes_id_offering
        UNIQUE (academy_cost_coverage_code_id, academy_offering_id),
    CONSTRAINT ck_academy_cost_coverage_codes_email CHECK (email <> ''),
    CONSTRAINT ck_academy_cost_coverage_codes_note  CHECK (invoice_note <> ''),
    CONSTRAINT ck_academy_cost_coverage_codes_created_by
        CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 21 (Akademie) — „Je Anmeldung das Kind — im Erwachsenen-Zweig die
-- teilnehmende Person —, das Angebot, der Betrag als das, was beim Absenden galt
-- …, der Zahlweg … und, bei einer Abmeldung, der Tag der Erklärung, wer sie
-- abgegeben hat, der Tag des Eintrags und der berechnete Betrag; die Anmeldung
-- bleibt stehen und gilt als abgemeldet." Löschanker: das
-- Ende des letzten Angebots dieses Teilnehmers und **sechs Monate danach** —
-- dieselbe Frist wie die Ferienbuchung, und für die Teilnehmer der
-- Erwachsenen-Seminare dieselbe wie für schulfremde Kinder
-- (Datenschutzbeauftragter, 02.09.2026; `fragen.md`).
-- **Diese Zeile ist der einzige Anker ihres Teilnehmers**, wo er sonst keinen
-- hat: Ein Kind, das allein über ein Angebot in den Bestand kam, hat kein
-- Austrittsdatum, und die erwachsene Teilnehmerin hat überhaupt keine
-- Rollenzeile — `persons` trägt „keinen eigenen [Anker]" und wartet auf seine
-- Rollenanker (stammdaten-schema.sql). Beide gehen deshalb mit ihrer letzten
-- Anmeldung, wie das schulfremde Kind mit seiner letzten Ferienbuchung
-- (ferien-schema.sql); der Lösch-Lauf räumt sie in Stufe 1 und kommt damit in
-- Stufe 2 und 6 an ihnen vorbei (querschnitt-schema.sql).
-- Bewusst KEIN Verweis auf das SEPA-Mandat: Das Mandat steht am Kind und wird
-- abgelöst, welcher Weg gegangen wurde, sagt der Zahlweg.
CREATE TABLE academy_registrations (
    academy_registration_id uuid NOT NULL DEFAULT gen_random_uuid(),
    academy_offering_id     uuid NOT NULL,
    -- Der Zweig des Angebots, hier mitgeführt, damit der CHECK unten ihn sehen
    -- kann; `fk_academy_registrations_offering` hält ihn mit seiner Quelle
    -- zusammen (rules.md Abschnitt 1). Ohne ihn ginge die Anmeldung eines
    -- Kindes zu einem Erwachsenen-Seminar durch.
    for_adults              boolean NOT NULL DEFAULT false,
    -- Im Kinder-Zweig das Kind, im Erwachsenen-Zweig die Person: „dort ein Kind,
    -- hier die erwachsene Person selbst, die sich anmeldet und für die keine
    -- Familie entsteht" (21). Genau eine der beiden Spalten steht, und welche,
    -- sagt der Zweig. Der Erwachsenen-Zweig kommt dabei mit dem aus, was
    -- `persons` trägt: „Ein Geburtsdatum wird von ihr nicht erhoben" (21) —
    -- Stammdaten führen es am Kind und nur dort, und der Zweig verlangt der
    -- Tabelle deshalb keine Spalte ab (Betreiber, 03.09.2026).
    child_id                uuid,
    person_id               uuid,
    -- Was beim Absenden galt — Gebühr plus Zusatzbetrag; „eine spätere
    -- Änderung rechnet nichts rückwirkend um" (hebel.md).
    amount_cents            integer NOT NULL,
    -- „Eingezogen, online bezahlt oder berechnet": eingezogen wird die Familie
    -- mit SEPA-Mandat, online zahlt die ohne, und berechnet wird, wo ein
    -- Kostenübernahme-Code an die Stelle der Zahlung tritt. Der Zahlweg folgt
    -- dem Mandat und nicht einer Wahl der Eltern.
    -- **Im Erwachsenen-Zweig gibt es keinen Einzug** (Betreiber, 03.09.2026):
    -- Das Mandat steht am Kind (`sepa_mandates`, stammdaten-schema.sql), und
    -- über es wird nichts abgebucht, was nicht dieses Kind betrifft — auch dann
    -- nicht, wenn die Teilnehmerin daneben ein Kind an der Schule hat. Sie zahlt
    -- online oder über einen Kostenübernahme-Code.
    payment_mode            text NOT NULL,
    academy_cost_coverage_code_id uuid,
    -- Die Fassung der Abmeldebedingungen, die beim Absenden galt — „sichtbar,
    -- bevor angemeldet wird"; eine Unterschrift entsteht daraus nicht.
    cancellation_terms_contract_text_id integer NOT NULL,
    -- Die Abmeldung in zwei Schritten: die Eltern erklären, die anbietende
    -- Stelle trägt ein und entscheidet über den Betrag — dieselbe Bauform wie
    -- der Ferienstorno. Sagt die Stelle selbst ab, trägt sie beide Schritte und
    -- den Betrag null: „dann gilt keine Frist und keine Gebühr".
    cancellation_declared_at timestamptz,
    cancellation_declared_by text,
    cancellation_recorded_at timestamptz,
    cancellation_recorded_by text,
    retained_amount_cents   integer,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_academy_registrations PRIMARY KEY (academy_registration_id),
    -- Bindet das Angebot an den Zweig, gegen den der Teilnehmer geprüft wird.
    CONSTRAINT fk_academy_registrations_offering
        FOREIGN KEY (academy_offering_id, for_adults)
        REFERENCES academy_offerings (academy_offering_id, for_adults),
    CONSTRAINT fk_academy_registrations_child
        FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_academy_registrations_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id),
    -- „Er … gilt für diese eine Anmeldung" (21) — und für das Angebot, für das
    -- er erzeugt wurde: Ohne diesen zusammengesetzten Schlüssel bezahlte ein
    -- Code der Kochwerkstatt den Chor.
    CONSTRAINT fk_academy_registrations_coverage_code
        FOREIGN KEY (academy_cost_coverage_code_id, academy_offering_id)
        REFERENCES academy_cost_coverage_codes (academy_cost_coverage_code_id,
                                                academy_offering_id),
    CONSTRAINT fk_academy_registrations_terms
        FOREIGN KEY (cancellation_terms_contract_text_id)
        REFERENCES contract_texts (contract_text_id),
    -- Der Zweig entscheidet, woran die Anmeldung hängt — nie an beidem und nie
    -- an keinem.
    CONSTRAINT ck_academy_registrations_participant
        CHECK ((for_adults AND person_id IS NOT NULL AND child_id IS NULL)
               OR (NOT for_adults AND child_id IS NOT NULL AND person_id IS NULL)),
    CONSTRAINT ck_academy_registrations_payment_mode
        CHECK (payment_mode IN ('direct_debit', 'paid', 'invoiced')),
    -- Der Einzug bleibt dem Kinder-Zweig: Ein Mandat des Kindes deckt den
    -- Seminarbeitrag seiner Mutter nicht.
    CONSTRAINT ck_academy_registrations_adult_payment
        CHECK (NOT for_adults OR payment_mode <> 'direct_debit'),
    -- Ein Code tritt an die Stelle der Zahlung und nur dort.
    CONSTRAINT ck_academy_registrations_coverage
        CHECK ((payment_mode = 'invoiced') = (academy_cost_coverage_code_id IS NOT NULL)),
    CONSTRAINT ck_academy_registrations_amount CHECK (amount_cents >= 0),
    CONSTRAINT ck_academy_registrations_declared
        CHECK ((cancellation_declared_at IS NULL) = (cancellation_declared_by IS NULL)),
    -- Wirksam wird die Abmeldung erst mit dem Eintrag; der einbehaltene Betrag
    -- entsteht mit ihm.
    CONSTRAINT ck_academy_registrations_recorded
        CHECK ((cancellation_recorded_at IS NULL) = (cancellation_recorded_by IS NULL)
               AND (cancellation_recorded_at IS NULL) = (retained_amount_cents IS NULL)),
    CONSTRAINT ck_academy_registrations_retained
        CHECK (retained_amount_cents IS NULL
               OR (retained_amount_cents >= 0 AND retained_amount_cents <= amount_cents)),
    CONSTRAINT ck_academy_registrations_declared_by
        CHECK (cancellation_declared_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_academy_registrations_recorded_by
        CHECK (cancellation_recorded_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_academy_registrations_created_by
        CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Teilnehmerliste je Angebot und die Zählung der belegten Plätze.
-- „Angemeldet wird zum Angebot als Ganzem" — je Angebot eine Anmeldung je
-- Teilnehmer, aber nur unter den nicht abgemeldeten: Die Anmeldung „bleibt
-- stehen und gilt als abgemeldet", und geändert wird sie nicht, sondern
-- abgemeldet und neu angemeldet. Zwei Indizes, weil der Teilnehmer im einen
-- Zweig ein Kind und im anderen eine Person ist.
CREATE UNIQUE INDEX ix_academy_registrations_active_child
    ON academy_registrations (academy_offering_id, child_id)
    WHERE cancellation_recorded_at IS NULL AND child_id IS NOT NULL;

CREATE UNIQUE INDEX ix_academy_registrations_active_person
    ON academy_registrations (academy_offering_id, person_id)
    WHERE cancellation_recorded_at IS NULL AND person_id IS NOT NULL;

-- 21: „Er … gilt für diese eine Anmeldung." Ohne diesen Schlüssel zahlt das
-- Jugendamt einmal und die Schule berechnet mehrfach. Wie am Index darüber
-- zählen die abgemeldeten Zeilen nicht mit: Wer abmeldet und neu anmeldet,
-- benutzt denselben Code für denselben Vorgang.
CREATE UNIQUE INDEX ix_academy_registrations_coverage_code
    ON academy_registrations (academy_cost_coverage_code_id)
    WHERE cancellation_recorded_at IS NULL AND academy_cost_coverage_code_id IS NOT NULL;

CREATE INDEX ix_academy_registrations_offering
    ON academy_registrations (academy_offering_id)
    WHERE cancellation_recorded_at IS NULL;

-- DER EINZIGE TRIGGER DIESES SCHEMAS, und er trägt die Regeln, die das Angebot
-- über seine Zeile hinaus stellt — dieselbe Begründung wie an
-- `enforce_parent_work_capacity` (elternbonus-schema.sql), die hier nicht
-- wiederholt wird:
--   * Die **Platzzahl ist hart** (21) und zählt fremde Zeilen; einen
--     deklarativen Weg dafür kennt Postgres nicht.
--   * **Fremde Kinder**, wo das Angebot sie nicht zulässt. „Fremd heißt hier
--     dasselbe wie in 10" (21), und dort heißt es: „bekannt ist dabei ein Kind,
--     das eingeschrieben ist (08) oder einen laufenden Hortvertrag hat (09)"
--     (10 Z3) — beides steht in anderen Tabellen, und ein CHECK sieht nur seine
--     eigene Zeile.
--   * **Was den Vorgang anhält**, sobald ein Elternteil selbst absendet: „Bis
--     zur Freigabe steht das Angebot nirgends … und niemand kann sich anmelden"
--     (21 Z2), ein abgesagtes Angebot nimmt niemanden mehr auf, das
--     Anmeldefenster gilt, und „geprüft wird, ob das Kind zur Zielgruppe gehört"
--     (21 Z4). Alle vier hängen an Zeilen, die diese nicht sieht.
-- **Für Mitarbeitende sperren die letzten vier nicht**: „Das Sekretariat
-- erledigt den Vorgang stellvertretend" und kann „jedes Datum setzen, auch eines
-- in der Vergangenheit" (hebel.md, der offizielle Umweg) — der Trigger liest das
-- am Urheber ab, wie es sonst nur der `created_by`-CHECK tut. Platzzahl und
-- fremdes Kind gelten dagegen für alle: Die eine ist eine physische Grenze, die
-- andere die Zulassung des Angebots, und für beide nennt kein Block einen Ausweg.
-- `FOR UPDATE` serialisiert die Anmeldungen je Angebot, sonst zählen zwei
-- gleichzeitige denselben freien Platz. Das Prädikat des laufenden Hortvertrags
-- ist dasselbe wie in `ex_contracts_care_period` (anmeldung-schema.sql) — zwei
-- Fassungen desselben Satzes liefen auseinander.
CREATE FUNCTION enforce_academy_registration() RETURNS trigger AS $$
DECLARE
    offering record;
    taken    bigint;
BEGIN
    SELECT places, allows_external_children, approved_at, cancelled_at, closed_at,
           registration_opens_at, registration_closes_at
      INTO offering
      FROM academy_offerings
     WHERE academy_offering_id = NEW.academy_offering_id
       FOR UPDATE;

    SELECT count(*) INTO taken
      FROM academy_registrations
     WHERE academy_offering_id = NEW.academy_offering_id
       AND cancellation_recorded_at IS NULL;

    IF taken >= offering.places THEN
        RAISE EXCEPTION 'Angebot % ist voll: % von % Plätzen belegt',
                        NEW.academy_offering_id, taken, offering.places
              USING ERRCODE = 'check_violation';
    END IF;

    IF NEW.child_id IS NOT NULL AND NOT offering.allows_external_children
       AND NOT EXISTS (SELECT 1 FROM children
                        WHERE child_id = NEW.child_id
                          AND entry_date IS NOT NULL
                          AND (exit_date IS NULL OR exit_date >= current_date))
       AND NOT EXISTS (SELECT 1 FROM contracts
                        WHERE child_id = NEW.child_id
                          AND contract_type = 'care'
                          AND released_at IS NOT NULL
                          AND daterange(admission_date, coalesce(end_date, runs_until), '[]')
                              @> current_date) THEN
        RAISE EXCEPTION 'Angebot % steht fremden Kindern nicht offen',
                        NEW.academy_offering_id
              USING ERRCODE = 'check_violation';
    END IF;

    -- Ab hier nur die Selbstanmeldung der Eltern: „wer es verpasst, ist nicht
    -- dabei, und der offizielle Umweg trägt den Einzelfall" (21). Das
    -- Sekretariat trägt stellvertretend ein und „kann jedes Datum setzen, auch
    -- eines in der Vergangenheit" (hebel.md) — für es sperrt hier nichts.
    IF NEW.created_by NOT LIKE 'guardian:%' THEN
        RETURN NEW;
    END IF;

    IF offering.approved_at IS NULL THEN
        RAISE EXCEPTION 'Angebot % ist nicht freigegeben', NEW.academy_offering_id
              USING ERRCODE = 'check_violation';
    END IF;

    IF offering.cancelled_at IS NOT NULL THEN
        RAISE EXCEPTION 'Angebot % ist abgesagt', NEW.academy_offering_id
              USING ERRCODE = 'check_violation';
    END IF;

    IF offering.closed_at IS NOT NULL
       OR now() < offering.registration_opens_at
       OR (offering.registration_closes_at IS NOT NULL
           AND now() >= offering.registration_closes_at) THEN
        RAISE EXCEPTION 'Anmeldung zu Angebot % ist nicht offen', NEW.academy_offering_id
              USING ERRCODE = 'check_violation';
    END IF;

    IF NEW.child_id IS NOT NULL
       AND EXISTS (SELECT 1 FROM academy_offering_audiences a
                    WHERE a.academy_offering_id = NEW.academy_offering_id)
       AND NOT EXISTS (
            SELECT 1
              FROM academy_offering_audiences a
              JOIN children c ON c.child_id = NEW.child_id
             WHERE a.academy_offering_id = NEW.academy_offering_id
               AND (CASE WHEN a.class_id IS NOT NULL THEN c.class_id = a.class_id
                         ELSE (a.school_branch_id IS NULL
                               OR a.school_branch_id = c.school_branch_id)
                          AND (a.grade_from IS NULL OR c.grade_level >= a.grade_from)
                          AND (a.grade_to   IS NULL OR c.grade_level <= a.grade_to)
                    END)) THEN
        RAISE EXCEPTION 'Kind % gehört nicht zur Zielgruppe von Angebot %',
                        NEW.child_id, NEW.academy_offering_id
              USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_academy_registrations_admission
    BEFORE INSERT ON academy_registrations
    FOR EACH ROW EXECUTE FUNCTION enforce_academy_registration();


-- ---------------------------------------------------------------------------
-- Fremdschlüssel von Q3 und Q5 auf diese Domäne
-- ---------------------------------------------------------------------------
-- Q5 zeigt auf die Anmeldung, weil „je Anmeldung eine Aufgabe bei der
-- Buchhaltung" entsteht (21) und mehrere davon gleichzeitig zu derselben
-- Familie offen stehen. Mit Cascade wie die übrigen Bezüge der Aufgabe.
ALTER TABLE sync_tasks
    ADD CONSTRAINT fk_sync_tasks_academy_registration
        FOREIGN KEY (academy_registration_id)
        REFERENCES academy_registrations (academy_registration_id)
        ON DELETE CASCADE;

-- Q3 zeigt auf die Anmeldung; die Spalte steht in querschnitt-schema.sql. Sie
-- entsteht nur ohne SEPA-Mandat: „Das Geld folgt dem Mandat" (21) — mit Mandat
-- wird eingezogen, und der Zahlweg an der Anmeldung sagt, welcher Weg es war.
-- Mit Cascade: „Löschanker: geht mit dem Vorgang, an dem die Zahlung hängt"
-- (querschnitt-schema.sql) — sonst hielte die Zahlung die Anmeldung fest.
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_academy_registration
        FOREIGN KEY (academy_registration_id)
        REFERENCES academy_registrations (academy_registration_id)
        ON DELETE CASCADE;
