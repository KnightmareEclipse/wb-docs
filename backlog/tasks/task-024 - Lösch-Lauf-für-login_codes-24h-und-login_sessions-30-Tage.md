---
id: TASK-024
title: Lösch-Lauf für login_codes (24h) und login_sessions (30 Tage)
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - wb-backend
  - lauf
  - dsgvo
milestone: m-1
dependencies: []
references:
  - TODO-SESSIONS.md
  - schema/stammdaten-schema.sql
  - wb-backend/app/runs.py
priority: high
ordinal: 24000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das Schema sagt die Fristen zu, niemand führt sie aus. Beide gehören keiner Fachdomäne, entstehen also nicht mit einer. Kein Platzproblem, sondern ein Frist-Problem: Ohne den Lauf ist login_codes eine unbefristete Liste jeder Adresse, die je jemand ins Anmeldefeld getippt hat.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Zeile im Register des Lauf-Diensts
- [ ] #2 login_codes nach 24 Stunden, login_sessions nach 30 Tagen
<!-- AC:END -->
