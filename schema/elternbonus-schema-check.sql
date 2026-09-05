-- Prüfskript zu elternbonus-schema.sql.
--
-- Sollstand: vier Tabellen — parent_work_sessions, parent_work_session_audiences,
-- parent_work_signups und parent_work_entries —, dazu der Index für den
-- Erinnerungslauf, der für die Jahresrechnung und der einzige Trigger dieses
-- Schemas, der Anmeldefenster und Platzzahl hält. Geprüft wird zusätzlich, dass
-- die drei Werte im System und die Elternvertretung dort stehen, wo dieser Block
-- sie liest und ohne eigene Familienspalte, dass die Jahresliste als eine Aufgabe
-- bei der Buchhaltung Platz hat, und dass von der gestrichenen Bestätigung keine
-- Spalte übrig ist.
--
-- Setzt stammdaten-schema.sql, querschnitt-schema.sql und
-- klassenorganisation-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f elternbonus-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY['parent_work_sessions', 'parent_work_session_audiences',
                      'parent_work_signups', 'parent_work_entries']) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;

    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_parent_work_sessions_reminder', 'ix_parent_work_entries_year']) AS i
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

    -- „insbesondere keine Kategorie und kein Schlüssel"; und kein Betrag, der
    -- am Eintrag stünde statt gerechnet zu werden.
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'parent_work_entries'
                  AND column_name IN ('category_id', 'weight', 'amount_cents')) THEN
        RAISE EXCEPTION 'Der Eintrag führt Angaben, die Block 14 ausschließt';
    END IF;
    RAISE NOTICE 'ok: vier Tabellen, zwei Indizes, keine ausgeschlossene Spalte';
END $$;

-- 14: „Niemand bestätigt eine Stunde. Was die Eltern eintragen, zählt."
-- Bleibt eine der Spalten stehen, gibt es zwei Wahrheiten darüber, wann eine
-- Stunde zählt — und die Jahresrechnung könnte an der falschen hängen.
DO $$
DECLARE leftover text;
BEGIN
    SELECT string_agg(column_name, ', ') INTO leftover
    FROM information_schema.columns
    WHERE table_name = 'parent_work_entries'
      AND column_name IN ('confirming_employee_id', 'confirming_employee_name',
                          'confirmed_at', 'rejected_at', 'rejected_reason');
    IF leftover IS NOT NULL THEN
        RAISE EXCEPTION 'Die gestrichene Bestätigung lebt weiter: %', leftover;
    END IF;
    IF to_regclass('public.ix_parent_work_entries_waiting') IS NOT NULL THEN
        RAISE EXCEPTION 'Der Index der Bestätigungsaufgabe steht noch';
    END IF;
    RAISE NOTICE 'ok: keine Spur der Bestätigung mehr, weder Spalte noch Index';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY['pk_parent_work_sessions', 'ck_parent_work_sessions_activity',
                      'ck_parent_work_sessions_meeting_point',
                      'ck_parent_work_sessions_bring_along',
                      'ck_parent_work_sessions_created_by',
                      'ck_parent_work_sessions_capacity',
                      'ck_parent_work_sessions_description',
                      'ck_parent_work_sessions_reason',
                      'ck_parent_work_sessions_reason_needs_cancel',
                      'pk_parent_work_session_audiences',
                      'fk_parent_work_session_audiences_session',
                      'fk_parent_work_session_audiences_class',
                      'fk_parent_work_session_audiences_branch',
                      'uq_parent_work_session_audiences',
                      'ck_parent_work_session_audiences_form',
                      'ck_parent_work_session_audiences_grades',
                      'pk_parent_work_signups', 'fk_parent_work_signups_session',
                      'fk_parent_work_signups_person', 'uq_parent_work_signups',
                      'ck_parent_work_signups_created_by',
                      'pk_parent_work_entries', 'fk_parent_work_entries_family',
                      'fk_parent_work_entries_session',
                      'ck_parent_work_entries_hours',
                      'ck_parent_work_entries_activity',
                      'ck_parent_work_entries_school_year']) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger
                    WHERE tgname = 'trg_parent_work_signups_capacity') THEN
        RAISE EXCEPTION 'Fehlender Trigger: trg_parent_work_signups_capacity';
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints und der Kapazitäts-Trigger vorhanden';
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
    ('22222222-2222-2222-2222-222222222222', 'Mutter',      'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222223', 'Vater',       'Muster', 'system:check');
