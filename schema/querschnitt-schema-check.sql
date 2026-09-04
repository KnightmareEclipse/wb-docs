-- Prüfskript zu querschnitt-schema.sql.
--
-- Sollstand: 20 Tabellen — acht Wertelisten (consent_purposes,
-- sharepoint_libraries, child_file_categories, document_types, sync_targets,
-- contract_text_kinds, retention_subjects, retention_hold_reasons),
-- Q2 (contract_texts,
-- signatures, documents, child_file_folders), Q1 (consents), Q3 (payments),
-- Q5 (sync_tasks), die drei übrigen Hebel (configured_values, change_log,
-- outbound_emails) und die zwei des Lösch-Laufs
-- (retention_notice_recipients, retention_holds).
-- Die vertragsgebundenen Gegenproben zu `signatures` stehen in
-- anmeldung-schema-check.sql, weil ihr Fremdschlüssel dort entsteht; die
-- Unterschrift unter dem SEPA-Mandat steht hier, sie kennt keinen Vertrag.
-- `contract_text_kinds` definiert die Dokumentsorte vollständig: Klasse,
-- Dokumentart und die Graph-Kennung der Arbeitsfassung. `contract_texts` trägt
-- die eingefrorene Vorlagendatei samt Prüfsumme und Einfrierzeitpunkt, und für
-- sie trägt die Änderungsspur die Prüfsumme statt des Werts. `child_file_folders`
-- führt eine Zeile je Kind, Bibliothek und Kategorie; `documents` zeigt auf den
-- Ordner statt auf die Bibliothek, trägt eine Pflicht-Bezeichnung und eine
-- freiwillige Art.
-- Dazu fünfzehn partielle Unique-Indizes (drei für signatures, zwei für
-- consents, neun für sync_tasks, einer über die erste Zeile je angehaltenem
-- Fall) und zwei Lese-Indizes, auf outbound_emails und auf change_log. `payments` trägt außerdem ein UNIQUE auf der Zahlungsreferenz;
-- seine Gegenprobe steht in putzdienst-schema-check.sql, weil sie wie die
-- übrigen Q3-Proben einen echten Anlass braucht.
--
-- Setzt stammdaten-schema.sql voraus. Läuft in einer Transaktion, die am Ende
-- zurückgerollt wird:
--   psql -v ON_ERROR_STOP=1 -f querschnitt-schema-check.sql

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Existiert jede Tabelle?
-- ---------------------------------------------------------------------------
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY[
        'consent_purposes', 'sharepoint_libraries', 'child_file_categories',
        'document_types',
        'sync_targets', 'signatures', 'documents', 'child_file_folders',
        'consents', 'payments', 'sync_tasks', 'configured_values', 'change_log',
        'contract_text_kinds',
        'contract_texts', 'outbound_emails',
        'retention_subjects', 'retention_hold_reasons',
        'retention_notice_recipients', 'retention_holds'
    ]) AS t
    WHERE to_regclass('public.' || t) IS NULL;

    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 20 Tabellen vorhanden';
END $$;

-- ---------------------------------------------------------------------------
-- 2. Trägt jedes benannte Constraint und jeder Index seinen Namen?
-- ---------------------------------------------------------------------------
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_consents', 'pk_payments', 'pk_sync_tasks', 'pk_signatures',
        'pk_documents', 'pk_change_log',
        'fk_consents_person', 'fk_consents_child', 'fk_consents_signature',
        'fk_documents_child', 'fk_sync_tasks_target', 'fk_sync_targets_role',
        'fk_sync_tasks_payment', 'fk_sync_tasks_branch',
        'uq_child_file_folders', 'uq_child_file_folders_graph_item',
        'uq_child_file_folders_id_child', 'fk_child_file_folders_category',
        'pk_child_file_categories', 'uq_child_file_categories_code',
        'fk_child_file_categories_retention',
        'fk_documents_folder', 'ck_documents_label',
        'ck_consents_answer', 'ck_consents_revocation',
        'ck_consents_revoked_after_granted', 'ck_sync_tasks_completed_by',
        'ck_signatures_level',
        'ck_payments_single_cause', 'ck_payments_status', 'ck_payments_confirmed',
        'ck_payments_amount', 'uq_payments_payment_reference',
        'ck_sync_tasks_single_subject',
        'ck_sync_tasks_outcome', 'ck_sync_tasks_completed',
        'ck_documents_purpose', 'ck_documents_filed', 'ck_documents_not_required',
        'ck_change_log_values', 'ck_change_log_operation', 'ck_change_log_column_scope',
        'fk_signatures_mandate', 'fk_signatures_child',
        'ck_signatures_subject', 'ck_signatures_agreement',
        'fk_signatures_image_library', 'ck_signatures_image',
        'fk_change_log_person', 'fk_change_log_child', 'fk_change_log_family',
        'ck_change_log_single_anchor',
        'pk_configured_values', 'uq_configured_values',
        'pk_contract_texts', 'uq_contract_texts',
        'uq_consent_purposes_requires_child', 'fk_consents_purpose',
        'uq_consent_purposes_newsletter', 'fk_outbound_emails_topic',
        'ck_outbound_emails_topic', 'ck_outbound_emails_topic_person',
        'ck_consents_child',
        'fk_consents_document', 'fk_sepa_mandates_document',
        'uq_documents_graph_item', 'uq_documents_id_child', 'uq_signatures_id_person',
        'pk_contract_text_kinds', 'uq_contract_text_kinds_code',
        'ck_contract_text_kinds_class', 'ck_contract_text_kinds_working',
        'ck_contract_text_kinds_class_shape',
        'fk_contract_text_kinds_document_type', 'fk_contract_text_kinds_working_library',
        'ck_contract_texts_frozen', 'ck_contract_texts_checksum',
        'ck_change_log_template',
        'fk_contract_texts_kind', 'uq_contract_texts_id_code',
        'uq_sync_targets_branch_bound', 'ck_sync_tasks_branch_bound',
        'pk_retention_subjects', 'uq_retention_subjects_code',
        'pk_retention_hold_reasons', 'uq_retention_hold_reasons_code',
        'pk_retention_notice_recipients', 'uq_retention_notice_recipients',
        'fk_retention_notice_recipients_subject', 'fk_retention_notice_recipients_employee',
        'fk_retention_notice_recipients_role', 'fk_retention_notice_recipients_branch',
        'ck_retention_notice_recipients_kind', 'ck_retention_notice_recipients_branch',
        'pk_retention_holds', 'fk_retention_holds_subject', 'fk_retention_holds_reason',
        'fk_retention_holds_child', 'fk_retention_holds_person', 'fk_retention_holds_family',
        'fk_retention_holds_first', 'uq_retention_holds_original',
        'ck_retention_holds_single_anchor', 'ck_retention_holds_first_other',
        'ck_retention_holds_held_until'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;

    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY[
        'ix_consents_person_child_purpose', 'ix_consents_person_purpose',
        'ix_sync_tasks_open_person', 'ix_sync_tasks_open_child',
        'ix_sync_tasks_open_family', 'ix_sync_tasks_open_year',
        'ix_sync_tasks_open_period', 'ix_sync_tasks_open_booking',
        'ix_sync_tasks_open_academy',
        'ix_sync_tasks_open_slot', 'ix_sync_tasks_open_payment', 'ix_change_log_row',
        'ix_signatures_contract', 'ix_signatures_agreement', 'ix_signatures_mandate',
        'ix_outbound_emails_undeliverable', 'ix_retention_holds_held_until',
        'ix_retention_holds_first'
    ]) AS i
    WHERE to_regclass('public.' || i) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Indizes: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints und Indizes vorhanden';
END $$;

-- ---------------------------------------------------------------------------
-- 3. Hilfsfunktionen
-- ---------------------------------------------------------------------------
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
-- 4. Stammsätze
-- ---------------------------------------------------------------------------
INSERT INTO countries (code, name, nationality_name) VALUES ('DE', 'Deutschland', 'deutsch');
INSERT INTO school_branches (code, name, first_grade_level, final_grade_level, created_by)
    VALUES ('GS', 'Grundschule', 1, 4, 'system:check');
INSERT INTO roles (code, name, created_by) VALUES ('secretariat', 'Sekretariat', 'system:check');
-- Die eine zweiggebundene Rolle: „eine Schulleitung sieht … für die andere
-- Schulform nichts" (hebel.md). An ihr hängen die Proben zur Schulart unten.
INSERT INTO roles (code, name, is_branch_bound, created_by)
    VALUES ('school_management', 'Schulleitung', true, 'system:check');
-- Beide Personen wohnen an derselben Anschrift — „ein Häkchen, kein zweiter
-- Vorgang" (02). Sie ist der Anlass für Stufe 7 des Lösch-Laufs unten.
INSERT INTO addresses (address_id, street, house_number, postal_code, city, country_id, created_by)
    VALUES ('11111111-1111-1111-1111-111111111111', 'Hauptstr.', '1', '12345', 'Musterstadt',
            (SELECT country_id FROM countries WHERE code = 'DE'), 'system:check');
INSERT INTO persons (person_id, first_name, last_name, address_id, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Kind',   'Muster',
     '11111111-1111-1111-1111-111111111111', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Mutter', 'Muster',
     '11111111-1111-1111-1111-111111111111', 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222221',
            '33333333-3333-3333-3333-333333333333', DATE '2020-05-01', 'system:check');

INSERT INTO sharepoint_libraries (sharepoint_library_id, code, name, graph_drive_id, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'student_file', 'Digitale Schülerakte', 'b!drive-1', 'system:check');
INSERT INTO document_types (code, name, created_by)
    VALUES ('school_contract', 'Schulvertrag', 'system:check'),
           ('observation_sheet', 'Beobachtungsbogen', 'system:check'),
           ('sepa_mandate', 'SEPA-Mandat', 'system:check');
-- Die Unterordner der Akte, „jeder mit seiner eigenen Frist" (grenzkarte.md,
-- Q2). Welche es am Ende gibt, setzt der Datenschutzbeauftragte; zwei genügen
-- hier, um den zweiten Ordner derselben Kategorie abweisen zu können.
INSERT INTO child_file_categories (child_file_category_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'contracts',   'Verträge und Vereinbarungen', 'system:check'),
    (2, 'proceedings', 'Verfahrensunterlagen',        'system:check');
INSERT INTO consent_purposes (code, name, requires_child, self_consent_age, created_by)
    VALUES ('photo', 'Fotoeinverständnis', true, 14, 'system:check'),
           ('marketing_holiday', 'Werbe-Einwilligung Ferienbetreuung', false, NULL, 'system:check');
-- Ohne festen Schlüssel und ohne OVERRIDING SYSTEM VALUE, aus demselben Grund
-- wie `payees` in rechnungsfreigabe-schema-check.sql: mit festem Schlüssel
-- bliebe die Identity-Folge auf 1 stehen, und die Probe „derselbe Vertragstext
-- zweimal zum selben Gültigkeitstag" weiter unten legt ohne Schlüssel an — sie
-- scheiterte dann an `pk_contract_texts` statt an `uq_contract_texts`, den sie
-- zu prüfen behauptet.
-- Die Textsorte steht als Wert im System; eine Fassung ohne sie gibt es nicht.
INSERT INTO contract_text_kinds (code, name, kind_class, document_type_id,
                                 working_library_id, working_item_id, created_by) VALUES
    ('school_contract_gs', 'Schulvertrag Grundschule', 'signed',
     (SELECT document_type_id FROM document_types WHERE code = 'school_contract'),
     1, 'item-vorlage-gs', 'system:check');

