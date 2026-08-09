-- Prüfskript zu domains/stammdaten-schema.sql — belegt, dass die Zusagen aus
-- domains/stammdaten.md nicht nur Prosa sind, sondern in der Datenbank gelten.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
--   podman cp domains/stammdaten-schema.sql       pg:/tmp/schema.sql
--   podman cp domains/stammdaten-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/schema.sql
--   podman exec pg sh -c 'psql -U postgres -f /tmp/check.sql 2>&1'
--   podman rm -f pg
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt, sonst
-- bricht das Skript beim ersten erwarteten Fehler ab.
--
-- Fallstricke beim Auswerten:
--   * Pro Lauf eine frische Datenbank. Ein zweiter Lauf gegen dieselbe DB
--     erzeugt Folgefehler, die wie Befunde aussehen.
--   * stdout und stderr im Container zusammenführen — das `sh -c '… 2>&1'`
--     oben. Sonst reordert podman die beiden Ströme und die Paarung
--     Ankündigung/ERROR sieht wie ein Befund aus.
--   * Sollstand: 53 Ankündigungen zu 53 ERROR-Zeilen. Verankert zählen, und auf
--     der AUSGABE statt auf dieser Datei — deren Kopfkommentar enthält die
--     Zeichenkette selbst und verfälscht die Zahl:
--       grep -cE '^--- erwartet: FEHLER'  gegen  grep -cE '^psql:.*: ERROR:'
--     Zusätzlich prüfen, dass jeder Ankündigung ein ERROR folgt — unmittelbar,
--     außer bei den beiden app.actor-Fällen: dort steht erst das BEGIN ihrer
--     Transaktion dazwischen.
--   * Jede Berührung dieser Datei oder des Schemas so validieren, auch bei
--     reinen Kommentaränderungen. Ändern sich Spalten, muss zusätzlich
--     domains/stammdaten-benchmark/generate.sql mit n_children=500 durchlaufen
--     und exakt die Zeilenzahlen aus domains/stammdaten-schema-benchmark.md
--     (Durchlauf 1) liefern, sonst sind die dokumentierten Messwerte hinfällig.

-- ---------------------------------------------------------------------------
-- Ausgangsdaten
-- ---------------------------------------------------------------------------
BEGIN;
SET LOCAL app.actor = 'system:test';
INSERT INTO school_branches (school_branch_id, label) VALUES (1, 'Grundschule'), (2, 'Realschule');
INSERT INTO grade_levels (grade_level_id, school_branch_id, label, sort_order, is_final_grade)
    VALUES (4, 1, '4', 4, true), (5, 2, '5', 5, false), (6, 2, '6', 6, false);
INSERT INTO classes (class_id, school_branch_id, grade_level_id, entry_year, stream) VALUES
    (40, 1, 4, 2022, 'a'),
    (50, 2, 5, 2025, 'a');
INSERT INTO phone_types (phone_type_id, label) VALUES (1, 'Festnetz'), (2, 'Mobil'), (3, 'Arbeit');
INSERT INTO denominations (denomination_id, label) VALUES (1, 'evangelisch');
INSERT INTO countries (country_id, label, code) VALUES (1, 'Deutschland', 'DEU'), (2, 'Türkei', 'TUR');
INSERT INTO genders (gender_id, label, code) VALUES (1, 'weiblich', 'w'), (2, 'divers', 'd');
INSERT INTO addresses (address_id, street, city, country_id)
    VALUES ('11111111-1111-1111-1111-111111111111', 'Hauptstr. 1', 'Musterdorf', 1);
-- Kind und Elternteil unter derselben Anschrift
INSERT INTO persons (person_id, last_name, address_id) VALUES
    ('22222222-2222-2222-2222-222222222222', 'Müller', '11111111-1111-1111-1111-111111111111'),
    ('33333333-3333-3333-3333-333333333333', 'Müller', '11111111-1111-1111-1111-111111111111');
INSERT INTO children (child_id, date_of_birth, class_id)
    VALUES ('22222222-2222-2222-2222-222222222222', '2016-05-01', 40);
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
    FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222222';

BEGIN;
SET LOCAL app.actor = 'guardian:abc';
UPDATE persons SET first_name = 'Anna' WHERE person_id = '22222222-2222-2222-2222-222222222222';
COMMIT;
SELECT 'audit nach UPDATE' AS pruefung, created_by, updated_by, (updated_at > created_at) AS zeitstempel_neu
    FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (kein app.actor gesetzt — RESET simuliert eine Transaktion, die SET LOCAL vergisst)'
