-- Prüfskript zu putzdienst-schema.sql.
--
-- Sollstand: 10 Tabellen — cleaning_cycles, cleaning_slot_types,
-- cleaning_cycle_quotas, cleaning_slots, cleaning_family_quotas,
-- cleaning_buyouts, cleaning_assignments, cleaning_slot_buyouts,
-- cleaning_swap_offers und cleaning_swap_acceptances, davon eine Werteliste.
-- Dazu die beiden Q3-Fremdschlüssel auf `payments` und der Q5-Fremdschlüssel
-- `fk_sync_tasks_cleaning_slot`.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f putzdienst-schema-check.sql

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Existiert jede Tabelle?
-- ---------------------------------------------------------------------------
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY[
        'cleaning_cycles', 'cleaning_slot_types', 'cleaning_cycle_quotas',
        'cleaning_slots', 'cleaning_family_quotas', 'cleaning_buyouts',
        'cleaning_assignments', 'cleaning_slot_buyouts', 'cleaning_swap_offers',
        'cleaning_swap_acceptances'
    ]) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 10 Tabellen vorhanden';
END $$;

-- ---------------------------------------------------------------------------
-- 2. Constraints, samt der beiden Q3-Fremdschlüssel
-- ---------------------------------------------------------------------------
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_cleaning_cycles', 'pk_cleaning_slots', 'pk_cleaning_assignments',
        'uq_cleaning_cycles_year', 'uq_cleaning_assignments',
        'uq_cleaning_cycle_quotas', 'uq_cleaning_family_quotas',
        'uq_cleaning_slot_buyouts',
        'uq_cleaning_swap_acceptances', 'uq_cleaning_slots_id_type',
        'uq_cleaning_assignments_id_type', 'uq_cleaning_swap_offers_id_type',
        'fk_cleaning_assignments_slot', 'fk_cleaning_swap_offers_assignment',
        'fk_cleaning_swap_acceptances_offer', 'fk_cleaning_swap_acceptances_slot',
        'ck_cleaning_cycles_window', 'ck_cleaning_cycles_allocated',
        'ck_cleaning_cycles_release',
        'ck_cleaning_slots_cancelled', 'ck_cleaning_slots_sheet',
        'ck_cleaning_slots_sheet_recorded', 'fk_cleaning_slots_sheet_library',
        'ck_cleaning_assignments_source',
        'ck_cleaning_assignments_waiver', 'ck_cleaning_assignments_handover',
        'ck_cleaning_cycle_quotas_required', 'ck_cleaning_buyouts_count',

        'fk_payments_cleaning_buyout', 'fk_payments_cleaning_slot_buyout',
        'fk_sync_tasks_cleaning_slot'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;

    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_cleaning_swap_offers_open']) AS i
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
INSERT INTO families (family_id, created_by) VALUES
    ('33333333-3333-3333-3333-333333333331', 'system:check'),
    ('33333333-3333-3333-3333-333333333332', 'system:check');

INSERT INTO sharepoint_libraries (sharepoint_library_id, code, name, graph_drive_id,
                                  created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 'generated', 'Erzeugt', 'b!putz', 'system:check');

INSERT INTO cleaning_slot_types (cleaning_slot_type_id, code, name, created_by)
    OVERRIDING SYSTEM VALUE VALUES
    (1, 'regular', 'Regulärer Putzdienst', 'system:check'),
    (2, 'deep',    'Großputz',             'system:check');

INSERT INTO cleaning_cycles (cleaning_cycle_id, start_year, registration_opens_at,
                             registration_closes_at, created_by)
    OVERRIDING SYSTEM VALUE
    VALUES (1, 2026, TIMESTAMPTZ '2026-09-01 08:00+02', TIMESTAMPTZ '2026-09-20 23:59+02',
            'system:check');

INSERT INTO cleaning_cycle_quotas (cleaning_cycle_id, cleaning_slot_type_id,
                                   required_count, default_capacity, created_by)
    VALUES (1, 1, 5, 8, 'system:check'), (1, 2, 1, 20, 'system:check');