INSERT INTO contract_texts (code, valid_from, body, created_by)
    VALUES ('school_contract_gs', DATE '2026-08-01', 'Vertragstext GS', 'system:check');
INSERT INTO sync_targets (code, name, role_id, created_by)
    VALUES ('asv_bw', 'ASV-BW', (SELECT role_id FROM roles WHERE code='secretariat'), 'system:check'),
           ('optigem', 'Optigem', (SELECT role_id FROM roles WHERE code='secretariat'), 'system:check');
-- 08 Z4: „die Freigabe bei der Schulleitung dieser Schulart" — das einzige Ziel
-- dieser Datei, dessen Rolle an eine Schulart gebunden ist.
INSERT INTO sync_targets (code, name, role_id, is_branch_bound, created_by)
    VALUES ('contract_release', 'Freigabe Schulvertrag',
            (SELECT role_id FROM roles WHERE code='school_management'), true, 'system:check');

-- Das Flag ist an seine Rollenzeile gebunden; ein geliehenes gibt es nicht
-- (rules.md Abschnitt 1) — sonst trüge jedes Ziel die Zweigbindung, die es
-- gerade braucht.
SELECT pg_temp.expect_reject(
    'Q5 — Ziel mit dem Zweig-Flag einer Rolle, die es nicht hat',
    $q$INSERT INTO sync_targets (code, name, role_id, is_branch_bound, created_by)
       VALUES ('geliehen', 'Geliehenes Flag',
               (SELECT role_id FROM roles WHERE code='secretariat'), true, 'system:check')$q$);
INSERT INTO sepa_mandates (sepa_mandate_id, child_id, account_holder_person_id, iban,
                           credit_institution, mandate_reference, created_by)
    VALUES ('66666666-6666-6666-6666-666666666666',
            '44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            'DE02120300000000202051', 'Musterbank', 'WB-0001', 'system:check');

-- ---------------------------------------------------------------------------
-- 5. Gegenproben — Q1
-- ---------------------------------------------------------------------------

-- grenzkarte.md, „Drei Zustände": genau eine der beiden Antworten steht.
SELECT pg_temp.expect_reject(
    'Q1 — Zustimmung ohne Antwort',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child, delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               'mutter@example.org', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q1 — Zustimmung erteilt UND abgelehnt',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child, granted_at, declined_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               now(), now(), 'mutter@example.org', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q1 — Zustimmung mit leerer Zustelladresse',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child, granted_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               now(), '', 'system:check')$q$);

-- README: „Der Vollimport bringt die eingeschriebenen Kinder mit, aber nicht
-- die Bestände … Das Sekretariat trägt sie aus den Akten nach." Eine aus der
-- Papierakte nachgetragene Antwort hatte keinen Kanal und deshalb keine
-- Zustelladresse; ein NOT NULL zwänge dort zu einer erfundenen. Auf dieser
-- Zeile bauen die folgenden Gegenproben auf.
SELECT pg_temp.expect_accept(
    'Q1 — aus der Akte nachgetragenes Fotoeinverständnis ohne Zustelladresse',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child,
                             granted_at, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               now(), 'entra:sekretariat')$q$);

SELECT pg_temp.expect_reject(
    'Q1 — zweite gültige Antwort derselben Person zu demselben Kind und Zweck',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child, declined_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               now(), 'mutter@example.org', 'system:check')$q$);

-- grenzkarte.md, Q1: der Zeitpunkt ist der Nachweis nach Art. 7 Abs. 1 DSGVO
-- — eine Erteilung, die nach ihrem Widerruf datiert, belegt nichts.
SELECT pg_temp.expect_reject(
    'Q1 — Widerruf zehn Tage vor der Erteilung',
    $q$INSERT INTO consents (person_id, consent_purpose_id, requires_child, granted_at, revoked_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='marketing_holiday'), false,
               now(), now() - interval '10 days', 'mutter@example.org', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q1 — Widerruf einer Ablehnung',
    $q$INSERT INTO consents (person_id, consent_purpose_id, requires_child, declined_at, revoked_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='marketing_holiday'), false,
               now(), now(), 'mutter@example.org', 'system:check')$q$);

-- Die Ablehnung ist eine eigene Zeile: nach dem Widerruf darf eine neue Antwort
-- daneben entstehen (grenzkarte.md, Q1).
SELECT pg_temp.expect_accept(
    'Q1 — neue Antwort nach Widerruf der ersten',
    $q$UPDATE consents SET revoked_at = now()
         WHERE consent_purpose_id = (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo');
       INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child, declined_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               now(), 'mutter@example.org', 'system:check')$q$);

-- Q2 — 08: das Fotoeinverständnis ist „für alle Lehrkräfte, Hortkräfte und das
-- Sekretariat ohne Umweg sichtbar", und sichtbar wird es je Kind. Ohne `child_id`
-- fiele die Zeile aus beiden Unique-Indizes und aus jeder solchen Ansicht.
SELECT pg_temp.expect_reject(
    'Q2 — Fotoeinverständnis ohne Kind',
    $q$INSERT INTO consents (person_id, consent_purpose_id, requires_child, granted_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               now(), 'mutter@example.org', 'system:check')$q$);

-- Das mitgeführte Flag ist an seine Zweckzeile gebunden: ein geliehenes gibt es
-- nicht (rules.md Abschnitt 1).
SELECT pg_temp.expect_reject(
    'Q2 — Fotoeinverständnis mit dem Flag der Werbe-Einwilligung',
    $q$INSERT INTO consents (person_id, consent_purpose_id, requires_child, granted_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), false,
               now(), 'mutter@example.org', 'system:check')$q$);

-- grenzkarte.md, Q1: die Werbe-Einwilligung Ferienbetreuung hängt an der Person
-- und an keinem Kind.
-- Q12: die kindlose Variante des Eindeutigkeits-Index trägt dieselbe Regel wie
-- die mit Kind — „je Person und Zweck höchstens eine gültige Antwort".
SELECT pg_temp.expect_accept(
    'Q1 — Werbe-Einwilligung ohne Kind',
    $q$INSERT INTO consents (person_id, consent_purpose_id, requires_child, granted_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='marketing_holiday'),
               false, now(), 'mutter@example.org', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q12 — zweite gültige Antwort derselben Person zu einem Zweck ohne Kind',
    $q$INSERT INTO consents (person_id, consent_purpose_id, requires_child, declined_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='marketing_holiday'),
               false, now(), 'mutter@example.org', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    'Q12 — neue Antwort ohne Kind, nachdem die erste widerrufen wurde',
    $q$UPDATE consents SET revoked_at = now()
         WHERE child_id IS NULL AND revoked_at IS NULL
           AND consent_purpose_id = (SELECT consent_purpose_id FROM consent_purposes
                                      WHERE code='marketing_holiday');
       INSERT INTO consents (person_id, consent_purpose_id, requires_child, declined_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='marketing_holiday'),
               false, now(), 'mutter@example.org', 'system:check')$q$);


-- ---------------------------------------------------------------------------
-- 6. Gegenproben — Q2
-- ---------------------------------------------------------------------------

-- Der Ordner steht vor der Datei: `documents` zeigt auf ihn und nicht mehr auf
-- die Bibliothek. Zwei Kategorien desselben Kindes in derselben Akte — das ist
-- der Regelfall, seit sich die Akte in Unterordner teilt.
INSERT INTO child_file_folders (child_file_folder_id, child_id, sharepoint_library_id,
                                child_file_category_id, graph_item_id, created_by)
    VALUES ('10000000-0000-0000-0000-000000000001',
            '44444444-4444-4444-4444-444444444444', 1, 1, '01FOLDER', 'system:check'),
           ('10000000-0000-0000-0000-000000000002',
            '44444444-4444-4444-4444-444444444444', 1, 2, '01FOLDER2', 'system:check');

SELECT pg_temp.expect_reject(
    'Q2 — zweiter Ordner derselben Kategorie in derselben Bibliothek',
    $q$INSERT INTO child_file_folders (child_id, sharepoint_library_id,
                                       child_file_category_id, graph_item_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 1, 1, '01OTHER', 'system:check')$q$);

-- grenzkarte.md, Q2: „der am Anmeldetag verlangte, aber nicht mitgebrachte
-- Beobachtungsbogen ist eine Anforderung ohne Ablageort".
SELECT pg_temp.expect_accept(
    'Q2 — Anforderung ohne Datei',
    $q$INSERT INTO documents (child_id, document_type_id, label, child_file_folder_id,
                              sharepoint_library_id, requested_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='observation_sheet'),
               'Beobachtungsbogen', '10000000-0000-0000-0000-000000000002',
               1, now(), 'system:check')$q$);

-- grenzkarte.md, Q2: „Die Art ist freiwillig … Alles Übrige liegt mit Kategorie
-- und Bezeichnung da und braucht keine Art." Die Bezeichnung dagegen ist
-- Pflicht — ohne Art wäre die Datei sonst an nichts zu erkennen.
SELECT pg_temp.expect_accept(
    'Q2 — Schriftwechsel ohne Art, mit Bezeichnung',
    $q$INSERT INTO documents (child_id, label, child_file_folder_id,
                              sharepoint_library_id, graph_item_id, filed_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'Brief der Klassenlehrkraft',
               '10000000-0000-0000-0000-000000000002', 1, '01BRIEF', now(),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — Datei ohne Bezeichnung',
    $q$INSERT INTO documents (child_id, label, child_file_folder_id,
                              sharepoint_library_id, graph_item_id, filed_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', '',
               '10000000-0000-0000-0000-000000000002', 1, '01LEER', now(),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — Dokumentzeile ohne Anforderung und ohne Datei',
    $q$INSERT INTO documents (child_id, document_type_id, label, child_file_folder_id,
                              sharepoint_library_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='school_contract'),
               'Schulvertrag', '10000000-0000-0000-0000-000000000001', 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — Datei ohne Ablagezeitpunkt',
    $q$INSERT INTO documents (child_id, document_type_id, label, child_file_folder_id,
                              sharepoint_library_id, graph_item_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='school_contract'),
               'Schulvertrag', '10000000-0000-0000-0000-000000000001', 1, '01ABC',
               'system:check')$q$);

-- 08: „eine Unterlage, eine Datei" — Mandat und unterschriebene Zustimmung
-- zeigen auf ihre eigene Datei, und die Datei geht nicht, solange eines von
-- beiden sie festhält (Lösch-Lauf, Stufe 1).
INSERT INTO documents (document_id, child_id, document_type_id, label,
                       child_file_folder_id, sharepoint_library_id,
                       graph_item_id, filed_at, created_by)
    VALUES ('99999999-9999-9999-9999-999999999998', '44444444-4444-4444-4444-444444444444',
            (SELECT document_type_id FROM document_types WHERE code='sepa_mandate'),
            'SEPA-Mandat', '10000000-0000-0000-0000-000000000001',
            1, '01MANDAT', now(), 'system:check');
SELECT pg_temp.expect_accept(
    'Q2 — das Mandat zeigt auf seine eigene Datei',
    $q$UPDATE sepa_mandates SET document_id = '99999999-9999-9999-9999-999999999998'
        WHERE sepa_mandate_id = '66666666-6666-6666-6666-666666666666'$q$);
SELECT pg_temp.expect_reject(
    'Q2 — die Datei des Mandats geht nicht, solange das Mandat steht',
    $q$DELETE FROM documents WHERE document_id = '99999999-9999-9999-9999-999999999998'$q$);
-- Die Person ist das Kind selbst: Es hat an dieser Stelle noch keine Antwort,
-- also kann allein der Fremdschlüssel auf die Datei abweisen.
SELECT pg_temp.expect_reject(
    'Q2 — Zustimmung mit einer Datei, die es nicht gibt',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child, granted_at,
                             delivery_address, document_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222221',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
               now(), 'kind@example.org', '99999999-9999-9999-9999-999999999990',
               'system:check')$q$);

