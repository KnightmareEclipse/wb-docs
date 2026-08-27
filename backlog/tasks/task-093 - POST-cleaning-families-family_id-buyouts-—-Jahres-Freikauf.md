---
id: TASK-093
title: 'POST /cleaning/families/{family_id}/buyouts — Jahres-Freikauf'
status: To Do
assignee: []
created_date: '2026-08-27 22:43'
labels:
  - wb-backend
  - route
  - putzdienst
  - zahlung
  - eltern
milestone: m-0
dependencies: []
references:
  - api/putzdienst-api.md
  - schema/putzdienst-schema.sql
priority: high
ordinal: 105000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Familie kauft ihre gesamte Pflicht des Jahres frei. Betrag aus configured_values, Zahlung über die Sofortzahlung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Betrag kommt aus configured_values, nie aus dem Code
- [ ] #2 Bestehende Reservierungen werden dabei freigegeben
<!-- AC:END -->
