-- Gesundheits- und Förderdaten (Domäne 9) — ein Bestand je Kind, den heute
-- sechs Formulare getrennt erheben.
-- Lesepfad, von der Konfiguration zur Angabe: `health_trait_types` sagt, welche
-- Kategorien es gibt, `health_fields` welche Felder, `health_type_fields`
-- welches Feld zu welcher Kategorie gehört. Daran hängt die Antwort:
-- `child_health_records` je Kind die vorgeschaltete Frage, ob überhaupt
-- geantwortet wird, `child_health_answers` dieselbe Frage je Kategorie,
-- `health_traits` die einzelne Angabe und `health_trait_values` je Feld einen
-- Wert. Quer dazu liegen die zwei Freigaben: `child_health_releases` je
-- Instanz, `health_trait_releases` je Angabe und Instanz — sie entscheiden
-- zusammen mit dem Sichtkreis, wer was sieht. `measles_proofs` steht daneben,
-- weil der Nachweis kein Merkmal ist.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus. Der Satz
-- entsteht mit dem Schulvertrag (08), bei einem externen Hortkind mit dem
-- Hortvertrag (09) und bei einem schulfremden Ferienkind mit seiner Buchung
-- (10, `ferien-schema.sql`); erhoben wird er einmal je Kind, nicht je Vertrag.
-- Wer ihn schon hat, gibt ihn für den nächsten Anlass nur frei.
--
-- WARUM EINE ZEILE JE FELD UND NICHT JE MERKMAL. Die Tiefe unterscheidet sich
-- je Kategorie — die Zeckenentfernung ist ein Ja/Nein, die chronische
-- Erkrankung trägt Bezeichnung, Handlungshinweis, Attest und Zeitraum —, und
-- die Sichtbarkeit läuft quer dazu: Die Küche sieht Bezeichnung und
-- Handlungshinweis einer Allergie und von der chronischen Erkrankung nichts,
-- und das Attest derselben Erkrankung sieht die Lehrkraft als Vorliegen, das
-- Sekretariat im Klartext (`health_field_visibility.presence_only`) — ein
-- Unterschied, den keine Spaltenliste je Kategorie trägt. Beides zusammen
-- ist mit festen Spalten nicht darstellbar: Eine Spaltenliste je Kategorie wäre
-- je neue Frage eine Migration, und Spaltensichtbarkeit ist in Postgres nur
-- statisch zu vergeben. Als Zeilen fällt beides mit einem Mechanismus —
-- Zeilen prüft der Fremdschlüssel, Zeilen filtert RLS (`api/gesundheit-api.md`).
-- Der Preis steht dort, wo er anfällt: `health_trait_values` trägt fünf
-- Wertspalten statt einer, und ob ein Feld überhaupt beantwortet wurde, ist
-- keine NOT-NULL-Frage mehr, sondern die Frage nach einer fehlenden Zeile —
-- deshalb `child_health_answers`.
--
-- Bewusst KEINE Kopie des Masernnachweises: „festgehalten wird nur, ob er
-- dokumentiert wurde und wie er vorgelegt wurde".
-- Bewusst KEIN Formularbaukasten daneben: kein Feld für Reihenfolge oder
-- Beschriftung, keine bedingte Anschlussfrage, keine Formularfassung. Ein
-- Fragensatz ist eine Menge von Feldern; alles Weitere entsteht, wenn ein Fall
-- dafür vorliegt (rules.md Abschnitt 1).


-- ---------------------------------------------------------------------------
-- Konfiguration — was es geben kann
-- ---------------------------------------------------------------------------

