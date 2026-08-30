# Prompt: die gebauten Routen und ihre Tests gegenprüfen

Gegenstück zu [`api-bauen.md`](api-bauen.md). Dort entsteht der Code, hier wird er angegriffen —
und mit ihm die Tests, die ihn grün melden. **Der Prüfer baut nicht und repariert nicht**; er
meldet, und du entscheidest.

**Dreizehn Läufe: zwölf Domänen, dann einer über alle.** Eine Session je Domäne, kopieren, `DOMÄNE`
ersetzen, absenden. Jede richtet sich ihren eigenen Arbeitsbaum samt eigener Datenbank ein und
räumt ihn wieder ab — deshalb ist es gleich, ob du sie nacheinander startest oder drei
nebeneinander. Mehr als drei bringt nichts: Je Session läuft eine Postgres, und die Suite ist
datenbankgebunden.

Der Lauf ist nur etwas wert, wenn er unabhängig ist: eine frische Session, die den Bau nicht
mitgemacht hat und die Testnamen für Behauptungen hält, nicht für Belege. **Eine Session, eine
Domäne** — nicht zwei nacheinander im selben Fenster, sonst schickt sie beim Messen der zweiten die
ganze erste mit und du zahlst denselben Kontext hundertfach.

Gestartet wird **in einer `wb-backend`-Session**; dort lädt sich `CLAUDE.md` des Repos von selbst.
Effort `xhigh`, Thinking an. Vorher `git status` sauber und `podman` erreichbar, sonst nichts.

Reihenfolge, wenn du frei wählst: **die teuerste zuletzt**, damit du nach der ersten weißt, was ein
Lauf kostet — `gesundheit`, `klassenorganisation`, `payments`, `auth`, `elternbonus`, `mensa`,
`ferien`, `querschnitt`, `cleaning`, `rechnungsfreigabe`, `stammdaten`, `anmeldung`.

---

Es gelten [`gemeinsam.md`](gemeinsam.md), `CLAUDE.md` beider Repos und `wb-backend/README.md`.
Alles liest du zuerst und ich wiederhole es hier nicht.

Wir prüfen die Fachdomäne **DOMÄNE**: ihre Endpunkte in `app/routers/DOMÄNE.py` und die Tests, die
sie grün melden. Der Auftrag steht in `wb-docs/api/DOMÄNE-api.md`, seine Herkunft in den
Soll-Blöcken, die er nennt.

## Die eine Regel, aus der der Rest folgt

**Ein grüner Test belegt nichts, solange nicht gezeigt ist, dass er rot werden kann.** Das ist keine
Zuspitzung, sondern der einzige Weg, die Frage zu beantworten, für die es diesen Lauf gibt: Deckt
die Suite den Randfall wirklich ab, oder läuft sie an ihm vorbei und meldet trotzdem grün?

Der teuerste Fehler dieser Schicht ist nicht der fehlende Test. Es ist der **Test, der etwas
anderes prüft, als sein Name sagt** — ein Zugriffstest, der die Rolle abweist und die fremde Id nie
probiert; eine Zusicherung über eine Liste, die leer ist; ein erwarteter `400`, der aus dem falschen
Grund kommt. Solche Tests stehen jahrelang und schützen nichts.

## Dein Arbeitsplatz richtet sich selbst ein

Du arbeitest **nicht im Hauptbaum**: Dieser Lauf nimmt Sicherungen aus dem Router heraus, und das
tut man nicht dort, wo nebenher jemand anders arbeitet. Aus dem Hauptbaum heraus, einmal am Anfang:

```
git worktree add -f ../wbp-DOMÄNE HEAD
cp -r secrets .env ../wbp-DOMÄNE/
chcon -Rt container_file_t ../wbp-DOMÄNE/secrets
cd ../wbp-DOMÄNE
podman-compose -p wbp-DOMÄNE up -d db
podman-compose -p wbp-DOMÄNE --profile tools run --rm migrate
```

Vier Dinge daran sind gemessen und nicht geraten:

- **Nur `db` wird hochgefahren.** Caddy ist der einzige Dienst mit veröffentlichten Ports; mit ihm
  kollidiert jede zweite Session sofort.
