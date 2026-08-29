---
id: TASK-102
title: >-
  GET /cleaning/slots/{slot_id}/attendance-sheet — die Anwesenheitsliste
  erzeugen
status: Done
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-28 21:53'
labels:
  - wb-backend
  - route
  - putzdienst
  - sekretariat
milestone: m-0
dependencies: []
references:
  - api/putzdienst-api.md
  - soll-prozesse/hebel.md
priority: high
ordinal: 114000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Frisch erzeugte Liste im Sinne von hebel.md: entsteht beim Aufruf, bildet den letzten Stand ab, es gibt keine veraltete Fassung daneben.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Wird bei jedem Aufruf neu erzeugt, nie zwischengespeichert
- [x] #2 Freigekaufte Zuteilungen stehen nicht darauf
<!-- AC:END -->
