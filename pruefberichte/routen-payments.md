Stand: c4ef05a, Nullpunkt: 18 Tests grün

# Prüflauf `payments` — Routen und Tests

Geprüft: `app/routers/payments.py` (`POST /payments/callback`, `GET /payments`),
`app/services/payments.py`, `tests/test_payments.py`, dazu die vier Settler, die der Rückruf ruft
(`settle_buyout`, `settle_slot_buyout`, `settle_application`, `settle_holiday_bookings`).
Plan: `api/querschnitt-api.md` Q3 samt der Form in `api/gemeinsam.md`, „Sofortzahlung" —
eine `api/payments-api.md` gibt es nicht und soll es nach dem Plan auch nicht geben.

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

```
[payments-R3] Klasse 6 · POST /payments/callback → settle_holiday_bookings
Plan: „Ein Kauf aus mehreren Zeilen trägt ganz oder gar nicht" (gemeinsam.md, „Sofortzahlung"),
und der Docstring des Settlers sagt „Everything is checked before the first row is written."
`write_bookings` (`app/services/ferien.py`) gibt aber an zwei Stellen `None` zurück, **nachdem**
für ein früheres Kind schon `holiday_bookings`-Zeilen geflusht sind: `entry.child is None` und
`form.family_id is None and not form.guardians`. `_record` liest dieses `None` als „nichts
geschrieben", legt die Zahlung ohne Vorgang plus Aufgabe an — und committet die halben Buchungen
mit. `picks_still_hold` deckt beide Fälle nicht ab; abgefangen werden sie allein von
`POST /holiday/bookings`, also von der Route auf der anderen Seite der Zahlungssitzung.
Nur gelesen: über die heutige Route nicht erreichbar, weil sie beide mit 400 abweist.
Vorschlag: die zwei Bedingungen in `picks_still_hold` ziehen, wo der Callback sie vor der ersten
Zeile fragt.
```

```
[payments-R2] Klasse 8, Plan gegen Block · die Akademie-Anmeldung fehlt an drei Stellen
Block: „der Freikauf eines Putzdiensttermins (01), die Bearbeitungsgebühr der Voranmeldung (05),
die Ferienbuchung (10) **und die Akademie-Anmeldung, hinter der kein Mandat steht (21)** … Für alle
vier gilt dasselbe" (hebel.md, „Sofortzahlung").
Plan: „Drei Vorgänge werden sofort bezahlt", „eine für alle drei Anlässe", „Fünf Festlegungen dazu,
die für alle drei Anlässe gelten" (gemeinsam.md, „Sofortzahlung") — der Plan zählt drei, der Block
vier. Das Schema zählt schon fünf Spalten: `academy_registration_id` steht in `payments`, in
`ck_payments_single_cause` und im `GRANT UPDATE` der Akademie-Migration.
Router: `_SETTLE` kennt vier Anlässe, `_causeless()` und der `key`-Ausdruck in `read_payments`
zählen vier von fünf Ursachenspalten. Eine Akademie-Zahlung liefe im Einzelnachweis als
„ohne Vorgang" mit Familie „—" — also als genau der Fall, den die Liste der Buchhaltung zur
Entscheidung ausweist.
Nur gelesen: heute nicht auslösbar, `app/routers/akademie.py` gibt es noch nicht.
Vorschlag: erst die Zahl in gemeinsam.md gegen den Block richtigstellen (drei → vier), dann die
zwei Ausdrücke in `read_payments` um die fünfte Spalte ergänzen; der Zweig in `_SETTLE` kommt mit
der Akademie-Route.
```

```
[payments-R1] Klasse 4 · GET /payments?start=&end=
Plan: „Zeitpunkt, Bruttobetrag, Familie, Anlass und die Referenz" zu **einer** Sammelgutschrift
(querschnitt-api.md Q3) — der Zeitraum ist die ganze Auswahl, und kein Constraint trägt ihn.
Gemessen: `if start is not None: … confirmed_at >= _day_start(start)` ausgehängt,
tests/test_payments.py bleibt grün (18 passed). Beide Zeitraum-Tests arbeiten mit start == end,
und der end-Filter allein hält sie: „heute bis heute" braucht die Untergrenze nicht, „gestern bis
gestern" schließt die Zahlung von jetzt schon über die Obergrenze aus.
Vorschlag: ein Test mit einer Zahlung von gestern und `start=heute`, der sie nicht in der Liste
findet — die Gegenrichtung der bestehenden Zeitraum-Tests.
```

```
[payments-R4] Klasse 5 · GET /payments — die zweite erlaubte Rolle
Plan: „`accounting`, `executive_management`" (querschnitt-api.md Q3).
Gemessen: `require_role("accounting", "executive_management")` auf `require_role("accounting")`
verkürzt, tests/test_payments.py bleibt grün (18 passed). Kein Test ruft die Route als
Geschäftsführung; `test_the_office_does_not_see_the_proof` prüft nur, dass das Sekretariat
abgewiesen wird, und die Gegenrichtung bleibt offen.
Vorschlag: den vorhandenen Rollen-Test um einen zweiten Aufruf als `executive_management` ergänzen,
der 200 bekommt.
```

