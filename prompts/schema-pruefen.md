# Prompt: das gebaute Schema gegenprüfen

Gegenstück zu [`prompts/schema-bauen.md`](prompts/schema-bauen.md). Dort entsteht das SQL, hier wird es
angegriffen. **Der Prüfer baut nicht** — er meldet, und du entscheidest.

Der Lauf ist nur etwas wert, wenn er unabhängig ist: eine frische Session, die den Bau nicht
mitgemacht hat und die Begründungen in den Dateien für Behauptungen hält, nicht für Belege.

Effort `xhigh`. Vorher `git status` sauber: Der Lauf legt genau eine Datei an, `pruefberichte/aktuell.md`,
und ändert sonst nichts. Alles unter dem Strich ist der Prompt.

---

Es gelten [`gemeinsam.md`](gemeinsam.md) (wie du mit mir redest, kein Subagent urteilt) und
`CLAUDE.md`. Beides liest du zuerst und ich wiederhole es hier nicht.

Wir prüfen das Datenmodell unter `schema/`. Es ist aus den Soll-Blöcken abgeleitet; ob das
gelungen ist, ist deine Frage. Du änderst nichts und baust nichts nach — auch nicht „nur eben
schnell".

## Die eine Regel, aus der der Rest folgt

**Jeder Kommentar in einer `.sql` ist eine Behauptung, kein Beleg.** Das Schema erklärt sich
selbst: es nennt je Tabelle den Block, der sie verlangt, zitiert wörtlich, benennt den Löschanker
und schreibt hin, welche Spalte bewusst fehlt. Genau das prüfst du nach — mit dem Block in der
Hand, nicht mit dem Kommentar.

Der teuerste Fehler dieses Projekts ist nicht die vergessene Spalte. Es ist die **plausible
Begründung für etwas Falsches**: ein Satz, der klingt wie ein Zitat und keines ist, ein Löschanker,
der auf ein Feld zeigt, das die Frist gar nicht tragen kann, ein „bewusst KEINE …", das einen
Block überstimmt, der es gar nicht hergibt. Solche Stellen lesen sich sauber und stehen jahrelang.

## Was du liest, und in welcher Reihenfolge

Erst das Schema, dann die Quellen — nicht umgekehrt. Wer die Blöcke zuerst liest, findet im SQL,
was er erwartet. Diese Reihenfolge gilt **je Domäne**, nicht einmal für den ganzen Lauf; warum,
steht im nächsten Abschnitt.

**Einmal zu Beginn**, weil es für alle Domänen gilt:

1. **`soll-prozesse/hebel.md`** — was für alle Prozesse gilt. Ein Hebel, den das Schema je Domäne
   nachbaut statt einmal, ist ein Fund; ein Hebel, den es gar nicht trägt, auch.
2. **`rules.md`**, Abschnitte 1, 3 und 7, und **`grenzkarte.md`**.

**Dann je Domäne**, und die nächste fängst du erst danach an:

3. **`schema/<domäne>-schema.sql` samt Prüfskript**, vollständig. Notier dir dabei jede Behauptung,
   die du prüfen wirst: Zitat, Löschanker, „bewusst KEINE", `[A]`, `[A!]`, `[?]`.
4. **Die Blöcke in `soll-prozesse/`, die diese Domäne nennt** — vollständig, nicht überflogen.

**Punkte 1 bis 4 liest du selbst** — aus dem Grund, der in `gemeinsam.md` steht.

**Die Rangfolge bei Widerspruch** steht in `CLAUDE.md`. Sie wird nie durch das Schema entschieden:
dass eine Tabelle dasteht, belegt nichts über die Regel, die sie tragen soll.

## Der Lauf überlebt seinen eigenen Kontext

Schema, Prüfskripte, Blöcke und Referenzen sind zusammen rund 750 KB — mehr, als in ein Fenster
passt, und der Lauf wird unterwegs zusammengefasst. Wer alles zuerst liest und erst am Ende
urteilt, verliert dabei genau das, worauf dieser Prompt gebaut ist: den Satz aus dem Block, gegen
den das Zitat gehalten wird. Deshalb liegt **kein Fund in deinem Gedächtnis**:

