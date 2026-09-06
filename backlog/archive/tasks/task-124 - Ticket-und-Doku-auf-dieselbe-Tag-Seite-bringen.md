---
id: TASK-124
title: Ticket und Doku auf dieselbe Tag-Seite bringen
status: To Do
assignee: []
created_date: '2026-08-27 23:30'
updated_date: '2026-08-30 18:14'
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Die halbe Frage ist gemessen und beantwortet: Backlog.md verwirft einen zweiten Schlüssel nicht. Ein von Hand eingetragenes tags: in der Frontmatter eines Tickets überlebt ein backlog task edit unverändert — AC #2 ist damit über den Weg 'beide Schlüssel' erreichbar, ohne Quartz zu konfigurieren. Die andere Hälfte ist keine Werkzeugfrage: Die Doku hat heute gar keine Frontmatter (außer index.md mit title:), also gibt es auf keiner Tag-Seite eine Doku-Datei, neben der ein Ticket stehen könnte. AC #1 verlangt damit die Entscheidung, ob die .md-Dateien Frontmatter bekommen — dreißig Dateien, und CLAUDE.md verbietet Boilerplate. Zweiter Weg ohne Frontmatter: Die Tickets tragen ihre Bezüge schon als references:; als [[wikilink]] im Rumpf verbände sie der Graph und die Backlinks, ohne dass eine Datei ein Tag braucht. Beide Wege sind eine Entscheidung über die Form des Repos, keine über Quartz.
<!-- SECTION:NOTES:END -->
