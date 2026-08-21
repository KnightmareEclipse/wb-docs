# Prompt: alle offenen Domänen bauen, in einem Zug

Einmal absenden, dann läuft es durch. Die Session fragt nichts, schreibt die Dateien selbst und committet je Domäne. Du liest hinterher.

Für eine einzelne Domäne im Gespräch — etwa eine Nachbesserung nach der Abnahme — nimmst du [`schema-prompt.md`](schema-prompt.md); zum Gegenprüfen des fertigen Laufs [`schema-pruef-prompt.md`](schema-pruef-prompt.md). Der Preis dieser Betriebsart: Entscheidungen, die du sonst vorher beantwortet hättest, prüfst du hinterher. Sie stehen als `[A!]` im Schlussbericht und in den Dateien.

Effort `xhigh`, Thinking an. Vorher `git status` sauber. Alles unter dem Strich ist der Prompt.

---

Wir bauen das Datenmodell **neu**, über alle Fachdomänen, in einem Durchgang. Welche es gibt, steht in `wb-docs/domains/grenzkarte.md`. Nimm sie alle — auch die schon einmal gebauten, und auch die, für die dort festgelegt ist, dass sie keine eigenen Tabellen brauchen; dann ist die Feststellung „nichts zu bauen" das Ergebnis für diese Domäne.

**Das ist ein Neubau, keine Fortschreibung.** Die Schemata in `wb-docs/domains/` sind ein Vorentwurf, den dieser Lauf ersetzt: Domäne für Domäne gebaut, jede gegen den Blockstand ihres Tages, keine gegen den ganzen Prozess. Genau deshalb wird neu gebaut. Was hier entsteht, leitest du selbst aus den Soll-Blöcken ab — Einzelheiten in [`schema-prompt.md`](schema-prompt.md), Abschnitt „Drei Referenzen und ein Vorentwurf".

## Wohin geschrieben wird

Alles nach `schema/` **in diesem Repo** (`wb-brainstorming`), je Domäne zwei Dateien:

- `schema/<domäne>-schema.sql`
- `schema/<domäne>-schema-check.sql`

`<domäne>` ist der kurze deutsche Kleinbuchstabenname (`mensa`, `putzdienst`, `klassenorganisation`).

**In `wb-docs` änderst du nichts** — dort wird nur gelesen.

## Was du liest

Die Leseliste aus [`schema-prompt.md`](schema-prompt.md), Abschnitt „Was du vorher liest, und wozu", gilt unverändert — samt der Regel, dass Blöcke und Grenzkarte durch deine Hände gehen und nicht durch die eines Subagenten, samt der Rangfolge bei Widerspruch und samt dem Abschnitt „Drei Referenzen und ein Vorentwurf".

Aus den **sieben Schemata in `wb-docs`** nimmst du genau zwei Dinge: die Konventionen unverändert (Kommentarform, Schlüssel, Constraint-Namen) und ein unbelegbares Feld als Hinweis für die Abweichungsliste. Keine Struktur, keine Entscheidung, keinen Schnitt. Eine dortige Lösung ist keine Präzedenz — sie wurde ohne die Blöcke getroffen, die du gerade gelesen hast.

**Die Domänen dieses Laufs kennen einander, und das ersetzt die Präzedenz.** Was du selbst zwei Domänen vorher nach `schema/` geschrieben hast, ist Bestand: darauf zeigst du per Fremdschlüssel, das baust du nicht nach, und dessen Muster hältst du durch. Der einzige Vorlauf, dem du glaubst, ist dein eigener aus diesem Lauf.

## Du hältst nicht an

Du arbeitest autonom. Ich sitze nicht daneben und kann nichts beantworten — eine Rückfrage blockiert die Arbeit, bis ich zufällig hinschaue.

