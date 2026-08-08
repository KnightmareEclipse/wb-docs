-- Prüfskript zu domains/stammdaten-schema.sql — belegt, dass die Zusagen aus
-- domains/stammdaten.md nicht nur Prosa sind, sondern in der Datenbank gelten.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:16
--   podman cp domains/stammdaten-schema.sql       pg:/tmp/schema.sql
--   podman cp domains/stammdaten-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/schema.sql
--   podman exec pg psql -U postgres -f /tmp/check.sql
--   podman rm -f pg
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt, sonst
-- bricht das Skript beim ersten erwarteten Fehler ab.

-- ---------------------------------------------------------------------------
-- Ausgangsdaten
-- ---------------------------------------------------------------------------
BEGIN;
SET LOCAL app.actor = 'system:test';
INSERT INTO school_branches (id, label) VALUES (1, 'Grundschule'), (2, 'Realschule');
INSERT INTO grade_levels (id, school_branch_id, label, sort_order, is_final_grade)
    VALUES (4, 1, '4', 4, true), (5, 2, '5', 5, false), (6, 2, '6', 6, false);
INSERT INTO classes (id, school_branch_id, grade_level_id, entry_year, stream) VALUES
    (40, 1, 4, 2022, 'a'),
    (50, 2, 5, 2025, 'a');
INSERT INTO phone_types (id, label) VALUES (1, 'Festnetz'), (2, 'Mobil'), (3, 'Arbeit');
INSERT INTO denominations (id, label) VALUES (1, 'evangelisch');
INSERT INTO addresses (id, street, city)
    VALUES ('11111111-1111-1111-1111-111111111111', 'Hauptstr. 1', 'Musterdorf');
-- Kind und Elternteil unter derselben Anschrift
INSERT INTO persons (id, last_name, address_id) VALUES
    ('22222222-2222-2222-2222-222222222222', 'Müller', '11111111-1111-1111-1111-111111111111'),
    ('33333333-3333-3333-3333-333333333333', 'Müller', '11111111-1111-1111-1111-111111111111');
INSERT INTO children (id, date_of_birth, class_id)
    VALUES ('22222222-2222-2222-2222-222222222222', '2016-05-01', 40);
INSERT INTO organizations (id, name) VALUES ('44444444-4444-4444-4444-444444444444', 'Jugendamt');
COMMIT;

-- Session-weiter Actor für den Rest des Skripts (bewusst SET statt SET LOCAL,
-- damit nicht jede der folgenden Einzelanweisungen ihre eigene Transaktion
-- braucht) — der eigentliche Anwendungscode setzt ihn dagegen bewusst pro
-- Transaktion neu (siehe Kommentar am Trigger).
SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- Audit-Trigger: Verursacher kommt aus der Sitzungsvariablen, created_* ist
-- unveränderlich, updated_* wird fortgeschrieben; fehlender Actor scheitert
-- hart statt einen leeren/veralteten Verursacher stehen zu lassen (rules.md
-- Abschnitt 3)
-- ---------------------------------------------------------------------------
SELECT 'audit nach INSERT' AS pruefung, created_by, updated_by
    FROM persons WHERE id = '22222222-2222-2222-2222-222222222222';

BEGIN;
SET LOCAL app.actor = 'guardian:abc';
UPDATE persons SET first_name = 'Anna' WHERE id = '22222222-2222-2222-2222-222222222222';
COMMIT;
SELECT 'audit nach UPDATE' AS pruefung, created_by, updated_by, (updated_at > created_at) AS zeitstempel_neu
    FROM persons WHERE id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (kein app.actor gesetzt — RESET simuliert eine Transaktion, die SET LOCAL vergisst)'
