-- Prüfskript zu gesundheit-schema.sql.
--
-- Sollstand: 13 Tabellen — die Konfiguration health_trait_types,
-- health_value_kinds, health_fields, health_type_fields,
-- health_visibility_scopes, health_field_visibility und
-- measles_presentation_types; die Antworten child_health_records,
-- child_health_answers, health_traits und health_trait_values; dazu
-- health_emergency_accesses und measles_proofs. Ein partieller Unique-Index
-- gegen die zweite Zeile einer Kategorie, die nur eine erlaubt, und ein Index
-- auf dem Paar (Kategorie, Feld), über das jede Sicht filtert.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f gesundheit-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY['health_trait_types', 'health_value_kinds', 'health_fields',
                      'health_type_fields', 'health_visibility_scopes',
                      'health_field_visibility', 'measles_presentation_types',
                      'child_health_records', 'child_health_answers',
                      'health_traits', 'health_trait_values',
                      'health_emergency_accesses', 'measles_proofs']) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 13 Tabellen vorhanden';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_health_trait_types', 'uq_health_trait_types_multiple',
        'pk_health_value_kinds', 'ck_health_value_kinds_code',
        'pk_health_fields', 'uq_health_fields_kind', 'fk_health_fields_kind',
        'pk_health_type_fields', 'fk_health_type_fields_type',
        'fk_health_type_fields_field',
        'pk_health_visibility_scopes', 'pk_health_field_visibility',
        'fk_health_field_visibility_pair',
        'pk_child_health_records', 'uq_child_health_records',
        'ck_child_health_records_answer',
        'pk_child_health_answers', 'uq_child_health_answers',
        'uq_child_health_answers_type', 'ck_child_health_answers_answer',
        'pk_health_traits', 'fk_health_traits_answer', 'fk_health_traits_type',
        'uq_health_traits_type',
        'pk_health_trait_values', 'fk_health_trait_values_trait',
        'fk_health_trait_values_pair', 'fk_health_trait_values_kind',
        'fk_health_trait_values_document', 'uq_health_trait_values',
        'ck_health_trait_values_kind', 'ck_health_trait_values_text',
        'ck_health_trait_values_period',
        'pk_health_emergency_accesses', 'ck_health_emergency_accesses_created_by',
        'pk_measles_proofs', 'uq_measles_proofs'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;
    IF to_regclass('public.ix_health_traits_single') IS NULL THEN
        RAISE EXCEPTION 'Fehlender Index: ix_health_traits_single';
    END IF;
    IF to_regclass('public.ix_health_trait_values_pair') IS NULL THEN
        RAISE EXCEPTION 'Fehlender Index: ix_health_trait_values_pair';
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints und Indizes vorhanden';
END $$;

-- Die drei ineinanderliegenden Sichten von früher sind fort — mit ihnen die
-- Flags, die sie trugen. Bleibt eine davon stehen, gibt es zwei Wahrheiten
-- darüber, wer was sieht.
DO $$
DECLARE leftover text;
BEGIN
    SELECT string_agg(column_name, ', ') INTO leftover
    FROM information_schema.columns
    WHERE table_name IN ('health_trait_types', 'health_traits')
      AND column_name IN ('is_everyday_relevant', 'is_kitchen_relevant',
                          'needs_permission', 'is_medication',
                          'has_treatment_reason', 'is_emergency_medication',
                          'description', 'treatment_reason', 'treatment_from',
                          'treatment_until', 'has_certificate',
                          'certificate_document_id', 'permission_granted_at',
                          'permission_declined_at', 'self_administered',
                          'emergency_description');
    IF leftover IS NOT NULL THEN
        RAISE EXCEPTION 'Feste Merkmalsspalten überlebt: %', leftover;
    END IF;
    RAISE NOTICE 'ok: keine festen Merkmalsspalten mehr, die Tiefe steht in health_type_fields';
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
INSERT INTO persons (person_id, first_name, last_name, created_by)
    VALUES ('22222222-2222-2222-2222-222222222221', 'Kind', 'Muster', 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444441',
            '22222222-2222-2222-2222-222222222221',
            '33333333-3333-3333-3333-333333333333', DATE '2018-05-01', 'system:check');

INSERT INTO health_value_kinds (code, name) VALUES
    ('bool', 'Ja/Nein'), ('text', 'Text'), ('date', 'Datum'),
    ('period', 'Zeitraum'), ('document', 'Dokument');

