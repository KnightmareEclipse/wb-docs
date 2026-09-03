-- Stammdaten — Person, Familie, Kind, Erziehungsberechtigte, Mitarbeitende,
-- Klassen. Der Bestand, auf den jede andere Domäne zeigt und den keine kopiert.
-- Lesepfad: Zuerst die Lookups, dann `persons` — jede Rolle ist eine Zeile
-- darauf. `families` bündelt Kinder und Sorgeberechtigte; `children` trägt den
-- Schullebenslauf, `employees` den Arbeitslebenslauf. `classes` steht daneben
-- und wird von `children.class_id` gefüllt.
--
-- Bezeichner englisch, Kommentare deutsch. Schuljahr = Startjahr als integer
-- (2026 heißt 2026/27, 1.8.2026–31.7.2027); eine Schuljahrestabelle gibt es
-- nicht, das Jahr folgt aus dem Datum (Block 04).
--
-- Erzeuger-Spalten `created_by` durchgängig mit Präfix: "entra:<oid>" für
-- interne Nutzer, "guardian:<uuid>" für den OTP-Pfad, "system:<job>" für Läufe.
--
-- [A!] Es gibt kein `updated_at`/`updated_by` auf irgendeiner Tabelle: die
-- Änderungsspur (querschnitt-schema.sql) trägt wer, wann und was vorher
-- dastand, damit ist der letzte Änderer ableitbar. — Alternative: beides
-- zusätzlich an jeder Tabelle, dann ist „wann zuletzt geändert" ohne Join
-- lesbar; Preis: zwei Orte für dieselbe Tatsache, und der eine wird beim ersten
-- Massen-Update vergessen (rules.md Abschnitt 1).


-- ---------------------------------------------------------------------------
-- Wertelisten
-- ---------------------------------------------------------------------------

-- Herkunft: rules.md Abschnitt 3 — „Kategoriewerte (Status/Typ/Rollen-artige
-- Felder) als eigene Lookup-Tabelle". Kein Löschanker: keine Personendaten.
-- Bewusst KEINE Audit-Spalten hier — der Inhalt ist eine Bezeichnung, keine
-- Regel; die drei Listen mit Regelwirkung tragen sie unten selbst.
CREATE TABLE salutations (
    salutation_id integer GENERATED ALWAYS AS IDENTITY,
    code          text NOT NULL,
    name          text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active      boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_salutations      PRIMARY KEY (salutation_id),
    CONSTRAINT uq_salutations_code UNIQUE (code)
);

CREATE TABLE genders (
    gender_id integer GENERATED ALWAYS AS IDENTITY,
    code      text NOT NULL,
    name      text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active  boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_genders      PRIMARY KEY (gender_id),
    CONSTRAINT uq_genders_code UNIQUE (code)
);

-- Herkunft: 05 (Bewerbung) — „Konfession und Anschrift (Pflicht), zweite
-- Staatsangehörigkeit und Kirchengemeinde (freiwillig)".
CREATE TABLE denominations (
    denomination_id integer GENERATED ALWAYS AS IDENTITY,
    code            text NOT NULL,
    name            text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active        boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_denominations      PRIMARY KEY (denomination_id),
    CONSTRAINT uq_denominations_code UNIQUE (code)
);

-- Herkunft: 05 (Bewerbung) — „Geburtsort und -land, Muttersprache".
CREATE TABLE languages (
    language_id integer GENERATED ALWAYS AS IDENTITY,
    code        text NOT NULL,
    name        text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active    boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_languages      PRIMARY KEY (language_id),
    CONSTRAINT uq_languages_code UNIQUE (code)
);

