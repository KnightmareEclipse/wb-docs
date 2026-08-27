---
id: TASK-026
title: Das Räumen der alten Dokumentzeile als eine Transaktion hinter einem Knopf
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
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
