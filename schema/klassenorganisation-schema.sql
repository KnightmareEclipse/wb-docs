-- Klassenorganisation (Domäne 13) — wer in einer Klasse unterrichtet, welche
-- Kinder außerhalb ihrer Klasse zusammenkommen, wann eine Klasse Schluss hat
-- und wer sie als Elternvertretung führt.
-- Lesepfad: `class_teaching_assignments` und `elective_groups` sind die zweite
-- Achse der Sichtbarkeit — nicht *welche Angabe* jemand sieht, das sagt
-- gesundheit-schema.sql, sondern *von welchen Kindern*; `elective_modules` ist
-- die Werteliste darüber, `child_group_memberships` hängt das Kind an seine
-- Gruppe. `class_end_times` und `class_representatives` stehen daneben und
-- hängen an nichts davon. Klassenlehrkraft und Raum bleiben
-- `classes.class_teacher_id` und `classes.room` in stammdaten-schema.sql.
--
-- Setzt stammdaten-schema.sql voraus.
--
-- [A!] Die Werteliste der Wahlmodule steht hier und nicht in `stammdaten`. Der
-- Grund, sie dort zu verorten, war die Ladereihenfolge — eine Spalte an
-- `children` kann nicht auf eine Tabelle dieser Datei zeigen —, und er entfällt,
-- seit die Zugehörigkeit eine eigene Tabelle ist. — Alternative: Werteliste und
-- Gruppe in `stammdaten`; Preis: die zweite Achse läge in zwei Dateien, und der
-- Stammdaten-Freeze (grenzkarte.md) träfe eine Struktur, die mit jeder Kohorte
-- wächst.


-- ---------------------------------------------------------------------------
-- Die zweite Achse — von welchen Kindern jemand liest
-- ---------------------------------------------------------------------------

