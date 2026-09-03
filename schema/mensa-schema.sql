-- Mensa (Domäne 6) — die eigenständige Essensanmeldung der Realschule.
-- Lesepfad: `meal_variants` ist die Werteliste, `meal_prices` der Beitrag je
-- Zahl der Esstage, `child_meal_profiles` trägt die Variante
-- je Kind — auch für ein Hortkind ohne Abo. `meal_subscriptions` ist das
-- Schuljahres-Abo, `meal_subscription_days` seine Wochentage samt
-- Gültigkeitszeitraum, weil Tage im laufenden Jahr dazukommen und wegfallen.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus; die
-- Betreuungsmodule mit Essen stehen in anmeldung-schema.sql, die Ferienmodule
-- in ferien-schema.sql — beide werden hier nur gelesen.
--
-- [A!] Eigene Tabellen statt der Betreuungsmodul-Tabellen aus 09. — Alternative:
-- das Abo als Katalogzeile „Mittagessen" über dieselbe Struktur buchen, so
-- grenzkarte.md („die eine Stelle, an der bewusst zusammengelegt wurde"); Preis:
-- Block 11 gibt dem Abo drei eigene Mechaniken, die das Betreuungsmodul nicht
-- kennt — den frühesten Beginn am 1. Oktober und sonst „zum nächsten
-- Monatsersten", die Kündigung „nur zum 31. Januar und nur, wenn die Erklärung
-- bis zum 3. Januar eingeht", und einen eigenen Monatsbeitrag „je Esstag und
-- Monat"; dazu entstehen „kein Vertragsdokument und keine Unterschrift", woran
-- die Modulanlage hängt. Der Block schlägt die Grenzkarte, und der Preis steht
-- an `uq_meal_subscription_days`: gegen ein Hortmodul mit Essen prüft die Anwendung.
-- Zwei Regeln dieses Blocks sind Überschneidungsregeln und stehen deshalb als
-- EXCLUDE statt als UNIQUE. `btree_gist` kommt mit Postgres und macht die
-- Gleichheits-Spalten daneben möglich (rules.md Abschnitt 1, Punkt 3).
--
-- Bewusst KEINE eigene Buchung für Hort- und Ferienkinder: ihr Essen folgt dem
-- gebuchten Modul, angemeldet wird es nirgends. Berechnet wird es dagegen
-- gesondert — der Betreuungsvertrag (Stand 11.12.2025) führt es als „Zuzüglich
-- Mittagessen" neben dem Monatsbeitrag und berechnet es „für alle Schüler, die
-- länger als 13 Uhr betreut werden". Beide Blöcke sagen dasselbe: 09 „Das
-- Mittagessen wird zuzüglich berechnet und steckt nicht im Modulpreis", 11
-- „Berechnet wird es trotzdem, und zwar nach derselben Staffel". Der Betrag
-- steht für beide Wege in `meal_prices`. Bewusst KEIN Küchen-Freitextfeld
-- neben der Variante: „Eine Unverträglichkeit ist genau
-- das, wofür es den Bestand gibt" (Domäne 9). Bewusst KEINE Platzzahl: „es gibt
-- keine Obergrenze der Mensa".


CREATE EXTENSION IF NOT EXISTS btree_gist;


-- Herkunft: 11 (Mensa-Anmeldung) — „Tragen je Kind die Essensvariante ein —
-- isst alles oder vegetarisch". Kein Löschanker: keine Personendaten.
CREATE TABLE meal_variants (
    meal_variant_id integer GENERATED ALWAYS AS IDENTITY,
    code            text NOT NULL,
    name            text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active        boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_meal_variants      PRIMARY KEY (meal_variant_id),
    CONSTRAINT uq_meal_variants_code UNIQUE (code)
);

-- Herkunft: 11 (Mensa-Anmeldung) — „Der Beitrag hängt an der Zahl der Esstage
-- in der Woche, gestaffelt und nicht gerechnet: derzeit 21,50 € für einen
-- Wochentag, 42,50 € für zwei, 63,50 € für drei, 84,50 € für vier und 105 € für
-- fünf, je Monat und je ein Wert im System der Geschäftsführung." Die Staffel
-- lässt sich nicht rechnen, weil sie nicht gleichmäßig steigt. Deshalb eine
-- Zeile je Tageszahl, dieselbe Bauform wie `care_module_prices`: „der Nachlass
-- steckt im Betrag, und wer ihn
-- ändern will, ändert eine Zahl statt einer Regel" (09). Kein Löschanker: keine
-- Personendaten.
-- Dieselbe Staffel trägt das Mittagessen eines Hortkindes: es wird „für alle
-- Schüler berechnet, die länger als 13 Uhr betreut werden" (Betreuungsvertrag),
-- und `care_modules.includes_lunch` sagt, an welchem Modul eines hängt. Eine
-- Liste für beide Wege, weil es nur diese eine Preisliste gibt — Hort- und
-- Realschulkind zahlen dasselbe Essen. Eine zweite Staffel wäre eine Tabelle
-- mehr und keine andere Struktur.
-- Das einzelne Essen ohne Abo steht bewusst NICHT hier: Es hat keine Zahl von
-- Esstagen, an der es hinge, und ist eine Zahl statt einer Staffel. Es fällt an,
-- wo ein Fall der Notfallbetreuung über Mittag reicht — welcher das ist, sagt
-- `emergency_care_types.care_module_id` über `care_modules.includes_lunch`
-- (anmeldung-schema.sql), und wie beim Monatsbeitrag steckt es nicht im
-- Fallpreis. Der Betrag steht deshalb als „meal_single_amount_cents" in
-- `configured_values` (querschnitt-schema.sql), wie jeder Wert, der weder je
-- Modul noch je Schulart verschieden ist; derzeit 5,90 € je Fall.
CREATE TABLE meal_prices (
    meal_price_id        integer GENERATED ALWAYS AS IDENTITY,
    -- Die Zahl der Esstage in der Woche, wie beim Hortbeitrag die Zahl der
    -- gebuchten Wochentage.
    weekday_count        smallint NOT NULL,
    valid_from           date NOT NULL,
    -- Auf elf Monate kalkuliert, September bis Juli; der August ist
    -- beitragsfrei, wie beim Hortbeitrag (09).
    monthly_amount_cents integer NOT NULL,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_meal_prices PRIMARY KEY (meal_price_id),
    CONSTRAINT uq_meal_prices UNIQUE (weekday_count, valid_from),
    CONSTRAINT ck_meal_prices_days   CHECK (weekday_count BETWEEN 1 AND 5),
    CONSTRAINT ck_meal_prices_amount CHECK (monthly_amount_cents >= 0),
    CONSTRAINT ck_meal_prices_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 11 (Mensa-Anmeldung) — „Die Variante steht am Kind, nicht am Abo,
-- und die Eltern eines Hortkindes tragen sie im Portal genauso ein, obwohl sie
-- sich nie anmelden." Löschanker: das letzte bestätigte Ende dieses Kindes, wie
-- die Gesundheitsangaben (03); ein Kind mit nur einem Werkstatttermin folgt
-- dem Anker aus 10. Eine fehlende Zeile heißt „isst alles": „‚Noch nicht
-- eingetragen' und ‚isst alles' sind dasselbe und werden nicht unterschieden."
CREATE TABLE child_meal_profiles (
    child_meal_profile_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id              uuid NOT NULL,
    meal_variant_id       integer NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_child_meal_profiles PRIMARY KEY (child_meal_profile_id),
    CONSTRAINT fk_child_meal_profiles_child
        FOREIGN KEY (child_id) REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT fk_child_meal_profiles_variant
        FOREIGN KEY (meal_variant_id) REFERENCES meal_variants (meal_variant_id),
    CONSTRAINT uq_child_meal_profiles UNIQUE (child_id),
    CONSTRAINT ck_child_meal_profiles_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 11 (Mensa-Anmeldung) — „Je Kind ein laufendes Essensabo, nie zwei
-- nebeneinander, mit den gebuchten Wochentagen (Pflicht), dem Beginn, dem Ende
-- und der Fassung der Essensbedingungen, der zugestimmt wurde." Löschanker: die
-- offene Aufbewahrungsfrist für Vertragsdaten (03). Bewusst KEIN Dokument und
-- keine Unterschrift: „bindend ist die Anmeldung gleichwohl, dafür sorgen die
-- Bedingungen, denen die Eltern zustimmen".
CREATE TABLE meal_subscriptions (
    meal_subscription_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id               uuid NOT NULL,
    -- Bewusst KEINE Spalte für das Schuljahr: „eine Schuljahrestabelle gibt es
    -- nicht, das Jahr folgt aus dem Datum (Block 04)" (stammdaten-schema.sql),
    -- und hier folgt es aus `starts_on`. Zusätzlich gespeichert trüge es kein
    -- Constraint — `ex_meal_subscriptions_period` rechnet über den Zeitraum —
    -- und wäre der zweite Ort für dieselbe Tatsache (rules.md Abschnitt 1).
    -- Frühestens der 1. Oktober; wer später anmeldet, beginnt zum nächsten
    -- Monatsersten — beides hält `ck_meal_subscriptions_start` unten.
    starts_on              date NOT NULL,
    -- Der Tag, bis zu dem es nach jetzigem Stand läuft — der 31. Juli, nach
    -- einer Kündigung zum 3. Januar der 31. Januar, beim Abgang der Tag, den
    -- das Sekretariat einträgt (03). Es wird ausgewählt, nicht gerechnet.
    ends_on                date NOT NULL,
    terms_contract_text_id integer NOT NULL,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_meal_subscriptions PRIMARY KEY (meal_subscription_id),
    CONSTRAINT fk_meal_subscriptions_child
        FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_meal_subscriptions_terms
        FOREIGN KEY (terms_contract_text_id) REFERENCES contract_texts (contract_text_id),
    -- 11: „Je Kind ein laufendes Essensabo, nie zwei nebeneinander." Als
    -- Überschneidungsregel über den tatsächlichen Zeitraum, weil ein Abo nicht
    -- immer am 31. Juli endet.
    CONSTRAINT ex_meal_subscriptions_period
        EXCLUDE USING gist (child_id WITH =,
                            daterange(starts_on, ends_on, '[]') WITH &&),
    -- Bewusst KEIN zweiter Schlüssel je Kind und Schuljahr: Wer zum 31. Januar
    -- kündigt, darf sich im selben Schuljahr neu anmelden — „Kein Stichtag,
    -- angemeldet wird jederzeit" und „Wer später anmeldet, beginnt zum nächsten
    -- Monatsersten" (11); entschieden von Sekretariat und
    -- Hauswirtschaftsleitung. Zwei Abos nacheinander sind kein Nebeneinander.
    CONSTRAINT ck_meal_subscriptions_period CHECK (ends_on >= starts_on),
    -- 11: „Das Abo beginnt frühestens am 1. Oktober … Wer später anmeldet,
    -- beginnt zum nächsten Monatsersten." Zwei Sätze, eine Regel: der Beginn
    -- ist immer ein Monatserster und liegt nie im August oder September — das
    -- Schuljahr beginnt im August, „angemeldet wird im September, wenn der
    -- neue Stundenplan steht". Das Ende trägt die Regel nicht: es ist der
    -- 31. Juli, der 31. Januar oder der Tag, den das Sekretariat beim Abgang
    -- einträgt (03).
    CONSTRAINT ck_meal_subscriptions_start
        CHECK (EXTRACT(day FROM starts_on) = 1
               AND EXTRACT(month FROM starts_on) NOT IN (8, 9)),
    CONSTRAINT ck_meal_subscriptions_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 11 (Mensa-Anmeldung) — „Gebucht wird der Wochentag im
-- Schuljahres-Abo, nicht der einzelne Tag: Wer montags gebucht ist, isst jeden
-- Montag." Löschanker: geht mit dem Abo. Der Gültigkeitszeitraum steht hier und
-- nicht am Abo, weil Tage im laufenden Jahr dazukommen („ab dem nächsten
-- Monatsersten") und zum 31. Januar wegfallen können.
-- Ein zurückgenommener, noch nicht begonnener Tag wird gelöscht statt beendet:
-- „das ist keine Verringerung, sondern die Rücknahme einer Buchung, die nie
-- lief".
CREATE TABLE meal_subscription_days (
    meal_subscription_day_id uuid NOT NULL DEFAULT gen_random_uuid(),
    meal_subscription_id     uuid NOT NULL,
    -- ISO-Wochentag, 1 = Montag bis 5 = Freitag.
    weekday                  smallint NOT NULL,
    valid_from               date NOT NULL,
    -- Leer heißt „bis zum Ende des Abos"; gesetzt wird er allein auf den
    -- 31. Januar, wenn zum 3. Januar verringert wurde.
    valid_until              date,
    created_at               timestamptz NOT NULL DEFAULT now(),
    created_by               text NOT NULL,

    CONSTRAINT pk_meal_subscription_days PRIMARY KEY (meal_subscription_day_id),
    CONSTRAINT fk_meal_subscription_days_subscription
        FOREIGN KEY (meal_subscription_id) REFERENCES meal_subscriptions (meal_subscription_id) ON DELETE CASCADE,
    -- „Je Kind und Tag gibt es höchstens ein Essen" — innerhalb des Abos trägt
    -- das dieser Schlüssel; gegen ein Hortmodul mit Essen prüft die Anwendung,
    -- weil beide in verschiedenen Tabellen stehen. Über den Zeitraum und nicht
    -- über `valid_from`: derselbe Montag ab 1.10. und ab 1.12. wären zwei
    -- verschiedene Starttage und gälten am 15.12. beide — der Monatsbeitrag
    -- zählte ihn doppelt.
    CONSTRAINT ex_meal_subscription_days_period
        EXCLUDE USING gist (meal_subscription_id WITH =, weekday WITH =,
                            daterange(valid_from, valid_until, '[]') WITH &&),
    CONSTRAINT ck_meal_subscription_days_weekday CHECK (weekday BETWEEN 1 AND 5),
    CONSTRAINT ck_meal_subscription_days_period
        CHECK (valid_until IS NULL OR valid_until >= valid_from),
    CONSTRAINT ck_meal_subscription_days_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Tagesliste der Küche: welche Abo-Tage an einem Datum gelten.
CREATE INDEX ix_meal_subscription_days_weekday
    ON meal_subscription_days (weekday, valid_from);


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------

-- [?] Der Text der Essensbedingungen braucht zwei Anpassungen, bevor er so
--     laufen kann: Anmeldung und Kündigung im Portal statt mit Unterschrift,
--     und die Lastschrift-Ermächtigung nicht mehr aus ihm selbst — das Mandat
--     steht künftig im Schulvertrag (11). — Geschäftsführung
