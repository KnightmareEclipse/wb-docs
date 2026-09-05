---
id: TASK-269
title: Die elf reparierten Schemata nach wb-backend übertragen
status: Done
assignee: []
created_date: '2026-09-05 15:34'
updated_date: '2026-09-05 19:49'
labels:
  - wb-backend
  - pruefzyklus
dependencies: []
ordinal: 282000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gemessen auf wertelisten-und-log-filter (d1becc7) nach dem Merge aus TASK-198: ./schema-check.sh gibt 1 zurück, elf der vierzehn Prüfskripte aus wb-docs/schema/ scheitern gegen die Datenbank des Backends. Es fehlen ganze Bestände — querschnitt elf Tabellen (mail_categories bis retention_holds), akademie acht, klassenorganisation fünf, anmeldung sechs, gesundheit drei, stammdaten zwei (alumni_kinds, alumni), putzdienst eine — dazu einzelne Constraints in ferien (sechs), mensa (drei) und rechnungsfreigabe (zwei); elternbonus meldet die Regel 'Anmeldung auf einen vollen Einsatz umgehängt' als nicht gebaut. Grün sind nur klassenbildung, m365 und selfservice, also genau die drei Schemata ohne Tabellen. Das ist der Rückstand des abgeschlossenen Schema-Prüfzyklus: wb-docs ist repariert, wb-backend nicht, und der Übertrag läuft über prompts/schema-uebertragen.md. Solange er offen ist, prüfen die acht Läufe aus TASK-202 Routen gegen ein Schema, das wb-docs längst anders beschreibt, und melden Funde, die in Wahrheit dieser Rückstand sind.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 ./schema-check.sh gibt 0 zurück, alle vierzehn Prüfskripte rc=0
- [x] #2 Die Änderungen stehen in der Ursprungsrevision, es entsteht keine Migrationskette
- [x] #3 pytest bleibt grün, Nullpunkt vor dem Übertrag sind 805 Tests
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Kriterium 1 und 2 nachgemessen: `./schema-check.sh` gibt 0 zurück, alle vierzehn Prüfskripte rc=0. Die elf Domänen-Revisionen sind bearbeitet, drei Revisionen sind gelöscht, neu ist allein die Revision der neuen Domäne Akademie — zu keiner bestehenden Domäne kommt eine Revision dazu, es entsteht also keine Kette.

Kriterium 3 steht, nachdem der Lauf wiederholbar geworden ist: zweimal hintereinander gegen dieselbe Datenbank rc=0 mit je 805 Tests.

Er war es nicht. Der erste Lauf gab rc=1 mit 803 passed und einem Fehler — `tests/test_mensa.py::test_a_weekday_a_care_module_feeds_is_refused_at_the_days_route_too`, `duplicate key value violates unique constraint "pk_contract_texts", Key (contract_text_id)=(637)`. `_release()` in tests/test_stammdaten.py legt eine `contract_texts`-Zeile `care_contract` an und nahm sie nie zurück; `contract_texts` stand nicht in `conftest.WIPED`, der TRUNCATE setzte aber die Identity-Folge zurück, während die Zeile ihre Kennung behielt. Aufgenommen ist sie jetzt, und aus demselben Grund wie `configured_values`: keine Migration füllt sie, sie steht nicht in `SEEDED_TABLES`, jede Zeile darin stammt aus einem Lauf.

Die Testzahl: 805 sind 804 aus dem Übertrag plus der Leser-Test aus TASK-240. Der Nullpunkt von 805 minus `test_a_kind_of_date_without_a_deadline_locks_nobody` in tests/test_ferien.py ergab die 804 — dessen Gegenstand ging mit der Kochwerkstatt aus der Domäne. Die Regel, die er hielt, steht aber weiter: `holiday_session_types.cancellation_deadline_days` bleibt nullable, und `_inside_deadline` kehrt bei leerer Spalte ohne Sperre zurück (app/routers/ferien.py) — mit einem Docstring, der die entfallene Kochwerkstatt als Beispiel nennt. Der Zweig ist ohne Gegenprobe.
<!-- SECTION:NOTES:END -->
