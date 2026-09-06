---
id: TASK-183
title: Der Lösch-Lauf muss Papierkorb und Versionsverlauf in SharePoint mitnehmen
status: To Do
assignee: []
created_date: '2026-09-01 19:42'
updated_date: '2026-09-03 22:26'
labels:
  - dsgvo
  - sharepoint
  - wb-docs
  - wb-backend
dependencies: []
references:
  - grenzkarte.md
  - soll-prozesse/09-hortvertrag.md
ordinal: 196000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aufgefallen beim Hortakte-Beschluss vom 01.09.2026, betrifft aber jede Datei im System.

Ein über Graph gelöschter Ordner landet im Papierkorb der Site und liegt dort standardmäßig 93 Tage weiter — danach noch einmal im Papierkorb der Sammlung. Ein gelöschter Aktenordner ist damit nicht gelöscht, und der Lösch-Lauf hielte seine Zusage nicht.

Dazu der Versionsverlauf: Bei einem fortgeschriebenen Dokument — die Betreuungsakte des Horts ist genau das — stehen frühere Fassungen im Element. Sie verschwinden mit ihm, sind aber bis dahin Teil dessen, was Eltern bei einer Auskunft sehen dürfen.

Die Grenzkarte führt 'Versionierung ist eingebaut' bisher nur als Vorteil (Q2); die Kehrseite steht nirgends.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Lösch-Lauf leert nach dem Löschen den Papierkorb für dieses Element — beide Stufen
- [ ] #2 In grenzkarte.md Q2 steht, dass Versionsverlauf und Papierkorb zum Löschen gehören
- [ ] #3 Entschieden, ob frühere Fassungen zur Auskunft gehören und wie sie herausgegeben werden
- [ ] #4 2,3
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
AC 2 und 3 sind zu: grenzkarte.md Q2 traegt jetzt einen eigenen Absatz — Versionsverlauf und Papierkorb gehoeren zum Loeschen, ein Loeschen ist erst vollstaendig, wenn beide Papierkorb-Stufen geleert sind. Block 17 (Dateien) und die Kommentare an documents/child_file_folders sagen dasselbe.

AC 3 entschieden am 04.09.2026, und zwar gegen einen Mechanismus: Weltenbaum sagt nur, **wo** es Dateien gibt. Herausholen und endgueltiges Zusammenstellen macht ein Mensch (Block 18, Schritt 2) — damit ist der Versionsverlauf keine Frage an das System, sondern eine Entscheidung dessen, der die Akte herausgibt.

AC 1 ist wb-backend (app/services/retention.py) und wartet mit TASK-194 auf den gruenen Pruefbericht zum Querschnitt-Schema.
<!-- SECTION:NOTES:END -->
