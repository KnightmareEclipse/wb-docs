-- Prüfskript zu mensa-schema.sql.
--
-- Sollstand: 5 Tabellen — meal_variants, meal_prices, child_meal_profiles,
-- meal_subscriptions und meal_subscription_days, dazu ein Lese-Index für die
-- Tagesliste der Küche.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f mensa-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY['meal_variants', 'meal_prices', 'child_meal_profiles',
                      'meal_subscriptions', 'meal_subscription_days']) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 5 Tabellen vorhanden';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_meal_subscriptions', 'pk_child_meal_profiles',
        'fk_child_meal_profiles_child', 'fk_meal_subscriptions_terms',
        'uq_child_meal_profiles', 'ex_meal_subscriptions_period', 'ex_meal_subscription_days_period',
        'ck_meal_subscription_days_weekday',
        'ck_meal_subscription_days_period', 'ck_meal_subscriptions_period',
        'ck_meal_subscriptions_start',
        'uq_meal_prices', 'ck_meal_prices_days', 'ck_meal_prices_amount'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;
    IF to_regclass('public.ix_meal_subscription_days_weekday') IS NULL THEN
        RAISE EXCEPTION 'Fehlender Index: ix_meal_subscription_days_weekday';
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
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Kind',  'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Kind2', 'Muster', 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by) VALUES
    ('44444444-4444-4444-4444-444444444441', '22222222-2222-2222-2222-222222222221',
     '33333333-3333-3333-3333-333333333333', DATE '2016-05-01', 'system:check'),
    ('44444444-4444-4444-4444-444444444442', '22222222-2222-2222-2222-222222222222',
     '33333333-3333-3333-3333-333333333333', DATE '2018-05-01', 'system:check');
-- Die Textsorte steht als Wert im System; eine Fassung ohne sie gibt es nicht.
INSERT INTO contract_text_kinds (code, name, kind_class, created_by) VALUES
    ('meal_terms', 'Essensbedingungen', 'agreed', 'system:check');

INSERT INTO contract_texts (contract_text_id, code, valid_from, body, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'meal_terms', DATE '2026-08-01', 'Essensbedingungen', 'system:check');
INSERT INTO meal_variants (meal_variant_id, code, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'all', 'isst alles'), (2, 'vegetarian', 'vegetarisch');

-- ---------------------------------------------------------------------------
-- Gegenproben
-- ---------------------------------------------------------------------------

-- 11: „Die Variante steht am Kind" — genau eine je Kind.
INSERT INTO child_meal_profiles (child_id, meal_variant_id, created_by)
    VALUES ('44444444-4444-4444-4444-444444444441', 2, 'system:check');
