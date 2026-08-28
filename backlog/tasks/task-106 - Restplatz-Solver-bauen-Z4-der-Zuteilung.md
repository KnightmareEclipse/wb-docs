---
id: TASK-106
title: Restplatz-Solver bauen (Z4 der Zuteilung)
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-28 16:27'
labels:
  - wb-backend
  - putzdienst
  - lauf
milestone: m-0
dependencies: []
references:
  - soll-prozesse/01-putzdienst.md
  - schema/putzdienst-schema.sql
  - api/putzdienst-api.md
priority: high
ordinal: 118000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das Modell des Solvers fehlt ganz: ortools steht in keiner requirements.in, im Code stehen nur zwei Kommentare, die ihn erwähnen. Er verteilt die Restplätze nach den Reservierungen und darf die Platzzahl überschreiten — das Sekretariat entscheidet danach am Gesamtbild. Die fünf Zuteilungs-Routen setzen ihn voraus.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Läuft als Lauf im Register des Lauf-Diensts, Marke ist allocated_at
- [ ] #2 Ein zweiter Lauf nach der Freigabe teilt nicht neu zu
- [ ] #3 Überschrittene Termine sind im Gesamtbild sichtbar, nicht stillschweigend verteilt
- [ ] #4 Eine Familie, die ihre Pflichtzahl freigekauft hat, bekommt keine Zuteilung — der Freikauf senkt die Pflichtzahl, bevor der Solver rechnet
<!-- AC:END -->
