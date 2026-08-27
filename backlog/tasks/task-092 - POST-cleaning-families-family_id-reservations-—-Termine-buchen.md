---
id: TASK-092
title: 'POST /cleaning/families/{family_id}/reservations — Termine buchen'
status: To Do
assignee: []
created_date: '2026-08-27 22:43'
labels:
  - wb-backend
  - route
  - putzdienst
  - eltern
milestone: m-0
dependencies: []
references:
  - api/putzdienst-api.md
  - soll-prozesse/01-putzdienst.md
priority: high
ordinal: 104000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Buchung selbst: Eltern reservieren im offenen Fenster Termine ihrer Pflichtmenge. Ohne diese Route gibt es kein Buchungsfenster.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Nur im offenen Fenster, nur bis zur Pflichtmenge
- [ ] #2 source = 'reserved', Platzzahl des Termins wird nicht überschritten
<!-- AC:END -->
