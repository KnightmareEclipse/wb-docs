---
id: TASK-009
title: Schema-Durchgang für Lösch-Lauf und DSGVO-Auskunft
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-09-03 18:18'
labels:
  - wb-docs
  - schema
  - dsgvo
milestone: m-1
dependencies:
  - TASK-007
references:
  - prompts/schema-bauen.md
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Folgt aus Block 17 und 18. Die Annahme "wahrscheinlich ohne eigene Tabellen" trägt seit dem 03.09.2026 nicht mehr — die Domäne braucht zwei:

- Die **Empfängerliste je Bestand**: mindestens zwei Einträge, jeder entweder eine einzelne Person oder eine Rollengruppe, änderbar ohne Bau (soll-prozesse/hebel.md). Eine Rollengruppe trägt dabei **optional eine Schulart**: "die Lehrkräfte" ohne Zusatz wären beide Zweige, und manche Lehrkraft ist nur für einen zuständig. Aufgelöst wird der Eintrag beim Versand, nicht beim Eintragen — sonst steht in der Liste, wer heute die Rolle hat, statt wer sie am Löschtag hat.
- Das **Anhalten im Einzelfall**: eine Zeile je angehaltener Löschung, mit ihrem Anker (Kind, Person oder Familie), dem betroffenen Bestand, dem Grund aus einer Werteliste, wer angehalten hat, einem **Datum, bis wann** — und dem **ursprünglichen Löschtermin**.

**Dieser Durchgang kommt zuletzt, und der Grund ist kein Zeitplan, sondern eine Abhängigkeit:** Jede Domäne, die daneben gebaut wird, legt ihm eine Tabelle hin, die einen Löschanker braucht — das Notizfeld an der Person (TASK-220), die Tagesbuchung der Notfallbetreuung (TASK-214), die Akademie samt Erwachsenen-Teilnehmern (TASK-176), die Wahlmodulgruppen und das Unterrichtsverhältnis (TASK-161), die Newsletter-Einwilligung (TASK-208). Wer den Lauf vorher schreibt, schreibt ihn zweimal.

Der Anker gehört an dieselbe Stelle wie bei change_log und sync_tasks: Kind, Person oder Familie als Spalte, nicht Tabellenname plus Schlüssel als Text — ein Anhalten muss der Lauf finden, bevor er die Zeilen überhaupt gesammelt hat.

**Unbegrenztes Verlängern ist ausdrücklich erlaubt** (03.09.2026): Ein Rechtsstreit kann Jahre dauern, und Art. 17 Abs. 3 lit. e deckt genau das. Es gibt deshalb keine Obergrenze und keine erzwungene Entscheidung — an ihre Stelle tritt Sichtbarkeit. Der ursprüngliche Löschtermin ist der Preis dafür, dass sie funktioniert: Er wird beim Verlängern **nicht** zurückgesetzt, sondern mitgenommen, sonst begänne die Zählung mit jedem Anhalten von vorn und genau die Zahl, um die es geht, wäre fort. Aus ihm und der Zahl der Zeilen je Anker entsteht die Liste "seit wann fällig, wie oft geschoben" — frisch erzeugt wie jede andere (hebel.md).

Die Mindestzahl zwei ist der einzige Punkt, der nicht in einen CHECK passt: Sie zählt über die Zeilen einer Gruppe. Entweder ein Trigger, oder die Schreibschicht hält sie und das Prüfskript weist den Ein-Empfänger-Fall nach — die billigere Fassung, solange niemand an der Schreibschicht vorbeischreibt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Empfängerliste steht: je Bestand mindestens zwei Einträge, Person oder Rollengruppe
- [ ] #2 Eine Rollengruppe als Empfänger trägt optional eine Schulart und wird erst beim Versand aufgelöst
- [ ] #3 Ein Bestand mit nur einem Empfänger wird abgewiesen — als Gegenprobe, gleich ob per Trigger oder Prüfskript
- [ ] #4 Ein angehaltener Anker wird vom Lauf übersprungen, und das Prüfskript zeigt es
- [ ] #5 Ein Anhalten ohne Enddatum wird abgewiesen; ein Anhalten ohne Grund aus der Werteliste ebenso
- [ ] #6 Nach Ablauf des Anhaltens beginnt die Ankündigung von vorn statt sofort zu löschen
- [ ] #7 Das Verlängern setzt den ursprünglichen Löschtermin nicht zurück — als Gegenprobe: zweimal anhalten, die Fälligkeit bleibt die erste
- [ ] #8 Es gibt eine frisch erzeugte Liste der angehaltenen Löschungen mit Fälligkeit, Alter und Anzahl der Verlängerungen
- [ ] #9 Jede Tabelle, die seit dem 03.09.2026 dazugekommen ist, hat ihren Löschanker — Notizfeld, Notfallbetreuung, Akademie, Unterrichtsverhältnis, Newsletter
<!-- AC:END -->
