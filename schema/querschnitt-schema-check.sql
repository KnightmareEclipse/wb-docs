-- Prüfskript zu querschnitt-schema.sql.
--
-- Sollstand: 14 Tabellen — vier Wertelisten (consent_purposes,
-- sharepoint_libraries, document_types, sync_targets), Q2 (contract_texts,
-- signatures, documents, child_file_folders), Q1 (consents), Q3 (payments),
-- Q5 (sync_tasks) und die drei übrigen Hebel (configured_values, change_log,
-- outbound_emails).
-- Die vertragsgebundenen Gegenproben zu `signatures` stehen in
-- anmeldung-schema-check.sql, weil ihr Fremdschlüssel dort entsteht; die
-- Unterschrift unter dem SEPA-Mandat steht hier, sie kennt keinen Vertrag.
-- Dazu dreizehn partielle Unique-Indizes (drei für signatures, zwei für
-- consents, acht für sync_tasks) und zwei Lese-Indizes, auf outbound_emails und
-- auf change_log. `payments` trägt außerdem ein UNIQUE auf der Zahlungsreferenz;
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
        'consent_purposes', 'sharepoint_libraries', 'document_types',
        'sync_targets', 'signatures', 'documents', 'child_file_folders',
        'consents', 'payments', 'sync_tasks', 'configured_values', 'change_log',
        'contract_texts', 'outbound_emails'
    ]) AS t
    WHERE to_regclass('public.' || t) IS NULL;

    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 14 Tabellen vorhanden';
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
        'fk_sync_tasks_payment',
        'uq_child_file_folders',
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
        'ck_consents_child',
        'fk_documents_library'
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
        'ix_sync_tasks_open_slot', 'ix_sync_tasks_open_payment', 'ix_change_log_row',
        'ix_signatures_contract', 'ix_signatures_agreement', 'ix_signatures_mandate',
        'ix_outbound_emails_undeliverable'
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
           ('observation_sheet', 'Beobachtungsbogen', 'system:check');
INSERT INTO consent_purposes (code, name, requires_child, self_consent_age, created_by)
    VALUES ('photo', 'Fotoeinverständnis', true, 14, 'system:check'),
           ('marketing_holiday', 'Werbe-Einwilligung Ferienbetreuung', false, NULL, 'system:check');
-- Ohne festen Schlüssel und ohne OVERRIDING SYSTEM VALUE, aus demselben Grund
-- wie `payees` in rechnungsfreigabe-schema-check.sql: mit festem Schlüssel
-- bliebe die Identity-Folge auf 1 stehen, und die Probe „derselbe Vertragstext
-- zweimal zum selben Gültigkeitstag" weiter unten legt ohne Schlüssel an — sie
-- scheiterte dann an `pk_contract_texts` statt an `uq_contract_texts`, den sie
-- zu prüfen behauptet.
INSERT INTO contract_texts (code, valid_from, body, created_by)
    VALUES ('school_contract_gs', DATE '2026-08-01', 'Vertragstext GS', 'system:check');
INSERT INTO sync_targets (code, name, role_id, created_by)
    VALUES ('asv_bw', 'ASV-BW', (SELECT role_id FROM roles WHERE code='secretariat'), 'system:check'),
           ('optigem', 'Optigem', (SELECT role_id FROM roles WHERE code='secretariat'), 'system:check');
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

-- grenzkarte.md, Q2: „der am Anmeldetag verlangte, aber nicht mitgebrachte
-- Beobachtungsbogen ist eine Anforderung ohne Ablageort".
SELECT pg_temp.expect_accept(
    'Q2 — Anforderung ohne Datei',
    $q$INSERT INTO documents (child_id, document_type_id, sharepoint_library_id,
                              requested_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='observation_sheet'),
               1, now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — Dokumentzeile ohne Anforderung und ohne Datei',
    $q$INSERT INTO documents (child_id, document_type_id, sharepoint_library_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='school_contract'),
               1, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q2 — Datei ohne Ablagezeitpunkt',
    $q$INSERT INTO documents (child_id, document_type_id, sharepoint_library_id,
                              graph_item_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='school_contract'),
               1, '01ABC', 'system:check')$q$);