INSERT INTO cleaning_slots (cleaning_slot_id, cleaning_cycle_id, cleaning_slot_type_id,
                            starts_at, created_by) VALUES
    ('88888888-8888-8888-8888-888888888881', 1, 1, TIMESTAMPTZ '2026-10-10 09:00+02', 'system:check'),
    ('88888888-8888-8888-8888-888888888882', 1, 1, TIMESTAMPTZ '2026-11-14 09:00+01', 'system:check'),
    ('88888888-8888-8888-8888-888888888883', 1, 2, TIMESTAMPTZ '2027-07-24 09:00+02', 'system:check');

INSERT INTO cleaning_assignments (cleaning_assignment_id, cleaning_slot_id,
                                  cleaning_slot_type_id, family_id, source, created_by)
    VALUES ('99999999-9999-9999-9999-999999999991',
            '88888888-8888-8888-8888-888888888881', 1,
            '33333333-3333-3333-3333-333333333331', 'reserved', 'system:check'),
           ('99999999-9999-9999-9999-999999999992',
            '88888888-8888-8888-8888-888888888882', 1,
            '33333333-3333-3333-3333-333333333332', 'allocated', 'system:check');

-- ---------------------------------------------------------------------------
-- 5. Gegenproben
-- ---------------------------------------------------------------------------

-- 01: „keine Familie zweimal am selben Termin".
SELECT pg_temp.expect_reject(
    '01 — dieselbe Familie zweimal am selben Termin',
    $q$INSERT INTO cleaning_assignments (cleaning_slot_id, cleaning_slot_type_id,
                                        family_id, source, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881', 1,
               '33333333-3333-3333-3333-333333333331', 'allocated', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '01 — unbekannte Herkunft einer Zuteilung',
    $q$INSERT INTO cleaning_assignments (cleaning_slot_id, cleaning_slot_type_id,
                                        family_id, source, created_by)
       VALUES ('88888888-8888-8888-8888-888888888883', 2,
               '33333333-3333-3333-3333-333333333331', 'imported', 'system:check')$q$);

-- grenzkarte.md, „Drei Zustände": eine Strafe wird nur erlassen, wo sie besteht.
SELECT pg_temp.expect_reject(
    '01 — Straferlass ohne Nichterscheinen',
    $q$UPDATE cleaning_assignments
          SET penalty_waived_at = now(), penalty_waived_by = 'entra:1'
        WHERE cleaning_assignment_id = '99999999-9999-9999-9999-999999999991'$q$);

SELECT pg_temp.expect_reject(
    '01 — Straferlass ohne Namen dahinter',
    $q$UPDATE cleaning_assignments SET no_show = true, penalty_waived_at = now()
        WHERE cleaning_assignment_id = '99999999-9999-9999-9999-999999999991'$q$);

SELECT pg_temp.expect_reject(
    '01 — Strafübergabe ohne Nichterscheinen',
    $q$UPDATE cleaning_assignments SET penalty_handed_over_at = now()
        WHERE cleaning_assignment_id = '99999999-9999-9999-9999-999999999992'$q$);

-- „Schulleitung und Geschäftsführung … den Rückzug tragen sie selbst ein."
SELECT pg_temp.expect_accept(
    '01 — Nichterscheinen, Strafe, Rückzug durch eine benannte Stelle',
    $q$UPDATE cleaning_assignments
          SET no_show = true, penalty_waived_at = now(), penalty_waived_by = 'entra:leitung'
        WHERE cleaning_assignment_id = '99999999-9999-9999-9999-999999999991'$q$);

-- 01: „Zurücktreten kann man von einem Freikauf nicht" — und zweimal freikaufen
-- lässt sich derselbe Termin auch nicht.
INSERT INTO cleaning_slot_buyouts (cleaning_slot_buyout_id, cleaning_assignment_id, created_by)
    VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
            '99999999-9999-9999-9999-999999999992', 'system:check');
SELECT pg_temp.expect_reject(
    '01 — derselbe Termin zweimal freigekauft',
    $q$INSERT INTO cleaning_slot_buyouts (cleaning_assignment_id, created_by)
       VALUES ('99999999-9999-9999-9999-999999999992', 'system:check')$q$);

-- Q3 zeigt auf beide Freikäufe; der Anlass muss existieren.
SELECT pg_temp.expect_reject(
    'Q3 — Zahlung auf einen Einzel-Freikauf, den es nicht gibt',
    $q$INSERT INTO payments (cleaning_slot_buyout_id, amount_cents, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9', 3500, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    'Q3 — Zahlung auf den Einzel-Freikauf',
    $q$INSERT INTO payments (cleaning_slot_buyout_id, amount_cents, status, confirmed_at, created_by)
       VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 3500, 'confirmed', now(), 'system:check')$q$);

