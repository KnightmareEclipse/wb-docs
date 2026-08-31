---
id: TASK-143
title: Die drei Erinnerungen zum Schulanfang am 1. September
status: To Do
assignee: []
created_date: '2026-08-31 00:59'
labels:
  - wb-backend
  - stammdaten
  - lauf
milestone: m-5
dependencies: []
references:
  - api/stammdaten-api.md
  - soll-prozesse/04-schuljahreswechsel.md
ordinal: 155000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der dritte der drei fehlenden Läufe der Stammdaten (api/stammdaten-api.md, "Die vier Läufe").

Aus 04 Z4: am 1. September, ein festes Datum, entstehen drei Aufgaben beim Sekretariat — Putzdienstjahr einrichten, Voranmeldung öffnen, Lösch-Lauf anstoßen. Im August wäre nichts davon zu erledigen.

Die Aufgabe ist hier ihre eigene Marke: raise_task ersetzt eine offene, statt sich danebenzulegen (app/services/querschnitt.py), also braucht der Lauf keine Spalte. Was in den drei Erinnerungen inhaltlich noch fehlt, fragt TASK-046 — das ist der Inhalt, dies der Lauf.

Gefunden im dreizehnten API-Prüfzyklus als STAMMDATEN-R9.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Run-Zeile in app/runs.py unter dem Aktor system:rollover
- [ ] #2 Zweimal hintereinander gerufen entstehen keine sechs Aufgaben
- [ ] #3 Ein Test in tests/test_runs.py
<!-- AC:END -->
