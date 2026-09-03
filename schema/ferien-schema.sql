-- Ferienprogramm (Domäne 3) — Betreuung in den Ferien, gebucht je Tag.
-- Lesepfad: `holiday_session_types` ist die Terminart und trägt als Wert im
-- System ihre Module samt Beträgen. Ein `holiday_programme` bündelt Termine
-- (`holiday_sessions`) mit ihren Tagen; gebucht wird je Kind, Termin und Modul
-- in `holiday_bookings`. Der Kostenübernahme-Code tritt dort an die Stelle der
-- Zahlung. Dateien entstehen in dieser Domäne keine.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus.
-- Bewusst KEINE Gesundheitsangaben und kein Fotoeinverständnis als eigene
-- Tabellen hier: „Der Bestand steht am Kind (08, 09) und nirgends sonst" (10).
-- Erhoben werden sie über diese Domäne trotzdem — bei einem fremden Kind
-- entsteht der Gesundheitsbestand mit der Ferienbuchung, weil es keinen anderen
-- Weg gibt, auf dem er entstünde; bei einem Kind der Schule geben die Eltern
-- den vorhandenen Bestand für dieses Programm frei. Wohin diese Freigabe zeigt,
-- steht noch nicht: `gesundheit-schema.sql` kennt heute die zwei dauerhaften
-- Sichtkreise `school` und `care`, und „was noch fehlt, ist der Anlassgeber".
-- Die eigene Frist dieses Bestands steht seit dem 02.09.2026: **vier Wochen
-- nach dem letzten gebuchten Termin**, gerechnet vom Termin und nicht vom Ende
-- des Programms. Sie ist damit deutlich kürzer als die der Buchung selbst
-- (sechs Monate, unten) — die Gesundheitsangabe wird für den Tag gebraucht, die
-- Buchung als Nachweis darüber hinaus. Löschankündigung und Anhalten im
-- Einzelfall stehen als gemeinsamer Hebel in hebel.md; die Stellen sind hier
-- Hortleitung und Geschäftsführung — nie nur eine, damit die Ankündigung nicht
-- an einem Urlaub scheitert.
-- Bewusst KEINE Warteliste und kein Nachrücken: „Ist ein Termin zu,
-- ist er zu."


-- ---------------------------------------------------------------------------
-- Terminart und Module — Werte im System
-- ---------------------------------------------------------------------------

