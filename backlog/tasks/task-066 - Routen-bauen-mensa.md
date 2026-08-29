---
id: TASK-066
title: 'Routen bauen: mensa'
status: Done
assignee: []
created_date: '2026-08-27 11:39'
updated_date: '2026-08-29 21:30'
labels:
  - wb-backend
  - route
  - mensa
milestone: m-2
dependencies:
  - TASK-065
references:
  - api/mensa-api.md
  - wb-backend/app/db/changelog.py
ordinal: 78000
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
