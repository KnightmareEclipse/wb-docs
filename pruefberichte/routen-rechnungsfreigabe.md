# Prüfbericht: Routen der Rechnungsfreigabe

`app/routers/rechnungsfreigabe.py` (2012 Zeilen, 30 Routen) gegen
`wb-docs/api/rechnungsfreigabe-api.md` und `tests/test_rechnungsfreigabe.py` (48 Tests).
Nullpunkt: 48 passed.

## Funde

```
[RF-R1] Klasse 1 · GET /expense-claims/{id}/document, PUT …/booking, POST …/void,
        PATCH /expense-claim-items/{id}/ledger-account (und die 6 Schreibrouten der Wertelisten)
Plan: „Der Admin sieht hier nichts … Was er erbt, ist damit sein eigener Beleg."
      Alle vier hängen an `require_role(...)`, und das setzt `allowed = roles | {ADMIN_ROLE}`
      (`app/core/security.py:413`) — `admin` steht damit an jeder von ihnen. Die vier
      Routen nehmen zusätzlich keinen Ownership-Check: `book_claim`, `void_claim`,
      `correct_ledger_account` und `read_claim_document` holen den Beleg mit
      `session.get(...)` statt über `_reach_claim`, weil `accounting` ohnehin alles sieht.
Gemessen: Sonde mit einer beliebigen Entra-Id und der Rolle `admin`:
      GET /expense-claims/{id} → 404 (richtig), GET …/document → 200 (die ganze PDF samt
      Anhängen), PUT …/booking → 200. Kein Test der Datei ruft eine dieser vier als `admin`.
Vorschlag: die vier Routen an eine eigene Abhängigkeit ohne `admin` hängen und je ein Test
      mit `admin` auf `/document` und `/booking`.
```

```
[RF-R2] Klasse 1 · GET /expense-claims, GET /expense-claims/{id},
        PUT /expense-claim-items/{id}/decision (und jede Route über `_reach_item`)
Plan: „jeder Ownership-Check dieser Datei zählt über Mitarbeitende". Der Anker ist
      `_me()`, und der gibt `None` für ein Entra-Konto ohne `employees`-Zeile. In
      `_visible()` wird daraus `submitter_employee_id IS NULL`, in `_reach_item()`
      `None != None` → False. Beide Spalten werden real NULL: `fk_expense_claims_submitter`
      und `fk_expense_claim_items_approver` sind ON DELETE SET NULL, und der Lösch-Lauf
      trägt laut Plan genau vorher den Namen nach.
Gemessen: Sonde — Name nachgetragen, Mitarbeiterzeile gelöscht, dann mit einer fremden
      Entra-Id und der Rolle `staff`: der verwaiste Beleg steht in GET /expense-claims,
      GET /expense-claims/{id} → 200, und der verwaiste Teil wird über
      PUT …/decision freigegeben → 200, state `approved`.
Vorschlag: `_me()` einen fehlenden Mitarbeitereintrag mit 403 abweisen (wie
      `create_claim` es schon tut), statt `None` durch die Bedingungen laufen zu lassen.
```

```
[RF-R3] Klasse 5 · PUT …/decision, PATCH /expense-claim-items/{id}, POST …/forwarding,
        POST …/split, POST …/withdrawal, PATCH …/ledger-account, PUT …/booking, POST …/void
Plan: „Die Rolle trennt deshalb nicht Person von Person, sondern Route von Route:
      `GET /expense-claims/{id}` und `POST /expense-claims` setzen sie, die Liste, die
      Auswertungen und die Jahreszahlen nie. Ohne sie stünde eine IBAN in jeder Antwort,
      die einen Beleg streift." Genau das passiert: alle acht Schreibrouten antworten mit
      `ClaimOut` aus `_claim_out()`, und das ruft `_bank_details()` unter
      `backend_expense_bank`. Der Personenkreis wird dadurch nicht weiter — er ist
      derselbe wie bei `GET /{id}` —, die Zahl der Antworten mit IBAN aber achtmal so groß.
Gemessen: Sonde — die Antwort von PUT /expense-claim-items/{id}/decision trägt
      `third_party_iban` im Klartext.
Vorschlag: `_claim_out(session, claim, with_bank=False)` als Vorgabe und die zwei vom
      Plan genannten Routen als einzige Aufrufer mit `True`.
```

