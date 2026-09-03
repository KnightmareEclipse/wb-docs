-- Prüfskript zu akademie-schema.sql.
--
-- Sollstand: 7 Tabellen — academy_categories, academy_offerings,
-- academy_offering_leads, academy_offering_audiences, academy_approvers,
-- academy_cost_coverage_codes und academy_registrations. Dazu zwei partielle
-- Unique-Indizes über die nicht abgemeldeten Anmeldungen (je einer für den
-- Kinder- und den Erwachsenen-Zweig), ein Lese-Index auf die Teilnehmerliste
-- und der eine Trigger, der Platzzahl und fremde Kinder abweist. Dazu die
-- Fremdschlüssel von Q3 und Q5 auf diese Domäne: die Zahlung der Familie ohne
-- SEPA-Mandat und die Aufgabe bei der Buchhaltung, beide mit Cascade.
--
-- Setzt stammdaten-schema.sql, querschnitt-schema.sql und anmeldung-schema.sql
-- voraus:
--   psql -v ON_ERROR_STOP=1 -f akademie-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY[
        'academy_categories', 'academy_offerings', 'academy_offering_leads',
        'academy_offering_audiences', 'academy_approvers',
        'academy_cost_coverage_codes', 'academy_registrations'
    ]) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 7 Tabellen vorhanden';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_academy_offerings', 'pk_academy_registrations',
        'fk_academy_offerings_category', 'uq_academy_offerings_id_branch',
        'fk_academy_registrations_offering', 'fk_academy_registrations_child',
        'fk_academy_registrations_person', 'fk_academy_registrations_coverage_code',
        'fk_academy_registrations_terms',
        'fk_academy_offering_leads_offering', 'fk_academy_offering_leads_employee',
        'uq_academy_offering_leads', 'uq_academy_approvers',
        'uq_academy_offering_audiences', 'ck_academy_offering_audiences_form',
        'ck_academy_offerings_period', 'ck_academy_offerings_window',
        'ck_academy_offerings_places', 'ck_academy_offerings_deadline',
        'ck_academy_offerings_decision', 'ck_academy_offerings_returned',
        'ck_academy_offerings_cancellation',
        'ck_academy_registrations_participant', 'ck_academy_registrations_payment_mode',
        'ck_academy_registrations_coverage', 'ck_academy_registrations_recorded',
        'ck_academy_registrations_retained', 'ck_academy_registrations_declared_by',
        'ck_academy_registrations_recorded_by',
        'ck_academy_offerings_surcharge_label',
        'fk_payments_academy_registration', 'fk_sync_tasks_academy_registration'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;
    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_academy_registrations_active_child',
                      'ix_academy_registrations_active_person',
                      'ix_academy_registrations_offering',
                      'ix_sync_tasks_open_academy']) AS i
    WHERE to_regclass('public.' || i) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Indizes: %', missing;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger
                    WHERE tgname = 'trg_academy_registrations_admission') THEN
        RAISE EXCEPTION 'Der Trigger fehlt — Platzzahl und fremde Kinder wären ungeprüft';
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints, Indizes und der Trigger vorhanden';
END $$;

-- 21: „Eine Angabe ‚Art des Angebots' gibt es deshalb nicht … wer die drei Fälle
-- unterscheiden will, liest den Zeitraum." Und: „angemeldet wird zum Angebot als
-- Ganzem" — eine Terminliste hätte nichts, wozu man sich einzeln anmeldete.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'academy_offerings'
                  AND column_name IN ('offering_type', 'offering_type_id', 'kind')) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — das Angebot trägt wieder eine Angebotsart';
    END IF;
    IF to_regclass('public.academy_offering_sessions') IS NOT NULL
       OR to_regclass('public.academy_offering_dates') IS NOT NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — es gibt wieder eine Terminliste';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 21 — weder Angebotsart noch Terminliste';
END $$;

-- Q3/Q5: beide Bezüge stehen als Spalte an `payments` und `sync_tasks`
-- (querschnitt-schema.sql) — nicht in einer zweiten Zahlungs- oder
-- Aufgabentabelle hier (grenzkarte.md, Q3).
DO $$
BEGIN
    IF to_regclass('public.academy_payments') IS NOT NULL
       OR to_regclass('public.academy_tasks') IS NOT NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Zahlung oder Aufgabe stehen ein zweites Mal';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): Q3/Q5 — keine zweite Zahlungs- oder Aufgabentabelle';
END $$;