- **`chcon` ist keine Zierde.** `secrets/` und `.env` sind gitignoriert, kommen also nicht mit dem
  Baum; und eine frische Kopie trägt `user_home_t`, womit der Container sie nicht lesen kann. Ohne
  die Zeile scheitert der Lauf erst im Test, mit `SettingsError: error getting value for field
  "migration_db_password"` — und das sieht aus wie ein Fund.
- **Kein `seed`.** Die Suite baut sich ihre Welt selbst und will eine leere Datenbank.
- **`-p wbp-DOMÄNE`** gibt eigene Container und ein eigenes Volume, sonst teilst du dir die
  Datenbank mit dem Nachbarn — und `tests/conftest.py` räumt sie zwischen zwei Tests aus.

**Dein Nullpunkt** ist danach ein grüner Lauf deiner Testdatei:
`podman-compose -p wbp-DOMÄNE --profile tools run --rm --no-deps test pytest tests/test_DOMÄNE.py -q`.
Ist der schon rot, brichst du ab und sagst in einem Satz, was rot war — jede Messung danach wäre
bedeutungslos.

## Die Methode: nimm die Sicherung heraus und sieh, ob es knallt

Für jede Regel, die du prüfst, genau das — von Hand, eine nach der anderen:

1. Die Bedingung im Router entfernen oder umdrehen: `!=` statt `==`, die `where`-Klausel raus, das
   `if` auf `False`.
2. `podman-compose -p wbp-DOMÄNE --profile tools run --rm --no-deps test pytest
   tests/test_DOMÄNE.py -x -q`
3. **Rot heißt: die Regel ist geprüft. Grün heißt: sie ist es nicht, und das ist der Fund.**
4. `git checkout -- app/` — sofort, nach jeder einzelnen Messung, nicht am Ende der Domäne.

Das ist teuer, also nicht für alles: **gemessen wird bei Fehlerklasse 1 und 2 immer**, dazu bei
jeder Regel, die laut Plan „kein Constraint trägt". Für den Rest genügt Lesen. Kommst du über
vierzig Messungen, hör auf und schreib in den Bericht, wo du aufgehört hast — ein Lauf, der die
Hälfte gründlich macht, ist mehr wert als einer, der abbricht.

## Was du liest, und in welcher Reihenfolge

Erst der Code, dann der Auftrag — wer den Plan zuerst liest, findet im Router, was er erwartet.

1. **`wb-docs/api/gemeinsam.md`** — was für jede Route gilt. Eine Route, die den gemeinsamen Hebel
   nachbaut statt ihn zu nutzen, ist ein Fund; eine, die ihn übergeht, auch.
2. **`app/db/changelog.py`**, **`app/core/security.py`** und **`tests/conftest.py`**. Die dritte ist
   die wichtigste und wird am seltensten gelesen: Was die Suite zwischen zwei Tests wegräumt und was
   sie stehen lässt, entscheidet, welcher Test überhaupt etwas beobachten kann.
3. **`app/routers/DOMÄNE.py`** vollständig, dazu ihr Modell und ihr Service.
4. **`tests/test_DOMÄNE.py`** vollständig.
5. **Erst danach `wb-docs/api/DOMÄNE-api.md`** und die Soll-Blöcke, die er nennt.

**Das liest du selbst** — aus dem Grund, der in `gemeinsam.md` steht.

## Die acht Fehlerklassen

Nach diesen suchst du, in dieser Reihenfolge.

1. **Die Ownership-Bedingung steht nicht in der Query.** Die eine Klasse, die kein vorhandener Test
   fängt und die `api-bauen.md` beim Namen nennt. Nimm die Spalte „Worauf eingeschränkt" aus dem
   Plan und such die Bedingung im `select`. Fehlt sie, ist der Endpunkt grün und offen zugleich:
   Jeder Berechtigte erreicht damit jede fremde Zeile. Der Test, der zählt, ist der, in dem ein
   *Berechtigter* eine fremde Id rät und eine Absage bekommt. Ein Test, der einer falschen **Rolle**
   eine Absage nachweist, sagt darüber nichts.