```
[RF-R4] Klasse 4 · PUT /expense-claim-items/{id}/decision
Plan: „Wer sich etwas erstatten lässt, gibt es nicht selbst frei" — die Sperre trägt
      `ck_expense_claim_items_self_approval`, und der greift nur, wenn Freigeber *und*
      Einreicher **derselben Zeile** zusammenfallen. `executive_management` entscheidet
      über den Umweg aber jeden Teil, auch den eines Belegs, den sie selbst eingereicht hat:
      `_reach_item` lässt sie an der Ownership-Bedingung vorbei, und die Zeile trägt einen
      fremden Freigeber, der CHECK schweigt.
Gemessen: Sonde — Geschäftsführung reicht `payment_route=to_me` mit `world.approver` als
      Freigeber ein und ruft dann selbst PUT …/decision → 200, state `approved`.
Vorschlag: in `_reach_item` den Umweg versagen, wo `claim.submitter_employee_id == me`
      und der Beleg `is_reimbursement` oder `travel` ist, dazu ein Test.
```

```
[RF-R5] Klasse 1 · POST /expense-claims/{id}/split
Plan: „die Führungskraft, bei der er liegt; `executive_management` (Umweg)". Die zweite
      Bedingung — der offene Teil muss **meiner** sein — steht in der Auswahl von `mine`.
Gemessen: `and (item.approver_employee_id == me or _EXECUTIVE in user.roles)` entfernt,
      48 grün. `test_a_stranger_cannot_split_a_claim_that_is_not_with_him` scheitert schon
      an `_reach_claim` (der Fremde sieht den Beleg gar nicht) und erreicht die Bedingung
      nie. Ungeprüft bleibt damit der Fall, der zählt: der **Einreicher** und jede
      Führungskraft, die weitergeleitet hat, sehen den Beleg und teilten ihn hier auf.
Vorschlag: ein Test, in dem der Einreicher seinen eigenen, bei einer Führungskraft
      liegenden Beleg aufzuteilen versucht, und einer mit der weitergeleiteten Zeile.
```

```
[RF-R6] Klasse 8 · PUT …/decision, POST /expense-claims, POST …/forwarding, POST …/split,
        POST …/void
Plan: drei Teams-Pings mit Auslöser je Route, dazu drei Regeln, „die die Route mitprüft"
      (Meldegrenze am ganzen Beleg, Wert zur Freigabe, kein Ping an den Auslöser).
      Gebaut ist keiner: `grep -rniE "teams|ping" app` findet allein den
      healthchecks.io-Ping der Läufe. `_THRESHOLD_CODE` steht in Zeile 77 des Routers und
      wird nirgends gelesen — die Konstante ist der Rest des ungebauten Pings.
Vorschlag: entweder die Pings bauen oder Plan und Konstante streichen; eine tote
      Konstante mit dem Namen einer Meldegrenze liest sich beim nächsten Bau als gebaut.
```
```
[RF-R7] Klasse 4 · PUT /expense-claim-items/{id}/decision
Plan: „Nur solange nichts entschieden ist (`ck_expense_claim_items_decision`)." Der CHECK
      zählt `num_nonnulls(approved_at, rejected_at, forwarded_at) <= 1` und sieht damit
      **Freigabe auf Freigabe nicht**: `approved_at` wird überschrieben, und mit ihm
      Projekt, Konto, „im Budget" und Notiz. Die Route hat dafür ihre eigene Sperre.
Gemessen: die Sperre neutralisiert, 48 grün. Kein Test entscheidet zweimal.
Vorschlag: ein Test, der denselben Teil ein zweites Mal freigibt und 400 erwartet — sonst
      steht neben `PATCH …/{id}` (Grund Pflicht) ein zweiter Weg, das Projekt einer
      getroffenen Entscheidung ohne Begründung auszutauschen.
```

