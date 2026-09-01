---
id: TASK-153
title: api/gesundheit-api.md nach dem Schema-Umbau neu planen
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
labels:
  - wb-docs
  - api-plan
  - gesundheit
dependencies:
  - TASK-152
references:
  - api/gesundheit-api.md
  - api/ferien-api.md
  - api/mensa-api.md
  - prompts/api-planen.md
  - schema/gesundheit-schema.sql
ordinal: 165000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Datei plant sieben Routen gegen das alte Merkmalsmodell: drei konzentrische Sichten, drei enge Rollen, eine View auf is_everyday_relevant. Nichts davon existiert noch.

Neu zu entscheiden sind vor allem zwei Dinge: welche Rolle welchen Sichtkreis bekommt (health_visibility_scopes), und ob die Sicht künftig über RLS statt über eine View je Ausschnitt läuft — bei beliebig vielen Sichtkreisen über wechselnde Kindermengen ist jede weitere View eine Migration.

Ein Durchgang nach prompts/api-planen.md, nicht nebenbei: Die Gegenprobe Ablaufzeilen ↔ Routen gehört dazu. Mitzuziehen sind die zwei Stellen, die diese Datei heute korrigiert — ferien-api.md und mensa-api.md nennen backend_health bzw. kitchen_health_traits.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Das Zugriffsmodell nennt Sichtkreise statt der drei Stufen und sagt je Rolle, welchen sie bekommt
- [ ] #2 Die Routen für Merkmal und Wert stehen, samt der Frage, ob ein Wert einzeln oder der Fragensatz am Stück geschrieben wird
- [ ] #3 Die Notfalleinsicht hat eine eigene Route, die ihre Protokollzeile schreibt
- [ ] #4 Die Gegenprobe Ablaufzeilen ↔ Routen ist gerechnet und ohne Abweichung
- [ ] #5 ferien-api.md und mensa-api.md sind mitgezogen
<!-- AC:END -->
