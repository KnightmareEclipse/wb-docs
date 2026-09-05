-- Prüfskript zu gesundheit-schema.sql.
--
-- Sollstand: 16 Tabellen — die Konfiguration health_trait_types,
-- health_value_kinds, health_fields, health_type_fields,
-- health_visibility_scopes, health_field_visibility und
-- measles_presentation_types; die Antworten child_health_records,
-- child_health_answers, health_traits und health_trait_values; den
-- handlungsrelevanten Hinweis child_health_action_notes, eine Zeile je Bestand
-- und Sichtkreis; die zwei
-- Freigaben child_health_releases und health_trait_releases; dazu
-- health_emergency_accesses und measles_proofs. Ein partieller Unique-Index
-- gegen die zweite Zeile einer Kategorie, die nur eine erlaubt, ein Index
-- auf dem Paar (Kategorie, Feld), über das jede Sicht filtert, und ein
-- partieller auf der Herkunft der Angabe — die Frage des Lösch-Laufs, welche
-- Angaben an einem abgelaufenen Anlass hängen.
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
                      'child_health_action_notes',
                      'child_health_releases', 'health_trait_releases',
                      'health_emergency_accesses', 'measles_proofs']) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 16 Tabellen vorhanden';
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
        'pk_health_visibility_scopes', 'uq_health_visibility_scopes_release',
        'uq_health_visibility_scopes_emergency',
        'uq_health_visibility_scopes_temporary', 'ck_health_visibility_scopes_temporary',
        'ck_health_visibility_scopes_ends',
        'pk_health_field_visibility', 'fk_health_field_visibility_pair',
        'fk_health_field_visibility_kind', 'ck_health_field_visibility_presence',
        'ck_health_field_visibility_emergency',
        'pk_child_health_action_notes', 'fk_child_health_action_notes_record',
        'ck_child_health_action_notes_note',
        'ck_child_health_action_notes_created_by', 'ck_health_traits_answered',
        'pk_child_health_records', 'uq_child_health_records',
        'ck_child_health_records_answer',
        'pk_child_health_answers', 'uq_child_health_answers',
        'uq_child_health_answers_type', 'ck_child_health_answers_answer',
        'uq_child_health_answers_record',
        'pk_health_traits', 'fk_health_traits_answer', 'fk_health_traits_record',
        'fk_health_traits_type', 'uq_health_traits_type', 'uq_health_traits_record',
        'fk_health_traits_origin', 'ck_health_traits_origin',
        'ck_health_traits_origin_temporary',
        'pk_child_health_releases', 'fk_child_health_releases_record',
        'fk_child_health_releases_scope', 'uq_child_health_releases',
        'uq_child_health_releases_state', 'ck_child_health_releases_needs',
        'ck_child_health_releases_answer',
        'pk_health_trait_releases', 'fk_health_trait_releases_trait',
        'fk_health_trait_releases_release', 'ck_health_trait_releases_released',
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
    IF to_regclass('public.ix_health_traits_origin') IS NULL THEN
        RAISE EXCEPTION 'Fehlender Index: ix_health_traits_origin';
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
    (5, 'tick_removal',   'Zeckenentfernung',        false, 'system:check'),
    -- 19: „Schwimmfähigkeit … verschwindet mit der Fahrt" — die Kategorie, die
    -- der Vertrag nicht erhebt und die deshalb nur über einen Anlass hereinkommt.
    (6, 'swimming',       'Schwimmfähigkeit',        false, 'system:check');

INSERT INTO health_fields (health_field_id, code, name, value_kind_code, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'label',         'Bezeichnung',            'text',     'system:check'),
    (2, 'note',          'Beachten',               'text',     'system:check'),
    (3, 'permission',    'Erlaubnis',              'bool',     'system:check'),
    (4, 'certificate',   'Attest',                 'document', 'system:check'),
    (5, 'period',        'Zeitraum',               'period',   'system:check'),
    (6, 'vaccinated_on', 'Datum der letzten Impfung', 'date',  'system:check'),
    (7, 'can_swim',      'Kann schwimmen',         'bool',     'system:check');

INSERT INTO health_type_fields (health_trait_type_id, health_field_id, created_by) VALUES
    (1, 1, 'system:check'), (1, 2, 'system:check'),
    (2, 1, 'system:check'), (2, 2, 'system:check'), (2, 3, 'system:check'),
    (3, 1, 'system:check'), (3, 2, 'system:check'), (3, 4, 'system:check'),
    (3, 5, 'system:check'),
    (4, 1, 'system:check'),
    (5, 3, 'system:check'),
    (6, 7, 'system:check');

-- Fünf Sichtkreise, und `needs_release` sagt, welche Freigabeziele sind:
-- `school` und `care`, nicht `full`, `kitchen` und `emergency`.
INSERT INTO health_visibility_scopes (health_visibility_scope_id, code, name,
                                      is_emergency, needs_release, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'kitchen',   'Küche',      false, false, 'system:check'),
    (2, 'care',      'Betreuung',  false, true,  'system:check'),
    (3, 'school',    'Schule',     false, true,  'system:check'),
    (4, 'full',      'Volle Akte', false, false, 'system:check'),
    (5, 'emergency', 'Notfall',    true,  false, 'system:check');

INSERT INTO measles_presentation_types (measles_presentation_type_id, code, name)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'vaccination_card', 'Impfpass'), (2, 'certificate', 'ärztliche Bescheinigung');

INSERT INTO sharepoint_libraries (sharepoint_library_id, code, name, graph_drive_id, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'student_file', 'Digitale Schülerakte', 'b!x', 'system:check');
INSERT INTO document_types (document_type_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'certificate', 'Attest', 'system:check');
-- Die Datei liegt im Unterordner ihrer Kategorie, nicht in der Bibliothek
-- (querschnitt-schema.sql): erst der Ordner, dann das Blatt darin.
INSERT INTO child_file_categories (child_file_category_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'health', 'Gesundheitsunterlagen', 'system:check');
INSERT INTO child_file_folders (child_file_folder_id, child_id, sharepoint_library_id,
                                child_file_category_id, graph_item_id, created_by)
    VALUES ('10000000-0000-0000-0000-000000000001',
            '44444444-4444-4444-4444-444444444441', 1, 1, '01ORDNER', 'system:check');
