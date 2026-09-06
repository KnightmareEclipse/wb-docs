---
id: TASK-243
title: 'template_docx wird nachgeladen, nicht mitgelesen'
status: To Do
assignee: []
created_date: '2026-09-04 12:36'
labels:
  - wb-backend
dependencies: []
references:
  - dokumente.md
ordinal: 256000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`GET /contract-texts` liefert je Code die geltende und die angekuendigte Fassung. Traegt `contract_texts` die eingefrorene Vorlagendatei als `bytea` (TASK-222), zieht jeder Aufruf dieser Route saemtliche Vorlagen mit — bei zehn Sorten je zwei Fassungen rund acht Megabyte in einen Container, dessen Anwendung mit 77 MB gemessen ist.

Dieselbe Bauform, die fuer die Art.-9-Wertspalten schon gilt (TASK-155, "die fuenf Wertspalten sind deferred"), fehlt hier.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 template_docx wird nachgeladen und nicht mit der Zeile gelesen
- [ ] #2 GET /contract-texts liefert Pruefsumme und Einfrierzeitpunkt, nie die Bytes
<!-- AC:END -->
