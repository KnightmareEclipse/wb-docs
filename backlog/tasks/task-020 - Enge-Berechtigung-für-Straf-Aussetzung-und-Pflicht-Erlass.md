---
id: TASK-020
title: Enge Berechtigung für Straf-Aussetzung und Pflicht-Erlass
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - wb-backend
  - putzdienst
  - rollen
milestone: m-0
dependencies: []
references:
  - TODO-SESSIONS.md
  - schema/putzdienst-schema.sql
  - glossar.md
priority: high
ordinal: 20000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ein Spalten-GRANT plus Rollenwahl, kein Anwendungs-if. Auslösen dürfen beides Geschäftsführung und Schulleitung. Eine Schreib- und keine Lesebeschränkung: Buchhaltung, Buchungsansicht und Solver lesen beide Stellen weiter, eng gelesen wird allein der Grund der Abweichung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Spalten-GRANT in der Migration der Domäne, __protected_columns__ am Modell
- [ ] #2 tests/test_privileges.py weist ein zu breites Recht ab
<!-- AC:END -->
