---
id: TASK-173
title: Vier Angaben aus dem Fahrtformular in den Gesundheitsbestand aufnehmen
status: To Do
assignee: []
created_date: '2026-09-01 18:45'
labels:
  - gesundheit
  - veranstaltungen
  - wb-backend
dependencies:
  - TASK-169
references:
  - soll-prozesse/19-ausfluege-und-fahrten.md
  - schema/gesundheit-schema.sql
ordinal: 185000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Anmeldebogen der Klassenfahrt fragt vier Dinge, die der Bestand nicht kennt: Tetanus- und FSME-Impfschutz je **mit Datum**, Schwimmfähigkeit samt Abzeichen und ob eine private Haftpflicht besteht. Sie bleiben am Kind und werden bei der nächsten Fahrt nur bestätigt.

Das Impfdatum ist der Grund, warum das nicht bloß eine Zeile ist: Ein Datum im Freitext ist nicht auswertbar, also braucht es die Wertart "date" — die gibt es seit dem Umbau, aber die Felder selbst fehlen.

Nicht dabei: die Versicherung, das Kind sei frei von ansteckenden Krankheiten und Ungeziefer. Sie gilt für genau diese Fahrt und wird nicht als Bestand geführt — sie gehört zur Teilnahme.

Ebenfalls fahrtgebunden und nicht hierher: Badeerlaubnis und die Erlaubnis für besondere Aktivitäten.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die vier Felder stehen als health_fields mit ihren Wertarten
- [ ] #2 Sie sind den richtigen Kategorien zugeordnet und in Sichtkreisen sichtbar gemacht
- [ ] #3 Die Momentaufnahmen der Fahrt stehen NICHT im Bestand
<!-- AC:END -->
