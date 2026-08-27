---
id: TASK-101
title: 'PUT /cleaning/slots/{slot_id}/attendance — Anwesenheit zurücktragen'
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-27 23:29'
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
ordinal: 113000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Übernahme der Papierliste. Freigekaufte Zuteilungen gehören nicht darauf — no_show auf einer bezahlten Zeile wäre eine Strafe auf einem bezahlten Termin.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Freigekaufte Zuteilungen sind ausgenommen
- [ ] #2 attendance_recorded_at wird gesetzt, ein zweiter Lauf ändert nichts
<!-- AC:END -->
