---
id: TASK-064
title: 'Routen bauen: anmeldung'
status: Done
assignee: []
created_date: '2026-08-27 11:39'
updated_date: '2026-08-29 20:22'
labels:
  - wb-backend
  - route
  - anmeldung
milestone: m-2
dependencies:
  - TASK-063
references:
  - api/anmeldung-api.md
  - wb-backend/app/db/changelog.py
ordinal: 76000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Folgt dem API-Plan. Der Zuschnitt der einzelnen Routen entsteht dort — dieses Ticket wird danach zerlegt, nicht vorher geraten.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Jeder Endpunkt schreibt über die Schreibschicht, nicht an ihr vorbei
- [x] #2 Tabellenrechte und enge Rollen in der Migration der Domäne mitgezogen
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Gebaut in wb-backend PR #5: 54 Routen in app/routers/anmeldung.py, Gegenprobe 54 = 54 gegen api/anmeldung-api.md. Jeder Endpunkt hängt an route_class=TransactionRoute und schreibt über die ORM-Schicht; tests/test_changelog.py fängt das Gegenteil. Die engen Rollen sind spaltengenau nachgezogen — backend_admissions hält jetzt auch das UPDATE auf applications.assessed_level_id und backend_runtime keines mehr, backend_finance das INSERT auf sepa_mandates. 93 neue Tests (326 -> 419), die vierzehn Prüfskripte je rc=0.
<!-- SECTION:FINAL_SUMMARY:END -->