INSERT INTO employees (employee_id, person_id, house_id, created_by) VALUES
    ('55555555-5555-5555-5555-555555555551', '22222222-2222-2222-2222-222222222221', 1, 'system:check');
INSERT INTO families (family_id, created_by) VALUES
    ('33333333-3333-3333-3333-333333333331', 'system:check'),
    ('33333333-3333-3333-3333-333333333332', 'system:check');
INSERT INTO school_branches (school_branch_id, code, name, first_grade_level,
                             final_grade_level, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'GS', 'Grundschule', 1, 4, 'system:check');
INSERT INTO school_branches (school_branch_id, code, name, first_grade_level,
                             final_grade_level, created_by)
    OVERRIDING SYSTEM VALUE VALUES (2, 'RS', 'Realschule', 5, 10, 'system:check');
INSERT INTO classes (class_id, school_branch_id, start_school_year, stream, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (81, 1, 2024, 'a', 'system:check'),
    (82, 1, 2024, 'b', 'system:check');

-- ---------------------------------------------------------------------------
-- Der Einsatz
-- ---------------------------------------------------------------------------

-- Die vier benannten Einsätze liegen **relativ zu `now()`** und nicht auf einem
-- festen Datum: Der Trigger misst das Anmeldefenster daran, und ein fester Tag
-- machte dieses Skript an ihm rot, ohne dass sich am Schema etwas geändert
-- hätte. Der Tag im Kalender ist für keine Probe hier die Sache.
INSERT INTO parent_work_sessions (parent_work_session_id, starts_at, activity,
                                  meeting_point, bring_along, created_by)
    VALUES ('77777777-7777-7777-7777-777777777771',
            now() + interval '60 days', 'Gipswände bauen', 'Aula',
            'Sicherheitsschuhe, Handschuhe', 'entra:hausmeister');

-- 14 Z1: „Mehrere Einsätze sind mehrere Ausschreibungen, auch am selben Tag."
SELECT pg_temp.expect_accept(
    '14 — zweiter Einsatz am selben Tag',
    $q$INSERT INTO parent_work_sessions (parent_work_session_id, starts_at, activity,
                                         meeting_point, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772',
               now() + interval '60 days', 'Platten legen bei Fahrradständer',
               'Fahrradständer', 'entra:hausmeister')$q$);

INSERT INTO parent_work_sessions (parent_work_session_id, starts_at, activity,
                                  meeting_point, created_by)
    VALUES ('77777777-7777-7777-7777-777777777773',
            now() + interval '90 days', 'Schullandheim begleiten', 'Aula',
            'entra:sekretariat');

SELECT pg_temp.expect_reject(
    '14 — Einsatz ohne Tätigkeit',
    $q$INSERT INTO parent_work_sessions (starts_at, activity, meeting_point, created_by)
       VALUES (TIMESTAMPTZ '2027-05-08 14:00+02', '', 'Aula', 'entra:hausmeister')$q$);

SELECT pg_temp.expect_reject(
    '14 — Einsatz ohne Treffpunkt',
    $q$INSERT INTO parent_work_sessions (starts_at, activity, meeting_point, created_by)
       VALUES (TIMESTAMPTZ '2027-05-08 14:00+02', 'Decke streichen', '', 'entra:hausmeister')$q$);

-- „Freiwillig: nicht jeder Einsatz verlangt etwas" — aber leer statt fehlend
-- gibt es nicht.
SELECT pg_temp.expect_reject(
    '14 — Einsatz mit leerer Mitbringliste statt ohne',
    $q$INSERT INTO parent_work_sessions (starts_at, activity, meeting_point, bring_along,
                                         created_by)
       VALUES (TIMESTAMPTZ '2027-05-08 14:00+02', 'Decke streichen', 'Aula', '',
               'entra:hausmeister')$q$);

-- 14: „Wie viele Plätze — freiwillig, denn meistens gibt es keine Grenze."
SELECT pg_temp.expect_accept(
    '14 — Einsatz mit Platzzahl, weil nur vier Personen gebraucht werden',
    $q$INSERT INTO parent_work_sessions (starts_at, activity, meeting_point, capacity,
                                         created_by)
       VALUES (TIMESTAMPTZ '2027-05-15 14:00+02', 'Lampen montieren', 'Flur', 4,
               'entra:hausmeister')$q$);

SELECT pg_temp.expect_reject(
    '14 — Einsatz mit null Plätzen',
    $q$INSERT INTO parent_work_sessions (starts_at, activity, meeting_point, capacity,
                                         created_by)
       VALUES (TIMESTAMPTZ '2027-05-15 14:00+02', 'Lampen montieren', 'Flur', 0,
               'entra:hausmeister')$q$);

-- 14: „Ohne Angabe alle Familien." Die vier Formen, die der
-- Block nennt, müssen alle darstellbar sein — sonst steht in der Ausschreibung
-- eine Zielgruppe, die das System nicht kennt.
SELECT pg_temp.expect_accept(
    '14 — die 8a und die 8b: zwei benannte Klassen',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, class_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 81, 'entra:klassenlehrkraft'),
              ('77777777-7777-7777-7777-777777777772', 82, 'entra:klassenlehrkraft')$q$);

