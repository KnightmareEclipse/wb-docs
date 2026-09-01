---
id: TASK-127
title: 'Entscheiden: Akademie-Angebot und kostenpflichtige AG — ein Fall oder zwei'
status: Done
assignee: []
created_date: '2026-08-28 13:27'
updated_date: '2026-09-01 19:11'
labels:
  - entscheidung
  - wb-docs
  - ferien
  - ags
  - geschaeftsfuehrung
milestone: m-5
dependencies: []
references:
  - soll-prozesse/10-ferienprogramm.md
  - schema/ferien-schema.sql
  - schema/ags-schema.sql
ordinal: 139000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Geschäftsführung will die Kochwerkstatt als Akademie führen, neben der weitere Angebote entstehen und wegfallen können, und plant Chor GS/RS mit Gebühr. Der Chor läuft über Wochen bis über das ganze Schuljahr — damit ist er kein Ferientermin und der Ferien-Ablauf trägt ihn nicht. Offen ist, ob die weiteren Akademie-Angebote der Kochwerkstatt folgen (einzelner Kurs mit Kursgebühr, Datensatz im Ferien-Ablauf) oder dem Chor (übers Schuljahr, laufender Beitrag). Wo sie dem Chor folgen, sind Akademie und kostenpflichtige AG dieselbe Form und teilen einen Block; zwei Blöcke für dieselbe Form wären der Fehler. Der Geschäftsführung fehlen die Details selbst noch.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden, ob ein Akademie-Angebot ein Ferientermin ist oder ein Schuljahresangebot
- [x] #2 Wenn Schuljahresangebot: es und die kostenpflichtige AG teilen einen Block, nicht zwei
- [x] #3 Umbenennung von Block und Domäne entschieden (heute »Ferienprogramm und Kochwerkstatt«)
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Beantwortet am 01.09.2026: Ein Akademie-Angebot ist kein Ferientermin, sondern trägt einen Zeitraum — Einzeltermin, Reihe und Schuljahresangebot sind dieselbe Form mit anderen Werten. Akademie und kostenpflichtige AG teilen deshalb einen Block, soll-prozesse/21-akademie.md. Umbenannt ist beides: Block 10 heißt nur noch Ferienprogramm, die Kochwerkstatt zieht in die Akademie um (TASK-177), und Domäne 6 heißt Mensa- und Akademie-Anmeldung.
<!-- SECTION:FINAL_SUMMARY:END -->
