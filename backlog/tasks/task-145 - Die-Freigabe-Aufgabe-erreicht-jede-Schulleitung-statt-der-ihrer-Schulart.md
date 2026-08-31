---
id: TASK-145
title: Die Freigabe-Aufgabe erreicht jede Schulleitung statt der ihrer Schulart
status: Done
assignee: []
created_date: '2026-08-31 14:05'
updated_date: '2026-08-31 20:45'
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

Entschieden und gebaut: eine Spalte `sync_tasks.school_branch_id`, bewusst außerhalb von `ck_sync_tasks_single_subject` — sie sagt, wer die Aufgabe sieht, nicht worum sie geht. Die Route nimmt die Schulart aus der Bewerbung und nicht aus dem Kind: `children.school_branch_id` wird erst bei der Freigabe gesetzt, also in genau dem Schritt, den die Aufgabe anfordert. `role_recipients` filtert auf `employee_roles.school_branch_id`, die Wochenmail gruppiert nach Rolle und Schulart. Zwei Gegenproben im Prüfskript belegen, dass die Schulart mit einem Bezug durchgeht und allein nicht trägt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden: Schulart am Vorgang oder zurückgenommener Satz im Plan
- [x] #2 Bei der Schulart: eine Migration der Querschnitts-Domäne samt Gegenprobe, kein Nachbau in der Route
- [x] #3 Die Entscheidung steht als Satz in api/anmeldung-api.md und, wo sie das Schema betrifft, in schema/querschnitt-schema.sql
<!-- AC:END -->