SELECT pg_temp.expect_accept(
    '14 — die ganze Realschule: eine Schulart ohne Stufengrenze',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, school_branch_id,
                                                 created_by)
       VALUES ('77777777-7777-7777-7777-777777777773', 2, 'entra:sekretariat')$q$);

SELECT pg_temp.expect_accept(
    '14 — ab Klasse 7: eine Spanne ohne Ende',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, grade_from, created_by)
       VALUES ('77777777-7777-7777-7777-777777777773', 7, 'entra:sekretariat')$q$);

SELECT pg_temp.expect_accept(
    '14 — Klasse 5 bis 7 der Realschule: Schulart und beide Grenzen',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, school_branch_id,
                                                 grade_from, grade_to, created_by)
       VALUES ('77777777-7777-7777-7777-777777777773', 2, 5, 7, 'entra:sekretariat')$q$);

SELECT pg_temp.expect_reject(
    '14 — dieselbe Klasse zweimal an demselben Einsatz',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, class_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 81, 'entra:klassenlehrkraft')$q$);

-- In beiden Formen sind drei der vier Spalten leer; ohne NULLS NOT DISTINCT
-- stünde derselbe Zuschnitt beliebig oft nebeneinander.
SELECT pg_temp.expect_reject(
    '14 — derselbe Zuschnitt zweimal an demselben Einsatz',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, school_branch_id,
                                                 grade_from, grade_to, created_by)
       VALUES ('77777777-7777-7777-7777-777777777773', 2, 5, 7, 'entra:sekretariat')$q$);

SELECT pg_temp.expect_reject(
    '14 — Einsatz für eine Klasse, die es nicht gibt',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, class_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 89, 'entra:klassenlehrkraft')$q$);

-- Eine benannte Klasse ODER ein Zuschnitt — beides zugleich wäre eine Zeile,
-- die zwei verschiedene Mengen meint.
SELECT pg_temp.expect_reject(
    '14 — Klasse und Zuschnitt in derselben Zeile',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, class_id,
                                                 school_branch_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 81, 1, 'entra:klassenlehrkraft')$q$);

-- Und eine Zeile ohne jede Angabe wäre „alle" — genau der Zustand, den die
-- fehlende Zeile schon trägt.
SELECT pg_temp.expect_reject(
    '14 — Zielgruppenzeile, die niemanden einschränkt',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 'entra:klassenlehrkraft')$q$);

