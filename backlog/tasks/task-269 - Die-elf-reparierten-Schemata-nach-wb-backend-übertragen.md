---
id: TASK-269
title: Die elf reparierten Schemata nach wb-backend übertragen
status: In Progress
assignee: []
created_date: '2026-09-05 15:34'
updated_date: '2026-09-05 16:42'
labels:
  - wb-backend
  - pruefzyklus
dependencies: []
ordinal: 282000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gemessen auf wertelisten-und-log-filter (d1becc7) nach dem Merge aus TASK-198: ./schema-check.sh gibt 1 zurück, elf der vierzehn Prüfskripte aus wb-docs/schema/ scheitern gegen die Datenbank des Backends. Es fehlen ganze Bestände — querschnitt elf Tabellen (mail_categories bis retention_holds), akademie acht, klassenorganisation fünf, anmeldung sechs, gesundheit drei, stammdaten zwei (alumni_kinds, alumni), putzdienst eine — dazu einzelne Constraints in ferien (sechs), mensa (drei) und rechnungsfreigabe (zwei); elternbonus meldet die Regel 'Anmeldung auf einen vollen Einsatz umgehängt' als nicht gebaut. Grün sind nur klassenbildung, m365 und selfservice, also genau die drei Schemata ohne Tabellen. Das ist der Rückstand des abgeschlossenen Schema-Prüfzyklus: wb-docs ist repariert, wb-backend nicht, und der Übertrag läuft über prompts/schema-uebertragen.md. Solange er offen ist, prüfen die acht Läufe aus TASK-202 Routen gegen ein Schema, das wb-docs längst anders beschreibt, und melden Funde, die in Wahrheit dieser Rückstand sind.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 ./schema-check.sh gibt 0 zurück, alle vierzehn Prüfskripte rc=0
- [x] #2 Die Änderungen stehen in der Ursprungsrevision, es entsteht keine Migrationskette
- [ ] #3 pytest bleibt grün, Nullpunkt vor dem Übertrag sind 805 Tests
<!-- AC:END -->
