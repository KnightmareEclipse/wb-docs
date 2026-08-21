-- Elternbonus Elternmitarbeit (Domäne 11) — gezählt werden bestätigte Stunden
-- je Familie und Schuljahr.
-- Lesepfad: eine Tabelle. `parent_work_entries` trägt je Eintrag Datum, Dauer,
-- Tätigkeit und die namentlich benannte Person, die ihn bestätigt. Alles
-- Weitere wird gerechnet oder anderswo gelesen: Monatsbetrag und
-- Pflichtstunden als `configured_values`, die Elternvertreter als
-- `class_representatives`, die Mitarbeiterfamilien als `employees` samt Haus.
--
-- Setzt stammdaten-schema.sql, querschnitt-schema.sql und
-- klassenorganisation-schema.sql voraus.
-- Bewusst KEINE Jahresliste als Tabelle: sie ist frisch erzeugt, und „unsere
-- Zahl ist ein Vorschlag" — maßgeblich ist die Abrechnung der Buchhaltung.
-- Bewusst KEINE Kategorie und kein Bewertungsschlüssel je Tätigkeit: „eine
-- Stunde ist eine Stunde, gleich wobei". Bewusst KEINE abweichende
-- Pflichtstundenzahl je Familie: „ein Härtefall wird über das Schulgeld
-- erlassen und damit außerhalb".


