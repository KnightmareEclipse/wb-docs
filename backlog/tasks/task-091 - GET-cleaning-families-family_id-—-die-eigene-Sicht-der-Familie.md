---
id: TASK-091
title: 'GET /cleaning/families/{family_id} — die eigene Sicht der Familie'
status: Done
assignee: []
created_date: '2026-08-27 22:43'
updated_date: '2026-08-28 18:17'
labels:
  - wb-backend
  - route
  - putzdienst
  - eltern
milestone: m-0
dependencies: []
references:
  - api/putzdienst-api.md
  - soll-prozesse/01-putzdienst.md
priority: high
ordinal: 103000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pflichtmenge, reservierte und zugeteilte Termine, Freikäufe und offene Strafen einer Familie. Der Einstieg jeder Elternansicht im Portal.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Eltern nur die eigene Familie, Ownership-Check in der Query
- [x] #2 Freigekaufte Termine sind als solche erkennbar
<!-- AC:END -->
