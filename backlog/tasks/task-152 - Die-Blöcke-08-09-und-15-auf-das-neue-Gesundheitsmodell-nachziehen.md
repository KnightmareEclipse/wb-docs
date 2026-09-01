---
id: TASK-152
title: 'Die Blöcke 08, 09 und 15 auf das neue Gesundheitsmodell nachziehen'
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
labels:
  - wb-docs
  - gesundheit
  - dsgvo
dependencies: []
references:
  - soll-prozesse/08-schulvertrag.md
  - soll-prozesse/09-hortvertrag.md
  - soll-prozesse/15-klassenbildung.md
  - schema/gesundheit-schema.sql
  - grenzkarte.md
ordinal: 164000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Schema-Umbau der Domäne 9 ist gefahren, die Blöcke behaupten noch den alten Ablauf: Pflicht auf alle Kategorien, drei ineinanderliegende Sichtstufen, kein Notfallweg. Der Block schlägt alles (CLAUDE.md-Rangfolge) — solange er das Alte sagt, ist das Schema unbegründet.

Drei Änderungen, je Block dieselben: die Angaben sind je Kategorie freiwillig und in der Tiefe wählbar; sichtbar wird je Angabe an einen Sichtkreis statt je Stufe; und die Notfalleinsicht steht jedem Mitarbeitenden für jedes Kind offen, protokolliert statt genehmigt. In 09 kommt dazu, dass die Eltern die Weitergabe an den Hort ausdrücklich freigeben und verweigern dürfen.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 08 Z2 beschreibt die Freiwilligkeit je Kategorie und den Unterschied zwischen „nichts vorhanden" und „nicht beantwortet"
- [ ] #2 09 Z3 beschreibt die Freigabe an den Hort samt Ablehnungsrecht
- [ ] #3 15 beschreibt die Einsicht der Klassenlehrkraft als Sichtkreis, nicht als oberste Stufe
- [ ] #4 Keine der drei Dateien nennt noch „Alltagsangaben" als Stufe oder die drei konzentrischen Sichten
- [ ] #5 Die Notfalleinsicht steht in genau einem Block und wird von den anderen nur genannt
<!-- AC:END -->
