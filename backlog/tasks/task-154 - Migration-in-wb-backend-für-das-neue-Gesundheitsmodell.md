---
id: TASK-154
title: Das neue Gesundheitsmodell in die Ursprungsrevision einarbeiten
status: Done
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-02 00:40'
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
Das Schema in schema/gesundheit-schema.sql ist umgebaut und geprüft; wb-backend führt das Schema (CLAUDE.md) und muss nachziehen.

**Keine neue Alembic-Revision.** Solange nichts produktiv läuft, wird die Ursprungsrevision überschrieben statt eine Kette gebaut: Die Datenbank wird ohnehin platt gemacht, und eine Migrationskette, die niemand je durchläuft, ist Ballast, den jeder spätere Leser für Geschichte hält. Der Stand nach dem Bau ist eine Revision, die das fertige Schema anlegt.

Sechs Konfigurationstabellen kommen dazu (health_value_kinds, health_fields, health_type_fields, health_visibility_scopes, health_field_visibility, dazu allows_multiple an health_trait_types), zwei Datentabellen (child_health_answers, health_trait_values) und das Notfallprotokoll health_emergency_accesses. health_traits verliert seine sechzehn festen Spalten.

Der lokale Testbestand fällt dabei weg — ein Umzugspfad für Daten, die es nur lokal gibt, ist Arbeit ohne Abnehmer.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, "Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md ("Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 alembic upgrade head läuft gegen eine leere und gegen die lokale Datenbank durch
- [x] #2 Die downgrade-Richtung ist gebaut oder ausdrücklich als nicht unterstützt vermerkt
- [x] #3 schema-check.sh gegen die migrierte Datenbank ist grün — das Prüfskript aus wb-docs ist der Maßstab
- [x] #4 Der Bau ist vor dem migrate gelaufen (sonst nutzt compose run migrate die alten Quellen)
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Ursprungsrevision 08fc49476134 überschrieben (Branch gesundheit-umbau in wb-backend). Downgrade gebaut; alembic upgrade head gegen die frisch aufgesetzte Datenbank rc=0, schema-check.sh: gesundheit rc=0 (elternbonus rc=3 ist der ausstehende Umbau aus TASK-165). Sechs Sichtkreise als Sichten health_values_<code> mit je eigener DB-Rolle; kitchen_health_traits und everyday_health_traits bleiben als abgeleitete Sichten, bis TASK-157 Mensa und Ferien umzieht.
<!-- SECTION:NOTES:END -->
