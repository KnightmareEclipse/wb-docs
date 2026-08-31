# Routen-Prüfbericht: cleaning

`app/routers/cleaning.py` (29 Routen), `app/services/cleaning.py`, `tests/test_cleaning.py`
(113 Tests, Nullpunkt grün) gegen `wb-docs/api/putzdienst-api.md` und `gemeinsam.md`.
32 Sicherungen einzeln herausgenommen, 12 davon rot.

## Funde

[cleaning-R1] Klasse 5 · jede schreibende Elternroute der Domäne
Plan: `gemeinsam.md`, „Einsichtsstufe": „**nur lesen** sieht jede Ansicht, ruft aber keine
schreibende Route." `core/security.py` hält dafür `reach_family(user, family_id, write=True)`;
`cleaning.py` baut den Hebel in `_reach_family` und `_guardian_only` nach — ohne den
Schreib-Zweig — und liest `writable_families` nirgends. Ein Erziehungsberechtigter mit
`read_only` reserviert damit, gibt frei, kauft frei, stellt zum Tausch und kreuzt an.
Gelesen: `grep -rn "write=True" app/routers/` nennt sieben Router, `cleaning.py` nicht; kein
Test der Datei baut einen `CurrentUser` mit abweichendem `writable_families`.
Vorschlag: `_reach_family`/`_guardian_only` auf `reach_family(..., write=True)` umstellen, dazu
ein Test mit `writable_families=frozenset()` auf `POST …/reservations`.

[cleaning-R2] Klasse 5 · GET /cleaning/cycles/{year}/slots
Plan: „Erziehungsberechtigte; `secretariat`". Die Route hängt nur an `get_current_user` und
prüft auf der Mitarbeiterseite gar keine Rolle: jedes Konto mit `employees`-Zeile liest die
Terminliste des Jahres, auch eines ohne jede Rolle oder mit abgelaufenem `last_working_day`.
Die Nachbarroute `GET /cleaning/families/{id}` prüft an derselben Stelle
`_UNRESTRICTED_QUOTA_ROLES`.
Gelesen: kein Test fährt die Route mit einer fremden Mitarbeiterrolle an.
Vorschlag: den Staff-Zweig auf `_UNRESTRICTED_QUOTA_ROLES` legen, dazu ein Test mit `teacher` —
das Gegenstück zu `test_only_the_office_sees_the_allocation`.

[cleaning-R3] Klasse 4 · POST /cleaning/assignments/{assignment_id}/buyout
Plan: Z7, Freikauf eines Termins. Ein abgesagter Termin kostet nichts, also gibt es nichts
freizukaufen — die Route weist ihn ab, `settle_slot_buyout` ebenfalls. Fällt die Prüfung an der
Route weg, eröffnet sie die Zahlung trotzdem, und der Rückruf macht daraus eine Zahlung ohne
Vorgang samt Aufgabe bei der Buchhaltung: die Familie hat bezahlt.
Gemessen: `if slot.cancelled_at is not None: raise 400` auf `if False` gesetzt,
`tests/test_cleaning.py` bleibt grün (113 passed).
Vorschlag: ein Test, der einen abgesagten Termin freikaufen will und 400 sowie `till.opened == []`
erwartet.

[cleaning-R4] Klasse 4 · POST /cleaning/assignments/{assignment_id}/buyout
Plan: „höchstens einmal je Termin (`uq_cleaning_slot_buyouts`)". Die 409 der Route ist die
einzige Stelle, an der das *vor* der Zahlung auffällt; der Schlüssel greift erst im Rückruf und
macht die zweite Zahlung zu einer ohne Vorgang.
Gemessen: `if already is not None: raise 409` auf `if False` gesetzt, `tests/test_cleaning.py`
bleibt grün (113 passed).
Vorschlag: denselben Termin zweimal freikaufen und beim zweiten Mal 409 sowie `till.opened`
unverändert erwarten.

