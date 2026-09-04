---
id: TASK-241
title: Modulanlage und Gesundheitsblatt passen in keine Klasse
status: To Do
assignee: []
created_date: '2026-09-04 12:36'
labels:
  - schema
  - wb-docs
dependencies: []
references:
  - dokumente.md
  - soll-prozesse/09-hortvertrag.md
ordinal: 254000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Drei Sorten, die es real gibt, passen nicht in `signed`/`agreed`/`applies`:

- **Modulanlage** (09): unterschrieben, nach jeder Anpassung neu ausgefertigt, bleibt in der Akte — "damit hat jeder Vertragspartner seine Ausfertigung, wie der Vertrag es verlangt". `care_module_agreements` traegt aber weder `document_id` noch Pruefsumme.
- **Gesundheitsblatt** (`grenzkarte.md`, TASK-226): erzeugte Datei ohne eigene Unterschrift — getragen wird sie von den Unterschriften unter dem Vertrag (08). Als `signed` bekaeme sie Unterschriftszeilen, die niemand fuellt.
- **Erklaerung zur Klassenfahrt** (19): unterschrieben von allen Sorgeberechtigten und dem Kind, abgelegt in der Akte — aber ihre Rahmenbedingungen schreibt die Lehrkraft je Fahrt in eigenen Worten, und damit kaeme ein Satz aus den Daten statt aus der Vorlage. Dazu eine eigene Frist ab Fahrtende (vier Wochen bzw. drei Jahre), nicht ab dem Austritt.

Zu entscheiden ist, ob eine vierte Klasse noetig ist oder ob die drei Faelle in die bestehenden passen. Der Kommentar an `kind_class` warnt: "eine vierte Klasse waere eine Aenderung an jedem Leser, nicht eine Zeile".
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob eine vierte Klasse entsteht oder die drei Faelle anders getragen werden
- [ ] #2 care_module_agreements traegt ihre Ausfertigung samt Pruefsumme, oder es steht begruendet, warum nicht
- [ ] #3 Das Gesundheitsblatt hat eine Klasse und bekommt keine leeren Unterschriftszeilen
- [ ] #4 Die Erklaerung aus 19 traegt ihre eigene Frist ab Fahrtende, nicht die des Kindes
<!-- AC:END -->
