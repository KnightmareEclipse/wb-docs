-- Prüfskript zu domains/putzdienst-schema.sql — belegt, dass die Zusagen aus
-- domains/putzdienst.md in der Datenbank gelten und nicht nur im Text stehen.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
--   podman cp domains/stammdaten-schema.sql       pg:/tmp/stammdaten.sql
--   podman cp domains/putzdienst-schema.sql       pg:/tmp/putzdienst.sql
--   podman cp domains/putzdienst-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/stammdaten.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/putzdienst.sql
--   podman exec pg sh -c 'psql -U postgres -f /tmp/check.sql 2>&1'
--   podman rm -f pg
--
-- Das Stammdaten-Schema MUSS zuerst geladen sein: dieses Schema referenziert
-- families und nutzt dessen set_row_audit().
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt, sonst
-- bricht das Skript beim ersten erwarteten Fehler ab.
--
-- Fallstricke beim Auswerten — identisch zu domains/stammdaten-schema-check.sql:
--   * Pro Lauf eine frische Datenbank.
--   * stdout und stderr im Container zusammenführen (`sh -c '… 2>&1'`), sonst
--     reordert podman die Ströme und die Paarung sieht wie ein Befund aus.
--   * Sollstand: 22 Ankündigungen zu 22 ERROR-Zeilen, jeweils unmittelbar
--     gepaart. Verankert und auf der AUSGABE zählen, nicht auf dieser Datei —
--     deren Kopfkommentar enthält die Zeichenkette selbst:
--       grep -cE '^--- erwartet: FEHLER'  gegen  grep -cE '^psql:.*: ERROR:'

SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- Ausgangsdaten
-- ---------------------------------------------------------------------------
INSERT INTO families (family_id) VALUES
    ('f0000000-0000-0000-0000-000000000001'),   -- abweichende Pflichtmenge (Quereinstieg)
    ('f0000000-0000-0000-0000-000000000002'),   -- kauft sich frei
    ('f0000000-0000-0000-0000-000000000003');   -- Standardfall, nur eine Zuteilung

INSERT INTO cleaning_duty_types (duty_type_id, label, is_major) VALUES
    (1, 'Regulär', false),
    (2, 'Großputz', true),
    (3, 'Gartenarbeit', false);   -- zählt als regulär, siehe domains/putzdienst.md

INSERT INTO cleaning_cycles
    (cycle_id, label, starts_on, ends_on, booking_opens_at, booking_closes_at,
     required_regular, required_major, buyout_amount, slot_buyout_amount,
     no_show_penalty, capacity_buffer, proration_cutoff_on)
VALUES
    (1, '2026/27', '2026-10-01', '2027-09-30',
     '2026-09-01 00:00+02', '2026-09-20 23:59+02',
     5, 1, 150.00, 25.00, 75.00, 2, '2027-05-20');

-- Anfangszeiten bewusst verschieden — die Termine starten nicht alle gleich.
INSERT INTO cleaning_slots (slot_id, cycle_id, duty_type_id, slot_date, starts_at) VALUES
    (10, 1, 1, '2026-10-17', '15:00'),
    (11, 1, 2, '2027-04-24', '09:00'),
    (12, 1, 3, '2027-05-08', '14:30'),   -- Gartenarbeit
    (13, 1, 1, '2027-09-18', NULL);      -- letzter Monat, Zeit noch offen

-- ---------------------------------------------------------------------------
-- Audit-Trigger hängt auch an den neuen Tabellen (die Funktion selbst ist in
-- domains/stammdaten-schema-check.sql geprüft, hier nur die Verdrahtung)
-- ---------------------------------------------------------------------------
SELECT 'audit verdrahtet' AS pruefung, created_by, updated_by
    FROM cleaning_cycles WHERE cycle_id = 1;

-- ---------------------------------------------------------------------------
-- Zyklus: Zeitraum, Buchungsfenster, Stichtag, Überlappung
-- ---------------------------------------------------------------------------

