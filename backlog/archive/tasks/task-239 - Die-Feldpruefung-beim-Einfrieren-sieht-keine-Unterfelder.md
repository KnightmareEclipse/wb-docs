---
id: TASK-239
title: Die Feldpruefung beim Einfrieren sieht keine Unterfelder
status: To Do
assignee: []
created_date: '2026-09-04 12:35'
labels:
  - wb-backend
  - dsgvo
dependencies: []
references:
  - dokumente.md
ordinal: 252000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gemessen am 04.09.2026: `jinja2.meta.find_undeclared_variables` liefert nur die obersten Namen. Fuer `{{ kind.nmae }} {{ gesundheit.hiv }}` kommen `kind` und `gesundheit` zurueck — die Unterfelder erscheinen nicht.

TASK-227 schneidet die Freigabe aber genau nach Namensraeumen (`kind`, `familie`, `vertrag`, `gesundheit`). Damit prueft der Torwaechter aus TASK-228 an Unterfeldern nichts: Ein Tippfehler wirft erst mit `StrictUndefined` im Request der Freigabe, und ein Merkmal, das eine Sorte nicht sehen darf, kommt durch, solange sein Namensraum freigegeben ist. Das Beispiel, mit dem TASK-227 wirbt — `{{ gesundheit.hiv }}` in einem Ferienbrief scheitert beim Hochladen — funktioniert so nicht.

Zwei Wege: die freigegebenen Namen flach schneiden, oder die Pruefung ueber den Syntaxbaum laufen lassen und Getattr-Knoten aufloesen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ein nicht freigegebenes Unterfeld weist die Fassung ab, nicht erst der Render
- [ ] #2 Ein Tippfehler in einem Unterfeld faellt beim Anlegen der Fassung auf
- [ ] #3 Gegenprobe mit genau dem Beispiel aus TASK-227: gesundheit.hiv in einer Sorte ohne diesen Sichtkreis
<!-- AC:END -->
