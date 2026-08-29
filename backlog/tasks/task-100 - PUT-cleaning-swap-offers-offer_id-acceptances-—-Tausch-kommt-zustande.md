---
id: TASK-100
title: 'PUT /cleaning/swap-offers/{offer_id}/acceptances — Tausch kommt zustande'
status: Done
assignee: []
created_date: '2026-08-27 22:43'
updated_date: '2026-08-28 21:24'
labels:
  - wb-backend
  - route
  - putzdienst
  - eltern
  - mail
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - api/putzdienst-api.md
  - soll-prozesse/01-putzdienst.md
priority: high
ordinal: 112000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Tausch braucht keine Entscheidung: er kommt zustande, sobald sich zwei Angebote gegenseitig annehmen. Danach geht eine Mail an beide Familien mit dem jeweils neuen Termin.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Zustandekommen ist beidseitig, nicht einseitig
- [x] #2 Beide Familien bekommen ihre Mail mit dem neuen Termin
<!-- AC:END -->
