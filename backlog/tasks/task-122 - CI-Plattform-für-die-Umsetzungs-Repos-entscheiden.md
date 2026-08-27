---
id: TASK-122
title: CI-Plattform für die Umsetzungs-Repos entscheiden
status: To Do
assignee: []
created_date: '2026-08-27 22:46'
labels:
  - entscheidung
  - infra
  - betreiber
milestone: m-5
dependencies: []
references:
  - rules.md
ordinal: 134000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
rules.md und beide Umsetzungs-Repos schieben es auf: die Lint- und Testläufe laufen lokal vor dem Commit, CI-Wiring wartet, bis eine Plattform gewählt ist. Die Wahl selbst war nie eine Aufgabe. Preis der Verzögerung ist niedrig, solange ein Mensch die Läufe verlässlich anstößt — genau das ist die Annahme, die zu prüfen ist.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden mit Preis: welcher Dienstleister, welcher AVV-Bedarf, welches Credential
- [ ] #2 Oder ausdrücklich verworfen, mit dem Grund
<!-- AC:END -->
