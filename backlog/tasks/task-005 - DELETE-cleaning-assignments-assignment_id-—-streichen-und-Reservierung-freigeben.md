---
id: TASK-005
title: >-
  DELETE /cleaning/assignments/{assignment_id} — streichen und Reservierung
  freigeben
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
priority: high
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Eltern nur die eigene Familie, nur source = 'reserved', nur im offenen Fenster. Das Sekretariat jeden Termin und dann mit Mail.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Eltern: eigene Familie, source = 'reserved', nur im offenen Fenster
- [x] #2 Sekretariat: jeder Termin, und dann geht eine Mail raus
<!-- AC:END -->
