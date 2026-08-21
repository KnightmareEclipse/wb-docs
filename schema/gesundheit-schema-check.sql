-- Prüfskript zu gesundheit-schema.sql.
--
-- Sollstand: 5 Tabellen — health_trait_types, measles_presentation_types,
-- child_health_records, health_traits und measles_proofs, dazu ein
-- Unique-Index gegen dieselbe Angabe zweimal.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f gesundheit-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY['health_trait_types', 'measles_presentation_types',
                      'child_health_records', 'health_traits', 'measles_proofs']) AS t
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
        'pk_health_traits', 'pk_child_health_records', 'pk_measles_proofs',
        'fk_health_traits_record', 'fk_health_traits_type',
        'fk_health_traits_certificate', 'fk_child_health_records_child',
        'uq_child_health_records', 'uq_measles_proofs',
        'ck_child_health_records_answer', 'ck_health_traits_permission',
        'ck_health_traits_certificate', 'ck_health_traits_description',
        'uq_health_trait_types_flags', 'ck_health_traits_permission_type',
        'ck_health_traits_self_administered', 'ck_health_traits_treatment_reason',
        'ck_health_traits_treatment_period', 'ck_health_traits_treatment_order',
        'ck_health_traits_emergency', 'ck_health_trait_types_kitchen'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;
    IF to_regclass('public.ix_health_traits_unique') IS NULL THEN
        RAISE EXCEPTION 'Fehlender Index: ix_health_traits_unique';
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints und Indizes vorhanden';
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

-- 11: „die Mensa sieht davon allein diese beiden Punkte, den schmalsten
-- Ausschnitt, den 08 kennt: ohne Notfallmedikation, ohne Diagnose, ohne
-- Attestlage" — die beiden Punkte sind Unverträglichkeit und Allergie.
-- Drei Stufen: alles, Alltag, Küche.
INSERT INTO health_trait_types (health_trait_type_id, code, name, needs_permission,
                                is_medication, has_treatment_reason,
                                is_emergency_medication,
                                is_everyday_relevant, is_kitchen_relevant, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'allergy',        'Allergie',              false, false, false, false, true,  true,  'system:check'),
    (2, 'emergency_med',  'Notfallmedikament',     true,  true,  false, true,  true,  false, 'system:check'),
    (3, 'therapy',        'Therapeutische Maßnahme', true, false, true, false, false, false, 'system:check'),
    (4, 'school_support', 'Schulbegleitung',       false, false, false, false, false, false, 'system:check'),
    (5, 'tick_removal',   'Zeckenentfernung',      true,  false, false, false, true,  false, 'system:check');

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM health_trait_types
                WHERE code = 'emergency_med' AND is_kitchen_relevant) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Küche sieht die Notfallmedikation';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 11 — die Notfallmedikation steht außerhalb der Küchensicht';
END $$;

SELECT pg_temp.expect_reject(
    '11 — Küchenmerkmal, das nicht einmal Alltagsangabe ist',
    $q$INSERT INTO health_trait_types (code, name, is_everyday_relevant,
                                       is_kitchen_relevant, created_by)
       VALUES ('diagnosis', 'Chronische Erkrankung', false, true, 'system:check')$q$);
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
-- Gegenproben
-- ---------------------------------------------------------------------------

-- 08: „‚will nicht beantworten' ist eine eingetragene Antwort und kein leeres
-- Feld" — beides zugleich geht nicht.
INSERT INTO child_health_records (child_health_record_id, child_id, answered_at, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551',
            '44444444-4444-4444-4444-444444444441', now(), 'system:check');
