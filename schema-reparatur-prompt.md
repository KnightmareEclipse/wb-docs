# Prompt: die Funde aus dem Prüfbericht schließen

Gegenstück zu [`schema-pruef-prompt.md`](schema-pruef-prompt.md). Dort wird gemeldet, hier wird
repariert. **Der Reparateur baut, was der Block hergibt — und fragt, was er nicht hergibt.**

Ein Paket je Lauf. Beim Absenden nennst du die Kennungen (`F3 F7 F12 …`) oder eine
Paketnummer aus der Liste unten. Effort `xhigh`. Vorher `git status` sauber. Alles unter dem
Strich ist der Prompt.

**Die Pakete**, nach dem gruppiert, was du dafür offen haben musst — nicht nach Gewicht:

1. **Zitate und Belegstellen** — nur Kommentare, kein SQL. Zuerst, solange die Zeilennummern
   des Berichts noch stimmen.
2. **Löschanker** — eine Regel für „geht mit X", dann über alle vierzehn Dateien.
3. **Flag ohne Bindung / Wert an zwei Orten** — zusammengesetzter Fremdschlüssel plus CHECK.
4. **UNIQUE und Index, die reale Fälle abweisen** — die teuerste Klasse.
5. **Fehlende Spalte oder Tabelle** — je Domäne, mit dem Block in der Hand.
6. **Prüfskripte** — die Gegenproben, die niemand sonst mitbringt.

---

Wir schließen Funde aus [`pruefbericht.md`](pruefbericht.md) im Datenmodell unter `schema/`.
Der Bericht ist die Arbeitsliste, nicht die Anweisung.

**Derzeit gibt es hier nichts zu tun.** Alle fünf bisherigen Berichtszyklen sind abgeschlossen
und liegen als Beweisstücke daneben:

- [`pruefbericht-01.md`](pruefbericht-01.md) — 84 Funde aus drei Läufen, alle geschlossen.
- [`pruefbericht-02.md`](pruefbericht-02.md) — 33 Funde aus zwei unabhängigen Läufen, alle
  geschlossen; dazu sechs Stellen, an denen das Schema eine Antwort der Schule behauptete, die ihr
  Block noch offen stellte — die Antworten stehen inzwischen in den Blöcken.
- [`pruefbericht-03.md`](pruefbericht-03.md) — 18 Funde aus einem Lauf, alle geschlossen; sieben
  der vierzehn Domänen kamen ohne Fund durch. Keiner wurde verworfen. Offen blieb eine einzige
  Sachfrage, die kein Block entscheidet: die Frist, nach der eine versandte Mail ohne Person
  verfällt — sie steht als `[?]` im Kopf von `schema/querschnitt-schema.sql`.
- [`pruefbericht-04.md`](pruefbericht-04.md) — 7 Funde aus einem Lauf, alle geschlossen; zehn der
  vierzehn Domänen kamen ohne Fund durch. Keiner wurde verworfen. Die eine Sachfrage, die kein
  Block entschied — was der Jahreslauf mit einem Warteplatz am Ende seiner Schulart tut —, hat die
  Schule beantwortet: Er endet zum 31. Juli wie der Jahrgang in 04, und die Antwort steht an
  `ck_applications_grade_level` in `schema/anmeldung-schema.sql`.
- [`pruefbericht-05.md`](pruefbericht-05.md) — 13 Funde aus einem unabhängigen Gegenlauf, alle
  geschlossen; fünf der vierzehn Domänen kamen ohne Fund durch. Keiner wurde verworfen, und keine
  Sachfrage blieb offen — jeden Fund entschied ein Block. Zwei Entscheidungen ziehen weiter als
  ihr Fund: der Putzdienst-Jahreslauf räumt die Einzel-Freikäufe seither selbst, weil
  `fk_cleaning_slot_buyouts_assignment` sie mit NO ACTION festhält (F7), und `login_codes` hat
  einen Fremdschlüssel auf `persons`, wo vorher „bewusst KEINER" stand (F1) — beides steht als
  Satz an seiner Stelle im Schema. Was der Lauf nicht prüfen konnte, liegt weiter nicht im Repo:
  Betreuungsvertrag und Preislisten, und damit die Zitate daraus.

