---
id: TASK-069
title: API-Plan gesundheit
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 12:46'
labels:
  - wb-docs
  - api-plan
  - gesundheit
milestone: m-4
dependencies: []
references:
  - prompts/api-planen.md
  - schema/gesundheit-schema.sql
  - api/gemeinsam.md
  - api/gesundheit-api.md
ordinal: 81000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Besondere Kategorien nach Art. 9 — die enge Rolle ist hier keine Kür, und die zweite Stufe hat ihre eigene. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/gesundheit-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
