-- Prüfskript zu rechnungsfreigabe-schema.sql.
--
-- Sollstand: 9 Tabellen — payees, cost_projects, ledger_accounts,
-- claim_templates, claim_template_shares, expense_claims, expense_claim_items,
-- travel_details und expense_claim_attachments, dazu zwei Lese-Indizes
-- für Dublettenhinweis und Warteschlange.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus:
--   psql -v ON_ERROR_STOP=1 -f rechnungsfreigabe-schema-check.sql

BEGIN;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY['payees', 'cost_projects', 'ledger_accounts', 'claim_templates',
                      'claim_template_shares', 'expense_claims', 'expense_claim_items',
                      'travel_details', 'expense_claim_attachments']) AS t
    WHERE to_regclass('public.' || t) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 9 Tabellen vorhanden';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_expense_claims', 'pk_expense_claim_items', 'pk_travel_details',
        'fk_expense_claims_submitter', 'fk_expense_claims_payee',
        'fk_expense_claim_items_approver', 'fk_expense_claim_items_project',
        'fk_travel_details_claim', 'fk_expense_claim_attachments_claim',
        'uq_expense_claims_number', 'uq_travel_details', 'uq_expense_claims_amount',
        'ck_travel_details_amount',
        'uq_expense_claim_attachments', 'uq_claim_template_shares', 'uq_payees_name',
        'ck_expense_claims_submitter', 'ck_expense_claim_items_approver',
        'ck_expense_claims_type', 'ck_expense_claims_route',
        'ck_expense_claims_third_party', 'ck_expense_claims_payee',
        'ck_expense_claims_end', 'ck_expense_claims_voided',
        'ck_expense_claims_calendar_year',
        'ck_expense_claim_items_decision', 'ck_expense_claim_items_rejected',
        'ck_expense_claim_items_corrected',
        'ck_expense_claim_items_forwarded', 'ck_expense_claim_items_approved',
        'uq_expense_claims_submitter', 'fk_expense_claim_items_submitter_claim',
        'fk_expense_claim_items_submitter', 'ck_expense_claim_items_self_approval',
        'ck_travel_details_mode', 'ck_travel_details_rate', 'ck_travel_details_distance',
        'ck_claim_template_shares_amount', 'ck_payees_merge'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;

    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_expense_claims_duplicate', 'ix_expense_claim_items_waiting']) AS i
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
INSERT INTO houses (house_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'school', 'Schule', 'system:check'), (2, 'kita', 'KITA', 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Einreicher', 'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Fuehrung',   'Muster', 'system:check'),
    ('22222222-2222-2222-2222-222222222223', 'KitaKraft',  'Muster', 'system:check');
INSERT INTO employees (employee_id, person_id, house_id, created_by) VALUES
    ('55555555-5555-5555-5555-555555555551', '22222222-2222-2222-2222-222222222221', 1, 'system:check'),
    ('55555555-5555-5555-5555-555555555552', '22222222-2222-2222-2222-222222222222', 1, 'system:check'),
    ('55555555-5555-5555-5555-555555555553', '22222222-2222-2222-2222-222222222223', 2, 'system:check');

-- Ohne feste Schlüssel und ohne OVERRIDING SYSTEM VALUE: die beiden Zeilen
-- bekommen 1 und 2 aus der Identity-Folge, und die Folge steht danach auf 3.
-- Mit festen Schlüsseln blieb sie auf 1 stehen — die Probe „derselbe
-- Empfängername zweimal" weiter unten legt ohne Schlüssel an und scheiterte
-- deshalb an `pk_payees` statt an `uq_payees_name`, den sie zu prüfen behauptet.
-- Der RESTART davor macht das wiederholbar: Identity-Folgen sind nicht
-- transaktional, nach dem ROLLBACK steht die Folge weiter auf 3, und der
-- zweite Lauf bekäme 3 und 4 statt 1 und 2 — die Proben unten rechnen aber mit
-- `payee_id = 1` und `= 2`. rules.md Abschnitt 3: „Jedes Skript ist idempotent
-- — beliebig oft wiederholbar."
ALTER TABLE payees ALTER COLUMN payee_id RESTART WITH 1;
INSERT INTO payees (name, created_by)
    VALUES ('Deutsche Bahn', 'system:check'), ('DB', 'system:check');
INSERT INTO cost_projects (cost_project_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'GS', 'Grundschule', 'system:check'), (2, 'KITA', 'KITA', 'system:check');
INSERT INTO ledger_accounts (ledger_account_id, code, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, '4930', 'Bürobedarf', 'system:check');
INSERT INTO sharepoint_libraries (sharepoint_library_id, code, name, graph_drive_id, created_by)
    OVERRIDING SYSTEM VALUE VALUES (1, 'generated', 'Erzeugt', 'b!x', 'system:check');

-- ---------------------------------------------------------------------------
-- Gegenproben — Beleg
-- ---------------------------------------------------------------------------

-- 12: „Ein Beleg gehört zu dem Jahr, in dem er eingereicht wurde" — das
-- Kalenderjahr folgt aus `created_at` und trägt den Nummernkreis
-- (`uq_expense_claims_number`). Deshalb steht in den Proben unten überall das
-- Jahr des Laufs und keine feste Zahl: ein fremdes Jahr weist `ck_expense_claims_calendar_year` ab.
SELECT pg_temp.expect_reject(
    '12 — Beleg im Nummernkreis eines fremden Jahres',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', 1999, 1, 1000,
               'Kaffee', 'to_me', 'system:check')$q$);

