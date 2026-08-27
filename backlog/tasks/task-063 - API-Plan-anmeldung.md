---
id: TASK-063
title: API-Plan anmeldung
status: To Do
assignee: []
created_date: '2026-08-27 11:39'
labels:
  - wb-docs
  - api-plan
  - anmeldung
milestone: m-2
dependencies: []
references:
  - prompts/api-planen.md
  - schema/anmeldung-schema.sql
  - api/gemeinsam.md
ordinal: 75000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Voranmeldung, Anmeldetag, Aufnahmeentscheidung, Vertrag — eine Domäne, drei Phasen, dazu der Hortvertrag. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 api/anmeldung-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [ ] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
