# Prompt: die Funde aus dem Prüfbericht schließen

Gegenstück zu [`prompts/schema-pruefen.md`](schema-pruefen.md). Dort wird gemeldet, hier wird
repariert. **Der Reparateur baut, was der Block hergibt — und fragt, was er nicht hergibt.**

Ein Paket je Lauf. Beim Absenden nennst du die Kennungen (`F3 F7 F12 …`) oder eine
Paketnummer aus der Liste unten. Effort `xhigh`. Vorher `git status` sauber. Alles unter dem
Strich ist der Prompt.

**Die Pakete**, nach dem gruppiert, was du dafür offen haben musst — nicht nach Gewicht:

1. **Zitate und Belegstellen** — nur Kommentare, kein SQL. Zuerst, solange die Zeilennummern
   des Berichts noch stimmen.
2. **Löschanker** — eine Regel für „geht mit X", dann über alle Dateien in `schema/`.
3. **Flag ohne Bindung / Wert an zwei Orten** — zusammengesetzter Fremdschlüssel plus CHECK.
4. **UNIQUE und Index, die reale Fälle abweisen** — die teuerste Klasse.
5. **Fehlende Spalte oder Tabelle** — je Domäne, mit dem Block in der Hand.
6. **Prüfskripte** — die Gegenproben, die niemand sonst mitbringt.

---

Es gelten [`gemeinsam.md`](gemeinsam.md) (wie du mit mir redest, kein Subagent urteilt) und
`CLAUDE.md`. Beides liest du zuerst und ich wiederhole es hier nicht.

Wir schließen Funde aus `pruefberichte/aktuell.md` im Datenmodell unter `schema/`. Der Bericht ist
die Arbeitsliste, nicht die Anweisung.

**Derzeit gibt es hier nichts zu tun.** Kein Fund wurde verworfen. Was aus den Zyklen weiterträgt,
steht als Satz an seiner Stelle im Schema und nicht in einer Liste daneben — offen sind allein die
zwei `[?]` am Ende von `schema/querschnitt-schema.sql`: die Frist, nach der eine versandte Mail ohne
Person verfällt, und ob der Nachweis des Fotoeinverständnisses das Kind überdauern muss.

Ein neuer Prüflauf legt `pruefberichte/aktuell.md` frisch an; erst dann gibt es hier wieder etwas zu
tun. **Am Ende des Zyklus wird die Datei gelöscht** — der Beleg, dass ein Fund geschlossen ist, ist
die reparierte `.sql` samt grünem Prüfskript, und die Git-Historie hält den Bericht. Die Kennungen
`[F1]`, `[F2]`, … gehören zu ihrem Lauf und nicht zu einem neuen.

## Die eine Regel, aus der der Rest folgt

**Auch der Prüfbericht ist eine Behauptung, kein Beleg.** Derselbe Maßstab, den er an die
SQL-Kommentare legt, gilt für ihn selbst: Ein Fund ist erst dann einer, wenn du den Satz aus
dem Soll-Block gelesen hast, auf den er sich beruft. Was dort „empirisch geprüft" steht, trägt
sich selbst; was nur begründet ist, prüfst du gegen die Quelle, bevor du etwas änderst.

Und **der Vorschlag im Fund ist der Vorschlag eines Prüfers.** Er hat das Schema angegriffen,
nicht gebaut. Trägt er, nimm ihn. Trägt eine kleinere Änderung dieselbe Regel, nimm die kleinere.

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

Aufruf, `ON_ERROR_STOP=1` und Ladereihenfolge stehen in `CLAUDE.md`. Am Ende des Pakets läuft der
Ladelauf in eine leere Datenbank und alle Prüfskripte gegen die vollständige — nicht
einzeln gegen ihre Voraussetzungen. Rückgabewert je Skript, nicht der Text auf dem Schirm. Geht das
nicht, sag es einmal am Anfang und ändere nur, was ohne Datenbank entscheidbar ist.

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
- **`pruefberichte/aktuell.md` bleibt, wie er ist.** Er ist Beweisstück, nicht Arbeitsblatt.

## Was du meldest

Je abgeschlossenem Fund **eine Zeile**: Kennung, was geändert wurde, Gegenprobe ja oder nein.

Am Ende höchstens fünfzehn Zeilen: was gebaut ist, was an einer Antwort hängt, was du als Fund
verworfen hast und warum, und der Rückgabewert von Ladelauf und Prüfskripten. Die verworfenen und
die offenen Funde führst du vollständig auf.
