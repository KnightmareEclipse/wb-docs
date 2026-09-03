-- Anmeldung (Domänen 2 und 4) — eine Domäne, drei Phasen: Voranmeldung →
-- Anmeldetag und Aufnahmeentscheidung → Vertrag. Dazu der Hortvertrag, der
-- derselbe Vertragsvorgang ist, und die Betreuungsmodule.
-- Lesepfad: `applications` ist die Mitte — sie trägt Ziel, Anmeldetag,
-- Bewertung und Ergebnis. Davor stehen `enrolment_windows` und
-- `application_unlocks` (wer sich überhaupt bewerben darf), daneben die
-- Anmeldetage. Danach `contracts` mit `contract_responses` und den
-- Modulanlagen; der Hortvertrag ist derselbe Vorgang mit anderem Typ.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus.
-- Bewusst KEINE Tabelle für den Schulpflicht-Stichtag: „Der Stichtag des Landes
-- … steht deshalb nirgends" (06). Bewusst KEINE Geschwister-Selbstauskunft:
-- „Geschwister werden nicht gefragt" (05). Bewusst KEIN Hospitationszeitraum:
-- der Quereinstieg läuft „in jeder Hinsicht" außerhalb (06). Bewusst KEIN
-- Freitextfeld für den Bearbeitungsstand: „Ein Grund wird nicht eingetragen und
-- eine Notiz auch nicht — dafür gibt es kein Feld, auch kein stillgelegtes"
-- (07, Schritt 2), und derselbe Block noch einmal unter „Gehört nicht dazu":
-- „Bewertung, Ranking und Notizen der Lehrkräfte: außerhalb des Systems, auch
-- nicht halb und auch nicht als stillgelegtes Feld." Bewusst KEIN
-- Zusammensetzungswunsch: „Die Gründe — Freundschaften, Förderbedarf,
-- Ausgewogenheit — bleiben außerhalb wie das Ranking in 07" (15, Schritt 2),
-- und sein „Was dabei erhoben wird" kennt ihn nicht. Alle fünf stehen so in
-- grenzkarte.md und werden vom jüngeren Block überstimmt.
-- Bewusst KEINE Tabelle für die abgeschickte, aber nicht bezahlte Bewerbung:
-- „Wer abbricht oder das Formular schließt, fängt von vorn an: es wird nichts
-- zwischengespeichert" und „bis zur bestätigten Zahlung gibt es keine
-- Bewerbung" (05, Schritt 3); „ein abgebrochenes Formular hinterlässt nichts",
-- und „vor der Zahlung entsteht keine Bewerbung, die gelöscht werden müsste"
-- (05, Fristen und Löschen). Die abgeschickten Angaben liegen zwischen dem
-- Absenden und der bestätigten Zahlung allein im Prozessspeicher der Anwendung;
-- auf ihn und nicht auf eine Zeile hier zielt der eine Tag, nach dem sie
-- „verschwinden" (05). `applications.submitted_at` ist deshalb NOT NULL und
-- trägt den Zeitpunkt der Zahlung.
-- Der Elternfragebogen der GS-Anmeldetag-Checkliste bleibt vorerst Papier und
-- damit eine Unterlage wie jede andere: eine Q2-Zeile, die sagt, ob er
-- vorliegt, ohne dass jemand seinen Inhalt auswertet. Zieht er später ins
-- Portal, wird jede seiner Fragen ein Feld — das ist ein Nachrüsten und kein
-- Umbau, aber es beginnt mit der Fragenliste und einem Satz in 06, wer die
-- Antworten sieht.
-- Die Notfallbetreuung steht als Tagesbuchung darin (`emergency_care_bookings`,
-- Werteliste und Preise weiter oben): ein Fall je Kind und Tag, je Fall
-- berechnet, offen auch für Kinder ohne Betreuungsvertrag. Ein weiteres
-- `care_module` wäre die falsche Bauform — es hinge an einer Modulanlage, die es
-- bei diesen Kindern nicht gibt, und kennte nur einen Monatsbeitrag.
-- Bewusst KEINE Spalte für den Weg, auf dem eine Notfallbetreuung hereinkommt:
-- Portal und Nachtrag durch den Hort schreiben dieselbe Zeile, und `created_by`
-- trägt mit `guardian:` oder `entra:` bereits, welcher der beiden es war. Das
-- ist der offizielle Umweg (hebel.md) mit einer benannten Abweichung: Hier
-- trägt der Hort stellvertretend ein und nicht das Sekretariat, denn er nimmt
-- den Anruf entgegen.
-- Daneben die Brückentage (`care_bridge_days`): eine Abfrage je Tag und eine
-- Antwort je Kind, keine Buchung — an ihnen fällt kein eigener Betrag an.


-- Für `ex_contracts_care_period`: `child_id WITH =` braucht btree_gist, wie in
-- mensa-schema.sql. IF NOT EXISTS, weil beide Dateien sie anlegen und die
-- Ladereihenfolge hinter `stammdaten` und `querschnitt` offen ist.
CREATE EXTENSION IF NOT EXISTS btree_gist;


-- ---------------------------------------------------------------------------
-- Wertelisten
-- ---------------------------------------------------------------------------

