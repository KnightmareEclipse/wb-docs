---
id: TASK-111
title: 'Dokumenterzeugung aufbauen: Word-Vorlage, docxtpl, PDF über Graph'
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
labels:
  - wb-backend
  - anmeldung
  - sharepoint
milestone: m-2
dependencies: []
references:
  - oberflaechen.md
  - schema/anmeldung-schema.sql
ordinal: 123000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
In oberflaechen.md entschieden, nirgends beauftragt: Word-Vorlage mit Platzhaltern, gefüllt per docxtpl im Backend, PDF-Konvertierung über Graph (content?format=pdf). Ohne sie steht die Vertragsstrecke.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Kein Konverter im Container, kein Premium-Konnektor
- [ ] #2 Die erzeugte Datei landet in der Bibliothek, in der Menschen nur lesen
<!-- AC:END -->
