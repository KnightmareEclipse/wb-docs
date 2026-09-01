---
id: TASK-170
title: Schema für Ausflugskonto und Bildungskarte bauen
status: To Do
assignee: []
created_date: '2026-09-01 18:44'
labels:
  - schema
  - veranstaltungen
  - wb-docs
dependencies:
  - TASK-169
references:
  - soll-prozesse/20-ausflugskonto.md
  - soll-prozesse/hebel.md
  - grenzkarte.md
ordinal: 182000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus Block 20. Das Ausflugskonto je Kind und Schuljahr — Pauschale hinein, Kosten der Ausflüge heraus, Rest ins nächste Jahr oder zur Auszahlung —, die Bildungskarte mit Guthaben und Gültigkeit, und der Erstattungsvorgang mit seinen drei Zeitpunkten: beim Amt beantragt, erstattet, den Eltern gutgeschrieben.

Zwei Punkte, an denen es schiefgehen kann und die das Schema tragen muss: Die Gutschrift kommt **erst nach** der Erstattung — ein Gutschriftzeitpunkt ohne Erstattungszeitpunkt darf es nicht geben. Und die Bildungskarte ist ein **Sozialdatum** nach § 35 SGB I, kein Art.-9-Datum: Der Leserkreis ist eng, aber anders begründet als beim Gesundheitsbestand — Grundschule nur Klassenlehrkraft, Realschule alle Lehrkräfte, dazu Sekretariat und Rechnungswesen.

Die Pauschale ist ein Wert im System, gesetzt von der Schulleitung — die zweite benannte Ausnahme in hebel.md, dort bereits nachgezogen.

Beschlossen am 01.09.2026 mit der Geschäftsführung, Ablauf in soll-prozesse/19-ausfluege-und-fahrten.md und soll-prozesse/20-ausflugskonto.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Das Konto rechnet je Kind und Schuljahr, mit Übertrag ins Folgejahr
- [ ] #2 Eine Gutschrift ohne vorangegangene Erstattung wird abgewiesen — als Gegenprobe
- [ ] #3 Der Leserkreis der Bildungskarte ist im Schema begründet und trennt Grundschule von Realschule
- [ ] #4 Beim Schulabgang friert das Konto ein und der Rest steht als Auszahlung
- [ ] #5 Keine Spalte für einen Guthabenstand, der von der Stadt käme — es gibt keine Schnittstelle
<!-- AC:END -->
