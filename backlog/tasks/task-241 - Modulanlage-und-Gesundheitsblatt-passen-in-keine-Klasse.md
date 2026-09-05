---
id: TASK-241
title: Modulanlage und Gesundheitsblatt passen in keine Klasse
status: In Progress
assignee: []
created_date: '2026-09-04 12:36'
updated_date: '2026-09-05 00:35'
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
- [x] #1 Entschieden, ob eine vierte Klasse entsteht oder die drei Faelle anders getragen werden
- [x] #2 care_module_agreements traegt ihre Ausfertigung samt Pruefsumme, oder es steht begruendet, warum nicht
- [x] #3 Das Gesundheitsblatt hat eine Klasse und bekommt keine leeren Unterschriftszeilen
- [ ] #4 Die Erklaerung aus 19 traegt ihre eigene Frist ab Fahrtende, nicht die des Kindes
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Entschieden: **keine vierte Klasse.** Die drei Faelle passen in `signed`, sobald die Klasse sagt, was sie wirklich entscheidet — dass eine Urkunde je Vorgang samt Pruefsumme entsteht. **Ob sie Unterschriftszeilen traegt, sagt die Vorlage und nicht die Klasse:** Der Kreis der erwarteten Unterzeichner ist je Sorte verschieden und steht in `signatures`, und die Vorlage des Gesundheitsblatts hat schlicht keine Schleife darueber. Der Preis der Alternative steht im Kommentar an `kind_class` und ist unveraendert: eine vierte Klasse waere eine Aenderung an jedem Leser, nicht eine Zeile.

Modulanlage: `care_module_agreements` traegt jetzt `document_id` samt `document_checksum` und `fk_care_module_agreements_document`. `ck_care_module_agreements_document` bindet die Ausfertigung an die Freigabe — '09, Schritt 6: die Hortleitung gibt sie frei', und die Bestaetigungsmail geht 'nach jeder freigegebenen Anpassung'. Die Tabelle hatte ueberhaupt keinen Kopfkommentar; Herkunft und Loeschanker stehen jetzt da.

Ein Fund daraus, den die Selbstpruefung des Loesch-Laufs sofort meldete: Die Modulanlage haelt ihre Datei mit NO ACTION fest und stand in keiner Stufe. Sie steht jetzt auf dem Platz des Vertrags (3) und damit vor `documents` (9), wie der Nachtrag daneben; der Kopf von querschnitt-schema.sql nennt sie bei den Haltern.

Vier Gegenproben in anmeldung-schema-check.sql, gegen den benannten Constraint verifiziert: Ausfertigung vor der Freigabe, ohne Pruefsumme, im falschen Format, und der gute Fall.

Offen bleibt Kriterium 4: Die Erklaerung aus 19 braucht die Domaene der Veranstaltungen, und die ist nicht gebaut — TASK-169 haengt an TASK-168 (Schulleitung). Ihre eigene Frist ab Fahrtende entsteht mit ihrer Tabelle und nicht davor.
<!-- SECTION:NOTES:END -->
