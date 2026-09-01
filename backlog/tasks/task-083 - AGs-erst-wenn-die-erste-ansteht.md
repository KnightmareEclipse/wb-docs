---
id: TASK-083
title: 'AGs: erst wenn die erste ansteht'
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-09-01 19:11'
labels:
  - wb-docs
  - ags
  - wartet
  - geschaeftsfuehrung
milestone: m-5
dependencies: []
references:
  - schema/ags-schema.sql
  - soll-prozesse/README.md
ordinal: 95000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Chor GS und RS sind geplant, beide mit Gebühr — damit steht die erste an; weitere waren noch im Prozess. Der Schnitt der Geschäftsführung: abgebildet wird, was einen Zahlungslauf hat, kostenlose AGs führen die Lehrkräfte auf ihrer Liste. Er trägt, mit einer Präzisierung — nicht das Geld entscheidet, sondern die begrenzte Anmeldung: eine kostenlose AG mit mehr Bewerbern als Plätzen bräuchte dasselbe. Praktisch fällt beides zusammen. Erst mit den Antworten unten beginnt Block 20; eine Tabelle auf Verdacht entsteht weiter nicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Einmalige Gebühr (Sofortzahlung) oder laufender Beitrag (aufs Schulgeld) — das entscheidet den halben Block
- [x] #2 Gibt es Plätze und damit eine Zuteilung, oder meldet sich an, wer will
- [x] #3 Wer führt die Liste und wer trägt die Anmeldung ein
- [x] #4 Mit TASK-127 zusammen entschieden: dasselbe wie ein Akademie-Angebot außerhalb der Ferien
- [x] #5 Chor läuft über Wochen bis über das ganze Schuljahr — kein Ferientermin, der Ferien-Ablauf trägt ihn nicht
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Beantwortet am 01.09.2026: Die AGs sind in der Akademie aufgegangen (soll-prozesse/21-akademie.md). Ein Betrag je Angebot, einmal fällig — eingezogen über das SEPA-Mandat, bei einer Familie ohne Mandat sofort online. Begrenzte Plätze ja, und hart; keine Zuteilung und kein Nachrücken, wer zuerst kommt. Die anbietende Stelle führt das Angebot und liest die Teilnehmerliste, angemeldet wird von den Eltern selbst. Der Chor ist damit derselbe Fall wie ein Akademie-Angebot (TASK-127), und kein Ferientermin.
<!-- SECTION:FINAL_SUMMARY:END -->
