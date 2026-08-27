---
id: TASK-002
title: 'POST /cleaning/cycles/{year}/allocation/release — die Freigabe'
status: To Do
assignee: []
created_date: '2026-08-27 11:33'
labels:
  - wb-backend
  - putzdienst
  - route
milestone: m-0
dependencies: []
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
- [ ] #1 Setzt allocation_released_at genau einmal
- [ ] #2 Die Route antwortet selbst, wenn allocated_at fehlt, statt in ck_cleaning_cycles_release zu laufen
- [ ] #3 Rolle secretariat
<!-- AC:END -->
