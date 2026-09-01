---
id: TASK-177
title: Die Kochwerkstatt aus dem Ferien-Schema herauslösen
status: To Do
assignee: []
created_date: '2026-09-01 19:10'
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

Drei Dinge verlieren damit ihren Grund und nicht bloß ihre Beispiele: die Terminart 'cooking' samt ihren beiden Modulen und ihrem Stornotext, die Tabelle holiday_session_surcharges (sie gibt es laut ihres eigenen Kommentars allein für die Lebensmittel der Kochwerkstatt — im Ferienprogramm sind alle Beträge fest) und das Kennzeichen am Modul, ob ein Mittagessen enthalten ist (Block 10: 'Die Ferienmodule tragen keines').

Danach ziehen die Kommentare in ferien-schema.sql, der Sollstand im Kopf von ferien-schema-check.sql und dessen Seed-Zeilen nach.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Migration in wb-backend, danach die .sql hier nachgezogen
- [ ] #2 holiday_session_surcharges ist weg — oder es steht in einem Kommentar, welcher Ferienfall sie noch braucht
- [ ] #3 Das Kennzeichen 'Mittagessen enthalten' am Ferienmodul ist weg
- [ ] #4 Die Terminart Kochwerkstatt samt Modulen und Stornotext ist aus Schema, Prüfskript und Seed verschwunden
- [ ] #5 Der Sollstand im Kopf des Prüfskripts stimmt wieder, alle Prüfskripte laufen grün gegen die vollständige Datenbank
<!-- AC:END -->