-- 01: „Das Sekretariat darf jeden Termin einer Familie streichen oder
-- verschieben" — nicht aber einen freigekauften: „Zurücktreten kann man von
-- einem Freikauf nicht", und mit Cascade nähme das Streichen den Freikauf und
-- über `fk_payments_cleaning_slot_buyout` die bestätigte Zahlung mit.
SELECT pg_temp.expect_reject(
    '01 — freigekaufter Termin gestrichen',
    $q$DELETE FROM cleaning_assignments
        WHERE cleaning_assignment_id = '99999999-9999-9999-9999-999999999992'$q$);

-- Jeder andere Termin bleibt streichbar; die Regel hängt am Freikauf und nicht
-- an der Zuteilung.
SELECT pg_temp.expect_accept(
    '01 — ein Termin ohne Freikauf lässt sich streichen',
    $q$INSERT INTO cleaning_assignments (cleaning_assignment_id, cleaning_slot_id,
                                        cleaning_slot_type_id, family_id, source, created_by)
       VALUES ('99999999-9999-9999-9999-999999999993',
               '88888888-8888-8888-8888-888888888883', 2,
               '33333333-3333-3333-3333-333333333331', 'manual', 'system:check');
       DELETE FROM cleaning_assignments
        WHERE cleaning_assignment_id = '99999999-9999-9999-9999-999999999993'$q$);

-- 01: „auch gleich alle auf einmal, ohne einen einzigen zu buchen".
INSERT INTO cleaning_buyouts (cleaning_buyout_id, cleaning_cycle_id, family_id,
                              cleaning_slot_type_id, bought_count, created_by)
    VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 1,
            '33333333-3333-3333-3333-333333333331', 1, 5, 'system:check');
SELECT pg_temp.expect_accept(
    'Q3 — Zahlung auf den Komplett-Freikauf',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, status, confirmed_at, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 17500, 'confirmed', now(), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '01 — Komplett-Freikauf über null Termine',
    $q$INSERT INTO cleaning_buyouts (cleaning_cycle_id, family_id, cleaning_slot_type_id,
                                     bought_count, created_by)
       VALUES (1, '33333333-3333-3333-3333-333333333332', 2, 0, 'system:check')$q$);

-- Die Q3-Gegenproben, die einen echten Anlass brauchen: der Putzdienst ist die
-- erste Domäne, die einen mitbringt (grenzkarte.md, Q3).
SELECT pg_temp.expect_reject(
    'Q3 — Zahlung mit zwei Anlässen',
    $q$INSERT INTO payments (cleaning_buyout_id, cleaning_slot_buyout_id, amount_cents, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
               'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 3500, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q3 — bestätigte Zahlung ohne Bestätigungszeitpunkt',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, status, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, 'confirmed', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q3 — offene Zahlung mit Bestätigungszeitpunkt',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, confirmed_at, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, now(), 'system:check')$q$);

-- Ohne `confirmed_at`: mit ihm wiese `ck_payments_confirmed` die Zeile ab, und
-- die Werteliste offen/bestätigt (grenzkarte.md, Q3) bliebe über alle 14
-- Skripte hinweg unbelegt — dies ist die einzige Probe auf sie.
SELECT pg_temp.expect_reject(
    'Q3 — unbekannter Zahlungsstatus',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, status, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, 'refunded',
               'system:check')$q$);

-- grenzkarte.md, Q3: „Die Aussetzung ist deshalb keine Zahlung mit Betrag 0."
SELECT pg_temp.expect_reject(
    'Q3 — Zahlung über 0 €',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 0, 'system:check')$q$);

-- 01: „neben Stripe bleibt die manuelle Bestätigung durch die Buchhaltung als
-- benannter Ausweg für Überweisung und Bargeld bestehen."
SELECT pg_temp.expect_accept(
    'Q3 — von Hand bestätigte Zahlung ohne Stripe-Referenz',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, status, confirmed_at, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, 'confirmed', now(),
               'system:check')$q$);

