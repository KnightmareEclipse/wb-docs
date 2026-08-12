-- Gesundheitsdaten-Schema (Domäne 9, fachdomaenen.md Abschnitt 6):
-- Gesundheitsmerkmale je Kind und der Masernschutznachweis. Konzeptioneller
-- Entwurf zu domains/gesundheit.md und domains/grenzkarte.md — konkreter als
-- Prosa, aber noch kein Alembic-Migrationscode.
--
-- SETZT domains/stammdaten-schema.sql UND domains/anmeldung-schema.sql VORAUS:
-- es referenziert children aus Stammdaten und documents (Q2) aus der Anmeldung,
-- und es nutzt set_row_audit() samt app.actor-Präfixregel.
--
-- Stammdaten sind ab dem Vollimport eingefroren (domains/grenzkarte.md). Dieses
-- Schema hält sich daran: es hängt sich an children.child_id und ändert dort
-- nichts — der Stammdaten-Kern liefert nur den Anker.
--
-- BESONDERE KATEGORIEN NACH ART. 9 DSGVO. Das ist der Datenbestand mit dem
-- engsten Zugriffsprofil im ganzen System, und die Struktur ist danach gebaut:
--
--   * EINE ZEILE JE MERKMAL mit Merkmalsart als Werteliste — nicht rund dreißig
--     Spalten, wie es die sechs Papierformulare nahelegen. Zwei Gründe: eine
--     weitere Merkmalsart ist damit ein Datensatz statt einer Migration, und das
--     Spalten-GRANT der engeren DB-Rolle greift auf EINER Tabelle statt auf
--     dreißig Spalten (domains/grenzkarte.md, „Gesundheitsmerkmal (9)").
--   * ZWEISTUFIGER ZUGRIFF auf derselben Tabelle: den vollen Satz sehen
--     Sekretariat, Klassenlehrer:in und Hort; alle unterrichtenden Personen
--     sehen ausschließlich action_note. Zwei Spalten mit unterschiedlichem
--     GRANT, kein zweites Berechtigungssystem. Ein Fachlehrer braucht die
--     Handlungsregel, nicht die Diagnose — der volle Satz wäre Über-Offenlegung
--     nach Art. 9. Eine echte Fachlehrer-Berechtigung bräuchte ein
--     Unterrichtszuordnungs-Modell, und das lebt in Untis (dauerhaft out of
--     scope).
--   * Die GRANTs selbst stehen wie bei den Konfessionsspalten NICHT hier,
--     sondern in wb-backend/db/init-roles.sh. Wichtig dabei, sonst greift die
--     ganze Konstruktion nicht: die Laufzeit-Rolle darf kein tabellenweites
--     GRANT SELECT/UPDATE auf health_traits bekommen, und der Owner der Tabelle
--     darf nicht die Laufzeit-Rolle sein.
--
-- Der Satz ist GRÖSSER als der Schulvertrag: dieselben Merkmale werden auf allen
-- vier Anmeldetag-Checklisten, im Schulvertrag und noch einmal im Hortvertrag
-- erhoben — sechs Formulare, ein Datenbestand (prozesse.md Abschnitt 7.2 und
-- 8). In Weltenbaum wird der Satz dagegen EINMAL JE KIND eingesammelt und nicht
-- je Vertrag: der Schulvertrag sticht den Hortvertrag aus, und nur ein externes
-- Hortkind liefert ihn über den Hortvertrag, weil es keine Schulanmeldung gibt,
-- die ihn geliefert hätte. Genau deshalb hängen die Merkmale am Kind.
-- Ausgefüllt wird der Bogen von den Eltern (domains/gesundheit.md).
--
-- Was hier bewusst NICHT steht:
--   * Keine Einwilligung und keine Unterschrift. „Einwilligung Mutter/Vater" und
--     die beiden Signaturen des Gesundheitsblatts sind Q1 und Q2 aus dem
--     Anmelde-Schema — hier stünden sie ein zweites Mal.
--   * Keine Zeckenentfernungs-Spalte. „Darf die Schule eine Zecke entfernen" ist
--     eine Erlaubnis und kein Merkmal des Kindes: sie ist eine Zustimmung (Q1)
--     mit eigenem Zweck, widerrufbar wie jede andere.
--   * Keine Geburtsurkunde. Sie ist kein Gesundheitsdatum und bleibt eine reine
--     Q2-Zeile mit Bezug Kind (domains/grenzkarte.md) — hier hätte sie das
--     falsche Zugriffsprofil.
--   * Keine Historie und kein Behandlungszeitraum. WAS HIER STEHT, GILT — ein
--     Merkmal, das nicht mehr zutrifft, wird gelöscht statt datiert
--     (Begründung an der Stelle, wo der Zeitraum stünde).
--   * Keine Diagnose-Codes (ICD o. ä.). Niemand fragt danach, und ein Code
--     verleitet zu Auswertungen, für die es keine Rechtsgrundlage gibt
--     (rules.md Abschnitt 7).
--   * Keine Masern-Kopie, aber sehr wohl der Fall „geprüft, nicht vorgelegt":
--     die Infektionsschutz-Anlage des Betreuungsvertrags hält fest, dass ein
--     fehlender Masern-Immunitätsnachweis dem Gesundheitsamt gemeldet wird —
--     measles_proofs trägt deshalb neben der Vorlage auch das Meldedatum
--     (Begründung an der Tabelle).
--
-- Löschreihenfolge, erzwungen durch die Fremdschlüssel unten: erst das Merkmal,
-- dann die Q2-Dokumentzeile des Attests, dann die Datei in SharePoint
-- (idea/06-dsgvo-organisatorisch.md). Dieser Bestand hat voraussichtlich die
-- KÜRZESTE Frist im System, hält über attestation_document_id aber ein
-- ON DELETE RESTRICT in eine Domäne mit anderer Frist — der Lösch-Job muss
-- deshalb hier anfangen und nicht bei der Anmeldung.

-- ---------------------------------------------------------------------------
-- Wertelisten
-- ---------------------------------------------------------------------------

-- Merkmalsart: Lebensmittelunverträglichkeit, Allergie, chronische Erkrankung,
-- Medikament, Notfallmedikation, körperliche Einschränkung, Seh-/Hörschwäche,
-- therapeutische Maßnahme (LRS, ADHS, Logopädie …), Unterstützungsbedarf
-- einschließlich Schulbegleitung.
--
-- Schulbegleitung steht bewusst HIER und nicht als Freitext an der Bewerbung:
-- sie ist ein Unterstützungsbedarf, der über das Aufnahmeverfahren hinaus gilt
-- und im Schulalltag gebraucht wird — mit diesem Zugriffsprofil, nicht mit dem
-- der Bewerbung (domains/grenzkarte.md, „Zwei Bemerkungen").
CREATE TABLE health_trait_types (
    health_trait_type_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label                text NOT NULL UNIQUE CHECK (label <> ''),
    sort_order           smallint NOT NULL UNIQUE
);

-- Wie der Masernschutznachweis vorgelegt wurde. Der Nachweis ist gesetzlich
-- verpflichtend (§20 IfSG) und wird auf allen vier Checklisten geprüft, aber
-- NIE als Kopie: festgehalten wird nur, ob er dokumentiert wurde und auf
-- welchem Weg — „hier gehen viele Wege" (prozesse.md Abschnitt 5.2).
CREATE TABLE measles_presentation_types (
    measles_presentation_type_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label                        text NOT NULL UNIQUE CHECK (label <> '')
);

-- ---------------------------------------------------------------------------
-- Gesundheitsmerkmal
-- ---------------------------------------------------------------------------

-- Alle sechs Formulare folgen demselben Muster: Merkmal vorhanden, Beschreibung,
-- ggf. Behandlungszeitraum, ggf. Attest, ggf. Erlaubnis zur Verabreichung oder
-- Durchführung. Genau dieses Muster sind die Spalten unten.
--
-- Bewusst KEIN UNIQUE auf (child_id, health_trait_type_id): mehrere Allergien
-- sind der Normalfall, und zwei therapeutische Maßnahmen nebeneinander ebenso.
CREATE TABLE health_traits (
    health_trait_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id              uuid NOT NULL REFERENCES children(child_id) ON DELETE RESTRICT,
    health_trait_type_id  integer NOT NULL REFERENCES health_trait_types(health_trait_type_id) ON DELETE RESTRICT,
    -- WAS vorliegt: „Erdnuss", „Adrenalin-Pen", „Logopädie". Das Gegenstück zu
    -- den „Art der …"-Feldern der Papierformulare.
    description           text NOT NULL CHECK (description <> ''),
    -- WAS ZU TUN oder zu unterlassen ist: „kein Kontakt, Notfallset im
    -- Sekretariat", „keine Sprungübungen", „bei Atemnot verabreichen". Fasst
    -- drei Formularfelder zusammen, die dasselbe meinen — Beschreibung der
    -- Notfallsituation, nicht auszuführende Tätigkeiten, Verabreichungshinweis.
    -- Gehört zum VOLLEN Satz und ist NICHT der breit sichtbare Hinweis (siehe
    -- action_note): hier steht die vollständige Anweisung samt Zusammenhang.
    instruction           text CHECK (instruction <> ''),
    -- Behandlungsgrund, real nur bei therapeutischen Maßnahmen erhoben. Das ist
    -- die sensibelste einzelne Angabe des ganzen Schemas — eine Diagnose. Sie
    -- teilt das Spalten-GRANT des vollen Satzes und wird nirgends ausgewertet,
    -- nur angezeigt.
    treatment_reason      text CHECK (treatment_reason <> ''),
    -- KEIN Behandlungszeitraum, obwohl die Anmeldetag-Checklisten ihn bei
    -- therapeutischen Maßnahmen real erheben (domains/grenzkarte.md). Hier
    -- gewinnt Datensparsamkeit gegen die Schema-Ausnahme aus rules.md
    -- Abschnitt 1, und zwar aus einem Grund, der nur für Art. 9 gilt:
    -- WAS HIER STEHT, GILT. Ein Merkmal, das nicht mehr zutrifft, wird
    -- gelöscht statt mit einem Enddatum versehen.
    -- Ein „bis"-Datum hätte die Zeile nicht entfernt, sondern nur behauptet,
    -- dass sie abgelaufen ist — und weil kein Abnehmer danach filtert, stünde
    -- der breit sichtbare action_note einer längst beendeten Therapie
    -- weiterhin allen unterrichtenden Personen vor Augen. Ein Datum, das
    -- niemand liest, ist bei besonderen Kategorien schlechter als keines: es
    -- erzeugt den Anschein einer Bereinigung, die nicht stattfindet.
    -- Was das Löschen auslöst, ist offen und als akzeptiertes Risiko benannt:
    -- erhoben wird einmal je Kind, eine wiederkehrende Sammelaktion gibt es
    -- nicht, Änderungen kommen von den Eltern (domains/gesundheit.md).
    -- Attest. Zeigt auf die Q2-Dokumentzeile im Anmelde-Schema, statt hier einen
    -- zweiten Dateiverweis aufzumachen: die Datei liegt in SharePoint, und der
    -- Lösch-Job muss sie über genau einen Weg finden (domains/grenzkarte.md, Q2).
    attestation_document_id uuid REFERENCES documents(document_id) ON DELETE RESTRICT,
    -- Erlaubnis zur Verabreichung bzw. Durchführung. Zeitpunkt statt Boolean
    -- wegen der Nachweispflicht (Art. 7 Abs. 1 DSGVO), dieselbe Bauform wie
    -- children.previous_school_consent_at.
    --
    -- Warum sie NICHT nach Q1 wandert, obwohl die Zeckenentfernung genau dorthin
    -- verwiesen wird (Kopfkommentar) — der Unterschied ist der Bezug: eine
    -- Q1-Zustimmung gilt Person × Kind × Zweck und trägt ein UNIQUE genau
    -- darauf (consents im Anmelde-Schema). Diese Erlaubnis gilt dem EINZELNEN
    -- Merkmal: zwei Notfallmedikamente desselben Kindes sind getrennt zu
    -- erlauben, in Q1 wären sie derselbe Zweck und damit dieselbe Zeile. Die
    -- Zeckenentfernung hat diesen Merkmalsbezug nicht — sie gilt dem Kind, und
    -- deshalb geht sie nach Q1 und diese Spalte nicht.
    --
    -- Kein Widerrufsfeld daneben, anders als consents.revoked_at: es gilt die
    -- Regel dieser Tabelle — was hier steht, gilt. Eine zurückgenommene
    -- Erlaubnis wird auf NULL gesetzt, ein entfallenes Merkmal gelöscht.
    --
    -- WER sie erteilt hat, tragen die Audit-Spalten unten, nicht Q2: von dieser
    -- Zeile führt kein Weg zu einer Signatur — attestation_document_id zeigt auf
    -- das Attest, nicht auf das Gesundheitsdatenblatt, und ein mitten im
    -- Schuljahr ergänztes Merkmal hat gar kein unterschriebenes Blatt. Das
    -- trägt, weil den Bogen die ELTERN ausfüllen (domains/gesundheit.md): der
    -- Regelfall ist damit „guardian:<uuid>" und benennt die erteilende Person.
    -- Nur im Ausnahmefall, wenn das Sekretariat vom Papier überträgt, steht
    -- „entra:<oid>" da und belegt lediglich, wer abgetippt hat.
    -- Reicht das für einen Prozess einmal nicht, ist der Nachweis das
    -- unterschriebene Blatt in Q2 — über child_id und Dokumenttyp auffindbar,
    -- aber nicht je Merkmal.
    permission_granted_at timestamptz,
    -- --- BREIT SICHTBAR: eigenes Spalten-GRANT, andere Leserschaft ------------
    -- Der kurze handlungsrelevante Hinweis, den die Klassenlehrkraft formuliert
    -- und den ALLE unterrichtenden Personen sehen: „keine Sprungübungen",
    -- „Notfallmedikament im Sekretariat". Bewusst eine eigene Spalte und nicht
    -- ein gekürztes instruction: der Unterschied ist nicht die Länge, sondern
    -- der Leserkreis — hier darf keine Diagnose stehen, und wer ihn formuliert,
    -- trifft genau diese Entscheidung. Wer beide Spalten zusammenlegt, hebt den
    -- Art.-9-Schutz auf, ohne es zu merken.
    action_note           text CHECK (action_note <> ''),
    -- --- Ende breit sichtbar --------------------------------------------------
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,
    updated_at            timestamptz NOT NULL DEFAULT now(),
    updated_by            text NOT NULL
);
-- „Alle Merkmale dieses Kindes" ist die einzige Abfrage der Domäne.
CREATE INDEX ON health_traits (child_id);
CREATE INDEX ON health_traits (attestation_document_id);

-- ---------------------------------------------------------------------------
-- Masernschutznachweis
-- ---------------------------------------------------------------------------

-- Kein Merkmal, sondern ein Nachweis-STATUS — deshalb eine eigene Tabelle und
-- keine health_traits-Zeile: er hat kein „was liegt vor" und keine
-- Handlungsanweisung. Trotzdem in Domäne 9, weil der Impfstatus ein
-- Gesundheitsdatum ist.
--
-- child_id ist zugleich Primärschlüssel: ein Kind hat genau einen
-- Nachweis-Status oder keinen. Ein zweiter wäre kein Sonderfall, sondern eine
-- Dublette. KEINE Zeile heißt „noch nicht geprüft".
--
-- Die Zeile trägt zwei Tatsachen, einzeln oder zusammen (CHECK unten):
--   * VORGELEGT: presented_on samt Vorlageart — beide nur gemeinsam.
--   * GEMELDET: reported_to_health_office_on. Die Infektionsschutz-Anlage des
--     Betreuungsvertrags hält ausdrücklich fest, dass ein fehlender
--     Masern-Immunitätsnachweis dem Gesundheitsamt gemeldet wird (§20 IfSG) —
--     „geprüft, nicht vorgelegt, gemeldet" ist damit ein realer Zustand und
--     war vorher nicht von „nie geprüft" zu unterscheiden. Wird der Nachweis
--     später nachgereicht, kommen Vorlagedatum und -art in dieselbe Zeile und
--     das Meldedatum bleibt als Beleg der erfolgten Meldung stehen.
--
-- Es entsteht KEIN Dokument (siehe measles_presentation_types), deshalb auch
-- kein Verweis nach Q2. Die Zeile IST der Nachweis.
--
-- Muss im Alltag schnell nachprüfbar sein — das Sekretariat schlägt ihn nach,
-- nicht nur am Anmeldetag (prozesse.md Abschnitt 5.2). Über den
-- Primärschlüssel ist genau das ein Punkt-Lookup.
CREATE TABLE measles_proofs (
    child_id                     uuid PRIMARY KEY REFERENCES children(child_id) ON DELETE RESTRICT,
    presented_on                 date,
    measles_presentation_type_id integer
        REFERENCES measles_presentation_types(measles_presentation_type_id) ON DELETE RESTRICT,
    reported_to_health_office_on date,
    created_at                   timestamptz NOT NULL DEFAULT now(),
    created_by                   text NOT NULL,
    updated_at                   timestamptz NOT NULL DEFAULT now(),
    updated_by                   text NOT NULL,
    -- Eine Zeile ohne jede Tatsache wäre von „geprüft" nicht zu unterscheiden
    -- und verdeckte nur den Zustand „keine Zeile".
    CONSTRAINT measles_proofs_any_fact_check
        CHECK (presented_on IS NOT NULL OR reported_to_health_office_on IS NOT NULL),
    -- Vorlagedatum und Vorlageart nur gemeinsam — eine Vorlage ohne Weg oder
    -- ein Weg ohne Vorlage ist keine.
    CONSTRAINT measles_proofs_presentation_complete_check
        CHECK ((presented_on IS NULL) = (measles_presentation_type_id IS NULL))
);

-- ---------------------------------------------------------------------------
-- Audit-Trigger
-- ---------------------------------------------------------------------------
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON health_traits
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON measles_proofs
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
