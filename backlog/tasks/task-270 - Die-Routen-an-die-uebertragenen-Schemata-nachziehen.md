---
id: TASK-270
title: Die Routen an die uebertragenen Schemata nachziehen
status: To Do
assignee: []
created_date: '2026-09-05 16:42'
updated_date: '2026-09-05 16:50'
labels:
  - wb-backend
  - pruefzyklus
dependencies: []
ordinal: 283000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gemessen auf `wertelisten-und-log-filter` nach TASK-269 (**3843fab** in wb-backend): ./schema-check.sh gibt 0 zurück, alle vierzehn Prüfskripte rc=0, `alembic check` meldet nichts, der Katalogabgleich gegen eine aus `wb-docs/schema/*.sql` gebaute Datenbank ist deckungsgleich bis auf `expense_claim_items.last_action_at`. Modelle und Migrationen stehen also. Was fehlt, ist der Anwendungscode: `pytest` sammelt nicht mehr, weil `app/routers/ferien.py` `HolidaySessionSurcharge` importiert und `HolidayModule.includes_lunch` liest. Beides ist mit der Kochwerkstatt aus dem Ferien-Schema heraus (0bb975e in wb-docs); die Nachfolger stehen am Akademie-Angebot, dessen Routen es noch nicht gibt. Solange die eine Zeile steht, läuft kein einziger der 805 Tests.

**Einstiegspunkt ist `mypy app tests`**, weil `pytest` nicht sammelt und der Typlauf damit die einzige Karte ist. Er zeigt 27 Fehler, davon 14 schon am Nullpunkt d1becc7 — die dreizehn neuen sind genau diese Arbeit, und sie haben vier Ursachen: `HolidaySessionSurcharge` (routers/ferien, services/ferien, tests/test_ferien), `HolidayModule.includes_lunch` (routers/ferien zweimal, services/mensa, tests/test_mensa), `ChildHealthRecord.action_note` (routers/gesundheit dreimal, routers/stammdaten zweimal) und das nullable gewordene `documents.document_type_id` (routers/querschnitt).

Der Rest, den der Übertrag offengelegt hat — keine Funde am Schema, sondern die Stellen, an denen der Anwendungscode noch die alte Form annimmt:

- **ferien** — der Aufschlag je Termin und `includes_lunch` fallen aus den Antworten; `holiday_bookings` trägt jetzt `holiday_programme_id` und `is_invoiced`, die beide beim Anlegen zu setzen sind, und `holiday_sessions` die Schwelle `low_places_threshold` samt Mitteilungsmarke.
- **mensa** — die Tagesliste liest das Mittagessen bisher am Ferienmodul; diese Quelle ist fort und kommt am Akademie-Angebot wieder. `meal_subscriptions` trägt zusätzlich `terms_contract_text_code`.
- **gesundheit** — `child_health_records.action_note` ist eine eigene Tabelle je Bestand und Sichtkreis (`child_health_action_notes`) mit der engen Rolle `backend_health_note` darauf; die Notfallsicht läuft nicht mehr über `health_field_visibility`, sondern sieht jedes Feld (Auflage vom 02.09.2026, TASK-205) — `test_any_staff_member_reads_the_emergency_slice_and_leaves_a_row` behauptet noch den engen Ausschnitt. Dazu die beiden Freigabetabellen, die noch keine Route hat, und `health_traits.child_health_record_id`.
- **querschnitt** — `documents` verlangt `label` und `child_file_folder_id`, `child_file_folders` eine Kategorie aus `child_file_categories`; `document_type_id` ist nullable geworden.
- **anmeldung** — `contracts` trägt `contract_text_code` und `school_branch_id`, beide beim Anlegen zu setzen; die Sorte kommt aus `contract_text_kinds`, die der Seed jetzt füllt (`school_contract_GS`/`school_contract_RS`, `care_contract`, `meal_terms`, `holiday_terms`). `app/services/anmeldung.py` bildet den Code mit `school_contract_{branch_code}` schon.
- **putzdienst** — Zuteilung, Tauschangebot und Annahme führen den Zyklus mit; beide Freikäufe die Zahlart als Wert aus `payment_modes`.

Auch `app/seed.py` gehört dazu und bricht als erstes: gemessen scheitert der Lauf an `cleaning_assignments.cleaning_cycle_id`. Solange er das tut, lässt sich der lokale Personal-Login nicht wiederherstellen — die Datenbank wurde für den Übertrag neu aufgesetzt und ist leer (0 Personen, 0 Mitarbeitende).

**Reihenfolge**, weil vorher nichts messbar ist:

1. `app/seed.py` und die vier Importbrüche — erst danach läuft überhaupt ein Test.
2. Dann `tests/test_privileges.py` zuerst laufen lassen. Sie ist die einzige Gegenprobe auf die Grants und die engen Rollen, und sie hat den Übertrag nicht gesehen: geändert wurden Spaltenrechte in allen zehn Domänen-Revisionen, der Zuschnitt von `backend_health_note` (von `child_health_records.action_note` auf die eigene Tabelle, samt dem Eintrag in `READ_HELPERS`) und die Rolle `backend_health_emergency`, die jetzt an ihrer eigenen View hängt.
3. Danach domänenweise in der Reihenfolge der Liste oben.

**Zwei Entscheidungen fallen vorher, beide streichen ein extern sichtbares Antwortfeld:**

- `expense_claim_items.last_action_at` steht noch in wb-backend, die `.sql` schreibt ausdrücklich „bewusst NICHT als Spalte" und legt das Alter in den Index `greatest(created_at, corrected_at)`. 19 Fundstellen im Rechnungsfreigabe-Router: 11 Schreibstellen, das Antwortfeld `ExpenseClaimItemOut.last_action_at`, zwei Lesestellen fürs Wartealter, ein Test, der das Vergessen bewacht. Das Prüfskript prüft den Index nur dem Namen nach und bleibt so oder so grün.
- Die Notfallsicht liefert heute die `value_document_id`; die zweite Hälfte derselben Auflage vom 02.09.2026 verlangt Dokumentfelder nur als Vorliegen. Das ändert die Antwort der Notfalltür.

**Nicht anfassen:** `wb-docs/schema/*.sql` ist die Quelle dieses Übertrags und war schon vor TASK-269 repariert; was dort falsch aussieht, wird ein Ticket und keine Korrektur. Eine Schemaänderung geht in die Revision ihrer Domäne und wird mit `downgrade base` / `upgrade head` eingespielt, nie als Anhang (CLAUDE.md von wb-backend, Abschnitt 6). Und: `ruff format` und `mypy` schreiben aus dem `test`-Dienst nicht in den Baum — dafür einen Einweg-Container mit `-v "$PWD:/src:z" --user 0` fahren, sonst ist das Ergebnis das der letzten gebauten Fassung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 pytest sammelt wieder und laeuft gruen, 805 Tests als Nullpunkt
- [ ] #2 ruff check, ruff format --check und mypy app tests sind sauber
- [ ] #3 ./schema-check.sh bleibt bei 0 und alembic check meldet nichts
- [ ] #4 podman-compose --profile tools run --rm seed laeuft durch, der lokale Login steht wieder
<!-- AC:END -->
