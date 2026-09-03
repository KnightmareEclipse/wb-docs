---
id: TASK-218
title: 'Unterrichtsende je Klasse und Wochentag, samt Häkchen für Sport am Ende'
status: To Do
assignee: []
created_date: '2026-09-03 17:11'
updated_date: '2026-09-03 18:20'
labels:
  - schema
  - klassenorganisation
milestone: m-5
dependencies: []
references:
  - schema/klassenorganisation-schema.sql
  - soll-prozesse/09-hortvertrag.md
  - schema/stammdaten-schema.sql
ordinal: 231000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beschrieben am 03.09.2026: Der Hort führt heute, **wann welche Klasse Unterrichtsende hat** — als Uhrzeit je Klasse und Wochentag. Das ist keine Neugier, sondern Betriebsplanung: Er weiß daran, wann er mit wie vielen Kindern rechnet.

Und er führt eine Abweichung mit: **Wo Sport am Unterrichtsende liegt, kommen die Kinder später.** Die Schule hat keine eigene Sporthalle, die Halle ist extern, und die Eltern fahren die Kinder anschließend zurück — das ist Teil der Elternarbeit. Für den Hort heißt das: An diesem Wochentag trifft diese Klasse später ein.

**Eine Ankunftszeit gibt es nicht, und zwar der Sache nach** (Betreiber, 03.09.2026): Die Kinder treffen unterschiedlich ein — es hängt an den Eltern, am Verkehr, an allem Möglichen. Eine Zeit je Klasse wäre also nicht bloß ungenau, sondern falsch. Geführt wird deshalb nur, *welche* Klasse *an welchem Tag* Sport am Ende hat.

**Gebraucht wird also eine Zeile je Klasse und Wochentag** mit dem Unterrichtsende als Uhrzeit und einem **Häkchen `sport_at_end`** (Betreiber, 03.09.2026): An diesem Tag liegt Sport am Ende, die Kinder kommen deshalb später. Mehr wird nicht getrackt, weil mehr nicht existiert.

Verworfen, mit kleinem Preis: ein **Freitext-Grund** statt des Häkchens wäre nach der Wirkung benannt statt nach der Ursache und trüge einen zweiten Anlass mit, ohne dass eine Spalte dazukäme. Er kostet dafür einen Satz, den jemand tippt, für eine Tatsache, die jeder kennt. Käme ein zweiter Anlass — Schwimmen betrifft die Hortkinder ausdrücklich nicht —, ist er ein zweites Häkchen oder eben doch der Text; heute trägt das eine.

**Das ist kein Stundenplan und wird keiner.** Eine Zeit je Klasse und Wochentag beantwortet die Frage des Horts vollständig; Untis bleibt out of scope, und weder Fächer noch Stunden noch Räume entstehen hier. Wer später eine Stundenplanfrage stellt, bekommt eine eigene Domäne und nicht diese Tabelle.

**Ein weiterer verworfener Weg samt Preis**, damit er nicht neu erfunden wird: Die Abweichung je **Datum** statt je Wochentag träfe auch den Wandertag, wäre für die wöchentliche Sportabweichung aber jede Woche eine Zeile, die jemand einträgt — die Pflege, die liegen bleibt. Käme der einmalige Fall doch, ist er eine Tabelle **daneben** und kein Umbau dieser einen.

Zwei Dinge bewusst nicht: **keine Abweichung je Kind** — holt ein Elternteil sein Kind an der Halle ab, sieht der Hort das am Nachmittag und braucht dafür keine Vorhersage. Und **keine Verbindung zum Modul**: Ein Kind mit „Nachmittag 2 bis 14:30" ist an Sporttagen später da, am gebuchten Modul ändert das nichts. Vertrag und Betrieb bleiben getrennt, sonst rechnet irgendwann jemand Beiträge nach Anwesenheit.

Sie gehört zu `klassenorganisation` — dieselbe Domäne wie das Unterrichtsverhältnis, dieselbe Pflege: je Schuljahr, von der Stelle, die den Deputatsplan ohnehin macht (TASK-161).

**Die Fahrten zur Sporthalle werden nicht ausgeschrieben** (Betreiber, 03.09.2026). Sie sind Elternarbeit, aber die Eltern regeln sie unter sich und tragen die Stunden hinterher ein — die Eintragung läuft ohnehin auf Vertrauensbasis. Das Schema trägt das bereits und nennt genau diesen Fall: `parent_work_entries.parent_work_session_id` ist freiwillig, „Was die Eltern unter sich regeln — der Fahrdienst der Grundschule vor allem — wird ohne Einsatz eingetragen" (14 Z4). Für dieses Ticket folgt daraus nichts als die Feststellung, dass daraus nichts folgt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Zeile je Klasse und Wochentag mit dem Unterrichtsende als Uhrzeit
- [ ] #2 Ein Häkchen sagt, dass an diesem Tag Sport am Ende liegt und die Kinder später kommen
- [ ] #3 Keine Ankunftszeit je Klasse — sie unterscheidet sich von Kind zu Kind
- [ ] #4 Kein Fach, keine Stunde, kein Raum: Die Tabelle bleibt eine Zeit je Klasse und Wochentag
- [ ] #5 Die Zeiten hängen am Schuljahr und werden wie die Unterrichtsverteilung gepflegt
<!-- AC:END -->
