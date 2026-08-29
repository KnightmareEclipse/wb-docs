-- Putzdienst (Domäne 1) — Putzdienstjahr, Termine, Zuteilung, Freikauf, Tausch.
-- Lesepfad: `cleaning_cycles` ist das Putzdienstjahr (Oktober bis September)
-- und der Rahmen für alles Weitere. Daran hängen die Termine
-- (`cleaning_slots`) und die Pflichtmengen; `cleaning_assignments` verbindet
-- Familie und Termin und trägt Anwesenheit und Strafe. Freikauf und Tausch
-- stehen als eigene Zeilen daneben, weil beide eine Zahlung bzw. eine zweite
-- Familie berühren.
--
-- Alles hängt an der Familie, nie am Kind: „zwei Kinder an der Schule bedeuten
-- genauso viele Termine wie eines" (01).
-- Setzt stammdaten-schema.sql und querschnitt-schema.sql voraus.


-- Herkunft: 01 (Putzdienst) — „Das Putzdienstjahr läuft von Oktober bis
-- September, der Unterricht beginnt schon im September — dieser Monat Puffer
-- ist Absicht". Löschanker: das Zyklusende plus ein Jahr — „gelöscht wird
-- einmal jährlich zum Schuljahresanfang, und zwar nicht das gerade vergangene
-- Putzdienstjahr, sondern das davor". Bewusst KEIN eigener Preis am Zyklus: die
-- beiden Preise stehen als Werte im System (querschnitt-schema.sql).
CREATE TABLE cleaning_cycles (
    cleaning_cycle_id integer GENERATED ALWAYS AS IDENTITY,
    -- Das Kalenderjahr, in dessen Oktober der Zyklus beginnt; er endet im
    -- September des Folgejahres.
    start_year        smallint NOT NULL,
    registration_opens_at  timestamptz NOT NULL,
    -- Der Zeitpunkt, zu dem das System die offenen Pflichttermine automatisch
    -- verteilt; bis dahin dürfen Eltern selbst reservieren und umbuchen.
    registration_closes_at timestamptz NOT NULL,
    -- Die Marke des Zuteilungslaufs (01, Z4): gesetzt, wenn die offenen
    -- Pflichttermine verteilt sind. Das Fenster schließt derweil ohne Spalte —
    -- es schließt durch `registration_closes_at`, und wer reservieren will,
    -- liest die Uhr.
    allocated_at           timestamptz,
    -- Ohne diese Freigabe durch das Sekretariat „erfährt keine Familie ihre
    -- Termine" — die Zuteilung steht dann zwar, wirkt aber noch nicht.
    allocation_released_at timestamptz,
    -- Die Marke des Laufs „Anmeldefenster offen" (01, Z2): gesetzt, sobald die
    -- Mail an alle Familien mit Pflichtterminen draußen ist. Sie ist es, die den
    -- Lauf einmalig macht — er sucht die Zyklen, die keine tragen, und
    -- `allocation_released_at` taugt dafür nicht: die trägt die Freigabe durch
    -- das Sekretariat und keinen Lauf. Bewusst OHNE CHECK gegen
    -- `registration_opens_at`: das Sekretariat verschiebt das Fenster bis zum
    -- Schließen, und ein nach der Mail vorgezogener Beginn wäre dann eine
    -- Constraint-Verletzung statt einer Terminänderung.
    registration_mail_sent_at timestamptz,
    -- Die Marke des Laufs „Zuteilungsmail" (01, Z6): gesetzt, sobald jede
    -- Familie mit Terminen ihre Liste bekommen hat. Eine eigene Spalte neben
    -- `allocation_released_at`, weil die Freigabe der Griff des Sekretariats ist
    -- und über den Versand nichts sagt — ein Mailfehler darf die Freigabe nicht
    -- zurücknehmen, und der Lauf sucht die freigegebenen Zyklen ohne diese
    -- Marke.
    allocation_mail_sent_at timestamptz,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,

    CONSTRAINT pk_cleaning_cycles       PRIMARY KEY (cleaning_cycle_id),
    CONSTRAINT uq_cleaning_cycles_year  UNIQUE (start_year),
    CONSTRAINT ck_cleaning_cycles_window
        CHECK (registration_closes_at > registration_opens_at),
    CONSTRAINT ck_cleaning_cycles_allocated
        CHECK (allocated_at IS NULL OR allocated_at >= registration_closes_at),
    -- „Ohne Freigabe erfährt keine Familie ihre Termine" — und ohne Lauf gibt es
    -- nichts freizugeben: die Freigabe setzt die Zuteilung voraus und folgt ihr.
    CONSTRAINT ck_cleaning_cycles_release
        CHECK (allocation_released_at IS NULL
               OR (allocated_at IS NOT NULL AND allocation_released_at >= allocated_at)),
    -- Die Mail sagt der Familie ihre Termine — „ohne Freigabe erfährt keine
    -- Familie ihre Termine", also kann sie der Freigabe nicht vorausgehen.
    CONSTRAINT ck_cleaning_cycles_allocation_mail
        CHECK (allocation_mail_sent_at IS NULL OR allocation_released_at IS NOT NULL),
    CONSTRAINT ck_cleaning_cycles_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst) — „die Art (regulärer Putzdienst oder Großputz,
-- Pflicht)". Löschanker: keiner, keine Personendaten. Bewusst KEINE eigene Art
-- für Gartentermine: „ein Gartentermin ist ein regulärer Putzdienst oder ein
-- Großputz und zählt auch so", der Unterschied steht im Hinweistext.
CREATE TABLE cleaning_slot_types (
    cleaning_slot_type_id integer GENERATED ALWAYS AS IDENTITY,
    code                  text NOT NULL,
    name                  text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active              boolean NOT NULL DEFAULT true,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_cleaning_slot_types      PRIMARY KEY (cleaning_slot_type_id),
    CONSTRAINT uq_cleaning_slot_types_code UNIQUE (code),
    CONSTRAINT ck_cleaning_slot_types_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst) — „Wie viele Putzdienste eine Familie im Jahr
