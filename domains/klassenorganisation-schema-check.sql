-- Prüfskript zu domains/klassenorganisation-schema.sql — belegt, dass die
-- Zusagen aus domains/klassenorganisation.md in der Datenbank gelten und nicht
-- nur im Text stehen. Bewusst ohne Testframework: eine Datei, gegen eine
-- Wegwerf-Datenbank laufen lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
--   podman cp domains/stammdaten-schema.sql             pg:/tmp/1.sql
--   podman cp domains/klassenorganisation-schema.sql    pg:/tmp/2.sql
--   podman cp domains/klassenorganisation-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/1.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/2.sql
--   podman exec pg sh -c 'psql -U postgres -f /tmp/check.sql 2>&1'
--   podman rm -f pg
--
-- Nur Stammdaten MUSS vorher geladen sein (classes, guardians).
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt.
--
-- Fallstricke beim Auswerten — identisch zu den anderen Prüfskripten:
--   * Pro Lauf eine frische Datenbank.
--   * stdout und stderr im Container zusammenführen (`sh -c '… 2>&1'`).
--   * Sollstand: 3 Ankündigungen zu 3 ERROR-Zeilen, jeweils unmittelbar
--     gepaart. Verankert und auf der AUSGABE zählen, nicht auf dieser Datei.

SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- Ausgangsdaten: eine Klasse, zwei Erziehungsberechtigte, eine dritte Person
-- ---------------------------------------------------------------------------
INSERT INTO school_branches (school_branch_id, label) VALUES (1, 'Grundschule');
INSERT INTO grade_levels (grade_level_id, school_branch_id, label, sort_order)
    VALUES (1, 1, 'Klasse 1', 1);
INSERT INTO classes (class_id, school_branch_id, grade_level_id, entry_year, stream)
    VALUES (1, 1, 1, 2026, 'a');

INSERT INTO persons (person_id, last_name, first_name) VALUES
    ('22222222-2222-2222-2222-222222222222', 'Müller', 'Beate'),
    ('33333333-3333-3333-3333-333333333333', 'Schmidt', 'Carla'),
    ('44444444-4444-4444-4444-444444444444', 'Fremd', 'Franz'),   -- keine Erziehungsberechtigten-Rolle
    ('55555555-5555-5555-5555-555555555555', 'Weber', 'Dora');
INSERT INTO guardians (guardian_id) VALUES
    ('22222222-2222-2222-2222-222222222222'),
    ('33333333-3333-3333-3333-333333333333'),
    ('55555555-5555-5555-5555-555555555555');

-- ---------------------------------------------------------------------------
-- Vertretung und Stellvertretung, je Klasse höchstens eine
-- ---------------------------------------------------------------------------
INSERT INTO class_parent_representatives (class_id, is_deputy, guardian_id) VALUES
    (1, false, '22222222-2222-2222-2222-222222222222'),
    (1, true,  '33333333-3333-3333-3333-333333333333');
SELECT 'vertretung und stellvertretung besetzt' AS pruefung,
       count(*) FILTER (WHERE NOT is_deputy) AS vertretung,
       count(*) FILTER (WHERE is_deputy)     AS stellvertretung
  FROM class_parent_representatives WHERE class_id = 1;

\echo '--- erwartet: FEHLER (zweite Vertretung derselben Klasse)'
INSERT INTO class_parent_representatives (class_id, is_deputy, guardian_id)
    VALUES (1, false, '33333333-3333-3333-3333-333333333333');

\echo '--- erwartet: FEHLER (dieselbe Person hält beide Ämter derselben Klasse)'
UPDATE class_parent_representatives
   SET guardian_id = '22222222-2222-2222-2222-222222222222'
 WHERE class_id = 1 AND is_deputy;

\echo '--- erwartet: FEHLER (Person ohne Erziehungsberechtigten-Rolle als Vertretung)'
UPDATE class_parent_representatives
   SET guardian_id = '44444444-4444-4444-4444-444444444444'
 WHERE class_id = 1 AND NOT is_deputy;

-- Der Wechsel nach der Neuwahl ist ein UPDATE auf derselben Amtszeile — kein
-- neuer Datensatz, keine Historie.
UPDATE class_parent_representatives
   SET guardian_id = '55555555-5555-5555-5555-555555555555'
 WHERE class_id = 1 AND NOT is_deputy;
SELECT 'wechsel per update, amt bleibt die zeile' AS pruefung,
       count(*) AS aemter,
       (SELECT p.first_name FROM class_parent_representatives r
          JOIN persons p ON p.person_id = r.guardian_id
         WHERE r.class_id = 1 AND NOT r.is_deputy) AS neue_vertretung
  FROM class_parent_representatives WHERE class_id = 1;