-- Herkunft: grenzkarte.md, „Gesundheitsmerkmal (9)" — „eine weitere
-- Merkmalsart ist damit ein Datensatz statt einer Migration." Kein Löschanker:
-- keine Personendaten. Die vier Struktur-Flags von früher
-- (`needs_permission`, `is_medication`, `has_treatment_reason`,
-- `is_emergency_medication`) sind entfallen: Sie sagten, welche Spalten des
-- Merkmals gelten — das sagt jetzt `health_type_fields`, und zwar für beliebig
-- viele Tiefen statt für vier. `is_everyday_relevant` und `is_kitchen_relevant`
-- sind aus demselben Grund fort: Sie trugen drei ineinanderliegende Sichten,
-- und der Bedarf liegt quer (siehe `health_field_visibility`).
CREATE TABLE health_trait_types (
    health_trait_type_id integer GENERATED ALWAYS AS IDENTITY,
    code                 text NOT NULL,
    name                 text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active            boolean NOT NULL DEFAULT true,
    -- Wahr, wo ein Kind mehrere Angaben derselben Kategorie haben kann: „zwei
    -- Notfallmedikamente desselben Kindes sind getrennt zu erlauben"
    -- (grenzkarte.md, Q1). Falsch bei allem, wovon es je Kind genau eines gibt
    -- — eine zweite Zeckenerlaubnis ist keine zweite Angabe, sondern ein
    -- Doppeleintrag. `health_traits` führt das Flag mit und wird davon
    -- gesteuert.
    allows_multiple      boolean NOT NULL DEFAULT false,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_health_trait_types      PRIMARY KEY (health_trait_type_id),
    CONSTRAINT uq_health_trait_types_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel von `health_traits` und ist
    -- deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_health_trait_types_multiple
        UNIQUE (health_trait_type_id, allows_multiple),
    CONSTRAINT ck_health_trait_types_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: diese Datei. Kein Löschanker: keine Personendaten.
-- AUSNAHME von der Regel „Kategoriewerte als Lookup, damit ein neuer Wert
-- keine Migration ist": Ein neuer Wert *ist* hier eine Migration, weil er eine
-- neue Wertspalte in `health_trait_values` braucht. Die Tabelle steht trotzdem,
-- weil die Oberfläche einen Anzeigenamen je Art braucht und weil ein
-- Fremdschlüssel den Tippfehler abfängt; der CHECK am Wert nennt dieselben
-- Codes und ist die Stelle, die beim Erweitern mitgeändert werden muss.
CREATE TABLE health_value_kinds (
    code       text NOT NULL,
    name       text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT pk_health_value_kinds PRIMARY KEY (code),
    -- Genau die fünf, die `ck_health_trait_values_kind` auswertet.
    CONSTRAINT ck_health_value_kinds_code
        CHECK (code IN ('bool', 'text', 'date', 'period', 'document'))
);

-- Herkunft: die Erhebungsbögen selbst — Schulvertrag (08), Hortvertrag (09)
-- und die Erklärung zur außerunterrichtlichen Veranstaltung fragen dieselben
-- Feldarten in verschiedener Zusammenstellung ab. Kein Löschanker: keine
-- Personendaten.
-- Die Wertart ist hier und nicht am Wert festgelegt, damit derselbe Feldcode
-- nicht einmal als Text und einmal als Datum ankommen kann;
-- `health_trait_values` führt sie mit und ist per zusammengesetztem
-- Fremdschlüssel daran gebunden.
CREATE TABLE health_fields (
    health_field_id integer GENERATED ALWAYS AS IDENTITY,
    code            text NOT NULL,
    name            text NOT NULL,
    value_kind_code text NOT NULL,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    created_by      text NOT NULL,

    CONSTRAINT pk_health_fields      PRIMARY KEY (health_field_id),
    CONSTRAINT uq_health_fields_code UNIQUE (code),
    CONSTRAINT fk_health_fields_kind
        FOREIGN KEY (value_kind_code) REFERENCES health_value_kinds (code),
    CONSTRAINT uq_health_fields_kind UNIQUE (health_field_id, value_kind_code),
    CONSTRAINT ck_health_fields_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: diese Datei — die Tiefe je Kategorie, die vorher in vier Booleans
-- steckte. Kein Löschanker: keine Personendaten.
-- Ein Fragensatz (Schulvertrag, Hortvertrag, ein Ferienprogramm) wählt aus
-- diesen Paaren aus; welcher Anlass welche Felder erhebt, gehört zum
-- Erhebungsanlass und nicht hierher.
CREATE TABLE health_type_fields (
    health_trait_type_id integer NOT NULL,
    health_field_id      integer NOT NULL,
    -- Deaktiviert statt gelöscht: Wird ein Feld nicht mehr gefragt, bleiben die
    -- Werte stehen, die schon darauf zeigen (rules.md Abschnitt 3).
    is_active            boolean NOT NULL DEFAULT true,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_health_type_fields PRIMARY KEY (health_trait_type_id, health_field_id),
    CONSTRAINT fk_health_type_fields_type
        FOREIGN KEY (health_trait_type_id) REFERENCES health_trait_types (health_trait_type_id),
    CONSTRAINT fk_health_type_fields_field
        FOREIGN KEY (health_field_id) REFERENCES health_fields (health_field_id),
    CONSTRAINT ck_health_type_fields_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 08, 11 und 15 — die Ausschnitte, die dort je Rolle beschrieben
-- sind, und der Notfallausschnitt aus dem Gespräch mit der Geschäftsführung.
-- Kein Löschanker: keine Personendaten.
-- Die Sichten sind ausdrücklich NICHT mehr eine Leiter. In den Feldern sähen
-- sie noch nach einer aus; was sie auseinanderzieht, ist die Freigabe:
-- `school` und `care` tragen dieselben Felder und sehen trotzdem Verschiedenes,
-- weil die Eltern je Instanz entscheiden. Dazu das Attest, das eine Lehrkraft
-- als Vorliegen sieht und das Sekretariat im Klartext — dieselbe Zeile, zwei
-- Tiefen. Fünf Zeilen: `full`, `school`, `care`, `kitchen`, `emergency`.
-- `school` trägt Klassenleitung und Fachunterricht zusammen, seit beide
-- dasselbe sehen; `care` bleibt trotz derselben Felder eine eigene Zeile, weil
-- er ein eigenes Freigabeziel ist — Schule und Hort sind zwei Instanzen
-- desselben Bestands, und die Eltern entscheiden je Instanz.
-- Welche Rolle welchen Sichtkreis bekommt, steht in `api/gesundheit-api.md`
-- und wird über GRANTs vergeben; diese Tabelle sagt nur, was ein Sichtkreis
-- umfasst.
CREATE TABLE health_visibility_scopes (
    health_visibility_scope_id integer GENERATED ALWAYS AS IDENTITY,
    code                       text NOT NULL,
    name                       text NOT NULL,
    -- Wahr allein beim Notfallausschnitt: Er wird nicht über die Zuständigkeit
    -- für ein Kind vergeben, sondern steht jedem Mitarbeitenden für jedes Kind
    -- offen und wird stattdessen protokolliert (`health_emergency_accesses`).
    -- Er läuft deshalb auch nicht über `health_field_visibility`, sondern sieht
    -- **jedes** Feld jeder Kategorie — „der Mitarbeitende sieht im Notfall
    -- alles, nicht nur einen Ausschnitt" (02.09.2026). Als Zeilenmenge wäre das
    -- eine Vollständigkeit, die niemand hält: Ein neues Paar (Kategorie, Feld)
    -- wäre im Notfall unsichtbar, bis jemand die Zeile nachträgt, und der
    -- Fehler bliebe still. Die Sicht liefert stattdessen alles und reduziert
    -- allein die Dokumentfelder auf ihr Vorliegen — die zweite Auflage
    -- desselben Tages.
    is_emergency               boolean NOT NULL DEFAULT false,
    -- Wahr, wo die Eltern erst freigeben müssen: `school`, `care` und jede
    -- Anlass-Instanz. Falsch bei `full` — die Eltern und das Sekretariat lesen
    -- den Bestand, den sie selbst geschrieben haben —, bei `kitchen`, die ihre
    -- Freigabe von der Liste erbt, auf der das Kind steht, und bei `emergency`,
    -- der Freigaben ausdrücklich übergeht. Ein Häkchen hier und keine zweite
    -- Werteliste daneben: die wäre dieselben Dinge ein zweites Mal.
    needs_release              boolean NOT NULL DEFAULT false,
    is_active                  boolean NOT NULL DEFAULT true,
    created_at                 timestamptz NOT NULL DEFAULT now(),
    created_by                 text NOT NULL,

    CONSTRAINT pk_health_visibility_scopes      PRIMARY KEY (health_visibility_scope_id),
    CONSTRAINT uq_health_visibility_scopes_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel von `child_health_releases`
    -- und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_health_visibility_scopes_release
        UNIQUE (health_visibility_scope_id, needs_release),
    -- Trägt den zusammengesetzten Fremdschlüssel von `health_field_visibility`.
    CONSTRAINT uq_health_visibility_scopes_emergency
        UNIQUE (health_visibility_scope_id, is_emergency),
    CONSTRAINT ck_health_visibility_scopes_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: diese Datei. Kein Löschanker: keine Personendaten.
-- Eine Zeile je sichtbarem Feld, und mit `presence_only` drei Zustände statt
-- zweier: Zeile da heißt Wert sichtbar, Zeile fehlt heißt, das Feld gibt es für
-- diesen Sichtkreis nicht, Zeile mit Häkchen heißt „liegt vor, ist aber nicht
-- einsehbar". Der Fremdschlüssel geht auf das Paar und nicht auf Kategorie und
-- Feld einzeln: Sichtbar machen lässt sich nur, was die Kategorie überhaupt
-- erhebt.
CREATE TABLE health_field_visibility (
    health_visibility_scope_id integer NOT NULL,
    health_trait_type_id       integer NOT NULL,
    health_field_id            integer NOT NULL,
    -- Mitgeführt, damit der CHECK unten die Wertart sehen kann;
    -- `fk_health_field_visibility_kind` hält sie mit ihrer Quelle zusammen.
    value_kind_code            text NOT NULL,
    -- Ebenso mitgeführt, und immer falsch: Der Notfallausschnitt wird nicht
    -- über Zeilen geführt (siehe `health_visibility_scopes.is_emergency`), und
    -- eine Zeile für ihn wäre die halbe Wahrheit — sie sähe aus wie eine
    -- Begrenzung, die es nicht gibt.
    is_emergency               boolean NOT NULL DEFAULT false,
    -- „es muss ersichtlich sein, dass Attest vorliegt, Attest selber muss nicht
    -- zwingend einsehbar sein" (Datenschutzbeauftragter, 02.09.2026). Die Sicht
    -- liefert dann statt der `document_id` nur, ob eine hinterlegt ist. Als
    -- Zeile und nicht in der Route: RLS filtert Zeilen und keine Spalten, und
    -- läge die Regel im Anwendungscode, sähe kein Prüfskript sie.
    presence_only              boolean NOT NULL DEFAULT false,
    created_at                 timestamptz NOT NULL DEFAULT now(),
    created_by                 text NOT NULL,

    CONSTRAINT pk_health_field_visibility
        PRIMARY KEY (health_visibility_scope_id, health_trait_type_id, health_field_id),
    CONSTRAINT fk_health_field_visibility_scope
        FOREIGN KEY (health_visibility_scope_id, is_emergency)
        REFERENCES health_visibility_scopes (health_visibility_scope_id, is_emergency),
    CONSTRAINT fk_health_field_visibility_pair
        FOREIGN KEY (health_trait_type_id, health_field_id)
        REFERENCES health_type_fields (health_trait_type_id, health_field_id),
    CONSTRAINT fk_health_field_visibility_kind
        FOREIGN KEY (health_field_id, value_kind_code)
        REFERENCES health_fields (health_field_id, value_kind_code),
    -- Nur ein Dokumentfeld lässt sich auf sein Vorliegen zusammenstreichen; bei
    -- jeder anderen Wertart wäre der geleerte Wert die ganze Angabe, und die
    -- Zeile hieße dasselbe wie keine. — Alternative: das Häkchen ohne Prüfung
    -- zulassen; Preis: eine Konfiguration, die stillschweigend nichts tut.
    CONSTRAINT ck_health_field_visibility_presence
        CHECK (NOT presence_only OR value_kind_code = 'document'),
    CONSTRAINT ck_health_field_visibility_emergency CHECK (NOT is_emergency),
    CONSTRAINT ck_health_field_visibility_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 06 (Anmeldetag) — „der Masernnachweis, bei dem allein zählt, ob und
-- wie er vorlag". Kein Löschanker: keine Personendaten. „viele Wege" gehen
-- dafür durch (grenzkarte.md), deshalb eine Werteliste statt eines CHECK
-- (rules.md Abschnitt 3).
CREATE TABLE measles_presentation_types (
    measles_presentation_type_id integer GENERATED ALWAYS AS IDENTITY,
    code                         text NOT NULL,
    name                         text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active                     boolean NOT NULL DEFAULT true,

    CONSTRAINT pk_measles_presentation_types      PRIMARY KEY (measles_presentation_type_id),
    CONSTRAINT uq_measles_presentation_types_code UNIQUE (code)
);


-- ---------------------------------------------------------------------------
-- Antworten — was dieses Kind hat
-- ---------------------------------------------------------------------------

-- Herkunft: 08 (Schulvertrag) — „Die Gesundheitsangaben sind ein Bestand je
-- Kind …: freiwillig, mit einer vorgeschalteten Frage, ob überhaupt geantwortet
-- wird — ‚will nicht beantworten' ist eine eingetragene Antwort und kein leeres
-- Feld." Löschanker: das letzte bestätigte Ende dieses Kindes (03) — damit ist
-- die Löschzusage des Betreuungsvertrags eingehalten. Ein leeres Feld gibt es
-- nur bei den Kindern des Vollimports, „erkennbar daran, dass diese Strecke bei
-- ihnen nie lief".
CREATE TABLE child_health_records (
    child_health_record_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id               uuid NOT NULL,
    -- Zwei Zeitpunkte statt eines Ja/Nein, dieselbe Bauform wie Q1: die
    -- vergessene Frage darf nicht wie eine Verweigerung aussehen.
    answered_at            timestamptz,
    declined_at            timestamptz,
    -- „Der kurze handlungsrelevante Hinweis der Klassenlehrkraft … ein Feld am
    -- Bestand, nicht am Merkmal, und damit die einzige Angabe über das Kind
    -- statt über eine Erkrankung" (grenzkarte.md, „Zugriff, drei Bedingungen")
    -- — die zweite Spalte mit eigenem GRANT neben dem vollen Satz. Wer ihn
    -- liest, steht in api/gesundheit-api.md. Nicht zu verwechseln mit dem
    -- Feld „Beachten" an einem einzelnen Merkmal: Das schreiben die Eltern und
    -- es gilt für diese eine Angabe, dieser Satz kommt von der Klassenlehrkraft
    -- und gilt für das Kind.
    action_note            text,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_child_health_records PRIMARY KEY (child_health_record_id),
    CONSTRAINT fk_child_health_records_child
        FOREIGN KEY (child_id) REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT uq_child_health_records UNIQUE (child_id),
    -- Beantwortet oder ausdrücklich verweigert, nie beides.
    CONSTRAINT ck_child_health_records_answer
        CHECK (answered_at IS NULL OR declined_at IS NULL),
    -- Ein leerer Hinweis sieht aus wie ein geprüfter, und ihn lesen alle
    -- unterrichtenden Personen.
    CONSTRAINT ck_child_health_records_action_note CHECK (action_note <> ''),
    CONSTRAINT ck_child_health_records_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: das Gespräch mit der Geschäftsführung vom 01.09.2026 — die Eltern
-- beantworten nicht mehr pauschal alles oder nichts, sondern entscheiden je
-- Kategorie, ob und wie tief sie antworten. Löschanker: geht mit dem Bestand
-- und damit mit dem Kind (03).
-- Diese Tabelle trägt den Unterschied, den eine fehlende Zeile in
-- `health_traits` nicht mehr hergibt. Drei Zustände statt zweier:
--   Zeile mit `answered_at`, keine Merkmalszeile → gefragt, es gibt nichts.
--   Zeile mit `declined_at`                      → gefragt, will nicht sagen.
--   keine Zeile                                  → nie gefragt.
-- Der dritte ist über Monate der Normalfall, weil der Bestand von Hand
-- nachgetragen wird (soll-prozesse/README.md, „Nacharbeit"). Ohne diese
-- Unterscheidung läse eine leere Liste sich als Entwarnung — die eine
-- Fehldeutung, die bei Art.-9-Daten wirklich schadet.
CREATE TABLE child_health_answers (
    child_health_answer_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_health_record_id uuid NOT NULL,
    health_trait_type_id   integer NOT NULL,
    answered_at            timestamptz,
    declined_at            timestamptz,
    -- Abgeleitet und gespeichert, weil ein Fremdschlüssel eine Spalte braucht
    -- und keinen Ausdruck: `health_traits` hängt daran und kann deshalb nicht
    -- unter einer verweigerten Kategorie stehen. Ohne diese Klammer meldete die
    -- Ansicht „will nicht sagen", während im Bestand genau die Angabe steht,
    -- die die Familie nicht nennen wollte.
    is_answered            boolean NOT NULL GENERATED ALWAYS AS (answered_at IS NOT NULL) STORED,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_child_health_answers PRIMARY KEY (child_health_answer_id),
    CONSTRAINT fk_child_health_answers_record
        FOREIGN KEY (child_health_record_id)
        REFERENCES child_health_records (child_health_record_id) ON DELETE CASCADE,
    CONSTRAINT fk_child_health_answers_type
        FOREIGN KEY (health_trait_type_id) REFERENCES health_trait_types (health_trait_type_id),
    CONSTRAINT uq_child_health_answers UNIQUE (child_health_record_id, health_trait_type_id),
    -- Trägt den zusammengesetzten Fremdschlüssel von `health_traits`: Ein
    -- Merkmal kann seine Kategorie nicht von der Antwort abweichen lassen.
    CONSTRAINT uq_child_health_answers_type
        UNIQUE (child_health_answer_id, health_trait_type_id, is_answered),
    -- Und den zweiten: Über ihn reicht der Bestandsbezug bis zur Angabe
    -- durch, an der die Freigabe hängt (`health_trait_releases`).
    CONSTRAINT uq_child_health_answers_record
        UNIQUE (child_health_answer_id, child_health_record_id),
    CONSTRAINT ck_child_health_answers_answer
        CHECK (answered_at IS NULL OR declined_at IS NULL),
    CONSTRAINT ck_child_health_answers_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 08 (Schulvertrag) — „Je Punkt — Unverträglichkeit, Allergie,
-- chronische Erkrankung, Medikament, Notfallmedikament samt Notfallbeschreibung,
-- körperliche Einschränkung, Seh- oder Hörschwäche, therapeutische Maßnahme
-- samt Grund und Zeitraum, Zeckenentfernung — steht, was, ob ein Attest vorlag
-- und ob die Schule handeln darf." Löschanker: geht mit dem Bestand und damit
-- mit dem Kind (03).
-- Die Zeile trägt nichts mehr als ihre Zugehörigkeit: Was das Merkmal ist, wie
-- es heißt, ob ein Attest vorlag und ob die Schule handeln darf, steht als
-- Wertzeile daneben. Sie bleibt trotzdem eine eigene Tabelle, weil ein Kind
-- zwei Notfallmedikamente haben kann und die Werte des einen nicht mit denen
-- des anderen vermischt werden dürfen.
-- Die Schulbegleitung ist eine Merkmalsart dieser Liste und kein Freitext an
-- der Bewerbung: „er gehört zu den Gesundheits- und Förderdaten mit deren
-- Zugriffsprofil" (grenzkarte.md).
-- Die Zeckenentfernung ebenfalls: „Sie ist dort eine Kategorie wie jede andere,
-- nur mit genau einem Feld: der Erlaubnis" (grenzkarte.md).
CREATE TABLE health_traits (
    health_trait_id        uuid NOT NULL DEFAULT gen_random_uuid(),
    child_health_answer_id uuid NOT NULL,
    -- Mitgeführt, damit der Wert unten gegen das Paar (Kategorie, Feld) prüfen
    -- kann und damit der Index unten `allows_multiple` sieht;
    -- `fk_health_traits_answer` hält beides mit seiner Quelle zusammen.
    health_trait_type_id   integer NOT NULL,
    -- Ebenso mitgeführt, und immer wahr: Derselbe Fremdschlüssel trägt damit,
    -- dass diese Kategorie beantwortet ist. Eine Kategorie nachträglich auf
    -- „will nicht sagen" zu setzen scheitert, solange eine Angabe darunter
    -- steht — die gewollte Reihenfolge, denn die Kategorie wird am Stück
    -- geschrieben (api/gesundheit-api.md).
    is_answered            boolean NOT NULL DEFAULT true,
    -- Ebenso mitgeführt, und aus einem Grund, der zwei Tabellen weiter liegt:
    -- Eine Freigabe darf es nur geben, wo die vorgeschaltete Frage derselben
    -- Instanz freigegeben ist, und `health_trait_releases` prüft das mit einem
    -- zusammengesetzten Fremdschlüssel gegen `child_health_releases`. Dafür muss
    -- der Bestand hier stehen; `fk_health_traits_record` hält ihn mit seiner
    -- Quelle zusammen.
    child_health_record_id uuid NOT NULL,
    allows_multiple        boolean NOT NULL DEFAULT false,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_health_traits PRIMARY KEY (health_trait_id),
    CONSTRAINT fk_health_traits_answer
        FOREIGN KEY (child_health_answer_id, health_trait_type_id, is_answered)
        REFERENCES child_health_answers (child_health_answer_id, health_trait_type_id,
                                         is_answered)
        ON DELETE CASCADE,
    CONSTRAINT fk_health_traits_record
        FOREIGN KEY (child_health_answer_id, child_health_record_id)
        REFERENCES child_health_answers (child_health_answer_id, child_health_record_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_health_traits_type
        FOREIGN KEY (health_trait_type_id, allows_multiple)
        REFERENCES health_trait_types (health_trait_type_id, allows_multiple),
    -- Trägt den zusammengesetzten Fremdschlüssel von `health_trait_values`.
    CONSTRAINT uq_health_traits_type UNIQUE (health_trait_id, health_trait_type_id),
    -- Und den von `health_trait_releases`.
    CONSTRAINT uq_health_traits_record UNIQUE (health_trait_id, child_health_record_id),
    CONSTRAINT ck_health_traits_answered CHECK (is_answered),
    CONSTRAINT ck_health_traits_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- „zwei Notfallmedikamente desselben Kindes sind getrennt zu erlauben"
-- (grenzkarte.md, Q1) — bei allem anderen ist die zweite Zeile derselben
-- Kategorie ein Doppeleintrag und keine zweite Angabe.
CREATE UNIQUE INDEX ix_health_traits_single
    ON health_traits (child_health_answer_id)
    WHERE NOT allows_multiple;

-- Herkunft: das Gespräch mit der Geschäftsführung vom 01.09.2026 — „bei
-- chronischer Krankheit angeben und selber entscheiden, wie tief".
-- Löschanker: geht mit dem Merkmal und damit mit dem Kind (03).
-- Eine Zeile je beantwortetem Feld. Ein Feld ohne Zeile ist nicht beantwortet;
-- ob es überhaupt gefragt wurde, sagt `child_health_answers` eine Ebene höher.
-- Fünf Wertspalten statt einer generischen: Der Typ bleibt damit geprüft, die
-- Bereichsprüfung eines Zeitraums bleibt ein CHECK, und ein Attest bleibt ein
-- Fremdschlüssel auf das Dokument statt einer hingeschriebenen UUID.
CREATE TABLE health_trait_values (
    health_trait_value_id uuid NOT NULL DEFAULT gen_random_uuid(),
    health_trait_id       uuid NOT NULL,
    health_field_id       integer NOT NULL,
    -- Mitgeführt wie oben: Über sie greifen die beiden zusammengesetzten
    -- Fremdschlüssel, die den Wert an seine Kategorie und an seine Wertart
    -- binden. Auseinanderlaufen können sie nicht.
    health_trait_type_id  integer NOT NULL,
    value_kind_code       text NOT NULL,
    -- Trägt unter anderem die Erlaubnis („darf die Schule handeln"). Sie ist
    -- eine Einwilligung und braucht deshalb drei Zustände und einen Zeitpunkt
    -- (Art. 7 Abs. 1 DSGVO) — beides steht hier ohne zweites Spaltenpaar:
    -- erteilt und verweigert sind der Wert, „nicht gefragt" ist die fehlende
    -- Zeile, und der Zeitpunkt ist `created_at`. Eine später geänderte
    -- Erlaubnis ist dieselbe Zeile mit neuem Wert; ihren Verlauf hält das
    -- Änderungsprotokoll in wb-backend (grenzkarte.md, Q1).
    value_bool            boolean,
    value_text            text,
    value_date            date,
    value_period          daterange,
    value_document_id     uuid,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_health_trait_values PRIMARY KEY (health_trait_value_id),
    CONSTRAINT fk_health_trait_values_trait
        FOREIGN KEY (health_trait_id, health_trait_type_id)
        REFERENCES health_traits (health_trait_id, health_trait_type_id) ON DELETE CASCADE,
    -- Kein Feld an der falschen Kategorie: Eine Notfallbeschreibung an einer
    -- Zeckenerlaubnis gibt es nur, wenn die Zuordnung sie vorsieht.
    CONSTRAINT fk_health_trait_values_pair
        FOREIGN KEY (health_trait_type_id, health_field_id)
        REFERENCES health_type_fields (health_trait_type_id, health_field_id),
    -- Kein Wert im falschen Typ: Die Wertart kommt vom Feld und nicht vom
    -- Schreibenden.
    CONSTRAINT fk_health_trait_values_kind
        FOREIGN KEY (health_field_id, value_kind_code)
        REFERENCES health_fields (health_field_id, value_kind_code),
    -- Bewusst OHNE Bindung an das Kind des Bestands: Dass das Attest diesem
    -- Kind gehört, prüft die Route (api/gesundheit-api.md, „die Route prüft,
    -- dass das Dokument diesem Kind gehört"). Die strenge Fassung hieße,
    -- `child_id` über drei Ebenen mitzuführen und `documents` um ein UNIQUE zu
    -- erweitern — eine Änderung in `querschnitt-schema.sql`, wo `child_id`
    -- zudem leer sein darf und der Fremdschlüssel dann gar nicht prüfte. Das
    -- ist die benannte Auslassung dieser Datei, wie die letzte Admin-Rolle in
    -- stammdaten-schema.sql; das Prüfskript hält sie fest.
    CONSTRAINT fk_health_trait_values_document
        FOREIGN KEY (value_document_id) REFERENCES documents (document_id),
    -- Dasselbe Feld genau einmal je Merkmal.
    CONSTRAINT uq_health_trait_values UNIQUE (health_trait_id, health_field_id),
    -- Genau die Wertspalte, die die Wertart benennt — und genau eine. Diese
    -- Liste und `ck_health_value_kinds_code` sind das Paar, das beim Erweitern
    -- gemeinsam wächst.
    CONSTRAINT ck_health_trait_values_kind
        CHECK (CASE value_kind_code
                   WHEN 'bool'     THEN value_bool     IS NOT NULL
                   WHEN 'text'     THEN value_text     IS NOT NULL
                   WHEN 'date'     THEN value_date     IS NOT NULL
                   WHEN 'period'   THEN value_period   IS NOT NULL
                   WHEN 'document' THEN value_document_id IS NOT NULL
                   ELSE false
               END
               AND num_nonnulls(value_bool, value_text, value_date,
                                value_period, value_document_id) = 1),
    -- Eine leere Angabe ist keine: „will nicht sagen" steht eine Ebene höher.
    CONSTRAINT ck_health_trait_values_text CHECK (value_text <> ''),
    -- Ein Zeitraum, der vor seinem Anfang endet, ist keiner. Beide Grenzen
    -- bleiben freiwillig — eine laufende Maßnahme hat kein Ende, eine seit
    -- Jahren laufende oft keinen erinnerten Anfang —, deshalb prüft der CHECK
    -- den Bereich und nicht seine Ränder.
    CONSTRAINT ck_health_trait_values_period
        CHECK (value_period IS NULL OR NOT isempty(value_period)),
    CONSTRAINT ck_health_trait_values_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Der Lesepfad jeder Sicht: alle Werte eines Kindes, gefiltert über
-- (Kategorie, Feld) gegen den Sichtkreis der lesenden Rolle.
CREATE INDEX ix_health_trait_values_pair
    ON health_trait_values (health_trait_type_id, health_field_id);


-- ---------------------------------------------------------------------------
-- Freigabe — wem die Angabe überhaupt vorliegt
-- ---------------------------------------------------------------------------
-- Die zweite Bedingung neben dem Sichtkreis, und sie liegt in den Daten statt
-- in der Konfiguration: Der Sichtkreis sagt, welche Felder ein Kreis sehen
-- *kann*, die Freigabe, welche Angabe ihm überhaupt vorliegt. Schule und Hort
-- sind dabei zwei Instanzen desselben Bestands und nicht zwei Bestände — der
-- eine Bestand je Kind bleibt, und die Eltern entscheiden zweistufig: erst je
-- Instanz überhaupt, dann je Angabe.

-- Herkunft: 09 (Hortvertrag) — „die Eltern geben ihn dafür ausdrücklich frei
-- und dürfen die Freigabe verweigern" (grenzkarte.md, zum Hortvertrag).
-- Löschanker: geht mit dem Bestand und damit mit dem Kind (03).
-- Zwei Zeitpunkte statt eines Häkchens, dieselbe Bauform wie `child_health_records`
-- und aus demselben Grund: „beim Hort nicht gefragt" darf nicht aussehen wie
-- „beim Hort abgelehnt".
CREATE TABLE child_health_releases (
    child_health_release_id    uuid NOT NULL DEFAULT gen_random_uuid(),
    child_health_record_id     uuid NOT NULL,
    health_visibility_scope_id integer NOT NULL,
    -- Mitgeführt samt CHECK, damit eine Freigabe an einen Sichtkreis, der
    -- keiner ist, gar nicht erst entsteht — `full`, `kitchen` und `emergency`
    -- sind keine Freigabeziele.
    needs_release              boolean NOT NULL DEFAULT true,
    released_at                timestamptz,
    declined_at                timestamptz,
    -- Abgeleitet und gespeichert, weil ein Fremdschlüssel eine Spalte braucht
    -- und keinen Ausdruck: `health_trait_releases` hängt daran und kann deshalb
    -- nicht an einer abgelehnten Instanz stehen. Ein Widerruf setzt die
    -- Einzelfreigaben voraus — er scheitert, solange noch eine hängt, und das
    -- ist die gewollte Reihenfolge.
    is_released                boolean NOT NULL GENERATED ALWAYS AS (released_at IS NOT NULL) STORED,
    created_at                 timestamptz NOT NULL DEFAULT now(),
    created_by                 text NOT NULL,

    CONSTRAINT pk_child_health_releases PRIMARY KEY (child_health_release_id),
    CONSTRAINT fk_child_health_releases_record
        FOREIGN KEY (child_health_record_id)
        REFERENCES child_health_records (child_health_record_id) ON DELETE CASCADE,
    CONSTRAINT fk_child_health_releases_scope
        FOREIGN KEY (health_visibility_scope_id, needs_release)
        REFERENCES health_visibility_scopes (health_visibility_scope_id, needs_release),
    CONSTRAINT uq_child_health_releases
        UNIQUE (child_health_record_id, health_visibility_scope_id),
    -- Trägt den zusammengesetzten Fremdschlüssel von `health_trait_releases`.
    CONSTRAINT uq_child_health_releases_state
        UNIQUE (child_health_record_id, health_visibility_scope_id, is_released),
    CONSTRAINT ck_child_health_releases_needs CHECK (needs_release),
    CONSTRAINT ck_child_health_releases_answer
        CHECK (released_at IS NULL OR declined_at IS NULL),
    CONSTRAINT ck_child_health_releases_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 08 (Schulvertrag) und 09 (Hortvertrag) — der Bestand wird einmal
-- erhoben, und „wer ihn schon hat, gibt ihn für den nächsten Anlass nur frei"
-- (Dateikopf). Löschanker: die Angabe geht mit der letzten verfallenen
-- Freigabe, spätestens mit dem Kind (03).
-- Bewusst KEINE Anlass-Spalte daneben: Der Anlass *ist* der Sichtkreis, an den
-- freigegeben wird — dauerhaft an `school`, befristet an die Instanz einer
-- Veranstaltung —, und eine zweite Spalte trüge dieselbe Tatsache ein zweites
-- Mal. Dass eine Angabe zu mehreren Anlässen gehört, ist damit die zweite Zeile
-- und kein zweites Modell.
CREATE TABLE health_trait_releases (
    health_trait_id            uuid NOT NULL,
    health_visibility_scope_id integer NOT NULL,
    -- Mitgeführt wie oben: Über ihn und `is_released` greift der
    -- zusammengesetzte Fremdschlüssel, der eine Einzelfreigabe an einer
    -- abgelehnten Instanz ausschließt. — Alternative: die Regel in der
    -- Schreibschicht; Preis: kein Prüfskript sieht sie, und sie ist genau die,
    -- deren Bruch eine Art.-9-Angabe an eine Stelle trägt, die sie abgelehnt
    -- bekommen hat.
    child_health_record_id     uuid NOT NULL,
    is_released                boolean NOT NULL DEFAULT true,
    -- Ab hier fällt die Angabe aus jeder Alltagsansicht dieses Sichtkreises,
    -- bleibt aber stehen: eingeschränkt verarbeitet, lesbar allein zur
    -- Verteidigung von Rechtsansprüchen (Art. 17 Abs. 3 lit. e, Art. 18 DSGVO).
    -- Leer heißt „ohne Zweckende" — die Angabe, die der Schule dauerhaft
    -- vorliegt.
    purpose_ends_on            date,
    -- Ab hier ist sie fort. Für eine Anlass-Instanz vier Wochen nach dem Ende
    -- der Veranstaltung, für den Bestand am Kind drei Monate nach seinem
    -- Austritt (Datenschutzbeauftragter, 02./03.09.2026). Gerechnet wird der Tag
    -- beim Freigeben; die zwei Löschankündigungen davor und das Anhalten im
    -- Einzelfall stehen in soll-prozesse/hebel.md und werden hier nicht
    -- wiederholt.
    delete_on                  date,
    created_at                 timestamptz NOT NULL DEFAULT now(),
    created_by                 text NOT NULL,

    CONSTRAINT pk_health_trait_releases
        PRIMARY KEY (health_trait_id, health_visibility_scope_id),
    CONSTRAINT fk_health_trait_releases_trait
        FOREIGN KEY (health_trait_id, child_health_record_id)
        REFERENCES health_traits (health_trait_id, child_health_record_id) ON DELETE CASCADE,
    CONSTRAINT fk_health_trait_releases_release
        FOREIGN KEY (child_health_record_id, health_visibility_scope_id, is_released)
        REFERENCES child_health_releases (child_health_record_id, health_visibility_scope_id,
                                          is_released) ON DELETE CASCADE,
    CONSTRAINT ck_health_trait_releases_released CHECK (is_released),
    CONSTRAINT ck_health_trait_releases_dates
        CHECK (delete_on IS NULL OR purpose_ends_on IS NULL OR delete_on >= purpose_ends_on),
    CONSTRAINT ck_health_trait_releases_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Frage des Lösch-Laufs: welche Freigaben sind fällig.
CREATE INDEX ix_health_trait_releases_delete_on
    ON health_trait_releases (delete_on);

-- Herkunft: das Gespräch mit der Geschäftsführung vom 01.09.2026 — „das sollte
-- eine Taste sein bei dem Schüler, wodurch jeder Mitarbeiter im Notfall
-- nachschauen kann". Löschanker: geht mit dem Kind (03).
-- Der Notfallausschnitt wird nicht über die Zuständigkeit für ein Kind
-- vergeben, sondern steht jedem Mitarbeitenden für jedes Kind offen — eine
-- Genehmigungskette ist bei einem Anfall auf dem Schulhof das falsche Bauteil,
-- sie blockiert im einzigen Moment, der zählt. Der Schutz ist deshalb die
-- Nachvollziehbarkeit: Jeder Zugriff hinterlässt eine Zeile. Die Alternative
-- wäre, die Angaben vorsorglich breit herauszugeben, damit im Notfall jeder sie
-- hat — dann wüsste das ganze Kollegium dauerhaft von jeder Erkrankung.
-- Bewusst KEINE Spalte für einen eingetippten Grund: Er wäre im Ernstfall nicht
-- zu tippen und im Missbrauchsfall nicht wahr.
-- Die Konstruktion ist am 02.09.2026 bestätigt worden, mit drei Auflagen: Der
-- Mitarbeitende sieht im Notfall **alles**, nicht nur einen Ausschnitt, und ohne
-- Rücksicht auf Freigaben — sonst blendete eine Hort-Ablehnung genau den
-- Zugriff, der im Ernstfall zählt; dass ein ärztliches Attest vorliegt, muss
-- ersichtlich sein, ohne dass das Attest selbst einsehbar wäre
-- (`health_field_visibility.presence_only`); und **jede Betätigung wird der
-- Geschäftsführung gemeldet**,
-- nicht nur protokolliert. Adressat und Takt dieser Meldung sollen anpassbar
-- bleiben — nach der Anlaufzeit womöglich ein Monats- oder Quartalsbericht
-- statt einer Meldung je Fall; die Zeile hier trägt beides gleich gut, weil sie
-- den Zeitpunkt führt und nicht den Versand.
-- Die Aufbewahrung des Protokolls steht seit dem 03.09.2026: **es geht mit dem
-- Kind**, wie die Gesundheitsangaben selbst. Ein Vorfall im September 2026 an
-- einem Kind, das 2031 abgeht, beginnt seine Frist also 2031 und nicht 2026 —
-- gerechnet wird ab dem Austritt, nicht ab dem Zugriff. Die notierte „Frist 1 h"
-- war nie die Aufbewahrung, sondern die Meldung an die Geschäftsführung; sie
-- geht inzwischen unmittelbar beim Auslösen heraus.
CREATE TABLE health_emergency_accesses (
    health_emergency_access_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id                   uuid NOT NULL,
    accessed_at                timestamptz NOT NULL DEFAULT now(),
    created_at                 timestamptz NOT NULL DEFAULT now(),
    -- Wer nachgesehen hat. Immer eine Person mit Schulkonto: Eltern haben
    -- diesen Weg nicht, und `system:` kann keinen Notfall haben.
    created_by                 text NOT NULL,

    CONSTRAINT pk_health_emergency_accesses PRIMARY KEY (health_emergency_access_id),
    CONSTRAINT fk_health_emergency_accesses_child
        FOREIGN KEY (child_id) REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT ck_health_emergency_accesses_created_by CHECK (created_by ~ '^entra:')
);

-- Herkunft: grenzkarte.md — „Der Masernschutznachweis ist gesetzlich
-- verpflichtend (§20 IfSG) … er braucht Vorlagedatum und Vorlageart in Domäne
-- 9." Löschanker: geht mit dem Kind (03). Bewusst KEINE Q2-Zeile: „Es entsteht
-- also gar kein Dokument, Q2 trägt den Nachweis nicht." Fehlt er, bleibt das
-- als fehlende Zeile sichtbar — auch nach der Freigabe, weil die Meldepflicht
-- des Trägers nicht mit ihr endet (09). Bewusst KEINE Spalte für die erfolgte
-- Meldung ans Gesundheitsamt: Der Meldefall ist genau der ohne Zeile, an der
-- sie hängen könnte. Sie wird deshalb eine Q5-Aufgabe beim Sekretariat mit dem
-- Kind als Bezug (09, `querschnitt-schema.sql`) — eine Aufgabenart ohne
-- Fremdsystem dahinter.
CREATE TABLE measles_proofs (
    measles_proof_id             uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id                     uuid NOT NULL,
    presented_on                 date NOT NULL,
    measles_presentation_type_id integer NOT NULL,
    created_at                   timestamptz NOT NULL DEFAULT now(),
    created_by                   text NOT NULL,

    CONSTRAINT pk_measles_proofs PRIMARY KEY (measles_proof_id),
    CONSTRAINT fk_measles_proofs_child
        FOREIGN KEY (child_id) REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT fk_measles_proofs_type
        FOREIGN KEY (measles_presentation_type_id)
        REFERENCES measles_presentation_types (measles_presentation_type_id),
    -- 06: „der Masernnachweis, bei dem allein zählt, ob und wie er vorlag" —
    -- je Kind genau eine Zeile, die die Frage „liegt er vor" ohne Sortierung
    -- beantwortet.
    CONSTRAINT uq_measles_proofs UNIQUE (child_id),
    CONSTRAINT ck_measles_proofs_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------
-- Keine. Die Aufbewahrung des Notfallprotokolls stand hier zuletzt als Frage
-- offen; sie ist entschieden — es geht mit dem Kind (03, 08, und der Kommentar
-- an `health_emergency_accesses`), gerechnet ab dem Austritt und nicht ab dem
-- Zugriff.
--
-- Der Erhebungsanlass ist keine offene Frage mehr: Er ist der Sichtkreis, an
-- den freigegeben wird, und Zweckende wie Löschtermin stehen an der Freigabe
-- (`health_trait_releases`). Was noch fehlt, ist der Anlassgeber — die Domäne
-- der außerunterrichtlichen Veranstaltungen legt die Instanz an, an die eine
-- Fahrt freigeben lässt. Bis dahin gibt es die zwei dauerhaften Instanzen
-- `school` und `care`, und die drei Monate nach dem Austritt des Kindes sind
-- der einzige gerechnete Löschtermin. Ein schulfremdes Kind hat keinen Austritt
-- — bei ihm gilt die eigene Frist aus ferien-schema.sql, vier Wochen nach dem
-- letzten gebuchten Termin.
