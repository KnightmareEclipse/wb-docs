---
id: TASK-019
title: Frist des Einzel-Freikaufs als Backend-Prüfung
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-27 23:29'
labels:
  - wb-backend
  - putzdienst
  - zahlung
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - schema/putzdienst-schema.sql
priority: high
ordinal: 19000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
„Nur vor dem Termindatum" ist keine Constraint, weil das Datum an cleaning_slots hängt. Sie muss an derselben Stelle sitzen, die die Zahlung auslöst — sonst entsteht ein bezahlter Freikauf für einen bereits gelaufenen Termin.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Prüfung sitzt an der Stelle, die die Zahlung auslöst
- [ ] #2 Test: Freikauf auf einen vergangenen Termin wird abgewiesen, bevor Geld fließt
<!-- AC:END -->
