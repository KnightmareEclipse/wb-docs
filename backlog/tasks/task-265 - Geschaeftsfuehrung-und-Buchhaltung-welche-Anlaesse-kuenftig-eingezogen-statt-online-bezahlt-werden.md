---
id: TASK-265
title: >-
  Geschaeftsfuehrung und Buchhaltung: welche Anlaesse kuenftig eingezogen statt
  online bezahlt werden
status: To Do
assignee: []
created_date: '2026-09-05 00:18'
updated_date: '2026-09-05 00:40'
labels:
  - wb-docs
  - zahlung
  - entscheidung
dependencies:
  - TASK-264
references:
  - soll-prozesse/hebel.md
  - soll-prozesse/01-putzdienst.md
  - soll-prozesse/10-ferienprogramm.md
ordinal: 278000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Offen ist nicht der Mechanismus, sondern die Entscheidung. TASK-264 baut den Zahlweg an jeden Vorgang, der ihn tragen kann; welcher Anlass ihn nutzt, sagt danach der Soll-Block. Heute zieht allein die Akademie ein (21), Putzdienst-Freikauf (01) und Ferienbuchung (10) laufen ueber Stripe.

Was gegeneinander steht: Jeder Einzug spart die Stripe-Gebuehr und nimmt einen Fall aus der Sammelgutschrift, deren fehlender Verwendungszweck heute das Hauptproblem der Buchhaltung ist (hebel.md). Er kostet dafuer je Fall eine Aufgabe in Optigem statt eines automatischen Rueckrufs, und beim Putzdienst und Ferienprogramm liegt das Volumen weit ueber dem der Akademie — die Rechnung ist Stripe-Gebuehr gegen Buchhaltungsstunden.

Zwei Folgen, die mitentschieden werden, weil sie nicht am Schema haengen: Beim Einzug entsteht der Vorgang mit dem Absenden und nicht mit der bestaetigten Zahlung — der Platz ist belegt, bevor das Geld da ist —, und eine Ruecklastschrift dreht ihn nicht automatisch zurueck. Die Sperre aus TASK-264 ist der Hebel dagegen, aber sie wirkt nur, wo jemand sie gesetzt hat.

Ergebnis der Runde wandert in die Bloecke 01 und 10, nicht hierher.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden und in 01 nachgezogen: der Putzdienst-Freikauf wird eingezogen, wo ein Mandat steht, oder bleibt Sofortzahlung
- [ ] #2 Entschieden und in 10 nachgezogen: dasselbe fuer die Ferienbuchung
- [ ] #3 Entschieden: ob eine Ruecklastschrift den Vorgang beruehrt oder allein die Buchhaltung
- [ ] #4 Entschieden: woher der Betrag eines eingezogenen Putzdienst-Freikaufs kommt — er steckt heute allein in der Zahlung, die beim Einzug nicht entsteht
<!-- AC:END -->