-- Buchungsfenster liegt VOR dem Zyklus — das muss erlaubt bleiben (September
-- bucht für Oktober–September), belegt bereits durch den Insert oben.
SELECT 'buchungsfenster vor zyklusbeginn erlaubt' AS pruefung,
       booking_closes_at < starts_on AS liegt_davor FROM cleaning_cycles WHERE cycle_id = 1;

\echo '--- erwartet: FEHLER (Zyklus endet vor seinem Beginn)'
INSERT INTO cleaning_cycles (label, starts_on, ends_on, booking_opens_at, booking_closes_at,
    required_regular, required_major, buyout_amount, slot_buyout_amount, no_show_penalty, capacity_buffer)
VALUES ('kaputt', '2028-10-01', '2028-09-30', '2028-09-01 00:00+02', '2028-09-20 00:00+02',
        5, 1, 150.00, 25.00, 75.00, 2);

\echo '--- erwartet: FEHLER (Buchungsfenster schließt vor dem Öffnen)'
INSERT INTO cleaning_cycles (label, starts_on, ends_on, booking_opens_at, booking_closes_at,
    required_regular, required_major, buyout_amount, slot_buyout_amount, no_show_penalty, capacity_buffer)
VALUES ('kaputt2', '2028-10-01', '2029-09-30', '2028-09-20 00:00+02', '2028-09-01 00:00+02',
        5, 1, 150.00, 25.00, 75.00, 2);

\echo '--- erwartet: FEHLER (Proration-Stichtag liegt außerhalb des Zyklus)'
INSERT INTO cleaning_cycles (label, starts_on, ends_on, booking_opens_at, booking_closes_at,
    required_regular, required_major, buyout_amount, slot_buyout_amount, no_show_penalty, capacity_buffer,
    proration_cutoff_on)
VALUES ('kaputt3', '2028-10-01', '2029-09-30', '2028-09-01 00:00+02', '2028-09-20 00:00+02',
        5, 1, 150.00, 25.00, 75.00, 2, '2030-01-01');

\echo '--- erwartet: FEHLER (überlappender Zyklus — sonst ist jeder Termin mehrdeutig)'
INSERT INTO cleaning_cycles (label, starts_on, ends_on, booking_opens_at, booking_closes_at,
    required_regular, required_major, buyout_amount, slot_buyout_amount, no_show_penalty, capacity_buffer)
VALUES ('überlappt', '2027-09-01', '2028-08-31', '2027-09-01 00:00+02', '2027-09-20 00:00+02',
        5, 1, 150.00, 25.00, 75.00, 2);

-- Lückenlos anschließender Zyklus ist dagegen erlaubt
INSERT INTO cleaning_cycles (cycle_id, label, starts_on, ends_on, booking_opens_at, booking_closes_at,
    required_regular, required_major, buyout_amount, slot_buyout_amount, no_show_penalty, capacity_buffer)
VALUES (2, '2027/28', '2027-10-01', '2028-09-30', '2027-09-01 00:00+02', '2027-09-20 00:00+02',
        5, 1, 150.00, 25.00, 75.00, 2);

-- Der Zyklus-Zeitraum liegt hier bewusst frei — sonst schlüge der Constraint
-- darüber zu und das Buchungsfenster bliebe ungeprüft. Zwei überlappende
-- Fenster machen mehrdeutig, wofür gerade gebucht wird.
\echo '--- erwartet: FEHLER (überlappendes Buchungsfenster bei freiem Zyklus-Zeitraum)'
INSERT INTO cleaning_cycles (label, starts_on, ends_on, booking_opens_at, booking_closes_at,
    required_regular, required_major, buyout_amount, slot_buyout_amount, no_show_penalty, capacity_buffer)
VALUES ('fenster überlappt', '2029-10-01', '2030-09-30', '2027-09-10 00:00+02', '2027-09-15 00:00+02',
        5, 1, 150.00, 25.00, 75.00, 2);

-- ---------------------------------------------------------------------------
-- Erinnerungsstufen
-- ---------------------------------------------------------------------------
INSERT INTO cleaning_reminder_stages (cycle_id, days_before) VALUES (1, 7), (1, 1);

\echo '--- erwartet: FEHLER (dieselbe Stufe zweimal — zwei Mails am selben Tag)'
INSERT INTO cleaning_reminder_stages (cycle_id, days_before) VALUES (1, 7);

