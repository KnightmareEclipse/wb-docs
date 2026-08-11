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
--     Die private E-Mail steht dort, das Schulpostfach an children und die
--     Dienstadresse an employees: drei Postfächer mit drei Lebensdauern, jedes
--     an der Rolle, die es vergibt und wieder einzieht (Begründung an
--     children.school_email).
--   * Kind, Erziehungsberechtigte und Zahlungsverantwortliche/r sind Rollen AUF
--     persons, keine parallelen Personentabellen mit je eigenen
--     Namens-/Telefonspalten. Die Rolle „Kontakt" hat bewusst keine eigene
--     Tabelle mehr — sie ist die Menge der in child_contacts verknüpften
--     Personen (Begründung dort).
--   * Jede Rolle ist eine natürliche Person. Es gibt bewusst KEINE Organisation
--     als eigene Partei — Begründung an guardians.
--   * Kein abgeleitetes/redundantes Feld — auch nicht Klassenstufe und Klasse am
--     Kind: children.provisional_grade_level_id und children.class_id schließen
--     sich per CHECK gegenseitig aus, es gibt also nie zwei Werte für denselben
--     Sachverhalt gleichzeitig (Begründung an der Tabelle).
--
-- Datensparsamkeit (rules.md Abschnitt 7): ein Feld existiert nur, wenn es auf
-- einem realen Formular steht ODER ein benannter Prozess es braucht. Deshalb
-- führen Erziehungsberechtigte kein Geburtsdatum und keine Demografie.
--
-- Für FREITEXT gilt das doppelt, und deshalb gibt es hier kein allgemeines
-- Kommentar- oder Notizfeld — weder an persons noch an children, guardians
-- oder families. Erfahrungswert des Betreibers: das Sekretariat füllt
-- jedes leicht befüllbare Feld mit allem Möglichen. Ein Freitextfeld ohne
-- benannten Abnehmer sammelt damit Personendaten ohne Rechtsgrundlage, ohne
-- Zweckbindung und ohne Löschregel — und ist als Einziges hinterher nicht
-- selektiv löschbar. Die drei vorhandenen Freitexte haben je einen konkreten
-- Abnehmer: phone_numbers.note die Erreichbarkeit einer Nummer,
-- child_contacts.relationship den Bezug zum Kind, family_guardians.acting_for
-- die Briefanschrift bei Amtsvormundschaft.
--
-- Nachrüsten ist ausdrücklich der vorgesehene Weg, nicht der Notnagel: eine
-- nullable Spalte anzufügen ist Katalogarbeit (gemessen: 1,9 ms auf einer
-- Tabelle mit einer Million Zeilen) und vom Freeze nicht berührt, der nur
-- bestehende Spalten schützt. Auslöser ist ein benannter Fall, in dem etwas
-- Legitimes sonst keinen Platz hat — nicht die Vermutung, dass er kommt.
--
-- Audit-Spalten: created_at/created_by/updated_at/updated_by auf jeder Tabelle
-- mit veränderlichem Inhalt (idea/03). Unter den Lookup-Tabellen haben sie
-- genau die drei, deren Inhalt eine REGEL steuert statt nur eine Bezeichnung zu
-- tragen: guardian_categories (exempt_from_parent_duties), grade_levels
-- (is_final_grade) und classes (grade_level_id, vom Jahreslauf fortgeschrieben).
-- Dort hat eine unbemerkte Fehländerung eine reale Auswirkung auf laufende
-- Zuteilungen — bei den übrigen Lookups ändert sie nur einen Anzeigetext. Was
-- an der jeweiligen Tabelle konkret schiefginge, steht dort.
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

-- Unveränderliche Spalten: der Primärschlüssel jeder Tabelle bleibt nach dem
-- Anlegen unveränderlich, durchgesetzt per Spaltenrecht der Laufzeit-Rolle
-- (wb-backend/db/init-roles.sh) — kein Trigger nötig, keine Laufzeitkosten,
-- derselbe Mechanismus wie beim Art.-9-Spaltenschutz unten. Bei den Rollen-
-- tabellen (children, guardians, payers, employees) ist das zugleich
-- der Fremdschlüssel auf persons: eine Rollenzeile lässt sich damit nicht auf
-- einen anderen Menschen umbiegen, was sämtliche Familienzugehörigkeiten und
-- damit den OTP-Ownership-Check (idea/04) stillschweigend mitverschöbe.
-- Für die Umsetzung, gegen Postgres 18 verifiziert:
--   * Die Laufzeit-Rolle darf KEIN tabellenweites GRANT UPDATE bekommen. Das
--     deckt alle Spalten ab, und ein nachträgliches REVOKE UPDATE (spalte) hebt
--     es nicht auf — der Schreibzugriff bliebe erlaubt. Stattdessen nur die
--     zugelassenen Spalten einzeln granten: GRANT UPDATE (spalte, …) ON tabelle.
--   * Die vier Audit-Spalten brauchen dabei kein GRANT — der Trigger unten setzt
--     sie unabhängig von den Spaltenrechten des Aufrufers.
--   * Wie beim Art.-9-Schutz wirkt das weder gegen den Tabelleneigentümer noch
--     gegen die Migrations-Rolle (die darf das richtigerweise), und das
--     Prüfskript kann es nicht belegen, da es als Superuser läuft.

-- Benannte Constraints: Postgres leitet einen brauchbaren Namen selbst ab,
-- solange eine Regel an genau einer Spalte hängt (persons_email_check,
-- children_family_id_fkey, children_mandate_reference_key, und ab Postgres 18 auch
-- persons_last_name_not_null). Nur bei MEHRSPALTIGEN Regeln fehlt ihm der Anker,
-- dann zählt er durch: "children_check3" sagt weder im Log noch in der
-- API-Antwort, welche Zusage gebrochen wurde. Genau diese bekommen deshalb einen
-- expliziten Namen, ebenso die partiellen Unique-Indizes (die gar keine
-- Constraints sein können — Postgres kennt kein UNIQUE mit WHERE-Klausel und
-- führt sie in pg_index statt pg_constraint).
-- Muster ist Postgres' eigenes, <tabelle>_<sachverhalt>_check, damit benannte und
-- automatische Namen nicht als zwei Dialekte nebeneinanderstehen. Einspaltige
-- Regeln bewusst NICHT explizit benannt: rund hundert CONSTRAINT-Klauseln für
-- praktisch identische Namen machen das Schema schwerer lesbar, ohne eine
-- Fehlermeldung zu verbessern.
--
-- Für die Umsetzung in wb-backend gilt die Regel strenger: dort sorgt
-- SQLAlchemys MetaData(naming_convention=...) dafür, dass JEDES Constraint einen
-- deterministischen Namen bekommt — nur so kann eine Alembic-Migration es später
-- sicher per ALTER greifen (TODO-SESSIONS.md).

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
-- Warum überhaupt ein code neben dem label — gilt für alle drei gleichermaßen:
-- Abnehmer ist der CSV-Export nach ASV-BW (fachdomaenen.md). Setzte er auf dem
-- frei umbenennbaren label auf, bräche er still, sobald jemand eine Zeile
-- umbenennt. Der label trägt dafür die menschliche Sichtprüfung dazwischen
-- ("Türkei" ist prüfbar, "TUR" kaum), der code die maschinelle Seite; beide
-- Spalten werden gebraucht, weil der Weg nach ASV-BW beide anspricht.
-- code ist zudem nach dem Anlegen unveränderlich — nicht per Trigger, sondern
-- schlicht dadurch, dass er nicht ins Spalten-GRANT der Laufzeit-Rolle kommt
-- (Kopfkommentar oben): ein geänderter code würde still die Bedeutung jeder
-- referenzierenden Zeile verschieben, statt nur eine Bezeichnung zu ändern.
-- ---------------------------------------------------------------------------

-- Geschlecht ist das amtliche Merkmal für ASV-BW und Statistik, deshalb wie
-- countries/languages mit stabilem code neben dem frei umbenennbaren label
-- (Begründung im Blockkopf).
--
-- ISO 5218 geprüft und bewusst NICHT übernommen: die Norm kennt nur 0/1/2/9
-- (unbekannt/männlich/weiblich/nicht anwendbar) und kann "divers" gar nicht
-- ausdrücken — das seit 2018 nach §22 Abs. 3 PStG erforderliche dritte
-- Geschlecht wäre damit nicht abbildbar, die Norm anzuwenden also schlechter als
-- kein Code. Die Werte kommen stattdessen aus der ASV-BW-Werteliste
-- (svp_wl_wert.schluessel); der CHECK sichert nur die Form — kurz, ohne
-- Leerzeichen, damit dort nicht die Bezeichnung selbst landet.
CREATE TABLE genders (
    gender_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label     text NOT NULL UNIQUE,  -- z. B. "männlich", "weiblich", "divers", "keine Angabe"
    code      text NOT NULL UNIQUE CHECK (code ~ '^[A-Za-z0-9]{1,8}$')
);

