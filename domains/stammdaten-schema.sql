-- Stammdaten-Kernschema (Person, Adresse, Familie, Erziehungsberechtigte, Kind,
-- Kontakte, Zahlungsverantwortliche). Konzeptioneller Entwurf zu
-- domains/stammdaten.md — konkreter als Prosa, aber noch kein Alembic-
-- Migrationscode. Übertragung in SQLAlchemy-2.0-Modelle + Alembic-Migration
-- folgt im App-Stack-Repo (wb-backend), gemäß dessen eigener CLAUDE.md
-- (englische Bezeichner, dort Abschnitt 1/8).
--
-- Gegengelesen gegen vier reale Schulverwaltungs-Schemata (ASV-BW-Strukturdump,
-- SVWS-NRW, GibbonEdu, eigenes Vorprojekt), um Randfälle nicht neu zu erfinden.
-- Wo eine Referenz bewusst NICHT übernommen wurde, steht der Grund am Feld.
--
-- id-Typ: uuid statt fortlaufender Zahl für alle personenbezogenen Entitäten —
-- verhindert, dass eine Familie/Person über die reine ID einer anderen erraten
-- werden kann (Defense in Depth zusätzlich zum ohnehin nötigen Ownership-Check,
-- idea/04). Nativ ab Postgres 13 (gen_random_uuid()), keine Extension nötig.
-- Kleine Referenztabellen (Lookups, Klassen): integer-Identity, kein
-- Ownership-Check nötig, tauchen nie in einer URL für Externe auf.
--
-- Ein Ort pro Sachverhalt (rules.md Abschnitt 1): jedes Attribut existiert an
-- genau einer Stelle. Kein Feld darf je nach Fall in zwei Tabellen stehen können,
-- sonst wird bei einer Änderung eine der beiden Stellen vergessen. Deshalb:
--   * persons trägt, was JEDE natürliche Person hat (Identität, Erreichbarkeit,
--     Anschrift) — Demografie steht am Kind, Beruf am Erziehungsberechtigten.
--   * Kind, Erziehungsberechtigte, Kontakt und Zahlungsverantwortliche/r sind
--     Rollen AUF persons, keine parallelen Personentabellen mit je eigenen
--     Namens-/Telefonspalten.
--   * Organisationen sind eine eigene Tabelle, nicht ein Satz Zusatzspalten auf
--     guardians, die bei natürlichen Personen leer bliebe.
--   * Kein abgeleitetes/redundantes Feld — auch nicht Klassenstufe und Klasse am
--     Kind: children.provisional_grade_level_id und children.class_id schließen
--     sich per CHECK gegenseitig aus, es gibt also nie zwei Werte für denselben
--     Sachverhalt gleichzeitig (Begründung an der Tabelle).
--
-- Datensparsamkeit (rules.md Abschnitt 7): ein Feld existiert nur, wenn es auf
-- einem realen Formular steht ODER ein benannter Prozess es braucht. Deshalb
-- führen Erziehungsberechtigte kein Geburtsdatum und keine Demografie.
--
-- Audit-Spalten: created_at/created_by/updated_at/updated_by auf jeder Tabelle mit
-- veränderlichem Inhalt (idea/03) — dazu zählen classes/grade_levels (Jahreslauf
-- bzw. Regeländerung über die Verwaltungsoberfläche sind ebenfalls Änderungen),
-- nicht aber die übrigen, nur per Bezeichnung änderbaren Lookup-Tabellen.
-- Format von created_by/updated_by — durchgängig mit Präfix, damit alle drei
-- Formen greppbar und maschinell unterscheidbar sind:
--   "entra:<oid>"      — Entra-ID Object-ID des internen Nutzers (stabil, überlebt
--                        Namens-/Mailwechsel, anders als UPN)
--   "guardian:<uuid>"  — Erziehungsberechtigte über den OTP-Pfad (idea/04)
--   "system:<job>"     — automatische Läufe (z. B. "system:import", "system:rollover")
-- Der Trigger prüft das Präfix, bewusst nicht die Nutzlast: der reale Fehlermodus
-- ist ein vertippter oder ganz fehlender Präfix, nicht eine kaputte UUID. Ein
-- solcher Wert landet sonst in zehntausenden Zeilen und lässt sich hinterher
-- nicht mehr von einem echten unterscheiden.
-- Alle vier Spalten werden per Trigger gefüllt (ganz unten), nicht von der
-- Anwendung — kein Schreibpfad kann sie vergessen. created_by/updated_by sind
-- zusätzlich NOT NULL: der Trigger ist der Regelweg, NOT NULL der Schema-Backstop,
-- falls ein Schreibpfad den Trigger je umgeht (z. B. absichtlich deaktiviert für
-- einen Bulk-Import).

-- Unveränderliche Spalten: id auf jeder Tabelle sowie die Identitäts-
-- Fremdschlüssel person_id/organization_id auf guardians und payers bleiben nach
-- dem Anlegen unveränderlich, durchgesetzt per Spaltenrecht der Laufzeit-Rolle
-- (wb-backend/db/init-roles.sh) — kein Trigger nötig, keine Laufzeitkosten,
-- derselbe Mechanismus wie beim Art.-9-Spaltenschutz unten. Damit wird eine
-- natürliche Person nie zur Organisation und umgekehrt, und ein Guardian lässt
-- sich nicht auf einen anderen Menschen umbiegen: das verschöbe sämtliche
-- Familienzugehörigkeiten und damit den OTP-Ownership-Check (idea/04)
-- stillschweigend mit.
-- Für die Umsetzung, gegen Postgres 16 verifiziert:
--   * Die Laufzeit-Rolle darf KEIN tabellenweites GRANT UPDATE bekommen. Das
--     deckt alle Spalten ab, und ein nachträgliches REVOKE UPDATE (spalte) hebt
--     es nicht auf — der Schreibzugriff bliebe erlaubt. Stattdessen nur die
--     zugelassenen Spalten einzeln granten: GRANT UPDATE (spalte, …) ON tabelle.
--   * Die vier Audit-Spalten brauchen dabei kein GRANT — der Trigger unten setzt
--     sie unabhängig von den Spaltenrechten des Aufrufers.
--   * Wie beim Art.-9-Schutz wirkt das weder gegen den Tabelleneigentümer noch
--     gegen die Migrations-Rolle (die darf das richtigerweise), und das
--     Prüfskript kann es nicht belegen, da es als Superuser läuft.

CREATE EXTENSION IF NOT EXISTS citext;  -- für case-insensitive E-Mail-Vergleiche

-- ---------------------------------------------------------------------------
-- Lookup-Tabellen und Schulstruktur (rules.md Abschnitt 3: Kategoriewerte als
-- Daten, nicht als ENUM/CHECK) — Bezeichnung frei änderbar über die
-- Verwaltungsoberfläche, keine Migration pro Umbenennung. classes steht der
-- Schulstruktur wegen mit in diesem Block, ist aber keine Werteliste, sondern
-- die Kohorten-Entität (Begründung an der Tabelle).
--
-- Drei von ihnen sind Sonderfälle: countries, languages und genders führen neben
-- dem frei änderbaren label eine code-Spalte, deren Werte einer externen Liste
-- gehören (ISO 3166-1 alpha-3, BCP 47 bzw. ASV-BW-Werteliste). Diese Listen
-- werden geseedet, nicht von Hand gepflegt; der label bleibt trotzdem frei
-- ("Türkei"/"Türkiye"). Der Formatprüf-CHECK auf code sichert deshalb Seed und
-- Import, nicht eine laufende Eingabe.
-- code ist zudem nach dem Anlegen unveränderlich — nicht per Trigger, sondern
-- schlicht dadurch, dass er nicht ins Spalten-GRANT der Laufzeit-Rolle kommt
-- (Kopfkommentar oben): ein geänderter code würde still die Bedeutung jeder
-- referenzierenden Zeile verschieben, statt nur eine Bezeichnung zu ändern.
-- ---------------------------------------------------------------------------

-- Geschlecht ist das amtliche Merkmal für ASV-BW und Statistik (domains/
-- stammdaten.md), deshalb wie countries/languages mit stabilem code neben dem
-- frei umbenennbaren label. Konkreter Abnehmer ist der CSV-Export nach ASV-BW
-- (fachdomaenen.md): setzte er auf dem label auf, bräche er still, sobald jemand
-- "divers" umbenennt — der code ist der Wert, der die Umbenennung überlebt.
--
-- ISO 5218 geprüft und bewusst NICHT übernommen: die Norm kennt nur 0/1/2/9
-- (unbekannt/männlich/weiblich/nicht anwendbar) und kann "divers" gar nicht
-- ausdrücken — das seit 2018 nach §22 Abs. 3 PStG erforderliche dritte
-- Geschlecht wäre damit nicht abbildbar, die Norm anzuwenden also schlechter als
-- kein Code. Die Werte kommen stattdessen aus der ASV-BW-Werteliste
-- (svp_wl_wert.schluessel); der CHECK sichert nur die Form — kurz, ohne
-- Leerzeichen, damit dort nicht die Bezeichnung selbst landet.
CREATE TABLE genders (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE,  -- z. B. "männlich", "weiblich", "divers", "keine Angabe"
    code  text NOT NULL UNIQUE CHECK (code ~ '^[A-Za-z0-9]{1,8}$')
);

