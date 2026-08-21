-- Prüfskript zu klassenbildung-schema.sql.
--
-- Sollstand: keine eigenen Tabellen. Geprüft wird, dass die vier Angaben der
-- heutigen Klassenbildungsliste, die das Schema trägt, an ihren Stellen stehen,
-- dass der Zusammensetzungswunsch keine Spalte hat (15 schlägt grenzkarte.md)
-- und dass die beiden Bedingungen aus Block 15 als Constraints greifen.
--
-- Setzt stammdaten-schema.sql und anmeldung-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f klassenbildung-schema-check.sql

BEGIN;

DO $$
DECLARE unexpected text;
BEGIN
    SELECT string_agg(t, ', ') INTO unexpected
    FROM unnest(ARRAY['class_formations', 'class_placement_wishes',
                      'class_capacities', 'grade_levels']) AS t
    WHERE to_regclass('public.' || t) IS NOT NULL;
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Domäne 12 hat entgegen grenzkarte.md eigene Tabellen: %', unexpected;
    END IF;
    RAISE NOTICE 'ok: keine eigenen Tabellen, wie die Grenzkarte es festlegt';
END $$;

DO $$
DECLARE missing text;
BEGIN
    -- Wohnort und Geschlecht an persons, Geschwister über die Familie, die
    -- Klasse am Kind.
    SELECT string_agg(x, ', ') INTO missing FROM (VALUES
        ('persons.address_id'), ('persons.gender_id'), ('children.family_id'),
        ('children.class_id')
    ) AS v(x)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns
         WHERE table_name = split_part(x, '.', 1)
           AND column_name = split_part(x, '.', 2));
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Der Klassenbildung fehlen Angaben: %', missing;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_name = 'classes' AND column_name = 'class_teacher_id') THEN
        RAISE EXCEPTION 'Die Klassenlehrkraft fehlt';
    END IF;

    -- „Keine Kapazität … die Zielmarke von derzeit 25 steht so wenig im System
    -- wie in 07"; „Stufe und Anzeigename werden nicht erhoben, sondern gerechnet".
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'classes'
                  AND column_name IN ('capacity', 'max_children', 'grade_level',
                                      'display_name')) THEN
        RAISE EXCEPTION 'Die Klasse führt Angaben, die Block 15 ausschließt';
    END IF;

    -- 15, Schritt 2: „Die Gründe — Freundschaften, Förderbedarf,
    -- Ausgewogenheit — bleiben außerhalb wie das Ranking in 07." Der Wunsch
    -- stand allein auf grenzkarte.md und wird vom jüngeren Block überstimmt.
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'applications'
                  AND column_name = 'class_placement_wish') THEN
        RAISE EXCEPTION 'Der Zusammensetzungswunsch hat entgegen Block 15 eine Spalte';
    END IF;
    RAISE NOTICE 'ok: die vier Angaben stehen, keine ausgeschlossene Spalte';
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
    (1, 1, 2026, 'a', 'system:check'), (2, 2, 2026, 'a', 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Kind1', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Kind2', 'Muster', 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333331', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by) VALUES
    ('44444444-4444-4444-4444-444444444441', '22222222-2222-2222-2222-222222222221',
     '33333333-3333-3333-3333-333333333331', DATE '2020-05-01', 'system:check'),
    ('44444444-4444-4444-4444-444444444442', '22222222-2222-2222-2222-222222222222',
     '33333333-3333-3333-3333-333333333331', DATE '2021-05-01', 'system:check');

-- ---------------------------------------------------------------------------
-- Gegenproben
-- ---------------------------------------------------------------------------

-- 15, erste Bedingung: „Das Kind ist eingeschrieben."
SELECT pg_temp.expect_reject(
    '15 — Kind ohne Einschreibung in eine Klasse gesetzt',
    $q$UPDATE children SET class_id = 1
        WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

-- 15, zweite Bedingung: „es gibt eine Klasse, in die es passt."
SELECT pg_temp.expect_reject(
    '15 — Grundschulkind in eine Realschulklasse gesetzt',
    $q$UPDATE children SET school_branch_id = 1, first_grade_level = 1,
                           final_grade_level = 4, grade_level = 1,
                           entry_date = DATE '2026-08-01', class_id = 2
        WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

SELECT pg_temp.expect_accept(
    '15 — eingeschriebenes Kind in eine Klasse seiner Schulart gesetzt',
    $q$UPDATE children SET school_branch_id = 1, first_grade_level = 1,
                           final_grade_level = 4, grade_level = 1,
                           entry_date = DATE '2026-08-01', class_id = 1
        WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

-- 15: „Ein Kind ohne Klasse ist kein Fehler."
SELECT pg_temp.expect_accept(
    '15 — eingeschriebenes Kind ohne Klasse',
    $q$UPDATE children SET school_branch_id = 1, first_grade_level = 1,
                           final_grade_level = 4, grade_level = 1,
                           entry_date = DATE '2026-08-01'
        WHERE child_id = '44444444-4444-4444-4444-444444444442'$q$);

-- „Umsetzen geht jederzeit und ist dieselbe Handlung."
INSERT INTO classes (class_id, school_branch_id, start_school_year, stream, created_by)
    OVERRIDING SYSTEM VALUE VALUES (3, 1, 2026, 'b', 'system:check');
SELECT pg_temp.expect_accept(
    '15 — Klassenwechsel als dieselbe Handlung',
    $q$UPDATE children SET class_id = 3
        WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

-- „Wie viele Kinder in einer Klasse sitzen, wird gezeigt, nicht geprüft."
SELECT pg_temp.expect_accept(
    '15 — beliebig viele Kinder in derselben Klasse',
    $q$UPDATE children SET class_id = 3
        WHERE child_id = '44444444-4444-4444-4444-444444444442'$q$);

DO $$ BEGIN RAISE NOTICE 'klassenbildung-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