-- Herkunft: 14 (Elternbonus) — „Je Eintrag Datum, Stundenzahl in halben
-- Stunden, die Tätigkeit in einem Satz und die bestätigende Person (alles
-- Pflicht), dazu ihr Ja oder Nein samt Zeitpunkt — mehr nicht." Löschanker: wie
-- beim Putzdienst „einmal jährlich zum Schuljahresanfang fällt nicht das gerade
-- vergangene Schuljahr, sondern das davor" — die Frist rechnet am Schuljahr und
-- nicht am Austritt des Kindes (03). Bewusst KEIN Begründungsfeld bei der
-- Ablehnung: „Abgelehnt wird ohne Begründung im System."
CREATE TABLE parent_work_entries (
    parent_work_entry_id uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Der Bonus hängt an der Familie: „gezählt wird für die Familie, gleich wer
    -- gearbeitet hat".
    family_id            uuid NOT NULL,
    -- Das Schuljahr, dem die Stunde zugerechnet wird; gerechnet wird nach dem
    -- 31. Juli, und „Mehrgeleistete Stunden verfallen ebenso und werden nicht
    -- ins nächste Schuljahr übernommen". Es folgt aus `worked_on` und steht
    -- trotzdem hier, weil Zählung und Löschfrist an ihm hängen; der CHECK unten
    -- hält es an seinem Datum fest (rules.md Abschnitt 1).
    school_year          smallint NOT NULL,
    worked_on            date NOT NULL,
    -- In halben Stunden gezählt statt als Dezimalzahl: so gibt es keinen Wert,
    -- den das Formular zulässt und der Block nicht kennt.
    half_hours           smallint NOT NULL,
    -- Die Tätigkeit in einem Satz; „insbesondere keine Kategorie und kein
    -- Schlüssel".
    activity             text NOT NULL,
    -- „Genau die gewählte Person bestätigt oder lehnt ab; niemand sonst … kann
    -- ihn abnehmen" — einer der beiden Fälle in hebel.md, in denen eine Aufgabe
    -- an einem Menschen hängt und nicht an einer Rolle. Wählbar ist nur, wer
    -- eine Mitarbeiterrolle der Schule trägt; das prüft die Anwendung, weil das
    -- Haus an `employees` und die Rolle an `employee_roles` steht.
    confirming_employee_id uuid,
    -- „Was seinen Namen anderswo trägt, überlebt ihn: eine bestätigte
    -- Mitarbeitsstunde (14) folgt ihrer eigenen Frist" (00). Solange es den
    -- Mitarbeitendeneintrag gibt, steht der Name dort und hier nicht — sonst
    -- wäre er ein zweiter Ort für dieselbe Tatsache. Der Lösch-Lauf trägt ihn
    -- ein, bevor er den Eintrag löscht; der CHECK unten erzwingt genau diese
    -- Reihenfolge, weil das Nullsetzen sonst an ihm scheitert.
    confirming_employee_name text,
    -- Zwei Zeitpunkte statt eines Ja/Nein: „Ein unbestätigter Eintrag zählt
    -- auch dann nicht, wenn ihm niemand widersprochen hat."
    confirmed_at         timestamptz,
    rejected_at          timestamptz,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_parent_work_entries PRIMARY KEY (parent_work_entry_id),
    -- „Schuljahr = Startjahr … 1.8.2026–31.7.2027" (stammdaten-schema.sql, 04):
    -- eine Stunde vom 5. Oktober 2026 gehört ins Schuljahr 2026 und in kein
    -- anderes. Einen Spielraum für den nachgereichten Zettel gibt es nicht —
    -- 14: „was später kommt oder liegen bleibt, zählt nicht"; die Frist trifft
    -- den Eintrag, nicht die Zurechnung.
    CONSTRAINT ck_parent_work_entries_school_year
        CHECK (school_year = EXTRACT(year FROM worked_on)::smallint
                             - CASE WHEN EXTRACT(month FROM worked_on) >= 8 THEN 0 ELSE 1 END),
    -- Bewusst OHNE Cascade auf die Familie: die Zeile folgt der Schuljahresfrist
    -- und nicht dem Austritt (03, „ebenso die Elternbonus-Daten (14), die
    -- dieselbe Frist tragen") — dieselbe Entscheidung wie im Putzdienst.
    CONSTRAINT fk_parent_work_entries_family
        FOREIGN KEY (family_id) REFERENCES families (family_id),
    -- Der Eintrag überlebt den Mitarbeitenden; von ihm bleibt der Name daneben.
    CONSTRAINT fk_parent_work_entries_confirmer
        FOREIGN KEY (confirming_employee_id) REFERENCES employees (employee_id)
        ON DELETE SET NULL,
    -- Die bestätigende Person ist Pflicht: entweder der Mitarbeitendeneintrag
    -- oder, wenn der fort ist, sein Name. Nie keines von beiden.
    CONSTRAINT ck_parent_work_entries_confirmer
        CHECK (confirming_employee_id IS NOT NULL
               OR (confirming_employee_name IS NOT NULL AND confirming_employee_name <> '')),
    CONSTRAINT ck_parent_work_entries_activity CHECK (activity <> ''),
    -- „Stundenzahl in halben Stunden" — mindestens eine halbe.
    CONSTRAINT ck_parent_work_entries_hours CHECK (half_hours > 0),
    -- Bestätigt oder abgelehnt, nie beides; leer heißt „wartet noch".
    CONSTRAINT ck_parent_work_entries_decision
        CHECK (confirmed_at IS NULL OR rejected_at IS NULL),
    CONSTRAINT ck_parent_work_entries_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Aufgabe der bestätigenden Person: „eine offene Aufgabe mit allen
-- Einträgen, die auf sie warten — nicht eine je Eintrag".
CREATE INDEX ix_parent_work_entries_waiting
    ON parent_work_entries (confirming_employee_id, created_at)
    WHERE confirmed_at IS NULL AND rejected_at IS NULL;

-- Trägt die Jahresrechnung und den Stand, den die Eltern jederzeit sehen.
CREATE INDEX ix_parent_work_entries_year
    ON parent_work_entries (family_id, school_year);


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------
-- [?] Ist der Text der Anlage anzupassen — Eintragung im Portal statt Zettel,
--     Frist 31. Juli, und dass nur bestätigte Stunden zählen (14)? —
--     Geschäftsführung
-- [?] Wird der Bonus in Optigem als eigene Position geführt, damit Aufschlag
--     und Rückzahlung dort buchbar sind (14)? — Buchhaltung
