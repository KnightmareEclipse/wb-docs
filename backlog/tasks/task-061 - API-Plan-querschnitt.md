---
id: TASK-061
title: API-Plan querschnitt
status: Done
assignee: []
created_date: '2026-08-27 11:39'
updated_date: '2026-08-29 18:19'
labels:
  - wb-docs
  - api-plan
  - querschnitt
milestone: m-1
dependencies: []
references:
  - prompts/api-planen.md
  - schema/querschnitt-schema.sql
  - api/gemeinsam.md
ordinal: 73000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Querschnitt. Bewusst NICHT vor dem Putzdienst, aus demselben Grund wie 059: Payments, sync_tasks und outbound_emails werden geschrieben, aber nicht von außen gerufen — der Mailversand läuft im Dienst, die Aufgabe entsteht im Vorgang, der sie auslöst. Die eine Ausnahme ist der Rückruf des Zahlungsdienstes; er hat seinen Plan bereits in api/gemeinsam.md, Abschnitt Sofortzahlung, und sein eigenes Ticket (104). Was hier noch zu planen ist, betrifft die Ansichten auf Dokumente, Zustimmungen und Änderungsspur — alles ab Domäne 2/4.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 api/querschnitt-api.md steht, Gemeinsames bleibt in api/gemeinsam.md
- [x] #2 Rollen je Route benannt, enge Rollen als Spalten-GRANT und nicht als if
<!-- AC:END -->
