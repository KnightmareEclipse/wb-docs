# TODO — Offene Punkte für Entwicklungs-Sessions

Fachliche und technische Punkte, die eine Session in diesem Repo oder in `wb-backend` abarbeiten kann — im Unterschied zu `TODO.md`, das reale Konten, Zugänge und organisatorische Vorbereitungen sammelt. Sortiert nach Dringlichkeit.

## In diesem Repo

### Die beiden offenen Soll-Blöcke

**17 Lösch-Lauf** (was verschwindet wann, in welcher Reihenfolge) und **18 DSGVO-Auskunft** (wer bekommt was, in welcher Frist) — `prompts/block-fuellen.md`. Kein Nachzügler, sondern Voraussetzung: Jede Tabelle mit Personenbezug nennt im Schema ihren Löschanker, und viele davon zeigen auf einen Lauf, den bisher nur die Anker beschreiben. Solange Block 17 fehlt, ist die Frist selbst nirgends festgelegt.

Zwei Punkte muss Block 17 zusätzlich entscheiden, beide seit der Übertragung nach `wb-backend` benannt und beide in Stufe 8 des Lösch-Laufs beschrieben (Kopf von `schema/querschnitt-schema.sql`): welche Frist für eine `change_log`-Zeile ohne Anker gilt — rund siebzig Tabellen erreichen ihren Löschanker nur über einen Join und geben der Spur deshalb keinen mit —, und welche Rolle sie löschen darf. `backend_runtime` liest und schreibt die Spur heute und löscht sie nicht, damit eine Änderungsspur nicht von der Anwendung tilgbar ist.

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

### Was die drei gemeinsamen Mechanismen noch brauchen

Gebaut sind inzwischen die Versandschicht (`wb-backend/app/services/mail.py`) und der Lauf-Dienst (`wb-backend/app/runs.py`), dessen Register die Fenster-offen-Mail und den Zuteilungslauf trägt (`wb-backend/app/services/cleaning.py`), dazu der `UNIQUE` auf `payments.payment_reference`. Was daran noch fehlt, sind vier Punkte — drei Schemaergänzungen, ein Lauf ohne Bauherrn und ein Secret:

- **Dem Putzdienst fehlen zwei Lauf-Marken** (`schema/putzdienst-schema.sql`). An `cleaning_cycles`: dass die Zuteilungsmail raus ist (Z6). An `cleaning_slots`: die zwei Erinnerungen je Termin (Z9). Beide hängen an der Freigabe der Zuteilung, die noch keine Route hat; die beiden gebauten Läufe tragen ihre (`registration_mail_sent_at`, `allocated_at`), und die des Monatslaufs steht im Schema bereit (`cleaning_assignments.penalty_handed_over_at`). **`allocation_released_at` ist für keine davon zu gebrauchen** — sie trägt die Freigabe durch das Sekretariat und nicht den Lauf. Welche Form die zwei bekommen, entscheidet der Bau des jeweiligen Laufs; eine Zustandsdatei neben der Datenbank ist keine davon.
- **Die Zahlung ohne Vorgang hat im Schema keinen Ort** — der Fall aus `api/gemeinsam.md`, vierte Festlegung: Das Geld ist da, die Bedingung trägt beim Rückruf nicht mehr. Drei Ergänzungen, alle drei mit der Domäne, die zuerst bezahlt: `ck_payments_single_cause` muss den vorgangslosen Fall zulassen (heute verlangt er genau einen der vier Schlüssel), `sync_tasks` braucht den Bezug auf die Zahlung als achten (heute ist keiner der sieben eine), und `sync_targets` braucht sein erstes **hausinternes** Ziel — dieselbe Lücke, die `api/putzdienst-api.md` schon für „Anwesenheitsliste drucken" benennt. Ohne sie kommt das Geld an und keine Zeile hält es fest.
- **Die 24 Stunden von `login_codes` haben keinen Bauherrn** (`schema/stammdaten-schema.sql` sagt sie zu, niemand führt sie aus), und die 30 Tage von `login_sessions` ebenso wenig. Beide gehören keiner Fachdomäne, entstehen also nicht mit einer — und Block 17 ist noch nicht geschrieben. Kein Platzproblem (gemessen 300 bzw. 319 Byte je Zeile), sondern ein Frist-Problem: Ohne den Lauf ist `login_codes` eine unbefristete Liste jeder Adresse, die je jemand ins Anmeldefeld getippt hat — genau das Sammelbecken, dessentwegen der Anmeldecode keine `outbound_emails`-Zeile bekommt.
- **Das Webhook-Secret des Zahlungsdienstes** ist eine Secret-Datei wie die anderen (`wb-backend/CLAUDE.md` Abschnitt 4), keine Umgebungsvariable mit dem Wert darin. Die Rückrufroute ist die einzige ohne Anmeldung; ihre Signaturprüfung ist damit die ganze Zugangskontrolle.

### Was am Vertragsvorgang im Backend liegt, nicht im Schema

