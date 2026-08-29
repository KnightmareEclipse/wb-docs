---
id: TASK-103
title: >-
  PUT /cleaning/slots/{slot_id}/attendance-sheet — die gedruckte Liste als
  Vorgang abschließen
status: Done
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-28 21:43'
labels:
  - wb-backend
  - route
  - putzdienst
  - sekretariat
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - api/putzdienst-api.md
  - schema/putzdienst-schema.sql
priority: high
ordinal: 115000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gegenstück zum Erzeugen: die zurückkommende Papierliste wird in einem Zug übernommen, statt Zeile für Zeile.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Eine Transaktion für die ganze Liste
- [x] #2 Ein zweites Zurücktragen überschreibt nicht stillschweigend
<!-- AC:END -->
