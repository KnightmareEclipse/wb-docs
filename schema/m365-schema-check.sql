-- Prüfskript zu m365-schema.sql.
--
-- Sollstand: keine eigenen Tabellen. Geprüft wird stattdessen, dass die vier
-- fremden Strukturen tragen, was Block 13 von ihnen verlangt — die sechs
-- Angaben an `employees`, die Schuladresse an `children`, die eine Aufgabenart
-- je Person in `sync_tasks` und die Rollen, die am letzten Arbeitstag hängen.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f m365-schema-check.sql

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Es gibt bewusst keine eigenen Tabellen
-- ---------------------------------------------------------------------------
DO $$
DECLARE unexpected text;
BEGIN
    SELECT string_agg(t, ', ') INTO unexpected
    FROM unnest(ARRAY['m365_accounts', 'account_statuses', 'offboarding_steps']) AS t
    WHERE to_regclass('public.' || t) IS NOT NULL;
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Domäne 7 hat entgegen Block 13 eigene Tabellen: %', unexpected;
    END IF;
    RAISE NOTICE 'ok: keine eigenen Tabellen, wie Block 13 es festlegt';
END $$;

-- ---------------------------------------------------------------------------
-- 2. Die sechs Angaben des Mitarbeitendeneintrags stehen
-- ---------------------------------------------------------------------------
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY['person_id', 'house_id', 'work_email', 'first_working_day',
                      'last_working_day', 'successor_note']) AS c
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns
         WHERE table_name = 'employees' AND column_name = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Dem Mitarbeitendeneintrag fehlen Angaben: %', missing;
    END IF;

    -- „Mehr Personaldaten entstehen hier nicht — kein Vertrag, kein
    -- Stundenumfang, kein Gehalt."
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'employees'
                  AND column_name IN ('salary', 'contract_type', 'weekly_hours',
                                      'vacation_days')) THEN
        RAISE EXCEPTION 'Der Mitarbeitendeneintrag führt Personaldaten, die Block 13 ausschließt';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_name = 'children' AND column_name = 'school_email') THEN
        RAISE EXCEPTION 'Die Schuladresse am Kind fehlt';
    END IF;
    RAISE NOTICE 'ok: sechs Angaben am Mitarbeitenden, Schuladresse am Kind, keine siebte';
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
-- 3. Stammsätze
-- ---------------------------------------------------------------------------
INSERT INTO houses (house_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'school', 'Schule', 'system:check'), (2, 'kita', 'KITA', 'system:check');
INSERT INTO roles (role_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'admin', 'Admin', 'system:check');
INSERT INTO sync_targets (sync_target_id, code, name, role_id, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'm365', 'M365', 1, 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Neu',  'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Kita', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222223', 'Kind', 'Muster', 'system:check');
INSERT INTO employees (employee_id, person_id, house_id, created_by) VALUES
    ('55555555-5555-5555-5555-555555555551', '22222222-2222-2222-2222-222222222221', 1, 'system:check'),
    ('55555555-5555-5555-5555-555555555552', '22222222-2222-2222-2222-222222222222', 2, 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444441',
            '22222222-2222-2222-2222-222222222223',
            '33333333-3333-3333-3333-333333333333', DATE '2018-05-01', 'system:check');

-- ---------------------------------------------------------------------------
-- 4. Gegenproben
-- ---------------------------------------------------------------------------

-- 13: „Legen einen Mitarbeitenden an — Name, Haus" — das Haus ist Pflicht, und
-- „KITA-Mitarbeitende laufen denselben Ablauf … nur ihre Domain ist eine
-- andere".
SELECT pg_temp.expect_accept(
    '13 — KITA-Mitarbeitende im selben Bestand',
    $q$UPDATE employees SET work_email = 'kita@kita.de'
        WHERE employee_id = '55555555-5555-5555-5555-555555555552'$q$);

-- 13: „Sie spiegelt den Tenant" — dieselbe Adresse gibt es kein zweites Mal.
SELECT pg_temp.expect_reject(
    '13 — dieselbe Dienstadresse zweimal',
    $q$UPDATE employees SET work_email = 'kita@kita.de'
        WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

-- 13: „Je Person gibt es dabei eine Aufgabenart und nicht zwei — Anlegen und
-- Offboarding ersetzen einander, statt sich zu verdoppeln."
INSERT INTO sync_tasks (sync_task_id, sync_target_id, person_id, task_text, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661', 1,
            '22222222-2222-2222-2222-222222222221', 'Konto anlegen', 'system:check');
SELECT pg_temp.expect_reject(
    '13 — Offboarding-Aufgabe neben der offenen Anlege-Aufgabe',
    $q$INSERT INTO sync_tasks (sync_target_id, person_id, task_text, created_by)
       VALUES (1, '22222222-2222-2222-2222-222222222221', 'Offboarding', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '13 — Offboarding, nachdem die Anlage abgehakt wurde',
    $q$UPDATE sync_tasks SET completed_at = now(), completed_by = 'entra:admin', outcome = 'done'
         WHERE sync_task_id = '66666666-6666-6666-6666-666666666661';
       INSERT INTO sync_tasks (sync_target_id, person_id, task_text, created_by)
       VALUES (1, '22222222-2222-2222-2222-222222222221', 'Offboarding', 'system:check')$q$);

-- 13: „Für ein Kind derselbe Handgriff wie für einen Mitarbeitenden, kein
-- zweiter Weg daneben" — dieselbe Aufgabenart trägt beide Bezüge.
SELECT pg_temp.expect_accept(
    '13 — dieselbe Aufgabenart für ein Kind',
    $q$INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
       VALUES (1, '44444444-4444-4444-4444-444444444441', 'Konto anlegen', 'system:check')$q$);

-- 13: „Der Anker für den Lösch-Lauf ist der letzte Arbeitstag" — er lässt sich
-- eintragen, ohne dass eine Aufgabe abgehakt ist.
SELECT pg_temp.expect_accept(
    '13 — letzter Arbeitstag ohne abgehakte Aufgabe',
    $q$UPDATE employees SET last_working_day = DATE '2027-07-31'
        WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

SELECT pg_temp.expect_reject(
    '13 — letzter Arbeitstag vor dem ersten',
    $q$UPDATE employees SET first_working_day = DATE '2027-09-01'
        WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

-- 13: „Die Schuladresse am Kind … bleibt stehen, auch wenn dessen Konto längst
-- weg ist — sie sagt dann, welches es war."
SELECT pg_temp.expect_accept(
    '13 — Schuladresse bleibt am abgegangenen Kind stehen',
    $q$UPDATE children SET school_email = 'kind@schule.de',
                           school_branch_id = NULL, grade_level = NULL,
                           first_grade_level = NULL, final_grade_level = NULL,
                           exit_date = NULL, exit_reason = NULL
        WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

DO $$ BEGIN RAISE NOTICE 'm365-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