SELECT pg_temp.expect_reject(
    '08 — Bestand zugleich beantwortet und verweigert',
    $q$UPDATE child_health_records SET declined_at = now()
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'$q$);

-- „erhoben wird einmal je Kind, nicht je Vertrag" (grenzkarte.md).
SELECT pg_temp.expect_reject(
    '09 — zweiter Gesundheitsbestand desselben Kindes',
    $q$INSERT INTO child_health_records (child_id, declined_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444441', now(), 'system:check')$q$);

-- „Ein leeres gibt es trotzdem, aber nur an einer Stelle: bei den Kindern, die
-- beim Vollimport schon eingeschrieben waren" (08).
SELECT pg_temp.expect_accept(
    '08 — Bestand ohne Antwort für ein Kind aus dem Vollimport',
    $q$UPDATE child_health_records SET answered_at = NULL
        WHERE child_health_record_id = '55555555-5555-5555-5555-555555555551'$q$);

-- grenzkarte.md, „Drei Zustände": die Erlaubnis je Merkmal trägt beide
-- Antworten selbst, nie beide zugleich.
INSERT INTO health_traits (health_trait_id, child_health_record_id, health_trait_type_id,
                           needs_permission, is_medication, is_emergency_medication,
                           description, permission_granted_at, self_administered, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661',
            '55555555-5555-5555-5555-555555555551', 2, true, true, true, 'Adrenalin-Pen',
            now(), false, 'system:check');
SELECT pg_temp.expect_reject(
    '09 — Verabreichungserlaubnis zugleich erteilt und verweigert',
    $q$UPDATE health_traits SET permission_declined_at = now()
        WHERE health_trait_id = '66666666-6666-6666-6666-666666666661'$q$);

-- „zwei Notfallmedikamente desselben Kindes sind getrennt zu erlauben".
SELECT pg_temp.expect_accept(
    'Q1 — zweites Notfallmedikament mit eigener Erlaubnis',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, is_medication, is_emergency_medication,
                                  description, permission_declined_at, self_administered,
                                  created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, true, true, true,
               'Salbutamol-Spray', now(), true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — dieselbe Angabe zweimal an demselben Bestand',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, is_medication, is_emergency_medication,
                                  description, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, true, true, true,
               'Adrenalin-Pen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Merkmal ohne Angabe, was es ist',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id, description,
                                  created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, '', 'system:check')$q$);

-- 08: „ob ein Attest vorlag" — ein Attestdokument gibt es nur, wo eines vorlag.
SELECT pg_temp.expect_reject(
    '08 — Attestdokument ohne Attest',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, has_treatment_reason,
                                  description, certificate_document_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, true, true, 'Ergotherapie',
               '99999999-9999-9999-9999-999999999991', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '08 — therapeutische Maßnahme mit Grund und Attest',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, has_treatment_reason,
                                  description, treatment_reason, has_certificate,
                                  certificate_document_id, permission_granted_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, true, true, 'Ergotherapie',
               'Feinmotorik', true, '99999999-9999-9999-9999-999999999991',
               now(), 'system:check')$q$);

-- 08, „Was dabei erhoben wird": „therapeutische Maßnahme samt Grund und
-- Zeitraum". Der Block ist jünger als grenzkarte.md und schlägt sie.
SELECT pg_temp.expect_accept(
    '08 — therapeutische Maßnahme mit Behandlungszeitraum',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, has_treatment_reason,
                                  description, treatment_reason,
                                  treatment_from, treatment_until,
                                  permission_granted_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, true, true, 'Logopädie',
               'Aussprache', DATE '2026-09-01', DATE '2027-07-31',
               now(), 'system:check')$q$);

-- Eine laufende Maßnahme hat kein Ende: der Anfang allein genügt.
SELECT pg_temp.expect_accept(
    '08 — Behandlungszeitraum ohne Ende',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, has_treatment_reason,
                                  description, treatment_reason, treatment_from,
                                  permission_granted_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, true, true, 'Physiotherapie',
               'Haltung', DATE '2026-10-01', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Behandlungszeitraum, der vor seinem Anfang endet',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, has_treatment_reason,
                                  description, treatment_reason,
                                  treatment_from, treatment_until,
                                  permission_granted_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, true, true, 'Ergotherapie',
               'Feinmotorik', DATE '2027-07-31', DATE '2026-09-01',
               now(), 'system:check')$q$);

-- Dasselbe Flag steuert Grund und Zeitraum: eine Art ohne Behandlungsgrund
-- trägt auch keinen Zeitraum.
SELECT pg_temp.expect_reject(
    '08 — Behandlungszeitraum an einer Art, die keinen erhebt',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id, description,
                                  treatment_from, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, 'Nussallergie',
               DATE '2026-09-01', 'system:check')$q$);

