-- Stresstest-Generator für domains/stammdaten-schema.sql — bewusst weit über
-- der realen Schulgröße (~500 Schüler), um die Join-Kosten-Annahme aus
-- rules.md Abschnitt 1 empirisch zu prüfen statt sie nur zu behaupten.
-- NICHT Teil des Schemas selbst — Wegwerf-Skript für eine Wegwerf-Datenbank.

\timing on
SET app.actor = 'system:stresstest';

-- ---------------------------------------------------------------------------
-- Lookups
-- ---------------------------------------------------------------------------
INSERT INTO school_branches (id, label) VALUES (1,'Grundschule'), (2,'Realschule');
INSERT INTO grade_levels (school_branch_id, label, sort_order, is_final_grade)
    SELECT 1, g::text, g, (g = 4) FROM generate_series(1,4) g
    UNION ALL
    SELECT 2, g::text, g, (g = 10) FROM generate_series(5,10) g;
INSERT INTO phone_types (label) VALUES ('Festnetz'), ('Mobil'), ('Arbeit');
INSERT INTO genders (label) VALUES ('männlich'), ('weiblich'), ('divers'), ('keine Angabe');
INSERT INTO salutations (label) VALUES ('Herr'), ('Frau'), ('keine Anrede');
INSERT INTO denominations (label) VALUES ('römisch-katholisch'), ('evangelisch'), ('konfessionslos');
INSERT INTO guardian_categories (label) VALUES ('Elternteil'), ('Pflegeeltern'), ('Jugendamt');

-- ---------------------------------------------------------------------------
-- Größenordnung — bewusst weit jenseits der realen ~500 Schüler
-- ---------------------------------------------------------------------------
\set n_children 500000
\set n_classes 20000

-- Klassen: Kohorten über alle Klassenstufen verteilt, entry_year/stream nur
-- zur Erfüllung der UNIQUE-Kohorten-Constraint durchnummeriert (Realismus der
-- Werte irrelevant für einen Join-Kosten-Test). entry_year/stream als
-- injektive Basis-100-Kodierung von n, mit n % 100 als Jahr statt n / 26:
-- hält entry_year innerhalb des CHECK (2000..2100) auch bei n_classes=20000,
-- und 26 Buchstaben allein reichen ohnehin nicht für 20.000 Kombinationen.
INSERT INTO classes (school_branch_id, grade_level_id, entry_year, stream)
    SELECT gl.school_branch_id, gl.id, 2000 + (n % 100), 's' || (n / 100)
    FROM generate_series(1, :n_classes) AS s(n)
    JOIN grade_levels gl ON gl.id = 1 + (s.n % 10);

-- Adressen: eine je ca. 1,6 Personen (Familien teilen sich Adressen). Straße
-- variiert (500 Werte) statt konstant — sonst testet der Adress-Suchindex
-- (postal_code, street, house_number) nichts, weil eine Spalte konstant ist.
INSERT INTO addresses (street, house_number, postal_code, city)
    SELECT 'Musterstraße ' || (n % 500), (n % 200)::text, lpad((70000 + n % 900)::text, 5, '0'), 'Musterstadt'
    FROM generate_series(1, :n_children) n;

-- Familien: ca. 1,8 Kinder je Familie
INSERT INTO families (id)
    SELECT gen_random_uuid() FROM generate_series(1, :n_children / 18 * 10);

-- Kind-Personen + children in einem Rutsch: gen_random_uuid() einmal je Zeile,
-- per CTE geteilt, damit persons.id = children.id exakt übereinstimmt.
WITH new_children AS (
    SELECT gen_random_uuid() AS id, n
    FROM generate_series(1, :n_children) n
),
addr AS (
    SELECT id, row_number() OVER () AS rn FROM addresses
),
fam AS (
    SELECT id, row_number() OVER () AS rn FROM families
),
cls AS (
    SELECT id, grade_level_id, row_number() OVER () AS rn FROM classes
)
INSERT INTO persons (id, last_name, first_name, address_id)
    SELECT nc.id, 'Nachname' || nc.n, 'Vorname' || nc.n, a.id
    FROM new_children nc
    JOIN addr a ON a.rn = 1 + (nc.n % (SELECT count(*) FROM addresses));

WITH new_children AS (
    SELECT p.id, row_number() OVER () AS n FROM persons p
),
fam AS (
    SELECT id, row_number() OVER () AS rn FROM families
),
cls AS (
    SELECT id, row_number() OVER () AS rn FROM classes
)
INSERT INTO children (id, family_id, date_of_birth, class_id, entry_date)
    SELECT nc.id,
           f.id,
           date '2010-01-01' + (nc.n % 4000)::int,
           c.id,
           date '2015-01-01' + (nc.n % 3000)::int
    FROM new_children nc
    JOIN fam f ON f.rn = 1 + (nc.n % (SELECT count(*) FROM families))
    JOIN cls c ON c.rn = 1 + (nc.n % (SELECT count(*) FROM classes));

