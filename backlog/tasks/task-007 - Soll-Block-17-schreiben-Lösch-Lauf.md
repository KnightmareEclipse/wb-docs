---
id: TASK-007
title: 'Soll-Block 17 schreiben: Lösch-Lauf'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - wb-docs
  - soll-block
  - dsgvo
milestone: m-1
dependencies: []
references:
  - TODO-SESSIONS.md
  - prompts/block-fuellen.md
  - schema/querschnitt-schema.sql
priority: high
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Was verschwindet wann, in welcher Reihenfolge. Kein Nachzügler, sondern Voraussetzung: Jede Tabelle mit Personenbezug nennt im Schema ihren Löschanker, und viele zeigen auf einen Lauf, den bisher nur die Anker beschreiben. Solange er fehlt, ist die Frist selbst nirgends festgelegt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Frist für eine change_log-Zeile ohne Anker ist entschieden (rund siebzig Tabellen erreichen ihren Anker nur über einen Join)
- [ ] #2 Welche Rolle die Spur löschen darf ist entschieden — backend_runtime liest und schreibt sie heute und löscht sie nicht
- [ ] #3 Häkchen und Link in soll-prozesse/README.md gesetzt
<!-- AC:END -->
