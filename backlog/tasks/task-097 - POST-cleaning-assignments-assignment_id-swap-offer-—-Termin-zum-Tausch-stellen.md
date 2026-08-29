---
id: TASK-097
title: >-
  POST /cleaning/assignments/{assignment_id}/swap-offer — Termin zum Tausch
  stellen
status: Done
assignee: []
created_date: '2026-08-27 22:43'
updated_date: '2026-08-28 21:24'
labels:
  - wb-backend
  - route
  - putzdienst
  - eltern
  - zweiter-zyklus
milestone: m-5
dependencies: []
references:
  - api/putzdienst-api.md
  - soll-prozesse/01-putzdienst.md
priority: high
ordinal: 109000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Z8 des Blocks: Eltern tauschen direkt untereinander, ohne das Sekretariat. Ein Angebot läuft bis zur Freikauf-Frist seines eigenen Termins und verfällt dann ohne eigenen Vorgang.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Nur eigene Termine, nur vor der Freikauf-Frist
- [x] #2 Ein gelaufener Termin lässt sich nicht mehr tauschen
<!-- AC:END -->
