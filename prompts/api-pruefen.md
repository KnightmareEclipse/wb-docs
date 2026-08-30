# Prompt: die gebauten Routen und ihre Tests gegenprüfen

Gegenstück zu [`api-bauen.md`](api-bauen.md). Dort entsteht der Code, hier wird er angegriffen —
und mit ihm die Tests, die ihn grün melden. **Es wird nicht gebaut und nicht repariert**; gemeldet
wird, und du entscheidest.

**Du startest genau eine Session und tust sonst nichts.** Sie richtet sich selbst ein, verteilt die
zwölf Domänen auf Agenten mit je eigenem Arbeitsbaum und eigener Datenbank, räumt hinter sich auf
und legt am Ende zwölf Berichtsdateien plus eine Zusammenfassung hin.

Gestartet wird **in einer `wb-backend`-Session** — dort lädt sich `CLAUDE.md` des Repos von selbst,
und die Arbeitsbäume, die dieser Lauf anlegt, sind Bäume dieses Repos. Effort `xhigh`, Thinking an.
Vorher `git status` sauber, `podman` erreichbar, sonst nichts. Alles unter dem Strich ist der
Prompt.

---

Es gelten [`gemeinsam.md`](gemeinsam.md), `CLAUDE.md` beider Repos und `wb-backend/README.md`.
Alles liest du zuerst und ich wiederhole es hier nicht — **mit einer ausgeschriebenen Ausnahme,
gleich unten.**

Wir prüfen die 235 Endpunkte unter `app/routers/` und die rund 15 000 Zeilen unter `tests/`. Der
Auftrag der Routen steht in `wb-docs/api/`, ihre Herkunft in `wb-docs/soll-prozesse/`.

## Die eine Regel, aus der der Rest folgt

**Ein grüner Test belegt nichts, solange nicht gezeigt ist, dass er rot werden kann.** Das ist keine
Zuspitzung, sondern der einzige Weg, die Frage zu beantworten, für die es diesen Lauf gibt: Deckt
die Suite den Randfall wirklich ab, oder läuft sie an ihm vorbei und meldet trotzdem grün?

Der teuerste Fehler dieser Schicht ist nicht der fehlende Test. Es ist der **Test, der etwas
anderes prüft, als sein Name sagt** — ein Zugriffstest, der die Rolle abweist und die fremde Id nie
probiert; eine Zusicherung über eine Liste, die leer ist; ein erwarteter `400`, der aus dem falschen
Grund kommt. Solche Tests stehen jahrelang und schützen nichts.

## Die Ausnahme von „Kein Subagent urteilt"

`gemeinsam.md` verbietet, ein Urteil an einen Agenten zu geben, und nennt den Grund: Ein
zusammengefasster Bericht hat den Satz nicht mehr, gegen den das Zitat gehalten wird. **Für diesen
einen Lauf gilt die Regel nicht — weil ihr Grund hier nicht greift.** Es wird nichts
zusammengefasst: Jeder Agent schreibt dieselbe Datei im selben Format, die eine eigene Session
geschrieben hätte, mit Belegstelle und Messzeile je Fund. Die Datei ist das Ergebnis, nicht sein
Bericht an dich.

Drei Bedingungen, ohne die die Ausnahme nicht trägt:

- **Ein Agent je Domäne, und er macht sie ganz** — lesen, messen, aufschreiben, aufräumen. Kein
  Agent, der etwas nachsieht und dir antwortet; das wäre genau der Fall, den die Regel meint.
- **Was zurückfließt, ist eine Zeile**: Domäne, Zahl der Funde, Datei geschrieben ja/nein. Mehr
  liest du von ihm nicht, und mehr braucht er dir nicht zu sagen.
- **Du prüfst nichts nach, was ein Agent geurteilt hat.** Sein Bericht steht, wie er steht;
  widersprechen darf ihm nur ein zweiter unabhängiger Lauf.

## Was du selbst tust

1. **Die zwölf Arbeitsbäume anlegen**, nacheinander und bevor der erste Agent startet — `git
   worktree add` fasst das `.git` des Hauptbaums an, und das machen zwölf Agenten nicht
   gleichzeitig. Je Domäne, aus dem Hauptbaum heraus:

   ```
   git worktree add -f ../wbp-DOMÄNE HEAD
   cp -r secrets .env ../wbp-DOMÄNE/
   chcon -Rt container_file_t ../wbp-DOMÄNE/secrets
   ```

   **Die dritte Zeile ist keine Zierde.** `secrets/` und `.env` sind gitignoriert, kommen also nicht
   mit dem Baum; und eine frische Kopie trägt `user_home_t`, womit der Container sie nicht lesen
   kann — der Lauf scheitert dann erst im Test, mit `SettingsError: error getting value for field
   "migration_db_password"`, und das sieht nach einem Fund aus. Gemessen, nicht vermutet.