Der Tippfehler-Fall braucht nichts davon — dort wird in dieselbe Zeile neu erzeugt und die Unterschriften bleiben (`schema/anmeldung-schema.sql`). Beides greift nur, wenn der **Vertragstext** sich geändert hat und deshalb wirklich neu unterschrieben werden muss:

- **Das Räumen der alten Dokumentzeile ist ein Vorgang, kein Klickpfad.** Zustimmung → Signatur → Dokument → Datei in SharePoint hängen mit `ON DELETE RESTRICT` aneinander; wer beim Dokument anfängt, bricht mit einer Fremdschlüssel-Verletzung ab. Das gehört in **eine** Transaktion hinter einen Knopf. Sonst führt das Sekretariat den ersten Schritt aus, läuft beim zweiten in eine Fehlermeldung und lässt einen halb geräumten Bestand stehen — und Unfertiges bleibt an dieser Schule eher liegen, als dass jemand nachfragt (`fachdomaenen.md` Abschnitt 3).
- **Der zweite Signaturlink braucht eine Begründung.** Er sieht aus wie der erste; ohne einen Satz dazu wirkt er wie ein Systemfehler, und die Eltern unterschreiben nicht. Gehört in dieselbe Mailvorlage, die den Link erzeugt.

Unabhängig vom Textwechsel gehört ein Schritt an den Abschluss selbst: **die Signaturbilder abräumen, sobald der Vertrag freigegeben ist (`contracts.released_at`)** — Datei in SharePoint löschen, Kennung an der Signaturzeile leeren (`schema/anmeldung-schema.sql`). Vorher wird das Bild für die Neuerzeugung gebraucht, danach steckt es im PDF; bleibt es liegen, ist es eine zweite Kopie ohne Abnehmer, die kein Lösch-Job je anfasst, weil sein Anker die Frist des Dokuments ist.

## Für `wb-backend`

### Die Freigabe der Zuteilung (01, Z5) und die Mail daran (Z6)

Der Zuteilungslauf steht; ohne Freigabe „erfährt keine Familie ihre Termine", der Zyklus bleibt also
an dieser Stelle stehen. Fünf Routen, alle im Abschnitt „Zuteilung" von `api/putzdienst-api.md`,
alle `secretariat`, keine enge Rolle:

- `GET /cleaning/cycles/{year}/allocation` — das Gesamtbild je Termin und je Familie, **samt der Termine, an denen die Platzzahl überschritten wurde**: Der Lauf darf sie überschreiten, und das Sekretariat entscheidet am Bild, ob es so trägt.
- `POST /cleaning/cycles/{year}/allocation/release` — setzt `allocation_released_at`, genau einmal. Die Datenbank verlangt vorher `allocated_at` (`ck_cleaning_cycles_release`); die Route antwortet selbst, statt in den Constraint zu laufen.
- `POST /cleaning/families/{family_id}/assignments` — von Hand zuteilen, `source = 'manual'`; die Familie bekommt ihre aktuelle Terminliste. Das ist der Weg, auf dem Quereinsteiger von ihren Terminen erfahren.
- `PATCH /cleaning/assignments/{assignment_id}` — verschieben: derselbe Zyklus, dieselbe Art, nicht nach `attendance_recorded_at`.
- `DELETE /cleaning/assignments/{assignment_id}` — streichen bzw. eine Reservierung freigeben; Eltern nur die eigene Familie, nur `source = 'reserved'`, nur im offenen Fenster, das Sekretariat jeden Termin und dann mit Mail.

**Die Zuteilungsmail (Z6) ist ein Lauf, keine Zeile in der Freigabe-Route.** Sie steht so in der
Lauf-Tabelle von `api/putzdienst-api.md`, und der Auslöser ist keine Uhr, sondern eine gesetzte
Spalte: Der Lauf sucht die Zyklen mit Freigabe und ohne Mail-Marke. Das hält die Route kurz und
kostet ein Mailfehler nicht die Freigabe. Die Marke ist eine Schemaänderung und geht wie die beiden
bestehenden als Migration in `wb-backend` voran (`schema/putzdienst-schema.sql` zeigt die Form).
**Sie ist zugleich die erste Erinnerung an den ersten Termin des Jahres** — wer danach Z9 baut, darf
den ersten nicht doppelt erinnern.

Was dafür schon steht und nicht neu gebaut wird: die Versandschicht mit ihrer einen Stelle nach
draußen, der Lauf-Dienst samt Register, und in `wb-backend/app/services/cleaning.py` die Bausteine
`_required` (Pflichtmenge je Familie), `_guardians_by_family` (Adressen je Familie) und `_enrolled`.
Für den Einstieg: `soll-prozesse/01-putzdienst.md` Z5 und Z6, dann die beiden genannten Abschnitte
der API-Datei, dann `wb-backend/app/routers/cleaning.py`.

### Was eine Schemaänderung dort mitziehen muss

