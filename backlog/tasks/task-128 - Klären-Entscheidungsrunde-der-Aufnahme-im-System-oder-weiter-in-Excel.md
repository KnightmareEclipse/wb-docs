---
id: TASK-128
title: 'Klären: Entscheidungsrunde der Aufnahme im System oder weiter in Excel'
status: Done
assignee: []
created_date: '2026-08-28 15:48'
updated_date: '2026-09-01 21:30'
labels:
  - wartet
  - geschaeftsfuehrung
  - schulleitung
  - entscheidung
  - dsgvo
milestone: m-5
dependencies: []
ordinal: 141000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Block 07 nimmt allein das Ergebnis auf; Gespräch, Bewertung und Ranking bleiben bei den Lehrkräften in Excel, und prozesse.md hält fest, dass sie das bevorzugen. Die Geschäftsführung fragt, ob Schulleitung und Sekretariat während der Entscheidung eine gemeinsame Oberfläche bekommen. Der Preis eines Ja steht in prozesse.md Abschnitt 145: Die Notizen werden heute nach Abschluss vernichtet — im System wären sie personenbezogene Daten mit Löschfrist und Auskunftsrecht, einsehbar auch nach einer Absage. Empfehlung an die Geschäftsführung: bei Excel bleiben.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden, ob die Entscheidungsrunde eine eigene Ansicht bekommt
- [ ] #2 Bei Ja: Löschfrist und Auskunftsumfang der Notizen mit der Datenschutzbeauftragten geklärt, bevor gebaut wird
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Entschieden am 01.09.2026: keine eigene Ansicht. Die Entscheidungsrunde führt allein die Schulleitung in Excel, ohne das Sekretariat; Weltenbaum nimmt nur das Ergebnis auf, wie Block 07 es beschreibt. Damit bleiben Gespräch, Bewertung und Ranking außerhalb des Systems — keine personenbezogenen Notizen mit Löschfrist und Auskunftsrecht, und AC#2 entfällt mit dem Nein. Eine Folge entsteht trotzdem: Die Schulleitung braucht ihre Excel-Grundlage künftig aus den Voranmeldungen (TASK-191).
<!-- SECTION:NOTES:END -->
