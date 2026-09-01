-- Elternbonus Elternmitarbeit (Domäne 11) — gezählt werden die eingetragenen
-- Stunden je Familie und Schuljahr.
-- Lesepfad: drei Tabellen. `parent_work_sessions` ist der ausgeschriebene
-- Einsatz, `parent_work_signups` die Anmeldung dazu, `parent_work_entries` die
-- geleistete Stunde — mit oder ohne Einsatz. Alles
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
--
-- BEWUSST KEINE BESTÄTIGUNG. Entschieden am 01.09.2026: „Wir haben bisher den
-- Eltern vertraut und werden es weiterhin tun." Was die Eltern eintragen,
-- zählt; niemand nimmt es ab, niemand kann es ablehnen. Der Preis steht in 14
-- („Was heute schiefgeht"): Die Jahresliste trägt ungeprüfte Zahlen. Damit
-- fällt auch die namentlich benannte Person am Eintrag — einer der beiden
-- Fälle in hebel.md, in denen eine Aufgabe an einem Menschen statt an einer
-- Rolle hing; übrig bleibt der Beleg bei der gewählten Führungskraft (12).


-- Herkunft: 14 (Elternbonus) Z1 — „Schreibt einen Einsatz aus: Tag, Beginn, in
-- einem Satz die Tätigkeit, den Treffpunkt und was mitzubringen ist." Ersetzt
-- die Mail an alle Eltern samt der fremden Umfrageplattform, auf der heute je
-- Termin eine offene Namensliste entsteht. Löschanker: wie der Eintrag die
-- Schuljahresfrist — der Einsatz trägt die Anmeldungen, und keine davon lebt
-- länger als die Stunden, die daraus wurden.
-- Bewusst KEIN Ende und KEINE Dauer: „Wie lange jemand bleibt, entscheidet sich
-- vor Ort und steht ohnehin in der Stunde, die er einträgt" (14).
-- Bewusst KEINE Zuteilung und KEINE Warteschlange: Der Putzdienst hat beides,
-- weil dort jede Familie einen Termin haben muss; hier meldet sich, wer kann,
-- die Platzzahl begrenzt höchstens und verteilt nicht (14, „Gehört nicht
-- dazu"). Bewusst KEIN Bedarfsantrag davor: „Wer Hände braucht, schreibt selbst
-- aus."
CREATE TABLE parent_work_sessions (
    parent_work_session_id uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Tag und Beginn in einem: „Freitag, 24.04 … ab 14:00 Uhr". Mehrere
    -- Einsätze am selben Tag sind mehrere Zeilen.
    starts_at         timestamptz NOT NULL,
    -- Die Tätigkeit in einem Satz, wie am Eintrag: „Gipswände bauen".
    activity          text NOT NULL,
    -- Der freie Text daneben — das, was heute im Fließteil der Rundmail steht:
    -- „damit die neuen Klassenzimmer im Herbst fertig sind". Freiwillig, denn
    -- die meisten Einsätze erklären sich mit ihrer Tätigkeit.
    description       text,
    meeting_point     text NOT NULL,
    -- Was mitzubringen ist — „Sicherheitsschuhe / Handschuhe". Freiwillig: nicht
    -- jeder Einsatz verlangt etwas.
    bring_along       text,
    -- Wie viele mitkommen können — freiwillig, denn meistens gibt es keine
    -- Grenze: „Wir brauchen vier Personen" ist der Fall, für den sie da ist
    -- (14). Ist sie erreicht, ist zu; kein Nachrücken, dieselbe Regel wie beim
    -- Ferienprogramm (`ferien-schema.sql`).
    -- Wo sie steht, ist sie **hart**: „Wenn wir nur vier Leute mitnehmen
    -- dürfen, ist der fünfte einer zu viel" (14). Durchgesetzt wird sie vom
    -- Trigger unten — der einzige in diesem Schema, und die Begründung steht
    -- dort.
    capacity          smallint,
    -- Die Absage. Sie löscht den Einsatz nicht, denn die Angemeldeten bekommen
    -- ihre Mail und die Zeile ist der Beleg dafür (14).
    cancelled_at      timestamptz,
    -- Warum abgesagt wurde — freiwillig, aber es geht in die Mail an die
    -- Angemeldeten: „Wetter" erspart die Rückfragen, die sonst beim
    -- Ausschreibenden landen. Ohne Absage gibt es ihn nicht (CHECK unten).
    cancellation_reason text,
    -- Die Erinnerung am Vortag, dieselbe Bauform wie im Putzdienst
    -- (`putzdienst-schema.sql`): Der Lauf sieht an der Spalte, dass er diesen
    -- Einsatz schon hatte, und schickt sie nicht zweimal.
    reminder_sent_at  timestamptz,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_parent_work_sessions PRIMARY KEY (parent_work_session_id),
    CONSTRAINT ck_parent_work_sessions_activity      CHECK (activity <> ''),
    CONSTRAINT ck_parent_work_sessions_meeting_point CHECK (meeting_point <> ''),
    CONSTRAINT ck_parent_work_sessions_bring_along   CHECK (bring_along <> ''),
    CONSTRAINT ck_parent_work_sessions_capacity      CHECK (capacity > 0),
    CONSTRAINT ck_parent_work_sessions_description   CHECK (description <> ''),
    CONSTRAINT ck_parent_work_sessions_reason        CHECK (cancellation_reason <> ''),
    -- Ein Grund ohne Absage gehört nicht an den Einsatz: Er beschriebe etwas,
    -- das nicht passiert ist.
    CONSTRAINT ck_parent_work_sessions_reason_needs_cancel
        CHECK (cancelled_at IS NOT NULL OR cancellation_reason IS NULL),
    -- Ausgeschrieben wird von der Schule, nie von den Eltern. Wer genau: „jede
    -- Person mit einer Mitarbeiterrolle der Schule" (14 Z1) — die beiden
    -- KITA-Rollen ausgenommen. Das prüft die Anwendung, weil das Haus an
    -- `employees` und die Rolle an `employee_roles` steht.
    CONSTRAINT ck_parent_work_sessions_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Trägt den täglichen Erinnerungslauf: die Einsätze von morgen, die noch keine
-- Mail hatten.
CREATE INDEX ix_parent_work_sessions_reminder
    ON parent_work_sessions (starts_at)
    WHERE reminder_sent_at IS NULL AND cancelled_at IS NULL;

-- Herkunft: 14 Z1 — „Wen er anspricht." Löschanker: geht mit dem Einsatz und
-- mit der Klasse.
-- Keine Zeile heißt „alle Familien": Der häufigste Fall — der Baueinsatz für
-- die ganze Schule — kommt ohne eine einzige Zeile aus, und es gibt keinen
-- zweiten Zustand „ausdrücklich alle" neben ihm.
-- Eine Zeile ist entweder eine **benannte Klasse** oder ein **Zuschnitt** aus
-- Schulart und Stufenspanne; mehrere Zeilen vereinigen sich. Damit stehen die
-- vier Fälle, die 14 nennt: „die 8a und die 8b" sind zwei Klassenzeilen, „die
-- Realschule" eine Schulartzeile, „ab Klasse 7" eine Spanne ohne Ende, „Klasse
-- 5 bis 7" eine mit beiden Grenzen.
-- Der Unterschied zwischen beiden Formen ist nicht Bequemlichkeit, sondern
-- Zeitverhalten: Eine benannte Klasse bleibt, was sie ist; ein Zuschnitt gilt
-- auch für Kinder, die später dazukommen. Wer „die ganze Realschule" als Liste
-- ihrer Klassen aufzählte, hätte im nächsten Schuljahr eine Klasse zu wenig —
-- genau der Fehler, den niemand bemerkt.
-- Ausgewertet wird gegen das Kind (`children.class_id`, `school_branch_id`,
-- `grade_level`) und nicht gegen die Klasse: Die Stufe steht dort als Spalte,
-- während sie an der Klasse aus Startjahr und Schulart gerechnet werden müsste.
CREATE TABLE parent_work_session_audiences (
    parent_work_session_audience_id uuid NOT NULL DEFAULT gen_random_uuid(),
    parent_work_session_id uuid NOT NULL,
    -- Entweder diese eine Klasse …
    class_id               integer,
    -- … oder ein Zuschnitt: Schulart, Stufe ab, Stufe bis — jedes für sich
    -- freiwillig, aber mindestens eines davon.
    school_branch_id       integer,
    grade_from             smallint,
    grade_to               smallint,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_parent_work_session_audiences PRIMARY KEY (parent_work_session_audience_id),
    CONSTRAINT fk_parent_work_session_audiences_session
        FOREIGN KEY (parent_work_session_id)
        REFERENCES parent_work_sessions (parent_work_session_id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_work_session_audiences_class
        FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_work_session_audiences_branch
        FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    -- Dieselbe Zielgruppe zweimal ist einmal — `NULLS NOT DISTINCT`, weil sonst
    -- zwei gleiche Zuschnitte nebeneinander stünden: In beiden Formen sind drei
    -- der vier Spalten leer.
    CONSTRAINT uq_parent_work_session_audiences
        UNIQUE NULLS NOT DISTINCT (parent_work_session_id, class_id, school_branch_id,
                                   grade_from, grade_to),
    -- Eine benannte Klasse ODER ein Zuschnitt, nie beides und nie keines: Eine
    -- Zeile ohne jede Angabe wäre „alle" und damit die Zeile, die es gerade
    -- nicht geben soll.
    CONSTRAINT ck_parent_work_session_audiences_form
        CHECK ((class_id IS NOT NULL
                AND school_branch_id IS NULL AND grade_from IS NULL AND grade_to IS NULL)
               OR (class_id IS NULL
                   AND num_nonnulls(school_branch_id, grade_from, grade_to) > 0)),
    CONSTRAINT ck_parent_work_session_audiences_grades
        CHECK (grade_from IS NULL OR grade_to IS NULL OR grade_to >= grade_from),
    CONSTRAINT ck_parent_work_session_audiences_created_by
        CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 14 Z2 — „Melden sich an oder wieder ab, bis der Einsatz beginnt."
-- Löschanker: geht mit dem Einsatz und mit der Person.
-- Angemeldet wird je Person und nicht je Familie: Es können zwei aus derselben
-- Familie kommen, und der Hausmeister braucht den Namen, den er heute von Hand
-- einsammelt. Abgemeldet wird durch Löschen der Zeile — eine Anmeldung, die es
-- nicht mehr gibt, ist keine, und ein Zeitpunkt daneben trüge nur Historie
-- (rules.md Abschnitt 1).
-- Bewusst KEINE Familie an der Zeile: Sie steht über die Sorgeberechtigung
-- schon fest, und die Stunde daraus hängt ohnehin an der Familie.
CREATE TABLE parent_work_signups (
    parent_work_signup_id  uuid NOT NULL DEFAULT gen_random_uuid(),
    parent_work_session_id uuid NOT NULL,
    person_id              uuid NOT NULL,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_parent_work_signups PRIMARY KEY (parent_work_signup_id),
    CONSTRAINT fk_parent_work_signups_session
        FOREIGN KEY (parent_work_session_id)
        REFERENCES parent_work_sessions (parent_work_session_id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_work_signups_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    -- Zweimal angemeldet ist einmal.
    CONSTRAINT uq_parent_work_signups UNIQUE (parent_work_session_id, person_id),
    CONSTRAINT ck_parent_work_signups_created_by CHECK (created_by ~ '^(entra:|guardian:)')
);

-- DER EINZIGE TRIGGER DIESES SCHEMAS, und er steht hier, weil die Regel eine
-- Aggregatbedingung ist: „Ist die Platzzahl erreicht, ist zu" (14) zählt die
-- Kindzeilen, und dafür kennt Postgres keinen deklarativen Weg. Die beiden
-- Alternativen sind teurer und stiller falsch: Ein Sentinel-Wert für
-- „unbegrenzt" (damit ein zusammengesetzter Fremdschlüssel griffe) ist eine
-- Zahl, die irgendwann jemand als echte Platzzahl liest; eine Platznummer je
-- Anmeldung mit UNIQUE darüber wäre deklarativ, verlangte aber, dass beim
-- Abmelden entstandene Lücken verwaltet werden.
-- `FOR UPDATE` ist kein Beiwerk: Ohne die Sperre auf der Einsatzzeile zählen
-- zwei gleichzeitige Anmeldungen beide denselben freien Platz, und bei einer
-- Fahrt mit vier Plätzen ist der fünfte einer zu viel (14). Die Sperre
-- serialisiert die Anmeldungen je Einsatz und nur dort.
CREATE FUNCTION enforce_parent_work_capacity() RETURNS trigger AS $$
DECLARE
    seats smallint;
    taken bigint;
BEGIN
    SELECT capacity INTO seats
      FROM parent_work_sessions
     WHERE parent_work_session_id = NEW.parent_work_session_id
       FOR UPDATE;

    IF seats IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT count(*) INTO taken
      FROM parent_work_signups
     WHERE parent_work_session_id = NEW.parent_work_session_id;

    IF taken >= seats THEN
        RAISE EXCEPTION 'Einsatz % ist voll: % von % Plätzen belegt',
                        NEW.parent_work_session_id, taken, seats
              USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_parent_work_signups_capacity
    BEFORE INSERT ON parent_work_signups
    FOR EACH ROW EXECUTE FUNCTION enforce_parent_work_capacity();


-- Herkunft: 14 (Elternbonus) — „Je Eintrag Datum, Stundenzahl in halben
-- Stunden und die Tätigkeit in einem Satz (alles Pflicht), dazu der Einsatz, wo
-- die Stunde von einem kommt — mehr nicht." Löschanker: wie
-- beim Putzdienst „einmal jährlich zum Schuljahresanfang fällt nicht das gerade
-- vergangene Schuljahr, sondern das davor" — die Frist rechnet am Schuljahr und
-- nicht am Austritt des Kindes (03).
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
    -- Schlüssel". Kommt die Stunde von einem ausgeschriebenen Einsatz, ist sie
    -- von dort vorausgefüllt — kopiert und nicht verwiesen, weil der Eintrag
    -- den Einsatz überlebt und die Tätigkeit dann trotzdem lesbar bleiben muss.
    activity             text NOT NULL,
    -- Der Einsatz, aus dem die Stunde kommt — freiwillig, und das ist der
    -- häufigere Fall: „Was die Eltern unter sich regeln — der Fahrdienst der
    -- Grundschule vor allem — wird ohne Einsatz eingetragen" (14 Z4). Der
    -- Bezug ist eine Herkunftsangabe, keine Bedingung: Auch wer sich nie
    -- angemeldet hat, trägt seine Stunde ein.
    parent_work_session_id uuid,
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
    -- Der Eintrag überlebt seinen Einsatz: Fällt der weg, bleibt die Stunde mit
    -- ihrer kopierten Tätigkeit stehen.
    CONSTRAINT fk_parent_work_entries_session
        FOREIGN KEY (parent_work_session_id)
        REFERENCES parent_work_sessions (parent_work_session_id) ON DELETE SET NULL,
    CONSTRAINT ck_parent_work_entries_activity CHECK (activity <> ''),
    -- „Stundenzahl in halben Stunden" — mindestens eine halbe.
    CONSTRAINT ck_parent_work_entries_hours CHECK (half_hours > 0),
    CONSTRAINT ck_parent_work_entries_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Trägt die Jahresrechnung und den Stand, den die Eltern jederzeit sehen.
CREATE INDEX ix_parent_work_entries_year
    ON parent_work_entries (family_id, school_year);


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------
-- [?] Ist der Text der Anlage anzupassen — Eintragung im Portal statt Zettel
--     und Frist 31. Juli (14)? Der dritte Punkt ist entschieden und fällt weg:
--     bestätigt wird nicht mehr. — Geschäftsführung
-- [?] Wird der Bonus in Optigem als eigene Position geführt, damit Aufschlag
--     und Rückzahlung dort buchbar sind (14)? — Buchhaltung