- **Wo Blöcke, Grenzkarte und die drei Referenzen nicht reichen, entscheidest du, markierst es und baust weiter.** Nicht anhalten, nicht um Erlaubnis fragen, keine Varianten zur Auswahl stellen.
- **Prüf deinen letzten Absatz, bevor du den Zug beendest.** Ist er ein Plan, eine Frage, eine Liste nächster Schritte oder ein Versprechen („ich würde als Nächstes…"), dann tu das jetzt. Beenden erst, wenn alle Domänen gebaut sind und der Gesamtdurchgang gelaufen ist.
- **Was hier niemand wissen kann**, wird eine `[?]`-Marke mit Adressat — die ist für die Leute in der Schule. Nichts ausdenken.

## Zwei Marken statt einer Fragerunde

Im Gespräch hättest du gefragt; hier trägt die Datei die Frage:

- **`[A]`** wie gewohnt: Aussage, Alternative, Preis. Kippt sie, ändert sich ein Feld oder ein Constraint.
- **`[A!]`** für eine Annahme, die den Schnitt trägt: Kippt sie, wird die Domäne umgebaut, nicht nachgebessert. Das sind die, die ich sonst als Frage bekommen hätte.

Beide stehen an genau der Stelle, an die sie gehören, im Format aus [`schema-prompt.md`](schema-prompt.md). Alle `[A!]` sammelst du zusätzlich im Schlussbericht — das ist meine Triage-Liste, und daran hängt, ob diese Betriebsart trägt.

## Reihenfolge, Dateien, Commits

- **Leg die Reihenfolge zu Beginn fest und nenn sie in einer Zeile.** Berührt eine Domäne eine andere, geht die zuerst, die die Tatsache besitzt — Stammdaten und die Querschnitts-Entitäten Q1–Q5 also vor allem, was auf sie zeigt.
- **Eine Domäne ist abgeschlossen, bevor die nächste anfängt.** `.sql`, Prüfskript, Commit, dann weiter. Kein Sammelcommit am Ende.
- **Ein Commit je Domäne**, Betreff im Ton der bestehenden Historie dieses Repos. Nur committen, nicht pushen.
- Die Regel „Datei anfassen erst nach meinem OK" aus dem Dialogprompt gilt hier **nicht** — der Commit je Domäne tritt an ihre Stelle: Ich prüfe hinterher in Portionen statt vorher in Runden.

## Der Lauf überlebt seinen eigenen Kontext

Ein Durchgang über alle Domänen liest mehr, als in ein Fenster passt, und wird unterwegs zusammengefasst. Deshalb liegt **kein Zustand in deinem Gedächtnis, den du nicht wiederfinden kannst**:

- **Wo du stehst, sagen `git log --oneline` und `ls schema/`** — nicht deine Erinnerung. Fang nach einer Zusammenfassung dort an, statt eine Domäne zweimal oder gar nicht zu bauen.
- **Den Schlussbericht erzeugst du aus den Dateien**, nicht aus dem Kopf: `grep -n '\[A!\]' schema/*.sql` ist die Triage-Liste, `grep -n '\[A\]'` die Zählung je Domäne. Eine `[A!]`, die du gesetzt und dann vergessen hast, ist im Bericht dieselbe Lücke wie eine, die du nie gesetzt hast.
- **Je Domäne liest du die Blöcke neu, die sie berührt.** Dass du sie drei Domänen vorher schon gelesen hast, trägt nicht — das wörtliche Zitat an jeder Tabelle stammt aus dem Block, nicht aus deinem Gedächtnis an ihn.

## Delegation

Wie in [`schema-prompt.md`](schema-prompt.md): Referenzschemata gern, Blöcke und Grenzkarte nie. Dazu in dieser Betriebsart:

- **Erlaubt:** `*-schema.sql` nach einer Tatsache durchsuchen — die in `wb-docs` wie die, die in diesem Lauf schon entstanden sind. Die Antwort ist eine Fundstelle, kein Zitat, da geht nichts verloren.
- **Nicht erlaubt:** eine Domäne von einem Subagenten bauen lassen, auch nicht teilweise, auch nicht parallel zu einer anderen. Domänengrenzen und „ein Ort pro Sachverhalt" sind genau das, was zwei parallele Agenten verletzen, und niemand sieht es hinterher.
- **Nicht erlaubt:** einen Subagenten deine Arbeit prüfen lassen. Prüfen tust du im Hauptlauf.

## Es gilt unverändert

Aus [`schema-prompt.md`](schema-prompt.md), wörtlich und ohne Abstriche — lies die Abschnitte, ich wiederhole sie hier nicht:

- **Die Regeln fürs Modell** — 3NF, ein Ort pro Sachverhalt, Schlüssel und Constraint-Namen, Lookup oder `CHECK`, drei Zustände, Löschanker, keine konstruierten Randfälle.
- **Nachvollziehbarkeit** — Herkunft mit wörtlichem Zitat, Begründung nicht offensichtlicher Spalten, bewusst fehlende Spalten, Änderungsspur.
- **Verständlichkeit** — Lesepfad, englische Bezeichner, deutsche Kommentare, Glossar, nichts was SQLAlchemy nicht ausdrückt.
- **Länge** — die Satzbudgets für Spalten-, Tabellen- und Kopfkommentar.
- **So sieht eine fertige Tabelle aus** — das Beispiel ist die Vorlage.
- **Die Abweichungsliste** — für jede Domäne, die es in `wb-docs` schon gibt.

## Und das gilt dort nicht

Vier Stellen des Dialogprompts setzen voraus, dass ich antworte. Sie sind hier ersatzlos gestrichen, damit du nicht selbst entscheiden musst, welche Datei gewinnt:

- **„Reihenfolge: erst der Entwurf, dann die Fragen"** und **„Was du mich fragst"** — hier wird nicht gefragt, sondern markiert. Das Format der `[A]` aus dem ersten Abschnitt gilt weiter, die Fragerunde daraus nicht.
- **„Eine Domäne ist erst fertig, wenn kein `[A]` mehr in der Datei steht"** — genau umgekehrt: Die Marken **bleiben** stehen, sie sind das Ergebnis dieser Betriebsart. Sie verschwinden erst, wenn ich sie beantwortet habe.
- **„Erst nach meinem OK zum Schema: das Prüfskript"** — es entsteht sofort, vor dem Commit derselben Domäne.
- **„Wie du mit mir redest"** — ersetzt durch „Zwischenmeldungen" und „Der Schlussbericht" unten. Nur „Ergebnis zuerst" und „keine Zusammenfassung dessen, was du gerade geschrieben hast" gelten auch dort.

## Was du je Domäne lieferst

1. **`schema/<domäne>-schema.sql`** — vollständig. Kein Auszug, keine Auslassungszeichen, keine „hier analog weiter"-Stelle.
2. **`schema/<domäne>-schema-check.sql`** — Sollstand im Kopfkommentar; prüft, ob jede Tabelle existiert und jedes Constraint greift, und belegt jede Regel aus den Blöcken, die im Schema stehen soll, mit einem fehlschlagenden `INSERT`. Eine Regel ohne Gegenprobe gilt als nicht gebaut.
3. **Die Abweichungsliste**, falls die Domäne in `wb-docs` schon existiert — in den Schlussbericht, nie in die Datei.

**Prüfskripte laufen lassen:** Postgres ist hier nicht installiert, Podman schon — eine Wegwerf-Datenbank ist ein Einzeiler (`podman run --rm -d -e POSTGRES_PASSWORD=x -p 5432:5432 postgres:17`). Lauf jedes Skript dagegen und nimm das Ergebnis in den Bericht. Geht es nicht, sag das einmal am Anfang und bau trotzdem durch — nicht anhalten, nicht danach fragen.

## Zum Schluss: einmal alles zusammen

Die vier Nähte aus [`schema-prompt.md`](schema-prompt.md) prüfen je eine Domäne. Was **zwischen** ihnen bricht, sieht keine davon — und genau dort bricht es: ein Fremdschlüssel auf eine Tabelle, die inzwischen anders heißt, ein Sachverhalt, den zwei Domänen jede für sich gebaut haben, eine Q-Entität, die dreimal referenziert und nirgends angelegt wurde.

Nach der letzten Domäne deshalb **ein** Durchgang über alles, und danach ein eigener Commit:

- **Alle `schema/*-schema.sql` in Reihenfolge in eine leere Datenbank laden.** Das ist der billigste Gesamttest, den es gibt: Jeder Fremdschlüssel ins Leere, jeder doppelte Tabellen- oder Constraint-Name schlägt sofort fehl. Danach die Prüfskripte, ebenfalls alle.
- **Ein Sachverhalt, zwei Domänen** — `grep` über alle Dateien nach den Spaltennamen, die mehrfach vorkommen dürften. Ein Treffer ist kein Fehler, aber jeder ist anzusehen.
- **Was du reparierst, reparierst du an der Wurzel**, also in der Domäne, der die Tatsache gehört — nicht mit einer zweiten Spalte in der Domäne, die sie braucht.

Geht das ohne Datenbank nicht, sag es im Bericht als eigene Zeile. Ein Lauf ohne diesen Durchgang ist nicht fertig, sondern ungeprüft.

## Zwischenmeldungen

Bevor du anfängst: ein Satz zur Reihenfolge. Je abgeschlossener Domäne **eine Zeile** — Name, Zahl der Tabellen, Zahl der `[A]`, Zahl der `[A!]`. Sonst nichts: kein Vorlesen dessen, was du gerade schreibst, keine Ankündigung jedes Schritts, keine Zwischenzusammenfassung.

## Der Schlussbericht

Das ist meine gesamte Sicht auf einen Lauf, den ich nicht mitgelesen habe. Das Zeilenbudget gilt nur für die Prosa drumherum, höchstens zehn Zeilen; die Listen kürzt du nicht. In dieser Reihenfolge:

1. **Was gebaut wurde** — eine Zeile je Domäne, mit Commit-Kurzhash.
2. **Alle `[A!]` über alle Domänen**, je Eintrag eine Zeile: Marke, Domäne, Aussage, Alternative. Das lese ich zuerst.
3. **Zahl der `[A]` je Domäne** — nicht auflisten, die stehen in den Dateien und ich finde sie per Textsuche.
4. **Unbelegbare Felder aus dem Vorentwurf** (`W1, W2 …`), je Eintrag eine Zeile: was dort steht, wo du gesucht hast, dein Vorschlag. Nur diese Sorte — dass du anders geschnitten hast, ist der Zweck des Laufs und keine Zeile wert.
5. **Prüfskripte** — je Domäne gelaufen oder nicht, und mit welchem Ergebnis.
6. **Der Gesamtdurchgang** — ob alle Dateien zusammen in eine leere Datenbank laufen, und was er gefunden hat.

Kein Schlussabsatz, der das Ergebnis würdigt. Keine „nächsten Schritte" — der nächste Schritt ist, dass ich lese.
