-- Prüfskript zu ferien-schema.sql.
--
-- Sollstand: 10 Tabellen — holiday_session_types, holiday_modules,
-- holiday_module_prices, holiday_programmes, holiday_sessions,
-- holiday_session_days, holiday_session_surcharges,
-- holiday_cost_coverage_codes, holiday_bookings und holiday_care_notes.
-- Dazu ein Lese-Index
-- auf die Teilnehmerliste, ein partieller Unique-Index über die nicht
-- stornierten Buchungen und die Fremdschlüssel von Q3 und Q5 auf diese Domäne.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f ferien-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY[
        'holiday_session_types', 'holiday_modules', 'holiday_module_prices',
        'holiday_programmes', 'holiday_sessions', 'holiday_session_days',
        'holiday_session_surcharges',
        'holiday_cost_coverage_codes', 'holiday_bookings', 'holiday_care_notes'
    ]) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 10 Tabellen vorhanden';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_holiday_bookings', 'pk_holiday_sessions', 'pk_holiday_modules',
        'fk_holiday_bookings_child', 'fk_holiday_bookings_session',
        'fk_holiday_bookings_module', 'fk_holiday_bookings_terms',
        'fk_holiday_bookings_coverage_code', 'fk_holiday_programmes_role',
        'uq_holiday_session_days',
        'uq_holiday_session_surcharges', 'uq_holiday_module_prices',
        'uq_holiday_modules_id_type', 'uq_holiday_sessions_id_type',
        'ck_holiday_bookings_payment_mode', 'ck_holiday_bookings_coverage',
        'ck_holiday_bookings_declared', 'ck_holiday_bookings_recorded',
        'ck_holiday_bookings_retained', 'ck_holiday_sessions_cancellation',
        'ck_holiday_sessions_places', 'ck_holiday_programmes_window',
        'fk_payments_holiday_booking',
        'ck_holiday_bookings_declared_by', 'ck_holiday_bookings_recorded_by',
        'uq_holiday_bookings_amount', 'fk_sync_tasks_holiday_booking',
        'uq_holiday_care_notes', 'fk_holiday_care_notes_child',
        'fk_holiday_care_notes_programme'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;
    -- 10: „Die Ausschreibung selbst samt ihren Bildern: Webseite der Schule."
    IF to_regclass('public.holiday_session_images') IS NOT NULL THEN
        RAISE EXCEPTION 'Es gibt wieder eine Bildtabelle, obwohl die Ausschreibung außerhalb steht';
    END IF;
    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_holiday_bookings_session', 'ix_holiday_bookings_active',
                      'ix_sync_tasks_open_booking']) AS i
    WHERE to_regclass('public.' || i) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Indizes: %', missing;
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
INSERT INTO roles (role_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'day_care_management', 'Hortleitung', 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by)
    VALUES ('22222222-2222-2222-2222-222222222221', 'Kind', 'Muster', 'system:check');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222221',
            '33333333-3333-3333-3333-333333333333', DATE '2018-05-01', 'system:check');
