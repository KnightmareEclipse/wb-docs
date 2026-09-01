---
id: TASK-156
title: Router gesundheit.py auf das neue Modell umbauen
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
labels:
  - wb-backend
  - gesundheit
  - route
dependencies:
  - TASK-153
  - TASK-155
references:
  - wb-backend/app/routers/gesundheit.py
  - api/gesundheit-api.md
ordinal: 168000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sieben Routen lesen und schreiben heute Merkmale mit festen Feldern; die Flag-Prüfung _validate_against_type fällt mit den vier Booleans weg.

Neu: Der Bestand wird je Kategorie beantwortet oder abgelehnt, Werte werden je Feld geschrieben, und die Antwort einer Leseroute enthält nur die Felder des Sichtkreises, den die aufrufende Rolle hat. Was die Route ausliefert, entscheidet nicht mehr eine Fallunterscheidung im Code, sondern die Zeilenfilterung der Datenbank.

Der Zuschnitt je Rolle steht im API-Plan und wird hier nicht neu erfunden.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 GET liefert je Rolle genau die Felder ihres Sichtkreises, ohne Filter im Anwendungscode
- [ ] #2 Die Antwort unterscheidet sichtbar „nicht beantwortet" von „nichts vorhanden" und von „nicht gefragt"
- [ ] #3 Schreibrouten für Antwort je Kategorie und Wert je Feld stehen
- [ ] #4 Die Notfallroute liefert den Notfallausschnitt und schreibt dabei ihre Protokollzeile
- [ ] #5 _validate_against_type und die vier Flags sind restlos entfernt
<!-- AC:END -->
