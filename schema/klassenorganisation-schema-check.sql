-- Prüfskript zu klassenorganisation-schema.sql.
--
-- Sollstand: eine Tabelle — class_representatives — samt Lese-Index für die
-- Frage, die der Elternbonus stellt. Geprüft wird zusätzlich, dass die beiden
-- übrigen Angaben derselben Liste nicht hier stehen, sondern in den Stammdaten.
--
-- Setzt stammdaten-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f klassenorganisation-schema-check.sql

BEGIN;

DO $$
BEGIN
    IF to_regclass('public.class_representatives') IS NULL THEN
        RAISE EXCEPTION 'Fehlende Tabelle: class_representatives';
    END IF;
    IF to_regclass('public.ix_class_representatives_year') IS NULL THEN
        RAISE EXCEPTION 'Fehlender Index: ix_class_representatives_year';
    END IF;
    -- „Die beiden übrigen Angaben derselben Liste, Klassenlehrer:in und
    -- Klassenzimmer, stehen bereits" (grenzkarte.md) — die Domäne bringt allein
    -- die Elternvertretung mit.
    IF (SELECT count(*) FROM information_schema.columns
         WHERE table_name = 'classes'
           AND column_name IN ('class_teacher_id', 'room')) <> 2 THEN
        RAISE EXCEPTION 'Klassenlehrkraft oder Raum fehlen in den Stammdaten';
    END IF;
    RAISE NOTICE 'ok: eine Tabelle, und die beiden übrigen Angaben stehen anderswo';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY['pk_class_representatives', 'fk_class_representatives_class',
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
    OVERRIDING SYSTEM VALUE VALUES (1, 'GS', 'Grundschule', 1, 4, 'system:check');
INSERT INTO classes (class_id, school_branch_id, start_school_year, stream, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 2026, 'a', 'system:check'), (2, 1, 2026, 'b', 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Mutter', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Vater',  'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222223', 'Dritte', 'Muster', 'system:check');

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
