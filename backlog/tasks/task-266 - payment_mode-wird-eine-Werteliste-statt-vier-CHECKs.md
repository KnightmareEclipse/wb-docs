---
id: TASK-266
title: payment_mode wird eine Werteliste statt vier CHECKs
status: Done
assignee: []
created_date: '2026-09-05 00:18'
updated_date: '2026-09-05 01:20'
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
- [x] #1 payment_modes steht im Querschnitt, die vier Tabellen zeigen darauf, die vier CHECKs sind weg
- [x] #2 Die beiden Kostenuebernahme-CHECKs tragen ihr Merkmal weiter und weisen den Fall in der Gegenprobe weiter ab
- [x] #3 Alle Pruefskripte laufen gruen, die Kopfkommentare tragen den neuen Sollstand
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
payment_modes steht im Querschnitt, neben payments: code, name, is_active und die beiden Merkmale, die CHECKs lesen. Die vier aufgezaehlten CHECKs sind weg, an ihrer Stelle stehen vier Fremdschluessel.

**Zwei Ziele statt einem** — das ist die Abweichung von TASK-134: uq_payment_modes_traits (code, is_invoiced, is_direct_debit) traegt die Akademie, die beide Merkmale liest; uq_payment_modes_invoiced (code, is_invoiced) traegt Ferien und die beiden Putzdienst-Freikaeufe. Ein Fremdschluessel verlangt seine Zielspalten genau so, wie er sie fuehrt, und drei Tabellen ein Merkmal mitfuehren zu lassen, das kein CHECK von ihnen liest, waere eine Spalte ohne Leser.

Die drei CHECKs, die den Wert vergleichen, lesen jetzt das Merkmal statt des Codes: ck_academy_registrations_coverage und ck_holiday_bookings_coverage als is_invoiced = (code_id IS NOT NULL), ck_academy_registrations_adult_payment als NOT is_direct_debit.

**Was die Aufzaehlung sonst mit weggenommen haette:** Der Putzdienst kennt keinen Kostenuebernahme-Code — das stand im CHECK und stuende nach dem Umbau nirgends. Es steht jetzt als ck_cleaning_buyouts_no_invoice und ck_cleaning_slot_buyouts_no_invoice, und die beiden vorhandenen Gegenproben ('Freikauf auf Rechnung, den es hier nicht gibt') fallen unveraendert darauf.

ck_payment_modes_exclusive haelt fest, dass es berechnet-und-eingezogen nicht gibt; die Gegenprobe steht in querschnitt-schema-check.sql, wo die Werteliste steht.

Nachgezogen: 43 INSERT- und 6 UPDATE-Stellen in den drei Pruefskripten, der Seed der Werteliste in jedem der drei, die Sollstaende in vier Kopfkommentaren (querschnitt 23 auf 24 Tabellen, dabei die stehengebliebene 20 in der NOTICE mitkorrigiert) und der Lesepfad von querschnitt-schema.sql. Alle 14 Schemata und alle 14 Pruefskripte rc=0; jede beruehrte Gegenprobe ist gegen ihren benannten Constraint verifiziert.

wb-backend zieht nach: TASK-268.
<!-- SECTION:NOTES:END -->