-- schuldet: derzeit 5 reguläre + 1 Großputz" und „die Platzzahl … steht als
-- Standard je Art einmal für das ganze Jahr". Löschanker: geht mit dem Zyklus.
-- Beide Zahlen stehen an derselben Zeile, weil beide je Zyklus und Art gelten;
-- die Pflichtmenge braucht daneben keinen eigenen Gültigkeitstag, denn sie
-- ändert sich „nur zum Beginn eines Putzdienstjahres".
CREATE TABLE cleaning_cycle_quotas (
    cleaning_cycle_quota_id integer GENERATED ALWAYS AS IDENTITY,
    cleaning_cycle_id       integer NOT NULL,
    cleaning_slot_type_id   integer NOT NULL,
    required_count          smallint NOT NULL,
    -- Obergrenze je Termin dieser Art, am einzelnen Termin überschreibbar; sie
    -- ist „eine Obergrenze, kein Soll, das gefüllt werden müsste".
    default_capacity        smallint NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_cleaning_cycle_quotas    PRIMARY KEY (cleaning_cycle_quota_id),
    CONSTRAINT fk_cleaning_cycle_quotas_cycle
        FOREIGN KEY (cleaning_cycle_id) REFERENCES cleaning_cycles (cleaning_cycle_id) ON DELETE CASCADE,
    CONSTRAINT fk_cleaning_cycle_quotas_type
        FOREIGN KEY (cleaning_slot_type_id) REFERENCES cleaning_slot_types (cleaning_slot_type_id),
    CONSTRAINT uq_cleaning_cycle_quotas UNIQUE (cleaning_cycle_id, cleaning_slot_type_id),
    CONSTRAINT ck_cleaning_cycle_quotas_required CHECK (required_count >= 0),
    CONSTRAINT ck_cleaning_cycle_quotas_capacity CHECK (default_capacity > 0),
    CONSTRAINT ck_cleaning_cycle_quotas_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst) — „legt die Putzdiensttermine einzeln an … je
