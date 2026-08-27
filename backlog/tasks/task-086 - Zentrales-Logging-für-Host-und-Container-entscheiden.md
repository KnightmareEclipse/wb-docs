---
id: TASK-086
title: Zentrales Logging für Host und Container entscheiden
status: To Do
assignee: []
created_date: '2026-08-27 11:40'
labels:
  - entscheidung
  - infra
milestone: m-1
dependencies: []
references:
  - project-parts.md
  - idea/03-container-anwendung.md
ordinal: 98000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die einzige offene Teilentscheidung des Monitoring-Abschnitts: eine gemeinsame Senke statt eigenem Log-Stack, naheliegender Kandidat journald. Die endgültige Wahl folgt mit dem tatsächlichen Log-Volumen. Retention 30–90 Tage gilt unabhängig vom Tool.
<!-- SECTION:DESCRIPTION:END -->
