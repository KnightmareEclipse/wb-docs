-- Prüfskript zu domains/mensa-schema.sql — belegt, dass die Zusagen aus
-- domains/mensa.md in der Datenbank gelten und nicht nur im Text stehen.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
--   podman cp domains/stammdaten-schema.sql  pg:/tmp/1.sql
--   podman cp domains/putzdienst-schema.sql  pg:/tmp/2.sql
--   podman cp domains/anmeldung-schema.sql   pg:/tmp/3.sql
--   podman cp domains/mensa-schema.sql       pg:/tmp/4.sql
--   podman cp domains/mensa-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/1.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/2.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/3.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/4.sql
--   podman exec pg sh -c 'psql -U postgres -f /tmp/check.sql 2>&1'
--   podman rm -f pg
--
-- Stammdaten und Anmeldung MÜSSEN vorher geladen sein (children bzw.
-- care_modules für die Tagesliste). Putzdienst steht nur deshalb dazwischen,
-- weil das Anmelde-Schema die dort gebaute payments-Tabelle erweitert.
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt.
--
-- Fallstricke beim Auswerten — identisch zu den anderen Prüfskripten:
--   * Pro Lauf eine frische Datenbank.
--   * stdout und stderr im Container zusammenführen (`sh -c '… 2>&1'`).
--   * Sollstand: 4 Ankündigungen zu 4 ERROR-Zeilen, jeweils unmittelbar
--     gepaart. Verankert und auf der AUSGABE zählen, nicht auf dieser Datei.

SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- Ausgangsdaten: ein Hortkind (GS) und ein Mensa-Kind (RS)
-- ---------------------------------------------------------------------------
INSERT INTO persons (person_id, last_name, first_name) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Müller', 'Anna'),   -- GS, Hort
    ('22222222-2222-2222-2222-222222222222', 'Weber',  'Willi');  -- RS, Mensa
INSERT INTO children (child_id, date_of_birth) VALUES
    ('11111111-1111-1111-1111-111111111111', '2019-04-03'),
    ('22222222-2222-2222-2222-222222222222', '2013-09-21');

-- Modulkatalog: Nachmittagsbetreuung über 13 Uhr löst das Mittagessen aus,
-- das Katalogmodul „Mittagessen" trägt dasselbe Kennzeichen trivialerweise.
INSERT INTO care_modules (care_module_id, label, time_description,
                          includes_homework, includes_lunch, sort_order) VALUES
    (1, 'Nachmittagsbetreuung 1', 'Schulende bis 13:00 Uhr', false, false, 1),
    (3, 'Nachmittagsbetreuung 3', 'Schulende bis 15:30 Uhr', true,  true,  3),
    (7, 'Mittagessen',            'Mittagspause',            false, true,  7);

INSERT INTO care_module_bookings (care_module_booking_id, child_id, care_module_id, valid_from) VALUES
    ('e0000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 3, '2026-10-01'),
    ('e0000000-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 7, '2026-10-01');
INSERT INTO care_module_booking_days (care_module_booking_id, weekday) VALUES
    ('e0000000-0000-0000-0000-000000000001', 1),
    ('e0000000-0000-0000-0000-000000000001', 3),
    ('e0000000-0000-0000-0000-000000000002', 3);

-- „Isst am Wochentag X mit" ist EIN Prädikat über die Buchungstabellen: aktive
-- Buchung eines includes_lunch-Moduls — das Hortkind über sein
-- Nachmittagsmodul, das Mensa-Kind über das Katalogmodul, ohne eigene
-- Essensbuchungstabelle.
SELECT 'tagesliste mittwoch: hortkind und mensa-kind über ein prädikat' AS pruefung,
       count(*) AS esser
  FROM care_module_bookings b
  JOIN care_modules m           ON m.care_module_id = b.care_module_id AND m.includes_lunch
  JOIN care_module_booking_days d ON d.care_module_booking_id = b.care_module_booking_id
 WHERE d.weekday = 3
   AND b.valid_from <= '2026-11-04'
   AND (b.valid_until IS NULL OR b.valid_until >= '2026-11-04');

-- ---------------------------------------------------------------------------
-- Küchenprofil: einmal je Kind, Varianten als Zeilen
-- ---------------------------------------------------------------------------
INSERT INTO meal_diet_types (meal_diet_type_id, label) VALUES
    (1, 'Vegetarisch'), (2, 'Laktosefrei'), (3, 'Glutenfrei');

INSERT INTO meal_profiles (child_id, kitchen_note)
    VALUES ('11111111-1111-1111-1111-111111111111', 'keine Nüsse');
INSERT INTO meal_profile_diets (child_id, meal_diet_type_id) VALUES
    ('11111111-1111-1111-1111-111111111111', 1),
    ('11111111-1111-1111-1111-111111111111', 3);
SELECT 'vegetarisch und glutenfrei zugleich, dazu ein küchen-hinweis' AS pruefung,
       count(d.*) AS varianten, p.kitchen_note
  FROM meal_profiles p
  LEFT JOIN meal_profile_diets d ON d.child_id = p.child_id
 WHERE p.child_id = '11111111-1111-1111-1111-111111111111'
 GROUP BY p.kitchen_note;

\echo '--- erwartet: FEHLER (dieselbe Variante zweimal am selben Kind)'
INSERT INTO meal_profile_diets (child_id, meal_diet_type_id)
    VALUES ('11111111-1111-1111-1111-111111111111', 1);

\echo '--- erwartet: FEHLER (Variante ohne Küchenprofil)'
INSERT INTO meal_profile_diets (child_id, meal_diet_type_id)
    VALUES ('22222222-2222-2222-2222-222222222222', 2);

\echo '--- erwartet: FEHLER (leerer Küchen-Hinweis statt NULL)'
UPDATE meal_profiles SET kitchen_note = ''
    WHERE child_id = '11111111-1111-1111-1111-111111111111';

-- ---------------------------------------------------------------------------
-- Löschmechanik: das Profil verschwindet nicht nebenbei
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Kind mit Küchenprofil wird nicht nebenbei mitgelöscht)'
DELETE FROM children WHERE child_id = '11111111-1111-1111-1111-111111111111';

-- Der Lösch-Job räumt das Profil ausdrücklich; die Varianten fallen mit ihm.
DELETE FROM meal_profiles WHERE child_id = '11111111-1111-1111-1111-111111111111';
SELECT 'profil geräumt, varianten kaskadiert' AS pruefung,
       (SELECT count(*) FROM meal_profiles
         WHERE child_id = '11111111-1111-1111-1111-111111111111') AS profile,
       (SELECT count(*) FROM meal_profile_diets
         WHERE child_id = '11111111-1111-1111-1111-111111111111') AS varianten;
