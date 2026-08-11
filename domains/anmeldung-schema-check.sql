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
--   * Sollstand: 37 Ankündigungen zu 37 ERROR-Zeilen, jeweils unmittelbar
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
INSERT INTO consent_purposes (consent_purpose_id, label) VALUES
    (1, 'Schulvertrag'), (2, 'Gesundheitsdaten'), (3, 'Fotoeinverständnis'),
    (4, 'Informationsaustausch Hort/Schule');
INSERT INTO document_types (document_type_id, label) VALUES
    (1, 'Schulvertrag'), (2, 'Geburtsurkunde'), (3, 'SEPA-Mandat');

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
UPDATE applications
   SET target_school_year = '2032/33', target_grade_level_id = 6, school_branch_id = 2
 WHERE application_id = 'a0000000-0000-0000-0000-000000000002';
SELECT 'warteliste jährlich fortgeschrieben' AS pruefung, s.label, s.is_waitlist,
       g.label AS zielstufe
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
-- Schulvertrag
-- ---------------------------------------------------------------------------
INSERT INTO contracts (contract_id, application_id, deadline_on)
    VALUES ('c0000000-0000-0000-0000-000000000001',
            'a0000000-0000-0000-0000-000000000001', '2027-03-15');

\echo '--- erwartet: FEHLER (zweiter Vertragsvorgang zur selben Bewerbung)'
INSERT INTO contracts (application_id, deadline_on)
    VALUES ('a0000000-0000-0000-0000-000000000001', '2027-03-15');

\echo '--- erwartet: FEHLER (Schulleitung gibt frei, ohne dass das Sekretariat geprüft hat)'
UPDATE contracts SET headmaster_released_at = now()
    WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

\echo '--- erwartet: FEHLER (Bestätigungsmail vor der Freigabe)'
UPDATE contracts SET secretariat_checked_at = now(), confirmation_sent_at = now()
    WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

-- Der reguläre Weg, in der vorgesehenen Reihenfolge
UPDATE contracts SET secretariat_checked_at = now() WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';
UPDATE contracts SET headmaster_released_at = now() WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';
UPDATE contracts SET confirmation_sent_at = now()   WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';
SELECT 'vertragsvorgang in der vorgesehenen reihenfolge' AS pruefung,
       secretariat_checked_at IS NOT NULL AS geprueft,
       headmaster_released_at IS NOT NULL AS freigegeben,
       confirmation_sent_at   IS NOT NULL AS bestaetigt
  FROM contracts WHERE contract_id = 'c0000000-0000-0000-0000-000000000001';

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
INSERT INTO documents (document_id, document_type_id, application_id, storage_path)
    VALUES ('d0000000-0000-0000-0000-000000000001', 1,
            'a0000000-0000-0000-0000-000000000001', 'RS25a/mueller-anna/schulvertrag.pdf');
INSERT INTO documents (document_type_id, child_id, storage_path)
    VALUES (2, '11111111-1111-1111-1111-111111111111', 'RS25a/mueller-anna/geburtsurkunde.pdf');

\echo '--- erwartet: FEHLER (Dokument ohne jeden Bezug)'
INSERT INTO documents (document_type_id, storage_path) VALUES (1, 'irgendwo.pdf');

\echo '--- erwartet: FEHLER (Dokument an Kind UND Bewerbung zugleich)'
INSERT INTO documents (document_type_id, child_id, application_id, storage_path)
    VALUES (1, '11111111-1111-1111-1111-111111111111',
            'a0000000-0000-0000-0000-000000000001', 'doppelt.pdf');

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

-- Zustimmung mit festgehaltener Zustelladresse, belegt durch eine Signatur
INSERT INTO consents (person_id, child_id, consent_purpose_id, delivery_email, signature_id)
    VALUES ('22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111', 1,
            'familie.mueller@example.org', '50000000-0000-0000-0000-000000000001');