INSERT INTO documents (document_id, child_id, document_type_id, label,
                       child_file_folder_id, sharepoint_library_id,
                       graph_item_id, filed_at, created_by)
    VALUES ('99999999-9999-9999-9999-999999999991',
            '44444444-4444-4444-4444-444444444441', 1, 'Attest',
            '10000000-0000-0000-0000-000000000001', 1, '01ATT', now(), 'system:check');

-- ---------------------------------------------------------------------------
-- Der Sichtkreis: welche Felder ein Kreis überhaupt sehen kann
-- ---------------------------------------------------------------------------

-- Der grobe Schnitt vom 02.09.2026: Lehrkräfte und Hort sehen alles, die Küche
-- allein Bezeichnung und Beachten der Allergie.
SELECT pg_temp.expect_accept(
    'TASK-197 — Schule und Hort sehen dieselben Felder, das Attest nur als Vorliegen',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, presence_only, created_by)
       VALUES (3, 3, 1, 'text', false, 'system:check'),
              (3, 3, 2, 'text', false, 'system:check'),
              (3, 3, 4, 'document', true, 'system:check'),
              (3, 1, 1, 'text', false, 'system:check'),
              (3, 1, 2, 'text', false, 'system:check'),
              (3, 5, 3, 'bool', false, 'system:check'),
              (2, 3, 1, 'text', false, 'system:check'),
              (2, 3, 2, 'text', false, 'system:check'),
              (2, 3, 4, 'document', true, 'system:check'),
              (2, 1, 1, 'text', false, 'system:check'),
              (2, 1, 2, 'text', false, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '11 — die Küche sieht Bezeichnung und Hinweis der Allergie, sonst nichts',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, created_by)
       VALUES (1, 1, 1, 'text', 'system:check'), (1, 1, 2, 'text', 'system:check')$q$);

-- TASK-206: „full behält das Attest im Klartext, damit das Sekretariat
-- abgleichen kann."
SELECT pg_temp.expect_accept(
    'TASK-206 — die volle Akte sieht dasselbe Attest im Klartext',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, presence_only, created_by)
       VALUES (4, 3, 4, 'document', false, 'system:check')$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM health_field_visibility
                WHERE health_visibility_scope_id = 1 AND health_trait_type_id = 3) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Küche sieht die chronische Erkrankung';
    END IF;
    RAISE NOTICE 'ok: die Küche bleibt auf die Allergie beschränkt';
END $$;

-- TASK-206: Dasselbe Feld, zwei Tiefen — der eine Kreis bekommt die
-- `document_id`, der andere nur, DASS eine hinterlegt ist. Das ist der
-- Unterschied, den eine Leiter nicht trägt.
DO $$
DECLARE nur_vorliegen boolean; im_klartext boolean;
BEGIN
    SELECT presence_only INTO nur_vorliegen FROM health_field_visibility
     WHERE health_visibility_scope_id = 3 AND health_trait_type_id = 3
       AND health_field_id = 4;
    SELECT NOT presence_only INTO im_klartext FROM health_field_visibility
     WHERE health_visibility_scope_id = 4 AND health_trait_type_id = 3
       AND health_field_id = 4;
    IF NOT nur_vorliegen OR NOT im_klartext THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — das Attest liegt für beide Kreise gleich';
    END IF;
    RAISE NOTICE 'ok: dasselbe Attestfeld, zwei Tiefen';
END $$;

-- TASK-206: Nur ein Dokumentfeld lässt sich auf sein Vorliegen zusammenstreichen
-- — bei jeder anderen Wertart wäre der geleerte Wert die ganze Angabe.
SELECT pg_temp.expect_reject(
    'TASK-206 — Vorliegen-Häkchen an einem Textfeld',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, presence_only, created_by)
       VALUES (1, 1, 2, 'text', true, 'system:check')$q$);

-- Und die Wertart kommt vom Feld, nicht vom Schreibenden. Feld 5 ist ein
-- Zeitraum; der Sichtkreis muss ein gewöhnlicher sein, sonst greift der
-- Notfall-Schlüssel und die Wertart bleibt ungeprüft.
SELECT pg_temp.expect_reject(
    'TASK-206 — Sichtbarkeit mit falscher Wertart eingetragen',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, created_by)
       VALUES (3, 3, 5, 'text', 'system:check')$q$);

-- Sichtbar machen lässt sich nur, was die Kategorie überhaupt erhebt.
SELECT pg_temp.expect_reject(
    '3a — Sichtbarkeit für ein Feld, das diese Kategorie nicht hat',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, created_by)
       VALUES (3, 5, 1, 'text', 'system:check')$q$);

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

