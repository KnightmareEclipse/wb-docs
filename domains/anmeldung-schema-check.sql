-- Prüfskript zu domains/anmeldung-schema.sql — belegt, dass die Zusagen aus
-- domains/anmeldung.md in der Datenbank gelten und nicht nur im Text stehen.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
--   podman cp domains/stammdaten-schema.sql      pg:/tmp/stammdaten.sql
--   podman cp domains/putzdienst-schema.sql      pg:/tmp/putzdienst.sql
--   podman cp domains/anmeldung-schema.sql       pg:/tmp/anmeldung.sql
--   podman cp domains/anmeldung-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/stammdaten.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/putzdienst.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/anmeldung.sql
--   podman exec pg sh -c 'psql -U postgres -f /tmp/check.sql 2>&1'
--   podman rm -f pg
--
-- BEIDE Vorgänger-Schemata MÜSSEN zuerst geladen sein, in dieser Reihenfolge:
-- dieses Schema referenziert children/persons/grade_levels aus Stammdaten und
-- erweitert die in putzdienst-schema.sql gebaute payments-Tabelle.
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt, sonst
-- bricht das Skript beim ersten erwarteten Fehler ab.
--
-- Fallstricke beim Auswerten — identisch zu den beiden anderen Prüfskripten:
--   * Pro Lauf eine frische Datenbank.
--   * stdout und stderr im Container zusammenführen (`sh -c '… 2>&1'`), sonst
--     reordert podman die Ströme und die Paarung sieht wie ein Befund aus.
--   * Sollstand: 59 Ankündigungen zu 59 ERROR-Zeilen, jeweils unmittelbar
--     gepaart. Verankert und auf der AUSGABE zählen, nicht auf dieser Datei —
--     deren Kopfkommentar enthält die Zeichenkette selbst:
--       grep -cE '^--- erwartet: FEHLER'  gegen  grep -cE '^psql:.*: ERROR:'

SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- Ausgangsdaten aus Stammdaten
-- ---------------------------------------------------------------------------
INSERT INTO school_branches (school_branch_id, label) VALUES
    (1, 'Grundschule'), (2, 'Realschule');
INSERT INTO grade_levels (grade_level_id, school_branch_id, label, sort_order) VALUES
    (1, 1, 'Klasse 1', 1),
    (5, 2, 'Klasse 5', 5),
    (6, 2, 'Klasse 6', 6);

INSERT INTO persons (person_id, last_name, first_name) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Müller', 'Anna'),      -- Kind, extern
    ('22222222-2222-2222-2222-222222222222', 'Müller', 'Beate'),     -- Mutter
    ('33333333-3333-3333-3333-333333333333', 'Müller', 'Christian'), -- Vater
    ('44444444-4444-4444-4444-444444444444', 'Schmidt', 'Dora');     -- Kind, Hort ohne Schule

INSERT INTO children (child_id, date_of_birth) VALUES
    ('11111111-1111-1111-1111-111111111111', '2021-03-14'),
    ('44444444-4444-4444-4444-444444444444', '2020-08-02');

-- Ein Putzdienst-Zyklus wird für die Q3-Erweiterung gebraucht (die bestehende
-- Zahlung muss weiter funktionieren, siehe unten).
INSERT INTO families (family_id) VALUES ('f0000000-0000-0000-0000-000000000001');
INSERT INTO cleaning_cycles
    (cycle_id, label, starts_on, ends_on, booking_opens_at, booking_closes_at,
     required_regular, required_major, buyout_amount, slot_buyout_amount,
     no_show_penalty, capacity_buffer)
VALUES (1, '2026/27', '2026-10-01', '2027-09-30',
        '2026-09-01 00:00+02', '2026-09-20 23:59+02', 5, 1, 150.00, 25.00, 75.00, 2);

-- ---------------------------------------------------------------------------
-- Wertelisten
-- ---------------------------------------------------------------------------
INSERT INTO kindergartens (kindergarten_id, label) VALUES (1, 'Clemens-KITA');
INSERT INTO kindergarten_recommendations (kindergarten_recommendation_id, label) VALUES
    (1, 'Einschulung'), (2, 'Zurückstellung');
INSERT INTO enrollment_categories (enrollment_category_id, label) VALUES
    (1, 'schulpflichtig'), (2, 'Kann-Kind'), (3, 'zurückgestellt');
INSERT INTO school_programs (school_program_id, label) VALUES
    (1, 'Musikarche'), (2, 'Ferienprogramm'), (3, 'Clemens-KITA');
INSERT INTO school_recommendations (school_recommendation_id, label) VALUES
    (1, 'Hauptschule'), (2, 'Realschule'), (3, 'Gymnasium');
INSERT INTO fit_assessments (fit_assessment_id, label, sort_order) VALUES
    (1, 'Zusage', 1), (2, 'Eher Ja', 2), (3, 'Eher Nein', 3), (4, 'Absage', 4);
INSERT INTO consent_purposes (consent_purpose_id, label, code) VALUES
    (1, 'Schulvertrag', 'school_contract'), (2, 'Gesundheitsdaten', 'health_data'),
    (3, 'Fotoeinverständnis', 'photo'), (4, 'Informationsaustausch Hort/Schule', 'hort_school_exchange');
INSERT INTO document_types (document_type_id, label, code) VALUES
    (1, 'Schulvertrag', 'school_contract'), (2, 'Geburtsurkunde', 'birth_certificate'),
    (3, 'SEPA-Mandat', 'sepa_mandate');

-- Der code ist der stabile Anker für Systemverhalten (Foto-Ansicht,
-- Werbemail-Filter); das label bleibt frei umbenennbar.
\echo '--- erwartet: FEHLER (Zweck-Code in freier Schreibweise statt Ankerform)'
INSERT INTO consent_purposes (label, code) VALUES ('Werbung', 'Werbung per Mail');

-- Status samt der beiden nicht umbenennbaren Kennzeichen
INSERT INTO application_statuses (application_status_id, label, is_waitlist, is_final) VALUES
    (1, 'in Bearbeitung', false, false),
    (2, 'auf Warteliste',  true,  false),
    (3, 'Zusage',          false, false),
    (4, 'abgesagt',        false, true),
    -- Ein ausgeschlagener Wartelistenplatz zaehlt wie eine Absage: eigener
    -- Endstatus, gleiche Loeschung zum 01.08. (domains/anmeldung.md).
    (5, 'Platz abgelehnt', false, true);
SELECT 'status verdrahtet' AS pruefung, created_by FROM application_statuses WHERE application_status_id = 1;

\echo '--- erwartet: FEHLER (Status kann nicht zugleich Warteliste und Endstatus sein)'
INSERT INTO application_statuses (label, is_waitlist, is_final) VALUES ('beides', true, true);

-- ---------------------------------------------------------------------------
-- Schulpflicht-Stichtage: Daten, keine Konstanten
-- ---------------------------------------------------------------------------
INSERT INTO enrollment_cutoffs (school_year, cutoff_on, compulsory_age)
    VALUES ('2027/28', '2027-06-30', 6);
