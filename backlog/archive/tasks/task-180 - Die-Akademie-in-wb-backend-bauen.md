---
id: TASK-180
title: Die Akademie in wb-backend bauen
status: To Do
assignee: []
created_date: '2026-09-01 19:10'
labels:
  - api
  - akademie
  - wb-backend
dependencies:
  - TASK-179
references:
  - soll-prozesse/21-akademie.md
  - prompts/api-bauen.md
ordinal: 192000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Migration, Modelle, Schreibschicht und Router für die Akademie nach prompts/api-bauen.md, danach api-pruefen.md in einer frischen Session. Der öffentliche Endpunkt der Ausschreibung ist der einzige ohne Zugang — er gehört in die Prüfung an erster Stelle.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Migration, Modelle und Schreibschicht stehen; kein Endpunkt schreibt an der Schreibschicht vorbei
- [ ] #2 Der öffentliche Endpunkt liefert ohne Anmeldung und ohne personenbezogene Angabe
- [ ] #3 Tests für Platzzahl, Zielgruppe, fremdes Kind und beide Zahlwege — je erst rot, dann grün
<!-- AC:END -->
