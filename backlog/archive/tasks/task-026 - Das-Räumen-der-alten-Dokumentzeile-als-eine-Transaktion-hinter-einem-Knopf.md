---
id: TASK-026
title: Das Räumen der alten Dokumentzeile als eine Transaktion hinter einem Knopf
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:11'
labels:
  - wb-backend
  - anmeldung
milestone: m-4
dependencies: []
references:
  - schema/anmeldung-schema.sql
ordinal: 26000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zustimmung → Signatur → Dokument → Datei in SharePoint hängen mit ON DELETE RESTRICT aneinander; wer beim Dokument anfängt, bricht mit einer Fremdschlüssel-Verletzung ab. Sonst führt das Sekretariat den ersten Schritt aus, läuft beim zweiten in eine Fehlermeldung und lässt einen halb geräumten Bestand stehen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Transaktion, ein Knopf — kein Klickpfad
- [ ] #2 Greift nur beim geänderten Vertragstext, nicht beim Tippfehler-Fall
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Geprüft, nicht gebaut: Die Auslösebedingung ('greift nur beim geänderten Vertragstext') steht in keinem Block. 08 nennt die Textänderung für alle als den Ausweg aus dem individuell geänderten Vertrag, sagt aber nichts darüber, dass ein bereits freigegebener Vertrag danach neu unterschrieben wird — und die Fassung friert ausdrücklich mit der Zusage ein. Die Reihenfolge, die das Ticket beschreibt (Zustimmung, Signatur, Dokument, Datei in SharePoint), steht als Reihenfolge des Lösch-Laufs im Kopf von schema/querschnitt-schema.sql, also in Block 17 — der ist TASK-007 und hängt an den Aufbewahrungsfristen. Vor dem Bau zu klären, welchem Block der Knopf gehört: dem Schulvertragsupdate (TASK-126), dem Lösch-Lauf (TASK-007) oder 08.
<!-- SECTION:NOTES:END -->