-- Herkunft: 10 (Ferienprogramm) — „Die Terminart ist ein Wert im System wie das
-- Betreuungsmodul in 09 und trägt dreierlei: ihre zwei Module …, ob fremde
-- Kinder zugelassen sind, und ihre Stornobedingungen als Text samt Beträgen."
-- Kein Löschanker: keine Personendaten. Bewusst KEINE Altersspanne: „Das Alter
-- ist eine Angabe im Thema des Termins, keine Regel."
CREATE TABLE holiday_session_types (
    holiday_session_type_id integer GENERATED ALWAYS AS IDENTITY,
    code                    text NOT NULL,
    name                    text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active                boolean NOT NULL DEFAULT true,
    -- 10, Schritt 3: „Geprüft wird nur eines: ob die Terminart fremden Kindern
    -- offensteht; das Alter nicht." Es ist die einzige Zulassungsregel dieser
    -- Domäne, und sie wird deshalb nicht der Route überlassen: „bekannt ist
    -- dabei ein Kind, das eingeschrieben ist (08) oder einen laufenden
    -- Hortvertrag hat (09)" steht in zwei anderen Tabellen, ein CHECK sieht nur
    -- seine eigene Zeile — sie trägt der Trigger unten, in derselben Fassung
    -- wie am Akademie-Angebot (`akademie-schema.sql`).
    -- Beide Terminarten stehen heute auf wahr: „Derzeit Ferientag und
    -- Ferienwoche … Beide stehen fremden Kindern offen, das Häkchen dafür ist
    -- heute überall gesetzt" (10). Das Häkchen unterscheidet damit vorerst
    -- nichts — es bleibt, weil der Block die Prüfung ausdrücklich benennt und
    -- weil eine geschlossene Terminart hier und nirgends sonst markiert würde.
    allows_external_children boolean NOT NULL DEFAULT true,
    -- Der Code des Textes, unter dem die Stornobedingungen dieser Terminart in
    -- `contract_texts` (querschnitt-schema.sql) stehen — nicht der Text selbst:
    -- 10 zählt sie unter dem auf, was „die Geschäftsführung … als Werte im
    -- System" pflegt, und hebel.md sagt dort „Jeder dieser Werte trägt ein
    -- Datum, ab dem er gilt … ein noch nicht gültiger lässt sich bis dahin
    -- ändern oder zurücknehmen, ein bereits gültiger nicht mehr. Beide sind
    -- sichtbar, damit eine Familie eine angekündigte Erhöhung sieht, bevor sie
    -- sich entscheidet." Als schlichte Spalte hier trügen sie keinen
    -- Gültigkeitstag und keine Fassung: eine angekündigte Erhöhung ließe sich
    -- nicht vorab eintragen, und nach einer Änderung wäre nicht mehr lesbar,
    -- was zur Buchung galt. Derselbe Weg wie bei der Nachbarangabe, den
    -- Teilnahmebedingungen (`holiday_bookings.terms_contract_text_id`).
    -- Das System rechnet aus ihnen weiterhin nichts: es zeigt sie, und die
    -- Hortleitung trägt den einbehaltenen Betrag ein. Gewählt wird die Sorte
    -- aus `contract_text_kinds` und nicht getippt (querschnitt-schema.sql).
    cancellation_terms_code text NOT NULL,
    -- Die Sperre der Eltern als Zahl und nicht als `if` über die drei bekannten
    -- `code`-Werte: „bis 3 Tage davor … ab 3 Tagen ist ein Storno nicht mehr
    -- möglich" (10, „Fristen und Termine"), gezählt zum **ersten Tag des
    -- Programms** und nicht zum gebuchten Tag. Leer heißt „keine Sperre".
    -- Eine Uhrzeit trägt sie nicht: Die Frist des Ferienprogramms endet mit dem
    -- Tag, und wo eine Uhrzeit dazugehört, steht sie am Akademie-Angebot
    -- (`akademie-schema.sql`). Der Text daneben
    -- (`cancellation_terms_code`) sagt einem Menschen, was ein Storno kostet;
    -- diese Zahl sagt der Route, ab wann sie ihn nicht mehr entgegennimmt, und
    -- ohne sie hinge die Regel an `code`-Werten im Anwendungscode, wo kein
    -- Prüfskript sie sieht. Das System rechnet aus ihr weiterhin keinen Betrag:
    -- „Das System rechnet daraus nichts" — es sperrt, und die Hortleitung trägt
    -- ein. Für Sekretariat und Hortleitung gilt sie nicht (offizieller Umweg).
    cancellation_deadline_days smallint,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_holiday_session_types      PRIMARY KEY (holiday_session_type_id),
    CONSTRAINT uq_holiday_session_types_code UNIQUE (code),
    CONSTRAINT fk_holiday_session_types_terms
        FOREIGN KEY (cancellation_terms_code) REFERENCES contract_text_kinds (code),
    CONSTRAINT ck_holiday_session_types_terms CHECK (cancellation_terms_code <> ''),
    CONSTRAINT ck_holiday_session_types_code  CHECK (code <> ''),
    CONSTRAINT ck_holiday_session_types_name  CHECK (name <> ''),
    CONSTRAINT ck_holiday_session_types_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 10 (Ferienprogramm) — „Je Terminart gibt es zwei Module — sie
