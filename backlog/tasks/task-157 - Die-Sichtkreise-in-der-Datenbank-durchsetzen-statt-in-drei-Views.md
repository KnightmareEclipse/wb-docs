---
id: TASK-157
title: Die Sichtkreise in der Datenbank durchsetzen statt in drei Views
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
labels:
  - wb-backend
  - gesundheit
  - dsgvo
dependencies:
  - TASK-153
  - TASK-155
references:
  - wb-backend/tests/test_privileges.py
  - api/gesundheit-api.md
  - schema/gesundheit-schema.sql
ordinal: 169000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Heute tragen drei Rollen und zwei Views den Zuschnitt: backend_health, backend_health_everyday auf everyday_health_traits, backend_kitchen auf kitchen_health_traits. Das trug drei ineinanderliegende Stufen; bei überschneidenden Sichtkreisen wäre jeder weitere Zuschnitt eine weitere View und damit eine Migration.

Stattdessen eine Regel über Daten: eine Policy, die health_trait_values gegen health_field_visibility und den Sichtkreis der aufrufenden Rolle filtert. Ein neuer Sichtkreis ist dann eine Zeile, kein Schema-Eingriff.

Die zweite Achse — von welchen Kindern jemand liest — hängt an den Unterrichtsgruppen und ist nicht Teil dieses Tickets; bis dahin bleibt es bei der heutigen Zuständigkeit über Klasse, Betreuungsvertrag und Familie.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Policy statt einer View je Ausschnitt; everyday_health_traits und kitchen_health_traits sind fort
- [ ] #2 Ein neuer Sichtkreis ist nachweislich eine Datenzeile: der Nachweis steht als Test, nicht als Behauptung
- [ ] #3 Ein Test zeigt, dass Sport den Hinweis zur chronischen Erkrankung sieht und ihre Bezeichnung nicht
- [ ] #4 Die Küche sieht weiterhin ausschließlich Unverträglichkeit und Allergie
- [ ] #5 test_privileges.py läuft mit den geänderten Rollen durch
<!-- AC:END -->
