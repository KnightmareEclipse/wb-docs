---
id: TASK-078
title: 'Routen bauen: klassenbildung'
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 15:29'
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

Ergebnis des Plans: **keine Route**. Die drei Ablaufzeilen laufen über gebaute Stammdaten- und Querschnitts-Routen, die Domäne schreibt eine einzige fremde Spalte (children.class_id). Begründung in api/klassenbildung-api.md. Der eine Fund der Gegenprobe ist TASK-137.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Keine Route gebaut — jede Zeile der Ablauftabelle zeigt auf eine vorhandene
<!-- AC:END -->