BEGIN;
RESET app.actor;
UPDATE persons SET first_name = 'Anna2' WHERE person_id = '22222222-2222-2222-2222-222222222222';
ROLLBACK;
SET app.actor = 'system:test';

-- Präfixprüfung: die nackte Entra-Object-ID ohne "entra:" ist der Fall, den das
-- vereinheitlichte Format verhindern soll (Begründung im Schema-Kopfkommentar).
\echo '--- erwartet: FEHLER (app.actor ohne bekanntes Präfix — nackte Entra-Object-ID)'
BEGIN;
SET LOCAL app.actor = '00000000-1111-2222-3333-444444444444';
UPDATE persons SET first_name = 'Anna3' WHERE person_id = '22222222-2222-2222-2222-222222222222';
ROLLBACK;
SET app.actor = 'system:test';

BEGIN;
SET LOCAL app.actor = 'entra:00000000-1111-2222-3333-444444444444';
UPDATE persons SET first_name = 'Anna4' WHERE person_id = '22222222-2222-2222-2222-222222222222';
COMMIT;
SELECT 'app.actor mit entra:-Präfix akzeptiert' AS pruefung, updated_by
    FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222222';
SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- E-Mail ist bewusst NICHT UNIQUE: zwei Erziehungsberechtigte dürfen sich eine
-- Mailbox teilen (Begründung am Feld). Der citext-Vergleich bleibt dabei
-- case-insensitiv, damit die OTP-Prüfung (idea/04) auch die andere
-- Schreibweise findet — und dann eben mehrere Personen liefert.
-- ---------------------------------------------------------------------------
INSERT INTO persons (person_id, last_name, email) VALUES
    ('bbbbbbbb-2222-2222-2222-222222222222', 'Beispiel', 'Vorname.Nachname@Beispiel.de');
SELECT 'citext-Lookup case-insensitiv' AS pruefung, count(*) AS anzahl
    FROM persons WHERE email = 'VORNAME.NACHNAME@BEISPIEL.DE';  -- andere Schreibweise, muss trotzdem finden

-- Muss durchlaufen: geteilte Mailbox zweier Erziehungsberechtigter, hier
-- zusätzlich in abweichender Schreibweise.
INSERT INTO persons (person_id, last_name, email) VALUES
    ('cccccccc-2222-2222-2222-222222222222', 'Beispiel2', 'vorname.nachname@beispiel.de');
SELECT 'geteilte Mailbox: OTP-Treffer liefert mehrere Personen' AS pruefung, count(*) AS anzahl
    FROM persons WHERE email = 'vorname.nachname@beispiel.de';  -- erwartet: 2

\echo '--- erwartet: FEHLER (Leerstring statt NULL bei E-Mail)'
INSERT INTO persons (person_id, last_name, email) VALUES ('dddddddd-2222-2222-2222-222222222222', 'Leer', '');

-- E-Mail-Struktur: genau ein @, kein Leerzeichen, Punkt in der Domain. Fängt die
-- realen Import-Artefakte, ohne eine RFC-5322-Volltextregex zu behaupten.
\echo '--- erwartet: FEHLER (Platzhaltertext statt E-Mail)'
INSERT INTO persons (person_id, last_name, email) VALUES ('d1d1d1d1-2222-2222-2222-222222222222', 'Platzhalter', 'unbekannt');

\echo '--- erwartet: FEHLER (Anzeigename mit Leerzeichen mitkopiert)'
INSERT INTO persons (person_id, last_name, email) VALUES ('d2d2d2d2-2222-2222-2222-222222222222', 'Anzeigename', 'Anna Müller <anna@beispiel.de>');

\echo '--- erwartet: FEHLER (zwei @ in einer Adresse)'
INSERT INTO persons (person_id, last_name, email) VALUES ('d3d3d3d3-2222-2222-2222-222222222222', 'DoppelAt', 'a@b@beispiel.de');

\echo '--- erwartet: FEHLER (Domain ohne Punkt)'
INSERT INTO persons (person_id, last_name, email) VALUES ('d4d4d4d4-2222-2222-2222-222222222222', 'KeinPunkt', 'anna@intranet');

-- Gültige Sonderformen, die eine zu strenge Regex fälschlich abwiese
INSERT INTO persons (person_id, last_name, email) VALUES
    ('d5d5d5d5-2222-2222-2222-222222222222', 'PlusTag',  'anna+schule@beispiel.co.uk'),
    ('d6d6d6d6-2222-2222-2222-222222222222', 'Apostroph', 'o''brien.anne-marie@sub.beispiel.de');
