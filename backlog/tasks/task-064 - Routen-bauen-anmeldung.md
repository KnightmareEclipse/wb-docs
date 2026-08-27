---
id: TASK-064
title: 'Routen bauen: anmeldung'
status: To Do
assignee: []
created_date: '2026-08-27 11:39'
labels:
  - wb-backend
  - route
  - anmeldung
milestone: m-2
dependencies:
  - TASK-063
references:
  - api/anmeldung-api.md
  - wb-backend/app/db/changelog.py
ordinal: 76000
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