2. **Die Agenten starten, drei gleichzeitig**, in dieser Reihenfolge, größte Domäne zuerst:
   `anmeldung`, `stammdaten`, `rechnungsfreigabe`, `cleaning`, `querschnitt`, `ferien`, `mensa`,
   `elternbonus`, `gesundheit`, `klassenorganisation`, `payments`, `auth`. Jeder bekommt den
   **Auftrag unten wörtlich**, mit `DOMÄNE` ersetzt und den beiden absoluten Pfaden eingesetzt: sein
   Arbeitsbaum und der `wb-docs`-Baum. Er erbt deinen Kontext nicht, also steht alles im Auftrag
   oder nirgends. Drei gleichzeitig, weil je Agent eine Postgres läuft; auf mehr geht die Wanduhr
   nicht mehr herunter, weil die Suite datenbankgebunden ist.

3. **Nach jedem Agenten seinen Baum entfernen** — `git worktree remove --force ../wbp-DOMÄNE`. Seine
   Container räumt er selbst ab; stirbt er vorher, machst du es: `podman-compose -p wbp-DOMÄNE down
   -v`.

4. **Den domänenübergreifenden Teil machst du selbst**, im Hauptbaum, wenn alle durch sind. Er
   gehört in keinen Agenten, sonst fährt ihn jeder von zwölfen und meldet zwölfmal dieselbe Zahl:

   - **Fehlerklasse 8 über alle Router auf einmal**: Plan gegen Router, Methode, Pfad, Rolle,
     Einschränkung. Die ersten beiden zählt jeder nach, die letzten beiden niemand — und dort liegt
     der Unterschied zwischen „gebaut" und „richtig gebaut".
   - **Zwei Zahlen über alle Domänen**: wie viele Routen überhaupt einen Test haben, und wie viele
     einen Test auf die **fremde Id**. Die Differenz ist die eigentliche Aussage dieses Laufs.
   - **Der volle Lauf**: `pytest`, `ruff check`, `ruff format --check`, `mypy app`,
     `./schema-check.sh`. In den Bericht kommt der Rückgabewert, nicht der Text auf dem Schirm.
   - **Die Gegenprobe aufs Aufräumen**: `git status` sauber, `git worktree list` nur der Hauptbaum,
     `podman ps -a` und `podman volume ls` ohne `wbp-`.

5. **Die Zusammenfassung erzeugst du aus den Dateien**, nicht aus dem Kopf und nicht aus dem, was
   die Agenten dir gesagt haben.

## Der Auftrag je Agent — wörtlich weitergeben