[cleaning-R5] Klasse 4 · GET /cleaning/penalties
Plan: „Jede Liste, jede Erinnerung, jede Anwesenheits- und Strafroute filtert Zuteilungen mit
Freikauf aus; das Schema trägt dafür kein Kennzeichen, es ist eine Regel der Anwendung."
Gemessen: `.where(CleaningSlotBuyout.cleaning_slot_buyout_id.is_(None))` entfernt,
`tests/test_cleaning.py` bleibt grün (113 passed). Die Nachbarbedingung derselben Query
(`penalty_waived_at is None`) wird rot.
Vorschlag: einen freigekauften, als abwesend markierten Termin anlegen und prüfen, dass er
weder in der offenen noch in der `period=`-Liste steht.

[cleaning-R6] Klasse 4 · die Terminliste per Mail (`_dates_for_mail`)
Plan: dieselbe Regel wie R5; für die Mail ist sie die teuerste — eine Familie zu einem Termin
zu bestellen, den sie bezahlt hat, ist „die eine Mail schlimmer als keine"
(`01-putzdienst.md`, Zuteilungsmail).
Gemessen: beide Filter (`cancelled_at is None`, kein Freikauf) aus `_dates_for_mail` entfernt,
`tests/test_cleaning.py` bleibt grün (113 passed).
Vorschlag: nach einem Freikauf einen zweiten Termin von Hand zuteilen und prüfen, dass die Mail
den freigekauften nicht nennt.

[cleaning-R7] Klasse 4 · GET /cleaning/families/{family_id}
Plan: der Stand der Familie, „freigekauft" als eigene Aussage je Termin.
Gemessen: `bought_free: bool = row[0] in free_of` auf `False` festgenagelt,
`tests/test_cleaning.py` bleibt grün (113 passed) — das Portal zeigt einen bezahlten Termin
als normalen, und `_bought_free()` wird für die Route nie geprüft.
Vorschlag: `test_a_family_reads_what_it_owes_and_what_it_holds` um einen freigekauften Termin
erweitern und `bought_free is True` prüfen.

[cleaning-R8] Klasse 4 · POST …/assignments, PATCH /assignments/{id}, POST …/reservations
Plan: „nicht nach `attendance_recorded_at`" (PATCH) und „an einem abgesagten Termin" nichts
(Sonderfälle). `_check_takes_a_family` trägt beide Regeln für alle drei Routen.
Gemessen: der `attendance_recorded_at`-Zweig von `_check_takes_a_family` auf `if False` gesetzt
→ grün (113 passed). Der ganze Aufruf aus `move_assignment` entfernt → grün. Der ganze Aufruf
aus `reserve_slot` entfernt → grün. Nur der Aufruf in `add_assignment` ist über
`test_a_cancelled_appointment_takes_no_family` gedeckt, und auch nur für die Absage.
Vorschlag: je einen Test „auf einen ausgewerteten Termin verschieben" und „einen abgesagten
Termin reservieren".

[cleaning-R9] Klasse 4 · PUT /cleaning/swap-offers/{offer_id}/acceptances
Plan: „nicht die fremden Termine, an denen die Familie schon steht (`schema/putzdienst-schema.sql`:
die Anwendung prüft das vor dem Ankreuzen)" — ausdrücklich ohne Constraint.
Gemessen: `if row[4] in standing: continue` aus `takeable` entfernt,
`tests/test_cleaning.py` bleibt grün (113 passed). Getestet ist nur die *Leseseite*
(`test_the_list_hides_a_date_the_family_already_stands_on`), nicht das Ankreuzen; das letzte
Netz ist dann `uq_cleaning_assignments` im Tausch, also eine 409 statt einer Absage.
Vorschlag: eine Familie auf beide Termine setzen und den Haken auf den fremden mit 400 abweisen.

[cleaning-R10] Klasse 4 · PUT /cleaning/swap-offers/{offer_id}/acceptances
Plan: das Angebot „läuft bis zur Freikauf-Frist seines eigenen Termins", und ein getauschtes ist
verbraucht.
Gemessen: `if offer.matched_at is not None: raise 400` auf `if False` → grün (113 passed);
`if slot.starts_at - BUYOUT_LEAD <= _now(): raise 400` auf `if False` → grün (113 passed).
Für `DELETE /swap-offers/{id}` ist die erste Regel getestet, für `PUT …/acceptances` keine
von beiden.
Vorschlag: nach einem vollzogenen Tausch noch einmal ankreuzen (400) und dasselbe für ein
Angebot, dessen Termin in zwei Tagen liegt.

