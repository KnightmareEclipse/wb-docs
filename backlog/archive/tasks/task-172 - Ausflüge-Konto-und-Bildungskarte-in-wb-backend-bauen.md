---
id: TASK-172
title: 'Ausflüge, Konto und Bildungskarte in wb-backend bauen'
status: To Do
assignee: []
created_date: '2026-09-01 18:45'
labels:
  - wb-backend
  - veranstaltungen
  - route
  - test
dependencies:
  - TASK-171
references:
  - wb-backend/CLAUDE.md
ordinal: 184000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Migration, Modelle, Schreibschicht, Routen und Tests für beide Domänen — nach dem API-Plan, nicht davor.

Vier Stellen, die beim Bau leicht danebengehen: die Freigabe der Schulleitung als Bedingung für jede Elternsicht; die Reihenfolge Erstattung vor Gutschrift; der Ratenplan der mehrtägigen Fahrt über die vorhandene Bezahlstrecke statt einer eigenen; und der Jahresabschluss des Kontos, der vor dem Jahreslauf laufen muss — wie der des Elternbonus, aus demselben Grund.

Beschlossen am 01.09.2026 mit der Geschäftsführung, Ablauf in soll-prozesse/19-ausfluege-und-fahrten.md und soll-prozesse/20-ausflugskonto.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Migration und schema-check.sh sind grün
- [ ] #2 Kein Endpunkt schreibt an der Schreibschicht vorbei
- [ ] #3 Ein Test zeigt, dass Eltern einen nicht freigegebenen Ausflug nicht sehen
- [ ] #4 Ein Test zeigt, dass eine Gutschrift ohne Erstattung abgewiesen wird
- [ ] #5 Jeder neue Test war einmal rot
<!-- AC:END -->