-- Dasselbe Jahr in jeder Sitzung: `EXTRACT(year FROM timestamptz)` ist STABLE,
-- erst die feste Zeitzone im CHECK macht das Jahr entscheidbar. Die Zeile unten
-- liegt am Silvesterabend eine halbe Stunde vor Mitternacht UTC — in Berlin ist
-- da schon das neue Jahr. Ohne die feste Zeitzone ginge sie in einer
-- UTC-Sitzung durch und wäre danach in einer Berliner Sitzung nicht mehr
-- änderbar; die drei Proben halten beide Seiten fest.
SELECT pg_temp.expect_reject(
    '12 — Beleg am Silvesterabend mit dem Jahr der UTC-Sitzung',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route,
                                   created_at, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', 2026, 1, 1000,
               'Kaffee', 'to_me', TIMESTAMPTZ '2026-12-31 23:30+00', 'system:check')$q$);
SELECT pg_temp.expect_accept(
    '12 — derselbe Beleg mit dem Jahr, das in Berlin gilt',
    $q$INSERT INTO expense_claims (expense_claim_id, submitter_employee_id, claim_type,
                                   calendar_year, payee_id, amount_cents, purpose,
                                   payment_route, created_at, created_by)
       VALUES ('66666666-6666-6666-6666-66666666666e',
               '55555555-5555-5555-5555-555555555551', 'invoice', 2027, 1, 1000,
               'Kaffee', 'to_me', TIMESTAMPTZ '2026-12-31 23:30+00', 'system:check')$q$);
SET TIME ZONE 'Pacific/Auckland';
SELECT pg_temp.expect_accept(
    '12 — und er bleibt in einer Sitzung mit fremder Zeitzone änderbar',
    $q$UPDATE expense_claims SET purpose = 'Kaffee und Kuchen'
        WHERE expense_claim_id = '66666666-6666-6666-6666-66666666666e'$q$);
RESET TIME ZONE;

-- 12: „Zwei Belegarten und keine dritte."
SELECT pg_temp.expect_reject(
    '12 — dritte Belegart',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'petty_cash', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, 1000,
               'Kaffee', 'to_me', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '12 — unbekannter Zahlweg',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, 1000,
               'Kaffee', 'cash', 'system:check')$q$);

