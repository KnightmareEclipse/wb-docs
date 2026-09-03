-- Prüfskript zu klassenorganisation-schema.sql.
--
-- Sollstand: sechs Tabellen — die zweite Achse der Sichtbarkeit
-- (elective_modules, elective_groups, child_group_memberships,
-- class_teaching_assignments), das Unterrichtsende je Klasse und Wochentag
-- (class_end_times) und die Elternvertretung (class_representatives), dazu drei
-- Lese-Indizes. Geprüft wird zusätzlich, dass die Klassenlehrkraft und der Raum
-- weiterhin in den Stammdaten stehen und dass aus der zweiten Achse weder eine
-- Fächerliste noch ein Stundenplan geworden ist.
--
-- Setzt stammdaten-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f klassenorganisation-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY['elective_modules', 'elective_groups', 'child_group_memberships',
                      'class_teaching_assignments', 'class_end_times',
                      'class_representatives']) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;

    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY['ix_child_group_memberships_group',
                      'ix_class_teaching_assignments_class',
                      'ix_class_representatives_year']) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Indizes: %', missing;
    END IF;

    -- „Die beiden übrigen Angaben derselben Liste, Klassenlehrer:in und
    -- Klassenzimmer, stehen bereits" (grenzkarte.md) — die Domäne bringt sie
    -- nicht mit.
    IF (SELECT count(*) FROM information_schema.columns
         WHERE table_name = 'classes'
           AND column_name IN ('class_teacher_id', 'room')) <> 2 THEN
        RAISE EXCEPTION 'Klassenlehrkraft oder Raum fehlen in den Stammdaten';
    END IF;
    RAISE NOTICE 'ok: sechs Tabellen, drei Indizes, und die zwei Klassenangaben stehen anderswo';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY['pk_elective_modules', 'uq_elective_modules_code',
                      'pk_elective_groups', 'fk_elective_groups_module',
                      'fk_elective_groups_branch', 'fk_elective_groups_employee',
                      'uq_elective_groups', 'ck_elective_groups_label',
                      'pk_child_group_memberships', 'fk_child_group_memberships_child',
                      'fk_child_group_memberships_group',
                      'pk_class_teaching_assignments',
                      'fk_class_teaching_assignments_employee',
                      'fk_class_teaching_assignments_class',
                      'uq_class_teaching_assignments',
                      'pk_class_end_times', 'fk_class_end_times_class',
                      'ck_class_end_times_weekday',
                      'pk_class_representatives', 'fk_class_representatives_class',
                      'fk_class_representatives_person', 'uq_class_representatives']) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;

    -- „Mehr nicht: kein Wahltag, kein Protokoll, keine Stimmenzahl, kein
    -- Amtstitel und keine geprüfte Höchstzahl."
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'class_representatives'
                  AND column_name IN ('elected_on', 'votes', 'title', 'minutes')) THEN
        RAISE EXCEPTION 'Die Elternvertretung führt Angaben, die Block 16 ausschließt';
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints vorhanden, keine ausgeschlossene Spalte';
END $$;

-- TASK-161: „Keine dieser Fächerlisten wird gebaut … gebraucht werden von ihnen
-- nur die drei Wahlmodule." Und die Gruppe lebt so lange wie die Kohorte, trägt
-- also kein Schuljahr — sonst wäre sie eine zweite Klasse.
DO $$
BEGIN
    IF to_regclass('public.subjects') IS NOT NULL
       OR to_regclass('public.school_subjects') IS NOT NULL THEN
        RAISE EXCEPTION 'Eine Fächerliste ist entstanden, obwohl sie nichts trägt';
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'elective_groups'
                  AND column_name IN ('school_year', 'subject_id')) THEN
        RAISE EXCEPTION 'Die Wahlmodulgruppe trägt ein Schuljahr oder ein Fach';
    END IF;
    -- Die Zugehörigkeit steht als Zeile und nicht als Spalte am Kind.
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'children' AND column_name = 'elective_group_id') THEN
        RAISE EXCEPTION 'Die Gruppe steht als Spalte am Kind statt als Zuordnung';
    END IF;
    -- Und die Stammklasse bleibt, wo sie war.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_name = 'children' AND column_name = 'class_id') THEN
        RAISE EXCEPTION 'children.class_id ist verschwunden';
    END IF;
    RAISE NOTICE 'ok: keine Fächerliste, kein Schuljahr an der Gruppe, die Stammklasse steht';
END $$;