-- Herkunft: 05 (Bewerbung) — „Geburtsort und -land … Staatsangehörigkeit".
-- Eine Liste trägt beide Bezeichnungen (Land „Deutschland",
-- Staatsangehörigkeit „deutsch") statt zweier Tabellen. — Alternative:
-- getrennte `countries` und `nationalities`; Preis: zwei Listen, die dieselben
-- Staaten führen und beim nächsten Staatszerfall getrennt gepflegt werden
-- müssen.
CREATE TABLE countries (
    country_id       integer GENERATED ALWAYS AS IDENTITY,
    -- ISO-3166-1 alpha-2, damit ein Import aus ASV-BW ohne Namensabgleich trifft.
    code             text NOT NULL,
    name             text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active         boolean NOT NULL DEFAULT true,
    -- Wie die Staatsangehörigkeit auf einem Formular heißt („deutsch").
    nationality_name text NOT NULL,

    CONSTRAINT pk_countries      PRIMARY KEY (country_id),
    CONSTRAINT uq_countries_code UNIQUE (code)
);

-- Herkunft: 05 (Bewerbung) — „Je Sorgeberechtigtem Name, Geschlecht,
-- Verhältnis zum Kind, Konfession, Beruf …".
CREATE TABLE guardian_relations (
    guardian_relation_id integer GENERATED ALWAYS AS IDENTITY,
    code                 text NOT NULL,
    name                 text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active             boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_guardian_relations      PRIMARY KEY (guardian_relation_id),
    CONSTRAINT uq_guardian_relations_code UNIQUE (code)
);

-- Herkunft: hebel.md, „Einsichtsstufe" — „Wer davon ausgenommen werden muss,
-- bekommt vom Sekretariat auf Vorlage eines Beschlusses eine von drei Stufen":
-- voll, nur lesen, gesperrt. Kein Löschanker: keine Personendaten.
-- Werteliste und keine CHECK-Liste: Die Stufe entscheidet über keine andere
-- Spalte derselben Zeile Pflicht oder nicht — nur darüber, was das Portal zeigt
-- —, und damit greift die Ausnahme aus rules.md Abschnitt 3 nicht. 02 rechnet
-- ausdrücklich mit einem vierten Grad: „Ein vierter Grad derselben Achse ist ein
-- Wert mehr und die Stelle im Portal, die ihn beachtet." Ein Wert mehr ist hier
-- eine Zeile; unter einem CHECK wäre er eine Migration an einer eingefrorenen
-- Stammdatentabelle (grenzkarte.md). Der `code` ist stabil, denn der Code
-- verzweigt auf ihn — umbenannt wird der `name`.
-- Ein Beschluss, der je Bereich oder je Kind unterscheidet, ist dagegen keine
-- vierte Zeile, sondern eine zweite Achse, und die schließt hebel.md aus: „Die
-- Stufe hängt an der Person, nicht an einzelnen Angaben."
CREATE TABLE access_levels (
    access_level_id integer GENERATED ALWAYS AS IDENTITY,
    code            text NOT NULL,
    name            text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active        boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_access_levels      PRIMARY KEY (access_level_id),
    CONSTRAINT uq_access_levels_code UNIQUE (code)
);

-- Herkunft: grenzkarte.md, „Zwei Schulen, nicht eine" — „`previous_schools` …
-- trägt seit der Bedeutungserweiterung genau die staatlichen
-- Überweisungspartner". Der Kindergarten steht bewusst NICHT hier, er bekommt
-- eine eigene Werteliste in Domäne 2/4.
CREATE TABLE previous_schools (
    previous_school_id integer GENERATED ALWAYS AS IDENTITY,
    name               text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active           boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_previous_schools      PRIMARY KEY (previous_school_id),
    CONSTRAINT uq_previous_schools_name UNIQUE (name)
);

-- Herkunft: 15 (Klassenbildung) — „eine `GS` beginnt in Stufe 1, eine `RS` in
-- Stufe 5". Löschanker: keiner, keine Personendaten. Audit-Spalten, weil die
-- beiden Stufengrenzen eine Regel steuern: `final_grade_level` entscheidet im
-- Jahreslauf (04), wer zum 31. Juli abgeht, `first_grade_level` die gerechnete
-- Stufe jeder Klasse.
CREATE TABLE school_branches (
    school_branch_id  integer GENERATED ALWAYS AS IDENTITY,
    -- Trägt zugleich das Kennungspräfix jeder Klasse dieser Schulart („GS26b",
    -- Block 15) — deshalb kurz und unveränderlich.
    code              text NOT NULL,
    name              text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active          boolean NOT NULL DEFAULT true,
    first_grade_level smallint NOT NULL,
    -- „Wer am Ende seiner Schulart steht — Klasse 4, Klasse 10" (Block 04). Als
    -- Spalte statt als `is_final_grade` an einer Stufenliste: die Stufe allein
    -- ist ohne Schulart nicht final, Klasse 4 der Realschule gibt es nicht.
    final_grade_level smallint NOT NULL,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_school_branches        PRIMARY KEY (school_branch_id),
    CONSTRAINT uq_school_branches_code   UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel von `children` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_school_branches_grades UNIQUE (school_branch_id, first_grade_level, final_grade_level),
    CONSTRAINT ck_school_branches_grades CHECK (final_grade_level >= first_grade_level),
    CONSTRAINT ck_school_branches_created_by
        CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 13 (M365-Kontenverwaltung) — „Legen einen Mitarbeitenden an — Name,
-- Haus, auf Wunsch der erste Arbeitstag". Löschanker: keiner, keine
-- Personendaten. Audit-Spalten, weil das Haus die M365-Domain und die
-- Putzdienst-Befreiung steuert (grenzkarte.md, Q4).
CREATE TABLE houses (
    house_id   integer GENERATED ALWAYS AS IDENTITY,
    code       text NOT NULL,
    name       text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active   boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,

    CONSTRAINT pk_houses      PRIMARY KEY (house_id),
    CONSTRAINT uq_houses_code UNIQUE (code),
    CONSTRAINT ck_houses_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: hebel.md, „Rollen" — „Es gibt diese Rollen, mehrere je Person
-- möglich: Mitarbeitende … Sekretariat, Lehrkraft … Admin, KITA-Mitarbeitende,
-- KITA-Leitung". Löschanker: keiner, keine Personendaten. Audit-Spalten, weil
-- eine geänderte Zeile hier über den Zugriff aller Träger entscheidet.
CREATE TABLE roles (
    role_id    integer GENERATED ALWAYS AS IDENTITY,
    -- Der Code ist die Verankerung im Anwendungscode und wird nie umbenannt;
    -- der Name darf jederzeit wandern (rules.md Abschnitt 3).
    code       text NOT NULL,
    name       text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active   boolean NOT NULL DEFAULT true,
    -- Trägt allein die Schulleitung, die es je Schulform einmal gibt
    -- (hebel.md, „Rollen"); für alle übrigen Rollen bleibt sie leer.
    is_branch_bound boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,

    CONSTRAINT pk_roles      PRIMARY KEY (role_id),
    CONSTRAINT uq_roles_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel von `employee_roles` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_roles_branch_bound UNIQUE (role_id, is_branch_bound),
    CONSTRAINT ck_roles_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- Herkunft: 02 (Datenänderung) — „Je Sorgeberechtigtem die eigenen
-- Kontaktdaten: Anschrift, Telefon, Mailadresse". Die Aufteilung in Arten folgt
-- ASV-BW, das sie beim Übertragen erwartet. Kein Löschanker: keine
-- Personendaten.
CREATE TABLE phone_types (
    phone_type_id integer GENERATED ALWAYS AS IDENTITY,
    code          text NOT NULL,
    name          text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active      boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_phone_types      PRIMARY KEY (phone_type_id),
    CONSTRAINT uq_phone_types_code UNIQUE (code)
);


-- ---------------------------------------------------------------------------
-- Person und Erreichbarkeit
-- ---------------------------------------------------------------------------

-- Herkunft: 02 (Datenänderung) — „Wer die eigene Anschrift ändert, wird
-- gefragt, ob sie auch für die Kinder gilt — ein Häkchen, kein zweiter
-- Vorgang". Löschanker: keiner eigener; eine Anschrift verschwindet mit der
-- letzten Person, die auf sie zeigt. Von selbst geschieht das nicht —
-- `persons.address_id` und `sepa_mandates.account_holder_address_id` zeigen
-- vorwärts auf sie, und eine Vorwärtsreferenz nimmt nichts mit. Sie ist deshalb
-- Stufe 7 des Lösch-Laufs (Kopf von querschnitt-schema.sql), die einzige, die
-- der Lauf selbst berechnet.
-- Eine eigene Zeile, auf die mehrere Personen zeigen dürfen, statt vier
-- Spalten an `persons`. — Alternative: Anschrift direkt an der Person, dann
-- ist das Häkchen ein Kopiervorgang; Preis: der Umzug einer Familie ist vier
-- Änderungen statt einer, und eine davon bleibt liegen.
CREATE TABLE addresses (
    address_id  uuid NOT NULL DEFAULT gen_random_uuid(),
    street      text NOT NULL,
    house_number text NOT NULL,
    postal_code text NOT NULL,
    city        text NOT NULL,
    -- Der Ortsteil. ASV-BW verlangt ihn für die Schulstatistik; ohne ihn ist
    -- beim Übertragen nicht mehr feststellbar, wo ein Kind wohnt.
    district    text,
    country_id  integer NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now(),
    created_by  text NOT NULL,

    CONSTRAINT pk_addresses         PRIMARY KEY (address_id),
    CONSTRAINT fk_addresses_country FOREIGN KEY (country_id) REFERENCES countries (country_id),
    CONSTRAINT ck_addresses_street      CHECK (street <> ''),
    CONSTRAINT ck_addresses_postal_code CHECK (postal_code <> ''),
    CONSTRAINT ck_addresses_city        CHECK (city <> ''),
    CONSTRAINT ck_addresses_district    CHECK (district <> ''),
    CONSTRAINT ck_addresses_created_by  CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: grenzkarte.md, Regel 2 — „Personendaten haben genau ein Zuhause:
-- `persons` plus die Rollentabellen in Stammdaten". Löschanker: keiner eigener
-- — eine Person verschwindet erst, wenn alle ihre Rollenanker erreicht sind
-- (00, „ein Sorgeberechtigter, der zugleich Mitarbeitender ist, ist trotzdem
-- eine Person"). Bewusst KEIN Geburtsdatum: Es steht am Kind (rules.md 7).
CREATE TABLE persons (
    person_id     uuid NOT NULL DEFAULT gen_random_uuid(),
    salutation_id integer,
    -- Nullable für die seltenen Einzelname-Fälle; mit `<> ''`, weil NULL hier
    -- eine Aussage trägt und der Leerstring aus dem CSV-Import genauso aussähe.
    first_name    text,
    last_name     text NOT NULL,
    -- Der Rufname, wo er vom Vornamen abweicht: ein Doppelname, von dem nur
    -- eine Hälfte gesprochen wird, oder eine Kurzform, mit der ein Kind
    -- angesprochen werden will. Leer heißt „der Vorname gilt".
    nickname      text,
    gender_id     integer,
    -- „Am Kind die Anschrift (Pflicht)" (02), ebenso 05 („Konfession und
    -- Anschrift (Pflicht)"). Die Pflicht steht bewusst NICHT als NOT NULL —
    -- dieselbe Tabelle trägt Mitarbeitende (13) und Notfallkontakte (02), für
    -- die kein Block eine Anschrift verlangt, und die Person entsteht in der
    -- Bewerbung, bevor jemand sie eingetragen hat. Sie liegt in der Anwendung,
    -- wie die Notfallnummer an `phone_numbers` und die Mailadresse je Familie.
    address_id    uuid,
    -- Die private Adresse, und nur die; das Schulpostfach steht an
    -- `children.school_email`, die Dienstadresse an `employees.work_email`.
    -- Bewusst NICHT UNIQUE: zwei Erziehungsberechtigte dürfen sich real eine
    -- Mailbox teilen (05, „die zweite wird übernommen").
    email         text,
    -- 00 (Zugang und Portal): „je Person die letzte Anmeldung: daran sieht das
    -- Sekretariat, welche Familie das Portal überhaupt nutzt".
    last_login_at timestamptz,
    -- Was sich das Sekretariat merkt und wofür es kein Feld gibt. An `persons`
    -- und nicht an `children`, weil Kind und Sorgeberechtigter dieselbe
    -- Zeilensorte sind und zwei Spalten dieselbe Sache zweimal wären.
    -- Hier gehört NICHT hinein: Gesundheitsangaben — die haben ihren Ort samt
    -- Sichtkreisen und Freigaben (gesundheit-schema.sql) —, Einschätzungen über
    -- einen Menschen, Verdacht, und nichts, wofür ein Feld fehlt. Taucht
    -- dieselbe Sorte Notiz dreimal auf, ist das keine Notiz, sondern eine
    -- fehlende Spalte. Die Familie liest sie bei der Auskunft nach Art. 15;
    -- dass das am Eingabefeld steht, ist der wirksamste Schutz und kostet
    -- nichts (grenzkarte.md, „Die Notiz an der Person").
    note          text,
    -- Abgeleitet und gespeichert, weil ein Fremdschlüssel eine Spalte braucht
    -- und keinen Ausdruck: `employees` zeigt darauf und kann deshalb neben einer
    -- Notiz nicht bestehen. Eine Notiz an einem Mitarbeitenden wäre ein Stück
    -- Personalakte, und die führt Weltenbaum nicht (13).
    has_note      boolean NOT NULL GENERATED ALWAYS AS (note IS NOT NULL) STORED,
    created_at    timestamptz NOT NULL DEFAULT now(),
    created_by    text NOT NULL,

    CONSTRAINT pk_persons            PRIMARY KEY (person_id),
    CONSTRAINT fk_persons_salutation FOREIGN KEY (salutation_id) REFERENCES salutations (salutation_id),
    CONSTRAINT fk_persons_gender     FOREIGN KEY (gender_id)     REFERENCES genders (gender_id),
    CONSTRAINT fk_persons_address    FOREIGN KEY (address_id)    REFERENCES addresses (address_id),
    CONSTRAINT ck_persons_first_name CHECK (first_name <> ''),
    CONSTRAINT ck_persons_nickname   CHECK (nickname <> ''),
    CONSTRAINT ck_persons_last_name  CHECK (last_name <> ''),
    CONSTRAINT ck_persons_email      CHECK (email <> ''),
    CONSTRAINT ck_persons_note       CHECK (note <> ''),
    -- Trägt den zusammengesetzten Fremdschlüssel von `employees`.
    CONSTRAINT uq_persons_note       UNIQUE (person_id, has_note),
    CONSTRAINT ck_persons_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 02 (Datenänderung) — „mindestens eine tagsüber erreichbare
-- Notfallnummer ist Pflicht — vormittags für die Schule, nachmittags für die
-- Betreuung …, eine Regel statt zweier Nummern". Löschanker: geht mit der Person.
-- Die Pflicht selbst steht bewusst NICHT als Constraint hier: sie greift erst
-- mit dem ersten Vertrag am Kind und würde jede Voranmeldung blockieren.
-- Bewusst KEINE Hauptnummer und keine Reihenfolge unter den Nummern: kein
-- Block nennt eine, und grenzkarte.md hält ausdrücklich fest, dass „die
-- Notfallnummer bekommt kein eigenes Feld". Wonach im Notfall gesucht wird,
-- trägt `reachable_daytime` — das verlangt 02 wörtlich.
CREATE TABLE phone_numbers (
    phone_number_id uuid NOT NULL DEFAULT gen_random_uuid(),
    person_id       uuid NOT NULL,
    number          text NOT NULL,
    phone_type_id   integer,
    -- Freie Bemerkung zu dieser einen Nummer („Rückruf nur vormittags"); nach
    -- ihr wird nicht gruppiert (rules.md Abschnitt 3). Die Erreichbarkeit
    -- tagsüber, an der die Pflicht aus 02 hängt, trägt allein
    -- `reachable_daytime`, die Art der Verbindung allein `phone_type_id`.
    note            text,
    -- Wahr, wo diese Nummer tagsüber erreichbar ist; nur solche zählen für die
    -- Notfallpflicht aus 02.
    reachable_daytime boolean NOT NULL DEFAULT false,
    created_at      timestamptz NOT NULL DEFAULT now(),
    created_by      text NOT NULL,

    CONSTRAINT pk_phone_numbers        PRIMARY KEY (phone_number_id),
    CONSTRAINT fk_phone_numbers_person FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT fk_phone_numbers_type   FOREIGN KEY (phone_type_id) REFERENCES phone_types (phone_type_id),
    CONSTRAINT ck_phone_numbers_number CHECK (number <> ''),
    CONSTRAINT ck_phone_numbers_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);



-- ---------------------------------------------------------------------------
-- Familie, Kind, Sorgeberechtigung
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md, „Familie und Kind" — „Familie heißt die Eltern, nicht der
-- Haushalt. Getrennt lebende Eltern bleiben eine Familie." Löschanker: die
-- Familie verschwindet, wenn kein Kind mehr eine Verbindung hat (03, „erst,
-- wenn die Familie kein Kind mehr an der Schule hat"). Bewusst ohne eigene
-- Spalten: sie ist der Anker, an dem Putzdienst und Elternbonus hängen, und
-- trägt selbst keine Angabe.
-- „Mindestens eine Mailadresse je Familie ist Pflicht, damit keine Familie ohne
-- Kanal ist", und „die letzte Mailadresse und die letzte Notfallnummer lassen
-- sich nur ersetzen, nie löschen" (02). Beides steht bewusst NICHT als
-- Constraint — dieselbe begründete Auslassung wie bei der Notfallnummer an
-- `phone_numbers`: die
-- Familie entsteht mit der ersten Bewerbung, und ein Constraint hier bräuchte
-- die Adresse, bevor jemand sie eingetragen hat. Die Pflicht liegt in der
-- Anwendung, die das Löschen der letzten Adresse abweist.
CREATE TABLE families (
    family_id  uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,

    CONSTRAINT pk_families PRIMARY KEY (family_id),
    CONSTRAINT ck_families_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 15 (Klassenbildung) — „Eine Klasse ist ein Körper, der Kinder, eine
-- Klassenlehrkraft und einen Raum bündelt … Sie trägt eine Kennung, die ihr
-- ganzes Leben gleich bleibt: Schulart, Startschuljahr, Zug — `GS26b`".
-- Löschanker: keiner — „die Klassen vergangener Schuljahre bleiben als Kennung
-- stehen und tragen für sich keine Personendaten". Bewusst KEINE Spalten für
-- Stufe, Anzeigename und Kapazität: die ersten beiden werden gerechnet, die
-- dritte „wird gezeigt, nicht geprüft".
CREATE TABLE classes (
    class_id          integer GENERATED ALWAYS AS IDENTITY,
    school_branch_id  integer NOT NULL,
    -- Das Schuljahr, in dem die Kohorte begonnen hat — nicht das des Anlegens:
    -- „ein zweiter Zug, der erst entsteht, wenn eine Stufe geteilt wird, trägt
    -- trotzdem die Jahreszahl seiner Kohorte".
    start_school_year smallint NOT NULL,
    -- Der Zug („a", „b"). Zusammen mit Schulart und Startjahr die Kennung, an
    -- der M365-Gruppe und Mailverteiler hängen und die nie geändert wird.
    stream            text NOT NULL,
    -- Freie Angabe, rein informativ: „eine Raumliste, einen Belegungsplan oder
    -- eine Prüfung auf Doppelbelegung gibt es nicht".
    room              text,
    -- Die Klassenlehrkraft, „Pflicht" in der Klassenbildung (15) — genau eine
    -- je Klasse, so hat die Schule die offene Frage beantwortet. Leer, solange
    -- die Klasse steht und niemand gesetzt ist: beim Vollimport entstehen die
    -- Klassen aus ihrer rückgerechneten Kohorten-Kennung, bevor jemand
    -- zuordnet. Der Fremdschlüssel steht weiter unten, weil `employees` erst
    -- danach entsteht.
    class_teacher_id  uuid,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_classes        PRIMARY KEY (class_id),
    CONSTRAINT fk_classes_branch FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    CONSTRAINT uq_classes_key    UNIQUE (school_branch_id, start_school_year, stream),
    -- Trägt den zusammengesetzten Fremdschlüssel von `children` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_classes_id_branch UNIQUE (class_id, school_branch_id),
    CONSTRAINT ck_classes_stream CHECK (stream <> ''),
    CONSTRAINT ck_classes_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 05 (Bewerbung) — „Zum Kind: Vor- und Nachname, Geschlecht,
-- Geburtsdatum, Geburtsort und -land, Muttersprache, Staatsangehörigkeit,
-- Konfession und Anschrift (Pflicht), zweite Staatsangehörigkeit und
-- Kirchengemeinde (freiwillig)". Löschanker: `exit_date` — ab ihm rechnet der
-- Lösch-Lauf (03), und mit dem Kind geht auch `school_email` (13). Bewusst
-- KEINE Spalte für den Schulbegleitungsbedarf: er ist ein Förderdatum und
-- gehört mit dessen Zugriffsprofil in Domäne 9 (grenzkarte.md).
CREATE TABLE children (
    child_id                   uuid NOT NULL DEFAULT gen_random_uuid(),
    person_id                  uuid NOT NULL,
    family_id                  uuid NOT NULL,
    birth_date                 date NOT NULL,
    birthplace                 text,
    birth_country_id           integer,
    native_language_id         integer,
    nationality_country_id     integer,
    -- Freiwillig und deshalb getrennt von der ersten (05).
    second_nationality_country_id integer,
    denomination_id            integer,
    -- Freiwillig (05), und sie bleibt: „Die Kirchengemeinde will die Schule
    -- weiter erheben — sie wird gebaut und befüllt wie jedes andere Feld dieser
    -- Liste; ob sie später wegfällt, wird in einigen Monaten entschieden und
    -- damit nach dem Vollimport, nicht davor" (05). Ein benannter
    -- Verarbeitungszweck steht für sie weiterhin aus — Block 07 nennt sie mit
    -- keinem Wort, und grenzkarte.md führt sie unter den weißen Flecken —, und
    -- genau darüber wird dann entschieden. Bis dahin ist das kein offener
    -- Punkt, der etwas aufhält.
    congregation               text,
    -- Entsteht mit der Freigabe des Schulvertrags aus dem Ziel der Bewerbung
    -- (08) und wirkt zum Eintrittsdatum; ein Bewerberkind hat sie noch nicht.
    school_branch_id           integer,
    grade_level                smallint,
    -- Die beiden Grenzen der Schulart, hier mitgeführt, damit der CHECK unten
    -- sie sehen kann; `fk_children_branch` hält sie mit ihrer Quelle zusammen
    -- (rules.md Abschnitt 1). Vorher stand statt ihrer 1..10 hart im CHECK —
    -- eine Zahl, die keine Schulart hergibt, ging damit durch.
    first_grade_level          smallint,
    final_grade_level          smallint,
    class_id                   integer,
    -- 04: „Dazu, wer seine Stufe wiederholt — ohne Grund, der fällt außerhalb."
    -- Das Schuljahr, in dem das Kind seine Stufe wiederholt: Der Lauf am
    -- 1. August lässt genau die stehen, deren Wert das beginnende Schuljahr
    -- trägt, und 15 liest dieselbe Spalte („wer für welches Schuljahr
    -- eingeschrieben ist … und wer wiederholt"). Als Jahreszahl und nicht als
    -- Boolean, das jemand jedes Jahr zurücksetzen müsste.
    repeats_grade_school_year  smallint,
    -- 08: „Die Einschreibung besteht ab der Freigabe und wirkt zum
    -- Eintrittsdatum" — Regelfall 1. August, beim Quereinstieg ein anderer Tag.
    entry_date                 date,
    exit_date                  date,
    -- 03: „der Grund in einem Satz (Pflicht, Freitext) … trägt zugleich, worauf
    -- der Abgang beruht" — deshalb daneben kein eigenes Nachweisfeld.
    exit_reason                text,
    -- Die staatliche Schule, mit der die Schülerüberweisung läuft (grenzkarte.md,
    -- „Zwei Schulen, nicht eine"); der Kindergarten steht an der Bewerbung.
    previous_school_id         integer,
    -- Einmaliges, sofort verbrauchtes Einverständnis und deshalb nicht Q1; das
    -- abgesendete Voranmeldeformular ist der Anker, an dem „leer" hier
    -- „verweigert" heißt (grenzkarte.md, „Drei Zustände").
    previous_school_consent_at timestamptz,
    -- Trägt und ändert allein der Admin, weil sie den Tenant spiegelt (13); sie
    -- bleibt stehen, auch wenn das Konto längst gelöscht ist.
    school_email               text,
    created_at                 timestamptz NOT NULL DEFAULT now(),
    created_by                 text NOT NULL,

    CONSTRAINT pk_children               PRIMARY KEY (child_id),
    CONSTRAINT fk_children_person        FOREIGN KEY (person_id) REFERENCES persons (person_id),
    CONSTRAINT fk_children_family        FOREIGN KEY (family_id) REFERENCES families (family_id),
    CONSTRAINT fk_children_birth_country FOREIGN KEY (birth_country_id) REFERENCES countries (country_id),
    CONSTRAINT fk_children_language      FOREIGN KEY (native_language_id) REFERENCES languages (language_id),
    CONSTRAINT fk_children_nationality   FOREIGN KEY (nationality_country_id) REFERENCES countries (country_id),
    CONSTRAINT fk_children_second_nationality
        FOREIGN KEY (second_nationality_country_id) REFERENCES countries (country_id),
    CONSTRAINT fk_children_denomination  FOREIGN KEY (denomination_id) REFERENCES denominations (denomination_id),
    -- MATCH FULL: entweder steht die Schulart mit ihren beiden Grenzen da oder
    -- keine der drei Spalten — sonst blieben die Grenzen bei einem leeren
    -- `school_branch_id` ungeprüft und der CHECK unten liefe ins Leere.
    CONSTRAINT fk_children_branch
        FOREIGN KEY (school_branch_id, first_grade_level, final_grade_level)
        REFERENCES school_branches (school_branch_id, first_grade_level, final_grade_level)
        MATCH FULL,
    CONSTRAINT fk_children_previous_school
        FOREIGN KEY (previous_school_id) REFERENCES previous_schools (previous_school_id),
    -- Zusammengesetzt, damit ein Kind nicht in einer Klasse der anderen
    -- Schulart landen kann (rules.md Abschnitt 1, „ableitbarer Wert … per
    -- zusammengesetztem Fremdschlüssel an sein Original gebunden").
    -- Was daraus für den Jahreslauf folgt: Beim Viertklässler, der in die eigene
    -- Realschule wechselt — „bei dem ändern sich nur Schulart und Stufe" (04) —,
    -- ändern sich in dieser Zeile drei Spalten und nicht zwei. Seine Klasse ist
    -- bis zum 31. Juli eine der Grundschule; der Lauf am 1. August leert die
    -- Klassenzuordnung mit der Schulart, sonst bleibt er an dieser Zeile
    -- stehen und lässt alle folgenden liegen („niemand kann ihn aufhalten", 04).
    -- Die neue Klasse setzt danach 15, Schritt 2 — dort steht die Schulart schon
    -- auf Realschule. Der Fremdschlüssel ist damit nicht zu eng: Ohne ihn
    -- schriebe der Lauf den Wechsler in eine Grundschulklasse fort.
    CONSTRAINT fk_children_class
        FOREIGN KEY (class_id, school_branch_id) REFERENCES classes (class_id, school_branch_id),
    CONSTRAINT uq_children_person       UNIQUE (person_id),
    -- Trägt den zusammengesetzten Fremdschlüssel von `child_group_memberships`
    -- (klassenorganisation-schema.sql): Ein Kind kommt nur in eine Gruppe seiner
    -- eigenen Schulart.
    CONSTRAINT uq_children_id_branch    UNIQUE (child_id, school_branch_id),
    CONSTRAINT uq_children_school_email UNIQUE (school_email),
    -- 04: Schulart und Stufe entstehen mit der Einschreibung und sind ab ihr
    -- Pflicht; davor trägt das Ziel die Bewerbung.
    CONSTRAINT ck_children_enrolment
        CHECK (entry_date IS NULL
               OR (school_branch_id IS NOT NULL AND grade_level IS NOT NULL)),
    -- 03: Austrittsdatum und Grund sind beide Pflicht oder beide leer.
    CONSTRAINT ck_children_exit
        CHECK ((exit_date IS NULL) = (exit_reason IS NULL)),
    CONSTRAINT ck_children_exit_reason CHECK (exit_reason <> ''),
    CONSTRAINT ck_children_exit_after_entry
        CHECK (exit_date IS NULL OR entry_date IS NULL OR exit_date >= entry_date),
    -- Eine Klasse setzt die Einschreibung voraus (15, „das Kind ist
    -- eingeschrieben … und es gibt eine Klasse, in die es passt").
    CONSTRAINT ck_children_class_needs_entry
        CHECK (class_id IS NULL OR entry_date IS NOT NULL),
    -- Wiederholen kann nur, wer schon eingeschrieben ist: „Alles rückt eine
    -- Stufe auf, was im endenden Schuljahr schon eingeschrieben war,
    -- Wiederholer ausgenommen" (04).
    CONSTRAINT ck_children_repeats_needs_entry
        CHECK (repeats_grade_school_year IS NULL OR entry_date IS NOT NULL),
    -- 04: „Wer am Ende seiner Schulart steht — Klasse 4, Klasse 10" — welche
    -- Stufen es gibt, sagt die Schulart und nicht diese Zeile.
    CONSTRAINT ck_children_grade_level
        CHECK (grade_level IS NULL
               OR (first_grade_level IS NOT NULL
                   AND grade_level BETWEEN first_grade_level AND final_grade_level)),
    CONSTRAINT ck_children_school_email CHECK (school_email <> ''),
    CONSTRAINT ck_children_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 05 (Bewerbung) — „Je Sorgeberechtigtem Name, Geschlecht, Verhältnis
-- zum Kind, Konfession, Beruf, Staatsangehörigkeit, Telefon, Mailadresse und
-- Anschrift". Die Rollentabelle zu dieser Aufzählung: Beruf, Konfession und
-- Staatsangehörigkeit sind Angaben über den Menschen und nicht über seine
-- Sorgeberechtigung in einer bestimmten Familie — sie stehen deshalb hier und
-- nicht an `family_guardians`, deren Schlüssel `(family_id, person_id)` ist.
-- „Familie heißt die Eltern, nicht der Haushalt" (hebel.md): Ein Elternteil mit
-- Kindern aus zwei Beziehungen ist Zeile in zwei `families` (so auch
-- zugang.md, „Ist eine Person Mitglied mehrerer Familien
-- (Patchwork)"), und an `family_guardians` stünde sein Beruf dann zweimal —
-- gepflegt würde einer davon (rules.md Abschnitt 1).
-- Löschanker: geht mit der Person (Cascade, Stufe 6 des Lösch-Laufs) und nicht
-- mit der Familie; ein Mensch behält seinen Beruf, wenn eine seiner Familien
-- geht.
-- Bewusst KEIN Fremdschlüssel von `family_guardians` hierher und keine
-- Pflichtzeile: alle drei Angaben sind freiwillig, und eine Zeile mit drei
-- leeren Spalten trüge keinen Sachverhalt. Sie entsteht mit der ersten
-- erhobenen Angabe — dieselbe Bauform wie `child_meal_profiles`
-- (mensa-schema.sql), wo die fehlende Zeile selbst die Aussage ist.
-- — Alternative: die drei Spalten an `persons`; Preis: `children` trägt
-- Konfession und Staatsangehörigkeit schon selbst, und ein Kind ist eine
-- Person — es gäbe für dieselbe Tatsache sofort wieder zwei Orte, diesmal
-- zwischen `persons` und `children`.
-- Bewusst KEIN Geburtsdatum und keine Demografie über diese Felder hinaus —
-- kein Formular erhebt sie und kein Prozess liest sie (rules.md Abschnitt 7).
CREATE TABLE guardians (
    guardian_id            uuid NOT NULL DEFAULT gen_random_uuid(),
    person_id              uuid NOT NULL,
    occupation             text,
    denomination_id        integer,
    nationality_country_id integer,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_guardians        PRIMARY KEY (guardian_id),
    CONSTRAINT fk_guardians_person FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT fk_guardians_denomination
        FOREIGN KEY (denomination_id) REFERENCES denominations (denomination_id),
    CONSTRAINT fk_guardians_nationality
        FOREIGN KEY (nationality_country_id) REFERENCES countries (country_id),
    -- Der ganze Zweck dieser Tabelle: je Mensch genau eine Zeile, gleich in wie
    -- vielen Familien er sorgeberechtigt ist.
    CONSTRAINT uq_guardians_person UNIQUE (person_id),
    CONSTRAINT ck_guardians_occupation CHECK (occupation <> ''),
    CONSTRAINT ck_guardians_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 05 (Bewerbung), dieselbe Aufzählung — hier steht, was an *dieser*
-- Sorgeberechtigung hängt und nicht am Menschen: das Verhältnis zum Kind, die
-- Einsichtsstufe, die Briefanschrift der Amtsvormundschaft und das Postflag.
-- Die drei personenweiten Angaben stehen an `guardians` darüber.
-- Löschanker: geht mit der Familie (03).
CREATE TABLE family_guardians (
    family_guardian_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    family_id            uuid NOT NULL,
    person_id            uuid NOT NULL,
    guardian_relation_id integer NOT NULL,
    -- hebel.md, „Einsichtsstufe": vom Sekretariat auf Vorlage eines Beschlusses
    -- gesetzt. Als Werteliste und ohne Vorgabewert: „voll" ist der Standard, und
    -- den setzt, wer die Zeile anlegt — eine Vorgabe wäre hier ein fester
    -- Schlüssel im DDL, den die Werteliste gerade nicht hat.
    access_level_id      integer NOT NULL,
    -- Die Briefanschrift bei einer Amtsvormundschaft — die handelnde Person
    -- steht in `persons`, die Stelle, für die sie handelt, hier.
    acting_for           text,
    -- „Wer in Briefe einzubeziehen ist" (06, 09). Sie steht neben der
    -- Einsichtsstufe und ersetzt sie nicht: die Stufe nimmt jemandem den
    -- Zugriff, dieses Häkchen nur die Post. Wer beides hat, bekommt nichts.
    include_in_correspondence boolean NOT NULL DEFAULT true,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_family_guardians        PRIMARY KEY (family_guardian_id),
    CONSTRAINT fk_family_guardians_family FOREIGN KEY (family_id) REFERENCES families (family_id) ON DELETE CASCADE,
    CONSTRAINT fk_family_guardians_person FOREIGN KEY (person_id) REFERENCES persons (person_id),
    CONSTRAINT fk_family_guardians_relation
        FOREIGN KEY (guardian_relation_id) REFERENCES guardian_relations (guardian_relation_id),
    CONSTRAINT uq_family_guardians UNIQUE (family_id, person_id),
    CONSTRAINT fk_family_guardians_access_level
        FOREIGN KEY (access_level_id) REFERENCES access_levels (access_level_id),
    CONSTRAINT ck_family_guardians_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 02 (Datenänderung) — „An der Familie die Notfallkontakte und
-- Abholberechtigten (Name, Telefonnummer, Verhältnis zum Kind; … eine nicht
-- sorgeberechtigte Person genügt …)". Löschanker: „erst, wenn die Familie kein
-- Kind mehr an der Schule hat" (03) — bewusst später als die Gesundheitsdaten.
-- An der Familie und nicht am Kind: „Eine Änderung, die mehrere Kinder
-- betrifft, wird einmal an der Familie gemacht, nicht je Kind."
CREATE TABLE family_contacts (
    family_contact_id uuid NOT NULL DEFAULT gen_random_uuid(),
    family_id         uuid NOT NULL,
    person_id         uuid NOT NULL,
    -- Freitext statt Werteliste: er beschreibt diese eine Verknüpfung („Oma",
    -- „Nachbarin"), und niemand gruppiert danach.
    relationship      text,
    -- Beides an derselben Zeile, weil dieselbe Person real beides ist; getrennt
    -- wären es zwei Zeilen mit demselben Namen.
    is_emergency_contact boolean NOT NULL DEFAULT false,
    is_pickup_authorised boolean NOT NULL DEFAULT false,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_family_contacts        PRIMARY KEY (family_contact_id),
    CONSTRAINT fk_family_contacts_family FOREIGN KEY (family_id) REFERENCES families (family_id) ON DELETE CASCADE,
    CONSTRAINT fk_family_contacts_person FOREIGN KEY (person_id) REFERENCES persons (person_id),
    CONSTRAINT uq_family_contacts UNIQUE (family_id, person_id),
    -- Eine Zeile ohne beide Rollen trüge keinen Sachverhalt.
    CONSTRAINT ck_family_contacts_role
        CHECK (is_emergency_contact OR is_pickup_authorised),
    CONSTRAINT ck_family_contacts_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 08 (Schulvertrag) — „Je Kind das SEPA-Mandat: Kontoinhaber, IBAN,
-- Kreditinstitut und der Tag der Unterschrift (Pflicht); die BIC nur bei einem
-- nicht-deutschen Konto". Löschanker: geht mit dem Kind, aber erst **zwei Jahre
-- nach seinem Austritt** — die eigene Frist des Mandats, kürzer als die des
-- Vertrags, weil es kein Rechtsdokument über den Schulplatz ist, sondern die
-- Ermächtigung zum Einzug; was tatsächlich eingezogen wurde, steht in Optigem
-- und nicht hier (Datenschutzbeauftragter, 02.09.2026).
-- Bewusst KEINE Änderung an einer bestehenden Zeile: „Geändert wird es nicht,
-- es wird ersetzt … Das abgelöste Mandat bleibt mit seinem Unterschriftsdatum
-- stehen."
-- Bewusst KEINE eigenen Unterschriftsspalten: „Eine sorgeberechtigte Person
-- füllt im Portal ein neues aus und unterschreibt" (08) — diese Unterschrift
-- ist eine Q2-Signatur wie jede andere und steht in `signatures`
-- (querschnitt-schema.sql, `sepa_mandate_id`), mit Person, Zeitpunkt und
-- Namenszug. Zwei Mechaniken für dieselbe Handlung wären zwei Orte für
-- denselben Sachverhalt (rules.md Abschnitt 1); der Namenszug hätte in der
-- zweiten ohnehin keinen Platz (grenzkarte.md, Q2). Dass jedes Mandat eine
-- trägt („der Tag der Unterschrift (Pflicht)", 08), prüft die Anwendung: eine
-- Zeile in einer anderen Tabelle lässt sich von hier aus nicht erzwingen —
-- dasselbe gilt für den Vertrag daneben.
-- [A!] Das Mandat ist eine eigene Tabelle mit Historie und trägt die
-- Bankverbindung selbst; eine `payers`-Tabelle für das Einzugsmittel gibt es
-- nicht. — Alternative: IBAN an einer Zahler-Rolle, das Mandat nur als
-- Referenz an `children` (so grenzkarte.md, Q3); Preis: nach dem Ersetzen ist
-- nicht mehr lesbar, von welchem Konto wann eingezogen werden durfte — genau
-- das, was Block 08 verlangt.
CREATE TABLE sepa_mandates (
    sepa_mandate_id  uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id         uuid NOT NULL,
    -- Der Kontoinhaber als Person, wo er im Bestand steht; weicht er ab, tragen
    -- die drei Spalten darunter seine Angaben, und sie stehen bewusst hier statt
    -- in den Stammdaten (08).
    account_holder_person_id uuid,
    account_holder_name      text,
    account_holder_address_id uuid,
    account_holder_email     text,
    iban             text NOT NULL,
    -- Nur bei einem nicht-deutschen Konto, „weil Optigem sie dort verlangt".
    bic              text,
    -- Der Name, den der Kontoinhaber beim Unterschreiben angegeben hat, und
    -- nicht der heutige: Er folgt zwar aus der Bankleitzahl in der IBAN, aber
    -- Banken fusionieren und benennen sich um, und das Mandat „bleibt mit
    -- seinem Unterschriftsdatum stehen" (08). Nachgeführt wird er deshalb nie —
    -- eine festgehaltene Tatsache wie `outbound_emails.recipient_email`, keine
    -- vergessene Ableitung.
    credit_institution text NOT NULL,
    mandate_reference text NOT NULL,
    -- Gesetzt, sobald ein neues Mandat dieses ablöst; das abgelöste bleibt
    -- stehen und wird nie geändert.
    superseded_at    timestamptz,
    -- Die erzeugte Datei des Mandats — „eine Unterlage, eine Datei" (08): Es
    -- steht als Datei für sich und nicht im PDF des Vertrags, sonst trüge es
    -- dessen Frist, und aus einem Bündel ist nichts einzeln zu löschen. Ein
    -- ersetztes Mandat bekommt seine eigene Datei, die alte bleibt stehen. Der
    -- Fremdschlüssel steht in querschnitt-schema.sql, wo `documents` entsteht.
    document_id      uuid,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_sepa_mandates       PRIMARY KEY (sepa_mandate_id),
    CONSTRAINT fk_sepa_mandates_child FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_sepa_mandates_holder
        FOREIGN KEY (account_holder_person_id) REFERENCES persons (person_id),
    CONSTRAINT fk_sepa_mandates_holder_address
        FOREIGN KEY (account_holder_address_id) REFERENCES addresses (address_id),
    CONSTRAINT uq_sepa_mandates_reference UNIQUE (mandate_reference),
    -- Entweder eine Person aus dem Bestand oder ein eigener Name, nie beides
    -- und nie keines.
    CONSTRAINT ck_sepa_mandates_holder
        CHECK ((account_holder_person_id IS NOT NULL) <> (account_holder_name IS NOT NULL)),
    -- „Weicht der Kontoinhaber ab, stehen seine Anschrift und Mailadresse am
    -- Mandat und nicht in den Stammdaten" (08) — die Bedingung gilt für alle
    -- drei Spalten und nicht nur für den Namen. Steht der Inhaber im Bestand,
    -- stehen Anschrift und Mailadresse an seiner Person; hier daneben wären sie
    -- der zweite Ort für dieselbe Angabe (rules.md Abschnitt 1).
    CONSTRAINT ck_sepa_mandates_holder_contact
        CHECK (account_holder_person_id IS NULL
               OR (account_holder_address_id IS NULL AND account_holder_email IS NULL)),
    CONSTRAINT ck_sepa_mandates_iban CHECK (iban ~ '^[A-Z]{2}[0-9A-Z]{13,32}$'),
    CONSTRAINT ck_sepa_mandates_bic
        CHECK (bic IS NOT NULL OR iban LIKE 'DE%'),
    CONSTRAINT ck_sepa_mandates_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Dieselbe IBAN darf an mehreren Mandaten stehen: „ein Mandat je Kind, aber
-- nicht je Zweck" (grenzkarte.md) — zwei Kinder derselben Familie ziehen vom
-- selben Konto und haben trotzdem je ein eigenes Mandat. Eindeutig ist allein
-- die Mandatsreferenz.
-- Je Kind darf höchstens ein Mandat gelten; abgelöste bleiben daneben stehen.
CREATE UNIQUE INDEX ix_sepa_mandates_current
    ON sepa_mandates (child_id) WHERE superseded_at IS NULL;


-- ---------------------------------------------------------------------------
-- Mitarbeitende und Rollen (Q4)
-- ---------------------------------------------------------------------------

-- Herkunft: 13 (M365-Kontenverwaltung) — „Neu ist der Mitarbeitendeneintrag:
-- Name und Haus (Pflicht), die Schuladresse (Pflicht, vom Admin) und der letzte
-- Arbeitstag, sobald er feststeht". Löschanker: `last_working_day` — ab ihm
-- rechnet der Lösch-Lauf, und ab ihm enden die Rollen von selbst (00, 13).
-- Bewusst KEINE Spalten für Vertrag, Gehalt, Stundenumfang oder Urlaub: Block
-- 13 grenzt die Personalverwaltung im eigentlichen Sinn ausdrücklich aus — und
-- `has_note` unten hält dieselbe Grenze gegen die Notiz an `persons`.
CREATE TABLE employees (
    employee_id       uuid NOT NULL DEFAULT gen_random_uuid(),
    person_id         uuid NOT NULL,
    -- Mitgeführt samt CHECK, und immer falsch: Über den zusammengesetzten
    -- Fremdschlüssel unten schließt das beides aus — eine Notiz an einer Person,
    -- die schon Mitarbeitende ist, und einen Mitarbeitendeneintrag für eine
    -- Person, die eine Notiz trägt. Ein Trigger wäre der andere Weg und kommt in
    -- diesem Schema an keiner Stelle vor.
    has_note          boolean NOT NULL DEFAULT false,
    -- Schule oder KITA. Entscheidet die M365-Domain (13) und, ob die Familie
    -- bei Putzdienst (01) und Elternbonus (14) ausgenommen ist.
    house_id          integer NOT NULL,
    -- Spiegelt den Tenant und wird allein vom Admin gepflegt (13); sie entsteht
    -- erst mit dem Konto, am leeren Feld ist ablesbar, dass es fehlt.
    work_email        text,
    -- Die Entra-Object-ID des Schulkontos: die Kennung, an der die Anmeldung
    -- hängt. Sie überlebt Heirat, Namens- und Mailwechsel, die Adresse
    -- darüber nicht — dieselbe Kennung, die `created_by` als „entra:<oid>"
    -- führt. Block 13 zählt sechs Angaben am Mitarbeitendeneintrag; dies ist
    -- keine siebte davon, sondern die Anmeldeidentität.
    entra_object_id   uuid,
    -- Freiwillig, „weil an ihm nichts hängt und ihn beim Import für die
    -- Bestandsmitarbeitenden ohnehin niemand mehr heraussucht".
    first_working_day date,
    -- Der Faden, an dem alles hängt: mit seinem Ablauf enden alle Rollen von
    -- selbst, ohne dass jemand sie entzieht.
    last_working_day  date,
    -- „An wen die Post künftig geht", woraus der Admin die Autoantwort baut;
    -- freiwillig, sonst ruft er wie heute an.
    successor_note    text,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_employees        PRIMARY KEY (employee_id),
    CONSTRAINT fk_employees_person FOREIGN KEY (person_id) REFERENCES persons (person_id),
    CONSTRAINT fk_employees_note
        FOREIGN KEY (person_id, has_note) REFERENCES persons (person_id, has_note),
    CONSTRAINT ck_employees_note   CHECK (NOT has_note),
    CONSTRAINT fk_employees_house  FOREIGN KEY (house_id)  REFERENCES houses (house_id),
    CONSTRAINT uq_employees_person     UNIQUE (person_id),
    CONSTRAINT uq_employees_work_email UNIQUE (work_email),
    CONSTRAINT uq_employees_entra      UNIQUE (entra_object_id),
    CONSTRAINT ck_employees_work_email CHECK (work_email <> ''),
    CONSTRAINT ck_employees_working_days
        CHECK (last_working_day IS NULL OR first_working_day IS NULL
               OR last_working_day >= first_working_day),
    CONSTRAINT ck_employees_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 00 (Zugang und Portal) — „je Mitarbeitendem seine Rollen, samt wer
-- sie wann vergeben oder entzogen hat …, sichtbar für Admins und
-- Geschäftsführung". Löschanker: geht mit dem Mitarbeitendeneintrag, also mit
-- `employees.last_working_day`. Bewusst KEIN Entzugsdatum als eigener
-- Lebenslauf: „eine Rollenhistorie mit einem Entzugseintrag gibt es dafür
-- nicht, weil niemand entzieht" (13) — die Spur trägt den Verlauf.
-- Bewusst KEINE Sperre gegen den Entzug der letzten Admin-Rolle, obwohl
-- hebel.md sie verlangt: „Die letzte Admin-Rolle lässt sich nicht entziehen,
-- nur übertragen." Die Regel zählt über alle Zeilen dieser Tabelle und ließe
-- sich nur mit einem Trigger halten; einen solchen kennt dieses Schema an
-- keiner Stelle, und Block 13 zieht dieselbe Grenze für den Nachbarfall — die
-- letzte Admin-Rolle endet mit dem letzten Arbeitstag, „ein Wächter wird dafür
-- nicht gebaut". Das Entziehen weist deshalb die Anwendung ab, an derselben
-- Stelle, an der sie es anbietet (00, Schritt 4). Was sich in einer Zeile
-- ausdrücken lässt, steht dagegen als Constraint — die fünf Fehleingaben des
-- Anmeldecodes (`ck_login_codes_attempts`) —; diese eine Zusage aus hebel.md
-- ist die benannte Auslassung und keine übersehene.
CREATE TABLE employee_roles (
    employee_role_id uuid NOT NULL DEFAULT gen_random_uuid(),
    employee_id      uuid NOT NULL,
    role_id          integer NOT NULL,
    -- Gesetzt allein bei der Schulleitung, die es je Schulform einmal gibt
    -- (hebel.md, „Rollen"); alle übrigen Rollen sind an keinen Zweig gebunden.
    school_branch_id integer,
    -- Das Flag der Rolle, hier mitgeführt, damit der CHECK unten es sehen kann
    -- — der zusammengesetzte Fremdschlüssel hält beide zusammen (rules.md
    -- Abschnitt 1). Ein zweiter Ort für dieselbe Tatsache entsteht damit nicht:
    -- auseinanderlaufen können sie gar nicht.
    is_branch_bound  boolean NOT NULL DEFAULT false,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_employee_roles          PRIMARY KEY (employee_role_id),
    CONSTRAINT fk_employee_roles_employee FOREIGN KEY (employee_id) REFERENCES employees (employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_employee_roles_role
        FOREIGN KEY (role_id, is_branch_bound) REFERENCES roles (role_id, is_branch_bound),
    CONSTRAINT fk_employee_roles_branch   FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    -- NULLS NOT DISTINCT, weil `school_branch_id` bei fünfzehn der sechzehn
    -- Rollen leer ist: ohne den Zusatz wäre jede zweigfreie Rolle für sich
    -- einzigartig und ließe sich beliebig oft an dieselbe Person hängen.
    CONSTRAINT uq_employee_roles
        UNIQUE NULLS NOT DISTINCT (employee_id, role_id, school_branch_id),
    -- hebel.md, „Rollen": „Eine Schulleitung sieht und entscheidet, was zu einem
    -- Kind ihrer Schulform gehört … und für die andere Schulform nichts." Eine
    -- zweiggebundene Rolle ohne Zweig sähe beide, eine zweigfreie mit Zweig
    -- verlöre die Hälfte — beides weist dieser CHECK ab.
    CONSTRAINT ck_employee_roles_branch_bound
        CHECK (is_branch_bound = (school_branch_id IS NOT NULL)),
    CONSTRAINT ck_employee_roles_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 15 (Klassenbildung) — „die Klassenlehrkraft (Pflicht, genau eine je
-- Klasse — dieselbe Lehrkraft darf mehrere Klassen führen, eine Klasse hat aber
-- nur eine; eine Doppelbesetzung wird nicht geführt)". Die Zuordnung ist deshalb
-- eine Spalte an der Klasse und keine eigene Tabelle. Löschanker: keiner
-- eigener, die Zuordnung geht mit dem Mitarbeitenden — SET NULL, denn die
-- Klasse bleibt stehen, wenn ihre
-- Lehrkraft geht.
ALTER TABLE classes
    ADD CONSTRAINT fk_classes_teacher
        FOREIGN KEY (class_teacher_id) REFERENCES employees (employee_id) ON DELETE SET NULL;


-- ---------------------------------------------------------------------------
-- Zugang
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md, „Zugang und Anmeldecode" — „Er gilt 15 Minuten und nur
-- einmal, verfällt nach fünf Fehleingaben, und je Adresse und Stunde gibt es
-- höchstens fünf." Löschanker: keiner — die Zeile ist eine kurzlebige Marke und
-- verfällt von selbst (hebel.md, „Kein Vorgang läuft ab"). Der Fremdschlüssel
-- auf `persons` steht deshalb nur am Bestätigungscode und nicht am
-- Anmeldecode: der Anmeldecode „bestätigt auch die Adresse einer Familie, die
-- es im Bestand noch gar nicht gibt (05, 09, 10)", und „das Anmeldefeld
-- antwortet auf jede Adresse gleich und verrät nicht, ob sie hinterlegt ist"
-- (hebel.md). Der Bestätigungscode dagegen gilt einer „neu eingetragenen
-- Mailadresse" (hebel.md) — eingetragen hat sie eine Person, die es gibt.
-- [A!] Der Anmeldecode bekommt eine Tabelle in Stammdaten. — Alternative: gar
-- keine, weil grenzkarte.md dem Eltern-Selfservice (8) keine eigenen Entitäten
-- gibt; Preis: Ratelimit je Adresse und Stunde und die fünf Fehleingaben
-- hätten keinen Ort und lägen im Prozessspeicher der Anwendung.
-- Bewusst NICHT zusammengelegt mit den beiden anderen Marken an einer
-- Mailadresse: `application_unlocks` (05) hebt eine Anmeldesperre auf,
-- `holiday_cost_coverage_codes` (10) tritt an die Stelle einer Zahlung. Drei
-- gleich aussehende Zeilen, drei verschiedene Sachverhalte — wer sie
-- zusammenlegt, braucht ein Typfeld und verliert die Fremdschlüssel.
CREATE TABLE login_codes (
    login_code_id  uuid NOT NULL DEFAULT gen_random_uuid(),
    email          text NOT NULL,
    -- Wessen Adresse hier auf Bestätigung wartet. Bei `email_confirmation`
    -- Pflicht: „nur eine neue Mailadresse gilt erst, wenn der Bestätigungscode
    -- eingegeben ist" (02), und bis dahin steht in `persons.email` weiter die
    -- alte — „dazu eine Info an die bisherige Adresse, dass sie ersetzt wurde".
    -- Ohne diese Spalte hätte die neue Adresse keinen Ort, an dem stünde, wem
    -- sie gehört. Bei `login` bleibt sie leer, siehe oben.
    person_id      uuid,
    -- Nur der Hash: der Klartextcode geht per Mail hinaus und hat daneben
    -- keinen Grund, in der Datenbank zu stehen.
    code_hash      text NOT NULL,
    -- Anmeldung oder Bestätigung einer neu eingetragenen Adresse — ein
    -- Mechanismus für beides (hebel.md), aber zwei unterscheidbare Anlässe.
    purpose        text NOT NULL,
    -- Bewusst KEINE Spalte für den Ablauf: „Er gilt 15 Minuten" (hebel.md) ist
    -- eine der Zahlen, die „fest und nirgends einstellbar" sind — der Ablauf
    -- ist damit `created_at + interval '15 minutes'` und sonst nichts. Ein
    -- gespeicherter Zeitpunkt daneben trüge kein Constraint, das sich über den
    -- Ableitungsweg nicht ausdrücken ließe; er wäre der zweite Ort für dieselbe
    -- Tatsache (rules.md Abschnitt 1) und ließe sich nur befüllen, indem die
    -- Anwendung die Ableitung nachbaut.
    consumed_at    timestamptz,
    failed_attempts smallint NOT NULL DEFAULT 0,
    created_at     timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT pk_login_codes PRIMARY KEY (login_code_id),
    -- Cascade: der Code ist eine kurzlebige Marke und hat keinen eigenen
    -- Anker — er geht mit der Person, wie Telefonnummer und versandte Mail
    -- (Stufe 6 des Lösch-Laufs, querschnitt-schema.sql).
    CONSTRAINT fk_login_codes_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT ck_login_codes_email   CHECK (email <> ''),
    CONSTRAINT ck_login_codes_purpose CHECK (purpose IN ('login', 'email_confirmation')),
    -- Die Bestätigung hat immer eine Person, die Anmeldung nie.
    CONSTRAINT ck_login_codes_person
        CHECK ((purpose = 'email_confirmation') = (person_id IS NOT NULL)),
    CONSTRAINT ck_login_codes_attempts CHECK (failed_attempts BETWEEN 0 AND 5)
);

-- Abgelaufene Codes werden nach 24 Stunden gelöscht, damit die Tabelle nicht
-- unbegrenzt wächst. — Alternative: stehenlassen und dem Lösch-Lauf
-- überlassen; Preis: eine Tabelle, die je Anmeldung eine Zeile sammelt und
-- deren älteste niemand mehr braucht — nach 15 Minuten ist der Code tot, nach
-- einer Stunde auch das Ratelimit, das ihn zählt.

-- Stützt die Abfrage, die das Ratelimit „je Adresse und Stunde gibt es
-- höchstens fünf" (hebel.md) in der Anwendung zählt. Die Regel selbst steht
-- bewusst NICHT als Constraint: sie zählt über ein gleitendes Fenster und
-- ließe sich nur mit einem Trigger halten, den dieses Schema nirgends kennt —
-- dieselbe begründete Auslassung wie bei der Notfallnummer an `phone_numbers`.
-- Die sechste Zeile derselben Stunde weist deshalb die Anwendung ab, nicht die
-- Datenbank.
CREATE INDEX ix_login_codes_email_created ON login_codes (email, created_at);


-- Die offene Sitzung eines Elternteils. Sie entsteht mit dem eingelösten Code
-- und endet mit dem Abmelden oder mit dem Ablauf der 30 Tage (hebel.md).
-- Zwei Sätze aus 00 tragen diese Tabelle, und ohne sie wären beide unhaltbar:
-- „Die Rollen selbst liest das System bei jedem Aufruf frisch, nicht einmalig
-- beim Anmelden" und „Es gilt sofort, auch mitten in einer laufenden Sitzung".
-- Ein selbsttragendes Token hätte seine Reichweite eingebacken und wäre 30 Tage
-- lang weder einzuholen noch zu beenden.
-- Bewusst KEINE Spalte für die Reichweite: welche Familien die Sitzung sieht,
-- folgt bei jedem Aufruf aus `email` über `persons` und `family_guardians` —
-- eine gespeicherte Kopie wäre der zweite Ort für dieselbe Tatsache
-- (rules.md Abschnitt 1) und genau der Grund, warum es die Tabelle gibt.
-- Bewusst KEINE Spalte für den letzten Zugriff: sie machte jeden Aufruf zu
-- einem UPDATE und damit zu einer Zeile in `change_log`. Was 00 wirklich
-- verlangt, ist die letzte Anmeldung, und die steht an `persons.last_login_at`.
CREATE TABLE login_sessions (
    login_session_id uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Das Postfach, das sich ausgewiesen hat — nicht die Person: eine geteilte
    -- Adresse löst auf mehrere auf (zugang.md), und als wen die Sitzung gerade
    -- handelt, steht in `person_id`.
    email            text NOT NULL,
    -- Als wen die Sitzung weitermacht; leer, solange die Wahl nicht getroffen
    -- ist oder die Adresse hier niemandem gehört. Bedienführung, keine
    -- Sicherheitsgrenze (zugang.md) — wer das Postfach hat, darf jeden Kandidaten
    -- wählen, und nur den.
    person_id        uuid,
    -- Nur der Hash, wie beim Code: der Klartext liegt im Browser, und eine
    -- Kopie der Datenbank wäre sonst ein Stapel offener Sitzungen.
    token_hash       text NOT NULL,
    created_at       timestamptz NOT NULL DEFAULT now(),
    -- Bewusst KEINE Spalte für den Ablauf, aus demselben Grund wie bei
    -- `login_codes`: „Eltern bleiben 30 Tage angemeldet" ist eine der festen
    -- Zahlen (hebel.md), der Ablauf ist damit `created_at + interval '30 days'`.
    -- Das Abmelden dagegen ist ein Ereignis und keine Ableitung — es braucht
    -- seine Spalte.
    revoked_at       timestamptz,

    CONSTRAINT pk_login_sessions PRIMARY KEY (login_session_id),
    -- Cascade wie beim Code: die Sitzung ist eine kurzlebige Marke ohne eigenen
    -- Anker und geht mit der Person (Stufe 6 des Lösch-Laufs,
    -- querschnitt-schema.sql).
    CONSTRAINT fk_login_sessions_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    -- Zwei Sitzungen mit demselben Hash gäbe es nur, wenn zwei denselben Wert
    -- gezogen hätten; das UNIQUE ist zugleich der Index, über den jeder Aufruf
    -- seine Sitzung findet.
    CONSTRAINT uq_login_sessions_token_hash UNIQUE (token_hash),
    CONSTRAINT ck_login_sessions_email CHECK (email <> '')
);


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------
-- Für die vier Felder Konfession, Beruf und Staatsangehörigkeit der Eltern und
-- Kirchengemeinde des Kindes steht die datenschutzrechtliche Antwort seit dem
-- 02.09.2026: „Wir haben keinen Erlaubnistatbestand, daher können die Felder
-- nur als freiwillige Felder stehen bleiben. Dies muss beim Ausfüllen
-- ersichtlich sein." Alle vier bleiben damit `NULL`-fähig, und keines darf je
-- Pflichtfeld eines Formulars werden — die Freiwilligkeit ist keine Eigenschaft
-- der Spalte, sondern eine des Formulars, und sie muss dort sichtbar sein, nicht
-- im Kleingedruckten. Ohne Erlaubnistatbestand trägt allein die Einwilligung;
-- eine nicht beantwortete Frage bleibt deshalb leer und wird nicht nachgefasst.
-- [?] Offen ist nur noch der fachliche Teil: Welchen Zweck hat jedes einzelne
--     Feld, und soll es überhaupt bleiben? Das entscheidet die Schulleitung
--     (so vermerkt am 02.09.2026), nicht der Datenschutzbeauftragte.
--     NICHT mehr dazu gehört die Frist der Kirchengemeinde: Sie wird weiter
--     erhoben, und über sie wird erst einige Monate NACH dem Vollimport
--     entschieden (05). Sie steht deshalb nicht mehr unter dem, was vor dem
--     Import fällig ist, und ist kein Kandidat für ein DROP COLUMN davor.
--     Was daran hängt: Solange kein Kind im Bestand steht, ist ein gestrichenes
--     Feld eine gelöschte Spalte. Nach dem Vollimport ist es eine Migration auf
--     echten Daten, und bei Konfession und Staatsangehörigkeit auf besonders
--     geschützten. Die Entscheidung gehört deshalb vor den Import, nicht
--     danach. — Schulleitung und Datenschutzbeauftragte
-- Für Vertrags- und Zahlungsdaten stehen die Fristen seit dem 02.09.2026:
-- **Schulvertrag fünf Jahre nach dem Austritt, SEPA-Mandat zwei Jahre nach dem
-- Austritt** — getrennt, weil das Mandat nur die Ermächtigung ist und der
-- Vertrag das Rechtsdokument. Der Bezugstag ist beide Male der Austritt des
-- Kindes, nicht der Tag der Unterschrift.
-- Nicht mittragend ist die Annahme, mit der diese Frage gestellt wurde: Dass
-- die aufbewahrungspflichtige Führung in ASV-BW und Optigem liegt, ist
-- bestätigt — die Pflicht trifft die Arbeitskopie nicht. Daraus folgt aber kein
-- früheres Löschen: Es gibt keinen Zwang, in der Kopie zu löschen, solange das
-- Original bleiben muss, und die ausdrückliche Empfehlung lautet, die
-- Aufbewahrung hier zu erfüllen statt in ASV-BW, weil diese Datenbank in
-- eigener Hand liegt. Wo teilweise gelöscht wird, muss gesichert bleiben, dass
-- die Originale in der Schülerakte stehen bleiben.
-- [?] Wie lange werden die Daten eines ausgeschiedenen Mitarbeitenden
--     aufbewahrt? Ohne die Antwort hat `employees.last_working_day` als
--     Löschanker kein Ziel (00, 13). Beantwortet ist erst die zweite Hälfte der
--     Frage: Name und dienstliche Mailadresse werden **nicht aktiv aus
--     nachweispflichtigen Zusammenhängen entfernt** (02.09.2026) — eine
--     abgenommene Mitarbeitsstunde, ein freigegebener Beleg und eine geführte
--     Klasse behalten ihren Urheber, auch wenn der Eintrag selbst geht. Die
--     Frist für den Eintrag fehlt weiter. — Datenschutzbeauftragte