-- Anrede für Anschreiben ("Herr", "Frau", "keine Anrede"). Bewusst getrennt vom
-- Geschlecht und NICHT daraus abgeleitet: Geschlecht ist das amtliche Merkmal für
-- ASV-BW/Statistik, die Anrede die Ansprache im Schreiben — bei "divers", bei
-- "keine Anrede" (Anrede steckt schon im Namen, z. B. "Freiherr von") und bei
-- persönlicher Präferenz gibt es keine Ableitung. ASV-BW und SVWS-NRW führen
-- beide Felder ebenfalls nebeneinander. Fehlt heute im ASV-Export nach Vis365
-- und damit in M365 — Rundschreiben sind deshalb dort nicht sauber anredbar.
CREATE TABLE salutations (
    salutation_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label         text NOT NULL UNIQUE
);

-- Klassifizierung einer Erziehungsberechtigten-Beziehung ("Mutter", "Vater",
-- "Pflegeeltern", "Jugendamt", "Vereinsvormund"). Hängt an family_guardians,
-- nicht am Erziehungsberechtigten: dieselbe Person kann in einer Familie
-- leiblicher Elternteil und in einer anderen Amtsvormund sein.
-- Entspricht K_ErzieherArt in SVWS-NRW.
--
-- exempt_from_parent_duties ist die Ausnahme aus rules.md Abschnitt 3: keine
-- Bezeichnung, sondern eine strukturelle Tatsache — diese Art der
-- Erziehungsberechtigung begründet keine Elternmitarbeit. Sie trägt damit die
-- Putzdienst-Befreiung der Amts- und Vereinsvormundschaft
-- (domains/putzdienst.md): eine Sachbearbeiterin des Jugendamts ist eine ganz
-- normale natürliche Person (Begründung an guardians) und wäre sonst
-- putzdienstpflichtig. Deshalb ein nicht umbenennbares Flag neben dem frei
-- benennbaren label — die Befreiung darf nicht daran hängen, dass niemand
-- "Jugendamt" umbenennt.
--
-- Die Aussage gilt je Familienzugehörigkeit und nicht je Person, und das ist
-- genau richtig: dieselbe Frau ist für ein Mündel "Jugendamt" und befreit, für
-- ihr eigenes Kind "Mutter" und pflichtig. Fehlt die Kategorie, gilt pflichtig —
-- der sichere Ausgang. Pflegeeltern sind ausdrücklich pflichtig.
--
-- Mit Audit-Spalten (Kopfkommentar): eine unbemerkte Fehländerung an
-- exempt_from_parent_duties befreit still ganze Familien von der
-- Mitarbeitspflicht.
CREATE TABLE guardian_categories (
    guardian_category_id      integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label                     text NOT NULL UNIQUE,
    exempt_from_parent_duties boolean NOT NULL DEFAULT false,
    created_at                timestamptz NOT NULL DEFAULT now(),
    created_by                text NOT NULL,
    updated_at                timestamptz NOT NULL DEFAULT now(),
    updated_by                text NOT NULL
);

CREATE TABLE denominations (
    denomination_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label           text NOT NULL UNIQUE   -- z. B. "römisch-katholisch", "evangelisch", "konfessionslos"
);

-- Verkehrssprache des Kindes. Lookup statt Freitext (rules.md Abschnitt 3):
-- wiederholte Auswahl aus einem stabilen Satz — getippt würde daraus
-- "de"/"De"/"deutsch"/"German". code/label im Blockkopf begründet, hier ist der
-- code der BCP-47-Wert.
-- code-CHECK: BCP-47-Grundform, kleingeschriebenes Primär-Subtag (2–3 Buchstaben,
-- deckt ISO 639-1/-2/-3 ab) plus beliebig viele Subtags — erlaubt "de", "tr",
-- "de-DE", "zh-Hant", "es-419". Bewusst auf die kanonische Kleinschreibung des
-- Primär-Subtags festgelegt, dieselbe Normalisierungslogik wie bei der IBAN:
-- "DE" und "de" wären sonst zwei Zeilen für dieselbe Sprache, und genau das
-- soll die Spalte verhindern ("deutsch"/"German" fallen ohnehin durch).
CREATE TABLE languages (
    language_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label       text NOT NULL UNIQUE,  -- z. B. "Deutsch", "Türkisch"
    code        text NOT NULL UNIQUE CHECK (code ~ '^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$')  -- BCP 47, z. B. "de", "tr"
);

-- Land (Anschrift, Geburtsland, Staatsangehörigkeit). Lookup statt ISO-Code als
-- Freitext (rules.md Abschnitt 3), aus demselben Grund wie languages; code/label
-- im Blockkopf begründet. Ohne Lookup läge die Länderliste hartkodiert in der
-- Eingabemaske: dieselbe Konstante, nur eine Schicht weiter außen. Ein bloßer
-- Regex wäre kein Ersatz — "XX" und vor allem das häufige "UK" (ISO wäre "GB")
-- kämen ungehindert durch. ASV-BW führt Staatsangehörigkeit, Geburtsland und
-- Staat der Anschrift ebenfalls als Werteliste (svp_*.wl_staatsangehoerigkeit_id
-- / wl_geburtsland_id / wl_staat_id → SVP_WL_WERT), nicht als ISO-Code.
--
-- Bewusst alpha-3 statt des verbreiteteren alpha-2, aus zwei Gründen: alpha-2 ist
-- die einzige der drei Varianten mit realer Neuvergabe-Historie (CS war
-- Tschechoslowakei, später Serbien und Montenegro), und alpha-2 kollidiert
-- optisch mit languages.code direkt daneben — "DE"/"de" sind Land und Sprache
-- und in einem Export nicht auseinanderzuhalten, "DEU"/"de" schon. Numeric-3
-- (276) wird zwar nie neu vergeben, ist aber für einen Menschen im Sekretariat
-- nicht lesbar.
CREATE TABLE countries (
    country_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label      text NOT NULL UNIQUE,                           -- z. B. "Deutschland", "Türkei"
    code       text NOT NULL UNIQUE CHECK (code ~ '^[A-Z]{3}$')  -- ISO 3166-1 alpha-3, z. B. "DEU", "TUR"
);

-- Art einer Telefonnummer ("Festnetz", "Mobil", "Arbeit"). Lookup statt fester
-- Spalten, damit eine vierte Art eine Datenzeile ist und keine Migration —
-- Muster von SVWS-NRW (K_TelefonArt) und ASV-BW (Kommunikationstyp).
CREATE TABLE phone_types (
    phone_type_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label         text NOT NULL UNIQUE
);

-- Schulzweig — heute Grundschule und Realschule (fachdomaenen.md Abschnitt 1).
CREATE TABLE school_branches (
    school_branch_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label            text NOT NULL UNIQUE
);

-- Klassenstufen als Daten statt als Zahlenbereich: label ist frei ("1", "10",
-- "VKL", "J1"), sort_order ordnet innerhalb des Zweigs. is_final_grade markiert
-- die jeweils letzte Klasse eines Zweigs und trägt damit die Abschlussklassen-
-- Regel des Putzdiensts (domains/putzdienst.md, „Abgänge & Klassenstufen-
-- Übergänge") als Datum statt als Konstante im Code — Regeländerung ist ein
-- UPDATE, keine Migration und kein Codetouch
-- (rules.md Abschnitt 3). Mit Audit-Spalten (Kopfkommentar): is_final_grade
-- steuert die Putzdienst-Abgangslogik direkt.
CREATE TABLE grade_levels (
    grade_level_id   integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    school_branch_id integer NOT NULL REFERENCES school_branches(school_branch_id) ON DELETE RESTRICT,
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
    UNIQUE (grade_level_id, school_branch_id)
);
-- Höchstens eine Abschlussklasse je Zweig — Bauform und Abwägung an
-- phone_numbers_one_primary_per_person. Ohne diesen Index ließen sich zwei
-- Klassenstufen desselben Zweigs als "letzte" markieren, und die Putzdienst-
-- Abgangsregel (domains/putzdienst.md) sperrte den September-Termin still für
-- Familien, die noch ein Jahr bleiben — sichtbar wird das nirgends, denn
-- is_final_grade steht in keiner Anzeige.
CREATE UNIQUE INDEX grade_levels_one_final_per_branch ON grade_levels (school_branch_id) WHERE is_final_grade;

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
    class_id         integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    school_branch_id integer NOT NULL REFERENCES school_branches(school_branch_id) ON DELETE RESTRICT,
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
    -- der Jahreslauf und nicht das Schema — gleiche Abwägung wie an
    -- phone_numbers_one_primary_per_person.
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
    -- Audit-Spalten (Kopfkommentar): grade_level_id wird vom Jahreslauf
    -- jährlich fortgeschrieben — ohne created_by/updated_by wäre ein
    -- fehlerhafter Lauf nicht auf Verursacher und Zeitpunkt zurückzuführen.
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,
    updated_at       timestamptz NOT NULL DEFAULT now(),
    updated_by       text NOT NULL,
    UNIQUE (school_branch_id, entry_year, stream),
    FOREIGN KEY (grade_level_id, school_branch_id) REFERENCES grade_levels(grade_level_id, school_branch_id),
    CHECK (entry_year BETWEEN 2000 AND 2100)
);

