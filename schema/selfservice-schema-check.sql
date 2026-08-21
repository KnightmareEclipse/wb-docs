-- Prüfskript zu selfservice-schema.sql.
--
-- Sollstand: keine eigenen Tabellen. Geprüft wird, dass die fünf Strukturen
-- stehen, auf denen der Selfservice arbeitet, und dass die drei bewusst nicht
-- gebauten Dinge auch wirklich nicht da sind.
--
-- Setzt stammdaten-schema.sql, querschnitt-schema.sql und anmeldung-schema.sql
-- voraus:
--   psql -v ON_ERROR_STOP=1 -f selfservice-schema-check.sql

BEGIN;

DO $$
DECLARE unexpected text;
BEGIN
    SELECT string_agg(t, ', ') INTO unexpected
    FROM unnest(ARRAY['portal_accounts', 'self_service_requests',
                      'access_level_fields', 'guardian_permissions']) AS t
    WHERE to_regclass('public.' || t) IS NOT NULL;
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Domäne 8 hat entgegen grenzkarte.md eigene Tabellen: %', unexpected;
    END IF;

    -- „Ein Zustand ‚hat Zugang' … folgt aus den laufenden Verbindungen."
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name IN ('families', 'persons')
                  AND column_name IN ('has_portal_access', 'portal_enabled')) THEN
        RAISE EXCEPTION 'Es gibt einen Zugangs-Zustand neben den laufenden Verbindungen';
    END IF;
    RAISE NOTICE 'ok: keine eigenen Tabellen und kein Zugangs-Zustand';
END $$;

DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(x, ', ') INTO missing FROM (VALUES
        ('persons.email'), ('persons.last_login_at'), ('addresses.street'),
        ('phone_numbers.number'), ('family_contacts.is_emergency_contact'),
        ('family_guardians.access_level_id'), ('login_codes.created_at'),
        -- Die Grenze aus 02 hat zwei Seiten: die Freigabe des ersten Vertrags
        -- und, bei den Kindern des Vollimports ohne Vertrag, die Einschreibung.
        ('contracts.released_at'), ('children.entry_date')
    ) AS v(x)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns
         WHERE table_name = split_part(x, '.', 1)
           AND column_name = split_part(x, '.', 2));
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Dem Selfservice fehlen Strukturen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle fünf Strukturen stehen';
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
INSERT INTO countries (country_id, code, name, nationality_name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'DE', 'Deutschland', 'deutsch');
INSERT INTO guardian_relations (guardian_relation_id, code, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'mother', 'Mutter'), (2, 'father', 'Vater');
INSERT INTO access_levels (access_level_id, code, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'full', 'voll'), (2, 'read_only', 'nur lesen'), (3, 'blocked', 'gesperrt');
INSERT INTO addresses (address_id, street, house_number, postal_code, city, country_id, created_by)
    VALUES ('11111111-1111-1111-1111-111111111111', 'Hauptstr.', '1', '12345',
            'Musterstadt', 1, 'guardian:11111111-1111-1111-1111-111111111111');
INSERT INTO persons (person_id, first_name, last_name, email, address_id, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Mutter', 'Muster', 'fam@example.org',
     '11111111-1111-1111-1111-111111111111', 'guardian:22222222-2222-2222-2222-222222222221'),
    ('22222222-2222-2222-2222-222222222222', 'Vater',  'Muster', 'fam@example.org',
     '11111111-1111-1111-1111-111111111111', 'guardian:22222222-2222-2222-2222-222222222221'),
    ('22222222-2222-2222-2222-222222222223', 'Oma',    'Muster', NULL, NULL, 'entra:sekretariat');
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333331', 'guardian:22222222-2222-2222-2222-222222222221');
INSERT INTO family_guardians (family_id, person_id, guardian_relation_id,
                              access_level_id, created_by) VALUES
    ('33333333-3333-3333-3333-333333333331', '22222222-2222-2222-2222-222222222221', 1, 1,
     'guardian:22222222-2222-2222-2222-222222222221'),
    ('33333333-3333-3333-3333-333333333331', '22222222-2222-2222-2222-222222222222', 2, 1,
     'guardian:22222222-2222-2222-2222-222222222221');

-- ---------------------------------------------------------------------------
-- Gegenproben
-- ---------------------------------------------------------------------------