- **Eine Domäne ist abgeschlossen, bevor die nächste anfängt.** Lesen, urteilen, Funde
  aufschreiben, dann weiter. Kein Sammelurteil am Ende.
- **Funde schreibst du sofort nach `pruefberichte/aktuell.md`**, angehängt, im Format unten, je Domäne unter
  einer eigenen Überschrift. Das ist die einzige Datei, die dieser Lauf anlegt.
- **Wo du stehst, sagt `pruefberichte/aktuell.md`** und nicht deine Erinnerung. Fang nach einer
  Zusammenfassung bei der ersten Domäne an, die dort noch keine Überschrift hat — auch dann, wenn
  du meinst, sie schon gelesen zu haben.
- **Den Schlussbericht erzeugst du aus der Datei**, nicht aus dem Kopf.

Was über alle Domänen geht — Fehlerklasse 6 und der Gesamtlauf — kommt zum Schluss und mechanisch:
`grep` und ein Ladelauf, nicht die Erinnerung an vierzehn Dateien.

## Die sieben Fehlerklassen

Nach diesen suchst du, in dieser Reihenfolge. Jede ist in diesem Projekt schon einmal wirklich
vorgekommen.

1. **Eine Regel steht im Block und nirgends im Schema.** Geh die Blöcke Satz für Satz durch:
   Alles unter „Was dabei erhoben wird" ist eine Zusage. Findest du dafür keine Spalte, keinen
   Constraint und keine begründete Auslassung, ist das ein Fund.
2. **Ein Constraint verbietet etwas, das ein Block erlaubt.** Die gefährlichste Klasse, weil sie
   erst im Betrieb auffällt und dann eine Migration kostet. Lies jeden `UNIQUE` und jeden `CHECK`
   gegen die Frage: Welcher reale Fall aus einem Block bricht hier? Doppelbesetzungen, zweite
   Unterschriften, Geschwister mit derselben Bankverbindung, dieselbe Person in zwei Rollen.
3. **Ein Zitat steht so nicht im Block.** Prüf jedes wörtliche Zitat gegen die Quelle — Wortlaut,
   nicht Sinn. Ein sinngemäßes Zitat ist ein Fund, auch wenn die Aussage stimmt.
4. **Ein Löschanker trägt nicht.** Jede Tabelle mit Personenbezug nennt einen. Prüf zweierlei: Gibt
   es das Feld, auf das er zeigt? Und kommt der Lösch-Lauf über Fremdschlüssel wirklich dorthin —
   oder blockiert ein `RESTRICT` unterwegs, ohne dass das jemand aufgeschrieben hat?
5. **Ein Prüfskript prüft nichts.** Siehe unten, eigener Abschnitt.
6. **Ein Sachverhalt steht an zwei Orten.** `rules.md` Abschnitt 1. Nimm die Liste der
   Spaltennamen, die in mehreren Tabellen vorkommen, und sieh jeden an: zwei Zeilen mit demselben
   Namen sind meist zwei Sachverhalte, manchmal aber einer.
7. **Die Grenzkarte wurde überstimmt, ohne dass ein Block das hergibt.** Das Schema darf von ihr
   abweichen — aber nur mit einem Blocksatz, der jünger ist und die Sache wirklich entscheidet.
   Steht als Begründung nur eine Überlegung, ist das ein Fund.

## Prüfskripte prüfen sich nicht selbst

Zu jeder `.sql` liegt ein `-schema-check.sql`. Dass es grün durchläuft, heißt für sich genommen
nichts. Vier Fallen, drei davon sind hier schon zugeschnappt:

- **Die Gegenprobe läuft ins Leere.** Ein `UPDATE … WHERE …`, das null Zeilen trifft, ist
  erfolgreich — und eine `expect_reject`-Probe darauf meldet fälschlich „Regel nicht gebaut" oder,
  schlimmer, eine `expect_accept`-Probe meldet Erfolg, ohne dass je etwas geschrieben wurde. Prüf
  je Gegenprobe, ob die Zeile, die sie ändern will, an dieser Stelle überhaupt existiert.
