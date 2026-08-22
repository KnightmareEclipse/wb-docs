-- Prüfskript zu anmeldung-schema.sql.
--
-- Sollstand: 20 Tabellen — acht Wertelisten (application_statuses,
-- kindergartens, school_levels, enrolment_assessments,
-- kindergarten_recommendations, attended_offers,
-- care_need_levels, care_modules), dazu care_module_prices, tuition_fees,
-- enrolment_windows,
-- application_unlocks, admission_days, admission_day_slots, applications,
-- application_offers, contracts, contract_responses, care_module_agreements und
-- care_module_bookings. Dazu drei partielle Unique-Indizes und die beiden
-- Querschnitts-Fremdschlüssel auf `contracts` und `applications`. Zwei
-- Fremdschlüssel dieser Datei sind zusammengesetzt, obwohl sie einspaltig
-- aussehen: `fk_applications_slot` bindet das Zeitfenster an seinen Tag,
-- `fk_contracts_application` den Schulvertrag an das Kind seiner Bewerbung. Hier stehen
-- außerdem die Gegenproben zu `signatures` (Q2), deren Fremdschlüssel auf den
-- Vertragsvorgang erst mit dieser Datei entsteht.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f anmeldung-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY[
        'application_statuses', 'kindergartens', 'school_levels',
        'enrolment_assessments', 'kindergarten_recommendations',
        'attended_offers', 'care_need_levels', 'care_modules',
        'care_module_prices', 'tuition_fees', 'enrolment_windows', 'application_unlocks',
        'admission_days', 'admission_day_slots', 'applications',
        'application_offers', 'contracts', 'contract_responses',
        'care_module_agreements', 'care_module_bookings'
    ]) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 20 Tabellen vorhanden';
END $$;

-- 07: „Bewertung, Ranking und Notizen der Lehrkräfte: außerhalb des Systems,
-- auch nicht halb und auch nicht als stillgelegtes Feld." Der Block schlägt die
-- Karte, die eine Skala Zusage / Eher Ja / Eher Nein / Absage vorsah — die
-- Gegenprobe dazu ist das Fehlen, denn eine Spalte, die es nicht gibt, hat
-- keinen anderen Anker. `assessed_level_id` ist davon nicht berührt: die eigene
-- Niveau-Einschätzung hält 06 ausdrücklich fest.
DO $$
DECLARE unexpected text;
BEGIN
    IF to_regclass('public.assessment_results') IS NOT NULL THEN
        RAISE EXCEPTION 'Die Werteliste assessment_results steht entgegen Block 07 wieder da';
    END IF;
    SELECT string_agg(column_name, ', ') INTO unexpected
      FROM information_schema.columns
     WHERE table_name = 'applications'
       AND column_name IN ('assessment_result_id', 'assessment_rank', 'assessment_note');
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Die Bewerbung trägt entgegen Block 07 eine Bewertung: %', unexpected;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_name = 'applications' AND column_name = 'assessed_level_id') THEN
        RAISE EXCEPTION 'Die eigene Niveau-Einschätzung aus 06 fehlt';
    END IF;
    RAISE NOTICE 'ok: kein Bewertungsergebnis, die Niveau-Einschätzung steht';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_applications', 'pk_contracts', 'pk_admission_days',
        'fk_applications_child', 'fk_applications_admission_day',
        'fk_applications_status', 'fk_contracts_child', 'fk_contracts_text',
        'fk_contracts_document', 'fk_care_module_bookings_module',
        'uq_enrolment_windows', 'uq_admission_days_target',
        'uq_admission_day_slots', 'uq_application_offers',
        'uq_contract_responses', 'uq_care_module_bookings', 'uq_care_module_prices',
        'ck_applications_source', 'ck_applications_record_outcome',
        'ck_applications_record_note',
        'ck_applications_record_needs_slot', 'ck_applications_slot_and_day',
        'ck_applications_release', 'ck_applications_ended',
        'ck_contracts_type', 'ck_contracts_application', 'ck_contracts_care_only',
        'ck_contracts_document', 'ck_contracts_end',
        'ck_contract_responses_answer', 'ck_contract_responses_review',
        'ck_care_module_bookings_weekday',
        'ck_care_modules_grade', 'ck_care_module_prices_days',
        'ck_admission_days_hours', 'ck_admission_days_break',
        'ck_enrolment_windows_order', 'uq_application_statuses_is_final',
        'ck_applications_final_ended',
        'ck_applications_grade_level', 'ck_admission_days_grade_level',
        'ck_enrolment_windows_grade_level', 'fk_applications_branch',
        'fk_admission_days_branch', 'fk_enrolment_windows_branch',
        'ck_contracts_care_home_alone', 'ck_contracts_care_admission',
        'fk_applications_local_school', 'fk_applications_care_need_level',
        'ck_applications_care_need',
        'fk_applications_slot', 'uq_admission_day_slots_id_day',
        'fk_contracts_application', 'uq_applications_id_child',
        'uq_care_need_levels_code', 'uq_tuition_fees', 'fk_tuition_fees_branch',
        'ck_tuition_fees_amount', 'ck_tuition_fees_rank',
        'fk_signatures_contract', 'fk_signatures_agreement', 'fk_payments_application'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;

    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_applications_running', 'ix_contracts_running',
                      'ix_care_module_agreements_running']) AS i
    WHERE to_regclass('public.' || i) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Indizes: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints und Indizes vorhanden';
END $$;

CREATE FUNCTION pg_temp.expect_reject(rule text, stmt text) RETURNS void AS $$
BEGIN
    EXECUTE stmt;
    RAISE EXCEPTION 'REGEL NICHT GEBAUT — durchgelassen: %', rule;
EXCEPTION
    WHEN check_violation OR foreign_key_violation OR unique_violation
         OR not_null_violation OR exclusion_violation THEN
        RAISE NOTICE 'ok (abgewiesen): %', rule;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION pg_temp.expect_accept(rule text, stmt text) RETURNS void AS $$
BEGIN
    EXECUTE stmt;
    RAISE NOTICE 'ok (erlaubt): %', rule;
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- Stammsätze
-- ---------------------------------------------------------------------------
INSERT INTO school_branches (school_branch_id, code, name, first_grade_level,
                             final_grade_level, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'GS', 'Grundschule', 1, 4, 'system:check'),
           (2, 'RS', 'Realschule',  5, 10, 'system:check');
INSERT INTO application_statuses (application_status_id, code, name, is_final,
                                  keeps_connection, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'running',  'in Bearbeitung', false, true,  'system:check'),
    (2, 'waiting',  'auf Warteliste', false, true,  'system:check'),
    (3, 'offered',  'Zusage',         false, true,  'system:check'),
    (4, 'rejected', 'Absage',         true,  false, 'system:check'),
    (5, 'enrolled', 'eingeschrieben', true,  true,  'system:check');
INSERT INTO school_levels (school_level_id, code, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'hs', 'Hauptschule'), (2, 'rs', 'Realschule'), (3, 'gym', 'Gymnasium');
INSERT INTO kindergartens (kindergarten_id, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'Clemens-KITA');
INSERT INTO attended_offers (attended_offer_id, code, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'music_ark', 'Musikarche'), (2, 'holiday', 'Ferienprogramm');
INSERT INTO care_need_levels (care_need_level_id, code, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'core_time', 'Kernzeit'), (2, 'afternoon', 'Nachmittag'),
           (3, 'all_day', 'Ganztags');
INSERT INTO previous_schools (previous_school_id, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'Grundschule Musterstadt'), (2, 'Grundschule Nachbarort');

INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Kind',   'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Mutter', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222223', 'Vater',  'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222224', 'Extern', 'Hortkind', 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by) VALUES
    ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222221',
     '33333333-3333-3333-3333-333333333333', DATE '2020-05-01', 'system:check'),
    ('44444444-4444-4444-4444-444444444445', '22222222-2222-2222-2222-222222222224',
     '33333333-3333-3333-3333-333333333333', DATE '2019-05-01', 'system:check');

