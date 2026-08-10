# TODO — Offene Punkte für Entwicklungs-Sessions

Fachliche/technische Punkte, die eine Session in diesem Repo oder in `wb-backend` abarbeiten kann — im Unterschied zu `TODO.md`, das reale Konten/Zugänge und organisatorische Vorbereitungen sammelt. Sortiert nach Dringlichkeit.

## Vor dem ersten Import echter Daten

### Nächste Fachdomäne: Voranmeldung / Anmeldeprozess (2/4)

Als drittes Domänenschema zu bauen, nach Stammdaten und Putzdienst — Entitäten und Grenzen stehen bereits in `domains/grenzkarte.md` („Bewerbung (2/4)" bis „Zwei Bemerkungen"), es fehlen nur die Spalten. Ergebnis wie bei den beiden gebauten: `…-schema.sql` samt Prüfskript und `.md`, danach `grenzkarte.md` nachziehen.

**Sie erweitert Stammdaten nicht, sie hängt sich an.** „Schreibt Stammdaten: ja (viel)" in der Grenzkarte meint Datenverkehr — Zeilen anlegen und ändern —, nicht neue Spalten: die Bewerbung *zeigt* auf `children` und `families`, statt Personendaten zu kopieren, und was sie darüber hinaus braucht (Kindergarten, Geschwister-Selbstauskunft, Betreuungsmodul, Bewertung), sind eigene Entitäten der Domäne. Auch die eine offene Zuschnitt-Frage — ob externe Bewerber ihre Personenzeile schon bei der Voranmeldung bekommen oder erst bei der Aufnahme — ist ohne Rückwirkung auf Stammdaten (`domains/stammdaten.md`).

Der Freeze Ende August 2026 ist damit **kein** Termin für diese Domäne. Was tatsächlich davon abhängt, ist die Schema-Durchsicht des Betreibers: sie läuft erst, wenn die Voranmeldung im Schema steht, damit derselbe Stammdatensatz nicht zweimal geprüft wird.

Drei Berührungen mit Gebautem sind vorab bekannt: **Q3 öffnen** — die Voranmeldegebühr ist der zweite Stripe-Anlass und kommt als weitere Vorgangs-Spalte samt erweitertem Entweder-oder-CHECK an `payments` dazu, nicht als zweite Zahlungstabelle. **Kindergarten** bekommt eine eigene Werteliste in dieser Domäne, nicht in `previous_schools` — die trägt die staatlichen Überweisungspartner, ein Kindergarten darin verschöbe die Bedeutung einer bestehenden Spalte. **Q1 und Q2** (Zustimmung, Dokument/Signatur) hängen am Schulvertrag der dritten Phase; ob sie mit dieser Domäne entstehen oder danach, ist zu entscheiden, bevor die Vertragsphase modelliert wird.

Vor dem Entwurf mit dem Sekretariat zu bestätigen (`domains/grenzkarte.md`): ob Grundschulempfehlung und Niveau zwei Angaben sind oder zwei Namen für dieselbe.

### Wie die Anmeldeformulare Kinder nicht doppelt anlegen

Ein Formular je Vorgang, zwei Einstiege — nicht zwei Formulare. Identisch sind Programm bzw. Zielklassenstufe, Betreuungsmodul, Zustimmungen und Zahlung; unterschiedlich ist allein der Identitätsblock: bekannte Adresse → Kind aus der Auswahlliste, Erziehungsberechtigte und Anschrift vorbelegt (Korrekturen laufen über den Eltern-Selfservice, nicht über ein Anmeldeformular); unbekannte → dieselben Felder leer, die Zeilen entstehen daraus. Gedoppelt werden dürfen die Feldlisten nicht, sonst läuft eine der beiden Fassungen still hinterher.

Welcher Einstieg gilt, entscheidet der OTP-Fluss, der jedem Vorgang vorausgeht (`idea/04-identitaet-zugriff.md`) — der Absender wählt ihn nicht. Das ist der Kern der Dublettenvermeidung: der Regelfall ist eine **Auswahl**, kein Abgleich. Für Wiederkehrer gilt das auch dann, wenn sie schulfremd sind, denn auch ein Ferienprogramm-Kind bekommt eine Familie (`domains/stammdaten.md`).

