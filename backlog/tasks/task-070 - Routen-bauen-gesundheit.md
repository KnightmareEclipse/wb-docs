---
id: TASK-070
title: 'Routen bauen: gesundheit'
status: To Do
assignee: []
created_date: '2026-08-27 11:40'
labels:
  - wb-backend
  - route
  - gesundheit
milestone: m-4
dependencies:
  - TASK-069
references:
  - api/gesundheit-api.md
  - wb-backend/app/db/changelog.py
ordinal: 82000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Folgt dem API-Plan. Der Zuschnitt der einzelnen Routen entsteht dort — dieses Ticket wird danach zerlegt, nicht vorher geraten.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Jeder Endpunkt schreibt über die Schreibschicht, nicht an ihr vorbei
- [ ] #2 Tabellenrechte und enge Rollen in der Migration der Domäne mitgezogen
<!-- AC:END -->