SELECT pg_temp.expect_reject(
    '14 — Stufenspanne, die vor ihrem Anfang endet',
    $q$INSERT INTO parent_work_session_audiences (parent_work_session_id, grade_from, grade_to,
                                                 created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 8, 5, 'entra:klassenlehrkraft')$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM parent_work_session_audiences
                WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777771') THEN
        RAISE EXCEPTION 'Testaufbau falsch: der Baueinsatz sollte an alle gehen';
    END IF;
    RAISE NOTICE 'ok: keine Zeile heißt „alle Familien", ohne zweiten Zustand daneben';
END $$;

-- „Ausgeschrieben wird von der Schule, nie von den Eltern"
-- (elternbonus-schema.sql; 14 sagt es über die sechs Rollen, die es dürfen).
SELECT pg_temp.expect_reject(
    '14 — Einsatz von Eltern ausgeschrieben',
    $q$INSERT INTO parent_work_sessions (starts_at, activity, meeting_point, created_by)
       VALUES (TIMESTAMPTZ '2027-05-08 14:00+02', 'Decke streichen', 'Aula',
               'guardian:mutter')$q$);

-- ---------------------------------------------------------------------------
-- Die Anmeldung
-- ---------------------------------------------------------------------------

-- 14 Z2: „Melden sich an oder wieder ab" — und zwar je Person, damit zwei aus
-- derselben Familie kommen können.
SELECT pg_temp.expect_accept(
    '14 — zwei Personen derselben Familie melden sich zum selben Einsatz an',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by) VALUES
        ('77777777-7777-7777-7777-777777777771',
         '22222222-2222-2222-2222-222222222222', 'guardian:mutter'),
        ('77777777-7777-7777-7777-777777777771',
         '22222222-2222-2222-2222-222222222223', 'guardian:vater')$q$);

SELECT pg_temp.expect_reject(
    '14 — dieselbe Person zweimal an demselben Einsatz',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777771',
               '22222222-2222-2222-2222-222222222222', 'guardian:mutter')$q$);

SELECT pg_temp.expect_reject(
    '14 — Anmeldung an einem Einsatz, den es nicht gibt',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777779',
               '22222222-2222-2222-2222-222222222222', 'guardian:mutter')$q$);

-- 14 Z2: „Ist eine Platzzahl gesetzt und erreicht, ist zu." Hart, nicht
-- ungefähr: „Wenn nur vier Personen mitfahren dürfen, ist der fünfte einer zu
-- viel."
INSERT INTO parent_work_sessions (parent_work_session_id, starts_at, activity,
                                  meeting_point, capacity, created_by)
    VALUES ('77777777-7777-7777-7777-777777777774',
            now() + interval '120 days', 'Fahrt zum Landesmuseum', 'Bushaltestelle',
            2, 'entra:klassenlehrkraft');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222224', 'Erste',  'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222225', 'Zweite', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222226', 'Dritte', 'Muster', 'system:check');

SELECT pg_temp.expect_accept(
    '14 — zwei Anmeldungen auf zwei Plätze',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by) VALUES
        ('77777777-7777-7777-7777-777777777774',
         '22222222-2222-2222-2222-222222222224', 'guardian:eine'),
        ('77777777-7777-7777-7777-777777777774',
         '22222222-2222-2222-2222-222222222225', 'guardian:zweite')$q$);

SELECT pg_temp.expect_reject(
    '14 — die dritte Anmeldung auf zwei Plätze',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777774',
               '22222222-2222-2222-2222-222222222226', 'guardian:dritte')$q$);

-- Wer sich abmeldet, gibt seinen Platz frei — das ist der Sinn der Zählung
-- gegenüber einer festen Platznummer.
SELECT pg_temp.expect_accept(
    '14 — nach einer Abmeldung ist der Platz wieder zu haben',
    $q$DELETE FROM parent_work_signups
        WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777774'
          AND person_id = '22222222-2222-2222-2222-222222222224';
       INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777774',
               '22222222-2222-2222-2222-222222222226', 'guardian:dritte')$q$);

-- Ohne Platzzahl zählt der Trigger gar nicht erst.
SELECT pg_temp.expect_accept(
    '14 — beliebig viele Anmeldungen, wo keine Grenze steht',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777773',
               '22222222-2222-2222-2222-222222222224', 'guardian:eine'),
              ('77777777-7777-7777-7777-777777777773',
               '22222222-2222-2222-2222-222222222225', 'guardian:zweite'),
              ('77777777-7777-7777-7777-777777777773',
               '22222222-2222-2222-2222-222222222226', 'guardian:dritte')$q$);

