---
id: TASK-137
title: Die Klassenlehrkraft sieht das Austrittsdatum ihrer Kinder
status: In Progress
assignee: []
created_date: '2026-08-30 15:28'
updated_date: '2026-08-30 15:51'
labels:
  - wb-docs
  - wb-backend
  - stammdaten
  - klassenbildung
milestone: m-5
dependencies: []
references:
  - api/stammdaten-api.md
  - api/klassenbildung-api.md
  - soll-prozesse/15-klassenbildung.md
priority: medium
ordinal: 149000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Block 15 gibt der Klassenlehrkraft zwei Einsichten, 'beide nur für die Kinder ihrer Klasse': den vollen Gesundheitssatz (gebaut, gesundheit-api.md) und das Austrittsdatum. Die zweite fehlt. GET /children/{child_id} gibt einer Lehrkraft nur Name, Klasse und Alltagsangaben, GET /children/{child_id}/departure nennt sie nicht, und der Roster zeigt nur eingeschriebene Kinder — die Klassenlehrkraft sieht heute, dass ein Kind verschwunden ist, und nicht, wann es geht. Ort ist GET /children/{child_id} mit demselben Ownership-Check wie die Gesundheitseinsicht: classes.class_teacher_id gibt children.exit_date frei, jede andere Lehrkraft sieht es nicht. Erst api/stammdaten-api.md ergänzen, dann in wb-backend bauen.

Die Doku-Hälfte steht: api/stammdaten-api.md nennt das Austrittsdatum an GET /children/{child_id}. Offen ist der Bau in wb-backend.
<!-- SECTION:DESCRIPTION:END -->
