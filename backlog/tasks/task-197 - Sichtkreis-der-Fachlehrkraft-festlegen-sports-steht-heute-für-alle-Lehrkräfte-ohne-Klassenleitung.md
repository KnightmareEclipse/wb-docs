---
id: TASK-197
title: >-
  Sichtkreis der Fachlehrkraft festlegen: sports steht heute für alle Lehrkräfte
  ohne Klassenleitung
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
labels:
  - entscheidung
  - gesundheit
  - dsgvo
dependencies:
  - TASK-152
references:
  - api/gesundheit-api.md
ordinal: 210000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Annahme aus TASK-153/156 (Nachtlauf 02.09.2026): Jede Rolle mit teacher, die für ein Kind nicht Klassenlehrkraft ist, liest den Sichtkreis sports — Handlungshinweise („Beachten") und Erlaubnisse aller Kategorien, die Bezeichnung nur beim Notfallmedikament, keine Diagnosenamen, kein Attest. Grund: Die einzige Fachlehrkraft, die ein Block nennt, ist die des Sportunterrichts, und bis die zweite Achse steht (Wahlmodul, AG, Begleitung einer Veranstaltung), ist jede Lehrkraft ohne Klassenleitung für jedes Kind Fachlehrkraft. Block 08 Z. 95 sagt dagegen noch „Lehrkräfte und Hort sehen … Unverträglichkeit, Allergie, Notfallmedikation samt Erlaubnis, Zeckenentfernung" mit Bezeichnung. Entweder bestätigt die Schule den engeren Schnitt und TASK-152 schreibt die Blöcke so, oder es kommt ein siebter Sichtkreis teaching mit der Alltagsliste — eine Seed-Zeile je Paar, keine Migration. Ebenso zu bestätigen: care (Hort) sieht zusätzlich das „Beachten" jeder Kategorie, nicht nur der vier Alltagskategorien.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, welche Felder die Fachlehrkraft ohne Klassenleitung sieht, mit der Geschäftsführung
- [ ] #2 Seed (value_list_seed, Abschnitt Gesundheit) und api/gesundheit-api.md sagen dasselbe wie die Blöcke nach TASK-152
<!-- AC:END -->
