---
id: TASK-270
title: Die Routen an die uebertragenen Schemata nachziehen
status: To Do
assignee: []
created_date: '2026-09-05 16:42'
updated_date: '2026-09-05 16:47'
labels:
  - wb-backend
  - pruefzyklus
dependencies: []
ordinal: 283000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gemessen auf wertelisten-und-log-filter nach TASK-269 (3843fab in wb-backend): ./schema-check.sh gibt 0 zurück, alle vierzehn Prüfskripte rc=0, `alembic check` meldet nichts — aber `pytest` sammelt nicht mehr, weil `app/routers/ferien.py` `HolidaySessionSurcharge` importiert und `HolidayModule.includes_lunch` liest. Beides ist mit der Kochwerkstatt aus dem Ferien-Schema heraus (0bb975e in wb-docs); die Nachfolger stehen am Akademie-Angebot, dessen Routen es noch nicht gibt. Solange die eine Zeile steht, läuft kein einziger der 805 Tests.

Dahinter liegt der Rest, den der Übertrag offengelegt hat. Es sind keine Funde am Schema, sondern die Stellen, an denen der Anwendungscode noch die alte Form annimmt:

- **ferien** — der Aufschlag je Termin und `includes_lunch` fallen aus den Antworten; `holiday_bookings` trägt jetzt `holiday_programme_id` und `is_invoiced`, die beide beim Anlegen zu setzen sind, und `holiday_sessions` die Schwelle `low_places_threshold` samt Mitteilungsmarke.
- **mensa** — die Tagesliste liest das Mittagessen bisher am Ferienmodul; diese Quelle ist fort und kommt am Akademie-Angebot wieder. `meal_subscriptions` trägt zusätzlich `terms_contract_text_code`.
- **gesundheit** — `child_health_records.action_note` ist eine eigene Tabelle je Bestand und Sichtkreis (`child_health_action_notes`) mit der engen Rolle darauf; die Notfallsicht läuft nicht mehr über `health_field_visibility`, sondern sieht jedes Feld (Auflage vom 02.09.2026, TASK-205) — `test_any_staff_member_reads_the_emergency_slice_and_leaves_a_row` behauptet noch den engen Ausschnitt. Dazu die beiden Freigabetabellen, die noch keine Route hat, und `health_traits.child_health_record_id`.
- **querschnitt** — `documents` verlangt `label` und `child_file_folder_id`, `child_file_folders` eine Kategorie; `document_type_id` ist nullable geworden und mypy meldet die Stelle in `app/routers/querschnitt.py`.
- **anmeldung** — `contracts` trägt `contract_text_code` und `school_branch_id`, beide beim Anlegen zu setzen; die Sorte kommt aus `contract_text_kinds`, die der Seed jetzt füllt (`school_contract_GS`/`school_contract_RS`, `care_contract`, `meal_terms`, `holiday_terms`).
- **putzdienst** — Zuteilung, Tauschangebot und Annahme führen den Zyklus mit; beide Freikäufe die Zahlart als Wert aus `payment_modes`.

Auch `app/seed.py` gehört dazu und bricht als erstes: gemessen scheitert der Lauf an `cleaning_assignments.cleaning_cycle_id`. Solange er das tut, lässt sich der lokale Personal-Login nicht wiederherstellen — die Datenbank wurde für den Übertrag neu aufgesetzt und ist leer.

Abnahmekriterium ist der Nullpunkt aus TASK-269: 805 Tests grün. Was dabei an Antwortfeldern verschwindet, ist extern sichtbar und vorher zu besprechen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 pytest sammelt wieder und laeuft gruen, 805 Tests als Nullpunkt
- [ ] #2 ruff check, ruff format --check und mypy app tests sind sauber
- [ ] #3 ./schema-check.sh bleibt bei 0 und alembic check meldet nichts
- [ ] #4 podman-compose --profile tools run --rm seed laeuft durch, der lokale Login steht wieder
<!-- AC:END -->