-- Die harte Platzzahl gilt auch für die Anmeldung, die umgehängt wird: „daran
-- ändert auch der Zufall zweier gleichzeitiger Anmeldungen nichts" (14) — ein
-- `UPDATE` wäre sonst der Weg, auf dem zwei Personen auf einem Platz sitzen.
SELECT pg_temp.expect_reject(
    '14 — Anmeldung auf einen vollen Einsatz umgehängt',
    $q$UPDATE parent_work_signups
          SET parent_work_session_id = '77777777-7777-7777-7777-777777777774'
        WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777773'
          AND person_id = '22222222-2222-2222-2222-222222222224'$q$);

-- Die Absage löscht den Einsatz nicht: Die Angemeldeten bekommen ihre Mail,
-- und der Grund fährt darin mit.
SELECT pg_temp.expect_accept(
    '14 — Einsatz mit Grund abgesagt, seine Anmeldungen bleiben für die Mail stehen',
    $q$UPDATE parent_work_sessions SET cancelled_at = now(),
                                      cancellation_reason = 'Dauerregen angesagt'
        WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777772'$q$);

-- 14, „Abgesagt wird von beiden Seiten": Der abgesagte Einsatz bleibt als Beleg
-- stehen — er nimmt aber niemanden mehr auf, dessen Mail schon raus ist.
SELECT pg_temp.expect_reject(
    '14 — Anmeldung an einem abgesagten Einsatz',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772',
               '22222222-2222-2222-2222-222222222222', 'guardian:mutter')$q$);

-- 14, Fristen: „Ein Einsatz nimmt Anmeldungen an, bis er beginnt; danach ist er
-- vorbei und trägt nur noch seine Stunden."
INSERT INTO parent_work_sessions (parent_work_session_id, starts_at, activity,
                                  meeting_point, created_by)
    VALUES ('77777777-7777-7777-7777-777777777775',
            now() - interval '1 day', 'Schulfest aufbauen', 'Hof',
            'entra:sekretariat');
SELECT pg_temp.expect_reject(
    '14 — Anmeldung an einem Einsatz, der schon begonnen hat',
    $q$INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777775',
               '22222222-2222-2222-2222-222222222222', 'guardian:mutter')$q$);

-- Ein Grund ohne Absage beschriebe etwas, das nicht passiert ist.
SELECT pg_temp.expect_reject(
    '14 — Absagegrund an einem Einsatz, der stattfindet',
    $q$UPDATE parent_work_sessions SET cancellation_reason = 'Dauerregen angesagt'
        WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777773'$q$);

SELECT pg_temp.expect_reject(
    '14 — Einsatz mit leerer Beschreibung statt ohne',
    $q$INSERT INTO parent_work_sessions (starts_at, activity, description, meeting_point,
                                         created_by)
       VALUES (TIMESTAMPTZ '2027-05-08 14:00+02', 'Decke streichen', '', 'Aula',
               'entra:hausmeister')$q$);

-- ---------------------------------------------------------------------------
-- Der Eintrag
-- ---------------------------------------------------------------------------

-- 14 Z4: „Der Einsatz ist dabei kein Muss … und das ist kein Sonderfall,
-- sondern der häufigere Weg." Der Fahrdienst hat keine Ausschreibung.
SELECT pg_temp.expect_accept(
    '14 — Stunde ohne Einsatz, wie beim Fahrdienst',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 4,
               'Fahrdienst Grundschule', 'guardian:mutter')$q$);

INSERT INTO parent_work_entries (parent_work_entry_id, family_id, school_year, worked_on,
                                 half_hours, activity, parent_work_session_id, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661',
            '33333333-3333-3333-3333-333333333331', 2026, DATE '2027-04-24', 8,
            'Gipswände bauen', '77777777-7777-7777-7777-777777777771', 'guardian:mutter');

SELECT pg_temp.expect_reject(
    '14 — Stunde an einem Einsatz, den es nicht gibt',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, parent_work_session_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2027-04-24', 8,
               'Gipswände bauen', '77777777-7777-7777-7777-777777777779', 'guardian:mutter')$q$);

