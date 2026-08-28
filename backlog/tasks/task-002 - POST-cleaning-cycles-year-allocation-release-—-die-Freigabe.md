---
id: TASK-002
title: 'POST /cleaning/cycles/{year}/allocation/release — die Freigabe'
status: Done
assignee: []
created_date: '2026-08-27 11:33'
updated_date: '2026-08-28 18:05'
labels:
  - wb-backend
  - putzdienst
  - route
milestone: m-0
dependencies:
  - TASK-106
references:
  - api/putzdienst-api.md
  - soll-prozesse/01-putzdienst.md
  - schema/putzdienst-schema.sql
priority: high
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Setzt allocation_released_at, genau einmal. Ohne Freigabe erfährt keine Familie ihre Termine — der Zyklus steht an dieser Stelle.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Setzt allocation_released_at genau einmal
- [x] #2 Die Route antwortet selbst, wenn allocated_at fehlt, statt in ck_cleaning_cycles_release zu laufen
- [x] #3 Rolle secretariat
<!-- AC:END -->