-- Fünf Kategorien mit verschiedener Tiefe: die Zeckenerlaubnis ist ein
-- Ja/Nein, die chronische Erkrankung trägt vier Felder.
INSERT INTO health_trait_types (health_trait_type_id, code, name, allows_multiple, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'allergy',        'Allergie',                true,  'system:check'),
    (2, 'emergency_med',  'Notfallmedikament',       true,  'system:check'),
    (3, 'diagnosis',      'Chronische Erkrankung',   true,  'system:check'),
    (4, 'school_support', 'Schulbegleitung',         false, 'system:check'),
    (5, 'tick_removal',   'Zeckenentfernung',        false, 'system:check');

INSERT INTO health_fields (health_field_id, code, name, value_kind_code, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'label',         'Bezeichnung',            'text',     'system:check'),
    (2, 'note',          'Beachten',               'text',     'system:check'),
    (3, 'permission',    'Erlaubnis',              'bool',     'system:check'),
    (4, 'certificate',   'Attest',                 'document', 'system:check'),
    (5, 'period',        'Zeitraum',               'period',   'system:check'),
    (6, 'vaccinated_on', 'Datum der letzten Impfung', 'date',  'system:check');

INSERT INTO health_type_fields (health_trait_type_id, health_field_id, created_by) VALUES
    (1, 1, 'system:check'), (1, 2, 'system:check'),
    (2, 1, 'system:check'), (2, 2, 'system:check'), (2, 3, 'system:check'),
    (3, 1, 'system:check'), (3, 2, 'system:check'), (3, 4, 'system:check'),
    (3, 5, 'system:check'),
    (4, 1, 'system:check'),
    (5, 3, 'system:check');

INSERT INTO health_visibility_scopes (health_visibility_scope_id, code, name,
                                      is_emergency, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'kitchen',   'Küche',            false, 'system:check'),
    (2, 'care',      'Betreuung',        false, 'system:check'),
    (3, 'sports',    'Sportunterricht',  false, 'system:check'),
    (4, 'class_lead', 'Klassenleitung',  false, 'system:check'),
    (5, 'emergency', 'Notfall',          true,  'system:check');

INSERT INTO measles_presentation_types (measles_presentation_type_id, code, name)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'vaccination_card', 'Impfpass'), (2, 'certificate', 'ärztliche Bescheinigung');

INSERT INTO sharepoint_libraries (sharepoint_library_id, code, name, graph_drive_id, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'generated', 'Erzeugt', 'b!x', 'system:check');
INSERT INTO document_types (document_type_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'certificate', 'Attest', 'system:check');
INSERT INTO documents (document_id, child_id, document_type_id, sharepoint_library_id,
                       graph_item_id, filed_at, created_by)
    VALUES ('99999999-9999-9999-9999-999999999991',
            '44444444-4444-4444-4444-444444444441', 1, 1, '01ATT', now(), 'system:check');

-- ---------------------------------------------------------------------------
-- Der Umbau selbst: Sichten, die nicht ineinanderliegen
-- ---------------------------------------------------------------------------

-- Der Fall, an dem die alte Leiter zerbrach: Der Sportunterricht sieht den
-- Handlungshinweis einer chronischen Erkrankung, nicht ihre Bezeichnung — die
-- Küche dagegen die Bezeichnung der Allergie. Weder liegt die eine Sicht in der
-- anderen noch beide in einer dritten.
SELECT pg_temp.expect_accept(
    '3a — Sport sieht den Hinweis zur Erkrankung, nicht ihre Bezeichnung',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id, created_by)
       VALUES (3, 3, 2, 'system:check'), (3, 1, 2, 'system:check'),
              (3, 5, 3, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '11 — die Küche sieht Bezeichnung und Hinweis der Allergie, sonst nichts',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id, created_by)
       VALUES (1, 1, 1, 'system:check'), (1, 1, 2, 'system:check')$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM health_field_visibility v
                WHERE v.health_visibility_scope_id = 3
                  AND (v.health_trait_type_id, v.health_field_id) = (3, 1)) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Sport sieht die Diagnose';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM health_field_visibility v
                    WHERE v.health_visibility_scope_id = 1
                      AND (v.health_trait_type_id, v.health_field_id) = (1, 1))
       OR EXISTS (SELECT 1 FROM health_field_visibility v
                   WHERE v.health_visibility_scope_id = 3
                     AND (v.health_trait_type_id, v.health_field_id) = (1, 1)) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Sichten liegen doch ineinander';
    END IF;
    RAISE NOTICE 'ok: die Sichten überschneiden sich, ohne einander zu enthalten';