-- api/gemeinsam.md, „Sofortzahlung": Der Zahlungsdienst wiederholt ein Ereignis,
-- bis er eine 2xx bekommt — die zweite Zustellung darf keine zweite Zahlung
-- anlegen. Zwei Zeilen mit derselben Referenz sind genau dieser Fall.
SELECT pg_temp.expect_reject(
    'Q3 — dieselbe Zahlungsreferenz zweimal',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, payment_reference, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, 'cs_test_gleich', 'system:check'),
              ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, 'cs_test_gleich', 'system:check')$q$);

-- Die Gegenrichtung, und ohne sie wäre der Schlüssel oben zu scharf gebaut: Bei
-- der manuellen Bestätigung bleibt die Referenz leer, und beliebig viele solche
-- Zahlungen müssen nebeneinander stehen dürfen.
SELECT pg_temp.expect_accept(
    'Q3 — zwei Zahlungen ohne Referenz nebeneinander',
    $q$INSERT INTO payments (cleaning_buyout_id, amount_cents, created_by)
       VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, 'system:check'),
              ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 3500, 'system:check')$q$);

-- 01: „je Termin aber nur ein Angebot".
INSERT INTO cleaning_swap_offers (cleaning_swap_offer_id, cleaning_assignment_id,
                                  cleaning_slot_type_id, created_by)
    VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc1',
            '99999999-9999-9999-9999-999999999991', 1, 'system:check');
SELECT pg_temp.expect_reject(
    '01 — zweites Tauschangebot zu demselben Termin',
    $q$INSERT INTO cleaning_swap_offers (cleaning_assignment_id, cleaning_slot_type_id,
                                        created_by)
       VALUES ('99999999-9999-9999-9999-999999999991', 1, 'system:check')$q$);

-- 01: „je Termin aber nur ein Angebot" ist eine Aussage über die offenen. Ein
-- vollzogenes bleibt stehen („danach ist das Angebot verbraucht") und darf den
-- Termin nicht für den Rest des Putzdienstjahres sperren — kein Block sagt, dass
-- eine Familie einen Termin nur einmal je Jahr tauschen darf.
UPDATE cleaning_swap_offers SET matched_at = now()
 WHERE cleaning_swap_offer_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc1';
SELECT pg_temp.expect_accept(
    '01 — zweites Angebot zu demselben Termin, nachdem das erste vollzogen ist',
    $q$INSERT INTO cleaning_swap_offers (cleaning_swap_offer_id, cleaning_assignment_id,
                                        cleaning_slot_type_id, created_by)
       VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc2',
               '99999999-9999-9999-9999-999999999991', 1, 'system:check')$q$);
SELECT pg_temp.expect_reject(
    '01 — drittes Angebot, solange das zweite offen steht',
    $q$INSERT INTO cleaning_swap_offers (cleaning_assignment_id, cleaning_slot_type_id,
                                        created_by)
       VALUES ('99999999-9999-9999-9999-999999999991', 1, 'system:check')$q$);
DELETE FROM cleaning_swap_offers
 WHERE cleaning_swap_offer_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc2';
UPDATE cleaning_swap_offers SET matched_at = NULL
 WHERE cleaning_swap_offer_id = 'cccccccc-cccc-cccc-cccc-ccccccccccc1';

-- Die mitgeführte Art gehört dem eigenen Termin: eine geliehene gibt es nicht
-- (rules.md Abschnitt 1).
SELECT pg_temp.expect_reject(
    '01 — Angebot, das seinen regulären Termin als Großputz ausgibt',
    $q$INSERT INTO cleaning_swap_offers (cleaning_assignment_id, cleaning_slot_type_id,
                                        created_by)
       VALUES ('99999999-9999-9999-9999-999999999992', 2, 'system:check')$q$);

INSERT INTO cleaning_swap_acceptances (cleaning_swap_offer_id, cleaning_slot_id,
                                       cleaning_slot_type_id, created_by)
    VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc1',
            '88888888-8888-8888-8888-888888888882', 1, 'system:check');
SELECT pg_temp.expect_reject(
    '01 — derselbe fremde Termin zweimal angekreuzt',
    $q$INSERT INTO cleaning_swap_acceptances (cleaning_swap_offer_id, cleaning_slot_id,
                                             cleaning_slot_type_id, created_by)
       VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc1',
               '88888888-8888-8888-8888-888888888882', 1, 'system:check')$q$);

