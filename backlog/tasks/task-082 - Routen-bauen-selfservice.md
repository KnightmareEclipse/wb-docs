---
id: TASK-082
title: 'Routen bauen: selfservice'
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 15:37'
labels:
  - wb-backend
  - route
  - selfservice
milestone: m-5
dependencies:
  - TASK-081
references:
  - api/selfservice-api.md
  - wb-backend/app/db/changelog.py
ordinal: 94000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Folgt dem API-Plan. Der Zuschnitt der einzelnen Routen entsteht dort — dieses Ticket wird danach zerlegt, nicht vorher geraten.

Ergebnis des Plans: **keine Route**. Von den acht Ablaufzeilen der Blöcke 00 und 02 tragen sechs eine gebaute Stammdaten- oder Querschnitts-Route, zwei sind Systemzeilen ohne Aufrufer. Begründung in api/selfservice-api.md. Die Gegenprobe fand keine Lücke.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Keine Route gebaut — sechs Zeilen zeigen auf eine vorhandene, zwei haben keinen Aufrufer
<!-- AC:END -->