-- G1 — 08: „ob die Schule handeln darf", „bei Medikamenten dazu, ob das Kind
-- sie selbst nimmt", „therapeutische Maßnahme samt Grund", „Notfallmedikament
-- samt Notfallbeschreibung". Vier Flags an der Merkmalsart, vier Regeln je
-- Merkmal — vorher benannten sie die Regeln und trugen keine.
SELECT pg_temp.expect_reject(
    '08 — Verabreichungserlaubnis an einer Allergie',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id, description,
                                  permission_granted_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, 'Nussallergie',
               now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — „ob das Kind sie selbst nimmt" an einer Nicht-Medikamentart',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id, description,
                                  self_administered, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, 'Nussallergie',
               true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Behandlungsgrund an einer Art, die keinen erhebt',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id, description,
                                  treatment_reason, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, 'Nussallergie',
               'Feinmotorik', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Notfallbeschreibung an einer therapeutischen Maßnahme',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, has_treatment_reason,
                                  description, treatment_reason,
                                  emergency_description, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 3, true, true, 'Logopädie',
               'Aussprache', 'Notruf wählen', 'system:check')$q$);

-- Die mitgeführten Flags sind an ihre Merkmalsart gebunden: geliehene gibt es
-- nicht (rules.md Abschnitt 1).
SELECT pg_temp.expect_reject(
    'rules.md 1 — Allergie mit den Flags des Notfallmedikaments',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, is_medication, is_emergency_medication,
                                  description, permission_granted_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, true, true, true,
               'Nussallergie', now(), 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '08 — Notfallmedikament mit Notfallbeschreibung',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, is_medication, is_emergency_medication,
                                  description, permission_granted_at, self_administered,
                                  emergency_description, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, true, true, true,
               'Notfallset Insekten', now(), false,
               'Pen in den Oberschenkel, dann 112', 'system:check')$q$);

-- grenzkarte.md: „Schulbegleitung ist ein Unterstützungsbedarf … er gehört zu
-- den Gesundheits- und Förderdaten" — als Merkmalsart, nicht als Freitext.
SELECT pg_temp.expect_accept(
    'grenzkarte.md — Schulbegleitung als Merkmal statt als Bewerbungsnotiz',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id, description,
                                  created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 4, 'Integrationskraft vormittags',
               'system:check')$q$);

-- 08: „Je Punkt — … therapeutische Maßnahme samt Grund und Zeitraum,
-- Zeckenentfernung — steht, was, ob ein Attest vorlag und ob die Schule handeln
-- darf", und Lehrkräfte und Hort sehen sie im Alltag. grenzkarte.md führt sie
-- als Q1-Zweck; der jüngere Block schlägt die Karte, sie ist deshalb eine
-- Merkmalsart mit eigener Erlaubnis.
SELECT pg_temp.expect_accept(
    '08 — Zeckenentfernung als Merkmal mit Handlungserlaubnis',
    $q$INSERT INTO health_traits (child_health_record_id, health_trait_type_id,
                                  needs_permission, description, permission_granted_at,
                                  created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 5, true,
               'Zecken dürfen entfernt werden', now(), 'system:check')$q$);

-- grenzkarte.md: „er muss schnell nachprüfbar sein" — je Kind eine Zeile.
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

-- grenzkarte.md, Q2: „Eine verwaiste Datei in SharePoint ist genauso ein
-- DSGVO-Verstoß wie eine verwaiste Zeile" — deshalb blockiert ein Attest das
-- Löschen des Kindes, bis der Lösch-Lauf die Datei mitentfernt hat.
SELECT pg_temp.expect_reject(
    'Q2 — Kind gelöscht, obwohl noch ein Attest in SharePoint liegt',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

-- 03: gelöscht wird „die Gesundheitsangaben nach dem letzten bestätigten Ende
-- dieses Kindes" — die Frist rechnet am Ende und nicht am Löschen. Diese Probe
-- belegt allein den Cascade: ist die Datei fort, geht der ganze Bestand mit dem
-- Kind.
SELECT pg_temp.expect_accept(
    '03 — der Bestand verschwindet mit dem Kind',
    $q$UPDATE health_traits SET certificate_document_id = NULL;
       DELETE FROM documents WHERE child_id = '44444444-4444-4444-4444-444444444441';
       DELETE FROM children  WHERE child_id = '44444444-4444-4444-4444-444444444441'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM child_health_records) OR EXISTS (SELECT 1 FROM health_traits)
       OR EXISTS (SELECT 1 FROM measles_proofs) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Gesundheitsdaten überleben ihr Kind';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 03 — kein Gesundheitsdatum überlebt sein Kind';
END $$;

DO $$ BEGIN RAISE NOTICE 'gesundheit-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
