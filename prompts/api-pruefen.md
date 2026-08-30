# Prompt: die gebauten Routen und ihre Tests gegenprüfen

Gegenstück zu [`api-bauen.md`](api-bauen.md). Dort entsteht der Code, hier wird er angegriffen —
und mit ihm die Tests, die ihn grün melden. **Der Prüfer baut nicht** und **repariert nicht**; er
meldet, und du entscheidest.

Der Lauf ist nur etwas wert, wenn er unabhängig ist: eine frische Session, die den Bau nicht
mitgemacht hat und die Testnamen für Behauptungen hält, nicht für Belege.

Gearbeitet wird **in einer `wb-backend`-Session** — dort lädt sich `CLAUDE.md` des Repos von selbst.
Effort `xhigh`, Thinking an. Vorher `git status` sauber und der Stack oben; der Lauf braucht die
laufende Datenbank, weil er Code kaputt macht und den Testlauf ansieht. Alles unter dem Strich ist
der Prompt.

---

Es gelten [`gemeinsam.md`](gemeinsam.md) (wie du mit mir redest, kein Subagent urteilt), `CLAUDE.md`
beider Repos und `wb-backend/README.md`. Alles liest du zuerst und ich wiederhole es hier nicht.

Wir prüfen die 235 Endpunkte unter `app/routers/` und die rund 15 000 Zeilen unter `tests/`. Der
Auftrag der Routen steht in `wb-docs/api/`, ihre Herkunft in `wb-docs/soll-prozesse/`. Du änderst
nichts dauerhaft — was du zum Messen kaputt machst, machst du im selben Atemzug rückgängig.

## Die eine Regel, aus der der Rest folgt

**Ein grüner Test belegt nichts, solange nicht gezeigt ist, dass er rot werden kann.** Das ist keine
Zuspitzung, sondern der einzige Weg, die Frage zu beantworten, für die es diesen Lauf gibt: Deckt
die Suite den Randfall wirklich ab, oder läuft sie an ihm vorbei und meldet trotzdem grün?

Der teuerste Fehler dieser Schicht ist nicht der fehlende Test. Es ist der **Test, der etwas
anderes prüft, als sein Name sagt** — ein Zugriffstest, der die Rolle abweist und die fremde Id nie
probiert; eine Zusicherung über eine Liste, die leer ist; ein erwarteter `400`, der aus dem
falschen Grund kommt. Solche Tests stehen jahrelang und schützen nichts.

## Die Methode: nimm die Sicherung heraus und sieh, ob es knallt

Für jede Regel, die du prüfst, machst du genau das — von Hand, eine nach der anderen:

1. Die Bedingung im Router entfernen oder umdrehen (`!=` statt `==`, `where`-Klausel raus, `if`
   auf `False`).
2. Nur die Testdatei der Domäne laufen lassen: `podman-compose --profile tools run --rm --no-deps
   test pytest tests/test_DOMÄNE.py -x -q`.
3. **Rot heißt: die Regel ist geprüft.** Grün heißt: sie ist es nicht, und das ist der Fund.
4. Zurücknehmen — `git checkout -- app/` nach jeder Messung, nicht am Ende der Domäne.

Nach jeder Domäne einmal `git status`, und er ist sauber. Ein Lauf, der eine herausgenommene
Sicherung liegen lässt, ist schlimmer als keiner.

Das ist teuer, also nicht für alles. Nimm die Sicherungen heraus, die **Fehlerklasse 1 und 2** unten
betreffen, dazu jede Regel, die laut Plan „kein Constraint trägt". Für den Rest genügt Lesen.

## Was du liest, und in welcher Reihenfolge

Erst der Code, dann der Auftrag — nicht umgekehrt. Wer den Plan zuerst liest, findet im Router, was
er erwartet. Diese Reihenfolge gilt **je Domäne**.

**Einmal zu Beginn**, weil es für alle gilt:

1. **`wb-docs/api/gemeinsam.md`** — was für jede Route gilt. Eine Route, die den gemeinsamen Hebel
   nachbaut statt ihn zu nutzen, ist ein Fund; eine, die ihn übergeht, auch.
2. **`app/db/changelog.py`**, **`app/core/security.py`** und **`tests/conftest.py`**. Die dritte
   ist die wichtigste und wird am seltensten gelesen: Was die Suite zwischen zwei Tests wegräumt und
   was sie stehen lässt, entscheidet, welcher Test überhaupt etwas beobachten kann.

**Dann je Domäne**, und die nächste fängst du erst danach an:

3. **`app/routers/<domäne>.py`** vollständig, dazu ihr `app/models/` und ihr `app/services/`.
4. **`tests/test_<domäne>.py`** vollständig.
5. **`wb-docs/api/<domäne>-api.md`**, und **erst danach** die Soll-Blöcke, die sie nennt.

**Punkte 1 bis 5 liest du selbst** — aus dem Grund, der in `gemeinsam.md` steht.

