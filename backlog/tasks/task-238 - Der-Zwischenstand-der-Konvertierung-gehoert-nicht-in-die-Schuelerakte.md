---
id: TASK-238
title: Der Zwischenstand der Konvertierung gehoert nicht in die Schuelerakte
status: Done
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

**Gegenstandslos seit dem 04.09.2026 (TASK-242).** Die Konvertierung laeuft nicht mehr ueber Graph, sondern im Container: Der Konverter nimmt Bytes und gibt Bytes zurueck, es gibt keinen Upload und damit keinen Zwischenstand. Beide Haelften dieses Tickets loesen sich damit auf — nicht durch eine Abhilfe, sondern weil der Weg verschwunden ist, der sie erzeugt hat.

**Was zu tun bleibt, ist nicht dieses Ticket, sondern der Umstieg selbst** — und die einmalige Frage, ob im Papierkorb der Site noch Zwischenstaende aus der bisherigen Laufzeit liegen. Das ist ein Aufraeumschritt und keine Dauerpflicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Der Zwischenstand landet nicht in der Schuelerakte
- [x] #2 Beide Papierkorbstufen werden geleert, nicht nur das Element entfernt
- [x] #3 Gegenprobe: nach einer Ansicht steht in der Akte keine Datei ohne documents-Zeile
<!-- AC:END -->
