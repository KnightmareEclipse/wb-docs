---
id: TASK-072
title: 'Routen bauen: elternbonus'
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 14:42'
labels:
  - wb-backend
  - route
  - elternbonus
milestone: m-5
dependencies:
  - TASK-071
references:
  - api/elternbonus-api.md
  - wb-backend/app/db/changelog.py
  - wb-backend/app/routers/elternbonus.py
ordinal: 84000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Folgt dem API-Plan. Der Zuschnitt der einzelnen Routen entsteht dort — dieses Ticket wird danach zerlegt, nicht vorher geraten.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Jeder Endpunkt schreibt über die Schreibschicht, nicht an ihr vorbei
- [x] #2 Tabellenrechte und enge Rollen in der Migration der Domäne mitgezogen
<!-- AC:END -->
