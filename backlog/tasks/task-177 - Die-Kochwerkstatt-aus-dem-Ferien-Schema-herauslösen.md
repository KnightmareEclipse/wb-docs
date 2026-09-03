---
id: TASK-177
title: Die Kochwerkstatt aus dem Ferien-Schema herauslösen
status: To Do
assignee: []
created_date: '2026-09-01 19:10'
updated_date: '2026-09-03 11:37'
labels:
  - schema
  - ferien
  - akademie
  - wb-docs
  - wb-backend
dependencies:
  - TASK-176
references:
  - schema/ferien-schema.sql
  - schema/ferien-schema-check.sql
  - soll-prozesse/10-ferienprogramm.md
  - soll-prozesse/21-akademie.md
ordinal: 189000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Kochwerkstatt ist seit dem 01.09.2026 ein Akademie-Angebot (Block 21) und kein Ferientermin mehr. Block 10 ist nachgezogen, das Schema noch nicht — und wb-backend führt es, die Änderung beginnt also dort als Migration.

Drei Dinge verlassen die Ferien-Domäne. Zwei davon wandern in die Akademie und verschwinden NICHT (bestätigt am 03.09.2026):

- Der Lebensmittelaufschlag (`holiday_session_surcharges`) ist kein Kochwerkstatt-Artefakt, sondern der einzige Betrag dieser Domäne, den nicht die Geschäftsführung setzt: "Die Lebensmittel kauft die Hauswirtschaftsleitung je Termin ein, und was sie kosten, weiß niemand ein Jahr im Voraus" (10). Er wird in der Akademie ein zweiter Betrag am Angebot (TASK-176). Für die Ferien selbst bleibt kein Fall übrig, die Tabelle fällt also — aber erst, wenn ihr Nachfolger steht.
- Das Kennzeichen `holiday_modules.includes_lunch` ("Die Ferienmodule tragen keines") wird in der Akademie eine allgemeine Option am Angebot, mit derselben Bedeutung: im Preis enthalten, nie gesondert berechnet, und das Kind steht an dem Tag auf der Mensaliste (11).

Ersatzlos weg ist allein die Terminart 'cooking' samt ihren beiden Modulen und ihrem Stornotext. Die beiden Module werden in der Akademie zwei Angebote, weil man sich dort zum Angebot als Ganzem anmeldet.

Danach ziehen die Kommentare in ferien-schema.sql, der Sollstand im Kopf von ferien-schema-check.sql und dessen Seed-Zeilen nach.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Migration in wb-backend, danach die .sql hier nachgezogen
- [ ] #2 holiday_session_surcharges ist weg, und der Aufschlag steht als zweiter Betrag am Akademie-Angebot — TASK-176 trägt ihn, bevor diese Tabelle fällt
- [ ] #3 includes_lunch ist vom Ferienmodul weg und steht als Option am Akademie-Angebot
- [ ] #4 Die Terminart Kochwerkstatt samt Modulen und Stornotext ist aus Schema, Prüfskript und Seed verschwunden
- [ ] #5 Der Sollstand im Kopf des Prüfskripts stimmt wieder, alle Prüfskripte laufen grün gegen die vollständige Datenbank
<!-- AC:END -->