-- Herkunft: 15 (Klassenbildung) — „Quer zur Klasse steht die Wahlmodulgruppe:
-- Technik, AES und Französisch werden einmal gewählt und bis zum Abgang
-- behalten." Kein Löschanker: keine Personendaten.
-- Drei Zeilen — Technik, AES, Französisch —, und sie stehen hier allein, weil
-- sie die Sichtbarkeit tragen. Bewusst KEINE Fächerliste daneben: Die siebzehn
-- Fächer der Realschule und die dreizehn der Grundschule tragen nichts, denn
-- für „wer darf welches Kind sehen" zählt allein das Paar Lehrkraft ↔
-- Kindermenge (15).
CREATE TABLE elective_modules (
    elective_module_id integer GENERATED ALWAYS AS IDENTITY,
    code               text NOT NULL,
    name               text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus jedem
    -- Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn zeigt
    -- (rules.md Abschnitt 3).
    is_active          boolean NOT NULL DEFAULT true,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_elective_modules      PRIMARY KEY (elective_module_id),
    CONSTRAINT uq_elective_modules_code UNIQUE (code),
    CONSTRAINT ck_elective_modules_code CHECK (code <> ''),
    CONSTRAINT ck_elective_modules_name CHECK (name <> ''),
    CONSTRAINT ck_elective_modules_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 15 (Klassenbildung) — „Sie hat genau eine Lehrkraft, und an ihr —
-- nicht am Modul — hängt, wer diese Kinder sieht"; gepflegt wird sie wie die
-- Klasse selbst. Löschanker: keiner — die Gruppe überlebt ihre Lehrkraft, und
-- mit dem Kind geht allein seine Mitgliedschaft.
-- Sie bekommt eine eigene Kennung, weil sie sich teilen kann: Heute gibt es je
-- Modul und Kohorte genau eine, und die Oberfläche zeigt deshalb das Modul;
-- entsteht eine zweite mit eigener Lehrkraft, hielte weder das Paar
-- (Modul, Kohorte) noch die Klasse die beiden auseinander — die eine gäbe es
-- zweimal, die andere zerschnitte eine Gruppe, die es als Ganzes gibt.
-- Sie hängt an der Gruppe und nicht am Modul, und das ist der ganze Zweck:
-- Hinge die Lehrkraft am Modul, sähe sie alle Technik-Kinder der Schule —
-- achtzig statt der fünfzehn, die sie unterrichtet.
-- Bewusst KEIN Schuljahr: Das Modul wird einmal gewählt und bis zum Abgang
-- behalten, die Gruppe lebt so lange wie die Kohorte. Bewusst KEIN Verlauf, wer
-- sie früher geführt hat: Die Sichtbarkeit fragt nach dem Jetzt, ein Wechsel
-- überschreibt, und wer die Geschichte will, liest die Änderungsspur.
CREATE TABLE elective_groups (
    elective_group_id  integer GENERATED ALWAYS AS IDENTITY,
    -- Wie sie im Haus heißt („Technik 7 · A"). Sie trägt den Namen selbst, weil
    -- es zwei desselben Moduls im selben Jahrgang geben darf und sie sonst nicht
    -- auseinanderzuhalten wären.
    label              text NOT NULL,
    elective_module_id integer NOT NULL,
    school_branch_id   integer NOT NULL,
    -- Das Schuljahr, in dem die Kohorte begonnen hat — dieselbe Zahl und
    -- dieselbe Bedeutung wie `classes.start_school_year`. Sie steht hier, damit
    -- beim Eintragen die Gruppen des richtigen Jahrgangs zur Auswahl stehen und
    -- eine noch leere Gruppe ein Zuhause hat.
    start_school_year  smallint NOT NULL,
    -- Genau eine Lehrkraft; zwei wären eine Verbindungstabelle, und dafür liegt
    -- kein Fall vor. Beim Anlegen ist sie Pflicht — an ihr hängt die
    -- Sichtbarkeit —, die Spalte bleibt trotzdem leerbar: Die Gruppe steht
    -- still, wenn ihre Lehrkraft geht (wie `classes.class_teacher_id`), und
    -- leer heißt dann „niemand sieht diese Kinder über diese Gruppe" statt
    -- „alle".
    employee_id        uuid,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_elective_groups PRIMARY KEY (elective_group_id),
    CONSTRAINT fk_elective_groups_module
        FOREIGN KEY (elective_module_id) REFERENCES elective_modules (elective_module_id),
    CONSTRAINT fk_elective_groups_branch
        FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    CONSTRAINT fk_elective_groups_employee
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id) ON DELETE SET NULL,
    -- Zwei Gruppen desselben Moduls im selben Jahrgang sind ausdrücklich
    -- erlaubt — nur nicht zweimal unter demselben Namen.
    CONSTRAINT uq_elective_groups
        UNIQUE (elective_module_id, school_branch_id, start_school_year, label),
    -- Trägt den zusammengesetzten Fremdschlüssel von `child_group_memberships`.
    CONSTRAINT uq_elective_groups_id_branch_module
        UNIQUE (elective_group_id, school_branch_id, elective_module_id),
    CONSTRAINT ck_elective_groups_label CHECK (label <> ''),
    CONSTRAINT ck_elective_groups_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 15 (Klassenbildung) — „Ein Kind kann in mehreren Gruppen sein;
-- heute ist es je eines." Löschanker: geht mit dem Kind (03).
-- Eine Tabelle und keine Spalte an `children`, obwohl heute je Kind genau eine
-- Zeile entsteht: Wird aus der Klasse als Einheit doch die eigene Fördergruppe
-- (siehe `class_teaching_assignments`), hat ein förderbedürftiges Kind in aller
-- Regel Deutsch *und* Mathematik — die Ein-Gruppen-Grenze wäre dann nicht der
-- Randfall, sondern der Normalfall. — Alternative: `children.elective_group_id`,
-- eine Spalte weniger und derselbe Join; Preis: dieser Wechsel wäre keine Wahl
-- mehr, sondern eine Umstellung von Spalte auf Tabelle samt Policy und
-- Oberfläche, mitten in einer laufenden Domäne.
-- Für die Pflege ändert das nichts: Man wählt bei der Anmeldung eine Gruppe, ob
-- daraus eine Spalte oder eine Zeile wird, merkt niemand.
CREATE TABLE child_group_memberships (
    child_id           uuid NOT NULL,
    elective_group_id  integer NOT NULL,
    -- Beide mitgeführt, und beide tragen eine Regel, die die Zuordnung allein
    -- nicht hält (rules.md Abschnitt 1). Die Schulart bindet Kind und Gruppe
    -- aneinander: Ohne sie käme ein Grundschulkind in eine Realschulgruppe, und
    -- deren Lehrkraft sähe ein Kind, das sie nie unterrichtet — genau der Kreis,
    -- den diese Datei eng halten soll. Sie schließt zugleich ein Kind ohne
    -- Einschreibung aus, denn erst die bringt die Schulart mit.
    school_branch_id   integer NOT NULL,
    -- Das Modul trägt die Einmalwahl: „Technik, AES und Französisch werden
    -- einmal gewählt und bis zum Abgang behalten" (15) — zwei Gruppen desselben
    -- Moduls sind ein Doppeleintrag, zwei Module nebeneinander sind es nicht.
    elective_module_id integer NOT NULL,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_child_group_memberships PRIMARY KEY (child_id, elective_group_id),
    -- Wechselt ein Kind die Schulart (04, Grundschule → eigene Realschule),
    -- scheitert der Jahreslauf hier, solange eine Mitgliedschaft steht: Sie geht
    -- mit der alten Schulart und muss vorher fallen — dieselbe Handreichung wie
    -- bei der Klassenzuordnung, die derselbe Lauf leert.
    CONSTRAINT fk_child_group_memberships_child
        FOREIGN KEY (child_id, school_branch_id)
        REFERENCES children (child_id, school_branch_id) ON DELETE CASCADE,
    CONSTRAINT fk_child_group_memberships_group
        FOREIGN KEY (elective_group_id, school_branch_id, elective_module_id)
        REFERENCES elective_groups (elective_group_id, school_branch_id, elective_module_id)
        ON DELETE CASCADE,
    -- Die Kohorte prüft hier bewusst nichts: Sie steht an der Gruppe, „damit
    -- beim Eintragen die richtigen Gruppen zur Auswahl stehen" (15) — also in
    -- der Auswahl und nicht als Constraint. Ein Wiederholer bliebe sonst ohne
    -- Gruppe, obwohl er dasselbe Modul weiter besucht.
    CONSTRAINT uq_child_group_memberships_module UNIQUE (child_id, elective_module_id),
    CONSTRAINT ck_child_group_memberships_created_by
        CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Frage der Gruppenliste: welche Kinder hängen an dieser Gruppe.
CREATE INDEX ix_child_group_memberships_group
    ON child_group_memberships (elective_group_id);

-- Herkunft: 15 (Klassenbildung) — „Drei Wege führen zu einem Kind, und je
-- Zuordnung entsteht eine eigene Liste: die Klassenleitung, der Unterricht in
-- seiner Klasse und die Wahlmodulgruppe"; gepflegt je Schuljahr von der Stelle,
-- die die Klassen ohnehin führt. Löschanker:
-- geht mit dem Mitarbeitendeneintrag, also mit `employees.last_working_day`.
-- Die Klasse ist die Einheit, auch wo sie zu grob ist: Der Förderunterricht der
-- Grundschule geht an fünf Kinder einer Klasse, über diese Zeile sieht die
-- Förderlehrkraft alle siebenundzwanzig. Das ist entschieden und nicht
-- übersehen — der weitere Kreis bleibt innerhalb *einer* Klasse, deren Kinder
-- dieselbe Lehrkraft ohnehin täglich vor sich hat, und die Fehlerrichtung
-- stimmt: Es sieht jemand ein Kind, das er ohnehin unterrichtet, statt dass im
-- Ernstfall die Angabe der Person fehlt, die daneben steht.
-- — Alternative: die Fördergruppe wird geführt, dann trifft der Kreis die Regel
-- wörtlich; Preis: eine Mitgliederliste in ihrer schlechtesten Form, denn wer
-- Förderung bekommt, wechselt unterjährig — eine veraltete Liste blendete im
-- Zweifel das Kind mit der Allergie aus. Umkehrbar bleibt es trotzdem: Die
-- Fördergruppe wäre eine `elective_groups`-Zeile mit ihrer Kohorte und kein
-- neues Modell.
-- Bewusst KEIN Fach: Für „wer darf welches Kind sehen" trägt allein das Paar
-- Lehrkraft ↔ Kindermenge; die Fächerlisten der beiden Schularten bleiben
-- Dokumentation.
CREATE TABLE class_teaching_assignments (
    class_teaching_assignment_id uuid NOT NULL DEFAULT gen_random_uuid(),
    employee_id                  uuid NOT NULL,
    class_id                     integer NOT NULL,
    -- Anders als die Gruppe hängt sie am Schuljahr: Wer unterrichtet, wird zum
    -- Wechsel neu verteilt, und die Zeile des Vorjahres soll dabei nicht
    -- weitergelten.
    school_year                  smallint NOT NULL,
    created_at                   timestamptz NOT NULL DEFAULT now(),
    created_by                   text NOT NULL,

    CONSTRAINT pk_class_teaching_assignments PRIMARY KEY (class_teaching_assignment_id),
    CONSTRAINT fk_class_teaching_assignments_employee
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_class_teaching_assignments_class
        FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE,
    CONSTRAINT uq_class_teaching_assignments UNIQUE (employee_id, class_id, school_year),
    CONSTRAINT ck_class_teaching_assignments_created_by
        CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Frage der Klassenliste: wer unterrichtet in dieser Klasse.
CREATE INDEX ix_class_teaching_assignments_class
    ON class_teaching_assignments (class_id, school_year);


-- ---------------------------------------------------------------------------
-- Unterrichtsende — was der Hort zum Planen braucht
-- ---------------------------------------------------------------------------

-- Herkunft: 15 (Klassenbildung) — „Das Unterrichtsende je Wochentag (Uhrzeit,
-- Pflicht, sobald es feststeht)", je Klasse eine Zeile („wann sie an welchem
-- Wochentag Unterrichtsende hat", Z1). Gelesen wird sie im Hort (09), der daran
-- weiß, wann er mit wie vielen Kindern rechnet. Kein Löschanker: keine
-- Personendaten.
-- Bewusst KEINE Ankunftszeit: Die Kinder treffen unterschiedlich ein, es hängt
-- an den Eltern und am Verkehr — eine Zeit je Klasse wäre nicht ungenau,
-- sondern falsch. Bewusst KEIN Fach, keine Stunde, kein Raum: Das ist kein
-- Stundenplan und wird keiner, Untis bleibt draußen.
-- — Alternative: die Abweichung je Datum statt je Wochentag, dann träfe sie
-- auch den Wandertag; Preis: für die wöchentliche Sportabweichung jede Woche
-- eine Zeile, die jemand einträgt. Käme der einmalige Fall doch, ist er eine
-- Tabelle daneben.
CREATE TABLE class_end_times (
    class_id       integer NOT NULL,
    school_year    smallint NOT NULL,
    -- ISO-Wochentag, 1 = Montag bis 5 = Freitag.
    weekday        smallint NOT NULL,
    ends_at        time NOT NULL,
    -- An diesem Tag liegt Sport am Unterrichtsende. Die Halle ist extern und
    -- die Eltern fahren die Kinder zurück, sie kommen also später im Hort an.
    -- Als Häkchen und nicht als Freitext-Grund: Der Text wäre ein Satz, den
    -- jemand für eine Tatsache tippt, die jeder kennt; käme ein zweiter Anlass
    -- — Schwimmen betrifft die Hortkinder ausdrücklich nicht —, ist er ein
    -- zweites Häkchen oder eben doch der Text.
    sport_at_end   boolean NOT NULL DEFAULT false,
    created_at     timestamptz NOT NULL DEFAULT now(),
    created_by     text NOT NULL,

    CONSTRAINT pk_class_end_times PRIMARY KEY (class_id, school_year, weekday),
    CONSTRAINT fk_class_end_times_class
        FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE,
    CONSTRAINT ck_class_end_times_weekday CHECK (weekday BETWEEN 1 AND 5),
    CONSTRAINT ck_class_end_times_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Elternvertretung
-- ---------------------------------------------------------------------------

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
    -- eingetippt. **Dass sie sorgeberechtigt ist, prüft die Route und kein
    -- Constraint** (api/klassenorganisation-api.md): Der Fremdschlüssel zeigt
    -- auf `persons`, weil das Amt an der Klasse hängt und nicht an einer
    -- Familie — und `guardians` trägt nur, wer eine der drei freiwilligen
    -- Angaben gemacht hat, wäre als Ziel also zu eng. Bewusst auch ohne
    -- Prüfung, ob sie noch ein Kind in dieser Klasse hat: „Wechselt ein Kind
    -- die Klasse oder geht es ab, endet das Amt nicht von selbst."
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
-- Keine. Wer die Wahlmodulgruppe pflegt, steht seit dem 03.09.2026 fest:
-- Klassenlehrkraft, Sekretariat und Schulleitung (15). Am Schema hängt daran
-- ohnehin nichts, die Antwort entscheidet allein den GRANT. Bewusst KEINE zweite Tabelle für ein Gremium über der Klasse: „Und kein
-- Gremium über der Klassenvertretung: Gesamtelternbeirat, Vorsitz,
-- Schulkonferenz gibt es bisher nicht, und ihre Besetzung im System zu führen
-- wäre auch dann nicht das, was die Schule braucht" (16). Geführt wird die
-- Elternvertretung je Klasse und Schuljahr, mehr nicht. Käme je eines dazu,
-- wäre es eine Tabelle daneben und kein Umbau dieser einen.
