---
id: TASK-143
title: Die drei Erinnerungen zum Schulanfang am 1. September
status: Done
assignee: []
created_date: '2026-08-31 00:59'
updated_date: '2026-08-31 20:12'
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

**Entschieden: drei Ziele, eines je Erinnerung** — `cleaning_year_setup`, `preregistration_opening`, `deletion_run`, alle bei `secretariat`. Eine Sammelaufgabe scheiterte an `ix_sync_tasks_open_year` (unique auf Ziel und Schuljahr) und wäre auch fachlich schlechter: `outcome` hängt an der Zeile, also ließe sich „war schon offen, nichts zu tun" für eine der drei nicht sagen, und die Wochenmail trüge wochenlang dieselbe Zeile, während zwei Drittel erledigt sind. Die Zeile in api/querschnitt-api.md, die das Gegenteil sagte, ist richtiggestellt; `in_house` bleibt bei der Unterschriftenliste.

Die Marke ist, **dass** die Aufgabe für dieses Schuljahr angelegt wurde, nicht dass sie offen steht — sonst legt der nächste Tick fünf Minuten nach dem Abhaken dieselbe Erinnerung neu an. Der Test dazu wurde mit herausgenommener Sicherung rot gesehen.

<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Eine Run-Zeile in app/runs.py unter dem Aktor system:rollover
- [x] #2 Zweimal hintereinander gerufen entstehen keine sechs Aufgaben
- [x] #3 Ein Test in tests/test_runs.py
<!-- AC:END -->