-- hebel.md, Einsichtsstufe: „vom Sekretariat auf Vorlage eines Beschlusses …
-- voll, nur lesen, gesperrt" — drei Zeilen in `access_levels`, und die Stufe am
-- Sorgeberechtigten zeigt auf eine davon.
SELECT pg_temp.expect_accept(
    'hebel.md — Einsichtsstufe auf „nur lesen" gesetzt',
    $q$UPDATE family_guardians SET access_level_id =
           (SELECT access_level_id FROM access_levels WHERE code = 'read_only')
        WHERE person_id = '22222222-2222-2222-2222-222222222222'$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Einsichtsstufe, die in der Werteliste nicht steht',
    $q$UPDATE family_guardians SET access_level_id = 99
        WHERE person_id = '22222222-2222-2222-2222-222222222222'$q$);

-- 02: „Ein vierter Grad derselben Achse ist ein Wert mehr und die Stelle im
-- Portal, die ihn beachtet" — ein Wert mehr und keine Migration. Die Feldliste
-- je Stufe bleibt dagegen ausgeschlossen (`access_level_fields` oben): Sie wäre
-- eine zweite Achse, nicht ein vierter Grad.
SELECT pg_temp.expect_accept(
    '02 — der vierte Grad ist eine Zeile',
    $q$INSERT INTO access_levels (code, name) VALUES ('partial', 'teilweise');
       UPDATE family_guardians SET access_level_id =
           (SELECT access_level_id FROM access_levels WHERE code = 'partial')
        WHERE person_id = '22222222-2222-2222-2222-222222222222'$q$);

-- 02: „Wer die eigene Anschrift ändert, wird gefragt, ob sie auch für die
-- Kinder gilt — ein Häkchen, kein zweiter Vorgang": eine Zeile, mehrere
-- Personen darauf.
SELECT pg_temp.expect_accept(
    '02 — Umzug einer Familie als eine Änderung',
    $q$UPDATE addresses SET street = 'Nebenstr.', house_number = '7'
        WHERE address_id = '11111111-1111-1111-1111-111111111111'$q$);

-- 02: die Eltern tragen selbst ein — der Urheber trägt das guardian-Präfix.
SELECT pg_temp.expect_accept(
    '02 — Erziehungsberechtigte als Urheber einer eigenen Änderung',
    $q$INSERT INTO phone_numbers (person_id, number, reachable_daytime, note, created_by)
       VALUES ('22222222-2222-2222-2222-222222222221', '0170 1234567', true,
               'mobil, tagsüber', 'guardian:22222222-2222-2222-2222-222222222221')$q$);

SELECT pg_temp.expect_reject(
    '02 — Änderung ohne erkennbaren Urheber',
    $q$INSERT INTO phone_numbers (person_id, number, created_by)
       VALUES ('22222222-2222-2222-2222-222222222221', '0170 7654321', 'anonym')$q$);

-- 02: „An der Familie die Notfallkontakte und Abholberechtigten … eine nicht
-- sorgeberechtigte Person genügt."
SELECT pg_temp.expect_accept(
    '02 — nicht sorgeberechtigte Person als Notfallkontakt',
    $q$INSERT INTO family_contacts (family_id, person_id, relationship,
                                    is_emergency_contact, created_by)
       VALUES ('33333333-3333-3333-3333-333333333331',
               '22222222-2222-2222-2222-222222222223', 'Oma', true,
               'guardian:22222222-2222-2222-2222-222222222221')$q$);

-- 05: Bestätigt wird nur die eigene Mailadresse, „die zweite wird übernommen" —
-- die Adresse ist bewusst nicht UNIQUE, und der Zugang folgt daraus (00:
-- „Teilen sich Mutter und Vater eine Mailadresse, teilen sie sich damit auch
-- den Zugang").
DO $$
BEGIN
    IF (SELECT count(*) FROM persons WHERE email = 'fam@example.org') <> 2 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — zwei Personen teilen sich keine Mailbox';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 00 — zwei Sorgeberechtigte teilen sich eine Mailadresse';
END $$;

-- hebel.md, Anmeldecode: er hängt an der Adresse und nicht an einer Person —
-- „bevor dort irgendetwas entsteht, bestätigen sie ihre Mailadresse".
SELECT pg_temp.expect_accept(
    '00 — Anmeldecode für eine Adresse, die der Schule unbekannt ist',
    $q$INSERT INTO login_codes (email, code_hash, purpose)
       VALUES ('nochnichtbekannt@example.org', 'x', 'login')$q$);

DO $$ BEGIN RAISE NOTICE 'selfservice-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
