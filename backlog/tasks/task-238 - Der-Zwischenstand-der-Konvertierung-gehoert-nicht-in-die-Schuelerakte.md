---
id: TASK-238
title: Der Zwischenstand der Konvertierung gehoert nicht in die Schuelerakte
status: To Do
assignee: []
created_date: '2026-09-04 12:35'
labels:
  - wb-backend
  - dsgvo
dependencies: []
references:
  - dokumente.md
  - folgenabschaetzung.md
ordinal: 251000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Graph konvertiert nur ein Element und keinen Rumpf: `build_contract_document` laedt die gefuellte `.docx` in die Schuelerakte, holt das PDF und entfernt sie wieder (`app/services/anmeldung.py`). Ein ueber Graph entferntes Element liegt danach im Papierkorb der Site und anschliessend in dem der Sammlung (`grenzkarte.md`, Q2) — ohne `documents`-Zeile und damit ausserhalb des Loesch-Laufs, der ueber Zeilen geht.

Mit der Ansicht vor der Unterschrift trifft das jede Ansicht der Eltern, nicht nur die Freigabe: ein vollstaendig gefuellter Vertragsentwurf je Aufruf. Beim Gesundheitsblatt sind das Art.-9-Daten. Steht als R10 in `folgenabschaetzung.md`.

Zwei Haelften: der Zwischenstand geht an einen Ort, den kein Bestand als Ablage fuehrt, und beide Papierkorbstufen gehoeren zum Entfernen — dieselbe Regel, die TASK-183 fuer den Loesch-Lauf traegt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Zwischenstand landet nicht in der Schuelerakte
- [ ] #2 Beide Papierkorbstufen werden geleert, nicht nur das Element entfernt
- [ ] #3 Gegenprobe: nach einer Ansicht steht in der Akte keine Datei ohne documents-Zeile
<!-- AC:END -->
