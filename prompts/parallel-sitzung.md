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
| **5** | Prüflauf nach `prompts/schema-pruefen.md` für eine Domäne, die eine andere Sitzung **fertig** hat | keine — ein Prüflauf schreibt einen Bericht und ändert nichts |

Fehlt deine Nummer in der Tabelle, frag mich; rate nicht.

## Wenn deine Arbeit an eine fremde Datei stößt

Das kommt vor, und es ist kein Fehler: Ein Löschanker in einer fremden `.sql`, ein Satz in einem
fremden Block. Fass sie nicht an — melde sie am Ende als Fund, mit Pfad und dem Satz, der dort
stehen müsste. Ich trage ihn nach oder gebe ihn der Sitzung, der die Datei gehört. Eine
Halbänderung an einer Datei, die gleichzeitig jemand anders schreibt, kostet mehr als der Umweg.

`backlog/` gehört allen: Jede Sitzung legt und ändert dort ihre eigenen Tickets. Zwei Sitzungen
fassen nie dasselbe Ticket an, weil kein Ticket in zwei Strängen steht.

## Der Lösch-Lauf läuft nie parallel

TASK-007, 009, 183 und 194 fassen `querschnitt` an **und** die Löschanker-Kommentare jeder Domäne —
sie kollidieren mit jedem anderen Strang. Und sie kommen zuletzt: Jeder der Stränge oben erzeugt
neue Tabellen, die einen Löschanker brauchen. Wer den Lauf vorher schreibt, schreibt ihn zweimal.

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
