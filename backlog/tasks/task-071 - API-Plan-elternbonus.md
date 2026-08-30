---
id: TASK-071
title: API-Plan elternbonus
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 13:41'
labels:
  - wb-docs
  - api-plan
  - elternbonus
milestone: m-5
dependencies: []
references:
  - prompts/api-planen.md
  - schema/elternbonus-schema.sql
  - api/gemeinsam.md
  - api/elternbonus-api.md
ordinal: 83000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bestätigte Stunden je Familie und Schuljahr. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/elternbonus-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
