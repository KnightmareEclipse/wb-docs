---
id: TASK-036
title: Stammdaten-Export für den Vollimport beschaffen
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-08-28 16:41'
labels:
  - wartet
  - betreiber
  - import
milestone: m-1
dependencies: []
references:
  - grenzkarte.md
priority: high
ordinal: 36000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Stichtag, ab dem der Freeze gilt. Liegt beim Betreiber selbst, keine Zulieferung durch Dritte. Der Export ist zugleich die Gegenprobe aufs Stammdaten-Schema und ersetzt darin die Durchsicht mit dem zweiten Admin (037): Er wird zuerst gegen eine Wegwerf-Datenbank geladen, und was dabei nicht passt, ist der Befund — echte Daten finden mehr als ein Mensch, der DDL liest. Erst danach der Lauf gegen die echte Datenbank.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Export liegt vollständig vor, Stichtag notiert
- [ ] #2 Probelauf gegen eine Wegwerf-Datenbank ist durch, jede Abweichung ist entweder gefixt oder als bewusst offen notiert
- [ ] #3 Erst danach der Lauf gegen die Produktivdatenbank
- [ ] #4 Die Richtung ist fest: Weicht der Export ab, wird der Export umgeformt, nicht das Schema — Ausnahme ist allein ein fehlender Wert, den eine NOT-NULL-Spalte verlangt
<!-- AC:END -->