2. **Ein Test prüft den Fehlercode und nicht den Zustand.** `assert status_code == 400` belegt nicht,
   dass nichts geschrieben wurde. Such abgewiesene Schreibwege, die davor schon eine Zeile angelegt
   haben — besonders dort, wo ein Block „ein Vorgang, eine Route" sagt. Miss es: Zeilen zählen vor
   dem Aufruf, Zeilen zählen danach.
3. **Ein Test ist grün, weil er nichts trifft.** Eine Zusicherung über eine leere Liste hält immer;
   ein Fixture, dessen Zeile die Suite vorher weggeräumt hat, lässt jeden Vergleich ins Leere
   laufen. Prüf je Testdatei die Zusicherungen über Listen: Steht irgendwo, dass die Liste nicht
   leer ist?
4. **Eine Regel, die kein Constraint trägt, hat keinen Test.** Der Plan schreibt sie regelmäßig aus
   („vier Regeln der Domäne trägt kein Constraint, und sie stehen deshalb in der Route"). Genau die
   sind ungeschützt: Die Datenbank fängt sie nicht, also muss die Suite es tun. Zähl sie aus dem
   Plan und geh sie einzeln mit der Methode oben durch.
5. **Die enge Rolle wird umgangen oder gar nicht geprüft.** Jede Route, die im Plan eine trägt, muss
   sie im Code nehmen — und eine, die keine trägt, darf keine nehmen. Der Fund, der zählt: eine
   Spalte hinter `backend_sensitive`, die eine Route ohne den Block liest oder in einer Antwort
   mitgibt, in der der Plan sie nicht nennt.
6. **Die Transaktion trägt nicht so weit, wie der Block sagt.** „Der Beleg entsteht mit dem Absenden
   oder gar nicht" ist eine Zusage über eine Transaktion, nicht über eine Route. Prüf jeden
   Endpunkt, der mehr als eine Tabelle schreibt oder Graph ruft: Was bleibt stehen, wenn der zweite
   Schritt wirft? Und die häufigere Gegenrichtung: Geht eine Mail raus, obwohl die Transaktion
   zurückgerollt ist?
7. **Ein Lauf ist nicht wiederholbar, oder seine Marke steht am falschen Ort.** Nur wo deine Domäne
   einen Lauf hat (`app/runs.py`, `tests/test_runs.py`). Die Marke muss sagen, dass *dieser Lauf*
   gelaufen ist, nie eine Spalte sein, die einen benachbarten Vorgang führt. Zweimal hintereinander
   aufgerufen: Passiert beim zweiten Mal wirklich nichts?
8. **Plan und Router weichen ab** — Methode, Pfad, Rolle, Einschränkung. Nur, was dir in deiner
   Domäne auffällt; gezählt wird es über alle Domänen im dreizehnten Lauf.

## Was du meldest

Ein Bericht, keine Änderung: `wb-docs/pruefberichte/routen-DOMÄNE.md`, die einzige Datei, die dieser
Lauf anlegt. **Funde schreibst du sofort hinein**, nicht am Ende — der Lauf überlebt seinen eigenen
Kontext nicht, und nach einer Zusammenfassung ist die Datei, was du hast. Je Fund vier Zeilen:

```
[DOMÄNE-R1] Klasse 1 · PUT /contracts/{id}/responses/{person_id}/data-review
Plan: „die eigene Person". Der select filtert nur auf contract_id.
Gemessen: Bedingung entfernt, tests/test_anmeldung.py bleibt grün.
Vorschlag: person_id gegen den Token prüfen, dazu ein Test mit fremder person_id.
```

- **Die Nummer trägt deine Domäne als Präfix** und läuft in deiner Datei durch. Zwölf Sessions, die
  alle bei `R1` anfangen, geben zwölf `[R1]`, und dann ist kein Fund mehr ansprechbar.
- **Die Zeile „Gemessen" ist Pflicht, wo du gemessen hast**, und fehlt, wo du nur gelesen hast. Ein
  Fund ohne sie wiegt weniger, und das soll man ihm ansehen.
- **Gewicht zuerst**: was eine fremde Zeile erreichbar macht, vor allem anderen; danach, was Daten
  halb schreibt; erst danach, was nur ungeprüft ist.
- **Ein Vorschlag je Fund**, ein Satz. Nicht ausformuliert, nicht gebaut.

**Erst sammeln, dann sortieren.** Was dir auffällt, kommt in die Datei — auch das, von dem du beim
Aufschreiben noch nicht weißt, ob es trägt. Schon beim Lesen zu entscheiden, ob etwas den Bericht
wert ist, kostet zuverlässig die leisen Funde, und die leisen sind hier die teuren.

Darunter eine zweite, kurze Liste `Angesehen, nicht als Fund gewertet` — was du geprüft und
entkräftet hast. Nicht, was dir nicht gefällt: Ein Endpunkt, den du anders geschnitten hättest,
gehört in keine der beiden Listen.

## Aufräumen, und erst dann melden

```
git checkout -- .
git status                                   # muss sauber sein
podman-compose -p wbp-DOMÄNE down -v
cd - && git worktree remove --force ../wbp-DOMÄNE
```

Ein Lauf, der eine herausgenommene Sicherung, eine laufende Datenbank oder einen Arbeitsbaum liegen
lässt, ist schlimmer als keiner. Deine Schlussnachricht ist der Bericht in der Datei plus höchstens
zehn Zeilen: Zahl der Funde, wie viele Sicherungen du herausgenommen hast und wie viele davon rot
wurden, und die vier Gegenproben oben.

## Was du nicht tust

- **Nichts ändern außer der Berichtsdatei.** Keinen Router, keinen Test, kein Commit, kein „ich
  hab's gleich mit repariert". Auch den Test nicht, dessen Lücke du gefunden hast: Wer repariert,
  prüft danach seine eigene Arbeit.
- **Keine zweite Domäne in dieser Session.** Auch keine kleine.
- **Nicht gegen den Plan urteilen, sondern gegen den Block.** Weicht die Route vom Plan ab, ist das
  ein Fund; weicht der Plan vom Block ab, auch — und der zweite wiegt schwerer, weil er sich beim
  nächsten Bau fortpflanzt. Die Rangfolge steht in `wb-docs/CLAUDE.md`.
- **Den Marken `[A]` und `[?]` nicht widersprechen.** Dass sie offen sind, ist kein Fund.
- **Wo dir etwas fehlt, um zu urteilen, wird das eine Zeile im Bericht.** Nicht anhalten, nicht
  fragen — ich sitze nicht daneben.

---

## Der dreizehnte Lauf: was keine einzelne Domäne sieht

Eigene Session, **nachdem alle zwölf Berichte liegen**. Kein Arbeitsbaum, keine eigene Datenbank,
keine Messung — im Hauptbaum, lesend und zählend. Effort `high` genügt.

Es gelten `gemeinsam.md` und `CLAUDE.md` beider Repos.

1. **Plan gegen Router über alle zwölf auf einmal**: Methode, Pfad, Rolle, Einschränkung, in beide
   Richtungen. Die ersten beiden zählt jeder Bau schon nach, die letzten beiden niemand — und dort
   liegt der Unterschied zwischen „gebaut" und „richtig gebaut".
2. **Zwei Zahlen**: wie viele der 235 Routen überhaupt einen Test haben, und wie viele einen Test
   auf die **fremde Id** — nicht auf die falsche Rolle. Die Differenz ist die eigentliche Aussage
   dieses Prüfzyklus.
3. **Der volle Lauf**: `pytest`, `ruff check`, `ruff format --check`, `mypy app`,
   `./schema-check.sh`. In den Bericht kommt der Rückgabewert, nicht der Text auf dem Schirm. Die
   Zahl der Tests muss die sein, mit der die zwölf Läufe angefangen haben — weicht sie ab, hat eine
   Session etwas liegen lassen.
4. **Die Gegenprobe aufs Aufräumen**: `git status` sauber, `git worktree list` nur der Hauptbaum,
   `podman ps -a` und `podman volume ls` ohne `wbp-`.
5. **Die Zusammenfassung aus den zwölf Dateien**, nicht aus dem Gedächtnis: die schwersten Funde mit
   ihrer Nummer, die zwei Zahlen, die Rückgabewerte, und eine Zeile, welche Domänen ohne Fund
   durchgekommen sind. Sie kommt nach `wb-docs/pruefberichte/routen.md`.

Auch dieser Lauf ändert nichts außer seiner eigenen Datei.
