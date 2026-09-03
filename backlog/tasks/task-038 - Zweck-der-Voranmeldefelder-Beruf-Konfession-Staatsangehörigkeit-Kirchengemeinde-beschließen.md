---
id: TASK-038
title: >-
  Zweck der Voranmeldefelder Beruf, Konfession, Staatsangehörigkeit,
  Kirchengemeinde beschließen
status: In Progress
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-09-03 00:44'
labels:
  - wartet
  - schulleitung
  - dsgvo
milestone: m-1
dependencies: []
references:
  - fragen.md
priority: high
ordinal: 38000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Spalten stehen, weil ein DROP COLUMN billig ist und ein beim Vollimport nicht erhobener Wert nicht nacherhebbar. Konfession ist ein Art.-9-Datum, und ein Feld ohne beschlossenen Zweck mit echten Personendaten zu füllen, schließt rules.md Abschnitt 7 aus. Weiterhin vor dem Vollimport, nicht danach.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die drei genannten Zwecke belastbar bestätigt — sonst fällt das Feld vor dem Import raus
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Am 02.09.2026 datenschutzrechtlich beantwortet: kein Erlaubnistatbestand, die vier Felder können nur als freiwillige stehen bleiben, und die Freiwilligkeit muss beim Ausfüllen ersichtlich sein. Eingetragen in schema/stammdaten-schema.sql. Offen bleibt der fachliche Teil — welchen Zweck jedes Feld hat und ob es bleibt; das entscheidet die Schulleitung.
<!-- SECTION:NOTES:END -->
