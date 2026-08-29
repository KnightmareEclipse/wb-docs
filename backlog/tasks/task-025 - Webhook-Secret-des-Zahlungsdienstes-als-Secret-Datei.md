---
id: TASK-025
title: Webhook-Secret des Zahlungsdienstes als Secret-Datei
status: Done
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-28 23:59'
labels:
  - wb-backend
  - zahlung
  - secret
milestone: m-0
dependencies: []
references:
  - wb-backend/CLAUDE.md
priority: high
ordinal: 25000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Eine Secret-Datei wie die anderen, keine Umgebungsvariable mit dem Wert darin. Die Rückrufroute ist die einzige ohne Anmeldung; ihre Signaturprüfung ist damit die ganze Zugangskontrolle.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Secret-Datei, nicht Env-Var
- [x] #2 Signaturprüfung an der Rückrufroute, Test mit falscher Signatur
<!-- AC:END -->