\echo '--- erwartet: FEHLER (Stufe „0 Tage vorher" ist keine Vorlaufzeit)'
INSERT INTO cleaning_reminder_stages (cycle_id, days_before) VALUES (1, 0);

-- ---------------------------------------------------------------------------
-- Termine
-- ---------------------------------------------------------------------------

-- Großputz und regulärer Termin am selben Tag müssen möglich bleiben — genau
-- deshalb gibt es die Solver-Regel, die eine Familie nicht beiden zuordnet.
INSERT INTO cleaning_slots (slot_id, cycle_id, duty_type_id, slot_date, starts_at)
    VALUES (14, 1, 2, '2026-10-17', '09:00');

-- ---------------------------------------------------------------------------
-- Pflichtmenge je Familie
-- ---------------------------------------------------------------------------

-- Quereinstieg zum Halbjahr: die Proration ergibt 2 + 1 (die Hälfte von 5 + 1)
INSERT INTO cleaning_family_duties (cycle_id, family_id, required_regular, required_major, reason)
    VALUES (1, 'f0000000-0000-0000-0000-000000000001', 2, 1, 'Quereinstieg 02/2027');

-- Eintritt nach dem Stichtag: 0 + 0 ist ein gültiger Wert, nicht „Standard"
INSERT INTO cleaning_family_duties (cycle_id, family_id, required_regular, required_major, reason)
    VALUES (1, 'f0000000-0000-0000-0000-000000000002', 0, 0, 'Eintritt nach Stichtag');

\echo '--- erwartet: FEHLER (Zeile ohne jede Abweichung verdeckt nur den Zyklus-Standard)'
INSERT INTO cleaning_family_duties (cycle_id, family_id, reason)
    VALUES (2, 'f0000000-0000-0000-0000-000000000001', 'sagt nichts');

\echo '--- erwartet: FEHLER (negative Pflichtmenge)'
INSERT INTO cleaning_family_duties (cycle_id, family_id, required_regular)
    VALUES (2, 'f0000000-0000-0000-0000-000000000002', -1);

-- Vereinbarte Sonderregelung in einem Zyklus ganz ohne Termine: nur so belegt
-- der Löschversuch unten den Fremdschlüssel dieser Tabelle und nicht den von
-- cleaning_slots.
INSERT INTO cleaning_family_duties (cycle_id, family_id, required_regular, reason)
    VALUES (2, 'f0000000-0000-0000-0000-000000000002', 3, 'Vereinbarung Schulträger');

\echo '--- erwartet: FEHLER (Zyklus löschen nimmt eine vereinbarte Sonderregelung nicht mit)'
DELETE FROM cleaning_cycles WHERE cycle_id = 2;

-- ---------------------------------------------------------------------------
-- Zuteilung
-- ---------------------------------------------------------------------------
INSERT INTO cleaning_assignments (slot_id, family_id) VALUES
    (10, 'f0000000-0000-0000-0000-000000000001'),
    (12, 'f0000000-0000-0000-0000-000000000001'),   -- Gartenarbeit
    (11, 'f0000000-0000-0000-0000-000000000001'),   -- Großputz
    (13, 'f0000000-0000-0000-0000-000000000003');   -- Familie ohne sonstige Putzdienst-Daten

\echo '--- erwartet: FEHLER (dieselbe Familie zweimal am selben Termin)'
INSERT INTO cleaning_assignments (slot_id, family_id)
    VALUES (10, 'f0000000-0000-0000-0000-000000000001');

-- Die Papier-Unterschriftenliste dieses Termins ist übertragen — erst ab hier
-- sagen seine no_show-Werte etwas. Am Termin, nicht je Familie.
UPDATE cleaning_slots SET attendance_recorded_at = now() WHERE slot_id = 12;

-- Nichterscheinen als Attribut der Zuteilung, keine eigene Entität
UPDATE cleaning_assignments SET no_show = true
    WHERE slot_id = 12 AND family_id = 'f0000000-0000-0000-0000-000000000001';

