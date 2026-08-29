---
id: TASK-095
title: 'POST /cleaning/assignments/{assignment_id}/penalty-waiver — Strafe aussetzen'
status: Done
assignee: []
created_date: '2026-08-27 22:43'
updated_date: '2026-08-28 21:43'
labels:
  - wb-backend
  - route
  - putzdienst
  - rollen
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - api/putzdienst-api.md
  - schema/putzdienst-schema.sql
priority: high
ordinal: 107000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aussetzung der 45-Euro-Strafe. Auslösen dürfen das nur Geschäftsführung und Schulleitung; die Enge ist ein Spalten-GRANT plus Rollenwahl, kein Anwendungs-if.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Enge Rolle über SET LOCAL ROLE, nicht über ein if im Router
- [x] #2 Der Grund der Abweichung bleibt eng gelesen
<!-- AC:END -->
