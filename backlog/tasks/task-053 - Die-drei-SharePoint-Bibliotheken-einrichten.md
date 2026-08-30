---
id: TASK-053
title: Die drei SharePoint-Bibliotheken einrichten
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
labels:
  - wartet
  - zweiter-admin
  - sharepoint
milestone: m-4
dependencies: []
references:
  - grenzkarte.md
  - api/rechnungsfreigabe-api.md
  - oberflaechen.md
priority: high
ordinal: 56000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Eine für die von Weltenbaum erzeugten Unterlagen samt Vorlagen-Ordner (App schreibt, Sekretariat und Geschäftsführung lesen nur), eine für die Schülerakte (Sekretariat und Geschäftsführung schreiben), eine für die Beleganhänge der Rechnungsfreigabe (App schreibt und liest, niemand direkt — Ordner je Kalenderjahr, kein Kindbezug). Je Bibliothek ein Sites.Selected-Grant. Form und Begründung stehen fest, offen sind die konkreten Sites.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Keine Berechtigung je Kind, Klasse oder Zweig
- [ ] #2 Die vorhandenen Aktenordner einmalig mit child_file_folders verknüpfen
- [ ] #3 Auf die Beleg-Bibliothek hat kein Mensch Direktzugriff, auch nicht Sekretariat und Geschäftsführung
<!-- AC:END -->