SELECT 'stichtag als datenwert' AS pruefung, cutoff_on, compulsory_age FROM enrollment_cutoffs;

\echo '--- erwartet: FEHLER (zweiter Stichtag für dasselbe Schuljahr)'
INSERT INTO enrollment_cutoffs (school_year, cutoff_on, compulsory_age)
    VALUES ('2027/28', '2027-07-31', 6);

\echo '--- erwartet: FEHLER (unplausibles Einschulungsalter)'
INSERT INTO enrollment_cutoffs (school_year, cutoff_on, compulsory_age)
    VALUES ('2028/29', '2028-06-30', 42);

-- Das Schuljahr ist ein tragender Verbindungswert (Bewerbung → Stichtag), kein
-- Anzeigetext: eine zweite Schreibweise fände beim Vergleich still nichts.
\echo '--- erwartet: FEHLER (Schuljahr in abweichender Schreibweise)'
INSERT INTO enrollment_cutoffs (school_year, cutoff_on, compulsory_age)
    VALUES ('2028/2029', '2028-06-30', 6);

-- ---------------------------------------------------------------------------
-- Anmeldefenster: Sperre und Gebühr als Daten je Zweig und Schuljahr
-- ---------------------------------------------------------------------------
-- Die Schließung ist real je Schule dynamisch — deshalb je Zweig ein Fenster
-- mit eigenem Schlusszeitpunkt und eigener Gebühr.
INSERT INTO application_windows (application_window_id, school_branch_id, school_year,
                                 opens_at, closes_at, fee) VALUES
    (1, 1, '2027/28', '2026-10-26 00:00+02', '2027-02-01 23:59+01', 60.00),
    (2, 2, '2027/28', '2026-10-26 00:00+02', '2027-01-16 23:59+01', 60.00);
SELECT 'anmeldefenster und gebühr als datenwerte, schließung je zweig' AS pruefung,
       count(*) AS fenster, count(DISTINCT closes_at) AS verschiedene_schlusszeiten
  FROM application_windows WHERE school_year = '2027/28';

\echo '--- erwartet: FEHLER (Fenster schließt vor seiner Öffnung)'
INSERT INTO application_windows (school_branch_id, school_year, opens_at, closes_at, fee)
    VALUES (1, '2028/29', '2027-10-25 00:00+02', '2027-10-01 00:00+02', 60.00);

\echo '--- erwartet: FEHLER (zweites Fenster desselben Zweigs im selben Schuljahr)'
INSERT INTO application_windows (school_branch_id, school_year, opens_at, closes_at, fee)
    VALUES (1, '2027/28', '2027-03-01 00:00+01', '2027-06-30 23:59+02', 60.00);

-- ---------------------------------------------------------------------------
-- Gesprächstermine: Raster und Slot
-- ---------------------------------------------------------------------------
INSERT INTO interview_days (interview_day_id, school_branch_id, school_year, day_on,
                            starts_at, ends_at, break_starts_at, break_ends_at)
    VALUES (1, 1, '2027/28', '2027-02-06', '08:00', '16:00', '12:00', '13:00');
SELECT 'anmeldetag als datenwert' AS pruefung, day_on, starts_at, ends_at FROM interview_days;

\echo '--- erwartet: FEHLER (Tag endet vor seinem Beginn)'
INSERT INTO interview_days (school_branch_id, school_year, day_on, starts_at, ends_at)
    VALUES (2, '2027/28', '2027-02-11', '16:00', '08:00');

\echo '--- erwartet: FEHLER (halbe Mittagspause — nur Beginn gesetzt)'
INSERT INTO interview_days (school_branch_id, school_year, day_on, starts_at, ends_at, break_starts_at)
    VALUES (2, '2027/28', '2027-02-11', '08:00', '16:00', '12:00');

\echo '--- erwartet: FEHLER (Mittagspause liegt außerhalb des Tages)'
INSERT INTO interview_days (school_branch_id, school_year, day_on, starts_at, ends_at,
                            break_starts_at, break_ends_at)
    VALUES (2, '2027/28', '2027-02-11', '08:00', '16:00', '18:00', '19:00');

\echo '--- erwartet: FEHLER (zwei Anmeldetage desselben Zweigs am selben Datum)'
INSERT INTO interview_days (school_branch_id, school_year, day_on, starts_at, ends_at)
    VALUES (1, '2027/28', '2027-02-06', '08:00', '16:00');

INSERT INTO interview_slots (interview_slot_id, interview_day_id, school_branch_id, starts_at, capacity)
    VALUES (1, 1, 1, '08:00', 5), (2, 1, 1, '09:00', 4);

\echo '--- erwartet: FEHLER (Slot ohne Kapazität ist nicht buchbar)'
INSERT INTO interview_slots (interview_day_id, school_branch_id, starts_at, capacity)
    VALUES (1, 1, '10:00', 0);

\echo '--- erwartet: FEHLER (derselbe Slot zweimal am selben Tag)'
INSERT INTO interview_slots (interview_day_id, school_branch_id, starts_at, capacity)
    VALUES (1, 1, '08:00', 5);

-- Ein Slot gehört zum Zweig seines Tages und kann nicht umgehängt werden.
\echo '--- erwartet: FEHLER (Slot mit fremdem Zweig an einem Anmeldetag)'
INSERT INTO interview_slots (interview_day_id, school_branch_id, starts_at, capacity)
    VALUES (1, 2, '11:00', 4);

-- ---------------------------------------------------------------------------
-- Bewerbung
-- ---------------------------------------------------------------------------
INSERT INTO applications (application_id, child_id, application_status_id,
                          target_school_year, target_grade_level_id, school_branch_id,
                          submitted_on, filled_by_person_id, other_parent_informed,
                          siblings_at_school, sibling_count, interested_in_care,
                          kindergarten_id, kindergarten_consent_at,
                          kindergarten_recommendation_id, enrollment_category_id,
                          interview_slot_id)
VALUES ('a0000000-0000-0000-0000-000000000001',
        '11111111-1111-1111-1111-111111111111', 1,
        '2027/28', 1, 1, '2026-10-20', '22222222-2222-2222-2222-222222222222', true,
        true, 2, true, 1, now(), 1, 1, 1);
SELECT 'bewerbung zeigt auf das kind, kopiert keine personendaten' AS pruefung,
       p.last_name, p.first_name, c.date_of_birth
  FROM applications a
  JOIN children c ON c.child_id = a.child_id
  JOIN persons  p ON p.person_id = a.child_id
 WHERE a.application_id = 'a0000000-0000-0000-0000-000000000001';

INSERT INTO application_programs (application_id, school_program_id) VALUES
    ('a0000000-0000-0000-0000-000000000001', 1),
    ('a0000000-0000-0000-0000-000000000001', 2);
SELECT 'mehrere wahrgenommene angebote' AS pruefung, count(*) AS angebote
  FROM application_programs WHERE application_id = 'a0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (dasselbe Angebot zweimal an derselben Bewerbung)'
