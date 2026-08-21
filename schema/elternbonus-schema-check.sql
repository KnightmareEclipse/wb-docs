-- Prüfskript zu elternbonus-schema.sql.
--
-- Sollstand: eine Tabelle — parent_work_entries — samt zwei Lese-Indizes für
-- die Aufgabe der bestätigenden Person und für die Jahresrechnung. Geprüft wird
-- zusätzlich, dass die drei Werte im System und die Elternvertretung dort
-- stehen, wo dieser Block sie liest.
--
-- Setzt stammdaten-schema.sql, querschnitt-schema.sql und
-- klassenorganisation-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f elternbonus-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    IF to_regclass('public.parent_work_entries') IS NULL THEN
        RAISE EXCEPTION 'Fehlende Tabelle: parent_work_entries';
    END IF;

    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_parent_work_entries_waiting', 'ix_parent_work_entries_year']) AS i
    WHERE to_regclass('public.' || i) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Indizes: %', missing;
    END IF;

    -- Monatsbetrag und die beiden Pflichtstundenzahlen sind Werte im System und
    -- stehen nicht hier; die Elternvertretung steht in Domäne 13.
    IF to_regclass('public.configured_values') IS NULL
       OR to_regclass('public.class_representatives') IS NULL THEN
        RAISE EXCEPTION 'Werte im System oder Elternvertretung fehlen';
    END IF;

    -- „insbesondere keine Kategorie und kein Schlüssel"; „Abgelehnt wird ohne
    -- Begründung im System".
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'parent_work_entries'
                  AND column_name IN ('category_id', 'weight', 'rejected_reason',
                                      'amount_cents')) THEN
        RAISE EXCEPTION 'Der Eintrag führt Angaben, die Block 14 ausschließt';
    END IF;
    RAISE NOTICE 'ok: eine Tabelle, zwei Indizes, keine ausgeschlossene Spalte';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY['pk_parent_work_entries', 'fk_parent_work_entries_family',
                      'fk_parent_work_entries_confirmer',
                      'ck_parent_work_entries_confirmer',
                      'ck_parent_work_entries_decision', 'ck_parent_work_entries_hours',
                      'ck_parent_work_entries_activity',
                      'ck_parent_work_entries_school_year']) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints vorhanden';
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
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Hausmeister', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Lehrkraft',   'Muster', 'system:check');
INSERT INTO employees (employee_id, person_id, house_id, created_by) VALUES
    ('55555555-5555-5555-5555-555555555551', '22222222-2222-2222-2222-222222222221', 1, 'system:check'),
    ('55555555-5555-5555-5555-555555555552', '22222222-2222-2222-2222-222222222222', 1, 'system:check');
INSERT INTO families (family_id, created_by) VALUES
    ('33333333-3333-3333-3333-333333333331', 'system:check'),
    ('33333333-3333-3333-3333-333333333332', 'system:check');

-- ---------------------------------------------------------------------------
-- Gegenproben
-- ---------------------------------------------------------------------------

-- 14: „Stundenzahl in halben Stunden" — und mehr als null.
SELECT pg_temp.expect_reject(
    '14 — Eintrag über null Stunden',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 0,
               'Garten', '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '14 — Eintrag ohne Tätigkeit',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 4,
               '', '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

-- „und wer sie bestätigt: die Person, die diese Aufgabe verantwortet hat …
-- nicht frei geschrieben" — der Eintrag braucht sie.
SELECT pg_temp.expect_reject(
    '14 — Eintrag ohne bestätigende Person',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 4,
               'Garten', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '14 — bestätigende Person, die es nicht gibt',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 4,
               'Garten', '55555555-5555-5555-5555-555555555559', 'system:check')$q$);

-- E3 — „Schuljahr = Startjahr … 1.8.2026–31.7.2027" (04): der 5. Oktober 2026
-- gehört ins Schuljahr 2026 und in kein anderes; 14 kennt dafür keinen
-- Spielraum („was später kommt oder liegen bleibt, zählt nicht").
SELECT pg_temp.expect_reject(
    '14 — Stunde vom Oktober 2026 dem Schuljahr 2030 zugerechnet',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2030, DATE '2026-10-05', 4,
               'Garten', '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '14 — Stunde vom Juli, dem letzten Monat ihres Schuljahres, ins nächste gezogen',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2027, DATE '2027-07-31', 4,
               'Garten', '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '14 — der 1. August ist der erste Tag des neuen Schuljahres',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2027, DATE '2027-08-01', 4,
               'Garten', '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

INSERT INTO parent_work_entries (parent_work_entry_id, family_id, school_year, worked_on,
                                 half_hours, activity, confirming_employee_id, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661',
            '33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 4,
            'Gartenaktion Herbst', '55555555-5555-5555-5555-555555555551', 'system:check');

-- 14: „Ein unbestätigter Eintrag zählt auch dann nicht, wenn ihm niemand
-- widersprochen hat" — bestätigt und abgelehnt schließen einander aus.
SELECT pg_temp.expect_reject(
    '14 — Eintrag zugleich bestätigt und abgelehnt',
    $q$UPDATE parent_work_entries SET confirmed_at = now(), rejected_at = now()
        WHERE parent_work_entry_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_accept(
    '14 — Eintrag bestätigt',
    $q$UPDATE parent_work_entries SET confirmed_at = now()
        WHERE parent_work_entry_id = '66666666-6666-6666-6666-666666666661'$q$);

-- „Haben die Eltern die falsche Person gewählt, lehnt sie ab und die Eltern
-- tragen die Stunde mit der richtigen neu ein" — derselbe Tag darf zweimal
-- stehen, es gibt keinen Schlüssel darüber.
SELECT pg_temp.expect_accept(
    '14 — Stunde nach Ablehnung mit der richtigen Person neu eingetragen',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, rejected_at,
                                        created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-06', 4,
               'Schulfest', '55555555-5555-5555-5555-555555555551', now(), 'system:check');
       INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, confirming_employee_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-06', 4,
               'Schulfest', '55555555-5555-5555-5555-555555555552', 'system:check')$q$);

-- „gezählt wird für die Familie, gleich wer gearbeitet hat" — der Eintrag hängt
-- an der Familie und nicht an einer Person.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'parent_work_entries' AND column_name = 'person_id') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Eintrag hängt an einer Person statt an der Familie';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 14 — der Eintrag hängt an der Familie, nicht an einer Person';
END $$;

