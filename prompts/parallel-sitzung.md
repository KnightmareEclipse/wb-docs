# Parallel arbeiten — ein Strang je Sitzung

Für den Fall, dass mehrere Sitzungen gleichzeitig an diesem Repo arbeiten. Ich stelle diesem Prompt
**„Du bist Sitzung N"** voran, sonst ändert sich nichts: `prompts/gemeinsam.md` und `CLAUDE.md`
gelten unverändert und werden hier nicht wiederholt.

## Deine Datei-Hoheit

Jede Datei gehört genau einer Sitzung. Das ist die einzige Regel, die dieser Prompt hinzufügt, und
sie ersetzt jede Abstimmung: Solange niemand fremde Dateien anfasst, entstehen keine Konflikte, und
niemand muss wissen, was die anderen gerade tun.

| Sitzung | Strang | Deine Dateien |
|---|---|---|
| **1** | Sichtbarkeit: TASK-161, dann 157/205/206/162 am Stück, danach 152 und 197; dazu 218 und 220 | `schema/gesundheit-*`, `schema/klassenorganisation-*`, `schema/stammdaten-*`, `api/gesundheit-api.md`, `soll-prozesse/08`, `09`, `15` |
| **2** | Akademie und Ferien: TASK-176, 177, 178, 179, 180 | `schema/ferien-*`, `schema/akademie-*` (neu), `api/ferien-api.md`, `api/akademie-api.md` (neu), `soll-prozesse/10`, `21` |
| **3** | Hort: TASK-214, 216, 217 | `schema/anmeldung-*`, `soll-prozesse/09` — **nur lesend, 09 gehört Sitzung 1** |
| **4** | Prosa ohne Schema: TASK-209, 211, 119, 121 | `verarbeitungsverzeichnis.md`, `runbook.md`, neue Dokumente |
| **6** | Lösch-Lauf: TASK-007, 009, 183, 194 — **läuft allein, siehe unten** | `schema/querschnitt-*`, `soll-prozesse/17` (neu), und die Löschanker jeder Domäne |
| **5** | Prüflauf für etwas, das eine andere Sitzung **fertig** hat — `prompts/schema-pruefen.md` nach einem Schema, `prompts/api-pruefen.md` nach gebauten Routen | keine — ein Prüflauf schreibt einen Bericht und ändert nichts |

Fehlt deine Nummer in der Tabelle, frag mich; rate nicht.

## Was du damit tust

**Das Ticket ist die Aufgabe** — es trägt, was gilt, warum, und woran du merkst, dass es fertig ist.
Lies es zuerst, nicht die Tabelle oben; die sagt nur, welche dir gehören.

**Wie du vorgehst, steht in `CLAUDE.md` unter „Arbeitsgänge"** — für ein Schema
`prompts/schema-bauen.md`, für eine API `prompts/api-planen.md`, für einen Soll-Block
`prompts/block-fuellen.md`. Der Prüflauf danach gehört ausdrücklich einer anderen Sitzung: Wer
gebaut hat, prüft nicht.

**Das ist dein einziger Haltepunkt.** Steht eine Domäne im Schema, hörst du auf und meldest sie zum
Prüfen — was auf ihr aufbaut, etwa ihre Routen, beginnt erst mit dem grünen Bericht. Sonst planst du
gegen ein Schema, das sich noch ändert.

Der Bericht kommt zu dir zurück: Du schließt seine Funde mit `prompts/schema-reparieren.md`, überträgst
mit `prompts/schema-uebertragen.md` nach `wb-backend` und machst dann weiter. Am Ende des Strangs
wiederholt sich das für die Routen — bauen, prüfen lassen, mit `prompts/api-reparieren.md` schließen.

Arbeite die Tickets deines Strangs in ihrer Reihenfolge ab; wo eine Abhängigkeit besteht, steht sie
im Ticket. Ist der letzte durch, sag es und hör auf — such dir keinen neuen Strang.

## Wenn deine Arbeit an eine fremde Datei stößt

Das kommt vor, und es ist kein Fehler: Ein Löschanker in einer fremden `.sql`, ein Satz in einem
fremden Block. Fass sie nicht an — melde sie am Ende als Fund, mit Pfad und dem Satz, der dort
stehen müsste. Ich trage ihn nach oder gebe ihn der Sitzung, der die Datei gehört. Eine
Halbänderung an einer Datei, die gleichzeitig jemand anders schreibt, kostet mehr als der Umweg.

`backlog/` gehört allen: Jede Sitzung legt und ändert dort ihre eigenen Tickets. Zwei Sitzungen
fassen nie dasselbe Ticket an, weil kein Ticket in zwei Strängen steht.

## Sitzung 6 läuft nie parallel

Sie fasst `querschnitt` an **und** die Löschanker-Kommentare jeder Domäne — sie kollidiert mit jedem
anderen Strang. Und sie kommt zuletzt: Jeder Strang oben erzeugt neue Tabellen, die einen Löschanker
brauchen. Wer den Lauf vorher schreibt, schreibt ihn zweimal. Läuft sie, läuft sonst nichts.

## Commit

Committe selbst, sobald dein Strang einen abgeschlossenen Stand hat, mit `[SN]` am Anfang der
Betreffzeile — `[S2] Die Kochwerkstatt zieht in die Akademie`. Daran sehe ich hinterher, welcher
Strang was getan hat, ohne die Diffs zu lesen. Auf `main`, ohne Zweig: Bei getrennten Dateimengen
gibt es nichts zu mergen.

## Länge

Die Tickets und Kommentare, die hier entstehen, sind kurz — ein Ticket erklärt, was gilt und warum,
und hört dann auf. Kein zusammenfassender Abschlussabsatz, keine Wiederholung dessen, was drei
Zeilen darüber steht, keine Aufzählung der Selbstverständlichkeiten. Der Umfang folgt der Sache:
Eine Entscheidung mit Preis braucht ihren Absatz, ein Häkchen braucht einen Satz.
