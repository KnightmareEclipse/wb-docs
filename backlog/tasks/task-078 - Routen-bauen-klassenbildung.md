---
id: TASK-078
title: 'Routen bauen: klassenbildung'
status: To Do
assignee: []
created_date: '2026-08-27 11:40'
labels:
  - wb-backend
  - route
  - klassenbildung
milestone: m-5
dependencies:
  - TASK-077
references:
  - api/klassenbildung-api.md
  - wb-backend/app/db/changelog.py
ordinal: 90000
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
