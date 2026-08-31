# Prüfbericht: Routen der Sofortzahlung

Zwei Routen in `app/routers/payments.py`, 14 Tests in `tests/test_payments.py`. **Nullpunkt grün**
(14 passed). Eine eigene `api/payments-api.md` gibt es nicht; der Auftrag ist der Abschnitt
„Sofortzahlung" in [`api/gemeinsam.md`](../api/gemeinsam.md) samt
[`hebel.md#sofortzahlung`](../soll-prozesse/hebel.md). Gemessen nach der Methode aus
`prompts/api-pruefen.md`. **17 Läufe, 16 gültige Messungen, 12 rot.**

Mitgemessen wurden die beiden Settle-Funktionen in `app/services/cleaning.py`: Sie sind die
„Bedingung des Vorgangs erneut, und zwar sperrend" aus `gemeinsam.md` und gehören damit zu dieser
Route, auch wenn sie in einer anderen Datei stehen.

## Funde

```
[PAYMENTS-R1] Klasse 8 · GET /payments
hebel.md: der Einzelnachweis trägt „Zeitpunkt, Bruttobetrag, Familie, Anlass und die Referenz".
  _cleaning_causes() löst aber nur die beiden Putzdienst-Anlässe auf. Eine Zahlung mit
  application_id oder holiday_booking_id — zwei der vier Anlässe aus _SETTLE, beide gebaut — ist
  nicht causeless, bekommt also weder „ohne Vorgang" noch ein Label: In der Zeile steht Familie
  „—" und Anlass leer. Genau das, wofür die Buchhaltung die Liste aufmacht, fehlt bei der Hälfte
  der Anlässe. Der Kommentar an der Stelle spricht von „a cause a later domain brings" — die
  beiden sind aber schon da.
Nicht gemessen, gelesen: kein Test in tests/test_payments.py erzeugt eine Zahlung dieser beiden
  Anlässe, und die beiden Tests, die den Rückruf dafür fahren, liegen in test_anmeldung.py und
  test_ferien.py und lesen die Liste nicht.
Vorschlag: zwei weitere Nachschlagen wie _cleaning_causes, je über children.family_id
  (applications.child_id, holiday_bookings.child_id), plus ein Test je Anlass auf der Liste.
```

```
[PAYMENTS-R2] Klasse 3 · GET /payments, tests/test_payments.py:602
test_the_proof_is_empty_outside_its_period sichert `assert "0,00 €" in response.text` zu. Die
  Summe einer Zahlung über 50,00 € enthält diese Zeichenfolge ebenfalls — jede Summe, die auf
  „0,00 €" endet, hält die Zusicherung. Der Test prüft damit nicht, dass die Liste leer ist.
Gemessen: beide `where`-Klauseln des Zeitraums aus der Query entfernt — die Zahlung von heute
  steht dann in der Liste für gestern und in ihrer Summe, tests/test_payments.py bleibt grün
  (14 passed).
Vorschlag: auf `>Summe</td><td class="amount">0,00 €` oder auf „0 Zahlungen" zusichern.
```

```
[PAYMENTS-R3] Klasse 4 · POST /payments/callback
Der Docstring schreibt die Regel aus: „Any *other* integrity error is a real one and goes out as a
  5xx, so that the retry can finish what this one could not." Sie hängt an der einen Zeile
  `if _REFERENCE_KEY not in str(exc.orig): raise` und an keinem Constraint.
Gemessen: die Zeile entfernt, also jeder IntegrityError als „known" beantwortet —
  tests/test_payments.py bleibt grün (14 passed). Damit bekäme Stripe für eine Zustellung, die an
  einem anderen Schlüssel scheitert (etwa uq_cleaning_slot_buyouts bei zwei gleichzeitigen
  Rückrufen auf denselben Termin), ein 2xx: Es wird nicht wiederholt, und der bezahlte Vorgang
  entsteht nie — ohne Zeile, ohne Aufgabe, ohne Spur.
Vorschlag: ein Test, der einen anderen Integritätsfehler auslöst und ein 5xx verlangt.
```

```
[PAYMENTS-R4] Klasse 4 · GET /payments
`Payment.status == "confirmed"` ist der Filter, der die Liste zum Nachweis der *bestätigten*
  Zahlungen macht; `ck_payments_status` lässt daneben `open` zu.
Gemessen: Filter entfernt, tests/test_payments.py bleibt grün (14 passed). Kein Test legt eine
  offene Zahlung an, also hält nichts die Grenze — eine offene Zahlung liefe in der Liste und in
  ihrer Summe mit, und die Summe ist das, was die Buchhaltung gegen die Sammelgutschrift hält.
Vorschlag: eine Zahlung mit status="open" anlegen und zusichern, dass sie nicht erscheint.
```