-- Und die eine Stelle, an der beide leer bleiben dürfen: der Bestand eines
-- Kindes aus dem Vollimport, bei dem diese Strecke nie lief. Eine Ebene tiefer
-- gibt es diesen Fall nicht, und dort prüft der CHECK deshalb mit `<>`.
SELECT pg_temp.expect_accept(
    '08 — der Bestand des Vollimports: weder beantwortet noch verweigert',
    $q$UPDATE child_health_records SET answered_at = NULL
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551';
       UPDATE child_health_records SET answered_at = now()
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'$q$);

-- grenzkarte.md: „Der kurze handlungsrelevante Hinweis steht daneben: am
-- Bestand, nicht am Merkmal … Er steht je Sichtkreis." Schule und
-- Hort schreiben je für ihren eigenen Alltag, und ein externes Hortkind hat
-- gar keine Klassenlehrkraft, die schriebe.
SELECT pg_temp.expect_accept(
    '09 — je Instanz ein eigener Hinweis, beide nebeneinander',
    $q$INSERT INTO child_health_action_notes (child_health_record_id,
                                              health_visibility_scope_id, note, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3,
               'Epilepsie — im Anfall nicht festhalten, Zeit notieren', 'entra:lehrkraft'),
              ('55555555-5555-5555-5555-555555555551', 2,
               'Epilepsie — auf Ausflüge das Notfallmedikament mitnehmen',
               'entra:hortleitung')$q$);

SELECT pg_temp.expect_reject(
    'grenzkarte.md — leerer Handlungshinweis',
    $q$INSERT INTO child_health_action_notes (child_health_record_id,
                                              health_visibility_scope_id, note, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 4, '', 'entra:lehrkraft')$q$);

-- Ein Kreis, ein Hinweis: Der zweite ersetzt den ersten, statt sich daneben zu
-- stellen — sonst stünden auf demselben Blatt zwei Sätze und niemand wüsste,
-- welcher gilt.
SELECT pg_temp.expect_reject(
    '09 — zweiter Hinweis desselben Kreises',
    $q$INSERT INTO child_health_action_notes (child_health_record_id,
                                              health_visibility_scope_id, note, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, 'Noch ein Satz',
               'entra:hortleitung')$q$);

-- api/gesundheit-api.md: der Hinweis geht „nicht an die Eltern" — und kommt
-- erst recht nicht von ihnen. Er ist die Einschätzung der betreuenden Stelle.
SELECT pg_temp.expect_reject(
    'api/gesundheit-api.md — die Eltern schreiben den Hinweis',
    $q$INSERT INTO child_health_action_notes (child_health_record_id,
                                              health_visibility_scope_id, note, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 4, 'Von den Eltern',
               'guardian:mutter')$q$);

SELECT pg_temp.expect_reject(
    '09 — zweiter Gesundheitsbestand desselben Kindes',
    $q$INSERT INTO child_health_records (child_id, declined_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', now(), 'system:check')$q$);

-- Zustand 1: gefragt, es gibt nichts — eine Antwortzeile ohne Merkmal. Die
-- Kategorie 2 bleibt bis zum Schluss ohne Angabe, sonst wäre die Zeile hinterher
-- keine Entwarnung mehr.
SELECT pg_temp.expect_accept(
    '3a — beantwortet, ohne dass es etwas zu nennen gibt',
    $q$INSERT INTO child_health_answers (child_health_record_id, health_trait_type_id,
                                         answered_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, now(), 'system:check')$q$);

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
       VALUES ('55555555-5555-5555-5555-555555555551', 6, now(), now(), 'system:check')$q$);

-- Und weder noch ist kein vierter Zustand: „nie gefragt" ist die fehlende
-- Zeile, und eine Zeile ohne beides läse sich in jedem Join wie „will nicht
-- sagen" (dieselbe `<>`-Form wie `consents` in querschnitt-schema.sql).
SELECT pg_temp.expect_reject(
    '3a — Kategorie weder beantwortet noch verweigert',
    $q$INSERT INTO child_health_answers (child_health_record_id, health_trait_type_id,
                                         created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 6, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — dieselbe Kategorie zweimal beantwortet',
    $q$INSERT INTO child_health_answers (child_health_record_id, health_trait_type_id,
                                         answered_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, now(), 'system:check')$q$);

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
           ('77777777-7777-7777-7777-777777777774',
            '55555555-5555-5555-5555-555555555551', 1, now(), 'system:check'),
           ('77777777-7777-7777-7777-777777777775',
            '55555555-5555-5555-5555-555555555551', 6, now(), 'system:check');

INSERT INTO health_traits (health_trait_id, child_health_answer_id, health_trait_type_id,
                           child_health_record_id, allows_multiple, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661',
            '77777777-7777-7777-7777-777777777771', 3, '55555555-5555-5555-5555-555555555551', true, 'system:check'),
           ('66666666-6666-6666-6666-666666666662',
            '77777777-7777-7777-7777-777777777772', 5, '55555555-5555-5555-5555-555555555551', false, 'system:check'),
           ('66666666-6666-6666-6666-666666666664',
            '77777777-7777-7777-7777-777777777774', 1, '55555555-5555-5555-5555-555555555551', true, 'system:check');

-- Ein Merkmal kann seine Kategorie nicht von der Antwort abweichen lassen.
SELECT pg_temp.expect_reject(
    'rules.md 1 — Merkmal mit anderer Kategorie als seine Antwortzeile',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  child_health_record_id, allows_multiple, created_by)
       VALUES ('77777777-7777-7777-7777-777777777771', 1,
               '55555555-5555-5555-5555-555555555551', true, 'system:check')$q$);

-- Und den Bestand ebensowenig: Über ihn hängt die Freigabe, er darf also nicht
-- von dem der Antwortzeile abweichen.
SELECT pg_temp.expect_reject(
    'rules.md 1 — Merkmal mit fremdem Bestandsbezug',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  child_health_record_id, allows_multiple, created_by)
       VALUES ('77777777-7777-7777-7777-777777777771', 3,
               '55555555-5555-5555-5555-555555555559', true, 'system:check')$q$);

-- Und nicht die Mehrfach-Erlaubnis einer fremden Kategorie leihen.
SELECT pg_temp.expect_reject(
    'rules.md 1 — Zeckenerlaubnis mit geliehenem allows_multiple',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  child_health_record_id, allows_multiple, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 5,
               '55555555-5555-5555-5555-555555555551', true, 'system:check')$q$);

-- 08: „will nicht sagen" ist keine Entwarnung — und darf erst recht nicht über
-- einer Angabe stehen, die die Familie gerade nicht nennen wollte.
SELECT pg_temp.expect_reject(
    '08 — Angabe unter einer verweigerten Kategorie',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  child_health_record_id, allows_multiple, created_by)
       SELECT child_health_answer_id, 4, '55555555-5555-5555-5555-555555555551',
              false, 'system:check'
         FROM child_health_answers
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'
          AND health_trait_type_id = 4$q$);