-- 21, Betreiber 03.09.2026: „Die Werteliste wird gebaut und bleibt zunächst
-- leer." Das ist keine Lücke, sondern der Stand — und es heißt, dass das erste
-- Angebot die erste Kategorie braucht.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM academy_categories) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Kategorienliste ist nicht leer';
    END IF;
    RAISE NOTICE 'ok: 21 — die Kategorienliste steht und ist leer';
END $$;

CREATE FUNCTION pg_temp.expect_reject(rule text, stmt text) RETURNS void AS $$
BEGIN
    EXECUTE stmt;
    RAISE EXCEPTION 'REGEL NICHT GEBAUT — durchgelassen: %', rule;
EXCEPTION
    WHEN check_violation OR foreign_key_violation OR unique_violation
         OR not_null_violation THEN
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
INSERT INTO houses (house_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'school', 'Schule', 'system:check');
INSERT INTO school_branches (school_branch_id, code, name, first_grade_level,
                             final_grade_level, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'GS', 'Grundschule', 1, 4, 'system:check');
INSERT INTO classes (class_id, school_branch_id, start_school_year, stream, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 1, 2026, 'a', 'system:check');

INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('11111111-1111-1111-1111-111111111101', 'Eins',  'Schulkind',  'system:check'),
    ('11111111-1111-1111-1111-111111111102', 'Zwei',  'Fremdkind',  'system:check'),
    ('11111111-1111-1111-1111-111111111103', 'Drei',  'Schulkind',  'system:check'),
    ('11111111-1111-1111-1111-111111111104', 'Vier',  'Schulkind',  'system:check'),
    ('11111111-1111-1111-1111-111111111105', 'Fünf',  'Hortkind',   'system:check'),
    ('11111111-1111-1111-1111-111111111201', 'Leitet', 'Kurs',      'system:check'),
    ('11111111-1111-1111-1111-111111111202', 'Gibt',   'Frei',      'system:check'),
    ('11111111-1111-1111-1111-111111111203', 'Erwachsen', 'Person', 'system:check');

INSERT INTO families (family_id, created_by)
    VALUES ('22222222-2222-2222-2222-222222222201', 'system:check');

-- Drei eingeschriebene Kinder, ein schulfremdes und eines, das allein über den
-- Hortvertrag im Haus ist — „bekannt ist ein Kind, das eingeschrieben ist (08)
-- oder einen laufenden Hortvertrag hat (09)".
INSERT INTO children (child_id, person_id, family_id, birth_date, school_branch_id,
                      grade_level, first_grade_level, final_grade_level, entry_date,
                      created_by) VALUES
    ('33333333-3333-3333-3333-333333333301', '11111111-1111-1111-1111-111111111101',
     '22222222-2222-2222-2222-222222222201', DATE '2018-05-01', 1, 2, 1, 4,
     DATE '2026-08-01', 'system:check'),
    ('33333333-3333-3333-3333-333333333303', '11111111-1111-1111-1111-111111111103',
     '22222222-2222-2222-2222-222222222201', DATE '2018-06-01', 1, 2, 1, 4,
     DATE '2026-08-01', 'system:check'),
    ('33333333-3333-3333-3333-333333333304', '11111111-1111-1111-1111-111111111104',
     '22222222-2222-2222-2222-222222222201', DATE '2018-07-01', 1, 2, 1, 4,
     DATE '2026-08-01', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by) VALUES
    ('33333333-3333-3333-3333-333333333302', '11111111-1111-1111-1111-111111111102',
     '22222222-2222-2222-2222-222222222201', DATE '2018-08-01', 'system:check'),
    ('33333333-3333-3333-3333-333333333305', '11111111-1111-1111-1111-111111111105',
     '22222222-2222-2222-2222-222222222201', DATE '2018-09-01', 'system:check');

INSERT INTO employees (employee_id, person_id, house_id, created_by) VALUES
    ('44444444-4444-4444-4444-444444444401', '11111111-1111-1111-1111-111111111201',
     1, 'system:check'),
    ('44444444-4444-4444-4444-444444444402', '11111111-1111-1111-1111-111111111202',
     1, 'system:check');

INSERT INTO contract_texts (contract_text_id, code, valid_from, body, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'academy_cancellation_cooking', DATE '2026-01-01',
     'bis 9 Uhr am Kurstag kostenlos, danach die halbe Kursgebühr', 'system:check');

INSERT INTO contracts (contract_id, child_id, contract_type, contract_text_id,
                       may_walk_home_alone, admission_date, released_at, released_by,
                       created_by)
    VALUES ('88888888-8888-8888-8888-888888888801',
            '33333333-3333-3333-3333-333333333305', 'care', 1, false,
            DATE '2026-08-01', now(), 'entra:hortleitung', 'system:check');