SELECT 'E-Mail: Plus-Tag, mehrstufige Domain, Apostroph/Bindestrich akzeptiert' AS pruefung;

-- ---------------------------------------------------------------------------
-- Leerstring auf den identitätstragenden Pflichtspalten: NOT NULL allein lässt
-- ihn durch, beim Vollimport aus CSV/Excel ist er der häufigste Artefakt
-- (Begründung an persons.last_name)
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Person ohne Nachnamen, Leerstring statt NULL)'
INSERT INTO persons (person_id, last_name) VALUES ('e1e1e1e1-2222-2222-2222-222222222222', '');

\echo '--- erwartet: FEHLER (Telefonzeile ohne Nummer)'
INSERT INTO phone_numbers (person_id, phone_type_id, number)
    VALUES ('33333333-3333-3333-3333-333333333333', 1, '');

\echo '--- erwartet: FEHLER (Klasse ohne Zug — Kohorten-Kennung wäre mehrdeutig)'
INSERT INTO classes (school_branch_id, grade_level_id, entry_year, stream) VALUES (2, 5, 2027, '');

-- ---------------------------------------------------------------------------
-- Höchstens eine Abschlussklasse je Zweig — is_final_grade steuert die
-- Putzdienst-Abgangsregel (domains/putzdienst.md), eine zweite gesetzte Zeile
-- desselben Zweigs bliebe sonst unbemerkt
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (zweite Abschlussklasse in der Grundschule)'
INSERT INTO grade_levels (school_branch_id, label, sort_order, is_final_grade) VALUES (1, '3', 3, true);

-- Der jeweils erste Eintrag je Zweig bleibt erlaubt (Realschule hat noch keinen)
INSERT INTO grade_levels (grade_level_id, school_branch_id, label, sort_order, is_final_grade) VALUES (10, 2, '10', 10, true);
SELECT 'erste Abschlussklasse je Zweig erlaubt' AS pruefung;

-- ---------------------------------------------------------------------------
-- Klassenstufe und Klasse am Kind schließen sich gegenseitig aus — keine
-- gekoppelte Kopie, keine Redundanz
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (class_id gesetzt UND provisional_grade_level_id gesetzt)'
UPDATE children SET provisional_grade_level_id = 4 WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- ---------------------------------------------------------------------------
-- Übrige Plausibilitätsregeln am Kind
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (zweite Staatsangehörigkeit ohne erste)'
UPDATE children SET second_nationality_id = 2 WHERE child_id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (zweimal derselbe Staat — doppelt gemappte Importspalte)'
UPDATE children SET nationality_id = 1, second_nationality_id = 1
    WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- Zwei verschiedene Staaten bleiben erlaubt
UPDATE children SET nationality_id = 1, second_nationality_id = 2
    WHERE child_id = '22222222-2222-2222-2222-222222222222';
SELECT 'doppelte Staatsangehörigkeit mit zwei verschiedenen Staaten erlaubt' AS pruefung;

-- Land kommt aus der Lookup-Tabelle, nicht aus einem Regex: ein nicht gepflegter
-- Wert ist damit gar nicht eintragbar. Der Code ist ISO 3166-1 alpha-3 — das aus
-- Domainnamen vertraute alpha-2 fällt bewusst durch, sonst stünden "DE" und
-- "DEU" nebeneinander für dasselbe Land.
\echo '--- erwartet: FEHLER (unbekanntes Land an der Anschrift)'
UPDATE addresses SET country_id = 999 WHERE address_id = '11111111-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (alpha-2 statt alpha-3 als Ländercode)'
INSERT INTO countries (label, code) VALUES ('Vereinigtes Königreich', 'GB');

\echo '--- erwartet: FEHLER (Bezeichnung statt Schlüssel in genders.code)'
INSERT INTO genders (label, code) VALUES ('männlich', 'männlich');

-- Sprachcode ebenso: BCP-47-Grundform, kanonisch kleingeschriebenes
-- Primär-Subtag — sonst stünden "de" und "DE" als zwei Zeilen für dieselbe
-- Sprache nebeneinander, und genau das soll die code-Spalte verhindern.
INSERT INTO languages (label, code) VALUES
    ('Deutsch', 'de'), ('Türkisch', 'tr'), ('Deutsch (Österreich)', 'de-AT'),
    ('Chinesisch (traditionell)', 'zh-Hant'), ('Spanisch (Lateinamerika)', 'es-419');
