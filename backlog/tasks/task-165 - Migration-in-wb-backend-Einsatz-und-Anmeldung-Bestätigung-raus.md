---
id: TASK-165
title: 'Migration in wb-backend: Einsatz und Anmeldung, Bestätigung raus'
status: To Do
assignee: []
created_date: '2026-09-01 17:46'
updated_date: '2026-09-01 18:09'
labels:
  - wb-backend
  - elternbonus
  - schema
dependencies:
  - TASK-164
references:
  - schema/elternbonus-schema.sql
  - schema/elternbonus-schema-check.sql
  - wb-backend/app/models/elternbonus.py
ordinal: 177000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Drei Tabellen kommen dazu — parent_work_sessions, parent_work_session_audiences und parent_work_signups —, parent_work_entries bekommt den freiwilligen Bezug auf den Einsatz und verliert vier Spalten, drei Constraints und den Index der Bestätigungsaufgabe.

Dazu der **erste Trigger des Projekts**: trg_parent_work_signups_capacity hält die Platzzahl. Er sperrt die Einsatzzeile mit FOR UPDATE, bevor er zählt — ohne die Sperre sehen zwei gleichzeitige Anmeldungen denselben freien Platz, und bei einer Fahrt mit vier Plätzen ist der fünfte einer zu viel. Die Migration muss Funktion und Trigger mitbringen; ein Modell allein trägt sie nicht.

Produktiv läuft nichts; die Migration darf den lokalen Testbestand fallen lassen, statt einen Umzugspfad für Daten zu bauen, die es nur hier gibt.

Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 alembic upgrade head läuft gegen eine leere und gegen die lokale Datenbank durch
- [ ] #2 schema-check.sh ist grün — schema/elternbonus-schema-check.sql ist der Maßstab
- [ ] #3 Die Modelle bilden beide neuen Tabellen ab und tragen keine Bestätigungsspalte mehr
- [ ] #4 Der Bau ist vor dem migrate gelaufen
<!-- AC:END -->