INSERT INTO child_file_folders (child_id, sharepoint_library_id, graph_item_id, created_by)
    VALUES ('44444444-4444-4444-4444-444444444444', 1, '01FOLDER', 'system:check');
SELECT pg_temp.expect_reject(
    'Q2 — zweiter Aktenordner desselben Kindes',
    $q$INSERT INTO child_file_folders (child_id, sharepoint_library_id, graph_item_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 1, '01OTHER', 'system:check')$q$);

-- 06: „Unterlagen, je Stück vorgelegt, fehlt oder nicht nötig" — der dritte
-- Stand steht allein und ist von „fehlt" unterscheidbar.
SELECT pg_temp.expect_accept(
    '06 — Unterlage als nicht nötig festgestellt',
    $q$INSERT INTO documents (child_id, document_type_id, sharepoint_library_id,
                              not_required_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='school_contract'),
               1, now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '06 — Unterlage zugleich vorgelegt und nicht nötig',
    $q$INSERT INTO documents (child_id, document_type_id, sharepoint_library_id,
                              not_required_at, graph_item_id, filed_at, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               (SELECT document_type_id FROM document_types WHERE code='observation_sheet'),
               1, now(), '01ABC', now(), 'system:check')$q$);

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
         INSERT INTO signatures (child_id, person_id, signed_at, created_by)
         VALUES ('44444444-4444-4444-4444-444444444444',
                 '22222222-2222-2222-2222-222222222221', now(), 'system:check')
         RETURNING signature_id)
       INSERT INTO consents (person_id, child_id, consent_purpose_id, requires_child,
                             granted_at, delivery_address, signature_id, created_by)
       SELECT '22222222-2222-2222-2222-222222222221',
              '44444444-4444-4444-4444-444444444444',
              (SELECT consent_purpose_id FROM consent_purposes WHERE code='photo'), true,
              now(), 'kind@example.org', s.signature_id, 'system:check'
       FROM s$q$);

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

SELECT pg_temp.expect_reject(
    'Q5 — Aufgabe ohne Bezug',
    $q$INSERT INTO sync_tasks (sync_target_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='asv_bw'),
               'Kind anlegen', 'system:check')$q$);

-- Der achte Bezug, und der Grund für ihn steht an `ck_payments_single_cause`:
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
    $q$INSERT INTO change_log (table_name, row_id, column_name, old_value, new_value, changed_by)
       VALUES ('children', '44444444-4444-4444-4444-444444444444', 'grade_level', '1', '2',
               'system:rollover')$q$);

-- 00: „je Mitarbeitendem seine Rollen, samt wer sie wann vergeben oder entzogen
-- hat (Änderungsspur)" — Vergeben und Entziehen sind Anlegen und Löschen einer
-- Zeile und tragen keinen Spaltennamen.
SELECT pg_temp.expect_accept(
    '00 — vergebene Rolle als angelegte Zeile',
    $q$INSERT INTO change_log (table_name, row_id, operation, new_value, changed_by)
       VALUES ('employee_roles', '55555555-5555-5555-5555-555555555551', 'insert',
               'Sekretariat', 'entra:1')$q$);

