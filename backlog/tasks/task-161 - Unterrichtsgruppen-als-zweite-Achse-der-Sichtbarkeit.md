---
id: TASK-161
title: Unterrichtsgruppen als zweite Achse der Sichtbarkeit
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
labels:
  - schema
  - wb-docs
  - gesundheit
  - wartet
dependencies: []
references:
  - schema/klassenorganisation-schema.sql
  - schema/stammdaten-schema.sql
  - grenzkarte.md
  - pruefberichte/gespraech-geschaeftsfuehrung.md
ordinal: 173000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Sichtkreis sagt, welche Angaben jemand sehen darf. Er sagt nicht, von welchen Kindern — und die Sportlehrkraft unterrichtet nicht alle 500. Heute gibt es dafür nur children.class_id, also die Stammklasse.

Gebraucht werden vier Quellen derselben Form — eine Menge Kinder, eine Menge Lehrkräfte, ein Zeitraum: Stammklasse, Wahlmodul, AG bzw. Akademie-Angebot und die Begleitung einer Veranstaltung. Als eine Zuordnung statt vier Sonderfällen, sonst schreibt jede Quelle ihre eigene Policy.

Offen und Teil dieses Tickets: Woher die Modulzuordnung kommt. Sie steht in ASV, Untis ist auf „out of scope" gesetzt — entweder pflegt sie jemand in Weltenbaum oder sie kommt als Import. Ohne sie sieht die Fachlehrkraft im Alltag nichts und die Notfalleinsicht wird vom Netz zum Normalweg.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Zuordnung Person ↔ Kindermenge ↔ Art der Beziehung mit Zeitraum, die alle vier Quellen trägt
- [ ] #2 children.class_id ist als Spezialfall darin aufgegangen oder ausdrücklich daneben begründet
- [ ] #3 Die Herkunft der Modulzuordnung ist entschieden und benannt
- [ ] #4 Das Prüfskript weist eine Zuständigkeit ohne Zeitraum ab
<!-- AC:END -->