SELECT pg_temp.expect_reject(
    '08 — Kategorie nachträglich verweigert, obwohl eine Angabe darunter steht',
    $q$UPDATE child_health_answers SET answered_at = NULL, declined_at = now()
        WHERE child_health_answer_id = '77777777-7777-7777-7777-777777777771'$q$);

-- Q1: „zwei Notfallmedikamente desselben Kindes sind getrennt zu erlauben".
SELECT pg_temp.expect_accept(
    'Q1 — zweites Merkmal einer Kategorie, die mehrere erlaubt',
    $q$INSERT INTO health_traits (health_trait_id, child_health_answer_id,
                                  health_trait_type_id, child_health_record_id,
                                  allows_multiple, created_by)
       VALUES ('66666666-6666-6666-6666-666666666663',
               '77777777-7777-7777-7777-777777777771', 3,
               '55555555-5555-5555-5555-555555555551', true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '3a — zweite Zeckenerlaubnis desselben Kindes',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  child_health_record_id, allows_multiple, created_by)
       VALUES ('77777777-7777-7777-7777-777777777772', 5,
               '55555555-5555-5555-5555-555555555551', false, 'system:check')$q$);

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

-- Die Allergie, und genau ihre beiden Felder sieht auch die Küche (11).
SELECT pg_temp.expect_accept(
    '11 — die Allergie mit Bezeichnung und Hinweis',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_text,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666664', 1, 1, 'text', 'Erdnuss',
               'system:check'),
              ('66666666-6666-6666-6666-666666666664', 1, 2, 'text',
               'Kein Erdnussöl, auch keine Spuren', 'system:check')$q$);

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

-- Kein Wert im falschen Typ: Die Wertart kommt vom Feld. An einem Merkmal ohne
-- Wert für dieses Feld, sonst greift `uq_health_trait_values` und der
-- Fremdschlüssel auf die Wertart bleibt ungeprüft.
SELECT pg_temp.expect_reject(
    '3a — Bezeichnung als Ja/Nein eingetragen',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_bool,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666663', 3, 1, 'bool', true,
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
-- Die benannte Auslassung: das Attest eines fremden Kindes
-- ---------------------------------------------------------------------------
-- Der Vorgang gibt es nicht: Ein Attest entsteht bei der Anmeldung und immer zum
-- eigenen Kind. Bleibt die Fehleingabe, und „die Route prüft, dass das Dokument
-- diesem Kind gehört" (api/gesundheit-api.md). Die Datenbank prüft es nicht: Der
-- Weg dorthin führte über drei mitgeführte Spalten und ein UNIQUE in
-- `querschnitt-schema.sql`, wo `documents.child_id` zudem leer sein darf und der
-- Fremdschlüssel dann gar nichts prüfte. Dieselbe Bauform wie bei der letzten
-- Admin-Rolle (stammdaten-schema-check.sql): Die Gegenprobe hält die Auslassung
-- fest, statt sie zu verschweigen.
INSERT INTO persons (person_id, first_name, last_name, created_by)
    VALUES ('22222222-2222-2222-2222-222222222229', 'Fremdes', 'Kind', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444449',
            '22222222-2222-2222-2222-222222222229',
            '33333333-3333-3333-3333-333333333333', DATE '2019-03-01', 'system:check');
INSERT INTO child_file_folders (child_file_folder_id, child_id, sharepoint_library_id,
                                child_file_category_id, graph_item_id, created_by)
    VALUES ('10000000-0000-0000-0000-000000000009',
            '44444444-4444-4444-4444-444444444449', 1, 1, '01ORDNERF', 'system:check');
INSERT INTO documents (document_id, child_id, document_type_id, label,
                       child_file_folder_id, sharepoint_library_id,
                       graph_item_id, filed_at, created_by)
    VALUES ('99999999-9999-9999-9999-999999999999',
            '44444444-4444-4444-4444-444444444449', 1, 'Attest',
            '10000000-0000-0000-0000-000000000009', 1, '01FREMD', now(), 'system:check');

SELECT pg_temp.expect_accept(
    'Q2 — Attest eines fremden Kindes (die Sperre trägt die Route)',
    $q$INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code,
                                        value_document_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666663', 3, 4, 'document',
               '99999999-9999-9999-9999-999999999999', 'system:check')$q$);


-- ---------------------------------------------------------------------------
-- Die Freigabe: wem die Angabe überhaupt vorliegt
-- ---------------------------------------------------------------------------