-- Herkunft: grenzkarte.md, „Bewerbung" — „Der Status trägt dabei den gesamten
-- Lebenslauf und ersetzt drei naheliegende Zusatzentitäten: die Warteliste ist
-- ein Status …, die Absage ein Endstatus, und der Rücktritt … ebenfalls."
-- Kein Löschanker: keine Personendaten. Audit-Spalten, weil die beiden Flags
-- eine Regel steuern.
CREATE TABLE application_statuses (
    application_status_id integer GENERATED ALWAYS AS IDENTITY,
    code                  text NOT NULL,
    name                  text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active              boolean NOT NULL DEFAULT true,
    -- Wahr bei jedem Endstatus (Absage, Rückzug, Einschreibung); daran hängt,
    -- ob ein gebuchter Anmeldetermin verfällt (06).
    is_final              boolean NOT NULL DEFAULT false,
    -- Wahr, wo der Status die laufende Verbindung der Familie erhält — Zusage
    -- und Warteplatz ja, Absage nein (hebel.md, „Laufende Verbindung").
    keeps_connection      boolean NOT NULL DEFAULT true,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_application_statuses      PRIMARY KEY (application_status_id),
    CONSTRAINT uq_application_statuses_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel von `applications` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_application_statuses_is_final UNIQUE (application_status_id, is_final),
    CONSTRAINT ck_application_statuses_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: grenzkarte.md, „Die Voranmeldung liefert je Schulart etwas
-- anderes" — „Sein Name kommt aus einer eigenen Werteliste in Domäne 2/4, nicht
-- aus `previous_schools` — die trägt … genau die staatlichen
-- Überweisungspartner." Kein Löschanker: keine Personendaten.
CREATE TABLE kindergartens (
    kindergarten_id integer GENERATED ALWAYS AS IDENTITY,
    name            text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active        boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_kindergartens      PRIMARY KEY (kindergarten_id),
    CONSTRAINT uq_kindergartens_name UNIQUE (name)
);

-- Herkunft: 06 (Anmeldetag) — „ihre Empfehlung, Hauptschule, Realschule oder
-- Gymnasium (Pflicht)". Dieselbe Liste trägt die eigene Einschätzung des
-- Niveaus; dass es zwei Spalten sind, steht an der Bewerbung begründet.
CREATE TABLE school_levels (
    school_level_id integer GENERATED ALWAYS AS IDENTITY,
    code            text NOT NULL,
    name            text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active        boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_school_levels      PRIMARY KEY (school_level_id),
    CONSTRAINT uq_school_levels_code UNIQUE (code)
);

-- Herkunft: 06 (Anmeldetag) — „bei Grundschule Klasse 1 die Einstufung —
-- schulpflichtig, Kann-Kind oder zurückgestellt (Pflicht)". Kein Löschanker.
CREATE TABLE enrolment_assessments (
    enrolment_assessment_id integer GENERATED ALWAYS AS IDENTITY,
    code                    text NOT NULL,
    name                    text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active                boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_enrolment_assessments      PRIMARY KEY (enrolment_assessment_id),
    CONSTRAINT uq_enrolment_assessments_code UNIQUE (code)
);

-- Herkunft: 06 (Anmeldetag) — „die Empfehlung des Kindergartens, Einschulung
-- oder Zurückstellung (freiwillig)". Kein Löschanker.
CREATE TABLE kindergarten_recommendations (
    kindergarten_recommendation_id integer GENERATED ALWAYS AS IDENTITY,
    code                           text NOT NULL,
    name                           text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active                       boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_kindergarten_recommendations      PRIMARY KEY (kindergarten_recommendation_id),
    CONSTRAINT uq_kindergarten_recommendations_code UNIQUE (code)
);

-- Herkunft: 06 (Anmeldetag) — „Ebenso ergänzt werden die wahrgenommenen
-- Angebote aus 05 — Musikarche, Ferienprogramm, Clemens-KITA". Kein Löschanker.
CREATE TABLE attended_offers (
    attended_offer_id integer GENERATED ALWAYS AS IDENTITY,
    code              text NOT NULL,
    name              text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active          boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_attended_offers      PRIMARY KEY (attended_offer_id),
    CONSTRAINT uq_attended_offers_code UNIQUE (code)
);

-- Herkunft: 06 (Anmeldetag) — „Der Betreuungsbedarf — Kernzeit, Nachmittag,
-- Ganztags (freiwillig) — ist dieselbe Angabe wie das Betreuungsinteresse aus
-- 05, hier um den Umfang ergänzt". Kein Löschanker: keine Personendaten.
-- Werteliste und keine CHECK-Liste, weil die drei Namen benannte Alternativen
-- sind und keine Struktur entscheiden (rules.md Abschnitt 3). Bewusst KEINE
-- Bindung an `care_modules`: „eine Buchung ist er nicht, gebucht wird in 09".
CREATE TABLE care_need_levels (
    care_need_level_id integer GENERATED ALWAYS AS IDENTITY,
    code               text NOT NULL,
    name               text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active           boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_care_need_levels      PRIMARY KEY (care_need_level_id),
    CONSTRAINT uq_care_need_levels_code UNIQUE (code)
);

-- Herkunft: 09 (Hortvertrag) — „Die Module — Frühbetreuung, vier
-- Nachmittagsstufen bis 13:00, 14:30, 15:30 und 17:00, dazu ‚nach Mittagsschule'
-- allein für Realschule Klasse 5 — stehen mit Zeit, Abholzeit, Schulart und der
-- Angabe, ob ein Mittagessen dabei ist, als Werte im System." Kein Löschanker:
-- keine Personendaten. Bewusst KEINE Preis-Spalte hier: der Preis hängt an der
-- Zahl der Wochentage und steht deshalb in `care_module_prices`.
-- Bewusst KEINE Gruppeneinteilung der Hausaufgabenbetreuung: Klasse 1+2 und 3+4
-- werden in je zwei Gruppen betreut, aber die Einteilung ändert sich, und es
-- hängt weder eine Zusage noch eine Abrechnung daran (Betreiber, 03.09.2026) —
-- im Frontend ist sie eine Anzeigeregel, hier wäre sie eine Liste, die niemand
-- pflegt. Braucht sie je jemand, trägt sie die Bauform der Wahlmodulgruppe
-- (`klassenorganisation-schema.sql`).
CREATE TABLE care_modules (
    care_module_id   integer GENERATED ALWAYS AS IDENTITY,
    code             text NOT NULL,
    name             text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active         boolean NOT NULL DEFAULT true,
    starts_at_time   time,
    ends_at_time     time,
    -- Bis wann das Kind abgeholt sein muss; steht auf der Betreuungsliste.
    pickup_until_time time,
    -- Ein Häkchen und keine Zeitregel: „derzeit trägt jedes Modul über 13 Uhr
    -- eines, aber das ist ein Häkchen" (09). Trägt allein das Essen im
    -- Betreuungsmodul; das Essensabo der Realschule steht in mensa-schema.sql
    -- und bucht nicht über diese Tabellen (Begründung dort im Dateikopf).
    -- Das Häkchen sagt, DASS ein Essen dazugehört, nicht, dass es im Modulpreis
    -- steckt: der Betreuungsvertrag berechnet es „zuzüglich" zum Monatsbeitrag,
    -- „für alle Schüler, die länger als 13 Uhr betreut werden". Der Betrag
    -- steht in `meal_prices` (mensa-schema.sql) und richtet sich nach der Zahl
    -- der Tage mit einem solchen Modul.
    includes_lunch   boolean NOT NULL DEFAULT false,
    -- Ein Häkchen aus dem umgekehrten Grund wie sein Nachbar darüber: Das Essen
    -- ließe sich heute aus der Uhrzeit ableiten und steht trotzdem als Häkchen
    -- da; die Hausaufgabenbetreuung lässt sich NICHT ableiten — es gibt Module
    -- über Mittag ohne sie (Betreiber, 03.09.2026), und weder Uhrzeit noch Dauer
    -- sagen, welches Modul eine trägt. Sie kostet nichts und wird nicht
    -- gesondert gebucht: Wer sie besucht, ist die Liste der Kinder mit einem
    -- solchen Modul an diesem Wochentag — ein Filter über diese Spalte und kein
    -- Datum am Kind.
    includes_homework_supervision boolean NOT NULL DEFAULT false,
    -- Gesetzt, wo das Modul nur einer Schulart offensteht („nach Mittagsschule"
    -- allein Realschule); leer heißt „für alle".
    school_branch_id integer,
    -- Gesetzt, wo das Modul nur einer Klassenstufe offensteht (Klasse 5). Heißt
    -- bewusst nicht `grade_level` wie am Kind: dort ist es die Stufe, hier eine
    -- Beschränkung.
    restricted_to_grade_level smallint,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_care_modules      PRIMARY KEY (care_module_id),
    CONSTRAINT uq_care_modules_code UNIQUE (code),
    CONSTRAINT fk_care_modules_branch
        FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    -- Eine Stufenbeschränkung ohne Schulart wäre nicht auflösbar: Klasse 5 gibt
    -- es nur in der Realschule.
    CONSTRAINT ck_care_modules_grade
        CHECK (restricted_to_grade_level IS NULL OR school_branch_id IS NOT NULL),
    CONSTRAINT ck_care_modules_times
        CHECK (ends_at_time IS NULL OR starts_at_time IS NULL OR ends_at_time > starts_at_time),
    CONSTRAINT ck_care_modules_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 09 (Hortvertrag) — „Der Preis hängt am Modul und an der Zahl der
-- gebuchten Wochentage — je Modul also fünf Beträge, einer je Tageszahl, denn
-- er steigt nicht gleichmäßig und für bestimmte Tageszahlen gibt es Nachlass."
-- Die Liste der Schule nennt nicht überall alle fünf: Wo nur ein Tagessatz
-- steht (Frühbetreuung, Nachmittag 1, „nach Mittagsschule"), ist der Betrag
-- sein Vielfaches; wo daneben ein Fünf-Tage-Satz steht (Nachmittag 2 und 3),
-- gilt dieser statt des Vielfachen — dort steckt der Nachlass. Gerechnet wird
-- das einmal beim Eintragen, nicht bei jeder Abfrage: In der Tabelle stehen
-- alle fünf Beträge, und wer einen ändern will, ändert eine Zahl.
-- Kein Löschanker. Bewusst KEINE Rabattregel: „Der Nachlass steckt im Betrag,
-- und wer ihn ändern will, ändert eine Zahl statt einer Regel." Das gilt für
-- die Tagesstaffel. Die Geschwisterermäßigung steht daneben und wird hier NICHT
-- gerechnet: „Ab dem 2. Kind einer Familie, das Betreuungsleistungen im Hort an
-- der Clemens Schule bucht, bekommt das älteste Kind eine Ermäßigung der
-- Betreuungskosten von 10%. Ausgenommen davon ist die Notfall- und
-- Ferienbetreuung" (Betreuungsvertrag). Sie hängt an einem anderen Kind als dem
-- des Vertrags und ändert keinen Betrag dieser Tabelle; Weltenbaum zeigt sie als
-- Satz neben dem Monatsbeitrag („und Ermäßigungen stehen nur als Satz dabei",
-- 09), angewendet wird sie in Optigem. Der Satz selbst ist ein Wert
-- im System (`configured_values`, „care_sibling_discount_basis_points"), damit
-- die Geschäftsführung ihn ändern kann, ohne dass jemand Text anfasst. Wie jeder Wert
-- im System: „ein noch nicht gültiger lässt sich bis dahin ändern oder
-- zurücknehmen, ein bereits gültiger nicht mehr" (hebel.md) — das prüft die
-- Anwendung, `now()` ist in keinem CHECK zulässig (querschnitt-schema.sql).
CREATE TABLE care_module_prices (
    care_module_price_id integer GENERATED ALWAYS AS IDENTITY,
    care_module_id       integer NOT NULL,
    weekday_count        smallint NOT NULL,
    valid_from           date NOT NULL,
    monthly_amount_cents integer NOT NULL,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_care_module_prices PRIMARY KEY (care_module_price_id),
    CONSTRAINT fk_care_module_prices_module
        FOREIGN KEY (care_module_id) REFERENCES care_modules (care_module_id),
    CONSTRAINT uq_care_module_prices UNIQUE (care_module_id, weekday_count, valid_from),
    CONSTRAINT ck_care_module_prices_days CHECK (weekday_count BETWEEN 1 AND 5),
    CONSTRAINT ck_care_module_prices_amount CHECK (monthly_amount_cents >= 0),
    CONSTRAINT ck_care_module_prices_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: die Preisliste der Schule, geschärft am 03.09.2026 — eine
-- Notfallbetreuung „entsteht aus einem Notfall — spontan, für einen einzelnen
-- Tag, abgerechnet je Fall". Vier ihrer fünf Fälle sind dasselbe wie ein
-- Betreuungsmodul, nur je Tag statt je Monat abgerechnet: Frühbetreuung bzw.
-- Modul 1 bis 13:00 für 8 €, Modul 2 für 12 €, Modul 3 für 16 €, Modul 4 für
-- 20 €. Der fünfte — eine halbe Stunde außerhalb der Öffnungszeiten für 20 € —
-- liegt außerhalb jedes Moduls und hat als Monatsbeitrag kein Gegenstück;
-- deshalb ist `care_module_id` nullable, und deshalb steht diese Werteliste
-- neben `care_modules` statt darin: Eine Zeile dort stünde in der
-- Modul-Wochentag-Matrix von `care_module_bookings` und ließe sich als
-- Monatsmodul buchen. Kein Löschanker: keine Personendaten.
CREATE TABLE emergency_care_types (
    emergency_care_type_id integer GENERATED ALWAYS AS IDENTITY,
    code                   text NOT NULL,
    name                   text NOT NULL,
    -- Gesetzt, wo der Fall ein Betreuungsmodul ist; leer, wo er außerhalb jedes
    -- Moduls liegt. Am gesetzten Modul hängt zugleich das Mittagessen:
    -- `care_modules.includes_lunch` sagt, DASS eines dazugehört, und wie beim
    -- Monatsbeitrag steckt es nicht im Betrag — bei den Modulen 2 bis 4 wird es
    -- zusätzlich berechnet. Ein eigenes Essens-Häkchen an der Tagesbuchung
    -- wäre dieselbe Angabe ein zweites Mal.
    care_module_id         integer,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active              boolean NOT NULL DEFAULT true,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_emergency_care_types      PRIMARY KEY (emergency_care_type_id),
    CONSTRAINT uq_emergency_care_types_code UNIQUE (code),
    CONSTRAINT fk_emergency_care_types_module
        FOREIGN KEY (care_module_id) REFERENCES care_modules (care_module_id),
    -- Je Modul höchstens ein Fall. Mehrere modullose bleiben erlaubt, weil NULL
    -- in einem UNIQUE nicht mit sich selbst kollidiert — außerhalb der
    -- Öffnungszeiten gibt es kein Modul, an dem sich zählen ließe.
    CONSTRAINT uq_emergency_care_types_module UNIQUE (care_module_id),
    CONSTRAINT ck_emergency_care_types_code CHECK (code <> ''),
    CONSTRAINT ck_emergency_care_types_name CHECK (name <> ''),
    CONSTRAINT ck_emergency_care_types_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: dieselbe Preisliste. Bauform wie `care_module_prices` daneben, nur
-- ohne die Tagesstaffel: Ein Fall kennt keine Zahl gebuchter Wochentage, und
-- der Nachlass, der dort im Betrag steckt, hat hier keinen Ort. Jeder Betrag
-- trägt seinen Gültigkeitstag wie jeder Wert im System, „es gilt immer der Wert,
-- dessen Datum zuletzt erreicht wurde" (hebel.md); dass ein bereits gültiger
-- sich nicht mehr ändern lässt, prüft die Anwendung — `now()` ist in keinem
-- CHECK zulässig (querschnitt-schema.sql). Die Geschwisterermäßigung nimmt die
-- Notfallbetreuung ausdrücklich aus (Betreuungsvertrag), hier ist also auch
-- kein Satz danebenzustellen. Kein Löschanker: keine Personendaten.
-- Welche Werte der Preisliste unsere sind, klärt fragen.md Frage 9 — das
-- betrifft die Zahlen beim Seed und nicht diese Struktur.
CREATE TABLE emergency_care_prices (
    emergency_care_price_id integer GENERATED ALWAYS AS IDENTITY,
    emergency_care_type_id  integer NOT NULL,
    valid_from              date NOT NULL,
    -- Je Fall, nicht je Monat: Der Betrag fällt an dem Tag an, an dem der Fall
    -- eintritt, und wird nicht auf Raten gelegt.
    amount_cents            integer NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_emergency_care_prices PRIMARY KEY (emergency_care_price_id),
    CONSTRAINT fk_emergency_care_prices_type
        FOREIGN KEY (emergency_care_type_id)
        REFERENCES emergency_care_types (emergency_care_type_id),
    CONSTRAINT uq_emergency_care_prices UNIQUE (emergency_care_type_id, valid_from),
    CONSTRAINT ck_emergency_care_prices_amount CHECK (amount_cents >= 0),
    CONSTRAINT ck_emergency_care_prices_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: hebel.md, „Geld im System, alles andere fest" — „Dazu die beiden
-- größten Beträge, das Schulgeld und der Hortbeitrag; beide Preislisten liegen
-- inzwischen vor. Das Schulgeld hängt an Schulart und Geschwisterrang."
-- Eigene Tabelle statt `configured_values`, weil der Betrag je Schulart
-- verschieden ist: „Was je Modul, Termin oder Schulart verschieden ist —
-- Hortbeitrag, Ferienaufschlag, Schulgeld, Vertragstext —, trägt seine eigene
-- Tabelle in der zuständigen
-- Domäne" (querschnitt-schema.sql). Kein Löschanker: keine Personendaten.
-- Bewusst KEIN Gültigkeits-Ende, wie bei jedem Wert im System: „Es gilt immer
-- der Wert, dessen Datum zuletzt erreicht wurde." Block 08 liest ihn zweimal —
-- im Vertragstext und in der Regel „das Schulgeld darin ist die vollständige
-- Staffel, die ab dem Eintrittsdatum gilt — nicht die am Tag der Unterschrift
-- geltende, und nicht der eine Betrag, der auf diese Familie gerade passt"; die
-- zweite ist eine Auswahlregel und kein Constraint.
-- Die Preisliste liegt seit der Antwort der Schule vor und trägt eine zweite
-- Dimension: das Schulgeld hängt an der Schulart UND daran, das wievielte Kind
-- der Familie es ist — Grundschule 145 / 125 / 105 / 0 €, Realschule 150 / 130 /
-- 110 / 0 € je Monat, gültig ab August 2026. Der Nachlass steckt wie beim
-- Hortbeitrag im Betrag und nicht in einer Regel (hebel.md), deshalb eine Zeile
-- je Rang statt eines Grundpreises mit Abzug.
-- In den Vertrag geht die VOLLSTÄNDIGE Staffel seiner Schulart, nicht der eine
-- Betrag, der beim Unterschreiben auf diese Familie passte: Der Rang ändert
-- sich, wenn ein Geschwister dazukommt oder die Schule verlässt, und ein
-- Vertrag, in dem „105 €" steht, weil damals drei Kinder da waren, wäre danach
-- falsch. Gelesen wird die Staffel Rang für Rang zum Eintrittsdatum — „es gilt
-- immer der Wert, dessen Datum zuletzt erreicht wurde" (hebel.md) —, und was
-- im erzeugten Dokument steht, friert mit ihm ein (08). Auch das ist eine
-- Auswahlregel und kein Constraint.
CREATE TABLE tuition_fees (
    tuition_fee_id       integer GENERATED ALWAYS AS IDENTITY,
    school_branch_id     integer NOT NULL,
    -- Das wievielte Kind: 1, 2, 3 und 4 für das vierte und jedes weitere
    -- (dann 0 €). Gezählt wird über beide Schularten zusammen, weil der Vertrag
    -- mit dem Trägerverein geschlossen wird, der beide Schulen verantwortet —
    -- der Rang steht deshalb nicht je Schulform fest, sondern folgt aus den
    -- Kindern der Familie. Welchen Rang ein Kind hat, rechnet die Anwendung
    -- beim Lesen des Betrags; hier steht nur, was ein Rang kostet.
    sibling_rank         smallint NOT NULL,
    valid_from           date NOT NULL,
    -- Monatlich wie der Hortbeitrag daneben: „damit die erste Rate im September
    -- mit den richtigen Zahlen läuft" (04). Der Vertrag zieht zwölf solche
    -- Beiträge im Jahr ein, zur Monatsmitte per SEPA-Lastschrift — anders als
    -- der Hortbeitrag mit elf Raten (09). Die Zahlungspflicht beginnt am 1.
    -- August oder, bei Eintritt im laufenden Schuljahr, am Ersten des
    -- Eintrittsmonats; sie folgt damit aus `children.entry_date` und braucht
    -- keine eigene Spalte. Ermäßigungen über den Geschwisterrang hinaus —
    -- etwa die Einkommensermäßigung auf Antrag — rechnet dieser Block nicht:
    -- sie wendet die Buchhaltung in Optigem an, wie beim Hortbeitrag (09).
    monthly_amount_cents integer NOT NULL,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_tuition_fees PRIMARY KEY (tuition_fee_id),
    CONSTRAINT fk_tuition_fees_branch
        FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    CONSTRAINT uq_tuition_fees UNIQUE (school_branch_id, sibling_rank, valid_from),
    -- Vier Ränge, weil der vierte alle weiteren mitträgt („ab dem vierten Kind
    -- beitragsfrei", 08).
    CONSTRAINT ck_tuition_fees_rank CHECK (sibling_rank BETWEEN 1 AND 4),
    CONSTRAINT ck_tuition_fees_amount CHECK (monthly_amount_cents >= 0),
    CONSTRAINT ck_tuition_fees_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Phase 1 — wer sich bewerben darf
-- ---------------------------------------------------------------------------

-- Herkunft: 05 (Bewerbung) — „Öffnet die Voranmeldung je Schulart für das
-- kommende Schuljahr — Grundschule Klasse 1, Realschule Klasse 5 — und setzt
-- ein Schließdatum, sobald es feststeht." Löschanker: keiner, keine
-- Personendaten. Bewusst KEINE Zeile für den Quereinstieg: „Der Quereinstieg
-- braucht das nicht, er ist immer offen."
CREATE TABLE enrolment_windows (
    enrolment_window_id integer GENERATED ALWAYS AS IDENTITY,
    school_branch_id    integer NOT NULL,
    target_grade_level  smallint NOT NULL,
    -- Die beiden Grenzen der Schulart, mitgeführt wie an `children`, damit der
    -- CHECK unten sie sehen kann: „Grundschule Klasse 1, Realschule Klasse 5"
    -- (05) — welche Stufen es gibt, sagt die Schulart und nicht diese Zeile.
    first_grade_level   smallint NOT NULL,
    final_grade_level   smallint NOT NULL,
    target_school_year  smallint NOT NULL,
    opens_at            timestamptz NOT NULL,
    -- Leer heißt „bleibt sie offen, bis eines gesetzt wird" (05); das
    -- Sekretariat darf es jederzeit vorziehen oder verschieben, auch nachdem
    -- es verstrichen ist.
    closes_at           timestamptz,
    created_at          timestamptz NOT NULL DEFAULT now(),
    created_by          text NOT NULL,

    CONSTRAINT pk_enrolment_windows PRIMARY KEY (enrolment_window_id),
    -- Zusammengesetzt auf `uq_school_branches_grades`, damit die Grenzen die
    -- der Schulart sind und nicht irgendwelche (rules.md Abschnitt 1). MATCH
    -- FULL wie an `children` braucht es nicht: alle drei Spalten sind Pflicht.
    CONSTRAINT fk_enrolment_windows_branch
        FOREIGN KEY (school_branch_id, first_grade_level, final_grade_level)
        REFERENCES school_branches (school_branch_id, first_grade_level, final_grade_level),
    CONSTRAINT uq_enrolment_windows
        UNIQUE (school_branch_id, target_grade_level, target_school_year),
    CONSTRAINT ck_enrolment_windows_grade_level
        CHECK (target_grade_level BETWEEN first_grade_level AND final_grade_level),
    CONSTRAINT ck_enrolment_windows_order CHECK (closes_at IS NULL OR closes_at > opens_at),
    CONSTRAINT ck_enrolment_windows_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 05 (Bewerbung) — „Die Freischaltung nennt das Ziel, gilt für alle
-- Kinder dieser Adresse und läuft nach 14 Tagen ab". Löschanker: „eine nicht
-- genutzte Freischaltung verfällt nach 14 Tagen und nimmt die Adresse mit".
-- Sie hängt an der Mailadresse und nicht an einer Person: die Familie kann der
-- Schule noch unbekannt sein.
CREATE TABLE application_unlocks (
    application_unlock_id uuid NOT NULL DEFAULT gen_random_uuid(),
    email                 text NOT NULL,
    school_branch_id      integer NOT NULL,
    target_grade_level    smallint NOT NULL,
    target_school_year    smallint NOT NULL,
    -- Bewusst KEINE Spalte für den Ablauf: „läuft nach 14 Tagen ab" (05) ist
    -- fest wie die Frist des Anmeldecodes (hebel.md) — der Ablauf ist
    -- `created_at + interval '14 days'` und sonst nichts. Zusätzlich
    -- gespeichert wäre er der zweite Ort für dieselbe Tatsache und trüge kein
    -- Constraint, das der Ableitungsweg nicht ausdrückte (rules.md Abschnitt 1).
    created_at            timestamptz NOT NULL DEFAULT now(),
    -- „Sie ist die einzige Ausnahme von einer harten Sperre und trägt deshalb
    -- einen Namen" (05).
    created_by            text NOT NULL,

    CONSTRAINT pk_application_unlocks PRIMARY KEY (application_unlock_id),
    CONSTRAINT fk_application_unlocks_branch
        FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    CONSTRAINT ck_application_unlocks_email  CHECK (email <> ''),
    CONSTRAINT ck_application_unlocks_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Phase 2 — Anmeldetag
-- ---------------------------------------------------------------------------

-- Herkunft: 06 (Anmeldetag) — „Legt einen Anmeldetag an: Datum, Von–Bis,
-- Pausenfenster, das Ziel … und zwei Zahlen — wie viele Minuten ein Zeitfenster
-- dauert und wie viele Kinder gleichzeitig hineinpassen." Löschanker: keiner —
-- „Der Anmeldetag selbst ist eine Organisationsangabe ohne Personenbezug und
-- bleibt stehen." Bewusst KEINE eigene Sorte für den Sondertermin: er ist „der
-- kleinste Anmeldetag" mit einem einzigen Zeitfenster.
CREATE TABLE admission_days (
    admission_day_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    school_branch_id   integer NOT NULL,
    target_grade_level smallint NOT NULL,
    -- Die beiden Grenzen der Schulart, wie an `enrolment_windows`: „das Ziel"
    -- eines Anmeldetags (06) ist eine Stufe, die es in dieser Schulart gibt.
    first_grade_level  smallint NOT NULL,
    final_grade_level  smallint NOT NULL,
    target_school_year smallint NOT NULL,
    day                date NOT NULL,
    starts_at_time     time NOT NULL,
    ends_at_time       time NOT NULL,
    break_from_time    time,
    break_to_time      time,
    slot_minutes       smallint NOT NULL,
    -- Harte Grenze, anders als beim Putzdienst: „hier sitzen an einem Tisch nur
    -- so viele Familien, wie Personal da ist".
    places_per_slot    smallint NOT NULL,
    -- Erst damit geht die Einladung raus; vorher sieht keine Familie den Tag.
    released_at        timestamptz,
    cancelled_at       timestamptz,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_admission_days PRIMARY KEY (admission_day_id),
    CONSTRAINT fk_admission_days_branch
        FOREIGN KEY (school_branch_id, first_grade_level, final_grade_level)
        REFERENCES school_branches (school_branch_id, first_grade_level, final_grade_level),
    -- Trägt den zusammengesetzten Fremdschlüssel der Bewerbung weiter unten.
    CONSTRAINT uq_admission_days_target
        UNIQUE (admission_day_id, school_branch_id, target_grade_level, target_school_year),
    CONSTRAINT ck_admission_days_grade_level
        CHECK (target_grade_level BETWEEN first_grade_level AND final_grade_level),
    CONSTRAINT ck_admission_days_hours CHECK (ends_at_time > starts_at_time),
    CONSTRAINT ck_admission_days_break
        CHECK ((break_from_time IS NULL) = (break_to_time IS NULL)
               AND (break_to_time IS NULL OR break_to_time > break_from_time)),
    CONSTRAINT ck_admission_days_slot_minutes CHECK (slot_minutes > 0),
    CONSTRAINT ck_admission_days_places CHECK (places_per_slot > 0),
    CONSTRAINT ck_admission_days_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 06 (Anmeldetag) — „Daraus erzeugt das System die Zeitfenster;
-- einzeln angelegt wird keines." Löschanker: keiner, keine Personendaten. Die
-- Zeile existiert trotzdem, weil das Sekretariat „die Plätze eines Zeitfensters
-- erhöhen" darf, nachdem das Raster steht.
CREATE TABLE admission_day_slots (
    admission_day_slot_id uuid NOT NULL DEFAULT gen_random_uuid(),
    admission_day_id      uuid NOT NULL,
    starts_at             timestamptz NOT NULL,
    -- Nur gesetzt, wo von der Zahl des Tages abgewichen wird; leer heißt, es
    -- gilt die Zahl des Tages.
    places_override       smallint,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_admission_day_slots PRIMARY KEY (admission_day_slot_id),
    CONSTRAINT fk_admission_day_slots_day
        FOREIGN KEY (admission_day_id) REFERENCES admission_days (admission_day_id) ON DELETE CASCADE,
    CONSTRAINT uq_admission_day_slots UNIQUE (admission_day_id, starts_at),
    -- Trägt den zusammengesetzten Fremdschlüssel der Bewerbung: er bindet das
    -- gebuchte Zeitfenster an den Tag, der daneben steht (rules.md Abschnitt 1).
    CONSTRAINT uq_admission_day_slots_id_day UNIQUE (admission_day_slot_id, admission_day_id),
    CONSTRAINT ck_admission_day_slots_places CHECK (places_override > 0),
    CONSTRAINT ck_admission_day_slots_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Die Bewerbung
-- ---------------------------------------------------------------------------

-- Herkunft: 05 (Bewerbung) — „Je Bewerbung ihr Ziel — Schulart, Zielstufe und
-- Zielschuljahr (Pflicht) …, dazu Eingang und Zahlung." Löschanker: der
-- Endstatus — „die Frist beginnt mit dem hier gesetzten Ende" (07) — und
-- **sechs Monate danach** (Datenschutzbeauftragter, 02.09.2026). Mit der
-- Bewerbung gehen die Personenzeilen, die allein mit ihr entstanden sind;
-- sonst wüchse der Stammdatenbestand mit Leuten, die nie an der Schule waren.
-- Die Löschankündigung davor und das Anhalten im Einzelfall stehen als
-- gemeinsamer Hebel in hebel.md — zwei Ankündigungen, zwei Wochen und eine
-- Woche vorher. Die Stellen sind hier das Sekretariat und die Schulleitung der
-- beworbenen Schulart: `school_branch_id` steht an dieser Tabelle, und es gibt
-- zwei Schulleitungen, je eine für Grundschule und Realschule
-- (`roles.is_branch_bound`, stammdaten-schema.sql). Bewusst KEINE Spalten für Geschwister,
-- Hospitationszeitraum, Absagegrund und Notiz der Entscheidungsrunde: alle vier
-- sind in ihrem Block ausdrücklich ausgeschlossen.
CREATE TABLE applications (
    application_id     uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id           uuid NOT NULL,
    school_branch_id   integer NOT NULL,
    target_grade_level smallint NOT NULL,
    -- Die beiden Grenzen der Schulart, mitgeführt wie an `children`: Aus dem
    -- Ziel der Bewerbung werden mit der Freigabe Schulart und Stufe des Kindes
    -- (08) — die Stufe darf also hier schon keine sein, die es in dieser
    -- Schulart nicht gibt.
    first_grade_level  smallint NOT NULL,
    final_grade_level  smallint NOT NULL,
    target_school_year smallint NOT NULL,
    -- Voranmeldung oder Quereinstieg; entscheidet, ob es überhaupt einen
    -- Anmeldetag gibt (06).
    source             text NOT NULL,
    -- Der Zeitpunkt der bestätigten Zahlung: „bis zur bestätigten Zahlung gibt
    -- es keine Bewerbung" (05).
    submitted_at       timestamptz NOT NULL,
    -- Wer das Formular ausgefüllt hat; folgt aus der Anmeldung und wird nicht
    -- gefragt (05).
    filling_person_id  uuid NOT NULL,
    -- „Bestätigung, dass die übrigen Sorgeberechtigten informiert sind
    -- (Pflicht; gibt es keine, entfällt die Angabe)" — deshalb nullable.
    other_guardians_informed boolean,
    -- Freiwillig; keine Zusage und kein Anspruch, aber Grundlage der
    -- Aufnahmeentscheidung (07) und der Hortplanung (09).
    care_interest      boolean,
    -- Derselbe Sachverhalt, am Anmeldetag um den Umfang ergänzt: „Der
    -- Betreuungsbedarf — Kernzeit, Nachmittag, Ganztags (freiwillig) — ist
    -- dieselbe Angabe wie das Betreuungsinteresse aus 05, hier um den Umfang
    -- ergänzt" (06). 09 liest ihn als „die einzige Vorschau darauf, mit wie
    -- vielen Kindern die Hortleitung im nächsten Jahr rechnen muss".
    care_need_level_id integer,

    -- Zweite Einrichtung neben `children.previous_school_id`: der Kindergarten
    -- liefert den Beobachtungsbogen und ist kein Überweisungspartner.
    kindergarten_id    integer,
    -- Einmaliges, sofort verbrauchtes Einverständnis und deshalb nicht Q1 —
    -- steht aber an der Bewerbung, weil der Kindergarten über den Anmeldetag
    -- hinaus nicht gebraucht wird (grenzkarte.md).
    kindergarten_consent_at timestamptz,
    -- 05: „Bei jedem Ziel in der Grundschule kommt die örtlich zuständige Schule
    -- hinzu, über welchen Weg die Bewerbung auch läuft — auch ein Quereinsteiger
    -- in Klasse 2 bleibt dort bis zur Zusage angemeldet. Das sind zwei
    -- Einrichtungen mit zwei verschiedenen Rollen im Verfahren, keine
    -- Alternative zueinander." Deshalb eine eigene Spalte neben
    -- `children.previous_school_id`, die die abgebende Schule trägt — und an der
    -- Bewerbung, weil sie nur bis zur Zusage gebraucht wird (07, Absagemail).
    local_school_id    integer,

    -- Phase 2: Anmeldetag. Zusammengesetzt mit dem Ziel, damit eine Bewerbung
    -- nicht in einem Zeitfenster eines fremden Ziels landen kann.
    admission_day_slot_id uuid,
    admission_day_id      uuid,
    -- Abschluss der Verwaltungsspur: durchgeführt oder nicht erschienen; wer
    -- nie gebucht hat, hat auch keine Spur, und dieser dritte Stand ist das
    -- leere Feld (06).
    record_outcome     text,
    -- Der letzte Punkt der Checkliste und die einzige Stelle, an der
    -- „durchgesehen" von „vergessen" unterscheidbar wird (grenzkarte.md).
    -- Trägt zugleich den dritten Zustand für `kindergarten_consent_at` und
    -- `attended_info_evening` (grenzkarte.md, „Drei Zustände").
    documents_checked_at timestamptz,
    attended_info_evening boolean NOT NULL DEFAULT false,
    -- 06: „Für alles, was am Anmeldetag nur erklärt wird — Elternmitarbeit (14)
    -- und Putzdienst, dass die örtlich zuständige Schule bis zur Zusage
    -- angemeldet bleibt, dass der Schulvertrag per Mail kommt, begrenzte
    -- Hortplätze und feste Tage, Förderverein, VVS-Infoblatt und Preisliste —,
    -- gibt es einen Haken, nicht je Punkt einen." Ohne ihn ist am Ende der Spur
    -- nicht ablesbar, ob die Punkte besprochen wurden.
    information_given_at timestamptz,
    -- 06, „Was dabei erhoben wird": „Dazu ein Freitext für Anmerkungen
    -- (freiwillig)" — der letzte Punkt derselben Aufzählung wie der Haken
    -- darüber und deshalb an derselben Stelle. Er gehört der Verwaltungsspur
    -- des Anmeldetags und nicht der Aufnahmeentscheidung, die kein Notizfeld
    -- kennt (07).
    record_note        text,
    -- Grundschule Klasse 1 (Pflicht dort, sonst leer).
    enrolment_assessment_id integer,
    kindergarten_recommendation_id integer,
    -- Realschule: das amtliche Dokument der abgebenden Schule.
    primary_school_recommendation_id integer,

    -- Bewusst KEINE Spalte für das konsolidierte Bewertungsergebnis auf der
    -- Skala Zusage / Eher Ja / Eher Nein / Absage, die grenzkarte.md vorsah:
    -- „Bewertung, Ranking und Notizen der Lehrkräfte: außerhalb des Systems,
    -- auch nicht halb und auch nicht als stillgelegtes Feld" (07), und 06
    -- merkt für 07 dasselbe vor. Der Block schlägt die Karte (Rangfolge in
    -- CLAUDE.md). Was Weltenbaum vom Ergebnis trägt, ist die
    -- Aufnahmeentscheidung selbst — Zusage, Warteplatz samt Priorität oder
    -- Absage — und die steht als `application_status_id` unten.
    -- Die eigene Einschätzung des Niveaus dagegen hält 06 ausdrücklich fest.
    -- Sie hat das engste Zugriffsprofil nach den Art.-9-Daten und braucht ein
    -- eigenes Spalten-GRANT (grenzkarte.md). Getrennt von der Empfehlung oben —
    -- dieselbe Werteliste, aber eine andere Sache: „Die Empfehlung kommt von
    -- der abgebenden Grundschule, die Bewertungstabelle fertigen die Lehrkräfte
    -- am Anmeldetag an, je nachdem, wie sich das Kind dort schlägt. Zwei Felder
    -- also, dauerhaft und nicht bis zu einer Klärung" (06). Das beantwortet den
    -- weißen Fleck der grenzkarte.md, der die beiden für denselben Wert halten
    -- könnte und deshalb „bis zur Klärung zwei Felder" vorschrieb: Geklärt ist
    -- es jetzt, und die Zahl bleibt zwei. Was die Lehrkräfte auf dem Weg zu
    -- ihrem Urteil notieren, bleibt außerhalb (07).
    assessed_level_id  integer,

    -- Ergebnis und Lebenslauf.
    application_status_id integer NOT NULL,
    -- Das Flag der Statuszeile, hier mitgeführt, damit der CHECK unten es sehen
    -- kann — `fk_applications_status` hält beide zusammen (rules.md
    -- Abschnitt 1). Ein zweiter Ort für dieselbe Tatsache entsteht damit nicht:
    -- auseinanderlaufen können sie gar nicht.
    is_final              boolean NOT NULL DEFAULT false,
    -- Eingetragen, aber noch nicht mitgeteilt: „‚noch nicht entschieden' und
    -- ‚entschieden, aber nicht gesendet' unterscheiden sich daran, dass ein
    -- Ergebnis eingetragen ist" (07).
    decided_at         timestamptz,
    released_at        timestamptz,
    -- Die 14 Tage aus 07, von Hand verschiebbar — auch nachdem sie verstrichen
    -- sind, „dann läuft sie weiter, als wäre sie nie gerissen".
    response_deadline_at timestamptz,
    -- Frei gesetzte Zahl, nach der die Warteliste sortiert; Lücken und
    -- Doppelungen sind erlaubt, das System zieht nichts nach (07).
    waiting_priority   integer,
    waiting_asked_at   timestamptz,
    waiting_confirmed_at timestamptz,
    -- Wann die Bewerbung geendet hat — der Löschanker dieser Tabelle: „die
    -- Frist beginnt mit dem hier gesetzten Ende" (07). Er steht neben dem
    -- Endstatus, weil dieser den Zeitpunkt nicht trägt; `ck_applications_final_ended`
    -- unten hält ihn an ihn gebunden.
    ended_at           timestamptz,
    -- Wer sie beendet hat — Eltern oder Schule (07); bei der Einschreibung
    -- beendet sie niemand, dort bleibt das Feld leer.
    ended_by           text,

    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_applications        PRIMARY KEY (application_id),
    CONSTRAINT fk_applications_child  FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_applications_branch
        FOREIGN KEY (school_branch_id, first_grade_level, final_grade_level)
        REFERENCES school_branches (school_branch_id, first_grade_level, final_grade_level),
    CONSTRAINT fk_applications_filling_person
        FOREIGN KEY (filling_person_id) REFERENCES persons (person_id),
    CONSTRAINT fk_applications_kindergarten
        FOREIGN KEY (kindergarten_id) REFERENCES kindergartens (kindergarten_id),
    CONSTRAINT fk_applications_local_school
        FOREIGN KEY (local_school_id) REFERENCES previous_schools (previous_school_id),
    CONSTRAINT fk_applications_care_need_level
        FOREIGN KEY (care_need_level_id) REFERENCES care_need_levels (care_need_level_id),
    -- Zusammengesetzt mit dem Tag, weil `admission_day_id` aus dem Zeitfenster
    -- folgt: Das Zeitfenster gehört genau einem Tag, und einspaltig prüfte hier
    -- niemand, ob es derselbe ist, der eine Zeile weiter steht. Für dasselbe
    -- Ziel gibt es mehr als einen Anmeldetag — der Sondertermin ist „der
    -- kleinste Anmeldetag" (06) —, und `fk_applications_admission_day` unten
    -- bindet den Tag nur ans Ziel, nicht ans Zeitfenster: eine Umbuchung, die
    -- allein das Zeitfenster setzt, ginge sonst durch, und die Einladung nennte
    -- den falschen Tag. MATCH SIMPLE genügt, weil
    -- `ck_applications_slot_and_day` unten schon erzwingt, dass beide Spalten
    -- zusammen stehen oder gar nicht.
    CONSTRAINT fk_applications_slot
        FOREIGN KEY (admission_day_slot_id, admission_day_id)
        REFERENCES admission_day_slots (admission_day_slot_id, admission_day_id),
    -- Bindet den gebuchten Tag an das Ziel der Bewerbung (rules.md Abschnitt 1).
    CONSTRAINT fk_applications_admission_day
        FOREIGN KEY (admission_day_id, school_branch_id, target_grade_level, target_school_year)
        REFERENCES admission_days (admission_day_id, school_branch_id, target_grade_level, target_school_year),
    CONSTRAINT fk_applications_enrolment_assessment
        FOREIGN KEY (enrolment_assessment_id) REFERENCES enrolment_assessments (enrolment_assessment_id),
    CONSTRAINT fk_applications_kindergarten_recommendation
        FOREIGN KEY (kindergarten_recommendation_id) REFERENCES kindergarten_recommendations (kindergarten_recommendation_id),
    CONSTRAINT fk_applications_primary_recommendation
        FOREIGN KEY (primary_school_recommendation_id) REFERENCES school_levels (school_level_id),
    CONSTRAINT fk_applications_assessed_level
        FOREIGN KEY (assessed_level_id) REFERENCES school_levels (school_level_id),
    CONSTRAINT fk_applications_status
        FOREIGN KEY (application_status_id, is_final)
        REFERENCES application_statuses (application_status_id, is_final),
    -- Trägt den zusammengesetzten Fremdschlüssel des Schulvertrags und ist
    -- deshalb zusätzlich zum Primärschlüssel nötig (rules.md Abschnitt 1).
    CONSTRAINT uq_applications_id_child UNIQUE (application_id, child_id),
    CONSTRAINT ck_applications_source CHECK (source IN ('pre_registration', 'lateral_entry')),
    -- „dieselbe Angabe … hier um den Umfang ergänzt" (06): ein Umfang ohne
    -- Bedarf wäre der zweite Ort für dieselbe Tatsache (rules.md Abschnitt 1).
    CONSTRAINT ck_applications_care_need
        CHECK (care_need_level_id IS NULL OR care_interest IS TRUE),
    -- Vorher stand hier 1..10 hart im CHECK — eine Zahl, die keine Schulart
    -- hergibt, ging damit durch; derselbe Fehler, den `children` schon behoben
    -- hat. Jetzt entscheidet die Schulart, welche Stufe ihr Ziel sein kann.
    -- Was daraus für den Jahreslauf folgt: 07, Schritt 5 rückt „jeden Warteplatz
    -- eine Stufe auf, dessen Zielschuljahr zum 31. Juli geendet hat" — am Ende
    -- der Schulart (Grundschule 4, Realschule 10) gibt es keine Stufe mehr, auf
    -- die er rücken könnte. Kein Block sagte, was dann geschieht; die Schule hat
    -- es entschieden: Dort endet der Warteplatz zum 31. Juli, wie der Jahrgang
    -- in 04 sein Austrittsdatum bekommt. Der Lauf setzt Endstatus, `ended_at`
    -- und `ended_by`, statt die Stufe zu erhöhen — sonst bricht er an dieser
    -- Zeile ab und lässt alle folgenden liegen, wie beim Schulartwechsler in
    -- stammdaten-schema.sql (`fk_children_class`).
    CONSTRAINT ck_applications_grade_level
        CHECK (target_grade_level BETWEEN first_grade_level AND final_grade_level),
    CONSTRAINT ck_applications_record_outcome
        CHECK (record_outcome IN ('completed', 'no_show')),
    -- Eine Spur ohne gebuchtes Zeitfenster gibt es nicht: „Wer nie gebucht hat,
    -- hat auch keine Spur" (06). Für die Anmerkung gilt derselbe Satz: sie ist
    -- der letzte Punkt derselben Aufzählung.
    CONSTRAINT ck_applications_record_needs_slot
        CHECK ((record_outcome IS NULL AND record_note IS NULL)
               OR admission_day_slot_id IS NOT NULL),
    -- Ein leerer Freitext ist keine Anmerkung, sondern ein leeres Feld.
    CONSTRAINT ck_applications_record_note CHECK (record_note <> ''),
    -- Zeitfenster und Tag stehen zusammen oder gar nicht.
    CONSTRAINT ck_applications_slot_and_day
        CHECK ((admission_day_slot_id IS NULL) = (admission_day_id IS NULL)),
    -- Freigegeben wird nur, was entschieden ist (07, Schritt 2 und 3).
    CONSTRAINT ck_applications_release
        CHECK (released_at IS NULL OR decided_at IS NOT NULL),
    -- 07: „die Frist beginnt mit dem hier gesetzten Ende." Ein Endstatus ohne
    -- Ende hätte zwei Folgen aus derselben Zeile: der Lösch-Lauf erreichte die
    -- abgesagte Bewerbung nie, und `ix_applications_running` sperrte zugleich
    -- den zweiten Anlauf, den 05 ausdrücklich vorsieht („nach Absage oder
    -- Rückzug ist der zweite Anlauf eine neue Bewerbung"). Die Gegenrichtung
    -- bleibt offen: bei der Einschreibung endet die Bewerbung, ohne dass jemand
    -- sie beendet — dort bleibt `ended_by` leer.
    CONSTRAINT ck_applications_final_ended
        CHECK (NOT is_final OR ended_at IS NOT NULL),
    CONSTRAINT ck_applications_ended_by CHECK (ended_by IN ('parents', 'school')),
    -- Wer eine Bewerbung beendet hat, hat sie zu einem Zeitpunkt beendet.
    CONSTRAINT ck_applications_ended
        CHECK (ended_by IS NULL OR ended_at IS NOT NULL),
    CONSTRAINT ck_applications_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- „Für dasselbe Kind und dasselbe Ziel entsteht keine zweite laufende
-- Bewerbung: wer es erneut versucht, landet in der vorhandenen" (05). Eine
-- beendete steht dagegen nicht im Weg.
CREATE UNIQUE INDEX ix_applications_running
    ON applications (child_id, school_branch_id, target_grade_level, target_school_year)
    WHERE ended_at IS NULL;

-- Ein Zeitfenster fasst nur so viele Bewerbungen, wie sein Tag vorsieht — die
-- Grenze selbst prüft die Anwendung, dieser Index trägt die Abfrage dazu.
CREATE INDEX ix_applications_slot ON applications (admission_day_slot_id)
    WHERE admission_day_slot_id IS NOT NULL;

-- Herkunft: 06 (Anmeldetag) — „Ebenso ergänzt werden die wahrgenommenen
-- Angebote aus 05 — Musikarche, Ferienprogramm, Clemens-KITA". Löschanker: geht
-- mit der Bewerbung. Mehrfachauswahl und deshalb eine Zeile je Angebot statt
-- einer Spaltenreihe.
CREATE TABLE application_offers (
    application_offer_id uuid NOT NULL DEFAULT gen_random_uuid(),
    application_id       uuid NOT NULL,
    attended_offer_id    integer NOT NULL,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_application_offers PRIMARY KEY (application_offer_id),
    CONSTRAINT fk_application_offers_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id) ON DELETE CASCADE,
    CONSTRAINT fk_application_offers_offer
        FOREIGN KEY (attended_offer_id) REFERENCES attended_offers (attended_offer_id),
    CONSTRAINT uq_application_offers UNIQUE (application_id, attended_offer_id),
    CONSTRAINT ck_application_offers_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Der Vertragsvorgang — Schulvertrag wie Hortvertrag
-- ---------------------------------------------------------------------------

-- Herkunft: 08 (Schulvertrag) und 09 (Hortvertrag) — „derselbe Vertragsvorgang
-- mit denselben vier Stationen und derselben Antwort je Erziehungsberechtigtem:
-- eine zweite Vertragstabelle wäre eine Kopie" (grenzkarte.md). Löschanker:
-- **fünf Jahre nach dem Austritt des Kindes** (Datenschutzbeauftragter,
-- 02.09.2026) — für jede Fassung dieselbe Frist und derselbe Bezugstag.
-- **Der Bezugstag ist zweigeteilt, weil es zwei Sorten Kind gibt:**
-- `children.exit_date` beim eingeschriebenen, `contracts.end_date` beim
-- externen Hortkind — „Beim externen Kind ist der Austritt das Ende seines
-- Hortvertrags, denn ein Austrittsdatum hat es nicht" (09). Ohne die zweite
-- Hälfte erreichte der Lauf ausgerechnet die Verträge nie, für die diese
-- Tabelle den Typ `care` überhaupt trägt: Ein externes Kind bekommt nie ein
-- `exit_date`, und eine Frist, die auf ein leeres Feld zeigt, läuft nicht ab.
-- Welches der beiden Felder gilt, entscheidet der Lauf am Kind und nicht ein
-- Constraint — `now()` ist in keinem CHECK zulässig (querschnitt-schema.sql). Ein
-- ersetzter Vertrag rechnet deshalb nicht ab der Freigabe seines Nachfolgers:
-- Ursprungsfassung und Update laufen gemeinsam ab dem Austritt, weil der alte
-- Vertrag belegt, was bis zur Ersetzung galt. Ein Vertrag, dessen Kind nie
-- kommt, fällt nicht heraus — der Rücktritt vor dem ersten Schultag trägt
-- dieselben fünf Jahre, gerechnet ab dem vereinbarten ersten Schultag:
-- „Dieselben fünf Jahre trägt ein Vertrag, dessen Kind nie kommt, und ein
-- ersetzter" (03). Bewusst KEINE
-- Spalte für die Kündigungsart: „Das System unterscheidet die Kündigungsarten
-- nicht, es kennt ein Enddatum und einen Grund in einem Satz" (09).
CREATE TABLE contracts (
    contract_id      uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Immer am Kind, auch beim Hortvertrag: „bei internen Kindern wie bei
    -- externen" (grenzkarte.md). Zwillinge sind zwei Verträge.
    child_id         uuid NOT NULL,
    -- Schulvertrag oder Hortvertrag. Trägt strukturell, welche Spalten gelten
    -- und wer gegenzeichnet — Schulleitung der Schulart bzw. Hortleitung.
    contract_type    text NOT NULL,
    -- Nur der Schulvertrag hat eine; ein Hortvertrag hängt am Kind (09).
    application_id   uuid,
    -- Welche Fassung des Vertragstexts gilt: „Die Fassung friert mit der Zusage
    -- ein und nicht erst mit der einzelnen Unterschrift — sonst unterschreiben
    -- Mutter und Vater verschiedene Texte" (08). Sie steht deshalb hier und
    -- nicht zusätzlich an jeder Unterschrift (querschnitt-schema.sql).
    contract_text_id integer NOT NULL,
    -- Vom Sekretariat vor dem Vorlegen geprüft; „Die Vollständigkeit sichert
    -- damit der Vorgang, nicht die Alltagsansicht" (grenzkarte.md, Q1).
    completeness_checked_at timestamptz,
    -- Die Freigabe: erst damit ist das Kind eingeschrieben bzw. die Betreuung
    -- aufgenommen, und erst damit entsteht das Dokument.
    released_at      timestamptz,
    released_by      text,
    -- Das fertige PDF; entsteht erst mit der Gegenzeichnung.
    document_id      uuid,
    -- „Vom fertigen Dokument wird eine Prüfsumme am Vertrag festgehalten, damit
    -- sich jede spätere Abweichung zeigt" (08).
    document_checksum text,
    -- „bis wann er nach jetzigem Stand läuft" — genau die Angabe, die 03 von
    -- jedem Vertrag einfordert; leer heißt „bis auf Weiteres" (09).
    runs_until       date,
    -- Der Tag, ab dem die Betreuung besteht; trägt allein der Hortvertrag, von
    -- Hand und je Kind einzeln (09).
    admission_date   date,
    end_date         date,
    -- Ein Satz wie beim Abgang (03); welche Kündigungsart vorlag, steht darin.
    end_reason       text,
    -- Nur beim Hortvertrag: „Je Kind, ob es den Heimweg allein antreten darf
    -- (Pflicht, Ja oder Nein, sichtbar für Hortkräfte und Sekretariat)" (09).
    may_walk_home_alone boolean,
    -- Nur beim Hortvertrag eines externen Kindes: „die Schule, die es besucht,
    -- samt Jahrgang (Pflicht, Freitext)" — bewusst keine Klassenstufe, an der
    -- der Jahreslauf hinge.
    external_school_note text,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_contracts       PRIMARY KEY (contract_id),
    CONSTRAINT fk_contracts_child FOREIGN KEY (child_id) REFERENCES children (child_id),
    -- Zusammengesetzt mit dem Kind, weil `child_id` beim Schulvertrag aus der
    -- Bewerbung folgt (`applications.child_id` ist NOT NULL, und ein
    -- Schulvertrag hat immer eine Bewerbung). Zwillinge sind zwei Bewerbungen
    -- und zwei Verträge mit demselben Ziel und derselben Familie; einspaltig
    -- ginge der Vertrag mit der Bewerbung des Geschwisters durch, und der
    -- Lösch-Lauf bliebe danach in Stufe 1 an genau diesem Fremdschlüssel
    -- stehen. Dieselbe Bindung wie `fk_children_class` und
    -- `fk_applications_admission_day` (rules.md Abschnitt 1).
    -- MATCH SIMPLE und nicht MATCH FULL: Der Hortvertrag trägt sein Kind ohne
    -- Bewerbung („ein Hortvertrag hängt am Kind", 09) — MATCH FULL wiese ihn
    -- ab, weil dort eine der beiden Spalten leer ist.
    CONSTRAINT fk_contracts_application
        FOREIGN KEY (application_id, child_id)
        REFERENCES applications (application_id, child_id),
    CONSTRAINT fk_contracts_text
        FOREIGN KEY (contract_text_id) REFERENCES contract_texts (contract_text_id),
    CONSTRAINT fk_contracts_document
        FOREIGN KEY (document_id) REFERENCES documents (document_id),
    CONSTRAINT ck_contracts_type CHECK (contract_type IN ('school', 'care')),
    -- Ein Schulvertrag entsteht aus einer Zusage, ein Hortvertrag nie.
    CONSTRAINT ck_contracts_application
        CHECK ((contract_type = 'school') = (application_id IS NOT NULL)),
    -- Die drei Hort-eigenen Angaben gibt es nur am Hortvertrag.
    CONSTRAINT ck_contracts_care_only
        CHECK (contract_type = 'care'
               OR (admission_date IS NULL AND may_walk_home_alone IS NULL
                   AND external_school_note IS NULL)),
    -- Und eine davon ist dort Pflicht: „ob es den Heimweg allein antreten darf
    -- (Pflicht, Ja oder Nein)" (09). Die Zeile entsteht erst mit dem Absenden
    -- des vollständig ausgefüllten Antrags (09, Schritt 4), vorher gibt es
    -- keinen Vertrag — der CHECK hält also niemanden auf.
    CONSTRAINT ck_contracts_care_home_alone
        CHECK (contract_type <> 'care' OR may_walk_home_alone IS NOT NULL),
    -- Und mit der Freigabe kommt die zweite dazu: „Gibt frei und unterschreibt
    -- für den Träger und trägt dabei das Aufnahmedatum ein" (09, Schritt 5),
    -- „Das Aufnahmedatum trägt die Hortleitung bei der Freigabe ein, immer von
    -- Hand und für jedes Kind einzeln". Vor der Freigabe steht es frei — der
    -- Antrag entsteht in Schritt 4 und weiß den Tag noch nicht.
    -- Der CHECK trägt zugleich `ex_contracts_care_period` unten: ohne
    -- Aufnahmedatum rechnete das als `daterange(NULL, …)`, also „seit jeher",
    -- und der nächste ordnungsgemäße Hortvertrag desselben Kindes würde
    -- abgewiesen, obwohl er sich mit nichts überschneidet.
    CONSTRAINT ck_contracts_care_admission
        CHECK (contract_type <> 'care' OR released_at IS NULL
               OR admission_date IS NOT NULL),
    CONSTRAINT ck_contracts_released
        CHECK ((released_at IS NULL) = (released_by IS NULL)),
    CONSTRAINT ck_contracts_released_by CHECK (released_by ~ '^(entra:|guardian:|system:)'),
    -- „Vor der Freigabe entsteht kein Dokument" (08).
    CONSTRAINT ck_contracts_document
        CHECK (document_id IS NULL OR released_at IS NOT NULL),
    -- 09: „Je Kind ein laufender Hortvertrag, nie zwei nebeneinander." Über den
    -- Zeitraum und nicht über `runs_until`: Zwei freigegebene Hortverträge
    -- desselben Kindes — einer ab dem 1. August bis zum 31. Juli, einer ab dem
    -- 1. Oktober bis auf Weiteres — laufen nebeneinander, ohne dass ihr Ende
    -- zusammenfällt; `ix_contracts_running` unten sieht davon nichts, und die
    -- eine Optigem-Aufgabe je Kind trüge danach nur einen der beiden.
    -- Der Hortvertrag hat, was der Zeitraum braucht: „Das Aufnahmedatum trägt
    -- die Hortleitung bei der Freigabe ein, immer von Hand und für jedes Kind
    -- einzeln" (09) — das ist `admission_date`. Oben endet er mit `end_date`,
    -- solange keines steht mit `runs_until` („bis wann er nach jetzigem Stand
    -- läuft"), und solange auch das leer ist, läuft er „bis auf Weiteres".
    -- Dieselbe Bauform wie `ex_meal_subscriptions_period` (mensa-schema.sql),
    -- das dieselbe Blockregel für das Essensabo trägt.
    -- Der Klasse-5-Fall aus 04 bleibt zulässig: Der alte Vertrag schließt am
    -- 31. Juli, der neue nimmt zum 1. August auf.
    CONSTRAINT ex_contracts_care_period
        EXCLUDE USING gist (child_id WITH =,
                            daterange(admission_date,
                                      coalesce(end_date, runs_until), '[]') WITH &&)
        WHERE (contract_type = 'care' AND released_at IS NOT NULL),
    CONSTRAINT ck_contracts_end
        CHECK ((end_date IS NULL) = (end_reason IS NULL)),
    CONSTRAINT ck_contracts_end_reason CHECK (end_reason <> ''),
    CONSTRAINT ck_contracts_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Dieselbe Regel — „Je Kind ein laufender Hortvertrag, nie zwei nebeneinander"
-- (09) — für den Schulvertrag, der kein eigenes Startdatum hat: Er liest es an
-- `children.entry_date`, und über einen Zeitraum lässt er sich deshalb nicht
-- ausschließen. Der Hortvertrag trägt sein `admission_date` und steht seit
-- diesem Lauf unter `ex_contracts_care_period` oben, das die Überschneidung
-- selbst rechnet; hier ist er nicht mehr dabei, sonst trüge dieselbe Regel
-- zweimal.
-- „Laufend" heißt freigegeben und ohne bekanntes Ende; `runs_until` steht
-- deshalb im Schlüssel und NICHT in der Bedingung. Vorher stand dort
-- `runs_until IS NULL`, und damit griff die Regel im Regelfall nicht: 08 führt
-- an jedem Schulvertrag „der 31. Juli des Schuljahres, in dem die Schulart
-- endet" mit — zwei freigegebene Verträge desselben Kindes gingen so
-- nebeneinander durch.
-- Zwei laufende Schulverträge unterscheiden sich allein darin, bis wann sie
-- laufen: Wer bis zum selben Tag läuft — oder beide „bis auf Weiteres", daher
-- NULLS NOT DISTINCT wie bei `employee_roles` (stammdaten) —, ist derselbe
-- Vertrag zweimal. Die beiden Fälle, die die Blöcke ausdrücklich zulassen,
-- bleiben offen:
--   * Der Viertklässler in die eigene Realschule hat von der Freigabe im Winter
--     bis zum 31. Juli zwei Schulverträge; der alte trägt sein Ende in
--     `runs_until` („bis wann er nach jetzigem Stand läuft", 03/09), der neue
--     den 31. Juli am Ende der Realschule. Das `end_date` setzt erst der
--     Jahreslauf am 1. August (04).
--   * Der Rücktritt vor der Freigabe lässt eine Zeile ohne `released_at`
--     stehen; sie ist kein laufender Vertrag, und „nach Absage oder Rückzug ist
--     der zweite Anlauf eine neue Bewerbung" (05).
-- Nicht gefangen, und für den Schulvertrag auch nicht fangbar: zwei laufende
-- Schulverträge mit verschiedenem `runs_until`, die keine Ablösung sind. Es
-- fehlt der Tag, ab dem der zweite gilt.
CREATE UNIQUE INDEX ix_contracts_running
    ON contracts (child_id, runs_until) NULLS NOT DISTINCT
    WHERE released_at IS NOT NULL AND end_date IS NULL AND contract_type = 'school';

-- Herkunft: 08 (Schulvertrag) — „Nehmen den Platz an oder lehnen ab. Wo alle
-- zustimmen müssen, zählt ein Widerspruch als Nein." Löschanker: geht mit dem
-- Vertrag. Bewusst KEINE Zeile für den, den seine Einsichtsstufe ausnimmt: er
-- „unterschreibt nicht mit und wird auch nicht erwartet".
CREATE TABLE contract_responses (
    contract_response_id uuid NOT NULL DEFAULT gen_random_uuid(),
    contract_id          uuid NOT NULL,
    person_id            uuid NOT NULL,
    -- Zwei Zeitpunkte wie bei Q1, aus demselben Grund: die ausbleibende Antwort
    -- muss von der Ablehnung unterscheidbar sein.
    accepted_at          timestamptz,
    declined_at          timestamptz,
    -- Der Haken aus Schritt 2: „alles durchsehen, was die Bewerbung erhoben hat
    -- — die eigenen Angaben und die des Kindes bis hin zu Geburtsort,
    -- Muttersprache und Konfession —, und mit einem Haken bestätigen" (08). Ein
    -- Haken und nicht zwei: der Block trennt eigene und Kind-Angaben nicht.
    data_reviewed_at     timestamptz,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_contract_responses PRIMARY KEY (contract_response_id),
    CONSTRAINT fk_contract_responses_contract
        FOREIGN KEY (contract_id) REFERENCES contracts (contract_id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_responses_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id),
    CONSTRAINT uq_contract_responses UNIQUE (contract_id, person_id),
    CONSTRAINT ck_contract_responses_answer
        CHECK ((accepted_at IS NOT NULL) <> (declined_at IS NOT NULL)),
    -- Durchgesehen hat nur, wer den Platz angenommen hat; wer ablehnt, füllt
    -- die Strecke gar nicht erst aus.
    CONSTRAINT ck_contract_responses_review
        CHECK (data_reviewed_at IS NULL OR accepted_at IS NOT NULL),
    CONSTRAINT ck_contract_responses_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Betreuungsmodule
-- ---------------------------------------------------------------------------

-- Herkunft: 09 (Hortvertrag) — „Die Modulbuchung ist eine Anlage des Vertrags,
-- und genau sie wird bei einer Anpassung neu unterschrieben und neu
-- freigegeben; der Vertrag darunter bleibt stehen, die vorigen Anlagen bleiben
-- in der Akte." Löschanker: geht mit dem Vertrag. Bewusst KEIN Monatsbeitrag
-- hier: er ergibt sich aus Modulen und Wochentagen gegen `care_module_prices`.
CREATE TABLE care_module_agreements (
    care_module_agreement_id uuid NOT NULL DEFAULT gen_random_uuid(),
    contract_id              uuid NOT NULL,
    -- „Ab wann ein neuer Umfang gilt, trägt die Hortleitung mit der Freigabe
    -- ein — nicht der Antrag entscheidet das" (09).
    valid_from               date,
    valid_until              date,
    released_at              timestamptz,
    released_by              text,
    -- Die Änderungsgebühr erlässt die Hortleitung, „wenn eine
    -- Stundenplanänderung der Anlass ist" — der im Vertrag benannte Fall.
    change_fee_waived        boolean NOT NULL DEFAULT false,
    created_at               timestamptz NOT NULL DEFAULT now(),
    created_by               text NOT NULL,

    CONSTRAINT pk_care_module_agreements PRIMARY KEY (care_module_agreement_id),
    CONSTRAINT fk_care_module_agreements_contract
        FOREIGN KEY (contract_id) REFERENCES contracts (contract_id) ON DELETE CASCADE,
    CONSTRAINT ck_care_module_agreements_released
        CHECK ((released_at IS NULL) = (released_by IS NULL)
               AND (released_at IS NULL) = (valid_from IS NULL)),
    CONSTRAINT ck_care_module_agreements_released_by
        CHECK (released_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_care_module_agreements_period
        CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from),
    CONSTRAINT ck_care_module_agreements_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Höchstens eine laufende Anlage je Vertrag; die vorigen bleiben mit ihrem
-- Enddatum stehen. Laufend heißt freigegeben: „Eine Anpassung beantragen die
-- Eltern im Portal und unterschreiben die neue Modulanlage …, die Hortleitung
-- gibt sie frei" (09, Schritt 6) — die beantragte Anlage existiert also
-- unterschrieben neben der laufenden, sonst gäbe es keinen Weg, eine Anpassung
-- überhaupt zu beantragen.
CREATE UNIQUE INDEX ix_care_module_agreements_running
    ON care_module_agreements (contract_id)
    WHERE released_at IS NOT NULL AND valid_until IS NULL;

-- Herkunft: grenzkarte.md — „Gebucht wird Modul × Wochentag, nicht das Modul
-- allein … Die Buchungseinheit ist damit zweidimensional." Löschanker: geht mit
-- der Anlage. Eine Zeile ist ein Kreuz in der Modul-Wochentag-Matrix.
CREATE TABLE care_module_bookings (
    care_module_booking_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    care_module_agreement_id uuid NOT NULL,
    care_module_id           integer NOT NULL,
    -- ISO-Wochentag, 1 = Montag bis 5 = Freitag; am Wochenende gibt es keine
    -- Betreuung.
    weekday                  smallint NOT NULL,
    created_at               timestamptz NOT NULL DEFAULT now(),
    created_by               text NOT NULL,

    CONSTRAINT pk_care_module_bookings PRIMARY KEY (care_module_booking_id),
    CONSTRAINT fk_care_module_bookings_agreement
        FOREIGN KEY (care_module_agreement_id) REFERENCES care_module_agreements (care_module_agreement_id) ON DELETE CASCADE,
    CONSTRAINT fk_care_module_bookings_module
        FOREIGN KEY (care_module_id) REFERENCES care_modules (care_module_id),
    CONSTRAINT uq_care_module_bookings
        UNIQUE (care_module_agreement_id, care_module_id, weekday),
    CONSTRAINT ck_care_module_bookings_weekday CHECK (weekday BETWEEN 1 AND 5),
    CONSTRAINT ck_care_module_bookings_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Notfallbetreuung und Brückentage
-- ---------------------------------------------------------------------------

-- Herkunft: 09 (Hortvertrag) — „Die Notfallbetreuung entsteht aus einem Notfall
-- — spontan, für einen einzelnen Tag, abgerechnet je Fall statt je Monat."
-- Sie hängt am Kind und nicht am Vertrag: Die Notfallbetreuung steht
-- Hortkindern wie Nicht-Hortkindern offen, und „ein Modul hinge an einer
-- Modulanlage, die ein Kind ohne Betreuungsvertrag nicht hat" (09).
-- Löschanker: **das letzte bestätigte Ende dieses Kindes**, wie das Essensabo
-- in mensa-schema.sql. Die fünf Jahre des Vertrags trägt sie nicht: Sie ist
-- keine Urkunde und hängt an keinem Vertrag, sondern zählt zu den
-- Betriebsdaten, auf denen „keine Aufbewahrungspflicht" liegt (03). Sie hält
-- das Kind fest, statt mit ihm zu gehen, damit der Lauf sie sieht und ein
-- Anhalten trägt.
-- Bewusst KEINE Spalte für das Mittagessen: Es folgt dem Modul des Falls
-- (`emergency_care_types.care_module_id` → `care_modules.includes_lunch`), wie
-- es beim Monatsbeitrag dem gebuchten Modul folgt — „Anmelden muss sich dafür
-- niemand" (09). Der Betrag des einzelnen Essens steht in mensa-schema.sql.
-- Bewusst KEINE Ablehnung als Zustand: Ob eine Notfallbetreuung überhaupt
-- abgelehnt werden darf, ist offen (siehe die Frage am Ende dieser Datei); bis
-- dahin ist ein Nein kein Eintrag, wie beim Hortvertrag selbst (09).
CREATE TABLE emergency_care_bookings (
    emergency_care_booking_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id                  uuid NOT NULL,
    care_date                 date NOT NULL,
    emergency_care_type_id    integer NOT NULL,
    -- Eingefroren beim Anlegen der Zeile, nicht beim Lesen: „Was schon
    -- berechnet oder bezahlt ist, bleibt bei dem Betrag, der damals galt"
    -- (hebel.md). Buchung und Fall liegen bei einem Notfall am selben oder am
    -- folgenden Tag; ein gerechneter Betrag aus `emergency_care_prices` fiele
    -- damit ohnehin gleich aus, aber er stünde nach einer Preisänderung anders
    -- auf einer Abrechnung, die längst raus ist.
    amount_cents              integer NOT NULL,
    -- Die Ankündigung. Gesetzt, wo eine vorausging — im Portal von den Eltern,
    -- am Telefon vom Hort nachgetragen; wer sie eingetragen hat, steht in
    -- `created_by`, denn die Zeile entsteht mit ihr. Leer beim unangekündigten
    -- Kind: Das ist der Papierfall, und er hat nur den Vollzug.
    booked_at                 timestamptz,
    -- Der Vollzug. Der Hort hakt ab, wer wirklich da war, und daran hängt die
    -- Abrechnung: „Abgerechnet wird, was stattgefunden hat." Leer bei einer
    -- Buchung, die sich erledigt hat. Ein eigener Urheber steht hier, weil der
    -- Vollzug eine zweite Handlung einer zweiten Stelle ist — bei einer Buchung
    -- fallen Urheber und `created_by` zusammen und brauchen keine zweite Spalte.
    attended_at               timestamptz,
    attended_by               text,
    created_at                timestamptz NOT NULL DEFAULT now(),
    created_by                text NOT NULL,

    CONSTRAINT pk_emergency_care_bookings PRIMARY KEY (emergency_care_booking_id),
    CONSTRAINT fk_emergency_care_bookings_child
        FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_emergency_care_bookings_type
        FOREIGN KEY (emergency_care_type_id)
        REFERENCES emergency_care_types (emergency_care_type_id),
    -- Ein Fall je Kind, Tag und Art; zwei halbe Stunden außerhalb der
    -- Öffnungszeiten sind damit eine Zeile und ein Betrag. Eine Stückzahl an
    -- der Zeile wäre eine Spalte, die außer bei genau diesem einen Fall niemand
    -- über 1 setzt.
    CONSTRAINT uq_emergency_care_bookings
        UNIQUE (child_id, care_date, emergency_care_type_id),
    CONSTRAINT ck_emergency_care_bookings_amount CHECK (amount_cents >= 0),
    -- Eines von beidem muss dastehen, sonst wäre die Zeile weder angekündigt
    -- noch geschehen.
    CONSTRAINT ck_emergency_care_bookings_state
        CHECK (booked_at IS NOT NULL OR attended_at IS NOT NULL),
    CONSTRAINT ck_emergency_care_bookings_attended
        CHECK ((attended_at IS NULL) = (attended_by IS NULL)),
    -- Abgehakt wird im Haus; die Eltern kündigen an, sie stellen nichts fest.
    CONSTRAINT ck_emergency_care_bookings_attended_by
        CHECK (attended_by ~ '^(entra:|system:)'),
    CONSTRAINT ck_emergency_care_bookings_created_by
        CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 09 (Hortvertrag) — „Vor manchen Ferien endet der Unterricht mitten
-- in der Woche … Für diese Brückentage fragt der Hort ab, wer sein Kind
-- trotzdem bringt — eine Abfrage je Tag, eine Antwort je Kind." Eine Zeile ist die Abfrage
-- eines Tages; angestoßen wird sie vom Hort, nie von selbst. Kein Löschanker:
-- keine Personendaten — die Antworten daneben tragen sie und gehen mit ihr.
-- Der Brückentag wird nicht gesondert berechnet: Das gebuchte Modul des Kindes
-- gilt weiter, abgefragt wird allein die Anwesenheit — deshalb eine Antwort und
-- keine Tagesbuchung wie bei der Notfallbetreuung. Eine Tagesbuchung mit eigenem
-- Betrag wäre ein zweiter Zahlweg neben dem Monatsbeitrag für Tage, die er schon
-- abdeckt.
-- [A!] Dass an einem Tag mit Ferienprogramm keine Abfrage entsteht, prüft die
--      Anwendung und kein Trigger. — Alternative: ein Trigger, der
--      `holiday_session_days` liest; Preis: `anmeldung` läse dann `ferien`,
--      während `ferien` schon `anmeldung` liest — der Ring bände die
--      Ladereihenfolge beider Domänen aneinander, die heute frei ist.
CREATE TABLE care_bridge_days (
    care_bridge_day_id uuid NOT NULL DEFAULT gen_random_uuid(),
    care_date          date NOT NULL,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_care_bridge_days PRIMARY KEY (care_bridge_day_id),
    -- Eine Abfrage je Tag; eine zweite wäre eine zweite Liste über dieselben
    -- Kinder.
    CONSTRAINT uq_care_bridge_days UNIQUE (care_date),
    CONSTRAINT ck_care_bridge_days_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 09 (Hortvertrag), dieselbe Stelle — „eine Antwort je Kind".
-- Löschanker: geht mit der Abfrage, und die gehört zum Lösch-Lauf (17).
-- Eine fehlende Zeile ist keine Antwort und heißt „kommt nicht": „Wer nicht
-- antwortet, bringt sein Kind nicht: Die stille Antwort ist die sichere" (09).
-- Deshalb steht hier kein Vorgabewert und keine Zeile auf Vorrat je
-- Kind; erwartet wird allein, wer `attending = true` eingetragen hat. Eine
-- ausdrückliche Absage ist trotzdem etwas anderes als Schweigen — der Hort
-- sieht daran, wen er gefragt bekommen hat und wer noch offen ist.
CREATE TABLE care_bridge_day_responses (
    care_bridge_day_response_id uuid NOT NULL DEFAULT gen_random_uuid(),
    care_bridge_day_id          uuid NOT NULL,
    child_id                    uuid NOT NULL,
    attending                   boolean NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    created_by                  text NOT NULL,

    CONSTRAINT pk_care_bridge_day_responses PRIMARY KEY (care_bridge_day_response_id),
    CONSTRAINT fk_care_bridge_day_responses_day
        FOREIGN KEY (care_bridge_day_id) REFERENCES care_bridge_days (care_bridge_day_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_care_bridge_day_responses_child
        FOREIGN KEY (child_id) REFERENCES children (child_id),
    -- Eine Antwort je Kind; eine geänderte ist dieselbe Zeile mit neuem Wert.
    CONSTRAINT uq_care_bridge_day_responses UNIQUE (care_bridge_day_id, child_id),
    CONSTRAINT ck_care_bridge_day_responses_created_by
        CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Fremdschlüssel des Querschnitts auf diese Domäne
-- ---------------------------------------------------------------------------
-- Die Spalten stehen in querschnitt-schema.sql; die Constraints entstehen hier,
-- weil erst jetzt Zieltabellen existieren.
ALTER TABLE signatures
    ADD CONSTRAINT fk_signatures_contract
        FOREIGN KEY (contract_id) REFERENCES contracts (contract_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_signatures_agreement
        FOREIGN KEY (care_module_agreement_id)
        REFERENCES care_module_agreements (care_module_agreement_id) ON DELETE CASCADE;

-- Mit Cascade: „Löschanker: geht mit dem Vorgang, an dem die Zahlung hängt"
-- (querschnitt-schema.sql) — sonst hielte die Zahlung die Bewerbung fest.
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_application
        FOREIGN KEY (application_id) REFERENCES applications (application_id)
        ON DELETE CASCADE;


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------





-- Beide Fristen dieser Domäne stehen seit dem 02.09.2026 und sind an ihren
-- Ankern eingetragen: Bewerbungen ohne Aufnahme sechs Monate ab dem Endstatus,
-- Verträge fünf Jahre ab dem Austritt. Was daraus für die Arbeitskopie folgt
-- und was nicht, steht an derselben Frage in stammdaten-schema.sql.
-- [?] Der Betreuungsvertragstext braucht drei Anpassungen, bevor er so laufen
--     kann: das Ende zum Ende der Klasse 4 bzw. 5 ohne Kündigung, die
--     Schriftform im Portal und die Zusage zur ausschließlichen Kenntnis der
--     Betreuungskräfte, die schon heute nicht stimmt (09). Gegen den Stand vom
--     11.12.2025 geprüft: alle drei stehen weiterhin aus. — Geschäftsführung,
--     Hortleitung
-- [?] Drei Dinge an der Notfallbetreuung sind offen und hängen zusammen: der
--     Nachweis auf dem Telefonweg — wer im Portal bucht, hat `created_by` mit
--     `guardian:`, wer anruft, hat nichts Schriftliches —, ob eine gebuchte
--     Notfallbetreuung abgelehnt werden darf, und ob eine gebuchte, aber nicht
--     wahrgenommene berechnet wird. Denkbar für den ersten Punkt sind eine
--     Bestätigung an die Familie, eine gezeichnete Tagesliste nach der Bauform
--     des Putzdienstes (01) oder gar nichts, weil der Streitfall in der Praxis
--     nicht vorkommt; entschieden ist keiner. Die Struktur trägt alle drei
--     Antworten: `booked_at` ohne `attended_at` ist die nicht wahrgenommene
--     Buchung. — Geschäftsführung