END $$;

-- Sichtbar machen lässt sich nur, was die Kategorie überhaupt erhebt.
SELECT pg_temp.expect_reject(
    '3a — Sichtbarkeit für ein Feld, das diese Kategorie nicht hat',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id, created_by)
       VALUES (3, 5, 1, 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Die drei Zustände je Kategorie
-- ---------------------------------------------------------------------------

INSERT INTO child_health_records (child_health_record_id, child_id, answered_at, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551',
            '44444444-4444-4444-4444-444444444441', now(), 'system:check');

SELECT pg_temp.expect_reject(
    '08 — Bestand zugleich beantwortet und verweigert',
    $q$UPDATE child_health_records SET declined_at = now()
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'$q$);

SELECT pg_temp.expect_reject(
    '09 — zweiter Gesundheitsbestand desselben Kindes',
    $q$INSERT INTO child_health_records (child_id, declined_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', now(), 'system:check')$q$);

-- Zustand 1: gefragt, es gibt nichts — eine Antwortzeile ohne Merkmal.
SELECT pg_temp.expect_accept(
    '3a — beantwortet, ohne dass es etwas zu nennen gibt',
    $q$INSERT INTO child_health_answers (child_health_record_id, health_trait_type_id,
                                         answered_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, now(), 'system:check')$q$);

-- Zustand 2: gefragt, will nicht sagen — die Freiwilligkeit je Kategorie.
SELECT pg_temp.expect_accept(
    '3a — eine Kategorie ausdrücklich nicht beantwortet, andere schon',
    $q$INSERT INTO child_health_answers (child_health_record_id, health_trait_type_id,
                                         declined_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 4, now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — Kategorie zugleich beantwortet und verweigert',
    $q$INSERT INTO child_health_answers (child_health_record_id, health_trait_type_id,
                                         answered_at, declined_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, now(), now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — dieselbe Kategorie zweimal beantwortet',
    $q$INSERT INTO child_health_answers (child_health_record_id, health_trait_type_id,
                                         answered_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, now(), 'system:check')$q$);

-- Zustand 3 ist die fehlende Zeile: Kategorie 3 wurde nie gefragt.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM child_health_answers
                WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'
                  AND health_trait_type_id = 3) THEN
        RAISE EXCEPTION 'Testaufbau falsch: Kategorie 3 sollte ungefragt sein';
    END IF;
    RAISE NOTICE 'ok: „nie gefragt" ist von „nichts vorhanden" unterscheidbar';
END $$;

-- ---------------------------------------------------------------------------
-- Merkmal und Werte
-- ---------------------------------------------------------------------------

INSERT INTO child_health_answers (child_health_answer_id, child_health_record_id,
                                  health_trait_type_id, answered_at, created_by)
    VALUES ('77777777-7777-7777-7777-777777777771',
            '55555555-5555-5555-5555-555555555551', 3, now(), 'system:check'),
           ('77777777-7777-7777-7777-777777777772',
            '55555555-5555-5555-5555-555555555551', 5, now(), 'system:check'),
           ('77777777-7777-7777-7777-777777777773',
            '55555555-5555-5555-5555-555555555551', 2, now(), 'system:check');

INSERT INTO health_traits (health_trait_id, child_health_answer_id, health_trait_type_id,
                           allows_multiple, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661',
            '77777777-7777-7777-7777-777777777771', 3, true, 'system:check'),
           ('66666666-6666-6666-6666-666666666662',
            '77777777-7777-7777-7777-777777777772', 5, false, 'system:check');

-- Ein Merkmal kann seine Kategorie nicht von der Antwort abweichen lassen.
SELECT pg_temp.expect_reject(
    'rules.md 1 — Merkmal mit anderer Kategorie als seine Antwortzeile',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  allows_multiple, created_by)
       VALUES ('77777777-7777-7777-7777-777777777771', 1, true, 'system:check')$q$);

-- Und nicht die Mehrfach-Erlaubnis einer fremden Kategorie leihen.
SELECT pg_temp.expect_reject(
    'rules.md 1 — Zeckenerlaubnis mit geliehenem allows_multiple',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  allows_multiple, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 5, true, 'system:check')$q$);

-- Q1: „zwei Notfallmedikamente desselben Kindes sind getrennt zu erlauben".
SELECT pg_temp.expect_accept(
    'Q1 — zweites Merkmal einer Kategorie, die mehrere erlaubt',
    $q$INSERT INTO health_traits (health_trait_id, child_health_answer_id,
                                  health_trait_type_id, allows_multiple, created_by)
       VALUES ('66666666-6666-6666-6666-666666666663',
               '77777777-7777-7777-7777-777777777771', 3, true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — zweite Zeckenerlaubnis desselben Kindes',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  allows_multiple, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 5, false, 'system:check')$q$);

-- Die vier Felder der chronischen Erkrankung, jedes in seiner Wertart.
SELECT pg_temp.expect_accept(
    '3a — eine Kategorie mit vier Feldern verschiedener Wertart',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_text,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3, 1, 'text', 'Epilepsie',
               'system:check'),
              ('66666666-6666-6666-6666-666666666661', 3, 2, 'text',
               'Bei Anfall Notfallmedikament, Sekretariat rufen', 'system:check');
       INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code,
                                        value_document_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3, 4, 'document',
               '99999999-9999-9999-9999-999999999991', 'system:check');
       INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_period,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3, 5, 'period',
               daterange(DATE '2026-09-01', DATE '2027-07-31'), 'system:check')$q$);

-- Die Zeckenerlaubnis ist eine einzige Zeile — die Tiefe steht an der
-- Kategorie und nicht in leeren Spalten.
SELECT pg_temp.expect_accept(
    '08 — Zeckenentfernung als ein einziges Ja/Nein',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_bool,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666662', 5, 3, 'bool', true,
               'system:check')$q$);

-- Kein Feld an der falschen Kategorie: Die Zeckenerlaubnis hat keine
-- Bezeichnung, weil `health_type_fields` ihr keine zuordnet.
SELECT pg_temp.expect_reject(
    '3a — Bezeichnung an der Zeckenerlaubnis',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_text,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666662', 5, 1, 'text', 'Zecken',
               'system:check')$q$);

