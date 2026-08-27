---
id: TASK-004
title: 'PATCH /cleaning/assignments/{assignment_id} — verschieben'
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
  - schema/putzdienst-schema.sql
priority: high
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Derselbe Zyklus, dieselbe Art, nicht nach attendance_recorded_at.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Nur innerhalb desselben Zyklus und derselben Art
- [ ] #2 Abgewiesen, sobald attendance_recorded_at steht
<!-- AC:END -->
