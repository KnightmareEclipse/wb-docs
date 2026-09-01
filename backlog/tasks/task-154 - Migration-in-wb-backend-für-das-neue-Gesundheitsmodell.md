---
id: TASK-154
title: Migration in wb-backend für das neue Gesundheitsmodell
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
labels:
  - wb-backend
  - gesundheit
  - schema
dependencies: []
references:
  - schema/gesundheit-schema.sql
  - schema/gesundheit-schema-check.sql
  - wb-backend/app/alembic/versions/
  - wb-backend/schema-check.sh
ordinal: 166000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das Schema in schema/gesundheit-schema.sql ist umgebaut und geprüft; wb-backend führt das Schema (CLAUDE.md) und braucht die Migration, die es dorthin bringt.

Sechs Konfigurationstabellen kommen dazu (health_value_kinds, health_fields, health_type_fields, health_visibility_scopes, health_field_visibility, dazu allows_multiple an health_trait_types), zwei Datentabellen (child_health_answers, health_trait_values) und das Notfallprotokoll health_emergency_accesses. health_traits verliert seine sechzehn festen Spalten.

Produktiv läuft nichts, lokal steht Testbestand: Die Migration darf den alten Bestand fallen lassen statt ihn umzuräumen — ein Umzugspfad für Daten, die es nur lokal gibt, ist Arbeit ohne Abnehmer.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 alembic upgrade head läuft gegen eine leere und gegen die lokale Datenbank durch
- [ ] #2 Die downgrade-Richtung ist gebaut oder ausdrücklich als nicht unterstützt vermerkt
- [ ] #3 schema-check.sh gegen die migrierte Datenbank ist grün — das Prüfskript aus wb-docs ist der Maßstab
- [ ] #4 Der Bau ist vor dem migrate gelaufen (sonst nutzt compose run migrate die alten Quellen)
<!-- AC:END -->