## Der Lauf überlebt seinen eigenen Kontext

Router, Tests, Pläne und Blöcke sind zusammen weit über ein Fenster hinaus, und der Lauf wird
unterwegs zusammengefasst. Deshalb liegt **kein Fund in deinem Gedächtnis**:

- **Eine Domäne ist abgeschlossen, bevor die nächste anfängt.** Lesen, messen, Funde aufschreiben,
  dann weiter. Kein Sammelurteil am Ende.
- **Funde schreibst du sofort nach `pruefberichte/routen.md`** im Wurzelverzeichnis von `wb-docs`,
  angehängt, je Domäne unter einer eigenen Überschrift. Das ist die einzige Datei, die dieser Lauf
  anlegt.
- **Wo du stehst, sagt die Datei** und nicht deine Erinnerung. Fang nach einer Zusammenfassung bei
  der ersten Domäne an, die dort keine Überschrift hat.
- **Den Schlussbericht erzeugst du aus der Datei**, nicht aus dem Kopf.

Reihenfolge der Domänen, größte zuerst, weil dort am meisten liegt: `anmeldung`, `stammdaten`,
`rechnungsfreigabe`, `cleaning`, `querschnitt`, `ferien`, `mensa`, `elternbonus`, `gesundheit`,
`klassenorganisation`, `payments`, `auth`.

## Die acht Fehlerklassen

Nach diesen suchst du, in dieser Reihenfolge.

1. **Die Ownership-Bedingung steht nicht in der Query.** Die eine Klasse, die kein vorhandener Test
   fängt und die `api-bauen.md` beim Namen nennt. Nimm die Spalte „Worauf eingeschränkt" aus dem
   Plan und such die Bedingung im `select`. Fehlt sie, ist der Endpunkt grün und offen zugleich:
   Jeder Berechtigte erreicht damit jede fremde Zeile. **Hier wird immer gemessen**, nie nur
   gelesen — und der Test, der zählt, ist der, in dem ein *Berechtigter* eine fremde Id rät und
   eine Absage bekommt. Ein Test, der einer falschen **Rolle** eine Absage nachweist, sagt darüber
   nichts.
2. **Ein Test prüft den Fehlercode und nicht den Zustand.** Ein `assert response.status_code == 400`
   belegt nicht, dass nichts geschrieben wurde. Such nach abgewiesenen Schreibwegen, die davor schon
   eine Zeile angelegt haben — besonders dort, wo ein Block „ein Vorgang, eine Route" sagt. Miss es:
   Zeile zählen vor dem Aufruf, Zeile zählen danach.
3. **Ein Test ist grün, weil er nichts trifft.** Dieselbe Falle wie bei den Prüfskripten des
   Schemas, eine Ebene höher. Eine Zusicherung über eine leere Liste hält immer; ein `next(…)` über
   ein Ergebnis, das nie gefüllt war, wirft nicht, wenn der Test ihn in einem `if` hat; ein Fixture,
   dessen Zeile die Suite vorher weggeräumt hat, lässt jeden Vergleich ins Leere laufen. Prüf je
   Testdatei die Zusicherungen, die über Listen gehen: Steht irgendwo, dass die Liste nicht leer
   ist?
