---
id: TASK-266
title: payment_mode wird eine Werteliste statt vier CHECKs
status: To Do
assignee: []
created_date: '2026-09-05 00:18'
labels:
  - wb-docs
  - wb-backend
  - schema
  - werteliste
dependencies:
  - TASK-264
references:
  - schema/querschnitt-schema.sql
  - schema/akademie-schema.sql
  - schema/ferien-schema.sql
ordinal: 279000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mit TASK-264 steht derselbe Kategoriewert an vier Tabellen als aufgezaehlter CHECK: academy_registrations, holiday_bookings, cleaning_buyouts und cleaning_slot_buyouts. Ein fuenfter Wert kostet damit vier Migrationen, und die vier Aufzaehlungen laufen beim ersten Fix auseinander. Dieselbe Umstellung wie TASK-134 sie fuer den Erstattungsweg der Rechnungsfreigabe gemacht hat: Tabelle payment_modes (code, name, is_active) im Querschnitt, vier Fremdschluessel darauf, die vier CHECKs fallen.

Bewusst nicht in TASK-264 mitgenommen: Die Umstellung fasst zwei Domaenen an, die heute gruen sind, und faerbt rund vierzig INSERT-Zeilen in ferien- und akademie-schema-check.sql um — das ist ein eigener Lauf und keine Beifracht.

Zwei Stellen brauchen dabei Sorgfalt: ck_holiday_bookings_coverage und ck_academy_registrations_coverage vergleichen den Wert mit dem Kostenuebernahme-Code und muessen das Merkmal an der Zeile mitgefuehrt bekommen, gehalten von zusammengesetzten Fremdschluesseln — dieselbe Bauform wie in TASK-134.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 payment_modes steht im Querschnitt, die vier Tabellen zeigen darauf, die vier CHECKs sind weg
- [ ] #2 Die beiden Kostenuebernahme-CHECKs tragen ihr Merkmal weiter und weisen den Fall in der Gegenprobe weiter ab
- [ ] #3 Alle Pruefskripte laufen gruen, die Kopfkommentare tragen den neuen Sollstand
<!-- AC:END -->
