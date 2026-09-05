---
id: TASK-262
title: 'Der Schulvertrag traegt die Textsorte seiner Schulart, erzwungen wird es nicht'
status: Done
assignee: []
created_date: '2026-09-04 23:47'
updated_date: '2026-09-05 00:35'
labels:
  - schema
  - anmeldung
milestone: m-5
dependencies: []
ordinal: 275000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gefunden am 05.09.2026 beim Durchgehen des Vertragsprozesses: `ck_contracts_text_kind` prueft nur eine Richtung — `(contract_type = care) = (contract_text_code = care_contract)`. Der **Hortvertrag** ist damit an seine Textsorte gebunden, der **Schulvertrag an keine Schulart**: Ein Grundschulkind kann den Realschulvertrag tragen, und nichts faellt auf.

**Warum das zaehlt:** Grund- und Realschule haben verschiedene Preise und verschiedene Vertragstexte (`tuition_fees` haengt an Schulart und Geschwisterrang, `school_contract_gs` und die RS-Sorte sind zwei Zeilen). Es sind zwei Vertraege, nicht einer mit einer Variante.

**Die Klassenstufe spielt dabei keine Rolle und ist kein Sonderfall.** Die Textsorte haengt an der Schulart, nicht an der Stufe: Ein Quereinsteiger in Klasse 3 bekommt denselben GS-Vertrag wie ein Erstklaessler, einer in Klasse 7 den RS-Vertrag. Die Stufe steht im Vertragstext (TASK-260), sie entscheidet aber nicht, welcher Text gilt.

**Der Wechsel GS → RS ist ebenfalls geklaert und braucht hier nichts:** Er erzeugt einen **neuen** Vertrag mit der Sorte der neuen Schulart; der alte endet zum 31. Juli mit der auslaufenden (04). Kein Nachtrag, sondern ein zweiter Vertragsvorgang.

**Woran der Constraint haengt:** Die Schulart steht nicht an `contracts`, sondern an der Bewerbung (`applications.school_branch_id`) und am Kind. Der Schulvertrag traegt `application_id` als Pflicht — der zusammengesetzte Weg ueber die Bewerbung ist damit vorhanden, und es ist derselbe Griff wie bei `fk_contracts_application`, der den Vertrag schon heute an das Kind seiner Bewerbung bindet.

Zu entscheiden ist, ob die Bindung ueber einen zusammengesetzten Fremdschluessel laeuft oder ueber einen Trigger — der Hortvertrag hat keine Bewerbung und muss aussen vor bleiben.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ein Schulvertrag mit der Textsorte einer anderen Schulart wird abgewiesen — als Gegenprobe
- [x] #2 Der Hortvertrag bleibt unberuehrt: er kennt keine Schulart und keine Bewerbung
- [x] #3 Die Gegenprobe deckt den Quereinsteiger mit ab — die Stufe entscheidet nichts, die Schulart alles
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut ueber zusammengesetzte Fremdschluessel, nicht ueber einen Trigger — Trigger sind in diesem Projekt ausgeschlossen (CLAUDE.md).

`contracts.school_branch_id` fuehrt die Schulart der Bewerbung mit (rules.md Abschnitt 1: ein ableitbarer Wert darf stehen, wenn er ein Constraint traegt, das ueber den Ableitungsweg nicht ausdrueckbar ist). Zwei Schluessel binden sie: `fk_contracts_application_branch` gegen `applications` (dafuer neu `uq_applications_id_branch`), `fk_contracts_text_branch` gegen `contract_text_kinds`, das jetzt selbst eine `school_branch_id` samt `uq_contract_text_kinds_code_branch` traegt. `ck_contracts_branch` haelt beide scharf: ohne ihn liesse MATCH SIMPLE die leere Spalte ungeprueft durch, und der Realschulvertrag am Grundschulkind ginge wieder durch. Der Hortvertrag bleibt aussen vor — er traegt keine Schulart, beide Schluessel greifen bei ihm nicht.

Der Kommentar an `ck_contracts_text_kind`, der die Auslassung noch begruendete ('ein Constraint dafuer braeuchte eine dritte Spalte, die nichts weiter traegt'), ist ersetzt.

Der Fund dabei: Das Pruefskript selbst trug den Fehler. 'zweiter Schulvertrag beim Wechsel in die eigene Realschule' legte eine Bewerbung fuer die Realschule an und gab ihr den Grundschul-Vertragstext — genau der Fall aus dem Ticket, gruen durchgelaufen. Er ist korrigiert und faellt jetzt ohne die neuen Schluessel rot.

Vier Gegenproben in anmeldung-schema-check.sql, jede gegen den benannten Constraint verifiziert: Textsorte der anderen Schulart (fk_contracts_text_branch), Vertrag an einer Bewerbung anderer Schulart (fk_contracts_application_branch), Schulvertrag ohne Schulart und Hortvertrag mit Schulart (beide ck_contracts_branch), dazu der Quereinsteiger als expect_accept. Alle 14 Pruefskripte rc=0 gegen die vollstaendige Datenbank.

wb-backend zieht nach: TASK-267.
<!-- SECTION:NOTES:END -->