```
[RF-R8] Klasse 4 · alle Routen über `_still_running`
Plan: „ein zurückgezogener Beleg lebt nicht wieder auf", „danach führt kein Weg zurück",
      „Ein stornierter Beleg lebt nicht wieder auf". Getragen wird das von `_still_running`,
      und `ck_expense_claims_end` hält davon nur, dass Rückzug, Buchung und Storno sich
      nicht überlagern — Entscheiden, Korrigieren, Weiterleiten und Aufteilen an einem
      geschlossenen Beleg fängt es nicht.
Gemessen: `_still_running` auf `if False:` gesetzt, 48 grün. Der vorhandene Test auf die
      zweite Buchung läuft in die Zustandsprüfung von `book_claim` und nicht hierher.
Vorschlag: je ein Test, der einen zurückgezogenen und einen gebuchten Beleg zu
      entscheiden versucht.
```

```
[RF-R9] Klasse 4 · POST /expense-claims/{id}/split
Plan: „**Nicht für einen Beleg, der schon über eine Aufteilungsvorlage läuft** — dort steht
      der Schlüssel und der Umlauf ist entfallen." Kein Constraint trägt das.
Gemessen: `if claim.claim_template_id is not None and len(_live(items)) > 1` entfernt,
      48 grün.
Vorschlag: ein Test, der einen über eine Aufteilungsvorlage eingereichten Beleg aufteilt.
```

```
[RF-R10] Klasse 4 · POST /expense-claims/{id}/split
Plan: „Die Sperre gegen die eigene Freigabe gilt auch hier." Am Weiterleiten ist sie
      geprüft (`test_forwarding_keeps_the_lock_against_ones_own_approval`), am Aufteilen
      nicht — dabei legt genau diese Route je Teil eine neue Zeile mit einem frei
      gewählten Freigeber an.
Gemessen: die Prüfung je Teil entfernt, 48 grün. `ck_expense_claim_items_self_approval`
      fängt den Fall danach, aber als 500 statt als 400.
Vorschlag: ein Test, der einen Teil dem Einreicher zuweist.
```

```
[RF-R11] Klasse 4 · POST /expense-claims
Plan: „Stilllegen statt löschen: nimmt den Wert aus jeder Auswahl." Die Auswahlroute
      filtert `is_active`, das Einreichen prüft es selbst — ohne diese Prüfung nähme die
      Route einen stillgelegten Zahlweg weiter an, weil `fk_expense_claims_route` nur Code
      und Merkmale hält, nicht `is_active`.
Gemessen: `or not route.is_active` entfernt, 48 grün. Der Test, der einen Zahlweg
      stilllegt, reicht danach nichts damit ein.
Vorschlag: den vorhandenen Test um ein Einreichen mit dem stillgelegten Code erweitern.
```

```
[RF-R12] Klasse 4 · POST /expense-claims (travel)
Plan: bei `travel` entweder Ticketbetrag oder Strecke; der Betrag folgt daraus
      (`ck_travel_details_amount`). Dass **genau eines** von beidem kommt, prüft nur die
      Route.
Gemessen: `if (ticket is None) == (distance is None)` auf `if False:` gesetzt, 48 grün.
      Kein Test schickt beide oder keines.
Vorschlag: zwei Zeilen im vorhandenen Fahrt-Test, beide 400.
```

```
[RF-R13] Klasse 4 · GET /expense-claims/{id} (Dublettenhinweis)
Plan: „Empfänger und Betrag eines anderen Belegs **innerhalb von 30 Tagen**", und der
      Hinweis schweigt zu einem zurückgezogenen Beleg (`withdrawn_at IS NULL` im select).
Gemessen: zwei Messungen, beide grün — das 30-Tage-Fenster entfernt: 48 grün; den
      `withdrawn_at`-Filter entfernt: 48 grün. Beide Belege des vorhandenen Tests entstehen
      im selben Augenblick, also trifft er das Fenster nie.
Vorschlag: ein zweiter Beleg mit `created_at` vor 40 Tagen (kein Hinweis) und einer, der
      zurückgezogen ist (kein Hinweis).
```