-- Anrede für Anschreiben ("Herr", "Frau", "keine Anrede"). Bewusst getrennt vom
-- Geschlecht und NICHT daraus abgeleitet: Geschlecht ist das amtliche Merkmal für
-- ASV-BW/Statistik, die Anrede die Ansprache im Schreiben — bei "divers", bei
-- "keine Anrede" (Anrede steckt schon im Namen, z. B. "Freiherr von") und bei
-- persönlicher Präferenz gibt es keine Ableitung. ASV-BW und SVWS-NRW führen
-- beide Felder ebenfalls nebeneinander. Fehlt heute im ASV-Export nach Vis365
-- und damit in M365 — Rundschreiben sind deshalb dort nicht sauber anredbar.
CREATE TABLE salutations (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE
);

-- Akademischer Grad ("Dr.", "Prof. Dr.") — gehört zur Ansprache im Schreiben,
-- nicht zum Namen. Werteliste wie in ASV-BW (wl_akademischer_grad).
CREATE TABLE academic_titles (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE
);

-- Klassifizierung einer Erziehungsberechtigten-Beziehung (z. B. "Elternteil",
-- "Pflegeeltern", "Jugendamt", "Vereinsvormund") — rein informativ. Hängt an
-- family_guardians, nicht am Erziehungsberechtigten: dieselbe Person kann in
-- einer Familie leiblicher Elternteil und in einer anderen Pflegeelternteil sein.
-- Entspricht K_ErzieherArt in SVWS-NRW.
CREATE TABLE guardian_categories (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE
);

CREATE TABLE denominations (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE   -- z. B. "römisch-katholisch", "evangelisch", "konfessionslos"
);

-- Verkehrssprache des Kindes. Lookup statt Freitext (rules.md Abschnitt 3):
-- wiederholte Auswahl aus einem stabilen Satz, und der Wert speist den
-- ASV-BW-Export — getippt würde daraus "de"/"De"/"deutsch"/"German". label ist
-- die Anzeige in der Verwaltungsoberfläche, code der BCP-47-Wert für den Export.
-- code-CHECK: BCP-47-Grundform, kleingeschriebenes Primär-Subtag (2–3 Buchstaben,
-- deckt ISO 639-1/-2/-3 ab) plus beliebig viele Subtags — erlaubt "de", "tr",
-- "de-DE", "zh-Hant", "es-419". Bewusst auf die kanonische Kleinschreibung des
-- Primär-Subtags festgelegt, dieselbe Normalisierungslogik wie bei der IBAN:
-- "DE" und "de" wären sonst zwei Zeilen für dieselbe Sprache, und genau das
-- soll die Spalte verhindern ("deutsch"/"German" fallen ohnehin durch).
CREATE TABLE languages (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE,  -- z. B. "Deutsch", "Türkisch"
    code  text NOT NULL UNIQUE CHECK (code ~ '^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$')  -- BCP 47, z. B. "de", "tr"
);

-- Land (Anschrift, Geburtsland, Staatsangehörigkeit). Lookup statt ISO-Code als
-- Freitext (rules.md Abschnitt 3), aus demselben Grund wie languages — und beide
-- Spalten der Lookup werden gebraucht, weil der Weg nach ASV-BW beide anspricht:
-- Weltenbaum erzeugt einen CSV-Export, ein Mensch passt ihn von Hand an, ASV-BW
-- importiert ihn (fachdomaenen.md). Der label trägt die Sichtprüfung dazwischen
-- ("Türkei" ist prüfbar, "TUR" kaum), der code die maschinelle Seite: ein Export,
-- der auf der frei umbenennbaren Bezeichnung aufsetzt, bricht still, sobald jemand
-- eine Zeile umbenennt. Ohne Lookup läge die Länderliste zwangsläufig hartkodiert
-- in der Eingabemaske: dieselbe CHECK-Konstante, nur eine Schicht weiter außen. Ein Regex auf zwei Großbuchstaben wäre keine
-- Werteliste — "XX" und vor allem das häufige "UK" (ISO wäre "GB") kämen
-- ungehindert durch. ASV-BW führt Staatsangehörigkeit, Geburtsland und Staat der
-- Anschrift ebenfalls als Werteliste (svp_*.wl_staatsangehoerigkeit_id /
-- wl_geburtsland_id / wl_staat_id → SVP_WL_WERT), nicht als ISO-Code.
-- label ist die Anzeige, code der ISO-3166-1-alpha-3-Wert. Bewusst alpha-3 statt
-- des verbreiteteren alpha-2, aus zwei Gründen: alpha-2 ist die einzige der drei
-- Varianten mit realer Neuvergabe-Historie (CS war Tschechoslowakei, später
-- Serbien und Montenegro), und alpha-2 kollidiert optisch mit languages.code
-- direkt daneben — "DE"/"de" sind Land und Sprache und in einem Export nicht
-- auseinanderzuhalten, "DEU"/"de" schon. Numeric-3 (276) wird zwar nie neu
-- vergeben, ist aber für einen Menschen im Sekretariat nicht lesbar.
-- Die Liste wird aus ISO 3166-1 geseedet, nicht von Hand gepflegt; der CHECK auf
-- code sichert deshalb Seed und Import, er ersetzt die Liste nicht.
CREATE TABLE countries (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE,                           -- z. B. "Deutschland", "Türkei"
    code  text NOT NULL UNIQUE CHECK (code ~ '^[A-Z]{3}$')  -- ISO 3166-1 alpha-3, z. B. "DEU", "TUR"
);

-- Art einer Telefonnummer ("Festnetz", "Mobil", "Arbeit"). Lookup statt fester
-- Spalten, damit eine vierte Art eine Datenzeile ist und keine Migration —
-- Muster von SVWS-NRW (K_TelefonArt) und ASV-BW (Kommunikationstyp).
CREATE TABLE phone_types (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE
);

-- Schulzweig — heute Grundschule und Realschule (fachdomaenen.md Abschnitt 1).
CREATE TABLE school_branches (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE
);