-- heißen wie beim Hort und meinen dasselbe, einen Zeitzuschnitt mit eigenem
-- Betrag; dort hängen sie an einem Vertrag, hier an einem Termin." Kein
-- Löschanker. Bewusst KEINE gemeinsame Tabelle mit `care_modules`: dort ist die
-- Buchungseinheit Modul × Wochentag über ein Schuljahr, hier Modul × Termin.
-- Bewusst KEIN Kennzeichen für ein enthaltenes Mittagessen: „Ein Mittagessen
-- trägt keines von beiden — wer im Ferienprogramm betreut wird, isst nicht auf
-- Rechnung der Schule" (10); wo eines im Preis steckt, ist es ein
-- Akademie-Angebot (`akademie-schema.sql`).
CREATE TABLE holiday_modules (
    holiday_module_id       integer GENERATED ALWAYS AS IDENTITY,
    holiday_session_type_id integer NOT NULL,
    code                    text NOT NULL,
    name                    text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active                boolean NOT NULL DEFAULT true,
    starts_at_time          time,
    ends_at_time            time,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_holiday_modules PRIMARY KEY (holiday_module_id),
    CONSTRAINT fk_holiday_modules_type
        FOREIGN KEY (holiday_session_type_id) REFERENCES holiday_session_types (holiday_session_type_id),
    CONSTRAINT uq_holiday_modules_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel der Buchung: er bindet Modul
    -- und Termin an dieselbe Terminart (rules.md Abschnitt 1).
    CONSTRAINT uq_holiday_modules_id_type UNIQUE (holiday_module_id, holiday_session_type_id),
    CONSTRAINT ck_holiday_modules_code CHECK (code <> ''),
    CONSTRAINT ck_holiday_modules_name CHECK (name <> ''),
    CONSTRAINT ck_holiday_modules_times
        CHECK (ends_at_time IS NULL OR starts_at_time IS NULL OR ends_at_time > starts_at_time),
    CONSTRAINT ck_holiday_modules_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 10 (Ferienprogramm) — „Die Ferienwoche trägt eigene Beträge, auch
-- wenn sie derzeit gerade das Fünffache des Tagessatzes sind: Der Betrag steht
-- je Modul und ist keine Regel, die multipliziert."
-- Die Beträge liegen vor (10, hebel.md): 22 € je Tag für die Betreuung bis
-- 14 Uhr und 28 € bis 16 Uhr, im Sommer — wo nur die ganze Woche buchbar ist —
-- 110 € und 140 € je Woche. Dass die Woche derzeit genau das Fünffache des
-- Tages kostet, ist eine Zahl und keine Regel: Der Betrag steht je Modul und
-- mit eigenem Gültigkeitstag, also kann die Schule sie jederzeit entkoppeln,
-- ohne dass etwas umgebaut wird.
-- Bewusst KEIN Aufschlag je Termin daneben: „Alle Beträge stehen fest und
-- gelten für jeden Termin gleich — was ein einzelner Tag im Einkauf kostet,
-- spielt in der Betreuung keine Rolle" (10). Den einen Betrag, den nicht die
-- Geschäftsführung setzt, trägt das Akademie-Angebot als Zusatzbetrag
-- (`akademie-schema.sql`, `surcharge_cents`).
-- Kein Löschanker. Eigene Tabelle statt
-- einer Spalte am Modul, weil der Betrag ein Wert im System ist und einen
-- Gültigkeitstag trägt (hebel.md) — samt dessen Regel: „ein noch nicht gültiger
-- lässt sich bis dahin ändern oder zurücknehmen, ein bereits gültiger nicht
-- mehr", geprüft von der Anwendung (querschnitt-schema.sql).
CREATE TABLE holiday_module_prices (
    holiday_module_price_id integer GENERATED ALWAYS AS IDENTITY,
    holiday_module_id       integer NOT NULL,
    valid_from              date NOT NULL,
    amount_cents            integer NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_holiday_module_prices PRIMARY KEY (holiday_module_price_id),
    CONSTRAINT fk_holiday_module_prices_module
        FOREIGN KEY (holiday_module_id) REFERENCES holiday_modules (holiday_module_id),
    CONSTRAINT uq_holiday_module_prices UNIQUE (holiday_module_id, valid_from),
    CONSTRAINT ck_holiday_module_prices_amount CHECK (amount_cents >= 0),
    CONSTRAINT ck_holiday_module_prices_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Programm und Termine
-- ---------------------------------------------------------------------------

-- Herkunft: 10 (Ferienprogramm) — „Die Hortleitung legt ein Programm an: Name,
-- Anmeldefenster und seine Termine." Löschanker: keiner, keine Personendaten.
-- Die anbietende Stelle ist damit heute die einzige, die der Block kennt; sie
-- steht trotzdem als Zeile am Programm und nicht als Rolle im Code — rules.md
-- Abschnitt 3, „organisatorische Werte … liegen als Daten in der Datenbank".
CREATE TABLE holiday_programmes (
    holiday_programme_id  integer GENERATED ALWAYS AS IDENTITY,
    name                  text NOT NULL,
    -- Die Hortleitung; „eine neue Rolle entsteht dafür nicht".
    offering_role_id      integer NOT NULL,
    registration_opens_at timestamptz NOT NULL,
    -- Das gesetzte Datum; jederzeit vorziehbar oder verschiebbar wie das
    -- Voranmeldefenster (05).
    registration_closes_at timestamptz,
    -- „Schließt die Anmeldung — zum gesetzten Datum oder jederzeit von Hand,
    -- auch wenn rechnerisch noch Platz wäre."
    closed_at             timestamptz,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_holiday_programmes PRIMARY KEY (holiday_programme_id),
    CONSTRAINT fk_holiday_programmes_role
        FOREIGN KEY (offering_role_id) REFERENCES roles (role_id),
    CONSTRAINT ck_holiday_programmes_name CHECK (name <> ''),
    CONSTRAINT ck_holiday_programmes_window
        CHECK (registration_closes_at IS NULL OR registration_closes_at > registration_opens_at),
    CONSTRAINT ck_holiday_programmes_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 10 (Ferienprogramm) — „Ein Ferientermin hat seine Tage, eine
-- Terminart und eine Platzzahl; die Uhrzeiten und den Preis trägt das Modul."
-- Löschanker: keiner, keine Personendaten — „ein abgesagter Termin bleibt
-- sichtbar stehen, damit hinterher unterscheidbar ist, ob er lief oder ausfiel".
-- Bewusst KEINE eigene Termin-Entität mit dem Putzdienst geteilt: die beiden
-- teilen nichts außer einem Datum (grenzkarte.md). Bewusst KEINE Bilder: „Die
-- Ausschreibung selbst samt ihren Bildern: Webseite der Schule" (10) — das
-- Portal trägt das Formular, nicht die Werbung. Damit entfällt zugleich die
-- Bibliothek, die anonym auslieferbar sein müsste; für Bilder wird es keine
-- geben, und kein Formular zeigt eines aus der Datenbank.
CREATE TABLE holiday_sessions (
    holiday_session_id      uuid NOT NULL DEFAULT gen_random_uuid(),
    holiday_programme_id    integer NOT NULL,
    holiday_session_type_id integer NOT NULL,
    -- Das Thema: worum es geht, was mitzubringen ist, die Altersangabe. Es
    -- steht beim Buchen, weil beides die Wahl trägt.
    title                   text NOT NULL,
    description             text,
    -- Obergrenze für die Anzeige, keine Sperre: „Senden zwei Familien im selben
    -- Moment ab, wird der Termin um eins überschritten."
    places                  smallint NOT NULL,
    cancelled_at            timestamptz,
    cancellation_reason     text,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_holiday_sessions PRIMARY KEY (holiday_session_id),
    CONSTRAINT fk_holiday_sessions_programme
        FOREIGN KEY (holiday_programme_id) REFERENCES holiday_programmes (holiday_programme_id),
    CONSTRAINT fk_holiday_sessions_type
        FOREIGN KEY (holiday_session_type_id) REFERENCES holiday_session_types (holiday_session_type_id),
    -- Tragen die zusammengesetzten Fremdschlüssel der Buchung weiter unten: den
    -- der Terminart und den des Programms.
    CONSTRAINT uq_holiday_sessions_id_type UNIQUE (holiday_session_id, holiday_session_type_id),
    CONSTRAINT uq_holiday_sessions_id_programme
        UNIQUE (holiday_session_id, holiday_programme_id),
    CONSTRAINT ck_holiday_sessions_title  CHECK (title <> ''),
    CONSTRAINT ck_holiday_sessions_description CHECK (description <> ''),
    -- „samt Grund in einem Satz" (10) — ein leerer Satz ist keiner.
    CONSTRAINT ck_holiday_sessions_reason CHECK (cancellation_reason <> ''),
    CONSTRAINT ck_holiday_sessions_places CHECK (places > 0),
    -- Eine Absage trägt ihren Grund in einem Satz, wie jedes Ende in 03.
    CONSTRAINT ck_holiday_sessions_cancellation
        CHECK ((cancelled_at IS NULL) = (cancellation_reason IS NULL)),
    CONSTRAINT ck_holiday_sessions_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 10 (Ferienprogramm) — „in den kurzen Ferien ein Termin je Tag über
-- mehrere Tage, in den Sommerferien ein Termin je Woche über mehrere Wochen".
-- Löschanker: keiner, keine Personendaten. Eine Zeile je Tag statt eines
-- Von–Bis, weil eine Ferienwoche Feiertage aussparen darf.
CREATE TABLE holiday_session_days (
    holiday_session_day_id uuid NOT NULL DEFAULT gen_random_uuid(),
    holiday_session_id     uuid NOT NULL,
    day                    date NOT NULL,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_holiday_session_days PRIMARY KEY (holiday_session_day_id),
    CONSTRAINT fk_holiday_session_days_session
        FOREIGN KEY (holiday_session_id) REFERENCES holiday_sessions (holiday_session_id) ON DELETE CASCADE,
    CONSTRAINT uq_holiday_session_days UNIQUE (holiday_session_id, day),
    CONSTRAINT ck_holiday_session_days_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Kostenübernahme und Buchung
-- ---------------------------------------------------------------------------

-- Herkunft: 10 (Ferienprogramm) — „Sekretariat oder Hortleitung erzeugt einen
-- Kostenübernahme-Code für eine Mailadresse und ein Programm, dazu ein
-- Satz, an wen berechnet wird … Der Code gilt für diese eine Anmeldung … und
-- verfällt nach 14 Tagen." Löschanker: nicht die Frist. hebel.md sagt „Fristen
-- sperren, sie löschen nicht" — die Frist macht den Code ungültig und räumt
-- die Zeile nicht weg, und die trägt eine Mailadresse und den Satz, an wen
-- berechnet wird. Er geht deshalb nach der Regel an der Tabelle unten: nicht
-- eingelöst mit seiner Frist, eingelöst mit seiner Buchung. Bewusst KEINE
-- Spalten für Antrag, Bescheid, Bewilligungszeitraum und Teilbeträge: sie
-- „kommen im System nicht vor".
CREATE TABLE holiday_cost_coverage_codes (
    holiday_cost_coverage_code_id uuid NOT NULL DEFAULT gen_random_uuid(),
    holiday_programme_id          integer NOT NULL,
    -- Gilt nur für die Adresse, für die er erzeugt wurde; eine Familie muss es
    -- dafür noch nicht geben.
    email                         text NOT NULL,
    code_hash                     text NOT NULL,
    -- „ein Satz, an wen berechnet wird" — Landratsamt oder Jugendamt.
    invoice_note                  text NOT NULL,
    -- Bewusst KEINE Spalte für den Ablauf: „verfällt nach 14 Tagen" (10) ist
    -- fest wie die Frist der Freischaltung in 05 — der Ablauf ist
    -- `created_at + interval '14 days'` und sonst nichts. Zusätzlich
    -- gespeichert wäre er der zweite Ort für dieselbe Tatsache und trüge kein
    -- Constraint, das der Ableitungsweg nicht ausdrückte (rules.md Abschnitt 1).
    -- Aus demselben Grund KEINE Spalte für das Einlösen: Dass ein Code
    -- eingelöst ist, sagt die Buchung, die auf ihn zeigt
    -- (`fk_holiday_bookings_coverage_code`), und wann, sagt deren `created_at`.
    -- „Eingelöst" ist damit ein EXISTS auf `holiday_bookings`; ein `redeemed_at`
    -- daneben trüge kein Constraint und wäre der zweite Ort.
    created_at                    timestamptz NOT NULL DEFAULT now(),
    -- Wie die Freischaltung in 05 „die benannte Ausnahme von einer Sperre samt
    -- Änderungsspur" — deshalb trägt sie einen Namen.
    created_by                    text NOT NULL,

    CONSTRAINT pk_holiday_cost_coverage_codes PRIMARY KEY (holiday_cost_coverage_code_id),
    CONSTRAINT fk_holiday_cost_coverage_codes_programme
        FOREIGN KEY (holiday_programme_id) REFERENCES holiday_programmes (holiday_programme_id),
    -- Trägt den zusammengesetzten Fremdschlüssel der Buchung: er bindet den Code
    -- an das Programm, für das er erzeugt wurde (rules.md Abschnitt 1).
    CONSTRAINT uq_holiday_cost_coverage_codes_id_programme
        UNIQUE (holiday_cost_coverage_code_id, holiday_programme_id),
    CONSTRAINT ck_holiday_cost_coverage_codes_email  CHECK (email <> ''),
    CONSTRAINT ck_holiday_cost_coverage_codes_hash   CHECK (code_hash <> ''),
    CONSTRAINT ck_holiday_cost_coverage_codes_note   CHECK (invoice_note <> ''),
    CONSTRAINT ck_holiday_cost_coverage_codes_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Ein nicht eingelöster Code wird nach seiner Frist gelöscht, ein eingelöster
-- mit der Buchung, an der er hängt — der Lösch-Lauf räumt erst die Buchung,
-- dann den Code, den `fk_holiday_bookings_coverage_code` bis dahin festhält
-- (NO ACTION, wie `documents` das Kind festhält). — Alternative: die Zeile
-- stehenlassen und allein dem Lösch-Lauf am Kind überlassen; Preis: der nicht
-- eingelöste Code hat gar kein Kind, an dem ein Anker rechnen könnte, und
-- sammelte die Mailadressen von Familien, die nie gebucht haben. Wie bei
-- `login_codes` (stammdaten-schema.sql) eine Regel des Laufs und kein
-- Constraint — „Fristen sperren, sie löschen nicht" (hebel.md).

-- Herkunft: 10 (Ferienprogramm) — „Je Buchung Kind, Termin, Modul, der gezahlte
-- Betrag als das, was an diesem Tag galt, der Zahlweg … und die Fassung der
-- Teilnahmebedingungen, der zugestimmt wurde." Löschanker: der letzte gebuchte
-- Termin dieses Kindes — „der Anker, den es heute nicht gibt" — und **sechs
-- Monate danach** (Datenschutzbeauftragter, 02.09.2026), mit der
-- Löschankündigung an Hortleitung und Geschäftsführung, die hebel.md gemeinsam
-- beschreibt.
-- Bei einem schulfremden Kind geht seine Zeile mit der letzten Buchung: Es hat
-- kein Austrittsdatum, an dem sonst gerechnet würde. Bewusst KEINE Löschung beim Storno: „die Buchung
-- bleibt stehen und gilt als storniert, sie verschwindet nicht".
CREATE TABLE holiday_bookings (
    holiday_booking_id      uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id                uuid NOT NULL,
    holiday_session_id      uuid NOT NULL,
    holiday_module_id       integer NOT NULL,
    -- Nur zur Bindung des Moduls an die Terminart des Termins; sie steht schon
    -- an beiden und wird hier allein für den zusammengesetzten Schlüssel geführt.
    holiday_session_type_id integer NOT NULL,
    -- Dasselbe für das Programm: Es steht am Termin und wird hier allein
    -- mitgeführt, damit der Kostenübernahme-Code an das Programm gebunden
    -- werden kann, für das er erzeugt wurde.
    holiday_programme_id    integer NOT NULL,
    -- Was an diesem Tag galt — der Modulbetrag; „eine spätere
    -- Änderung rechnet nichts rückwirkend um" (hebel.md).
    amount_cents            integer NOT NULL,
    -- Online bezahlt oder wird berechnet; im zweiten Fall trägt der Code den
    -- Satz, an wen.
    payment_mode            text NOT NULL,
    holiday_cost_coverage_code_id uuid,
    -- Die Fassung, die beim Absenden galt; eine Unterschrift entsteht daraus
    -- nicht.
    terms_contract_text_id  integer NOT NULL,
    -- Der Storno in zwei Schritten: die Eltern erklären, die Hortleitung
    -- trägt ein und entscheidet über den Betrag.
    cancellation_declared_at timestamptz,
    cancellation_declared_by text,
    cancellation_recorded_at timestamptz,
    cancellation_recorded_by text,
    retained_amount_cents   integer,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_holiday_bookings PRIMARY KEY (holiday_booking_id),
    CONSTRAINT fk_holiday_bookings_child
        FOREIGN KEY (child_id) REFERENCES children (child_id),
    -- Bindet den Termin an die Terminart, gegen die das Modul geprüft wird.
    CONSTRAINT fk_holiday_bookings_session
        FOREIGN KEY (holiday_session_id, holiday_session_type_id)
        REFERENCES holiday_sessions (holiday_session_id, holiday_session_type_id),
    -- „Je Terminart gibt es zwei Module" (10) — dass das gebuchte Modul zur
    -- Terminart dieses Termins gehört, trägt dieser zusammengesetzte Schlüssel
    -- (rules.md Abschnitt 1).
    CONSTRAINT fk_holiday_bookings_module
        FOREIGN KEY (holiday_module_id, holiday_session_type_id)
        REFERENCES holiday_modules (holiday_module_id, holiday_session_type_id),
    -- Bindet den Termin an sein Programm, gegen das der Code geprüft wird.
    CONSTRAINT fk_holiday_bookings_programme
        FOREIGN KEY (holiday_session_id, holiday_programme_id)
        REFERENCES holiday_sessions (holiday_session_id, holiday_programme_id),
    -- „Der Code gilt für diese eine Anmeldung" (10) — und für das Programm, für
    -- das er erzeugt wurde: Ohne diesen zusammengesetzten Schlüssel bezahlte
    -- ein Code des einen Programms eine Buchung im anderen.
    CONSTRAINT fk_holiday_bookings_coverage_code
        FOREIGN KEY (holiday_cost_coverage_code_id, holiday_programme_id)
        REFERENCES holiday_cost_coverage_codes (holiday_cost_coverage_code_id,
                                                holiday_programme_id),
    CONSTRAINT fk_holiday_bookings_terms
        FOREIGN KEY (terms_contract_text_id) REFERENCES contract_texts (contract_text_id),
    CONSTRAINT ck_holiday_bookings_payment_mode
        CHECK (payment_mode IN ('paid', 'invoiced')),
    -- Ein Code tritt an die Stelle der Zahlung und nur dort.
    CONSTRAINT ck_holiday_bookings_coverage
        CHECK ((payment_mode = 'invoiced') = (holiday_cost_coverage_code_id IS NOT NULL)),
    CONSTRAINT ck_holiday_bookings_amount CHECK (amount_cents >= 0),
    -- Wirksam wird der Storno erst mit dem Eintrag; der einbehaltene Betrag
    -- entsteht mit ihm.
    CONSTRAINT ck_holiday_bookings_declared
        CHECK ((cancellation_declared_at IS NULL) = (cancellation_declared_by IS NULL)),
    CONSTRAINT ck_holiday_bookings_recorded
        CHECK ((cancellation_recorded_at IS NULL) = (cancellation_recorded_by IS NULL)
               AND (cancellation_recorded_at IS NULL) = (retained_amount_cents IS NULL)),
    CONSTRAINT ck_holiday_bookings_retained
        CHECK (retained_amount_cents IS NULL
               OR (retained_amount_cents >= 0 AND retained_amount_cents <= amount_cents)),
    -- „wer sie abgegeben hat" und „wer ihn eingetragen hat" (10) — beide in
    -- derselben Form wie jeder andere Urheber dieser vierzehn Dateien.
    CONSTRAINT ck_holiday_bookings_declared_by
        CHECK (cancellation_declared_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_holiday_bookings_recorded_by
        CHECK (cancellation_recorded_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_holiday_bookings_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Teilnehmerliste je Termin und die Zählung der belegten Plätze.
-- „Gebucht wird je Kind und Termin" — je Termin eine Buchung je Kind, aber nur
-- unter den nicht stornierten: „die Buchung bleibt stehen und gilt als
-- storniert, sie verschwindet nicht", und „die Buchung selbst ändern Eltern
-- nicht, sie stornieren und buchen neu" (10). Ohne die Bedingung wäre der eine
-- Weg versperrt, den der Block für den Modulwechsel vorsieht — dieselbe
-- Bedingung wie am Lese-Index darunter.
CREATE UNIQUE INDEX ix_holiday_bookings_active
    ON holiday_bookings (child_id, holiday_session_id)
    WHERE cancellation_recorded_at IS NULL;

-- 10: „Der Code gilt für diese eine Anmeldung." Ohne diesen Schlüssel zahlt das
-- Amt einmal und die Schule berechnet mehrfach. Wie am Index darüber zählen die
-- stornierten Zeilen nicht mit: Wer storniert und neu bucht, benutzt denselben
-- Code für denselben Vorgang.
CREATE UNIQUE INDEX ix_holiday_bookings_coverage_code
    ON holiday_bookings (holiday_cost_coverage_code_id)
    WHERE cancellation_recorded_at IS NULL AND holiday_cost_coverage_code_id IS NOT NULL;

CREATE INDEX ix_holiday_bookings_session ON holiday_bookings (holiday_session_id)
    WHERE cancellation_recorded_at IS NULL;


-- DER EINZIGE TRIGGER DIESES SCHEMAS. Er trägt die drei Regeln, die eine
-- Buchung über ihre eigene Zeile hinaus prüfen muss und die keine davon sieht;
-- die Begründung für die Bauform steht an `enforce_parent_work_capacity`
-- (elternbonus-schema.sql) und wird hier nicht wiederholt:
--   * **Fremde Kinder**, wo die Terminart sie nicht zulässt (10 Z3) — dieselbe
--     Fassung des Prädikats wie in `enforce_academy_registration()` und in
--     `ex_contracts_care_period` (anmeldung-schema.sql).
--   * **Ein abgesagter Termin** nimmt keine Buchung mehr an, und **das
--     Anmeldefenster** gilt: „wer es verpasst, ist nicht dabei" (10).
-- Die letzten beiden sperren nur die Selbstbuchung der Eltern: „der offizielle
-- Umweg trägt den Einzelfall" (10), und das Sekretariat kann „jedes Datum
-- setzen, auch eines in der Vergangenheit" (hebel.md).
-- **Die Platzzahl steht ausdrücklich NICHT hier**: Sie ist „Obergrenze für die
-- Anzeige, keine Sperre" (10) — anders als am Akademie-Angebot, und der Block
-- nennt die Überschreitung um eins als hinnehmbar.
CREATE FUNCTION enforce_holiday_booking() RETURNS trigger AS $$
DECLARE
    session record;
BEGIN
    SELECT s.cancelled_at, p.closed_at, p.registration_opens_at,
           p.registration_closes_at, t.allows_external_children
      INTO session
      FROM holiday_sessions s
      JOIN holiday_programmes p  ON p.holiday_programme_id = s.holiday_programme_id
      JOIN holiday_session_types t ON t.holiday_session_type_id = s.holiday_session_type_id
     WHERE s.holiday_session_id = NEW.holiday_session_id;

    IF NOT session.allows_external_children
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
        RAISE EXCEPTION 'Termin % steht fremden Kindern nicht offen',
                        NEW.holiday_session_id
              USING ERRCODE = 'check_violation';
    END IF;

    IF NEW.created_by NOT LIKE 'guardian:%' THEN
        RETURN NEW;
    END IF;

    IF session.cancelled_at IS NOT NULL THEN
        RAISE EXCEPTION 'Termin % ist abgesagt', NEW.holiday_session_id
              USING ERRCODE = 'check_violation';
    END IF;

    IF session.closed_at IS NOT NULL
       OR now() < session.registration_opens_at
       OR (session.registration_closes_at IS NOT NULL
           AND now() >= session.registration_closes_at) THEN
        RAISE EXCEPTION 'Anmeldung zu Termin % ist nicht offen', NEW.holiday_session_id
              USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_holiday_bookings_admission
    BEFORE INSERT ON holiday_bookings
    FOR EACH ROW EXECUTE FUNCTION enforce_holiday_booking();


-- Herkunft: 10 (Ferienprogramm) — „Dazu je Kind eine Anmerkung für die
-- Betreuung (freiwillig, Freitext, sichtbar für die Hortleitung, Hortkräfte und
-- Sekretariat)". Der Block zählt sie ausdrücklich NEBEN dem auf,
-- was „je Buchung" steht; an der Buchung stünde sie je Kind UND Termin, und ein
-- Kind, das eine Ferienwoche bucht, trüge dieselbe Anmerkung fünfmal — eine
-- Korrektur erreichte eine davon (rules.md Abschnitt 1). Sie steht deshalb je
-- Kind und Programm: Erhoben wird sie in einem Zug mit den Terminen eines
-- Programms (Schritt 3), gelesen auf dessen Teilnehmerliste (Schritt 7).
-- Löschanker: der **letzte gebuchte Termin dieses Kindes in diesem Programm**
-- und **vier Wochen** danach — dieselbe Frist wie der Gesundheitsbestand des
-- fremden Kindes und aus demselben Grund: „sie trägt oft dasselbe, und nach dem
-- Programm gibt es keinen Zweck mehr, sie zu halten" (10, Betreiber
-- 03.09.2026). Sie geht damit **vor** dem Kind und nicht mit ihm; der
-- Fremdschlüssel darunter hält es fest, statt sie mitzunehmen — sonst räumte
-- eine Cascade die angehaltene Anmerkung still weg, und „solange sie angehalten
-- ist, geht auch das Kind nicht" (10).
-- Je Kind und Programm statt je Kind. — Alternative: eine Zeile je Kind über
-- alle Jahre; Preis: die Anmerkung aus einem Ferienprogramm von vor drei
-- Jahren stünde ungefragt auf der Teilnehmerliste von heute, und gelöscht
-- würde sie nie.
CREATE TABLE holiday_care_notes (
    holiday_care_note_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id             uuid NOT NULL,
    holiday_programme_id integer NOT NULL,
    -- Freitext für die Betreuung — heute die Spalte „Wichtige Notizen".
    note                 text NOT NULL,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_holiday_care_notes PRIMARY KEY (holiday_care_note_id),
    -- NO ACTION und nicht Cascade: Die Anmerkung hat ihre eigene, kürzere Frist
    -- und wird vom Lauf selbst geräumt (Stufe 1). Eine Cascade nähme die
    -- angehaltene Zeile mit dem Kind mit, ohne dass der Lauf sie sieht — genau
    -- das darf ein Anhalten nicht zulassen.
    CONSTRAINT fk_holiday_care_notes_child
        FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_holiday_care_notes_programme
        FOREIGN KEY (holiday_programme_id) REFERENCES holiday_programmes (holiday_programme_id),
    -- „je Kind eine Anmerkung" — eine, nicht mehrere.
    CONSTRAINT uq_holiday_care_notes UNIQUE (child_id, holiday_programme_id),
    CONSTRAINT ck_holiday_care_notes_note CHECK (note <> ''),
    CONSTRAINT ck_holiday_care_notes_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Fremdschlüssel von Q3 und Q5 auf diese Domäne
-- ---------------------------------------------------------------------------
-- Q5 zeigt auf die Ferienbuchung, weil die Erstattung „je Fall eine Aufgabe bei
-- der Buchhaltung" ist (10) und mehrere davon gleichzeitig zu demselben Kind
-- offen stehen. Mit Cascade wie die übrigen Bezüge der Aufgabe: „die erledigten
-- Nachzieh-Aufgaben gehen mit den Daten, auf die sie sich beziehen" (02).
ALTER TABLE sync_tasks
    ADD CONSTRAINT fk_sync_tasks_holiday_booking
        FOREIGN KEY (holiday_booking_id) REFERENCES holiday_bookings (holiday_booking_id)
        ON DELETE CASCADE;

-- Q3 zeigt auf die Ferienbuchung; die Spalte steht in querschnitt-schema.sql.
-- Mit Cascade: „Löschanker: geht mit dem Vorgang, an dem die Zahlung hängt"
-- (querschnitt-schema.sql) — sonst hielte die Zahlung die Buchung fest.
-- Einfach über `holiday_booking_id`, wie die drei übrigen Anlässe, und nicht
-- zusammengesetzt über den Betrag: **ein Absenden ist eine Sitzung und eine
-- Zahlungszeile, auch wenn drei Kinder an vier Terminen gebucht werden**
-- (api/ferien-api.md, api/gemeinsam.md „Sofortzahlung"). Der Betrag der Zahlung
-- ist dann die Summe und gleicht dem keiner einzelnen Buchung; ein Schlüssel
-- über `amount_cents` ließe genau dieses Absenden nicht entstehen. Was gekauft
-- wurde, steht an der ersten entstandenen Buchung über Kind, Familie und
-- Zeitpunkt — dieselbe Form wie beim Jahres-Freikauf des Putzdiensts, wo die
-- Zahlung ebenfalls an der ersten von mehreren Zeilen hängt.
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_holiday_booking
        FOREIGN KEY (holiday_booking_id)
        REFERENCES holiday_bookings (holiday_booking_id)
        ON DELETE CASCADE;


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------


-- Beide Fristen dieser Domäne stehen seit dem 02.09.2026 und sind an ihren
-- Ankern eingetragen: Buchung und Kind sechs Monate nach dem letzten gebuchten
-- Termin, der Gesundheitsbestand des fremden Kindes vier Wochen. Was daraus für
-- die Arbeitskopie folgt und was nicht, steht in stammdaten-schema.sql.
