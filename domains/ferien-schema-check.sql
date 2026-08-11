-- Prüfskript zu domains/ferien-schema.sql — belegt, dass die Zusagen aus
-- domains/ferien.md in der Datenbank gelten und nicht nur im Text stehen.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
--   podman cp domains/stammdaten-schema.sql   pg:/tmp/1.sql
--   podman cp domains/putzdienst-schema.sql   pg:/tmp/2.sql
--   podman cp domains/anmeldung-schema.sql    pg:/tmp/3.sql
--   podman cp domains/ferien-schema.sql       pg:/tmp/4.sql
--   podman cp domains/ferien-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/1.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/2.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/3.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/4.sql
--   podman exec pg sh -c 'psql -U postgres -f /tmp/check.sql 2>&1'
--   podman rm -f pg
--
-- ALLE DREI Vorgänger-Schemata MÜSSEN in dieser Reihenfolge geladen sein.
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt.
--
-- Fallstricke beim Auswerten — identisch zu den anderen Prüfskripten:
--   * Pro Lauf eine frische Datenbank.
--   * stdout und stderr im Container zusammenführen (`sh -c '… 2>&1'`).
--   * Sollstand: 9 Ankündigungen zu 9 ERROR-Zeilen, jeweils unmittelbar
--     gepaart. Verankert und auf der AUSGABE zählen, nicht auf dieser Datei.

SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- Ausgangsdaten: ein eingeschriebenes und ein schulfremdes Kind
-- ---------------------------------------------------------------------------
INSERT INTO persons (person_id, last_name, first_name) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Müller',  'Anna'),   -- eingeschrieben
    ('22222222-2222-2222-2222-222222222222', 'Fremd',   'Felix'),  -- schulfremd
    ('33333333-3333-3333-3333-333333333333', 'Fremd',   'Frauke'); -- anmeldender Elternteil

INSERT INTO children (child_id, date_of_birth, entry_date) VALUES
    ('11111111-1111-1111-1111-111111111111', '2018-05-04', '2025-09-15');
INSERT INTO children (child_id, date_of_birth) VALUES
    ('22222222-2222-2222-2222-222222222222', '2019-11-20');

-- ---------------------------------------------------------------------------
-- Programm und Angebotstage
-- ---------------------------------------------------------------------------
INSERT INTO programs (program_id, label, starts_on, ends_on, booking_closes_at, fee_per_day)
    VALUES (1, 'Ferienprogramm Herbst 2026', '2026-10-26', '2026-10-30',
            '2026-10-12 23:59+02', 18.00);

\echo '--- erwartet: FEHLER (Programm endet vor seinem Beginn)'
INSERT INTO programs (label, starts_on, ends_on, booking_closes_at, fee_per_day)
    VALUES ('kaputt', '2026-10-30', '2026-10-26', '2026-10-12 23:59+02', 18.00);

\echo '--- erwartet: FEHLER (Anmeldeschluss nach Programmbeginn)'
INSERT INTO programs (label, starts_on, ends_on, booking_closes_at, fee_per_day)
    VALUES ('kaputt2', '2026-10-26', '2026-10-30', '2026-10-28 23:59+02', 18.00);

INSERT INTO program_days (program_day_id, program_id, day_on, capacity) VALUES
    (1, 1, '2026-10-26', 20),
    (2, 1, '2026-10-27', 20);

\echo '--- erwartet: FEHLER (Angebotstag ohne Kapazität)'
INSERT INTO program_days (program_id, day_on, capacity) VALUES (1, '2026-10-28', 0);

\echo '--- erwartet: FEHLER (derselbe Tag zweimal im selben Programm)'
INSERT INTO program_days (program_id, day_on, capacity) VALUES (1, '2026-10-26', 20);

-- ---------------------------------------------------------------------------
-- Ein Vorgang, mehrere Kinder, mehrere Tage
-- ---------------------------------------------------------------------------
INSERT INTO program_registrations (program_registration_id, program_id, registered_by_person_id)
    VALUES ('a0000000-0000-0000-0000-000000000001', 1,
            '33333333-3333-3333-3333-333333333333');

