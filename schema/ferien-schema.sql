-- Ferienprogramm und Kochwerkstatt (Domäne 3) — zwei Angebote, ein Ablauf.
-- Lesepfad: `holiday_session_types` ist die Terminart und trägt als Wert im
-- System ihre Module samt Beträgen. Ein `holiday_programme` bündelt Termine
-- (`holiday_sessions`) mit ihren Tagen; gebucht wird je Kind, Termin und Modul
-- in `holiday_bookings`. Der Kostenübernahme-Code tritt dort an die Stelle der
-- Zahlung. Dateien entstehen in dieser Domäne keine.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus.
-- Bewusst KEINE Gesundheitsangaben und kein Fotoeinverständnis hier: „Was die
-- Betreuung über ein Kind weiß, steht am Kind (08, 09) und wird hier nur
-- gelesen." Bewusst KEINE Warteliste und kein Nachrücken: „Ist ein Termin zu,
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
    -- offensteht; das Alter nicht." Die Öffnung der Kochwerkstatt ist dieses
    -- Häkchen. Die Prüfung selbst leistet die Anwendung — „bekannt ist dabei ein
    -- Kind, das eingeschrieben ist (08) oder einen laufenden Hortvertrag hat
    -- (09)", und das steht in zwei anderen Tabellen; ein CHECK sieht nur seine
    -- eigene Zeile, und Trigger gibt es in diesem Schema nirgends (wie bei der
    -- Platzgrenze in 06).
    -- Beide Terminarten stehen heute auf wahr: „Derzeit Ferientag und
    -- Ferienwoche … sowie Kochwerkstatt; alle drei stehen fremden Kindern
    -- offen, das Häkchen dafür ist heute überall gesetzt" (10). Das Häkchen
    -- unterscheidet damit vorerst nichts — es bleibt, weil der Block die
    -- Prüfung ausdrücklich benennt und weil eine geschlossene Terminart hier
    -- und nirgends sonst markiert würde. Auch die Kochwerkstatt steht offen:
    -- „ein einzelner Termin, gedacht für 8 bis 13, und wie das Ferienprogramm
    -- offen für alle Kinder" (10). Der Preis steht im selben Block: Eine
    -- Allergie bei einem fremden Kind steht nur im Freitext — gerade dort, wo
    -- gekocht wird; getragen wird das von `holiday_care_notes` bei der Stelle,
    -- die den Termin führt, und nicht von einer Auswertung.
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
    -- anbietende Stelle trägt den einbehaltenen Betrag ein.
    cancellation_terms_code text NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_holiday_session_types      PRIMARY KEY (holiday_session_type_id),
    CONSTRAINT uq_holiday_session_types_code UNIQUE (code),
    CONSTRAINT ck_holiday_session_types_terms CHECK (cancellation_terms_code <> ''),
    CONSTRAINT ck_holiday_session_types_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 10 (Ferienprogramm) — „Je Terminart gibt es zwei Module — sie
-- heißen wie beim Hort und meinen dasselbe, einen Zeitzuschnitt mit eigenem
-- Betrag; dort hängen sie an einem Vertrag, hier an einem Termin." Kein
-- Löschanker. Bewusst KEINE gemeinsame Tabelle mit `care_modules`: dort ist die
-- Buchungseinheit Modul × Wochentag über ein Schuljahr, hier Modul × Termin.
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
    -- Im Preis enthalten und nie gesondert berechnet; wo es gesetzt ist, steht
    -- das Kind an diesem Tag auf der Mensaliste (11). Die Ferienmodule tragen
    -- keines, die Kochwerkstatt kann eines tragen.
    includes_lunch          boolean NOT NULL DEFAULT false,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_holiday_modules PRIMARY KEY (holiday_module_id),
    CONSTRAINT fk_holiday_modules_type
        FOREIGN KEY (holiday_session_type_id) REFERENCES holiday_session_types (holiday_session_type_id),
    CONSTRAINT uq_holiday_modules_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel der Buchung: er bindet Modul
    -- und Termin an dieselbe Terminart (rules.md Abschnitt 1).
    CONSTRAINT uq_holiday_modules_id_type UNIQUE (holiday_module_id, holiday_session_type_id),
    CONSTRAINT ck_holiday_modules_times
        CHECK (ends_at_time IS NULL OR starts_at_time IS NULL OR ends_at_time > starts_at_time),
    CONSTRAINT ck_holiday_modules_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 10 (Ferienprogramm) — „Die Ferienwoche trägt eigene Beträge, auch