Verstärkt wird das über den Einstiegspunkt: Die Ankündigung des Ferienprogramms geht als Mail mit Link an die in Stammdaten hinterlegten Adressen, nicht als Verweis auf die Website. Der Link ist **je Empfänger personalisiert**, nicht einer für alle — das System erzeugt die Mails ohnehin einzeln, und ein generischer Link führte auf ein leeres Adressfeld und damit zurück in den Irrtum, den er verhindern soll. **Anmelden tut er nicht** — er trägt die Adresse, an die er ging, füllt damit das Adressfeld und löst den Code aus, den der Elternteil wie sonst auch eingibt. Zwei Wirkungen, beide wichtiger als der gesparte Schritt: Der Elternteil muss sich nicht erinnern, unter welcher seiner Adressen er vor drei Jahren gebucht hat — genau der Irrtum, aus dem der Dublettenfall unten entsteht, und für jede erreichbare Familie damit erledigt. Und eine weitergeleitete Ankündigung („schau mal, Ferienprogramm!") nützt dem Empfänger nichts, weil der Code an das ursprüngliche Postfach geht.

Ein selbst authentifizierender Link wäre der kürzere Weg, ist hier aber falsch: Weiterleiten ist bei solchen Mails der Normalfall, und der Empfänger bekäme Lesezugriff auf eine fremde Familie. Das ist eine andere Klasse als die bewusst akzeptierte geteilte Elternmailbox (`idea/04-identitaet-zugriff.md`) — die wirkt innerhalb einer Familie, diese über Familiengrenzen hinweg.

Übrig bleibt der Elternteil, der ein anderes Postfach benutzt als das hinterlegte — der Fall bricht nicht ab, sondern gelingt auf dem falschen Weg: Code kommt, Formular öffnet sich, Anmeldung geht durch, nur eben als Fremder mit neuem Kind. Das leere Formular fragt deshalb vor dem Absenden einmal, ob das Kind schon einmal an der Schule oder im Ferienprogramm war, und rät bei „ja" zur Adresse von damals. Das ist eine Frage und keine Auskunft — wer die Antwort nicht ohnehin kennt, erfährt daraus nichts — und sie erreicht genau den, der es selbst am besten weiß. Dafür der Kandidatenabgleich Nachname + Geburtsdatum — mit zwei Regeln: **nie automatisch verknüpfen** und **das Ergebnis nie an den Absender**. Verknüpfte der anonyme Pfad selbsttätig, bekäme jeder, der Name und Geburtsdatum eines echten Schulkindes kennt — beides steht auf jeder Klassenliste —, eine Erziehungsberechtigten-Zeile in dessen Familie und damit Zugriff auf dessen Daten. Der Hinweis gehört deshalb als Feld an die Bewerbung bzw. die Buchung, die das Sekretariat ohnehin sichtet, samt Knopf zum Verknüpfen — **keine eigene Dublettenliste**: eine Liste, die zusätzlich geöffnet werden muss, wird nicht geöffnet (`fachdomaenen.md` Abschnitt 3). Der Fall schrumpft von selbst, weil auch die abweichende Adresse nach der ersten Anmeldung bekannt ist.

Zwei Punkte sind beim Entwurf zu entscheiden: ob die Personenzeilen **vor oder nach** der Zahlungsbestätigung entstehen — davor sammelt jeder Zahlungsabbruch Personendaten ohne Vorgang, danach muss das Formular seinen Inhalt zwischenparken. Und welche Löschfrist eine nie zur Aufnahme geführte Fremdanmeldung mitbringt: die Bewerbung hat eine eigene, kürzere, die mit ihr angelegten Personenzeilen brauchen dieselbe, sonst wächst Stammdaten mit Leuten, die nie an der Schule waren.

### Import-Prozedur: Nachschlagen statt blind einfügen

Der Vollimport läuft **einmal in eine leere Datenbank**; ein Korrekturlauf heißt „verwerfen und neu laden", und damit ist Idempotenz (`rules.md` Abschnitt 3) erfüllt, ohne dass das Schema etwas dafür tun muss. Ein wiederkehrender maschineller Abgleich existiert in keine Richtung: nach ASV-BW gehen nur Neuanlagen per CSV, die Bankverbindung wandert einmal von Hand nach Optigem, Änderungen laufen in beiden Systemen manuell (`fachdomaenen.md` Abschnitt 4). Deshalb bewusst **kein** Quellsystem-Schlüssel an `children`/`persons`.

Was bleibt, ist eine Anforderung an die Import-Prozedur selbst, nicht ans Schema: `addresses` hat bewusst kein UNIQUE (der „nur für diese Person"-Split legt wertgleiche Zweitzeilen an), der Import muss deshalb vor jedem Insert über den vorhandenen Suchindex `(postal_code, street, house_number)` nachschlagen und eine bestehende Zeile wiederverwenden. Sonst bekommt jede Familie so viele Adresszeilen wie Mitglieder — genau der Zustand, den das gemeinsame Adressmodell verhindern soll.

Dublettenerkennung beim Import: Nachname + Geburtsdatum beim Kind, Vor- + Nachname bei Erziehungsberechtigten. Die E-Mail trägt dort nicht mehr (`domains/stammdaten.md`, „Geteilte Mailbox").

## Für `wb-backend`

### Übertragung nach SQLAlchemy/Alembic: was Modelle nicht können

Tabellen, Spalten, PK/FK/UNIQUE, CHECKs, partielle Indizes und der Ausschluss-Constraint lassen sich als Modell ausdrücken. **Drei Dinge nicht:** die plpgsql-Funktion `set_row_audit()`, die 16 Trigger, die sie anhängen, und die Spalten-GRANTs. Die gehören als `op.execute()` in die Initial-Migration.

Das ist kein Tipparbeits-, sondern ein Sicherheitsproblem: Alembics `--autogenerate` **sieht diese drei gar nicht**. Es meldet nicht, dass sie fehlen, und würde sie bei einem späteren Regenerieren stillschweigend aus der Migration lassen. Damit fiele genau das weg, worauf das Schema am stärksten baut — Audit-Trail und Art.-9-Schutz — ohne eine einzige Fehlermeldung.

Die Doppelung ist dafür überprüfbar statt riskant: `domains/stammdaten-schema-check.sql` und `domains/putzdienst-schema-check.sql` laufen gegen **jede** Datenbank, auch gegen die von Alembic gebaute. Kommen dort 64/64 bzw. 17/17 heraus, ist die Übertragung nachweislich treu. Das gehört als fester Schritt hinter die Initial-Migration, nicht als einmalige Sichtprüfung.

Danach führt `wb-backend` das Schema; die `.sql` in diesem Repo bleibt der Entwurf samt Begründungen und ist nicht mehr die Quelle der Wahrheit.

### Constraint-Namen: `naming_convention` vor dem ersten Modell setzen

`MetaData(naming_convention=...)` in SQLAlchemy vergibt jedem Constraint einen deterministischen Namen aus einer Vorlage. Ohne sie benennt Alembic autogenerierte Constraints unvorhersehbar, und eine spätere Migration kann sie nicht sicher per `ALTER TABLE ... DROP CONSTRAINT` greifen — genau der Fall „im laufenden Betrieb anfassen". Muss stehen, **bevor** das erste Modell entsteht, sonst tragen die früh erzeugten Constraints andere Namen als alle späteren.

Im Entwurfsschema sind bereits die mehrspaltigen CHECKs, der Ausschluss-Constraint und die partiellen Unique-Indizes explizit benannt (`domains/stammdaten-schema.sql`); die Konvention muss diese Namen übernehmen, nicht überschreiben.


### Art.-9-Spalten-GRANT: Rollenwahl und ORM-Verhalten

- Sobald `backend_runtime` auf `children` kein `SELECT` auf `denomination_id`/`congregation` mehr hat, scheitert jedes Vollobjekt-Laden dieser Tabelle: SQLAlchemy selektiert per Default alle gemappten Spalten, `session.get(Child, id)` läuft in „permission denied for column". Lösung ist klein (`deferred()` auf dem Spaltenpaar oder zwei Mappings), muss aber vor dem ersten Modell dastehen — sonst wird sie unter Zeitdruck durch ein tabellenweites GRANT „gelöst" und der Mechanismus ist weg.
- Zweite, engere Rolle heißt: zweiter Pool oder `SET LOCAL ROLE` in derselben Transaktion, in der ohnehin `SET LOCAL app.actor` gesetzt wird. Letzteres ist der billigere Weg.
- `app.actor` muss ab jetzt ein Präfix tragen (`entra:`/`guardian:`/`system:`) — der Trigger weist alles andere ab. Betrifft den Schreibpfad für interne Nutzer: dort stand bisher die nackte Entra-Object-ID.
