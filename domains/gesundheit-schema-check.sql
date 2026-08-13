-- Prüfskript zu domains/gesundheit-schema.sql — belegt, dass die Zusagen aus
-- domains/gesundheit.md in der Datenbank gelten und nicht nur im Text stehen.
-- Bewusst ohne Testframework: eine Datei, gegen eine Wegwerf-Datenbank laufen
-- lassen und die Ausgabe lesen (rules.md Abschnitt 8).
--
--   podman run --rm -d --name pg -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
--   podman cp domains/stammdaten-schema.sql       pg:/tmp/1.sql
--   podman cp domains/putzdienst-schema.sql       pg:/tmp/2.sql
--   podman cp domains/anmeldung-schema.sql        pg:/tmp/3.sql
--   podman cp domains/gesundheit-schema.sql       pg:/tmp/4.sql
--   podman cp domains/gesundheit-schema-check.sql pg:/tmp/check.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/1.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/2.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/3.sql
--   podman exec pg psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/4.sql
--   podman exec pg sh -c 'psql -U postgres -f /tmp/check.sql 2>&1'
--   podman rm -f pg
--
-- Stammdaten und Anmeldung MÜSSEN vorher geladen sein (children, documents).
-- Putzdienst steht nur deshalb dazwischen, weil das Anmelde-Schema die dort
-- gebaute payments-Tabelle erweitert.
--
-- Erwartet: jede mit „--- erwartet: FEHLER" angekündigte Anweisung scheitert,
-- jede andere läuft durch. ON_ERROR_STOP hier bewusst NICHT gesetzt.
--
-- Fallstricke beim Auswerten — identisch zu den anderen Prüfskripten:
--   * Pro Lauf eine frische Datenbank.
--   * stdout und stderr im Container zusammenführen (`sh -c '… 2>&1'`).
--   * Sollstand: 10 Ankündigungen zu 10 ERROR-Zeilen, jeweils unmittelbar
--     gepaart. Verankert und auf der AUSGABE zählen, nicht auf dieser Datei.
--
-- WAS DIESES SKRIPT NICHT BELEGEN KANN: den zweistufigen Zugriff. Es läuft als
-- Superuser, und Spalten-GRANTs wirken weder gegen den Tabelleneigentümer noch
-- gegen die Migrations-Rolle — dieselbe Einschränkung wie beim Art.-9-Schutz in
-- Stammdaten. Belegt wird hier die Struktur, die den Schutz überhaupt erst
-- möglich macht: zwei getrennte Spalten auf einer Tabelle.

SET app.actor = 'system:test';

-- ---------------------------------------------------------------------------
-- Ausgangsdaten
-- ---------------------------------------------------------------------------
INSERT INTO persons (person_id, last_name, first_name) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Müller', 'Anna'),
    ('22222222-2222-2222-2222-222222222222', 'Fremd',  'Felix');
INSERT INTO children (child_id, date_of_birth, entry_date) VALUES
    ('11111111-1111-1111-1111-111111111111', '2016-05-01', '2023-09-11');
-- Externes Hortkind: bekommt denselben Satz ohne jede Schulanmeldung.
INSERT INTO children (child_id, date_of_birth) VALUES
    ('22222222-2222-2222-2222-222222222222', '2019-02-17');

INSERT INTO document_types (document_type_id, label, code) VALUES (10, 'Attest', 'attestation');
-- Vorlagepfad und Vorlagedatum gelten nur gemeinsam (documents im
-- Anmelde-Schema) — ein Attest ohne Vorlagedatum wäre eine Anforderung.
INSERT INTO documents (document_id, document_type_id, child_id, storage_path, created_on)
    VALUES ('d0000000-0000-0000-0000-000000000001', 10,
            '11111111-1111-1111-1111-111111111111',
            'RS25a/mueller-anna/attest-adrenalin.pdf', current_date);

INSERT INTO health_trait_types (health_trait_type_id, label, sort_order) VALUES
    (1, 'Lebensmittelunverträglichkeit', 1),
    (2, 'Allergie',                      2),
    (3, 'chronische Erkrankung',         3),
    (4, 'Medikament',                    4),
    (5, 'Notfallmedikation',             5),
    (6, 'körperliche Einschränkung',     6),
    (7, 'Seh-/Hörschwäche',              7),
    (8, 'therapeutische Maßnahme',       8),
    (9, 'Unterstützungsbedarf',          9);

INSERT INTO measles_presentation_types (measles_presentation_type_id, label) VALUES
    (1, 'Impfpass vorgelegt'),
    (2, 'ärztliche Bescheinigung vorgelegt');

