---
id: TASK-268
title: Der Zahlweg in wb-backend nachziehen
status: To Do
assignee: []
created_date: '2026-09-05 01:05'
labels:
  - wb-backend
  - schema
  - zahlung
dependencies:
  - TASK-264
references:
  - schema/stammdaten-schema.sql
  - schema/putzdienst-schema.sql
  - schema/ferien-schema.sql
  - soll-prozesse/hebel.md
ordinal: 281000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TASK-264 hat den Zahlweg in wb-docs gebaut: families traegt die Sperre auf Sofortzahlung, cleaning_buyouts, cleaning_slot_buyouts und holiday_bookings tragen ihren payment_mode, und hebel.md traegt die Regel in drei Stufen. In wb-backend steht davon nichts — der Betreiber wollte die Aenderung in diesem Repo und nicht im Code.

Damit liegt schema/ hier vor wb-backend, also andersherum als CLAUDE.md es vorsieht ("Eine Strukturaenderung beginnt dort und wird hier nachgezogen, nie umgekehrt"). Dieses Ticket dreht es wieder um: Die Migrationen der drei Domaenen werden bearbeitet statt ergaenzt (wb-backend CLAUDE.md Abschnitt 6), die Datenbank also neu aufgesetzt.

Was gebraucht wird, steht vollstaendig in den .sql dieses Repos; drei Punkte, die dort keinen Anker haben:

- Die Entscheidung gehoert an eine Stelle fuer alle Domaenen, nicht je Schreibstelle: eine Funktion, die die Sperre an families, dann ein laufendes Mandat eines Kindes der Familie, dann den Anlass liest. Welcher Anlass eingezogen werden darf, ist eine Liste im Code und keine Zeile in configured_values — das entscheidet der Soll-Block (TASK-265) und heute keiner.
- GRANT UPDATE auf das Sperr-Paar geht an backend_finance und nicht an die Laufzeitrolle: Es ist die eine Spalte, die eine Familie am liebsten selbst aendern wuerde. tests/test_privileges.py prueft das mit.
- PAID und INVOICED stehen heute in app/services/ferien.py; mit drei schreibenden Domaenen gehoeren sie neben die Entscheidung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 families traegt das Sperr-Paar, GRANT UPDATE darauf haelt backend_finance und nicht die Laufzeitrolle
- [ ] #2 Die drei Vorgangstabellen tragen ihren payment_mode; die Schreibstellen setzen ihn ueber die eine gemeinsame Entscheidung
- [ ] #3 Die drei Domaenen-Migrationen sind bearbeitet statt ergaenzt und die Datenbank neu aufgesetzt
- [ ] #4 pytest, ruff, ruff format und mypy gruen
<!-- AC:END -->