BEGIN;
RESET app.actor;
UPDATE persons SET first_name = 'Anna2' WHERE id = '22222222-2222-2222-2222-222222222222';
ROLLBACK;
SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- citext: Gleichheitsvergleich ist case-insensitiv (für den OTP-Lookup);
-- E-Mail ist bewusst NICHT UNIQUE — zwei Erziehungsberechtigte dürfen sich
-- eine Mailbox teilen (domains/stammdaten.md, akzeptiertes Risiko)
-- ---------------------------------------------------------------------------
INSERT INTO persons (id, last_name, email) VALUES
    ('bbbbbbbb-2222-2222-2222-222222222222', 'Beispiel', 'Vorname.Nachname@Beispiel.de');
-- Erlaubt: zweite Person mit derselben Mailbox (andere Groß-/Kleinschreibung
-- macht dabei keinen Unterschied, citext-Vergleich unten belegt das gleich mit)
INSERT INTO persons (id, last_name, email) VALUES
    ('cccccccc-2222-2222-2222-222222222222', 'Beispiel2', 'vorname.nachname@beispiel.de');
SELECT 'zwei Personen mit geteilter Mailbox erlaubt' AS pruefung, count(*) AS anzahl
    FROM persons WHERE email = 'VORNAME.NACHNAME@BEISPIEL.DE';  -- dritte Schreibweise, muss beide finden

\echo '--- erwartet: FEHLER (Leerstring statt NULL bei E-Mail)'
INSERT INTO persons (id, last_name, email) VALUES ('dddddddd-2222-2222-2222-222222222222', 'Leer', '');

\echo '--- erwartet: FEHLER (Leerstring statt NULL bei Organisations-E-Mail)'
UPDATE organizations SET email = '' WHERE id = '44444444-4444-4444-4444-444444444444';

-- ---------------------------------------------------------------------------
-- Klassenstufe und Klasse am Kind schließen sich gegenseitig aus — keine
-- gekoppelte Kopie, keine Redundanz
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (class_id gesetzt UND provisional_grade_level_id gesetzt)'
UPDATE children SET provisional_grade_level_id = 4 WHERE id = '22222222-2222-2222-2222-222222222222';

-- Umgekehrt erlaubt: Klassenstufe steht fest, Klasse noch nicht zugeteilt
UPDATE children SET class_id = NULL WHERE id = '22222222-2222-2222-2222-222222222222';
UPDATE children SET provisional_grade_level_id = 4 WHERE id = '22222222-2222-2222-2222-222222222222';
SELECT 'Klassenstufe ohne Klasse erlaubt' AS pruefung;

-- Für die folgenden Tests wieder zuteilen (provisional_grade_level_id muss dafür weichen)
UPDATE children SET provisional_grade_level_id = NULL WHERE id = '22222222-2222-2222-2222-222222222222';
UPDATE children SET class_id = 40 WHERE id = '22222222-2222-2222-2222-222222222222';

-- ---------------------------------------------------------------------------
-- Klasse als Kohorte: school_branch_id muss zur Klassenstufe passen, Kohorte
-- (Zweig/Eintrittsjahr/Zug) ist eindeutig, Jahreslauf schreibt grade_level_id
-- auf derselben Zeile fort statt Kinder umzuhängen — braucht dafür kein
-- angefasstes Kind, da es keine gekoppelte Kopie gibt
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (school_branch_id passt nicht zur Klassenstufe)'
INSERT INTO classes (school_branch_id, grade_level_id, entry_year, stream) VALUES (1, 5, 2025, 'b');

\echo '--- erwartet: FEHLER (Kohorte Realschule/2025/a existiert schon)'
INSERT INTO classes (school_branch_id, grade_level_id, entry_year, stream) VALUES (2, 5, 2025, 'a');

-- Ein zweites Kind wirklich an Klasse 50 hängen, damit der Jahreslauf unten
-- nicht nur eine leere Zeile verschiebt.
INSERT INTO persons (id, last_name) VALUES ('aaaaaaaa-1111-1111-1111-111111111111', 'Schmidt');
INSERT INTO children (id, date_of_birth, class_id)
    VALUES ('aaaaaaaa-1111-1111-1111-111111111111', '2015-03-01', 50);