-- 00: „Was seinen Namen anderswo trägt, überlebt ihn: eine bestätigte
-- Mitarbeitsstunde (14) folgt ihrer eigenen Frist." Ohne den Namen scheitert das
-- Nullsetzen am CHECK — der Eintrag kann nicht namenlos zurückbleiben.
SELECT pg_temp.expect_reject(
    '00 — Mitarbeitender gelöscht, ohne dass sein Name am Eintrag steht',
    $q$DELETE FROM employees WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

SELECT pg_temp.expect_accept(
    '00 — der Eintrag überlebt den Mitarbeitenden, sein Name bleibt daran',
    $q$UPDATE parent_work_entries SET confirming_employee_name = 'Hausmeister Muster'
        WHERE confirming_employee_id = '55555555-5555-5555-5555-555555555551';
       DELETE FROM employees WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM parent_work_entries
                    WHERE confirming_employee_id IS NULL
                      AND confirming_employee_name = 'Hausmeister Muster') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Eintrag überlebt seinen Bestätiger nicht';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 00 — der Eintrag steht weiter, mit dem Namen statt der Kennung';
END $$;

-- 03: „ebenso die Elternbonus-Daten (14), die dieselbe Frist tragen" — die
-- Einträge folgen der Schuljahresfrist und nicht dem Austritt; die Familie geht
-- deshalb erst, wenn der Jahreslauf sie geräumt hat, wie im Putzdienst.
SELECT pg_temp.expect_reject(
    '03 — Familie gelöscht, obwohl ihre Einträge noch ihre Frist laufen',
    $q$DELETE FROM families WHERE family_id = '33333333-3333-3333-3333-333333333331'$q$);

-- 14: „einmal jährlich zum Schuljahresanfang fällt … das Schuljahr davor".
SELECT pg_temp.expect_accept(
    '14 — nach dem Jahreslauf geht die Familie',
    $q$DELETE FROM parent_work_entries
        WHERE family_id = '33333333-3333-3333-3333-333333333331';
       DELETE FROM families WHERE family_id = '33333333-3333-3333-3333-333333333331'$q$);

-- 14: „Drei Werte im System gehören der Geschäftsführung: der Monatsbetrag
-- (derzeit 10 €) und die beiden Pflichtstundenzahlen (derzeit 15 und 10); sie
-- ändert sie mit Gültigkeit zum 1. August." Sie stehen als `configured_values`
-- und nicht in dieser Domäne — die Probe hält die drei Codes an den Namen fest,
-- unter denen querschnitt-schema.sql sie aufzählt und die Anwendung sie liest.
SELECT pg_temp.expect_accept(
    '14 — die drei Werte des Bonus haben ihren Ort, mit Gültigkeit zum 1. August',
    $q$INSERT INTO configured_values (code, valid_from, value, created_by) VALUES
        ('parent_bonus_monthly_cents',            DATE '2026-08-01', 1000, 'system:check'),
        ('parent_bonus_required_hours_primary',   DATE '2026-08-01',   15, 'system:check'),
        ('parent_bonus_required_hours_secondary', DATE '2026-08-01',   10, 'system:check')$q$);

DO $$
DECLARE fehlend text;
BEGIN
    SELECT string_agg(c, ', ') INTO fehlend
    FROM unnest(ARRAY['parent_bonus_monthly_cents',
                      'parent_bonus_required_hours_primary',
                      'parent_bonus_required_hours_secondary']) AS c
    WHERE NOT EXISTS (SELECT 1 FROM configured_values v WHERE v.code = c);
    IF fehlend IS NOT NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Wert des Bonus ohne Ort: %', fehlend;
    END IF;
    RAISE NOTICE 'ok: die drei Werte des Bonus stehen als Werte im System';
END $$;

DO $$ BEGIN RAISE NOTICE 'elternbonus-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