-- „nur ‚an Dritte' verlangt zusätzlich Kontoinhaber und IBAN … für ‚an mich'
-- wird keine Bankverbindung erhoben".
SELECT pg_temp.expect_reject(
    '12 — Bankverbindung bei „an mich"',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route,
                                   third_party_iban, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, 1000,
               'Kaffee', 'to_me', 'DE02120300000000202051', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '12 — Bankverbindung bei „an Dritte"',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route,
                                   third_party_account_holder, third_party_iban, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, 1000,
               'Material', 'to_third_party', 'Nachbarin', 'DE02120300000000202051',
               'system:check')$q$);

-- „Bei der Rechnung: Zahlungsempfänger … (alles Pflicht)".
SELECT pg_temp.expect_reject(
    '12 — Rechnung ohne Zahlungsempfänger',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   amount_cents, purpose, payment_route, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1000,
               'Material', 'to_me', 'system:check')$q$);

-- „bei einer Fahrt nach Strecke, die keinen Empfänger trägt".
INSERT INTO expense_claims (expense_claim_id, submitter_employee_id, claim_type,
                            calendar_year, amount_cents, purpose, payment_route, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661',
            '55555555-5555-5555-5555-555555555551', 'travel', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 3000,
            'Fortbildung Stuttgart', 'to_me', 'system:check');

-- „Gutschriften sind erlaubt, der Betrag darf negativ sein."
SELECT pg_temp.expect_accept(
    '12 — Gutschrift mit negativem Betrag',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, -1500,
               'Gutschrift Rücksendung', 'to_me', 'system:check')$q$);

-- „ihre lückenlose Nummer für die Buchhaltung" — je Kalenderjahr eindeutig.
SELECT pg_temp.expect_reject(
    '12 — dieselbe Belegnummer zweimal in einem Jahr',
    $q$UPDATE expense_claims SET claim_number = 1
         WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661';
       INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   claim_number, payee_id, amount_cents, purpose,
                                   payment_route, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, 1, 500,
               'Zweiter', 'to_me', 'system:check')$q$);

-- „Ein abgelehnter, stornierter oder zurückgezogener Beleg lebt nicht wieder auf."
SELECT pg_temp.expect_reject(
    '12 — Beleg zugleich gebucht und storniert',
    $q$UPDATE expense_claims SET booked_at = now(), booked_by = 'entra:buchhaltung',
                                voided_at = now(), voided_reason = 'doch nicht'
        WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_reject(
    '12 — Stornierung ohne Begründung',
    $q$UPDATE expense_claims SET voided_at = now()
        WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661'$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — Fahrtkosten
-- ---------------------------------------------------------------------------

-- Der Beleg für die Streckengrenze: 2500 km zu 0,30 € sind 750 €, und der
-- Betrag der Fahrtangabe muss der des Belegs sein.
INSERT INTO expense_claims (expense_claim_id, submitter_employee_id, claim_type,
                            calendar_year, amount_cents, purpose, payment_route, created_by)
    VALUES ('66666666-6666-6666-6666-666666666663',
            '55555555-5555-5555-5555-555555555551', 'travel', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 75000,
            'Fortbildung Lissabon', 'to_me', 'system:check');

SELECT pg_temp.expect_reject(
    '12 — Fahrt mit Ticketbetrag UND Strecke',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, ticket_amount_cents, distance_km,
                                   mileage_rate_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', DATE '2027-03-01', 3000, 'Schule',
               'Stuttgart', 3000, 100, 30, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '12 — Fahrt ohne Ticketbetrag und ohne Strecke',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', DATE '2027-03-01', 3000, 'Schule',
               'Stuttgart', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '12 — Strecke ohne den Kilometersatz, der damals galt',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, distance_km, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', DATE '2027-03-01', 3000, 'Schule',
               'Stuttgart', 100, 'system:check')$q$);

-- „die Strecke ist auf 2000 km je Fahrt begrenzt".
SELECT pg_temp.expect_reject(
    '12 — Fahrt über 2000 km',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, distance_km, mileage_rate_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666663', DATE '2027-03-01', 75000, 'Schule',
               'Lissabon', 2500, 30, 'system:check')$q$);

