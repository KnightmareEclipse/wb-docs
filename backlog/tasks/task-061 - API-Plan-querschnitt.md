---
id: TASK-061
title: API-Plan querschnitt
status: To Do
assignee: []
created_date: '2026-08-27 11:39'
labels:
  - wb-docs
  - api-plan
  - querschnitt
milestone: m-1
dependencies: []
references:
  - prompts/api-planen.md
  - schema/querschnitt-schema.sql
  - api/gemeinsam.md
ordinal: 73000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zustimmung (Q1), Dokument und Signatur (Q2), Zahlungsvorgang (Q3), Bereichsstruktur (Q4), Nachzieh-Aufgabe (Q5). Eine Domäne je Durchgang, wie beim Schema. Der Plan entsteht in wb-docs, gebaut wird danach in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 api/querschnitt-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [ ] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
