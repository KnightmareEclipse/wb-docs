-- Prüfskript zu domains/stammdaten-schema.sql — belegt, dass die Zusagen aus
-- domains/stammdaten.md nicht nur Prosa sind, sondern in der Datenbank gelten.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:16
--   podman cp domains/stammdaten-schema.sql       pg:/tmp/schema.sql
--   podman cp domains/stammdaten-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/schema.sql
--   podman exec pg psql -U postgres -f /tmp/check.sql
--   podman rm -f pg
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt, sonst
-- bricht das Skript beim ersten erwarteten Fehler ab.

-- ---------------------------------------------------------------------------
-- Ausgangsdaten
-- ---------------------------------------------------------------------------
BEGIN;
SET LOCAL app.actor = 'system:test';
INSERT INTO school_branches (id, label) VALUES (1, 'Grundschule'), (2, 'Realschule');
INSERT INTO grade_levels (id, school_branch_id, label, sort_order, is_final_grade)
    VALUES (4, 1, '4', 4, true), (5, 2, '5', 5, false);
INSERT INTO classes (id, grade_level_id, name) VALUES (40, 4, '4a'), (50, 5, '5a');
INSERT INTO phone_types (id, label) VALUES (1, 'Festnetz'), (2, 'Mobil'), (3, 'Arbeit');
INSERT INTO addresses (id, street, city)
    VALUES ('11111111-1111-1111-1111-111111111111', 'Hauptstr. 1', 'Musterdorf');
-- Kind und Elternteil unter derselben Anschrift
INSERT INTO persons (id, last_name, address_id) VALUES
    ('22222222-2222-2222-2222-222222222222', 'Müller', '11111111-1111-1111-1111-111111111111'),
    ('33333333-3333-3333-3333-333333333333', 'Müller', '11111111-1111-1111-1111-111111111111');
INSERT INTO children (id, date_of_birth, grade_level_id, class_id)
    VALUES ('22222222-2222-2222-2222-222222222222', '2016-05-01', 4, 40);
INSERT INTO organizations (id, name) VALUES ('44444444-4444-4444-4444-444444444444', 'Jugendamt');
COMMIT;

-- ---------------------------------------------------------------------------
-- Audit-Trigger: Verursacher kommt aus der Sitzungsvariablen, created_* ist
-- unveränderlich, updated_* wird fortgeschrieben
-- ---------------------------------------------------------------------------
SELECT 'audit nach INSERT' AS pruefung, created_by, updated_by
    FROM persons WHERE id = '22222222-2222-2222-2222-222222222222';

BEGIN;
SET LOCAL app.actor = 'guardian:abc';
UPDATE persons SET first_name = 'Anna' WHERE id = '22222222-2222-2222-2222-222222222222';
COMMIT;
SELECT 'audit nach UPDATE' AS pruefung, created_by, updated_by, (updated_at > created_at) AS zeitstempel_neu
    FROM persons WHERE id = '22222222-2222-2222-2222-222222222222';

-- ---------------------------------------------------------------------------
-- Klasse und Klassenstufe können nicht auseinanderlaufen
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Klasse 5a gehört nicht zu Klassenstufe 4)'
UPDATE children SET class_id = 50 WHERE id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (Klasse ohne Klassenstufe)'
UPDATE children SET grade_level_id = NULL WHERE id = '22222222-2222-2222-2222-222222222222';

-- Umgekehrt erlaubt: Klassenstufe steht fest, Klasse noch nicht zugeteilt
UPDATE children SET class_id = NULL WHERE id = '22222222-2222-2222-2222-222222222222';
SELECT 'Klassenstufe ohne Klasse erlaubt' AS pruefung;

-- ---------------------------------------------------------------------------
-- Telefonnummern: höchstens eine Hauptnummer, genau ein Eigentümer
-- ---------------------------------------------------------------------------
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary) VALUES
    ('22222222-2222-2222-2222-222222222222', 1, '07123 1', true),
    ('22222222-2222-2222-2222-222222222222', 2, '0170 2',  false);

\echo '--- erwartet: FEHLER (zweite Hauptnummer derselben Person)'
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary)
    VALUES ('22222222-2222-2222-2222-222222222222', 3, '07123 3', true);

\echo '--- erwartet: FEHLER (Nummer ohne Person und ohne Organisation)'
INSERT INTO phone_numbers (phone_type_id, number) VALUES (1, '07123 4');

-- ---------------------------------------------------------------------------
-- Erziehungsberechtigte: Person ODER Organisation, nie beides
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Person und Organisation gleichzeitig)'
INSERT INTO guardians (person_id, organization_id)
    VALUES ('33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444');

INSERT INTO guardians (id, person_id)
    VALUES ('55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333');
INSERT INTO guardians (id, organization_id)
    VALUES ('66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444');
SELECT 'Erziehungsberechtigte als Person und als Organisation angelegt' AS pruefung;

\echo '--- erwartet: FEHLER (Beruf an einer Organisation)'
UPDATE guardians SET occupation = 'Sachbearbeiter' WHERE id = '66666666-6666-6666-6666-666666666666';

-- ---------------------------------------------------------------------------
-- Geteilte Anschrift: ein UPDATE wirkt auf alle, die daran hängen — genau das
-- Verhalten, zu dem die Eingabemaske zurückfragen muss (domains/stammdaten.md)
-- ---------------------------------------------------------------------------
UPDATE addresses SET street = 'Nebenweg 9' WHERE id = '11111111-1111-1111-1111-111111111111';
SELECT 'Personen an der geänderten Anschrift' AS pruefung, count(*) AS anzahl
    FROM persons p JOIN addresses a ON a.id = p.address_id WHERE a.street = 'Nebenweg 9';

-- ---------------------------------------------------------------------------
-- Löschmechanik (domains/stammdaten.md): blockiert, wo die Löschung eine
-- Entscheidung ist — kaskadiert, wo die Zeile kein Eigenleben hat
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Anschrift noch bewohnt)'
DELETE FROM addresses WHERE id = '11111111-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (Person ist Erziehungsberechtigte)'
DELETE FROM persons WHERE id = '33333333-3333-3333-3333-333333333333';

-- Kind löschen = ein Löschbefehl auf die Personenzeile; Rollenzeile und
-- Telefonnummern hängen daran und verschwinden mit.
DELETE FROM persons WHERE id = '22222222-2222-2222-2222-222222222222';
SELECT 'nach Löschung der Kind-Person' AS pruefung,
       (SELECT count(*) FROM children)      AS kinder,
       (SELECT count(*) FROM phone_numbers) AS telefonnummern;
