---
id: TASK-268
title: Der Zahlweg in wb-backend nachziehen
status: To Do
assignee: []
created_date: '2026-09-05 01:05'
updated_date: '2026-09-05 19:10'
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
- [x] #3 Die drei Domaenen-Migrationen sind bearbeitet statt ergaenzt und die Datenbank neu aufgesetzt
- [ ] #4 pytest, ruff, ruff format und mypy gruen
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gemessen am Baum von wb-backend (9be3efa, Branch wertelisten-und-log-filter).

Kriterium 3 steht. Die Revisionen von Stammdaten, Ferien und Putzdienst sind bearbeitet, keine neue Revision daneben, und die Datenbank traegt `families.direct_debit_blocked_at`/`_by` samt `ck_families_direct_debit_blocked` und `ck_families_blocked_by` sowie `payment_mode` an `cleaning_buyouts`, `cleaning_slot_buyouts` und `holiday_bookings` (und an `academy_registrations`).

Offen bleiben drei:

- **Kriterium 1.** Das Sperr-Paar steht, das GRANT zeigt auf die falsche Rolle: Die Stammdaten-Revision vergibt `GRANT UPDATE (direct_debit_blocked_at, direct_debit_blocked_by) ON families TO backend_runtime`. In der Datenbank halten nur `backend_migrator` und `backend_runtime` etwas auf den beiden Spalten, `backend_finance` nichts. `tests/test_privileges.py` kennt die Spalten nicht.
- **Kriterium 2 zur Haelfte.** Die Spalte steht an allen drei Vorgangstabellen, die eine gemeinsame Entscheidung gibt es nicht. `PAID`/`INVOICED` stehen weiter in app/services/ferien.py, app/services/cleaning.py fuehrt daneben ein eigenes `BUYOUT_PAYMENT_MODE = "paid"`, und keine Schreibstelle liest die Sperre, ein laufendes Mandat oder den Anlass — `direct_debit` kommt in app/services und app/routers ueberhaupt nicht vor. Der Seed kennt zu `payment_modes` nur `paid` und `invoiced`.
- **Kriterium 4.** ruff check („All checks passed"), ruff format --check („89 files already formatted") und mypy app tests („Success: no issues found in 89 source files") sind sauber. pytest gab beim ersten Lauf rc=1 zurueck, beim zweiten rc=0 mit 804 — der Grund steht in TASK-269.
<!-- SECTION:NOTES:END -->