INSERT INTO application_programs (application_id, school_program_id)
    VALUES ('a0000000-0000-0000-0000-000000000001', 1);

\echo '--- erwartet: FEHLER (zweite Bewerbung desselben Kindes fürs selbe Zielschuljahr)'
INSERT INTO applications (child_id, application_status_id, target_school_year, target_grade_level_id, school_branch_id)
    VALUES ('11111111-1111-1111-1111-111111111111', 1, '2027/28', 1, 1);

-- Eine zweite Bewerbung für ein ANDERES Zielschuljahr ist dagegen der Normalfall
-- (Wechsel von der eigenen Grundschule in die eigene Realschule, Wiederholung
-- nach Absage).
INSERT INTO applications (application_id, child_id, application_status_id,
                          target_school_year, target_grade_level_id, school_branch_id)
    VALUES ('a0000000-0000-0000-0000-000000000002',
            '11111111-1111-1111-1111-111111111111', 2, '2031/32', 5, 2);
SELECT 'zwei bewerbungen desselben kindes in verschiedenen jahren' AS pruefung, count(*) AS bewerbungen
  FROM applications WHERE child_id = '11111111-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (Geschwister an der Schule, aber Geschwisterzahl 0)'
INSERT INTO applications (child_id, application_status_id, target_school_year,
                          target_grade_level_id, school_branch_id, siblings_at_school, sibling_count)
    VALUES ('44444444-4444-4444-4444-444444444444', 1, '2027/28', 1, 1, true, 0);

\echo '--- erwartet: FEHLER (Rücksprache-Erlaubnis ohne Kindergarten)'
INSERT INTO applications (child_id, application_status_id, target_school_year,
                          target_grade_level_id, school_branch_id, kindergarten_consent_at)
    VALUES ('44444444-4444-4444-4444-444444444444', 1, '2028/29', 1, 1, now());

-- Zweig der Zielklassenstufe und Zweig des gebuchten Slots müssen
-- zusammenpassen — sonst säße ein Grundschulkind im Realschul-Anmeldetag.
\echo '--- erwartet: FEHLER (Zweig passt nicht zur Zielklassenstufe)'
INSERT INTO applications (child_id, application_status_id, target_school_year,
                          target_grade_level_id, school_branch_id)
    VALUES ('44444444-4444-4444-4444-444444444444', 1, '2029/30', 1, 2);

\echo '--- erwartet: FEHLER (Gesprächsslot eines anderen Zweigs gebucht)'
INSERT INTO applications (child_id, application_status_id, target_school_year,
                          target_grade_level_id, school_branch_id, interview_slot_id)
    VALUES ('44444444-4444-4444-4444-444444444444', 1, '2030/31', 5, 2, 1);

\echo '--- erwartet: FEHLER (Rangnummer 0 statt leer)'
UPDATE applications SET rank_number = 0
    WHERE application_id = 'a0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (leerer Bearbeitungsstand statt NULL)'
UPDATE applications SET processing_note = ''
    WHERE application_id = 'a0000000-0000-0000-0000-000000000001';

-- Die Warteliste ist ein Status samt fortgeschriebener Zielklassenstufe, keine
-- eigene Entität: die jährliche Fortschreibung ist ein UPDATE.

-- Davor die jährliche Rückfrage: gefragt, aber noch nicht geantwortet — der
-- Zustand, der ohne eigene Spalte wie „nie gefragt" aussähe.
UPDATE applications SET waitlist_interest_asked_at = now()
 WHERE application_id = 'a0000000-0000-0000-0000-000000000002';
SELECT 'gefragt ohne antwort ist von nie gefragt unterscheidbar' AS pruefung,
       waitlist_interest_asked_at IS NOT NULL     AS gefragt,
       waitlist_interest_confirmed_at IS NULL     AS keine_antwort
  FROM applications WHERE application_id = 'a0000000-0000-0000-0000-000000000002';

\echo '--- erwartet: FEHLER (Interesse bestätigt, ohne dass gefragt wurde)'
UPDATE applications SET waitlist_interest_asked_at = NULL,
                        waitlist_interest_confirmed_at = now()
 WHERE application_id = 'a0000000-0000-0000-0000-000000000002';

UPDATE applications SET waitlist_interest_confirmed_at = now()
 WHERE application_id = 'a0000000-0000-0000-0000-000000000002';

-- Die Fortschreibung räumt beide Spalten: sie gelten je Zieljahr, nicht ewig.
UPDATE applications
   SET target_school_year = '2032/33', target_grade_level_id = 6, school_branch_id = 2,
       waitlist_interest_asked_at = NULL, waitlist_interest_confirmed_at = NULL
 WHERE application_id = 'a0000000-0000-0000-0000-000000000002';
SELECT 'warteliste jährlich fortgeschrieben, rückfrage zurückgesetzt' AS pruefung,
       s.label, s.is_waitlist, g.label AS zielstufe,
       a.waitlist_interest_asked_at IS NULL AS rueckfrage_offen
  FROM applications a
  JOIN application_statuses s ON s.application_status_id = a.application_status_id
  JOIN grade_levels g         ON g.grade_level_id = a.target_grade_level_id
 WHERE a.application_id = 'a0000000-0000-0000-0000-000000000002';

-- Bewertung: konsolidiertes Ergebnis, zwei getrennte Niveau-Felder
UPDATE applications
   SET fit_assessment_id = 2, primary_school_recommendation_id = 2,
       own_recommendation_id = 3, rank_number = 4,
       assessment_notes = 'wirkt sicher, Testblatt schwach'
 WHERE application_id = 'a0000000-0000-0000-0000-000000000001';
SELECT 'bewertung konsolidiert, empfehlung und eigenes niveau getrennt' AS pruefung,
       f.label AS einschaetzung, r1.label AS empfehlung, r2.label AS eigenes_niveau
  FROM applications a
  JOIN fit_assessments f          ON f.fit_assessment_id = a.fit_assessment_id
  JOIN school_recommendations r1  ON r1.school_recommendation_id = a.primary_school_recommendation_id
  JOIN school_recommendations r2  ON r2.school_recommendation_id = a.own_recommendation_id
 WHERE a.application_id = 'a0000000-0000-0000-0000-000000000001';

-- ---------------------------------------------------------------------------
-- Quereinstieg: Hospitationszeitraum und Schülerüberweisung an der Bewerbung
-- ---------------------------------------------------------------------------
INSERT INTO applications (application_id, child_id, application_status_id,
                          target_school_year, target_grade_level_id, school_branch_id,
                          is_lateral_entry, trial_attendance_starts_on, trial_attendance_ends_on,
                          student_transfer_requested_on, student_transfer_received_on,
                          student_transfer_returned_on)
    VALUES ('a0000000-0000-0000-0000-000000000003',
            '44444444-4444-4444-4444-444444444444', 1, '2027/28', 5, 2,
            true, '2027-11-08', '2027-11-12', '2027-11-15', '2027-11-20', '2027-11-27');
