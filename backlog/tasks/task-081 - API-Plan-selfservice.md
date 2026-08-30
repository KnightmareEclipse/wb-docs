---
id: TASK-081
title: API-Plan selfservice
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 15:37'
labels:
  - wb-docs
  - api-plan
  - selfservice
milestone: m-5
dependencies: []
references:
  - prompts/api-planen.md
  - schema/selfservice-schema.sql
  - api/gemeinsam.md
ordinal: 93000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ohne eigene Tabellen. Explizit nachrangig, erst nach Abschluss aller anderen Domänen. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/selfservice-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