```
[payments-R7] Klasse 3 · GET /payments — die Tagesgrenze in der Schulzeit
Plan: „Beide Tage sind inklusiv und werden in der Uhr der Schule gelesen" — der Router rechnet
`_day_start` mit `tzinfo=_LOCAL`, und `test_the_proof_lists_the_period_with_its_sum` schreibt den
Grund aus: „zwischen Mitternacht in Berlin und Mitternacht in UTC unterscheiden sich die zwei
Daten, und das Büro tippt das deutsche."
Gemessen: `tzinfo=_LOCAL` auf `datetime.UTC` gestellt, tests/test_payments.py bleibt grün
(18 passed, gemessen um 23:00 Ortszeit). Der Test kann den Unterschied nur zwischen 00:00 und 02:00
Berliner Zeit beobachten — an den übrigen 22 Stunden des Tages läuft er an der Regel vorbei, die er
im Docstring beschreibt.
Vorschlag: eine Zahlung mit festem `confirmed_at` auf 23:30 UTC anlegen und sie über den **Berliner**
Folgetag suchen; dann hängt der Test nicht mehr an der Uhrzeit des Laufs.
```

```
[payments-R5] Klasse 4 · POST /payments/callback — die Toleranz der Signatur
Plan: „Sie prüft die Signatur des Zahlungsdienstes … ohne diese Prüfung genügt ein POST"
(gemeinsam.md). Der Kommentar an `verify_signature` schreibt die Regel schärfer aus als jeder Test:
„Both directions: a clock that runs ahead of ours is as much a stranger's timestamp as one from
last week."
Gemessen: `abs(...)` aus dem Toleranzvergleich genommen, tests/test_payments.py bleibt grün
(18 passed). `test_an_old_signature_is_refused` prüft nur die Vergangenheit (`age=10min`); ein
Zeitstempel aus der Zukunft wird nirgends probiert, und damit hält die halbe Regel keinen Test.
Gewicht: gering — wer einen Zukunfts-Zeitstempel signieren kann, hat das Webhook-Secret ohnehin.
Vorschlag: denselben Test mit `age=-10min` daneben, eine Zeile.
```

```
[payments-R8] Klasse 4 · GET /payments — das Escaping der Druckansicht
Die Route baut HTML von Hand und escapt Familienname, Anlass und Referenz mit `html.escape`.
Gemessen: beide `html.escape` um Familie und Anlass entfernt, tests/test_payments.py bleibt grün
(18 passed). Kein Test führt einen Namen mit `<`, `>` oder `&` durch die Liste, also hält die
Sicherung nichts fest; `persons.last_name` ist Freitext aus der Stammdatenpflege.
Gewicht: gering — die Liste sehen nur `accounting` und `executive_management`, und was hier bricht,
ist eine Druckseite, kein Token.
Vorschlag: einen der bestehenden Nachweis-Tests auf einen Nachnamen mit `&` stellen und die
escapte Form in der Seite suchen.
```

## Angesehen, nicht als Fund gewertet

- **Klasse 1 (Ownership) ist in dieser Domäne leer.** `GET /payments` ist die Listenroute des Plans
  und kennt deshalb keinen Ownership-Check; `POST /payments/callback` hat keinen angemeldeten
  Aufrufer. Beides steht so im Plan.
- **Die drei Bedingungen der Rückrufroute tragen.** Signatur (M8 rot), Ereignistyp (M7 rot),
  `payment_status` (M6 rot), Idempotenz in beide Richtungen (`test_a_second_delivery_changes_nothing`
  und `test_another_integrity_error_is_no_known_delivery`, beide messen den Zustand und nicht nur
  den Code), die sperrende Wiederholung der Bedingung (M14 rot, M15 rot, M13 rot).
- **Die Aufgabe zur Zahlung ohne Vorgang** entsteht in derselben Transaktion (M12 rot).
- **`payments.status == 'confirmed'`** im Einzelnachweis (M5 rot) und der `end`-Filter (M2 rot).
- **Der gemeinsame Zahlweg-Hebel fehlt im Code** — `app/services/cleaning.py` führt ein eigenes
  `BUYOUT_PAYMENT_MODE = "paid"` neben `PAID`/`INVOICED` in `app/services/ferien.py`, und keine
  Schreibstelle liest die Sperre an `families` oder ein Mandat. Das ist TASK-268 und dort samt
  Messung schon aufgeschrieben, also kein Fund dieses Laufs.
- **Der Graph-Aufruf in `settle_application`** (`request_papers`) läuft innerhalb der
  Callback-Transaktion, die dabei einen Advisory-Lock hält — dieselbe Form, vor der
  `TransactionRoute` warnt. Sie ist hier gewollt: Papieranforderung und Zahlung sollen zusammen
  stehen oder gar nicht, und der Rückruf hat keinen wartenden Menschen.
- **Klasse 7 entfällt:** `payments` hat keinen Lauf in `app/runs.py`.
- **Kein Test lässt `announce_application`/`announce_holiday_bookings` über diesen Rückruf laufen** —
  die beiden Anlässe werden in `tests/test_payments.py` nur als fertige Zeilen gesetzt. Gedeckt ist
  der Weg aber in `tests/test_anmeldung.py` und `tests/test_ferien.py`, die den Rückruf selbst
  rufen; kein Fund dieser Domäne.

## Am Rezept, nicht am Code

Der Räum-Befehl in `prompts/api-pruefen.md` nennt `sharepoint_libraries`, und **genau die macht ihn
kaputt**: `TRUNCATE … sharepoint_libraries … CASCADE` reißt sechs Wertelisten mit, die nur die
Seed-Migration füllt — `contract_text_kinds`, `holiday_session_types`, `holiday_modules`,
`holiday_module_prices`, `health_traits`, `health_trait_values`. Der nächste Lauf stirbt dann an
`fk_contract_texts_kind` statt an der Mutation, und das sieht aus wie ein Fund. Gemessen: dieselbe
Zeile ohne `sharepoint_libraries` — die Liste aus `tests/conftest.py` — lässt alle sechs stehen
(`kinds=14, modules=4, types=2`). Vier Messungen dieses Laufs waren dadurch wertlos und wurden
wiederholt.