-- Ein zweites Kind mit eigener Akte: Es trägt die beiden Verwechslungsproben
-- darunter und sonst nichts. Seine Person hat bewusst keine Anschrift — Stufe 7
-- des Lösch-Laufs prüft weiter unten, dass keine übrig bleibt.
INSERT INTO persons (person_id, first_name, last_name, created_by)
    VALUES ('22222222-2222-2222-2222-222222222226', 'Kind D', 'Muster', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444447',
            '22222222-2222-2222-2222-222222222226',
            '33333333-3333-3333-3333-333333333333', DATE '2017-05-01', 'system:check');
INSERT INTO child_file_folders (child_file_folder_id, child_id, sharepoint_library_id,
                                child_file_category_id, graph_item_id, created_by)
    VALUES ('10000000-0000-0000-0000-000000000003',
            '44444444-4444-4444-4444-444444444447', 1, 1, '01FOLDERD', 'system:check');
INSERT INTO documents (document_id, child_id, document_type_id, label,
                       child_file_folder_id, sharepoint_library_id,
                       graph_item_id, filed_at, created_by)
    VALUES ('99999999-9999-9999-9999-999999999997', '44444444-4444-4444-4444-444444444447',
            (SELECT document_type_id FROM document_types WHERE code='school_contract'),
            'Schulvertrag', '10000000-0000-0000-0000-000000000003',
            1, '01KINDD', now(), 'system:check');

-- Ein Ordner ist ein Graph-Element wie jede Datei; zwei Zeilen darauf ließen
-- den Lösch-Lauf einen Ordner entfernen, auf den die zweite noch zeigt.
SELECT pg_temp.expect_reject(
    'Q2 — zweiter Ordner auf demselben Graph-Element',
    $q$INSERT INTO child_file_folders (child_id, sharepoint_library_id,
                                       child_file_category_id, graph_item_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444447', 1, 2, '01FOLDER', 'system:check')$q$);

-- grenzkarte.md, Q2: „Eine Datei beim falschen Kind ist keine ältere Fassung."
-- Der zusammengesetzte Fremdschlüssel bindet die Datei an einen Ordner
-- **desselben** Kindes; ohne ihn hinge das Blatt des einen in der Akte des
-- anderen, und die Verwechslung wäre eingebaut statt behoben.
SELECT pg_temp.expect_reject(
    'Q2 — Datei im Ordner eines anderen Kindes',
    $q$INSERT INTO documents (child_id, label, child_file_folder_id,
                              sharepoint_library_id, graph_item_id, filed_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'Zeugnis',
               '10000000-0000-0000-0000-000000000003', 1, '01FREMD', now(),
               'system:check')$q$);

-- grenzkarte.md, Q2: „Jede Datei bekommt eine Zeile" — und keine Datei zwei.
-- Ohne `uq_documents_graph_item` zeigten hier zwei Kinder auf dasselbe
-- Graph-Element, und der Lösch-Lauf nähme dem einen die Datei des anderen mit.
SELECT pg_temp.expect_reject(
    'Q2 — zweite Dokumentzeile auf dasselbe Graph-Element',
    $q$INSERT INTO documents (child_id, document_type_id, label, child_file_folder_id,
                              sharepoint_library_id, graph_item_id, filed_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444447',
               (SELECT document_type_id FROM document_types WHERE code='school_contract'),
               'Schulvertrag', '10000000-0000-0000-0000-000000000003',
               1, '01MANDAT', now(), 'system:check')$q$);

-- grenzkarte.md, Q2: „Eine Datei beim falschen Kind … die Verwechslung wäre
-- damit nicht behoben, sondern eingebaut." Der Zweck ist ein dritter, damit
-- allein der zusammengesetzte Fremdschlüssel abweisen kann und nicht der
-- Eindeutigkeits-Index.
INSERT INTO consent_purposes (code, name, requires_child, created_by)
    VALUES ('health_data', 'Gesundheitsangaben', true, 'system:check');
SELECT pg_temp.expect_reject(
    'Q2 — Zustimmung für ein Kind mit der Datei eines anderen',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child, granted_at,
                             delivery_address, document_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='health_data'), true,
               now(), 'mutter@example.org', '99999999-9999-9999-9999-999999999997',
               'system:check')$q$);

-- 06: „Unterlagen, je Stück vorgelegt, fehlt oder nicht nötig" — der dritte
-- Stand steht allein und ist von „fehlt" unterscheidbar.
SELECT pg_temp.expect_accept(
    '06 — Unterlage als nicht nötig festgestellt',
    $q$INSERT INTO documents (child_id, document_type_id, label, child_file_folder_id,
                              sharepoint_library_id, not_required_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='school_contract'),
               'Schulvertrag', '10000000-0000-0000-0000-000000000001', 1, now(),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '06 — Unterlage zugleich vorgelegt und nicht nötig',
    $q$INSERT INTO documents (child_id, document_type_id, label, child_file_folder_id,
                              sharepoint_library_id, not_required_at, graph_item_id,
                              filed_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='observation_sheet'),
               'Beobachtungsbogen', '10000000-0000-0000-0000-000000000002', 1, now(),
               '01ABC', now(), 'system:check')$q$);

-- Die vertragsgebundenen Gegenproben zu `signatures` stehen in
-- anmeldung-schema-check.sql: ihr Fremdschlüssel auf den Vertragsvorgang
-- entsteht dort, und eine Signatur ohne gültigen Vorgang lässt sich im
-- Gesamtdurchgang gar nicht mehr anlegen. Was ohne ihn gilt, steht hier.

-- 08: „Eine sorgeberechtigte Person füllt im Portal ein neues [Mandat] aus und
-- unterschreibt … der Vertrag darunter bleibt unberührt."
SELECT pg_temp.expect_accept(
    '08 — Unterschrift unter dem SEPA-Mandat, ohne Vertrag',
    $q$INSERT INTO signatures (sepa_mandate_id, person_id, signed_at, created_by)
       VALUES ('66666666-6666-6666-6666-666666666666',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — zweite Unterschrift unter demselben Mandat',
    $q$INSERT INTO signatures (sepa_mandate_id, person_id, signed_at, created_by)
       VALUES ('66666666-6666-6666-6666-666666666666',
               '22222222-2222-2222-2222-222222222221', now(), 'system:check')$q$);

-- 08: „Ab 14 unterschreibt das Kind sein Fotoeinverständnis mit — über einen
-- Signaturlink, keinen Zugang"; die Zustimmung zeigt darauf (grenzkarte.md, Q1).
-- `child_id` ist hier der Löschanker und nicht der Bezug der Zustimmung: ohne
-- ihn hinge diese Unterschrift an nichts.
SELECT pg_temp.expect_accept(
    '08 — Unterschrift des Kindes am Fotoeinverständnis, ohne Vertrag',
    $q$WITH s AS (
         INSERT INTO signatures (signature_id, child_id, person_id, signed_at, created_by)
         VALUES ('55555555-5555-5555-5555-555555555511',
                 '44444444-4444-4444-4444-444444444444',
                 '22222222-2222-2222-2222-222222222221', now(), 'system:check')
         RETURNING signature_id)
       INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child,
                             granted_at, delivery_address, signature_id, created_by)
       SELECT '22222222-2222-2222-2222-222222222221',
              '44444444-4444-4444-4444-444444444444',
              (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
              now(), 'kind@example.org', s.signature_id, 'system:check'
       FROM s$q$);

-- Dieselbe Verwechslung an der Unterschrift: Die Signatur oben gehört dem Kind,
-- die Antwort hier der Mutter. Ohne den zusammengesetzten Fremdschlüssel
-- belegte eine fremde Unterschrift ihre Zustimmung.
SELECT pg_temp.expect_reject(
    'Q1 — Zustimmung einer Person mit der Unterschrift einer anderen',
    $q$INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child,
                             granted_at, delivery_address, signature_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               '44444444-4444-4444-4444-444444444444',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='health_data'), true,
               now(), 'mutter@example.org', '55555555-5555-5555-5555-555555555511',
               'system:check')$q$);