-- TASK-218: „Das ist kein Stundenplan und wird keiner", und eine Ankunftszeit
-- gibt es der Sache nach nicht.
DO $$
DECLARE leftover text;
BEGIN
    SELECT string_agg(column_name, ', ') INTO leftover
    FROM information_schema.columns
    WHERE table_name = 'class_end_times'
      AND column_name IN ('arrives_at', 'arrival_at', 'subject_id', 'room',
                          'period', 'lesson', 'teacher_id');
    IF leftover IS NOT NULL THEN
        RAISE EXCEPTION 'Das Unterrichtsende trägt Stundenplan- oder Ankunftsspalten: %', leftover;
    END IF;
    RAISE NOTICE 'ok: eine Zeit je Klasse und Wochentag, keine Ankunft und kein Stundenplan';
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
INSERT INTO school_branches (school_branch_id, code, name, first_grade_level,
                             final_grade_level, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'GS', 'Grundschule', 1, 4, 'system:check'),
    (2, 'RS', 'Realschule',  5, 10, 'system:check');
INSERT INTO classes (class_id, school_branch_id, start_school_year, stream, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 2026, 'a', 'system:check'), (2, 1, 2026, 'b', 'system:check'),
    (3, 2, 2023, 'a', 'system:check'), (4, 2, 2023, 'b', 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Mutter', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Vater',  'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222223', 'Dritte', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222231', 'Klassen', 'Lehrkraft', 'system:check'),
    ('22222222-2222-2222-2222-222222222232', 'Technik', 'Lehrkraft', 'system:check'),
    ('22222222-2222-2222-2222-222222222233', 'Ohne',    'Zuordnung', 'system:check'),
    ('22222222-2222-2222-2222-222222222241', 'Kind',    'Ausa',      'system:check'),
    ('22222222-2222-2222-2222-222222222242', 'Kind',    'Ausb',      'system:check');
INSERT INTO houses (house_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'SCHULE', 'Schule', 'system:check');
INSERT INTO employees (employee_id, person_id, house_id, created_by) VALUES
    ('88888888-8888-8888-8888-888888888881',
     '22222222-2222-2222-2222-222222222231', 1, 'system:check'),
    ('88888888-8888-8888-8888-888888888882',
     '22222222-2222-2222-2222-222222222232', 1, 'system:check'),
    ('88888888-8888-8888-8888-888888888883',
     '22222222-2222-2222-2222-222222222233', 1, 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');
-- Zwei Realschulkinder in zwei Klassen derselben Kohorte — der Fall, für den es
-- die Gruppe gibt: Sie sitzen in verschiedenen Klassen und im selben Wahlmodul.
INSERT INTO children (child_id, person_id, family_id, birth_date, school_branch_id,
                      first_grade_level, final_grade_level, grade_level, entry_date,
                      class_id, created_by) VALUES
    ('44444444-4444-4444-4444-444444444441', '22222222-2222-2222-2222-222222222241',
     '33333333-3333-3333-3333-333333333333', DATE '2012-05-01', 2, 5, 10, 8,
     DATE '2023-08-01', 3, 'system:check'),
    ('44444444-4444-4444-4444-444444444442', '22222222-2222-2222-2222-222222222242',
     '33333333-3333-3333-3333-333333333333', DATE '2012-06-01', 2, 5, 10, 8,
     DATE '2023-08-01', 4, 'system:check');

INSERT INTO elective_modules (elective_module_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'technik',      'Technik',     'system:check'),
    (2, 'aes',          'AES',         'system:check'),
    (3, 'franzoesisch', 'Französisch', 'system:check');

-- ---------------------------------------------------------------------------
-- Die zweite Achse: welche Kinder jemand sieht
-- ---------------------------------------------------------------------------

-- TASK-161: „Eine Zuordnung Lehrkraft ↔ Klasse ohne Schuljahr wird abgewiesen."
SELECT pg_temp.expect_reject(
    'TASK-161 — Unterrichtsverteilung ohne Schuljahr',
    $q$INSERT INTO class_teaching_assignments (employee_id, class_id, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881', 3, 'system:check')$q$);

INSERT INTO class_teaching_assignments (employee_id, class_id, school_year, created_by)
    VALUES ('88888888-8888-8888-8888-888888888881', 3, 2026, 'system:check');

SELECT pg_temp.expect_reject(
    'TASK-161 — dieselbe Lehrkraft zweimal in derselben Klasse und im selben Jahr',
    $q$INSERT INTO class_teaching_assignments (employee_id, class_id, school_year, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881', 3, 2026, 'system:check')$q$);

-- „Zwei Gruppen desselben Moduls im selben Jahrgang sind darstellbar, mit
-- verschiedenen Lehrkräften" — der Fall, für den die Gruppe eine eigene
-- Kennung bekommt.
SELECT pg_temp.expect_accept(
    'TASK-161 — zwei Gruppen desselben Moduls im selben Jahrgang',
    $q$INSERT INTO elective_groups (elective_group_id, label, elective_module_id,
                                    school_branch_id, start_school_year, employee_id,
                                    created_by)
       OVERRIDING SYSTEM VALUE VALUES
       (1, 'Technik 8 · A', 1, 2, 2023, '88888888-8888-8888-8888-888888888882',
        'system:check'),
       (2, 'Technik 8 · B', 1, 2, 2023, '88888888-8888-8888-8888-888888888881',
        'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-161 — zweite Gruppe unter demselben Namen',
    $q$INSERT INTO elective_groups (label, elective_module_id, school_branch_id,
                                    start_school_year, employee_id, created_by)
       VALUES ('Technik 8 · A', 1, 2, 2023, '88888888-8888-8888-8888-888888888882',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-161 — Gruppe ohne Namen',
    $q$INSERT INTO elective_groups (label, elective_module_id, school_branch_id,
                                    start_school_year, employee_id, created_by)
       VALUES ('', 1, 2, 2023, '88888888-8888-8888-8888-888888888882', 'system:check')$q$);

-- „heute genau eine Gruppe je Kind, morgen zwei, ohne Umstellung".
SELECT pg_temp.expect_accept(
    'TASK-161 — ein Kind in einer Gruppe und ein Kind in zweien',
    $q$INSERT INTO child_group_memberships (child_id, elective_group_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', 1, 'system:check'),
              ('44444444-4444-4444-4444-444444444442', 1, 'system:check'),
              ('44444444-4444-4444-4444-444444444442', 2, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-161 — dasselbe Kind zweimal in derselben Gruppe',
    $q$INSERT INTO child_group_memberships (child_id, elective_group_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', 1, 'system:check')$q$);

-- „Listen entstehen je Zuordnung, nicht je Lehrkraft": Die Technik-Lehrkraft
-- unterrichtet keine Klasse und sieht trotzdem ein Kind aus jeder der beiden —
-- über die Gruppe, und als eigene Liste.
DO $$
DECLARE aus_klasse int; aus_gruppe int;
BEGIN
    SELECT count(*) INTO aus_klasse
    FROM children c
    JOIN class_teaching_assignments a ON a.class_id = c.class_id
    WHERE a.employee_id = '88888888-8888-8888-8888-888888888882';
    SELECT count(*) INTO aus_gruppe
    FROM child_group_memberships m
    JOIN elective_groups g ON g.elective_group_id = m.elective_group_id
    WHERE g.employee_id = '88888888-8888-8888-8888-888888888882';
    IF aus_klasse <> 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Wahlmodul-Lehrkraft sieht ganze Klassen';
    END IF;
    IF aus_gruppe <> 2 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Gruppenliste trägt % statt 2 Kinder', aus_gruppe;
    END IF;
    RAISE NOTICE 'ok: Klassenliste und Gruppenliste sind zwei, und die Gruppe hält den Kreis eng';
END $$;

-- „Fehlt die Zuordnung, sieht die Lehrkraft nichts statt zu viel."
DO $$
DECLARE sichtbar int;
BEGIN
    SELECT (SELECT count(*) FROM children c
             JOIN class_teaching_assignments a ON a.class_id = c.class_id
            WHERE a.employee_id = '88888888-8888-8888-8888-888888888883')
         + (SELECT count(*) FROM child_group_memberships m
             JOIN elective_groups g ON g.elective_group_id = m.elective_group_id
            WHERE g.employee_id = '88888888-8888-8888-8888-888888888883')
    INTO sichtbar;
    IF sichtbar <> 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Lehrkraft ohne Zuordnung sieht % Kinder', sichtbar;
    END IF;
    RAISE NOTICE 'ok: ohne Zuordnung sieht die Lehrkraft nichts statt zu viel';
END $$;

-- „Die Gruppe steht still, wenn ihre Lehrkraft geht" — sie verschwindet nicht,
-- und mit ihr verschwinden auch die Mitgliedschaften nicht; die Zuordnung zur
-- Klasse dagegen geht mit dem Mitarbeitendeneintrag.
SELECT pg_temp.expect_accept(
    'TASK-161 — die Lehrkraft geht, die Gruppe bleibt',
    $q$DELETE FROM employees
        WHERE employee_id = '88888888-8888-8888-8888-888888888881'$q$);

DO $$
BEGIN
    IF (SELECT employee_id FROM elective_groups WHERE elective_group_id = 2) IS NOT NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Gruppe hält ihre entfallene Lehrkraft fest';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM child_group_memberships WHERE elective_group_id = 2) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Mitgliedschaft ging mit der Lehrkraft';
    END IF;
    IF EXISTS (SELECT 1 FROM class_teaching_assignments
                WHERE employee_id = '88888888-8888-8888-8888-888888888881') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Unterrichtsverteilung überlebt ihre Lehrkraft';
    END IF;
    RAISE NOTICE 'ok: die Gruppe steht still, statt ihre Kinder mitzunehmen';
END $$;

-- Die Mitgliedschaft geht mit dem Kind (03).
SELECT pg_temp.expect_accept(
    '03 — die Mitgliedschaft verschwindet mit dem Kind',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM child_group_memberships
                WHERE child_id = '44444444-4444-4444-4444-444444444441') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Mitgliedschaft überlebt ihr Kind';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 03 — keine Mitgliedschaft überlebt ihr Kind';
END $$;

-- ---------------------------------------------------------------------------
-- Unterrichtsende je Klasse und Wochentag
-- ---------------------------------------------------------------------------

SELECT pg_temp.expect_accept(
    'TASK-218 — eine Zeit je Klasse und Wochentag, mit Sport am Ende',
    $q$INSERT INTO class_end_times (class_id, school_year, weekday, ends_at,
                                    sport_at_end, created_by)
       VALUES (1, 2026, 1, TIME '12:15', false, 'system:check'),
              (1, 2026, 3, TIME '13:00', true,  'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-218 — zweite Zeit für dieselbe Klasse am selben Wochentag',
    $q$INSERT INTO class_end_times (class_id, school_year, weekday, ends_at, created_by)
       VALUES (1, 2026, 1, TIME '11:30', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-218 — Unterrichtsende ohne Schuljahr',
    $q$INSERT INTO class_end_times (class_id, weekday, ends_at, created_by)
       VALUES (2, 2, TIME '12:15', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-218 — Unterricht am Samstag',
    $q$INSERT INTO class_end_times (class_id, school_year, weekday, ends_at, created_by)
       VALUES (2, 2026, 6, TIME '12:15', 'system:check')$q$);

-- Dieselbe Klasse im nächsten Schuljahr ist eine neue Zeile, keine Änderung.
SELECT pg_temp.expect_accept(
    'TASK-218 — dieselbe Klasse im nächsten Schuljahr',
    $q$INSERT INTO class_end_times (class_id, school_year, weekday, ends_at, created_by)
       VALUES (1, 2027, 1, TIME '12:45', 'system:check')$q$);


-- ---------------------------------------------------------------------------
-- Gegenproben
-- ---------------------------------------------------------------------------

-- 16: „derzeit zwei, manchmal drei Personen … eine Höchstzahl prüft niemand".
INSERT INTO class_representatives (class_id, school_year, person_id, created_by) VALUES
    (1, 2026, '22222222-2222-2222-2222-222222222221', 'system:check'),
    (1, 2026, '22222222-2222-2222-2222-222222222222', 'system:check');
SELECT pg_temp.expect_accept(
    '16 — dritte Person an derselben Klasse',
    $q$INSERT INTO class_representatives (class_id, school_year, person_id, created_by)
       VALUES (1, 2026, '22222222-2222-2222-2222-222222222223', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '16 — dieselbe Person zweimal an derselben Klasse und im selben Jahr',
    $q$INSERT INTO class_representatives (class_id, school_year, person_id, created_by)
       VALUES (1, 2026, '22222222-2222-2222-2222-222222222221', 'system:check')$q$);

-- „hält eine Person zwei Ämter, weil zwei Kinder in verschiedenen Klassen sind"
-- (16, Sonderfälle).
SELECT pg_temp.expect_accept(
    '16 — dieselbe Person in zwei Klassen',
    $q$INSERT INTO class_representatives (class_id, school_year, person_id, created_by)
       VALUES (2, 2026, '22222222-2222-2222-2222-222222222221', 'system:check')$q$);

-- „gilt für ein Schuljahr … im nächsten Jahr wird ohnehin neu gewählt".
SELECT pg_temp.expect_accept(
    '16 — dieselbe Person im nächsten Schuljahr erneut',
    $q$INSERT INTO class_representatives (class_id, school_year, person_id, created_by)
       VALUES (1, 2027, '22222222-2222-2222-2222-222222222221', 'system:check')$q$);

-- „Nichts prüft, ob die Person noch ein Kind in dieser Klasse hat" — es gibt
-- keinen Fremdschlüssel, der das verlangen würde.
SELECT pg_temp.expect_accept(
    '16 — Amt ohne Kind in dieser Klasse',
    $q$INSERT INTO class_representatives (class_id, school_year, person_id, created_by)
       VALUES (2, 2027, '22222222-2222-2222-2222-222222222223', 'system:check')$q$);

-- 16: „Der Eintrag … verschwindet mit der Person."
SELECT pg_temp.expect_accept(
    '16 — das Amt verschwindet mit der Person',
    $q$DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222223'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM class_representatives
                WHERE person_id = '22222222-2222-2222-2222-222222222223') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — ein Amt überlebt seine Person';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 16 — kein Amt überlebt seine Person';
END $$;

DO $$ BEGIN RAISE NOTICE 'klassenorganisation-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