-- Alle drei Schritte des Überweisungsvorgangs: informiert, erhalten,
-- zurückgesendet. Der erste unterscheidet „noch nicht informiert" von „noch
-- keine Antwort" — zwei verschiedene Handlungen für dasselbe leere Empfangsdatum.
SELECT 'quereinstieg: hospitation und die drei überweisungsschritte' AS pruefung,
       trial_attendance_starts_on,
       student_transfer_requested_on IS NOT NULL AS schule_informiert,
       student_transfer_received_on  IS NOT NULL AS ueberweisung_erhalten,
       student_transfer_returned_on  IS NOT NULL AS ueberweisung_zurueckgesendet
  FROM applications WHERE application_id = 'a0000000-0000-0000-0000-000000000003';

-- Der Regelfall daneben: informiert, aber noch keine Antwort — genau der
-- Zustand, der ohne die erste Spalte wie „noch nichts getan" aussähe.
UPDATE applications SET student_transfer_requested_on = '2027-03-01'
    WHERE application_id = 'a0000000-0000-0000-0000-000000000001';
SELECT 'informiert, aber noch nicht erhalten' AS pruefung,
       student_transfer_requested_on IS NOT NULL AS schule_informiert,
       student_transfer_received_on  IS NULL     AS wartet_auf_ueberweisung
  FROM applications WHERE application_id = 'a0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Hospitationsende vor ihrem Beginn)'
UPDATE applications SET trial_attendance_ends_on = '2027-11-01'
    WHERE application_id = 'a0000000-0000-0000-0000-000000000003';

-- ---------------------------------------------------------------------------
-- Q3: Anmeldegebühr als dritter Zahlungsanlass
-- ---------------------------------------------------------------------------
INSERT INTO payments (application_id, amount, reference)
    VALUES ('a0000000-0000-0000-0000-000000000001', 50.00, 'pi_3QexampleApplicationFee');
SELECT 'anmeldegebühr als dritter q3-anlass' AS pruefung, amount, settled_at IS NULL AS offen
  FROM payments WHERE application_id = 'a0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (zweite Zahlung auf dieselbe Bewerbung)'
INSERT INTO payments (application_id, amount)
    VALUES ('a0000000-0000-0000-0000-000000000001', 50.00);

\echo '--- erwartet: FEHLER (Zahlung auf Bewerbung UND Putzdienst-Freikauf zugleich)'
INSERT INTO cleaning_buyouts (buyout_id, cycle_id, family_id)
    VALUES ('b0000000-0000-0000-0000-000000000001', 1, 'f0000000-0000-0000-0000-000000000001');
INSERT INTO payments (application_id, cleaning_buyout_id, amount)
    VALUES ('a0000000-0000-0000-0000-000000000002',
            'b0000000-0000-0000-0000-000000000001', 50.00);

-- Der bestehende Putzdienst-Anlass funktioniert unverändert weiter
INSERT INTO payments (cleaning_buyout_id, amount)
    VALUES ('b0000000-0000-0000-0000-000000000001', 150.00);
SELECT 'putzdienst-freikauf nach der q3-erweiterung unverändert' AS pruefung, amount
  FROM payments WHERE cleaning_buyout_id = 'b0000000-0000-0000-0000-000000000001';

-- Löschung einer abgelehnten Bewerbung zum 01.08. (domains/anmeldung.md):
-- der Lösch-Job räumt von außen nach innen, und die Fremdschlüssel erzwingen
-- die Reihenfolge — die Zahlung geht mit, weil Optigem führend ist.
INSERT INTO applications (application_id, child_id, application_status_id,
                          target_school_year, target_grade_level_id, school_branch_id)
    VALUES ('a0000000-0000-0000-0000-000000000009',
            '44444444-4444-4444-4444-444444444444', 4, '2033/34', 1, 1);
INSERT INTO payments (application_id, amount, reference)
    VALUES ('a0000000-0000-0000-0000-000000000009', 50.00, 'pi_3QexampleAbgelehnt');

\echo '--- erwartet: FEHLER (Bewerbung löschen, solange ihre Zahlung noch steht)'
DELETE FROM applications WHERE application_id = 'a0000000-0000-0000-0000-000000000009';

DELETE FROM payments WHERE application_id = 'a0000000-0000-0000-0000-000000000009';
DELETE FROM applications WHERE application_id = 'a0000000-0000-0000-0000-000000000009';
SELECT 'abgelehnte bewerbung samt zahlung geräumt' AS pruefung,
       (SELECT count(*) FROM applications WHERE application_id = 'a0000000-0000-0000-0000-000000000009') AS bewerbungen,
       (SELECT count(*) FROM payments WHERE reference = 'pi_3QexampleAbgelehnt') AS zahlungen;

-- ---------------------------------------------------------------------------
-- Q5: Nachzieh-Aufgabe
-- ---------------------------------------------------------------------------
INSERT INTO sync_targets (sync_target_id, label, code) VALUES
    (1, 'ASV-BW', 'asv_bw'), (2, 'Optigem', 'optigem'), (3, 'Microsoft 365', 'm365');

\echo '--- erwartet: FEHLER (Zielsystem-Code in freier Schreibweise statt Ankerform)'
INSERT INTO sync_targets (label, code) VALUES ('Testsystem', 'ASV BW');

-- Neuanlage in ASV-BW nach Vertragsabschluss: die Aufgabe entsteht offen und
-- wird ausdrücklich erledigt — WER, hält die Audit-Spalte fest.
INSERT INTO sync_tasks (sync_task_id, sync_target_id, person_id, description)
    VALUES ('60000000-0000-0000-0000-000000000001', 1,
            '11111111-1111-1111-1111-111111111111', 'Neuanlage nach Vertragsabschluss');
SELECT 'nachzieh-aufgabe entsteht offen' AS pruefung, count(*) AS offene
  FROM sync_tasks WHERE completed_at IS NULL;
UPDATE sync_tasks SET completed_at = now()
    WHERE sync_task_id = '60000000-0000-0000-0000-000000000001';
SELECT 'nachzieh-aufgabe erledigt, verursacher im audit' AS pruefung,
       completed_at IS NOT NULL AS erledigt, updated_by
  FROM sync_tasks WHERE sync_task_id = '60000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Aufgabe ohne Beschreibung)'
INSERT INTO sync_tasks (sync_target_id, description) VALUES (2, '');

-- ---------------------------------------------------------------------------
-- Schulvertrag und Hortvertrag
-- ---------------------------------------------------------------------------
INSERT INTO contracts (contract_id, application_id, deadline_on)
    VALUES ('c0000000-0000-0000-0000-000000000001',
            'a0000000-0000-0000-0000-000000000001', '2027-03-15');

-- Mehrere Verträge über die Zeit sind zulässig, zwei OFFENE nicht: die Eltern
-- bekämen zwei Links und niemand wüsste, welcher zählt (domains/anmeldung.md).
\echo '--- erwartet: FEHLER (zweiter offener Vertragsvorgang zur selben Bewerbung)'
INSERT INTO contracts (application_id, deadline_on)
    VALUES ('a0000000-0000-0000-0000-000000000001', '2027-03-15');