-- P1 — 01: „Getauscht wird eins zu eins, nur gegen einen bestehenden Termin
-- derselben Art." Das Angebot steht über einem regulären Termin; der Großputz
-- lässt sich daran nicht ankreuzen — weder mit der eigenen Art noch mit der
-- des Angebots.
SELECT pg_temp.expect_reject(
    '01 — Großputz an einem Angebot über einen regulären Termin',
    $q$INSERT INTO cleaning_swap_acceptances (cleaning_swap_offer_id, cleaning_slot_id,
                                             cleaning_slot_type_id, created_by)
       VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc1',
               '88888888-8888-8888-8888-888888888883', 2, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '01 — Großputz, als reguläre Art ausgegeben',
    $q$INSERT INTO cleaning_swap_acceptances (cleaning_swap_offer_id, cleaning_slot_id,
                                             cleaning_slot_type_id, created_by)
       VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc1',
               '88888888-8888-8888-8888-888888888883', 1, 'system:check')$q$);

-- „hakt in der Liste der angebotenen Termine derselben Art alle an, die sie
-- dafür nehmen würde" — mehrere Zieltermine bleiben erlaubt, solange die Art
-- stimmt.
INSERT INTO cleaning_slots (cleaning_slot_id, cleaning_cycle_id, cleaning_slot_type_id,
                            starts_at, created_by)
    VALUES ('88888888-8888-8888-8888-888888888884', 1, 1,
            TIMESTAMPTZ '2027-01-16 09:00+01', 'system:check');
SELECT pg_temp.expect_accept(
    '01 — mehrere angekreuzte Zieltermine derselben Art an einem Angebot',
    $q$INSERT INTO cleaning_swap_acceptances (cleaning_swap_offer_id, cleaning_slot_id,
                                             cleaning_slot_type_id, created_by)
       VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc1',
               '88888888-8888-8888-8888-888888888884', 1, 'system:check')$q$);

-- 01, Schritt 8: „eine Familie kann keinen Termin annehmen, an dem sie schon
-- steht". Die Regel steht bewusst nicht als Constraint an der Annahme — sie ist
-- eine Abwesenheit, siehe Kommentar an `cleaning_swap_acceptances`. Diese
-- beiden Proben halten fest, wo sie stattdessen greift: Das Kreuz geht durch,
-- der vollzogene Tausch nicht. Wird die Auslassung je zurückgenommen, kippt die
-- erste Probe und meldet es.
INSERT INTO cleaning_slots (cleaning_slot_id, cleaning_cycle_id, cleaning_slot_type_id,
                            starts_at, created_by)
    VALUES ('88888888-8888-8888-8888-888888888885', 1, 1,
            TIMESTAMPTZ '2027-02-20 09:00+01', 'system:check');
INSERT INTO cleaning_assignments (cleaning_slot_id, cleaning_slot_type_id,
                                  family_id, source, created_by)
    VALUES ('88888888-8888-8888-8888-888888888885', 1,
            '33333333-3333-3333-3333-333333333331', 'allocated', 'system:check');
SELECT pg_temp.expect_accept(
    '01 — Kreuz an einem Termin, an dem die Familie schon steht (Anwendung)',
    $q$INSERT INTO cleaning_swap_acceptances (cleaning_swap_offer_id, cleaning_slot_id,
                                             cleaning_slot_type_id, created_by)
       VALUES ('cccccccc-cccc-cccc-cccc-ccccccccccc1',
               '88888888-8888-8888-8888-888888888885', 1, 'system:check')$q$);
SELECT pg_temp.expect_reject(
    '01 — der vollzogene Tausch stellte die Familie zweimal an denselben Termin',
    $q$UPDATE cleaning_assignments
          SET cleaning_slot_id = '88888888-8888-8888-8888-888888888885'
        WHERE cleaning_assignment_id = '99999999-9999-9999-9999-999999999991'$q$);

-- 01: „Bei den manuellen Schritten entsteht … je eine offene Aufgabe … —
-- Zuteilung freigeben, Anwesenheit eintragen, Anwesenheitsliste ausdrucken —,
-- und sie läuft in der Wochenmail mit, bis sie abgehakt ist." Die dritte hat
-- keine eigene Spur — gedruckt wird eine frisch erzeugte Liste — und braucht
-- deshalb den Bezug auf den Termin. Sie ist „ein bis zwei Tage vor dem Termin
-- fällig", hängt also am Termin und nicht am Jahr.
INSERT INTO roles (code, name, created_by)
    VALUES ('secretariat', 'Sekretariat', 'system:check');