[cleaning-R11] Klasse 4 · GET /cleaning/swap-offers
Plan: „die angebotenen Termine des laufenden Jahres" — drei Bedingungen in `_open_offers`,
keine davon mit Constraint: nicht verbraucht, Termin nicht abgesagt, Frist noch nicht erreicht.
Gemessen: alle drei einzeln entfernt (`matched_at is None`, `cancelled_at is None`,
`starts_at > now + BUYOUT_LEAD`), `tests/test_cleaning.py` bleibt jedes Mal grün (113 passed).
Vorschlag: je ein Test — ein getauschtes, ein abgesagtes und ein abgelaufenes Angebot stehen
nicht mehr in der Liste.

[cleaning-R12] Klasse 4 · PUT /cleaning/swap-offers/{offer_id}/acceptances
Plan: „akzeptieren sich **zwei** Angebote gegenseitig". Zwei Sicherungen halten das eigene
Angebot aus dem Tausch heraus: der Familienfilter in `takeable` und `row[0] != offer_id` in
`_mutual` — bei Patchwork mit zwei Familien hinter einem Login trägt nur der erste.
Gemessen: `row[2] == assignment.family_id` aus `takeable` entfernt → grün (113 passed);
`row[0] != offer_id` aus `_mutual` entfernt → grün (113 passed).
Vorschlag: ein Test, in dem eine Familie zwei Angebote stellt und sie sich nicht gegenseitig
annehmen können.

[cleaning-R13] Klasse 4 · POST /cleaning/assignments/{assignment_id}/penalty-waiver
Plan: „nur wo `no_show`".
Gemessen: `if not assignment.no_show: raise 400` auf `if False` gesetzt,
`tests/test_cleaning.py` bleibt grün (113 passed). Der Test, der die Regel im Namen trägt
(`test_a_penalty_that_does_not_exist_is_not_waived`), lässt `status_code in (400, 404)` zu und
bekommt tatsächlich 404: die Familie aus `_assign()` hat kein Kind, also weist schon
`_may_touch_family` die Schulleitung ab.
Vorschlag: die Familie aus `_absent_family_of_branch` ohne `no_show` verwenden und auf genau
400 prüfen.

[cleaning-R14] Klasse 8 · GET/POST/DELETE der Elternrouten
Plan: `GET /cleaning/families/{id}` „Erziehungsberechtigte; `secretariat`",
`DELETE /cleaning/assignments/{id}` „`secretariat`; Erziehungsberechtigte", Reservierung und
beide Freikäufe „`secretariat` (Umweg)". Der Code prüft überall `_UNRESTRICTED_QUOTA_ROLES` und
lässt damit `executive_management` mit — laut `gemeinsam.md` erbt nur `admin` ungenannt.
Gelesen: `_UNRESTRICTED_QUOTA_ROLES` ist für `PUT …/quota` richtig (dort nennt der Plan die
Rolle), wird aber für sechs weitere Routen mitbenutzt.
Vorschlag: entweder eine eigene Menge für die Elternrouten oder eine Zeile im Plan, die
`executive_management` dort nennt.

[cleaning-R15] Klasse 8 · DELETE /cleaning/assignments/{assignment_id} (Elternseite)
Plan: „nur im offenen Anmeldefenster". Geprüft wird `registration_closes_at <= _now()`, nicht
`registration_opens_at <= _now()` — vor dem Fenster wäre die Freigabe erlaubt.
Gelesen: praktisch unerreichbar, weil eine `reserved`-Zeile nur im offenen Fenster entsteht;
die Bedingung steht damit anders da, als der Plan sie schreibt.
Vorschlag: dieselbe Fensterprüfung wie in `reserve_slot` verwenden.