```
[RF-R14] Klasse 3 · POST /expense-claims mit Aufteilungsvorlage
Plan: „Was beim Runden übrig bleibt, fällt auf den größten Anteil."
Gemessen: `shares.index(max(shares))` auf `min(shares)` gedreht, 48 grün. Der Test heißt
      „the rounding remainder falls on the biggest share" und sichert allein
      `sum(parts) == 1001` zu — die Summe stimmt in beiden Richtungen.
Vorschlag: die Zusicherung auf die Verteilung selbst setzen (`[668, 333]`), nicht auf ihre
      Summe.
```

```
[RF-R15] Klasse 4 · `_live()`, also jede Route, die den Zustand rechnet
Plan: „die alte bekommt `forwarded_at` und bleibt als Spur stehen" — eine weitergeleitete
      Zeile entscheidet nichts, weder für den Zustand noch für die Liegezeit noch für die
      Summen der Auswertung.
Gemessen: `_live()` auf `list(items)` gesetzt, 48 grün.
Vorschlag: im Weiterleitungstest den neuen Teil freigeben und `state == "approved"`
      zusichern — mit der Spur in `_live` bliebe der Beleg offen.
```

```
[RF-R16] Klasse 4 · PATCH /expense-claim-items/{id}
Plan: „A drawn number belongs to an approved claim; the correction reopens it" — die
      Belegnummer fällt weg, wenn eine Korrektur den Betrag ändert. Kein Constraint.
Gemessen: `claim.claim_number = None` durch `pass` ersetzt, 48 grün.
Vorschlag: im Korrekturtest nach der Freigabe korrigieren und `claim_number is None`
      zusichern.
```

```
[RF-R17] Klasse 4 · POST /claim-templates, PUT /claim-templates/{id}
Plan: „je Vorlage steht ein Projekt höchstens einmal (`uq_claim_template_shares`)". Die
      Route weist es mit 400 ab, damit der Schlüssel nicht als 500 zurückkommt.
Gemessen: die Prüfung entfernt, 48 grün.
Vorschlag: ein Test mit zweimal demselben Projekt in einer Vorlage.
```

```
[RF-R18] Klasse 4 · PATCH /expense-claim-items/{id}
Plan: die Korrektur gehört der Führungskraft, bei der der Teil liegt — eine
      weitergeleitete Zeile ist eine Spur und wird nicht mehr korrigiert.
Gemessen: `if item.forwarded_at is not None` neutralisiert, 48 grün.
Vorschlag: den Weiterleitungstest um eine Korrektur der alten Zeile erweitern (400).
```

```
[RF-R19] Klasse 4 · POST /expense-claims (invoice)
Plan: „Bei `claim_type = 'invoice'` sind Empfänger, Betrag, Zweck, Zahlweg und mindestens
      ein Anhang Pflicht." Der Anhang ist geprüft; Empfänger und Betrag nicht.
Gemessen: `if body.payee_id is None or body.amount_cents is None` neutralisiert, 48 grün.
      `amount_cents` ist NOT NULL, der Fall käme also als 500 statt als 400 zurück.
Vorschlag: eine Zeile im vorhandenen Test, Rechnung ohne `payee_id`, 400.
```

```
[RF-R20] Klasse 3 · GET /expense-claims, GET /expense-claims/{id}
Plan: „ob die Führungskraft, bei der sie liegt, **ausgeschieden** ist
      (`employees.last_working_day`)" — ausgeschieden heißt: der letzte Arbeitstag liegt
      zurück, nicht bloß, dass einer eingetragen ist.
Gemessen: `.where(Employee.last_working_day < today)` entfernt, 48 grün. Der Test setzt
      nur den Fall „gestern gegangen" und sichert `True` zu; die Gegenrichtung — ein
      eingetragener Austritt in der Zukunft — hat keine Zusicherung.
Vorschlag: eine zweite Führungskraft mit `last_working_day` in der Zukunft, `False`.
```