-- Termin ein frei gewählter Startzeitpunkt (Datum und Uhrzeit), kein fester
-- Wochentag, kein Raster". Löschanker: geht mit dem Zyklus. Bewusst KEINE
-- Dauer: „wie lange ein Putzdienst ungefähr dauert, steht im Schulvertrag und
-- wird hier nicht festgehalten".
CREATE TABLE cleaning_slots (
    cleaning_slot_id      uuid NOT NULL DEFAULT gen_random_uuid(),
    cleaning_cycle_id     integer NOT NULL,
    cleaning_slot_type_id integer NOT NULL,
    starts_at             timestamptz NOT NULL,
    -- Was an diesem Termin anders ist („an diesem Termin wird ausschließlich im
    -- Garten gearbeitet"); steht in der Auswahl und in beiden Erinnerungsmails.
    note                  text,
    -- Nur gesetzt, wo von der Standard-Platzzahl der Art abgewichen wird; leer
    -- heißt, es gilt der Standard, und nicht, es gebe keine Grenze.
    capacity_override     smallint,
    -- Der Anker für den dritten Zustand der Anwesenheit: solange er leer ist,
    -- heißt `cleaning_assignments.no_show = false` „noch nicht ausgewertet"
    -- (grenzkarte.md, „Drei Zustände").
    attendance_recorded_at timestamptz,
    -- Die eingescannte Unterschriftenliste. 01, Schritt 11: das Sekretariat
    -- „trägt … ein, wer da war, und legt die eingescannte Liste dazu"; unter
    -- Dateien: „Unterschrieben kommt sie zurück und wird eingescannt beim Termin
    -- abgelegt — sie ist der Beleg dafür, wer da war, und lesen darf sie das
    -- Sekretariat." Sie liegt am Termin und nicht am Kind — sie gehört keinem
    -- und hätte in der Schülerakte keinen Platz —, trägt aber dieselben beiden
    -- Angaben wie `documents` (querschnitt-schema.sql): die Bibliothek und die
    -- Graph-Kennung, denn „ein Pfad bräche bei jedem Verschieben".
    attendance_sheet_library_id integer,
    attendance_sheet_graph_item_id text,
    -- Je Erinnerung eine Marke (Z9). Zwei Spalten und kein Zähler: die beiden
    -- Erinnerungen haben verschiedene Auslöser — die erste, „sobald der vorige
    -- Putzdienst gelaufen ist", die zweite ein bis zwei Tage vorher —, und ein
    -- Zähler sagte nicht, welche von beiden gelaufen ist. Sie stehen am Termin
    -- und nicht am Zyklus, weil je Termin erinnert wird. Beim ersten Termin des
    -- Jahres bleibt die erste leer, und das ohne Sonderfall: Er hat keinen
    -- Vorgänger, und „beim ersten Termin des Jahres übernimmt die Zuteilungsmail
    -- die erste Erinnerung".
    first_reminder_sent_at  timestamptz,
    second_reminder_sent_at timestamptz,
    -- Ein abgesagter Termin bleibt stehen, damit die betroffenen Familien
    -- sehen, was mit ihm war; „das geht dann zu Lasten der Schule".
    cancelled_at          timestamptz,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_cleaning_slots       PRIMARY KEY (cleaning_slot_id),
    CONSTRAINT fk_cleaning_slots_cycle
        FOREIGN KEY (cleaning_cycle_id) REFERENCES cleaning_cycles (cleaning_cycle_id) ON DELETE CASCADE,
    CONSTRAINT fk_cleaning_slots_type
        FOREIGN KEY (cleaning_slot_type_id) REFERENCES cleaning_slot_types (cleaning_slot_type_id),
    CONSTRAINT fk_cleaning_slots_sheet_library
        FOREIGN KEY (attendance_sheet_library_id)
        REFERENCES sharepoint_libraries (sharepoint_library_id),
    -- Trägt den zusammengesetzten Fremdschlüssel des Tauschs weiter unten.
    CONSTRAINT uq_cleaning_slots_id_type UNIQUE (cleaning_slot_id, cleaning_slot_type_id),
    CONSTRAINT ck_cleaning_slots_capacity CHECK (capacity_override > 0),
    CONSTRAINT ck_cleaning_slots_note     CHECK (note <> ''),

    -- Ein abgesagter Termin wird nicht ausgewertet.
    CONSTRAINT ck_cleaning_slots_cancelled
        CHECK (cancelled_at IS NULL OR attendance_recorded_at IS NULL),
    -- Bibliothek und Kennung stehen zusammen oder gar nicht — dieselbe Regel
    -- wie `ck_documents_filed`: abgelegt ist, wo eine Datei liegt.
    CONSTRAINT ck_cleaning_slots_sheet
        CHECK ((attendance_sheet_library_id IS NULL)
               = (attendance_sheet_graph_item_id IS NULL)),
    -- 01, Schritt 11: die Liste kommt mit dem Eintrag, wer da war. Ohne
    -- Auswertung gibt es keinen Beleg, der sie stützte.
    CONSTRAINT ck_cleaning_slots_sheet_recorded
        CHECK (attendance_sheet_graph_item_id IS NULL
               OR attendance_recorded_at IS NOT NULL),
    CONSTRAINT ck_cleaning_slots_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst), Sonderfälle — „die Pflichtzahl dieser Familie wird
-- abweichend gesetzt … Mitarbeitende der Schule mit eigenem Kind an der Schule
-- (null Termine) … Quereinsteiger, die mitten im Jahr kommen (anteilig)".
-- Löschanker: geht mit dem Zyklus. Bewusst KEINE Fortschreibung ins nächste
-- Jahr: „was bestehen bleiben soll, entscheidet das Sekretariat beim Einrichten
-- des neuen Jahres". Bewusst KEIN Grundfeld — der Grund liegt außerhalb.
CREATE TABLE cleaning_family_quotas (
    cleaning_family_quota_id uuid NOT NULL DEFAULT gen_random_uuid(),
    cleaning_cycle_id        integer NOT NULL,
    family_id                uuid NOT NULL,
    cleaning_slot_type_id    integer NOT NULL,
    -- Ersetzt die Pflichtmenge des Zyklus für genau diese Familie und Art;
    -- null Termine ist der Regelfall bei Mitarbeiterfamilien.
    required_count           smallint NOT NULL,
    created_at               timestamptz NOT NULL DEFAULT now(),
    created_by               text NOT NULL,

    CONSTRAINT pk_cleaning_family_quotas PRIMARY KEY (cleaning_family_quota_id),
    CONSTRAINT fk_cleaning_family_quotas_cycle
        FOREIGN KEY (cleaning_cycle_id) REFERENCES cleaning_cycles (cleaning_cycle_id) ON DELETE CASCADE,
    -- Bewusst OHNE Cascade auf die Familie: die Zeile folgt der Jahrgangsfrist
    -- aus 01 und nicht dem Austritt (03), wie bei `cleaning_assignments`.
    CONSTRAINT fk_cleaning_family_quotas_family
        FOREIGN KEY (family_id) REFERENCES families (family_id),
    CONSTRAINT fk_cleaning_family_quotas_type
        FOREIGN KEY (cleaning_slot_type_id) REFERENCES cleaning_slot_types (cleaning_slot_type_id),
    CONSTRAINT uq_cleaning_family_quotas
        UNIQUE (cleaning_cycle_id, family_id, cleaning_slot_type_id),
    CONSTRAINT ck_cleaning_family_quotas_required CHECK (required_count >= 0),
    CONSTRAINT ck_cleaning_family_quotas_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst) — „auch gleich alle auf einmal, ohne einen einzigen
-- zu buchen … der Freikauf des ganzen Jahres ist die Summe der offenen
-- Pflichttermine". Löschanker: geht mit dem Zyklus. Bewusst KEIN Betrag hier:
-- er steckt in der Zahlung (Q3), und der Preis je Termin steht als Wert im
-- System — beides zweimal zu führen ließe sie auseinanderlaufen.
CREATE TABLE cleaning_buyouts (
    cleaning_buyout_id    uuid NOT NULL DEFAULT gen_random_uuid(),
    cleaning_cycle_id     integer NOT NULL,
    family_id             uuid NOT NULL,
    cleaning_slot_type_id integer NOT NULL,
    -- Wie viele Pflichttermine dieser Art damit erledigt sind; die Pflichtzahl
    -- der Familie sinkt um genau diesen Wert.
    bought_count          smallint NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_cleaning_buyouts PRIMARY KEY (cleaning_buyout_id),
    CONSTRAINT fk_cleaning_buyouts_cycle
        FOREIGN KEY (cleaning_cycle_id) REFERENCES cleaning_cycles (cleaning_cycle_id) ON DELETE CASCADE,
    -- Bewusst OHNE Cascade auf die Familie: die Zeile folgt der Jahrgangsfrist
    -- aus 01 und nicht dem Austritt (03), wie bei `cleaning_assignments`.
    CONSTRAINT fk_cleaning_buyouts_family
        FOREIGN KEY (family_id) REFERENCES families (family_id),
    CONSTRAINT fk_cleaning_buyouts_type
        FOREIGN KEY (cleaning_slot_type_id) REFERENCES cleaning_slot_types (cleaning_slot_type_id),
    CONSTRAINT ck_cleaning_buyouts_count CHECK (bought_count > 0),
    CONSTRAINT ck_cleaning_buyouts_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst) — „welche Familie an welchem Termin eingeteilt ist".
-- Löschanker: geht mit dem Zyklus, nicht mit dem Austritt des Kindes (03,
-- „die Putzdienstdaten folgen weiter der Jahrgangsfrist aus 01"). Bewusst KEINE
-- eigene Anwesenheits-Entität: „Alle drei sind Attribute bzw. Anhängsel der
-- Zuteilung" (grenzkarte.md).
CREATE TABLE cleaning_assignments (
    cleaning_assignment_id uuid NOT NULL DEFAULT gen_random_uuid(),
    cleaning_slot_id       uuid NOT NULL,
    -- Die Art des Termins, hier mitgeführt, damit der Tausch weiter unten sie
    -- ohne Umweg sieht; `fk_cleaning_assignments_slot` hält sie mit dem Termin
    -- zusammen (rules.md Abschnitt 1).
    cleaning_slot_type_id  integer NOT NULL,
    family_id              uuid NOT NULL,
    -- Woher der Termin kommt. Trägt eine Regel: „nur die automatische Zuteilung
    -- selbst rührt Reservierungen nicht an" — sie erkennt sie hieran.
    source                 text NOT NULL,
    -- Der zweite Zustand der Anwesenheit; der dritte steht am Termin
    -- (`attendance_recorded_at`), sonst wäre „false" nicht von „noch nicht
    -- erfasst" zu unterscheiden.
    no_show                boolean NOT NULL DEFAULT false,
    -- Schulleitung und Geschäftsführung ziehen eine verhängte Strafe zurück und
    -- tragen den Rückzug selbst ein; die Forderung selbst zieht Optigem.
    penalty_waived_at      timestamptz,
    penalty_waived_by      text,
    -- Gesetzt vom Monatslauf am 1.; ab da ist die Strafe „für das Sekretariat
    -- nicht mehr korrigierbar".
    penalty_handed_over_at timestamptz,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_cleaning_assignments PRIMARY KEY (cleaning_assignment_id),
    CONSTRAINT fk_cleaning_assignments_slot
        FOREIGN KEY (cleaning_slot_id, cleaning_slot_type_id)
        REFERENCES cleaning_slots (cleaning_slot_id, cleaning_slot_type_id) ON DELETE CASCADE,
    -- Trägt den zusammengesetzten Fremdschlüssel des Angebots weiter unten.
    CONSTRAINT uq_cleaning_assignments_id_type
        UNIQUE (cleaning_assignment_id, cleaning_slot_type_id),
    CONSTRAINT fk_cleaning_assignments_family
        FOREIGN KEY (family_id) REFERENCES families (family_id),
    -- „keine Familie zweimal am selben Termin" (01, Zuteilungsregeln).
    CONSTRAINT uq_cleaning_assignments UNIQUE (cleaning_slot_id, family_id),
    CONSTRAINT ck_cleaning_assignments_source
        CHECK (source IN ('reserved', 'allocated', 'swapped', 'manual')),
    -- Erlassen wird nur eine Strafe, die es gibt.
    CONSTRAINT ck_cleaning_assignments_waiver
        CHECK ((penalty_waived_at IS NULL) = (penalty_waived_by IS NULL)
               AND (penalty_waived_at IS NULL OR no_show)),
    CONSTRAINT ck_cleaning_assignments_handover
        CHECK (penalty_handed_over_at IS NULL OR no_show),
    CONSTRAINT ck_cleaning_assignments_waived_by
        CHECK (penalty_waived_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_cleaning_assignments_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst) — „Kaufen sich von jedem ihrer Termine frei —
-- zugeteilt oder selbst reserviert —, bis zu dessen Freikauf-Frist. Der Termin
-- fällt bei dieser Familie weg". Löschanker: geht mit der Zuteilung, aber im
-- Lauf und nicht per Cascade (siehe `fk_cleaning_slot_buyouts_assignment`
-- unten). Bewusst
-- KEIN Flag an der Zuteilung daneben: die Zeile hier ist die Tatsache, und Q3
-- braucht sie ohnehin als eigenen Anker.
-- Die Frist steht bewusst nicht als Spalte: „die Frist ist fest: drei Tage vor
-- genau diesem Putzdienst, für alle Termine gleich und nirgends einstellbar".
CREATE TABLE cleaning_slot_buyouts (
    cleaning_slot_buyout_id uuid NOT NULL DEFAULT gen_random_uuid(),
    cleaning_assignment_id  uuid NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    created_by              text NOT NULL,

    CONSTRAINT pk_cleaning_slot_buyouts PRIMARY KEY (cleaning_slot_buyout_id),
    -- NO ACTION und nicht Cascade, wie `documents` das Kind festhält: „Das
    -- Sekretariat darf jeden Termin einer Familie streichen oder verschieben,
    -- auch einen selbst reservierten" (01) — und mit Cascade nähme dieses eine
    -- Streichen den bezahlten Freikauf mit, und `fk_payments_cleaning_slot_buyout`
    -- die bestätigte Zahlung gleich hinterher. „Zurücktreten kann man von einem
    -- Freikauf nicht", und ein freigekaufter Termin ist ohnehin schon weg:
    -- „hängt daran schon ein konkreter Termin …, fällt der weg". Zu streichen
    -- bleibt hier also nichts; verschoben wird er weiter.
    -- Der Löschanker bleibt die Zuteilung — er hängt jetzt am Lauf statt am
    -- Fremdschlüssel: der Jahreslauf aus 01 räumt erst die Freikäufe des Zyklus,
    -- dann den Zyklus, und der Lauf aus 17 führt sie in Stufe 3 vor
    -- `cleaning_assignments` (querschnitt-schema.sql).
    CONSTRAINT fk_cleaning_slot_buyouts_assignment
        FOREIGN KEY (cleaning_assignment_id) REFERENCES cleaning_assignments (cleaning_assignment_id),
    -- Ein Termin wird höchstens einmal freigekauft, und „zurücktreten kann man
    -- von einem Freikauf nicht".
    CONSTRAINT uq_cleaning_slot_buyouts UNIQUE (cleaning_assignment_id),
    CONSTRAINT ck_cleaning_slot_buyouts_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Herkunft: 01 (Putzdienst) — „Eine Familie stellt einen ihrer Termine zum
-- Tausch … Eine Familie darf mehrere ihrer Termine gleichzeitig anbieten, je
-- Termin aber nur ein Angebot." Löschanker: geht mit der Zuteilung. Bewusst
-- KEIN Ablaufdatum: „Ein Angebot läuft bis zur Freikauf-Frist seines eigenen
-- Termins und verfällt dann von selbst" — das folgt aus dem Termin.
CREATE TABLE cleaning_swap_offers (
    cleaning_swap_offer_id uuid NOT NULL DEFAULT gen_random_uuid(),
    cleaning_assignment_id uuid NOT NULL,
    -- Die Art des angebotenen Termins, aus der Zuteilung mitgeführt: „Getauscht
    -- wird eins zu eins, nur gegen einen bestehenden Termin derselben Art" (01)
    -- — die Annahme unten vergleicht gegen sie.
    cleaning_slot_type_id  integer NOT NULL,
    -- Gesetzt, sobald sich zwei Angebote gegenseitig akzeptiert haben; danach
    -- ist das Angebot verbraucht und der Tausch vollzogen.
    matched_at             timestamptz,
    created_at             timestamptz NOT NULL DEFAULT now(),
    created_by             text NOT NULL,

    CONSTRAINT pk_cleaning_swap_offers PRIMARY KEY (cleaning_swap_offer_id),
    CONSTRAINT fk_cleaning_swap_offers_assignment
        FOREIGN KEY (cleaning_assignment_id, cleaning_slot_type_id)
        REFERENCES cleaning_assignments (cleaning_assignment_id, cleaning_slot_type_id)
        ON DELETE CASCADE,
    -- Je Termin nur ein OFFENES Angebot: der partielle Index unter der Tabelle,
    -- nicht hier. Ein unbedingtes UNIQUE ließe jeden Termin nur ein einziges
    -- Mal im Putzdienstjahr tauschen, weil das vollzogene Angebot stehen bleibt.
    -- Trägt den zusammengesetzten Fremdschlüssel der Annahme unten.
    CONSTRAINT uq_cleaning_swap_offers_id_type
        UNIQUE (cleaning_swap_offer_id, cleaning_slot_type_id),
    CONSTRAINT ck_cleaning_swap_offers_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- 01: „Eine Familie darf mehrere ihrer Termine gleichzeitig anbieten, je Termin
-- aber nur ein Angebot" — eine Aussage über die offenen Angebote. Das
-- vollzogene bleibt daneben stehen („danach ist das Angebot verbraucht",
-- `matched_at`), und derselbe Termin lässt sich danach erneut anbieten: Nach
-- dem Tausch trägt die Zuteilung einen anderen Termin, und kein Block sagt, dass
-- eine Familie einen Termin nur einmal je Jahr tauschen darf. Deshalb partiell
-- und nicht unbedingt — wie `ix_sepa_mandates_current` (stammdaten-schema.sql).
CREATE UNIQUE INDEX ix_cleaning_swap_offers_open
    ON cleaning_swap_offers (cleaning_assignment_id) WHERE matched_at IS NULL;

-- Herkunft: 01 (Putzdienst) — „hakt in der Liste der angebotenen Termine
-- derselben Art alle an, die sie dafür nehmen würde. Akzeptieren sich zwei
-- Angebote gegenseitig, tauscht das System sofort." Löschanker: geht mit dem
-- Angebot. Eine Zeile ist ein Kreuz auf der Liste, kein Vorgang.
-- Bewusst KEINE Familie an der Annahme und damit kein Constraint für „eine
-- Familie kann keinen Termin annehmen, an dem sie schon steht" (01, Schritt 8):
-- Die Regel ist eine Abwesenheit — es dürfte keine Zuteilung dieser Familie an
-- diesem Termin geben —, und die trägt kein Fremdschlüssel und kein CHECK. Die
-- Anwendung prüft sie vor dem Ankreuzen, damit das Kreuz gar nicht erst
-- angeboten wird; kommt sie doch durch, weist `uq_cleaning_assignments` den
-- Tausch ab („keine Familie zweimal am selben Termin", 01) — dann mitten im
-- Vorgang statt an der Liste. Die beiden Nachbarregeln desselben Satzes stehen
-- dagegen im Schema: „nur gegen einen bestehenden Termin derselben Art" trägt
-- der zusammengesetzte Fremdschlüssel unten, „je Termin nur ein Angebot"
-- `ix_cleaning_swap_offers_open`.
CREATE TABLE cleaning_swap_acceptances (
    cleaning_swap_acceptance_id uuid NOT NULL DEFAULT gen_random_uuid(),
    cleaning_swap_offer_id      uuid NOT NULL,
    -- Der fremde Termin, den diese Familie nehmen würde. Auf den Termin und
    -- nicht auf das fremde Angebot, damit ein zurückgezogenes und neu
    -- gestelltes Angebot dieselbe Bereitschaft nicht verliert.
    cleaning_slot_id            uuid NOT NULL,
    -- Eine Spalte, zwei Fremdschlüssel: sie hängt zugleich am Angebot und am
    -- angekreuzten Termin und ist damit die Regel „nur gegen einen bestehenden
    -- Termin derselben Art" (01) — ein Großputz lässt sich nicht gegen einen
    -- regulären Termin ankreuzen.
    cleaning_slot_type_id       integer NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    created_by                  text NOT NULL,

    CONSTRAINT pk_cleaning_swap_acceptances PRIMARY KEY (cleaning_swap_acceptance_id),
    CONSTRAINT fk_cleaning_swap_acceptances_offer
        FOREIGN KEY (cleaning_swap_offer_id, cleaning_slot_type_id)
        REFERENCES cleaning_swap_offers (cleaning_swap_offer_id, cleaning_slot_type_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_cleaning_swap_acceptances_slot
        FOREIGN KEY (cleaning_slot_id, cleaning_slot_type_id)
        REFERENCES cleaning_slots (cleaning_slot_id, cleaning_slot_type_id) ON DELETE CASCADE,
    CONSTRAINT uq_cleaning_swap_acceptances
        UNIQUE (cleaning_swap_offer_id, cleaning_slot_id),
    CONSTRAINT ck_cleaning_swap_acceptances_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Fremdschlüssel von Q3 auf diese Domäne
-- ---------------------------------------------------------------------------
-- Beide Spalten stehen in querschnitt-schema.sql; die Constraints entstehen
-- hier, weil erst jetzt Zieltabellen existieren (grenzkarte.md, Q3: „angelegt
-- mit den beiden Putzdienst-Freikäufen").
-- Beide mit Cascade: „Löschanker: geht mit dem Vorgang, an dem die Zahlung
-- hängt" (querschnitt-schema.sql) — ohne ihn hielte die Zahlung den Freikauf
-- fest, dessen Löschanker sie selbst ist, und der Lauf aus 01 käme nie an.
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_cleaning_buyout
        FOREIGN KEY (cleaning_buyout_id) REFERENCES cleaning_buyouts (cleaning_buyout_id)
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_payments_cleaning_slot_buyout
        FOREIGN KEY (cleaning_slot_buyout_id) REFERENCES cleaning_slot_buyouts (cleaning_slot_buyout_id)
        ON DELETE CASCADE;

-- Derselbe Fall für den siebten Bezug der Nachzieh-Aufgabe: 01 nennt „eine
-- offene Aufgabe bei der zuständigen Person … Anwesenheitsliste ausdrucken",
-- und sie hängt am einzelnen Termin, weil sie „ein bis zwei Tage vor dem Termin
-- fällig" ist. Die Spalte steht in querschnitt-schema.sql, der Fremdschlüssel
-- hier. Mit Cascade: „die erledigten Nachzieh-Aufgaben gehen mit den Daten, auf
-- die sie sich beziehen" (02).
ALTER TABLE sync_tasks
    ADD CONSTRAINT fk_sync_tasks_cleaning_slot
        FOREIGN KEY (cleaning_slot_id) REFERENCES cleaning_slots (cleaning_slot_id)
        ON DELETE CASCADE;


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------
-- Keine. Die einzige Dateifrage dieser Domäne ist die eingescannte
-- Unterschriftenliste, und Block 01 entscheidet sie: Sie wird „eingescannt beim
-- Termin abgelegt", steht als Bibliothek und Graph-Kennung an `cleaning_slots`
-- und geht mit dem Putzdienstjahr („Die eingescannten Anwesenheitslisten gehen
-- mit"). Der Jahreslauf löscht über den Zyklus und muss die Dateien in
-- SharePoint vorher mitnehmen — er kennt den Zyklus, den er räumt, und liest
-- dessen Termine, bevor er sie kaskadieren lässt; „eine verwaiste Datei in
-- SharePoint ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile"
-- (querschnitt-schema.sql). Block 01 lässt sonst nichts offen, was das Schema
-- betrifft; der einzige offene Punkt dort — die digitale Anwesenheitserfassung
-- — ist ausdrücklich „zweite Iteration" und trägt heute keine Spalte.