-- wenn sie derzeit gerade das Fünffache des Tagessatzes sind: Der Betrag steht
-- je Modul und ist keine Regel, die multipliziert."
-- Die Beträge liegen vor (10, hebel.md): 22 € je Tag für die Betreuung bis
-- 14 Uhr und 28 € bis 16 Uhr, im Sommer — wo nur die ganze Woche buchbar ist —
-- 110 € und 140 € je Woche, dazu 30 € Kursgebühr für die Kochwerkstatt. Dass
-- die Woche derzeit genau das Fünffache des Tages kostet, ist eine Zahl und
-- keine Regel: Der Betrag steht je Modul und mit eigenem Gültigkeitstag, also
-- kann die Schule sie jederzeit entkoppeln, ohne dass etwas umgebaut wird.
-- Der zweite Betrag der Kochwerkstatt steht bewusst NICHT hier: „Die
-- Lebensmittel kauft die Hauswirtschaftsleitung je Termin ein, und was sie
-- kosten, weiß niemand ein Jahr im Voraus" (10). Er ist deshalb kein Preis mit
-- Gültigkeitstag, sondern der Aufschlag je Termin und Modul in
-- `holiday_session_surcharges` — genau dafür gibt es sie, und er ist der eine
-- Betrag dieser Domäne, den nicht die Geschäftsführung setzt (hebel.md).
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