\echo '--- erwartet: FEHLER (Vertragsvorgang ohne jeden Bezug)'
INSERT INTO contracts (deadline_on) VALUES ('2027-03-15');

\echo '--- erwartet: FEHLER (Vertragsvorgang an Bewerbung UND Kind zugleich)'
INSERT INTO contracts (application_id, child_id, deadline_on)
    VALUES ('a0000000-0000-0000-0000-000000000001',
            '11111111-1111-1111-1111-111111111111', '2027-03-15');

\echo '--- erwartet: FEHLER (Freigabe, ohne dass jemand auf Vollständigkeit geprüft hat)'
UPDATE contracts SET released_at = now()
    WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Bestätigungsmail vor der Freigabe)'
UPDATE contracts SET completeness_checked_at = now(), confirmation_sent_at = now()
    WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

-- Der reguläre Weg, in der vorgesehenen Reihenfolge
UPDATE contracts SET completeness_checked_at = now() WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';
UPDATE contracts SET released_at = now() WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';
UPDATE contracts SET confirmation_sent_at = now()   WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';
SELECT 'vertragsvorgang in der vorgesehenen reihenfolge' AS pruefung,
       completeness_checked_at IS NOT NULL AS geprueft,
       released_at IS NOT NULL AS freigegeben,
       confirmation_sent_at   IS NOT NULL AS bestaetigt
  FROM contracts WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

-- Fällt NACH der Gegenzeichnung auf, dass wesentliche Angaben fehlen, wird ein
-- zweiter Vertrag aufgesetzt statt der alte überschrieben — real vorgekommen.
-- Der alte bleibt als Beleg stehen, es gilt der zuletzt bestätigte
-- (domains/anmeldung.md). Erlaubt ist er, weil der erste abgeschlossen ist.
INSERT INTO contracts (contract_id, application_id, deadline_on)
    VALUES ('c0000000-0000-0000-0000-000000000004',
            'a0000000-0000-0000-0000-000000000001', '2027-05-31');
SELECT 'mehrere verträge je bewerbung, der zuletzt bestätigte gilt' AS pruefung,
       count(*) AS vertraege,
       count(*) FILTER (WHERE confirmation_sent_at IS NULL) AS offen,
       max(confirmation_sent_at) IS NOT NULL AS gueltiger_vorhanden
  FROM contracts WHERE application_id = 'a0000000-0000-0000-0000-000000000001';

-- Die Reihenfolge gilt auch nachträglich: ein korrigierter Prüfzeitpunkt darf
-- nicht hinter die Freigabe rutschen, sonst dokumentiert die Zeile eine
-- Prüfung nach der Freigabe — genau die Aussage, die die vier Zeitpunkte tragen.
\echo '--- erwartet: FEHLER (Prüfzeitpunkt nachträglich hinter die Freigabe geschoben)'
UPDATE contracts SET completeness_checked_at = now() + interval '1 day'
    WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

-- Der Konfliktfall, für den es die eigenen Antwortzeilen überhaupt gibt:
-- Mutter nimmt an, Vater lehnt ab.
INSERT INTO contract_responses (contract_id, person_id, accepted, responded_at,
                                own_data_confirmed_at, child_data_confirmed_at) VALUES
    ('c0000000-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222',
     true,  now(), now(), now()),
    ('c0000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333333',
     false, now(), now(), now());
SELECT 'platzannahme-konflikt ist abbildbar' AS pruefung,
       count(DISTINCT accepted) > 1 AS widerspruch
  FROM contract_responses WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Antwort ohne Zeitpunkt)'
INSERT INTO contract_responses (contract_id, person_id, accepted)
    VALUES ('c0000000-0000-0000-0000-000000000001',
            '11111111-1111-1111-1111-111111111111', true);

-- ---------------------------------------------------------------------------
-- Q1/Q2: Zustimmung, Dokument, Signatur
-- ---------------------------------------------------------------------------
INSERT INTO documents (document_id, document_type_id, application_id,
                       storage_drive_id, storage_item_id, created_on, template_version)
    VALUES ('d0000000-0000-0000-0000-000000000001', 1,
            'a0000000-0000-0000-0000-000000000001',
            'b!erzeugt', '01SCHULVERTRAG', current_date, '3.0');
INSERT INTO documents (document_type_id, child_id,
                       storage_drive_id, storage_item_id, created_on)
    VALUES (2, '11111111-1111-1111-1111-111111111111',
            'b!akte', '01GEBURTSURKUNDE', current_date);

\echo '--- erwartet: FEHLER (Dokument ohne jeden Bezug)'
INSERT INTO documents (document_type_id, storage_drive_id, storage_item_id, created_on)
    VALUES (1, 'b!akte', '01IRGENDWO', current_date);

\echo '--- erwartet: FEHLER (Dokument an Kind UND Bewerbung zugleich)'
INSERT INTO documents (document_type_id, child_id, application_id,
                       storage_drive_id, storage_item_id, created_on)
    VALUES (1, '11111111-1111-1111-1111-111111111111',
            'a0000000-0000-0000-0000-000000000001',
            'b!akte', '01DOPPELT', current_date);

-- Angeforderte, noch nicht vorgelegte Unterlage: der Beobachtungsbogen des
-- Kindergartens (prozesse.md Abschnitt 5.2). „Fehlt noch" ist damit eine Zeile
-- und nicht das Fehlen einer Zeile.
INSERT INTO document_types (document_type_id, label, code)
    VALUES (4, 'Beobachtungsbogen Kindergarten', 'kindergarten_observation');
INSERT INTO documents (document_id, document_type_id, application_id, requested_on)
    VALUES ('d0000000-0000-0000-0000-000000000009', 4,
            'a0000000-0000-0000-0000-000000000001', current_date);
SELECT 'angefordert ist von nie verlangt unterscheidbar' AS pruefung,
       storage_item_id IS NULL AS liegt_nicht_vor, requested_on IS NOT NULL AS angefordert
  FROM documents WHERE document_id = 'd0000000-0000-0000-0000-000000000009';

-- Nachgereicht: dieselbe Zeile trägt beides, die Anforderung bleibt als Beleg.
UPDATE documents SET storage_drive_id = 'b!akte',
                     storage_item_id  = '01BEOBACHTUNGSBOGEN',
                     created_on       = current_date
    WHERE document_id = 'd0000000-0000-0000-0000-000000000009';

-- Erst danach hakt das Sekretariat die Vollständigkeitsprüfung des Anmeldetags
-- ab — eine eigene Spalte, weil eine vergessene Prüfung sonst wie eine
-- vollständige Mappe aussähe.
UPDATE applications SET documents_checked_at = now()
    WHERE application_id = 'a0000000-0000-0000-0000-000000000001';
