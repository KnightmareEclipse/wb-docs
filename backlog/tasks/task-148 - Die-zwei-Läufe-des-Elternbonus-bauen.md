---
id: TASK-148
title: Die zwei Läufe des Elternbonus bauen
status: To Do
assignee: []
created_date: '2026-08-31 15:30'
updated_date: '2026-09-01 17:46'
labels:
  - wb-backend
  - elternbonus
  - lauf
milestone: m-5
dependencies: []
references:
  - api/elternbonus-api.md
  - soll-prozesse/14-elternbonus.md
ordinal: 160000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
api/elternbonus-api.md führt sie unter "Zwei Läufe", app/runs.py kennt keinen — inzwischen sind es drei.

Die Erinnerungsmail am 1. Juni (14 Z5) geht an jede Familie, deren Stunden noch nicht voll sind: Stand, was fehlt, und dass am 31. Juli Schluss ist. Elternvertreter- und Mitarbeiterfamilien bekommen sie nicht, sie gelten ohne Eintrag als voll. Von "unbestätigt" ist darin nicht mehr die Rede: Bestätigt wird nicht.

Neu der tägliche Erinnerungslauf am Vortag eines Einsatzes (14 Z3) an alle Angemeldeten — Tag, Beginn, Treffpunkt, Mitzubringendes. Er ist der Punkt, an dem heute Einsätze vergessen werden. Seine Marke steht als parent_work_sessions.reminder_sent_at, dieselbe Bauform wie im Putzdienst; ohne sie schickt ein zweiter Lauf am selben Tag die Mail noch einmal.

Der Jahresschluss am 1. August (14 Z6) schließt das am 31. Juli beendete Schuljahr und legt die Jahresliste als eine Aufgabe bei der Buchhaltung an. Er läuft vor dem Jahreslauf desselben Tages (TASK-142), sonst stünde ein Viertklässler schon als Realschüler da und die Familie hätte für das vergangene Jahr 10 statt 15 Pflichtstunden.

Nicht in diesem Ticket: die Absage-Mail. Sie hängt an keinem Lauf, sondern am Druck des Hausmeisters.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Je Lauf ist die Marke entschieden und benannt, bevor Code entsteht
- [x] #2 Zwei Run-Zeilen in app/runs.py, Aktoren system:parent_work_reminder und system:rollover
- [ ] #3 Der Jahresschluss läuft vor dem Jahreslauf desselben Tages (TASK-142)
- [x] #4 Zweimal hintereinander gerufen passiert beim zweiten Mal nichts
- [ ] #5 Elternvertreter- und Mitarbeiterfamilien bekommen die Mail vom 1. Juni nicht
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut: beide Läufe in app/services/elternbonus.py, registriert in app/runs.py, Tests in tests/test_runs.py (Erinnerungsmail inkl. Mitarbeiterfamilie, Jahresschluss-Task, je zweimal gerufen). AC#3 bleibt offen, bis TASK-142 den Jahreslauf anlegt und die Reihenfolge in app/runs.py wirklich greift. AC#5 nur zur Hälfte mit eigenem Test belegt: Mitarbeiterfamilie getestet, Elternvertreter-Ausschluss nur über die unveränderte, bereits in test_elternbonus.py geprüfte is_representative() mitgezogen, kein eigener Lauf-Test dafür.
<!-- SECTION:NOTES:END -->
