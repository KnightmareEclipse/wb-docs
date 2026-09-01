---
id: TASK-190
title: Wer eine Rolle zuweist und wer sie beim Stellenwechsel nachzieht
status: To Do
assignee: []
created_date: '2026-09-01 20:48'
updated_date: '2026-09-01 21:29'
labels:
  - wartet
  - geschaeftsfuehrung
  - zugang
dependencies: []
ordinal: 203000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Rollen selbst stehen (soll-prozesse/hebel.md, glossar.md). Offen war nie welche, sondern wer sie vergibt. Je Rolle zu fragen führt zu nichts — wer die Rollenliste nicht kennt, kann sie nicht aufteilen. Stattdessen eine Regel, vom Betreiber vorgeschlagen und von der Geschäftsführung zu nicken:

- **Jede Führungskraft vergibt die Rollen ihres Bereichs.**
- **Das Personalwesen vergibt alle übrigen.**
- **Der Admin darf jede Rolle vergeben**, damit niemand feststeckt.

Was das kostet, ist die einzige neue Struktur: eine **Zuordnung Bereich zu Rolle**, die es heute nicht gibt — employees kennt nur Schule oder KITA. Der Vorschlag dafür, kurz genug zum Nachlesen: Schulleitung → Lehrkraft; Hortleitung → Hortkraft; Hauswirtschaftsleitung → Mensa und Hausmeister; KITA-Leitung → KITA-Mitarbeitende; Personalwesen → Mitarbeitende, Sekretariat, Buchhaltung, Personalverwaltung, Führungskraft und die Leitungsrollen selbst.

Der Stellenwechsel braucht danach keinen eigenen Mechanismus: Wer den Bereich wechselt, bekommt die neue Rolle von der neuen Führungskraft und verliert die alte von der alten. Dass jemand das vergisst, ist kein Modellierungsproblem (CLAUDE.md, kein Netz gegen menschliches Vergessen).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Benannt, welche Rollen das Personalwesen setzt und welche nur die Führungskraft
- [ ] #2 Der Stellenwechsel hat einen Weg: wer meldet ihn, wer zieht die Rolle nach
- [ ] #3 Erst danach: ob Block 13 das trägt oder einen eigenen Schritt braucht
- [ ] #4 Die Regel ist bestätigt: Führungskraft für den eigenen Bereich, Personalwesen für den Rest, Admin für alles
- [ ] #5 Die Zuordnung Bereich zu Rolle steht — als Wert im System, nicht im Code
- [ ] #6 Erst danach: ob Block 13 sie trägt oder ein eigener Schritt entsteht
<!-- AC:END -->