SELECT 'BCP-47: de, tr, de-AT, zh-Hant, es-419 akzeptiert' AS pruefung;

\echo '--- erwartet: FEHLER (Sprachname statt BCP-47-Code)'
INSERT INTO languages (label, code) VALUES ('Deutsch (falsch)', 'deutsch');

\echo '--- erwartet: FEHLER (englischer Sprachname statt Code)'
INSERT INTO languages (label, code) VALUES ('German', 'German');

\echo '--- erwartet: FEHLER (Primär-Subtag großgeschrieben, nicht kanonisch)'
INSERT INTO languages (label, code) VALUES ('Deutsch (Großschreibung)', 'DE');

\echo '--- erwartet: FEHLER (Abgang vor Eintritt)'
UPDATE children SET entry_date = '2024-09-01', exit_date = '2024-08-01'
    WHERE child_id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (Einwilligung ohne abgebende Schule)'
UPDATE children SET previous_school_consent_at = now() WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- Umgekehrt erlaubt: Klassenstufe steht fest, Klasse noch nicht zugeteilt
UPDATE children SET class_id = NULL WHERE child_id = '22222222-2222-2222-2222-222222222222';
UPDATE children SET provisional_grade_level_id = 4 WHERE child_id = '22222222-2222-2222-2222-222222222222';
SELECT 'Klassenstufe ohne Klasse erlaubt' AS pruefung;

-- Für die folgenden Tests wieder zuteilen (provisional_grade_level_id muss dafür weichen)
UPDATE children SET provisional_grade_level_id = NULL WHERE child_id = '22222222-2222-2222-2222-222222222222';
UPDATE children SET class_id = 40 WHERE child_id = '22222222-2222-2222-2222-222222222222';

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

-- classes.grade_level_id hat keinen eigenen einspaltigen Fremdschlüssel
-- (Tabellenkommentar): der zusammengesetzte sperrt die Löschung trotzdem.
\echo '--- erwartet: FEHLER (Klassenstufe mit bestehender Klasse nicht löschbar)'
DELETE FROM grade_levels WHERE grade_level_id = 4;

-- Ein zweites Kind wirklich an Klasse 50 hängen, damit der Jahreslauf unten
-- nicht nur eine leere Zeile verschiebt.
INSERT INTO persons (person_id, last_name) VALUES ('aaaaaaaa-1111-1111-1111-111111111111', 'Schmidt');
INSERT INTO children (child_id, date_of_birth, class_id)
    VALUES ('aaaaaaaa-1111-1111-1111-111111111111', '2015-03-01', 50);

-- Jahreslauf für die fortbestehende Kohorte Realschule/2025/a: dieselbe
-- Klassenzeile (class_id 50) rückt eine Klassenstufe vor, kein Kind wird angefasst.
UPDATE classes SET grade_level_id = 6 WHERE class_id = 50;
SELECT 'Kohorte nach Jahreslauf, class_id des Kindes unverändert' AS pruefung,
       c.class_id, cl.grade_level_id AS aktuelle_klassenstufe
FROM children c JOIN classes cl ON cl.class_id = c.class_id
WHERE c.child_id = 'aaaaaaaa-1111-1111-1111-111111111111';

-- ---------------------------------------------------------------------------
-- Telefonnummern: höchstens eine Hauptnummer, genau ein Eigentümer, dieselbe
-- Nummer nur einmal je Eigentümer
-- ---------------------------------------------------------------------------
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary) VALUES
    ('22222222-2222-2222-2222-222222222222', 1, '07123 1', true),
    ('22222222-2222-2222-2222-222222222222', 2, '0170 2',  false);

\echo '--- erwartet: FEHLER (zweite Hauptnummer derselben Person)'
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary)
    VALUES ('22222222-2222-2222-2222-222222222222', 3, '07123 3', true);

\echo '--- erwartet: FEHLER (Nummer ohne Person)'
INSERT INTO phone_numbers (phone_type_id, number) VALUES (1, '07123 4');

\echo '--- erwartet: FEHLER (dieselbe Nummer nochmals an derselben Person, nur mit anderem Typ)'
INSERT INTO phone_numbers (person_id, phone_type_id, number)
    VALUES ('22222222-2222-2222-2222-222222222222', 3, '07123 1');

