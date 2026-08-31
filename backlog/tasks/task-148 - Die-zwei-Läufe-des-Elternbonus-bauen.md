---
id: TASK-148
title: Die zwei Läufe des Elternbonus bauen
status: To Do
assignee: []
created_date: '2026-08-31 15:30'
updated_date: '2026-08-31 21:48'
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
api/elternbonus-api.md führt sie unter "Zwei Läufe", app/runs.py kennt beide nicht — die Registertabelle trägt die fünf des Putzdienstes, die vier der Anmeldung und die zwei domänenlosen.

Die Erinnerungsmail am 1. Juni (14 Z3, Aktor system:parent_work_reminder) geht an jede Familie, deren bestätigte Stunden noch nicht voll sind: Stand, was fehlt, was unbestätigt ist, und dass am 31. Juli Schluss ist. Elternvertreter- und Mitarbeiterfamilien bekommen sie nicht, sie gelten ohne Eintrag als voll.

Der Jahresschluss am 1. August (14 Z4, Aktor system:rollover) schließt das am 31. Juli beendete Schuljahr und legt die Jahresliste als eine Aufgabe bei der Buchhaltung an (sync_targets, Ziel optigem). Er läuft vor dem Jahreslauf desselben Tages (TASK-142), sonst stünde ein Viertklässler schon als Realschüler da und die Familie hätte für das vergangene Jahr 10 statt 15 Pflichtstunden. Die Rechnung selbst steht bereits: GET /parent-work-entries/annual-list erzeugt sie frisch, der Lauf übergibt sie nur.

Vor dem Bau ist je Lauf die Marke zu entscheiden und nicht zu raten, in der Form aus README.md, "Runs": eine Spalte, wo die Domäne eine hat, sonst die Mail selbst als outbound_emails-Zeile. Die Erinnerungsmail trägt die zweite Form von selbst; der Jahresschluss verschickt nichts und trägt damit keine der beiden — eine Spalte für ihn wäre eine Migration.

Solange beide fehlen, hält allein die Route die Frist des 31. Juli (BONUS-R3), und keine Familie wird an sie erinnert.

Gefunden im API-Prüfzyklus als BONUS-R4.
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