```
[PAYMENTS-R5] Klasse 4 · app/services/cleaning.py, settle_buyout()
gemeinsam.md verlangt „Sie prüft die Bedingung des Vorgangs erneut, und zwar sperrend", und der
  Docstring nennt den Grund: ohne den Vorschuss-Lock kommen zwei gleichzeitig eröffnete Sitzungen
  beide durch, weil cleaning_buyouts bewusst keinen eindeutigen Schlüssel trägt.
Gemessen: `pg_advisory_xact_lock` entfernt, tests/test_payments.py bleibt grün (14 passed) — was
  zu erwarten war, weil eine Sperre nur unter Nebenläufigkeit sichtbar wird. Der Fund ist nicht
  die grüne Messung, sondern dass die einzige Regel dieser Route ohne Constraint und ohne Test
  dasteht: Fällt die Zeile bei einem Umbau, meldet nichts es.
Vorschlag: ein Test, der zwei Rückrufe gleichzeitig zustellt und genau einen Kauf verlangt.
```

## Angesehen, nicht als Fund gewertet

- **Die Signatur, das ganze Zugangsrecht dieser Route (Klasse 1 in ihrer einzigen Form).** Prüfung
  abgeschaltet → rot (`test_a_forged_delivery_is_refused`, und der Test zählt danach die Zeilen,
  nicht nur den Status). Zeitfenster entfernt → rot (`test_an_old_signature_is_refused`). Ein
  Rückruf ohne Kopfzeile nimmt dieselbe Tür. Ein innerhalb der fünf Minuten wiederholter Rumpf
  trägt dieselbe Sitzungs-Id und läuft in die Idempotenz.
- **Idempotenz.** Den „known"-Zweig entfernt → rot (`test_a_second_delivery_changes_nothing`, mit
  Zeilenzählung auf `payments` und `cleaning_slot_buyouts`). Die Gegenrichtung ist R3.
- **Was kein Ereignis ist.** Ereignistyp-Filter entfernt → rot; `payment_status`-Filter entfernt →
  rot (`test_an_unpaid_session_writes_nothing`). Beide antworten 2xx und schreiben nichts, wie
  `gemeinsam.md` es verlangt — ein 4xx brächte Stripe drei Tage lang wieder.
- **Zahlung ohne Vorgang plus Aufgabe, in einer Transaktion.** `SyncTask` nicht mehr angelegt → rot
  (`test_more_than_is_open_leaves_the_payment_without_a_cause`, prüft Ziel-Code und Betragstext).
  Die Marke „ohne Vorgang" in der Liste → rot (P12).
- **Die Bedingung erneut geprüft.** Die Frist des Terminfreikaufs entfernt → rot
  (`test_a_date_inside_its_last_three_days_is_not_bought_free`); die Mengenprüfung des
  Jahresfreikaufs entfernt → rot. Nur die Sperre daneben ist ungedeckt, das ist R5.
- **Der Rollenzugang der Liste.** Um `secretariat` erweitert → rot
  (`test_the_office_does_not_see_the_proof`). Listenroute ohne Ownership-Check, nie über den
  OTP-Pfad — so verlangt es `gemeinsam.md`, und `require_role` schließt den Elternteil ohne Rolle
  bauartbedingt aus.
- **Der einschließende Endtag.** `end + 1 Tag` auf `end` gekürzt → rot: der Test fragt
  `start=heute&end=heute` und liest die Referenz der Zahlung von heute.
- **Klasse 6, beide Richtungen.** Der Rückruf schreibt Zahlung und Vorgang in *einer* Transaktion
  (`transaction(_ACTOR)` um `_record`), und die Mail läuft erst hinter dem `async with` — eine Mail
  bei zurückgerollter Transaktion ist bauartbedingt ausgeschlossen. Die Gegenrichtung, Transaktion
  steht und Mail scheitert, fängt `send_tracked()` ab, das laut `README.md` nie wirft.
- **Klasse 7 entfällt**, die Domäne hat keinen Lauf: `gemeinsam.md` schreibt ausdrücklich aus, dass
  kein eigener Abgleich-Lauf gebaut wird, solange Stripe selbst wiederholt.
- **`except KeyError, ValueError:` in `app/services/cleaning.py`.** Kein Syntaxfehler, sondern
  PEP 758 in Python 3.14 — der Interpreter, gegen den dieses Repo gelockt ist.
- **Der zweite Rückruf auf denselben Termin.** `settle_slot_buyout` liest die vorhandene Zeile und
  gibt `None` zurück, bevor der eindeutige Schlüssel greifen kann: die zweite Zahlung wird eine ohne
  Vorgang samt Aufgabe, wie `gemeinsam.md` es für „Bedingung trägt nicht mehr" verlangt.
- **Ein Lauf war keine Messung.** Der erste Versuch am Rollenzugang der Liste ersetzte
  `require_role(...)` durch ein nicht importiertes `get_current_user` und scheiterte beim
  Einsammeln; wiederholt als P9b, dann rot.