SELECT pg_temp.expect_reject(
    '11 — zweite Essensvariante desselben Kindes',
    $q$INSERT INTO child_meal_profiles (child_id, meal_variant_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', 1, 'system:check')$q$);

-- „die Eltern eines Hortkindes tragen sie im Portal genauso ein, obwohl sie
-- sich nie anmelden" — die Variante hängt an keinem Abo.
SELECT pg_temp.expect_accept(
    '11 — Essensvariante eines Kindes ohne Abo',
    $q$INSERT INTO child_meal_profiles (child_id, meal_variant_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444442', 2, 'system:check')$q$);

-- 11: „ein Betrag je Esstag und Monat … ein Wert im System" — ab September 2026
-- eine Staffel je Zahl der Esstage, die sich nicht rechnen lässt.
SELECT pg_temp.expect_accept(
    '11 — Essensbeitrag je Zahl der Esstage',
    $q$INSERT INTO meal_prices (weekday_count, valid_from, monthly_amount_cents, created_by)
       VALUES (1, DATE '2026-09-01',  2150, 'system:check'),
              (2, DATE '2026-09-01',  4250, 'system:check'),
              (3, DATE '2026-09-01',  6350, 'system:check'),
              (4, DATE '2026-09-01',  8450, 'system:check'),
              (5, DATE '2026-09-01', 10500, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    'hebel.md — angekündigte Erhöhung neben dem geltenden Essensbeitrag',
    $q$INSERT INTO meal_prices (weekday_count, valid_from, monthly_amount_cents, created_by)
       VALUES (1, DATE '2027-09-01', 2250, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — zweiter Essensbeitrag zu derselben Tageszahl und demselben Tag',
    $q$INSERT INTO meal_prices (weekday_count, valid_from, monthly_amount_cents, created_by)
       VALUES (1, DATE '2026-09-01', 3000, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '11 — Essensbeitrag für einen sechsten Wochentag',
    $q$INSERT INTO meal_prices (weekday_count, valid_from, monthly_amount_cents, created_by)
       VALUES (6, DATE '2026-09-01', 12000, 'system:check')$q$);

-- stammdaten-schema.sql (04): „eine Schuljahrestabelle gibt es nicht, das Jahr
-- folgt aus dem Datum" — am Abo folgt es aus `starts_on`. Stand es zusätzlich
-- als Spalte, band es nichts an seine Quelle: ein Abo vom 1.10.2026 mit
-- `school_year = 2019` ging durch (rules.md Abschnitt 1).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'meal_subscriptions' AND column_name = 'school_year') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — das Schuljahr steht neben seiner Ableitung';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 11 — das Schuljahr des Abos hat keine eigene Spalte';
END $$;

-- 11: „Je Kind ein laufendes Essensabo, nie zwei nebeneinander."
INSERT INTO meal_subscriptions (meal_subscription_id, child_id, starts_on,
                                ends_on, terms_contract_text_id, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551',
            '44444444-4444-4444-4444-444444444441',
            DATE '2026-10-01', DATE '2027-07-31', 1, 'system:check');
SELECT pg_temp.expect_reject(
    '11 — zweites Abo desselben Kindes im selben Schuljahr',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441',
               DATE '2026-11-01', DATE '2027-07-31', 1, 'system:check')$q$);

-- M4 — 11: „Je Kind ein laufendes Essensabo, nie zwei nebeneinander." Das
-- greift auch dort, wo das gerechnete Schuljahr verschieden ist: ein Abo, das
-- mitten in ein laufendes hineinreicht, liegt daneben.
SELECT pg_temp.expect_reject(
    '11 — Abo, das in ein laufendes desselben Kindes hineinreicht',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441',
               DATE '2027-02-01', DATE '2028-07-31', 1, 'system:check')$q$);

-- 11: „Kein Stichtag, angemeldet wird jederzeit" — wer zum 31. Januar kündigt,
-- meldet sich im selben Schuljahr neu an, und das zweite Abo steht hinter dem
-- ersten statt neben ihm.
SELECT pg_temp.expect_accept(
    '11 — neues Abo im selben Schuljahr nach der Kündigung zum 31. Januar',
    $q$UPDATE meal_subscriptions SET ends_on = DATE '2027-01-31'
         WHERE meal_subscription_id = '55555555-5555-5555-5555-555555555551';
       INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441',
               DATE '2027-03-01', DATE '2027-07-31', 1, 'system:check')$q$);

-- „endet immer am 31. Juli … über das Schuljahr hinaus läuft nichts weiter" —
-- ein Abo des Folgejahres ist ein neues.
SELECT pg_temp.expect_accept(
    '11 — Abo desselben Kindes im nächsten Schuljahr',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441',
               DATE '2027-10-01', DATE '2028-07-31', 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '11 — Abo, das endet, bevor es beginnt',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444442',
               DATE '2027-07-01', DATE '2026-10-01', 1, 'system:check')$q$);

-- 11: „Das Abo beginnt frühestens am 1. Oktober … Wer später anmeldet, beginnt
-- zum nächsten Monatsersten."
SELECT pg_temp.expect_reject(
    '11 — Abo, das mitten im Monat beginnt',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444442',
               DATE '2026-11-15', DATE '2027-07-31', 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '11 — Abo, das schon im September beginnt',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444442',
               DATE '2026-09-01', DATE '2027-07-31', 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '11 — Abo, das schon im August beginnt',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on,
                                       terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444442',
               DATE '2026-08-01', DATE '2027-07-31', 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '11 — Abo ohne Fassung der Essensbedingungen',
    $q$INSERT INTO meal_subscriptions (child_id, starts_on, ends_on, created_by)
       VALUES ('44444444-4444-4444-4444-444444444442',
               DATE '2026-10-01', DATE '2027-07-31', 'system:check')$q$);

-- 11: „Gebucht wird der Wochentag im Schuljahres-Abo."
INSERT INTO meal_subscription_days (meal_subscription_id, weekday, valid_from, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551', 1, DATE '2026-10-01', 'system:check');
SELECT pg_temp.expect_reject(
    '11 — derselbe Wochentag zweimal ab demselben Tag',
    $q$INSERT INTO meal_subscription_days (meal_subscription_id, weekday, valid_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, DATE '2026-10-01', 'system:check')$q$);

-- M2 — „Je Kind und Tag gibt es höchstens ein Essen": der offene Montag ab
-- 1.10. und ein zweiter ab 1.12. gälten am 15.12. beide, und der Monatsbeitrag
-- zählte ihn doppelt.
SELECT pg_temp.expect_reject(
    '11 — derselbe Wochentag ab einem späteren Tag, während der erste noch läuft',
    $q$INSERT INTO meal_subscription_days (meal_subscription_id, weekday, valid_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, DATE '2026-12-01', 'system:check')$q$);

-- Beendet und danach neu ist dagegen kein Nebeneinander: „Weniger Tage … nur
-- zum 31. Januar", und ab dem 1. Februar ist der Tag wieder frei.
SELECT pg_temp.expect_accept(
    '11 — derselbe Wochentag wieder, nachdem der erste beendet wurde',
    $q$UPDATE meal_subscription_days SET valid_until = DATE '2027-01-31'
         WHERE meal_subscription_id = '55555555-5555-5555-5555-555555555551'
           AND weekday = 1;
       INSERT INTO meal_subscription_days (meal_subscription_id, weekday, valid_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, DATE '2027-02-01',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '11 — Essenstag am Samstag',
    $q$INSERT INTO meal_subscription_days (meal_subscription_id, weekday, valid_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 6, DATE '2026-10-01', 'system:check')$q$);

-- „Mehr Tage jederzeit, sie gelten ab dem nächsten Monatsersten."
SELECT pg_temp.expect_accept(
    '11 — zusätzlicher Wochentag ab einem späteren Monatsersten',
    $q$INSERT INTO meal_subscription_days (meal_subscription_id, weekday, valid_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, DATE '2026-12-01', 'system:check')$q$);

-- „Weniger Tage … nur zum 31. Januar" — der Tag wird beendet, nicht gelöscht.
SELECT pg_temp.expect_accept(
    '11 — Wochentag zum 31. Januar beendet',
    $q$UPDATE meal_subscription_days SET valid_until = DATE '2027-01-31'
        WHERE meal_subscription_id = '55555555-5555-5555-5555-555555555551'
          AND weekday = 3$q$);

SELECT pg_temp.expect_reject(
    '11 — Wochentag, dessen Ende vor seinem Beginn liegt',
    $q$UPDATE meal_subscription_days SET valid_until = DATE '2026-11-01'
        WHERE meal_subscription_id = '55555555-5555-5555-5555-555555555551'
          AND weekday = 3$q$);

-- „solange ein solcher Tag noch nicht begonnen hat, nehmen sie ihn wieder
-- zurück … eine Buchung, die nie lief" — und danach ist derselbe Tag ab einem
-- neuen Monatsersten wieder buchbar.
SELECT pg_temp.expect_accept(
    '11 — zurückgenommener Tag, danach neu ab einem späteren Monatsersten',
    $q$DELETE FROM meal_subscription_days
         WHERE meal_subscription_id = '55555555-5555-5555-5555-555555555551'
           AND weekday = 3;
       INSERT INTO meal_subscription_days (meal_subscription_id, weekday, valid_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, DATE '2027-02-01', 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Lösch-Lauf
-- ---------------------------------------------------------------------------
-- Die Löschanker dieser Datei an einem Durchlauf gezeigt statt behauptet. Er
-- ist die Stufe dieser Domäne im Lauf aus 17; die Reihenfolge über alle Domänen
-- steht im Kopf von querschnitt-schema.sql.

-- „Löschanker: die offene Aufbewahrungsfrist für Vertragsdaten (03)" — das Abo
-- trägt eine eigene Frist und hält das Kind bis dahin fest.
SELECT pg_temp.expect_reject(
    '03 — Kind gelöscht, während sein Essensabo noch seine Frist läuft',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

-- „Löschanker: geht mit dem Abo" — die Esstage nimmt es mit.
SELECT pg_temp.expect_accept(
    '11 — das Abo geht, und seine Esstage mit ihm',
    $q$DELETE FROM meal_subscriptions
        WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM meal_subscription_days) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — ein Esstag überlebt sein Abo';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 11 — kein Esstag überlebt sein Abo';
END $$;

-- „Löschanker: das letzte bestätigte Ende dieses Kindes, wie die
-- Gesundheitsangaben (03)" — die Variante steht am Kind und geht mit ihm.
SELECT pg_temp.expect_accept(
    '03/11 — nach dem Abo geht das Kind, und seine Essensvariante mit ihm',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM child_meal_profiles
                WHERE child_id = '44444444-4444-4444-4444-444444444441') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Essensvariante überlebt ihr Kind';
    END IF;
    -- Preise und Varianten tragen keinen Personenbezug und keinen Anker.
    IF NOT EXISTS (SELECT 1 FROM meal_prices) OR NOT EXISTS (SELECT 1 FROM meal_variants) THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — Preise oder Varianten gingen mit dem Kind';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 03 — keine Essensvariante überlebt ihr Kind, die Werteliste bleibt';
END $$;

DO $$ BEGIN RAISE NOTICE 'mensa-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