- **Die Gegenprobe ist nur isoliert grün.** Ein Skript, das mit erfundenen Fremdschlüssel-Werten
  arbeitet, läuft durch, solange die Zieltabelle noch nicht geladen ist. Lass deshalb **jedes**
  Prüfskript gegen die **vollständige** Datenbank laufen, nicht nur gegen seine eigenen
  Voraussetzungen.
- **Die Gegenprobe wird aus dem falschen Grund abgewiesen.** Eine Probe, die den `CHECK` belegen
  soll und in Wahrheit am `NOT NULL` scheitert, belegt den `CHECK` nicht. `expect_reject` fängt
  `check_violation`, `foreign_key_violation`, `unique_violation` und `not_null_violation` in einem
  Topf und schreibt nirgends auf, welches davon zugeschlagen hat — die Meldung „ok (abgewiesen)"
  sagt dir also nicht, was du wissen willst. Setz das Statement einzeln ab und lies den
  Constraint-Namen aus der Fehlermeldung; das Skript änderst du dafür nicht. Über alle Domänen sind
  das ein paar hundert Proben — geh nicht alle durch, sondern die, deren Regel dir beim Lesen der
  Blöcke ohnehin fraglich war.
- **Eine Regel hat gar keine Gegenprobe.** Zähl je Domäne die Regeln aus den Blöcken gegen die
  Proben im Skript. Eine Regel ohne Gegenprobe gilt als nicht gebaut — auch wenn der Constraint
  dasteht.

## Wie du läufst

Aufruf, `ON_ERROR_STOP=1` und Ladereihenfolge stehen in `CLAUDE.md`. Drei Schritte, in dieser Folge:

1. **Alle `schema/*-schema.sql` in eine leere Datenbank.** `ags`, `klassenbildung`, `m365` und
   `selfservice` legen keine Tabellen an; sie zu laden ist ein Nichts. Scheitert der Ladelauf **in
   der dokumentierten Reihenfolge**, ist das ein Fund und kein Bedienfehler.
2. **Alle Prüfskripte gegen diese vollständige Datenbank**, nicht einzeln gegen ihre
   Voraussetzungen. Jedes rollt am Ende zurück, keines stört also das nächste. In den Bericht kommt
   der Rückgabewert je Skript, nicht der Text auf dem Schirm.
3. **Danach greifst du das Schema selbst an.** Schreib eigene `INSERT`s für die Fälle, die dir beim
   Lesen der Blöcke aufgefallen sind — besonders für Klasse 2 oben. Was durchgeht und nicht sollte,
   ist ein Fund; was abgewiesen wird und dürfte, ebenso.

Geht das nicht, sag es einmal am Anfang und prüf trotzdem lesend durch.

## Was du meldest

Ein Bericht, keine Änderung. Je Fund drei Zeilen in dieser Form, nach Gewicht sortiert:

```
[F1] anmeldung · Klasse 2 · contracts
Block 09 sagt „…"; `uq_contracts_running` weist den zweiten Fall ab.
Vorschlag: partieller Index über … statt UNIQUE.
```

- **Jeder Fund trägt eine Nummer**, `[F1]`, `[F2]`, … — durchlaufend über den ganzen Bericht und
  nicht je Domäne. Du vergibst sie beim Aufschreiben, und sie **bleibt, wenn du am Ende nach
  Gewicht sortierst**: Sie ist der Griff, an dem die Reparatur den Fund anfasst und an dem ihr
  Commit hängt. Ein zweiter unabhängiger Lauf zählt weiter, wo der erste aufgehört hat — die
  Nummern sind über den Bericht eindeutig, nicht über den Lauf. Ein `[F]` ohne Nummer ist kein
  Fund, den jemand später ansprechen kann.
