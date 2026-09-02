---
id: TASK-159
title: Die Tests der Gesundheitsdomäne nachziehen
status: Done
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-02 00:40'
labels:
  - wb-backend
  - gesundheit
  - test
dependencies:
  - TASK-156
  - TASK-157
references:
  - wb-backend/tests/test_gesundheit.py
  - wb-backend/tests/test_privileges.py
ordinal: 171000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
test_gesundheit.py prüft Routen, die es so nicht mehr gibt, test_privileges.py die Rollen und Views, die fallen.

Wichtiger als die Anpassung sind die drei Fälle, die es vorher nicht geben konnte und die den Umbau tragen: ein Sichtkreis, der einen Ausschnitt quer zu den alten Stufen liefert; die Unterscheidung der drei Zustände je Kategorie in der Antwort einer Leseroute; und die Notfalleinsicht, die ohne Zuständigkeit liest und dabei protokolliert.

Ein grüner Test belegt nichts, solange nicht gezeigt ist, dass er rot werden kann (CLAUDE.md): Jeder neue Fall wird einmal gegen die herausgenommene Sicherung gefahren.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 test_gesundheit.py und test_privileges.py laufen grün
- [x] #2 Je ein Test für die drei neuen Fälle, jeder einmal rot gesehen
- [x] #3 Ein Test hält fest, dass eine leere Feldliste nicht als „nichts vorhanden" ausgeliefert wird
- [x] #4 Kein Test prüft noch is_everyday_relevant, is_kitchen_relevant oder eine der vier Flags
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
tests/test_gesundheit.py neu (42 Tests), test_privileges.py unverändert grün. Die drei neuen Fälle je einmal rot gesehen: Sichtkreis auf die volle Sicht gelenkt (2 Tests rot), unasked als answered gemeldet (2 Tests rot), Protokollzeile weggelassen (1 Test rot). Gesamtlauf 790 passed, ruff und mypy grün.
<!-- SECTION:NOTES:END -->