-- Jahreslauf für die fortbestehende Kohorte Realschule/2025/a: dieselbe
-- Klassenzeile (id 50) rückt eine Klassenstufe vor, kein Kind wird angefasst.
UPDATE classes SET grade_level_id = 6 WHERE id = 50;
SELECT 'Kohorte nach Jahreslauf, class_id des Kindes unverändert' AS pruefung,
       c.class_id, cl.grade_level_id AS aktuelle_klassenstufe
FROM children c JOIN classes cl ON cl.id = c.class_id
WHERE c.id = 'aaaaaaaa-1111-1111-1111-111111111111';

-- ---------------------------------------------------------------------------
-- Telefonnummern: höchstens eine Hauptnummer, genau ein Eigentümer
-- ---------------------------------------------------------------------------
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary) VALUES
    ('22222222-2222-2222-2222-222222222222', 1, '07123 1', true),
    ('22222222-2222-2222-2222-222222222222', 2, '0170 2',  false);

\echo '--- erwartet: FEHLER (zweite Hauptnummer derselben Person)'
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary)
    VALUES ('22222222-2222-2222-2222-222222222222', 3, '07123 3', true);

\echo '--- erwartet: FEHLER (Nummer ohne Person und ohne Organisation)'
INSERT INTO phone_numbers (phone_type_id, number) VALUES (1, '07123 4');

-- ---------------------------------------------------------------------------
-- Erziehungsberechtigte: Person ODER Organisation, nie beides
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Person und Organisation gleichzeitig)'
INSERT INTO guardians (person_id, organization_id)
    VALUES ('33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444');

INSERT INTO guardians (id, person_id)
    VALUES ('55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333');
INSERT INTO guardians (id, organization_id)
    VALUES ('66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444');
SELECT 'Erziehungsberechtigte als Person und als Organisation angelegt' AS pruefung;

\echo '--- erwartet: FEHLER (Beruf an einer Organisation)'
UPDATE guardians SET occupation = 'Sachbearbeiter' WHERE id = '66666666-6666-6666-6666-666666666666';

\echo '--- erwartet: FEHLER (Konfession an einer Organisation)'
UPDATE guardians SET denomination_id = 1 WHERE id = '66666666-6666-6666-6666-666666666666';

-- family_guardians.contact_person nur bei Organisation als Guardian (per Trigger,
-- kein CHECK möglich — Organisations-Status steht auf guardians, nicht hier)
INSERT INTO families (id) VALUES ('99999999-1111-1111-1111-111111111111');

