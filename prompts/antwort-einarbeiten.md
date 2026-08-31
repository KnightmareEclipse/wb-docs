# Prompt: eine Antwort aus der Schule einarbeiten

Für den Fall, dass jemand geantwortet hat — per Mail oder aus einem Gespräch. Gegenstück zu
[`fragen.md`](../fragen.md): Dort steht, **wie** gefragt wird, hier wird die Antwort verteilt.

Eine Session je Antwortmail, im Hauptbaum von `wb-docs`. Effort `xhigh`. Dieser Lauf **hält an** —
er ist das Gegenteil der Reparaturläufe: Ich sitze daneben, und was gekippt wird, kippt nicht ohne
mich.

Vorher: `git status` sauber, und der Thread liegt als **Textdatei** — in Outlook „Speichern unter"
mit Nur-Text, oder den Inhalt in eine `.txt` kopieren. Kein `.msg`: Das ist ein Binärformat, und
das Werkzeug dafür ist auf dieser Maschine nicht installiert. Verloren geht dabei nichts, worauf es
ankommt — die Kopfblöcke, an denen die Runden hängen, sind selbst Text. Der Pfad kommt unten
anstelle von `MAILPFAD`.

---

Es gelten [`gemeinsam.md`](gemeinsam.md) und `CLAUDE.md`. Beides liest du zuerst.

Der Thread liegt in `MAILPFAD`, aus Outlook als Text gespeichert. Es ist **kein einzelner
Briefwechsel, sondern die dritte oder vierte Runde**, und die Geschäftsführung schreibt ihre Sätze
**in meine hinein** statt darunter. Daraus folgt die Reihenfolge der Arbeit: erst die Runden
trennen, dann in jeder Runde die Sätze zuordnen, dann erst lesen, was es bedeutet.

## Erstens: die Runden trennen

Ein Outlook-Thread steht **umgekehrt chronologisch** — das Neueste oben, darunter die vorige Runde,
und so fort. Getrennt wird an den Kopfblöcken, die Outlook einfügt (`Von:` / `Gesendet:` / `An:` /
`Betreff:`, oder `-----Ursprüngliche Nachricht-----`). Die nummerierst du **von unten nach oben**,
`R1` ist die älteste, und nennst je Runde Absender und Datum.

Zitatzeichen (`>`, `>>`) sind ein Hinweis und kein Beweis: Outlook markiert Zitate durch Einrückung
und Farbe, und beides ist beim Speichern weg. Verlass dich auf die Kopfblöcke.

## Zweitens: in jeder Runde die Sätze zuordnen

**Rate die Zuordnung nicht — prüfe sie.** Meine Hälfte ist nicht verloren: Der Wortlaut meiner
Fragen steht in `fragen.md`, Fragen 9–12 sind die der Geschäftsführung. Was im Thread steht und
dort **nicht** wiederzufinden ist, ist ihre Antwort oder eine Ergänzung von mir. Wo Zitatzeichen
und Abgleich streiten, gewinnt der Abgleich.

Das Ergebnis ist eine **nummerierte Liste von Paaren, je Runde**: mein Satz, ihr Satz, im Wortlaut
beider. Die legst du mir **zuerst und vollständig** vor, bevor du einen einzigen bewertest. Eine
Stelle, die du nicht zuordnen kannst, kommt als eigener Punkt hinein, mit der Frage, wem sie
gehört — geraten wird nicht.

**Antworten müssen nicht zu Fragen 9–12 gehören.** Wer schreibt, schreibt auch zu anderem. Was eine
Frage aus einem anderen Gespräch trifft, wird dort eingeordnet, nicht verworfen.

## Drittens: die Runden gegeneinander halten

Hier liegt der Grund, aus dem dieser Thread nicht wie eine einzelne Mail zu lesen ist.

- **Sagt sie zur selben Sache in zwei Runden Verschiedenes, gilt die jüngere** — aber der
  Widerspruch wird **benannt**, nie stillschweigend aufgelöst. Er ist der wertvollste Fund im
  ganzen Thread und gehört auf den Zettel fürs Gespräch, damit ich ihn bestätigen lasse.