-- Erziehungsberechtigte: ca. 1,7 je Familie, eigene persons-Zeilen + eigene Adresse.
-- Modulo-Basis als Skalar-Subquery, NICHT als count(*) OVER()-Spalte einer
-- anderen CTE in der JOIN-Bedingung: eine Bedingung wie "a.rn = 1 + (ng.n %
-- a.total)" mischt Spalten aus ng UND addr auf einer Seite des Vergleichs —
-- das ist für Postgres kein hashbarer Equi-Join mehr, sondern erzwingt einen
-- Nested-Loop über das volle Produkt beider Zeilenmengen.
WITH new_guardians AS (
    SELECT gen_random_uuid() AS id, n FROM generate_series(1, (SELECT (:n_children / 18 * 10 * 1.7)::int)) n
),
addr AS (
    SELECT id, row_number() OVER () AS rn FROM addresses
)
INSERT INTO persons (id, last_name, first_name, email, address_id)
    SELECT ng.id, 'Erziehungsberechtigt' || ng.n, 'Vorname' || ng.n,
           ('eltern' || ng.n || '@example.invalid')::citext,
           a.id
    FROM new_guardians ng
    JOIN addr a ON a.rn = 1 + (ng.n % (SELECT count(*) FROM addresses));

WITH person_pool AS (
    SELECT p.id, row_number() OVER () AS rn
    FROM persons p
    LEFT JOIN children c ON c.id = p.id
    WHERE c.id IS NULL   -- nur die gerade angelegten Erziehungsberechtigten-Personen
)
INSERT INTO guardians (id, person_id)
    SELECT gen_random_uuid(), id FROM person_pool;

-- family_guardians: jede/r Erziehungsberechtigte:r einer Familie zugeordnet
-- (gleiche Korrektur wie oben: Skalar-Subquery statt count(*) OVER()-Spalte
-- der anderen CTE in der JOIN-Bedingung)
WITH g AS (
    SELECT id, row_number() OVER () AS rn FROM guardians
),
fam AS (
    SELECT id, row_number() OVER () AS rn FROM families
)
INSERT INTO family_guardians (family_id, guardian_id)
    SELECT f.id, g.id
    FROM g
    JOIN fam f ON f.rn = 1 + (g.rn % (SELECT count(*) FROM families));

-- Telefonnummern: eine je Person (Kind + Erziehungsberechtigte), Hauptnummer markiert
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary)
    SELECT id, 1 + (row_number() OVER () % 3), '0170' || lpad((row_number() OVER ())::text, 7, '0'), true
    FROM persons;

-- Zahlungsverantwortliche: der/die erste Erziehungsberechtigte je Familie wird
-- Hauptzahler:in aller Kinder dieser Familie (Regelfall, domains/stammdaten.md)
WITH first_guardian_per_family AS (
    SELECT DISTINCT ON (family_id) family_id, guardian_id
    FROM family_guardians
    ORDER BY family_id, guardian_id
),
new_payers AS (
    INSERT INTO payers (id, person_id)
    SELECT gen_random_uuid(), g.person_id
    FROM first_guardian_per_family fg
    JOIN guardians g ON g.id = fg.guardian_id
    RETURNING id, person_id
)
INSERT INTO child_payers (child_id, payer_id, is_primary)
SELECT c.id, np.id, true
FROM children c
JOIN first_guardian_per_family fg ON fg.family_id = c.family_id
JOIN guardians g ON g.id = fg.guardian_id
JOIN new_payers np ON np.person_id = g.person_id;

-- Kontakte: eine Kontaktperson auf ca. drei Kinder, Notfallkontakt-Priorität 1
WITH new_contact_persons AS (
    SELECT gen_random_uuid() AS id, n FROM generate_series(1, greatest(:n_children / 3, 1)) n
),
inserted_persons AS (
    INSERT INTO persons (id, last_name, first_name)
    SELECT id, 'Kontakt' || n, 'Vorname' || n FROM new_contact_persons
    RETURNING id
),
new_contacts AS (
    INSERT INTO contacts (id)
    SELECT id FROM inserted_persons
    RETURNING id
),
contact_pool AS (
    SELECT id, row_number() OVER () AS rn FROM new_contacts
),
kids AS (
    SELECT id, row_number() OVER () AS rn FROM children
)
INSERT INTO child_contacts (child_id, contact_id, relationship, priority)
SELECT k.id, cp.id, 'Großmutter', 1
FROM kids k
JOIN contact_pool cp ON cp.rn = 1 + (k.rn % (SELECT count(*) FROM new_contact_persons));

ANALYZE;

SELECT 'Zeilen je Tabelle' AS info;
SELECT 'addresses' t, count(*) FROM addresses
UNION ALL SELECT 'persons', count(*) FROM persons
UNION ALL SELECT 'families', count(*) FROM families
UNION ALL SELECT 'children', count(*) FROM children
UNION ALL SELECT 'guardians', count(*) FROM guardians
UNION ALL SELECT 'family_guardians', count(*) FROM family_guardians
UNION ALL SELECT 'phone_numbers', count(*) FROM phone_numbers
UNION ALL SELECT 'classes', count(*) FROM classes
UNION ALL SELECT 'payers', count(*) FROM payers
UNION ALL SELECT 'child_payers', count(*) FROM child_payers
UNION ALL SELECT 'contacts', count(*) FROM contacts
UNION ALL SELECT 'child_contacts', count(*) FROM child_contacts;