Das Datenmodell ist übertragen (`CLAUDE.md`, „Stand"). Drei Dinge daran sieht `--autogenerate` nicht, und es meldet ihr Fehlen auch nicht — wer eine Tabelle oder eine Spalte ergänzt, zieht sie von Hand mit:

- **Die Tabellenrechte.** `backend_runtime` hat keine Default-Privilegien; jede Migration vergibt, was ihre Tabellen brauchen, `UPDATE` immer spaltenweise. Ein vergessenes Recht fällt als „permission denied" auf, ein zu breites in `wb-backend/tests/test_privileges.py`.
- **Die engen Rollen.** Welche Spalte welche Rolle hat, steht als `__protected_columns__` am Modell und als `GRANT` in der Migration derselben Domäne; warum sie eng ist, steht am Feld in `schema/*.sql`. Ein dritter Ort dafür wird nicht geführt.
- **Die Änderungsspur.** Jedes Modell schuldet der Schreibschicht `__change_anchor__` und `__protected_columns__` (`wb-backend/app/db/base.py`); fehlt eines, wirft sie beim Flush. Ein Anker, der erst über einen Join zu finden ist, ist ein Fund und keine stille Erweiterung — was daraus folgt, trägt Stufe 8 des Lösch-Laufs (Kopf von `schema/querschnitt-schema.sql`).

Die Gegenprobe bleibt dieselbe: Alle vierzehn Prüfskripte in `schema/` laufen gegen **jede** Datenbank, auch gegen die von Alembic gebaute — als fester Schritt hinter jedem Migrationslauf, nicht als einmalige Sichtprüfung.

**Gegen die von Alembic gebaute Datenbank braucht dieser Schritt seit dem Anfangsbestand einen Vorspann**, sonst scheitern dreizehn der vierzehn an einem doppelten Schlüssel: Jedes Skript legt die Wertelisten selbst an, die es braucht, und rechnet dafür mit einer leeren Datenbank („die Datenbank bleibt danach leer", Kopf jedes Skripts). Die Lösung braucht keine Änderung an den Skripten — sie rollen ohnehin alles zurück, also darf der Vorspann in derselben Transaktion räumen:

```
{ echo "BEGIN; TRUNCATE <die gesäten Listen> CASCADE;"; cat "$f"; } \
    | docker compose exec -T db psql -U backend_migrator -d weltenbaum -v ON_ERROR_STOP=1 -q
```

Das `ROLLBACK;` am Ende des Skripts nimmt das `TRUNCATE` mit zurück, der Anfangsbestand steht danach unverändert da. Die Liste der Tabellen führt die Seed-Revision als `SEEDED_TABLES`.

Und der Rückgabewert wird **vor** jeder anderen Auswertung in eine Variable geschrieben: `rc=$?` direkt hinter dem Aufruf. Steht davor eine Kommando-Ersetzung wie `echo "$(basename "$f") rc=$?"`, trägt `$?` den Rückgabewert von `basename` — der Lauf ist dann grün, auch der gescheiterte, genau wie ohne `ON_ERROR_STOP=1`.

### Was von den Wertelisten noch offen ist

Der Anfangsbestand steht: Die Wertelisten, auf deren `code` der Anwendungscode verzweigt, kommen als Revision in der Migrationskette (`wb-backend/app/alembic/versions/`, „value list seed"), und `wb-backend/tests/test_seed.py` führt die Namensliste, gegen die eine frische Datenbank grün laufen muss. Nicht mitgekommen sind zwei Sorten, beide bewusst:

- **Inhalt, den ein Mensch pflegt** — `kindergartens`, `previous_schools`, `payees`, `cost_projects`, `ledger_accounts`, `sharepoint_libraries`, `contract_texts`, `configured_values` und die vier Preistabellen. Wer welche Zahl einträgt, steht in `TODO.md`; die Beträge selbst liegen vor und stehen ausgeschrieben in den Kommentaren ihrer Tabellen und in `soll-prozesse/hebel.md`.
- **Eine Liste, deren Werte offen sind** — `denominations`. Sie hängt nicht am Inhalt, sondern am Zweckbeschluss des Feldes selbst (`fragen.md`, Frage 1): Fällt das Feld, fällt die Liste mit ihm, und ein Anfangsbestand wäre vorher eine Entscheidung, die niemand getroffen hat. Die übrigen vier — `genders`, `guardian_relations`, `measles_presentation_types`, `languages` — sind entschieden und kommen mit.

Solange eine der beiden Sorten leer ist, hält sie ihren Vorgang an — `family_guardians.access_level_id` zeigt inzwischen auf eine gefüllte Liste, `payments` ohne `configured_values` weiß aber weiterhin keinen Betrag.

Zwei Listen sind nicht abgeschrieben, sondern normiert: `countries` trägt alle 249 ISO-3166-1-Einträge, `languages` die 183 mit ISO-639-1-Code, beide mit den deutschen Namen aus dem `iso-codes`-Katalog des Systems. Die Staatsangehörigkeitsbezeichnung steht in keinem Katalog und ist von Hand geschrieben — sie will vor dem Vollimport einmal gelesen werden, mehr nicht.