-- Eine Anlass-Instanz neben den beiden dauerhaften: dieselbe Bauform, nur
-- befristet — und mit dem Ende, ab dem ihre Frist rechnet. Die Fahrt ist
-- vorbei, damit unten das Zweckende greift.
INSERT INTO health_visibility_scopes (health_visibility_scope_id, code, name,
                                      needs_release, is_temporary, ends_on, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (6, 'trip_2026_10', 'Klassenfahrt Oktober 2026', true, true,
            CURRENT_DATE - 1, 'system:check');

-- 19: Eine befristete Instanz ist immer ein Freigabeziel — ohne Freigabe gäbe es
-- nichts, das nach vier Wochen verfiele.
SELECT pg_temp.expect_reject(
    '19 — befristete Instanz, die kein Freigabeziel ist',
    $q$INSERT INTO health_visibility_scopes (code, name, needs_release, is_temporary,
                                             ends_on, created_by)
       VALUES ('trip_bad', 'Fahrt ohne Freigabe', false, true, CURRENT_DATE + 30,
               'system:check')$q$);

-- 17: „Der Lauf rechnet je Bestand den Löschtermin aus dem Anker seiner
-- Domäne." Beim Anlass ist der Anker sein Ende — eine Instanz ohne Ende hat
-- keinen, ihre vier Wochen liefen nie an, und sie sähe aus wie eine dauerhafte.
SELECT pg_temp.expect_reject(
    '17 — Anlass-Instanz ohne Ende',
    $q$INSERT INTO health_visibility_scopes (code, name, needs_release, is_temporary,
                                             created_by)
       VALUES ('trip_no_end', 'Fahrt ohne Ende', true, true, 'system:check')$q$);

-- Und umgekehrt: Ein Ende an `school` wäre ein zweiter Löschanker neben dem
-- Austritt des Kindes.
SELECT pg_temp.expect_reject(
    '17 — dauerhafte Instanz mit eigenem Ende',
    $q$UPDATE health_visibility_scopes SET ends_on = CURRENT_DATE + 30
        WHERE health_visibility_scope_id = 3$q$);

INSERT INTO health_field_visibility (health_visibility_scope_id, health_trait_type_id,
                                     health_field_id, value_kind_code, created_by)
    VALUES (6, 3, 1, 'text', 'system:check'), (6, 3, 2, 'text', 'system:check');

-- ---------------------------------------------------------------------------
-- Woher die Angabe kam — der zweite Löschanker der Domäne
-- ---------------------------------------------------------------------------
-- 19: „Alle Gesundheitsangaben, die nur über diese Fahrt hereinkommen,
-- verschwinden mit ihr … In den Bestand am Kind kommt nur, was der Vertrag
-- erhebt." Ohne die Herkunft an der Angabe ist der Satz nicht ausführbar — eine
-- Freigabe sagt, wer liest, nicht, woher der Wert kam.
SELECT pg_temp.expect_accept(
    '19 — die Schwimmfähigkeit kommt nur über die Fahrt herein',
    $q$INSERT INTO health_traits (health_trait_id, child_health_answer_id,
                                  health_trait_type_id, child_health_record_id,
                                  allows_multiple, origin_scope_id, origin_is_temporary,
                                  created_by)
       VALUES ('66666666-6666-6666-6666-666666666665',
               '77777777-7777-7777-7777-777777777775', 6,
               '55555555-5555-5555-5555-555555555551', false, 6, true, 'entra:lehrkraft');
       INSERT INTO health_trait_values (health_trait_id, health_trait_type_id,
                                        health_field_id, value_kind_code, value_bool,
                                        created_by)
       VALUES ('66666666-6666-6666-6666-666666666665', 6, 7, 'bool', true,
               'entra:lehrkraft')$q$);

-- „Leer heißt: über den Vertrag": Eine dauerhafte Instanz als Herkunft wäre
-- dieselbe Tatsache in zweiter Schreibweise (rules.md 1).
SELECT pg_temp.expect_reject(
    '19 — die Schule als Herkunft einer Angabe',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  child_health_record_id, allows_multiple,
                                  origin_scope_id, origin_is_temporary, created_by)
       VALUES ('77777777-7777-7777-7777-777777777771', 3,
               '55555555-5555-5555-5555-555555555551', true, 3, false,
               'system:check')$q$);

-- Und keine halbe Herkunft: Ohne das mitgeführte Häkchen prüfte der
-- zusammengesetzte Fremdschlüssel gar nichts (MATCH SIMPLE).
SELECT pg_temp.expect_reject(
    '19 — Herkunft ohne ihr Häkchen',
    $q$INSERT INTO health_traits (child_health_answer_id, health_trait_type_id,
                                  child_health_record_id, allows_multiple,
                                  origin_scope_id, created_by)
       VALUES ('77777777-7777-7777-7777-777777777771', 3,
               '55555555-5555-5555-5555-555555555551', true, 6, 'system:check')$q$);

-- Die Frage des Lösch-Laufs, und genau die, die das Modell vorher nicht
-- beantworten konnte: Welche Angabe hängt am Anlass, und welche nicht? Die
-- Zeckenerlaubnis ist an niemanden freigegeben und bleibt trotzdem Bestand.
DO $$
DECLARE am_anlass int; anker date; zecke_am_anlass boolean;
BEGIN
    SELECT count(*) INTO am_anlass FROM health_traits WHERE origin_scope_id IS NOT NULL;
    IF am_anlass <> 1 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — % Angaben hängen am Anlass statt einer', am_anlass;
    END IF;
    SELECT origin_scope_id IS NOT NULL INTO zecke_am_anlass FROM health_traits
     WHERE health_trait_id = '66666666-6666-6666-6666-666666666662';
    IF zecke_am_anlass THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — die Zeckenerlaubnis gilt als Anlass-Angabe';
    END IF;
    -- Und der Anker der Anlass-Angabe ist erreichbar: das Ende der Fahrt. Die
    -- Frist dazu steht als Wert im System (querschnitt-schema.sql), nicht hier.
    SELECT s.ends_on INTO anker
      FROM health_traits t
      JOIN health_visibility_scopes s ON s.health_visibility_scope_id = t.origin_scope_id
     WHERE t.health_trait_id = '66666666-6666-6666-6666-666666666665';
    IF anker IS NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Anlass-Angabe hat keinen Löschanker';
    END IF;
    RAISE NOTICE 'ok: der Lauf trennt die Anlass-Angabe vom Bestand und findet ihren Anker';
END $$;

-- TASK-205: „erst überhaupt freigeben oder ablehnen" — je Instanz, mit
-- denselben drei Zuständen wie überall: freigegeben, abgelehnt, nie gefragt.
SELECT pg_temp.expect_accept(
    'TASK-205 — die Schule freigegeben, der Hort abgelehnt',
    $q$INSERT INTO child_health_releases (child_health_record_id,
                                          health_visibility_scope_id, released_at,
                                          created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, now(), 'system:check');
       INSERT INTO child_health_releases (child_health_record_id,
                                          health_visibility_scope_id, declined_at,
                                          created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, now(), 'system:check')$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM child_health_releases
                WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'
                  AND health_visibility_scope_id = 6) THEN
        RAISE EXCEPTION 'Testaufbau falsch: die Fahrt sollte ungefragt sein';
    END IF;
    RAISE NOTICE 'ok: „beim Hort abgelehnt" ist von „bei der Fahrt nicht gefragt" unterscheidbar';