INSERT INTO contract_texts (contract_text_id, code, valid_from, body, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'school_contract_gs', DATE '2026-08-01', 'Schulvertrag GS', 'system:check'),
    (2, 'care_contract',      DATE '2026-08-01', 'Betreuungsvertrag', 'system:check');

INSERT INTO care_modules (care_module_id, code, name, includes_lunch,
                          school_branch_id, restricted_to_grade_level, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'early',      'Frühbetreuung',      false, NULL, NULL, 'system:check'),
    (2, 'afternoon3', 'Nachmittag bis 15:30', true, NULL, NULL, 'system:check'),
    (3, 'after_noon_school', 'Nach Mittagsschule', true, 2, 5, 'system:check');

INSERT INTO admission_days (admission_day_id, school_branch_id, target_grade_level,
                            first_grade_level, final_grade_level,
                            target_school_year, day, starts_at_time, ends_at_time,
                            slot_minutes, places_per_slot, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551', 1, 1, 1, 4, 2027,
            DATE '2026-11-14', TIME '08:00', TIME '16:00', 20, 4, 'system:check');
INSERT INTO admission_day_slots (admission_day_slot_id, admission_day_id, starts_at, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661',
            '55555555-5555-5555-5555-555555555551',
            TIMESTAMPTZ '2026-11-14 08:00+01', 'system:check');

INSERT INTO applications (application_id, child_id, school_branch_id, target_grade_level,
                          first_grade_level, final_grade_level,
                          target_school_year, source, submitted_at, filling_person_id,
                          application_status_id, created_by)
    VALUES ('77777777-7777-7777-7777-777777777771',
            '44444444-4444-4444-4444-444444444444', 1, 1, 1, 4, 2027, 'pre_registration',
            now(), '22222222-2222-2222-2222-222222222222', 1, 'system:check');

-- ---------------------------------------------------------------------------
-- Gegenproben — Bewerbung
-- ---------------------------------------------------------------------------

-- 07, Schritt 5: „Der Jahreslauf rückt jeden Warteplatz eine Stufe auf, dessen
-- Zielschuljahr zum 31. Juli geendet hat." Am Ende der Schulart gibt es keine
-- solche Stufe — `ck_applications_grade_level` weist sie ab, und der Lauf bliebe
-- an dieser Zeile stehen. Die Schule hat den Fall entschieden: Dort endet der
-- Warteplatz zum 31. Juli, wie der Jahrgang in 04 sein Austrittsdatum bekommt.
INSERT INTO applications (application_id, child_id, school_branch_id, target_grade_level,
                          first_grade_level, final_grade_level, target_school_year,
                          source, submitted_at, filling_person_id,
                          application_status_id, waiting_priority, created_by)
    VALUES ('77777777-7777-7777-7777-77777777777a',
            '44444444-4444-4444-4444-444444444445', 1, 4, 1, 4, 2026, 'lateral_entry',
            now(), '22222222-2222-2222-2222-222222222222', 2, 10, 'system:check');
SELECT pg_temp.expect_reject(
    '07 — Warteplatz am Ende der Schulart eine Stufe aufgerückt',
    $q$UPDATE applications SET target_grade_level = 5
        WHERE application_id = '77777777-7777-7777-7777-77777777777a'$q$);
SELECT pg_temp.expect_accept(
    '07 — derselbe Warteplatz endet stattdessen zum 31. Juli',
    $q$UPDATE applications SET application_status_id = 4, is_final = true,
                              ended_at = now(), ended_by = 'school'
        WHERE application_id = '77777777-7777-7777-7777-77777777777a'$q$);

-- 05: „Für dasselbe Kind und dasselbe Ziel entsteht keine zweite laufende
-- Bewerbung."
SELECT pg_temp.expect_reject(
    '05 — zweite laufende Bewerbung für dasselbe Kind und Ziel',
    $q$INSERT INTO applications (child_id, school_branch_id, target_grade_level,
                                 first_grade_level, final_grade_level,
                                 target_school_year, source, submitted_at,
                                 filling_person_id, application_status_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 1, 1, 1, 4, 2027, 'pre_registration',
               now(), '22222222-2222-2222-2222-222222222222', 1, 'system:check')$q$);

