---
id: TASK-186
title: Die erzeugten Vertrags-PDFs barrierefrei machen
status: To Do
assignee: []
created_date: '2026-09-01 20:14'
updated_date: '2026-09-01 20:41'
labels:
  - wb-backend
  - anmeldung
  - frontend
milestone: m-2
dependencies: []
ordinal: 199000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das BFSG trifft nicht nur die Oberfläche: Die Geschäftsführung hat am 01.09.2026 bestätigt, dass es gilt (TASK-118), und damit fällt auch der Vertrag darunter, den das Portal erzeugt und den Eltern zum Lesen und Unterschreiben bekommen. Gebaut ist die Strecke schon (TASK-111): Word-Vorlage app/documents/contract-template.docx, gefüllt per docxtpl, Konvertierung über Graph.

Der Aufwand liegt in der Vorlage, nicht im Code — Graph übernimmt beim Export, was das .docx mitbringt: echte Überschriftenebenen statt fett formatierter Absätze, Dokumentsprache, Titel in den Dateieigenschaften, Alternativtext an Logo und Grafik, Tabellen mit Kopfzeile. Was die Vorlage nicht trägt, kann die Konvertierung nicht erfinden.

Gilt für jede Vorlage, die entsteht, nicht nur für die erste — Schulvertrag, Betreuungsvertrag, Essensbedingungen, Anlage zum Elternbonus, Erklärung zur Klassenfahrt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Word-Vorlage trägt Überschriftenebenen, Sprache, Titel und Alternativtexte
- [ ] #2 Ein erzeugtes PDF ist gegen einen Prüfer gelesen worden, nicht nur angesehen
- [ ] #3 Die Regel steht bei der Vorlage, damit die nächste sie mitbekommt
<!-- AC:END -->
