---
id: TASK-060
title: 'Routen bauen: stammdaten'
status: To Do
assignee: []
created_date: '2026-08-27 11:39'
labels:
  - wb-backend
  - route
  - stammdaten
milestone: m-1
dependencies:
  - TASK-059
references:
  - api/stammdaten-api.md
  - wb-backend/app/db/changelog.py
ordinal: 72000
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
