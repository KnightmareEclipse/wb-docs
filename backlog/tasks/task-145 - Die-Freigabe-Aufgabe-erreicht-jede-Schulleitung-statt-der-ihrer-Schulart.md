---
id: TASK-145
title: Die Freigabe-Aufgabe erreicht jede Schulleitung statt der ihrer Schulart
status: To Do
assignee: []
created_date: '2026-08-31 14:05'
labels:
  - wb-backend
  - anmeldung
  - querschnitt
milestone: m-5
dependencies: []
references:
  - api/anmeldung-api.md
  - soll-prozesse/08-schulvertrag.md
  - schema/querschnitt-schema.sql
ordinal: 157000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
POST /contracts/{contract_id}/submission legt die offene Aufgabe über raise_task() beim Ziel school_contract_release an. sync_targets trägt je Ziel eine Rolle und keine Schulart, sync_tasks trägt sie ebenso wenig — die Aufgabe erreicht damit jede Schulleitung, während Plan und Block 08 Z4 "bei der Schulleitung dieser Schulart" sagen. In der Wochenmail sieht die Grundschulleitung so die Namen der Realschulkinder, und umgekehrt; jede andere Route dieser Domäne hält "Schulleitung nur ihre eigene Schulart" ein.

Der Fund liegt zwischen Plan und Schema und nicht im Router: Ohne eine Spalte kann die Route nichts enger anlegen. Zu entscheiden ist deshalb eins von beidem — eine Schulart an sync_tasks (oder ein Ziel je Schulart in sync_targets), oder der Satz im Plan wird auf "bei der Schulleitung" zurückgenommen und die Wochenmail bleibt für beide Leitungen dieselbe.

Gefunden im dreizehnten API-Prüfzyklus als ANMELDUNG-R11.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden: Schulart am Vorgang oder zurückgenommener Satz im Plan
- [ ] #2 Bei der Schulart: eine Migration der Querschnitts-Domäne samt Gegenprobe, kein Nachbau in der Route
- [ ] #3 Die Entscheidung steht als Satz in api/anmeldung-api.md und, wo sie das Schema betrifft, in schema/querschnitt-schema.sql
<!-- AC:END -->
