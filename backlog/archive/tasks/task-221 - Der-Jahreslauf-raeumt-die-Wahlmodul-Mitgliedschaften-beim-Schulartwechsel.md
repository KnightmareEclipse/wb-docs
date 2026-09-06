---
id: TASK-221
title: Der Jahreslauf räumt die Wahlmodul-Mitgliedschaften beim Schulartwechsel
status: To Do
assignee: []
created_date: '2026-09-03 22:10'
updated_date: '2026-09-03 22:10'
labels:
  - wb-backend
  - klassenorganisation
milestone: m-5
dependencies:
  - TASK-161
references:
  - schema/klassenorganisation-schema.sql
  - soll-prozesse/04-schuljahreswechsel.md
ordinal: 234000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`child_group_memberships` führt die Schulart mit und ist über einen zusammengesetzten Fremdschlüssel an `children` gebunden — damit kann kein Grundschulkind in einer Realschulgruppe stehen. Die Kehrseite: Wechselt ein Kind die Schulart, scheitert die Änderung an `children`, solange eine Mitgliedschaft steht.

Der reale Fall ist der Viertklässler, der in die eigene Realschule wechselt: „bei dem ändern sich nur Schulart und Stufe" (04), und der Lauf am 1. August leert dabei bereits die Klassenzuordnung. Die Mitgliedschaften müssen im selben Zug fallen — sie gehören zur alten Schulart, und die neue Gruppe wählt das Kind ohnehin neu.

**Heute betrifft das kein Kind**, weil allein die Realschule Wahlmodule führt und ein Grundschulkind deshalb keine Mitgliedschaft hat. Der Lauf bricht also nicht — er bricht in dem Moment, in dem die Grundschule ihre erste Gruppe bekommt, und dann mitten im Jahreswechsel und ohne dass jemand den Zusammenhang sieht.

Kein Schema-Eingriff: Der Fremdschlüssel ist richtig so, und der Kommentar an der Tabelle nennt den Fall bereits.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Jahreslauf löscht die Wahlmodul-Mitgliedschaften eines Kindes, dessen Schulart sich ändert — im selben Schritt, der die Klassenzuordnung leert
- [ ] #2 Ein Test zeigt den Wechsel eines Kindes mit Mitgliedschaft; ohne den Schritt läuft er rot
<!-- AC:END -->
