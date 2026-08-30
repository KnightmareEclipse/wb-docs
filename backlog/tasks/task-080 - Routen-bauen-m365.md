---
id: TASK-080
title: 'Routen bauen: m365'
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 15:34'
labels:
  - wb-backend
  - route
  - m365
milestone: m-5
dependencies:
  - TASK-079
references:
  - api/m365-api.md
  - wb-backend/app/db/changelog.py
ordinal: 92000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Folgt dem API-Plan. Der Zuschnitt der einzelnen Routen entsteht dort — dieses Ticket wird danach zerlegt, nicht vorher geraten.

Ergebnis des Plans: **keine Route**. Alle fünf Ablaufzeilen laufen über gebaute Stammdaten- und Querschnitts-Routen; die Domäne schreibt nichts in den Tenant. Begründung in api/m365-api.md. Die Gegenprobe fand keine Lücke.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Keine Route gebaut — jede Zeile der Ablauftabelle zeigt auf eine vorhandene
<!-- AC:END -->
