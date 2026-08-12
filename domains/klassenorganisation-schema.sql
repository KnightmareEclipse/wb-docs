-- Klassenorganisations-Schema (Domäne 13, fachdomaenen.md Abschnitt 6): die
-- Elternvertretung je Klasse. Konzeptioneller Entwurf zu
-- domains/klassenorganisation.md und domains/grenzkarte.md — konkreter als
-- Prosa, aber noch kein Alembic-Migrationscode.
--
-- SETZT domains/stammdaten-schema.sql VORAUS: es referenziert classes und
-- guardians und nutzt set_row_audit() samt app.actor-Präfixregel.
--
-- Die Domäne bringt bewusst NUR diese eine Verknüpfung mit: Klassenlehrer:in
-- und Klassenzimmer der realen Klassenliste stehen bereits als
-- classes.class_teacher_id und classes.room in Stammdaten
-- (domains/grenzkarte.md, „Elternvertretung").

-- Elternvertreter:in und Stellvertretung je Klasse — eine Verknüpfung
-- Erziehungsberechtigte:r ↔ Klasse, kein Stammdatum der Person. Ohne
-- Schuljahres-Historie wie überall: die Tabelle trägt den aktuellen Stand, ein
-- Wechsel nach der Neuwahl ist ein UPDATE auf derselben Amtszeile.
--
-- is_deputy ist die strukturelle Zweiteilung des Amts (Vertretung /
-- Stellvertretung), keine umbenennbare Kategorie — deshalb Boolean statt
-- Lookup (rules.md Abschnitt 3). Der Primärschlüssel (class_id, is_deputy)
-- macht das Amt selbst zur Identität der Zeile: je Klasse höchstens eine
-- Vertretung und eine Stellvertretung. Das UNIQUE daneben verhindert, dass
-- dieselbe Person beide Ämter derselben Klasse hält; in verschiedenen Klassen
-- (Geschwister) bleibt sie wählbar.
--
-- guardian_id zeigt auf guardians, nicht auf persons: gewählt wird aus den
-- Erziehungsberechtigten. Dass die Person tatsächlich ein Kind in DIESER
-- Klasse hat, führt über guardians → family_guardians → children.class_id und
-- ist damit wie contract_responses.person_id (anmeldung-schema) nur als
-- Trigger ausdrückbar — die Bindung liegt in der Eingabemaske, die nur Eltern
-- der Klasse anbietet.
--
-- Beide Fremdschlüssel ON DELETE CASCADE wie family_guardians: das Amt ist
-- eine Zeile ohne Eigenleben — verschwindet die Person durch den Lösch-Job
-- oder die Klassenzeile, ist es gegenstandslos.
CREATE TABLE class_parent_representatives (
    class_id    integer NOT NULL REFERENCES classes(class_id) ON DELETE CASCADE,
    is_deputy   boolean NOT NULL DEFAULT false,
    guardian_id uuid NOT NULL REFERENCES guardians(guardian_id) ON DELETE CASCADE,
    created_at  timestamptz NOT NULL DEFAULT now(),
    created_by  text NOT NULL,
    updated_at  timestamptz NOT NULL DEFAULT now(),
    updated_by  text NOT NULL,
    PRIMARY KEY (class_id, is_deputy),
    UNIQUE (class_id, guardian_id)
);
CREATE INDEX ON class_parent_representatives (guardian_id);

-- ---------------------------------------------------------------------------
-- Audit-Trigger
-- ---------------------------------------------------------------------------
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON class_parent_representatives
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