Die Kennungen in einem abgeschlossenen Bericht gehören zu seinem Lauf und nicht zu einem neuen —
`pruefbericht-01.md` trug dabei noch domänenbuchstabige (`S11`, `Q6`), erst danach ist die
durchlaufende Nummer `[F1]`, `[F2]`, … die eine Form.
Ein neuer Prüflauf legt `pruefbericht.md` frisch an; erst dann gibt es hier wieder etwas zu tun,
und am Ende jenes Zyklus wird die Datei zu `pruefbericht-06.md`.

## Die eine Regel, aus der der Rest folgt

**Auch der Prüfbericht ist eine Behauptung, kein Beleg.** Derselbe Maßstab, den er an die
SQL-Kommentare legt, gilt für ihn selbst: Ein Fund ist erst dann einer, wenn du den Satz aus
dem Soll-Block gelesen hast, auf den er sich beruft. Was dort „empirisch geprüft" steht, trägt
sich selbst; was nur begründet ist, prüfst du gegen die Quelle, bevor du etwas änderst.

Und **der Vorschlag im Fund ist der Vorschlag eines Prüfers.** Er hat das Schema angegriffen,
nicht gebaut. Trägt er, nimm ihn. Trägt eine kleinere Änderung dieselbe Regel, nimm die kleinere.

Die Rangfolge bei Widerspruch ist dieselbe wie beim Bau: Soll-Block schlägt `hebel.md` schlägt
`grenzkarte.md` schlägt `prozesse.md`. Der Vorentwurf in `wb-docs/domains/` schlägt gar nichts.

## Wann du baust und wann du fragst

Je Fund entscheidest du das an einer Frage: **Entscheidet ein Block die Sache?**

- **Der Block entscheidet sie, und eine Bauform trägt sie** — bau es. Kein Rückfragen. Das ist
  der Normalfall: falsche Zitate, Löschanker gegen ihren eigenen Kommentar, fehlende Spalten
  für eine wörtliche Zusage, Constraints gegen einen wörtlich benannten Fall.
- **Der Block entscheidet sie, mehrere Bauformen tragen sie** — nimm die Form, die im Schema
  schon Präzedenz hat, und schreib den Block daneben. Die Wahl zwischen zwei gleich tragenden
  Formen ist Handwerk und keine Frage an mich.
- **Kein Block entscheidet sie** — frag. Der Fund nennt dann meist selbst eine offene
  Sachfrage, oder sein Vorschlag setzt eine Entscheidung voraus, die nirgends steht. Rate
  nicht, und bau nichts „vorsichtshalber": ein geratener Constraint kostet später eine
  Migration, eine offene Frage kostet einen Satz.
- **Der Fund trägt nicht** — bau nichts. Schreib in einer Zeile auf, welcher Satz aus welchem
  Block ihn entkräftet.

**Frag in einem Zug am Ende des Pakets, nicht bei jedem Fund einzeln.** Alles, was nicht an
einer Antwort hängt, baust du vorher fertig. Je Frage: Domäne und Kennung, was die Antwort
entscheidet, zwei bis vier Möglichkeiten, deine Empfehlung zuerst.

**Was ich beantworte, wird eine Zeile im Schema** — an der Stelle, die sie entscheidet, in der
Kommentarform der Datei. Nicht in einer Entscheidungsdatei daneben; das Schema erklärt sich
selbst, und genau deshalb überlebt die Entscheidung.

## Was zu einer Korrektur gehört

Drei Dinge, sonst ist sie nicht fertig:

1. **Die Änderung selbst** im `-schema.sql`, im Wortlaut und in der Kommentarform der Datei.
2. **Die Gegenprobe** im zugehörigen `-schema-check.sql`. Nach dem Maßstab des Prüf-Prompts
   gilt eine Regel ohne Gegenprobe als nicht gebaut — der nächste Lauf meldet sie sonst
   wieder. Bei einer reinen Zitatkorrektur entfällt sie; bei allem anderen nicht.