- **Was aus einer früheren Runde bereits in der Doku steht, kann jetzt falsch sein — und ich weiß
  nicht mehr, was davon eingearbeitet ist.** Also prüfst du es, für jede Aussage einzeln, und nicht
  nur am Dateistand: `grep` über `soll-prozesse/`, `schema/`, `api/`, `grenzkarte.md` und
  `backlog/` sagt, **was** dasteht; `git log -S` mit einem Kernbegriff der Aussage sagt, **wann und
  warum** es hineinkam. Deckt sich das Datum eines Commits mit einer Runde des Threads, hast du die
  Einarbeitung gefunden. Kippt die jüngere Runde sie, ist die Doku **zurückzudrehen** — ein
  Eingriff, kein Nachtrag.
- **Was in einer frühen Runde beantwortet und nie eingearbeitet wurde**, ist kein alter Hut,
  sondern eine offene Antwort. Sie wird behandelt wie eine neue.

## Viertens: der Zettel fürs Gespräch — **vor** allem Einarbeiten

Das Gespräch ist eher als jede Datei. Der Zettel entsteht deshalb **fertig, bevor du eine einzige
Datei anfasst** — endet der Lauf vorher, habe ich trotzdem etwas in der Hand. Er trägt drei Sorten
Punkt, je mit dem **Wortlaut**, mit dem ich sie ansprechen kann, in der Form, die `fragen.md` für
ihre Fragen verwendet — denn genau dorthin wandert ein Punkt, der im Gespräch keine Antwort findet:

- **Was unbeantwortet blieb** — auch das, was ich in einer frühen Runde gefragt habe und was seither
  untergegangen ist.
- **Was ich bestätigen lassen muss**, weil eine spätere Runde eine frühere kippt. Je Punkt beide
  Fassungen im Wortlaut, mit Runde und Datum, damit ich sie ihr vorhalten kann.
- **Was die Antwort neu aufgeworfen hat** — samt dem, was daran hängt, wenn es so bleibt.

Den Zettel legst du mir vor. Er wird **keine Datei**, solange ich nichts anderes sage: `fragen.md`
trägt die Fragen, die gestellt werden, nicht die eines einzelnen Termins.

## Fünftens: ein Paar nach dem anderen einarbeiten

Erst wenn der Zettel steht, gehst du die Punkte durch — **einen nach dem anderen und in einem Zug**,
nach jedem erledigten kommt direkt der nächste, ohne dazwischen zu fragen, ob es weitergehen soll.
Angehalten wird nur, wo ich entscheiden muss.

Je Paar sagst du dreierlei, mehr nicht:

1. **Was sie beantwortet** — reicht die Antwort nach dem Kriterium, das `fragen.md` zu dieser Frage
   nennt? Ein „im Prinzip ja" reicht nicht, wenn das Kriterium einen Betrag oder eine Frist verlangt.
2. **Was sie umwirft.** Der teure Fall, und der Grund für diesen Lauf.
3. **Was sie offenlässt** — für das Gespräch.

**Was umgeworfen wird, suchst du, statt es zu erinnern.** Eine gekippte Entscheidung steht selten
an einer Stelle: `grep` über `soll-prozesse/`, `schema/`, `api/`, `backlog/` und `grenzkarte.md`,
und jede Fundstelle mit Pfad und Zeile nennen. **Über eine Datei, die du nicht geöffnet hast,
urteilst du nicht.** Erst wenn die Liste der betroffenen Stellen steht, sagst du, was daraus folgt.

**Änderst wird nichts ohne mein Go.** Du legst je Paar vor, was zu ändern wäre und was es kostet;
sage ich zu, setzt du es sofort um und gehst weiter. Das gilt besonders für `schema/`: Dort ist
eine Änderung eine Migration in `wb-backend` und keine Zeile hier.

Wohin eine beantwortete Frage wandert, steht in `fragen.md`, „Wenn eine Antwort da ist" — vier
Stellen in fester Reihenfolge. Ich wiederhole sie hier nicht, und du hältst dich daran, auch wenn
es beim einzelnen Punkt umständlich wirkt.

## Was am Ende steht

Der Zettel steht schon. Dazu: **was eingearbeitet ist**, je Punkt eine Zeile mit den berührten
Pfaden, und **was offen blieb**, vollständig und ohne Auslassung.

Was die Geschäftsführung nicht entscheiden kann, wird ein `[?]` mit ihrem richtigen Adressaten,
keine erfundene Antwort.
