---
id: TASK-162
title: Erhebungsanlass mit Zweckende und Löschtermin je Angabe
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
labels:
  - schema
  - gesundheit
  - dsgvo
  - wartet
dependencies:
  - TASK-161
references:
  - schema/gesundheit-schema.sql
  - pruefberichte/fragen-datenschutz.txt
  - soll-prozesse/10-ferienprogramm.md
ordinal: 174000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Heute hängt jede Gesundheitsangabe am Kind und geht mit ihm. Das reicht nicht mehr: Das Ferienprogramm und die außerunterrichtliche Veranstaltung erheben zusätzliche Angaben für einen einzelnen Anlass, und wer sie danach sofort löscht, steht bei einer späteren Klage ohne Nachweis da — die Schule hatte diesen Fall bereits.

Zwei Termine je Angabe statt eines: ein Zweckende, ab dem sie aus jeder Alltagsansicht verschwindet, und ein Löschtermin, ab dem sie fort ist. Dazwischen ist sie eingeschränkt verarbeitet, lesbar nur zur Verteidigung von Rechtsansprüchen (Art. 17 Abs. 3 lit. e, Art. 18 DSGVO).

Setzt zweierlei voraus, das noch nicht steht: die Domäne der außerunterrichtlichen Veranstaltungen als Anlassgeber, und die Frist vom Datenschutzbeauftragten.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Jede Angabe trägt ihren Anlass; eine Angabe kann zu mehreren Anlässen gehören
- [ ] #2 Zweckende und Löschtermin stehen je Angabe, nicht je Bestand
- [ ] #3 Das Prüfskript zeigt, dass eine Angabe nach dem Zweckende aus der Alltagssicht fällt und trotzdem da ist
- [ ] #4 Die Frist des Datenschutzbeauftragten ist eingetragen, nicht geschätzt
<!-- AC:END -->
