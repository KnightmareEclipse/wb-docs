---
id: TASK-203
title: 'prompts/api-pruefen.md: zwei gemessene Lücken im Rezept'
status: To Do
assignee: []
created_date: '2026-09-02 23:45'
labels:
  - wb-docs
  - pruefzyklus
dependencies: []
references:
  - prompts/api-pruefen.md
ordinal: 216000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Prüflauf anmeldung ist an beiden hängengeblieben, beide sind gemessen und nicht vermutet. Erstens: Das Rezept baut nur den test-Dienst, nie migrate. Ein wbp-DOMÄNE_migrate-Image aus einem früheren Lauf überlebt podman-compose down -v, und podman-compose run baut nur ein fehlendes — der Migrationslauf zieht dann ein Schema von vorgestern hoch. Hier: 116 Fehler an einer Spalte, die die Migration im Baum längst anlegt, und ein roter Nullpunkt, der wie ein Fund aussieht. Es ist dieselbe Falle, die der Prompt für den test-Dienst zweimal ausschreibt. Zweitens: Die TRUNCATE-Zeile fürs Aufräumen nach einer roten Messung lässt contract_texts und sharepoint_libraries aus; das Fixture der Anmeldung legt beide selbst an und räumt sie nur bei sauberem Teardown, der nächste Lauf scheitert danach an uq_sharepoint_libraries_code statt an der Mutation. Beides trifft die acht Restläufe aus TASK-202.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Das Rezept baut migrate vor dem Migrationslauf, mit demselben Grund wie beim test-Dienst
- [ ] #2 Die TRUNCATE-Zeile nimmt contract_texts und sharepoint_libraries mit
<!-- AC:END -->