3. **Der Kommentar sagt, was der Constraint tut.** Wo du eine Behauptung korrigierst, statt
   sie zu bauen, muss danach der Kommentar auf das Feld passen, über dem er steht.

Für die Löschanker gilt zusätzlich: Wo ein Kommentar „geht mit X" sagt und der Fremdschlüssel
festhält, entscheidest du einmal — CASCADE, oder NO ACTION mit dem Grund daneben, wie
`documents` es vormacht — und wendest dieselbe Entscheidung auf alle Fundstellen an. Ein
Lösch-Lauf je Domäne als Gegenprobe schließt die Klasse dauerhaft; `gesundheit` und
`klassenorganisation` haben ihn schon.

## Wie du läufst

Postgres ist nicht installiert, Podman schon:

```
podman run --rm -d --name wb-reparatur -e POSTGRES_PASSWORD=x docker.io/library/postgres:17
podman exec -i wb-reparatur psql -U postgres -v ON_ERROR_STOP=1 -q < schema/stammdaten-schema.sql
```

`-v ON_ERROR_STOP=1` ist kein Beiwerk: ohne den Schalter endet auch ein gescheiterter Lauf mit
Rückgabewert 0. Ladereihenfolge `stammdaten`, `querschnitt`, dann der Rest.

Am Ende des Pakets läuft der Ladelauf in eine leere Datenbank und alle vierzehn Prüfskripte
gegen die vollständige — nicht einzeln gegen ihre Voraussetzungen. Rückgabewert je Skript, nicht
der Text auf dem Schirm. Geht das nicht, sag es einmal am Anfang und ändere nur, was ohne
Datenbank entscheidbar ist.

## Der Commit

Ein Commit je Paket, am Ende, wenn Ladelauf und Prüfskripte durch sind. Die Betreffzeile nennt
das Paket, der Rumpf die Kennungen — daran hängt der Stand:

```
Reparatur: Zitate und Belegstellen auf den Wortlaut der Quelle

F3 F7 F9 F12 F15 F18 F19 F22 F24 F27 F28 F31
```

Nicht pushen.

## Was du nicht tust

- **Nichts außerhalb des Pakets.** Was dir nebenbei auffällt, kommt nicht in diesen Commit;
  eine Zeile am Ende genügt, dann entscheide ich. Kein Aufräumen im Vorbeigehen, keine
  Umbenennung, kein Nachziehen einer Stelle, die dir unsauber vorkommt.
- **Keine Abstraktion über den Fund hinaus.** Kein Constraint für einen Fall, den kein Block
  nennt; keine Tabelle auf Vorrat; keine Spalte, die erst die nächste Domäne bräuchte.
- **`pruefbericht.md` bleibt, wie er ist.** Er ist Beweisstück, nicht Arbeitsblatt.
- **Kein Subagent baut oder urteilt.** Suchen darf er — eine Fundstelle, ein Spaltenname über
  alle Dateien. Nicht ändern, nicht entscheiden, und nicht nachprüfen, was du geändert hast.
- **`wb-docs` wird nur gelesen.**

## Was du meldest

Je abgeschlossenem Fund **eine Zeile**: Kennung, was geändert wurde, Gegenprobe ja oder nein.
Kein Vorlesen dessen, was du gerade liest, keine Ankündigung jedes Schritts.

Am Ende höchstens fünfzehn Zeilen: was gebaut ist, was an einer Antwort hängt, was du als Fund
verworfen hast und warum, und der Rückgabewert von Ladelauf und Prüfskripten. Führe die
verworfenen und die offenen Funde vollständig auf — die kürze ich nicht gegen ein Budget ein.
Kein Schlussabsatz, der das Ergebnis würdigt, keine „nächsten Schritte": Der nächste Schritt
ist, dass ich lese.