> Du prüfst die Fachdomäne **DOMÄNE** von `wb-backend`. Dein Arbeitsbaum ist `ABSOLUTER_PFAD`, er
> ist schon angelegt und eingerichtet; arbeite ausschließlich darin. Die Doku liegt unter
> `WB_DOCS_PFAD`. Du baust nichts, reparierst nichts und committest nichts.
>
> **Zuerst lesen**, in dieser Reihenfolge und selbst — nicht überfliegen, nicht delegieren:
> `WB_DOCS_PFAD/CLAUDE.md`, `WB_DOCS_PFAD/api/gemeinsam.md`, dann in deinem Baum `CLAUDE.md`,
> `app/db/changelog.py`, `app/core/security.py` und `tests/conftest.py`. Die letzte ist die
> wichtigste und wird am seltensten gelesen: Was die Suite zwischen zwei Tests wegräumt und was sie
> stehen lässt, entscheidet, welcher Test überhaupt etwas beobachten kann.
>
> **Dann deine Domäne**, und erst der Code, dann der Auftrag — wer den Plan zuerst liest, findet im
> Router, was er erwartet: `app/routers/DOMÄNE.py` vollständig, dazu ihr Modell und ihr Service;
> `tests/test_DOMÄNE.py` vollständig; **erst danach** `WB_DOCS_PFAD/api/DOMÄNE-api.md` und die
> Soll-Blöcke, die er nennt.
>
> **Deine Datenbank hochfahren**, aus deinem Baum heraus. Nur `db` — Caddy veröffentlicht Ports und
> würde mit den Nachbarn kollidieren, `db` tut das nicht:
>
> ```
> podman-compose -p wbp-DOMÄNE up -d db
> sleep 12
> podman-compose -p wbp-DOMÄNE --profile tools run --rm migrate
> ```
>
> Kein `seed`: Die Suite baut sich ihre Welt selbst und will eine leere Datenbank.
>
> **Die Methode, und sie ist der Kern des Auftrags.** Für jede Regel, die du prüfst:
>
> 1. Die Bedingung im Router entfernen oder umdrehen — `!=` statt `==`, die `where`-Klausel raus,
>    das `if` auf `False`.
> 2. `podman-compose -p wbp-DOMÄNE --profile tools run --rm --no-deps test pytest
>    tests/test_DOMÄNE.py -x -q`
> 3. **Rot heißt: die Regel ist geprüft. Grün heißt: sie ist es nicht, und das ist der Fund.**
> 4. `git checkout -- app/` — sofort, nach jeder einzelnen Messung, nicht am Ende.
>
> Das ist teuer, also nicht für alles: gemessen wird bei Fehlerklasse 1 und 2 immer, dazu bei jeder
> Regel, die laut Plan „kein Constraint trägt". Für den Rest genügt Lesen.
>
> **Die acht Fehlerklassen**, in dieser Reihenfolge:
>
> 1. **Die Ownership-Bedingung steht nicht in der Query.** Die eine Klasse, die kein vorhandener
>    Test fängt und die `api-bauen.md` beim Namen nennt. Nimm die Spalte „Worauf eingeschränkt" aus
>    dem Plan und such die Bedingung im `select`. Fehlt sie, ist der Endpunkt grün und offen
>    zugleich: Jeder Berechtigte erreicht damit jede fremde Zeile. Der Test, der zählt, ist der, in
>    dem ein *Berechtigter* eine fremde Id rät und eine Absage bekommt. Ein Test, der einer falschen
>    **Rolle** eine Absage nachweist, sagt darüber nichts.
> 2. **Ein Test prüft den Fehlercode und nicht den Zustand.** `assert status_code == 400` belegt
>    nicht, dass nichts geschrieben wurde. Such abgewiesene Schreibwege, die davor schon eine Zeile
>    angelegt haben — besonders dort, wo ein Block „ein Vorgang, eine Route" sagt. Miss es: Zeilen
>    zählen vor dem Aufruf, Zeilen zählen danach.
> 3. **Ein Test ist grün, weil er nichts trifft.** Eine Zusicherung über eine leere Liste hält
>    immer; ein Fixture, dessen Zeile die Suite vorher weggeräumt hat, lässt jeden Vergleich ins
>    Leere laufen. Prüf je Testdatei die Zusicherungen über Listen: Steht irgendwo, dass die Liste
>    nicht leer ist?
> 4. **Eine Regel, die kein Constraint trägt, hat keinen Test.** Der Plan schreibt sie regelmäßig
>    aus („vier Regeln der Domäne trägt kein Constraint, und sie stehen deshalb in der Route").
>    Genau die sind ungeschützt: Die Datenbank fängt sie nicht, also muss die Suite es tun. Zähl sie
>    aus dem Plan und geh sie einzeln mit der Methode oben durch.
> 5. **Die enge Rolle wird umgangen oder gar nicht geprüft.** Jede Route, die im Plan eine trägt,
>    muss sie im Code nehmen — und eine, die keine trägt, darf keine nehmen. Der Fund, der zählt:
>    eine Spalte hinter `backend_sensitive`, die eine Route ohne den Block liest oder in einer
>    Antwort mitgibt, in der der Plan sie nicht nennt.
> 6. **Die Transaktion trägt nicht so weit, wie der Block sagt.** „Der Beleg entsteht mit dem
>    Absenden oder gar nicht" ist eine Zusage über eine Transaktion, nicht über eine Route. Prüf
>    jeden Endpunkt, der mehr als eine Tabelle schreibt oder Graph ruft: Was bleibt stehen, wenn der
>    zweite Schritt wirft? Und die häufigere Gegenrichtung: Geht eine Mail raus, obwohl die
>    Transaktion zurückgerollt ist?
> 7. **Ein Lauf ist nicht wiederholbar, oder seine Marke steht am falschen Ort.** Nur wo deine
>    Domäne einen Lauf hat (`app/runs.py`, `tests/test_runs.py`). Die Marke muss sagen, dass *dieser
>    Lauf* gelaufen ist, nie eine Spalte sein, die einen benachbarten Vorgang führt. Zweimal
>    hintereinander aufgerufen: Passiert beim zweiten Mal wirklich nichts?
> 8. **Plan und Router weichen ab.** Nur, was dir in deiner Domäne auffällt — gezählt wird das über
>    alle Domänen an anderer Stelle.
>
> **Aufschreiben, sofort und nicht am Ende:** `WB_DOCS_PFAD/pruefberichte/routen-DOMÄNE.md`. Das ist
> die einzige Datei, die du anlegst, und sie liegt außerhalb deines Baums. Je Fund vier Zeilen:
>
> ```
> [DOMÄNE-R1] Klasse 1 · PUT /contracts/{id}/responses/{person_id}/data-review
> Plan: „die eigene Person". Der select filtert nur auf contract_id.
> Gemessen: Bedingung entfernt, tests/test_anmeldung.py bleibt grün.
> Vorschlag: person_id gegen den Token prüfen, dazu ein Test mit fremder person_id.
> ```
>
> - Die Nummer trägt deine Domäne als Präfix und läuft in deiner Datei durch — zwölf Agenten, die
>   alle bei `R1` anfangen, geben zwölf `[R1]`.
> - **Die Zeile „Gemessen" ist Pflicht, wo du gemessen hast**, und fehlt, wo du nur gelesen hast.
>   Ein Fund ohne sie wiegt weniger, und das soll man ihm ansehen.
> - **Gewicht zuerst**: was eine fremde Zeile erreichbar macht, vor allem anderen; danach, was Daten
>   halb schreibt; erst danach, was nur ungeprüft ist.
> - **Ein Vorschlag je Fund**, ein Satz. Nicht ausformuliert, nicht gebaut.
> - Darunter eine zweite, kurze Liste `Angesehen, nicht als Fund gewertet` — was du geprüft und
>   entkräftet hast. Nicht, was dir nicht gefällt: Ein Endpunkt, den du anders geschnitten hättest,
>   gehört in keine der beiden Listen.
>
> **Erst sammeln, dann sortieren.** Was dir auffällt, kommt in die Datei — auch das, von dem du beim
> Aufschreiben noch nicht weißt, ob es trägt. Schon beim Lesen zu entscheiden, ob etwas den Bericht
> wert ist, kostet zuverlässig die leisen Funde, und die leisen sind hier die teuren.
>
> **Zum Schluss aufräumen und erst dann melden:**
>
> ```
> git checkout -- .
> git status                      # muss sauber sein
> podman-compose -p wbp-DOMÄNE down -v
> ```
>
> Ein Lauf, der eine herausgenommene Sicherung oder eine laufende Datenbank liegen lässt, ist
> schlimmer als keiner.
>
> **Deine Antwort an mich ist eine Zeile**: Domäne, Zahl der Funde, wie viele Sicherungen du
> herausgenommen hast und wie viele davon rot wurden, `git status` sauber ja/nein. Nichts weiter —
> der Bericht ist die Datei.
>
> **Nicht anhalten und nicht fragen.** Wo dir etwas fehlt, um zu urteilen, wird das eine Zeile im
> Bericht. Den Marken `[A]` und `[?]` widersprichst du nicht; dass sie offen sind, ist kein Fund.

## Was du meldest

Die zwölf Dateien plus höchstens zehn Zeilen Prosa: die schwersten Funde mit ihrer Nummer, die zwei
Zahlen aus Schritt 4, die Rückgabewerte des vollen Laufs, und eine Zeile, welche Domänen ohne Fund
durchgekommen sind.

**Nicht gegen den Plan urteilen, sondern gegen den Block.** Weicht die Route vom Plan ab, ist das
ein Fund; weicht der Plan vom Block ab, auch — und der zweite wiegt schwerer, weil er sich beim
nächsten Bau fortpflanzt. Die Rangfolge steht in `wb-docs/CLAUDE.md`.

## Was nicht passiert

- **Kein Eingriff außer den Berichtsdateien.** Kein Router, kein Test, kein Commit, kein „ich hab's
  gleich mit repariert". Auch der Test nicht, dessen Lücke gefunden wurde: Wer repariert, prüft
  danach seine eigene Arbeit.
- **Kein Arbeitsbaum, keine Datenbank und keine Sicherung bleibt liegen.** Die vier Gegenproben aus
  Schritt 4 stehen im Bericht, auch wenn sie sauber sind.
- **Kein zweiter Lauf über dieselbe Domäne im selben Durchgang.** Ein Fund, den ein unabhängiger
  Lauf wiederfindet, wiegt schwer — und das merkt man nur, wenn er frisch sucht.