END $$;

SELECT pg_temp.expect_reject(
    'TASK-205 — Bestand zugleich freigegeben und abgelehnt',
    $q$UPDATE child_health_releases SET declined_at = now()
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'
          AND health_visibility_scope_id = 3$q$);

SELECT pg_temp.expect_reject(
    'TASK-205 — zweite Freigabe an dieselbe Instanz',
    $q$INSERT INTO child_health_releases (child_health_record_id,
                                          health_visibility_scope_id, released_at,
                                          created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, now(), 'system:check')$q$);

-- „`full`, `kitchen` und `emergency` sind keine Freigabeziele": die Eltern lesen
-- ihre eigene Akte, die Küche erbt von der Liste, und der Notfall übergeht die
-- Freigabe ohnehin.
SELECT pg_temp.expect_reject(
    'TASK-205 — Freigabe an den Notfallausschnitt',
    $q$INSERT INTO child_health_releases (child_health_record_id,
                                          health_visibility_scope_id, released_at,
                                          created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 5, now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-205 — Freigabe an die Küche',
    $q$INSERT INTO child_health_releases (child_health_record_id,
                                          health_visibility_scope_id, released_at,
                                          created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, now(), 'system:check')$q$);

-- Und weder noch ist auch hier kein Zustand — hier wiegt es schwerer als eine
-- Ebene höher: `is_released` würde false, die Zeile läse sich wie eine
-- Ablehnung, und `uq_child_health_releases` blockierte danach die richtige.
SELECT pg_temp.expect_reject(
    'TASK-205 — Instanz weder freigegeben noch abgelehnt',
    $q$INSERT INTO child_health_releases (child_health_record_id,
                                          health_visibility_scope_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 6, 'system:check')$q$);

-- Die Einzelfreigabe hängt an der Instanz-Freigabe: an die Schule geht sie, an
-- den abgelehnten Hort nicht.
SELECT pg_temp.expect_accept(
    'TASK-205 — die Erkrankung an die Schule freigegeben',
    $q$INSERT INTO health_trait_releases (health_trait_id, health_visibility_scope_id,
                                          child_health_record_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3,
               '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-205 — Einzelfreigabe an eine abgelehnte Instanz',
    $q$INSERT INTO health_trait_releases (health_trait_id, health_visibility_scope_id,
                                          child_health_record_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 2,
               '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-205 — Einzelfreigabe an eine nie gefragte Instanz',
    $q$INSERT INTO health_trait_releases (health_trait_id, health_visibility_scope_id,
                                          child_health_record_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 6,
               '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

-- Der Widerruf der Instanz setzt voraus, dass keine Einzelfreigabe mehr hängt —
-- die gewollte Reihenfolge, damit keine Angabe an einer widerrufenen Instanz
-- stehen bleibt.
SELECT pg_temp.expect_reject(
    'TASK-205 — Widerruf, solange eine Einzelfreigabe daran hängt',
    $q$UPDATE child_health_releases SET released_at = NULL, declined_at = now()
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'
          AND health_visibility_scope_id = 3$q$);

-- „Eine Angabe ohne Freigabe ist für den Sichtkreis unsichtbar": derselbe
-- Bestand, zwei Sichtkreise mit denselben Feldern, verschiedenes Ergebnis.
DO $$
DECLARE fuer_schule int; fuer_hort int;
BEGIN
    SELECT count(*) INTO fuer_schule
    FROM health_trait_values v
    JOIN health_traits t ON t.health_trait_id = v.health_trait_id
    JOIN health_trait_releases r ON r.health_trait_id = t.health_trait_id
                                AND r.health_visibility_scope_id = 3
    JOIN health_field_visibility f ON f.health_visibility_scope_id = 3
                                 AND f.health_trait_type_id = v.health_trait_type_id
                                 AND f.health_field_id = v.health_field_id;
    SELECT count(*) INTO fuer_hort
    FROM health_trait_values v
    JOIN health_traits t ON t.health_trait_id = v.health_trait_id
    JOIN health_trait_releases r ON r.health_trait_id = t.health_trait_id
                                AND r.health_visibility_scope_id = 2
    JOIN health_field_visibility f ON f.health_visibility_scope_id = 2
                                 AND f.health_trait_type_id = v.health_trait_type_id
                                 AND f.health_field_id = v.health_field_id;
    IF fuer_schule = 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die freigegebene Angabe kommt bei der Schule nicht an';
    END IF;
    IF fuer_hort <> 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Hort sieht % Werte ohne Freigabe', fuer_hort;
    END IF;
    RAISE NOTICE 'ok: dieselben Felder, und trotzdem sieht der Hort ohne Freigabe nichts';
END $$;

-- 09: „Was das für die Küche heißt, entscheidet nicht diese Freigabe, sondern
-- die Liste: Über die Hortliste gilt die Freigabe an den Hort, über die
-- Mensa-Tagesliste die an die Schule (11)." `needs_release = false` heißt an der
-- Küche also „keine eigene", nicht „keine" — und diese Hälfte sieht sonst kein
-- Prüfskript, weil das Erben in der abgeleiteten Sicht liegt
-- (`api/mensa-api.md`). Hier steht die Schule frei und der Hort abgelehnt.
INSERT INTO health_trait_releases (health_trait_id, health_visibility_scope_id,
                                   child_health_record_id, created_by)
    VALUES ('66666666-6666-6666-6666-666666666664', 3,
            '55555555-5555-5555-5555-555555555551', 'system:check');

DO $$
DECLARE ueber_mensa int; ueber_hort int;
BEGIN
    SELECT count(*) INTO ueber_mensa
    FROM health_trait_values v
    JOIN health_field_visibility f ON f.health_visibility_scope_id = 1
                                 AND f.health_trait_type_id = v.health_trait_type_id
                                 AND f.health_field_id      = v.health_field_id
    JOIN health_trait_releases r ON r.health_trait_id = v.health_trait_id
                                AND r.health_visibility_scope_id = 3;
    SELECT count(*) INTO ueber_hort
    FROM health_trait_values v
    JOIN health_field_visibility f ON f.health_visibility_scope_id = 1
                                 AND f.health_trait_type_id = v.health_trait_type_id
                                 AND f.health_field_id      = v.health_field_id
    JOIN health_trait_releases r ON r.health_trait_id = v.health_trait_id
                                AND r.health_visibility_scope_id = 2;
    IF ueber_mensa = 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Küche sieht über die Mensa-Tagesliste nichts, obwohl die Schule freigegeben hat';
    END IF;
    IF ueber_hort <> 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Küche sieht über die Hortliste % Werte, obwohl der Hort abgelehnt hat', ueber_hort;
    END IF;
    RAISE NOTICE 'ok: die Küche erbt die Freigabe der Liste, auf der das Kind steht';
END $$;

-- „Der Mitarbeitende sieht im Notfall alles" (TASK-205), nicht nur einen Ausschnitt:
-- Der Notfallkreis läuft weder über die Feldmatrix noch über die Freigabe. Eine
-- Zeile in der Matrix wäre eine Begrenzung, die es nicht gibt — und eine
-- Vollständigkeit, die niemand hält, sobald ein Paar dazukommt.
SELECT pg_temp.expect_reject(
    'TASK-206 — Sichtbarkeitszeile für den Notfallausschnitt',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, is_emergency, created_by)
       VALUES (5, 3, 1, 'text', true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-206 — Sichtbarkeitszeile für den Notfallausschnitt mit geliehenem Häkchen',
    $q$INSERT INTO health_field_visibility (health_visibility_scope_id,
                                            health_trait_type_id, health_field_id,
                                            value_kind_code, is_emergency, created_by)
       VALUES (5, 3, 1, 'text', false, 'system:check')$q$);

DO $$
DECLARE im_notfall int;
BEGIN
    IF EXISTS (SELECT 1 FROM health_field_visibility WHERE health_visibility_scope_id = 5) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Notfallausschnitt steht doch in der Matrix';
    END IF;
    -- Die Sicht zählt alle Werte des Kindes, ohne Matrix und ohne Freigabe. Die
    -- Zeckenerlaubnis ist an niemanden freigegeben und muss trotzdem dabei sein.
    SELECT count(*) INTO im_notfall
    FROM health_trait_values v
    WHERE NOT EXISTS (SELECT 1 FROM health_trait_releases r
                       WHERE r.health_trait_id = v.health_trait_id);
    IF im_notfall = 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Notfallausschnitt hängt doch an einer Freigabe';
    END IF;
    RAISE NOTICE 'ok: der Notfallausschnitt steht in keiner Zeile und sieht trotzdem alles';
END $$;

-- TASK-162: „Zweckende und Löschtermin je Angabe" — und beide an der Freigabe,
-- weil dieselbe Allergie der Schule dauerhaft und der Fahrt befristet vorliegt.
INSERT INTO child_health_releases (child_health_record_id, health_visibility_scope_id,
                                   released_at, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551', 6, now(), 'system:check');
SELECT pg_temp.expect_accept(
    'TASK-162 — dieselbe Angabe, der Fahrt befristet freigegeben',
    $q$INSERT INTO health_trait_releases (health_trait_id, health_visibility_scope_id,
                                          child_health_record_id,
                                          purpose_ends_on, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 6,
               '55555555-5555-5555-5555-555555555551',
               CURRENT_DATE - 1, 'system:check')$q$);

-- 17: „Der Lauf rechnet je Bestand den Löschtermin aus dem Anker seiner
-- Domäne", und die Frist steht als Wert im System (hebel.md, 04.09.2026).
-- Gespeichert wird der Termin deshalb nirgends — sonst erreichte eine gesenkte
-- Frist keine bestehende Zeile, und die Vierzehn-Tage-Regel griffe nicht.
DO $$
DECLARE gespeichert text;
BEGIN
    SELECT string_agg(table_name || '.' || column_name, ', ') INTO gespeichert
    FROM information_schema.columns
    WHERE table_name IN ('health_visibility_scopes', 'child_health_records',
                         'child_health_answers', 'health_traits',
                         'health_trait_values', 'child_health_releases',
                         'health_trait_releases')
      AND column_name IN ('delete_on', 'deleted_on', 'delete_after',
                          'retention_until');
    IF gespeichert IS NOT NULL THEN
        RAISE EXCEPTION 'Ein Löschtermin steht gespeichert statt gerechnet: %', gespeichert;
    END IF;
    RAISE NOTICE 'ok: kein gespeicherter Löschtermin — der Lauf rechnet aus dem Anker';
END $$;

-- „nach dem Zweckende aus der Alltagssicht, und trotzdem da": Die Fahrt sieht
-- nichts mehr, die Schule unverändert alles, und die Zeile steht.
DO $$
DECLARE fuer_fahrt int;
BEGIN
    SELECT count(*) INTO fuer_fahrt
    FROM health_trait_values v
    JOIN health_trait_releases r ON r.health_trait_id = v.health_trait_id
                                AND r.health_visibility_scope_id = 6
    JOIN health_field_visibility f ON f.health_visibility_scope_id = 6
                                 AND f.health_trait_type_id = v.health_trait_type_id
                                 AND f.health_field_id = v.health_field_id
    WHERE r.purpose_ends_on IS NULL OR r.purpose_ends_on >= CURRENT_DATE;
    IF fuer_fahrt <> 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Fahrt sieht nach dem Zweckende noch % Werte', fuer_fahrt;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM health_traits
                    WHERE health_trait_id = '66666666-6666-6666-6666-666666666661') THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — die Angabe ist mit ihrem Zweckende verschwunden';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM health_trait_releases
                    WHERE health_trait_id = '66666666-6666-6666-6666-666666666661'
                      AND health_visibility_scope_id = 3) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — das Zweckende der Fahrt traf die Schule mit';
    END IF;
    RAISE NOTICE 'ok: nach dem Zweckende aus der Alltagssicht, und trotzdem da';
END $$;

SELECT pg_temp.expect_reject(
    'TASK-205 — dieselbe Angabe zweimal an dieselbe Instanz freigegeben',
    $q$INSERT INTO health_trait_releases (health_trait_id, health_visibility_scope_id,
                                          child_health_record_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 3,
               '55555555-5555-5555-5555-555555555551', 'system:check')$q$);

-- „Ein Bestand je Kind bleibt": Die Freigabe trägt keinen Wert, und der Wert
-- kennt keine Instanz — sonst wären es zwei Bestände statt einer Freigabe.
-- `health_traits.origin_scope_id` ist die **eine benannte Ausnahme** und teilt
-- nichts: Sie sagt, woher der Wert kam, nicht, wer ihn liest, steht am Merkmal
-- und nicht am Wert, und trägt allein den Löschanker.
DO $$
DECLARE leftover text;
BEGIN
    SELECT string_agg(table_name || '.' || column_name, ', ') INTO leftover
    FROM information_schema.columns
    WHERE (table_name = 'health_trait_releases'
           AND column_name LIKE 'value\_%')
       OR (table_name IN ('health_trait_values', 'health_traits', 'child_health_answers')
           AND column_name = 'health_visibility_scope_id')
       OR (table_name = 'health_trait_values' AND column_name = 'origin_scope_id');
    IF leftover IS NOT NULL THEN
        RAISE EXCEPTION 'Der Bestand hat sich je Instanz geteilt: %', leftover;
    END IF;
    -- Und das Zweckende steht an der Freigabe, nicht an der Angabe.
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name IN ('health_traits', 'health_trait_values')
                  AND column_name = 'purpose_ends_on') THEN
        RAISE EXCEPTION 'Das Zweckende steht an der Angabe statt an der Freigabe';
    END IF;
    RAISE NOTICE 'ok: ein Bestand je Kind, und das Zweckende steht an der Freigabe';
END $$;

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
-- DSGVO-Verstoß wie eine verwaiste Zeile" — deshalb hält der Gesundheitswert
-- das Attest fest, bis der Lösch-Lauf ihn vor der Datei räumt. Der Wert trägt
-- den Fremdschlüssel anstelle des Merkmals.
-- **Nicht am Kind geprüft:** Dort weist schon `fk_child_health_records_child`
-- ab — dieselbe Probe wie die 15 Zeilen weiter unten, und über das Attest
-- belegte sie nichts.
SELECT pg_temp.expect_reject(
    'Q2 — Attest gelöscht, obwohl ein Gesundheitswert darauf zeigt',
    $q$DELETE FROM documents
        WHERE document_id = '99999999-9999-9999-9999-999999999991'$q$);

-- Das Attest fort, und das Kind steht immer noch: Der Gesundheitsbestand hat
-- seine eigene, kürzere Frist — drei Monate nach dem Austritt, während der
-- Vertrag fünf Jahre steht — und hält sein Kind fest, statt per Cascade mit ihm
-- zu gehen. Nur so sieht der Lösch-Lauf ihn, und nur so überlebt ein angehaltener
-- Bestand sein Anhalten (hebel.md).
DELETE FROM health_trait_values WHERE value_document_id IS NOT NULL;
-- Erst die Blätter, dann der Ordner: `documents` zeigt auf ihn und hielte ihn
-- sonst fest, und der Ordner hält seinerseits das Kind (querschnitt-schema.sql,
-- Stufe 1 des Lösch-Laufs).
DELETE FROM documents          WHERE child_id = '44444444-4444-4444-4444-444444444441';
DELETE FROM child_file_folders WHERE child_id = '44444444-4444-4444-4444-444444444441';
SELECT pg_temp.expect_reject(
    '03 — Kind gelöscht, obwohl sein Gesundheitsbestand noch steht',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

-- Und in der Reihenfolge des Laufs geht beides: erst der Bestand, der Antwort,
-- Merkmal, Wert, Freigabe und den handlungsrelevanten Hinweis per Cascade
-- mitnimmt, dann das Kind mit dem, was unmittelbar an ihm hängt.
SELECT pg_temp.expect_accept(
    '03 — erst der Bestand, dann das Kind',
    $q$DELETE FROM child_health_records
        WHERE child_id = '44444444-4444-4444-4444-444444444441';
       DELETE FROM children
        WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM child_health_records) OR EXISTS (SELECT 1 FROM child_health_answers)
       OR EXISTS (SELECT 1 FROM health_traits) OR EXISTS (SELECT 1 FROM health_trait_values)
       OR EXISTS (SELECT 1 FROM child_health_releases)
       OR EXISTS (SELECT 1 FROM health_trait_releases)
       OR EXISTS (SELECT 1 FROM measles_proofs)
       OR EXISTS (SELECT 1 FROM health_emergency_accesses)
       OR EXISTS (SELECT 1 FROM child_health_action_notes) THEN
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

-- Referenzform (stammdaten-schema.sql): Jede Werteliste weist den leeren Code
-- und den leeren Namen ab — der Code ist Fremdschlüsselziel und Verankerung im
-- Anwendungscode, der Name die einzige Anzeige des Werts.
SELECT pg_temp.expect_reject(
    'rules.md Abschnitt 3 — Werteliste mit leerem Code (`health_visibility_scopes`)',
    $q$INSERT INTO health_visibility_scopes (code, name, created_by) VALUES ('', 'Probe', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'rules.md Abschnitt 3 — Werteliste mit leerem Namen (`health_visibility_scopes`)',
    $q$INSERT INTO health_visibility_scopes (code, name, created_by) VALUES ('empty_name_probe', '', 'system:check')$q$);

DO $$ BEGIN RAISE NOTICE 'gesundheit-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