[cleaning-R16] Klasse 4 · die Terminart-Prüfungen
Plan: die Terminart ist eine aktive Werteliste; eine unbekannte oder doppelte ist 400.
Gemessen: „A slot type appears twice" in `_check_covers_every_type` auf `if False` → grün;
die Unbekannt-Prüfung in `buy_out_duties` ausgehängt → grün; dieselbe in `update_slot`
ausgehängt → grün (je 113 passed). Nur `POST /cycles` und `POST …/slots` haben dafür Tests.
Vorschlag: je ein Test mit doppelter Art im `POST /cycles` und unbekannter Art in
`PATCH /slots/{id}` und `POST …/buyouts`.

[cleaning-R17] Klasse 6 · POST …/buyouts und POST …/buyout
`checkout.open()` — ein HTTP-Aufruf an Stripe — läuft innerhalb der Request-Transaktion von
`get_db()`; `TransactionRoute` schließt sie erst nach dem Handler. Geschrieben wird nichts und
gesperrt auch nichts, der Preis ist eine gehaltene Verbindung über die Stripe-Runde. Genau die
Bauform, gegen die `TransactionRoute` gebaut wurde (`app/db/session.py`).
Gelesen: betrifft vermutlich jede Domäne, die eine Zahlung eröffnet — zählbar erst im
dreizehnten Lauf.
Vorschlag: die Sitzung nach dem Ende der Transaktion eröffnen oder die Stelle im Plan als
bewusst benennen.

[cleaning-R18] Klasse 8 · der Plan gegen sich selbst
`putzdienst-api.md`, Gegenprobe: „Es gibt **27 Routen**; **24** nennen eine Ablaufzeile, **3**
eine andere Stelle" — die vier Tabellen führen aber 29 Zeilen (9 + 6 + 9 + 5), und der Router
baut genau diese 29. Ebenso zeigt „**4** einen [Lauf](#die-vier-läufe)" auf einen Anker, den es
nicht gibt: der Abschnitt heißt „Die fünf Läufe" und führt fünf, `app/runs.py` registriert fünf.
Gelesen: Router und Läufe stimmen, gezählt hat sich der Plan.
Vorschlag: 27 → 29 und den Anker auf `#die-fünf-läufe`.

## Angesehen, nicht als Fund gewertet

- **Klasse 2 durchgemessen, nichts gefunden.** Wegwerf-Testdatei, danach gelöscht: ein an der
  Terminart gescheitertes `PATCH /cycles/{year}` lässt das Fenster stehen (obwohl die Route es
  vor der Prüfung am ORM-Objekt setzt), und eine mit 409 abgewiesene Reservierung schreibt keine
  Zeile. Trägt `TransactionRoute` — ein werfender Handler erreicht das `commit()` nicht.
- **Ownership der Elternseite**: fünf Bedingungen einzeln entfernt (`_reach_family`,
  `delete_assignment`, `buy_out_appointment`, `offer_swap`, `_load_own_offer`) — jedes Mal rot.
  Die Tests probieren die fremde Id, nicht die falsche Rolle.
- **Schulform der Schulleitung** (`_may_touch_family`): `return True` erzwungen → rot.
- **Freigabe-Sperre in `GET /families/{id}`** (allokierte Termine erst nach der Freigabe) → rot.
- **Freikauf-Filter in `_taken_places` und `_expected_at`** → rot; dieselbe Regel in
  Zuteilungsmail und Erinnerungen ist in `tests/test_runs.py` gedeckt.
- **`settle_buyout`/`settle_slot_buyout`** (Sperre, Alles-oder-nichts, Frist-Nachprüfung) liegen
  in dieser Domäne, ihre Tests aber in `tests/test_payments.py` — dort geprüft, hier nicht
  gemessen.
- **Die fünf Läufe** (Klasse 7): jeder trägt seine eigene Marke, und `tests/test_runs.py` prüft
  je Lauf, dass der zweite Tick nichts mehr tut; der Monatslauf nimmt die Aufgabe des Zeitraums
  als Marke, wie der Plan es sagt.
- **`GET /slots/{id}/attendance-sheet`**: `html.escape` je Name getestet, Freikauf-Ausschluss
  getestet.
- **Listenrouten hinter der Bürotür** (`/cycles/{year}/families`, `/allocation`, `/penalties`):
  kein Ownership-Check, `require_role` bzw. 403 gegen den OTP-Pfad — getestet.