-- Kein Wert im falschen Typ: Die Wertart kommt vom Feld.
SELECT pg_temp.expect_reject(
    '3a — Bezeichnung als Ja/Nein eingetragen',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_bool,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3, 1, 'bool', true,
               'system:check')$q$);

-- Und die Wertart bestimmt, welche Spalte gefüllt sein muss.
SELECT pg_temp.expect_reject(
    '3a — Textfeld ohne Text, aber mit Datum',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_date,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666662', 5, 3, 'bool',
               DATE '2026-09-01', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — zwei Wertspalten zugleich gefüllt',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code,
                                        value_text, value_date, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3, 1, 'text', 'Asthma',
               DATE '2026-09-01', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — dasselbe Feld zweimal an demselben Merkmal',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_text,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3, 1, 'text', 'Asthma',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — leerer Text als Angabe',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_text,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666663', 3, 2, 'text', '',
               'system:check')$q$);

-- Ein Zeitraum, der vor seinem Anfang endet, ist leer — daterange weist das
-- schon beim Bilden ab, der CHECK fängt den ausdrücklich leeren Bereich.
SELECT pg_temp.expect_reject(
    '08 — Behandlungszeitraum ohne Dauer',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_period,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666663', 3, 5, 'period',
               'empty'::daterange, 'system:check')$q$);

