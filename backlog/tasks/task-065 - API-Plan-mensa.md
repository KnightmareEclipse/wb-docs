---
id: TASK-065
title: API-Plan mensa
status: To Do
assignee: []
created_date: '2026-08-27 11:39'
labels:
  - wb-docs
  - api-plan
  - mensa
milestone: m-2
dependencies: []
references:
  - prompts/api-planen.md
  - schema/mensa-schema.sql
  - api/gemeinsam.md
ordinal: 77000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Küchenprofil je Kind und das eigenständige Schuljahres-Abo der Realschule samt seinen Wochentagen. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 api/mensa-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [ ] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
