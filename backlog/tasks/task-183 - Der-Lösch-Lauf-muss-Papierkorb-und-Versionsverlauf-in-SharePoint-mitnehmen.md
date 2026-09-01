---
id: TASK-183
title: Der Lösch-Lauf muss Papierkorb und Versionsverlauf in SharePoint mitnehmen
status: To Do
assignee: []
created_date: '2026-09-01 19:42'
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
<!-- AC:END -->
