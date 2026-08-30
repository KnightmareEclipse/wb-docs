---
id: TASK-136
title: Wählbare Sorgeberechtigte je Klasse als Stammdaten-Route
status: Done
assignee: []
created_date: '2026-08-30 15:25'
updated_date: '2026-08-30 17:00'
labels:
  - wb-docs
  - wb-backend
  - stammdaten
  - klassenorganisation
milestone: m-5
dependencies: []
references:
  - api/stammdaten-api.md
  - api/klassenorganisation-api.md
  - soll-prozesse/16-elternvertretung.md
priority: medium
ordinal: 148000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Elternvertretung wird 'ausgewählt und nicht eingetippt' (16), aber es gibt keine Route, die der Klassenlehrkraft die Sorgeberechtigten der Kinder ihrer Klasse zur Auswahl gibt — Name und person_id, kein Kontaktweg. GET /classes/{class_id}/roster trägt die Kinder samt Abholberechtigten, nicht die wählbaren Personen; GET /employees/selectable ist das Gegenstück für Mitarbeitende. Sie gehört den Stammdaten, weil ihr die Daten gehören: erst api/stammdaten-api.md ergänzen, dann in wb-backend bauen. Vor TASK-076, sonst hat POST /classes/{class_id}/representatives keine Auswahl davor.

Die Doku-Hälfte steht: api/stammdaten-api.md trägt GET /classes/{class_id}/selectable-guardians. Offen ist der Bau in wb-backend.
<!-- SECTION:DESCRIPTION:END -->