INSERT INTO contract_texts (contract_text_id, code, valid_from, body, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'holiday_terms', DATE '2026-01-01', 'Teilnahmebedingungen', 'system:check');
-- 10: die Stornobedingungen sind ein Wert im System wie die
-- Teilnahmebedingungen und stehen deshalb als Text mit Gültigkeitstag da, nicht
-- als Spalte an der Terminart.
INSERT INTO contract_texts (contract_text_id, code, valid_from, body, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (2, 'holiday_cancellation_day',     DATE '2026-01-01', 'bis 21 Tage vorher kostenlos', 'system:check'),
    (3, 'holiday_cancellation_cooking', DATE '2026-01-01', 'bis 9 Uhr kostenlos',          'system:check');

INSERT INTO holiday_session_types (holiday_session_type_id, code, name,
                                   allows_external_children, cancellation_terms_code, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    -- „Alle drei stehen fremden Kindern offen, das Häkchen dafür ist heute
    -- überall gesetzt" (10) — die Kochwerkstatt eingeschlossen. Das Häkchen
    -- unterscheidet heute deshalb nichts und markiert nur, wo eine geschlossene
    -- Terminart stünde; geprüft wird hier, dass es die Spalte gibt, nicht
    -- welchen Wert sie heute trägt.
    (1, 'holiday_day',  'Ferientag',     true, 'holiday_cancellation_day',     'system:check'),
    (2, 'cooking',      'Kochwerkstatt', true, 'holiday_cancellation_cooking', 'system:check');

INSERT INTO holiday_modules (holiday_module_id, holiday_session_type_id, code, name,
                             includes_lunch, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 'day_morning',   'Ferientag vormittags',   false, 'system:check'),
    (2, 1, 'day_full',      'Ferientag ganztags',     false, 'system:check'),
    (3, 2, 'cook_morning',  'Kochwerkstatt vormittags', true, 'system:check');

INSERT INTO holiday_programmes (holiday_programme_id, name, offering_role_id,
                                registration_opens_at, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'Sommerferien 2027', 1, TIMESTAMPTZ '2027-04-01 08:00+02', 'system:check');

INSERT INTO holiday_sessions (holiday_session_id, holiday_programme_id,
                              holiday_session_type_id, title, places, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551', 1, 1, 'Woche 1 — Wald', 20, 'system:check'),
           ('55555555-5555-5555-5555-555555555552', 1, 2, 'Brot backen',      8, 'system:check');

-- ---------------------------------------------------------------------------
-- Gegenproben
-- ---------------------------------------------------------------------------

-- rules.md 1: der zusammengesetzte Schlüssel bindet Modul und Termin an
-- dieselbe Terminart.
SELECT pg_temp.expect_reject(
    '10 — Modul einer fremden Terminart gebucht',
    $q$INSERT INTO holiday_bookings (child_id, holiday_session_id, holiday_module_id,
                                     holiday_session_type_id, amount_cents, payment_mode,
                                     terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '55555555-5555-5555-5555-555555555551', 3, 1, 2000, 'paid', 1, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '10 — Buchung mit Modul der eigenen Terminart',
    $q$INSERT INTO holiday_bookings (holiday_booking_id, child_id, holiday_session_id,
                                     holiday_module_id, holiday_session_type_id, amount_cents,
                                     payment_mode, terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661',
               '44444444-4444-4444-4444-444444444444',
               '55555555-5555-5555-5555-555555555551', 2, 1, 5000, 'paid', 1, 'system:check')$q$);

-- 10: „Gebucht wird je Kind und Termin."
SELECT pg_temp.expect_reject(
    '10 — dasselbe Kind zweimal an demselben Termin',
    $q$INSERT INTO holiday_bookings (child_id, holiday_session_id, holiday_module_id,
                                     holiday_session_type_id, amount_cents, payment_mode,
                                     terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '55555555-5555-5555-5555-555555555551', 1, 1, 3000, 'paid', 1, 'system:check')$q$);

-- „mehrere Kinder in einem Zug" und mehrere Termine je Kind bleiben erlaubt.
SELECT pg_temp.expect_accept(
    '10 — dasselbe Kind an einem zweiten Termin',
    $q$INSERT INTO holiday_bookings (child_id, holiday_session_id, holiday_module_id,
                                     holiday_session_type_id, amount_cents, payment_mode,
                                     terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '55555555-5555-5555-5555-555555555552', 3, 2, 2500, 'paid', 1, 'system:check')$q$);

-- 10: „Er tritt an die Stelle der Zahlung."
SELECT pg_temp.expect_reject(
    '10 — berechnete Buchung ohne Kostenübernahme-Code',
    $q$UPDATE holiday_bookings SET payment_mode = 'invoiced'
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

INSERT INTO holiday_cost_coverage_codes (holiday_cost_coverage_code_id, holiday_programme_id,
                                         email, code_hash, invoice_note, created_by)
    VALUES ('77777777-7777-7777-7777-777777777771', 1, 'familie@example.org', 'x',
            'Jugendamt Musterkreis', 'entra:sekretariat');

SELECT pg_temp.expect_reject(
    '10 — online bezahlte Buchung mit Kostenübernahme-Code',
    $q$UPDATE holiday_bookings
          SET holiday_cost_coverage_code_id = '77777777-7777-7777-7777-777777777771'
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_accept(
    '10 — berechnete Buchung mit Kostenübernahme-Code',
    $q$UPDATE holiday_bookings
          SET payment_mode = 'invoiced',
              holiday_cost_coverage_code_id = '77777777-7777-7777-7777-777777777771'
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

-- 10: „Der Code … verfällt nach 14 Tagen" — eine feste Zahl ist keine Spalte.
-- Der Ablauf folgt aus `created_at` (rules.md Abschnitt 1).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'holiday_cost_coverage_codes'
                  AND column_name = 'expires_at') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Ablauf steht neben seiner Ableitung';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 10 — der Ablauf des Codes hat keine eigene Spalte';
END $$;

-- Dasselbe für das Einlösen: dass ein Code eingelöst ist, sagt die Buchung, die
-- auf ihn zeigt, und wann, sagt deren `created_at` (rules.md Abschnitt 1).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'holiday_cost_coverage_codes'
                  AND column_name = 'redeemed_at') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — das Einlösen steht neben seiner Ableitung';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 10 — das Einlösen des Codes hat keine eigene Spalte';
END $$;

-- Dieselbe Tatsache aus ihrer einzigen Quelle: die Buchung zeigt auf den Code,
-- und wann sie entstand, sagt ihr `created_at`.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM holiday_bookings
                    WHERE holiday_cost_coverage_code_id
                          = '77777777-7777-7777-7777-777777777771') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der eingelöste Code ist über seine Buchung nicht lesbar';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 10 — „eingelöst" ist ein EXISTS auf die Buchung';
END $$;

-- 10: Die Stornobedingungen sind ein Wert im System und tragen deshalb einen
-- Gültigkeitstag: „ein noch nicht gültiger lässt sich bis dahin ändern oder
-- zurücknehmen … Beide sind sichtbar, damit eine Familie eine angekündigte
-- Erhöhung sieht, bevor sie sich entscheidet" (hebel.md). Als Spalte an der
-- Terminart ginge beides nicht.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'holiday_session_types'
                  AND column_name = 'cancellation_terms') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Stornobedingungen stehen wieder ohne Gültigkeitstag da';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 10 — die Stornobedingungen stehen als Text mit Gültigkeitstag';
END $$;

SELECT pg_temp.expect_accept(
    '10 — angekündigte Stornobedingungen neben den geltenden',
    $q$INSERT INTO contract_texts (contract_text_id, code, valid_from, body, created_by)
       OVERRIDING SYSTEM VALUE
       VALUES (4, 'holiday_cancellation_day', DATE '2027-08-01',
               'bis 21 Tage vorher kostenlos, danach 15 EUR je Tag', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '10 — dieselben Stornobedingungen zweimal zum selben Gültigkeitstag',
    $q$INSERT INTO contract_texts (contract_text_id, code, valid_from, body, created_by)
       OVERRIDING SYSTEM VALUE
       VALUES (5, 'holiday_cancellation_day', DATE '2027-08-01', 'anders', 'system:check')$q$);

-- 10: „Dazu je Kind eine Anmerkung für die Betreuung" — der Block zählt sie
-- neben dem auf, was je Buchung steht. An der Buchung stünde sie je Kind und
-- Termin und in einer Ferienwoche fünfmal (rules.md Abschnitt 1).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'holiday_bookings' AND column_name = 'care_note') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Anmerkung steht wieder je Buchung';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 10 — die Anmerkung steht nicht an der Buchung';
END $$;

SELECT pg_temp.expect_accept(
    '10 — eine Anmerkung je Kind und Programm',
    $q$INSERT INTO holiday_care_notes (child_id, holiday_programme_id, note, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 1,
               'Braucht mittags eine Pause', 'guardian:x')$q$);

SELECT pg_temp.expect_reject(
    '10 — zweite Anmerkung desselben Kindes zu demselben Programm',
    $q$INSERT INTO holiday_care_notes (child_id, holiday_programme_id, note, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 1, 'noch etwas', 'guardian:x')$q$);

-- 10: „Wirksam wird er erst, wenn die anbietende Stelle ihn einträgt: Sie …
-- trägt den einbehaltenen Betrag ein."
SELECT pg_temp.expect_accept(
    '10 — Storno erklärt, aber noch nicht eingetragen',
    $q$UPDATE holiday_bookings
          SET cancellation_declared_at = now(), cancellation_declared_by = 'guardian:x'
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

-- 10: „wer sie abgegeben hat" und „wer ihn eingetragen hat" — beide in
-- derselben Urheberform wie überall sonst.
SELECT pg_temp.expect_reject(
    '10 — Storno erklärt von einem Urheber ohne Kennung',
    $q$UPDATE holiday_bookings
          SET cancellation_declared_at = now(), cancellation_declared_by = 'die Eltern'
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_reject(
    '10 — Storno eingetragen von einem Urheber ohne Kennung',
    $q$UPDATE holiday_bookings
          SET cancellation_recorded_at = now(), cancellation_recorded_by = 'hort',
              retained_amount_cents = 0
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_reject(
    '10 — Storno eingetragen ohne einbehaltenen Betrag',
    $q$UPDATE holiday_bookings
          SET cancellation_recorded_at = now(), cancellation_recorded_by = 'entra:hort'
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_reject(
    '10 — einbehaltener Betrag über dem gezahlten',
    $q$UPDATE holiday_bookings
          SET cancellation_recorded_at = now(), cancellation_recorded_by = 'entra:hort',
              retained_amount_cents = 99999
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

-- „Für ihre eigene Absage gilt keine Frist und keine Gebühr: Bezahltes wird
-- voll erstattet" — der einbehaltene Betrag darf null sein.
SELECT pg_temp.expect_accept(
    '10 — Storno eingetragen mit einbehaltenem Betrag null',
    $q$UPDATE holiday_bookings
          SET cancellation_recorded_at = now(), cancellation_recorded_by = 'entra:hort',
              retained_amount_cents = 0
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

-- F5 — 10: „die Buchung selbst ändern Eltern nicht, sie stornieren und buchen
-- neu", und „die Buchung bleibt stehen und gilt als storniert, sie verschwindet
-- nicht". Beides zusammen geht nur, wenn die stornierte Zeile die Eindeutigkeit
-- nicht mehr belegt — sonst ist der einzige Weg zum Modulwechsel versperrt.
SELECT pg_temp.expect_accept(
    '10 — Neubuchung desselben Termins nach dem Storno',
    $q$INSERT INTO holiday_bookings (holiday_booking_id, child_id, holiday_session_id,
                                     holiday_module_id, holiday_session_type_id, amount_cents,
                                     payment_mode, terms_contract_text_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666662',
               '44444444-4444-4444-4444-444444444444',
               '55555555-5555-5555-5555-555555555551', 1, 1, 3000, 'paid', 1,
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '10 — dritte, nicht stornierte Buchung desselben Kindes an demselben Termin',
    $q$INSERT INTO holiday_bookings (child_id, holiday_session_id, holiday_module_id,
                                     holiday_session_type_id, amount_cents, payment_mode,
                                     terms_contract_text_id, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '55555555-5555-5555-5555-555555555551', 2, 1, 5000, 'paid', 1,
               'system:check')$q$);

-- 10: „der Termin trägt dann, dass er abgesagt ist, samt Grund in einem Satz".
SELECT pg_temp.expect_reject(
    '10 — abgesagter Termin ohne Grund',
    $q$UPDATE holiday_sessions SET cancelled_at = now()
        WHERE holiday_session_id = '55555555-5555-5555-5555-555555555552'$q$);

SELECT pg_temp.expect_accept(
    '10 — abgesagter Termin mit Grund, der stehen bleibt',
    $q$UPDATE holiday_sessions SET cancelled_at = now(), cancellation_reason = 'Küche defekt'
        WHERE holiday_session_id = '55555555-5555-5555-5555-555555555552'$q$);

-- 10: „Je Termin die Tage" — derselbe Tag steht nur einmal an einem Termin.
INSERT INTO holiday_session_days (holiday_session_id, day, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551', DATE '2027-08-02', 'system:check'),
           ('55555555-5555-5555-5555-555555555551', DATE '2027-08-03', 'system:check');
SELECT pg_temp.expect_reject(
    '10 — derselbe Tag zweimal an einem Termin',
    $q$INSERT INTO holiday_session_days (holiday_session_id, day, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', DATE '2027-08-02', 'system:check')$q$);

-- 10: „der Aufschlag je Modul dieses Termins einzeln, meist null".
INSERT INTO holiday_session_surcharges (holiday_session_id, holiday_module_id,
                                        surcharge_cents, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551', 1, 0, 'system:check');
SELECT pg_temp.expect_reject(
    '10 — zweiter Aufschlag für dasselbe Modul an demselben Termin',
    $q$INSERT INTO holiday_session_surcharges (holiday_session_id, holiday_module_id,
                                               surcharge_cents, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 1, 500, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '10 — negativer Aufschlag',
    $q$INSERT INTO holiday_session_surcharges (holiday_session_id, holiday_module_id,
                                               surcharge_cents, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 2, -500, 'system:check')$q$);

-- 10: das Anmeldefenster schließt nicht vor seinem Beginn.
SELECT pg_temp.expect_reject(
    '10 — Anmeldefenster, das vor seinem Beginn schließt',
    $q$INSERT INTO holiday_programmes (name, offering_role_id, registration_opens_at,
                                       registration_closes_at, created_by)
       VALUES ('Herbstferien', 1, TIMESTAMPTZ '2027-09-01 08:00+02',
               TIMESTAMPTZ '2027-08-01 08:00+02', 'system:check')$q$);

-- „steht es noch nicht, bleibt sie offen" — wie in 05.
SELECT pg_temp.expect_accept(
    '10 — Programm ohne Schließdatum',
    $q$INSERT INTO holiday_programmes (name, offering_role_id, registration_opens_at, created_by)
       VALUES ('Herbstferien', 1, TIMESTAMPTZ '2027-09-01 08:00+02', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '10 — Termin mit Platzzahl null',
    $q$INSERT INTO holiday_sessions (holiday_programme_id, holiday_session_type_id,
                                     title, places, created_by)
       VALUES (1, 1, 'Leer', 0, 'system:check')$q$);

-- 10: „Die Ferienwoche hat eigene Beträge" — je Modul und Gültigkeitstag einer.
INSERT INTO holiday_module_prices (holiday_module_id, valid_from, amount_cents, created_by)
    VALUES (1, DATE '2027-01-01', 2000, 'system:check');
SELECT pg_temp.expect_reject(
    '10 — derselbe Modulbetrag zweimal zum selben Gültigkeitstag',
    $q$INSERT INTO holiday_module_prices (holiday_module_id, valid_from, amount_cents, created_by)
       VALUES (1, DATE '2027-01-01', 2500, 'system:check')$q$);

-- F1 — 10: „Erstattungen sind kein Fremdsystem, aber Handarbeit, die auf einen
-- Menschen wartet: je Fall eine Aufgabe bei der Buchhaltung." „Je Fall" heißt
-- mehrere gleichzeitig zu demselben Kind — der Bezug ist deshalb die Buchung.
INSERT INTO sync_targets (sync_target_id, code, name, role_id, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'refund', 'Erstattung', 1, 'system:check');
INSERT INTO sync_tasks (sync_target_id, holiday_booking_id, task_text, created_by)
    VALUES (1, '66666666-6666-6666-6666-666666666661', 'Rückzahlung auslösen',
            'system:check');

SELECT pg_temp.expect_accept(
    '10 — zweite Erstattungsaufgabe zu einer anderen Buchung desselben Kindes',
    $q$INSERT INTO sync_tasks (sync_target_id, holiday_booking_id, task_text, created_by)
       VALUES (1, '66666666-6666-6666-6666-666666666662', 'Rückzahlung auslösen',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — zweite offene Aufgabe derselben Art zu derselben Buchung',
    $q$INSERT INTO sync_tasks (sync_target_id, holiday_booking_id, task_text, created_by)
       VALUES (1, '66666666-6666-6666-6666-666666666661', 'Rückzahlung auslösen',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5 — Aufgabe mit zwei Bezügen',
    $q$INSERT INTO sync_tasks (sync_target_id, holiday_booking_id, child_id,
                               task_text, created_by)
       VALUES (1, '66666666-6666-6666-6666-666666666662',
               '44444444-4444-4444-4444-444444444444', 'Rückzahlung auslösen',
               'system:check')$q$);


-- Q3: die Ferienbuchung ist einer der vier Anlässe.
SELECT pg_temp.expect_accept(
    'Q3 — Zahlung auf die Ferienbuchung',
    $q$INSERT INTO payments (holiday_booking_id, amount_cents, status, confirmed_at, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 5000, 'confirmed', now(),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q3 — Zahlung auf eine Ferienbuchung, die es nicht gibt',
    $q$INSERT INTO payments (holiday_booking_id, amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666669', 5000, 'system:check')$q$);

-- X2 — „der gezahlte Betrag als das, was an diesem Tag galt" (10) steht an der
-- Buchung, derselbe Betrag an der Zahlung (grenzkarte.md, Q3): zwei Orte, ein
-- Sachverhalt, aneinander gebunden (rules.md Abschnitt 1).
SELECT pg_temp.expect_reject(
    'X2 — Zahlung über einen anderen Betrag als die Buchung',
    $q$INSERT INTO payments (holiday_booking_id, amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 4000, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'X2 — der Betrag der Buchung wandert unter ihrer Zahlung weg',
    $q$UPDATE holiday_bookings SET amount_cents = 4000
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

-- 10: „Der Code gilt für diese eine Anmeldung." Eingelöst hängt er an seiner
-- Buchung und geht erst nach ihr — `fk_holiday_bookings_coverage_code` hält ihn
-- bis dahin fest, wie `documents` das Kind festhält. Das ist die Reihenfolge,
-- die die [A] an der Tabelle zusagt.
SELECT pg_temp.expect_reject(
    '10 — eingelöster Code gelöscht, während seine Buchung ihn noch hält',
    $q$DELETE FROM holiday_cost_coverage_codes
        WHERE holiday_cost_coverage_code_id = '77777777-7777-7777-7777-777777777771'$q$);

-- Q3: „geht mit dem Vorgang, an dem die Zahlung hängt" — die Buchung nimmt sie
-- mit, statt von ihr festgehalten zu werden.
SELECT pg_temp.expect_accept(
    'Q3 — die Zahlung geht mit ihrer Ferienbuchung',
    $q$DELETE FROM holiday_bookings
        WHERE holiday_booking_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_accept(
    '10 — nach der Buchung geht der eingelöste Code',
    $q$DELETE FROM holiday_cost_coverage_codes
        WHERE holiday_cost_coverage_code_id = '77777777-7777-7777-7777-777777777771'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM payments) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Zahlung überlebt ihren Vorgang';
    END IF;
    RAISE NOTICE 'ok (erlaubt): Q3 — keine Zahlung überlebt ihren Vorgang';
END $$;

DO $$ BEGIN RAISE NOTICE 'ferien-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
