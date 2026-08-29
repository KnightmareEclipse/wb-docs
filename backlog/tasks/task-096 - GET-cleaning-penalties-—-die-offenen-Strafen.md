---
id: TASK-096
title: GET /cleaning/penalties — die offenen Strafen
status: Done
assignee: []
created_date: '2026-08-27 22:43'
updated_date: '2026-08-28 21:43'
labels:
  - wb-backend
  - route
  - putzdienst
  - buchhaltung
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - api/putzdienst-api.md
  - schema/putzdienst-schema.sql
priority: high
ordinal: 108000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Übersicht der offenen und übergebenen Strafen für Buchhaltung und Sekretariat.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Freigekaufte Zuteilungen tauchen nicht als Strafe auf
- [x] #2 Übergebene sind von offenen unterscheidbar
<!-- AC:END -->
