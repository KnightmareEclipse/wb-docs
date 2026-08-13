# TODO — Offene Punkte für Entwicklungs-Sessions

Fachliche/technische Punkte, die eine Session in diesem Repo oder in `wb-backend` abarbeiten kann — im Unterschied zu `TODO.md`, das reale Konten/Zugänge und organisatorische Vorbereitungen sammelt. Sortiert nach Dringlichkeit.

## Vor dem ersten Import echter Daten

### Was an Domänenschemata noch offen ist

Gebaut sind Stammdaten, Putzdienst, Anmeldung (samt Q1/Q2/Q3/Q5), Ferienanmeldung, Gesundheitsdaten, der Mensa-Kern (`domains/mensa.md`) und die Klassenorganisation (`domains/klassenorganisation.md`) — damit alle Domänen, die vor dem Freeze gegen Stammdaten geprüft wurden, alle fünf Querschnitts-Entitäten und der gesamte Art.-9-Bestand.

Offen sind nur noch die nicht terminlich getriebenen Domänen: **5 Rechnungsfreigabe** (braucht zuerst die Bereichs- und Vorgesetztenstruktur an `employees`, Zuschnitt unbekannt — `domains/grenzkarte.md`, „Weiße Flecken"), **6 AGs** (nichts Konkretes bekannt) und **11 Bonussystem** (ausdrücklich nicht v1); **8 Eltern-Selfservice** und **12 Klassenbildung** brauchen per Festlegung keine eigenen Tabellen.

Keine davon ist vor dem Vollimport fällig, und keine verlangt eine Änderung an einer bestehenden Stammdaten-Spalte.

### Wie die Anmeldeformulare Kinder nicht doppelt anlegen

Ein Formular je Vorgang, zwei Einstiege — nicht zwei Formulare. Identisch sind Programm bzw. Zielklassenstufe, Betreuungsmodul, Zustimmungen und Zahlung; unterschiedlich ist allein der Identitätsblock: bekannte Adresse → Kind aus der Auswahlliste, Erziehungsberechtigte und Anschrift vorbelegt (Korrekturen laufen über den Eltern-Selfservice, nicht über ein Anmeldeformular); unbekannte → dieselben Felder leer, die Zeilen entstehen daraus. Gedoppelt werden dürfen die Feldlisten nicht, sonst läuft eine der beiden Fassungen still hinterher.

Welcher Einstieg gilt, entscheidet der OTP-Fluss, der jedem Vorgang vorausgeht (`idea/04-identitaet-zugriff.md`) — der Absender wählt ihn nicht. Das ist der Kern der Dublettenvermeidung: der Regelfall ist eine **Auswahl**, kein Abgleich. Für Wiederkehrer gilt das auch dann, wenn sie schulfremd sind, denn auch ein Ferienprogramm-Kind bekommt eine Familie (`domains/stammdaten.md`).

Verstärkt wird das über den Einstiegspunkt: Die Ankündigung des Ferienprogramms geht als Mail mit Link an die in Stammdaten hinterlegten Adressen, nicht als Verweis auf die Website. Der Link ist **je Empfänger personalisiert**, nicht einer für alle — das System erzeugt die Mails ohnehin einzeln, und ein generischer Link führte auf ein leeres Adressfeld und damit zurück in den Irrtum, den er verhindern soll. **Anmelden tut er nicht** — er trägt die Adresse, an die er ging, füllt damit das Adressfeld und löst den Code aus, den der Elternteil wie sonst auch eingibt. Weil er nichts freischaltet, braucht er auch keinen Token-Speicher und keine Gültigkeitsdauer: die Adresse steht als Parameter in der URL. Sie liegt unterwegs im TLS-verschlüsselten Teil und ist nur auf dem Gerät des Empfängers sichtbar, dem sie ohnehin gehört — **mitschreiben darf der Reverse-Proxy die Query dieser Route aber nicht**, sonst steht die Adresse in einem Bestand mit anderer Aufbewahrung und anderem Leserkreis als die Datenbank (`idea/03-container-anwendung.md`, Zentrales Logging). Zwei Wirkungen, beide wichtiger als der gesparte Schritt: Der Elternteil muss sich nicht erinnern, unter welcher seiner Adressen er vor drei Jahren gebucht hat — genau der Irrtum, aus dem der Dublettenfall unten entsteht, und für jede erreichbare Familie damit erledigt. Und eine weitergeleitete Ankündigung („schau mal, Ferienprogramm!") nützt dem Empfänger nichts, weil der Code an das ursprüngliche Postfach geht.

Ein selbst authentifizierender Link wäre der kürzere Weg, ist hier aber falsch: Weiterleiten ist bei solchen Mails der Normalfall, und der Empfänger bekäme Lesezugriff auf eine fremde Familie. Das ist eine andere Klasse als die bewusst akzeptierte geteilte Elternmailbox (`idea/04-identitaet-zugriff.md`) — die wirkt innerhalb einer Familie, diese über Familiengrenzen hinweg.

Übrig bleibt der Elternteil, der ein anderes Postfach benutzt als das hinterlegte — der Fall bricht nicht ab, sondern gelingt auf dem falschen Weg: Code kommt, Formular öffnet sich, Anmeldung geht durch, nur eben als Fremder mit neuem Kind. Das leere Formular fragt deshalb vor dem Absenden einmal, ob das Kind schon einmal an der Schule oder im Ferienprogramm war, und rät bei „ja" zur Adresse von damals. Das ist eine Frage und keine Auskunft — wer die Antwort nicht ohnehin kennt, erfährt daraus nichts — und sie erreicht genau den, der es selbst am besten weiß. Dafür der Kandidatenabgleich Nachname + Geburtsdatum — mit zwei Regeln: **nie automatisch verknüpfen** und **das Ergebnis nie an den Absender**. Verknüpfte der anonyme Pfad selbsttätig, bekäme jeder, der Name und Geburtsdatum eines echten Schulkindes kennt — beides steht auf jeder Klassenliste —, eine Erziehungsberechtigten-Zeile in dessen Familie und damit Zugriff auf dessen Daten. Der Hinweis gehört deshalb als Feld an die Bewerbung bzw. die Buchung, die das Sekretariat ohnehin sichtet, samt Knopf zum Verknüpfen — **keine eigene Dublettenliste**: eine Liste, die zusätzlich geöffnet werden muss, wird nicht geöffnet (`fachdomaenen.md` Abschnitt 3). Der Fall schrumpft von selbst, weil auch die abweichende Adresse nach der ersten Anmeldung bekannt ist.

Zwei Punkte sind beim Entwurf zu entscheiden: ob die Personenzeilen **vor oder nach** der Zahlungsbestätigung entstehen — davor sammelt jeder Zahlungsabbruch Personendaten ohne Vorgang, danach muss das Formular seinen Inhalt zwischenparken. Und welche Löschfrist eine nie zur Aufnahme geführte Fremdanmeldung mitbringt: die Bewerbung hat eine eigene, kürzere, die mit ihr angelegten Personenzeilen brauchen dieselbe, sonst wächst Stammdaten mit Leuten, die nie an der Schule waren.

### Import-Prozedur: Nachschlagen statt blind einfügen

Der Vollimport läuft **einmal in eine leere Datenbank**; ein Korrekturlauf heißt „verwerfen und neu laden", und damit ist Idempotenz (`rules.md` Abschnitt 3) erfüllt, ohne dass das Schema etwas dafür tun muss. Ein wiederkehrender maschineller Abgleich existiert in keine Richtung: nach ASV-BW gehen nur Neuanlagen per CSV, die Bankverbindung wandert einmal von Hand nach Optigem, Änderungen laufen in beiden Systemen manuell (`fachdomaenen.md` Abschnitt 4). Deshalb bewusst **kein** Quellsystem-Schlüssel an `children`/`persons`.

Was bleibt, ist eine Anforderung an die Import-Prozedur selbst, nicht ans Schema: `addresses` hat bewusst kein UNIQUE (der „nur für diese Person"-Split legt wertgleiche Zweitzeilen an), der Import muss deshalb vor jedem Insert über den vorhandenen Suchindex `(postal_code, street, house_number)` nachschlagen und eine bestehende Zeile wiederverwenden. Sonst bekommt jede Familie so viele Adresszeilen wie Mitglieder — genau der Zustand, den das gemeinsame Adressmodell verhindern soll.

Dublettenerkennung beim Import: Nachname + Geburtsdatum beim Kind, Vor- + Nachname bei Erziehungsberechtigten. Die E-Mail trägt dort nicht mehr (`domains/stammdaten.md`, „Geteilte Mailbox").

**Eine Quelle ist beim Import ausdrücklich nicht belastbar: die Warteliste.** Sie wird vom Sekretariat heute faktisch nicht gepflegt (`prozesse.md` Abschnitt 6) — Einträge können längst erledigt, abgesagt oder eingeschult sein. Sie ungeprüft zu übernehmen erzeugt einen Bestand, dem man den Verfall nicht ansieht, und die jährliche Fortschreibung zöge ihn danach still weiter. Vor dem Import einmal durch das Sekretariat bestätigen zu lassen oder mit Status „ungeprüft" zu übernehmen.

### Was am Putzdienst noch im Backend fehlt, nicht im Schema

Das Schema trägt Einzel-Freikauf und Straf-Aussetzung (`domains/putzdienst.md`). Zwei Dinge daneben sind bewusst nicht als Constraint gebaut und dürfen deshalb beim Implementieren nicht untergehen:

- **Die Frist des Einzel-Freikaufs** („nur vor dem Termindatum") ist eine Backend-Prüfung, weil das Datum an `cleaning_slots` hängt. Sie muss an derselben Stelle sitzen, die die Zahlung auslöst — sonst entsteht ein bezahlter Freikauf für einen bereits gelaufenen Termin.
- **Die enge Berechtigung** für Straf-Aussetzung und Pflicht-Erlass ist ein Spalten-GRANT plus Rollenwahl, kein Anwendungs-`if`. Auslösen dürfen beides Geschäftsführung und Schulleitung — eine Schreib- und keine Lesebeschränkung: Buchhaltung, Buchungsansicht und Solver lesen beide Stellen weiter, eng gelesen wird allein der Grund der Abweichung (`TODO.md`).
- **Freigekaufte Zuteilungen gehören nicht auf die Übertragungsliste der Anwesenheit:** `no_show` auf einer einzeln freigekauften Zeile wäre eine Strafe auf einem bezahlten Termin. Wie die Frist eine Bedingung über zwei Tabellen — die Übernahme der Papierliste muss sie ausnehmen.

### Was am Vertragsvorgang im Backend liegt, nicht im Schema

Der Tippfehler-Fall braucht nichts davon — dort wird in dieselbe Zeile neu erzeugt und die Unterschriften bleiben (`domains/anmeldung.md`, „Wenn mitten im Vorgang ein Fehler auffällt"). Beides greift nur, wenn der **Vertragstext** sich geändert hat und deshalb wirklich neu unterschrieben werden muss:

- **Das Räumen der alten Dokumentzeile ist ein Vorgang, kein Klickpfad.** Zustimmung → Signatur → Dokument → Datei in SharePoint hängen mit `ON DELETE RESTRICT` aneinander; wer beim Dokument anfängt, bricht mit einer Fremdschlüssel-Verletzung ab. Das gehört in **eine** Transaktion hinter einen Knopf. Sonst führt das Sekretariat den ersten Schritt aus, läuft beim zweiten in eine Fehlermeldung und lässt einen halb geräumten Bestand stehen — und Unfertiges bleibt an dieser Schule eher liegen, als dass jemand nachfragt (`fachdomaenen.md` Abschnitt 3).
- **Der zweite Signaturlink braucht eine Begründung.** Er sieht aus wie der erste; ohne einen Satz dazu wirkt er wie ein Systemfehler, und die Eltern unterschreiben nicht. Gehört in dieselbe Mailvorlage, die den Link erzeugt.

Unabhängig vom Textwechsel gehört ein Schritt an den Abschluss selbst: **die Signaturbilder abräumen, sobald `confirmation_sent_at` gesetzt wird** — Datei in SharePoint löschen, Kennung an der Signaturzeile leeren (`domains/anmeldung.md`, „Wo die Dateien liegen"). Vorher wird das Bild für die Neuerzeugung gebraucht, danach steckt es im PDF; bleibt es liegen, ist es eine zweite Kopie ohne Abnehmer, die kein Lösch-Job je anfasst, weil sein Anker die Frist des Dokuments ist.

## Für `wb-backend`

### Übertragung nach SQLAlchemy/Alembic: was Modelle nicht können

Tabellen, Spalten, PK/FK/UNIQUE, CHECKs, partielle Indizes und die Ausschluss-Constraints lassen sich als Modell ausdrücken. **Drei Dinge nicht:** die plpgsql-Funktion `set_row_audit()`, die 48 Trigger, die sie über die sieben Schemata anhängen, und die Spalten-GRANTs. Die gehören als `op.execute()` in die Initial-Migration.

Das ist kein Tipparbeits-, sondern ein Sicherheitsproblem: Alembics `--autogenerate` **sieht diese drei gar nicht**. Es meldet nicht, dass sie fehlen, und würde sie bei einem späteren Regenerieren stillschweigend aus der Migration lassen. Damit fiele genau das weg, worauf das Schema am stärksten baut — Audit-Trail und Art.-9-Schutz — ohne eine einzige Fehlermeldung.

Die Doppelung ist dafür überprüfbar statt riskant: die sieben Prüfskripte in `domains/` laufen gegen **jede** Datenbank, auch gegen die von Alembic gebaute. Kommen dort 66/66, 22/22, 60/60, 14/14, 11/11, 4/4 und 3/3 heraus, ist die Übertragung nachweislich treu. Das gehört als fester Schritt hinter die Initial-Migration, nicht als einmalige Sichtprüfung.

Danach führt `wb-backend` das Schema; die `.sql` in diesem Repo bleibt der Entwurf samt Begründungen und ist nicht mehr die Quelle der Wahrheit.

### Dependabot für die Base-Images einschalten

`.github/dependabot.yml` in `wb-backend` mit dem `docker`-Ecosystem auf `Dockerfile` und `docker-compose.yml` (PostgreSQL-, Caddy-, Python-Base-Image), monatliches Intervall passend zum Patch-Rhythmus aus `rules.md` Abschnitt 2. Reine Repo-Datei, kein Konto und kein Token nötig — Dependabot ist in GitHub eingebaut und muss nur in den Repo-Einstellungen aktiviert sein.

Das `pip`-Ecosystem bewusst **nicht** eintragen: es würde `requirements.txt` direkt anfassen, ohne `requirements.in` neu zu kompilieren, und damit die pip-tools-Kette umgehen (`rules.md` Abschnitt 3).

### Constraint-Namen: `naming_convention` vor dem ersten Modell setzen

`MetaData(naming_convention=...)` in SQLAlchemy vergibt jedem Constraint einen deterministischen Namen aus einer Vorlage. Ohne sie benennt Alembic autogenerierte Constraints unvorhersehbar, und eine spätere Migration kann sie nicht sicher per `ALTER TABLE ... DROP CONSTRAINT` greifen — genau der Fall „im laufenden Betrieb anfassen". Muss stehen, **bevor** das erste Modell entsteht, sonst tragen die früh erzeugten Constraints andere Namen als alle späteren.

Im Entwurfsschema sind bereits die mehrspaltigen CHECKs, der Ausschluss-Constraint und die partiellen Unique-Indizes explizit benannt (`domains/stammdaten-schema.sql`); die Konvention muss diese Namen übernehmen, nicht überschreiben.


### Art.-9-Spalten-GRANT: Rollenwahl und ORM-Verhalten

- Sobald `backend_runtime` auf `children` kein `SELECT` auf `denomination_id`/`congregation` mehr hat, scheitert jedes Vollobjekt-Laden dieser Tabelle: SQLAlchemy selektiert per Default alle gemappten Spalten, `session.get(Child, id)` läuft in „permission denied for column". Lösung ist klein (`deferred()` auf dem Spaltenpaar oder zwei Mappings), muss aber vor dem ersten Modell dastehen — sonst wird sie unter Zeitdruck durch ein tabellenweites GRANT „gelöst" und der Mechanismus ist weg.
- Zweite, engere Rolle heißt: zweiter Pool oder `SET LOCAL ROLE` in derselben Transaktion, in der ohnehin `SET LOCAL app.actor` gesetzt wird. Letzteres ist der billigere Weg.
- `app.actor` muss ab jetzt ein Präfix tragen (`entra:`/`guardian:`/`system:`) — der Trigger weist alles andere ab. Betrifft den Schreibpfad für interne Nutzer: dort stand bisher die nackte Entra-Object-ID.