INSERT INTO sync_targets (code, name, role_id, created_by)
    VALUES ('cleaning_sheet', 'Anwesenheitsliste Putzdienst',
            (SELECT role_id FROM roles WHERE code='secretariat'), 'system:check');
SELECT pg_temp.expect_accept(
    'Q5/01 — Aufgabe „Anwesenheitsliste ausdrucken" am einzelnen Termin',
    $q$INSERT INTO sync_tasks (sync_target_id, cleaning_slot_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='cleaning_sheet'),
               '88888888-8888-8888-8888-888888888881',
               'Anwesenheitsliste ausdrucken', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5/01 — zweite offene Aufgabe derselben Art zu demselben Termin',
    $q$INSERT INTO sync_tasks (sync_target_id, cleaning_slot_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='cleaning_sheet'),
               '88888888-8888-8888-8888-888888888881',
               'Anwesenheitsliste ausdrucken', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'Q5/01 — Aufgabe mit Termin UND Familie als Bezug',
    $q$INSERT INTO sync_tasks (sync_target_id, cleaning_slot_id, family_id, task_text, created_by)
       VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='cleaning_sheet'),
               '88888888-8888-8888-8888-888888888882',
               '33333333-3333-3333-3333-333333333331',
               'Anwesenheitsliste ausdrucken', 'system:check')$q$);

-- 02: „die erledigten Nachzieh-Aufgaben gehen mit den Daten, auf die sie sich
-- beziehen" — an einem eigenen Termin gezeigt, damit die Proben danach ihren
-- Bestand behalten.
INSERT INTO cleaning_slots (cleaning_slot_id, cleaning_cycle_id, cleaning_slot_type_id,
                            starts_at, created_by)
    VALUES ('88888888-8888-8888-8888-888888888886', 1, 1,
            TIMESTAMPTZ '2027-03-13 09:00+01', 'system:check');
INSERT INTO sync_tasks (sync_target_id, cleaning_slot_id, task_text, created_by)
    VALUES ((SELECT sync_target_id FROM sync_targets WHERE code='cleaning_sheet'),
            '88888888-8888-8888-8888-888888888886',
            'Anwesenheitsliste ausdrucken', 'system:check');
SELECT pg_temp.expect_accept(
    'Q5/01 — die Aufgabe geht mit ihrem Termin',
    $q$DELETE FROM cleaning_slots
        WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888886'$q$);
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM sync_tasks
                WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888886') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Aufgabe überlebt ihren Termin';
    END IF;
    RAISE NOTICE 'ok (erlaubt): Q5/01 — keine Aufgabe überlebt ihren Termin';
END $$;

-- 01, Dateien: „Unterschrieben kommt sie zurück und wird eingescannt beim
-- Termin abgelegt." Sie liegt am Termin und trägt dieselben beiden Angaben wie
-- jede andere Datei — Bibliothek und Graph-Kennung, „ein Pfad bräche bei jedem
-- Verschieben" (querschnitt-schema.sql).
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY['attendance_sheet_library_id',
                      'attendance_sheet_graph_item_id']) AS c
    WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns
                       WHERE table_name = 'cleaning_slots' AND column_name = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Der eingescannten Anwesenheitsliste fehlt ihr Ort: %', missing;
    END IF;
    RAISE NOTICE 'ok: die eingescannte Unterschriftenliste hat ihren Ort am Termin';
END $$;

