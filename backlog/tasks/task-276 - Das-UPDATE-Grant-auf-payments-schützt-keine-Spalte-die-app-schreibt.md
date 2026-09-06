---
id: TASK-276
title: 'Das UPDATE-Grant auf payments schützt keine Spalte, die app/ schreibt'
status: To Do
assignee: []
created_date: '2026-09-06 13:39'
labels:
  - wb-backend
  - querschnitt
  - zahlung
dependencies: []
ordinal: 288000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Prüfbericht `payments-R6` (`pruefberichte/routen-payments.md`) findet: Die Querschnitt-Migration (`app/alembic/versions/20260822_1323_5c49ca0f48b6_querschnitt_domain.py`) vergibt `GRANT UPDATE (cleaning_buyout_id, cleaning_slot_buyout_id, application_id, holiday_booking_id, academy_registration_id, amount_cents, status, payment_reference, confirmed_at) ON payments TO backend_runtime` — jede Spalte außer Schlüssel, Zeitstempel und Aktor.

Für die manuelle Bestätigung einer Zahlung durch die Buchhaltung entsteht nach dem Plan (`api/querschnitt-api.md`, `[A!]` bei "Für die manuelle Bestätigung ... entsteht keine Route") **keine** Route, und keine gibt es auch: `app/` schreibt nirgends `payment.status = …` oder `payment.amount_cents = …`. Der einzige Schreiber ist der `Payment(...)`-Konstruktor in `_record` (`app/routers/payments.py`) — ein INSERT. Die Laufzeitrolle darf damit den Betrag, den Bestätigungszeitpunkt und die Referenz einer stehenden Zahlung überschreiben, ohne dass irgendein Code das nutzt: die Referenz ist der Anker der Idempotenz (`uq_payments_payment_reference`), der Betrag der Inhalt des Einzelnachweises.

Der Vorschlag des Prüfers — das GRANT streichen — ist eine Migration und kein Routen-Fix (`prompts/api-reparieren.md`: "Braucht ein Fund DDL, ist er kein Routen-Fund mehr"). `tests/test_privileges.py` prüft `payments` bisher gar nicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Migration vergibt kein UPDATE mehr auf den neun bisherigen Spalten von payments (REVOKE UPDATE ON payments FROM backend_runtime)
- [ ] #2 tests/test_privileges.py hält fest, dass backend_runtime auf payments keine Spalte per UPDATE erreicht
- [ ] #3 Kommt die manuelle Bestätigung (die Route, die querschnitt-api.md [A!] noch offenlässt) später, bekommt sie ihr eigenes, enges UPDATE-GRANT in derselben Migration — nicht die neun Spalten von heute
<!-- AC:END -->
