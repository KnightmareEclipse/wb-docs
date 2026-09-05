Stand: c4ef05a, Nullpunkt: 18 Tests grün

# Prüflauf `payments` — Routen und Tests

Geprüft: `app/routers/payments.py` (`POST /payments/callback`, `GET /payments`),
`app/services/payments.py`, `tests/test_payments.py`, dazu die vier Settler, die der Rückruf ruft
(`settle_buyout`, `settle_slot_buyout`, `settle_application`, `settle_holiday_bookings`).
Plan: `api/querschnitt-api.md` Q3 samt der Form in `api/gemeinsam.md`, „Sofortzahlung" —
eine `api/payments-api.md` gibt es nicht und soll es nach dem Plan auch nicht geben.

R1–R5, R7, R8 sind geschlossen (`wb-backend`, Commits 6b6f45d, 1853f1f, bfc6787, 2b3b241, 94a3587,
00a7ca7). Offen bleibt R6 — die Korrektur liegt in der Querschnitt-Migration
(`20260822_1323_5c49ca0f48b6_querschnitt_domain.py`), nicht in einer Datei dieser Domäne, und wurde
deshalb hier nicht angefasst: „Diese eine Domäne, und keine zweite" (`api-reparieren.md`).

## Funde

```
[payments-R6] Klasse 5 · GRANT UPDATE auf `payments` ohne Nutzer
Plan: „Für die manuelle Bestätigung einer Zahlung durch die Buchhaltung entsteht **keine** Route"
(querschnitt-api.md, `[A!]`). Es gibt damit keine Route, die eine bestehende Zahlung ändert — und
keine gibt es auch: kein `payment.status = …`, kein `payment.amount_cents = …` in `app/`.
Die Querschnitt-Migration vergibt trotzdem
`GRANT UPDATE (cleaning_buyout_id, cleaning_slot_buyout_id, application_id, holiday_booking_id,
academy_registration_id, amount_cents, status, payment_reference, confirmed_at) ON payments TO
backend_runtime` — also auf jede Spalte außer Schlüssel, Zeitstempel und Aktor. Damit darf die
Laufzeitrolle den Betrag, den Bestätigungszeitpunkt und die Referenz einer stehenden Zahlung
überschreiben; die Referenz ist der Anker der Idempotenz, der Betrag der Inhalt des
Einzelnachweises.
Gemessen: `REVOKE UPDATE ON payments FROM backend_runtime`, tests/test_payments.py bleibt grün
(18 passed) — die Domäne braucht das Recht nicht.
Vorschlag: das UPDATE-GRANT in der Querschnitt-Migration streichen und in `tests/test_privileges.py`
festhalten; es kommt mit der Route wieder, die es braucht.
```