- **Gewicht zuerst**: was im Betrieb bricht, vor dem, was nur unsauber ist.
- **Je Fund die Belegstelle**: welcher Block, welcher Satz, welche Zeile im SQL.
- **Ein Vorschlag je Fund**, ein Satz. Nicht ausformuliert, nicht gebaut.

**Erst sammeln, dann sortieren.** Was dir auffällt, kommt in die Datei — auch das, von dem du beim
Aufschreiben noch nicht weißt, ob es trägt. Aussortiert und nach Gewicht gebracht wird am Ende, in
einem eigenen Durchgang über `pruefberichte/aktuell.md`. Der umgekehrte Weg, schon beim Lesen zu entscheiden,
ob etwas den Bericht wert ist, kostet zuverlässig die leisen Funde — und die leisen sind hier die
teuren: Ein falsches Zitat bricht nirgends im Betrieb.

Deshalb hat der Bericht **zwei Listen**. Die zweite ist kurz und macht sichtbar, was du entkräftet
hast, statt es still fallenzulassen:

```
Angesehen, nicht als Fund gewertet
mensa · `uq_meal_subscriptions_child` sah nach Klasse 2 aus; Block 11 kennt nur
        ein Abo je Kind und Schuljahr, der UNIQUE trägt.
querschnitt · `signatures` ohne Gegenprobe im eigenen Skript — sie steht in
        anmeldung-schema-check.sql, weil der Fremdschlüssel erst dort entsteht.
```

- **Trenn Fund von Geschmack.** Eine Tabelle, die du anders geschnitten hättest, ist weder ein Fund
  noch eine Zeile in der zweiten Liste. Dort steht, was du geprüft und entkräftet hast — nicht, was
  dir nicht gefällt.
- **Eine Zeile am Ende**: welche Domänen ohne Fund durchgekommen sind.
- **Die Sortierung nach Gewicht nennt die Nummern**, nicht nur die Domänen — sonst ist die Liste,
  aus der die Reparatur ihre Pakete schneidet, nicht auf die Funde zurückzuführen.

## Zwischenmeldungen

Je abgeschlossener Domäne **eine Zeile** — Name, Zahl der Funde, Prüfskript grün oder rot. Am Ende
ist der Bericht die Datei plus höchstens zehn Zeilen Prosa drumherum; die beiden Listen zählen nicht
mit.

## Was du nicht tust

- **Nichts ändern außer `pruefberichte/aktuell.md`.** Keine `.sql`, kein Commit, kein „ich hab's gleich mit
  repariert". Auch das Prüfskript nicht, dessen Lücke du gefunden hast.
- **Keinen `pruefberichte/NN.md` liest du** — heute sind das `pruefberichte/01.md` bis
  `pruefberichte/05.md`, morgen mehr. Das sind die Berichte früherer Zyklen, deren Funde alle
  geschlossen sind. Wer sie aufschlägt, sucht danach dort, wo schon einmal gesucht wurde — und
  übersieht, was seither dazugekommen ist. Findest du unabhängig wieder, was dort stand, ist das
  ein Rückschritt und wiegt schwer; das merkst du aber nur, wenn du sie nicht gelesen hast. Die
  Datei ohne Nummer, `pruefberichte/aktuell.md`, ist dagegen deine eigene und existiert am Anfang nicht.
- **Den Marken `[A]`, `[A!]` und `[?]` nicht widersprechen.** Sie sind bewusst offen; dass sie
  offen sind, ist kein Fund. Ein Fund ist, wenn eine davon etwas offenlässt, das ein Block längst
  entscheidet — bei `[A!]` wiegt das schwer, denn an ihr hängt der Schnitt der Domäne und nicht
  ein Feld. Alle `[A!]`, die dir untergekommen sind, nennst du am Ende in je einer Zeile: Domäne,
  Aussage, ob ein Block sie entscheidet.
- **Wo dir etwas fehlt, um zu urteilen, wird das eine Zeile im Bericht.** Nicht anhalten, nicht
  fragen — ich sitze nicht daneben.
