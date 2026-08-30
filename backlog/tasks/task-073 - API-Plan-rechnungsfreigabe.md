---
id: TASK-073
title: API-Plan rechnungsfreigabe
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 14:52'
labels:
  - wb-docs
  - api-plan
  - rechnungsfreigabe
milestone: m-5
dependencies: []
references:
  - prompts/api-planen.md
  - schema/rechnungsfreigabe-schema.sql
  - api/gemeinsam.md
ordinal: 85000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beleg, Freigabeschritt, Aufteilung auf mehrere Bereiche, Lieferant. Läuft heute stabil über die Teams-App, daher niedrige Migrationspriorität. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/rechnungsfreigabe-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
