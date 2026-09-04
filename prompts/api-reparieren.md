# Prompt: die Funde aus den Prüfberichten schließen

Gegenstück zu [`api-pruefen.md`](api-pruefen.md). Dort wird gemeldet, hier wird repariert. **Der
Reparateur baut, was der Block hergibt — und fragt, was er nicht hergibt.**

**Ein Bericht, ein Lauf.** Zuerst `wb-docs/pruefberichte/routen.md`: was keine einzelne
Domäne sieht und deshalb in gemeinsamem Code landet. Danach `stammdaten` und `querschnitt`, weil
ihre Korrekturen in die übrigen durchschlagen. **Diese drei nacheinander und im Hauptbaum** —
sie fassen `app/core/`, `app/db/`, `tests/conftest.py` und `wb-docs/api/gemeinsam.md` an, und das
ist dieselbe Stelle für alle drei.

**Die Fachdomänen danach laufen nebeneinander.** Jede fasst nur ihre Routendatei, ihre
Testdatei und ihre `-api.md` an; getrennt werden muss trotzdem bis zur Datenbank hinunter, weil
`tests/conftest.py` vor und nach jeder Suite truncatet. Das erledigt `spuren.sh`: je offenem Bericht
ein Baumpaar mit eigenem Compose-Stack und eine Session darauf, Effort `xhigh`. Es liest die
offenen Berichte aus `pruefberichte/`, nicht aus einer Liste — ein geschlossener Bericht ist eine
gelöschte Datei und fällt damit von selbst heraus.

**Alles bis zum Trennstrich ist Bedienanleitung und erreicht keinen Lauf.** `spuren.sh` schneidet es
ab und setzt `DOMÄNE` ein; was eine Session wissen muss, steht darunter.

Gestartet wird **in einer `wb-backend`-Session, die committet** — im Hauptbaum bei den ersten drei,
sonst im Backend-Baum ihrer Spur mit `wb-docs` als Schwesterverzeichnis daneben. `CLAUDE.md` dieses
Repos lädt sich von selbst, die von `wb-docs` nicht — die liest du zuerst, zusammen mit den Dateien
unten. Die Pfade nach `wb-docs` schreibt dieser Prompt deshalb aus; alles ohne Präfix liegt in
`wb-backend`.

Vorher: `git status` in beiden Repos sauber **und die Berichte sind committet.** Der Lauf löscht
seinen Bericht am Ende; ein nie committeter Bericht ist danach nicht gelöscht, sondern nie
dagewesen.

---

Es gelten [`gemeinsam.md`](gemeinsam.md), `CLAUDE.md` beider Repos und `wb-backend/README.md`.
Alles liest du zuerst und ich wiederhole es hier nicht.

Wir schließen die Funde aus `wb-docs/pruefberichte/routen-DOMÄNE.md` in `wb-backend`. Der Bericht
ist die Arbeitsliste, nicht die Anweisung. **Diese eine Domäne, und keine zweite.**

Die Datenbank bringst du selbst hoch, und **nur** sie: `podman-compose up -d db`. Läufst du in einer
Spur, published `caddy` die Ports aus der `.env` und kollidiert mit dem Hauptstack; gebraucht wird er
nicht, `pytest` läuft im eigenen Container gegen `db`.

**Auch der Bericht ist eine Behauptung.** Der Maßstab, den
[`schema-reparieren.md`](schema-reparieren.md) an den Schema-Bericht legt, gilt hier unverändert:
Ein Fund ist erst dann einer, wenn du die Stelle selbst geöffnet hast, und der Vorschlag darin ist
der eines Prüfers, der angegriffen und nicht gebaut hat. Trägt eine kleinere Änderung dieselbe
Regel, nimm die kleinere.

## Die eine Regel, aus der der Rest folgt

**Der Fund ist die Mutation.** Der Prüflauf hat Sicherungen herausgenommen, um zu sehen, ob die
Suite es merkt. Du hast das nicht mehr nötig: Ein echter Fund *ist* die herausgenommene Sicherung.
Also je Fund in dieser Reihenfolge:

