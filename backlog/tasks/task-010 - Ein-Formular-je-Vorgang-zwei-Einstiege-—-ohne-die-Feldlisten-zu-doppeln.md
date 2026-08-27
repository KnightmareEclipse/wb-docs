---
id: TASK-010
title: 'Ein Formular je Vorgang, zwei Einstiege — ohne die Feldlisten zu doppeln'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - frontend
  - anmeldung
milestone: m-3
dependencies: []
references:
  - zugang.md
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Identisch sind Programm bzw. Zielklassenstufe, Betreuungsmodul, Zustimmungen und Zahlung; unterschiedlich ist allein der Identitätsblock. Gedoppelt werden dürfen die Feldlisten nicht, sonst läuft eine der beiden Fassungen still hinterher.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Bekannte Adresse: Kind aus der Auswahlliste, Erziehungsberechtigte und Anschrift vorbelegt
- [ ] #2 Unbekannte Adresse: dieselben Felder leer, die Zeilen entstehen daraus
- [ ] #3 Welcher Einstieg gilt, entscheidet der OTP-Fluss — nicht der Absender
<!-- AC:END -->