-- Herkunft: 10 (Ferienprogramm) — „Die anbietende Stelle legt ein Programm an:
-- Name, Anmeldefenster und seine Termine." Löschanker: keiner, keine
-- Personendaten. Die anbietende Stelle steht als Rolle daran, weil sie „je
-- Programm" verschieden ist — Hortleitung oder Hauswirtschaftsleitung.
CREATE TABLE holiday_programmes (
    holiday_programme_id  integer GENERATED ALWAYS AS IDENTITY,
    name                  text NOT NULL,
    -- Hortleitung oder Hauswirtschaftsleitung; „eine neue Rolle entsteht dafür
    -- nicht".
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
    -- Trägt den zusammengesetzten Fremdschlüssel der Buchung weiter unten.
    CONSTRAINT uq_holiday_sessions_id_type UNIQUE (holiday_session_id, holiday_session_type_id),
    CONSTRAINT ck_holiday_sessions_title  CHECK (title <> ''),
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

-- Herkunft: 10 (Ferienprogramm) — „der Aufschlag je Modul dieses Termins
-- einzeln, meist null: Der Vormittag kocht etwas anderes als der Nachmittag …
-- der einzige Betrag in diesem Block, den nicht die Geschäftsführung setzt".
-- Löschanker: keiner. Bewusst KEIN Gültigkeitstag: der Aufschlag gehört einem
-- einzelnen Termin und lebt nicht länger als er.
CREATE TABLE holiday_session_surcharges (
    holiday_session_surcharge_id uuid NOT NULL DEFAULT gen_random_uuid(),
    holiday_session_id           uuid NOT NULL,
    holiday_module_id            integer NOT NULL,
    surcharge_cents              integer NOT NULL DEFAULT 0,
    created_at                   timestamptz NOT NULL DEFAULT now(),
    created_by                   text NOT NULL,

    CONSTRAINT pk_holiday_session_surcharges PRIMARY KEY (holiday_session_surcharge_id),
    CONSTRAINT fk_holiday_session_surcharges_session
        FOREIGN KEY (holiday_session_id) REFERENCES holiday_sessions (holiday_session_id) ON DELETE CASCADE,
    CONSTRAINT fk_holiday_session_surcharges_module
        FOREIGN KEY (holiday_module_id) REFERENCES holiday_modules (holiday_module_id),
    CONSTRAINT uq_holiday_session_surcharges UNIQUE (holiday_session_id, holiday_module_id),
    CONSTRAINT ck_holiday_session_surcharges_amount CHECK (surcharge_cents >= 0),
    CONSTRAINT ck_holiday_session_surcharges_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Kostenübernahme und Buchung
-- ---------------------------------------------------------------------------

-- Herkunft: 10 (Ferienprogramm) — „Sekretariat oder anbietende Stelle erzeugt
-- einen Kostenübernahme-Code für eine Mailadresse und ein Programm, dazu ein
-- Satz, an wen berechnet wird … Der Code gilt für diese eine Anmeldung … und
-- verfällt nach 14 Tagen." Löschanker: nicht die Frist. hebel.md sagt „Fristen
-- sperren, sie löschen nicht" — die Frist macht den Code ungültig und räumt die
-- Zeile nicht weg, und die trägt eine Mailadresse und den Satz, an wen
-- berechnet wird. Er geht deshalb nach der [A] unten: nicht eingelöst mit
-- seiner Frist, eingelöst mit seiner Buchung. Bewusst KEINE Spalten für
-- Antrag, Bescheid, Bewilligungszeitraum und Teilbeträge: sie „kommen im
-- System nicht vor".
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
    CONSTRAINT ck_holiday_cost_coverage_codes_email  CHECK (email <> ''),
    CONSTRAINT ck_holiday_cost_coverage_codes_note   CHECK (invoice_note <> ''),
    CONSTRAINT ck_holiday_cost_coverage_codes_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- [A] Ein nicht eingelöster Code wird nach seiner Frist gelöscht, ein
-- eingelöster mit der Buchung, an der er hängt — der Lösch-Lauf räumt erst die
-- Buchung, dann den Code, den `fk_holiday_bookings_coverage_code` bis dahin
-- festhält (NO ACTION, wie `documents` das Kind festhält). — Alternative: die
-- Zeile stehenlassen und allein dem Lösch-Lauf am Kind überlassen; Preis: der
-- nicht eingelöste Code hat gar kein Kind, an dem ein Anker rechnen könnte, und
-- sammelte die Mailadressen von Familien, die nie gebucht haben. Wie bei
-- `login_codes` (stammdaten-schema.sql) eine Regel des Laufs und kein
-- Constraint — „Fristen sperren, sie löschen nicht" (hebel.md).

-- Herkunft: 10 (Ferienprogramm) — „Je Buchung Kind, Termin, Modul, der gezahlte
-- Betrag als das, was an diesem Tag galt, der Zahlweg … und die Fassung der
-- Teilnahmebedingungen, der zugestimmt wurde." Löschanker: der letzte gebuchte
-- Termin dieses Kindes — „der Anker, den es heute nicht gibt"; wie lange danach,
-- ist offen (siehe [?] unten). Bewusst KEINE Löschung beim Storno: „die Buchung
-- bleibt stehen und gilt als storniert, sie verschwindet nicht".
CREATE TABLE holiday_bookings (
    holiday_booking_id      uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id                uuid NOT NULL,
    holiday_session_id      uuid NOT NULL,
    holiday_module_id       integer NOT NULL,
    -- Nur zur Bindung des Moduls an die Terminart des Termins; sie steht schon
    -- an beiden und wird hier allein für den zusammengesetzten Schlüssel geführt.
    holiday_session_type_id integer NOT NULL,
    -- Was an diesem Tag galt — Modulbetrag plus Aufschlag; „eine spätere
    -- Änderung rechnet nichts rückwirkend um" (hebel.md).
    amount_cents            integer NOT NULL,
    -- Online bezahlt oder wird berechnet; im zweiten Fall trägt der Code den
    -- Satz, an wen.
    payment_mode            text NOT NULL,
    holiday_cost_coverage_code_id uuid,
    -- Die Fassung, die beim Absenden galt; eine Unterschrift entsteht daraus
    -- nicht.
    terms_contract_text_id  integer NOT NULL,
    -- Der Storno in zwei Schritten: die Eltern erklären, die anbietende Stelle
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
    CONSTRAINT fk_holiday_bookings_coverage_code
        FOREIGN KEY (holiday_cost_coverage_code_id)
        REFERENCES holiday_cost_coverage_codes (holiday_cost_coverage_code_id),
    CONSTRAINT fk_holiday_bookings_terms
        FOREIGN KEY (terms_contract_text_id) REFERENCES contract_texts (contract_text_id),
    -- Trägt den zusammengesetzten Fremdschlüssel von Q3 unten (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_holiday_bookings_amount UNIQUE (holiday_booking_id, amount_cents),
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

CREATE INDEX ix_holiday_bookings_session ON holiday_bookings (holiday_session_id)
    WHERE cancellation_recorded_at IS NULL;


-- Herkunft: 10 (Ferienprogramm) — „Dazu je Kind eine Anmerkung für die
-- Betreuung (freiwillig, Freitext, sichtbar für die anbietende Stelle,
-- Hortkräfte und Sekretariat)". Der Block zählt sie ausdrücklich NEBEN dem auf,
-- was „je Buchung" steht; an der Buchung stünde sie je Kind UND Termin, und ein
-- Kind, das eine Ferienwoche bucht, trüge dieselbe Anmerkung fünfmal — eine
-- Korrektur erreichte eine davon (rules.md Abschnitt 1). Sie steht deshalb je
-- Kind und Programm: Erhoben wird sie in einem Zug mit den Terminen eines
-- Programms (Schritt 3), gelesen auf dessen Teilnehmerliste (Schritt 7).
-- Löschanker: geht mit dem Kind.
-- [A] Je Kind und Programm statt je Kind. — Alternative: eine Zeile je Kind über
-- alle Jahre; Preis: die Anmerkung aus einem Ferienprogramm von vor drei Jahren
-- stünde ungefragt auf der Teilnehmerliste der Kochwerkstatt von heute, und
-- gelöscht würde sie nie.
CREATE TABLE holiday_care_notes (
    holiday_care_note_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id             uuid NOT NULL,
    holiday_programme_id integer NOT NULL,
    -- Freitext für die Betreuung — heute die Spalte „Wichtige Notizen".
    note                 text NOT NULL,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_holiday_care_notes PRIMARY KEY (holiday_care_note_id),
    CONSTRAINT fk_holiday_care_notes_child
        FOREIGN KEY (child_id) REFERENCES children (child_id) ON DELETE CASCADE,
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
-- Zusammengesetzt über den Betrag: „der gezahlte Betrag als das, was an diesem
-- Tag galt" (10) steht an der Buchung, „Anlass × Betrag × Status ×
-- Zahlungsreferenz" (grenzkarte.md, Q3) an der Zahlung — beide Quellen
-- verlangen ihn, also bindet der Schlüssel sie aneinander, statt sie
-- auseinanderlaufen zu lassen (rules.md Abschnitt 1). Bei den übrigen drei
-- Anlässen greift er nicht: dort ist `holiday_booking_id` leer.
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_holiday_booking
        FOREIGN KEY (holiday_booking_id, amount_cents)
        REFERENCES holiday_bookings (holiday_booking_id, amount_cents)
        ON DELETE CASCADE;


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------


-- [?] Wie lange werden Buchung und Kind nach dem letzten gebuchten Termin
--     aufbewahrt? Ohne die Antwort hat der Löschanker dieser Domäne kein Ziel
--     (10). Dieselbe offene Frist wie in stammdaten-schema.sql, samt der dort
--     notierten Abgrenzung zu den amtlichen Werkzeugen. — Datenschutzbeauftragte