-- ---------------------------------------------------------------------------
-- Merkmale: eine Zeile je Merkmal, mehrere je Kind und Art
-- ---------------------------------------------------------------------------
INSERT INTO health_traits (child_id, health_trait_type_id, description, instruction, action_note) VALUES
    ('11111111-1111-1111-1111-111111111111', 2, 'Erdnuss',
     'Kein Kontakt mit erdnusshaltigen Speisen; bei Verdacht sofort Sekretariat.',
     'Erdnussallergie — Notfallset im Sekretariat'),
    ('11111111-1111-1111-1111-111111111111', 2, 'Birkenpollen',
     'Bei starkem Pollenflug Sportunterricht drinnen.', NULL);
SELECT 'mehrere merkmale derselben art je kind' AS pruefung, count(*) AS merkmale
  FROM health_traits
 WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 2;

-- Notfallmedikation mit Attest und Verabreichungserlaubnis: das vollständige
-- Muster, dem alle sechs Formulare folgen.
INSERT INTO health_traits (child_id, health_trait_type_id, description, instruction,
                           attestation_document_id, permission_granted_at, action_note)
    VALUES ('11111111-1111-1111-1111-111111111111', 5, 'Adrenalin-Autoinjektor',
            'Bei Atemnot oder Schwellung im Gesicht sofort verabreichen, danach 112.',
            'd0000000-0000-0000-0000-000000000001', now(),
            'Notfallmedikament im Sekretariat');
SELECT 'merkmal mit attest und verabreichungserlaubnis' AS pruefung,
       attestation_document_id IS NOT NULL AS hat_attest,
       permission_granted_at IS NOT NULL   AS darf_verabreicht_werden
  FROM health_traits
 WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 5;

-- Therapeutische Maßnahme mit Behandlungsgrund — ohne Zeitraum: was hier steht,
-- gilt; ein beendetes Merkmal wird gelöscht statt datiert.
INSERT INTO health_traits (child_id, health_trait_type_id, description, treatment_reason)
    VALUES ('11111111-1111-1111-1111-111111111111', 8, 'Logopädie',
            'Sprachentwicklungsverzögerung');
SELECT 'therapeutische maßnahme mit grund, ohne zeitraum' AS pruefung, treatment_reason
  FROM health_traits
 WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 8;

\echo '--- erwartet: FEHLER (Merkmal ohne Beschreibung)'
INSERT INTO health_traits (child_id, health_trait_type_id, description)
    VALUES ('11111111-1111-1111-1111-111111111111', 2, '');

\echo '--- erwartet: FEHLER (Merkmal ohne Art)'
INSERT INTO health_traits (child_id, description)
    VALUES ('11111111-1111-1111-1111-111111111111', 'irgendwas');

-- Zurückgenommene Erlaubnis: auf NULL setzen, kein Widerrufsfeld — dieselbe
-- Regel wie beim entfallenen Merkmal, das gelöscht statt datiert wird.
UPDATE health_traits SET permission_granted_at = NULL
    WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 5;
SELECT 'erlaubnis zurueckgenommen' AS pruefung, permission_granted_at IS NULL AS keine_erlaubnis
  FROM health_traits
 WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 5;
UPDATE health_traits SET permission_granted_at = now()
    WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 5;

\echo '--- erwartet: FEHLER (leerer Handlungshinweis statt NULL)'
UPDATE health_traits SET action_note = ''
    WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 5;

\echo '--- erwartet: FEHLER (leerer Behandlungsgrund statt NULL)'
UPDATE health_traits SET treatment_reason = ''
    WHERE child_id = '11111111-1111-1111-1111-111111111111' AND health_trait_type_id = 8;

-- ---------------------------------------------------------------------------
-- Der zweistufige Zugriff ist strukturell vorbereitet
-- ---------------------------------------------------------------------------
-- Die enge Sicht (voller Satz) und die breite Sicht (nur der Hinweis) liegen auf
-- derselben Tabelle und lassen sich getrennt granten. Das Skript kann das GRANT
-- nicht belegen (Superuser), wohl aber, dass die breite Sicht ohne jede
-- Diagnoseangabe auskommt.
SELECT 'breite sicht trägt keine diagnose' AS pruefung, t.label AS art, h.action_note
  FROM health_traits h
  JOIN health_trait_types t ON t.health_trait_type_id = h.health_trait_type_id
 WHERE h.child_id = '11111111-1111-1111-1111-111111111111'
   AND h.action_note IS NOT NULL
 ORDER BY t.sort_order;

