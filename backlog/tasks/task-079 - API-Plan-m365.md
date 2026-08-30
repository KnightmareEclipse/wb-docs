---
id: TASK-079
title: API-Plan m365
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 15:34'
labels:
  - wb-docs
  - api-plan
  - m365
milestone: m-5
dependencies: []
references:
  - prompts/api-planen.md
  - schema/m365-schema.sql
  - api/gemeinsam.md
ordinal: 91000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ohne eigene Tabellen, aber mit Routen: alles steht an employees, children und sync_tasks. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/m365-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
