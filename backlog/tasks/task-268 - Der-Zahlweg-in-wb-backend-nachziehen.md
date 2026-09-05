---
id: TASK-268
title: Der Zahlweg in wb-backend nachziehen
status: To Do
assignee: []
created_date: '2026-09-05 01:05'
updated_date: '2026-09-05 19:32'
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

- Die Entscheidung gehoert an eine Stelle fuer alle Domaenen, nicht je Schreibstelle: eine Funktion, die die Sperre an families, dann das laufende Mandat des Kindes am Vorgang, dann den Anlass liest. Welcher Anlass eingezogen werden darf, ist eine Liste im Code und keine Zeile in configured_values — das entscheidet der Soll-Block (TASK-265) und heute keiner.
- GRANT UPDATE auf das Sperr-Paar geht an backend_finance und nicht an die Laufzeitrolle: Es ist die eine Spalte, die eine Familie am liebsten selbst aendern wuerde. tests/test_privileges.py prueft das mit.
- PAID und INVOICED stehen heute in app/services/ferien.py; mit drei schreibenden Domaenen gehoeren sie neben die Entscheidung.
- Die Entscheidung faellt je Vorgang und nicht je Domaene: eingezogen oder sofort ueber Stripe bezahlt. `payment_modes` traegt `is_direct_debit` und `uq_payment_modes_traits` dafuer, der Seed kennt aber nur `paid` und `invoiced` — die Zeile fuer den Einzug fehlt, und ohne sie hat die Entscheidung keinen Wert zu setzen.
- **Eingezogen wird nur mit dem SEPA-Mandat des Kindes, und nur fuer dieses Kind.** `sepa_mandates` haengt allein an `child_id` — es gibt kein Familien- und kein Personenmandat. Damit ist der Einzug nicht an jedem Vorgang moeglich: `holiday_bookings` traegt `child_id` und kann ihn; `academy_registrations` traegt `child_id` **oder** `person_id` (`for_adults`) und kann ihn nur in der Kind-Haelfte; `cleaning_buyouts` haengt an `family_id` und `cleaning_slot_buyouts` an `cleaning_assignment_id`, an beiden haengt kein Kind. `[A]` Wo am Vorgang kein Kind haengt, gibt es keinen Einzug — es wird ueber Stripe gezahlt; fuer den Putzdienst steht das schon am `payment_mode` in schema/putzdienst-schema.sql, die Annahme zieht es ueber die Akademie-Anmeldung Erwachsener mit. — Alternative: ein Mandat je Familie statt je Kind, dann zoege auch der Putzdienst ein; Preis: `sepa_mandates` haengt heute an `child_id`, das waere eine Strukturaenderung an einer unterschriebenen Unterlage samt der neuen Frage, welches der Mandate einer Familie gilt.
- Es sind vier Vorgangstabellen, nicht drei: `academy_registrations` traegt `payment_mode` seit dem Uebertrag der Akademie und ist die einzige, deren Fremdschluessel `is_direct_debit` schon mitfuehrt (`fk_academy_registrations_payment_mode`). Die drei anderen paaren nur `code` und `is_invoiced` und muessen die dritte Spalte mitnehmen, sonst kann der Einzug an ihnen nicht stehen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 families traegt das Sperr-Paar, GRANT UPDATE darauf haelt backend_finance und nicht die Laufzeitrolle
- [ ] #2 Die vier Vorgangstabellen tragen ihren payment_mode; die Schreibstellen setzen ihn ueber die eine gemeinsame Entscheidung, die je Vorgang zwischen Einzug und Sofortzahlung ueber Stripe waehlt
- [x] #3 Die drei Domaenen-Migrationen sind bearbeitet statt ergaenzt und die Datenbank neu aufgesetzt
- [ ] #4 pytest, ruff, ruff format und mypy gruen
- [ ] #5 Eingezogen wird nur mit dem laufenden Mandat des Kindes am Vorgang und nur fuer dieses Kind; wo kein Kind am Vorgang haengt, gibt es keinen Einzug — Gegenprobe in beide Richtungen
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gemessen am Baum von wb-backend (9be3efa, Branch wertelisten-und-log-filter).

Kriterium 3 steht. Die Revisionen von Stammdaten, Ferien und Putzdienst sind bearbeitet, keine neue Revision daneben, und die Datenbank traegt `families.direct_debit_blocked_at`/`_by` samt `ck_families_direct_debit_blocked` und `ck_families_blocked_by` sowie `payment_mode` an `cleaning_buyouts`, `cleaning_slot_buyouts` und `holiday_bookings` (und an `academy_registrations`).

Offen bleiben drei:

- **Kriterium 1.** Das Sperr-Paar steht, das GRANT zeigt auf die falsche Rolle: Die Stammdaten-Revision vergibt `GRANT UPDATE (direct_debit_blocked_at, direct_debit_blocked_by) ON families TO backend_runtime`. In der Datenbank halten nur `backend_migrator` und `backend_runtime` etwas auf den beiden Spalten, `backend_finance` nichts. `tests/test_privileges.py` kennt die Spalten nicht.
- **Kriterium 2 zur Haelfte.** Die Spalte steht an allen vier Vorgangstabellen, die eine gemeinsame Entscheidung gibt es nicht. `PAID`/`INVOICED` stehen weiter in app/services/ferien.py, app/services/cleaning.py fuehrt daneben ein eigenes `BUYOUT_PAYMENT_MODE = "paid"`, und keine Schreibstelle liest die Sperre, ein laufendes Mandat oder den Anlass — `direct_debit` kommt in app/services und app/routers ueberhaupt nicht vor. Waehlbar ist der Einzug bis heute auch gar nicht: Der Seed kennt zu `payment_modes` nur `paid` und `invoiced`, und von den vier Fremdschluesseln fuehrt allein der der Akademie `is_direct_debit` mit.
- **Kriterium 5.** Der Anker fehlt an zwei der vier Tabellen: `cleaning_buyouts` traegt `family_id`, `cleaning_slot_buyouts` traegt `cleaning_assignment_id`, ein Kind haengt an keinem von beiden. `cleaning_slot_buyouts` traegt dazu `ck_cleaning_slot_buyouts_no_invoice CHECK (NOT is_invoiced)` — dieser Vorgang darf ohnehin nur sofort bezahlt werden. `academy_registrations` kann den Einzug nur tragen, solange `for_adults` falsch ist.
- **Kriterium 4.** ruff check („All checks passed"), ruff format --check („89 files already formatted") und mypy app tests („Success: no issues found in 89 source files") sind sauber. pytest gab beim ersten Lauf rc=1 zurueck, beim zweiten rc=0 mit 804 — der Grund steht in TASK-269.
<!-- SECTION:NOTES:END -->
