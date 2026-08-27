---
id: TASK-104
title: POST /payments/callback — der Rückruf des Zahlungsdienstes
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-27 23:29'
labels:
  - wb-backend
  - route
  - zahlung
  - querschnitt
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - api/putzdienst-api.md
  - api/gemeinsam.md
priority: high
ordinal: 116000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die einzige Route ohne Anmeldung; ihre Signaturprüfung ist die ganze Zugangskontrolle. Der Fall Zahlung ohne Vorgang ist in api/gemeinsam.md festgelegt und braucht die drei Schemaergänzungen aus dem Ticket dazu.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Signaturprüfung gegen die Secret-Datei, kein Fallback ohne Prüfung
- [ ] #2 Doppelter Rückruf ändert nichts (payment_reference ist UNIQUE)
<!-- AC:END -->