4. **Eine Regel, die kein Constraint trägt, hat keinen Test.** Der Plan schreibt sie regelmäßig aus
   („vier Regeln der Domäne trägt kein Constraint, und sie stehen deshalb in der Route"). Genau
   diese sind ungeschützt: Die Datenbank fängt sie nicht, also muss die Suite es tun. Zähl sie je
   Domäne aus dem Plan und geh sie einzeln mit der Methode oben durch.
5. **Die enge Rolle wird umgangen oder gar nicht geprüft.** Jede Route, die im Plan eine enge Rolle
   trägt, muss sie im Code auch nehmen — und eine, die keine trägt, darf keine nehmen. Der Fund, der
   zählt: eine Spalte hinter `backend_sensitive`, die eine Route ohne den Block liest oder in einer
   Antwort mitgibt, in der der Plan sie nicht nennt.
6. **Die Transaktion trägt nicht so weit, wie der Block sagt.** „Der Beleg entsteht mit dem Absenden
   oder gar nicht" ist eine Zusage über eine Transaktion, nicht über eine Route. Prüf jeden
   Endpunkt, der mehr als eine Tabelle schreibt oder Graph ruft: Was bleibt stehen, wenn der zweite
   Schritt wirft? Und die Gegenrichtung, die häufiger ist: Geht eine Mail raus, obwohl die
   Transaktion zurückgerollt ist?
7. **Ein Lauf ist nicht wiederholbar, oder seine Marke steht am falschen Ort.** `app/runs.py` und
   `tests/test_runs.py`. Die Marke muss sagen, dass **dieser Lauf** gelaufen ist, nie eine Spalte
   sein, die einen benachbarten Vorgang führt. Prüf je Lauf: zweimal hintereinander aufgerufen —
   passiert beim zweiten Mal wirklich nichts?
8. **Der Plan und der Router weichen ab, und niemand hat es gezählt.** Mechanisch, in beide
   Richtungen: Methode, Pfad, Rolle, Einschränkung. Die ersten beiden zählt jeder nach, die letzten
   beiden niemand — und dort liegt der Unterschied zwischen „gebaut" und „richtig gebaut".

## Was du zusätzlich mechanisch misst

Nicht aus dem Gedächtnis, sondern mit `grep` und einem Lauf:

- **Je Route mindestens ein Test.** Nimm die Pfade aus dem Router und such sie in der Testdatei.
  Eine Route ohne Treffer ist eine Zeile im Bericht, auch wenn sie harmlos aussieht.
- **Je Route der Test auf die fremde Id**, nicht nur auf die falsche Rolle. Zähl beide getrennt und
  schreib die zwei Zahlen in den Bericht; die Differenz ist die eigentliche Aussage dieses Laufs.
- **Der volle Lauf**, einmal am Anfang und einmal am Ende: `pytest`, `ruff check`,
  `ruff format --check`, `mypy app`, dazu `./schema-check.sh`. In den Bericht kommt der Rückgabewert,
  nicht der Text auf dem Schirm. Am Ende steht dieselbe Zahl Tests wie am Anfang — sonst hast du
  gebaut.

## Was du meldest

Ein Bericht, keine Änderung. Je Fund vier Zeilen in dieser Form, nach Gewicht sortiert:

```
[R1] anmeldung · Klasse 1 · PUT /contracts/{id}/responses/{person_id}/data-review
Plan: „die eigene Person". Der select filtert nur auf contract_id.
Gemessen: Bedingung entfernt, tests/test_anmeldung.py bleibt grün.
Vorschlag: person_id gegen den Token prüfen, dazu ein Test mit fremder person_id.
```

- **Jeder Fund trägt eine Nummer**, `[R1]`, `[R2]`, … — durchlaufend über den ganzen Bericht, nicht
  je Domäne, und sie bleibt beim Sortieren. Sie ist der Griff, an dem die Reparatur den Fund
  anfasst.
- **Die Zeile „Gemessen" ist Pflicht, wo du gemessen hast**, und fehlt, wo du nur gelesen hast. Ein
  Fund ohne sie wiegt weniger, und das soll man ihm ansehen.
- **Gewicht zuerst**: was eine fremde Zeile erreichbar macht, vor allem anderen. Danach, was Daten
  halb schreibt. Erst danach, was nur ungeprüft ist.
- **Ein Vorschlag je Fund**, ein Satz. Nicht ausformuliert, nicht gebaut.

**Erst sammeln, dann sortieren.** Was dir auffällt, kommt in die Datei — auch das, von dem du beim
Aufschreiben noch nicht weißt, ob es trägt. Deshalb hat der Bericht **zwei Listen**; die zweite
macht sichtbar, was du entkräftet hast, statt es still fallenzulassen:

```
Angesehen, nicht als Fund gewertet
mensa · GET /meals/day-list ohne Ownership-Prüfung sah nach Klasse 1 aus; der
        Plan sagt „unbeschränkt", die Route ist richtig.
```

- **Trenn Fund von Geschmack.** Ein Endpunkt, den du anders geschnitten hättest, ist weder ein Fund
  noch eine Zeile in der zweiten Liste.
- **Eine Zeile am Ende**: welche Domänen ohne Fund durchgekommen sind.

## Zwischenmeldungen

Je abgeschlossener Domäne **eine Zeile** — Name, Zahl der Funde, wie viele Sicherungen du
herausgenommen hast und wie viele davon rot wurden. Am Ende ist der Bericht die Datei plus höchstens
zehn Zeilen Prosa drumherum.

## Was du nicht tust

- **Nichts ändern außer `pruefberichte/routen.md`.** Keinen Router, keinen Test, kein Commit, kein
  „ich hab's gleich mit repariert". Auch den Test nicht, dessen Lücke du gefunden hast: Ein Prüfer,
  der repariert, prüft danach seine eigene Arbeit.
- **Keine Sicherung liegen lassen.** `git status` nach jeder Domäne, und er ist sauber.
- **Nicht gegen den Plan urteilen, sondern gegen den Block.** Weicht die Route vom Plan ab, ist das
  ein Fund; weicht der Plan vom Block ab, auch — und der zweite wiegt schwerer, weil er sich beim
  nächsten Bau fortpflanzt. Die Rangfolge steht in `wb-docs/CLAUDE.md`.
- **Den Marken `[A]` und `[?]` nicht widersprechen.** Dass sie offen sind, ist kein Fund.
- **Wo dir etwas fehlt, um zu urteilen, wird das eine Zeile im Bericht.** Nicht anhalten, nicht
  fragen — ich sitze nicht daneben.
