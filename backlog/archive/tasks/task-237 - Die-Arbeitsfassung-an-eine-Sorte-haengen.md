---
id: TASK-237
title: Die Arbeitsfassung an eine Sorte haengen
status: To Do
assignee: []
created_date: '2026-09-04 12:35'
labels:
  - wb-backend
  - route
dependencies: []
references:
  - dokumente.md
ordinal: 250000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Sorte traegt die Graph-Kennung ihrer Arbeitsfassung (`working_library_id` + `working_item_id`, TASK-225), aber kein Griff setzt sie: Wie eine Word-Datei aus SharePoint an eine Sorte kommt, steht in keinem Ticket und in keiner Route. TASK-228 setzt sie als gegeben voraus.

Der Weg ist der Link, den die Geschaeftsfuehrung im Browser kopiert: `GET /shares/{u!base64url(link)}/driveItem` liefert das Element samt Kennung, alternativ `GET /drives/{id}/root:/{pfad}`. Gespeichert wird nur die Kennung — "der Anzeigepfad wird bei Bedarf ueber Graph aufgeloest und nicht gespeichert" (`grenzkarte.md`, Q2).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ein eingeworfener SharePoint-Link wird zur Graph-Kennung aufgeloest und an der Sorte gespeichert
- [ ] #2 Gespeichert wird nie ein Pfad, auch nicht daneben
- [ ] #3 Eine Datei, die keine .docx ist oder nicht erreichbar, wird mit benanntem Fehler abgewiesen
<!-- AC:END -->
