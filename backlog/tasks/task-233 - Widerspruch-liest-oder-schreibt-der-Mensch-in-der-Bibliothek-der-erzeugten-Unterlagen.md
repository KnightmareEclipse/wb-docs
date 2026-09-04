---
id: TASK-233
title: >-
  Widerspruch: liest oder schreibt der Mensch in der Bibliothek der erzeugten
  Unterlagen
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
labels:
  - wb-docs
milestone: m-5
dependencies: []
ordinal: 245000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zwei Stellen stehen im Präsens nebeneinander und sagen Verschiedenes:

- **`oberflaechen.md`** (Abschnitt SharePoint-Dateispeicher): „in der ersten legt die App die erzeugten Unterlagen ab und **Menschen lesen nur**". Dieselbe Aussage trägt die Abschlussnotiz von TASK-111 und dessen Abnahmekriterium #2.
- **`schema/querschnitt-schema.sql`** am Kommentar zu `sharepoint_libraries`: „Entschieden nach der Abnahme … Der Preis ist benannt — die erzeugten Unterlagen sind für Sekretariat und Geschäftsführung **nicht mehr nur lesbar**. Dass ein Vertrag nachträglich verändert wurde, zeigt danach allein die Prüfsumme; verhindern kann sie es nicht."

Welche gilt, entscheidet mehr als eine Formulierung: An ihr hängt, ob die eingefrorene Vorlagendatei in SharePoint liegen könnte (TASK-222 legt sie aus genau diesem Grund nach Postgres) und wie belastbar die Zusage „niemand ändert einen Vertrag still" ist.

Aufgefallen beim Durchgehen der Dokumenterzeugung am 04.09.2026.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 oberflaechen.md und querschnitt-schema.sql sagen dasselbe ueber den Zugriff auf die Bibliothek
- [ ] #2 Die Abschlussnotiz von TASK-111 stimmt mit dem Ergebnis ueberein oder ist als ueberholt gekennzeichnet
<!-- AC:END -->