INSERT INTO program_bookings (program_registration_id, child_id, program_day_id, care_until, note) VALUES
    ('a0000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 1, '14:00', NULL),
    ('a0000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 2, '16:00', NULL),
    ('a0000000-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 1, '16:00', 'Erdnussallergie im Hort hinterlegt');
SELECT 'ein vorgang trägt mehrere kinder und tage' AS pruefung,
       count(*) AS buchungen, count(DISTINCT child_id) AS kinder
  FROM program_bookings
 WHERE program_registration_id = 'a0000000-0000-0000-0000-000000000001';

-- „Clemens-Kind" ist ableitbar und braucht kein Feld: eingeschrieben heißt
-- entry_date gesetzt und kein exit_date.
SELECT 'clemens-kind ist ableitbar, nicht gespeichert' AS pruefung,
       p.last_name,
       (c.entry_date IS NOT NULL AND c.exit_date IS NULL) AS eingeschrieben
  FROM program_bookings b
  JOIN children c ON c.child_id = b.child_id
  JOIN persons  p ON p.person_id = b.child_id
 WHERE b.program_registration_id = 'a0000000-0000-0000-0000-000000000001'
 GROUP BY p.last_name, c.entry_date, c.exit_date
 ORDER BY p.last_name;

\echo '--- erwartet: FEHLER (dasselbe Kind zweimal am selben Angebotstag)'
INSERT INTO program_bookings (program_registration_id, child_id, program_day_id, care_until)
    VALUES ('a0000000-0000-0000-0000-000000000001',
            '11111111-1111-1111-1111-111111111111', 1, '16:00');

\echo '--- erwartet: FEHLER (leere Bemerkung statt NULL)'
UPDATE program_bookings SET note = ''
    WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- Storno setzt einen Zeitpunkt, statt die Zeile zu löschen — sonst wäre die
-- Wiederanmeldung von der UNIQUE-Regel blockiert und die Tageskapazität
-- rechnete falsch.
UPDATE program_bookings SET cancelled_at = now()
    WHERE child_id = '11111111-1111-1111-1111-111111111111' AND program_day_id = 2;
SELECT 'tageskapazität zählt stornos nicht mit' AS pruefung,
       d.capacity,
       count(*) FILTER (WHERE b.cancelled_at IS NULL) AS belegt,
       count(*) FILTER (WHERE b.cancelled_at IS NOT NULL) AS storniert
  FROM program_days d
  LEFT JOIN program_bookings b ON b.program_day_id = d.program_day_id
 WHERE d.program_day_id = 2
 GROUP BY d.capacity;

-- ---------------------------------------------------------------------------
-- Q3: vierter und letzter Zahlungsanlass
-- ---------------------------------------------------------------------------
INSERT INTO payments (program_registration_id, amount, reference)
    VALUES ('a0000000-0000-0000-0000-000000000001', 54.00, 'pi_3QexampleHolidayBooking');
SELECT 'ferienbuchung als vierter q3-anlass' AS pruefung, amount
  FROM payments WHERE program_registration_id = 'a0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (zweite Zahlung auf denselben Anmeldevorgang)'
INSERT INTO payments (program_registration_id, amount)
    VALUES ('a0000000-0000-0000-0000-000000000001', 54.00);

\echo '--- erwartet: FEHLER (Zahlung ohne jeden Anlass, jetzt mit vier Spalten)'
INSERT INTO payments (amount) VALUES (54.00);

-- ---------------------------------------------------------------------------
-- Der schulfremde Fall: Personenzeile ohne jeden Schulbezug
-- ---------------------------------------------------------------------------
SELECT 'schulfremdes kind hat weder eintritts- noch austrittsdatum' AS pruefung,
       entry_date IS NULL AS ohne_eintritt, exit_date IS NULL AS ohne_austritt
  FROM children WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- Der Löschfrist-Anker ist deshalb das Programm und nicht das Kind. Solange das
-- Programm noch läuft, ist das Kind KEIN Kandidat.
SELECT 'laufendes programm: schulfremdes kind bleibt' AS pruefung,
       count(*) AS kandidaten
  FROM children c
 WHERE c.entry_date IS NULL
   AND EXISTS (SELECT 1 FROM program_bookings b WHERE b.child_id = c.child_id)
   AND NOT EXISTS (
         SELECT 1 FROM program_bookings b
           JOIN program_days d  ON d.program_day_id = b.program_day_id
           JOIN programs p      ON p.program_id = d.program_id
          WHERE b.child_id = c.child_id AND p.ends_on >= current_date);

-- Nach Programmende wird es einer — ohne dass es dafür eine eigene Spalte
-- bräuchte. Dasselbe Kind, ein bereits gelaufenes Programm.
INSERT INTO programs (program_id, label, starts_on, ends_on, booking_closes_at, fee_per_day)
    VALUES (2, 'Ferienprogramm Ostern 2026', '2026-03-30', '2026-04-02',
            '2026-03-20 23:59+02', 18.00);
INSERT INTO program_days (program_day_id, program_id, day_on, capacity)
    VALUES (3, 2, '2026-03-30', 20);
INSERT INTO program_registrations (program_registration_id, program_id, registered_by_person_id)
    VALUES ('a0000000-0000-0000-0000-000000000002', 2,
            '33333333-3333-3333-3333-333333333333');
UPDATE program_bookings SET program_registration_id = 'a0000000-0000-0000-0000-000000000002',
                            program_day_id = 3
    WHERE child_id = '22222222-2222-2222-2222-222222222222';
SELECT 'abgelaufenes programm: schulfremdes kind wird löschkandidat' AS pruefung,
       count(*) AS kandidaten
  FROM children c
 WHERE c.entry_date IS NULL
   AND EXISTS (SELECT 1 FROM program_bookings b WHERE b.child_id = c.child_id)
   AND NOT EXISTS (
         SELECT 1 FROM program_bookings b
           JOIN program_days d  ON d.program_day_id = b.program_day_id
           JOIN programs p      ON p.program_id = d.program_id
          WHERE b.child_id = c.child_id AND p.ends_on >= current_date);

\echo '--- erwartet: FEHLER (Kind mit Buchung wird nicht nebenbei mitgelöscht)'
DELETE FROM children WHERE child_id = '22222222-2222-2222-2222-222222222222';