-- ---------------------------------------------------------------------------
-- Externes Hortkind: derselbe Satz ohne Schulanmeldung
-- ---------------------------------------------------------------------------
INSERT INTO health_traits (child_id, health_trait_type_id, description, action_note)
    VALUES ('22222222-2222-2222-2222-222222222222', 1, 'Laktose',
            'keine Milchprodukte');
SELECT 'externes hortkind hat gesundheitsmerkmale ohne eintrittsdatum' AS pruefung,
       c.entry_date IS NULL AS nicht_eingeschrieben, count(h.*) AS merkmale
  FROM children c JOIN health_traits h ON h.child_id = c.child_id
 WHERE c.child_id = '22222222-2222-2222-2222-222222222222'
 GROUP BY c.entry_date;

-- ---------------------------------------------------------------------------
-- Masernschutznachweis: Vorlage ja, Kopie nein
-- ---------------------------------------------------------------------------
INSERT INTO measles_proofs (child_id, presented_on, measles_presentation_type_id)
    VALUES ('11111111-1111-1111-1111-111111111111', '2023-09-04', 1);
SELECT 'masernnachweis als punkt-lookup, ohne dokument' AS pruefung,
       presented_on, m.label AS vorlageart
  FROM measles_proofs p
  JOIN measles_presentation_types m
    ON m.measles_presentation_type_id = p.measles_presentation_type_id
 WHERE p.child_id = '11111111-1111-1111-1111-111111111111';

\echo '--- erwartet: FEHLER (zweiter Masernnachweis für dasselbe Kind)'
INSERT INTO measles_proofs (child_id, presented_on, measles_presentation_type_id)
    VALUES ('11111111-1111-1111-1111-111111111111', '2024-01-10', 2);

\echo '--- erwartet: FEHLER (Nachweis ohne Vorlagedatum)'
INSERT INTO measles_proofs (child_id, measles_presentation_type_id)
    VALUES ('22222222-2222-2222-2222-222222222222', 1);

\echo '--- erwartet: FEHLER (Nachweis ohne Vorlageart)'
INSERT INTO measles_proofs (child_id, presented_on)
    VALUES ('22222222-2222-2222-2222-222222222222', '2026-08-01');

-- Der Fall „geprüft, nicht vorgelegt": die Infektionsschutz-Anlage des
-- Betreuungsvertrags verlangt die Meldung ans Gesundheitsamt — die Zeile trägt
-- das Meldedatum und ist damit von „nie geprüft" (keine Zeile) unterscheidbar.
INSERT INTO measles_proofs (child_id, reported_to_health_office_on)
    VALUES ('22222222-2222-2222-2222-222222222222', '2026-09-15');
SELECT 'geprüft, nicht vorgelegt, gemeldet' AS pruefung,
       presented_on IS NULL AS ohne_vorlage, reported_to_health_office_on
  FROM measles_proofs WHERE child_id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (Zeile ohne jede Tatsache — weder Vorlage noch Meldung)'
UPDATE measles_proofs SET reported_to_health_office_on = NULL
    WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- Nachgereicht: die Vorlage kommt in dieselbe Zeile, das Meldedatum bleibt als
-- Beleg der erfolgten Meldung stehen.
UPDATE measles_proofs
   SET presented_on = '2026-10-01', measles_presentation_type_id = 2
 WHERE child_id = '22222222-2222-2222-2222-222222222222';
SELECT 'nachgereicht: vorlage und meldung in einer zeile' AS pruefung,
       presented_on, reported_to_health_office_on IS NOT NULL AS meldung_belegt
  FROM measles_proofs WHERE child_id = '22222222-2222-2222-2222-222222222222';

-- ---------------------------------------------------------------------------
-- Löschmechanik
-- ---------------------------------------------------------------------------
\echo '--- erwartet: FEHLER (Kind mit Gesundheitsmerkmal wird nicht nebenbei mitgelöscht)'
DELETE FROM children WHERE child_id = '22222222-2222-2222-2222-222222222222';

\echo '--- erwartet: FEHLER (Attest löschen, solange ein Merkmal darauf zeigt)'
DELETE FROM documents WHERE document_id = 'd0000000-0000-0000-0000-000000000001';

-- Das Attest hängt an genau EINEM Weg: über das Merkmal an der Q2-Zeile. Der
-- Lösch-Job findet die SharePoint-Datei damit ohne zweiten Dateiverweis.
SELECT 'attest ist über genau einen weg auffindbar' AS pruefung, d.storage_path
  FROM health_traits h JOIN documents d ON d.document_id = h.attestation_document_id
 WHERE h.child_id = '11111111-1111-1111-1111-111111111111';