SELECT pg_temp.expect_accept(
    '00 — entzogene Rolle als gelöschte Zeile',
    $q$INSERT INTO change_log (table_name, row_id, operation, old_value, changed_by)
       VALUES ('employee_roles', '55555555-5555-5555-5555-555555555551', 'delete',
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
    $q$INSERT INTO change_log (table_name, row_id, column_name, old_value, new_value,
                               proof_seen_at, changed_by)
       VALUES ('family_guardians', '33333333-3333-3333-3333-333333333333',
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

SELECT pg_temp.expect_accept(
    'hebel.md — spätere Fassung desselben Vertragstexts',
    $q$INSERT INTO contract_texts (code, valid_from, body, created_by)
       VALUES ('school_contract_gs', DATE '2027-08-01', 'neue Fassung', 'system:check')$q$);

-- hebel.md, „Unzustellbare Mail": „Bleibt eine Mail unzustellbar, ist das im
-- System sichtbar" — der Rückläufer trägt seinen Grund.
INSERT INTO outbound_emails (recipient_email, person_id, purpose)
    VALUES ('mutter@example.org', '22222222-2222-2222-2222-222222222222', 'offer');
SELECT pg_temp.expect_reject(
    'hebel.md — Rückläufer ohne Grund',
    $q$UPDATE outbound_emails SET undeliverable_at = now()
        WHERE purpose = 'offer'$q$);

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
-- kindlose Zustimmung.
SELECT pg_temp.expect_accept(
    'Q1 — Zustimmung und versandte Mail gehen mit ihrer Person',
    $q$DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222222'$q$);

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
-- Familie und Person: `fk_contracts_document` und `fk_health_traits_certificate`
-- halten den Lauf an seinem ersten Schritt auf und fielen aus dem engeren
-- Fenster heraus. Beides steht deshalb hier — die Aufzählung mit ihrem Platz im
-- Lauf, und darüber zwei Fragen: Hält eine Tabelle den Lauf auf, die in keiner
-- Stufe steht? Und steht eine Tabelle hinter der, die sie festhält?
CREATE TEMP TABLE loeschlauf (platz smallint, tabelle text, im_lauf boolean) ON COMMIT DROP;
INSERT INTO loeschlauf (platz, tabelle, im_lauf) VALUES
    -- Stufe 1, in der Reihenfolge des Dateikopfs
    ( 1, 'child_file_folders', true), ( 2, 'sepa_mandates',      true),
    ( 3, 'contracts',          true), ( 4, 'applications',       true),
    ( 5, 'holiday_bookings',   true),
    -- Direkt hinter der Buchung, die ihn mit NO ACTION festhält: er trägt eine
    -- Mailadresse und gehört keinem Kind.
    ( 6, 'holiday_cost_coverage_codes', true),
    ( 7, 'meal_subscriptions', true),
    ( 8, 'health_traits',      true), ( 9, 'documents',          true),
    -- Stufe 2
    (10, 'children', true),
    -- Stufe 3. Der Einzel-Freikauf steht vor der Zuteilung, die ihn mit
    -- NO ACTION festhält.
    (11, 'parent_work_entries',   true), (12, 'cleaning_slot_buyouts', true),
    (13, 'cleaning_assignments',  true), (14, 'cleaning_buyouts',      true),
    (15, 'cleaning_family_quotas', true),
    -- Stufe 4
    (16, 'families', true),
    -- Stufe 5
    (17, 'employees', true),
    -- Stufe 6
    (18, 'persons', true),
    -- Stufe 7. Sie folgt als einzige nicht aus einem Fremdschlüssel; hier steht
    -- sie trotzdem, weil die Prüfung darunter damit jede neue Tabelle meldet,
    -- die eine Anschrift festhält — und jede, die hinter ihr stünde.
    (19, 'addresses', true),
    -- Nicht im Lauf, aber an diesem Platz per Cascade fort: sie stehen mit dem
    -- Platz der Tabelle, die sie mitnimmt, und zählen deshalb als Halter — als
    -- Ziel des Laufs nicht, denn der Lauf räumt sie nie selbst.
    ( 3, 'contract_responses', false), ( 3, 'signatures',      false),
    (16, 'family_guardians',   false), (16, 'family_contacts', false);

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

DO $$ BEGIN RAISE NOTICE 'querschnitt-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
