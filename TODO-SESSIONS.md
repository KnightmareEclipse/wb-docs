# TODO — Offene Punkte für Entwicklungs-Sessions

Fachliche und technische Punkte, die eine Session in diesem Repo oder in `wb-backend` abarbeiten kann — im Unterschied zu `TODO.md`, das reale Konten, Zugänge und organisatorische Vorbereitungen sammelt. Sortiert nach Dringlichkeit.

## In diesem Repo

### Die beiden offenen Soll-Blöcke

**17 Lösch-Lauf** (was verschwindet wann, in welcher Reihenfolge) und **18 DSGVO-Auskunft** (wer bekommt was, in welcher Frist) — `prompts/block-fuellen.md`. Kein Nachzügler, sondern Voraussetzung: Jede Tabelle mit Personenbezug nennt im Schema ihren Löschanker, und viele davon zeigen auf einen Lauf, den bisher nur die Anker beschreiben. Solange Block 17 fehlt, ist die Frist selbst nirgends festgelegt.

Aus beiden Blöcken folgt danach ein Schema-Durchgang (`prompts/schema-bauen.md`) — wahrscheinlich ohne eigene Tabellen, aber das ist das Ergebnis der Domäne und keine Annahme.

## Vor dem ersten Import echter Daten

### Wie die Anmeldeformulare Kinder nicht doppelt anlegen

Ein Formular je Vorgang, zwei Einstiege — nicht zwei Formulare. Identisch sind Programm bzw. Zielklassenstufe, Betreuungsmodul, Zustimmungen und Zahlung; unterschiedlich ist allein der Identitätsblock: bekannte Adresse → Kind aus der Auswahlliste, Erziehungsberechtigte und Anschrift vorbelegt (Korrekturen laufen über den Eltern-Selfservice, nicht über ein Anmeldeformular); unbekannte → dieselben Felder leer, die Zeilen entstehen daraus. Gedoppelt werden dürfen die Feldlisten nicht, sonst läuft eine der beiden Fassungen still hinterher.

Welcher Einstieg gilt, entscheidet der OTP-Fluss, der jedem Vorgang vorausgeht (`idea/04-identitaet-zugriff.md`) — der Absender wählt ihn nicht. Das ist der Kern der Dublettenvermeidung: der Regelfall ist eine **Auswahl**, kein Abgleich. Für Wiederkehrer gilt das auch dann, wenn sie schulfremd sind, denn auch ein Ferienprogramm-Kind bekommt eine Familie (`schema/stammdaten-schema.sql`).