INSERT INTO academy_categories (academy_category_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'cooking', 'Kochen', 'entra:geschaeftsfuehrung');

-- ---------------------------------------------------------------------------
-- Gegenproben — das Angebot
-- ---------------------------------------------------------------------------

-- 21: „Ein Angebot trägt damit eine Kategorie" — Pflicht, auch solange die
-- Liste leer ist.
SELECT pg_temp.expect_reject(
    '21 — Angebot ohne Kategorie',
    $q$INSERT INTO academy_offerings (title, starts_on, ends_on, places, amount_cents,
                                      cancellation_terms_code, registration_opens_at,
                                      created_by)
       VALUES ('Chor', DATE '2027-02-01', DATE '2027-07-31', 12, 3000,
               'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
               'entra:lehrkraft')$q$);

SELECT pg_temp.expect_reject(
    '21 — Angebot, dessen Zeitraum rückwärts läuft',
    $q$INSERT INTO academy_offerings (academy_category_id, title, starts_on, ends_on,
                                      places, amount_cents, cancellation_terms_code,
                                      registration_opens_at, created_by)
       VALUES (1, 'Chor', DATE '2027-07-31', DATE '2027-02-01', 12, 3000,
               'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
               'entra:lehrkraft')$q$);

SELECT pg_temp.expect_reject(
    '21 — Anmeldefenster, das vor seinem Beginn schließt',
    $q$INSERT INTO academy_offerings (academy_category_id, title, starts_on, ends_on,
                                      places, amount_cents, cancellation_terms_code,
                                      registration_opens_at, registration_closes_at,
                                      created_by)
       VALUES (1, 'Chor', DATE '2027-02-01', DATE '2027-07-31', 12, 3000,
               'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
               TIMESTAMPTZ '2026-12-01 08:00+01', 'entra:lehrkraft')$q$);

SELECT pg_temp.expect_reject(
    '21 — Angebot ohne Platz',
    $q$INSERT INTO academy_offerings (academy_category_id, title, starts_on, ends_on,
                                      places, amount_cents, cancellation_terms_code,
                                      registration_opens_at, created_by)
       VALUES (1, 'Chor', DATE '2027-02-01', DATE '2027-07-31', 0, 3000,
               'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
               'entra:lehrkraft')$q$);

-- 21: „bis 9 Uhr am Kurstag kostenlos" ist null Tage und eine Uhrzeit; eine
-- Uhrzeit ohne Tageszahl beschriebe eine Frist, die es nicht gibt.
SELECT pg_temp.expect_reject(
    '21 — Absagefrist als Uhrzeit ohne Tageszahl',
    $q$INSERT INTO academy_offerings (academy_category_id, title, starts_on, ends_on,
                                      places, amount_cents, cancellation_terms_code,
                                      cancellation_deadline_time,
                                      registration_opens_at, created_by)
       VALUES (1, 'Chor', DATE '2027-02-01', DATE '2027-07-31', 12, 3000,
               'academy_cancellation_cooking', TIME '09:00',
               TIMESTAMPTZ '2027-01-01 08:00+01', 'entra:lehrkraft')$q$);

-- 21: Ein Zusatzbetrag ohne Etikett stünde in der Ausschreibung, ohne dass
-- jemand ihn erklären könnte — und ein Etikett ohne Betrag benennt nichts.
SELECT pg_temp.expect_reject(
    '21 — Zusatzbetrag ohne Etikett',
    $q$INSERT INTO academy_offerings (academy_category_id, title, starts_on, ends_on,
                                      places, amount_cents, surcharge_cents,
                                      cancellation_terms_code, registration_opens_at,
                                      created_by)
       VALUES (1, 'Chor', DATE '2027-02-01', DATE '2027-07-31', 12, 3000, 500,
               'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
               'entra:lehrkraft')$q$);

SELECT pg_temp.expect_reject(
    '21 — Etikett ohne Zusatzbetrag',
    $q$INSERT INTO academy_offerings (academy_category_id, title, starts_on, ends_on,
                                      places, amount_cents, surcharge_label,
                                      cancellation_terms_code, registration_opens_at,
                                      created_by)
       VALUES (1, 'Chor', DATE '2027-02-01', DATE '2027-07-31', 12, 3000, 'Noten',
               'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
               'entra:lehrkraft')$q$);