## Angesehen, nicht als Fund gewertet

- **Die Dateien gehen vor den Zeilen hoch** (`create_claim`). Steht so im Plan („Die Reihenfolge
  ist damit festgelegt … das ist der kleinere Schaden"), und jede Prüfung, die 400 gibt, liegt
  davor — auch `configured_value`, das ohne eingetragenen Kilometersatz wirft. Es bleibt keine
  Datei ohne Zeile zurück, außer die Transaktion bricht nach dem Schreiben ab.
- **`PUT /claim-templates/{id}` prüft die Rolle gegen die Anteilszahl *nach* der Änderung.** Damit
  kann die Buchhaltung eine Aufteilungsvorlage auf einen Anteil zurückstutzen. Der Plan schreibt
  genau das aus („nach der Zahl der Anteile **nach** der Änderung"), also kein Fund.
- **`book_claim`, `void_claim` und `correct_ledger_account` holen den Beleg ohne `_reach_claim`.**
  `accounting` sieht ohnehin jeden Beleg; die Lücke steckt allein in der Rolle und steht in
  [RF-R1].
- **`executive_management` entscheidet über jeden Teil.** Der Umweg dieser Domäne, ausdrücklich so
  geplant. Nur der Selbstfall ist einer, und der steht in [RF-R4].
- **30 Routen, Methode und Pfad decken sich mit den sechs Plantabellen**, einschließlich der
  Gegenprobe des Plans („Es gibt 30 Routen"). `/expense-claims/travel-suggestions` und
  `/expense-claims/statistics` sind vor `/expense-claims/{expense_claim_id}` deklariert, keine
  Verschattung.
- **Keine Läufe, keine `sync_tasks`-Zeile, kein `payments`-Bezug** — der Plan sagt für alle drei
  „keiner", und der Router hält es.
- **`GET /expense-claims` ohne Bankverbindung** — geprüft und gehalten
  (`test_the_iban_stands_in_the_single_claim_and_never_in_the_list`).
- **Die Belegnummer unter `pg_advisory_xact_lock(calendar_year)`** — die Sperre steht, wie der Plan
  sie verlangt. Ihre Wirkung bei zwei gleichzeitigen Freigaben ist nicht gemessen; das ginge nur
  mit zwei Verbindungen und ist keine Lücke im Code.

## Die Messungen

37 Sicherungen einzeln herausgenommen, je mit `build test` davor und `git checkout -- app/`
danach. **21 wurden rot**, 16 blieben grün — jede grüne steht oben als Fund.

Rot und damit geprüft: die Sichtbarkeitsbedingung der Liste, `_reach_claim`, `_reach_item`,
der Einreicher am Rückzug, „nur die eigenen Strecken", die Auswertung über die eigene Menge,
der Anhang folgt seinem Beleg, die Sperre gegen die eigene Freigabe beim Einreichen und beim
Weiterleiten, „eine Rechnung braucht eine Datei", die Rolle nach Anteilszahl, die Summe der
Anteile, die Summe der Teilbeträge, zwei Projekte je Aufteilung, Freigabe braucht ein Projekt,
Ablehnung braucht einen Grund, Bankdaten nur beim passenden Zahlweg, das Konto erst nach der
Freigabe, Buchen nur bei vollständiger Freigabe, kein Dokument für abgelehnt/storniert/
zurückgezogen, keine Zusammenführung eines Empfängers in sich selbst.

Sechs davon werden rot, weil ein CHECK der Datenbank greift und die Antwort 500 statt 400
wird — der Test sieht es, weil er auf 400 zusichert.

Vier Sonden liefen zusätzlich, jede als Wegwerf-Testdatei im Arbeitsbaum, danach gelöscht:
sie belegen RF-R1 bis RF-R4 als beobachtetes Verhalten und nicht als Lesart.