1. **Den Test schreiben, gegen den unreparierten Code — er muss rot werden.**
2. Erst dann den Router ändern.
3. Denselben Test noch einmal, jetzt grün.

Wird der Test in Schritt 1 grün, ist eins von beidem wahr: Du hast etwas anderes gebaut, als der
Fund beschreibt, oder der Fund trägt nicht. Beides hältst du fest, statt weiterzugehen.

Damit prüft nicht der Reparateur seine eigene Arbeit, sondern die rote Messung — und die ist
mechanisch. Das ist der Grund, aus dem `api-pruefen.md` dem Prüfer das Reparieren verbietet, in der
einzigen Form, in der er auf dieser Seite noch trägt.

## Zwei Sorten Fund

Nicht jeder Fund ist ein Loch im Router, und die zweite Sorte ist die häufigere:

- **Der Router ist offen** (Klasse 1, 2, 5, 6). Der Weg oben trägt unverändert: Der Fehler selbst
  macht den neuen Test rot.
- **Der Router ist dicht, aber kein Test hält ihn** — die Funde mit der Zeile „Gemessen: … bleibt
  grün". Hier gibt es nichts zu reparieren außer der Suite, und der neue Test ist gegen den heilen
  Router von Anfang an grün. Also brauchst du die Mutation des Prüfers noch einmal: Bedingung
  heraus, dein neuer Test muss rot werden, `git checkout -- app/`, Test wieder grün. **Ohne diese
  Runde ist er nicht belegt** — und du hättest genau den Test gebaut, den dieser Prüfzyklus angreift.

Für beide gelten der Bau-Zwang vor jeder Messung und das Räumen der Datenbank nach einer roten aus
`api-pruefen.md`, „Die Methode" — dieselben zwei Fallen, aus demselben Grund, hier nicht wiederholt.

## Wann du baust und wann du fragst

Die vier Fälle aus [`schema-reparieren.md`](schema-reparieren.md), „Wann du baust und wann du
fragst", gelten unverändert; an der Stelle des Schemas stehen `wb-docs/api/DOMÄNE-api.md` und der Block,
den er nennt. Zwei Ergänzungen:

- **Tragen zwei Bauformen, schlägt der gemeinsame Hebel aus `wb-docs/api/gemeinsam.md` den Eigenbau in der
  Route** — auch den kürzeren. Eine Route, die den Hebel nachbaut, war im Prüflauf ein Fund; sie
  darf es nicht durch die Reparatur werden.
- **Braucht ein Fund DDL, ist er kein Routen-Fund mehr.** Er wird ein Ticket in `wb-docs/backlog/`, keine
  Migration im Vorbeigehen: Das Schema ist gegengeprüft, und eine Spalte, die
  nebenbei in einem Reparaturlauf entsteht, ist durch keine Prüfung gegangen.

**Es gilt „Ein Lauf ohne Rückfrage" aus [`gemeinsam.md`](gemeinsam.md).** Auch im Hauptbaum: Der
Lauf überlebt seinen eigenen Kontext nicht, und die Antwort käme später als sein Ende. Was sonst
eine Frage wäre, wird eine `[A]`-Marke an der Stelle, an die sie gehört, und steht am Ende als
`A1, A2 …` in der Meldung. Angehalten wird nur, wo jede Annahme etwas Schlechteres erzeugt als
nichts.

## Wo die Korrektur landet

| Der Fund sagt | Du änderst |
|---|---|
| Der Router lässt eine fremde Zeile durch | `app/routers/DOMÄNE.py`, dazu der Test |
| Der Test prüft etwas anderes als sein Name | den Rumpf, nicht den Namen — der Name ist die Zusage |
| Der Plan weicht vom Block ab | `wb-docs/api/DOMÄNE-api.md`; der Block schlägt den Plan |
| Der Hebel selbst trägt nicht | `app/core/`, `app/db/`, `wb-docs/api/gemeinsam.md` — nur im ersten Lauf |