-- Das Angebot, an dem die Anmeldungen hängen: drei Plätze, fremde Kinder nicht
-- zugelassen („Der Chor ist für die eigenen Kinder"), Absagefrist null Tage und
-- 9 Uhr, dazu der Zusatzbetrag samt Etikett und das enthaltene Mittagessen.
SELECT pg_temp.expect_accept(
    '21 — Angebot mit Kategorie, Absagefrist, Zusatzbetrag und Mittagessen',
    $q$INSERT INTO academy_offerings (academy_offering_id, academy_category_id, title,
                                      description, starts_on, ends_on, schedule_text,
                                      allows_external_children, places, amount_cents,
                                      surcharge_cents, surcharge_label, includes_lunch,
                                      cancellation_deadline_days, cancellation_deadline_time,
                                      cancellation_terms_code, registration_opens_at,
                                      created_by)
       VALUES ('55555555-5555-5555-5555-555555555501', 1, 'Kochwerkstatt',
               'Wir backen Brot', DATE '2027-04-10', DATE '2027-04-10',
               'samstags 10–14 Uhr', false, 3, 3000, 500, 'Lebensmittel', true, 0,
               TIME '09:00', 'academy_cancellation_cooking',
               TIMESTAMPTZ '2027-01-01 08:00+01', 'entra:hauswirtschaftsleitung')$q$);

-- „Die Kochwerkstatt ist für alle" — dasselbe Häkchen, anderer Wert; ein Platz.
INSERT INTO academy_offerings (academy_offering_id, academy_category_id, title,
                               starts_on, ends_on, allows_external_children, places,
                               amount_cents, cancellation_deadline_days,
                               cancellation_terms_code, registration_opens_at, created_by)
    VALUES ('55555555-5555-5555-5555-555555555502', 1, 'Offene Kochwerkstatt',
            DATE '2027-05-08', DATE '2027-05-08', true, 1, 3000, 3,
            'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
            'entra:hauswirtschaftsleitung');

-- Der Erwachsenen-Zweig: „Seminarangebote für Erwachsene" (03.09.2026).
INSERT INTO academy_offerings (academy_offering_id, academy_category_id, for_adults,
                               title, starts_on, ends_on, places, amount_cents,
                               cancellation_terms_code, registration_opens_at, created_by)
    VALUES ('55555555-5555-5555-5555-555555555503', 1, true, 'Seminar Brotbacken',
            DATE '2027-06-05', DATE '2027-06-05', 1, 4500,
            'academy_cancellation_cooking', TIMESTAMPTZ '2027-01-01 08:00+01',
            'entra:hauswirtschaftsleitung');

SELECT pg_temp.expect_reject(
    '21 — negativer Zusatzbetrag',
    $q$UPDATE academy_offerings SET surcharge_cents = -100, surcharge_label = 'Material'
        WHERE academy_offering_id = '55555555-5555-5555-5555-555555555502'$q$);

-- 21: „Sie ist ein Ja oder ein Zurück mit einem Satz" — und beides zugleich ist
-- keiner der drei Zustände.
SELECT pg_temp.expect_reject(
    '21 — Angebot zurückgegeben ohne Satz',
    $q$UPDATE academy_offerings SET returned_at = now()
        WHERE academy_offering_id = '55555555-5555-5555-5555-555555555501'$q$);

SELECT pg_temp.expect_accept(
    '21 — Angebot mit einem Satz zurückgegeben',
    $q$UPDATE academy_offerings SET returned_at = now(), return_reason = 'Betrag zu hoch'
        WHERE academy_offering_id = '55555555-5555-5555-5555-555555555501'$q$);

SELECT pg_temp.expect_reject(
    '21 — Angebot zugleich freigegeben und zurückgegeben',
    $q$UPDATE academy_offerings SET approved_at = now(), approved_by = 'entra:gf'
        WHERE academy_offering_id = '55555555-5555-5555-5555-555555555501'$q$);

SELECT pg_temp.expect_accept(
    '21 — geändert wieder vorgelegt und freigegeben',
    $q$UPDATE academy_offerings
          SET returned_at = NULL, return_reason = NULL,
              approved_at = now(), approved_by = 'entra:gf'
        WHERE academy_offering_id = '55555555-5555-5555-5555-555555555501'$q$);

SELECT pg_temp.expect_reject(
    '21 — freigegeben von einem Urheber ohne Kennung',
    $q$UPDATE academy_offerings SET approved_at = now(), approved_by = 'die Chefin'
        WHERE academy_offering_id = '55555555-5555-5555-5555-555555555502'$q$);

-- „ein abgesagtes Angebot bleibt sichtbar stehen … samt Grund in einem Satz".
SELECT pg_temp.expect_reject(
    '21 — abgesagtes Angebot ohne Grund',
    $q$UPDATE academy_offerings SET cancelled_at = now()
        WHERE academy_offering_id = '55555555-5555-5555-5555-555555555502'$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — Verantwortliche, Freigebende, Zielgruppe
-- ---------------------------------------------------------------------------

-- 21: „wer ein Angebot führt, ist an ihm benannt" — eine oder mehrere Personen.
INSERT INTO academy_offering_leads (academy_offering_id, employee_id, created_by)
    VALUES ('55555555-5555-5555-5555-555555555501',
            '44444444-4444-4444-4444-444444444401', 'entra:gf');
SELECT pg_temp.expect_accept(
    '21 — ein zweiter Verantwortlicher an demselben Angebot',
    $q$INSERT INTO academy_offering_leads (academy_offering_id, employee_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501',
               '44444444-4444-4444-4444-444444444402', 'entra:gf')$q$);
SELECT pg_temp.expect_reject(
    '21 — dieselbe Person zweimal an demselben Angebot',
    $q$INSERT INTO academy_offering_leads (academy_offering_id, employee_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501',
               '44444444-4444-4444-4444-444444444401', 'entra:gf')$q$);

INSERT INTO academy_approvers (employee_id, created_by)
    VALUES ('44444444-4444-4444-4444-444444444402', 'entra:gf');
SELECT pg_temp.expect_reject(
    '21 — dieselbe Person zweimal in der Freigabeliste',
    $q$INSERT INTO academy_approvers (employee_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444402', 'entra:gf')$q$);

-- 14/21: „ohne Angabe alle" — eine Zeile ohne jede Angabe wäre genau die, die es
-- nicht geben soll; Klasse und Zuschnitt schließen einander aus.
SELECT pg_temp.expect_reject(
    '21 — Zielgruppenzeile ohne jede Angabe',
    $q$INSERT INTO academy_offering_audiences (academy_offering_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501', 'entra:hauswirtschaftsleitung')$q$);

SELECT pg_temp.expect_reject(
    '21 — benannte Klasse und Zuschnitt in einer Zeile',
    $q$INSERT INTO academy_offering_audiences (academy_offering_id, class_id,
                                               school_branch_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501', 1, 1,
               'entra:hauswirtschaftsleitung')$q$);

SELECT pg_temp.expect_accept(
    '21 — ein Zuschnitt aus Schulart und Stufenspanne',
    $q$INSERT INTO academy_offering_audiences (academy_offering_id, school_branch_id,
                                               grade_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501', 1, 2,
               'entra:hauswirtschaftsleitung')$q$);

SELECT pg_temp.expect_reject(
    '21 — derselbe Zuschnitt zweimal an einem Angebot',
    $q$INSERT INTO academy_offering_audiences (academy_offering_id, school_branch_id,
                                               grade_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501', 1, 2,
               'entra:hauswirtschaftsleitung')$q$);

SELECT pg_temp.expect_reject(
    '21 — Stufenspanne, die rückwärts läuft',
    $q$INSERT INTO academy_offering_audiences (academy_offering_id, grade_from, grade_to,
                                               created_by)
       VALUES ('55555555-5555-5555-5555-555555555501', 4, 2,
               'entra:hauswirtschaftsleitung')$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — die Anmeldung
-- ---------------------------------------------------------------------------

-- 21: „Der Chor ist für die eigenen Kinder" — ein Angebot ohne Häkchen weist das
-- schulfremde Kind ab. „Fremd heißt: weder eingeschrieben noch mit Hortvertrag."
SELECT pg_temp.expect_reject(
    '21 — fremdes Kind an einem Angebot, das keine fremden zulässt',
    $q$INSERT INTO academy_registrations (academy_offering_id, child_id, amount_cents,
                                          payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501',
               '33333333-3333-3333-3333-333333333302', 3500, 'paid', 1, 'guardian:x')$q$);

SELECT pg_temp.expect_accept(
    '21 — Kind mit laufendem Hortvertrag ist kein fremdes Kind',
    $q$INSERT INTO academy_registrations (academy_registration_id, academy_offering_id,
                                          child_id, amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666601',
               '55555555-5555-5555-5555-555555555501',
               '33333333-3333-3333-3333-333333333305', 3500, 'direct_debit', 1,
               'guardian:x')$q$);

SELECT pg_temp.expect_accept(
    '21 — eingeschriebenes Kind an demselben Angebot',
    $q$INSERT INTO academy_registrations (academy_registration_id, academy_offering_id,
                                          child_id, amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666602',
               '55555555-5555-5555-5555-555555555501',
               '33333333-3333-3333-3333-333333333301', 3500, 'paid', 1, 'guardian:x')$q$);

-- „Angemeldet wird zum Angebot als Ganzem" — je Teilnehmer eine offene Anmeldung.
SELECT pg_temp.expect_reject(
    '21 — dasselbe Kind zweimal an demselben Angebot',
    $q$INSERT INTO academy_registrations (academy_offering_id, child_id, amount_cents,
                                          payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501',
               '33333333-3333-3333-3333-333333333301', 3500, 'paid', 1, 'guardian:x')$q$);

SELECT pg_temp.expect_accept(
    '21 — das dritte Kind belegt den letzten Platz',
    $q$INSERT INTO academy_registrations (academy_registration_id, academy_offering_id,
                                          child_id, amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666603',
               '55555555-5555-5555-5555-555555555501',
               '33333333-3333-3333-3333-333333333303', 3500, 'paid', 1, 'guardian:x')$q$);

-- 21: „Sie ist hart … Wo zwölf Kinder an sechs Herdplatten stehen, ist das
-- dreizehnte eins zu viel."
SELECT pg_temp.expect_reject(
    '21 — Anmeldung über die Platzzahl hinaus',
    $q$INSERT INTO academy_registrations (academy_offering_id, child_id, amount_cents,
                                          payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555501',
               '33333333-3333-3333-3333-333333333304', 3500, 'paid', 1, 'guardian:x')$q$);

-- „Ein fremdes Kind meldet sich an wie jedes andere, sobald das Angebot ihm
-- offensteht."
SELECT pg_temp.expect_accept(
    '21 — fremdes Kind an einem offenen Angebot',
    $q$INSERT INTO academy_registrations (academy_registration_id, academy_offering_id,
                                          child_id, amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666604',
               '55555555-5555-5555-5555-555555555502',
               '33333333-3333-3333-3333-333333333302', 3000, 'paid', 1, 'guardian:x')$q$);

-- Der Erwachsenen-Zweig: „die Anmeldung hängt an einer Person und nicht am
-- Kind" (03.09.2026).
SELECT pg_temp.expect_accept(
    '21 — Erwachsene meldet sich zu einem Seminar an',
    $q$INSERT INTO academy_registrations (academy_registration_id, academy_offering_id,
                                          for_adults, person_id, amount_cents,
                                          payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666605',
               '55555555-5555-5555-5555-555555555503', true,
               '11111111-1111-1111-1111-111111111203', 4500, 'paid', 1, 'guardian:x')$q$);

SELECT pg_temp.expect_reject(
    '21 — Anmeldung ohne Teilnehmer',
    $q$INSERT INTO academy_registrations (academy_offering_id, amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555502', 3000, 'paid', 1, 'guardian:x')$q$);

SELECT pg_temp.expect_reject(
    '21 — Anmeldung mit Kind und Person zugleich',
    $q$INSERT INTO academy_registrations (academy_offering_id, child_id, person_id,
                                          amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555502',
               '33333333-3333-3333-3333-333333333304',
               '11111111-1111-1111-1111-111111111203', 3000, 'paid', 1, 'guardian:x')$q$);

SELECT pg_temp.expect_reject(
    '21 — Kind an einem Erwachsenen-Seminar',
    $q$INSERT INTO academy_registrations (academy_offering_id, child_id, amount_cents,
                                          payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555503',
               '33333333-3333-3333-3333-333333333304', 4500, 'paid', 1, 'guardian:x')$q$);

SELECT pg_temp.expect_reject(
    '21 — Erwachsene an einem Kinder-Angebot',
    $q$INSERT INTO academy_registrations (academy_offering_id, for_adults, person_id,
                                          amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555502', true,
               '11111111-1111-1111-1111-111111111203', 3000, 'paid', 1, 'guardian:x')$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — Zahlweg und Kostenübernahme
-- ---------------------------------------------------------------------------

-- 21: „er tritt an die Stelle der Zahlung".
SELECT pg_temp.expect_reject(
    '21 — berechnete Anmeldung ohne Kostenübernahme-Code',
    $q$UPDATE academy_registrations SET payment_mode = 'invoiced'
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666602'$q$);

INSERT INTO academy_cost_coverage_codes (academy_cost_coverage_code_id,
                                         academy_offering_id, email, code_hash,
                                         invoice_note, created_by)
    VALUES ('77777777-7777-7777-7777-777777777701',
            '55555555-5555-5555-5555-555555555501', 'familie@example.org', 'x',
            'Jugendamt Musterkreis', 'entra:sekretariat');

SELECT pg_temp.expect_reject(
    '21 — online bezahlte Anmeldung mit Kostenübernahme-Code',
    $q$UPDATE academy_registrations
          SET academy_cost_coverage_code_id = '77777777-7777-7777-7777-777777777701'
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666602'$q$);

SELECT pg_temp.expect_accept(
    '21 — berechnete Anmeldung mit Kostenübernahme-Code',
    $q$UPDATE academy_registrations
          SET payment_mode = 'invoiced',
              academy_cost_coverage_code_id = '77777777-7777-7777-7777-777777777701'
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666602'$q$);

SELECT pg_temp.expect_reject(
    '21 — ein Zahlweg, den es nicht gibt',
    $q$UPDATE academy_registrations SET payment_mode = 'cash'
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666601'$q$);

-- Wie im Ferienprogramm: Ablauf und Einlösen des Codes haben keine eigene
-- Spalte, sie folgen aus `created_at` und aus der Anmeldung, die auf ihn zeigt.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'academy_cost_coverage_codes'
                  AND column_name IN ('expires_at', 'redeemed_at')) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Ablauf oder Einlösen stehen neben ihrer Ableitung';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 21 — Ablauf und Einlösen des Codes haben keine Spalte';
END $$;

SELECT pg_temp.expect_reject(
    '21 — eingelöster Code gelöscht, während seine Anmeldung ihn hält',
    $q$DELETE FROM academy_cost_coverage_codes
        WHERE academy_cost_coverage_code_id = '77777777-7777-7777-7777-777777777701'$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — die Abmeldung
-- ---------------------------------------------------------------------------

-- 21: „wirksam wird es, wenn die anbietende Stelle es einträgt — sie … trägt den
-- berechneten oder einbehaltenen Betrag ein".
SELECT pg_temp.expect_accept(
    '21 — Abmeldung erklärt, aber noch nicht eingetragen',
    $q$UPDATE academy_registrations
          SET cancellation_declared_at = now(), cancellation_declared_by = 'guardian:x'
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666603'$q$);

SELECT pg_temp.expect_reject(
    '21 — Abmeldung erklärt von einem Urheber ohne Kennung',
    $q$UPDATE academy_registrations
          SET cancellation_declared_at = now(), cancellation_declared_by = 'die Eltern'
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666603'$q$);

SELECT pg_temp.expect_reject(
    '21 — Abmeldung eingetragen ohne einbehaltenen Betrag',
    $q$UPDATE academy_registrations
          SET cancellation_recorded_at = now(), cancellation_recorded_by = 'entra:hw'
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666603'$q$);

SELECT pg_temp.expect_reject(
    '21 — einbehaltener Betrag über dem gezahlten',
    $q$UPDATE academy_registrations
          SET cancellation_recorded_at = now(), cancellation_recorded_by = 'entra:hw',
              retained_amount_cents = 99999
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666603'$q$);

-- Sagt die anbietende Stelle selbst ab, „gilt keine Frist und keine Gebühr:
-- Bezahltes wird voll erstattet, Berechnetes nicht berechnet" (21) — der
-- einbehaltene Betrag darf null sein.
SELECT pg_temp.expect_accept(
    '21 — Abmeldung eingetragen mit einbehaltenem Betrag null',
    $q$UPDATE academy_registrations
          SET cancellation_recorded_at = now(), cancellation_recorded_by = 'entra:hw',
              retained_amount_cents = 0
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666603'$q$);

-- „Die Anmeldung bleibt stehen und gilt als abgemeldet, sie verschwindet nicht"
-- — und „die Anmeldung selbst ändern Eltern nicht: sie melden ab und neu an".
-- Beides zusammen geht nur, wenn die abgemeldete Zeile weder die Eindeutigkeit
-- noch den Platz belegt.
SELECT pg_temp.expect_accept(
    '21 — Neuanmeldung desselben Kindes nach der Abmeldung',
    $q$INSERT INTO academy_registrations (academy_registration_id, academy_offering_id,
                                          child_id, amount_cents, payment_mode,
                                          cancellation_terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666606',
               '55555555-5555-5555-5555-555555555501',
               '33333333-3333-3333-3333-333333333303', 3500, 'paid', 1, 'guardian:x')$q$);

DO $$
BEGIN
    IF (SELECT count(*) FROM academy_registrations
         WHERE academy_offering_id = '55555555-5555-5555-5555-555555555501'
           AND cancellation_recorded_at IS NULL) <> 3 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Teilnehmerliste zählt die Abgemeldeten mit';
    END IF;
    RAISE NOTICE 'ok: 21 — die Teilnehmerliste trägt die drei belegten Plätze';
END $$;

-- ---------------------------------------------------------------------------
-- Gegenproben — Q3 und Q5
-- ---------------------------------------------------------------------------

-- Q3, grenzkarte.md: „Der fünfte folgt demselben Muster und steht: die
-- Akademie-Anmeldung einer Familie **ohne** SEPA-Mandat."
SELECT pg_temp.expect_accept(
    'Q3 — Zahlung auf die Akademie-Anmeldung',
    $q$INSERT INTO payments (academy_registration_id, amount_cents, status, confirmed_at,
                             created_by)
       VALUES ('66666666-6666-6666-6666-666666666604', 3000, 'confirmed', now(),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q3 — Zahlung mit zwei Anlässen',
    $q$INSERT INTO payments (academy_registration_id, application_id, amount_cents,
                             created_by)
       VALUES ('66666666-6666-6666-6666-666666666604',
               '99999999-9999-9999-9999-999999999999', 3000, 'system:check')$q$);

-- Q5, 21: „je Anmeldung eine Aufgabe bei der Buchhaltung mit dem einzuziehenden
-- oder zu berechnenden Betrag" — je Anmeldung eine, nicht je Familie.
INSERT INTO roles (role_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'accounting', 'Buchhaltung', 'system:check');
INSERT INTO sync_targets (sync_target_id, code, name, role_id, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'optigem', 'Optigem', 1, 'system:check');
INSERT INTO sync_tasks (sync_target_id, academy_registration_id, task_text, created_by)
    VALUES (1, '66666666-6666-6666-6666-666666666601', 'Beitrag einziehen', 'system:check');

SELECT pg_temp.expect_accept(
    '21 — zweite Aufgabe zu einer anderen Anmeldung',
    $q$INSERT INTO sync_tasks (sync_target_id, academy_registration_id, task_text,
                               created_by)
       VALUES (1, '66666666-6666-6666-6666-666666666602', 'Beitrag berechnen',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — zweite offene Aufgabe derselben Art zu derselben Anmeldung',
    $q$INSERT INTO sync_tasks (sync_target_id, academy_registration_id, task_text,
                               created_by)
       VALUES (1, '66666666-6666-6666-6666-666666666601', 'Beitrag einziehen',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — Aufgabe mit zwei Bezügen',
    $q$INSERT INTO sync_tasks (sync_target_id, academy_registration_id, child_id,
                               task_text, created_by)
       VALUES (1, '66666666-6666-6666-6666-666666666603',
               '33333333-3333-3333-3333-333333333303', 'Beitrag einziehen',
               'system:check')$q$);

-- Q3: „geht mit dem Vorgang, an dem die Zahlung hängt" — die Anmeldung nimmt
-- sie mit, statt von ihr festgehalten zu werden.
SELECT pg_temp.expect_accept(
    'Q3 — die Zahlung geht mit ihrer Akademie-Anmeldung',
    $q$DELETE FROM academy_registrations
        WHERE academy_registration_id = '66666666-6666-6666-6666-666666666604'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM payments) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Zahlung überlebt ihren Vorgang';
    END IF;
    RAISE NOTICE 'ok (erlaubt): Q3 — keine Zahlung überlebt ihren Vorgang';
END $$;

-- 21/17: Die Anmeldung ist der einzige Anker ihres Teilnehmers, wo er sonst
-- keinen hat — die erwachsene Teilnehmerin hat keine Rollenzeile. Der Lauf
-- räumt deshalb erst die Anmeldung und dann die Person; umgekehrt hält ihn der
-- Fremdschlüssel auf, und genau das ist die Reihenfolge, die der Kommentar an
-- der Tabelle zusagt.
SELECT pg_temp.expect_reject(
    '17 — die erwachsene Teilnehmerin gelöscht, während ihre Anmeldung sie hält',
    $q$DELETE FROM persons
        WHERE person_id = '11111111-1111-1111-1111-111111111203'$q$);

SELECT pg_temp.expect_accept(
    '17 — nach der Anmeldung geht die Person, die sonst keinen Anker hat',
    $q$DELETE FROM academy_registrations
              WHERE person_id = '11111111-1111-1111-1111-111111111203';
       DELETE FROM persons
              WHERE person_id = '11111111-1111-1111-1111-111111111203'$q$);

DO $$ BEGIN RAISE NOTICE 'akademie-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
