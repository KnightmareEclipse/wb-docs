---
id: TASK-275
title: >-
  Sign-in-Frequency-Regel für die Personal-Anmeldung in der Conditional Access
  des Tenants
status: To Do
assignee: []
created_date: '2026-09-06 02:00'
labels:
  - wartet
  - betreiber
  - infra
  - zugang
milestone: m-5
dependencies: []
ordinal: 288000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
hebel.md verspricht „Mitarbeitende acht Stunden, alle Zahlen fest und nirgends einstellbar" — das ist im Code nicht einlösbar (AUTH-R4): MSAL erneuert das Zugriffstoken still über ein Refresh-Token, jedes erneuerte Token trägt ein frisches iat, und wb-backend sieht dabei nie, wie alt die eigentliche Anmeldung ist. Eine eigene Obergrenze gegen iat liefe deshalb leer — sie griffe nie, weil das Token ohnehin nie so alt wird. Die einzige Stelle, die eine echte Obergrenze durchsetzen kann, ist eine Sign-in-Frequency-Regel in der Conditional Access des Tenants, keine Zeile in wb-backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Conditional-Access-Regel mit Sign-in Frequency 8h auf die App-Registrierung angewandt
- [ ] #2 hebel.md nennt die Regel als Mechanismus statt einer Code-Zahl, die es nicht gibt
<!-- AC:END -->
