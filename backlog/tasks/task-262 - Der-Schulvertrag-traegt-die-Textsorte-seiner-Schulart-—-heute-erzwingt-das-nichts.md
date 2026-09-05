---
id: TASK-262
title: Der Schulvertrag traegt die Textsorte seiner Schulart, erzwungen wird es nicht
status: To Do
assignee: []
created_date: '2026-09-04 23:47'
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
- [ ] #1 Ein Schulvertrag mit der Textsorte einer anderen Schulart wird abgewiesen — als Gegenprobe
- [ ] #2 Der Hortvertrag bleibt unberuehrt: er kennt keine Schulart und keine Bewerbung
- [ ] #3 Die Gegenprobe deckt den Quereinsteiger mit ab — die Stufe entscheidet nichts, die Schulart alles
<!-- AC:END -->