Die Rangfolge bei Widerspruch steht in `CLAUDE.md`. Weicht der Router vom Plan ab und der Plan vom
Block, wird beides in einem Zug richtig — sonst meldet der nächste Bau die zweite Hälfte erneut.

## Was du liest, und in welcher Reihenfolge

1. **Den Bericht** — vollständig, samt der Liste „Angesehen, nicht als Fund gewertet".
2. **Den Code, den er nennt** — die Routendatei, ihr Modell, ihr Service, ganz und nicht im Ausschnitt.
3. **`tests/conftest.py`** und die Testdatei der Domäne.
4. **Erst danach `wb-docs/api/DOMÄNE-api.md`** und die Soll-Blöcke, die er nennt.

**Über Code, den du nicht geöffnet hast, urteilst du nicht** — auch dann nicht, wenn der Bericht
ihn zitiert. Das Zitat ist der Stand einer fremden Session, nicht der Stand der Datei.

## Wie du läufst

Je Fund die Testdatei der Domäne, nach dem Bau, wie in `api-pruefen.md`. Am Ende des Laufs einmal
der volle: `pytest`, `ruff check`, `ruff format --check`, `mypy app`, `./schema-check.sh`. In die
Meldung kommt der Rückgabewert je Aufruf, nicht der Text auf dem Schirm. Die Zahl der Tests ist die
des Gesamtlaufs plus deine neuen — weicht sie anders ab, hast du eine Datei verloren.

## Der Commit

**Ein Commit je Fund**, oder je Gruppe von Funden, die dieselbe Stelle anfassen — nicht einer am
Ende: Der Lauf überlebt seinen eigenen Kontext nicht, und was uncommittet in ihm liegt, ist beim
Abbruch weg. Betreff nennt die Route, Rumpf die Kennungen:

```
Die fremde Familie erreicht den Kontakt nicht mehr

STAMMDATEN-R4
```

Zwei Repos, zwei Commits: die Korrektur in `wb-backend`, der nachgezogene Plan in `wb-docs`. Nicht
pushen.

**Zuletzt, wenn der volle Lauf durch ist:** `git rm` auf `wb-docs/pruefberichte/routen-DOMÄNE.md`. Der Beleg,
dass ein Fund geschlossen ist, ist der reparierte Router samt seinem rot gewesenen Test; die
Historie hält den Bericht. Bleibt ein Fund offen, bleibt die Datei — mit ihm allein darin.

## Was du nicht tust

- **Nichts außerhalb der Funde deines Berichts.** Was dir nebenbei auffällt, kommt in keinen Commit;
  eine Zeile am Ende genügt, dann entscheide ich. Kein Aufräumen im Vorbeigehen, keine Umbenennung,
  keine Verallgemeinerung, die kein Fund verlangt.
- **Keinen Test an sein Ergebnis anpassen.** Wird er rot, weil der Router recht hat, ist das das
  Ergebnis. Keine gelockerte Zusicherung, kein Wert aus dem Fixture in die Erwartung kopiert, kein
  Hilfsskript neben der Suite.
- **Keine zweite Domäne in dieser Session.** Auch keine kleine.
- **Keine Durchsicht der eigenen Arbeit am Ende.** Der volle Lauf oben ist der Beleg; eine zweite
  Runde über dieselben Dateien kostet und findet nichts.
- **Den Bericht nicht ändern.** Er ist Beweisstück, bis er gelöscht wird, nicht Arbeitsblatt.

## Was du meldest

Je geschlossenem Fund **eine Zeile**: Kennung, was geändert wurde, rot-grün ja oder nein.

Am Ende höchstens fünfzehn Zeilen: was geschlossen ist, was an einer Antwort hängt, was du als Fund
verworfen hast und warum, und die Rückgabewerte des vollen Laufs. Die verworfenen und die offenen
Funde führst du vollständig auf.

Halt die Nachricht knapp — der Beleg steht im Commit, nicht in der Zusammenfassung.
