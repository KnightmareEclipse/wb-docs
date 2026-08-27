---
id: TASK-094
title: 'POST /cleaning/assignments/{assignment_id}/buyout — Einzel-Freikauf'
status: To Do
assignee: []
created_date: '2026-08-27 22:43'
updated_date: '2026-08-27 23:29'
labels:
  - wb-backend
  - route
  - putzdienst
  - zahlung
  - eltern
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - api/putzdienst-api.md
  - schema/putzdienst-schema.sql
priority: high
ordinal: 106000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ein einzelner Termin wird freigekauft. Die Frist (nur vor dem Termindatum) ist eine Backend-Prüfung, weil das Datum an cleaning_slots hängt — siehe das Ticket dazu.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Nur vor dem Termindatum, an derselben Stelle wie die Zahlung
- [ ] #2 Der Platz wird wieder frei
<!-- AC:END -->