-- X3 — 12: „entweder Ticketbetrag samt Beleg oder die Strecke, die mit dem
-- Kilometersatz multipliziert wird." Vorher stand der Belegbetrag daneben und
-- war an nichts gebunden: 9.999,99 € über 1 km gingen durch.
SELECT pg_temp.expect_reject(
    '12 — Belegbetrag, der nicht Strecke mal Kilometersatz ist',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, distance_km, mileage_rate_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', DATE '2027-03-01', 3000, 'Schule',
               'Stuttgart', 1, 30, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '12 — Fahrtangabe, deren Betrag vom Beleg abweicht',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, ticket_amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', DATE '2027-03-01', 2500, 'Schule',
               'Stuttgart', 2500, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '12 — Fahrt nach Strecke mit dem damals geltenden Satz',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, distance_km, mileage_rate_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', DATE '2027-03-01', 3000, 'Schule',
               'Stuttgart', 100, 30, 'system:check')$q$);

-- Und andersherum: der Betrag am Beleg kann nicht unter seiner Fahrtangabe
-- weglaufen.
SELECT pg_temp.expect_reject(
    '12 — der Betrag des Belegs wandert unter seiner Fahrtangabe weg',
    $q$UPDATE expense_claims SET amount_cents = 9999999
        WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661'$q$);

SELECT pg_temp.expect_reject(
    '12 — zweite Fahrtangabe an demselben Beleg',
    $q$INSERT INTO travel_details (expense_claim_id, travelled_on, amount_cents, origin,
                                   destination, ticket_amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', DATE '2027-03-02', 3000, 'Schule',
               'Ulm', 3000, 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — Freigabe und Aufteilung
-- ---------------------------------------------------------------------------

INSERT INTO expense_claim_items (expense_claim_item_id, expense_claim_id,
                                 submitter_employee_id, claim_type, payment_route,
                                 approver_employee_id, amount_cents, created_by)
    VALUES ('77777777-7777-7777-7777-777777777771',
            '66666666-6666-6666-6666-666666666661',
            '55555555-5555-5555-5555-555555555551', 'travel', 'to_me',
            '55555555-5555-5555-5555-555555555552', 3000, 'system:check');

-- 12: „Die eigene Person ist als Führungskraft wählbar, außer das Geld geht an
-- ihn selbst … Weil eine Fahrtkostenabrechnung immer eine Erstattung ist,
-- trifft sie das ausnahmslos."
SELECT pg_temp.expect_reject(
    '12 — Einreicher gibt seine eigene Fahrtkostenabrechnung frei',
    $q$INSERT INTO expense_claim_items (expense_claim_id, submitter_employee_id,
                                        claim_type, payment_route,
                                        approver_employee_id, amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661',
               '55555555-5555-5555-5555-555555555551', 'travel', 'to_me',
               '55555555-5555-5555-5555-555555555551', 0, 'system:check')$q$);

-- Dieselbe Sperre trifft „an mich"; sie trifft nicht, was gar nicht bei ihm
-- ankommt: „Die eigene Person ist als Führungskraft wählbar."
INSERT INTO expense_claims (expense_claim_id, submitter_employee_id, claim_type,
                            calendar_year, payee_id, amount_cents, purpose,
                            payment_route, created_by)
    VALUES ('66666666-6666-6666-6666-666666666662',
            '55555555-5555-5555-5555-555555555551', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, 4000,
            'Rechnung der Firma', 'to_company', 'system:check');
SELECT pg_temp.expect_accept(
    '12 — Einreicher gibt eine Rechnung frei, die direkt an die Firma geht',
    $q$INSERT INTO expense_claim_items (expense_claim_id, submitter_employee_id,
                                        claim_type, payment_route,
                                        approver_employee_id, amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666662',
               '55555555-5555-5555-5555-555555555551', 'invoice', 'to_company',
               '55555555-5555-5555-5555-555555555551', 4000, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '12 — Einreicher gibt seine eigene Erstattung frei',
    $q$INSERT INTO expense_claim_items (expense_claim_id, submitter_employee_id,
                                        claim_type, payment_route,
                                        approver_employee_id, amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666662',
               '55555555-5555-5555-5555-555555555551', 'invoice', 'to_me',
               '55555555-5555-5555-5555-555555555551', 0, 'system:check')$q$);

-- 12: „die Teilbeträge müssen den Betrag genau treffen" — auch das eine Summe
-- über mehrere Zeilen und deshalb Sache der Anwendung. Der Beleg über 4000
-- nimmt hier einen Teil über 9000 an.
SELECT pg_temp.expect_accept(
    '12 — Teilbetrag über dem Beleg (die Summe prüft die Anwendung)',
    $q$INSERT INTO expense_claim_items (expense_claim_id, submitter_employee_id,
                                        claim_type, payment_route,
                                        approver_employee_id, amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666662',
               '55555555-5555-5555-5555-555555555551', 'invoice', 'to_company',
               '55555555-5555-5555-5555-555555555552', 9000, 'system:check')$q$);

-- rules.md 1: der zusammengesetzte Fremdschlüssel hält die mitgeführten Angaben
-- mit ihrer Quelle zusammen — sonst ließe sich die Sperre am Teil umschreiben.
SELECT pg_temp.expect_reject(
    'rules.md 1 — Teil mit einer anderen Belegart als sein Beleg',
    $q$UPDATE expense_claim_items SET claim_type = 'invoice'
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '12 — Teil zugleich freigegeben und abgelehnt',
    $q$UPDATE expense_claim_items SET approved_at = now(), cost_project_id = 1,
                                     rejected_at = now(), rejected_reason = 'doch nicht'
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '12 — Ablehnung ohne Begründung',
    $q$UPDATE expense_claim_items SET rejected_at = now()
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '12 — Weiterleitung ohne Begründung',
    $q$UPDATE expense_claim_items SET forwarded_at = now()
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

-- „wem die Ausgabe gehört, bleibt die Entscheidung der Führungskraft" —
-- freigegeben wird nur mit Projekt.
SELECT pg_temp.expect_reject(
    '12 — Freigabe ohne Projekt',
    $q$UPDATE expense_claim_items SET approved_at = now()
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

-- 12, Schritt 2: „korrigieren (Angaben oder Betrag ändern, Grund Pflicht)", und
-- „Was dabei erhoben wird": „jede Korrektur, Ablehnung und Stornierung trägt
-- eine Pflichtbegründung." Es ist die einzige Stelle im Haus, an der jemand
-- einen fremden Betrag ändert, ohne dass der Einreicher zustimmt — „Zum
-- Einreicher zurück geht nichts".
SELECT pg_temp.expect_reject(
    '12 — Betrag korrigiert ohne Grund',
    $q$UPDATE expense_claim_items SET amount_cents = 2000, corrected_at = now()
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_reject(
    '12 — Korrekturgrund ohne Korrektur',
    $q$UPDATE expense_claim_items SET corrected_reason = 'falsches Projekt'
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

SELECT pg_temp.expect_accept(
    '12 — Betrag korrigiert, Grund daneben',
    $q$UPDATE expense_claim_items
          SET amount_cents = 2000, corrected_at = now(),
              corrected_reason = 'Strecke war 100 km, nicht 150'
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

-- „Zwei Wege davor entscheiden nichts, sie ändern nur, worüber und wer
-- entschieden wird": ein korrigierter Teil wird danach freigegeben wie jeder
-- andere. Die Korrektur gehört deshalb nicht in
-- `ck_expense_claim_items_decision` — die Freigabe darunter läuft auf demselben
-- Teil und weist die Korrektur nicht ab.
SELECT pg_temp.expect_accept(
    '12 — Freigabe mit Projekt, Konto und Budgetfeststellung',
    $q$UPDATE expense_claim_items
          SET approved_at = now(), cost_project_id = 1, ledger_account_id = 1,
              within_budget = true, last_action_at = now()
        WHERE expense_claim_item_id = '77777777-7777-7777-7777-777777777771'$q$);

-- 12: „Aufteilen … auf mindestens zwei Projekte" — mehrere Teile an einem Beleg,
-- jeder mit eigener Führungskraft.
SELECT pg_temp.expect_accept(
    '12 — zweiter Teil desselben Belegs bei einer anderen Führungskraft',
    $q$INSERT INTO expense_claim_items (expense_claim_id, submitter_employee_id,
                                        claim_type, payment_route,
                                        approver_employee_id, amount_cents, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661',
               '55555555-5555-5555-5555-555555555551', 'travel', 'to_me',
               '55555555-5555-5555-5555-555555555553', 0, 'system:check')$q$);

-- „Die KITA ist ein eigener Betrieb im selben Haus: Ihre Mitarbeitenden reichen
-- ein, gebucht wird auf ihr eigenes Projekt."
SELECT pg_temp.expect_accept(
    '12 — KITA-Mitarbeitende als Einreicherin',
    $q$INSERT INTO expense_claims (submitter_employee_id, claim_type, calendar_year,
                                   payee_id, amount_cents, purpose, payment_route, created_by)
       VALUES ('55555555-5555-5555-5555-555555555553', 'invoice', EXTRACT(year FROM now() AT TIME ZONE 'Europe/Berlin')::smallint, 1, 2000,
               'Bastelmaterial KITA', 'to_me', 'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Gegenproben — Vorlagen, Empfänger, Anhänge
-- ---------------------------------------------------------------------------

INSERT INTO claim_templates (claim_template_id, name, created_by) OVERRIDING SYSTEM VALUE
    VALUES (1, 'Miete Turnhalle', 'system:check'), (2, 'Halbe Vorlage', 'system:check');
INSERT INTO claim_template_shares (claim_template_id, cost_project_id, ledger_account_id,
                                   share_basis_points, created_by)
    VALUES (1, 1, 1, 6000, 'system:check');
SELECT pg_temp.expect_reject(
    '12 — zweiter Anteil derselben Vorlage auf dasselbe Projekt',
    $q$INSERT INTO claim_template_shares (claim_template_id, cost_project_id,
                                          share_basis_points, created_by)
       VALUES (1, 1, 4000, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '12 — Aufteilungsvorlage auf ein zweites Projekt',
    $q$INSERT INTO claim_template_shares (claim_template_id, cost_project_id,
                                          share_basis_points, created_by)
       VALUES (1, 2, 4000, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '12 — Anteil über 100 Prozent',
    $q$UPDATE claim_template_shares SET share_basis_points = 10001
        WHERE claim_template_id = 1 AND cost_project_id = 2$q$);

-- 12: „was beim Runden übrig bleibt, fällt auf den größten Anteil" setzt eine
-- vollständige Aufteilung voraus — eine Summe über mehrere Zeilen trägt kein
-- CHECK. Die Gegenprobe hält die Auslassung fest: hier läuft sie durch,
-- geprüft wird sie in der Anwendung.
SELECT pg_temp.expect_accept(
    '12 — Vorlage mit zwei Anteilen zu je 30 Prozent (die Summe prüft die Anwendung)',
    $q$INSERT INTO claim_template_shares (claim_template_id, cost_project_id,
                                          share_basis_points, created_by)
       VALUES (2, 1, 3000, 'system:check'),
              (2, 2, 3000, 'system:check')$q$);

-- 12: „die Buchhaltung berichtigt einen Eintrag oder führt zwei zusammen".
SELECT pg_temp.expect_accept(
    '12 — „DB" auf „Deutsche Bahn" zusammengeführt',
    $q$UPDATE payees SET merged_into_payee_id = 1 WHERE payee_id = 2$q$);

SELECT pg_temp.expect_reject(
    '12 — Empfänger auf sich selbst zusammengeführt',
    $q$UPDATE payees SET merged_into_payee_id = 1 WHERE payee_id = 1$q$);

SELECT pg_temp.expect_reject(
    '12 — derselbe Empfängername zweimal',
    $q$INSERT INTO payees (name, created_by) VALUES ('Deutsche Bahn', 'system:check')$q$);

-- 12: „Zahlungsempfänger, Betrag, Zweck …, der Zahlweg und mindestens ein
-- angehängter Beleg (alles Pflicht)" — die Anhangzeile entsteht nach dem Beleg,
-- und die Fahrt nach Strecke hat gar keinen. Die Gegenprobe hält fest, dass die
-- Pflicht deshalb in der Anwendung liegt und nicht hier.
SELECT pg_temp.expect_accept(
    '12 — Rechnung ohne Anhang gebucht (den Anhang verlangt die Anwendung)',
    $q$UPDATE expense_claims SET booked_at = now(), booked_by = 'entra:buchhaltung'
        WHERE expense_claim_id = '66666666-6666-6666-6666-666666666662'$q$);

-- 12: „ihre lückenlose Nummer für die Buchhaltung" — der Schlüssel hält sie je
-- Kalenderjahr eindeutig, lückenlos macht sie die Anwendung, die sie bei der
-- Freigabe zieht.
SELECT pg_temp.expect_accept(
    '12 — Belegnummer mit Lücke (die Folge zieht die Anwendung)',
    $q$UPDATE expense_claims SET claim_number = 7
        WHERE expense_claim_id = '66666666-6666-6666-6666-666666666662'$q$);

-- 12: „Anhänge lassen sich nach dem Absenden nicht austauschen" — dieselbe Datei
-- hängt an höchstens einem Beleg.
INSERT INTO expense_claim_attachments (expense_claim_id, sharepoint_library_id,
                                       graph_item_id, created_by)
    VALUES ('66666666-6666-6666-6666-666666666661', 1, '01BELEG', 'system:check');
SELECT pg_temp.expect_reject(
    '12 — dieselbe Datei ein zweites Mal angehängt',
    $q$INSERT INTO expense_claim_attachments (expense_claim_id, sharepoint_library_id,
                                              graph_item_id, created_by)
       VALUES ('66666666-6666-6666-6666-666666666661', 1, '01BELEG', 'system:check')$q$);

-- 12: „Der Beleg überlebt seinen Einreicher: Scheidet er aus, bleibt sein Name
-- daran." Ohne den Namen scheitert das Nullsetzen am CHECK — der Beleg kann
-- nicht ohne Einreicher zurückbleiben.
SELECT pg_temp.expect_reject(
    '12 — Einreicher gelöscht, ohne dass sein Name am Beleg steht',
    $q$DELETE FROM employees WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

SELECT pg_temp.expect_accept(
    '12 — der Beleg überlebt seinen Einreicher, sein Name bleibt daran',
    $q$UPDATE expense_claims SET submitter_employee_name = 'Hausmeister Muster'
        WHERE submitter_employee_id = '55555555-5555-5555-5555-555555555551';
       UPDATE expense_claim_items SET approver_employee_name = 'Hausmeister Muster'
        WHERE approver_employee_id = '55555555-5555-5555-5555-555555555551';
       DELETE FROM employees WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM expense_claims
                    WHERE submitter_employee_id IS NULL
                      AND submitter_employee_name = 'Hausmeister Muster') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Beleg überlebt seinen Einreicher nicht';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 12 — der Beleg steht weiter, mit dem Namen statt der Kennung';
END $$;

-- Dasselbe für die Führungskraft: „ein Beleg, der noch bei ihm liegt, trägt
-- dort den Vermerk, dass seine Führungskraft ausgeschieden ist" (13).
SELECT pg_temp.expect_reject(
    '13 — Führungskraft gelöscht, ohne dass ihr Name am Teil steht',
    $q$DELETE FROM employees WHERE employee_id = '55555555-5555-5555-5555-555555555552'$q$);

SELECT pg_temp.expect_accept(
    '13 — der Teil überlebt seine Führungskraft, ihr Name bleibt daran',
    $q$UPDATE expense_claim_items SET approver_employee_name = 'Lehrkraft Muster'
        WHERE approver_employee_id = '55555555-5555-5555-5555-555555555552';
       DELETE FROM employees WHERE employee_id = '55555555-5555-5555-5555-555555555552'$q$);

-- 12: „Zwei Werte im System gehören der Geschäftsführung, beide mit
-- Gültigkeitsdatum: der Kilometersatz … und die Meldegrenze, derzeit 250 € …;
-- es gilt jeweils der Wert zu der Handlung, die ihn braucht — der Kilometersatz
-- zum Einreichen, die Meldegrenze zur Freigabe." Der Kilometersatz steht am
-- Beleg mitgeführt; die Meldegrenze wird gelesen, nicht gerechnet, und hat
-- deshalb nur ihren Ort in der Werteliste (rules.md Abschnitt 3: kein
-- organisatorischer Wert im Code).
INSERT INTO configured_values (code, valid_from, value, created_by) VALUES
    ('expense_report_threshold_cents', DATE '2026-01-01', 25000, 'system:check'),
    ('expense_report_threshold_cents', DATE '2027-06-01', 30000, 'system:check');

DO $$
DECLARE threshold integer;
BEGIN
    -- Der Wert zur Freigabe: die Freigabe fällt am 1.3.2027, es gilt die 250 €
    -- von 2026 und noch nicht die 300 € ab Juni.
    SELECT value INTO threshold FROM configured_values
     WHERE code = 'expense_report_threshold_cents' AND valid_from <= DATE '2027-03-01'
     ORDER BY valid_from DESC LIMIT 1;
    IF threshold IS DISTINCT FROM 25000 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Meldegrenze zur Freigabe ist %, nicht 25000', threshold;
    END IF;
    RAISE NOTICE 'ok: 12 — die Meldegrenze steht als Wert im System, mit dem Wert zur Freigabe';
END $$;

-- ---------------------------------------------------------------------------
-- Lösch-Lauf
-- ---------------------------------------------------------------------------
-- Diese Domäne hat als einzige mit Personenbezug keinen Löschanker: „Es
-- verschwindet nichts von selbst … die Angaben zum Beleg bleiben zehn Jahre in
-- Weltenbaum, die Anhänge in SharePoint, und was danach mit einem Jahrgang
-- geschieht, entscheidet die Geschäftsführung von Hand" (12). Sie kommt deshalb im Lauf aus 17 nicht vor —
-- die Gegenprobe zeigt beides: dass nichts von selbst geht und dass der eine
-- Griff von Hand alles mitnimmt, was am Beleg hängt.

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint
                WHERE contype = 'f' AND confdeltype = 'a'
                  AND confrelid::regclass::text IN ('children', 'families', 'persons')
                  AND conrelid::regclass::text IN ('expense_claims', 'expense_claim_items',
                                                   'travel_details', 'expense_claim_attachments')) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — ein Beleg hält Kind, Familie oder Person im Lösch-Lauf auf';
    END IF;
    RAISE NOTICE 'ok: 12 — der Beleg hält den Lauf aus 17 an keiner Stelle auf';
END $$;

-- „Löschanker: geht mit dem Beleg" — für Teil, Fahrt und Anhang.
SELECT pg_temp.expect_accept(
    '12 — der Beleg von Hand gelöscht, Teile, Fahrt und Anhänge gehen mit ihm',
    $q$DELETE FROM expense_claims
        WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM expense_claim_items
                WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661')
       OR EXISTS (SELECT 1 FROM travel_details
                   WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661')
       OR EXISTS (SELECT 1 FROM expense_claim_attachments
                   WHERE expense_claim_id = '66666666-6666-6666-6666-666666666661') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Teil, Fahrt oder Anhang überlebt seinen Beleg';
    END IF;
    -- Empfänger, Projekte und Konten bleiben: „Ein Eintrag der Empfängerliste
    -- bleibt, solange ein Beleg auf ihn zeigt" — und danach auch.
    IF NOT EXISTS (SELECT 1 FROM payees) OR NOT EXISTS (SELECT 1 FROM cost_projects) THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — Empfänger oder Projekt ging mit dem Beleg';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 12 — nichts überlebt seinen Beleg, die Listen bleiben';
END $$;

DO $$ BEGIN RAISE NOTICE 'rechnungsfreigabe-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
