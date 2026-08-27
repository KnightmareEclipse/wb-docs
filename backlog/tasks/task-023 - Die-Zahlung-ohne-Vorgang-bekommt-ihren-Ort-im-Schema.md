---
id: TASK-023
title: Die Zahlung ohne Vorgang bekommt ihren Ort im Schema
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - wb-backend
  - schema
  - zahlung
milestone: m-0
dependencies: []
references:
  - TODO-SESSIONS.md
  - api/gemeinsam.md
  - api/putzdienst-api.md
priority: high
ordinal: 23000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das Geld ist da, die Bedingung trägt beim Rückruf nicht mehr. Drei Ergänzungen, alle drei mit der Domäne, die zuerst bezahlt. Ohne sie kommt das Geld an und keine Zeile hält es fest.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 ck_payments_single_cause lässt den vorgangslosen Fall zu (heute genau einer der vier Schlüssel)
- [ ] #2 sync_tasks bekommt den Bezug auf die Zahlung als achten
- [ ] #3 sync_targets bekommt sein erstes hausinternes Ziel
<!-- AC:END -->
