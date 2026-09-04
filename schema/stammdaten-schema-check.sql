-- Prüfskript zu stammdaten-schema.sql.
--
-- Sollstand: 28 Tabellen — 13 Wertelisten (salutations, genders, denominations,
-- languages, countries, guardian_relations, access_levels, previous_schools,
-- school_branches,
-- houses, roles, phone_types, alumni_kinds), Person und Erreichbarkeit (addresses, persons,
-- phone_numbers),
-- Familie und Kind (families, classes, children, guardians, family_guardians,
-- family_contacts, sepa_mandates), Q4 (employees, employee_roles), die
-- Ehemaligen (alumni) und der
-- Zugang (login_codes, login_sessions); die Klassenlehrkraft steht als Spalte
-- an `classes`.
-- `alumni` steht neben `persons` wie `employees`: eine Zugehoerigkeit, die eine
-- Person zusaetzlich zu ihren anderen traegt — je Person und Art eine Zeile,
-- und ein Jahr genau dort, wo die Art es verlangt.
-- `guardians` trägt die personenweiten Angaben eines Sorgeberechtigten,
-- `family_guardians` daneben allein, was an einer einzelnen Sorgeberechtigung
-- hängt.
-- Dazu zwei partielle bzw.
-- unterstützende Indizes (ix_sepa_mandates_current, ix_login_codes_email_created).
-- `persons.note` trägt, was sich das Sekretariat merkt; `persons.has_note` und
-- `employees.has_note` halten sie von den Mitarbeitenden fern.
--
-- Läuft gegen eine Datenbank, in die stammdaten-schema.sql geladen wurde:
--   psql -v ON_ERROR_STOP=1 -f stammdaten-schema-check.sql
-- Alles läuft in einer Transaktion, die am Ende zurückgerollt wird — die
-- Datenbank bleibt danach leer.

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Existiert jede Tabelle?
-- ---------------------------------------------------------------------------
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(t, ', ') INTO missing
    FROM unnest(ARRAY[
        'salutations', 'genders', 'denominations', 'languages', 'countries',
        'guardian_relations', 'access_levels', 'previous_schools',
        'school_branches', 'houses',
        'roles', 'addresses', 'persons', 'phone_numbers', 'families', 'classes',
        'children', 'guardians', 'family_guardians', 'family_contacts',
        'sepa_mandates',
        'employees', 'employee_roles', 'login_codes', 'login_sessions', 'phone_types',
        'alumni_kinds', 'alumni'
    ]) AS t
    WHERE to_regclass('public.' || t) IS NULL;

    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Tabellen: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle 26 Tabellen vorhanden';
END $$;

-- ---------------------------------------------------------------------------
-- 2. Trägt jedes benannte Constraint seinen Namen?
-- ---------------------------------------------------------------------------
DO $$
DECLARE missing text;
BEGIN
    SELECT string_agg(c, ', ') INTO missing
    FROM unnest(ARRAY[
        'pk_persons', 'pk_children', 'pk_families', 'pk_classes', 'pk_employees',
        'fk_children_family', 'fk_children_class', 'fk_children_branch',
        'fk_employees_house', 'fk_classes_teacher',
        'uq_children_person', 'uq_children_school_email', 'uq_classes_key',
        'uq_classes_id_branch', 'uq_employees_person', 'uq_family_guardians',
        'uq_sepa_mandates_reference',
        'ck_children_enrolment', 'ck_children_exit', 'ck_children_exit_after_entry',
        'ck_children_class_needs_entry', 'ck_children_grade_level',
        'fk_family_guardians_access_level', 'uq_access_levels_code',
        'ck_family_contacts_role',
        'ck_sepa_mandates_holder', 'ck_sepa_mandates_holder_contact',
        'ck_sepa_mandates_bic', 'ck_sepa_mandates_iban',
        'ck_employees_working_days', 'ck_school_branches_grades',
        'pk_alumni_kinds', 'uq_alumni_kinds_code', 'uq_alumni_kinds_exit_year',
        'pk_alumni', 'fk_alumni_person', 'fk_alumni_kind', 'fk_alumni_branch',
        'uq_alumni_person_kind', 'ck_alumni_exit_year', 'ck_alumni_exit_year_range',
        'ck_login_codes_purpose', 'ck_login_codes_attempts',
        'fk_login_codes_person', 'ck_login_codes_person',
        'uq_login_sessions_token_hash', 'fk_login_sessions_person',
        'ck_login_sessions_email',
        'ck_persons_created_by', 'uq_employees_entra',
        'fk_phone_numbers_type', 'ck_children_repeats_needs_entry',
        'uq_school_branches_grades', 'uq_roles_branch_bound',
        'fk_employee_roles_role', 'ck_employee_roles_branch_bound',
        'uq_employee_roles', 'uq_family_contacts',
        'pk_guardians', 'fk_guardians_person', 'uq_guardians_person',
        'fk_guardians_denomination', 'fk_guardians_nationality'
    ]) AS c
    WHERE NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = c);

    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Constraints: %', missing;
    END IF;

    SELECT string_agg(i, ', ') INTO missing
    FROM unnest(ARRAY['ix_sepa_mandates_current', 'ix_login_codes_email_created']) AS i
    WHERE to_regclass('public.' || i) IS NULL;
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'Fehlende Indizes: %', missing;
    END IF;
    RAISE NOTICE 'ok: alle geprüften Constraints und Indizes vorhanden';
END $$;

-- ---------------------------------------------------------------------------
-- 3. Hilfsfunktionen für die Gegenproben
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
-- 4. Stammsätze, gegen die geprüft wird
-- ---------------------------------------------------------------------------
INSERT INTO countries (code, name, nationality_name)
    VALUES ('DE', 'Deutschland', 'deutsch'), ('AT', 'Österreich', 'österreichisch');
INSERT INTO guardian_relations (code, name) VALUES ('mother', 'Mutter');
INSERT INTO access_levels (code, name) VALUES
    ('full', 'voll'), ('read_only', 'nur lesen'), ('blocked', 'gesperrt');
INSERT INTO school_branches (code, name, first_grade_level, final_grade_level, created_by)
    VALUES ('GS', 'Grundschule', 1, 4, 'system:check'),
           ('RS', 'Realschule', 5, 10, 'system:check');
INSERT INTO houses (code, name, created_by) VALUES ('school', 'Schule', 'system:check');
INSERT INTO roles (code, name, is_branch_bound, created_by)
    VALUES ('school_management', 'Schulleitung', true,  'system:check'),
           ('office',            'Sekretariat',  false, 'system:check'),
           ('admin',             'Admin',        false, 'system:check');

INSERT INTO addresses (address_id, street, house_number, postal_code, city, country_id, created_by)
    VALUES ('11111111-1111-1111-1111-111111111111', 'Hauptstr.', '1', '12345', 'Musterstadt',
            (SELECT country_id FROM countries WHERE code = 'DE'), 'system:check');

INSERT INTO persons (person_id, first_name, last_name, email, created_by) VALUES
    ('22222222-2222-2222-2222-222222222221', 'Kind',    'Muster', NULL,             'system:check'),
    ('22222222-2222-2222-2222-222222222222', 'Mutter',  'Muster', 'fam@example.org', 'system:check'),
    ('22222222-2222-2222-2222-222222222223', 'Vater',   'Muster', 'fam@example.org', 'system:check'),
    ('22222222-2222-2222-2222-222222222224', 'Oma',     'Muster', NULL,             'system:check'),
    ('22222222-2222-2222-2222-222222222225', 'Lehrer',  'Muster', NULL,             'system:check'),
    ('22222222-2222-2222-2222-222222222226', 'Lehrerin','Muster', NULL,             'system:check');

INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333', 'system:check');

INSERT INTO classes (school_branch_id, start_school_year, stream, created_by)
    VALUES ((SELECT school_branch_id FROM school_branches WHERE code = 'GS'), 2026, 'a', 'system:check'),
           ((SELECT school_branch_id FROM school_branches WHERE code = 'RS'), 2026, 'a', 'system:check');

INSERT INTO children (child_id, person_id, family_id, birth_date, school_branch_id,
                      first_grade_level, final_grade_level,
                      grade_level, entry_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222221',
            '33333333-3333-3333-3333-333333333333',
            DATE '2020-05-01',
            (SELECT school_branch_id FROM school_branches WHERE code = 'GS'),
            1, 4,
            1, DATE '2026-08-01', 'system:check');

INSERT INTO employees (employee_id, person_id, house_id, created_by)
    VALUES ('55555555-5555-5555-5555-555555555551',
            '22222222-2222-2222-2222-222222222225',
            (SELECT house_id FROM houses WHERE code = 'school'), 'system:check'),
           ('55555555-5555-5555-5555-555555555552',
            '22222222-2222-2222-2222-222222222226',
            (SELECT house_id FROM houses WHERE code = 'school'), 'system:check');

-- ---------------------------------------------------------------------------
-- 5. Gegenproben — je Regel ein abgewiesener INSERT
-- ---------------------------------------------------------------------------

-- 04/08: Schulart und Stufe entstehen mit der Einschreibung und sind ab ihr Pflicht.
SELECT pg_temp.expect_reject(
    '08 — eingeschriebenes Kind ohne Schulart und Stufe',
    $q$INSERT INTO children (person_id, family_id, birth_date, entry_date, created_by)
       VALUES ('22222222-2222-2222-2222-222222222224',
               '33333333-3333-3333-3333-333333333333',
               DATE '2020-01-01', DATE '2026-08-01', 'system:check')$q$);

-- 03: „das Austrittsdatum (Pflicht) und der Grund in einem Satz (Pflicht)".
SELECT pg_temp.expect_reject(
    '03 — Austrittsdatum ohne Grund',
    $q$UPDATE children SET exit_date = DATE '2027-03-01'
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

SELECT pg_temp.expect_reject(
    '03 — Grund ohne Austrittsdatum',
    $q$UPDATE children SET exit_reason = 'Umzug'
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

SELECT pg_temp.expect_reject(
    '03 — Austritt vor Eintritt',
    $q$UPDATE children SET exit_date = DATE '2026-01-01', exit_reason = 'Umzug'
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- 15: „Das Kind ist eingeschrieben … und es gibt eine Klasse, in die es passt."
SELECT pg_temp.expect_reject(
    '15 — Klasse ohne Einschreibung',
    $q$INSERT INTO children (person_id, family_id, birth_date, class_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222224',
               '33333333-3333-3333-3333-333333333333', DATE '2020-01-01',
               (SELECT class_id FROM classes WHERE stream = 'a'
                  AND school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='GS')),
               'system:check')$q$);

-- rules.md 1: der zusammengesetzte Fremdschlüssel bindet Klasse an Schulart.
SELECT pg_temp.expect_reject(
    '15 — Grundschulkind in einer Realschulklasse',
    $q$UPDATE children SET class_id =
         (SELECT class_id FROM classes
           WHERE school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='RS'))
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- 04, Schritt 2: „ein neues Kind genauso wie ein Viertklässler, der in die
-- eigene Realschule wechselt; bei dem ändern sich nur Schulart und Stufe." In
-- dieser Zeile sind es drei Spalten: Der Wechsler sitzt bis zum 31. Juli in
-- einer Grundschulklasse, und `fk_children_class` hält sie an der Schulart
-- fest. Die beiden Proben zeigen den Schritt, den der Lauf deshalb mitmachen
-- muss — er ist maschinell und „niemand kann ihn aufhalten" (04): Bliebe er an
-- dieser Zeile stehen, lägen alle folgenden liegen.
UPDATE children SET grade_level = 4, class_id =
         (SELECT class_id FROM classes
           WHERE school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='GS'))
     WHERE child_id = '44444444-4444-4444-4444-444444444444';
SELECT pg_temp.expect_reject(
    '04 — der Jahreslauf setzt am Wechsler nur Schulart und Stufe',
    $q$UPDATE children
          SET school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='RS'),
              first_grade_level = 5, final_grade_level = 10, grade_level = 5
        WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);
SELECT pg_temp.expect_accept(
    '04 — derselbe Schritt, der die Klassenzuordnung mit der Schulart leert',
    $q$UPDATE children
          SET school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='RS'),
              first_grade_level = 5, final_grade_level = 10, grade_level = 5,
              class_id = NULL
        WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);
-- 15, Schritt 2 kann den Wechsler erst danach in seine Realschulklasse setzen.
SELECT pg_temp.expect_accept(
    '15 — und erst danach steht er in einer Klasse seiner neuen Schulart',
    $q$UPDATE children SET class_id =
         (SELECT class_id FROM classes
           WHERE school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='RS'))
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);
-- Zurück auf den Stand, mit dem die Proben darunter rechnen.
UPDATE children
   SET school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='GS'),
       first_grade_level = 1, final_grade_level = 4, grade_level = 1, class_id = NULL
 WHERE child_id = '44444444-4444-4444-4444-444444444444';

