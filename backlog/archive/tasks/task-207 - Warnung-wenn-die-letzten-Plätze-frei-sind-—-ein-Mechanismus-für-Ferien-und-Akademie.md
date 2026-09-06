---
id: TASK-207
title: >-
  Warnung, wenn die letzten Plätze frei sind — ein Mechanismus für Ferien und
  Akademie
status: In Progress
assignee: []
created_date: '2026-09-03 13:55'
updated_date: '2026-09-04 01:05'
labels:
  - schema
  - ferien
  - akademie
milestone: m-5
dependencies: []
references:
  - schema/ferien-schema.sql
  - soll-prozesse/10-ferienprogramm.md
  - soll-prozesse/21-akademie.md
ordinal: 220000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beide Domänen haben dasselbe Bauteil: eine harte Platzzahl und eine anbietende Stelle. Also ein Mechanismus und nicht zwei — Ferienprogramm (10) und Akademie (21) teilen ihn, jede Stelle setzt ihre Schwelle selbst.

Die Schwelle steht **je Termin bzw. je Angebot als Wert**, leer heißt "keine Warnung". "Fünf" ist der heute geäußerte Wunsch der Hortleitung und keine Regel; als Zahl im Code wäre sie in dem Moment falsch, in dem ein Angebot mit zwölf Plätzen anders tickt als eines mit sechzig.

Empfänger ist die anbietende Stelle — dieselbe, die auch die Löschankündigung bekommt. Wer das je Domäne ist, steht in soll-prozesse/hebel.md und wird hier nicht wiederholt.

Der Punkt, an dem es schiefgeht: Ohne Marke schickt der Lauf die Warnung bei jedem Durchgang erneut, solange die Restplätze unter der Schwelle liegen. Sie gehört also einmal je Termin verschickt und vermerkt, wie jede andere Lauf-Marke im System.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Die Schwelle steht je Termin bzw. Angebot als Wert; leer heißt keine Warnung
- [ ] #2 Ein Lauf bedient Ferienprogramm und Akademie, nicht zwei
- [x] #3 Die Warnung geht genau einmal je Termin — die Marke dafür steht am Termin, wie bei den übrigen Läufen
- [x] #4 Empfänger ist die anbietende Stelle; wer das ist, steht in hebel.md und wird nicht wiederholt
- [x] #5 Das Prüfskript weist eine Schwelle ab, die größer als die Platzzahl ist
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut als zwei Spalten an holiday_sessions (ferien-schema.sql) und academy_offerings (akademie-schema.sql): low_places_threshold — leer heisst keine Warnung — und low_places_notice_sent_at als Lauf-Marke, dieselbe Bauform wie first_reminder_sent_at am Putzdienst-Termin. Zwei CHECKs je Tabelle: eine Schwelle ueber der Platzzahl wird abgewiesen, und eine Marke ohne Schwelle behauptete eine Warnung, die nie hinausging. Beide Pruefskripte tragen die Gegenproben. Der Lauf selbst ist wb-backend: eine Abfrage ueber beide Tabellen, kein zweiter Mechanismus. Empfaenger steht in hebel.md und wird hier nicht wiederholt.
<!-- SECTION:NOTES:END -->
