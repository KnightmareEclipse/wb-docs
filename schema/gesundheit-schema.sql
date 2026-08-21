-- Gesundheits- und Förderdaten (Domäne 9) — ein Bestand je Kind, den heute
-- sechs Formulare getrennt erheben.
-- Lesepfad: `child_health_records` trägt je Kind die vorgeschaltete Frage, ob
-- überhaupt geantwortet wird, und den handlungsrelevanten Hinweis für alle
-- unterrichtenden Personen. Daran hängen die einzelnen `health_traits` — eine
-- Zeile je Merkmal statt rund dreißig Spalten. `measles_proofs` steht daneben,
-- weil der Nachweis kein Merkmal ist.
--
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus. Der Satz
-- entsteht mit dem Schulvertrag (08), bei einem externen Hortkind mit dem
-- Hortvertrag (09); erhoben wird er einmal je Kind, nicht je Vertrag.
-- Der Behandlungszeitraum steht an der therapeutischen Maßnahme: Block 08 führt
-- ihn in „Was dabei erhoben wird" auf — „therapeutische Maßnahme samt Grund und
-- Zeitraum". grenzkarte.md wollte ihn weglassen („bei Art.-9-Daten wird ein
-- nicht mehr zutreffendes Merkmal gelöscht statt datiert"); der Block ist
-- jünger und schlägt die Karte, dieselbe Reihenfolge wie bei der
-- Zeckenentfernung unten. Der Satz aus der Karte gilt weiter für das Merkmal
-- selbst: Wer die Maßnahme nicht mehr hat, verliert die Zeile und nicht bloß
-- ihr Enddatum. Bewusst KEINE Kopie des Masernnachweises: „festgehalten wird
-- nur, ob er dokumentiert wurde und wie er vorgelegt wurde".


