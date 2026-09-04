---
id: TASK-182
title: api/querschnitt-api.md auf Hortakte und Aktenkategorien nachziehen
status: To Do
assignee: []
created_date: '2026-09-01 19:25'
updated_date: '2026-09-04 13:14'
labels:
  - api
  - querschnitt
  - sharepoint
  - wb-docs
dependencies:
  - TASK-181
references:
  - api/querschnitt-api.md
  - api/stammdaten-api.md
  - grenzkarte.md
ordinal: 194000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Folgt TASK-181. Drei Stellen ändern sich:

Der Aktenordner entsteht nicht mehr einmal je Kind, sondern je Kind, Bibliothek und Kategorie — die Route, die ihn anlegt, legt die Unterordner mit an.

Die Auslieferungsregel bleibt 'wer die Zeile daneben sehen darf', aber der Satz 'die Hortleitung … ohne Zugriff auf die Bibliothek' stimmt nicht mehr: Auf ihre eigene Bibliothek hat sie Zugriff, auf die Schülerakte weiterhin nicht.

PUT /children/{child_id}/class zieht nur den Ordner der Schülerakte um; die Hortakte kennt keine Kohorte und darf vom Klassenwechsel nicht berührt werden.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ordner-Anlage und Lösch-Lauf arbeiten je Kind, Bibliothek und Kategorie
- [ ] #2 Der Klassenumzug rührt die Hortakte nicht an — als Prüfung, nicht als Satz
- [ ] #3 Die Zugriffsregel für die Hortleitung ist richtiggestellt
- [ ] #4 Eine Route legt die Hortakte eines Kindes an — nur der Hort ruft sie, und sie ist der einzige Weg, auf dem der Ordner entsteht
- [ ] #5 Die zwei Listen des Loesch-Laufs stehen als Routen: angehaltene Loeschungen und Ordner ohne Anker — beide sagt Block 17 zu, die Datei kannte keine
<!-- AC:END -->