-- Muss durchlaufen: dieselbe Nummer bei einer ANDEREN Person (Festnetz eines
-- Haushalts) — die Eindeutigkeit gilt je Person, nicht global.
INSERT INTO phone_numbers (person_id, phone_type_id, number)
    VALUES ('33333333-3333-3333-3333-333333333333', 1, '07123 1');
SELECT 'dieselbe Nummer bei anderer Person akzeptiert' AS pruefung, count(*) AS anzahl
    FROM phone_numbers WHERE number = '07123 1';  -- erwartet: 2

-- ---------------------------------------------------------------------------
-- Erziehungsberechtigte: IST eine Person, teilt sich den Schlüssel mit persons.
-- Es gibt keine Organisation als Erziehungsberechtigte — auch eine Amtsvormundin
-- ist eine ganz normale Person (domains/stammdaten.md, „Familie").
-- ---------------------------------------------------------------------------
INSERT INTO guardians (guardian_id, occupation)
    VALUES ('33333333-3333-3333-3333-333333333333', 'Erzieherin');

\echo '--- erwartet: FEHLER (Erziehungsberechtigte ohne Personenzeile)'
INSERT INTO guardians (guardian_id) VALUES ('55555555-5555-5555-5555-555555555555');

\echo '--- erwartet: FEHLER (dieselbe Person zweimal als Erziehungsberechtigte)'
INSERT INTO guardians (guardian_id) VALUES ('33333333-3333-3333-3333-333333333333');

-- Die Sachbearbeiterin des Jugendamts: eine Person wie jede andere, mit eigener
-- Durchwahl und Dienstadresse — genau das, was ein Namensstring nicht könnte.
INSERT INTO persons (person_id, first_name, last_name, email)
    VALUES ('66666666-6666-6666-6666-666666666666', 'Sabine', 'Meier', 's.meier@jugendamt.example');
INSERT INTO guardians (guardian_id) VALUES ('66666666-6666-6666-6666-666666666666');
INSERT INTO phone_numbers (person_id, phone_type_id, number, is_primary, note)
    VALUES ('66666666-6666-6666-6666-666666666666', 3, '+4971120', true, 'Durchwahl');
SELECT 'Amtsvormundin als Person mit Durchwahl' AS pruefung, p.last_name, ph.number
    FROM guardians g JOIN persons p ON p.person_id = g.guardian_id
    JOIN phone_numbers ph ON ph.person_id = p.person_id
    WHERE g.guardian_id = '66666666-6666-6666-6666-666666666666';

-- Die Befreiung von der Elternmitarbeit hängt an der Kategorie, nicht daran,
-- dass jemand keine natürliche Person ist (domains/putzdienst.md).
INSERT INTO guardian_categories (guardian_category_id, label, exempt_from_parent_duties)
    VALUES (1, 'Mutter', false), (2, 'Jugendamt', true);
SELECT 'Kategorie trägt die Putzdienst-Befreiung' AS pruefung, label, exempt_from_parent_duties
    FROM guardian_categories ORDER BY guardian_category_id;

-- ---------------------------------------------------------------------------
-- Mitarbeiter: Rolle auf persons, eigene Dienstadresse (UNIQUE, anders als
-- persons.email), Beschäftigungszeitraum trägt die Putzdienst-Befreiung
-- ---------------------------------------------------------------------------
INSERT INTO persons (person_id, last_name) VALUES ('7e7e7e7e-1111-1111-1111-111111111111', 'Lehrkraft');
INSERT INTO employees (employee_id, work_email, entra_object_id, employment_start)
    VALUES ('7e7e7e7e-1111-1111-1111-111111111111', 'a.lehrkraft@clemens.schule',
            '00000000-aaaa-bbbb-cccc-000000000001', '2020-09-01');
SELECT 'Mitarbeiter angelegt, private und dienstliche Adresse getrennt' AS pruefung,
       (SELECT email FROM persons WHERE person_id = '7e7e7e7e-1111-1111-1111-111111111111') AS privat,
       (SELECT work_email FROM employees WHERE employee_id = '7e7e7e7e-1111-1111-1111-111111111111') AS dienstlich;

INSERT INTO persons (person_id, last_name) VALUES ('7e7e7e7e-2222-2222-2222-222222222222', 'Zweitkraft');

\echo '--- erwartet: FEHLER (Dienstadresse doppelt vergeben, hier in abweichender Schreibweise)'
INSERT INTO employees (employee_id, work_email) VALUES ('7e7e7e7e-2222-2222-2222-222222222222', 'A.Lehrkraft@Clemens.Schule');

\echo '--- erwartet: FEHLER (Dienstadresse ohne Struktur)'
INSERT INTO employees (employee_id, work_email) VALUES ('7e7e7e7e-2222-2222-2222-222222222222', 'kein Postfach');

\echo '--- erwartet: FEHLER (Austritt vor Eintritt)'
UPDATE employees SET employment_end = '2019-01-01' WHERE employee_id = '7e7e7e7e-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (Mitarbeiter ohne Personenzeile)'
INSERT INTO employees (employee_id) VALUES ('7e7e7e7e-9999-9999-9999-999999999999');

-- Klassenlehrer:in an der Kohorte
UPDATE classes SET class_teacher_id = '7e7e7e7e-1111-1111-1111-111111111111', room = 'A 1.02' WHERE class_id = 50;
SELECT 'Klassenlehrer:in und Raum an der Kohorte gesetzt' AS pruefung, class_teacher_id, room
    FROM classes WHERE class_id = 50;

\echo '--- erwartet: FEHLER (Löschung einer Person, die noch Klassenlehrer:in ist)'
DELETE FROM persons WHERE person_id = '7e7e7e7e-1111-1111-1111-111111111111';

-- family_guardians.contact_person nur bei Organisation als Guardian (per Trigger,
-- kein CHECK möglich — Organisations-Status steht auf guardians, nicht hier)
INSERT INTO families (family_id) VALUES ('99999999-1111-1111-1111-111111111111');

-- Anmeldedatum: angemeldet wird vor dem Eintritt, nie danach
UPDATE children SET registration_date = '2024-11-15', entry_date = '2025-09-01'
    WHERE child_id = '22222222-2222-2222-2222-222222222222';
SELECT 'Anmeldung/Eintritt/Austritt am Kind' AS pruefung, registration_date, entry_date, exit_date
    FROM children WHERE child_id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (Eintritt vor dem Anmeldedatum — vertauschte Importspalten)'
UPDATE children SET registration_date = '2025-10-01'
    WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- family_guardians: „In Briefe miteinbeziehen" ist per Default gesetzt
SELECT 'include_in_correspondence per Default true' AS pruefung, include_in_correspondence
    FROM family_guardians LIMIT 1;

-- acting_for trägt die Institution, für die diese Person in diesem Fall
-- handelt — nur für die Briefanschrift, ohne Regelwirkung.
INSERT INTO family_guardians (family_id, guardian_id, guardian_category_id, acting_for) VALUES
    ('99999999-1111-1111-1111-111111111111', '66666666-6666-6666-6666-666666666666', 2, 'Jugendamt Musterkreis');
SELECT 'Amtsvormundschaft: befreit, aber mit Briefanschrift' AS pruefung,
       fg.acting_for, gc.exempt_from_parent_duties
    FROM family_guardians fg JOIN guardian_categories gc
      ON gc.guardian_category_id = fg.guardian_category_id
    WHERE fg.family_id = '99999999-1111-1111-1111-111111111111';

-- ---------------------------------------------------------------------------
-- Familie: Außenbezeichnung darf kollidieren, die interne Unterscheidung nicht
-- ---------------------------------------------------------------------------
INSERT INTO families (family_id, label, alias) VALUES
    ('99999999-2222-2222-2222-222222222222', 'Familie Müller', 'Müller Sonnenweg'),
    ('99999999-3333-3333-3333-333333333333', 'Familie Müller', 'Müller Realschule');
SELECT 'zwei Familien Müller, unterscheidbar' AS pruefung, count(DISTINCT label) AS aussen,
       count(DISTINCT alias) AS intern FROM families WHERE label = 'Familie Müller';

\echo '--- erwartet: FEHLER (interne Unterscheidung doppelt vergeben)'
INSERT INTO families (label, alias) VALUES ('Familie Müller', 'Müller Sonnenweg');

\echo '--- erwartet: FEHLER (Leerstring als interne Unterscheidung belegte den UNIQUE-Platz)'
INSERT INTO families (alias) VALUES ('');

\echo '--- erwartet: FEHLER (Leerstring als Außenbezeichnung — leer heißt ableiten, nicht namenlos)'
INSERT INTO families (label) VALUES ('');

-- Mehrere Familien ohne Bezeichnung sind der Regelfall und kollidieren nicht:
-- der Name wird dort aus den Mitgliedern abgeleitet.
INSERT INTO families (family_id) VALUES
    ('99999999-4444-4444-4444-444444444444'),
    ('99999999-5555-5555-5555-555555555555');
SELECT 'Familien ohne Bezeichnung akzeptiert' AS pruefung, count(*) AS anzahl
    FROM families WHERE label IS NULL AND alias IS NULL;

-- ---------------------------------------------------------------------------
-- Kontakte: Notfallkontakt-Reihenfolge höchstens einmal je Kind belegt
-- ---------------------------------------------------------------------------
INSERT INTO persons (person_id, last_name) VALUES
    ('eeeeeeee-3333-3333-3333-333333333333', 'Oma'),
    ('ffffffff-3333-3333-3333-333333333333', 'Nachbarin');
INSERT INTO contacts (contact_id) VALUES
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
UPDATE addresses SET street = 'Nebenweg 9' WHERE address_id = '11111111-1111-1111-1111-111111111111';
SELECT 'Personen an der geänderten Anschrift' AS pruefung, count(*) AS anzahl
    FROM persons p JOIN addresses a ON a.address_id = p.address_id WHERE a.street = 'Nebenweg 9';

-- ---------------------------------------------------------------------------
-- Zahlungsverantwortliche: IST eine Person wie guardians, höchstens eine/r
-- Hauptzahler:in je Kind, Löschung blockiert
-- ---------------------------------------------------------------------------
INSERT INTO persons (person_id, last_name) VALUES ('77777777-7777-7777-7777-777777777777', 'Oma');
INSERT INTO payers (payer_id) VALUES ('77777777-7777-7777-7777-777777777777');

-- Kostenübernahme durch das Jugendamt: die Sachbearbeiterin ist die Zahlerin,
-- der abweichende Kontoinhaber trägt die Behörde (Begründung an der Tabelle).
INSERT INTO payers (payer_id, account_holder)
    VALUES ('66666666-6666-6666-6666-666666666666', 'Jugendamt Musterkreis');
SELECT 'Kostenübernahme: Person zahlt, Kontoinhaber ist die Behörde' AS pruefung, account_holder
    FROM payers WHERE payer_id = '66666666-6666-6666-6666-666666666666';

\echo '--- erwartet: FEHLER (dieselbe Person zweimal als Zahler)'
INSERT INTO payers (payer_id) VALUES ('77777777-7777-7777-7777-777777777777');

-- Bankverbindung: Struktur nach ISO 13616 / ISO 9362, nicht auf deutsche Längen
-- festgelegt — kürzeste IBAN (Norwegen, 15) und eine lange (Malta, 31) müssen
-- ebenso durchgehen wie BIC mit 8 und mit 11 Stellen.
UPDATE payers SET iban = 'NO9386011117947', bic = 'NDEANOKK'
    WHERE payer_id = '77777777-7777-7777-7777-777777777777';
UPDATE payers SET iban = 'MT84MALT011000012345MTLCAST001S', bic = 'DEUTDEFF500'
    WHERE payer_id = '77777777-7777-7777-7777-777777777777';
UPDATE payers SET iban = 'DE89370400440532013000', bic = 'DEUTDEFF'
    WHERE payer_id = '77777777-7777-7777-7777-777777777777';
SELECT 'IBAN/BIC: NO (15), MT (31), DE (22) sowie BIC 8- und 11-stellig akzeptiert' AS pruefung;

\echo '--- erwartet: FEHLER (IBAN ohne jede Struktur)'
UPDATE payers SET iban = 'ich habe keine IBAN' WHERE payer_id = '77777777-7777-7777-7777-777777777777';

\echo '--- erwartet: FEHLER (IBAN in Vierergruppen-Schreibweise, nicht normalisiert)'
UPDATE payers SET iban = 'DE89 3704 0044 0532 0130 00' WHERE payer_id = '77777777-7777-7777-7777-777777777777';

\echo '--- erwartet: FEHLER (IBAN zu kurz — unter den 15 Zeichen der kürzesten Ländervariante)'
UPDATE payers SET iban = 'NO938601111' WHERE payer_id = '77777777-7777-7777-7777-777777777777';

\echo '--- erwartet: FEHLER (BIC mit 9 Stellen — erlaubt sind nur 8 oder 11)'
UPDATE payers SET bic = 'DEUTDEFF5' WHERE payer_id = '77777777-7777-7777-7777-777777777777';

-- SEPA-Mandat: Referenz und Unterschriftsdatum nur gemeinsam, nie ohne IBAN,
-- Referenz je Gläubiger-ID eindeutig (Begründung am Feld).
UPDATE payers SET mandate_reference = 'WB-2026-0001', mandate_signed_at = '2026-03-01'
    WHERE payer_id = '77777777-7777-7777-7777-777777777777';
SELECT 'SEPA-Mandat: Referenz + Datum auf Zahler mit IBAN akzeptiert' AS pruefung;

\echo '--- erwartet: FEHLER (Mandatsreferenz ohne Unterschriftsdatum)'
UPDATE payers SET mandate_reference = 'WB-2026-0002', mandate_signed_at = NULL
    WHERE payer_id = '77777777-7777-7777-7777-777777777777';

\echo '--- erwartet: FEHLER (Unterschriftsdatum ohne Mandatsreferenz)'
UPDATE payers SET mandate_reference = NULL, mandate_signed_at = '2026-03-01'
    WHERE payer_id = '77777777-7777-7777-7777-777777777777';

\echo '--- erwartet: FEHLER (leere Mandatsreferenz statt NULL)'
UPDATE payers SET mandate_reference = '', mandate_signed_at = '2026-03-01'
    WHERE payer_id = '77777777-7777-7777-7777-777777777777';

\echo '--- erwartet: FEHLER (Mandat auf einem Zahler ohne IBAN)'
UPDATE payers SET mandate_reference = 'WB-2026-0003', mandate_signed_at = '2026-03-01'
    WHERE payer_id = '66666666-6666-6666-6666-666666666666';

\echo '--- erwartet: FEHLER (Mandatsreferenz doppelt vergeben)'
UPDATE payers SET iban = 'DE89370400440532013000', mandate_reference = 'WB-2026-0001', mandate_signed_at = '2026-04-01'
    WHERE payer_id = '66666666-6666-6666-6666-666666666666';

-- Umgekehrt erlaubt: IBAN ohne Mandat (Import aus Optigem, Erfassung vor
-- Vertragsabschluss).
UPDATE payers SET iban = 'DE89370400440532013000' WHERE payer_id = '66666666-6666-6666-6666-666666666666';
SELECT 'IBAN ohne Mandat akzeptiert' AS pruefung;

-- Genau eine/r je Kind, mehrere Kinder je Zahler:in (Geschwister, Mündel)
UPDATE children SET payer_id = '77777777-7777-7777-7777-777777777777'
    WHERE child_id IN ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-1111-1111-1111-111111111111');
SELECT 'eine Zahlerin trägt mehrere Kinder' AS pruefung, count(*) AS kinder
    FROM children WHERE payer_id = '77777777-7777-7777-7777-777777777777';

\echo '--- erwartet: FEHLER (Zahler:in löschen, solange ein Kind auf sie zeigt)'
DELETE FROM payers WHERE payer_id = '77777777-7777-7777-7777-777777777777';

-- Anders als früher blockiert die Zahlungsverantwortung das Löschen des KINDES
-- nicht mehr: die Zuordnung ist eine Spalte an der Kindzeile und verschwindet
-- mit ihr. Die payers-Zeile bleibt stehen und fällt als verwaist im selben Lauf
-- (domains/stammdaten.md, „Löschmechanik").
UPDATE children SET payer_id = NULL WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- ---------------------------------------------------------------------------
-- Löschmechanik (domains/stammdaten.md): blockiert, wo die Löschung eine
-- Entscheidung ist — kaskadiert, wo die Zeile kein Eigenleben hat
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Anschrift noch bewohnt)'
DELETE FROM addresses WHERE address_id = '11111111-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (Person ist Erziehungsberechtigte)'
DELETE FROM persons WHERE person_id = '33333333-3333-3333-3333-333333333333';

-- Kind löschen = ein Löschbefehl auf die Personenzeile; Rollenzeile und
-- Telefonnummern hängen daran und verschwinden mit.
DELETE FROM persons WHERE person_id = '22222222-2222-2222-2222-222222222222';
SELECT 'nach Löschung der Kind-Person' AS pruefung,
       (SELECT count(*) FROM children) AS kinder,
       -- bewusst auf diese Person eingegrenzt: Nummern anderer Eigentümer
       -- bleiben erwartungsgemäß stehen (Prüffall „dieselbe Nummer bei anderer
       -- Person" oben), eine Gesamtzahl verwischte hier die Aussage
       (SELECT count(*) FROM phone_numbers
          WHERE person_id = '22222222-2222-2222-2222-222222222222') AS telefonnummern_des_kindes;
