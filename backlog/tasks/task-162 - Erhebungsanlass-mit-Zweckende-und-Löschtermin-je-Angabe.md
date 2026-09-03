---
id: TASK-162
title: Erhebungsanlass mit Zweckende und Löschtermin je Angabe
status: In Progress
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-03 19:05'
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
- [x] #1 Jede Angabe trägt ihren Anlass; eine Angabe kann zu mehreren Anlässen gehören
- [x] #2 Zweckende und Löschtermin stehen je Angabe, nicht je Bestand
- [x] #3 Das Prüfskript zeigt, dass eine Angabe nach dem Zweckende aus der Alltagssicht fällt und trotzdem da ist
- [x] #4 Die Frist des Datenschutzbeauftragten ist eingetragen, nicht geschätzt
- [x] #5 Der Adressat der Vorwarnung ist ein Wert am Anlass und keine Regel im Code — welche Stelle es je Anlass ist, steht in soll-prozesse/hebel.md und wird hier nicht wiederholt
- [x] #6 Die Frist des Anlasses steht: vier Wochen nach der Veranstaltung; die zwei Ankündigungen davor folgen dem Hebel und werden hier nicht wiederholt
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Der Anlass ist der Sichtkreis, an den freigegeben wird — keine eigene Spalte daneben.
Zweckende und Löschtermin stehen an health_trait_releases und nicht an der Angabe
(so TASK-205, jünger als dieses Ticket): Dieselbe Allergie liegt der Schule dauerhaft
und einer Fahrt befristet vor. Das Prüfskript zeigt beides — nach dem Zweckende sieht
die Fahrt nichts mehr, die Angabe steht.

Offen bleibt der Anlassgeber: Die Domäne der außerunterrichtlichen Veranstaltungen
legt die Instanz an, an die eine Fahrt freigeben lässt. Bis dahin gibt es die zwei
dauerhaften Instanzen school und care.
<!-- SECTION:NOTES:END -->
