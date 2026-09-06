---
id: TASK-135
title: Altbestand des Beleg-Portals nach Weltenbaum übernehmen
status: To Do
assignee: []
created_date: '2026-08-30 15:19'
labels:
  - wb-backend
  - rechnungsfreigabe
  - import
milestone: m-5
dependencies:
  - TASK-074
references:
  - prozesse.md
  - soll-prozesse/12-rechnungsfreigabe.md
priority: low
ordinal: 147000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Belege liegen je Jahr in zwei SharePoint-Listen (Claims_Invoices_<Jahr>, Claims_Mileage_<Jahr>) samt ihren Anhängen. Aus 12 gilt zehn Jahre Aufbewahrung, und aus einem abgeschlossenen Beleg führt kein Weg zurück — es ist reine Datenübernahme, kein Prozess. Offen: wie weit zurück, ob die Anhänge mitwandern oder in SharePoint liegen bleiben, und was mit den Textprotokollen (Timeline, Notiz-Protokoll) geschieht, für die es in Weltenbaum change_log gibt. Sehr geringe Priorität: Der laufende Betrieb hängt nicht daran, die Altlisten bleiben lesbar.
<!-- SECTION:DESCRIPTION:END -->