-- Abgebende Schule (steht auf beiden Voranmeldeformularen, siehe
-- children.previous_school_id).
-- Lookup statt Freitext, weil dieselbe Grundschule sonst in drei Schreibweisen
-- in der Datenbank steht; wächst über die Verwaltungsoberfläche.
CREATE TABLE previous_schools (
    previous_school_id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    label              text NOT NULL UNIQUE
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
-- Vollständigkeit ist Pflicht, nicht Kür: Straße, PLZ und Ort sind NOT NULL mit
-- <> '' (Begründung der Leerstring-Prüfung an persons.last_name). Eine
-- Adresszeile, die nur „Deutschland" enthält, wäre eine Karteileiche — sie ist
-- über den Dedup-Index unten nicht auffindbar, wird deshalb nie
-- wiederverwendet, und niemand sieht ihr an, ob die Anschrift fehlt oder der
-- Import sie verloren hat. „Keine Anschrift bekannt" bleibt trotzdem
-- ausdrückbar: persons.address_id ist nullable. Die Pflicht sagt also nicht
-- „jede Person hat eine Anschrift", sondern „wenn eine Zeile existiert, ist sie
-- benutzbar".
--
-- Hausnummer und Teilort bleiben nullable — die Hausnummer, weil es Anschriften
-- ohne sie gibt (Hofname, Postfach, Auslandsadresse), der Teilort, weil er die
-- baden-württembergische Ausnahme und nicht die Regel ist. Beide bekommen
-- trotzdem <> '': sie stehen im Dedup-Index, und dort sind NULL und '' zwei
-- verschiedene Zeilen für dieselbe Anschrift.
--
-- BEWUSSTE 3NF-ABWEICHUNG, hier festgehalten, damit sie bei der Abnahme nicht
-- als Versehen gilt: postal_code → city und district → city sind reale
-- Abhängigkeiten (ein Teilort gehört zu genau einer Gemeinde, eine PLZ meist
-- auch), city gehört zu keinem Schlüssel, und damit ist die Tabelle streng
-- genommen nicht in dritter Normalform. Drei Gründe, es so zu lassen:
--   * Der Katalog dafür ist bereits geprüft und verworfen (SVWS K_Ort/
--     K_Ortsteil, domains/stammdaten.md) — Pflegeaufwand ohne Nutzen, solange
--     nichts nach Gemeinde ausgewertet wird.
--   * Die Abhängigkeit gilt nicht exakt: eine PLZ kann mehrere Gemeinden
--     umfassen, und im Ausland trägt die Regel gar nicht. Eine Normalisierung
--     würde also eine Genauigkeit behaupten, die es nicht gibt.
--   * „Ein Ort pro Sachverhalt" (rules.md Abschnitt 1) ist davon NICHT berührt:
--     die Regel verbietet, einen aus dem Bestand ableitbaren Wert zusätzlich zu
--     speichern. Hier gibt es die bestimmende Tabelle bewusst nicht, city ist
--     also aus nichts ableitbar und steht an genau einer Stelle. Die Abweichung
--     ist eine der Normalform-Theorie, keine der Pflegbarkeit.
CREATE TABLE addresses (
    address_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    street       text NOT NULL CHECK (street <> ''),
    house_number text CHECK (house_number <> ''),      -- text statt Zahl wegen "12a", "12-14"
    district     text CHECK (district <> ''),          -- Teilort (baden-württembergische Besonderheit, ASV: ortsteil)
    postal_code  text NOT NULL CHECK (postal_code <> ''),
    city         text NOT NULL CHECK (city <> ''),
    -- Kein DB-DEFAULT auf Deutschland: das wäre eine fest verdrahtete Lookup-ID
    -- im Schema. Die Eingabemaske wählt Deutschland vor, der Import liefert den
    -- Wert mit.
    country_id   integer NOT NULL REFERENCES countries(country_id) ON DELETE RESTRICT,
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
    person_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    salutation_id     integer REFERENCES salutations(salutation_id) ON DELETE RESTRICT,
    -- Bewusst KEIN akademischer Grad daneben, obwohl ASV-BW ihn als eigene
    -- Werteliste führt (svp_person.wl_akademischer_grad_id) und svp_anschrift
    -- daraus "Sehr geehrter Herr Dr. Huber" zusammensetzt: er steht auf keinem
    -- der beiden Voranmeldeformulare, nicht in der Vis365-Feldliste, und kein
    -- benannter Prozess liest ihn — Domäne 7 exportiert Anrede/Name/E-Mail/Mobil
    -- (fachdomaenen.md Abschnitt 6). Die Existenz im Fremdsystem-Export ist
    -- ausdrücklich KEIN Beleg (rules.md Abschnitt 7); genau daran ist das Feld
    -- vor dem Freeze gescheitert. Die Anrede selbst besteht denselben Test und
    -- bleibt deshalb. Erzeugt Weltenbaum später eigene Elternbriefe und soll der
    -- Grad darin vorkommen, ist das ein benannter Prozess und der Weg zurück
    -- billig: eine Lookup-Tabelle plus eine nullable Spalte (Kopfkommentar,
    -- "Nachrüsten").
    -- Nullable für die seltenen Einzelname-Fälle — und deshalb mit <> '', obwohl
    -- die übrigen nullable Freitextspalten ungeprüft bleiben: hier trägt NULL
    -- eine Aussage („diese Person hat nur einen Namen"), und der Leerstring aus
    -- dem CSV-Import sähe genauso aus. Ohne den CHECK wäre der Einzelname vom
    -- verlorenen Vornamen nicht mehr zu unterscheiden.
    first_name        text CHECK (first_name <> ''),
    -- CHECK <> '': NOT NULL allein lässt den Leerstring durch — beim Vollimport
    -- aus CSV/Excel der häufigste Artefakt (wie bei email unten), und auf einer
    -- identitätstragenden Pflichtspalte fällt er hinterher nur als "leeres Feld"
    -- auf. Ebenso an phone_numbers.number und classes.stream;
    -- bewusst nicht an den nullable Freitextspalten, dort ist '' statt NULL kein
    -- Identitätsproblem und ein CHECK je Spalte wäre Aufwand ohne Nutzen.
    last_name         text NOT NULL CHECK (last_name <> ''),
    gender_id         integer REFERENCES genders(gender_id) ON DELETE RESTRICT,
    address_id        uuid REFERENCES addresses(address_id) ON DELETE RESTRICT,
    -- Die PRIVATE E-Mail der Person, und nur die. Von der Schule vergebene
    -- Postfächer stehen an der Rolle, die sie vergibt: das Schulpostfach des
    -- Kindes an children.school_email, die Dienstadresse an
    -- employees.work_email (beide dort begründet). Diese Spalte überlebt jede
    -- Rolle, jene enden mit ihr — ein ehemaliger Schüler, dessen Kind später
    -- hier ist, behält seinen OTP-Zugang, und die Schule kann sein altes
    -- c-schule.de-Postfach löschen und neu vergeben, ohne dass hier etwas
    -- Falsches stehenbleibt.
    -- Bei Erziehungsberechtigten zugleich die Identität für
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
    -- Beim Kind bleibt diese Spalte im Regelfall leer: es hat keine private
    -- Adresse im System, und sein Schulpostfach steht an children.school_email.
    -- Die eine Ausnahme ist die private Adresse, an die das Fotoeinverständnis
    -- ab 14 Jahren den Signaturlink schickt — und die gehört ebenfalls nicht
    -- hierher, sondern als Zustelladresse an die Zustimmungszeile selbst
    -- (Anmeldeprozess-Fachdomäne): sie belegt, wohin dieser eine Vorgang ging.
    -- Ein Login-Ziel wird das Kind so oder so nicht — die
    -- OTP-Eintrittsbedingung verlangt zusätzlich mindestens eine
    -- family_guardians-Zeile (idea/04).
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

-- Telefonnummern als Zeilen statt als feste Spalten (Festnetz/Arbeit/Mobil):
-- eine weitere Art ist damit eine Datenzeile, keine Migration. is_primary
-- kennzeichnet die von der Person benannte Hauptnummer. Abnehmer ist der
-- telefonische Erstkontakt des Sekretariats — ein Kind steht im Sekretariat und
-- jemand muss JETZT die Eltern erreichen, ohne aus drei Nummern zu raten.
-- Bewusst NICHT der Vis365-/M365-Export: der liest den Typ „Mobil" (siehe
-- phone_types), nicht dieses Flag, und begründet es deshalb auch nicht.
-- Muster von SVWS-NRW (SchuelerTelefone + K_TelefonArt) und ASV-BW
-- (svp_kommunikation); Gibbon nimmt stattdessen vier feste Slots phone1..phone4
-- und kann deshalb keine fünfte Nummer.
--
-- Gehört immer zu einer Person. Eine Behördennummer gibt es nicht als eigenen
-- Fall: die Sachbearbeiterin des Jugendamts ist selbst eine Person (Begründung
-- an guardians), ihre Durchwahl also ihre Nummer.
CREATE TABLE phone_numbers (
    phone_number_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id       uuid NOT NULL REFERENCES persons(person_id) ON DELETE CASCADE,
    phone_type_id   integer NOT NULL REFERENCES phone_types(phone_type_id) ON DELETE RESTRICT,
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
    -- Dieselbe Nummer steht real zweimal an derselben Person, einmal als
    -- "Mobil" und einmal als "Arbeit" — der Typ ist aber eine Eigenschaft der
    -- Nummer, nicht ihre Identität. Zwei Zeilen dafür wären ein zweiter Ort für
    -- denselben Sachverhalt (rules.md Abschnitt 1), und is_primary säße dann
    -- womöglich auf der falschen. Deckt nebenbei den doppelten Importlauf ab.
    -- Dieser Index trägt zugleich den Zugriff über person_id allein
    -- (B-Tree-Präfix) — ein zusätzlicher einspaltiger daneben wäre redundant.
    UNIQUE (person_id, number)
);
-- Höchstens eine Hauptnummer je Person. Referenzmuster für „höchstens eine
-- markierte Zeile je Gruppe" im ganzen Schema (ebenso
-- grade_levels_one_final_per_branch und, ohne Index, classes.is_active):
-- ein partieller Unique-Index über die Gruppenspalte mit WHERE auf das Flag.
-- Er sichert die Obergrenze, NICHT die Untergrenze — dass überhaupt eine Zeile
-- markiert ist, sichert die Eingabemaske. Schemaseitig wäre das eine Bedingung
-- über mehrere Zeilen hinweg und damit ein weiterer Trigger; dieselbe Abwägung
-- gilt an allen drei Stellen.
CREATE UNIQUE INDEX phone_numbers_one_primary_per_person ON phone_numbers (person_id) WHERE is_primary;

-- ---------------------------------------------------------------------------
-- Familie, Kind, Erziehungsberechtigte
-- ---------------------------------------------------------------------------

-- Familie: Sorgerecht-Konstellation, nicht Haushalt (domains/stammdaten.md).
-- Manuell durch die Verwaltung gepflegt. Gibbon führt dieselbe Struktur
-- (gibbonFamily + gibbonFamilyAdult + gibbonFamilyChild), hängt dort aber
-- zusätzlich die Wohnanschrift an die Familie — bei uns falsch, weil Familie
-- hier die Sorgerechtslage abbildet und nicht den gemeinsamen Haushalt.
--
-- Zwei Bezeichnungsfelder mit verschiedenem Publikum. Sie sind bewusst nicht zu
-- einem zusammengelegt, anders als beim Freitext der Warteliste
-- (domains/grenzkarte.md): dort teilen sich zwei Felder dieselbe Leserschaft und
-- laufen deshalb auseinander, hier ist genau die Trennung der Zweck — label geht
-- nach außen, alias nie.
CREATE TABLE families (
    family_id  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Außenbezeichnung für Anschreiben und Listen („Familie Müller").
    -- Nullable, und leer heißt NICHT „namenlos", sondern „aus den Mitgliedern
    -- ableiten" — dieselbe Übersteuerungs-Bauform wie payers.billing_address_id.
    -- Damit bleibt der Regelfall ohne Pflege korrekt und veraltet beim
    -- Namenswechsel nicht; gesetzt wird das Feld nur, wo die Ableitung
    -- danebenliegt. Das ist real der Patchwork-Fall: Mutter Müller, Vater
    -- Schmidt, Kinder teils so, teils so — dort ist aus den Mitgliedern keine
    -- eindeutige Anrede zu bilden, und ein Mensch muss entscheiden.
    -- Bewusst KEIN UNIQUE: zwei Familien Müller sind real und legitim — genau
    -- dafür gibt es das alias unten.
    label      text CHECK (label <> ''),
    -- Interne Unterscheidung fürs Sekretariat („Müller Sonnenweg", „Müller RS").
    -- Geht NIE in eine Zustellung: die Außenbezeichnung ist label. Deshalb ein
    -- zweites Feld und kein Zusatz im ersten — sonst steht der interne
    -- Unterscheider im Elternbrief.
    -- UNIQUE, weil ein doppelt vergebenes alias seinen einzigen Zweck verfehlt.
    -- Nullable bleibt es trotzdem, und Postgres wertet NULLs in einem UNIQUE als
    -- verschieden — die vielen Familien ohne alias kollidieren also nicht.
    -- CHECK <> '' hier anders als bei den übrigen nullable Freitextspalten
    -- (Begründung an persons.last_name): mit dem UNIQUE daneben belegte der
    -- erste Leerstring den Platz und der zweite schlüge scheinbar grundlos fehl.
    alias      text UNIQUE CHECK (alias <> ''),
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
    child_id                   uuid PRIMARY KEY REFERENCES persons(person_id) ON DELETE CASCADE,
    family_id                  uuid REFERENCES families(family_id) ON DELETE RESTRICT,  -- nullable: Familie wird ggf. erst nach dem Import zugeordnet
    -- Zahlungsverantwortliche/r für dieses Kind. Genau eine/r — warum ein
    -- Fremdschlüssel hier und keine Verknüpfungstabelle, steht an payers.
    -- Umgekehrt bleibt N:1: dieselbe zahlende Partei trägt mehrere Kinder
    -- (Geschwister, oder das Jugendamt für mehrere Mündel).
    -- Nullable: vor dem Schulvertrag gibt es keine/n, und ein reines
    -- Ferienprogramm-Kind zahlt über Stripe ganz ohne payers-Zeile
    -- (domains/grenzkarte.md, Q3).
    -- ON DELETE RESTRICT: eine zahlende Person verschwindet nicht, solange noch
    -- ein Kind auf sie zeigt.
    -- Fremdschlüssel per ALTER TABLE unten, weil payers erst nach children
    -- definiert wird (Reihenfolge, siehe dort).
    payer_id                   uuid,
    -- SEPA-Lastschriftmandat. Steht am KIND und nicht am Zahler: die Schule
    -- sammelt ausdrücklich je Kind ein eigenes Mandat ein. Der Grund ist kein
    -- technischer, sondern der reale Verfall — verlässt das erste Kind die
    -- Schule, trägt sein Mandat die Geschwister nicht weiter, und ohne eigenes
    -- Mandat wäre für sie nichts mehr einziehbar (prozesse.md Abschnitt 7.4).
    -- Ein Mandat je Zahler hätte genau diesen Fall still falsch abgebildet.
    --
    -- Zwei Spalten hier statt einer eigenen Mandatstabelle: die Beziehung ist
    -- 1:1 zum Kind, und wer zahlt, steht mit payer_id bereits daneben — eine
    -- Tabelle dafür trüge nichts, was diese Zeile nicht schon trägt. Die
    -- Bankverbindung bleibt dagegen an payers: sie gehört der Person, nicht dem
    -- Kind, und Geschwister teilen sie sich (Begründung dort).
    --
    -- Die Referenz vergibt die Schule (das Formular fragt sie nicht ab) und sie
    -- muss je Gläubiger-ID eindeutig sein — daher UNIQUE, jetzt über alle
    -- Kinder statt über alle Zahler.
    --
    -- Keine Mandatshistorie: Optigem führt die Lastschrift aus
    -- (fachdomaenen.md Abschnitt 4), Weltenbaum hält nur den aktuellen Stand.
    --
    -- Das unterschriebene Mandat wird zusätzlich digital abgelegt (PDF samt
    -- Signatur). Dieses Artefakt gehört NICHT hierher, sondern in die
    -- Schulvertrags-/Anmeldeprozess-Fachdomäne, die dieselbe Struktur schon für
    -- Schulvertrag, Gesundheitsdatenblatt und Fotoeinverständnis braucht; es
    -- zeigt seit dieser Änderung auf das Kind, nicht mehr auf payers.id
    -- (domains/grenzkarte.md, Q2). Wichtig dabei: das Dokument trägt KEIN
    -- eigenes Unterschriftsdatum — das steht hier, einmal. Der Nachweis ist das
    -- Artefakt, der Datenwert für den Einzug ist diese Spalte.
    mandate_reference          text UNIQUE CHECK (mandate_reference <> ''),
    mandate_signed_at          date,
    nickname                   text,               -- Rufname, falls abweichend vom Vornamen — Schulalltag (Lehrer), nicht amtlicher Schriftverkehr; ASV-BW bleibt für die amtliche Rufname/Vorname-Unterscheidung führend
    -- Schulpostfach (c-schule.de), vergeben und wieder eingezogen von der
    -- M365-Kontenverwaltung (fachdomaenen.md Abschnitt 6). An der Kind-Rolle
    -- statt an persons.email, aus demselben Grund wie employees.work_email und
    -- mit denselben drei Folgen: es ist UNIQUE (die Schule vergibt es selbst,
    -- geteilte gibt es nicht — anders als bei den Elternpostfächern, wo genau
    -- das der Regelfall ist); es verschwindet beim Abgang mit der Rolle, statt
    -- als tote oder inzwischen neu vergebene Adresse in der Personenzeile
    -- stehenzubleiben; und es kann deshalb nie eine OTP-Identität werden
    -- (idea/04), auch nicht versehentlich für einen ehemaligen Schüler, der
    -- Jahre später als Elternteil zurückkommt.
    -- Struktur-CHECK identisch zu persons.email und dort begründet.
    school_email               citext UNIQUE,
    date_of_birth              date NOT NULL,
    -- Freitext, anders als das direkt benachbarte birth_country_id: ein
    -- Geburtsort ist keine wiederholte Auswahl aus einem gepflegten Satz (jede
    -- Klinikstadt der Welt kommt in Frage) und niemand gruppiert danach
    -- (rules.md Abschnitt 3). ASV-BW hält es genauso und trennt an derselben
    -- Stelle: svp_schueler_stamm.geburtsort ist dort Freitext ("Geburtsort laut
    -- Geburtsurkunde"), das direkt daneben stehende wl_geburtsland_id dagegen
    -- Werteliste und Statistikpflichtfeld.
    birthplace                 text,
    birth_country_id           integer REFERENCES countries(country_id) ON DELETE RESTRICT,
    nationality_id             integer REFERENCES countries(country_id) ON DELETE RESTRICT,
    second_nationality_id      integer REFERENCES countries(country_id) ON DELETE RESTRICT,  -- doppelte Staatsangehörigkeit
    home_language_id           integer REFERENCES languages(language_id) ON DELETE RESTRICT,  -- ein Feld für Verkehrs-/Muttersprache, siehe domains/stammdaten.md
    -- Konfession/Kirchengemeinde: Art.-9-DSGVO-Daten (besondere Kategorie,
    -- Religionszugehörigkeit, Voranmeldeformular). NUR hier am Kind, nicht an
    -- der gemeinsamen Basistabelle persons — dieselbe Feld-pro-Rolle-Regel wie
    -- occupation bei guardians: guardians und payers können die
    -- Spalte damit strukturell gar nicht erst befüllen, nicht nur per
    -- Konvention. Dass Erziehungsberechtigte sie bewusst NICHT bekommen, obwohl
    -- beide Voranmeldeformulare danach fragen, steht an guardians.
    -- Schutz zusätzlich per Spalten-GRANT auf genau diese zwei Spalten statt
    -- über eine eigene Tabellengrenze (wb-backend/db/init-roles.sh; Owner von
    -- children darf dabei nicht backend_runtime sein, sonst greift das
    -- Spalten-GRANT nicht).
    denomination_id            integer REFERENCES denominations(denomination_id) ON DELETE RESTRICT,
    congregation               text,               -- Kirchengemeinde, Freitext
    provisional_grade_level_id integer REFERENCES grade_levels(grade_level_id) ON DELETE RESTRICT,  -- NUR gültig, solange class_id NULL ist (CHECK unten) — danach gilt classes.grade_level_id
    class_id                   integer REFERENCES classes(class_id) ON DELETE RESTRICT,  -- Klasse; NULL solange nicht zugeteilt oder nicht eingeschult
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
    registration_date          date,
    entry_date                 date,
    -- Abgangsdatum: Löschfrist-Anker (idea/06-dsgvo-organisatorisch.md). class_id
    -- bleibt beim Abgang stehen und wird NICHT geleert — die Kohorten-Kennung ist
    -- der Ablageort der digitalen Schülerakte (Tabellenkommentar an classes), und
    -- es gibt keine zweite Stelle, die festhält, in welcher Kohorte das Kind war.
    -- Gilt gleichermaßen für den regulären Abgang nach der Abschlussklasse und
    -- den Schulwechsel mitten im Jahr: bewusst kein Abgangsgrund daneben, kein
    -- benannter Prozess unterscheidet die beiden (domains/stammdaten.md,
    -- „Geprüft, bewusst nicht übernommen").
    exit_date                  date,
    previous_school_id         integer REFERENCES previous_schools(previous_school_id) ON DELETE RESTRICT,  -- abgebende Schule; steht auf dem Grundschul- wie dem Realschul-Voranmeldeformular
    previous_school_consent_at timestamptz,  -- Einwilligung zur Auskunftseinholung dort; NULL = keine Einwilligung. Zeitpunkt statt Boolean wegen Nachweispflicht (Art. 7 Abs. 1 DSGVO)
    created_at                 timestamptz NOT NULL DEFAULT now(),
    created_by                 text NOT NULL,
    updated_at                 timestamptz NOT NULL DEFAULT now(),
    updated_by                 text NOT NULL,
    CHECK (school_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
    CONSTRAINT children_second_nationality_requires_first_check
        CHECK (second_nationality_id IS NULL OR nationality_id IS NOT NULL),
    -- Zweimal derselbe Staat ist keine doppelte Staatsangehörigkeit, sondern das
    -- Ergebnis einer doppelt gemappten Importspalte. Der NULL-Zweig muss explizit
    -- stehen: IS DISTINCT FROM allein wäre falsch, denn zwei NULL gelten dabei
    -- als nicht verschieden und der CHECK wiese jedes Kind ohne
    -- Staatsangehörigkeit ab.
    CONSTRAINT children_second_nationality_differs_check
        CHECK (second_nationality_id IS NULL OR second_nationality_id <> nationality_id),
    CONSTRAINT children_exit_after_entry_check
        CHECK (exit_date IS NULL OR entry_date IS NULL OR exit_date >= entry_date),
    -- Angemeldet wird vor dem Eintritt, nie danach. Fängt vertauschte Spalten
    -- beim Import — die beiden Daten liegen dort nebeneinander.
    CONSTRAINT children_entry_after_registration_check
        CHECK (entry_date IS NULL OR registration_date IS NULL OR entry_date >= registration_date),
    -- Geboren wird vor Anmeldung und Eintritt. Das Geburtsdatum ist die einzige
    -- NOT-NULL-Datumsspalte hier und trägt die halbe Dublettenerkennung
    -- (Nachname + Geburtsdatum, domains/stammdaten.md) — ohne Plausibilitätsregel
    -- wäre es die einzige Datumsspalte ganz ohne. Auf dem Voranmeldeformular
    -- stehen kindGeburtsdatum und Anmeldedatum in derselben Feldliste; eine
    -- vertauschte Zuordnung beim Import liefe sonst still durch und fiele erst
    -- Jahre später als unauffindbare Dublette auf. Ein Kind ohne beide
    -- Bezugsdaten (reines Ferienprogramm-Kind) bleibt ungeprüft — dort gibt es
    -- keinen Bezugspunkt.
    CONSTRAINT children_born_before_registration_check
        CHECK (registration_date IS NULL OR date_of_birth < registration_date),
    CONSTRAINT children_born_before_entry_check
        CHECK (entry_date IS NULL OR date_of_birth < entry_date),
    CONSTRAINT children_previous_school_consent_check
        CHECK (previous_school_consent_at IS NULL OR previous_school_id IS NOT NULL),
    CONSTRAINT children_class_excludes_provisional_grade_check
        CHECK (class_id IS NULL OR provisional_grade_level_id IS NULL),
    -- Referenz ohne Datum ist kein gültiges Mandat und umgekehrt — beide oder
    -- keines.
    CONSTRAINT children_mandate_complete_check
        CHECK ((mandate_reference IS NULL) = (mandate_signed_at IS NULL)),
    -- Ein Mandat ohne Zahler ist nicht einziehbar. Umgekehrt gilt das nicht:
    -- ein Kind darf eine/n Zahler/in ohne Mandat haben (Erfassung vor
    -- Vertragsabschluss).
    --
    -- Diese Prüfung ist schwächer als die frühere „Mandat nur mit IBAN", und
    -- das ist der Preis der Verlagerung: die IBAN steht an payers, ein CHECK
    -- kann nicht über zwei Tabellen greifen. Bewusst kein Trigger dafür — der
    -- Schulvertragsprozess erhebt Bankverbindung und Mandat in einem Schritt
    -- (prozesse.md Abschnitt 7.4), die Lücke ist also kein realer Ablauf. Was
    -- die Datenbank hier noch garantiert, ist die Kette Mandat → Zahler → Zeile
    -- in payers, in der die IBAN dann stehen kann.
    CONSTRAINT children_mandate_requires_payer_check
        CHECK (mandate_reference IS NULL OR payer_id IS NOT NULL)
);
CREATE INDEX ON children (family_id);
CREATE INDEX ON children (class_id);
CREATE INDEX ON children (provisional_grade_level_id);
-- „Welche Kinder zahlt diese Partei" — die Abfrage der Buchhaltung vor dem
-- Optigem-Übertrag und die Grundlage jeder Rechnung.
CREATE INDEX ON children (payer_id);
-- Bewusst KEIN Index auf date_of_birth: die einzige Abfrage, die das Feld filtert,
-- ist die Dublettenprüfung (Nachname + Geburtsdatum, domains/stammdaten.md) — die
-- startet über den Namen, und das Geburtsdatum ist nur noch der zweite Filter auf
-- einer Tabelle dieser Größe. Gegen Postgres 18 mit 500 Kindern nachgestellt: der
-- Planer scannt children und schlägt persons je Zeile über den Primärschlüssel
-- nach, ein Index auf date_of_birth käme dabei nicht zum Einsatz. Kein
-- Fremdschlüssel hängt daran.

-- Erziehungsberechtigte: IST eine Person — deshalb teilt sich guardians.id
-- direkt mit persons.id, wie bei children, payers und employees. Kein
-- Surrogatschlüssel und keine zusätzliche person_id daneben.
--
-- Es gibt bewusst KEINE Organisation als Erziehungsberechtigte, obwohl das
-- Jugendamt (Amtsvormundschaft, §1791b BGB, §55 SGB VIII) und ein Verein
-- (§1791a BGB) rechtlich Vormund sein können. Grund ist der einzige Eingang ins
-- System: Kinder kommen ausschließlich über den Anmeldeprozess, und dessen
-- Formular fragt Mutter, Vater und Pflegeeltern — nie eine Institution
-- (fachdomaenen.md Abschnitt 6). Was tatsächlich ankommt, ist die handelnde
-- Person; dass sie beim Jugendamt arbeitet, erfährt die Schule erst danach. Eine
-- Organisationszeile hätte damit keinen Erzeuger, und entscheiden kann ohnehin
-- nur ein Mensch: das Gesetz trennt genau so (das Amt überträgt die AUSÜBUNG
-- einzelnen Beamten oder Angestellten). Für welche Institution jemand handelt,
-- trägt family_guardians.acting_for; dass daraus keine Elternmitarbeitspflicht
-- folgt, trägt guardian_categories.exempt_from_parent_duties.
--
-- Folge, bewusst so: eine Amtsvormundin bekommt damit denselben OTP-Zugang wie
-- jede andere Erziehungsberechtigte (idea/04). Das ist nötig, weil sie den
-- Anmeldeprozess durchlaufen und den Schulvertrag zeichnen muss — und es macht
-- sie zugleich in Q1/Q2 referenzierbar, was mit einem Namensstring unmöglich wäre.
--
-- Name, Anschrift, Telefon und E-Mail stehen nicht hier, sondern an persons —
-- SVWS-NRW legt sie stattdessen als Anrede1/Name1/Vorname1 +
-- Anrede2/Name2/Vorname2 in EINE Zeile am Schüler (SchuelerErzAdr) und kann damit
-- weder Patchwork noch einen dritten Sorgeberechtigten abbilden.
--
-- ON DELETE RESTRICT statt CASCADE wie bei children: einen
-- Erziehungsberechtigten zu löschen ist eine echte Entscheidung des Lösch-Jobs
-- (domains/stammdaten.md, „Löschmechanik").
CREATE TABLE guardians (
    guardian_id     uuid PRIMARY KEY REFERENCES persons(person_id) ON DELETE RESTRICT,
    -- Beruf (Voranmeldeformular). Freitext: kein
    -- Prozess wertet nach Beruf aus, eine gepflegte Berufsliste wäre
    -- Pflegeaufwand ohne Nutzen (rules.md Abschnitt 3).
    occupation      text,
    -- Bewusst KEIN is_employee-Flag: die Mitarbeiter-Eigenschaft steht an
    -- employees (unten) und ist von dort ableitbar — ein Flag daneben wäre ein
    -- zweiter Ort für dieselbe Tatsache (rules.md Abschnitt 1) und träfe zudem
    -- die falsche Aussage: die Putzdienst-Befreiung (domains/putzdienst.md)
    -- hängt daran, ob jemand AKTUELL beschäftigt ist, nicht ob er es einmal war.
    -- Bewusst KEINE Konfession/Kirchengemeinde und keine Staatsangehörigkeit,
    -- obwohl beide Voranmeldeformulare beides abfragen: kein benannter Prozess
    -- braucht sie bei Erziehungsberechtigten — der ASV-BW-Export betrifft nur
    -- Kinder. Ein Formularfeld allein reicht als Beleg nicht, wenn es keinen
    -- Abnehmer gibt (rules.md Abschnitt 7), und bei Art.-9-Daten wiegt das
    -- doppelt: die Spalte gar nicht erst anzulegen ist die einzige Absicherung,
    -- die auch ein Import nicht umgehen kann. Beide Felder werden beim Umzug
    -- nach Weltenbaum aus dem Formular gestrichen statt ins Schema übernommen.
    -- Sollte die Aufnahmeentscheidung die Konfession der Eltern doch bewerten,
    -- gehört sie an die Bewerbung (domains/grenzkarte.md, Domäne 2/4) — dort hat
    -- sie die kürzere Löschfrist, die Art.-9-Daten ohnehin verdienen.
    created_at      timestamptz NOT NULL DEFAULT now(),
    created_by      text NOT NULL,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    updated_by      text NOT NULL
);

-- ---------------------------------------------------------------------------
-- Mitarbeiter
-- ---------------------------------------------------------------------------

-- Mitarbeiter: IST eine Person (immer natürlich) — deshalb teilt sich
-- employees.id direkt mit persons.id, wie bei children und guardians.
--
-- Steht schon jetzt, obwohl keine der Domänen gebaut ist, die sie braucht —
-- warum vorgezogen und was bewusst noch fehlt (Bereichs-/Vorgesetztenstruktur),
-- steht in domains/grenzkarte.md, Q4. Kein toter Code.
CREATE TABLE employees (
    employee_id      uuid PRIMARY KEY REFERENCES persons(person_id) ON DELETE CASCADE,
    -- Dienstadresse, getrennt von persons.email. Letztere ist die private
    -- Adresse und zugleich die OTP-Identität (idea/04) — ein Mitarbeiter, der
    -- zugleich Elternteil ist, verlöre sonst beim Offboarding seinen
    -- Elternzugang, obwohl er Elternteil bleibt. Anders als persons.email hier
    -- UNIQUE: die Schule vergibt diese Postfächer selbst, geteilte gibt es
    -- nicht. Struktur-CHECK identisch zu persons.email und dort begründet.
    -- Dieselbe Bauform trägt children.school_email; wer eine dritte Rolle mit
    -- eigenem Postfach anlegt, folgt ihr ebenfalls, statt persons.email zu
    -- überladen.
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
    CONSTRAINT employees_employment_period_check
        CHECK (employment_end IS NULL OR employment_start IS NULL OR employment_end >= employment_start)
);

-- Klassenlehrer:in. Der Fremdschlüssel steht hier statt an der Tabelle, weil
-- classes weiter oben definiert wird (Schulstruktur-Block) und employees erst
-- persons voraussetzt. Eine von zwei Stellen im Schema mit dieser Reihenfolge,
-- die zweite ist children.payer_id ganz unten.
-- Nullable: eine neue Kohorte existiert vor ihrer Lehrkraft, festgelegt wird
-- sie erst bei der Klassenbildung (fachdomaenen.md Abschnitt 6).
ALTER TABLE classes ADD FOREIGN KEY (class_teacher_id) REFERENCES employees(employee_id) ON DELETE RESTRICT;
CREATE INDEX ON classes (class_teacher_id);

-- Erziehungsberechtigte↔Familie: M:N (Patchwork-Fall, domains/stammdaten.md).
-- Nur sorgerechtgebende Mitgliedschaft — reines Umgangsrecht wird hier nie
-- eingetragen. Diese Tabelle ist zugleich die Grundlage des OTP-Ownership-Checks
-- und die vorgesehene Stelle für eine spätere Sichtbarkeits-Einschränkung
-- zwischen Sorgeberechtigten (domains/stammdaten.md, „Offene Punkte") — Gibbon
-- führt dort genau dafür ein Flag (gibbonFamilyAdult.childDataAccess). Wir bauen
-- es erst, wenn ein Fall vorliegt; die Struktur muss dafür nicht geändert werden.
CREATE TABLE family_guardians (
    family_id                 uuid NOT NULL REFERENCES families(family_id) ON DELETE CASCADE,
    guardian_id               uuid NOT NULL REFERENCES guardians(guardian_id) ON DELETE CASCADE,
    guardian_category_id      integer REFERENCES guardian_categories(guardian_category_id) ON DELETE RESTRICT,
    -- „In Briefe miteinbeziehen" — steht auf allen vier Anmeldetag-Checklisten
    -- direkt neben „Sorgeberechtigt" und entscheidet, wer Schulpost und
    -- Prozessmails bekommt. An der Familienzugehörigkeit und nicht an der
    -- Person: dieselbe Person kann für ein Kind einbezogen sein und für ein
    -- anderes nicht. Default true — wer sorgeberechtigt ist, wird im Regelfall
    -- angeschrieben; das Abwählen ist der begründungspflichtige Fall.
    -- Betrifft auch die Putzdienst-Erinnerungen (domains/putzdienst.md).
    include_in_correspondence boolean NOT NULL DEFAULT true,
    -- Für welche Institution diese Person in diesem Fall handelt („Jugendamt
    -- Musterkreis"), Freitext. Leer im Regelfall — gesetzt bei Amts- oder
    -- Vereinsvormundschaft, wo die Person selbst Erziehungsberechtigte ist
    -- (Begründung an guardians), der Brief aber „Jugendamt Musterkreis, z. Hd.
    -- Frau Meier" adressiert werden muss. An der Familienzugehörigkeit und nicht
    -- an der Person, aus demselben Grund wie guardian_category_id darüber.
    --
    -- Freitext und keine Werteliste: es sind einstellig viele Institutionen,
    -- niemand gruppiert danach, und die Befreiung von der Elternmitarbeit hängt
    -- nicht hieran, sondern an guardian_categories — dieses Feld trägt keine
    -- Regel, nur die Anschrift im Brief.
    acting_for                text,
    created_at                timestamptz NOT NULL DEFAULT now(),
    created_by                text NOT NULL,
    updated_at                timestamptz NOT NULL DEFAULT now(),
    updated_by                text NOT NULL,
    PRIMARY KEY (family_id, guardian_id)
);
CREATE INDEX ON family_guardians (guardian_id);

-- ---------------------------------------------------------------------------
-- Kontakte (nicht-rechtliche Bezugspersonen)
-- ---------------------------------------------------------------------------

-- Notfallkontakt/Abholberechtigt ohne Rechtsstellung — nie Datenzugriff, kein
-- Ownership-Check nötig, kein Login (domains/stammdaten.md). Kontaktpersonen
-- sind persons-Zeilen wie alle anderen: dieselbe Großmutter, die für ein
-- Enkelkind Pflegeelternteil und für ein anderes nur Notfallkontakt ist, steht
-- damit einmal in der Datenbank statt zweimal, und Name/Telefon/Anschrift
-- folgen derselben Mechanik wie überall sonst. ASV-BW hängt an svp_kontakt
-- ebenfalls eine Anschrift — dort allerdings an Institutions-Kontakte (laut
-- wl_kontakttyp_id Heim, Sponsor, Förderkreis, Lieferant), nicht an
-- Bezugspersonen; Gibbon legt Notfallkontakte dagegen als feste Spaltenpaare
-- (emergency1Name … emergency2Relationship) auf die Person des Kindes und
-- kann deshalb keinen dritten Kontakt und keine geteilte Nummer.
--
-- Es gibt bewusst KEINE Rollentabelle contacts neben dieser Verknüpfung, anders
-- als bei children, guardians, payers und employees. Der Unterschied ist die
-- Nutzlast: jene vier tragen rollenspezifische Spalten (Demografie, Beruf,
-- Bankverbindung, Beschäftigungszeitraum), eine contacts-Zeile trüge nur ihren
-- Primärschlüssel und vier Audit-Spalten. Sie sagte damit exakt das, was diese
-- Tabelle ohnehin sagt — „diese Person ist Kontakt eines Kindes" — und wäre ein
-- zweiter Ort für dieselbe Tatsache (rules.md Abschnitt 1), pflegbar bis zur
-- verwaisten Rollenzeile ohne einzige Verknüpfung. Die Rolle ist hier das, was
-- sie überall ist: eine Menge, kein Datensatz (domains/stammdaten.md, „Felder").
-- Preis, bewusst getragen: der Fremdschlüssel bezeugt nicht, dass jemand die
-- Person ausdrücklich als Kontakt vorgemerkt hat — jede persons-Zeile ist
-- eintragbar. Eine Rollentabelle leistete das aber auch nicht, denn sie stünde
-- jeder Person offen; sie verlangte nur einen Schreibschritt mehr.
--
-- Kein Notizfeld: sein einziges dokumentiertes Beispiel („nur nachmittags
-- erreichbar") trägt phone_numbers.note bereits je Nummer und damit genauer.
-- Anschrift und E-Mail sind für Kontaktpersonen technisch befüllbar —
-- Datensparsamkeit ist dort nur eine Regel der Eingabemaske, nicht strukturell
-- erzwungen wie bei Demografie (nur children) und Beruf (nur guardians).
--
-- relationship steht an der Verknüpfung, nicht an der Person: „Großmutter" gilt
-- relativ zum Kind, nicht absolut. Verknüpfung an das Kind und nicht
-- an die Familie, weil ein Kind vor der manuellen Familienzuordnung noch keine
-- Familie hat.
--
-- priority: Reihenfolge „Notfallkontakt 1/2/3", ein realer Prozess an dieser
-- Schule — anders als die bewusst nicht übernommene Gibbon-contactPriority bei
-- Erziehungsberechtigten (domains/stammdaten.md). Nullable, weil nicht jede
-- Verknüpfung eine Reihenfolge braucht; wo gesetzt, höchstens einmal je Kind
-- (UNIQUE unten) — keine zwei Kontakte mit demselben Rang.
CREATE TABLE child_contacts (
    child_id     uuid NOT NULL REFERENCES children(child_id) ON DELETE CASCADE,
    contact_id   uuid NOT NULL REFERENCES persons(person_id) ON DELETE CASCADE,
    -- Freitext, bewusst anders als guardian_categories an family_guardians —
    -- dort steht dieselbe Art Frage („wie steht diese Person zum Kind?") als
    -- Lookup. Unterschied: dort ist der Satz klein, rechtlich relevant und
    -- stabil; hier hat er einen langen Schwanz („Patentante", „Freundin der
    -- Familie"), niemand wertet Notfallkontakte nach Verwandtschaftsgrad aus,
    -- und eine Lookup zwänge das Sekretariat, beim Erfassen erst eine Kategorie
    -- anzulegen — Pflegeaufwand ohne Nutzen (rules.md Abschnitt 3).
    relationship text,
    priority     smallint,
    -- Darf dieses Kind an diese Person herausgegeben werden. Eigene Spalte und
    -- nicht in priority hineingelesen (gesetzt = Notfallkontakt, leer = „nur
    -- abholberechtigt"): diese Lesart kann den Fall „anrufbar, aber NICHT
    -- abholberechtigt" nicht ausdrücken — den geschiedenen Onkel, die entfernte
    -- Verwandte. Genau der ist der haftungsrelevante. Zwei unabhängige
    -- Ja/Nein-Aussagen brauchen zwei Spalten.
    --
    -- DEFAULT false, anders als family_guardians.include_in_correspondence
    -- (dort true): die Risikorichtung ist umgekehrt. Wer versehentlich keinen
    -- Elternbrief bekommt, fragt nach; wem versehentlich ein Kind mitgegeben
    -- wird, den holt niemand zurück. Die Erlaubnis muss deshalb aktiv gesetzt
    -- werden, nicht abgewählt.
    --
    -- Nur für Kontaktpersonen. Erziehungsberechtigte brauchen kein solches
    -- Kennzeichen — das Abholrecht folgt aus dem Sorgerecht und damit aus der
    -- family_guardians-Zeile selbst; eine gerichtliche Einschränkung ist ein
    -- Einzelfall ohne aktuellen Vertreter (rules.md Abschnitt 1,
    -- domains/stammdaten.md „Offene Punkte").
    pickup_authorized boolean NOT NULL DEFAULT false,
    created_at   timestamptz NOT NULL DEFAULT now(),
    created_by   text NOT NULL,
    updated_at   timestamptz NOT NULL DEFAULT now(),
    updated_by   text NOT NULL,
    PRIMARY KEY (child_id, contact_id),
    -- Ein Kind ist nicht sein eigener Notfallkontakt. Seit contact_id direkt auf
    -- persons zeigt, wäre das eintragbar — und eine doppelt gemappte
    -- Importspalte ist der reale Weg dorthin, wie bei
    -- children_second_nationality_differs_check.
    CONSTRAINT child_contacts_not_self_check CHECK (child_id <> contact_id)
);
CREATE INDEX ON child_contacts (contact_id);
CREATE UNIQUE INDEX child_contacts_one_contact_per_priority ON child_contacts (child_id, priority) WHERE priority IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Zahlungsverantwortliche
-- ---------------------------------------------------------------------------

-- Zahlungsverantwortlich für ein Kind ist nicht dasselbe wie sorgeberechtigt
-- (domains/stammdaten.md) — Großeltern zahlen mit oder allein, ohne
-- Erziehungsberechtigte zu sein. Deshalb eine eigene Rolle statt
-- Wiederverwendung von guardians; wie diese IST sie eine Person und
-- teilt sich den Schlüssel mit persons. Dass sie überhaupt eine eigene Tabelle
-- bekommt und die Kontaktrolle nicht, entscheidet die Nutzlast: hier stehen
-- Bankverbindung und Mandat, dort stünde nichts (Begründung an child_contacts).
--
-- Auch eine Kostenübernahme durch das Jugendamt (z. B. Ferienprogramm) läuft
-- über eine Person — die handelnde Sachbearbeiterin, Begründung an guardians.
-- Dass das Geld vom Amt kommt, tragen die vorhandenen Spalten: account_holder
-- nimmt den abweichenden Kontoinhaber auf, billing_address_id die Amtsanschrift.
--
-- Bewusst KEIN Anteil/Betrag: an der Schule zahlt real immer eine Partei allein
-- (auch das Jugendamt bei Kostenübernahme), geteilte Beiträge gibt es nicht.
-- Die Zuordnung ist deshalb ein Fremdschlüssel am Kind (children.payer_id) und
-- keine Verknüpfungstabelle. Käme die Aufteilung später doch, ist sie eine neue
-- Tabelle neben dieser — die alte M:N-Struktur hätte den Anteil ohnehin nicht
-- getragen, also für denselben Fall ebenfalls umgebaut werden müssen.
--
-- IBAN/BIC sind sensible, aber keine Art.-9-Daten — eigene Rollentabelle statt
-- Spalten auf persons/children/guardians (anders als Konfession oben): der
-- Zugriffskontext ist ein anderer (Abrechnung statt allgemeines Personenprofil),
-- betrifft nur wenige Personen, und die meisten Abfragen auf persons brauchen
-- die Daten nie mit. Eigene, engere DB-Rolle wie bei den Konfessionsspalten
-- (wb-backend/db/init-roles.sh).
--
-- billing_address_id nullable: NULL heißt „Anschrift der zahlenden Person
-- gilt", nur bei abweichender Rechnungsadresse gesetzt — kein Pflicht-Duplikat
-- der ohnehin vorhandenen Adresse.
--
-- ON DELETE RESTRICT wie bei guardians: eine zahlende Person verschwindet nicht
-- nebenbei, solange sie referenziert ist. Umgekehrt blockiert seit dem Wegfall
-- der Verknüpfungstabelle nichts mehr das Löschen eines Kindes mit
-- Zahlungsverantwortung — die Zuordnung verschwindet mit der Kindzeile, die
-- payers-Zeile bleibt und fällt als verwaist im selben Lauf
-- (domains/stammdaten.md, „Löschmechanik").
CREATE TABLE payers (
    payer_id           uuid PRIMARY KEY REFERENCES persons(person_id) ON DELETE RESTRICT,
    billing_address_id uuid REFERENCES addresses(address_id) ON DELETE RESTRICT,
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
    -- Die BIC bleibt, obwohl zwei Gründe gegen sie sprechen: Datensparsamkeit
    -- (rules.md Abschnitt 7) — für SEPA-Zahlungen innerhalb der Union darf sie
    -- seit dem 1.2.2016 nicht mehr verlangt werden (VO 260/2012, „IBAN-only")
    -- — und Normalform: sie folgt aus der IBAN, die das Institut
    -- identifiziert, also die transitive Abhängigkeit payer_id → iban → bic
    -- und damit ein 3NF-Verstoß. Dieselbe Ableitungskette, mit der das
    -- Kreditinstitut vom Formular gar nicht erst übernommen wird (unten), nur
    -- eine Stufe früher angesetzt.
    -- Beides tritt zurück, weil der Abnehmer feststeht: Optigem verlangt die
    -- BIC für Konten außerhalb Deutschlands (prozesse.md Abschnitt 7.4). Für
    -- inländische Konten bleibt sie leer — deshalb nullable und bewusst kein
    -- CHECK, der sie an das Länderpräfix der IBAN koppelt: welche Konten
    -- Optigem als „nicht deutsch" behandelt, entscheidet dessen Importformat
    -- und nicht diese Tabelle. ASV-BW führt daneben in svp_kontoverbindung
    -- ebenfalls eine swift-Spalte, nullable, ohne Statistikpflichtfeld-Marker,
    -- und die Bankverbindung hängt dort als eigene Entität über
    -- svp_schueler_stamm_kto_verbind am Schüler — sie existiert also auch
    -- dort, verlangt wird sie nicht.
    bic                text CHECK (bic ~ '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$'),
    account_holder     text,               -- Kontoinhaber, falls abweichend vom Namen der Person/Organisation
    -- Kreditinstitut steht bewusst NICHT daneben, obwohl das Formular es
    -- abfragt: es folgt aus der BIC und wäre ein zweiter Ort für denselben
    -- Sachverhalt (rules.md Abschnitt 1).
    --
    -- Das SEPA-Mandat steht ebenfalls NICHT hier, sondern an children: die
    -- Schule sammelt je Kind eines ein, nicht je Zahler (Begründung dort). Was
    -- hier bleibt, ist das Einzugs*mittel* — die Bankverbindung gehört der
    -- Person und wird von Geschwistern geteilt, das Mandat nicht.
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,
    updated_at         timestamptz NOT NULL DEFAULT now(),
    updated_by         text NOT NULL
);
CREATE INDEX ON payers (billing_address_id);

-- Zahlungsverantwortliche/r des Kindes. Wie bei classes.class_teacher_id per
-- ALTER TABLE nachgezogen: children wird oben definiert, payers erst hier.
ALTER TABLE children ADD FOREIGN KEY (payer_id) REFERENCES payers(payer_id) ON DELETE RESTRICT;

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

CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON guardian_categories
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON grade_levels
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON classes
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON addresses
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON persons
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
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON child_contacts
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
CREATE TRIGGER set_row_audit BEFORE INSERT OR UPDATE ON payers
    FOR EACH ROW EXECUTE FUNCTION set_row_audit();