SELECT pg_temp.expect_reject(
    '14 — Eintrag über null Stunden',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 0,
               'Garten', 'guardian:mutter')$q$);

SELECT pg_temp.expect_reject(
    '14 — Eintrag ohne Tätigkeit',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2026, DATE '2026-10-05', 4,
               '', 'guardian:mutter')$q$);

-- E3 — „Schuljahr = Startjahr … 1.8.2026–31.7.2027" (04): der 5. Oktober 2026
-- gehört ins Schuljahr 2026 und in kein anderes; 14 kennt dafür keinen
-- Spielraum („was später kommt oder liegen bleibt, zählt nicht").
SELECT pg_temp.expect_reject(
    '14 — Stunde vom Oktober 2026 dem Schuljahr 2030 zugerechnet',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2030, DATE '2026-10-05', 4,
               'Garten', 'guardian:mutter')$q$);

SELECT pg_temp.expect_reject(
    '14 — Stunde vom Juli, dem letzten Monat ihres Schuljahres, ins nächste gezogen',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2027, DATE '2027-07-31', 4,
               'Garten', 'guardian:mutter')$q$);

SELECT pg_temp.expect_accept(
    '14 — der 1. August ist der erste Tag des neuen Schuljahres',
    $q$INSERT INTO parent_work_entries (family_id, school_year, worked_on, half_hours,
                                        activity, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331', 2027, DATE '2027-08-01', 4,
               'Garten', 'guardian:mutter')$q$);

-- „gezählt wird für die Familie, gleich wer gearbeitet hat" — der Eintrag hängt
-- an der Familie und nicht an einer Person. Die Anmeldung dagegen schon; beides
-- steht nebeneinander und darf nicht zusammenfallen.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'parent_work_entries' AND column_name = 'person_id') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Eintrag hängt an einer Person statt an der Familie';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_name = 'parent_work_signups' AND column_name = 'person_id') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Anmeldung kennt die Person nicht';
    END IF;
    RAISE NOTICE 'ok: der Eintrag hängt an der Familie, die Anmeldung an der Person';
END $$;

-- ---------------------------------------------------------------------------
-- Löschen
-- ---------------------------------------------------------------------------

-- Der Eintrag überlebt seinen Einsatz: Die Stunde bleibt mit ihrer kopierten
-- Tätigkeit stehen, die Anmeldungen gehen mit.
SELECT pg_temp.expect_accept(
    '14 — Einsatz gelöscht, die Stunde bleibt',
    $q$DELETE FROM parent_work_sessions
        WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777771'$q$);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM parent_work_entries
                    WHERE parent_work_entry_id = '66666666-6666-6666-6666-666666666661'
                      AND parent_work_session_id IS NULL
                      AND activity = 'Gipswände bauen') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Stunde verliert mit dem Einsatz ihre Tätigkeit';
    END IF;
    IF EXISTS (SELECT 1 FROM parent_work_signups
                WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777771') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Anmeldungen überleben ihren Einsatz';
    END IF;
    RAISE NOTICE 'ok: die Stunde überlebt den Einsatz, die Anmeldung nicht';
END $$;

-- Die Zielgruppe geht ebenfalls mit dem Einsatz — und mit der Klasse, denn sie
-- ist nichts als die Verbindung der beiden.
SELECT pg_temp.expect_accept(
    '14 — mit der Klasse geht die Zielgruppe, der Einsatz bleibt',
    $q$DELETE FROM classes WHERE class_id = 81$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM parent_work_session_audiences
                WHERE class_id = 81) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Zielgruppe überlebt ihre Klasse';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM parent_work_sessions
                    WHERE parent_work_session_id = '77777777-7777-7777-7777-777777777772') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Einsatz geht mit einer seiner Klassen';
    END IF;
    RAISE NOTICE 'ok: die Zielgruppe geht mit der Klasse, der Einsatz bleibt stehen';
END $$;

-- Eine Anmeldung ist ein Personendatum und geht mit der Person.
INSERT INTO parent_work_signups (parent_work_session_id, person_id, created_by)
    VALUES ('77777777-7777-7777-7777-777777777773',
            '22222222-2222-2222-2222-222222222223', 'guardian:vater');
