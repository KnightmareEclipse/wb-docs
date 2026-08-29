---
id: TASK-093
title: 'POST /cleaning/families/{family_id}/buyouts — Jahres-Freikauf'
status: Done
assignee: []
created_date: '2026-08-27 22:43'
updated_date: '2026-08-28 23:23'
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
- [x] #1 Betrag kommt aus configured_values, nie aus dem Code
- [x] #2 Der Jahres-Freikauf deckt nur die offenen Pflichten; ein reservierter Termin bleibt stehen und wird ueber den Einzel-Freikauf abgeloest
<!-- AC:END -->