-- „Eine beendete steht dagegen nicht im Weg — nach Absage oder Rückzug (07)
-- ist der zweite Anlauf eine neue Bewerbung und kostet die Gebühr erneut" (05).
SELECT pg_temp.expect_accept(
    '05 — neue Bewerbung, nachdem die vorige beendet wurde',
    $q$UPDATE applications SET application_status_id = 4, is_final = true,
                              ended_at = now(), ended_by = 'parents'
         WHERE application_id = '77777777-7777-7777-7777-777777777771';
       INSERT INTO applications (application_id, child_id, school_branch_id, target_grade_level,
                                 first_grade_level, final_grade_level,
                                 target_school_year, source, submitted_at,
                                 filling_person_id, application_status_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772',
               '44444444-4444-4444-4444-444444444444', 1, 1, 1, 4, 2027, 'pre_registration',
               now(), '22222222-2222-2222-2222-222222222222', 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '05 — unbekannte Herkunft einer Bewerbung',
    $q$UPDATE applications SET source = 'walk_in'
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

SELECT pg_temp.expect_reject(
    '07 — beendet ohne Endzeitpunkt',
    $q$UPDATE applications SET ended_by = 'school'
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

-- 05: „bis zur bestätigten Zahlung gibt es keine Bewerbung", „es wird nichts
-- zwischengespeichert", „ein abgebrochenes Formular hinterlässt nichts". Die
-- abgeschickten, aber nicht bezahlten Angaben haben deshalb keine Zeile — weder
-- als eigene Tabelle noch als Bewerbung ohne Zahlungszeitpunkt.
DO $$
DECLARE unexpected text;
BEGIN
    SELECT string_agg(t, ', ') INTO unexpected
    FROM unnest(ARRAY['application_drafts', 'application_submissions',
                      'unpaid_applications']) AS t
    WHERE to_regclass('public.' || t) IS NOT NULL;
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Die unbezahlte Bewerbung hat entgegen 05 eine Tabelle: %', unexpected;
    END IF;
    RAISE NOTICE 'ok: keine Tabelle für die unbezahlte Bewerbung, wie 05 es festlegt';
END $$;

SELECT pg_temp.expect_reject(
    '05 — Bewerbung ohne bestätigte Zahlung',
    $q$INSERT INTO applications (child_id, school_branch_id, target_grade_level,
                                 first_grade_level, final_grade_level,
                                 target_school_year, source, filling_person_id,
                                 application_status_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 1, 2, 1, 4, 2027, 'lateral_entry',
               '22222222-2222-2222-2222-222222222222', 1, 'system:check')$q$);

-- 07, Schritt 2: „Ein Grund wird nicht eingetragen und eine Notiz auch nicht —
-- dafür gibt es kein Feld, auch kein stillgelegtes." 15, Schritt 2: „Die Gründe
-- — Freundschaften, Förderbedarf, Ausgewogenheit — bleiben außerhalb wie das
-- Ranking in 07." Beide Spalten standen allein auf grenzkarte.md.
DO $$
DECLARE unexpected text;
BEGIN
    SELECT string_agg(column_name, ', ') INTO unexpected
    FROM information_schema.columns
     WHERE table_name = 'applications'
       AND column_name IN ('processing_note', 'class_placement_wish',
                           'rejection_reason', 'decision_note');
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Die Bewerbung führt Freitext, den 07 und 15 ausschließen: %', unexpected;
    END IF;
    RAISE NOTICE 'ok: kein Bearbeitungsstand und kein Zusammensetzungswunsch an der Bewerbung';
END $$;

-- 07: „die Frist beginnt mit dem hier gesetzten Ende" — ein Endstatus ohne
-- Endzeitpunkt ließe den Lösch-Lauf die abgesagte Bewerbung nie erreichen und
-- sperrte zugleich den zweiten Anlauf aus 05.
SELECT pg_temp.expect_reject(
    '07 — Endstatus ohne Endzeitpunkt',
    $q$UPDATE applications SET application_status_id = 4, is_final = true
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

-- Das Flag der Statuszeile wird mitgeführt und ist deshalb an sie gebunden: ein
-- laufender Status, an dem „endgültig" steht, gibt es nicht (rules.md
-- Abschnitt 1).
SELECT pg_temp.expect_reject(
    '07 — laufender Status, an der Bewerbung als endgültig geführt',
    $q$UPDATE applications SET is_final = true, ended_at = now()
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

SELECT pg_temp.expect_reject(
    '07 — Endstatus, an der Bewerbung als laufend geführt',
    $q$UPDATE applications SET application_status_id = 5
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

-- 07: „‚entschieden, aber nicht gesendet' unterscheiden sich daran, dass ein
-- Ergebnis eingetragen ist" — freigegeben wird nur, was entschieden ist.
SELECT pg_temp.expect_reject(
    '07 — freigegeben, ohne dass ein Ergebnis eingetragen ist',
    $q$UPDATE applications SET released_at = now()
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

SELECT pg_temp.expect_accept(
    '07 — entschieden, dann freigegeben',
    $q$UPDATE applications SET application_status_id = 3, decided_at = now(),
                              released_at = now(), response_deadline_at = now() + interval '14 days'
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

-- 05: „Bei jedem Ziel in der Grundschule kommt die örtlich zuständige Schule
-- hinzu … Das sind zwei Einrichtungen mit zwei verschiedenen Rollen im
-- Verfahren, keine Alternative zueinander" — die abgebende steht am Kind, die
-- örtlich zuständige an der Bewerbung, und sie sind verschieden.
SELECT pg_temp.expect_accept(
    '05 — abgebende und örtlich zuständige Schule nebeneinander',
    $q$UPDATE children SET previous_school_id = 1
         WHERE child_id = '44444444-4444-4444-4444-444444444444';
       UPDATE applications SET local_school_id = 2
         WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '05 — örtlich zuständige Schule, die es nicht gibt',
    $q$UPDATE applications SET local_school_id = 99
         WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

-- 06: „Der Betreuungsbedarf — Kernzeit, Nachmittag, Ganztags (freiwillig) — ist
-- dieselbe Angabe wie das Betreuungsinteresse aus 05, hier um den Umfang
-- ergänzt."
SELECT pg_temp.expect_accept(
    '06 — Betreuungsbedarf mit seinem Umfang',
    $q$UPDATE applications SET care_interest = true, care_need_level_id = 3
         WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '06 — Umfang ohne Betreuungsbedarf',
    $q$UPDATE applications SET care_interest = false, care_need_level_id = 1
         WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '06 — Umfang bei unbeantwortetem Betreuungsbedarf',
    $q$UPDATE applications SET care_interest = NULL, care_need_level_id = 1
         WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

-- 06: „Für alles, was am Anmeldetag nur erklärt wird …, gibt es einen Haken,
-- nicht je Punkt einen."
SELECT pg_temp.expect_accept(
    '06 — der eine Haken für die erklärten Punkte',
    $q$UPDATE applications SET information_given_at = now()
         WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

-- 06: „Wer nie gebucht hat, hat auch keine Spur."
SELECT pg_temp.expect_reject(
    '06 — Verwaltungsspur ohne gebuchtes Zeitfenster',
    $q$UPDATE applications SET record_outcome = 'completed'
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

SELECT pg_temp.expect_reject(
    '06 — unbekannter Abschluss der Verwaltungsspur',
    $q$UPDATE applications
          SET admission_day_slot_id = '66666666-6666-6666-6666-666666666661',
              admission_day_id = '55555555-5555-5555-5555-555555555551',
              record_outcome = 'cancelled'
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

SELECT pg_temp.expect_reject(
    '06 — Zeitfenster ohne seinen Tag',
    $q$UPDATE applications SET admission_day_slot_id = '66666666-6666-6666-6666-666666666661'
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

-- rules.md 1: der zusammengesetzte Fremdschlüssel bindet den Tag ans Ziel.
-- Die mitgeführten Stufengrenzen wechseln mit: ohne sie wiese schon
-- `ck_applications_grade_level` die Zeile ab, und die Bindung Tag↔Ziel bliebe
-- unbelegt.
SELECT pg_temp.expect_reject(
    '06 — Anmeldetag eines fremden Ziels gebucht',
    $q$UPDATE applications
          SET admission_day_slot_id = '66666666-6666-6666-6666-666666666661',
              admission_day_id = '55555555-5555-5555-5555-555555555551',
              school_branch_id = 2, target_grade_level = 5,
              first_grade_level = 5, final_grade_level = 10
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

SELECT pg_temp.expect_accept(
    '06 — Zeitfenster des eigenen Ziels gebucht und Spur abgeschlossen',
    $q$UPDATE applications
          SET admission_day_slot_id = '66666666-6666-6666-6666-666666666661',
              admission_day_id = '55555555-5555-5555-5555-555555555551',
              record_outcome = 'completed', documents_checked_at = now()
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

-- 06, „Was dabei erhoben wird": „Dazu ein Freitext für Anmerkungen
-- (freiwillig)" — der letzte Punkt der Anmeldetags-Aufzählung.
SELECT pg_temp.expect_accept(
    '06 — Anmerkung an der Verwaltungsspur des Anmeldetags',
    $q$UPDATE applications
          SET admission_day_slot_id = '66666666-6666-6666-6666-666666666661',
              admission_day_id = '55555555-5555-5555-5555-555555555551',
              record_note = 'Mutter fragt nach dem Bus'
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

SELECT pg_temp.expect_reject(
    '06 — leerer Anmerkungstext statt keiner Anmerkung',
    $q$UPDATE applications SET record_note = ''
        WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

-- „Wer nie gebucht hat, hat auch keine Spur" (06) — das gilt auch für ihren
-- letzten Punkt.
SELECT pg_temp.expect_reject(
    '06 — Anmerkung ohne gebuchtes Zeitfenster',
    $q$UPDATE applications SET record_note = 'ohne Termin notiert'
        WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '06 — Anmeldetag, dessen Pause nur halb gesetzt ist',
    $q$INSERT INTO admission_days (school_branch_id, target_grade_level,
                                   first_grade_level, final_grade_level, target_school_year,
                                   day, starts_at_time, ends_at_time, break_from_time,
                                   slot_minutes, places_per_slot, created_by)
       VALUES (1, 1, 1, 4, 2027, DATE '2026-11-15', TIME '08:00', TIME '16:00',
               TIME '12:00', 20, 4, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '06 — Anmeldetag, der endet, bevor er beginnt',
    $q$INSERT INTO admission_days (school_branch_id, target_grade_level,
                                   first_grade_level, final_grade_level, target_school_year,
                                   day, starts_at_time, ends_at_time, slot_minutes,
                                   places_per_slot, created_by)
       VALUES (1, 1, 1, 4, 2027, DATE '2026-11-15', TIME '16:00', TIME '08:00', 20, 4,
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '06 — zwei Zeitfenster desselben Tages zur selben Zeit',
    $q$INSERT INTO admission_day_slots (admission_day_id, starts_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551',
               TIMESTAMPTZ '2026-11-14 08:00+01', 'system:check')$q$);

-- 06: die Platzzahl eines Zeitfensters ist „eine harte Grenze — ein volles
-- Zeitfenster ist nicht buchbar, anders als die überschreitbare Platzzahl beim
-- Putzdienst (01) und beim Ferienprogramm (10)". Sie ist die einzige harte
-- Kapazität des ganzen Modells und steht bewusst NICHT als Constraint: sie
-- zählte über die Zeilen einer anderen Tabelle, und `ix_applications_slot`
-- trägt allein die Abfrage dazu. Diese Probe hält die Auslassung fest, damit
-- sie beim Bau des Backends nicht untergeht.
INSERT INTO admission_days (admission_day_id, school_branch_id, target_grade_level,
                            first_grade_level, final_grade_level,
                            target_school_year, day, starts_at_time, ends_at_time,
                            slot_minutes, places_per_slot, created_by)
    VALUES ('55555555-5555-5555-5555-555555555552', 1, 1, 1, 4, 2027,
            DATE '2026-11-21', TIME '08:00', TIME '16:00', 20, 1, 'system:check');
INSERT INTO admission_day_slots (admission_day_slot_id, admission_day_id, starts_at, created_by)
    VALUES ('66666666-6666-6666-6666-666666666662',
            '55555555-5555-5555-5555-555555555552',
            TIMESTAMPTZ '2026-11-21 08:00+01', 'system:check');
SELECT pg_temp.expect_accept(
    '06 — Zeitfenster mit einem Platz, zweimal gebucht (die harte Grenze trägt die Anwendung)',
    $q$UPDATE applications
          SET admission_day_id = '55555555-5555-5555-5555-555555555552',
              admission_day_slot_id = '66666666-6666-6666-6666-666666666662'
        WHERE application_id IN ('77777777-7777-7777-7777-777777777771',
                                 '77777777-7777-7777-7777-777777777772')$q$);

-- Das Zeitfenster gehört genau einem Tag, und beide Anmeldetage oben tragen
-- dasselbe Ziel — der Sondertermin ist „der kleinste Anmeldetag" (06). Der
-- zusammengesetzte Fremdschlüssel auf `admission_day_slots` ist deshalb die
-- einzige Stelle, an der eine halbe Umbuchung auffällt: `fk_applications_
-- admission_day` bindet den Tag nur ans Ziel, und das Ziel stimmt hier.
SELECT pg_temp.expect_reject(
    '06 — umgebucht, aber nur das Zeitfenster gesetzt (der Tag bleibt der alte)',
    $q$UPDATE applications
          SET admission_day_slot_id = '66666666-6666-6666-6666-666666666661'
        WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_accept(
    '06 — dieselbe Umbuchung mit Tag und Zeitfenster zusammen',
    $q$UPDATE applications
          SET admission_day_id      = '55555555-5555-5555-5555-555555555551',
              admission_day_slot_id = '66666666-6666-6666-6666-666666666661'
        WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

-- Zurück auf den Stand, den die folgenden Proben vorfinden.
UPDATE applications
   SET admission_day_id      = '55555555-5555-5555-5555-555555555552',
       admission_day_slot_id = '66666666-6666-6666-6666-666666666662'
 WHERE application_id = '77777777-7777-7777-7777-777777777771';

-- 05: „Öffnet die Voranmeldung je Schulart" — je Ziel genau ein Fenster.
INSERT INTO enrolment_windows (school_branch_id, target_grade_level,
                               first_grade_level, final_grade_level, target_school_year,
                               opens_at, created_by)
    VALUES (1, 1, 1, 4, 2027, TIMESTAMPTZ '2026-10-25 00:00+02', 'system:check');
SELECT pg_temp.expect_reject(
    '05 — zweites Anmeldefenster für dasselbe Ziel',
    $q$INSERT INTO enrolment_windows (school_branch_id, target_grade_level,
                                      first_grade_level, final_grade_level,
                                      target_school_year, opens_at, created_by)
       VALUES (1, 1, 1, 4, 2027, TIMESTAMPTZ '2026-11-01 00:00+01', 'system:check')$q$);

-- 05: „Grundschule Klasse 1, Realschule Klasse 5" — welche Stufe ein Ziel sein
-- kann, sagt die Schulart. Vorher prüfte allein `applications` und dort gegen
-- 1..10; Grundschule Zielstufe 9 ging überall durch.
SELECT pg_temp.expect_reject(
    '05 — Anmeldefenster Grundschule für Zielstufe 9',
    $q$INSERT INTO enrolment_windows (school_branch_id, target_grade_level,
                                      first_grade_level, final_grade_level,
                                      target_school_year, opens_at, created_by)
       VALUES (1, 9, 1, 4, 2027, TIMESTAMPTZ '2026-10-25 00:00+02', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '06 — Anmeldetag Grundschule für Zielstufe 9',
    $q$INSERT INTO admission_days (school_branch_id, target_grade_level,
                                   first_grade_level, final_grade_level, target_school_year,
                                   day, starts_at_time, ends_at_time, slot_minutes,
                                   places_per_slot, created_by)
       VALUES (1, 9, 1, 4, 2027, DATE '2026-11-16', TIME '08:00', TIME '16:00', 20, 4,
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '05 — Bewerbung für die Grundschule mit Zielstufe 9',
    $q$INSERT INTO applications (child_id, school_branch_id, target_grade_level,
                                 first_grade_level, final_grade_level,
                                 target_school_year, source, submitted_at,
                                 filling_person_id, application_status_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 1, 9, 1, 4, 2027, 'lateral_entry',
               now(), '22222222-2222-2222-2222-222222222222', 1, 'system:check')$q$);

-- Und die Grenzen sind die der Schulart, nicht irgendwelche: mit 5..10 an der
-- Grundschule ginge Zielstufe 9 sonst durch den CHECK.
SELECT pg_temp.expect_reject(
    '05 — Bewerbung Grundschule mit den Grenzen der Realschule',
    $q$INSERT INTO applications (child_id, school_branch_id, target_grade_level,
                                 first_grade_level, final_grade_level,
                                 target_school_year, source, submitted_at,
                                 filling_person_id, application_status_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 1, 9, 5, 10, 2027, 'lateral_entry',
               now(), '22222222-2222-2222-2222-222222222222', 1, 'system:check')$q$);

-- Der Quereinstieg in eine Stufe mitten in der Schulart bleibt offen — „Der
-- Quereinstieg braucht das nicht, er ist immer offen" (05).
SELECT pg_temp.expect_accept(
    '05 — Quereinstieg in die Realschule, Zielstufe 9',
    $q$INSERT INTO applications (child_id, school_branch_id, target_grade_level,
                                 first_grade_level, final_grade_level,
                                 target_school_year, source, submitted_at,
                                 filling_person_id, application_status_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 2, 9, 5, 10, 2027, 'lateral_entry',
               now(), '22222222-2222-2222-2222-222222222222', 1, 'system:check')$q$);

-- „steht es noch nicht, bleibt sie offen, bis eines gesetzt wird" (05).
SELECT pg_temp.expect_accept(
    '05 — Anmeldefenster ohne Schließdatum',
    $q$INSERT INTO enrolment_windows (school_branch_id, target_grade_level,
                                      first_grade_level, final_grade_level,
                                      target_school_year, opens_at, created_by)
       VALUES (2, 5, 5, 10, 2027, TIMESTAMPTZ '2026-10-25 00:00+02', 'system:check')$q$);

-- 05: „Die Freischaltung … läuft nach 14 Tagen ab" — eine feste Zahl ist keine
-- Spalte. Der Ablauf folgt aus `created_at` (rules.md Abschnitt 1).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'application_unlocks' AND column_name = 'expires_at') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Ablauf steht neben seiner Ableitung';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 05 — der Ablauf der Freischaltung hat keine eigene Spalte';
END $$;

SELECT pg_temp.expect_accept(
    '05 — Freischaltung, deren Ablauf allein aus created_at folgt',
    $q$INSERT INTO application_unlocks (email, school_branch_id, target_grade_level,
                                        target_school_year, created_by)
       VALUES ('quer@example.org', 1, 1, 2027, 'entra:sekretariat')$q$);

-- Q3: die Anmeldegebühr hängt an genau dieser Bewerbung.
SELECT pg_temp.expect_accept(
    'Q3 — Anmeldegebühr auf die Bewerbung',
    $q$INSERT INTO payments (application_id, amount_cents, status, confirmed_at, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 2500, 'confirmed', now(),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q3 — Anmeldegebühr auf eine Bewerbung, die es nicht gibt',
    $q$INSERT INTO payments (application_id, amount_cents, created_by)
       VALUES ('77777777-7777-7777-7777-777777777779', 2500, 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — Vertragsvorgang
-- ---------------------------------------------------------------------------

INSERT INTO contracts (contract_id, child_id, contract_type, application_id,
                       contract_text_id, created_by)
    VALUES ('88888888-8888-8888-8888-888888888881',
            '44444444-4444-4444-4444-444444444444', 'school',
            '77777777-7777-7777-7777-777777777772', 1, 'system:check');

-- 08: „Zwillinge sind zwei Verträge" — zwei Bewerbungen mit demselben Ziel,
-- derselben Familie und demselben Vertragstext. Ohne den zusammengesetzten
-- Fremdschlüssel ginge der Vertrag mit der Bewerbung des Geschwisters durch,
-- und der Lösch-Lauf bliebe später an genau ihm stehen.
SELECT pg_temp.expect_reject(
    '08 — Schulvertrag am einen Kind, Bewerbung am anderen',
    $q$INSERT INTO contracts (child_id, contract_type, application_id,
                              contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'school',
               '77777777-7777-7777-7777-77777777777a', 1, 'system:check')$q$);

-- Die Gegenrichtung, die MATCH SIMPLE offenhalten muss: „ein Hortvertrag hängt
-- am Kind" (09) und trägt keine Bewerbung. MATCH FULL wiese ihn ab.
SELECT pg_temp.expect_accept(
    '09 — Hortvertrag ohne Bewerbung geht weiter durch',
    $q$INSERT INTO contracts (contract_id, child_id, contract_type, contract_text_id,
                              may_walk_home_alone, created_by)
       VALUES ('88888888-8888-8888-8888-88888888888f',
               '44444444-4444-4444-4444-444444444445', 'care', 2, false, 'system:check');
       DELETE FROM contracts WHERE contract_id = '88888888-8888-8888-8888-88888888888f'$q$);

-- 08/09: ein Schulvertrag entsteht aus einer Zusage, ein Hortvertrag nie.
SELECT pg_temp.expect_reject(
    '09 — Hortvertrag mit Bewerbung',
    $q$INSERT INTO contracts (child_id, contract_type, application_id, contract_text_id,
                              may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 'care',
               '77777777-7777-7777-7777-777777777772', 2, false, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Schulvertrag ohne Bewerbung',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 'school', 1, 'system:check')$q$);

-- 08: „Die Fassung friert mit der Zusage ein und nicht erst mit der einzelnen
-- Unterschrift." Sie steht deshalb am Vertrag und an keiner zweiten Stelle.
SELECT pg_temp.expect_reject(
    'hebel.md — Vertrag auf eine Fassung, die es nicht gibt',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id,
                              may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 'care', 99, false, 'system:check')$q$);

-- 09: „Der Hortvertrag hängt deshalb immer am Kind statt an einer Bewerbung —
-- bei internen Kindern wie bei externen."
SELECT pg_temp.expect_accept(
    '09 — Hortvertrag eines externen Kindes ohne Bewerbung',
    $q$INSERT INTO contracts (contract_id, child_id, contract_type, contract_text_id,
                              admission_date, may_walk_home_alone, external_school_note,
                              created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               '44444444-4444-4444-4444-444444444445', 'care', 2,
               DATE '2026-09-01', false, 'Grundschule Musterstadt, Jahrgang 3',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — Hort-eigene Angabe am Schulvertrag',
    $q$UPDATE contracts SET may_walk_home_alone = true
        WHERE contract_id = '88888888-8888-8888-8888-888888888881'$q$);

-- 09: „Je Kind ein laufender Hortvertrag, nie zwei nebeneinander" — laufend
-- heißt freigegeben und ohne bekanntes Ende.
SELECT pg_temp.expect_accept(
    '08 — die zurückgetretene Bewerbung hält den zweiten Anlauf nicht auf',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id,
                              may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 'care', 2, false, 'system:check')$q$);

UPDATE contracts SET released_at = now(), released_by = 'entra:hortleitung'
    WHERE contract_id = '88888888-8888-8888-8888-888888888882';

SELECT pg_temp.expect_reject(
    '09 — zweiter laufender Hortvertrag desselben Kindes',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id, released_at,
                              released_by, admission_date, may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 'care', 2,
               now(), 'entra:hortleitung', DATE '2026-10-01', false, 'system:check')$q$);

-- Derselbe Fall, wie er im Betrieb wirklich aussieht: 09 führt am Hortvertrag
-- „im ersten Jahr der 31. Juli" mit. Solange `runs_until` in der
-- Index-Bedingung stand, ging genau dieser zweite Vertrag durch.
SELECT pg_temp.expect_accept(
    '09 — der laufende Hortvertrag trägt seinen 31. Juli',
    $q$UPDATE contracts SET runs_until = DATE '2027-07-31'
         WHERE contract_id = '88888888-8888-8888-8888-888888888882'$q$);
SELECT pg_temp.expect_reject(
    '09 — zweiter Hortvertrag mit derselben Laufzeit daneben',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id, released_at,
                              released_by, admission_date, runs_until,
                              may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 'care', 2,
               now(), 'entra:hortleitung', DATE '2026-10-01', DATE '2027-07-31',
               false, 'system:check')$q$);

-- 04: „Wer in Klasse 5 weiter Betreuung braucht, schließt einen neuen" — der
-- Antrag entsteht vor dem 31. Juli, an dem der alte endet; das `end_date` setzt
-- erst der Jahreslauf am 1. August.
SELECT pg_temp.expect_accept(
    '04 — Hortvertrag für Klasse 5 neben dem auslaufenden',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id, released_at,
                              released_by, admission_date, may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444445', 'care', 2,
               now(), 'entra:hortleitung', DATE '2027-08-01', false, 'system:check')$q$);


-- 09, Schritt 5: „Gibt frei und unterschreibt für den Träger und trägt dabei
-- das Aufnahmedatum ein." Ohne das Datum rechnete `ex_contracts_care_period`
-- als „seit jeher und bis auf Weiteres" und wiese jeden späteren Hortvertrag
-- desselben Kindes ab.
SELECT pg_temp.expect_reject(
    '09 — freigegebener Hortvertrag ohne Aufnahmedatum',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id, released_at,
                              released_by, may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'care', 2,
               now(), 'entra:hortleitung', false, 'system:check')$q$);
-- Vor der Freigabe steht es frei: der Antrag aus Schritt 4 kennt den Tag noch
-- nicht.
SELECT pg_temp.expect_accept(
    '09 — Hortvertrag vor der Freigabe ohne Aufnahmedatum',
    $q$INSERT INTO contracts (contract_id, child_id, contract_type, contract_text_id,
                              may_walk_home_alone, created_by)
       VALUES ('88888888-8888-8888-8888-88888888888c',
               '44444444-4444-4444-4444-444444444444', 'care', 2, false, 'system:check')$q$);
DELETE FROM contracts WHERE contract_id = '88888888-8888-8888-8888-88888888888c';

-- 09: „Je Kind ein laufender Hortvertrag, nie zwei nebeneinander" — der Fall,
-- den `ix_contracts_running` nicht sehen konnte, weil die beiden Verträge
-- verschieden lang laufen: einer ab dem 1. August bis zum 31. Juli, einer ab
-- dem 1. Oktober bis auf Weiteres. Überlappende Laufzeiten, zwei Beitragslagen,
-- und die eine Optigem-Aufgabe je Kind trüge danach nur einen der beiden.
-- `ex_contracts_care_period` rechnet über den Zeitraum und weist ihn ab.
INSERT INTO contracts (contract_id, child_id, contract_type, contract_text_id, released_at,
                       released_by, admission_date, runs_until, may_walk_home_alone, created_by)
    VALUES ('88888888-8888-8888-8888-88888888888a',
            '44444444-4444-4444-4444-444444444444', 'care', 2,
            now(), 'entra:hortleitung', DATE '2026-08-01', DATE '2027-07-31',
            false, 'system:check');
SELECT pg_temp.expect_reject(
    '09 — zweiter Hortvertrag mit anderer Laufzeit, aber überschneidendem Zeitraum',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id, released_at,
                              released_by, admission_date, may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'care', 2,
               now(), 'entra:hortleitung', DATE '2026-10-01', false, 'system:check')$q$);
-- Derselbe Vertrag einen Tag nach dem Ende des ersten ist keine Überschneidung
-- — es ist der Klasse-5-Fall aus 04 und bleibt zulässig.
SELECT pg_temp.expect_accept(
    '04 — Hortvertrag, der zum 1. August nach dem Ende des alten aufnimmt',
    $q$INSERT INTO contracts (contract_id, child_id, contract_type, contract_text_id,
                              released_at, released_by, admission_date,
                              may_walk_home_alone, created_by)
       VALUES ('88888888-8888-8888-8888-88888888888b',
               '44444444-4444-4444-4444-444444444444', 'care', 2,
               now(), 'entra:hortleitung', DATE '2027-08-01', false, 'system:check')$q$);
DELETE FROM contracts WHERE contract_id IN ('88888888-8888-8888-8888-88888888888a',
                                            '88888888-8888-8888-8888-88888888888b');

-- „Ein eigenes Kind, das die Schule verlässt, verliert den Hortvertrag nicht"
-- — Schul- und Hortvertrag laufen nebeneinander.
SELECT pg_temp.expect_accept(
    '09 — Schul- und Hortvertrag desselben Kindes nebeneinander',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id,
                              may_walk_home_alone, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'care', 2, false, 'system:check')$q$);

-- 09: „Je Kind, ob es den Heimweg allein antreten darf (Pflicht, Ja oder Nein)"
-- — am Hortvertrag ist die Angabe Pflicht, und die Zeile entsteht erst mit dem
-- vollständig ausgefüllten Antrag (09, Schritt 4).
SELECT pg_temp.expect_reject(
    '09 — Hortvertrag ohne die Heimweg-Angabe',
    $q$INSERT INTO contracts (child_id, contract_type, contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'care', 2, 'system:check')$q$);

-- 08: „Vor der Freigabe entsteht kein Dokument."
INSERT INTO sharepoint_libraries (sharepoint_library_id, code, name, graph_drive_id, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'generated', 'Erzeugt', 'b!x', 'system:check');
INSERT INTO document_types (document_type_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'school_contract', 'Schulvertrag', 'system:check');
INSERT INTO documents (document_id, child_id, document_type_id, sharepoint_library_id,
                       graph_item_id, filed_at, created_by)
    VALUES ('99999999-9999-9999-9999-999999999991',
            '44444444-4444-4444-4444-444444444444', 1, 1, '01ABC', now(), 'system:check');
SELECT pg_temp.expect_reject(
    '08 — Vertragsdokument ohne Freigabe',
    $q$UPDATE contracts SET document_id = '99999999-9999-9999-9999-999999999991'
        WHERE contract_id = '88888888-8888-8888-8888-888888888881'$q$);

SELECT pg_temp.expect_reject(
    '08 — Freigabe ohne Namen dahinter',
    $q$UPDATE contracts SET released_at = now()
        WHERE contract_id = '88888888-8888-8888-8888-888888888881'$q$);

SELECT pg_temp.expect_accept(
    '08 — Freigabe, dann Dokument samt Prüfsumme',
    $q$UPDATE contracts SET released_at = now(), released_by = 'entra:schulleitung',
                            document_id = '99999999-9999-9999-9999-999999999991',
                            document_checksum = 'sha256:abc', runs_until = DATE '2031-07-31'
        WHERE contract_id = '88888888-8888-8888-8888-888888888881'$q$);

-- 08/04: der Viertklässler in die eigene Realschule hat von der Freigabe im
-- Winter bis zum 31. Juli zwei Schulverträge — der alte trägt sein Ende in
-- `runs_until`, das `end_date` setzt erst der Jahreslauf am 1. August.
SELECT pg_temp.expect_accept(
    '08 — zweiter Schulvertrag beim Wechsel in die eigene Realschule',
    $q$INSERT INTO applications (application_id, child_id, school_branch_id,
                                 target_grade_level, first_grade_level, final_grade_level,
                                 target_school_year, source,
                                 submitted_at, filling_person_id,
                                 application_status_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777773',
               '44444444-4444-4444-4444-444444444444', 2, 5, 5, 10, 2027,
               'pre_registration', now(), '22222222-2222-2222-2222-222222222222',
               1, 'system:check');
       INSERT INTO contracts (contract_id, child_id, contract_type, application_id,
                              contract_text_id, released_at, released_by, runs_until,
                              created_by)
       VALUES ('88888888-8888-8888-8888-888888888883',
               '44444444-4444-4444-4444-444444444444', 'school',
               '77777777-7777-7777-7777-777777777773', 2,
               now(), 'entra:schulleitung', DATE '2033-07-31', 'system:check')$q$);

-- Beide tragen ihren „31. Juli des Schuljahres, in dem die Schulart endet"
-- (08) — der alte 2031, der neue 2033. Ein dritter, der bis zum selben Tag
-- läuft wie einer von beiden, ist derselbe Vertrag zweimal.
SELECT pg_temp.expect_reject(
    '08 — dritter Schulvertrag mit derselben Laufzeit daneben',
    $q$INSERT INTO contracts (child_id, contract_type, application_id, contract_text_id,
                              released_at, released_by, runs_until, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'school',
               '77777777-7777-7777-7777-777777777771', 2,
               now(), 'entra:schulleitung', DATE '2033-07-31', 'system:check')$q$);

-- Und ohne Laufzeit — „bis auf Weiteres" — genauso, sobald ein zweiter
-- danebensteht, der ebenfalls keine trägt (NULLS NOT DISTINCT).
SELECT pg_temp.expect_accept(
    '08 — erster Schulvertrag bis auf Weiteres',
    $q$INSERT INTO contracts (contract_id, child_id, contract_type, application_id,
                              contract_text_id, released_at, released_by, created_by)
       VALUES ('88888888-8888-8888-8888-888888888884',
               '44444444-4444-4444-4444-444444444444', 'school',
               '77777777-7777-7777-7777-777777777771', 2,
               now(), 'entra:schulleitung', 'system:check')$q$);
SELECT pg_temp.expect_reject(
    '08 — zweiter Schulvertrag bis auf Weiteres daneben',
    $q$INSERT INTO contracts (child_id, contract_type, application_id, contract_text_id,
                              released_at, released_by, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'school',
               '77777777-7777-7777-7777-777777777771', 2,
               now(), 'entra:schulleitung', 'system:check')$q$);
DELETE FROM contracts WHERE contract_id = '88888888-8888-8888-8888-888888888884';

DELETE FROM contracts WHERE contract_id = '88888888-8888-8888-8888-888888888883';
DELETE FROM applications WHERE application_id = '77777777-7777-7777-7777-777777777773';

SELECT pg_temp.expect_reject(
    '09 — Vertragsende ohne Grund',
    $q$UPDATE contracts SET end_date = DATE '2027-07-31'
        WHERE contract_id = '88888888-8888-8888-8888-888888888882'$q$);

-- 08: „Nehmen den Platz an oder lehnen ab" — genau eine der beiden Antworten.
SELECT pg_temp.expect_reject(
    '08 — Platzantwort, die weder Annahme noch Ablehnung ist',
    $q$INSERT INTO contract_responses (contract_id, person_id, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               '22222222-2222-2222-2222-222222222222', 'system:check')$q$);

INSERT INTO contract_responses (contract_id, person_id, accepted_at, created_by)
    VALUES ('88888888-8888-8888-8888-888888888881',
            '22222222-2222-2222-2222-222222222222', now(), 'system:check');
SELECT pg_temp.expect_reject(
    '08 — zweite Antwort derselben Person zu demselben Vertrag',
    $q$INSERT INTO contract_responses (contract_id, person_id, declined_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               '22222222-2222-2222-2222-222222222223', now(), 'system:check');
       INSERT INTO contract_responses (contract_id, person_id, declined_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

-- 08: „Dies ist der einzige Moment, in dem die Familie diese Angaben noch
-- einmal vollständig vor sich hat" — durchgesehen hat nur, wer angenommen hat.
INSERT INTO contract_responses (contract_id, person_id, declined_at, created_by)
    VALUES ('88888888-8888-8888-8888-888888888881',
            '22222222-2222-2222-2222-222222222223', now(), 'system:check');
SELECT pg_temp.expect_reject(
    '08 — Durchsicht bestätigt, ohne den Platz angenommen zu haben',
    $q$UPDATE contract_responses SET data_reviewed_at = now()
        WHERE person_id = '22222222-2222-2222-2222-222222222223'$q$);

SELECT pg_temp.expect_accept(
    '08 — Durchsicht der Angaben nach der Platzannahme',
    $q$UPDATE contract_responses SET data_reviewed_at = now()
        WHERE person_id = '22222222-2222-2222-2222-222222222222'$q$);

-- Q2: die Unterschrift hängt am Vertragsvorgang.
SELECT pg_temp.expect_accept(
    'Q2 — Unterschrift am Vertragsvorgang',
    $q$INSERT INTO signatures (contract_id, person_id, signed_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — Unterschrift auf einen Vorgang, den es nicht gibt',
    $q$INSERT INTO signatures (contract_id, person_id, signed_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888889',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — dieselbe Person unterschreibt denselben Vorgang zweimal',
    $q$INSERT INTO signatures (contract_id, person_id, signed_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — unbekanntes Signaturniveau',
    $q$INSERT INTO signatures (contract_id, person_id, signed_at, signature_level, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               '22222222-2222-2222-2222-222222222223', now(), 'handwritten', 'system:check')$q$);

-- 08: „eine Zeile ohne Bild heißt ‚unterschrieben, Bild abgeräumt' — ‚hat nicht
-- unterschrieben' sagt die fehlende Zeile."
SELECT pg_temp.expect_accept(
    'Q2 — Signatur ohne Bild nach Abschluss des Vorgangs',
    $q$INSERT INTO signatures (contract_id, person_id, signed_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

-- 08: „der Vertrag darunter bleibt unberührt" — eine Unterschrift gilt dem
-- Vertragsvorgang oder dem Mandat, nie beidem.
INSERT INTO sepa_mandates (sepa_mandate_id, child_id, account_holder_person_id, iban,
                           credit_institution, mandate_reference, created_by)
    VALUES ('99999999-9999-9999-9999-999999999991',
            '44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            'DE02120300000000202051', 'Musterbank', 'WB-0001', 'system:check');
SELECT pg_temp.expect_reject(
    '08 — Unterschrift, die zugleich Vertrag und Mandat trägt',
    $q$INSERT INTO signatures (contract_id, sepa_mandate_id, person_id, signed_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               '99999999-9999-9999-9999-999999999991',
               '22222222-2222-2222-2222-222222222223', now(), 'system:check')$q$);

-- hebel.md, „Geld im System": „das Schulgeld je Schulform — Grundschule und
-- Realschule kosten verschieden", je Wert ein Gültigkeitstag. Dazu der
-- Geschwisterrang aus der Preisliste der Schule: 145 / 125 / 105 / 0 € in der
-- Grundschule, 150 / 130 / 110 / 0 € in der Realschule.
SELECT pg_temp.expect_accept(
    'hebel.md — Schulgeld je Schulform und Geschwisterrang',
    $q$INSERT INTO tuition_fees (school_branch_id, sibling_rank, valid_from,
                                 monthly_amount_cents, created_by)
       VALUES (1, 1, DATE '2026-08-01', 14500, 'system:check'),
              (1, 2, DATE '2026-08-01', 12500, 'system:check'),
              (1, 3, DATE '2026-08-01', 10500, 'system:check'),
              (1, 4, DATE '2026-08-01',     0, 'system:check'),
              (2, 1, DATE '2026-08-01', 15000, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    'hebel.md — angekündigte Erhöhung neben dem geltenden Schulgeld',
    $q$INSERT INTO tuition_fees (school_branch_id, sibling_rank, valid_from,
                                 monthly_amount_cents, created_by)
       VALUES (1, 1, DATE '2027-08-01', 15500, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — zweites Schulgeld derselben Schulform und desselben Rangs zum selben Tag',
    $q$INSERT INTO tuition_fees (school_branch_id, sibling_rank, valid_from,
                                 monthly_amount_cents, created_by)
       VALUES (1, 1, DATE '2026-08-01', 23000, 'system:check')$q$);

-- In den Vertrag geht die vollständige Staffel und nicht der eine Betrag, der
-- beim Unterschreiben passte. Dass eine Staffel vollständig ist, kann kein
-- Constraint sagen — sie steht über vier Zeilen, deren Gültigkeitstage
-- auseinanderfallen dürfen. Die Gegenprobe hält die Auslassung fest: eine halbe
-- Liste läuft hier durch, vollständig macht sie die Anwendung, die das Dokument
-- baut.
SELECT pg_temp.expect_accept(
    '08 — halbe Staffel einer Schulart (die Vollständigkeit prüft die Anwendung)',
    $q$INSERT INTO tuition_fees (school_branch_id, sibling_rank, valid_from,
                                 monthly_amount_cents, created_by)
       VALUES (2, 2, DATE '2026-08-01', 13000, 'system:check')$q$);

-- Das vierte und jedes weitere Kind ist der letzte Rang („ab dem vierten Kind
-- beitragsfrei", 08); einen fünften Betrag gibt es nicht, sonst stünde
-- derselbe Nachlass an zwei Stellen.
SELECT pg_temp.expect_reject(
    '08 — Schulgeld für einen fünften Rang',
    $q$INSERT INTO tuition_fees (school_branch_id, sibling_rank, valid_from,
                                 monthly_amount_cents, created_by)
       VALUES (1, 5, DATE '2026-08-01', 0, 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — Betreuungsmodule
-- ---------------------------------------------------------------------------

INSERT INTO care_module_agreements (care_module_agreement_id, contract_id, created_by)
    VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
            '88888888-8888-8888-8888-888888888882', 'system:check');

SELECT pg_temp.expect_reject(
    '09 — Anlage mit Geltungsbeginn, aber ohne Freigabe',
    $q$UPDATE care_module_agreements SET valid_from = DATE '2026-09-01'
        WHERE care_module_agreement_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'$q$);

SELECT pg_temp.expect_accept(
    '09 — Anlage mit Freigabe und Geltungsbeginn',
    $q$UPDATE care_module_agreements
          SET valid_from = DATE '2026-09-01', released_at = now(),
              released_by = 'entra:hortleitung'
        WHERE care_module_agreement_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'$q$);

-- 09, Schritt 6: „Eine Anpassung beantragen die Eltern im Portal und
-- unterschreiben die neue Modulanlage …, die Hortleitung gibt sie frei." Ohne
-- diesen Weg gäbe es im Modell keine Anpassung.
SELECT pg_temp.expect_accept(
    '09 — beantragte Anlage neben der laufenden',
    $q$INSERT INTO care_module_agreements (care_module_agreement_id, contract_id, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
               '88888888-8888-8888-8888-888888888882', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — zweite freigegebene Anlage an demselben Vertrag',
    $q$UPDATE care_module_agreements
          SET valid_from = DATE '2027-02-01', released_at = now(),
              released_by = 'entra:hortleitung'
        WHERE care_module_agreement_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3'$q$);

DELETE FROM care_module_agreements
    WHERE care_module_agreement_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3';

-- „die vorigen Anlagen bleiben in der Akte" (09).
SELECT pg_temp.expect_accept(
    '09 — neue Anlage, nachdem die vorige beendet wurde',
    $q$UPDATE care_module_agreements SET valid_until = DATE '2027-01-31'
         WHERE care_module_agreement_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1';
       INSERT INTO care_module_agreements (care_module_agreement_id, contract_id, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
               '88888888-8888-8888-8888-888888888882', 'system:check')$q$);

-- 09: „Eine Anpassung … unterschreiben die neue Modulanlage — der Vertrag
-- darunter bleibt stehen." Dieselbe Person unterschreibt also zweimal am selben
-- Vertrag: einmal ihn, einmal seine Anlage.
SELECT pg_temp.expect_accept(
    '09 — Unterschrift unter der Modulanlage neben der unter dem Vertrag',
    $q$INSERT INTO signatures (contract_id, care_module_agreement_id, person_id,
                              signed_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

-- 09: „der Vertrag darunter bleibt stehen" — eine Modulanlage ohne ihren
-- Vertrag gibt es nicht; vorher trug das `contract_id NOT NULL`. Der Anker des
-- Kindes steht mit, damit `ck_signatures_subject` nicht vorher zuschlägt und
-- die Probe die Regel belegt, die sie nennt.
SELECT pg_temp.expect_reject(
    '09 — Unterschrift unter einer Anlage ohne ihren Vertrag',
    $q$INSERT INTO signatures (care_module_agreement_id, child_id, person_id,
                              signed_at, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
               '44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222223', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — dieselbe Person unterschreibt dieselbe Anlage zweimal',
    $q$INSERT INTO signatures (contract_id, care_module_agreement_id, person_id,
                              signed_at, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

-- grenzkarte.md: „Gebucht wird Modul × Wochentag."
INSERT INTO care_module_bookings (care_module_agreement_id, care_module_id, weekday, created_by)
    VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 1, 1, 'system:check');
SELECT pg_temp.expect_reject(
    '09 — dasselbe Modul zweimal am selben Wochentag',
    $q$INSERT INTO care_module_bookings (care_module_agreement_id, care_module_id, weekday, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 1, 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — Buchung am Samstag',
    $q$INSERT INTO care_module_bookings (care_module_agreement_id, care_module_id, weekday, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 1, 6, 'system:check')$q$);

-- „mehrere Module nebeneinander sind der Normalfall" (09).
SELECT pg_temp.expect_accept(
    '09 — zweites Modul am selben Wochentag',
    $q$INSERT INTO care_module_bookings (care_module_agreement_id, care_module_id, weekday, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 2, 1, 'system:check')$q$);

-- 09: „je Modul also fünf Beträge, einer je Tageszahl".
INSERT INTO care_module_prices (care_module_id, weekday_count, valid_from,
                                monthly_amount_cents, created_by)
    VALUES (1, 1, DATE '2026-08-01', 3000, 'system:check');
SELECT pg_temp.expect_reject(
    '09 — Preis für sechs Wochentage',
    $q$INSERT INTO care_module_prices (care_module_id, weekday_count, valid_from,
                                       monthly_amount_cents, created_by)
       VALUES (1, 6, DATE '2026-08-01', 9000, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — derselbe Modulpreis zweimal zum selben Gültigkeitstag',
    $q$INSERT INTO care_module_prices (care_module_id, weekday_count, valid_from,
                                       monthly_amount_cents, created_by)
       VALUES (1, 1, DATE '2026-08-01', 3500, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — Modul mit Stufenbeschränkung, aber ohne Schulart',
    $q$INSERT INTO care_modules (code, name, restricted_to_grade_level, created_by)
       VALUES ('bad', 'Unsinn', 5, 'system:check')$q$);

-- Q3: „geht mit dem Vorgang, an dem die Zahlung hängt" — die Bewerbung nimmt
-- die Anmeldegebühr mit, statt von ihr festgehalten zu werden. Der Vertrag
-- darüber trägt seine eigene, noch offene Frist und geht ihr voraus.
SELECT pg_temp.expect_accept(
    'Q3 — die Anmeldegebühr geht mit ihrer Bewerbung',
    $q$DELETE FROM contracts    WHERE application_id = '77777777-7777-7777-7777-777777777772';
       DELETE FROM applications WHERE application_id = '77777777-7777-7777-7777-777777777772'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM payments WHERE application_id IS NOT NULL) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Anmeldegebühr überlebt ihre Bewerbung';
    END IF;
    RAISE NOTICE 'ok (erlaubt): Q3 — keine Zahlung überlebt ihren Vorgang';
END $$;

-- Die übrigen Stufen dieser Domäne im Lauf aus 17; die Reihenfolge über alle
-- Domänen steht im Kopf von querschnitt-schema.sql.

-- Stufe 1: „`contracts`, dann `applications` — der Vertrag hält seine Bewerbung
-- fest und geht ihr voraus." Der Schulvertrag der verbliebenen Bewerbung, damit
-- die Kette etwas zu halten hat.
INSERT INTO contracts (contract_id, child_id, contract_type, application_id,
                       contract_text_id, created_by)
    VALUES ('88888888-8888-8888-8888-888888888889',
            '44444444-4444-4444-4444-444444444444', 'school',
            '77777777-7777-7777-7777-777777777771', 1, 'system:check');
SELECT pg_temp.expect_reject(
    '17 — Bewerbung gelöscht, während ihr Vertrag sie noch festhält',
    $q$DELETE FROM applications WHERE application_id = '77777777-7777-7777-7777-777777777771'$q$);

-- „Löschanker: die offene Aufbewahrungsfrist für Vertragsdaten (03)" — der
-- Vertrag nimmt Antworten, Unterschriften und Modulanlagen mit.
SELECT pg_temp.expect_accept(
    '08/09 — der Vertrag geht, Antworten, Unterschriften und Modulanlagen mit ihm',
    $q$DELETE FROM contracts$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM contract_responses) OR EXISTS (SELECT 1 FROM care_module_agreements)
       OR EXISTS (SELECT 1 FROM care_module_bookings)
       OR EXISTS (SELECT 1 FROM signatures WHERE contract_id IS NOT NULL) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — etwas überlebt seinen Vertragsvorgang';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 08/09 — nichts überlebt seinen Vertragsvorgang';
END $$;

-- 07: „die Frist beginnt mit dem hier gesetzten Ende" — die Bewerbung nimmt
-- Angebote und Zahlung mit.
SELECT pg_temp.expect_accept(
    '07 — nach dem Vertrag geht die Bewerbung, Angebote und Zahlung mit ihr',
    $q$DELETE FROM applications$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM application_offers) OR EXISTS (SELECT 1 FROM payments) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Angebot oder Zahlung überlebt ihre Bewerbung';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 07 — weder Angebot noch Zahlung überlebt seine Bewerbung';
END $$;

-- Stufe 1, der Rest: „`documents` und `child_file_folders` …, `sepa_mandates`"
-- — auch sie halten das Kind fest, und dieses Skript legt ein Mandat an.
SELECT pg_temp.expect_reject(
    '17 — Kind gelöscht, während sein SEPA-Mandat es noch festhält',
    $q$DELETE FROM children$q$);

-- Stufe 2: erst jetzt lässt sich das Kind löschen — vorher hielten es
-- `fk_applications_child`, `fk_contracts_child` und `fk_sepa_mandates_child`
-- fest, jeder auf seiner eigenen Frist.
SELECT pg_temp.expect_accept(
    '17 — nach allen Vorgängen am Kind geht das Kind',
    $q$DELETE FROM documents;
       DELETE FROM child_file_folders;
       DELETE FROM sepa_mandates;
       DELETE FROM children$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM signatures) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Unterschrift überlebt ihr Kind';
    END IF;
    -- Anmeldetage, Anmeldefenster und die Wertelisten tragen keinen
    -- Personenbezug und keinen Anker.
    IF NOT EXISTS (SELECT 1 FROM admission_days) OR NOT EXISTS (SELECT 1 FROM tuition_fees) THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — Anmeldetag oder Schulgeldstaffel ging mit dem Kind';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 17 — die Domäne ist leer bis auf das, was keinen Anker hat';
END $$;

DO $$ BEGIN RAISE NOTICE 'anmeldung-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
