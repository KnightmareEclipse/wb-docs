---
id: TASK-059
title: API-Plan stammdaten
status: To Do
assignee: []
created_date: '2026-08-27 11:39'
updated_date: '2026-08-28 16:46'
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
Domäne 1. Bewusst NICHT vor dem Putzdienst: Der liest Personen, Familien und Kinder, ruft dafür aber keine Route auf — er greift über die Schreibschicht auf die Tabellen zu, und was ein Elternteil von seiner Familie sieht, liefert seine eigene Route (091). Eine Stammdaten-Route braucht erst, wer Stammdaten von außen ändert, und das ist Block 02 und damit Domäne 2/4. Vorher gebaut wäre sie eine Schnittstelle ohne Aufrufer.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 api/stammdaten-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [ ] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