\echo '--- erwartet: FEHLER (Sachbearbeiter-Notiz bei natürlicher Person als Guardian)'
INSERT INTO family_guardians (family_id, guardian_id, contact_person) VALUES
    ('99999999-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'Frau Beispiel');

INSERT INTO family_guardians (family_id, guardian_id, contact_person) VALUES
    ('99999999-1111-1111-1111-111111111111', '66666666-6666-6666-6666-666666666666', 'Frau Beispiel');
SELECT 'Sachbearbeiter-Notiz bei Organisation als Guardian erlaubt' AS pruefung;

-- ---------------------------------------------------------------------------
-- Kontakte: Notfallkontakt-Reihenfolge höchstens einmal je Kind belegt
-- ---------------------------------------------------------------------------
INSERT INTO persons (id, last_name) VALUES
    ('eeeeeeee-3333-3333-3333-333333333333', 'Oma'),
    ('ffffffff-3333-3333-3333-333333333333', 'Nachbarin');
INSERT INTO contacts (id) VALUES
    ('eeeeeeee-3333-3333-3333-333333333333'),
    ('ffffffff-3333-3333-3333-333333333333');
INSERT INTO child_contacts (child_id, contact_id, relationship, priority) VALUES
    ('22222222-2222-2222-2222-222222222222', 'eeeeeeee-3333-3333-3333-333333333333', 'Großmutter', 1);

\echo '--- erwartet: FEHLER (Priorität 1 beim selben Kind schon vergeben)'
INSERT INTO child_contacts (child_id, contact_id, relationship, priority) VALUES
    ('22222222-2222-2222-2222-222222222222', 'ffffffff-3333-3333-3333-333333333333', 'Nachbarin', 1);

-- Ohne Priorität weiterhin erlaubt (nicht jede Verknüpfung braucht eine Reihenfolge)
INSERT INTO child_contacts (child_id, contact_id, relationship) VALUES
    ('22222222-2222-2222-2222-222222222222', 'ffffffff-3333-3333-3333-333333333333', 'Nachbarin');
SELECT 'Kontakt ohne Priorität erlaubt' AS pruefung;

-- ---------------------------------------------------------------------------
-- Geteilte Anschrift: ein UPDATE wirkt auf alle, die daran hängen — genau das
-- Verhalten, zu dem die Eingabemaske zurückfragen muss (domains/stammdaten.md)
-- ---------------------------------------------------------------------------
UPDATE addresses SET street = 'Nebenweg 9' WHERE id = '11111111-1111-1111-1111-111111111111';
SELECT 'Personen an der geänderten Anschrift' AS pruefung, count(*) AS anzahl
    FROM persons p JOIN addresses a ON a.id = p.address_id WHERE a.street = 'Nebenweg 9';

-- ---------------------------------------------------------------------------
-- Zahlungsverantwortliche: Person ODER Organisation, höchstens eine/r
-- Hauptzahler:in je Kind, Löschung blockiert wie bei guardians
-- ---------------------------------------------------------------------------
INSERT INTO persons (id, last_name) VALUES ('77777777-7777-7777-7777-777777777777', 'Oma');
INSERT INTO payers (id, person_id) VALUES
    ('88888888-8888-8888-8888-888888888888', '77777777-7777-7777-7777-777777777777');
INSERT INTO payers (id, organization_id) VALUES
    ('99999999-9999-9999-9999-999999999999', '44444444-4444-4444-4444-444444444444');

\echo '--- erwartet: FEHLER (Zahler als Person und Organisation gleichzeitig)'
INSERT INTO payers (person_id, organization_id)
    VALUES ('77777777-7777-7777-7777-777777777777', '44444444-4444-4444-4444-444444444444');

INSERT INTO child_payers (child_id, payer_id, is_primary) VALUES
    ('22222222-2222-2222-2222-222222222222', '88888888-8888-8888-8888-888888888888', true),
    ('22222222-2222-2222-2222-222222222222', '99999999-9999-9999-9999-999999999999', false);

\echo '--- erwartet: FEHLER (zweite/r Hauptzahler:in fürs selbe Kind)'
UPDATE child_payers SET is_primary = true
    WHERE payer_id = '99999999-9999-9999-9999-999999999999';

\echo '--- erwartet: FEHLER (Kind mit bestehender Zahlungsverantwortung nicht mitlöschbar)'
DELETE FROM persons WHERE id = '22222222-2222-2222-2222-222222222222';

-- Zahlungsverantwortung auflösen, bevor unten die reguläre Löschmechanik-Prüfung
-- dieselbe Kind-Person löscht.
DELETE FROM child_payers WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- ---------------------------------------------------------------------------
-- Löschmechanik (domains/stammdaten.md): blockiert, wo die Löschung eine
-- Entscheidung ist — kaskadiert, wo die Zeile kein Eigenleben hat
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Anschrift noch bewohnt)'
DELETE FROM addresses WHERE id = '11111111-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (Person ist Erziehungsberechtigte)'
DELETE FROM persons WHERE id = '33333333-3333-3333-3333-333333333333';

-- Kind löschen = ein Löschbefehl auf die Personenzeile; Rollenzeile und
-- Telefonnummern hängen daran und verschwinden mit.
DELETE FROM persons WHERE id = '22222222-2222-2222-2222-222222222222';
SELECT 'nach Löschung der Kind-Person' AS pruefung,
       (SELECT count(*) FROM children)      AS kinder,
       (SELECT count(*) FROM phone_numbers) AS telefonnummern;