-- Herkunft: grenzkarte.md, „Gesundheitsmerkmal (9)" — „Also eine Zeile je
-- Merkmal mit Merkmalsart als Lookup, nicht rund dreißig Spalten — eine weitere
-- Merkmalsart ist damit ein Datensatz statt einer Migration." Kein Löschanker:
-- keine Personendaten. Audit-Spalten, weil vier der Flags steuern, welche
-- Spalten des Merkmals überhaupt gelten; `health_traits` führt genau diese vier
-- mit und ist per zusammengesetztem Fremdschlüssel daran gebunden (rules.md
-- Abschnitt 1, Ausnahme in Abschnitt 3).
CREATE TABLE health_trait_types (
    health_trait_type_id integer GENERATED ALWAYS AS IDENTITY,
    code                 text NOT NULL,
    name                 text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active             boolean NOT NULL DEFAULT true,
    -- Wahr, wo die Schule handeln darf oder nicht — Medikament,
    -- Notfallmedikament, therapeutische Maßnahme; dann trägt die Zeile ihre
    -- eigene Erlaubnis mit beiden Antworten.
    needs_permission     boolean NOT NULL DEFAULT false,
    -- Wahr bei Medikamenten: nur dort ist „ob das Kind sie selbst nimmt" eine
    -- Frage (08).
    is_medication        boolean NOT NULL DEFAULT false,
    -- Wahr, wo ein Behandlungsgrund erhoben wird (therapeutische Maßnahme).
    has_treatment_reason boolean NOT NULL DEFAULT false,
    -- Wahr allein beim Notfallmedikament: 08 führt es als eigenen Punkt neben
    -- dem Medikament — „Notfallmedikament samt Notfallbeschreibung" —, und nur
    -- dort gibt es eine Notfallbeschreibung.
    is_emergency_medication boolean NOT NULL DEFAULT false,
    -- Wahr bei den Alltagsangaben, die Lehrkräfte und Hort sehen dürfen —
    -- „Unverträglichkeit, Allergie, Notfallmedikation samt Erlaubnis,
    -- Zeckenentfernung" (08); sie steuert die engere Sicht, ohne dass ein
    -- zweites Berechtigungssystem entsteht.
    is_everyday_relevant boolean NOT NULL DEFAULT false,
    -- Wahr bei dem, was die Küche sieht: „die Mensa sieht davon allein diese
    -- beiden Punkte, den schmalsten Ausschnitt, den 08 kennt: ohne
    -- Notfallmedikation, ohne Diagnose, ohne Attestlage" (11) — die beiden
    -- Punkte sind Unverträglichkeit und Allergie, die 11 im Satz davor nennt. Das sind drei Stufen und nicht zwei; ohne diese Spalte läse die
    -- Mensa denselben Ausschnitt wie der Hort, und das wäre bei Art.-9-Daten
    -- eine Über-Offenlegung.
    is_kitchen_relevant  boolean NOT NULL DEFAULT false,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_health_trait_types      PRIMARY KEY (health_trait_type_id),
    CONSTRAINT uq_health_trait_types_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel von `health_traits` und ist
    -- deshalb zusätzlich zum Primärschlüssel nötig. `is_everyday_relevant` und
    -- `is_kitchen_relevant` stehen bewusst nicht darin: sie steuern je eine
    -- Ansicht, keine Spalte.
    CONSTRAINT uq_health_trait_types_flags
        UNIQUE (health_trait_type_id, needs_permission, is_medication,
                has_treatment_reason, is_emergency_medication),
    -- „den schmalsten Ausschnitt, den 08 kennt" (11): was die Küche sieht, sieht
    -- der Hort ohnehin — die engere Sicht liegt in der weiteren.
    CONSTRAINT ck_health_trait_types_kitchen
        CHECK (NOT is_kitchen_relevant OR is_everyday_relevant),
    CONSTRAINT ck_health_trait_types_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
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
    -- „ein kurzer handlungsrelevanter Hinweis ('keine Sprungübungen',
    -- 'Notfallmedikament im Sekretariat'), den die Klassenlehrkraft formuliert
    -- und den alle unterrichtenden Personen sehen"
    -- — die zweite Spalte mit eigenem GRANT neben dem vollen Satz
    -- (grenzkarte.md, „Zugriff, zweistufig").
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
    CONSTRAINT ck_child_health_records_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 08 (Schulvertrag) — „Je Punkt — Unverträglichkeit, Allergie,
-- chronische Erkrankung, Medikament, Notfallmedikament samt Notfallbeschreibung,
-- körperliche Einschränkung, Seh- oder Hörschwäche, therapeutische Maßnahme
-- samt Grund und Zeitraum, Zeckenentfernung — steht, was, ob ein Attest vorlag
-- und ob die Schule handeln darf." Löschanker: geht mit dem Bestand und damit
-- mit dem Kind (03).
-- Die Schulbegleitung ist eine Merkmalsart dieser Liste und kein Freitext an
-- der Bewerbung: „er gehört zu den Gesundheits- und Förderdaten mit deren
-- Zugriffsprofil" (grenzkarte.md).
-- Die Zeckenentfernung ebenfalls, und hier gegen grenzkarte.md: die führt sie
-- als Q1-Zweck („Erlaubnis, kein Gesundheitsmerkmal"), Block 08 zählt sie unter
-- den Punkten dieses Bestands auf und unter dem, was Lehrkräfte und Hort im
-- Alltag sehen. Der Block ist jünger und schlägt die Karte. Sie ist damit eine
-- Merkmalsart mit `needs_permission` — „ob die Schule handeln darf" ist bei ihr
-- die ganze Angabe — und `is_everyday_relevant`. Dieselbe Reihenfolge trägt den
-- Behandlungszeitraum der therapeutischen Maßnahme (Begründung im Dateikopf).
CREATE TABLE health_traits (
    health_trait_id        uuid NOT NULL DEFAULT gen_random_uuid(),
    child_health_record_id uuid NOT NULL,
    health_trait_type_id   integer NOT NULL,
    -- Die vier Flags der Merkmalsart, hier mitgeführt, damit die CHECKs unten
    -- sie sehen können; `fk_health_traits_type` hält sie mit ihrer Quelle
    -- zusammen (rules.md Abschnitt 1). Auseinanderlaufen können sie nicht.
    needs_permission       boolean NOT NULL DEFAULT false,
    is_medication          boolean NOT NULL DEFAULT false,
    has_treatment_reason   boolean NOT NULL DEFAULT false,
    is_emergency_medication boolean NOT NULL DEFAULT false,
    -- Was genau — die Angabe der Eltern zu diesem Merkmal.
    description            text NOT NULL,
    -- Nur bei therapeutischen Maßnahmen: „therapeutische Maßnahme samt Grund und
    -- Zeitraum" (08). Beide Grenzen sind freiwillig — eine laufende Maßnahme
    -- hat kein Ende, und eine seit Jahren laufende oft keinen erinnerten
    -- Anfang; dasselbe Flag steuert alle drei Spalten.
    treatment_reason       text,
    treatment_from         date,
    treatment_until        date,
    -- „ob ein Attest vorlag" (08) — und nicht, ob eines abgelegt ist: gezeigt
    -- und wieder mitgenommen wird es wie der Masernnachweis unten, bei dem
    -- „Es entsteht also gar kein Dokument". Wo eines abgelegt wurde, steht es
    -- daneben als Q2-Zeile; der CHECK unten lässt keine ohne dieses Häkchen zu.
    has_certificate        boolean NOT NULL DEFAULT false,
    certificate_document_id uuid,
    -- Die Erlaubnis gilt je Merkmal und hat deshalb keinen Anker neben sich:
    -- „ein mitten im Schuljahr ergänztes Notfallmedikament hat kein
    -- unterschriebenes Blatt" (grenzkarte.md, „Drei Zustände").
    permission_granted_at  timestamptz,
    permission_declined_at timestamptz,
    -- Nur bei Medikamenten: ob das Kind sie selbst nimmt (08).
    self_administered      boolean,
    -- Nur beim Notfallmedikament: was im Notfall zu tun ist.
    emergency_description  text,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_health_traits PRIMARY KEY (health_trait_id),
    CONSTRAINT fk_health_traits_record
        FOREIGN KEY (child_health_record_id) REFERENCES child_health_records (child_health_record_id) ON DELETE CASCADE,
    CONSTRAINT fk_health_traits_type
        FOREIGN KEY (health_trait_type_id, needs_permission, is_medication,
                     has_treatment_reason, is_emergency_medication)
        REFERENCES health_trait_types (health_trait_type_id, needs_permission,
                     is_medication, has_treatment_reason, is_emergency_medication),
    CONSTRAINT fk_health_traits_certificate
        FOREIGN KEY (certificate_document_id) REFERENCES documents (document_id),
    CONSTRAINT ck_health_traits_description CHECK (description <> ''),
    -- Erteilt oder verweigert, nie beides; leer heißt „noch nicht gefragt".
    CONSTRAINT ck_health_traits_permission
        CHECK (permission_granted_at IS NULL OR permission_declined_at IS NULL),
    -- Ein Attestdokument gibt es nur, wo ein Attest vorlag.
    CONSTRAINT ck_health_traits_certificate
        CHECK (certificate_document_id IS NULL OR has_certificate),
    -- Die vier Regeln, die die Flags der Merkmalsart benennen: „ob die Schule
    -- handeln darf", „bei Medikamenten dazu, ob das Kind sie selbst nimmt",
    -- „therapeutische Maßnahme samt Grund" (08) und die Notfallbeschreibung,
    -- die es nur beim Notfallmedikament gibt.
    CONSTRAINT ck_health_traits_permission_type
        CHECK (needs_permission
               OR (permission_granted_at IS NULL AND permission_declined_at IS NULL)),
    CONSTRAINT ck_health_traits_self_administered
        CHECK (is_medication OR self_administered IS NULL),
    CONSTRAINT ck_health_traits_treatment_reason
        CHECK (has_treatment_reason OR treatment_reason IS NULL),
    CONSTRAINT ck_health_traits_treatment_period
        CHECK (has_treatment_reason
               OR (treatment_from IS NULL AND treatment_until IS NULL)),
    CONSTRAINT ck_health_traits_treatment_order
        CHECK (treatment_from IS NULL OR treatment_until IS NULL
               OR treatment_until >= treatment_from),
    CONSTRAINT ck_health_traits_emergency
        CHECK (is_emergency_medication OR emergency_description IS NULL),
    CONSTRAINT ck_health_traits_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Ein Kind kann zwei Notfallmedikamente haben, aber nicht zweimal dieselbe
-- Angabe: „zwei Notfallmedikamente desselben Kindes sind getrennt zu erlauben"
-- (grenzkarte.md, Q1) — unterschieden werden sie an ihrer Beschreibung.
CREATE UNIQUE INDEX ix_health_traits_unique
    ON health_traits (child_health_record_id, health_trait_type_id, description);

-- Herkunft: grenzkarte.md — „Der Masernschutznachweis ist gesetzlich
-- verpflichtend (§20 IfSG) … er braucht Vorlagedatum und Vorlageart in Domäne
-- 9." Löschanker: geht mit dem Kind (03). Bewusst KEINE Q2-Zeile: „Es entsteht
-- also gar kein Dokument, Q2 trägt den Nachweis nicht." Fehlt er, bleibt das
-- als fehlende Zeile sichtbar — auch nach der Freigabe, weil die Meldepflicht
-- des Trägers nicht mit ihr endet (09).
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
-- Keine eigenen. Die Aufbewahrungsfrist dieses Bestands steht fest: „die
-- Gesundheitsangaben nach dem letzten bestätigten Ende dieses Kindes" (03).