-- „no_show = false" allein ist keine Anwesenheit: Termin 10 ist schlicht noch
-- nicht erfasst. Ohne diese Trennung sähe eine vergessene Übertragung aus wie
-- lauter erschienene Familien.
SELECT 'anwesenheit erfasst vs. offen' AS pruefung,
       count(*) FILTER (WHERE s.attendance_recorded_at IS NOT NULL)                  AS erfasst,
       count(*) FILTER (WHERE s.attendance_recorded_at IS NULL AND NOT a.no_show)    AS ohne_aussage
  FROM cleaning_assignments a
  JOIN cleaning_slots s ON s.slot_id = a.slot_id
 WHERE s.cycle_id = 1;

-- Straf-Aussetzung: die Strafe entsteht immer, wer die Berechtigung hat, setzt
-- sie danach aus — ein festgehaltener Gegenvorgang, keine unterlassene
-- Forderung (domains/putzdienst.md, „Erlass und Straf-Ausnahme").
UPDATE cleaning_assignments SET penalty_waived_at = now()
    WHERE slot_id = 12 AND family_id = 'f0000000-0000-0000-0000-000000000001';
SELECT 'strafe ausgesetzt, nichterscheinen bleibt stehen' AS pruefung, no_show, penalty_waived_at IS NOT NULL AS ausgesetzt
  FROM cleaning_assignments
 WHERE slot_id = 12 AND family_id = 'f0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Strafe aussetzen, wo gar keine entstanden ist)'
UPDATE cleaning_assignments SET penalty_waived_at = now()
    WHERE slot_id = 10 AND family_id = 'f0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Termin mit Zuteilungen löschen ist eine echte Entscheidung)'
DELETE FROM cleaning_slots WHERE slot_id = 10;

-- Bewusst die Familie ohne Pflichtmengen- und Freikaufzeile: sonst blockierte
-- deren Fremdschlüssel zuerst und die Zusage der Zuteilung bliebe unbelegt.
\echo '--- erwartet: FEHLER (Familie mit Zuteilung wird nicht nebenbei mitgelöscht)'
DELETE FROM families WHERE family_id = 'f0000000-0000-0000-0000-000000000003';

-- Gartenarbeit zählt gegen die reguläre Pflicht, Großputz gegen die eigene —
-- und das Nichterscheinen zählt nicht als erfüllt.
SELECT 'pflichterfuellung' AS pruefung,
       count(*) FILTER (WHERE NOT t.is_major AND NOT a.no_show) AS regulaer_geleistet,
       count(*) FILTER (WHERE     t.is_major AND NOT a.no_show) AS grossputz_geleistet,
       count(*) FILTER (WHERE a.no_show)                        AS nicht_erschienen
  FROM cleaning_assignments a
  JOIN cleaning_slots s      ON s.slot_id = a.slot_id
  JOIN cleaning_duty_types t ON t.duty_type_id = s.duty_type_id
 WHERE a.family_id = 'f0000000-0000-0000-0000-000000000001' AND s.cycle_id = 1;

-- ---------------------------------------------------------------------------
-- Freikauf und Zahlung
-- ---------------------------------------------------------------------------
INSERT INTO cleaning_buyouts (buyout_id, cycle_id, family_id)
    VALUES ('b0000000-0000-0000-0000-000000000001', 1, 'f0000000-0000-0000-0000-000000000002');

\echo '--- erwartet: FEHLER (zweiter Freikauf derselben Familie im selben Zyklus)'
INSERT INTO cleaning_buyouts (cycle_id, family_id)
    VALUES (1, 'f0000000-0000-0000-0000-000000000002');

INSERT INTO payments (cleaning_buyout_id, amount, reference)
    VALUES ('b0000000-0000-0000-0000-000000000001', 150.00, 'pi_3QexampleStripeIntent');

\echo '--- erwartet: FEHLER (zweite Zahlung auf denselben Freikauf wäre eine Doppelbelastung)'
INSERT INTO payments (cleaning_buyout_id, amount)
    VALUES ('b0000000-0000-0000-0000-000000000001', 150.00);

\echo '--- erwartet: FEHLER (Zahlung über 0)'
INSERT INTO payments (cleaning_buyout_id, amount)
    VALUES ('b0000000-0000-0000-0000-000000000001', 0);

\echo '--- erwartet: FEHLER (Freikauf mit Zahlung löschen)'
DELETE FROM cleaning_buyouts WHERE buyout_id = 'b0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Zahlung ohne jeden Anlass)'
INSERT INTO payments (amount) VALUES (150.00);

-- Einzel-Freikauf eines zugeteilten Termins: der Ausweg vor der Strafe für
-- eine Familie, die doch nicht kann (domains/putzdienst.md). Eigener Vorgang
-- mit eigenem Betrag, Bezug ist die Zuteilung statt Familie × Zyklus.
INSERT INTO cleaning_slot_buyouts (slot_buyout_id, assignment_id)
    SELECT 'bb000000-0000-0000-0000-000000000001', assignment_id FROM cleaning_assignments
     WHERE slot_id = 13 AND family_id = 'f0000000-0000-0000-0000-000000000003';
INSERT INTO payments (cleaning_slot_buyout_id, amount, reference)
    VALUES ('bb000000-0000-0000-0000-000000000001', 25.00, 'pi_3QexampleSlotBuyout');
SELECT 'einzel-freikauf mit eigener zahlung' AS pruefung, amount FROM payments
 WHERE cleaning_slot_buyout_id = 'bb000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (derselbe Termin zweimal freigekauft)'
INSERT INTO cleaning_slot_buyouts (assignment_id)
    SELECT assignment_id FROM cleaning_assignments
     WHERE slot_id = 13 AND family_id = 'f0000000-0000-0000-0000-000000000003';

\echo '--- erwartet: FEHLER (Zahlung auf zwei Anlässe gleichzeitig)'
INSERT INTO payments (cleaning_buyout_id, cleaning_slot_buyout_id, amount)
    VALUES ('b0000000-0000-0000-0000-000000000001', 'bb000000-0000-0000-0000-000000000001', 25.00);

-- Als UPDATE geprüft und nicht als zweiter INSERT: eine dritte Zahlungszeile
-- scheiterte schon am UNIQUE ihrer Vorgangs-Spalte, und die Referenz bliebe
-- unbelegt. Realer Weg dorthin ist ein zweimal zugestellter Stripe-Webhook.
\echo '--- erwartet: FEHLER (dieselbe Zahlungsreferenz an zwei Zahlungen)'
UPDATE payments SET reference = 'pi_3QexampleStripeIntent'
    WHERE cleaning_slot_buyout_id = 'bb000000-0000-0000-0000-000000000001';

-- Offen, bis die Buchhaltung bzw. Stripe bestätigt
SELECT 'zahlung offen' AS pruefung, settled_at IS NULL AS offen, reference IS NOT NULL AS hat_referenz
  FROM payments;

UPDATE payments SET settled_at = now();
SELECT 'zahlung bestaetigt' AS pruefung, settled_at IS NOT NULL AS bestaetigt FROM payments;

-- Restbedarf des Solvers: Gesamtbedarf abzüglich Freikäufe und geleisteter Termine
SELECT 'restbedarf' AS pruefung, f.family_id AS familie,
       coalesce(d.required_regular, c.required_regular)
         - count(a.*) FILTER (WHERE NOT t.is_major AND NOT a.no_show) AS offen_regulaer,
       (bo.buyout_id IS NOT NULL) AS freigekauft
  FROM families f
  CROSS JOIN cleaning_cycles c
  LEFT JOIN cleaning_family_duties d ON d.family_id = f.family_id AND d.cycle_id = c.cycle_id
  LEFT JOIN cleaning_buyouts bo      ON bo.family_id = f.family_id AND bo.cycle_id = c.cycle_id
  LEFT JOIN cleaning_assignments a   ON a.family_id = f.family_id
  LEFT JOIN cleaning_slots s         ON s.slot_id = a.slot_id AND s.cycle_id = c.cycle_id
  LEFT JOIN cleaning_duty_types t    ON t.duty_type_id = s.duty_type_id
 WHERE c.cycle_id = 1
 GROUP BY f.family_id, d.required_regular, c.required_regular, bo.buyout_id
 ORDER BY f.family_id;
