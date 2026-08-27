---
id: TASK-059
title: API-Plan stammdaten
status: To Do
assignee: []
created_date: '2026-08-27 11:39'
labels:
  - wb-docs
  - api-plan
  - stammdaten
milestone: m-1
dependencies: []
references:
  - prompts/api-planen.md
  - schema/stammdaten-schema.sql
  - api/gemeinsam.md
ordinal: 71000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Person, Familie, Kind, Erziehungsberechtigte, Mitarbeitende, Klassen — der Bestand, auf den jede andere Domäne zeigt. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 api/stammdaten-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [ ] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
