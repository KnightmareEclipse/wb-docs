---
id: TASK-108
title: Monatslauf für die Übergabe der Strafen bauen
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
labels:
  - wb-backend
  - putzdienst
  - lauf
  - buchhaltung
milestone: m-0
dependencies: []
references:
  - schema/putzdienst-schema.sql
  - soll-prozesse/01-putzdienst.md
priority: high
ordinal: 120000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
penalty_handed_over_at steht im Schema bereit, der Lauf, der sie setzt und die Strafen an die Buchhaltung übergibt, existiert nicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ausgesetzte Strafen und freigekaufte Termine gehen nicht mit
- [ ] #2 Ein verpasster Tick holt beim nächsten alles Fällige nach
<!-- AC:END -->
