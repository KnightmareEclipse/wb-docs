---
id: TASK-067
title: API-Plan ferien
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-29 22:10'
labels:
  - wb-docs
  - api-plan
  - ferien
milestone: m-3
dependencies: []
references:
  - prompts/api-planen.md
  - schema/ferien-schema.sql
  - api/gemeinsam.md
ordinal: 79000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ferienprogramm und Kochwerkstatt: Buchung je Tag und Betreuungsende, mehrere Kinder je Formular, auch für schulfremde Kinder. Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/ferien-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