-- Eine laufende Maßnahme hat kein Ende: der Anfang allein genügt.
SELECT pg_temp.expect_accept(
    '08 — Behandlungszeitraum ohne Ende',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_period,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666663', 3, 5, 'period',
               daterange(DATE '2026-10-01', NULL), 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Die Notfalleinsicht
-- ---------------------------------------------------------------------------

-- 3b: „jeder Mitarbeiter, im Notfall, protokolliert" — die Zeile entsteht ohne
-- Zuständigkeit für dieses Kind und ohne Genehmigung.
SELECT pg_temp.expect_accept(
    '3b — Notfalleinsicht einer Lehrkraft ohne Zuständigkeit für dieses Kind',
    $q$INSERT INTO health_emergency_accesses (child_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', 'entra:sportlehrkraft')$q$);

-- Eltern haben diesen Weg nicht, und ein Lauf hat keinen Notfall.
SELECT pg_temp.expect_reject(
    '3b — Notfalleinsicht ohne Schulkonto',
    $q$INSERT INTO health_emergency_accesses (child_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', 'guardian:mutter')$q$);

SELECT pg_temp.expect_reject(
    '3b — Notfalleinsicht durch einen Lauf',
    $q$INSERT INTO health_emergency_accesses (child_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', 'system:run')$q$);

-- Bewusst keine Spalte für einen eingetippten Grund.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'health_emergency_accesses'
                  AND column_name IN ('reason', 'justification', 'note')) THEN
        RAISE EXCEPTION 'Das Notfallprotokoll verlangt einen Grund, den im Ernstfall niemand tippt';
    END IF;
    RAISE NOTICE 'ok: kein Begründungsfeld am Notfallprotokoll';
END $$;

-- ---------------------------------------------------------------------------
-- Masernnachweis — unverändert
-- ---------------------------------------------------------------------------

INSERT INTO measles_proofs (child_id, presented_on, measles_presentation_type_id, created_by)
    VALUES ('44444444-4444-4444-4444-444444444441', DATE '2026-11-14', 1, 'system:check');
SELECT pg_temp.expect_reject(
    '06 — zweiter Masernnachweis desselben Kindes',
    $q$INSERT INTO measles_proofs (child_id, presented_on, measles_presentation_type_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', DATE '2026-12-01', 2, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '06 — Masernnachweis ohne Vorlageart',
    $q$INSERT INTO measles_proofs (child_id, presented_on, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', DATE '2026-11-14', 'system:check')$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'measles_proofs'
                  AND column_name IN ('reported_at', 'reported_to_authority_at',
                                      'notified_at', 'report_sent_at')) THEN
        RAISE EXCEPTION 'Der Nachweis trägt eine Meldespalte, obwohl der Meldefall gar keine Zeile hat';
    END IF;
    RAISE NOTICE 'ok: keine Meldespalte am Nachweis';
END $$;

INSERT INTO roles (code, name, created_by)
    VALUES ('secretariat', 'Sekretariat', 'system:check');
INSERT INTO sync_targets (code, name, role_id, created_by)
    VALUES ('measles_report', 'Meldung ans Gesundheitsamt',
            (SELECT role_id FROM roles WHERE code = 'secretariat'), 'system:check');
SELECT pg_temp.expect_accept(
    '09 — die Meldung ans Gesundheitsamt ist eine Aufgabe am Kind',
    $q$INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code = 'measles_report'),
               '44444444-4444-4444-4444-444444444441',
               'Fehlenden Masernnachweis dem Gesundheitsamt melden', 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Löschen
-- ---------------------------------------------------------------------------

-- grenzkarte.md, Q2: „Eine verwaiste Datei in SharePoint ist genauso ein
-- DSGVO-Verstoß wie eine verwaiste Zeile" — deshalb blockiert ein Attest das
-- Löschen des Kindes, bis der Lösch-Lauf die Datei mitentfernt hat. Der Wert
-- trägt den Fremdschlüssel jetzt anstelle des Merkmals.
SELECT pg_temp.expect_reject(
    'Q2 — Kind gelöscht, obwohl noch ein Attest in SharePoint liegt',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

-- 03: gelöscht wird „die Gesundheitsangaben nach dem letzten bestätigten Ende
-- dieses Kindes". Diese Probe belegt allein den Cascade über vier Ebenen:
-- Bestand, Antwort, Merkmal, Wert — in der Reihenfolge, die der Lösch-Lauf
-- fährt (querschnitt-schema.sql, Stufe 1): erst die Wertzeile, die das Attest
-- festhält, dann das Dokument, dann das Kind.
SELECT pg_temp.expect_accept(
    '03 — der Bestand verschwindet mit dem Kind, über alle vier Ebenen',
    $q$DELETE FROM health_trait_values WHERE value_document_id IS NOT NULL;
       DELETE FROM documents WHERE child_id = '44444444-4444-4444-4444-444444444441';
       DELETE FROM children  WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM child_health_records) OR EXISTS (SELECT 1 FROM child_health_answers)
       OR EXISTS (SELECT 1 FROM health_traits) OR EXISTS (SELECT 1 FROM health_trait_values)
       OR EXISTS (SELECT 1 FROM measles_proofs)
       OR EXISTS (SELECT 1 FROM health_emergency_accesses) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Gesundheitsdaten überleben ihr Kind';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 03 — kein Gesundheitsdatum überlebt sein Kind';
END $$;

-- Die Konfiguration überlebt: Sie trägt keine Personendaten.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM health_type_fields)
       OR NOT EXISTS (SELECT 1 FROM health_field_visibility) THEN
        RAISE EXCEPTION 'Die Konfiguration ist mit dem Kind verschwunden';
    END IF;
    RAISE NOTICE 'ok: Kategorien, Felder und Sichtkreise überleben das Kind';
END $$;

DO $$ BEGIN RAISE NOTICE 'gesundheit-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