-- grenzkarte.md, Q2: „heute durchgängig einfache elektronische Signatur", und
-- das elektronische Siegel „wird bewusst nicht beschafft" (08) — ein höheres
-- Niveau kennt kein Block.
SELECT pg_temp.expect_reject(
    'Q2 — Unterschrift mit qualifiziertem Signaturniveau',
    $q$INSERT INTO signatures (child_id, person_id, signed_at, signature_level, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222222', now(), 'qualified', 'system:check')$q$);

-- grenzkarte.md, Q2: „Bibliothek plus Element, beide nur gemeinsam gültig."
SELECT pg_temp.expect_reject(
    'Q2 — Namenszug mit halber Graph-Kennung',
    $q$INSERT INTO signatures (child_id, person_id, signed_at, signature_image_item_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222222', now(), '01SIG', 'system:check')$q$);

-- 08: jede Unterschrift trägt genau einen Bezug und damit genau einen
-- Löschanker — sonst bleibt sie nach dem Vorgang stehen, den sie belegt.
SELECT pg_temp.expect_reject(
    '08 — Unterschrift ganz ohne Bezug und damit ohne Löschanker',
    $q$INSERT INTO signatures (person_id, signed_at, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Unterschrift zugleich am Mandat und am Kind',
    $q$INSERT INTO signatures (sepa_mandate_id, child_id, person_id, signed_at, created_by)
       VALUES ('66666666-6666-6666-6666-666666666666',
               '44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222222', now(), 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- 7. Gegenproben — Q3
-- ---------------------------------------------------------------------------

-- Umgekehrt zur ersten Fassung, und der Grund steht am Constraint: „Trägt die
-- Bedingung beim Rückruf nicht mehr, wird nichts automatisch erstattet"
-- (api/gemeinsam.md). Die Zahlung ohne Anlass ist der einzige Fall, in dem das
-- System sonst Geld verlöre.
SELECT pg_temp.expect_accept(
    'Q3 — Zahlung ohne Anlass ist eintragbar',
    $q$INSERT INTO payments (payment_id, amount_cents, created_by)
       VALUES ('99999999-9999-9999-9999-999999999999', 2500, 'system:check')$q$);

-- Gelockert heißt nicht offen: zwei Anlässe bleiben abgewiesen. Die Probe
-- braucht keinen echten Vorgang — der CHECK zählt vor dem Fremdschlüssel, und
-- was er abweist, wird nie referenziert.
SELECT pg_temp.expect_reject(
    'Q3 — zwei Anlässe an einer Zahlung',
    $q$INSERT INTO payments (cleaning_buyout_id, application_id, amount_cents, created_by)
       VALUES ('77777777-7777-7777-7777-777777777777',
               '88888888-8888-8888-8888-888888888888', 2500, 'system:check')$q$);

-- Die übrigen Q3-Gegenproben stehen in putzdienst-schema-check.sql: sie
-- brauchen einen Vorgang, auf den die Zahlung zeigen darf, und den bringt erst
-- die erste Domäne mit einem Anlass mit.

-- ---------------------------------------------------------------------------
-- 8. Gegenproben — Q5 und Änderungsspur
-- ---------------------------------------------------------------------------

-- Die Schulart ist kein neunter Bezug, sondern eine Einschränkung des
-- Leserkreises (08 Z4). Die zwei Proben belegen genau das: mit einem Bezug
-- daneben geht die Aufgabe durch, allein trägt die Schulart sie nicht. Das
-- Schuljahr als Bezug, weil es keinen der übrigen Fälle dieser Datei berührt.
SELECT pg_temp.expect_accept(
    'Q5 — Aufgabe mit Bezug und Schulart',
    $q$INSERT INTO sync_tasks (sync_target_id, school_year, school_branch_id, is_branch_bound,
                              task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='contract_release'), 2099,
               (SELECT school_branch_id FROM school_branches ORDER BY school_branch_id LIMIT 1),
               true, 'Freigabe erteilen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — Schulart allein ist kein Bezug',
    $q$INSERT INTO sync_tasks (sync_target_id, school_branch_id, is_branch_bound,
                              task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='contract_release'),
               (SELECT school_branch_id FROM school_branches ORDER BY school_branch_id LIMIT 1),
               true, 'Freigabe erteilen', 'system:check')$q$);

-- 08 Z4: „ohne diese Spalte liest die Grundschulleitung in ihrer Wochenmail die
-- Namen der Realschulkinder." Die Umkehrung gilt genauso: Ein Ziel, dessen
-- Rolle nicht an eine Schulart gebunden ist, bekommt keine — sonst verlöre die
-- Aufgabe die Hälfte ihrer Empfänger.
SELECT pg_temp.expect_reject(
    'Q5 — Schulart an einem Ziel, dessen Rolle nicht zweiggebunden ist',
    $q$INSERT INTO sync_tasks (sync_target_id, school_year, school_branch_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'), 2098,
               (SELECT school_branch_id FROM school_branches ORDER BY school_branch_id LIMIT 1),
               'Jahrgang nachtragen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — zweiggebundenes Ziel ohne Schulart',
    $q$INSERT INTO sync_tasks (sync_target_id, school_year, is_branch_bound, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='contract_release'), 2097,
               true, 'Freigabe erteilen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — Aufgabe ohne Bezug',
    $q$INSERT INTO sync_tasks (sync_target_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
               'Kind anlegen', 'system:check')$q$);


-- Der neunte Bezug, und der Grund für ihn steht an `ck_payments_single_cause`:
-- die vorgangslose Zahlung wartet auf die Entscheidung eines Menschen, und ohne
-- diesen Bezug hinge sie an niemandem.
SELECT pg_temp.expect_accept(
    'Q5 — Aufgabe zu einer Zahlung ohne Vorgang',
    $q$INSERT INTO sync_tasks (sync_target_id, payment_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
               '99999999-9999-9999-9999-999999999999',
               'Zahlung ohne Vorgang prüfen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — Aufgabe an Zahlung und Kind zugleich',
    $q$INSERT INTO sync_tasks (sync_target_id, payment_id, child_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
               '99999999-9999-9999-9999-999999999999',
               '44444444-4444-4444-4444-444444444444',
               'Zahlung ohne Vorgang prüfen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — Aufgabe mit zwei Bezügen',
    $q$INSERT INTO sync_tasks (sync_target_id, child_id, school_year, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
               '44444444-4444-4444-4444-444444444444', 2026, 'Kind anlegen', 'system:check')$q$);

INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
    VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
            '44444444-4444-4444-4444-444444444444', 'Kind anlegen', 'system:check');

SELECT pg_temp.expect_reject(
    'Q5 — zweite offene Aufgabe zu demselben Ziel und Bezug',
    $q$INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
               '44444444-4444-4444-4444-444444444444', 'Adresse nachziehen', 'system:check')$q$);

-- hebel.md: „Je Aufgabenart und Bezug" — zu einer anderen Art darf gleichzeitig
-- eine offene Aufgabe für dasselbe Kind stehen.
SELECT pg_temp.expect_accept(
    'Q5 — offene Aufgabe zu einer zweiten Art für dasselbe Kind',
    $q$INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='optigem'),
               '44444444-4444-4444-4444-444444444444', 'Schulgeld einrichten', 'system:check')$q$);

-- A3 — 09: „Die Änderungsgebühr läuft darin nicht mit … Sie wird deshalb eine
-- eigene Aufgabe." Zwei Arten bei demselben System und derselben Rolle, zwei
-- offene Aufgaben zu demselben Kind — sonst verschluckt die Beitragslage die
-- einmalige Forderung.
INSERT INTO sync_targets (code, name, role_id, created_by)
    VALUES ('optigem_one_off', 'Optigem Einmalforderung',
            (SELECT role_id FROM roles WHERE code='secretariat'), 'system:check');
SELECT pg_temp.expect_accept(
    '09 — Änderungsgebühr neben der Beitragslage desselben Kindes',
    $q$INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='optigem_one_off'),
               '44444444-4444-4444-4444-444444444444', 'Änderungsgebühr fordern',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '09 — zweite offene Änderungsgebühr zu demselben Kind',
    $q$INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='optigem_one_off'),
               '44444444-4444-4444-4444-444444444444', 'Änderungsgebühr fordern',
               'system:check')$q$);

-- Abgehakt heißt: Zeitpunkt, Person und Ergebnis zusammen.
SELECT pg_temp.expect_reject(
    'Q5 — abgehakt ohne Ergebnis',
    $q$UPDATE sync_tasks SET completed_at = now(), completed_by = 'entra:1'
       WHERE task_text = 'Kind anlegen'$q$);

SELECT pg_temp.expect_reject(
    'Q5 — unbekanntes Ergebnis',
    $q$UPDATE sync_tasks SET completed_at = now(), completed_by = 'entra:1', outcome = 'later'
       WHERE task_text = 'Kind anlegen'$q$);

-- 02: „wer sie abgehakt hat" — derselbe Urheber in derselben Form wie überall.
SELECT pg_temp.expect_reject(
    'Q5 — abgehakt von irgendwem',
    $q$UPDATE sync_tasks SET completed_at = now(), completed_by = 'irgendwer', outcome = 'done'
       WHERE task_text = 'Kind anlegen'$q$);

-- Nach dem Abhaken darf die nächste Aufgabe zu demselben Bezug entstehen.
SELECT pg_temp.expect_accept(
    'Q5 — neue Aufgabe, nachdem die vorige abgehakt wurde',
    $q$UPDATE sync_tasks SET completed_at = now(), completed_by = 'entra:1', outcome = 'done'
         WHERE task_text = 'Kind anlegen';
       INSERT INTO sync_tasks (sync_target_id, child_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
               '44444444-4444-4444-4444-444444444444', 'Adresse nachziehen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Spureintrag ohne Alt- und Neuwert',
    $q$INSERT INTO change_log (table_name, row_id, column_name, changed_by)
       VALUES ('children', '44444444-4444-4444-4444-444444444444', 'exit_date', 'entra:1')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Spureintrag ohne Urheber-Präfix',
    $q$INSERT INTO change_log (table_name, row_id, column_name, new_value, changed_by)
       VALUES ('children', '44444444-4444-4444-4444-444444444444', 'exit_date', '2027-07-31', 'sekretariat')$q$);

-- „Läuft eine Änderung maschinell, steht der Lauf als Urheber darin."
SELECT pg_temp.expect_accept(
    'hebel.md — Jahreslauf als Urheber',
    $q$INSERT INTO change_log (table_name, row_id, child_id, column_name, old_value, new_value,
                               changed_by)
       VALUES ('children', '44444444-4444-4444-4444-444444444444',
               '44444444-4444-4444-4444-444444444444', 'grade_level', '1', '2',
               'system:rollover')$q$);

-- 00: „je Mitarbeitendem seine Rollen, samt wer sie wann vergeben oder entzogen
-- hat (Änderungsspur)" — Vergeben und Entziehen sind Anlegen und Löschen einer
-- Zeile und tragen keinen Spaltennamen.
SELECT pg_temp.expect_accept(
    '00 — vergebene Rolle als angelegte Zeile',
    $q$INSERT INTO change_log (table_name, row_id, person_id, operation, new_value, changed_by)
       VALUES ('employee_roles', '55555555-5555-5555-5555-555555555551',
               '22222222-2222-2222-2222-222222222222', 'insert',
               'Sekretariat', 'entra:1')$q$);

SELECT pg_temp.expect_accept(
    '00 — entzogene Rolle als gelöschte Zeile',
    $q$INSERT INTO change_log (table_name, row_id, person_id, operation, old_value, changed_by)
       VALUES ('employee_roles', '55555555-5555-5555-5555-555555555551',
               '22222222-2222-2222-2222-222222222222', 'delete',
               'Sekretariat', 'entra:1')$q$);

SELECT pg_temp.expect_reject(
    '00 — gelöschte Zeile mit Spaltennamen',
    $q$INSERT INTO change_log (table_name, row_id, operation, column_name, old_value, changed_by)
       VALUES ('employee_roles', '55555555-5555-5555-5555-555555555551', 'delete',
               'role_id', 'Sekretariat', 'entra:1')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Spaltenänderung ohne Spaltennamen',
    $q$INSERT INTO change_log (table_name, row_id, old_value, new_value, changed_by)
       VALUES ('children', '44444444-4444-4444-4444-444444444444', '1', '2', 'entra:1')$q$);

SELECT pg_temp.expect_reject(
    '00 — angelegte Zeile mit Altwert',
    $q$INSERT INTO change_log (table_name, row_id, operation, old_value, new_value, changed_by)
       VALUES ('employee_roles', '55555555-5555-5555-5555-555555555551', 'insert',
               'Sekretariat', 'Lehrkraft', 'entra:1')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Spureintrag mit unbekannter Art der Änderung',
    $q$INSERT INTO change_log (table_name, row_id, operation, new_value, changed_by)
       VALUES ('employee_roles', '55555555-5555-5555-5555-555555555551', 'upsert',
               'Sekretariat', 'entra:1')$q$);

-- 02, „Löschen": „die Änderungsspur und die erledigten Nachzieh-Aufgaben gehen
-- mit den Daten, auf die sie sich beziehen." Tabellenname und Schlüssel sind
-- Text und tragen keinen Fremdschlüssel; der Anker daneben trägt ihn. Diese
-- Zeile steht im Lösch-Lauf unten wieder.
SELECT pg_temp.expect_accept(
    '02 — Spureintrag mit dem Kind als Löschanker',
    $q$INSERT INTO change_log (table_name, row_id, child_id, column_name,
                               old_value, new_value, changed_by)
       VALUES ('consents', '00000000-0000-0000-0000-000000000001',
               '44444444-4444-4444-4444-444444444444', 'delivery_address',
               'alt@example.org', 'neu@example.org', 'entra:sekretariat')$q$);

-- Zwei Anker löschten die Spur mit dem, der zuerst geht.
SELECT pg_temp.expect_reject(
    '02 — Spureintrag mit Kind und Familie zugleich',
    $q$INSERT INTO change_log (table_name, row_id, child_id, family_id, column_name,
                               old_value, new_value, changed_by)
       VALUES ('consents', '00000000-0000-0000-0000-000000000002',
               '44444444-4444-4444-4444-444444444444',
               '33333333-3333-3333-3333-333333333333', 'delivery_address',
               'alt@example.org', 'neu@example.org', 'entra:sekretariat')$q$);

-- Eine Änderung an einem Wert im System hat keinen Personenbezug und deshalb
-- keinen Anker.
SELECT pg_temp.expect_accept(
    '02 — Spureintrag ohne Anker, weil die geänderte Zeile keinen hat',
    $q$INSERT INTO change_log (table_name, row_id, column_name, old_value, new_value, changed_by)
       VALUES ('configured_values', '1', 'value', '3500', '4000', 'entra:gf')$q$);

-- 02: „Bei einer Rechteänderung zusätzlich, dass ein Nachweis vorlag und wer ihn
-- gesehen hat — der Nachweis selbst kommt nicht ins System."
SELECT pg_temp.expect_accept(
    '02 — Rechteänderung mit gesehenem Nachweis',
    $q$INSERT INTO change_log (table_name, row_id, family_id, column_name, old_value, new_value,
                               proof_seen_at, changed_by)
       VALUES ('family_guardians', '33333333-3333-3333-3333-333333333333',
               '33333333-3333-3333-3333-333333333333',
               'access_level_id', '1', '2', now(), 'entra:sekretariat')$q$);

-- hebel.md, „Geld im System": jeder Wert trägt einen Gültigkeitstag, und je
-- Wert und Tag steht genau ein Eintrag.
INSERT INTO configured_values (code, valid_from, value, created_by)
    VALUES ('cleaning_buyout_cents', DATE '2026-10-01', 3500, 'system:check');
SELECT pg_temp.expect_reject(
    'hebel.md — derselbe Wert zweimal zum selben Gültigkeitstag',
    $q$INSERT INTO configured_values (code, valid_from, value, created_by)
       VALUES ('cleaning_buyout_cents', DATE '2026-10-01', 4000, 'system:check')$q$);

-- „Ein neuer Preis wird im Januar mit Gültigkeit zum 1. August eingetragen und
-- greift dann von selbst" — der künftige steht neben dem geltenden.
SELECT pg_temp.expect_accept(
    'hebel.md — künftiger Wert neben dem geltenden',
    $q$INSERT INTO configured_values (code, valid_from, value, created_by)
       VALUES ('cleaning_buyout_cents', DATE '2027-08-01', 4000, 'system:check')$q$);

-- hebel.md zählt die Änderungsgebühr unter den Werten im System auf („Änderung
-- der Betreuungsmodule 20 € (09)"); am Vorgang steht nur, OB sie erlassen wurde
-- (`care_module_agreements.change_fee_waived`), nicht wie hoch sie ist.
SELECT pg_temp.expect_accept(
    'hebel.md — die Änderungsgebühr der Betreuungsmodule mit Gültigkeitstag',
    $q$INSERT INTO configured_values (code, valid_from, value, created_by)
       VALUES ('care_change_fee_cents', DATE '2026-08-01', 2000, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Wert ohne Gültigkeitstag',
    $q$INSERT INTO configured_values (code, value, created_by)
       VALUES ('cleaning_penalty_cents', 4500, 'system:check')$q$);

-- „ein bereits gültiger nicht mehr" (hebel.md): Diese Hälfte des Satzes steht
-- bewusst nicht im Schema — sie vergleicht `valid_from` mit dem heutigen Tag,
-- und `now()` ist in keinem CHECK zulässig. Die Gegenprobe hält die Auslassung
-- fest: das Ändern läuft hier durch und wird von der Anwendung abgewiesen.
SELECT pg_temp.expect_accept(
    'hebel.md — bereits gültiger Wert geändert (die Sperre trägt die Anwendung)',
    $q$UPDATE configured_values SET value = 9900
        WHERE code = 'cleaning_buyout_cents' AND valid_from = DATE '2026-10-01'$q$);

-- 01: der Monatslauf der Strafen ist eine Aufgabe je Zeitraum, nicht je Familie.
SELECT pg_temp.expect_accept(
    'Q5 — Aufgabe mit Zeitraum als Bezug',
    $q$INSERT INTO sync_tasks (sync_target_id, reference_period, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='optigem'),
               DATE '2026-11-01', 'Putzdienst-Strafen des Monats buchen', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — zweite offene Aufgabe zu demselben Ziel und Zeitraum',
    $q$INSERT INTO sync_tasks (sync_target_id, reference_period, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='optigem'),
               DATE '2026-11-01', 'noch einmal', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — derselbe Vertragstext zweimal zum selben Gültigkeitstag',
    $q$INSERT INTO contract_texts (code, valid_from, body, created_by)
       VALUES ('school_contract_gs', DATE '2026-08-01', 'zweite Fassung', 'system:check')$q$);

-- „Ein Tippfehler ließe die Bedingungen sonst still verschwinden": Die Sorte
-- kommt aus der Werteliste, nicht aus dem Freitext.
SELECT pg_temp.expect_reject(
    'hebel.md — Vertragstext mit einer Sorte, die es nicht gibt',
    $q$INSERT INTO contract_texts (code, valid_from, body, created_by)
       VALUES ('schulvertrag_gs', DATE '2026-08-01', 'Fassung mit Tippfehler', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    'hebel.md — spätere Fassung desselben Vertragstexts',
    $q$INSERT INTO contract_texts (code, valid_from, body, created_by)
       VALUES ('school_contract_gs', DATE '2027-08-01', 'neue Fassung', 'system:check')$q$);

-- Die eingefrorene Vorlagendatei: Datei, Prüfsumme und Einfrierzeitpunkt
-- stehen zu dritt oder gar nicht.
SELECT pg_temp.expect_reject(
    'TASK-222 — Vorlagendatei ohne Prüfsumme und Einfrierzeitpunkt',
    $q$INSERT INTO contract_texts (code, valid_from, body, template_docx, created_by)
       VALUES ('school_contract_gs', DATE '2029-08-01', 'Fassung',
               '\x504b0304'::bytea, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-222 — Prüfsumme, die keine ist',
    $q$INSERT INTO contract_texts (code, valid_from, body, template_docx,
                                  template_checksum, frozen_at, created_by)
       VALUES ('school_contract_gs', DATE '2029-08-01', 'Fassung',
               '\x504b0304'::bytea, 'abc', now(), 'system:check')$q$);

SELECT pg_temp.expect_accept(
    'TASK-222 — eingefrorene Fassung: Datei, Prüfsumme, Zeitpunkt',
    $q$INSERT INTO contract_texts (code, valid_from, body, template_docx,
                                  template_checksum, frozen_at, created_by)
       VALUES ('school_contract_gs', DATE '2029-08-01', 'aus der Datei gelesen',
               '\x504b0304'::bytea,
               'sha256:' || repeat('a', 64), now(), 'system:check')$q$);

-- Eine Sorte ohne Arbeitsfassung ist reiner Text und erzeugt keine Urkunde;
-- eine mitgeltende Anlage mit Vorlage behauptete ein Dokument am Kind.
SELECT pg_temp.expect_reject(
    'TASK-225 — mitgeltende Anlage mit Arbeitsfassung',
    $q$INSERT INTO contract_text_kinds (code, name, kind_class, working_library_id,
                                       working_item_id, created_by)
       VALUES ('care_rules', 'Betreuungsordnung', 'applies', 1, 'item-9',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-225 — Arbeitsfassung als halbe Graph-Kennung',
    $q$INSERT INTO contract_text_kinds (code, name, kind_class, working_library_id,
                                       created_by)
       VALUES ('photo_consent', 'Fotoeinverständnis', 'signed', 1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'TASK-225 — Klasse, die es nicht gibt',
    $q$INSERT INTO contract_text_kinds (code, name, kind_class, created_by)
       VALUES ('care_rules', 'Betreuungsordnung', 'mitgeltend', 'system:check')$q$);

-- „Es gilt die jeweils gültige Fassung" (09): die mitgeltende Anlage braucht
-- `valid_from` und sonst nichts — kein Dokument, keine Unterschrift.
SELECT pg_temp.expect_accept(
    'TASK-231 — mitgeltende Anlage als reiner Text mit Gültigkeitstag',
    $q$INSERT INTO contract_text_kinds (code, name, kind_class, created_by)
       VALUES ('care_rules', 'Betreuungsordnung', 'applies', 'system:check');
       INSERT INTO contract_texts (code, valid_from, body, created_by)
       VALUES ('care_rules', DATE '2026-08-01', 'Betreuungsordnung', 'system:check')$q$);

-- TASK-232: Für `contract_texts.template_docx` trägt die Spur die Prüfsumme
-- statt des Werts — die eine Ausnahme, und der Versuch, die Bytes abzulegen,
-- fällt auf.
SELECT pg_temp.expect_reject(
    'TASK-232 — Änderungsspur mit dem Dateiinhalt der Vorlage',
    $q$INSERT INTO change_log (table_name, row_id, column_name, old_value, new_value,
                              changed_by)
       VALUES ('contract_texts', '1', 'template_docx', '\x504b0304', '\x504b0305',
               'entra:gf')$q$);
SELECT pg_temp.expect_accept(
    'TASK-232 — Änderungsspur mit der Prüfsumme',
    $q$INSERT INTO change_log (table_name, row_id, column_name, old_value, new_value,
                              changed_by)
       VALUES ('contract_texts', '1', 'template_docx',
               'sha256:' || repeat('a', 64), 'sha256:' || repeat('b', 64),
               'entra:gf')$q$);

-- Eine Werteliste legt kein Elternteil an: Zweck, Bibliothek, Dokumentart,
-- Aufgabenart und Vertragsfassung entstehen im Haus, und `contract_texts`
-- pflegt ausdrücklich die Geschäftsführung (hebel.md). Fünf Proben, eine je
-- Tabelle — die vier Wertelisten des Lösch-Laufs sind schon eng.
SELECT pg_temp.expect_reject(
    'rules.md — Zustimmungszweck, angelegt von einem Elternteil',
    $q$INSERT INTO consent_purposes (code, name, created_by)
       VALUES ('eigenmaechtig', 'Selbst erfunden', 'guardian:1')$q$);
SELECT pg_temp.expect_reject(
    'rules.md — Bibliothek, angelegt von einem Elternteil',
    $q$INSERT INTO sharepoint_libraries (code, name, graph_drive_id, created_by)
       VALUES ('eigen', 'Eigene Ablage', 'b!drive-9', 'guardian:1')$q$);
SELECT pg_temp.expect_reject(
    'rules.md — Dokumentart, angelegt von einem Elternteil',
    $q$INSERT INTO document_types (code, name, created_by)
       VALUES ('eigen', 'Eigene Unterlage', 'guardian:1')$q$);
SELECT pg_temp.expect_reject(
    'rules.md — Aufgabenart, angelegt von einem Elternteil',
    $q$INSERT INTO sync_targets (code, name, role_id, created_by)
       VALUES ('eigen', 'Eigenes Ziel',
               (SELECT role_id FROM roles WHERE code='secretariat'), 'guardian:1')$q$);
SELECT pg_temp.expect_reject(
    'hebel.md — Vertragsfassung, angelegt von einem Elternteil',
    $q$INSERT INTO contract_texts (code, valid_from, body, created_by)
       VALUES ('school_contract_gs', DATE '2028-08-01', 'Eigene Fassung', 'guardian:1')$q$);

-- hebel.md, „Unzustellbare Mail": „Bleibt eine Mail unzustellbar, ist das im
-- System sichtbar" — der Rückläufer trägt seinen Grund.
INSERT INTO outbound_emails (recipient_email, person_id, purpose)
    VALUES ('mutter@example.org', '22222222-2222-2222-2222-222222222222', 'offer');
SELECT pg_temp.expect_reject(
    'hebel.md — Rückläufer ohne Grund',
    $q$UPDATE outbound_emails SET undeliverable_at = now()
        WHERE purpose = 'offer'$q$);

-- ---------------------------------------------------------------------------
-- Newsletter: das Thema ist ein Zustimmungszweck, kein eigener Bestand
-- ---------------------------------------------------------------------------
-- Der Anker ist die Person: Ein Ehemaliger hat weder Kind noch Familie, und
-- `persons` verlangt keine — die Einwilligung steht trotzdem.
INSERT INTO consent_purposes (code, name, is_newsletter_topic, created_by)
    VALUES ('newsletter_alumni', 'Newsletter Ehemalige', true, 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by)
    VALUES ('22222222-2222-2222-2222-222222222228', 'Ehe', 'Malig', 'system:check');
SELECT pg_temp.expect_accept(
    'TASK-208 — Newsletter-Einwilligung einer Person ohne Kind und ohne Familie',
    $q$INSERT INTO consents (person_id, consent_purpose_id, granted_at,
                             delivery_address, created_by)
       VALUES ('22222222-2222-2222-2222-222222222228',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='newsletter_alumni'),
               now(), 'ehemalig@example.org', 'guardian:x')$q$);

-- „Der Widerspruch löscht nicht, er setzt einen Zeitpunkt": nach ihm steht die
-- Zeile noch da, und der Versand überspringt sie.
SELECT pg_temp.expect_accept(
    'TASK-208 — Widerspruch gegen den Newsletter',
    $q$UPDATE consents SET revoked_at = now()
        WHERE person_id = '22222222-2222-2222-2222-222222222228'$q$);
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM consents
                    WHERE person_id = '22222222-2222-2222-2222-222222222228'
                      AND revoked_at IS NOT NULL) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Widerspruch hat die Zeile mitgenommen';
    END IF;
    RAISE NOTICE 'ok (erlaubt): der Widerspruch lässt die Zeile stehen';
END $$;

-- Die Newsletter-Mail trägt ihr Thema und damit ihren Abmeldelink.
SELECT pg_temp.expect_accept(
    'TASK-208 — Newsletter-Mail mit Thema',
    $q$INSERT INTO outbound_emails (recipient_email, person_id, purpose,
                                    consent_purpose_id, is_newsletter_topic)
       VALUES ('ehemalig@example.org', '22222222-2222-2222-2222-222222222228',
               'newsletter',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='newsletter_alumni'),
               true)$q$);

-- „Wer sich vom Elternabend abmelden könnte, bekäme die nächste Vertragsfrist
-- auch nicht mehr": Ein Vorgangszweck ist kein Newsletter-Thema und lässt sich
-- nicht an eine Mail hängen — der zusammengesetzte Fremdschlüssel weist ab.
SELECT pg_temp.expect_reject(
    'TASK-208 — Vorgangsmail mit einem Zweck, der kein Newsletter-Thema ist',
    $q$INSERT INTO outbound_emails (recipient_email, person_id, purpose,
                                    consent_purpose_id, is_newsletter_topic)
       VALUES ('mutter@example.org', '22222222-2222-2222-2222-222222222222',
               'contract_deadline',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'),
               true)$q$);

-- Und ein Thema ohne Häkchen wäre eine Mail mit Thema, die keines trägt.
SELECT pg_temp.expect_reject(
    'TASK-208 — Mail mit Thema, aber ohne Newsletter-Häkchen',
    $q$INSERT INTO outbound_emails (recipient_email, person_id, purpose,
                                    consent_purpose_id)
       VALUES ('ehemalig@example.org', '22222222-2222-2222-2222-222222222228',
               'newsletter',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='newsletter_alumni'))$q$);

-- Der Abmeldelink hängt an der Person: eine Newsletter-Mail an eine Adresse
-- ohne Person ließe sich nicht abbestellen.
SELECT pg_temp.expect_reject(
    'TASK-208 — Newsletter-Mail an eine Adresse ohne Person',
    $q$INSERT INTO outbound_emails (recipient_email, purpose,
                                    consent_purpose_id, is_newsletter_topic)
       VALUES ('unbekannt2@example.org', 'newsletter',
               (SELECT consent_purpose_id FROM consent_purposes WHERE code='newsletter_alumni'),
               true)$q$);

SELECT pg_temp.expect_accept(
    'hebel.md — unzustellbare Mail mit Grund',
    $q$UPDATE outbound_emails SET undeliverable_at = now(),
                                 undeliverable_reason = '550 mailbox unavailable'
        WHERE purpose = 'offer'$q$);

-- 05, 09, 10: „bevor dort irgendetwas entsteht, bestätigen sie ihre
-- Mailadresse" — eine Mail an eine noch unbekannte Familie hat keine Person.
SELECT pg_temp.expect_accept(
    'hebel.md — Mail an eine Adresse ohne Person dahinter',
    $q$INSERT INTO outbound_emails (recipient_email, purpose)
       VALUES ('nochnichtbekannt@example.org', 'login_code')$q$);

-- ---------------------------------------------------------------------------
-- 9. Lösch-Lauf
-- ---------------------------------------------------------------------------
-- Die Löschanker dieser Datei an einem Durchlauf gezeigt statt behauptet.

-- Das Mandat folgt seiner eigenen Frist (stammdaten-schema.sql) und geht dem
-- Kind voraus; seine Unterschrift geht mit ihm.
SELECT pg_temp.expect_accept(
    '08 — das Mandat geht, und seine Unterschrift mit ihm',
    $q$DELETE FROM sepa_mandates WHERE sepa_mandate_id = '66666666-6666-6666-6666-666666666666'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM signatures WHERE sepa_mandate_id IS NOT NULL) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Unterschrift überlebt ihr Mandat';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 08 — keine Unterschrift überlebt ihr Mandat';
END $$;

-- Q2: „geht mit dem Kind, aber bewusst OHNE Cascade" — Dokument und Aktenordner
-- liegen in SharePoint und müssen dem Kind vorausgehen.
SELECT pg_temp.expect_reject(
    'Q2 — Kind gelöscht, obwohl seine Akte in SharePoint steht',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- Q1: „geht mit dem Kind bzw. mit der Person" — ist die Akte geräumt, nimmt das
-- Kind seine Zustimmungen mit.
SELECT pg_temp.expect_accept(
    'Q1/Q2 — nach der Akte geht das Kind, und die Zustimmungen gehen mit',
    $q$DELETE FROM documents          WHERE child_id = '44444444-4444-4444-4444-444444444444';
       DELETE FROM child_file_folders WHERE child_id = '44444444-4444-4444-4444-444444444444';
       DELETE FROM children           WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM consents WHERE child_id IS NOT NULL) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Zustimmung überlebt ihr Kind';
    END IF;
    RAISE NOTICE 'ok (erlaubt): Q1 — keine Zustimmung überlebt ihr Kind';
END $$;

-- 08: „Ab 14 unterschreibt das Kind sein Fotoeinverständnis mit." Diese
-- Unterschrift hängt an keinem Vertragsvorgang und an keinem Mandat; über die
-- Zustimmung ist sie nicht erreichbar, weil die eine Zeile vorher mit dem Kind
-- kaskadiert. `child_id` ist ihr Anker.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM signatures) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Unterschrift überlebt ihr Kind';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 08 — keine Unterschrift überlebt ihr Kind';
END $$;

-- 02: „die Änderungsspur … geht mit den Daten, auf die sie sich bezieht."
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM change_log WHERE table_name = 'consents') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Änderungsspur überlebt ihr Kind';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM change_log WHERE table_name = 'configured_values') THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — die Spur ohne Personenbezug ging mit';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 02 — die Spur geht mit ihrem Kind, die ohne Bezug bleibt';
END $$;

-- Ohne den Anker an der Unterschrift scheiterte dieses DELETE an
-- `fk_signatures_person`: die Zeile des Kindes stand dann noch da.
SELECT pg_temp.expect_accept(
    '08 — nach dem Kind geht seine Person, keine Unterschrift sperrt sie',
    $q$DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222221'$q$);

-- „Löschanker: geht mit der Person, an die sie ging" — für die Mail wie für die
-- kindlose Zustimmung. Die Einwilligung des Ehemaligen geht denselben Weg: Sie
-- hängt an keiner Familie und an keinem Kind, allein an ihrer Person.
SELECT pg_temp.expect_accept(
    'Q1 — Zustimmung und versandte Mail gehen mit ihrer Person',
    $q$DELETE FROM persons WHERE person_id IN ('22222222-2222-2222-2222-222222222222',
                                               '22222222-2222-2222-2222-222222222228')$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM consents)
       OR EXISTS (SELECT 1 FROM outbound_emails WHERE recipient_email = 'mutter@example.org') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Zustimmung oder Mail überlebt ihre Person';
    END IF;
    RAISE NOTICE 'ok (erlaubt): Q1 — weder Zustimmung noch Mail überlebt ihre Person';
END $$;

-- Stufe 7: Was der Lauf selbst berechnen muss. Die Anschrift hat keinen eigenen
-- Anker und kommt mit keiner Cascade mit — `persons.address_id` und
-- `sepa_mandates.account_holder_address_id` zeigen vorwärts auf sie. Abschnitt
-- 10 unten kann das nicht finden: Er prüft, was den Lauf aufhält, und eine
-- Vorwärtsreferenz hält nichts auf. Deshalb steht hier zuerst, dass sie den
-- Lauf über alle sechs Stufen davor überlebt, und dann der Schritt, der sie
-- räumt.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM addresses) THEN
        RAISE EXCEPTION 'unerwartet: die Anschrift ist fort, ohne dass eine Stufe sie räumte';
    END IF;
    RAISE NOTICE 'ok: nach Stufe 6 steht die Anschrift noch — sie hat keinen Anker, der sie nimmt';
END $$;

SELECT pg_temp.expect_accept(
    '02 — Stufe 7 räumt die Anschrift, auf die niemand mehr zeigt',
    $q$DELETE FROM addresses a
        WHERE NOT EXISTS (SELECT 1 FROM persons p
                           WHERE p.address_id = a.address_id)
          AND NOT EXISTS (SELECT 1 FROM sepa_mandates m
                           WHERE m.account_holder_address_id = a.address_id)$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM addresses) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Anschrift überlebt den vollständigen Lösch-Lauf';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 02 — nach Stufe 7 steht keine Personenangabe mehr';
END $$;

-- Die Mail an eine noch unbekannte Familie (05, 09, 10) hängt an keiner Person
-- und geht mit keinem Cascade fort. Das ist die benannte Auslassung, nicht ein
-- Anker: welche Frist ab `sent_at` für sie gilt, steht als offene Frage im
-- Dateikopf von querschnitt-schema.sql.
SELECT pg_temp.expect_accept(
    'hebel.md — Mail an eine noch unbekannte Familie, ohne Person und ohne Löschanker',
    $q$INSERT INTO outbound_emails (recipient_email, purpose)
       VALUES ('unbekannt@example.org', 'Zusage')$q$);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM outbound_emails WHERE recipient_email = 'unbekannt@example.org') THEN
        RAISE EXCEPTION 'unerwartet: die Mail ohne Person ist fort, obwohl kein Anker sie nimmt';
    END IF;
    RAISE NOTICE 'ok (erlaubt): die Mail ohne Person steht nach dem Lösch-Lauf noch — sie hat keinen Anker';
END $$;

-- ---------------------------------------------------------------------------
-- 10. Die Reihenfolge des Lösch-Laufs bleibt vollständig
-- ---------------------------------------------------------------------------
-- Der Kopf von querschnitt-schema.sql schreibt die Abfolge über alle Domänen
-- auf, die der Lauf aus 17 braucht — sie gehört keiner Domäne und steht deshalb
-- dort. Sie folgt aus den Fremdschlüsseln, die mit NO ACTION festhalten: genau
-- die sind die Tabellen, die der Lauf von Hand vor ihrem Anker räumen muss.
-- Diese Gegenprobe hält die Aufzählung an die Fremdschlüssel gebunden. Kommt
-- eine Tabelle dazu, die eine Stufe festhält, bricht sie hier — und nicht beim
-- ersten Lauf in Produktion, wo sie eine halb gelöschte Person hinterließe.
-- Geprüft wird gegen jede Tabelle der sechs Stufen und nicht nur gegen Kind,
-- Familie und Person: `fk_contracts_document` und `fk_health_trait_values_document`
-- halten den Lauf an seinem ersten Schritt auf und fielen aus dem engeren
-- Fenster heraus. Beides steht deshalb hier — die Aufzählung mit ihrem Platz im
-- Lauf, und darüber zwei Fragen: Hält eine Tabelle den Lauf auf, die in keiner
-- Stufe steht? Und steht eine Tabelle hinter der, die sie festhält?
CREATE TEMP TABLE loeschlauf (platz smallint, tabelle text, im_lauf boolean) ON COMMIT DROP;
INSERT INTO loeschlauf (platz, tabelle, im_lauf) VALUES
    -- Stufe 1, in der Reihenfolge des Dateikopfs
    ( 2, 'sepa_mandates',      true),
    ( 3, 'contracts',          true), ( 4, 'applications',       true),
    ( 5, 'holiday_bookings',   true),
    -- Direkt hinter der Buchung, die ihn mit NO ACTION festhält: er trägt eine
    -- Mailadresse und gehört keinem Kind.
    ( 6, 'holiday_cost_coverage_codes', true),
    -- Die Akademie-Anmeldung steht neben der Ferienbuchung: dieselbe eigene
    -- Frist, und sie hält Kind **und** Person fest. Die des Erwachsenen-Zweigs
    -- gehört keinem Kind und geht trotzdem hier, sonst bliebe der Lauf in
    -- Stufe 6 an ihr stehen. Dahinter ihr eingelöster Code, wie im
    -- Ferienprogramm.
    ( 6, 'academy_registrations', true),
    -- Vier Wochen nach dem letzten Termin, und damit vor der Buchung; sie hält
    -- ihr Kind fest, damit ein Anhalten trägt.
    ( 5, 'holiday_care_notes', true),
    ( 7, 'academy_cost_coverage_codes', true),
    ( 7, 'meal_subscriptions', true),
    -- Betriebsdaten am Kind ohne Aufbewahrungspflicht, am letzten bestätigten
    -- Ende dieses Kindes wie das Essensabo daneben (03). Sie hängen an keinem
    -- Vertrag: Ein Kind ohne Betreuungsvertrag kann beide haben, sie stehen
    -- deshalb neben `meal_subscriptions` und nicht hinter `contracts`.
    ( 7, 'emergency_care_bookings', true),
    ( 7, 'care_bridge_day_responses', true),
    ( 8, 'health_trait_values', true), ( 8, 'consents',           true),
    ( 9, 'documents',          true),
    -- Drei Monate nach dem Austritt und damit lange vor dem Vertrag, der das
    -- Kind fünf Jahre hält; er hält es seinerseits fest, damit der Lauf ihn
    -- sieht und ein Anhalten trägt.
    ( 9, 'child_health_records', true),
    -- Zuletzt in dieser Stufe der Ordner selbst: Seit die Datei auf ihn zeigt
    -- (`fk_documents_folder`), fiele ein früher geräumter Ordner mitsamt dem,
    -- was die Zeilen daneben noch behaupten. Erst die Blätter, dann der Ordner.
    (10, 'child_file_folders', true),
    -- Stufe 2
    (11, 'children', true),
    -- Stufe 3. Der Einzel-Freikauf steht vor der Zuteilung, die ihn mit
    -- NO ACTION festhält.
    (12, 'parent_work_entries',   true), (13, 'cleaning_slot_buyouts', true),
    -- Direkt hinter den Stunden, die aus ihm kamen: Er gehört keiner Familie,
    -- trägt aber dieselbe Schuljahresfrist und nimmt seine Anmeldungen mit.
    (12, 'parent_work_sessions',  true),
    (14, 'cleaning_assignments',  true), (15, 'cleaning_buyouts',      true),
    (16, 'cleaning_family_quotas', true),
    -- Stufe 4
    (17, 'families', true),
    -- Stufe 5
    (18, 'employees', true),
    -- Stufe 6
    (19, 'persons', true),
    -- Stufe 7. Sie folgt als einzige nicht aus einem Fremdschlüssel; hier steht
    -- sie trotzdem, weil die Prüfung darunter damit jede neue Tabelle meldet,
    -- die eine Anschrift festhält — und jede, die hinter ihr stünde.
    (20, 'addresses', true),
    -- Nicht im Lauf, aber an diesem Platz per Cascade fort: sie stehen mit dem
    -- Platz der Tabelle, die sie mitnimmt, und zählen deshalb als Halter — als
    -- Ziel des Laufs nicht, denn der Lauf räumt sie nie selbst.
    ( 3, 'contract_responses', false), ( 3, 'signatures',      false),
    (17, 'family_guardians',   false), (17, 'family_contacts', false);

DO $$
DECLARE ungenannt text;
        verdreht  text;
BEGIN
    SELECT string_agg(c.conrelid::regclass::text || ' (' || c.conname || ')', ', ')
      INTO ungenannt
      FROM pg_constraint c
      JOIN loeschlauf ziel ON ziel.tabelle = c.confrelid::regclass::text AND ziel.im_lauf
     WHERE c.contype = 'f'
       AND c.confdeltype = 'a'
       AND NOT EXISTS (SELECT 1 FROM loeschlauf q WHERE q.tabelle = c.conrelid::regclass::text);
    IF ungenannt IS NOT NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — hält den Lösch-Lauf auf, steht aber in keiner Stufe: %', ungenannt;
    END IF;

    SELECT string_agg(c.conname || ' (' || c.conrelid::regclass::text || ' auf Platz '
                      || q.platz || ' hält ' || c.confrelid::regclass::text
                      || ' auf Platz ' || ziel.platz || ')', ', ')
      INTO verdreht
      FROM pg_constraint c
      JOIN loeschlauf ziel ON ziel.tabelle = c.confrelid::regclass::text AND ziel.im_lauf
      JOIN loeschlauf q    ON q.tabelle    = c.conrelid::regclass::text
     WHERE c.contype = 'f'
       AND c.confdeltype = 'a'
       AND q.platz >= ziel.platz;
    IF verdreht IS NOT NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Lauf räumt zu früh: %', verdreht;
    END IF;

    RAISE NOTICE 'ok: 17 — jede festhaltende Tabelle steht in der Reihenfolge, und keine hinter der, die sie festhält';
END $$;

-- ---------------------------------------------------------------------------
-- 11. Lösch-Lauf (17) — Empfängerliste und Anhalten
-- ---------------------------------------------------------------------------
INSERT INTO houses (code, name, created_by) VALUES ('school', 'Schule', 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222223', 'Sekre', 'Tariat', 'system:check'),
    ('22222222-2222-2222-2222-222222222224', 'Kind B', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222225', 'Kind C', 'Muster', 'system:check');
INSERT INTO employees (employee_id, person_id, house_id, created_by)
    VALUES ('77777777-7777-7777-7777-777777777777',
            '22222222-2222-2222-2222-222222222223',
            (SELECT house_id FROM houses WHERE code = 'school'), 'system:check');
-- Zwei weitere Kinder: eines mit laufendem, eines mit abgelaufenem Anhalten.
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by) VALUES
    ('44444444-4444-4444-4444-444444444445', '22222222-2222-2222-2222-222222222224',
     '33333333-3333-3333-3333-333333333333', DATE '2019-05-01', 'system:check'),
    ('44444444-4444-4444-4444-444444444446', '22222222-2222-2222-2222-222222222225',
     '33333333-3333-3333-3333-333333333333', DATE '2018-05-01', 'system:check');

INSERT INTO retention_subjects (code, name, created_by) VALUES
    ('child_health_record', 'Gesundheitsbestand am Kind', 'system:check'),
    ('application',         'Bewerbung ohne Aufnahme',    'system:check');
INSERT INTO retention_hold_reasons (code, name, created_by) VALUES
    ('legal_dispute', 'Drohender Rechtsstreit', 'system:check');

-- hebel.md: „je Bestand eine Liste, deren Eintrag eine einzelne Person oder eine
-- ganze Rollengruppe sein kann" — und nur eines von beidem.
SELECT pg_temp.expect_reject(
    '17 — Empfänger, der weder Person noch Rollengruppe noch die Stelle des Vorgangs ist',
    $q$INSERT INTO retention_notice_recipients (retention_subject_id, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='application'),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '17 — Empfänger, der Person und Rollengruppe zugleich ist',
    $q$INSERT INTO retention_notice_recipients (retention_subject_id, employee_id, role_id, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='application'),
               '77777777-7777-7777-7777-777777777777',
               (SELECT role_id FROM roles WHERE code='secretariat'), 'system:check')$q$);

-- „eine benannte Person ist schon eingegrenzt" — eine Schulart daran sagt nichts.
SELECT pg_temp.expect_reject(
    '17 — Schulart an einer benannten Person statt an einer Rollengruppe',
    $q$INSERT INTO retention_notice_recipients (retention_subject_id, employee_id,
                                                school_branch_id, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='application'),
               '77777777-7777-7777-7777-777777777777',
               (SELECT school_branch_id FROM school_branches WHERE code='GS'), 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '17 — Rollengruppe mit Schulart: „die Lehrkräfte" ohne Zusatz wären beide Zweige',
    $q$INSERT INTO retention_notice_recipients (retention_subject_id, role_id,
                                                school_branch_id, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               (SELECT role_id FROM roles WHERE code='secretariat'),
               (SELECT school_branch_id FROM school_branches WHERE code='GS'), 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '17 — zweiter Empfänger desselben Bestands, diesmal eine benannte Person',
    $q$INSERT INTO retention_notice_recipients (retention_subject_id, employee_id, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '77777777-7777-7777-7777-777777777777', 'system:check')$q$);

-- Ohne `NULLS NOT DISTINCT` ginge genau diese zweite Zeile durch: leere Schulart
-- ist derselbe Empfänger und nicht ein anderer.
SELECT pg_temp.expect_accept(
    '17 — Empfänger, der aus dem Vorgang folgt (Lehrkraft einer Fahrt, Leitung eines Angebots)',
    $q$INSERT INTO retention_notice_recipients (retention_subject_id, from_the_case, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='application'),
               true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '17 — derselbe Empfänger ein zweites Mal am selben Bestand',
    $q$INSERT INTO retention_notice_recipients (retention_subject_id, from_the_case, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='application'),
               true, 'system:check')$q$);

-- „Empfänger sind immer mindestens zwei … Ein Empfänger, der im Urlaub ist, ist
-- kein Empfänger." Die Zahl zählt über die Zeilen einer Gruppe und trägt deshalb
-- kein CHECK; sie steht als Abfrage hier — dieselbe, die der Betrieb laufen
-- lässt. `application` hat oben genau einen Empfänger bekommen und muss darin
-- auftauchen, `child_health_record` mit zweien nicht.
DO $$
DECLARE zu_wenige text;
BEGIN
    SELECT string_agg(s.code, ', ' ORDER BY s.code) INTO zu_wenige
      FROM retention_subjects s
      LEFT JOIN retention_notice_recipients r USING (retention_subject_id)
     WHERE s.is_active
     GROUP BY s.retention_subject_id, s.code
    HAVING count(r.retention_notice_recipient_id) < 2;

    IF zu_wenige IS DISTINCT FROM 'application' THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Ein-Empfänger-Fall wird nicht gemeldet: %',
            coalesce(zu_wenige, '(nichts)');
    END IF;
    RAISE NOTICE 'ok (gemeldet): 17 — Bestand mit nur einem Empfänger';
END $$;

-- „Ein Anhalten gilt bis zu einem Datum, nie unbefristet."
SELECT pg_temp.expect_reject(
    '17 — Anhalten ohne Enddatum',
    $q$INSERT INTO retention_holds (retention_subject_id, child_id, retention_hold_reason_id,
                                    original_delete_on, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               current_date - 1, 'entra:hortleitung')$q$);

-- „dem Grund aus einer Werteliste" — ein Freitext stünde daneben.
SELECT pg_temp.expect_reject(
    '17 — Anhalten ohne Grund aus der Werteliste',
    $q$INSERT INTO retention_holds (retention_subject_id, child_id,
                                    original_delete_on, held_until, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               current_date - 1, current_date + 30, 'entra:hortleitung')$q$);

SELECT pg_temp.expect_reject(
    '17 — Anhalten ohne Anker',
    $q$INSERT INTO retention_holds (retention_subject_id, retention_hold_reason_id,
                                    original_delete_on, held_until, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               current_date - 1, current_date + 30, 'entra:hortleitung')$q$);

SELECT pg_temp.expect_reject(
    '17 — Anhalten mit zwei Ankern',
    $q$INSERT INTO retention_holds (retention_subject_id, child_id, family_id,
                                    retention_hold_reason_id, original_delete_on, held_until, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               '33333333-3333-3333-3333-333333333333',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               current_date - 1, current_date + 30, 'entra:hortleitung')$q$);

SELECT pg_temp.expect_reject(
    '17 — Anhalten, das vor dem Löschtermin endet und damit nichts aufhält',
    $q$INSERT INTO retention_holds (retention_subject_id, child_id, retention_hold_reason_id,
                                    original_delete_on, held_until, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               current_date - 1, current_date - 2, 'entra:hortleitung')$q$);

SELECT pg_temp.expect_accept(
    '17 — das erste Anhalten, mit Grund, Enddatum und ursprünglichem Löschtermin',
    $q$INSERT INTO retention_holds (retention_hold_id, retention_subject_id, child_id,
                                    retention_hold_reason_id, original_delete_on, held_until, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               (SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               current_date - 10, current_date + 30, 'entra:hortleitung')$q$);

-- „Der ursprüngliche Löschtermin bleibt beim Verlängern stehen — sonst begänne
-- die Zählung mit jedem Anhalten von vorn." Der zusammengesetzte Fremdschlüssel
-- auf die erste Zeile hält ihn: Wer verlängert, kommt nur mit demselben Tag
-- herein.
SELECT pg_temp.expect_reject(
    '17 — Verlängerung, die den ursprünglichen Löschtermin neu setzt',
    $q$INSERT INTO retention_holds (retention_subject_id, child_id, retention_hold_reason_id,
                                    first_hold_id, original_delete_on, held_until, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               '88888888-8888-8888-8888-888888888881',
               current_date + 20, current_date + 60, 'entra:hortleitung')$q$);

SELECT pg_temp.expect_accept(
    '17 — Verlängerung mit demselben ursprünglichen Löschtermin',
    $q$INSERT INTO retention_holds (retention_hold_id, retention_subject_id, child_id,
                                    retention_hold_reason_id, first_hold_id,
                                    original_delete_on, held_until, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               (SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               '88888888-8888-8888-8888-888888888881',
               current_date - 10, current_date + 60, 'entra:hortleitung')$q$);

-- hebel.md: „Der ursprüngliche Löschtermin bleibt beim Verlängern stehen."
-- Ohne `ix_retention_holds_first` bliebe genau das freiwillig: Wer über die
-- Oberfläche „neu anhalten" statt „verlängern" wählt, legte eine zweite erste
-- Zeile mit neuem Termin an und setzte die Zählung zurück.
SELECT pg_temp.expect_reject(
    '17 — zweites „neu anhalten" am selben Fall statt einer Verlängerung',
    $q$INSERT INTO retention_holds (retention_subject_id, child_id, retention_hold_reason_id,
                                    original_delete_on, held_until, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               current_date + 5, current_date + 90, 'entra:hortleitung')$q$);

-- „Eine Zeile ist nicht ihre eigene erste; sonst ginge der Fremdschlüssel oben
-- für jede beliebige Verlängerung auf."
SELECT pg_temp.expect_reject(
    '17 — Anhalten, das sich selbst als erste Zeile einträgt',
    $q$INSERT INTO retention_holds (retention_hold_id, retention_subject_id, child_id,
                                    retention_hold_reason_id, first_hold_id,
                                    original_delete_on, held_until, created_by)
       VALUES ('88888888-8888-8888-8888-888888888883',
               (SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444445',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               '88888888-8888-8888-8888-888888888883',
               current_date - 10, current_date + 60, 'entra:hortleitung')$q$);

-- Das dritte Kind: ein Anhalten, das gestern abgelaufen ist.
SELECT pg_temp.expect_accept(
    '17 — abgelaufenes Anhalten am dritten Kind',
    $q$INSERT INTO retention_holds (retention_subject_id, child_id, retention_hold_reason_id,
                                    original_delete_on, held_until, created_by)
       VALUES ((SELECT retention_subject_id FROM retention_subjects WHERE code='child_health_record'),
               '44444444-4444-4444-4444-444444444446',
               (SELECT retention_hold_reason_id FROM retention_hold_reasons WHERE code='legal_dispute'),
               current_date - 40, current_date - 1, 'entra:hortleitung')$q$);

-- Die drei Zusagen aus 17 an einer Abfrage: Der Lauf nimmt heute, was fällig und
-- nicht angehalten ist; ein angehaltener Anker wird übersprungen; und ein
-- abgelaufenes Anhalten löscht nicht am nächsten Morgen, sondern beginnt die
-- Ankündigung von vorn — der Termin rechnet dann ab dem Ende des Anhaltens plus
-- den vierzehn Tagen der ersten Ankündigung.
DO $$
DECLARE heute text;
        termin_gehalten date;
        termin_abgelaufen date;
BEGIN
    CREATE TEMP TABLE kandidaten (child_id uuid, delete_on date) ON COMMIT DROP;
    INSERT INTO kandidaten VALUES
        ('44444444-4444-4444-4444-444444444444', current_date - 1),
        ('44444444-4444-4444-4444-444444444445', current_date - 10),
        ('44444444-4444-4444-4444-444444444446', current_date - 40);

    -- GREATEST übergeht ein NULL: ohne Anhalten bleibt der Termin der eigene.
    CREATE TEMP TABLE faellig ON COMMIT DROP AS
        SELECT k.child_id,
               GREATEST(k.delete_on, max(h.held_until) + 14) AS termin
          FROM kandidaten k
          LEFT JOIN retention_holds h ON h.child_id = k.child_id
         GROUP BY k.child_id, k.delete_on;

    SELECT string_agg(child_id::text, ', ' ORDER BY child_id::text) INTO heute
      FROM faellig WHERE termin <= current_date;
    IF heute IS DISTINCT FROM '44444444-4444-4444-4444-444444444444' THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Lauf nimmt heute die falschen Anker: %',
            coalesce(heute, '(keinen)');
    END IF;

    SELECT termin INTO termin_gehalten FROM faellig
     WHERE child_id = '44444444-4444-4444-4444-444444444445';
    IF termin_gehalten <> current_date + 74 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — das laufende Anhalten verschiebt nicht bis %, sondern auf %',
            current_date + 74, termin_gehalten;
    END IF;

    SELECT termin INTO termin_abgelaufen FROM faellig
     WHERE child_id = '44444444-4444-4444-4444-444444444446';
    IF termin_abgelaufen <> current_date + 13 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — nach dem Anhalten wird sofort gelöscht statt angekündigt: %',
            termin_abgelaufen;
    END IF;
    RAISE NOTICE 'ok: 17 — angehaltener Anker übersprungen, abgelaufener kündigt von vorn an';
END $$;

-- „Die Liste der angehaltenen Löschungen zeigt je Fall, seit wann er fällig ist
-- und wie oft er geschoben wurde" — frisch erzeugt, aus dem ursprünglichen
-- Termin und der Zahl der Zeilen je Anker.
DO $$
DECLARE faellig_seit date;
        alter_tage   integer;
        geschoben    integer;
BEGIN
    SELECT min(h.original_delete_on),
           current_date - min(h.original_delete_on),
           count(*) - 1
      INTO faellig_seit, alter_tage, geschoben
      FROM retention_holds h
     WHERE h.child_id = '44444444-4444-4444-4444-444444444445';

    IF faellig_seit <> current_date - 10 OR alter_tage <> 10 OR geschoben <> 1 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Liste zeigt % / % / % statt % / 10 / 1',
            faellig_seit, alter_tage, geschoben, current_date - 10;
    END IF;
    RAISE NOTICE 'ok: 17 — die Liste trägt Fälligkeit, Alter und Zahl der Verlängerungen';
END $$;

-- „Die Spur lebt genau so lange wie das, worüber sie Auskunft gibt" (17). Sie
-- trägt deshalb keine eigene Frist, sondern den Anker der geänderten Zeile —
-- auch wo er erst über einen Join zu finden ist. Ein CHECK kann das nicht
-- halten: Ob eine Tabelle bei Kind, Person oder Familie ankommt, steht in den
-- Fremdschlüsseln und nicht in der Zeile. Die Abfrage darunter rechnet es aus
-- und meldet jede Spurzeile, die ihren Anker schuldig bleibt — sie ist zugleich
-- die, die der Betrieb laufen lässt, und sie wächst von selbst mit: Eine neue
-- Tabelle mit Personenbezug fällt hier auf, ohne dass jemand eine Liste pflegt.
SELECT pg_temp.expect_accept(
    '17 — Spureintrag einer Tabelle ohne jeden Personenbezug bleibt ohne Anker',
    $q$INSERT INTO change_log (table_name, row_id, column_name, old_value, new_value, changed_by)
       VALUES ('holiday_module_prices', '1', 'amount_cents', '2200', '2400', 'entra:gf')$q$);

-- Die herausgenommene Sicherung: eine Zeile, die über zwei Tabellen hinweg bei
-- einem Kind ankommt, und trotzdem ohne Anker eingetragen.
SELECT pg_temp.expect_accept(
    '17 — Spureintrag zu einer Tabelle mit Personenbezug, aber ohne Anker (wird unten gemeldet)',
    $q$INSERT INTO change_log (table_name, row_id, column_name, old_value, new_value, changed_by)
       VALUES ('sepa_mandates', '66666666-6666-6666-6666-666666666666', 'iban',
               'DE02120300000000202051', 'DE02120300000000202052', 'entra:sekretariat')$q$);

DO $$
DECLARE ohne_anker text;
BEGIN
    CREATE TEMP TABLE mit_personenbezug ON COMMIT DROP AS
    WITH RECURSIVE erreicht (tabelle) AS (
        SELECT unnest(ARRAY['children', 'persons', 'families'])
        UNION
        SELECT c.conrelid::regclass::text
          FROM pg_constraint c
          JOIN erreicht e ON e.tabelle = c.confrelid::regclass::text
         WHERE c.contype = 'f'
    )
    SELECT tabelle FROM erreicht;

    SELECT string_agg(DISTINCT l.table_name, ', ') INTO ohne_anker
      FROM change_log l
      JOIN mit_personenbezug p ON p.tabelle = l.table_name
     WHERE l.person_id IS NULL AND l.child_id IS NULL AND l.family_id IS NULL;

    IF ohne_anker IS DISTINCT FROM 'sepa_mandates' THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die ankerlose Spur wird nicht gemeldet: %',
            coalesce(ohne_anker, '(nichts)');
    END IF;
    RAISE NOTICE 'ok (gemeldet): 17 — Spureintrag mit Personenbezug, dem der Anker fehlt';
END $$;

DO $$ BEGIN RAISE NOTICE 'querschnitt-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
