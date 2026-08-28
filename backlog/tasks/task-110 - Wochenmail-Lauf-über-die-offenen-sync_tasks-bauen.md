---
id: TASK-110
title: Wochenmail-Lauf über die offenen sync_tasks bauen
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-28 16:46'
labels:
  - wb-backend
  - lauf
  - mail
  - querschnitt
milestone: m-0
dependencies: []
references:
  - soll-prozesse/hebel.md
  - schema/querschnitt-schema.sql
  - container.md
ordinal: 122000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
hebel.md sagt jedem Block zu, dass Änderungen die Fremdsysteme erreichen: eine offene Aufgabe je Fremdsystem bei der Stelle, die es ohnehin pflegt, gesammelt in einer Wochenmail. Die Tabelle steht, der Lauf existiert nicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Mail geht an die Rolle, nicht an einen Menschen
- [ ] #2 Keine offenen Aufgaben heißt keine Mail
<!-- AC:END -->