-- 01: Anmeldefenster und Freigabe.
SELECT pg_temp.expect_reject(
    '01 — Anmeldefenster, das vor seinem Beginn schließt',
    $q$INSERT INTO cleaning_cycles (start_year, registration_opens_at, registration_closes_at, created_by)
       VALUES (2027, TIMESTAMPTZ '2027-09-20 08:00+02', TIMESTAMPTZ '2027-09-01 08:00+02',
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '01 — Zuteilung freigegeben, bevor das Anmeldefenster schließt',
    $q$UPDATE cleaning_cycles SET allocation_released_at = TIMESTAMPTZ '2026-09-10 08:00+02'
        WHERE cleaning_cycle_id = 1$q$);

SELECT pg_temp.expect_reject(
    '01 — Zuteilung gelaufen, bevor das Anmeldefenster schließt',
    $q$UPDATE cleaning_cycles SET allocated_at = TIMESTAMPTZ '2026-09-10 08:00+02'
        WHERE cleaning_cycle_id = 1$q$);

SELECT pg_temp.expect_reject(
    '01 — freigegeben, ohne dass die Zuteilung gelaufen ist',
    $q$UPDATE cleaning_cycles SET allocation_released_at = TIMESTAMPTZ '2026-09-25 08:00+02'
        WHERE cleaning_cycle_id = 1$q$);

SELECT pg_temp.expect_reject(
    '01 — Zuteilungsmail vermerkt, ohne dass die Zuteilung freigegeben ist',
    $q$UPDATE cleaning_cycles SET allocation_mail_sent_at = TIMESTAMPTZ '2026-09-26 08:00+02'
        WHERE cleaning_cycle_id = 1$q$);

SELECT pg_temp.expect_reject(
    '01 — zweites Putzdienstjahr mit demselben Startjahr',
    $q$INSERT INTO cleaning_cycles (start_year, registration_opens_at, registration_closes_at, created_by)
       VALUES (2026, TIMESTAMPTZ '2026-09-01 08:00+02', TIMESTAMPTZ '2026-09-20 08:00+02',
               'system:check')$q$);

-- 01: ein abgesagter Termin wird nicht ausgewertet.
SELECT pg_temp.expect_reject(
    '01 — abgesagter Termin mit ausgewerteter Anwesenheit',
    $q$UPDATE cleaning_slots SET cancelled_at = now(), attendance_recorded_at = now()
        WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888883'$q$);

-- 01, Schritt 11: das Sekretariat „trägt … ein, wer da war, und legt die
-- eingescannte Liste dazu"; unter Dateien: „Unterschrieben kommt sie zurück und
-- wird eingescannt beim Termin abgelegt."
SELECT pg_temp.expect_accept(
    '01 — eingescannte Unterschriftenliste beim ausgewerteten Termin',
    $q$UPDATE cleaning_slots
          SET attendance_recorded_at = now(),
              attendance_sheet_library_id = 1,
              attendance_sheet_graph_item_id = '01ABCDEF'
        WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888881'$q$);

-- Bibliothek und Kennung stehen zusammen oder gar nicht — sonst wüsste niemand,
-- in welcher Bibliothek die Datei liegt, die der Jahreslauf mitnehmen muss.
SELECT pg_temp.expect_reject(
    '01 — Graph-Kennung der Liste ohne ihre Bibliothek',
    $q$UPDATE cleaning_slots SET attendance_sheet_graph_item_id = '01FEDCBA'
        WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888882'$q$);

-- Die Liste ist „der Beleg dafür, wer da war" — ohne ausgewertete Anwesenheit
-- belegt sie nichts.
SELECT pg_temp.expect_reject(
    '01 — Liste an einem Termin, der nie ausgewertet wurde',
    $q$UPDATE cleaning_slots SET attendance_sheet_library_id = 1,
                                attendance_sheet_graph_item_id = '01FEDCBA'
        WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888882'$q$);

-- 01: „Mitarbeitende der Schule mit eigenem Kind an der Schule (null Termine)".
SELECT pg_temp.expect_accept(
    '01 — abweichende Pflichtmenge von null für eine Mitarbeiterfamilie',
    $q$INSERT INTO cleaning_family_quotas (cleaning_cycle_id, family_id,
                                           cleaning_slot_type_id, required_count, created_by)
       VALUES (1, '33333333-3333-3333-3333-333333333332', 1, 0, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '01 — zweite abweichende Pflichtmenge derselben Familie und Art im selben Jahr',
    $q$INSERT INTO cleaning_family_quotas (cleaning_cycle_id, family_id,
                                           cleaning_slot_type_id, required_count, created_by)
       VALUES (1, '33333333-3333-3333-3333-333333333332', 1, 2, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '01 — negative Pflichtmenge',
    $q$INSERT INTO cleaning_family_quotas (cleaning_cycle_id, family_id,
                                           cleaning_slot_type_id, required_count, created_by)
       VALUES (1, '33333333-3333-3333-3333-333333333332', 2, -1, 'system:check')$q$);

-- 01: „die Platzzahl … eine Obergrenze, kein Soll" — aber keine von null.
SELECT pg_temp.expect_reject(
    '01 — Termin mit Platzzahl null',
    $q$UPDATE cleaning_slots SET capacity_override = 0
        WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888881'$q$);

-- „Die Platzzahl je Termin hält der Algorithmus möglichst ein, darf sie aber
-- überschreiten, wenn eine Familie sonst nicht vollzählig würde."
SELECT pg_temp.expect_accept(
    '01 — mehr Familien an einem Termin, als seine Platzzahl vorsieht',
    $q$UPDATE cleaning_slots SET capacity_override = 1
         WHERE cleaning_slot_id = '88888888-8888-8888-8888-888888888883';
       INSERT INTO cleaning_assignments (cleaning_slot_id, cleaning_slot_type_id,
                                         family_id, source, created_by)
       VALUES ('88888888-8888-8888-8888-888888888883', 2,
               '33333333-3333-3333-3333-333333333331', 'allocated', 'system:check'),
              ('88888888-8888-8888-8888-888888888883', 2,
               '33333333-3333-3333-3333-333333333332', 'allocated', 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- 6. Lösch-Lauf
-- ---------------------------------------------------------------------------

-- 03: „die Putzdienstdaten folgen weiter der Jahrgangsfrist aus 01, nicht dem
-- Austritt" — solange der Jahreslauf nicht geräumt hat, hält die Zuteilung die
-- Familie fest.
SELECT pg_temp.expect_reject(
    '03 — Familie gelöscht, obwohl ihre Putzdienstdaten noch stehen',
    $q$DELETE FROM families WHERE family_id = '33333333-3333-3333-3333-333333333331'$q$);

-- 01: „gelöscht wird einmal jährlich zum Schuljahresanfang, und zwar nicht das
-- gerade vergangene Putzdienstjahr, sondern das davor" — der Lauf setzt am
-- Zyklus an und läuft von dort durch, die Zahlung eingeschlossen: sie „geht mit
-- dem Vorgang, an dem die Zahlung hängt" (Q3). Mit dem Termin geht sein Verweis
-- auf die eingescannte Liste: „Die eingescannten Anwesenheitslisten gehen mit."
-- Die Datei in SharePoint nimmt der Lauf davor mit — er kennt den Zyklus, den
-- er räumt, und liest dessen Termine, bevor er löscht.
-- Zwei Schritte und nicht einer: Die Einzel-Freikäufe hält
-- `fk_cleaning_slot_buyouts_assignment` mit NO ACTION fest, damit das Streichen
-- eines einzelnen Termins sie nicht mitnimmt — der Jahreslauf räumt sie deshalb
-- selbst, vor dem Zyklus, und nimmt ihre Zahlungen per Cascade mit.
SELECT pg_temp.expect_accept(
    '01 — der Jahreslauf löscht den Zyklus samt allem, was an ihm hängt',
    $q$DELETE FROM cleaning_slot_buyouts b
         USING cleaning_assignments a, cleaning_slots s
        WHERE b.cleaning_assignment_id = a.cleaning_assignment_id
          AND a.cleaning_slot_id = s.cleaning_slot_id
          AND s.cleaning_cycle_id = 1;
       DELETE FROM cleaning_cycles WHERE cleaning_cycle_id = 1$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM cleaning_slots) OR EXISTS (SELECT 1 FROM cleaning_assignments)
       OR EXISTS (SELECT 1 FROM cleaning_buyouts) OR EXISTS (SELECT 1 FROM cleaning_slot_buyouts)
       OR EXISTS (SELECT 1 FROM cleaning_family_quotas) OR EXISTS (SELECT 1 FROM cleaning_cycle_quotas)
       OR EXISTS (SELECT 1 FROM payments) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Jahreslauf lässt Putzdienstdaten oder ihre Zahlung stehen';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 01 — nichts überlebt sein Putzdienstjahr';
END $$;

SELECT pg_temp.expect_accept(
    '03 — nach dem Jahreslauf geht auch die Familie',
    $q$DELETE FROM families WHERE family_id = '33333333-3333-3333-3333-333333333331'$q$);

DO $$ BEGIN RAISE NOTICE 'putzdienst-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
