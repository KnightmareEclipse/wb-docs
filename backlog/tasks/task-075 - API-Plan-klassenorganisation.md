---
id: TASK-075
title: API-Plan klassenorganisation
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 15:25'
labels:
  - wb-docs
  - api-plan
  - klassenorganisation
milestone: m-5
dependencies: []
references:
  - prompts/api-planen.md
  - schema/klassenorganisation-schema.sql
  - api/gemeinsam.md
ordinal: 87000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Elternvertretung und Stellvertretung je Klasse. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/klassenorganisation-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