Verstärkt wird das über den Einstiegspunkt: Die Ankündigung des Ferienprogramms geht als Mail mit Link an die in Stammdaten hinterlegten Adressen, nicht als Verweis auf die Website. Der Link ist **je Empfänger personalisiert**, nicht einer für alle — das System erzeugt die Mails ohnehin einzeln, und ein generischer Link führte auf ein leeres Adressfeld und damit zurück in den Irrtum, den er verhindern soll. **Anmelden tut er nicht** — er trägt die Adresse, an die er ging, füllt damit das Adressfeld und löst den Code aus, den der Elternteil wie sonst auch eingibt. Weil er nichts freischaltet, braucht er auch keinen Token-Speicher und keine Gültigkeitsdauer: die Adresse steht als Parameter in der URL. Sie liegt unterwegs im TLS-verschlüsselten Teil und ist nur auf dem Gerät des Empfängers sichtbar, dem sie ohnehin gehört — **mitschreiben darf der Reverse-Proxy die Query dieser Route aber nicht** (die `log`-Zeile in `wb-backend/caddy/Caddyfile` trägt den Hinweis, dass sie dafür einen `format filter` braucht, sobald es die Route gibt), sonst steht die Adresse in einem Bestand mit anderer Aufbewahrung und anderem Leserkreis als die Datenbank (`idea/03-container-anwendung.md`, Zentrales Logging). Zwei Wirkungen, beide wichtiger als der gesparte Schritt: Der Elternteil muss sich nicht erinnern, unter welcher seiner Adressen er vor drei Jahren gebucht hat — genau der Irrtum, aus dem der Dublettenfall unten entsteht, und für jede erreichbare Familie damit erledigt. Und eine weitergeleitete Ankündigung („schau mal, Ferienprogramm!") nützt dem Empfänger nichts, weil der Code an das ursprüngliche Postfach geht.

Ein selbst authentifizierender Link wäre der kürzere Weg, ist hier aber falsch: Weiterleiten ist bei solchen Mails der Normalfall, und der Empfänger bekäme Lesezugriff auf eine fremde Familie. Das ist eine andere Klasse als die bewusst akzeptierte geteilte Elternmailbox (`idea/04-identitaet-zugriff.md`) — die wirkt innerhalb einer Familie, diese über Familiengrenzen hinweg.

Übrig bleibt der Elternteil, der ein anderes Postfach benutzt als das hinterlegte — der Fall bricht nicht ab, sondern gelingt auf dem falschen Weg: Code kommt, Formular öffnet sich, Anmeldung geht durch, nur eben als Fremder mit neuem Kind. Das leere Formular fragt deshalb vor dem Absenden einmal, ob das Kind schon einmal an der Schule oder im Ferienprogramm war, und rät bei „ja" zur Adresse von damals. Das ist eine Frage und keine Auskunft — wer die Antwort nicht ohnehin kennt, erfährt daraus nichts — und sie erreicht genau den, der es selbst am besten weiß. Dafür der Kandidatenabgleich Nachname + Geburtsdatum — mit zwei Regeln: **nie automatisch verknüpfen** und **das Ergebnis nie an den Absender**. Verknüpfte der anonyme Pfad selbsttätig, bekäme jeder, der Name und Geburtsdatum eines echten Schulkindes kennt — beides steht auf jeder Klassenliste —, eine Erziehungsberechtigten-Zeile in dessen Familie und damit Zugriff auf dessen Daten. Der Hinweis gehört deshalb als Feld an die Bewerbung bzw. die Buchung, die das Sekretariat ohnehin sichtet, samt Knopf zum Verknüpfen — **keine eigene Dublettenliste**: eine Liste, die zusätzlich geöffnet werden muss, wird nicht geöffnet (`fachdomaenen.md` Abschnitt 3). Der Fall schrumpft von selbst, weil auch die abweichende Adresse nach der ersten Anmeldung bekannt ist.

Zwei Punkte sind beim Entwurf zu entscheiden: ob die Personenzeilen **vor oder nach** der Zahlungsbestätigung entstehen — davor sammelt jeder Zahlungsabbruch Personendaten ohne Vorgang, danach muss das Formular seinen Inhalt zwischenparken. Und welche Löschfrist eine nie zur Aufnahme geführte Fremdanmeldung mitbringt: die Bewerbung hat eine eigene, kürzere, die mit ihr angelegten Personenzeilen brauchen dieselbe, sonst wächst Stammdaten mit Leuten, die nie an der Schule waren.

### Import-Prozedur: Nachschlagen statt blind einfügen

Der Vollimport läuft **einmal in eine leere Datenbank**; ein Korrekturlauf heißt „verwerfen und neu laden", und damit ist Idempotenz (`rules.md` Abschnitt 3) erfüllt, ohne dass das Schema etwas dafür tun muss. Ein wiederkehrender maschineller Abgleich existiert in keine Richtung: nach ASV-BW gehen nur Neuanlagen per CSV, die Bankverbindung wandert einmal von Hand nach Optigem, Änderungen laufen in beiden Systemen manuell (`fachdomaenen.md` Abschnitt 4). Deshalb bewusst **kein** Quellsystem-Schlüssel an `children`/`persons`.

Was bleibt, ist eine Anforderung an die Import-Prozedur selbst, nicht ans Schema: `addresses` hat bewusst kein UNIQUE (der „nur für diese Person"-Split legt wertgleiche Zweitzeilen an), der Import muss deshalb vor jedem Insert über den vorhandenen Suchindex `(postal_code, street, house_number)` nachschlagen und eine bestehende Zeile wiederverwenden. Sonst bekommt jede Familie so viele Adresszeilen wie Mitglieder — genau der Zustand, den das gemeinsame Adressmodell verhindern soll.

Dublettenerkennung beim Import: Nachname + Geburtsdatum beim Kind, Vor- + Nachname bei Erziehungsberechtigten. Die E-Mail trägt dort nicht mehr (`schema/stammdaten-schema.sql`).

**Eine Quelle ist beim Import ausdrücklich nicht belastbar: die Warteliste.** Sie wird vom Sekretariat heute faktisch nicht gepflegt (`prozesse.md` Abschnitt 6) — Einträge können längst erledigt, abgesagt oder eingeschult sein. Sie ungeprüft zu übernehmen erzeugt einen Bestand, dem man den Verfall nicht ansieht, und die jährliche Fortschreibung zöge ihn danach still weiter. Vor dem Import einmal durch das Sekretariat bestätigen zu lassen oder mit Status „ungeprüft" zu übernehmen.

### Die bestehenden Klassen sind ein eigener Importschritt

Der Vollimport bringt Kinder, aber keine Klassen. Jede bestehende Klasse wird mit ihrer
**rückgerechneten Kohorten-Kennung** angelegt: Eine Klasse, die im Importjahr in Stufe 3 steht, ist
`GS` mit Startschuljahr zwei Jahre davor. Das ist ableitbar und keine Frage an die Schule — aber
ohne diesen Schritt hat kein Kind eine Klasse, und Klassenliste, Aktenordner und M365-Gruppe hängen
daran (`soll-prozesse/15-klassenbildung.md`, `soll-prozesse/README.md`).

### Was am Putzdienst noch im Backend fehlt, nicht im Schema

Das Schema trägt Einzel-Freikauf und Straf-Aussetzung (`schema/putzdienst-schema.sql`). Zwei Dinge daneben sind bewusst nicht als Constraint gebaut und dürfen deshalb beim Implementieren nicht untergehen:

- **Die Frist des Einzel-Freikaufs** („nur vor dem Termindatum") ist eine Backend-Prüfung, weil das Datum an `cleaning_slots` hängt. Sie muss an derselben Stelle sitzen, die die Zahlung auslöst — sonst entsteht ein bezahlter Freikauf für einen bereits gelaufenen Termin.
- **Die enge Berechtigung** für Straf-Aussetzung und Pflicht-Erlass ist ein Spalten-GRANT plus Rollenwahl, kein Anwendungs-`if`. Auslösen dürfen beides Geschäftsführung und Schulleitung — eine Schreib- und keine Lesebeschränkung: Buchhaltung, Buchungsansicht und Solver lesen beide Stellen weiter, eng gelesen wird allein der Grund der Abweichung.
- **Freigekaufte Zuteilungen gehören nicht auf die Übertragungsliste der Anwesenheit:** `no_show` auf einer einzeln freigekauften Zeile wäre eine Strafe auf einem bezahlten Termin. Wie die Frist eine Bedingung über zwei Tabellen — die Übernahme der Papierliste muss sie ausnehmen.

### Was am Vertragsvorgang im Backend liegt, nicht im Schema

Der Tippfehler-Fall braucht nichts davon — dort wird in dieselbe Zeile neu erzeugt und die Unterschriften bleiben (`schema/anmeldung-schema.sql`). Beides greift nur, wenn der **Vertragstext** sich geändert hat und deshalb wirklich neu unterschrieben werden muss:

- **Das Räumen der alten Dokumentzeile ist ein Vorgang, kein Klickpfad.** Zustimmung → Signatur → Dokument → Datei in SharePoint hängen mit `ON DELETE RESTRICT` aneinander; wer beim Dokument anfängt, bricht mit einer Fremdschlüssel-Verletzung ab. Das gehört in **eine** Transaktion hinter einen Knopf. Sonst führt das Sekretariat den ersten Schritt aus, läuft beim zweiten in eine Fehlermeldung und lässt einen halb geräumten Bestand stehen — und Unfertiges bleibt an dieser Schule eher liegen, als dass jemand nachfragt (`fachdomaenen.md` Abschnitt 3).
- **Der zweite Signaturlink braucht eine Begründung.** Er sieht aus wie der erste; ohne einen Satz dazu wirkt er wie ein Systemfehler, und die Eltern unterschreiben nicht. Gehört in dieselbe Mailvorlage, die den Link erzeugt.

Unabhängig vom Textwechsel gehört ein Schritt an den Abschluss selbst: **die Signaturbilder abräumen, sobald der Vertrag freigegeben ist (`contracts.released_at`)** — Datei in SharePoint löschen, Kennung an der Signaturzeile leeren (`schema/anmeldung-schema.sql`). Vorher wird das Bild für die Neuerzeugung gebraucht, danach steckt es im PDF; bleibt es liegen, ist es eine zweite Kopie ohne Abnehmer, die kein Lösch-Job je anfasst, weil sein Anker die Frist des Dokuments ist.

## Für `wb-backend`

### Übertragung nach SQLAlchemy/Alembic: was Modelle nicht können

Tabellen, Spalten, PK/FK/UNIQUE, CHECKs, partielle Indizes und die Ausschluss-Constraints lassen sich als Modell ausdrücken. Die drei Ausschlüsse brauchen `btree_gist` (`=` auf einem Skalar zusammen mit `&&` auf einer Range); die Extension legt inzwischen `db/init-roles.sh` als Superuser an, weil `CREATE EXTENSION` das Recht `CREATE` auf der Datenbank verlangt und der Migrator damit auch Schemata anlegen könnte — gemessen: sein eigenes `CREATE EXTENSION IF NOT EXISTS btree_gist` läuft danach als No-op durch, die Zeile aus der `.sql` kann also wörtlich mit. **Zwei Dinge nicht:** die Spalten-GRANTs für den Art.-9-Bestand und die enger geschnittenen DB-Rollen (Liste unten). Die gehören als `op.execute()` in die Migration der Domäne, die sie braucht.

Das ist kein Tipparbeits-, sondern ein Sicherheitsproblem: Alembics `--autogenerate` **sieht sie gar nicht**. Es meldet nicht, dass sie fehlen, und würde sie bei einem späteren Regenerieren stillschweigend aus der Migration lassen — ohne eine einzige Fehlermeldung fiele genau der Art.-9-Schutz weg.

**Die Änderungsspur ist der zweite Fall dieser Art, und der gefährlichere.** `change_log` wird von der **Anwendung** geschrieben, nicht von einem Datenbank-Trigger — bewusst so, weil eine Regel, die nur in der Datenbank lebt, im Code unsichtbar ist (Kopfkommentar in `schema/querschnitt-schema.sql`). Folge: Jeder Schreibpfad, der eine Tabelle dieses Modells ändert, muss die Spur selbst schreiben; wird das an einer Stelle vergessen, fehlt sie dort lautlos, und nichts in der Datenbank meldet es. Die Absicherung ist deshalb eine **gemeinsame Schreibschicht in `wb-backend`, durch die jede Änderung läuft** — kein Punkt, den man nachträglich einzieht. `changed_by` trägt dabei ein Präfix (`entra:`/`guardian:`/`system:`), das ein CHECK erzwingt.

Die Doppelung Schema ↔ Modell ist überprüfbar statt riskant: Alle vierzehn Prüfskripte in `schema/` laufen gegen **jede** Datenbank, auch gegen die von Alembic gebaute. Kommt dort je Skript der Sollstand aus seinem Kopfkommentar heraus, ist die Übertragung nachweislich treu. Das gehört als fester Schritt hinter jeden Migrationslauf, nicht als einmalige Sichtprüfung.

Danach führt `wb-backend` das Schema; die `.sql` hier bleibt die Begründungsquelle und ist nicht mehr die Quelle der Wahrheit.

### Constraint-Namen: `naming_convention` steht

Gesetzt in `wb-backend/app/db/base.py`, vor dem ersten Modell — damit die früh erzeugten Constraints dieselben Namen tragen wie alle späteren und eine spätere Migration sie per `ALTER TABLE ... DROP CONSTRAINT` sicher greifen kann.

**Die Vorlagen enthalten bewusst kein `%(constraint_name)s`.** Mit diesem Platzhalter behandelt SQLAlchemy einen ausdrücklich gesetzten Namen als Fragment und baut ihn in die Vorlage ein; ohne ihn greift die Konvention nur dort, wo ein Constraint gar keinen Namen hat. Genau das ist nötig, damit ein Modell den Namen aus `schema/*.sql` **wörtlich** übernehmen kann — ausgezählt sind dort 99 `pk_`, 160 `fk_`, 88 `uq_`, 270 `ck_`, 3 `ex_` und 30 `ix_`, und **jedes einzelne davon trägt seinen Namen ausgeschrieben** — die Vorlage fängt im ganzen Schema nichts mehr auf, sie ist reiner Auffang für ein künftig unbenanntes Constraint. Ableitbar aus Tabelle und Spalte wäre allein der Primärschlüssel; `fk_documents_type` aus `document_type_id` und `uq_care_module_prices` ganz ohne Spaltensuffix sind es nicht. Eine Vorlage mit Platzhalter würde das halbe Schema umbenennen.

Die Vorlagen sind damit der Auffang für alles Unbenannte, nicht die Quelle der Namen. Beim Übertragen gilt deshalb: **Namen aus der `.sql` wörtlich ins Modell**, dann liest der Handabgleich beide Seiten als denselben String. `wb-backend/tests/test_naming_convention.py` prüft beide Hälften mit echten Namen aus dem Schema; gegengeprüft ist auch der Weg durch `--autogenerate`.

### Art.-9-Spalten-GRANT: Rollenwahl und ORM-Verhalten

- Sobald `backend_runtime` auf `children` kein `SELECT` auf `denomination_id`/`congregation` mehr hat, scheitert jedes Vollobjekt-Laden dieser Tabelle: SQLAlchemy selektiert per Default alle gemappten Spalten, `session.get(Child, id)` läuft in „permission denied for column". Lösung ist klein (`deferred()` auf dem Spaltenpaar oder zwei Mappings), muss aber vor dem ersten Modell dastehen — sonst wird sie unter Zeitdruck durch ein tabellenweites GRANT „gelöst" und der Mechanismus ist weg.
- Die engere Rolle wird per `SET LOCAL ROLE` in derselben Transaktion gewählt, in der ohnehin `SET LOCAL app.actor` gesetzt wird — kein zweiter Pool. Sie ist `NOLOGIN` und hat kein Passwort; der `GRANT` an `backend_runtime` trägt **`WITH INHERIT FALSE, SET TRUE`**. Ohne `INHERIT FALSE` hält `backend_runtime` die Rechte schlicht selbst, und der Mechanismus ist weg — beides gegen Postgres 18 gegengeprüft, samt der Gegenkontrolle. Zwei Rollen trägt `stammdaten`: `backend_sensitive` (Konfession) und `backend_finance` (`sepa_mandates.iban`/`bic`), jede weitere kommt mit ihrer Domäne.
- **Vier Mechaniken, an Postgres 18 gemessen — sie bestimmen, wie die Migration aussehen muss.** Ein tabellenweites Recht schlägt jedes Spalten-GRANT daneben; das Spalten-GRANT allein bewirkt also nichts. `REVOKE SELECT ON t FROM rolle` nimmt die Spalten-Grants derselben Art mit — in der Migration steht deshalb erst der `REVOKE`, dann die Spaltenliste, nie umgekehrt. Ein `GENERATED AS IDENTITY`-Schlüssel braucht kein Sequenz-Privileg, ein `serial` schon (das Schema hat 47 mal Identity und kein `serial`). Und ein `SELECT *` ohne Tabellenrecht scheitert mit „permission denied for table", nicht spaltenweise — genau der Fall, für den das `deferred()` oben dasteht.
- **`backend_runtime` bekommt keine Default-Privilegien mehr.** `db/init-roles.sh` in `wb-backend` vergab bis zum Gerüst-Durchgang tabellenweit `SELECT, INSERT, UPDATE, DELETE` auf jede künftige Tabelle — beides, was `idea/03-container-anwendung.md` ausschließt: das tabellenweite `UPDATE` und die stillschweigende Aufnahme jeder neuen Spalte. Die Rolle startet jetzt ohne jedes Tabellenrecht, und jede Domänen-Migration vergibt, was ihre Tabellen brauchen. Das ist Mehrarbeit je Tabelle und der Preis dafür, dass ein vergessenes Recht als „permission denied" auffällt statt als offene Tür.
- **Durchgesetzt wird es von `wb-backend/tests/test_privileges.py`**, nicht von der Handprüfung: die drei Bedingungen aus `idea/03-container-anwendung.md` als Abfragen über den Katalog — keine Tabelle im Eigentum der Laufzeit-Rolle, nirgends ein tabellenweites `UPDATE` für sie, und kein tabellenweites Recht dort, wo eine enge Rolle dieselbe Rechteart hält. Die dritte vergleicht je Rechteart und nicht je Tabelle, damit der Putzdienst-Fall (eng nur schreibend, Laufzeit liest weiter) nicht fälschlich anschlägt. Keine gepflegte Spaltenliste dahinter — die veraltet, und eine fehlende Zeile wäre wieder unsichtbar. Weder `--autogenerate` noch die Prüfskripte in `schema/` sehen Privilegien überhaupt an.
- `app.actor` muss ab jetzt ein Präfix tragen (`entra:`/`guardian:`/`system:`) — der CHECK je Tabelle weist alles andere ab. Betrifft den Schreibpfad für interne Nutzer: dort stand bisher die nackte Entra-Object-ID.

Welche Spalte welche Rolle bekommt — die Liste ist mit den zuletzt gebauten Domänen gewachsen, jeder Eintrag ist die Rolle **einer** Domäne und entsteht in deren Migration:

- Konfession als Art.-9-Spalten: `children.denomination_id`/`congregation` **und** `family_guardians.denomination_id` (`schema/stammdaten-schema.sql`)
- Bankverbindung: `sepa_mandates.iban`/`bic`, nur Buchhaltung — sie überträgt sie einmal nach Optigem (`schema/stammdaten-schema.sql`, `glossar.md`)
- Gesundheitsmerkmale, **zweistufig**: voller Satz für Verwaltung, Klassenlehrer:in und Hort gegen `child_health_records.action_note` für alle unterrichtenden Personen — die Laufzeit-Rolle darf auf `health_traits` kein tabellenweites `SELECT`/`UPDATE` bekommen. Schreibend ist der Hinweis enger als lesend: `UPDATE (action_note)` auf `child_health_records` bekommt allein die Klassenlehrer:in, die ihn formuliert (`schema/gesundheit-schema.sql`, `glossar.md`)
- Niveau-Einschätzung der Bewerbung: `applications.assessed_level_id`, standardmäßig nicht breit sichtbar (`schema/anmeldung-schema.sql`). Das konsolidierte Bewertungsergebnis, einen Rang und eine Notiz gibt es nicht — Block 07 schließt alle drei aus, auch als stillgelegtes Feld
- Küchenprofil: eigene Rolle für Küche/Hausdienstverwaltung auf `child_meal_profiles` (`schema/mensa-schema.sql`). Das ist nur die **Variante** — die Unverträglichkeit auf der Tagesliste kommt aus `health_traits` über das Kennzeichen `health_trait_types.is_kitchen_relevant` und ist damit ein Art.-9-Zugriff, kein Mensa-Zugriff (`schema/gesundheit-schema.sql`)
- Straf-Aussetzung und Pflicht-Erlass: als Einziger dieser Liste eine **Schreib**beschränkung — `UPDATE` auf `cleaning_assignments.penalty_waived_at`/`penalty_waived_by` und Schreibzugriff auf `cleaning_family_quotas` nur für Geschäftsführung und Schulleitung. Gelesen werden beide weiter von der Laufzeit-Rolle: die Buchhaltung erkennt an `penalty_waived_at` die entfallende Forderung (`grenzkarte.md`, Q3), Buchungsansicht und Solver brauchen `required_count` — sonst sieht eine erlassene Familie die Standardpflicht. **Eine Lesebeschränkung entfällt:** einen Grund der Abweichung führt das Schema bewusst nicht, „der Grund liegt außerhalb" (`schema/putzdienst-schema.sql`)

### Dependabot für die Base-Images einschalten

`.github/dependabot.yml` in `wb-backend` mit dem `docker`-Ecosystem auf `Dockerfile`, `caddy/Dockerfile` und `docker-compose.yml` (PostgreSQL-, Caddy-, Python-Base-Image — das Caddy-Image liegt seit dem Gerüst-Durchgang hinter einer eigenen dünnen Dockerfile, weil das offizielle als Root läuft), monatliches Intervall passend zum Patch-Rhythmus aus `rules.md` Abschnitt 2. Reine Repo-Datei, kein Konto und kein Token nötig — Dependabot ist in GitHub eingebaut und muss nur in den Repo-Einstellungen aktiviert sein.

Das `pip`-Ecosystem bewusst **nicht** eintragen: es würde `requirements.txt` direkt anfassen, ohne `requirements.in` neu zu kompilieren, und damit die pip-tools-Kette umgehen (`rules.md` Abschnitt 3).