SELECT 'unterlagenprüfung des anmeldetags ist festgehalten' AS pruefung,
       a.documents_checked_at IS NOT NULL AS geprueft,
       count(*) FILTER (WHERE d.storage_item_id IS NULL) AS offene_unterlagen
  FROM applications a
  LEFT JOIN documents d ON d.application_id = a.application_id
 WHERE a.application_id = 'a0000000-0000-0000-0000-000000000001'
 GROUP BY a.documents_checked_at;

\echo '--- erwartet: FEHLER (Dokument weder vorgelegt noch angefordert)'
INSERT INTO documents (document_type_id, application_id)
    VALUES (1, 'a0000000-0000-0000-0000-000000000001');

\echo '--- erwartet: FEHLER (vorgelegtes Dokument ohne Vorlagedatum)'
INSERT INTO documents (document_type_id, application_id, storage_drive_id, storage_item_id)
    VALUES (1, 'a0000000-0000-0000-0000-000000000001', 'b!akte', '01OHNEDATUM');

-- Die Referenz ist zweiteilig und gilt nur ganz: ohne Bibliothek findet der
-- Abruf das Element nicht (domains/anmeldung.md, „Wo die Dateien liegen").
\echo '--- erwartet: FEHLER (Elementkennung ohne Bibliothek)'
INSERT INTO documents (document_type_id, application_id, storage_item_id, created_on)
    VALUES (1, 'a0000000-0000-0000-0000-000000000001', '01OHNEBIBLIOTHEK', current_date);

-- ---------------------------------------------------------------------------
-- Der Aktenordner: die zweite Ebene neben den Dokumentzeilen
-- ---------------------------------------------------------------------------
-- Nicht jede Datei der Schülerakte bekommt eine Zeile — der Ordner ist der
-- Anker, über den der Lösch-Job auch das erreicht, was Weltenbaum nie gesehen
-- hat (domains/anmeldung.md, „Wo die Dateien liegen").
INSERT INTO child_file_folders (child_id, storage_drive_id, storage_item_id)
    VALUES ('11111111-1111-1111-1111-111111111111', 'b!akte', '01ORDNER-MUELLER');
SELECT 'aktenordner hängt am kind, nicht an einer datei' AS pruefung,
       count(*) AS ordner
  FROM child_file_folders
 WHERE child_id = '11111111-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (zweiter Aktenordner für dasselbe Kind)'
INSERT INTO child_file_folders (child_id, storage_drive_id, storage_item_id)
    VALUES ('11111111-1111-1111-1111-111111111111', 'b!akte', '01ORDNER-ZWEITER');

\echo '--- erwartet: FEHLER (derselbe Ordner an zwei Kindern)'
INSERT INTO child_file_folders (child_id, storage_drive_id, storage_item_id)
    VALUES ('44444444-4444-4444-4444-444444444444', 'b!akte', '01ORDNER-MUELLER');

-- Der Ordner blockiert die Kindzeile wie die Gesundheitstabellen: er ist der
-- letzte Ort, an dem Dateien liegen, die keine Zeile mehr nennt — er darf nicht
-- als Nebenwirkung verschwinden, während die Dateien in SharePoint bleiben.
INSERT INTO persons (person_id, last_name, first_name)
    VALUES ('55555555-5555-5555-5555-555555555555', 'Fischer', 'Emil');
INSERT INTO children (child_id, date_of_birth)
    VALUES ('55555555-5555-5555-5555-555555555555', '2019-05-06');
INSERT INTO child_file_folders (child_id, storage_drive_id, storage_item_id)
    VALUES ('55555555-5555-5555-5555-555555555555', 'b!akte', '01ORDNER-FISCHER');
\echo '--- erwartet: FEHLER (Kind mit Aktenordner wird nicht nebenbei mitgelöscht)'
DELETE FROM children WHERE child_id = '55555555-5555-5555-5555-555555555555';

-- Ein Dokument, zwei Unterschriften
INSERT INTO signatures (signature_id, document_id, person_id) VALUES
    ('50000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001',
     '22222222-2222-2222-2222-222222222222'),
    ('50000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001',
     '33333333-3333-3333-3333-333333333333');
SELECT 'ein dokument, zwei unterschriften' AS pruefung, count(*) AS signaturen
  FROM signatures WHERE document_id = 'd0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (dieselbe Person unterschreibt dasselbe Dokument zweimal)'
INSERT INTO signatures (document_id, person_id)
    VALUES ('d0000000-0000-0000-0000-000000000001',
            '22222222-2222-2222-2222-222222222222');

-- „ees" wäre sonst lautlos eine zweite Signaturstufe neben „EES".
\echo '--- erwartet: FEHLER (Signaturstufe in abweichender Schreibweise)'
UPDATE signatures SET signature_level = 'ees'
    WHERE signature_id = '50000000-0000-0000-0000-000000000001';

-- Tippfehler-Korrektur vor Abschluss: dasselbe Dokument wird aus DERSELBEN
-- Vorlagenfassung neu erzeugt, die bereits geleisteten Unterschriften bleiben
-- stehen (domains/anmeldung.md, „Wenn mitten im Vorgang ein Fehler auffällt").
-- Was die Mutter unterschrieben hat, bleibt als Dateiversion in SharePoint
-- abrufbar; hier wandert nur das Erzeugungsdatum samt Audit-Spalte weiter.
UPDATE documents SET created_on = current_date + 1
    WHERE document_id = 'd0000000-0000-0000-0000-000000000001';
SELECT 'korrektur vor abschluss lässt die unterschriften stehen' AS pruefung,
       d.template_version, count(s.signature_id) AS signaturen
  FROM documents d LEFT JOIN signatures s ON s.document_id = d.document_id
 WHERE d.document_id = 'd0000000-0000-0000-0000-000000000001'
 GROUP BY d.template_version;

-- Ein Leerstring sähe aus wie eine Fassung und verglichen sich gegen nichts —
-- dann wäre nicht mehr entscheidbar, ob eine Korrektur den Vertragstext
-- verändert hat.
\echo '--- erwartet: FEHLER (leere Vorlagenfassung)'
UPDATE documents SET template_version = ''
    WHERE document_id = 'd0000000-0000-0000-0000-000000000001';

-- Zustimmung mit festgehaltener Zustelladresse, belegt durch eine Signatur.
-- granted_at steht ausdrücklich dabei — die Spalte hat bewusst keinen Default.
INSERT INTO consents (person_id, child_id, consent_purpose_id, granted_at, delivery_email, signature_id)
    VALUES ('22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111', 1, now(),
            'familie.mueller@example.org', '50000000-0000-0000-0000-000000000001');

-- Geteilte Mailbox: derselbe Zustellweg für beide Elternteile ist erlaubt und
-- genau deshalb wird die Adresse festgehalten (domains/stammdaten.md).
INSERT INTO consents (person_id, child_id, consent_purpose_id, granted_at, delivery_email, signature_id)
    VALUES ('33333333-3333-3333-3333-333333333333',
            '11111111-1111-1111-1111-111111111111', 1, now(),
            'familie.mueller@example.org', '50000000-0000-0000-0000-000000000002');
SELECT 'zwei zustimmungen über dasselbe postfach sind auswertbar' AS pruefung,
       count(DISTINCT person_id) AS personen, count(DISTINCT delivery_email) AS postfaecher
  FROM consents WHERE child_id = '11111111-1111-1111-1111-111111111111'
   AND consent_purpose_id = 1;

\echo '--- erwartet: FEHLER (dieselbe Zustimmung derselben Person zweimal)'
INSERT INTO consents (person_id, child_id, consent_purpose_id, granted_at, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111', 1, now(), 'zweitpostfach@example.org');

-- Auch die kindlose Zustimmung ist gegen Doppelung geschützt (NULLS NOT
-- DISTINCT) — mit gewöhnlichem UNIQUE ginge die zweite Zeile durch.
INSERT INTO consents (person_id, consent_purpose_id, granted_at, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222', 4, now(), 'familie.mueller@example.org');

\echo '--- erwartet: FEHLER (dieselbe kindlose Zustimmung zweimal)'
INSERT INTO consents (person_id, consent_purpose_id, granted_at, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222', 4, now(), 'familie.mueller@example.org');

\echo '--- erwartet: FEHLER (Zustelladresse ohne @)'
INSERT INTO consents (person_id, child_id, consent_purpose_id, granted_at, delivery_email)
    VALUES ('33333333-3333-3333-3333-333333333333',
            '11111111-1111-1111-1111-111111111111', 3, now(), 'keine-adresse');

\echo '--- erwartet: FEHLER (Widerruf vor der Zustimmung)'
UPDATE consents SET revoked_at = granted_at - interval '1 day'
    WHERE person_id = '22222222-2222-2222-2222-222222222222'
      AND consent_purpose_id = 1;

-- Widerruf ersetzt den Zustand, es entsteht keine zweite Zeile
UPDATE consents SET revoked_at = now()
    WHERE person_id = '22222222-2222-2222-2222-222222222222' AND consent_purpose_id = 1;
SELECT 'widerruf ohne historie' AS pruefung, count(*) AS zeilen,
       count(*) FILTER (WHERE revoked_at IS NOT NULL) AS widerrufen
  FROM consents WHERE person_id = '22222222-2222-2222-2222-222222222222'
   AND consent_purpose_id = 1;

-- Die Ablehnung ist eine eigene Antwort, keine fehlende Zeile: der Vater lehnt
-- das Fotoeinverständnis ab, die Mutter hat noch nicht geantwortet —
-- entschieden und offen bleiben unterscheidbar.
INSERT INTO consents (person_id, child_id, consent_purpose_id, declined_at, delivery_email)
    VALUES ('33333333-3333-3333-3333-333333333333',
            '11111111-1111-1111-1111-111111111111', 3, now(),
            'familie.mueller@example.org');
SELECT 'ablehnung ist von nie beantwortet unterscheidbar' AS pruefung,
       count(*) FILTER (WHERE declined_at IS NOT NULL) AS abgelehnt,
       count(*) AS beantwortet
  FROM consents
 WHERE child_id = '11111111-1111-1111-1111-111111111111' AND consent_purpose_id = 3;

\echo '--- erwartet: FEHLER (Zeile ohne Antwort — weder erteilt noch abgelehnt)'
INSERT INTO consents (person_id, child_id, consent_purpose_id, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111', 3, 'familie.mueller@example.org');

\echo '--- erwartet: FEHLER (erteilt und abgelehnt zugleich)'
INSERT INTO consents (person_id, child_id, consent_purpose_id, granted_at, declined_at, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111', 3, now(), now(),
            'familie.mueller@example.org');

\echo '--- erwartet: FEHLER (Widerruf einer Ablehnung — widerrufen wird nur eine Erteilung)'
UPDATE consents SET revoked_at = now()
    WHERE person_id = '33333333-3333-3333-3333-333333333333' AND consent_purpose_id = 3;

-- Die spätere Erteilung überschreibt die Ablehnung — dieselbe Zeile, keine
-- Historie, wie beim Widerruf.
UPDATE consents SET granted_at = now(), declined_at = NULL
    WHERE person_id = '33333333-3333-3333-3333-333333333333' AND consent_purpose_id = 3;
SELECT 'spätere erteilung überschreibt die ablehnung' AS pruefung,
       granted_at IS NOT NULL AS erteilt, declined_at IS NULL AS ablehnung_geraeumt
  FROM consents
 WHERE person_id = '33333333-3333-3333-3333-333333333333' AND consent_purpose_id = 3;

-- ---------------------------------------------------------------------------
-- Betreuungsmodule
-- ---------------------------------------------------------------------------
INSERT INTO care_modules (care_module_id, label, school_branch_id, time_description,
                          includes_homework, sort_order) VALUES
    (1, 'Frühbetreuung',           NULL, '7:00 Uhr bis Schulbeginn',                     false, 1),
    (2, 'Nachmittagsbetreuung 1',  NULL, 'Schulende bis 13:00 Uhr',                      false, 2),
    (4, 'Nachmittagsbetreuung 4',  NULL, 'Schulende bis 17:00 Uhr, ab 15:30 flexibel',   true,  4),
    (6, 'Hort nach Mittagschule',     2, '15:00 bis 17:00 Uhr',                          false, 6);

-- Der Hortvertrag ist auch beim SCHULKIND ein eigener Vorgang am Kind, neben
-- dessen Schulvertrag an der Bewerbung: er entsteht später und wird im
-- laufenden Schuljahr geändert, während der Schulvertrag steht
-- (domains/anmeldung.md). Deshalb eine zweite contracts-Zeile mit eigener
-- Frist, eigener Prüfung und eigener Freigabe — der Ablauf ist damit für
-- interne und externe Kinder derselbe.
INSERT INTO contracts (contract_id, child_id, deadline_on)
    VALUES ('c0000000-0000-0000-0000-000000000003',
            '11111111-1111-1111-1111-111111111111', '2027-06-30');
SELECT 'schulkind hat schulvertrag an der bewerbung und hortvertrag am kind' AS pruefung,
       count(*) FILTER (WHERE application_id IS NOT NULL) AS schulvertrag,
       count(*) FILTER (WHERE child_id       IS NOT NULL) AS hortvertrag
  FROM contracts
 WHERE application_id = 'a0000000-0000-0000-0000-000000000001'
    OR child_id       = '11111111-1111-1111-1111-111111111111';

-- Modul × Wochentag als Buchungseinheit — die Buchung hängt am Hortvertrag,
-- nicht am Schulvertrag.
INSERT INTO care_module_bookings (care_module_booking_id, child_id, care_module_id,
                                  contract_id, valid_from, valid_until)
    VALUES ('e0000000-0000-0000-0000-000000000001',
            '11111111-1111-1111-1111-111111111111', 4,
            'c0000000-0000-0000-0000-000000000003', '2027-09-13', '2031-07-31');
INSERT INTO care_module_booking_days (care_module_booking_id, weekday) VALUES
    ('e0000000-0000-0000-0000-000000000001', 1),
    ('e0000000-0000-0000-0000-000000000001', 2),
    ('e0000000-0000-0000-0000-000000000001', 4);
SELECT 'modul mal wochentag als buchungseinheit' AS pruefung, count(*) AS tage
  FROM care_module_booking_days
 WHERE care_module_booking_id = 'e0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Betreuung am Samstag)'
INSERT INTO care_module_booking_days (care_module_booking_id, weekday)
    VALUES ('e0000000-0000-0000-0000-000000000001', 6);

\echo '--- erwartet: FEHLER (Gültigkeit endet vor ihrem Beginn)'
INSERT INTO care_module_bookings (child_id, care_module_id, valid_from, valid_until)
    VALUES ('11111111-1111-1111-1111-111111111111', 1, '2027-09-13', '2027-01-01');

-- Höchstens eine OFFENE Buchung je Kind und Modul: die Modul-Anpassung muss die
-- alte Buchung schließen, bevor die neue entsteht — sonst wäre das Kind zweimal
-- aktiv gebucht und stünde doppelt auf der Küchen-Tagesliste (domains/mensa.md).
INSERT INTO care_module_bookings (care_module_booking_id, child_id, care_module_id, valid_from)
    VALUES ('e0000000-0000-0000-0000-000000000002',
            '11111111-1111-1111-1111-111111111111', 2, '2027-09-13');
\echo '--- erwartet: FEHLER (zweite offene Buchung desselben Moduls)'
INSERT INTO care_module_bookings (child_id, care_module_id, valid_from)
    VALUES ('11111111-1111-1111-1111-111111111111', 2, '2028-02-01');

-- Nach dem Schließen der alten ist die neue erlaubt — der Index erzwingt die
-- Reihenfolge, nicht die Anpassung selbst.
UPDATE care_module_bookings SET valid_until = '2028-01-31'
    WHERE care_module_booking_id = 'e0000000-0000-0000-0000-000000000002';
INSERT INTO care_module_bookings (child_id, care_module_id, valid_from)
    VALUES ('11111111-1111-1111-1111-111111111111', 2, '2028-02-01');
SELECT 'modulanpassung: geschlossene und neue buchung nebeneinander' AS pruefung,
       count(*) FILTER (WHERE valid_until IS NULL) AS offen,
       count(*)                                    AS gesamt
  FROM care_module_bookings
 WHERE child_id = '11111111-1111-1111-1111-111111111111' AND care_module_id = 2;

-- Derselbe Vorgang beim EXTERNEN Hortkind: der Hort nimmt Kinder auf, die weder
-- Grund- noch Realschüler sind. Ihr Hortvertrag durchläuft dieselben vier
-- Stationen und hängt ebenfalls am Kind — nur gibt es hier gar keine Bewerbung,
-- unter der ein Schulvertrag stehen könnte.
-- Dieselben Stationen, andere Stellen: geprüft wird im Hort, freigegeben von der
-- HORTLEITUNG (domains/anmeldung.md) — die Schulleitung ist je Zweig benannt und
-- für dieses Kind gar nicht zuständig. Deshalb heißen die Spalten nach der
-- Handlung und nicht nach der Stelle.
INSERT INTO contracts (contract_id, child_id, deadline_on)
    VALUES ('c0000000-0000-0000-0000-000000000002',
            '44444444-4444-4444-4444-444444444444', '2027-08-31');
UPDATE contracts SET completeness_checked_at = now()
    WHERE contract_id = 'c0000000-0000-0000-0000-000000000002';
UPDATE contracts SET released_at = now()
    WHERE contract_id = 'c0000000-0000-0000-0000-000000000002';
INSERT INTO care_module_bookings (child_id, care_module_id, contract_id, valid_from)
    VALUES ('44444444-4444-4444-4444-444444444444', 1,
            'c0000000-0000-0000-0000-000000000002', '2027-09-13');
SELECT 'hortvertrag hängt am kind statt an einer bewerbung' AS pruefung,
       b.valid_from, c.entry_date IS NULL AS nicht_eingeschrieben,
       k.application_id IS NULL AS ohne_bewerbung,
       k.completeness_checked_at IS NOT NULL AS geprueft,
       k.released_at IS NOT NULL AS freigegeben
  FROM care_module_bookings b
  JOIN children  c ON c.child_id    = b.child_id
  JOIN contracts k ON k.contract_id = b.contract_id
 WHERE b.child_id = '44444444-4444-4444-4444-444444444444';

-- Zwei Elternteile antworten auch am Hortvertrag getrennt — dieselbe Tabelle,
-- kein Sonderweg.
INSERT INTO contract_responses (contract_id, person_id, accepted, responded_at)
    VALUES ('c0000000-0000-0000-0000-000000000002',
            '22222222-2222-2222-2222-222222222222', true, now());
SELECT 'antwort je erziehungsberechtigtem gilt auch am hortvertrag' AS pruefung,
       count(*) AS antworten
  FROM contract_responses WHERE contract_id = 'c0000000-0000-0000-0000-000000000002';

\echo '--- erwartet: FEHLER (zweiter offener Vertragsvorgang zum selben Kind)'
INSERT INTO contracts (child_id, deadline_on)
    VALUES ('44444444-4444-4444-4444-444444444444', '2027-08-31');

-- ---------------------------------------------------------------------------
-- Löschmechanik: die Bewerbung blockiert, das Kind hängt daran
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Kind mit Bewerbung wird nicht nebenbei mitgelöscht)'
DELETE FROM children WHERE child_id = '11111111-1111-1111-1111-111111111111';

-- Der Lösch-Job erkennt nie aufgenommene Bewerber ohne eigene Spalte: leeres
-- Eintrittsdatum plus ausschließlich Endstatus (Kopfkommentar des Schemas).
-- Solange noch eine Bewerbung offen ist, darf das Kind NICHT gefunden werden.
SELECT 'kind mit offener bewerbung ist kein löschkandidat' AS pruefung,
       count(*) AS kandidaten
  FROM children c
 WHERE c.entry_date IS NULL
   AND EXISTS (SELECT 1 FROM applications a WHERE a.child_id = c.child_id)
   AND NOT EXISTS (
         SELECT 1 FROM applications a
           JOIN application_statuses s ON s.application_status_id = a.application_status_id
          WHERE a.child_id = c.child_id AND NOT s.is_final);

-- Erst wenn ALLE Bewerbungen des Kindes im Endstatus stehen, wird es einer.
UPDATE applications SET application_status_id = 4
    WHERE child_id = '11111111-1111-1111-1111-111111111111';
SELECT 'nie aufgenommene bewerber sind ohne eigene spalte auffindbar' AS pruefung,
       count(*) AS kandidaten
  FROM children c
 WHERE c.entry_date IS NULL
   AND EXISTS (SELECT 1 FROM applications a WHERE a.child_id = c.child_id)
   AND NOT EXISTS (
         SELECT 1 FROM applications a
           JOIN application_statuses s ON s.application_status_id = a.application_status_id
          WHERE a.child_id = c.child_id AND NOT s.is_final);