-- Geteilte Mailbox: derselbe Zustellweg für beide Elternteile ist erlaubt und
-- genau deshalb wird die Adresse festgehalten (domains/stammdaten.md).
INSERT INTO consents (person_id, child_id, consent_purpose_id, delivery_email, signature_id)
    VALUES ('33333333-3333-3333-3333-333333333333',
            '11111111-1111-1111-1111-111111111111', 1,
            'familie.mueller@example.org', '50000000-0000-0000-0000-000000000002');
SELECT 'zwei zustimmungen über dasselbe postfach sind auswertbar' AS pruefung,
       count(DISTINCT person_id) AS personen, count(DISTINCT delivery_email) AS postfaecher
  FROM consents WHERE child_id = '11111111-1111-1111-1111-111111111111'
   AND consent_purpose_id = 1;

\echo '--- erwartet: FEHLER (dieselbe Zustimmung derselben Person zweimal)'
INSERT INTO consents (person_id, child_id, consent_purpose_id, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111', 1, 'zweitpostfach@example.org');

-- Auch die kindlose Zustimmung ist gegen Doppelung geschützt (NULLS NOT
-- DISTINCT) — mit gewöhnlichem UNIQUE ginge die zweite Zeile durch.
INSERT INTO consents (person_id, consent_purpose_id, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222', 4, 'familie.mueller@example.org');

\echo '--- erwartet: FEHLER (dieselbe kindlose Zustimmung zweimal)'
INSERT INTO consents (person_id, consent_purpose_id, delivery_email)
    VALUES ('22222222-2222-2222-2222-222222222222', 4, 'familie.mueller@example.org');

\echo '--- erwartet: FEHLER (Zustelladresse ohne @)'
INSERT INTO consents (person_id, child_id, consent_purpose_id, delivery_email)
    VALUES ('33333333-3333-3333-3333-333333333333',
            '11111111-1111-1111-1111-111111111111', 3, 'keine-adresse');

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

-- ---------------------------------------------------------------------------
-- Betreuungsmodule
-- ---------------------------------------------------------------------------
INSERT INTO care_modules (care_module_id, label, school_branch_id, time_description,
                          includes_homework, sort_order) VALUES
    (1, 'Frühbetreuung',           NULL, '7:00 Uhr bis Schulbeginn',                     false, 1),
    (2, 'Nachmittagsbetreuung 1',  NULL, 'Schulende bis 13:00 Uhr',                      false, 2),
    (4, 'Nachmittagsbetreuung 4',  NULL, 'Schulende bis 17:00 Uhr, ab 15:30 flexibel',   true,  4),
    (6, 'Hort nach Mittagschule',     2, '15:00 bis 17:00 Uhr',                          false, 6);

-- Modul × Wochentag als Buchungseinheit
INSERT INTO care_module_bookings (care_module_booking_id, child_id, care_module_id,
                                  contract_id, valid_from, valid_until)
    VALUES ('e0000000-0000-0000-0000-000000000001',
            '11111111-1111-1111-1111-111111111111', 4,
            'c0000000-0000-0000-0000-000000000001', '2027-09-13', '2031-07-31');
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

-- Der Hort nimmt Kinder auf, die weder Grund- noch Realschüler sind: Buchung
-- ohne Vertragsvorgang und ohne Einschreibung.
INSERT INTO care_module_bookings (child_id, care_module_id, valid_from)
    VALUES ('44444444-4444-4444-4444-444444444444', 1, '2027-09-13');
SELECT 'externes hortkind ohne bewerbung und ohne eintrittsdatum' AS pruefung,
       b.valid_from, c.entry_date IS NULL AS nicht_eingeschrieben,
       b.contract_id IS NULL AS ohne_vertragsvorgang
  FROM care_module_bookings b
  JOIN children c ON c.child_id = b.child_id
 WHERE b.child_id = '44444444-4444-4444-4444-444444444444';

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
