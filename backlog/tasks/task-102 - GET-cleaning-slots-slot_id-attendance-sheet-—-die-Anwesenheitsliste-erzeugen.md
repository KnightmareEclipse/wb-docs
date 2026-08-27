---
id: TASK-102
title: >-
  GET /cleaning/slots/{slot_id}/attendance-sheet — die Anwesenheitsliste
  erzeugen
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
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
- [ ] #1 Wird bei jedem Aufruf neu erzeugt, nie zwischengespeichert
- [ ] #2 Freigekaufte Zuteilungen stehen nicht darauf
<!-- AC:END -->