-- 04: „Wer am Ende seiner Schulart steht — Klasse 4, Klasse 10." Die Grenzen
-- stehen an `school_branches` und nicht als Zahl im CHECK; Klasse 9 gibt die
-- Grundschule nicht her, ihre eigene 4 schon.
SELECT pg_temp.expect_reject(
    '04 — Grundschulkind in Klassenstufe 9',
    $q$UPDATE children SET grade_level = 9
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

SELECT pg_temp.expect_accept(
    '04 — Grundschulkind in seiner letzten Stufe',
    $q$UPDATE children SET grade_level = 4
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- Die Grenzen sind an ihre Schulart gebunden: geliehene Grenzen einer anderen
-- gibt es nicht (rules.md Abschnitt 1).
SELECT pg_temp.expect_reject(
    '04 — Grundschulkind mit den Grenzen der Realschule',
    $q$UPDATE children SET first_grade_level = 5, final_grade_level = 10, grade_level = 9
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- MATCH FULL: eine Schulart ohne ihre Grenzen gibt es nicht, sonst liefe der
-- CHECK darüber ins Leere.
SELECT pg_temp.expect_reject(
    '04 — Schulart ohne ihre beiden Stufengrenzen',
    $q$INSERT INTO children (person_id, family_id, birth_date, school_branch_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222224',
               '33333333-3333-3333-3333-333333333333', DATE '2020-01-01',
               (SELECT school_branch_id FROM school_branches WHERE code = 'GS'),
               'system:check')$q$);

SELECT pg_temp.expect_accept(
    '04 — zurück auf Klasse 1',
    $q$UPDATE children SET grade_level = 1
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- 04: „Das Sekretariat trägt bis zum 31. Juli ein, wer seine Stufe wiederholt."
-- Aufrücken tut, „was im endenden Schuljahr schon eingeschrieben war,
-- Wiederholer ausgenommen" — ohne Einschreibung gibt es nichts zu wiederholen.
SELECT pg_temp.expect_reject(
    '04 — Wiederholer ohne Einschreibung',
    $q$INSERT INTO children (person_id, family_id, birth_date,
                             repeats_grade_school_year, created_by)
       VALUES ('22222222-2222-2222-2222-222222222224',
               '33333333-3333-3333-3333-333333333333', DATE '2020-01-01',
               2027, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '04 — Wiederholer für das beginnende Schuljahr',
    $q$UPDATE children SET repeats_grade_school_year = 2027
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

SELECT pg_temp.expect_reject(
    '15 — dieselbe Klassenkennung zweimal',
    $q$INSERT INTO classes (school_branch_id, start_school_year, stream, created_by)
       VALUES ((SELECT school_branch_id FROM school_branches WHERE code='GS'), 2026, 'a', 'system:check')$q$);

-- 13: „Name und Haus (Pflicht)"; eine Person ist höchstens einmal Mitarbeitender.
SELECT pg_temp.expect_reject(
    '13 — Mitarbeitendeneintrag ohne Haus',
    $q$INSERT INTO employees (person_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222224', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '13 — zweiter Mitarbeitendeneintrag zu derselben Person',
    $q$INSERT INTO employees (person_id, house_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222225',
               (SELECT house_id FROM houses WHERE code='school'), 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '13 — letzter Arbeitstag vor dem ersten',
    $q$UPDATE employees SET first_working_day = DATE '2026-08-01',
                            last_working_day  = DATE '2026-07-01'
       WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

-- hebel.md, „Rollen": „Die Schulleitung gibt es zweimal, je Schulform eine …
-- Eine Schulleitung sieht und entscheidet, was zu einem Kind ihrer Schulform
-- gehört … und für die andere Schulform nichts." Das Flag der Rolle entscheidet
-- das, und es entscheidet es in beide Richtungen.
SELECT pg_temp.expect_accept(
    '00 — Schulleitung Grundschule',
    $q$INSERT INTO employee_roles (employee_id, role_id, school_branch_id,
                                   is_branch_bound, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551',
               (SELECT role_id FROM roles WHERE code = 'school_management'),
               (SELECT school_branch_id FROM school_branches WHERE code = 'GS'),
               true, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '00 — dieselbe Person zusätzlich Schulleitung Realschule',
    $q$INSERT INTO employee_roles (employee_id, role_id, school_branch_id,
                                   is_branch_bound, created_by)
       VALUES ('55555555-5555-5555-5555-555555555551',
               (SELECT role_id FROM roles WHERE code = 'school_management'),
               (SELECT school_branch_id FROM school_branches WHERE code = 'RS'),
               true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Schulleitung ohne Schulform, die damit beide sähe',
    $q$INSERT INTO employee_roles (employee_id, role_id, is_branch_bound, created_by)
       VALUES ('55555555-5555-5555-5555-555555555552',
               (SELECT role_id FROM roles WHERE code = 'school_management'),
               true, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Sekretariat an eine Schulform gebunden',
    $q$INSERT INTO employee_roles (employee_id, role_id, school_branch_id,
                                   is_branch_bound, created_by)
       VALUES ('55555555-5555-5555-5555-555555555552',
               (SELECT role_id FROM roles WHERE code = 'office'),
               (SELECT school_branch_id FROM school_branches WHERE code = 'GS'),
               false, 'system:check')$q$);

-- Das mitgeführte Flag ist an seine Rolle gebunden: eine zweigfreie Rolle lässt
-- sich nicht als zweiggebunden ausgeben (rules.md Abschnitt 1).
SELECT pg_temp.expect_reject(
    'hebel.md — Sekretariat mit geliehenem Flag der Schulleitung',
    $q$INSERT INTO employee_roles (employee_id, role_id, school_branch_id,
                                   is_branch_bound, created_by)
       VALUES ('55555555-5555-5555-5555-555555555552',
               (SELECT role_id FROM roles WHERE code = 'office'),
               (SELECT school_branch_id FROM school_branches WHERE code = 'GS'),
               true, 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '00 — Sekretariat ohne Schulform',
    $q$INSERT INTO employee_roles (employee_id, role_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555552',
               (SELECT role_id FROM roles WHERE code = 'office'), 'system:check')$q$);

-- 00: „mehrere je Person möglich" — dieselbe aber nicht zweimal. Ohne NULLS NOT
-- DISTINCT trüge der Schlüssel das für keine der zweigfreien Rollen.
SELECT pg_temp.expect_reject(
    '00 — dieselbe zweigfreie Rolle zweimal an derselben Person',
    $q$INSERT INTO employee_roles (employee_id, role_id, created_by)
       VALUES ('55555555-5555-5555-5555-555555555552',
               (SELECT role_id FROM roles WHERE code = 'office'), 'system:check')$q$);

-- hebel.md, „Rollen": „Die letzte Admin-Rolle lässt sich nicht entziehen, nur
-- übertragen." Die Regel zählt über alle Zeilen und bräuchte einen Trigger, den
-- dieses Schema nirgends kennt; Block 13 zieht dieselbe Grenze für den
-- Nachbarfall („ein Wächter wird dafür nicht gebaut"). Die Gegenprobe hält die
-- Auslassung fest: das Entziehen läuft hier durch und wird von der Anwendung
-- abgewiesen — dieselbe Bauform wie beim bereits gültigen Wert in
-- querschnitt-schema-check.sql.
INSERT INTO employee_roles (employee_id, role_id, created_by)
    VALUES ('55555555-5555-5555-5555-555555555552',
            (SELECT role_id FROM roles WHERE code = 'admin'), 'system:check');
SELECT pg_temp.expect_accept(
    'hebel.md — die letzte Admin-Rolle entzogen (die Sperre trägt die Anwendung)',
    $q$DELETE FROM employee_roles
        WHERE role_id = (SELECT role_id FROM roles WHERE code = 'admin')$q$);


-- 13: die Schuladresse spiegelt den Tenant und gibt es kein zweites Mal.
INSERT INTO children (person_id, family_id, birth_date, school_email, created_by)
    VALUES ('22222222-2222-2222-2222-222222222224',
            '33333333-3333-3333-3333-333333333333', DATE '2019-01-01',
            'kind@schule.de', 'system:check');
SELECT pg_temp.expect_reject(
    '13 — Schuladresse zweimal vergeben',
    $q$UPDATE children SET school_email = 'kind@schule.de'
       WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- hebel.md, Einsichtsstufe: die Stufe ist eine Zeile in `access_levels` und
-- keine Ausprägung im CHECK. Eine, die dort nicht steht, weist der
-- Fremdschlüssel ab.
INSERT INTO family_guardians (family_id, person_id, guardian_relation_id,
                              access_level_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333',
            '22222222-2222-2222-2222-222222222222',
            (SELECT guardian_relation_id FROM guardian_relations WHERE code='mother'),
            (SELECT access_level_id FROM access_levels WHERE code='full'),
            'system:check');
SELECT pg_temp.expect_reject(
    'hebel.md — Einsichtsstufe, die in der Werteliste nicht steht',
    $q$UPDATE family_guardians SET access_level_id = 99
       WHERE person_id = '22222222-2222-2222-2222-222222222222'$q$);

-- 02: „Ein vierter Grad derselben Achse ist ein Wert mehr und die Stelle im
-- Portal, die ihn beachtet." Ein Wert mehr — also eine Zeile, keine Migration.
SELECT pg_temp.expect_accept(
    '02 — ein vierter Grad ist eine Zeile',
    $q$INSERT INTO access_levels (code, name) VALUES ('partial', 'teilweise');
       UPDATE family_guardians SET access_level_id =
           (SELECT access_level_id FROM access_levels WHERE code='partial')
        WHERE person_id = '22222222-2222-2222-2222-222222222222'$q$);
UPDATE family_guardians SET access_level_id =
    (SELECT access_level_id FROM access_levels WHERE code='full')
 WHERE person_id = '22222222-2222-2222-2222-222222222222';
DELETE FROM access_levels WHERE code = 'partial';

-- Die Stufe ist Pflicht: „im Normalfall also für alle Sorgeberechtigten" (02)
-- heißt „voll", nicht „keine Angabe".
SELECT pg_temp.expect_reject(
    'hebel.md — Sorgeberechtigter ohne Einsichtsstufe',
    $q$INSERT INTO family_guardians (family_id, person_id, guardian_relation_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333333',
               '22222222-2222-2222-2222-222222222224',
               (SELECT guardian_relation_id FROM guardian_relations WHERE code='mother'),
               'system:check')$q$);

SELECT pg_temp.expect_reject(
    '05 — dieselbe Person zweimal in derselben Familie sorgeberechtigt',
    $q$INSERT INTO family_guardians (family_id, person_id, guardian_relation_id,
                                     access_level_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333333',
               '22222222-2222-2222-2222-222222222222',
               (SELECT guardian_relation_id FROM guardian_relations WHERE code='mother'),
               (SELECT access_level_id FROM access_levels WHERE code='full'),
               'system:check')$q$);

-- ---------------------------------------------------------------------------
-- Beruf, Konfession und Staatsangehörigkeit hängen am Menschen, nicht an der
-- Sorgeberechtigung. Die drei Gegenproben dazu.
-- ---------------------------------------------------------------------------

-- Die Spalten stehen nicht mehr an `family_guardians` — eine Spalte, die es
-- nicht geben darf, hat keinen anderen Anker als diese Probe.
DO $$
DECLARE stray text;
BEGIN
    SELECT string_agg(column_name, ', ') INTO stray
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'family_guardians'
      AND column_name IN ('occupation', 'denomination_id', 'nationality_country_id');
    IF stray IS NOT NULL THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — personenweite Angabe an der Sorgeberechtigung: %', stray;
    END IF;
    RAISE NOTICE 'ok: Beruf, Konfession und Staatsangehörigkeit stehen nicht an `family_guardians`';
END $$;

-- hebel.md: „Familie heißt die Eltern, nicht der Haushalt." Ein Elternteil mit
-- Kindern aus zwei Beziehungen ist Zeile in zwei Familien — das ist erlaubt.
INSERT INTO families (family_id, created_by)
    VALUES ('33333333-3333-3333-3333-333333333334', 'system:check');
SELECT pg_temp.expect_accept(
    'hebel.md — dieselbe Person ist in zwei Familien sorgeberechtigt',
    $q$INSERT INTO family_guardians (family_id, person_id, guardian_relation_id,
                                     access_level_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333334',
               '22222222-2222-2222-2222-222222222222',
               (SELECT guardian_relation_id FROM guardian_relations WHERE code='mother'),
               (SELECT access_level_id FROM access_levels WHERE code='full'),
               'system:check')$q$);

INSERT INTO guardians (person_id, occupation, nationality_country_id, created_by)
    VALUES ('22222222-2222-2222-2222-222222222222', 'Lehrerin',
            (SELECT country_id FROM countries WHERE code = 'DE'), 'system:check');

-- Und ihr Beruf steht dabei genau einmal: eine zweite Zeile für denselben
-- Menschen wäre der zweite Ort, den `uq_guardians_person` verhindert.
SELECT pg_temp.expect_reject(
    'rules.md 1 — zweite Sorgeberechtigten-Zeile für denselben Menschen',
    $q$INSERT INTO guardians (person_id, occupation, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222', 'Ärztin', 'system:check')$q$);

DO $$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n FROM family_guardians
     WHERE person_id = '22222222-2222-2222-2222-222222222222';
    IF n <> 2 THEN
        RAISE EXCEPTION 'Aufbau falsch — die Person ist in % statt zwei Familien sorgeberechtigt', n;
    END IF;
    SELECT count(*) INTO n FROM guardians
     WHERE person_id = '22222222-2222-2222-2222-222222222222';
    IF n <> 1 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Beruf steht % mal statt einmal', n;
    END IF;
    RAISE NOTICE 'ok: zwei Sorgeberechtigungen, ein Beruf';
END $$;

-- 02: ein Kontakt ist Notfallkontakt, abholberechtigt oder beides — nie keines.
SELECT pg_temp.expect_reject(
    '02 — Kontakt ohne Rolle',
    $q$INSERT INTO family_contacts (family_id, person_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333333',
               '22222222-2222-2222-2222-222222222224', 'system:check')$q$);

-- 02: „An der Familie die Notfallkontakte und Abholberechtigten" — dieselbe
-- Person steht einmal je Familie, sonst hinge dieselbe Nummer an zwei Zeilen.
INSERT INTO family_contacts (family_id, person_id, relationship,
                             is_emergency_contact, created_by)
    VALUES ('33333333-3333-3333-3333-333333333333',
            '22222222-2222-2222-2222-222222222224', 'Oma', true, 'system:check');
SELECT pg_temp.expect_reject(
    '02 — dieselbe Person zweimal als Kontakt derselben Familie',
    $q$INSERT INTO family_contacts (family_id, person_id, relationship,
                                    is_pickup_authorised, created_by)
       VALUES ('33333333-3333-3333-3333-333333333333',
               '22222222-2222-2222-2222-222222222224', 'Oma', true, 'system:check')$q$);

-- 02: „Mindestens eine Mailadresse je Familie ist Pflicht" — das steht bewusst
-- nicht im Schema; die Familie entsteht vor jeder Adresse. Die Gegenprobe hält
-- die Auslassung fest, damit sie beim Bau des Backends nicht übersehen wird.
SELECT pg_temp.expect_accept(
    '02 — Familie ohne jede Mailadresse (die Pflicht trägt die Anwendung)',
    $q$INSERT INTO families (family_id, created_by)
       VALUES ('33333333-3333-3333-3333-333333333339', 'system:check')$q$);

-- 08: SEPA-Mandat.
INSERT INTO sepa_mandates (child_id, account_holder_person_id, iban,
                           credit_institution, mandate_reference, created_by)
    VALUES ('44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            'DE02120300000000202051', 'Musterbank', 'WB-0001', 'system:check');

SELECT pg_temp.expect_reject(
    '08 — zweites gültiges Mandat je Kind',
    $q$INSERT INTO sepa_mandates (child_id, account_holder_person_id,
                                  iban, credit_institution, mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222222',
               'DE02500105170137075030', 'Musterbank', 'WB-0002', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Mandat ohne Kontoinhaber',
    $q$INSERT INTO sepa_mandates (child_id, iban, credit_institution,
                                  mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'DE02500105170137075030',
               'Musterbank', 'WB-0003', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — Mandat mit Person UND abweichendem Namen',
    $q$INSERT INTO sepa_mandates (child_id, account_holder_person_id, account_holder_name,
                                  iban, credit_institution,
                                  mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222222', 'Tante Muster',
               'DE02500105170137075030', 'Musterbank', 'WB-0004', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — nicht-deutsches Konto ohne BIC',
    $q$INSERT INTO sepa_mandates (child_id, account_holder_name, iban,
                                  credit_institution, mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'Tante Muster',
               'AT483200000012345864', 'Musterbank', 'WB-0005', 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '08 — dieselbe Mandatsreferenz zweimal',
    $q$INSERT INTO sepa_mandates (child_id, account_holder_name, iban,
                                  credit_institution, mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'Tante Muster',
               'DE02500105170137075030', 'Musterbank', 'WB-0001', 'system:check')$q$);

-- hebel.md, Anmeldecode: „Er gilt 15 Minuten … Alle Zahlen sind fest und
-- nirgends einstellbar" — eine feste Zahl ist keine Spalte. Der Ablauf folgt
-- aus `created_at`; stünde er zusätzlich als Zeitpunkt da, wäre er der zweite
-- Ort für dieselbe Tatsache (rules.md Abschnitt 1).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'login_codes' AND column_name = 'expires_at') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Ablauf steht neben seiner Ableitung';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): hebel.md — der Ablauf des Codes hat keine eigene Spalte';
END $$;

SELECT pg_temp.expect_accept(
    'hebel.md — Anmeldecode, dessen Ablauf allein aus created_at folgt',
    $q$INSERT INTO login_codes (email, code_hash, purpose)
       VALUES ('a@example.org', 'x', 'login')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Anmeldecode mit unbekanntem Anlass',
    $q$INSERT INTO login_codes (email, code_hash, purpose)
       VALUES ('a@example.org', 'x', 'password_reset')$q$);

SELECT pg_temp.expect_reject(
    'hebel.md — Anmeldecode mit sechster Fehleingabe',
    $q$INSERT INTO login_codes (email, code_hash, purpose, failed_attempts)
       VALUES ('a@example.org', 'x', 'login', 6)$q$);

-- 02: „nur eine neue Mailadresse gilt erst, wenn der Bestätigungscode
-- eingegeben ist", und bis dahin steht in `persons.email` weiter die alte. Die
-- wartende Adresse steht deshalb hier, samt der Person, der sie gehört.
SELECT pg_temp.expect_accept(
    '02 — Bestätigungscode für die neue Adresse einer bekannten Person',
    $q$INSERT INTO login_codes (email, code_hash, purpose, person_id)
       VALUES ('neu@example.org', 'x', 'email_confirmation',
               '22222222-2222-2222-2222-222222222222')$q$);

SELECT pg_temp.expect_reject(
    '02 — Bestätigungscode ohne die Person, deren Adresse er bestätigt',
    $q$INSERT INTO login_codes (email, code_hash, purpose)
       VALUES ('neu@example.org', 'x', 'email_confirmation')$q$);

-- hebel.md: „Das Anmeldefeld antwortet auf jede Adresse gleich und verrät
-- nicht, ob sie hinterlegt ist" — der Anmeldecode kennt seine Person deshalb
-- nicht, und die Familie muss es im Bestand noch gar nicht geben (05, 09, 10).
SELECT pg_temp.expect_reject(
    'hebel.md — Anmeldecode mit einer Person daran',
    $q$INSERT INTO login_codes (email, code_hash, purpose, person_id)
       VALUES ('a@example.org', 'x', 'login',
               '22222222-2222-2222-2222-222222222222')$q$);

-- Löschanker: der Code geht mit der Person, wie Telefonnummer und versandte
-- Mail (Stufe 6 des Lösch-Laufs).
DO $$
DECLARE geblieben bigint;
BEGIN
    INSERT INTO persons (person_id, last_name, created_by)
        VALUES ('22222222-2222-2222-2222-2222222222f1', 'Fluechtig', 'system:check');
    INSERT INTO login_codes (email, code_hash, purpose, person_id)
        VALUES ('fluechtig@example.org', 'x', 'email_confirmation',
                '22222222-2222-2222-2222-2222222222f1');
    DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-2222222222f1';
    SELECT count(*) INTO geblieben FROM login_codes
     WHERE person_id = '22222222-2222-2222-2222-2222222222f1';
    IF geblieben > 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Bestätigungscode überlebt seine Person';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 02 — der Bestätigungscode geht mit seiner Person';
END $$;

-- hebel.md, Anmeldecode: „je Adresse und Stunde gibt es höchstens fünf" — die
-- Zahl steht bewusst nicht im Schema. `ix_login_codes_email_created` stützt nur
-- die Abfrage, die sie zählt; abgewiesen wird die sechste in der Anwendung.
SELECT pg_temp.expect_accept(
    'hebel.md — sechster Code derselben Adresse in derselben Stunde (das Ratelimit zählt die Anwendung)',
    $q$INSERT INTO login_codes (email, code_hash, purpose)
       VALUES ('ratelimit@example.org', 'x', 'login'),
              ('ratelimit@example.org', 'x', 'login'),
              ('ratelimit@example.org', 'x', 'login'),
              ('ratelimit@example.org', 'x', 'login'),
              ('ratelimit@example.org', 'x', 'login'),
              ('ratelimit@example.org', 'x', 'login')$q$);

-- 00: „Die Rollen selbst liest das System bei jedem Aufruf frisch" — die
-- Sitzung trägt deshalb ihre Reichweite nicht mit sich. Stünde sie hier, wäre
-- sie die eingefrorene Kopie einer Tatsache, die woanders gilt.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'login_sessions'
                  AND column_name IN ('families', 'family_id', 'expires_at')) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Sitzung trägt Reichweite oder Ablauf als Spalte';
    END IF;
    RAISE NOTICE 'ok (abgewiesen): 00 — die Sitzung speichert weder Reichweite noch Ablauf';
END $$;

-- hebel.md: „Das Anmeldefeld antwortet auf jede Adresse gleich" — eine Sitzung
-- entsteht deshalb auch für eine Adresse, die hier niemandem gehört; sie liest
-- dann nichts (zugang.md).
SELECT pg_temp.expect_accept(
    'zugang.md — Sitzung einer Adresse, die die Schule nicht kennt',
    $q$INSERT INTO login_sessions (email, token_hash)
       VALUES ('fremd@example.org', 'h1')$q$);

SELECT pg_temp.expect_reject(
    'zugang.md — zwei Sitzungen mit demselben Sitzungswert',
    $q$INSERT INTO login_sessions (email, token_hash)
       VALUES ('a@example.org', 'gleich'), ('b@example.org', 'gleich')$q$);

-- Löschanker: die Sitzung geht mit der Person, wie der Code daneben.
DO $$
DECLARE geblieben bigint;
BEGIN
    INSERT INTO persons (person_id, last_name, created_by)
        VALUES ('22222222-2222-2222-2222-2222222222f2', 'Sitzend', 'system:check');
    INSERT INTO login_sessions (email, token_hash, person_id)
        VALUES ('sitzend@example.org', 'h2', '22222222-2222-2222-2222-2222222222f2');
    DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-2222222222f2';
    SELECT count(*) INTO geblieben FROM login_sessions
     WHERE person_id = '22222222-2222-2222-2222-2222222222f2';
    IF geblieben > 0 THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Sitzung überlebt ihre Person';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 00 — die Sitzung geht mit ihrer Person';
END $$;

-- 15: Schularten haben eine Anfangs- und eine Endstufe, in dieser Reihenfolge.
SELECT pg_temp.expect_reject(
    '15 — Schulart, deren Endstufe vor der Anfangsstufe liegt',
    $q$INSERT INTO school_branches (code, name, first_grade_level, final_grade_level, created_by)
       VALUES ('XX', 'Unsinn', 5, 4, 'system:check')$q$);

-- Änderungsspur: der Urheber trägt eines der drei Präfixe.
SELECT pg_temp.expect_reject(
    'hebel.md — Urheber ohne Präfix',
    $q$INSERT INTO persons (last_name, created_by) VALUES ('Ohne', 'jemand')$q$);

-- 15: „die Klassenlehrkraft (Pflicht)" — genau eine je Klasse, als Spalte.
UPDATE classes SET class_teacher_id = '55555555-5555-5555-5555-555555555551'
 WHERE stream = 'a'
   AND school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='GS');
SELECT pg_temp.expect_reject(
    '15 — Klassenlehrkraft, die kein Mitarbeitender ist',
    $q$UPDATE classes SET class_teacher_id = '55555555-5555-5555-5555-55555555559f'
        WHERE stream = 'a'
          AND school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='GS')$q$);

-- ---------------------------------------------------------------------------
-- 6. Gegenproben in die andere Richtung — was die Blöcke ausdrücklich erlauben
-- ---------------------------------------------------------------------------

-- 05: „Familie, Kind und Sorgeberechtigte entstehen mit der ersten bezahlten
-- Bewerbung" — ein Bewerberkind hat weder Schulart noch Stufe noch Klasse.
SELECT pg_temp.expect_accept(
    '05 — Bewerberkind ohne Einschreibung',
    $q$INSERT INTO children (person_id, family_id, birth_date, created_by)
       VALUES ('22222222-2222-2222-2222-222222222226',
               '33333333-3333-3333-3333-333333333333', DATE '2021-01-01', 'system:check')$q$);

-- 15: Eine Lehrkraft darf zwei Klassen führen — das verbietet kein Block; was
-- die Schule ausgeschlossen hat, sind zwei Lehrkräfte an einer Klasse, und das
-- trägt die Spalte von selbst.
SELECT pg_temp.expect_accept(
    '15 — dieselbe Lehrkraft an zwei Klassen',
    $q$UPDATE classes SET class_teacher_id = '55555555-5555-5555-5555-555555555551'
        WHERE stream = 'a'
          AND school_branch_id = (SELECT school_branch_id FROM school_branches WHERE code='RS')$q$);

-- 05: Bestätigt wird nur die eigene Mailadresse, „die zweite wird übernommen" —
-- die Adresse ist deshalb bewusst nicht UNIQUE. Beide Stammsätze oben tragen
-- bereits dieselbe; hier eine dritte Person mit derselben Adresse.
SELECT pg_temp.expect_accept(
    '05 — dritte Person mit derselben Mailadresse',
    $q$INSERT INTO persons (last_name, email, created_by)
       VALUES ('Muster', 'fam@example.org', 'system:check')$q$);

-- 08: „Das abgelöste Mandat bleibt mit seinem Unterschriftsdatum stehen."
SELECT pg_temp.expect_accept(
    '08 — abgelöstes Mandat neben dem gültigen',
    $q$UPDATE sepa_mandates SET superseded_at = now()
         WHERE mandate_reference = 'WB-0001';
       INSERT INTO sepa_mandates (child_id, account_holder_person_id,
                                  iban, credit_institution, mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222222',
               'DE02500105170137075030', 'Musterbank', 'WB-0006', 'system:check')$q$);

-- 00: „ein Sorgeberechtigter, der zugleich Mitarbeitender ist, ist trotzdem
-- eine Person" — dieselbe `persons`-Zeile trägt beide Rollen.
SELECT pg_temp.expect_accept(
    '00 — dieselbe Person ist Sorgeberechtigte und Mitarbeitende',
    $q$INSERT INTO employees (person_id, house_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222',
               (SELECT house_id FROM houses WHERE code='school'), 'system:check')$q$);

-- grenzkarte.md: „ein Mandat je Kind, aber nicht je Zweck … ein Geschwisterkind
-- über sein eigenes" — dieselbe IBAN steht an zwei Mandaten, die Referenz nicht.
INSERT INTO children (child_id, person_id, family_id, birth_date, created_by)
    VALUES ('44444444-4444-4444-4444-444444444449',
            '22222222-2222-2222-2222-222222222225',
            '33333333-3333-3333-3333-333333333333', DATE '2022-01-01', 'system:check');
SELECT pg_temp.expect_accept(
    '08 — dieselbe IBAN am Mandat des Geschwisterkindes',
    $q$INSERT INTO sepa_mandates (child_id, account_holder_person_id,
                                  iban, credit_institution, mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444449',
               '22222222-2222-2222-2222-222222222222',
               'DE02120300000000202051', 'Musterbank', 'WB-0009',
               'system:check')$q$);

-- 08: „Weicht der Kontoinhaber ab, stehen seine Anschrift und Mailadresse am
-- Mandat und nicht in den Stammdaten." Die Bedingung gilt für alle drei Spalten
-- und nicht nur für den Namen: steht der Inhaber im Bestand, hat er Anschrift
-- und Mailadresse schon an seiner Person (rules.md Abschnitt 1).
UPDATE sepa_mandates SET superseded_at = now() WHERE mandate_reference = 'WB-0006';
SELECT pg_temp.expect_reject(
    '08 — Mandat auf eine Person aus dem Bestand, daneben Anschrift und Mailadresse',
    $q$INSERT INTO sepa_mandates (child_id, account_holder_person_id,
                                  account_holder_address_id, account_holder_email,
                                  iban, credit_institution,
                                  mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444',
               '22222222-2222-2222-2222-222222222222',
               '11111111-1111-1111-1111-111111111111', 'tante@example.org',
               'DE02500105170137075030', 'Musterbank', 'WB-0007', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '08 — abweichender Kontoinhaber mit Anschrift und Mailadresse am Mandat',
    $q$INSERT INTO sepa_mandates (child_id, account_holder_name,
                                  account_holder_address_id, account_holder_email,
                                  iban, credit_institution,
                                  mandate_reference, created_by)
       VALUES ('44444444-4444-4444-4444-444444444444', 'Tante Muster',
               '11111111-1111-1111-1111-111111111111', 'tante@example.org',
               'DE02500105170137075030', 'Musterbank', 'WB-0008', 'system:check')$q$);

-- 02: „mindestens eine tagsüber erreichbare Notfallnummer ist Pflicht" — die
-- Pflicht steht bewusst nicht im Schema (sie greift erst mit dem ersten Vertrag
-- am Kind), die Erreichbarkeit selbst schon. Eine Hauptnummer gibt es nicht:
-- „die Notfallnummer bekommt kein eigenes Feld" (grenzkarte.md).
INSERT INTO phone_types (phone_type_id, code, name) OVERRIDING SYSTEM VALUE
    VALUES (1, 'mobile', 'Mobil'), (2, 'landline', 'Festnetz');
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'phone_numbers'
                  AND column_name IN ('is_primary', 'is_emergency', 'rank')) THEN
        RAISE EXCEPTION 'Es gibt eine Reihenfolge unter den Nummern, die kein Block nennt';
    END IF;
    RAISE NOTICE 'ok: keine Hauptnummer neben `reachable_daytime`';
END $$;

-- 02: „Am Kind die Anschrift (Pflicht)" — die Pflicht steht bewusst nicht im
-- Schema: dieselbe Tabelle trägt Mitarbeitende und Notfallkontakte, für die
-- kein Block eine Anschrift verlangt. Abgewiesen wird sie in der Anwendung.
SELECT pg_temp.expect_accept(
    '02 — Person ohne Anschrift (die Pflicht am Kind trägt die Anwendung)',
    $q$INSERT INTO persons (last_name, created_by)
       VALUES ('Ohne Anschrift', 'system:check')$q$);

SELECT pg_temp.expect_accept(
    '02 — zwei Nummern derselben Person, eine davon tagsüber erreichbar',
    $q$INSERT INTO phone_numbers (person_id, number, phone_type_id, reachable_daytime, created_by)
       VALUES ('22222222-2222-2222-2222-222222222222', '0170 1', 1, true,  'system:check'),
              ('22222222-2222-2222-2222-222222222222', '0711 2', 2, false, 'system:check')$q$);

-- hebel.md, „Zugang und Anmeldecode": „Mitarbeitende nehmen ihr Schulkonto" —
-- die Entra-Kennung ist die Anmeldeidentität und kann nicht an zweien hängen.
SELECT pg_temp.expect_reject(
    '13 — dieselbe Entra-Kennung an zwei Mitarbeitenden',
    $q$UPDATE employees SET entra_object_id = '00000000-0000-0000-0000-0000000000aa'
         WHERE employee_id = '55555555-5555-5555-5555-555555555551';
       UPDATE employees SET entra_object_id = '00000000-0000-0000-0000-0000000000aa'
         WHERE employee_id = '55555555-5555-5555-5555-555555555552'$q$);

-- rules.md Abschnitt 3, Kategoriewerte als Lookup: `is_active = false` nimmt
-- den Wert aus jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf
-- ihn zeigt — so steht es an jeder Werteliste dieser Datei.
SELECT pg_temp.expect_accept(
    'rules.md 3 — Werteliste deaktiviert, die Zeilen darauf bleiben',
    $q$UPDATE guardian_relations SET is_active = false WHERE code = 'mother'$q$);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM family_guardians
                    WHERE person_id = '22222222-2222-2222-2222-222222222222') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — der Altbestand ging mit der Deaktivierung verloren';
    END IF;
    RAISE NOTICE 'ok (erlaubt): rules.md 3 — der Altbestand überlebt die Deaktivierung';
END $$;

-- 15: „Löschanker: keiner eigener, die Zuordnung geht mit dem Mitarbeitenden" —
-- der Fremdschlüssel trägt das jetzt, statt es festzuhalten. Die Klasse bleibt
-- stehen, ihre Lehrkraft-Spalte wird leer.
SELECT pg_temp.expect_accept(
    '15 — die Klassenlehrkraft-Zuordnung geht mit dem Mitarbeitenden',
    $q$DELETE FROM employees WHERE employee_id = '55555555-5555-5555-5555-555555555551'$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM classes
                WHERE class_teacher_id = '55555555-5555-5555-5555-555555555551') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Zuordnung überlebt ihren Mitarbeitenden';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM classes WHERE stream = 'a') THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Klasse geht mit ihrer Lehrkraft';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 15 — keine Zuordnung überlebt ihren Mitarbeitenden, die Klasse bleibt';
END $$;

-- ---------------------------------------------------------------------------
-- 7. Lösch-Lauf
-- ---------------------------------------------------------------------------
-- Die Löschanker dieser Datei an einem Durchlauf gezeigt statt behauptet — wie
-- ihn querschnitt-schema-check.sql für Q1 und Q2 führt. Er ist der Ausschnitt
-- des Laufs aus 17, den diese Domäne allein bedienen kann; die vollständige
-- Reihenfolge über alle Domänen steht in querschnitt-schema.sql und läuft in
-- anmeldung-schema-check.sql.

-- 08: „Löschanker: geht mit dem Kind, aber erst nach der Aufbewahrungsfrist für
-- Zahlungsdaten" — das Mandat hält das Kind fest, bis es selbst fällig ist.
SELECT pg_temp.expect_reject(
    '08 — Kind gelöscht, während sein Mandat noch seine Frist läuft',
    $q$DELETE FROM children WHERE child_id = '44444444-4444-4444-4444-444444444444'$q$);

-- 03: „ab `exit_date` rechnet der Lösch-Lauf, und mit dem Kind geht auch
-- `school_email`" (13).
SELECT pg_temp.expect_accept(
    '03/08 — nach den Mandaten gehen die Kinder',
    $q$DELETE FROM sepa_mandates;
       DELETE FROM children$q$);

-- 03: „erst, wenn die Familie kein Kind mehr an der Schule hat" — Sorgerecht
-- und Kontakte hängen an der Familie und gehen mit ihr.
SELECT pg_temp.expect_accept(
    '03 — nach dem letzten Kind geht die Familie, Sorgerecht und Kontakte mit ihr',
    $q$DELETE FROM families$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM family_guardians) OR EXISTS (SELECT 1 FROM family_contacts) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — Sorgerecht oder Kontakt überlebt seine Familie';
    END IF;
    -- Die Angaben über den Menschen hängen dagegen an der Person und nicht an
    -- der Familie: sie bleiben stehen, bis die Person selbst geht.
    IF NOT EXISTS (SELECT 1 FROM guardians) THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — der Beruf ging mit einer der beiden Familien';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 03 — weder Sorgerecht noch Kontakt überlebt seine Familie, der Beruf bleibt';
END $$;

-- ---------------------------------------------------------------------------
-- Die Notiz an der Person — und die Grenze, an der sie endet
-- ---------------------------------------------------------------------------
-- TASK-220: „Keine Notiz an einer Person mit `employees`-Zeile", weil sie dort
-- ein Stück Personalakte wäre. Getragen wird das vom Paar
-- (`persons.has_note`, `employees.has_note`) und nicht von einer Konvention.

INSERT INTO persons (person_id, first_name, last_name, created_by)
    VALUES ('22222222-2222-2222-2222-222222222229', 'Ohne', 'Konto', 'system:check');

SELECT pg_temp.expect_accept(
    'TASK-220 — Notiz an einer Person ohne Mitarbeitendeneintrag',
    $q$UPDATE persons SET note = 'Holt mittwochs die Oma ab'
        WHERE person_id = '22222222-2222-2222-2222-222222222229'$q$);

SELECT pg_temp.expect_reject(
    'TASK-220 — leere Notiz',
    $q$UPDATE persons SET note = ''
        WHERE person_id = '22222222-2222-2222-2222-222222222229'$q$);

SELECT pg_temp.expect_reject(
    'TASK-220 — Notiz an einer Person, die Mitarbeitende ist',
    $q$UPDATE persons SET note = 'kommt oft zu spät'
        WHERE person_id = '22222222-2222-2222-2222-222222222226'$q$);

-- Und andersherum: Wer eine Notiz trägt, bekommt keinen
-- Mitarbeitendeneintrag, solange sie steht.
SELECT pg_temp.expect_reject(
    'TASK-220 — Mitarbeitendeneintrag für eine Person mit Notiz',
    $q$INSERT INTO employees (person_id, house_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222229',
               (SELECT house_id FROM houses WHERE code = 'school'), 'system:check')$q$);

SELECT pg_temp.expect_accept(
    'TASK-220 — die Notiz gestrichen, dann geht der Mitarbeitendeneintrag',
    $q$UPDATE persons SET note = NULL
        WHERE person_id = '22222222-2222-2222-2222-222222222229';
       INSERT INTO employees (person_id, house_id, created_by)
       VALUES ('22222222-2222-2222-2222-222222222229',
               (SELECT house_id FROM houses WHERE code = 'school'), 'system:check')$q$);


-- 13: „Löschanker: `last_working_day` — ab ihm rechnet der Lösch-Lauf" — die
-- Person geht deshalb nicht vor ihrem Mitarbeitendeneintrag.
SELECT pg_temp.expect_reject(
    '13 — Person gelöscht, während ihr Mitarbeitendeneintrag noch steht',
    $q$DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222226'$q$);

-- ---------------------------------------------------------------------------
-- Die Ehemaligen: eine Zugehörigkeit neben der Person, nicht ihr Rest
-- ---------------------------------------------------------------------------
INSERT INTO alumni_kinds (code, name, requires_exit_year, created_by) VALUES
    ('former_pupil',    'Ehemaliges Kind',         true,  'system:check'),
    ('former_guardian', 'Ehemaliges Elternteil',   false, 'system:check'),
    ('former_employee', 'Ehemalige:r Mitarbeitende:r', true, 'system:check');
INSERT INTO persons (person_id, first_name, last_name, created_by) VALUES
    ('88888888-8888-8888-8888-888888888881', 'Rueck', 'Kehrer', 'system:check'),
    ('88888888-8888-8888-8888-888888888882', 'Ehe', 'Maligeltern', 'system:check');

-- Das ehemalige Kind traegt Jahr und Zweig: „Realschule 2026" und nicht „2026".
SELECT pg_temp.expect_accept(
    '00 — das ehemalige Kind mit Jahrgang und Zweig',
    $q$INSERT INTO alumni (person_id, alumni_kind_id, requires_exit_year,
                           exit_year, school_branch_id, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               (SELECT alumni_kind_id FROM alumni_kinds WHERE code='former_pupil'),
               true, 2010,
               (SELECT school_branch_id FROM school_branches WHERE code='GS'),
               'system:check')$q$);

-- „Eltern brauchen keinen Jahrgang": ihr letztes Kind ging in einem Jahr, ein
-- frueheres vielleicht vier Jahre davor.
SELECT pg_temp.expect_accept(
    '00 — das ehemalige Elternteil ohne Jahrgang',
    $q$INSERT INTO alumni (person_id, alumni_kind_id, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               (SELECT alumni_kind_id FROM alumni_kinds WHERE code='former_guardian'),
               'system:check')$q$);

-- Wo die Art ein Jahr verlangt, steht eines — sonst waere requires_exit_year
-- eine Absichtserklaerung.
SELECT pg_temp.expect_reject(
    '00 — ehemaliges Kind ohne Jahrgang',
    $q$INSERT INTO alumni (person_id, alumni_kind_id, requires_exit_year, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               (SELECT alumni_kind_id FROM alumni_kinds WHERE code='former_pupil'),
               true, 'system:check')$q$);

-- Und das mitgefuehrte Flag muss zu seiner Art passen.
SELECT pg_temp.expect_reject(
    '00 — Art und mitgefuehrtes Jahrgangs-Flag widersprechen sich',
    $q$INSERT INTO alumni (person_id, alumni_kind_id, requires_exit_year,
                           exit_year, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               (SELECT alumni_kind_id FROM alumni_kinds WHERE code='former_guardian'),
               true, 2010, 'system:check')$q$);

SELECT pg_temp.expect_reject(
    '00 — ein Jahrgang, der ein Zahlendreher ist',
    $q$INSERT INTO alumni (person_id, alumni_kind_id, requires_exit_year,
                           exit_year, created_by)
       VALUES ('88888888-8888-8888-8888-888888888882',
               (SELECT alumni_kind_id FROM alumni_kinds WHERE code='former_employee'),
               true, 1899, 'system:check')$q$);

-- Dieselbe Art zweimal an derselben Person waere zwei Antworten auf eine Frage.
SELECT pg_temp.expect_reject(
    '00 — dieselbe Person zweimal in derselben Art',
    $q$INSERT INTO alumni (person_id, alumni_kind_id, requires_exit_year,
                           exit_year, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               (SELECT alumni_kind_id FROM alumni_kinds WHERE code='former_pupil'),
               true, 2011, 'system:check')$q$);

-- Zwei Arten dagegen sind zwei Zugehoerigkeiten: Wer als Kind ging und Jahre
-- spaeter als Mitarbeitende ausschied, steht zweimal da — mit zwei Jahren, die
-- beide stimmen.
SELECT pg_temp.expect_accept(
    '00 — dieselbe Person als ehemaliges Kind und als ehemalige Mitarbeitende',
    $q$INSERT INTO alumni (person_id, alumni_kind_id, requires_exit_year,
                           exit_year, created_by)
       VALUES ('88888888-8888-8888-8888-888888888881',
               (SELECT alumni_kind_id FROM alumni_kinds WHERE code='former_employee'),
               true, 2024, 'system:check')$q$);

-- Der Kern des Ganzen: Die Zugehoerigkeit haelt ihre Person fest. Ein
-- Ehemaliger im Verteiler ist kein Rest, sondern ein Empfaenger.
SELECT pg_temp.expect_reject(
    '17 — die Person mit einer Alumni-Zeile laesst sich nicht loeschen',
    $q$DELETE FROM persons WHERE person_id = '88888888-8888-8888-8888-888888888881'$q$);

-- Stufe 6 raeumt sie deshalb selbst, vor der Person — die Zugehoerigkeit
-- besteht, weil jemand zugestimmt hat, und ist ohne die Zustimmung
-- gegenstandslos.
DELETE FROM alumni;
SELECT pg_temp.expect_accept(
    '17 — nach der Alumni-Zeile geht die Person',
    $q$DELETE FROM persons WHERE person_id = '88888888-8888-8888-8888-888888888881'$q$);

-- 02: „Löschanker: geht mit der Person" — die Nummern gehen mit ihr.
SELECT pg_temp.expect_accept(
    '02/13 — nach dem Mitarbeitendeneintrag gehen die Personen, die Nummern mit ihnen',
    $q$DELETE FROM employees;
       DELETE FROM persons$q$);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM phone_numbers) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Telefonnummer überlebt ihre Person';
    END IF;
    IF EXISTS (SELECT 1 FROM guardians) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — die Sorgeberechtigten-Angaben überleben ihre Person';
    END IF;
    IF EXISTS (SELECT 1 FROM employee_roles) THEN
        RAISE EXCEPTION 'REGEL NICHT GEBAUT — eine Rolle überlebt ihren Mitarbeitendeneintrag';
    END IF;
    -- „die Klassen vergangener Schuljahre bleiben als Kennung stehen": die
    -- Klasse hat keinen Löschanker und überlebt Kind wie Lehrkraft.
    IF NOT EXISTS (SELECT 1 FROM classes) THEN
        RAISE EXCEPTION 'ZU VIEL GELÖSCHT — die Klasse ging mit ihren Kindern';
    END IF;
    RAISE NOTICE 'ok (erlaubt): 02/13 — nichts Personenbezogenes überlebt seinen Anker, die Klasse bleibt';
END $$;

DO $$ BEGIN RAISE NOTICE 'stammdaten-schema-check: alle Gegenproben bestanden'; END $$;

ROLLBACK;
