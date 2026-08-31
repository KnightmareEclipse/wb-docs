---
id: TASK-141
title: Die beiden Vorarbeits-Mails des Jahreswechsels am 1. Juli
status: Done
assignee: []
created_date: '2026-08-31 00:59'
updated_date: '2026-08-31 19:56'
labels:
  - wb-backend
  - stammdaten
  - lauf
milestone: m-5
dependencies: []
references:
  - api/stammdaten-api.md
  - soll-prozesse/04-schuljahreswechsel.md
ordinal: 153000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Plan nennt vier Läufe der Stammdaten (api/stammdaten-api.md, "Die vier Läufe"); app/runs.py trägt von ihnen genau einen, login_purge. Dies ist der erste der drei fehlenden.

Aus 04 Z1: am 1. Juli, ein festes Datum, geht eine Mail ans Sekretariat mit den Kindern, die nicht aufsteigen, und eine an die Geschäftsführung, die Preise des neuen Jahres zu prüfen; die zweite legt zugleich ihre Aufgabe an. Die erste geht genau einmal, es wird nicht nachgefasst.

Die Marke ist die Mail selbst — eine outbound_emails-Zeile dieses Zwecks seit dem Auslöser, wie die vier Läufe der Anmeldung und die Wochenmail es machen (app/runs.py). Keine Spalte daneben, also keine Migration.

Gefunden im dreizehnten API-Prüfzyklus als STAMMDATEN-R9.

Gebaut in app/services/rollover.py, registriert als rollover_repeaters und rollover_prices. Die Preisprüfung brauchte ein neues Ziel `annual_prices` — es gab noch keines bei der Geschäftsführung; Bezug ist das Schuljahr, womit der partielle Unique-Index die zweite Aufgabe verhindert.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Zwei Run-Zeilen in app/runs.py unter dem Aktor system:rollover
- [x] #2 Die Marke ist die outbound_emails-Zeile; ein zweiter Tick am selben Tag schickt nichts
- [x] #3 Die Mail an die Geschäftsführung legt ihre Aufgabe in derselben Transaktion an
- [x] #4 Je Lauf ein Test in tests/test_runs.py, der zweimal hintereinander läuft
<!-- AC:END -->
