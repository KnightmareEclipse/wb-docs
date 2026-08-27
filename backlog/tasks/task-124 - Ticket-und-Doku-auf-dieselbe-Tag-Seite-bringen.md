---
id: TASK-124
title: Ticket und Doku auf dieselbe Tag-Seite bringen
status: To Do
assignee: []
created_date: '2026-08-27 23:30'
labels:
  - wb-docs
  - werkzeug
milestone: m-5
dependencies: []
references:
  - werkzeuge.md
ordinal: 136000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Backlog.md schreibt labels: in die Frontmatter, Quartz liest tags:. Deshalb steht ein Ticket nicht auf derselben Tag-Seite wie die Doku, die es betrifft. Die Volltextsuche findet beide unabhängig davon, der Graph verbindet sie nicht. Zu lösen entweder über Quartz-Konfiguration oder dadurch, dass die Tickets beide Schlüssel tragen — ohne dass Backlog.md den zweiten beim Bearbeiten wieder verwirft.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ein Ticket und die Datei, die es betrifft, stehen auf derselben Tag-Seite
- [ ] #2 Backlog.md verwirft den Schlüssel beim nächsten Bearbeiten nicht
<!-- AC:END -->