-- Klassenstufen als Daten statt als Zahlenbereich: label ist frei ("1", "10",
-- "VKL", "J1"), sort_order ordnet innerhalb des Zweigs. is_final_grade markiert
-- die jeweils letzte Klasse eines Zweigs und trägt damit die Abschlussklassen-
-- Regel des Putzdiensts (domains/putzdienst.md, „Abgänge & Klassenstufen-
-- Übergänge") als Datum statt als Konstante im Code — Regeländerung ist ein
-- UPDATE, keine Migration und kein Codetouch
-- (rules.md Abschnitt 3). Mit Audit-Spalten, anders als die übrigen Lookup-
-- Tabellen: is_final_grade steuert die Putzdienst-Abgangslogik direkt, eine
-- unbemerkte Fehländerung hat also eine reale Auswirkung auf laufende
-- Zuteilungen statt nur eine Bezeichnung zu ändern.
CREATE TABLE grade_levels (
    id               integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    school_branch_id integer NOT NULL REFERENCES school_branches(id) ON DELETE RESTRICT,
    label            text NOT NULL,
    sort_order       smallint NOT NULL,
    is_final_grade   boolean NOT NULL DEFAULT false,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,
    updated_at       timestamptz NOT NULL DEFAULT now(),
    updated_by       text NOT NULL,
    UNIQUE (school_branch_id, label),
    UNIQUE (school_branch_id, sort_order),
    -- Ziel des zusammengesetzten Fremdschlüssels von classes unten — hält
    -- classes.school_branch_id konsistent zur jeweils referenzierten
    -- Klassenstufe, statt es unabhängig pflegbar zu lassen.
    UNIQUE (id, school_branch_id)
);
-- Höchstens eine Abschlussklasse je Zweig. Ohne diesen Index ließen sich zwei
-- Klassenstufen desselben Zweigs als "letzte" markieren, und die Putzdienst-
-- Abgangsregel (domains/putzdienst.md) sperrte den September-Termin still für
-- Familien, die noch ein Jahr bleiben — sichtbar wird das nirgends, denn
-- is_final_grade steht in keiner Anzeige. Dieselbe Bauform wie bei
-- phone_numbers/child_payers.is_primary. Dass überhaupt eine Zeile je Zweig
-- gesetzt ist, sichert wie dort die Eingabemaske: schemaseitig wäre das eine
-- Bedingung über mehrere Zeilen hinweg und damit ein weiterer Trigger.
CREATE UNIQUE INDEX ON grade_levels (school_branch_id) WHERE is_final_grade;

-- Klasse als Kohorte ("RS25a"), nicht als Klassenstufen-Slot: die Zeile ist ein
-- Zug eines Jahrgangs innerhalb eines Zweigs (Zweig + Eintrittsjahr + Zug),
-- nicht eine feste Klassenstufe. Stabil ist dabei die ZEILE, nicht ihre
-- Besetzung — Quereinsteiger kommen dazu, Abgänger fallen weg, Wiederholer
-- wechseln auf die Kohorte der zu wiederholenden Stufe (domains/stammdaten.md,
-- „Schuljahreswechsel"). Deshalb trägt die Zeile selbst die Kohorten-Identität
-- (school_branch_id, entry_year, stream) und nicht die Menge ihrer Kinder. grade_level_id
-- ist die AKTUELLE Klassenstufe und wird beim jährlichen Jahreslauf auf
-- derselben Zeile fortgeschrieben, ohne die Kinder auf eine andere Klassenzeile
-- umzuhängen. Diese Kennung ist an der Schule bereits im Gebrauch, u. a. für
-- die digitale Schülerakte — Ordnerstruktur/Ablage bleiben über die gesamte
-- Schulzeit einer Kohorte stabil.
--
-- entry_year: Startjahr der Kohorte im jeweiligen Zweig, nicht der Eintritt des
-- einzelnen Kindes — der steht als children.entry_date am Kind und weicht bei
-- Quereinsteigern ab.
-- Kalenderjahr, in dem das Schuljahr der Kohorte beginnt, vierstellig
-- (z. B. 2025 für Schuljahr 25/26) — konsistent mit date_of_birth/entry_date,
-- keine Y2K-artige Mehrdeutigkeit. Die zweistellige Kurzform in „RS25a" ist reine
-- Anzeigeberechnung (entry_year % 100), kein eigener Speicherwert.
--
-- Kein Anzeigename als Spalte: sowohl die aktuelle Klassenbezeichnung ("5a",
-- für Klassenlisten/M365-Verteiler/Vis365-Export) als auch die Kohorten-
-- Kennung ("RS25a", für die Akte) sind aus school_branch_id, entry_year,
-- stream und der jeweils aktuellen grade_levels.label berechenbar — kein
-- abgeleitetes/redundantes Feld (rules.md Abschnitt 1).
--
-- school_branch_id ist eine kontrollierte Doppelung zu grade_level_id:
-- school_branch_id + entry_year + stream müssen zusammen eindeutig sein (zwei
-- Zweige können im selben Jahr beide einen Zug "a" einschulen) — das geht nur
-- mit einer echten Spalte, nicht über den Umweg grade_level_id →
-- grade_levels.school_branch_id. Der zusammengesetzte Fremdschlüssel hält
-- beide Spalten konsistent.
--
-- grade_level_id trägt bewusst KEINEN eigenen einspaltigen Fremdschlüssel
-- daneben: der zusammengesetzte unten verlangt ohnehin eine Zeile mit passendem
-- (id, school_branch_id), beide Spalten sind NOT NULL, und beim Löschen einer
-- Klassenstufe blockiert er genauso (Default NO ACTION, nicht DEFERRABLE) wie
-- ein ON DELETE RESTRICT. Ein zweiter Fremdschlüssel wäre eine Einschränkung
-- ohne eigene Wirkung; das Prüfskript belegt, dass die Sperre trotzdem greift.
CREATE TABLE classes (
    id               integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    school_branch_id integer NOT NULL REFERENCES school_branches(id) ON DELETE RESTRICT,
    grade_level_id   integer NOT NULL,
    entry_year       smallint NOT NULL,
    -- "a", "b", … — Freitext statt Lookup (rules.md Abschnitt 3): der Zug ist
    -- Teil der Kohorten-Identität dieser einen Zeile, keine wiederholte Auswahl
    -- aus einem gepflegten Wertevorrat, und niemand gruppiert über Zeilen hinweg
    -- danach. Eine Lookup-Tabelle wäre Pflegeaufwand ohne Nutzen. CHECK <> ''
    -- begründet an persons.last_name — ein leerer Zug macht die Kohorten-Kennung
    -- "RS25" mehrdeutig.
    stream           text NOT NULL CHECK (stream <> ''),
    -- Kohorte ist durch — oder ein Zug wurde aufgelöst (zu wenige Kinder, in den
    -- Parallelzug zusammengelegt). Die Zeile bleibt für die Akte stehen, zählt
    -- aber nirgends mehr als Klasse mit: Klassenlisten, Auswahlfelder,
    -- M365-Verteiler und die Putzdienst-Pflichtermittlung
    -- (domains/putzdienst.md) lesen ausschließlich aktive Klassen. Der
    -- Jahreslauf setzt das Kennzeichen, wenn eine Kohorte über die
    -- Abschluss-Klassenstufe hinaus ist; grade_level_id bleibt dabei auf der
    -- letzten Stufe stehen, eine nächste gibt es nicht.
    --
    -- Bewusst gespeichert statt abgeleitet, obwohl „hat noch Kinder ohne
    -- exit_date" nahe liegt (rules.md Abschnitt 1): die Klassenzeile eines neuen
    -- Jahrgangs existiert vor ihren Kindern — genau dafür gibt es
    -- children.provisional_grade_level_id — und wäre nach dieser Ableitung
    -- fälschlich inaktiv. Umgekehrt hinge „aktiv" sonst daran, dass der
    -- Jahreslauf bei jedem einzelnen Kind das Abgangsdatum gesetzt hat; das
    -- Kennzeichen an der Kohorte ist die davon unabhängige zweite Aussage.
    -- Dass eine inaktive Klasse keine Kinder ohne exit_date mehr hat, sichert
    -- der Jahreslauf — schemaseitig wäre das eine Bedingung über mehrere Zeilen
    -- hinweg und damit ein weiterer Trigger, gleiche Abwägung wie bei
    -- phone_numbers.is_primary.
    --
    -- Ja/Nein-Merkmal, keine Auswahl aus benannten Alternativen: Boolean statt
    -- Lookup (rules.md Abschnitt 3). Und bewusst kein „Ehemalige" als weitere
    -- grade_levels-Zeile, auf die der Jahreslauf sonderfallfrei weiterschalten
    -- könnte — das ist keine Klassenstufe und wäre über
    -- children.provisional_grade_level_id einem Kind zuweisbar.
    -- Kein Index: die Tabelle hat die Größenordnung Dutzende Zeilen, der Planer
    -- liest sie ohnehin am Stück (domains/stammdaten-schema-benchmark.md).
    is_active        boolean NOT NULL DEFAULT true,
    -- Klassenlehrer:in und Klassenzimmer stehen beide auf der real geführten
    -- Klassenliste des Sekretariats. Der Fremdschlüssel auf employees wird
    -- weiter unten per ALTER TABLE nachgezogen (Reihenfolge, siehe dort).
    -- Raum als Freitext statt Lookup (rules.md Abschnitt 3): niemand wertet
    -- über Räume hinweg aus, und eine Raumverwaltung gibt es nicht.
    class_teacher_id uuid,
    room             text,
    -- Audit-Spalten hier wie bei grade_levels bewusst vorhanden, anders als bei
    -- den übrigen Lookup-Tabellen: grade_level_id wird vom Jahreslauf jährlich
    -- fortgeschrieben (Tabellenkommentar oben) — ohne created_by/updated_by
    -- wäre ein fehlerhafter Lauf nicht auf Verursacher/Zeitpunkt zurückzuführen.
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,
    updated_at       timestamptz NOT NULL DEFAULT now(),
    updated_by       text NOT NULL,
    UNIQUE (school_branch_id, entry_year, stream),
    FOREIGN KEY (grade_level_id, school_branch_id) REFERENCES grade_levels(id, school_branch_id),
    CHECK (entry_year BETWEEN 2000 AND 2100)
);

-- Abgebende Schule (steht auf beiden Voranmeldeformularen, siehe
-- children.previous_school_id).
-- Lookup statt Freitext, weil dieselbe Grundschule sonst in drei Schreibweisen
-- in der Datenbank steht; wächst über die Verwaltungsoberfläche.
CREATE TABLE previous_schools (
    id    integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label text NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------------
-- Anschrift
-- ---------------------------------------------------------------------------

-- Eigene Tabelle statt Adressspalten an jeder Person: Kind und ein oder beide
-- Erziehungsberechtigte wohnen im Regelfall unter derselben Anschrift — eine
-- Familie zieht um, und ohne gemeinsame Zeile wären das drei bis fünf
-- Änderungen, von denen erfahrungsgemäß eine vergessen wird (rules.md
-- Abschnitt 1). ASV-BW löst es genauso (svp_anschrift, referenziert von Person
-- und Kontakt); SVWS-NRW dupliziert die Adresse stattdessen an Schüler und
-- Erzieher — genau der Zustand, den wir vermeiden wollen.
--
-- Preis dieser Entscheidung, in der Verwaltungsoberfläche zu lösen und nicht im
-- Schema: eine geteilte Zeile zu ändern ändert sie für alle, die daran hängen.
-- Die Maske muss beim Bearbeiten fragen „nur für diese Person" (= neue Zeile
-- anlegen und umhängen) oder „für alle an dieser Anschrift" (= Zeile ändern).
-- Der Trennungsfall — ein Elternteil zieht aus — ist der erste Fall, nicht der
-- zweite. Index auf persons.address_id existiert genau für diese Rückfrage.
--
-- Getrennte Personen bekommen dadurch je ihre eigene Adresszeile; es gibt
-- weiterhin keine mehrdeutige "Familienadresse".
CREATE TABLE addresses (
    id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    street       text,
    house_number text,               -- text statt Zahl wegen "12a", "12-14"
    district     text,               -- Teilort (baden-württembergische Besonderheit, ASV: ortsteil)
    postal_code  text,
    city         text,
    -- Kein DB-DEFAULT auf Deutschland: das wäre eine fest verdrahtete Lookup-ID
    -- im Schema. Die Eingabemaske wählt Deutschland vor, der Import liefert den
    -- Wert mit.
    country_id   integer NOT NULL REFERENCES countries(id) ON DELETE RESTRICT,
    created_at   timestamptz NOT NULL DEFAULT now(),
    created_by   text NOT NULL,
    updated_at   timestamptz NOT NULL DEFAULT now(),
    updated_by   text NOT NULL
);
-- Ohne diesen Index findet die Eingabemaske eine bestehende Adresszeile beim
-- Erfassen praktisch nie (voller Scan pro Eingabe) — dann sammeln sich
-- Dubletten an, und das ganze „geteilte Anschrift"-Konzept oben verwaist in
-- der Praxis. Bewusst kein UNIQUE: der dokumentierte „nur für diese Person"-Split
-- legt kurzzeitig bewusst eine wertgleiche Zweitzeile an.
CREATE INDEX ON addresses (postal_code, street, house_number);

-- ---------------------------------------------------------------------------
-- Personen und Organisationen
-- ---------------------------------------------------------------------------

-- Person: gemeinsame Stammdaten jedes natürlichen Menschen im System — Kind,
-- natürliche Erziehungsberechtigte-Person, Kontaktperson, Zahlungsverantwortliche/r;
-- künftig auch Personal/Lehrer. Nur Attribute, die für jede Rolle gelten;
-- Rollenspezifisches steht auf children/guardians/payers. Organisationen sind
-- keine Personen (eigene Tabelle unten). Entspricht svp_person (ASV-BW) und
-- gibbonPerson (Gibbon).
CREATE TABLE persons (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    salutation_id     integer REFERENCES salutations(id) ON DELETE RESTRICT,
    academic_title_id integer REFERENCES academic_titles(id) ON DELETE RESTRICT,
    first_name        text,            -- nullable: seltene Einzelname-Fälle
    -- CHECK <> '': NOT NULL allein lässt den Leerstring durch — beim Vollimport
    -- aus CSV/Excel der häufigste Artefakt (wie bei email unten), und auf einer
    -- identitätstragenden Pflichtspalte fällt er hinterher nur als "leeres Feld"
    -- auf. Ebenso an organizations.name, phone_numbers.number, classes.stream;
    -- bewusst nicht an den nullable Freitextspalten, dort ist '' statt NULL kein
    -- Identitätsproblem und ein CHECK je Spalte wäre Aufwand ohne Nutzen.
    last_name         text NOT NULL CHECK (last_name <> ''),
    gender_id         integer REFERENCES genders(id) ON DELETE RESTRICT,
    address_id        uuid REFERENCES addresses(id) ON DELETE RESTRICT,
    -- E-Mail der Person. Bei Erziehungsberechtigten zugleich die Identität für
    -- den OTP-Login (idea/04) — und bewusst NICHT UNIQUE: an der Schule teilen
    -- sich real 1–2 Elternpaare je Klasse eine Mailbox, und die Voranmeldung
    -- erzeugt den Fall aktiv (die Mutter trägt ihre Adresse für beide ein). Ein
    -- UNIQUE löste ihn nicht auf, sondern versteckte ihn: der zweite Insert
    -- bricht, und statt eines zweiten Postfachs entsteht erfahrungsgemäß eine
    -- erfundene Adresse, die niemand liest — beide Codes landen weiterhin in
    -- derselben Mailbox, aber die Datenbank sieht sauber aus. Ohne UNIQUE bleibt
    -- der Zustand abfragbar (zwei Personen derselben Familie mit gleicher
    -- email), und das Sekretariat weiß vor einem Prozess mit Doppelzustimmung,
    -- wo es auf Papier nachfassen muss.
    --
    -- Folge für den OTP-Pfad: ein Treffer kann mehrere Personen ergeben; der
    -- Check liefert dann die Vereinigung ihrer Familien, und die Oberfläche
    -- fragt nach Code-Eingabe, als wer die Sitzung läuft — Bedienführung, keine
    -- Sicherheitsgrenze (idea/04). E-Mail-Authentifizierung beweist ohnehin nur
    -- Postfach-Zugriff, nie die dahinterstehende Einzelperson. Prozesse mit
    -- echtem Einzelzustimmungsbedarf (z. B. Schulvertrag, wo beide
    -- Erziehungsberechtigte separat zustimmen müssen) brauchen deshalb eine
    -- eigene, explizite Zustimmungserfassung je Erziehungsberechtigtem samt
    -- Zustelladresse (Anmeldeprozess-Fachdomäne) statt sich auf die
    -- Login-Identität zu verlassen — mit festgehaltener Zustelladresse ist
    -- hinterher auswertbar, ob zwei Zustimmungen über dasselbe Postfach kamen.
    --
    -- Beim Kind bleibt die Mail beim Import leer; befüllt wird sie erst durch
    -- die spätere M365-Kontenverwaltung (Schulpostfach, fachdomaenen.md
    -- Abschnitt 6). Die private Adresse, an die das Fotoeinverständnis ab
    -- 14 Jahren den Signaturlink schickt, gehört NICHT hierher, sondern als
    -- Zustelladresse an die Zustimmungszeile selbst (Anmeldeprozess-
    -- Fachdomäne): sie belegt, wohin dieser eine Vorgang ging, und wird von der
    -- späteren Schulmail überschrieben statt ergänzt. Ein Login-Ziel wird das
    -- Kind so oder so nicht — die OTP-Eintrittsbedingung verlangt zusätzlich
    -- mindestens eine family_guardians-Zeile (idea/04).
    email             citext,
    created_at        timestamptz NOT NULL DEFAULT now(),
    created_by        text NOT NULL,
    updated_at        timestamptz NOT NULL DEFAULT now(),
    updated_by        text NOT NULL,
    -- Struktur-CHECK statt bloßem Leerstring-Verbot: genau ein @, kein
    -- Leerzeichen, ein Punkt in der Domain. Bewusst KEINE RFC-5322-Volltextregex
    -- — die ist berüchtigt unlesbar und weist gültige Adressen ab; die
    -- eigentliche Prüfung ist ohnehin, ob der OTP-Code ankommt (idea/04). Der
    -- CHECK fängt die realen Import-Artefakte: Leerstring, "unbekannt", "kein",
    -- ein versehentlich mitkopierter Anzeigename. Leerstring statt NULL ist
    -- dabei der häufigste (CSV/Excel) und ohne das UNIQUE von früher der
    -- gefährlichste: mehrere Personen mit Leerstring-Mail liefen sonst
    -- widerspruchsfrei ein und stünden in derselben Trefferliste wie eine echte
    -- Adresse.
    CHECK (email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')
);
CREATE INDEX ON persons (address_id);
-- Der OTP-Login (idea/04) schlägt über die E-Mail nach. Ohne UNIQUE legt kein
-- Constraint diesen Index mehr an, er muss deshalb explizit stehen.
CREATE INDEX ON persons (email);
-- Ein normaler B-Tree kann unter einer echten (nicht-C-)Collation kein
-- `LIKE 'Müll%'` beschleunigen, nur Gleichheit — für die Namenssuche der
-- Verwaltungsoberfläche (Präfix, case-insensitiv) nötig: text_pattern_ops auf
-- lower(last_name), deckt dabei auch die case-insensitive Gleichheitssuche
-- (Dublettenprüfung Nachname+Geburtsdatum, domains/stammdaten.md) mit ab.
CREATE INDEX ON persons (lower(last_name) text_pattern_ops);

-- Organisation als Erziehungsberechtigte (Jugendamt, Pflegedienst, Vereinsvormund
-- — real vorkommend, domains/stammdaten.md). Eigene Anschrift und Telefonnummer,
-- weil die Schule sie anschreiben und anrufen können muss. Der fallbezogene
-- Sachbearbeiter steht nicht hier, sondern an family_guardians: das Jugendamt
-- vergibt ihn pro Fall, nicht pro Behörde.
CREATE TABLE organizations (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text NOT NULL CHECK (name <> ''),  -- CHECK begründet an persons.last_name
    address_id uuid REFERENCES addresses(id) ON DELETE RESTRICT,
    -- Rein ausgehender Kanal: die Schule schreibt die Behörde an. Anders als
    -- persons.email bewusst NICHT UNIQUE, weil kein Login daran hängt — die
    -- OTP-Prüfung liest ausschließlich persons.email (idea/04). Ohne
    -- Login-Funktion kauft Eindeutigkeit hier nichts und würde den realen Fall
    -- blockieren, dass mehrere Außenstellen derselben Behörde eine gemeinsame
    -- Poststelle-Adresse nutzen.
    -- Leerstring-Import-Artefakt und Formatprüfung: CHECK unten, identisch zu
    -- persons.email und dort begründet.
    email      citext,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by text NOT NULL,
    CHECK (email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')
);
CREATE INDEX ON organizations (address_id);

-- Telefonnummern als Zeilen statt als feste Spalten (Festnetz/Arbeit/Mobil):
-- eine weitere Art ist damit eine Datenzeile, keine Migration. is_primary
-- kennzeichnet die von der Person benannte Hauptnummer — für O365-Kontakte und
-- den telefonischen Erstkontakt braucht es eine eindeutige Auswahl statt
-- Zufall. Muster von SVWS-NRW (SchuelerTelefone + K_TelefonArt) und ASV-BW
-- (svp_kommunikation); Gibbon nimmt stattdessen vier feste Slots phone1..phone4
-- und kann deshalb keine fünfte Nummer.
--
-- Gehört entweder zu einer Person ODER zu einer Organisation — dieselbe
-- Entweder-oder-Modellierung wie bei guardians unten, damit die Nummer einer
-- Behörde nicht in einer zweiten Tabelle landet.
CREATE TABLE phone_numbers (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id       uuid REFERENCES persons(id) ON DELETE CASCADE,
    organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
    phone_type_id   integer NOT NULL REFERENCES phone_types(id) ON DELETE RESTRICT,
    -- Speicherform ist E.164 (+4971231234567): das ist, was Vis365/M365 beim
    -- Kontaktabgleich übernimmt, und es beendet das Nebeneinander von "0170 2"
    -- und "+49 170 2" für dieselbe Nummer. Bewusst OHNE CHECK: das Sekretariat
    -- tippt lokal, die Umwandlung gehört in die Eingabemaske bzw. den Import —
    -- ein Constraint würde hier den Import blockieren, statt Datenqualität zu
    -- erzeugen. Nachrüstbar, sobald die Maske normalisiert. Der CHECK <> ''
    -- verhindert derweil nur die leere Nummernzeile (begründet an
    -- persons.last_name) — er prüft kein Format.
    number          text NOT NULL CHECK (number <> ''),
    is_primary      boolean NOT NULL DEFAULT false,
    note            text,               -- z. B. "nur vormittags"
    created_at      timestamptz NOT NULL DEFAULT now(),
    created_by      text NOT NULL,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text NOT NULL,
    CHECK ((person_id IS NULL) <> (organization_id IS NULL)),
    -- Dieselbe Nummer steht real zweimal an derselben Person, einmal als
    -- "Mobil" und einmal als "Arbeit" — der Typ ist aber eine Eigenschaft der
    -- Nummer, nicht ihre Identität. Zwei Zeilen dafür wären ein zweiter Ort für
    -- denselben Sachverhalt (rules.md Abschnitt 1), und is_primary säße dann
    -- womöglich auf der falschen. Deckt nebenbei den doppelten Importlauf ab.
    -- Ohne WHERE-Klausel ausreichend: Postgres wertet NULLs in einem UNIQUE als
    -- verschieden, die jeweils leere Hälfte der Entweder-oder-Modellierung
    -- kollidiert also nicht mit sich selbst.
    -- Diese beiden Indizes tragen zugleich den Zugriff über person_id bzw.
    -- organization_id allein (B-Tree-Präfix) — ein zusätzlicher einspaltiger
    -- Index daneben wäre redundant.
    UNIQUE (person_id, number),
    UNIQUE (organization_id, number)
);
-- Höchstens eine Hauptnummer je Person bzw. je Organisation.
CREATE UNIQUE INDEX ON phone_numbers (person_id)       WHERE is_primary AND person_id IS NOT NULL;
CREATE UNIQUE INDEX ON phone_numbers (organization_id) WHERE is_primary AND organization_id IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Familie, Kind, Erziehungsberechtigte
-- ---------------------------------------------------------------------------

-- Familie: Sorgerecht-Konstellation, nicht Haushalt (domains/stammdaten.md).
-- Manuell durch die Verwaltung gepflegt, kein abgeleitetes Feld. Bewusst ohne
-- Bezeichnungsfeld: ein „Familie Müller" veraltet beim ersten Namenswechsel und
-- ist ohnehin aus den Mitgliedern ableitbar. Gibbon führt dieselbe Struktur
-- (gibbonFamily + gibbonFamilyAdult + gibbonFamilyChild), hängt dort aber
-- zusätzlich die Wohnanschrift an die Familie — bei uns falsch, weil Familie
-- hier die Sorgerechtslage abbildet und nicht den gemeinsamen Haushalt.
-- updated_at/updated_by können hier strukturell nie von created_* abweichen: die
-- Tabelle hat außer der id keine Nutzlast-Spalte, ein UPDATE ändert also nie etwas.
-- Trotzdem bewusst beibehalten — sie wegzulassen hieße, families vom gemeinsamen
-- set_row_audit-Trigger auszunehmen und eine zweite Trigger-Variante zu pflegen.
-- Vier tote Spalten sind billiger als ein Sonderfall im einzigen Audit-Pfad.
CREATE TABLE families (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by text NOT NULL
);

-- Kind: IST eine Person (immer natürliche Person) — deshalb teilt sich children.id
-- direkt mit persons.id, keine eigene person_id-Spalte. Hier stehen die Felder,
-- die es nur beim Kind gibt: Demografie (aus Voranmeldeformular und ASV-BW-Export,
-- Zweck ist die Übernahme nach ASV-BW) und Schulbezug. Erziehungsberechtigte
-- bekommen diese Felder bewusst nicht (Datensparsamkeit, rules.md Abschnitt 7).
--
-- provisional_grade_level_id UND class_id schließen sich gegenseitig aus (CHECK
-- unten) — keine gekoppelte Kopie, keine Redundanz, die auseinanderlaufen
-- könnte. Ist eine Klasse zugeteilt, kommt die aktuelle Klassenstufe
-- ausschließlich per Join aus classes.grade_level_id; provisional_grade_level_id
-- trägt nur den Zustand „Klassenstufe bekannt, Klasse (a/b) noch nicht
-- zugeteilt" — z. B. vor der Klassenzuteilung im Jahreslauf oder bevor die
-- Klassenzeilen eines neuen Jahrgangs überhaupt existieren. Ein Ferienprogramm-
-- Kind (fachdomaenen.md Abschnitt 1, auch für schulfremde Kinder offen) hat
-- weder das eine noch das andere gesetzt. Absichtlich NICHT „grade_level_id"
-- genannt: der Name macht sichtbar, dass ein direkter Lesezugriff bei
-- zugeteilter Klasse NULL liefert, statt still einen falschen/veralteten Wert
-- vorzutäuschen. Der Jahreslauf einer fortbestehenden Kohorte schreibt dadurch
-- nur classes.grade_level_id fort (wenige Zeilen) — kein Kind wird dafür
-- angefasst.
CREATE TABLE children (
    id                 uuid PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    family_id          uuid REFERENCES families(id) ON DELETE RESTRICT,  -- nullable: Familie wird ggf. erst nach dem Import zugeordnet
    nickname           text,               -- Rufname, falls abweichend vom Vornamen — Schulalltag (Lehrer), nicht amtlicher Schriftverkehr; ASV-BW bleibt für die amtliche Rufname/Vorname-Unterscheidung führend
    date_of_birth      date NOT NULL,
    -- Freitext, anders als das direkt benachbarte birth_country_id: ein
    -- Geburtsort ist keine wiederholte Auswahl aus einem gepflegten Satz (jede
    -- Klinikstadt der Welt kommt in Frage) und niemand gruppiert danach
    -- (rules.md Abschnitt 3). ASV-BW hält es genauso und trennt an derselben
    -- Stelle: svp_schueler_stamm.geburtsort ist dort Freitext ("Geburtsort laut
    -- Geburtsurkunde"), das direkt daneben stehende wl_geburtsland_id dagegen
    -- Werteliste und Statistikpflichtfeld.
    birthplace         text,
    birth_country_id      integer REFERENCES countries(id) ON DELETE RESTRICT,
    nationality_id        integer REFERENCES countries(id) ON DELETE RESTRICT,
    second_nationality_id integer REFERENCES countries(id) ON DELETE RESTRICT,  -- doppelte Staatsangehörigkeit
    home_language_id   integer REFERENCES languages(id) ON DELETE RESTRICT,  -- ein Feld für Verkehrs-/Muttersprache, siehe domains/stammdaten.md
    -- Konfession/Kirchengemeinde: Art.-9-DSGVO-Daten (besondere Kategorie,
    -- Religionszugehörigkeit, Voranmeldeformular). Rollenspezifisch auf
    -- children UND guardians statt an der gemeinsamen Basistabelle persons —
    -- dieselbe Feld-pro-Rolle-Regel wie occupation bei guardians: contacts/
    -- payers können die Spalte damit strukturell gar nicht erst befüllen, nicht
    -- nur per Konvention. Schutz zusätzlich per Spalten-GRANT auf genau diese
    -- zwei Spalten je Tabelle statt über eine eigene Tabellengrenze
    -- (wb-backend/db/init-roles.sh; Owner von children/guardians darf dabei
    -- nicht backend_runtime sein, sonst greift das Spalten-GRANT nicht).
    denomination_id    integer REFERENCES denominations(id) ON DELETE RESTRICT,
    congregation       text,               -- Kirchengemeinde, Freitext
    provisional_grade_level_id integer REFERENCES grade_levels(id) ON DELETE RESTRICT,  -- NUR gültig, solange class_id NULL ist (CHECK unten) — danach gilt classes.grade_level_id
    class_id           integer REFERENCES classes(id) ON DELETE RESTRICT,  -- Klasse; NULL solange nicht zugeteilt oder nicht eingeschult
    -- Eintritt in die SCHULE, nicht in den Zweig — Grundlage der
    -- Quereinsteiger-Proration (domains/putzdienst.md). Bleibt beim internen
    -- Wechsel Grundschule → Realschule unverändert, ebenso wie exit_date dabei
    -- leer bleibt: ein Abgangsdatum startete dort die Löschfrist
    -- (idea/06-dsgvo-organisatorisch.md) für ein Kind, das weiter an der Schule
    -- ist, und nähme seiner Familie die Putzdienst-Pflicht. Der Wechsel ist genau
    -- ein UPDATE auf class_id. „Seit wann im Zweig" braucht keine eigene Spalte,
    -- das ist classes.entry_year der neuen Kohorte.
    -- Anmeldedatum: der Tag, an dem die Anmeldung einging. Zusammen mit
    -- entry_date und exit_date das Trio, das den Verlauf des Kindes an der
    -- Schule beschreibt. Bewusst hier und nicht nur an der Bewerbung
    -- (Anmeldeprozess-Fachdomäne): die Bewerbung hat eine kürzere Löschfrist,
    -- nach deren Ablauf das Datum sonst verloren wäre.
    registration_date  date,
    entry_date         date,
    -- Abgangsdatum: Löschfrist-Anker (idea/06-dsgvo-organisatorisch.md). class_id
    -- bleibt beim Abgang stehen und wird NICHT geleert — die Kohorten-Kennung ist
    -- der Ablageort der digitalen Schülerakte (Tabellenkommentar an classes), und
    -- es gibt keine zweite Stelle, die festhält, in welcher Kohorte das Kind war.
    -- Gilt gleichermaßen für den regulären Abgang nach der Abschlussklasse und
    -- den Schulwechsel mitten im Jahr: bewusst kein Abgangsgrund daneben, kein
    -- benannter Prozess unterscheidet die beiden (domains/stammdaten.md,
    -- „Geprüft, bewusst nicht übernommen").
    exit_date          date,
    previous_school_id integer REFERENCES previous_schools(id) ON DELETE RESTRICT,  -- abgebende Schule; steht auf dem Grundschul- wie dem Realschul-Voranmeldeformular
    previous_school_consent_at timestamptz,  -- Einwilligung zur Auskunftseinholung dort; NULL = keine Einwilligung. Zeitpunkt statt Boolean wegen Nachweispflicht (Art. 7 Abs. 1 DSGVO)
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,
    updated_at         timestamptz NOT NULL DEFAULT now(),
    updated_by         text NOT NULL,
    CHECK (second_nationality_id IS NULL OR nationality_id IS NOT NULL),
    -- Zweimal derselbe Staat ist keine doppelte Staatsangehörigkeit, sondern das
    -- Ergebnis einer doppelt gemappten Importspalte. Der NULL-Zweig muss explizit
    -- stehen: IS DISTINCT FROM allein wäre falsch, denn zwei NULL gelten dabei
    -- als nicht verschieden und der CHECK wiese jedes Kind ohne
    -- Staatsangehörigkeit ab.
    CHECK (second_nationality_id IS NULL OR second_nationality_id <> nationality_id),
    CHECK (exit_date IS NULL OR entry_date IS NULL OR exit_date >= entry_date),
    -- Angemeldet wird vor dem Eintritt, nie danach. Fängt vertauschte Spalten
    -- beim Import — die beiden Daten liegen dort nebeneinander.
    CHECK (entry_date IS NULL OR registration_date IS NULL OR entry_date >= registration_date),
    CHECK (previous_school_consent_at IS NULL OR previous_school_id IS NOT NULL),
    CHECK (class_id IS NULL OR provisional_grade_level_id IS NULL)
);
CREATE INDEX ON children (family_id);
CREATE INDEX ON children (class_id);
CREATE INDEX ON children (provisional_grade_level_id);
-- Bewusst KEIN Index auf date_of_birth: die einzige Abfrage, die das Feld filtert,
-- ist die Dublettenprüfung (Nachname + Geburtsdatum, domains/stammdaten.md) — die
-- startet über den Namen, und der Planer wählt bei dieser Datenmenge ohnehin einen
-- Hash-Join über beide Seiten statt eines Index-Zugriffs (gegen Postgres 16 mit
-- 500 Kindern nachgestellt). Kein Fremdschlüssel hängt daran.

-- Erziehungsberechtigte: entweder eine natürliche Person ODER eine Organisation —
-- genau eine der beiden Referenzen ist gesetzt (CHECK unten). Die strukturelle
-- Unterscheidung trägt damit der Fremdschlüssel selbst; ein zusätzliches
-- is_organization-Flag wäre ein zweiter Ort für dieselbe Tatsache und könnte
-- widersprüchlich gepflegt werden. Die frei benennbare Klassifizierung
-- („Elternteil"/„Jugendamt") steht an der Familienzugehörigkeit unten.
--
-- person_id/organization_id sind nach dem Anlegen unveränderlich (Spaltenrecht,
-- siehe Kopfkommentar) — eine Person wird nie zur Organisation, und die Zeile
-- lässt sich nicht auf einen anderen Menschen umbiegen.
--
-- Name, Anschrift, Telefon und E-Mail stehen nicht hier, sondern an persons bzw.
-- organizations — SVWS-NRW legt sie stattdessen als Anrede1/Name1/Vorname1 +
-- Anrede2/Name2/Vorname2 in EINE Zeile am Schüler (SchuelerErzAdr) und kann damit
-- weder Patchwork noch einen dritten Sorgeberechtigten abbilden.
CREATE TABLE guardians (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id       uuid UNIQUE REFERENCES persons(id) ON DELETE RESTRICT,
    organization_id uuid UNIQUE REFERENCES organizations(id) ON DELETE RESTRICT,
    -- Beruf (Voranmeldeformular), nur bei natürlicher Person. Freitext: kein
    -- Prozess wertet nach Beruf aus, eine gepflegte Berufsliste wäre
    -- Pflegeaufwand ohne Nutzen (rules.md Abschnitt 3).
    occupation      text,
    -- Bewusst KEIN is_employee-Flag: die Mitarbeiter-Eigenschaft steht an
    -- employees (unten) und ist von dort ableitbar — ein Flag daneben wäre ein
    -- zweiter Ort für dieselbe Tatsache (rules.md Abschnitt 1) und träfe zudem
    -- die falsche Aussage: die Putzdienst-Befreiung (domains/putzdienst.md)
    -- hängt daran, ob jemand AKTUELL beschäftigt ist, nicht ob er es einmal war.
    -- Konfession/Kirchengemeinde: Art.-9-DSGVO-Daten, Voranmeldeformular, nur
    -- bei natürlicher Person — Begründung und GRANT-Hinweis an children.denomination_id.
    denomination_id integer REFERENCES denominations(id) ON DELETE RESTRICT,
    congregation    text,               -- Kirchengemeinde, Freitext
    created_at      timestamptz NOT NULL DEFAULT now(),
    created_by      text NOT NULL,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text NOT NULL,
    CHECK ((person_id IS NULL) <> (organization_id IS NULL)),
    CHECK (person_id IS NOT NULL OR (occupation IS NULL AND denomination_id IS NULL AND congregation IS NULL))
);

-- ---------------------------------------------------------------------------
-- Mitarbeiter
-- ---------------------------------------------------------------------------

-- Mitarbeiter: IST eine Person (immer natürlich) — deshalb teilt sich
-- employees.id direkt mit persons.id, wie bei children und contacts.
--
-- Steht schon jetzt und nicht erst mit der M365-Kontenverwaltung, obwohl die
-- Domäne noch nicht gebaut ist (fachdomaenen.md Abschnitt 6). Drei Gründe:
--   * Die Putzdienst-Befreiung (domains/putzdienst.md) hängt an „ist aktuell
--     Mitarbeiter" — ein statisches Flag an guardians träfe die Aussage nicht
--     und müsste später auf Live-Daten migriert werden.
--   * Die Gesundheitsdaten-Fachdomäne gibt nur Sekretariat, Klassenlehrer:in
--     und Hort Zugriff (domains/grenzkarte.md). „Klassenlehrer:in dieses
--     Kindes" ist ohne diese Tabelle und classes.class_teacher_id unten nicht
--     ausdrückbar.
--   * Der Vollimport kommt komplett auf einmal (fachdomaenen.md Abschnitt 6) —
--     was danach fehlt, wird zur Migration auf echten Daten.
--
-- Bewusst NOCH NICHT enthalten: Bereichs-/Vorgesetztenstruktur. Die braucht
-- erst die Rechnungsfreigabe (fachdomaenen.md Abschnitt 6, niedrige Priorität),
-- und wie tief sie geschnitten ist, ist unbekannt — sie zu raten wäre teurer
-- als sie später zu ergänzen (rules.md Abschnitt 1).
CREATE TABLE employees (
    id               uuid PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    -- Dienstadresse, getrennt von persons.email. Letztere ist die private
    -- Adresse und zugleich die OTP-Identität (idea/04) — ein Mitarbeiter, der
    -- zugleich Elternteil ist, verlöre sonst beim Offboarding seinen
    -- Elternzugang, obwohl er Elternteil bleibt. Anders als persons.email hier
    -- UNIQUE: die Schule vergibt diese Postfächer selbst, geteilte gibt es
    -- nicht. Struktur-CHECK identisch zu persons.email und dort begründet.
    work_email       citext UNIQUE,
    -- Entra-ID Object-ID. Verbindet den Audit-Verursacher „entra:<oid>"
    -- (Kopfkommentar) mit einer Person und trägt die Zugriffsentscheidung der
    -- API: welche:r angemeldete Mitarbeiter:in ist Klassenlehrer:in welcher
    -- Klasse. Ohne sie ist beides nur über einen Graph-Abruf je Anfrage lösbar.
    entra_object_id  text UNIQUE CHECK (entra_object_id <> ''),
    employment_start date,
    -- Gesetzt heißt: ausgeschieden. Trägt die Putzdienst-Befreiung („aktuell
    -- beschäftigt" = employment_end IS NULL) und den Offboarding-Lauf der
    -- M365-Kontenverwaltung. Die Zeile bleibt danach stehen, weil der
    -- Audit-Trail auf sie zeigt.
    employment_end   date,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,
    updated_at       timestamptz NOT NULL DEFAULT now(),
    updated_by       text NOT NULL,
    CHECK (work_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
    CHECK (employment_end IS NULL OR employment_start IS NULL OR employment_end >= employment_start)
);

-- Klassenlehrer:in. Der Fremdschlüssel steht hier statt an der Tabelle, weil
-- classes weiter oben definiert wird (Schulstruktur-Block) und employees erst
-- persons voraussetzt — die einzige Stelle im Schema mit dieser Reihenfolge.
-- Nullable: eine neue Kohorte existiert vor ihrer Lehrkraft, festgelegt wird
-- sie erst bei der Klassenbildung (fachdomaenen.md Abschnitt 6).
ALTER TABLE classes ADD FOREIGN KEY (class_teacher_id) REFERENCES employees(id) ON DELETE RESTRICT;
CREATE INDEX ON classes (class_teacher_id);

-- Erziehungsberechtigte↔Familie: M:N (Patchwork-Fall, domains/stammdaten.md).
-- Nur sorgerechtgebende Mitgliedschaft — reines Umgangsrecht wird hier nie
-- eingetragen. Diese Tabelle ist zugleich die Grundlage des OTP-Ownership-Checks
-- und die vorgesehene Stelle für eine spätere Sichtbarkeits-Einschränkung
-- zwischen Sorgeberechtigten (domains/stammdaten.md, „Offene Punkte") — Gibbon
-- führt dort genau dafür ein Flag (gibbonFamilyAdult.childDataAccess). Wir bauen
-- es erst, wenn ein Fall vorliegt; die Struktur muss dafür nicht geändert werden.
CREATE TABLE family_guardians (
    family_id            uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    guardian_id          uuid NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
    guardian_category_id integer REFERENCES guardian_categories(id) ON DELETE RESTRICT,
    -- „In Briefe miteinbeziehen" — steht auf allen vier Anmeldetag-Checklisten
    -- direkt neben „Sorgeberechtigt" und entscheidet, wer Schulpost und
    -- Prozessmails bekommt. An der Familienzugehörigkeit und nicht an der
    -- Person: dieselbe Person kann für ein Kind einbezogen sein und für ein
    -- anderes nicht. Default true — wer sorgeberechtigt ist, wird im Regelfall
    -- angeschrieben; das Abwählen ist der begründungspflichtige Fall.
    -- Betrifft auch die Putzdienst-Erinnerungen (domains/putzdienst.md).
    include_in_correspondence boolean NOT NULL DEFAULT true,
    -- nur bei Organisation: Sachbearbeiter für diesen Fall, Freitext (wechselt
    -- öfter, keine eigene Person-Zeile wert). Kein CHECK möglich (Organisations-
    -- Status steht auf guardians, nicht auf dieser Zeile) — durchgesetzt per
    -- Trigger unten (check_family_guardians_contact_person). Ein nachträglicher
    -- Wechsel des Guardians von Organisation auf Person, der die Notiz sonst
    -- verwaist zurückließe, ist per Spaltenrecht ausgeschlossen (Kopfkommentar).
    contact_person       text,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,
    updated_at           timestamptz NOT NULL DEFAULT now(),
    updated_by           text NOT NULL,
    PRIMARY KEY (family_id, guardian_id)
);
CREATE INDEX ON family_guardians (guardian_id);

-- ---------------------------------------------------------------------------
-- Kontakte (nicht-rechtliche Bezugspersonen)
-- ---------------------------------------------------------------------------

-- Notfallkontakt/Abholberechtigt ohne Rechtsstellung — nie Datenzugriff, kein
-- Ownership-Check nötig, kein Login (domains/stammdaten.md). Rolle auf persons
-- wie children und guardians: dieselbe Großmutter, die für ein Enkelkind
-- Pflegeelternteil und für ein anderes nur Notfallkontakt ist, steht damit
-- einmal in der Datenbank statt zweimal, und Name/Telefon/Anschrift folgen
-- derselben Mechanik wie überall sonst. ASV-BW hängt an svp_kontakt ebenfalls
-- eine Anschrift — dort allerdings an Institutions-Kontakte (laut
-- wl_kontakttyp_id Heim, Sponsor, Förderkreis, Lieferant), nicht an
-- Bezugspersonen; Gibbon legt Notfallkontakte dagegen als feste Spaltenpaare
-- (emergency1Name … emergency2Relationship) auf die Person des Kindes und
-- kann deshalb keinen dritten Kontakt und keine geteilte Nummer.
--
-- Preis dieser Vereinheitlichung: Anschrift und E-Mail sind für Kontakte
-- technisch befüllbar. Datensparsamkeit ist hier also nur noch eine Regel der
-- Eingabemaske, nicht mehr strukturell erzwungen — anders als bei Demografie
-- (nur children) und Beruf (nur guardians), die weiterhin an der Rollentabelle
-- hängen und für andere Rollen gar nicht existieren.
CREATE TABLE contacts (
    id         uuid PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    note       text,               -- z. B. "nur nachmittags erreichbar"; Singular wie phone_numbers.note
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by text NOT NULL
);

-- relationship steht an der Verknüpfung, nicht am Kontakt: „Großmutter" gilt
-- relativ zum Kind, nicht absolut zur Person. Verknüpfung an das Kind und nicht
-- an die Familie, weil ein Kind vor der manuellen Familienzuordnung noch keine
-- Familie hat.
--
-- priority: Reihenfolge „Notfallkontakt 1/2/3", ein realer Prozess an dieser
-- Schule — anders als die bewusst nicht übernommene Gibbon-contactPriority bei
-- Erziehungsberechtigten (domains/stammdaten.md). Nullable, weil nicht jede
-- Verknüpfung eine Reihenfolge braucht (z. B. reine Abholberechtigung ohne
-- Notfall-Rolle); wo gesetzt, höchstens einmal je Kind (UNIQUE unten) — keine
-- zwei Kontakte mit demselben Rang.
CREATE TABLE child_contacts (
    child_id     uuid NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    contact_id   uuid NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    -- Freitext, bewusst anders als guardian_categories an family_guardians —
    -- dort steht dieselbe Art Frage („wie steht diese Person zum Kind?") als
    -- Lookup. Unterschied: dort ist der Satz klein, rechtlich relevant und
    -- stabil; hier hat er einen langen Schwanz („Patentante", „Freundin der
    -- Familie"), niemand wertet Notfallkontakte nach Verwandtschaftsgrad aus,
    -- und eine Lookup zwänge das Sekretariat, beim Erfassen erst eine Kategorie
    -- anzulegen — Pflegeaufwand ohne Nutzen (rules.md Abschnitt 3).
    relationship text,
    priority     smallint,
    created_at   timestamptz NOT NULL DEFAULT now(),
    created_by   text NOT NULL,
    updated_at   timestamptz NOT NULL DEFAULT now(),
    updated_by   text NOT NULL,
    PRIMARY KEY (child_id, contact_id)
);
CREATE INDEX ON child_contacts (contact_id);
CREATE UNIQUE INDEX ON child_contacts (child_id, priority) WHERE priority IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Zahlungsverantwortliche
-- ---------------------------------------------------------------------------

-- Zahlungsverantwortlich für ein Kind ist nicht dasselbe wie sorgeberechtigt
-- (domains/stammdaten.md) — Großeltern zahlen mit oder allein, ohne
-- Erziehungsberechtigte zu sein; das Jugendamt übernimmt bei Kostenübernahmen
-- (z. B. Ferienprogramm) direkt als Organisation. Deshalb eine eigene Rolle
-- statt Wiederverwendung von guardians/contacts, mit demselben
-- Entweder-Person-oder-Organisation-Muster wie guardians (Fremdschlüssel trägt
-- die Unterscheidung, kein zusätzliches Flag).
--
-- Bewusst KEIN Anteil/Betrag je Zahler (Bezuschussung, Gutscheine) — offener
-- Punkt, noch zu klären; child_payers.is_primary hält vorerst nur fest, wer
-- der/die Hauptzahler:in ist, analog phone_numbers.is_primary.
--
-- IBAN/BIC sind sensible, aber keine Art.-9-Daten — eigene Rollentabelle statt
-- Spalten auf persons/children/guardians (anders als Konfession oben): der
-- Zugriffskontext ist ein anderer (Abrechnung statt allgemeines Personenprofil),
-- betrifft nur wenige Personen, und die meisten Abfragen auf persons brauchen
-- die Daten nie mit. Eigene, engere DB-Rolle wie bei den Konfessionsspalten
-- (wb-backend/db/init-roles.sh).
--
-- billing_address_id nullable: NULL heißt „Anschrift der zahlenden
-- Person/Organisation gilt", nur bei abweichender Rechnungsadresse gesetzt —
-- kein Pflicht-Duplikat der ohnehin vorhandenen Adresse.
CREATE TABLE payers (
    id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id          uuid UNIQUE REFERENCES persons(id) ON DELETE RESTRICT,
    organization_id    uuid UNIQUE REFERENCES organizations(id) ON DELETE RESTRICT,
    billing_address_id uuid REFERENCES addresses(id) ON DELETE RESTRICT,
    -- Struktur-CHECK nach ISO 13616 (IBAN) bzw. ISO 9362 (BIC), bewusst
    -- international und nicht auf die deutsche Länge festgelegt: IBAN ist
    -- Ländercode + zwei Prüfziffern + 11–30 Zeichen BBAN, also 15 (Norwegen) bis
    -- 34 Zeichen gesamt; BIC ist 4 Buchstaben Institut + 2 Buchstaben Land +
    -- 2 alphanumerisch Ort, optional 3 alphanumerisch Filiale, also 8 oder 11.
    -- Der Vollimport ist eine Vertrauensgrenze und hätte sonst gar keine
    -- Prüfung — eine unbrauchbare Bankverbindung fiele erst Monate später bei
    -- der ersten Lastschrift auf.
    -- Gespeichert wird ausschließlich die normalisierte Form: Großbuchstaben,
    -- keine Leerzeichen. Die auf Papier übliche Vierergruppen-Schreibweise
    -- ("DE89 3704 …") muss der Import bzw. die Eingabemaske vorher entfernen —
    -- der CHECK weist sie ab, statt zwei Schreibweisen derselben Kontoverbindung
    -- nebeneinander zuzulassen.
    -- Die Mod-97-Prüfziffer (ISO 7064) gehört in die Anwendung, nicht in einen
    -- CHECK: Rechnen im Constraint wäre schwer lesbar und bei einer künftigen
    -- Regeländerung nur per Migration korrigierbar.
    iban               text CHECK (iban ~ '^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$'),
    bic                text CHECK (bic ~ '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$'),
    account_holder     text,               -- Kontoinhaber, falls abweichend vom Namen der Person/Organisation
    -- SEPA-Lastschriftmandat. EIN Mandat je Zahler, nicht je Zweck: Schulgeld,
    -- Mensa, Putzdienst-Freikauf und Ferienprogramm ziehen alle über dasselbe
    -- Mandat ein (fachdomaenen.md Abschnitt 6) — deshalb Spalten hier und keine
    -- eigene Tabelle. Ohne beide Felder ist eine gespeicherte IBAN nicht
    -- einziehbar, sie gehören in den SEPA-Datensatz.
    --
    -- Die Referenz vergibt die Schule (das Formular fragt sie nicht ab) und sie
    -- muss je Gläubiger-ID eindeutig sein — daher UNIQUE.
    --
    -- Kreditinstitut steht bewusst NICHT daneben, obwohl das Formular es
    -- abfragt: es folgt aus der BIC und wäre ein zweiter Ort für denselben
    -- Sachverhalt (rules.md Abschnitt 1).
    --
    -- Keine Mandatshistorie: Optigem führt die Lastschrift aus
    -- (fachdomaenen.md Abschnitt 4), Weltenbaum hält nur den aktuellen Stand —
    -- wie überall sonst in diesem Schema (domains/stammdaten.md,
    -- „Schuljahreswechsel").
    --
    -- Das unterschriebene Mandat wird zusätzlich digital abgelegt (PDF samt
    -- Signatur). Dieses Artefakt gehört NICHT hierher, sondern in die
    -- Schulvertrags-/Anmeldeprozess-Fachdomäne, die dieselbe Struktur schon für
    -- Schulvertrag, Gesundheitsdatenblatt und Fotoeinverständnis braucht; es
    -- zeigt auf payers.id. Wichtig dabei: das Dokument trägt KEIN eigenes
    -- Unterschriftsdatum — das steht hier, einmal. Der Nachweis ist das
    -- Artefakt, der Datenwert für den Einzug ist diese Spalte.
    mandate_reference  text UNIQUE CHECK (mandate_reference <> ''),
    mandate_signed_at  date,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,
    updated_at         timestamptz NOT NULL DEFAULT now(),
    updated_by         text NOT NULL,
    CHECK ((person_id IS NULL) <> (organization_id IS NULL)),
    -- Referenz ohne Datum ist kein gültiges Mandat und umgekehrt — beide oder
    -- keines.
    CHECK ((mandate_reference IS NULL) = (mandate_signed_at IS NULL)),
    -- Mandat ohne Konto ist sinnlos. Umgekehrt gilt das nicht: eine IBAN darf
    -- vor der Unterschrift dastehen (Import aus Optigem, Erfassung vor
    -- Vertragsabschluss).
    CHECK (mandate_reference IS NULL OR iban IS NOT NULL)
);
CREATE INDEX ON payers (billing_address_id);

-- Kind↔Zahler: M:N (mehrere Zahler je Kind für Bezuschussungsfälle, dieselbe
-- zahlende Person/Organisation ggf. für mehrere Kinder). ON DELETE RESTRICT
-- auf child_id: ein Kind mit noch bestehender Zahlungsverantwortung wird nicht
-- nebenbei mitgelöscht, das ist eine echte Entscheidung wie bei guardians
-- (domains/stammdaten.md, „Löschmechanik") — anders als child_contacts, das
-- keine Rechtsfolge hat.
CREATE TABLE child_payers (
    child_id   uuid NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    payer_id   uuid NOT NULL REFERENCES payers(id) ON DELETE CASCADE,
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by text NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by text NOT NULL,
    PRIMARY KEY (child_id, payer_id)
);
CREATE INDEX ON child_payers (payer_id);
-- Höchstens eine/r Hauptzahler:in je Kind.
CREATE UNIQUE INDEX ON child_payers (child_id) WHERE is_primary;

-- ---------------------------------------------------------------------------
-- Audit-Spalten automatisch fortschreiben. In der Datenbank statt in der
-- Anwendung, damit kein Schreibpfad sie vergessen kann (idea/03) — sonst bleibt
-- updated_at für immer auf dem Einfüge-Zeitpunkt stehen und der Audit-Trail ist
-- wertlos.
--
-- Den Verursacher kennt nur die Anwendung. Sie setzt ihn einmal pro Transaktion
-- als Sitzungsvariable (SET LOCAL app.actor = '<oid>' / 'guardian:<uuid>' /
-- 'system:<job>'), der Trigger schreibt ihn in jede berührte Zeile. Fehlt die
-- Variable, scheitert der Schreibpfad hart (rules.md Abschnitt 3: „ein stiller
-- Fehlschlag zählt als nicht vorhanden") statt einen leeren oder veralteten
-- Verursacher stehen zu lassen. nullif(..., '') ist dabei nötig: Postgres
-- liefert für eine per SET LOCAL gesetzte Sitzungsvariable außerhalb der
-- setzenden Transaktion nicht NULL zurück, sondern einen Leerstring — ohne
-- nullif würde ein Schreibpfad, der SET LOCAL vergisst, unbemerkt mit leerem
-- Verursacher durchlaufen statt hart zu scheitern.
--
-- Bewusst KEINE separate Änderungshistorie-Tabelle: kein aktueller Prozess
-- braucht mehr als „wer hat zuletzt geändert" (rules.md Abschnitt 1). Die vier
-- Spalten bleiben der Anknüpfungspunkt, falls doch einmal eine volle Historie
-- nötig wird.
-- ---------------------------------------------------------------------------

CREATE FUNCTION set_row_audit() RETURNS trigger AS $$
DECLARE
    actor text := nullif(current_setting('app.actor', true), '');
BEGIN
    IF actor IS NULL THEN
        RAISE EXCEPTION 'app.actor nicht gesetzt — SET LOCAL app.actor vor jedem Schreibzugriff auf eine Audit-Tabelle';
    END IF;
    IF actor !~ '^(entra|guardian|system):.' THEN
        RAISE EXCEPTION 'app.actor braucht ein bekanntes Präfix (entra:/guardian:/system:), war: %', actor;
    END IF;
    IF TG_OP = 'INSERT' THEN
        NEW.created_at := now();
        NEW.created_by := actor;
    ELSE
        NEW.created_at := OLD.created_at;   -- unveränderlich
        NEW.created_by := OLD.created_by;
    END IF;
    NEW.updated_at := now();
    NEW.updated_by := actor;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON grade_levels
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON classes
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON addresses
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON persons
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON phone_numbers
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON families
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON children
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON guardians
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON employees
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON family_guardians
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON child_contacts
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON payers
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON child_payers
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();

-- ---------------------------------------------------------------------------
-- family_guardians.contact_person nur bei Organisation als Erziehungsberechtigte
-- (Tabellenkommentar oben) — kein CHECK möglich, weil der Organisations-Status
-- auf guardians steht, einer anderen Tabelle als contact_person selbst; CHECK-
-- Constraints dürfen keine andere Tabelle nachschlagen. Analog zu
-- guardians.occupation, nur eben cross-table statt in derselben Zeile.
-- ---------------------------------------------------------------------------

CREATE FUNCTION check_family_guardians_contact_person() RETURNS trigger AS $$
BEGIN
    IF NEW.contact_person IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM guardians WHERE id = NEW.guardian_id AND organization_id IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'contact_person nur zulässig, wenn guardian_id eine Organisation ist (guardian_id %)', NEW.guardian_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_family_guardians_contact_person BEFORE INSERT OR UPDATE ON family_guardians
    FOR EACH ROW EXECUTE FUNCTION check_family_guardians_contact_person();
