-- Klassenorganisation (Domäne 13) — die Elternvertretung je Klasse, und sonst
-- nichts.
-- Lesepfad: eine Tabelle. `class_representatives` verbindet Klasse, Schuljahr
-- und Person; alles Weitere derselben Liste steht schon — Klassenlehrkraft als
-- `classes.class_teacher_id`, Raum als `classes.room`, beide in
-- stammdaten-schema.sql.
--
-- Setzt stammdaten-schema.sql voraus.


-- Herkunft: 16 (Elternvertretung) — „Je Klasse und Schuljahr die gewählten
-- Personen (Pflicht, sobald gewählt; mehrere ohne Rangfolge)." Löschanker: „Der
-- Eintrag hängt an Klasse und Person und verschwindet mit der Person"; die
-- Klassen vergangener Schuljahre bleiben stehen und tragen für sich keine
-- Personendaten. Bewusst KEINE Spalten für Wahltag, Protokoll, Stimmenzahl und
-- Amtstitel — „mehr nicht" — und keine geprüfte Höchstzahl: „zwei oder drei ist
-- die Praxis, keine Regel".
CREATE TABLE class_representatives (
    class_representative_id uuid NOT NULL DEFAULT gen_random_uuid(),
    class_id                integer NOT NULL,
    -- Das Amt „gilt für ein Schuljahr: Es beginnt mit dem Eintrag und endet am
    -- 31. Juli von selbst" — das Schuljahr trägt das Ende, kein Lauf und kein
    -- Datumsfeld.
    school_year             smallint NOT NULL,
    -- Eine sorgeberechtigte Person aus dem Bestand, ausgewählt und nicht
    -- eingetippt. Bewusst ohne Prüfung, ob sie noch ein Kind in dieser Klasse
    -- hat: „Wechselt ein Kind die Klasse oder geht es ab, endet das Amt nicht
    -- von selbst."
    person_id               uuid NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_class_representatives PRIMARY KEY (class_representative_id),
    CONSTRAINT fk_class_representatives_class
        FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE,
    CONSTRAINT fk_class_representatives_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    -- Dieselbe Person hält dasselbe Amt nur einmal; zwei Ämter in zwei Klassen
    -- sind ausdrücklich möglich (16, Sonderfälle).
    CONSTRAINT uq_class_representatives UNIQUE (class_id, school_year, person_id),
    CONSTRAINT ck_class_representatives_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Frage, die 14 stellt: „wer im Schuljahr Elternvertreter war".
CREATE INDEX ix_class_representatives_year
    ON class_representatives (school_year, person_id);


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------
-- Keine. Bewusst KEINE zweite Tabelle für ein Gremium über der Klasse: „Und kein
-- Gremium über der Klassenvertretung: Gesamtelternbeirat, Vorsitz,
-- Schulkonferenz gibt es bisher nicht, und ihre Besetzung im System zu führen
-- wäre auch dann nicht das, was die Schule braucht" (16). Geführt wird die
-- Elternvertretung je Klasse und Schuljahr, mehr nicht. Käme je eines dazu,
-- wäre es eine Tabelle daneben und kein Umbau dieser einen.