SELECT pg_temp.expect_accept(
    '14 — mit der Person geht ihre Anmeldung',
    $q$DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222223'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM parent_work_signups
                WHERE person_id = '22222222-2222-2222-2222-222222222223') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Anmeldung überlebt ihre Person';
    END IF;
    RAISE NOTICE 'ok: keine Anmeldung ohne ihre Person';
END $$;

-- 03: „ebenso die Elternbonus-Daten (14), die dieselbe Frist tragen" — die
-- Einträge folgen der Schuljahresfrist und nicht dem Austritt; die Familie geht
-- deshalb erst, wenn der Jahreslauf sie geräumt hat, wie im Putzdienst.
SELECT pg_temp.expect_reject(
    '03 — Familie gelöscht, obwohl ihre Einträge noch ihre Frist laufen',
    $q$DELETE FROM families WHERE family_id = '33333333-3333-3333-3333-333333333331'$q$);

-- 14: „einmal jährlich zum Schuljahresanfang fällt nicht das gerade vergangene
-- Schuljahr, sondern das davor".
SELECT pg_temp.expect_accept(
    '14 — nach dem Jahreslauf geht die Familie',
    $q$DELETE FROM parent_work_entries
        WHERE family_id = '33333333-3333-3333-3333-333333333331';
       DELETE FROM families WHERE family_id = '33333333-3333-3333-3333-333333333331'$q$);

-- 14, Sonderfälle: „Erlassen wird jeder Familie, in der der Amtsträger
-- sorgeberechtigt ist." Der Weg läuft von `class_representatives.person_id`
-- über `family_guardians` — das Amt selbst benennt keine Familie, und eine
-- Spalte dafür wäre der zweite Ort für dieselbe Zuordnung. Die Probe steht hier
-- und nicht bei der Klassenorganisation, weil allein diese Domäne den Weg geht.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'class_representatives' AND column_name = 'family_id') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — das Amt benennt eine Familie, statt sie über die Sorgeberechtigung zu finden';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_name = 'family_guardians' AND column_name = 'person_id') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Weg vom Amtsträger zu seinen Familien fehlt';
    END IF;
    RAISE NOTICE 'ok: der Erlass findet seine Familien über die Sorgeberechtigung';
END $$;

-- 14 Z6: „Legt die Jahresliste als **eine** Aufgabe bei der Buchhaltung an", und
-- „die Rückzahlung des Schuljahres ist eine Aufgabe mit der Jahresliste, nicht
-- eine je Familie" (14, Fremdsysteme). Der Bezug ist damit das Schuljahr; die
-- Spalte steht an `sync_tasks` (querschnitt-schema.sql), diese Domäne legt keine
-- eigene an.
INSERT INTO roles (code, name, created_by)
    VALUES ('accounting', 'Buchhaltung', 'system:check');
INSERT INTO sync_targets (code, name, role_id, created_by)
    VALUES ('parent_work_annual_list', 'Jahresliste Elternbonus verrechnen',
            (SELECT role_id FROM roles WHERE code = 'accounting'), 'system:check');
SELECT pg_temp.expect_accept(
    '14 — die Jahresliste ist eine Aufgabe bei der Buchhaltung, Bezug das Schuljahr',
    $q$INSERT INTO sync_tasks (sync_target_id, school_year, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets
                 WHERE code = 'parent_work_annual_list'),
               2026, 'Rückzahlungen des Schuljahres 2026 mit dem Schulgeld verrechnen',
               'system:parent_work_annual_run')$q$);

-- „**Eine** Aufgabe … nicht eine je Familie": Der Index über Aufgabenart und
-- Bezug lässt die zweite offene für dasselbe Schuljahr nicht zu — ein zweiter
-- Lauf ersetzt sie, statt sie danebenzulegen.
SELECT pg_temp.expect_reject(
    '14 — eine zweite offene Aufgabe für dasselbe Schuljahr',
    $q$INSERT INTO sync_tasks (sync_target_id, school_year, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets
                 WHERE code = 'parent_work_annual_list'),
               2026, 'Noch einmal dasselbe Schuljahr', 'system:parent_work_annual_run')$q$);

DO $$ BEGIN RAISE NOTICE 'elternbonus-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
