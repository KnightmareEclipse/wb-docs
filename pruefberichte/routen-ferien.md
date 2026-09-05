Stand: c4ef05a, Nullpunkt: 56 Tests grün

# Routen-Prüflauf Ferien

Geprüft: `app/routers/ferien.py` (1803 Zeilen, 19 Routen), `app/services/ferien.py` und
`tests/test_ferien.py` gegen `api/ferien-api.md`, `soll-prozesse/10-ferienprogramm.md` und
`soll-prozesse/hebel.md`.

**40 Sicherungen herausgenommen, 29 wurden rot, 11 blieben grün.** Jede Messung einzeln: Bedingung
entfernt oder umgedreht, `--profile tools build test`, `pytest tests/test_ferien.py`, danach
`git checkout -- app/` und die personenbezogenen Tabellen geräumt. Alle 19 Routen tragen einen Test;
**8 davon tragen einen Test auf die fremde Kennung oder das fremde Programm**, nicht auf die falsche
Rolle.

## Funde

[FERIEN-R1] Klasse 8 · POST /holiday/bookings/{id}/cancellation-declaration erreicht fremde Programme
Plan: „`secretariat`, **die anbietende Rolle** (Umweg)"; Block 10 „Sonderfälle": „Sekretariat und
Hortleitung buchen, stornieren und setzen jedes Datum stellvertretend". Der Router nimmt
`require_staff(user, _SECRETARIAT, _DAY_CARE, _DOMESTIC)` — beide anbietenden Rollen fest verdrahtet,
ohne `holiday_programmes.offering_role_id` zu lesen. Die Hauswirtschaftsleitung erklärt damit Stornos
in den Programmen der Hortleitung, legt dort die Aufgabe an und löst die Mail aus. Die Nachbarroute
`record_cancellation` macht es richtig
(`require_staff(user, _SECRETARIAT, await _offering_code(session, programme))`), und `_programme_of`
steht in `declare_cancellation` schon zur Verfügung.
Gemessen: `rec_role` — dieselbe Zeile in `record_cancellation` auf die zwei festen Rollen umgestellt,
`test_the_other_offering_role_enters_no_cancellation` wird rot. Für `declare_cancellation` gibt es
keinen solchen Test.
Vorschlag: dieselbe Form wie in `record_cancellation`, dazu ein Test mit der fremden anbietenden Rolle.

[FERIEN-R2] Klasse 8 · PUT /children/{child_id}/holiday-care-notes/{holiday_programme_id}
Plan: „`secretariat`, die anbietende Rolle". Der Router nimmt wieder beide fest
(`require_staff(user, _SECRETARIAT, _DAY_CARE, _DOMESTIC)`), obwohl das Programm im Pfad steht und
die anbietende Rolle daraus abzulesen wäre — die Route lädt es zwei Zeilen später ohnehin
(`session.get(HolidayProgramme, holiday_programme_id)`).
Vorschlag: `_offering_code` über das Programm des Pfades, wie in `record_cancellation`.

[FERIEN-R3] Klasse 5 · POST /holiday/sessions/{id}/cancellation trägt keine geprüfte Zugangssicherung
Die Route storniert **alle** Buchungen eines Termins, erzeugt je Buchung eine Erstattungsaufgabe und
mailt allen betroffenen Familien. Beide Schranken davor sind ungeprüft:
Gemessen: `sess_guard` — `raise HTTPException(403, "The offering Stelle calls a date off")` durch
`pass` ersetzt, `tests/test_ferien.py` bleibt grün (56 passed). Ein Elternteil sagt damit einen
ganzen Termin ab.
Gemessen: `sess_role` — `require_staff(user, _SECRETARIAT, await _offering_code(session, programme))`
entfernt, ebenfalls grün. Jede Mitarbeiterrolle sagt damit jeden Termin ab.
`test_a_cancelled_date_takes_every_booking_with_it_at_no_charge` ruft nur mit der richtigen Rolle,
`test_the_participant_list_is_internal…` deckt eine andere Route.
Vorschlag: zwei Gegenproben — als Mutter 403, als fremde anbietende Rolle 403 —, beide mit der
Zusicherung, dass keine Buchung ein `cancellation_recorded_at` bekommen hat.

[FERIEN-R4] Klasse 5 · POST /holiday/bookings: die fremde `family_id` ist ungeprüft
`if body.family_id is not None and user.is_guardian: reach_family(user, body.family_id, write=True)`
ist der einzige Schutz des Wegs „unbekanntes Kind in eine vorhandene Familie" (`_join_family`).
Gemessen: Bedingung auf `if False` gesetzt, `tests/test_ferien.py` bleibt grün. Ohne sie trüge ein
Elternteil ein Kind in eine **fremde** Familie ein; `_join_family` schreibt ihm die Anschrift jener
Familie an, und `announce_holiday_bookings` schickt die Bestätigung an deren Sorgeberechtigte.
Der Nachbarweg ist geprüft (`test_a_child_of_a_foreign_family_is_not_bookable` über `child_id`,
Messung `book_own` wird rot), dieser nicht — und
`test_an_unknown_child_joins_the_family_the_school_already_has` fährt ihn mit der **eigenen**
`family_id`.
Vorschlag: derselbe Test mit `world.other_family` und einem Kind im Rumpf, 404 erwartet, dazu
`len(await _rows(Child))` unverändert.

[FERIEN-R5] Klasse 5 · POST /holiday/bookings/{id}/cancellation-declaration, der Staff-Zweig
Gemessen: `require_staff(user, _SECRETARIAT, _DAY_CARE, _DOMESTIC)` im `else`-Zweig durch `pass`
ersetzt, `tests/test_ferien.py` bleibt grün. Jede Mitarbeiterrolle — Lehrkraft, Buchhaltung,
Schulleitung — erklärte damit den Storno jeder Buchung, samt Aufgabe und Mail an die anbietende
Stelle. Die drei Nachbarrouten desselben Schnitts tragen die Gegenprobe
(`test_a_teacher_books_nothing`, `test_a_teacher_does_not_read_the_family_view`,
`test_a_teacher_writes_no_care_note`); diese ist die vierte und einzige ohne eine.
Vorschlag: dieselbe Lehrkraft-Gegenprobe, dazu R1.

[FERIEN-R6] Klasse 4 · der Kostenübernahme-Code verfällt ungeprüft
Plan und Block: „verfällt **14 Tage** nach `created_at` — die Frist ist fest und steht in keiner
Spalte". Sie hängt allein an `.where(HolidayCostCoverageCode.created_at > _now() - COVERAGE_TTL)`
in `_coverage_code`.
Gemessen: Zeile entfernt, `tests/test_ferien.py` bleibt grün.
`test_an_expired_and_unredeemed_code_drops_out_of_the_list` prüft die **Liste**, nicht das Einlösen —
ein abgelaufener Code kauft heute ungeprüft eine Ferienbuchung auf Rechnung eines Amtes.
Vorschlag: ein Test, der mit einem Code älter als `COVERAGE_TTL` bucht und 400 samt leerer
`holiday_bookings` erwartet.

[FERIEN-R7] Klasse 4 · die Programmbindung des Kostenübernahme-Codes ist ungeprüft
Plan: „Er gilt für diese eine Anmeldung", erzeugt „für eine Mailadresse **und ein Programm**".
Gemessen: `.where(HolidayCostCoverageCode.holiday_programme_id == programme_id)` in `_coverage_code`
entfernt, `tests/test_ferien.py` bleibt grün. Ein Code des einen Programms löste damit eine Buchung
im anderen ein; `fk_holiday_bookings_coverage_code` über (`holiday_cost_coverage_code_id`,
`holiday_programme_id`) fängt die Zeile zwar ab, aber als IntegrityError und damit als 500 statt
als 400.
Vorschlag: ein Test, der den Code des Wochenprogramms im Tagesprogramm einlöst.

[FERIEN-R8] Klasse 4 · die Notfallnummer der unbekannten Familie ist ungeprüft
Plan: „ohne sie weist die Route ab — ihre Pflicht greift mit der ersten Buchung"; Block 10 Z3
dasselbe. Kein Constraint trägt es, die Route hält es allein.
Gemessen: `if not any(guardian.phone for guardian in body.guardians)` auf `if False` gesetzt,
`tests/test_ferien.py` bleibt grün. `test_a_family_the_school_does_not_know_comes_into_being_with_the_payment`
reicht eine Nummer mit und prüft danach ihre Existenz — dass ihr Fehlen abgewiesen wird, prüft niemand.
Vorschlag: `_stranger_body` ohne `phone` absenden, 400 erwarten und `not checkout.sessions`.

[FERIEN-R9] Klasse 4 · „ein Absenden trägt die Termine genau eines Programms" ist ungeprüft
Plan: „Ein Absenden über zwei Programme hätte für beide keinen eindeutigen Bezug, und
`uq_holiday_care_notes` fasst genau diesen Fall nicht." Gehalten wird das allein von
`date.holiday_programme_id != programme.holiday_programme_id` in `picks_still_hold`.
Gemessen: Bedingung auf `if date is None:` verkürzt, `tests/test_ferien.py` bleibt grün. Ohne sie
entstünde ein Absenden über zwei Programme — die Anmerkung landete am Programm des Formulars, die
Buchung am Programm des Termins, und ein Kostenübernahme-Code des einen bezahlte Termine des anderen.
Vorschlag: ein Test mit `world.session` und `world.late_session` in einem Rumpf, 400 erwartet.

[FERIEN-R10] Klasse 4 · „kein Betrag in Kraft" ist ungeprüft
`_amount_of` weist ein Modul ohne geltenden `holiday_module_prices`-Satz mit 400 ab; kein Constraint
trägt das.
Gemessen: `if amount is None: raise …` durch `return amount if amount is not None else 1` ersetzt,
`tests/test_ferien.py` bleibt grün. Der Nachbarfall ist geprüft
(`test_a_booking_that_would_cost_nothing_is_refused`, Betrag 0), der leere nicht.
Vorschlag: ein Modul ohne Preiszeile buchen und 400 erwarten.

[FERIEN-R11] Klasse 8 · die Warnung bei den letzten Plätzen fehlt ganz
Block 10 („Dazu die **Warnung bei den letzten Plätzen** an die Hortleitung, nach dem gemeinsamen
Hebel") und `hebel.md` §„Warnung bei den letzten Plätzen" („es ist ein Lauf und nicht zwei", Ferien
und Akademie teilen ihn) fordern einen Lauf; `ferien-schema.sql` trägt `low_places_threshold` samt
`low_places_notice_sent_at` und nennt letztere ausdrücklich „Die Lauf-Marke dazu".
`api/ferien-api.md` §„Kein Lauf" behauptet dagegen, diese Domäne habe keinen, und zählt drei Gründe
auf, unter denen die Warnung nicht vorkommt. Der Plan weicht damit vom Block ab, und das wiegt
schwerer als eine Abweichung der Route vom Plan.
Gemessen: `grep low_places app/runs.py` ist leer; `RUNS` führt 17 Läufe, keiner davon. Die Route
schreibt die Schwelle (`_check_low_places`, Messung `low_places` wird rot), die Marke füllt niemand.
`app/models/akademie.py` trägt dieselben zwei Spalten, also fehlt der eine Lauf für beide Domänen.
Vorschlag: Der Plan zieht gegen den Block nach; bis der Lauf steht, ein Ticket statt eines stillen
Widerspruchs — der Kommentar an `SessionIn.low_places_threshold` („the run that sends it reads the
mark beside it") behauptet heute einen Lauf, den es nicht gibt.

[FERIEN-R12] Klasse 4 · zwei 400er, die heute nur ein Constraint hält
Gemessen: `days_dup` — `_check_days` (derselbe Tag zweimal an einem Termin) auf `if False` gesetzt,
grün; `uq_holiday_session_days` fängt es dann als 500 statt als 400.
Gemessen: `kind_active` — `if kind is None or not kind.is_active` in `create_session` auf `if False`
gesetzt, grün; eine unbekannte Terminart fängt `fk_holiday_sessions_type` als 500, eine **inaktive**
fängt niemand — dann entsteht ein Termin an einer Terminart, die `GET /holiday/session-types` nicht
mehr zeigt.
Vorschlag: je ein Test; der zweite ist der teurere, weil er keine Gegenprobe in der Datenbank hat.

[FERIEN-R13] Klasse 8 · das Prüfrezept selbst: das TRUNCATE in `prompts/api-pruefen.md` räumt zu viel
`TRUNCATE … contract_texts, sharepoint_libraries RESTART IDENTITY CASCADE` reißt über
`contract_text_kinds.working_library_id → sharepoint_libraries` die Werteliste `contract_text_kinds`
mit, und über `holiday_session_types.cancellation_terms_code → contract_text_kinds` auch
`holiday_session_types` und `holiday_modules`. Keine Migration legt sie danach neu an.
Gemessen: Nach dem ersten Aufruf des Befehls lief jede weitere Messung mit
`56 errors … KeyError: 'holiday_day'` — der Nullpunkt sah rot aus, ohne dass eine Mutation im Spiel
war. Erst `down -v` samt neuem `migrate` gab die 56 grünen zurück; die ganze Messreihe wurde danach
wiederholt. `tests/conftest.py` nennt `sharepoint_libraries` deshalb **nicht** in `WIPED`.
Vorschlag: im Rezept `sharepoint_libraries` aus dem TRUNCATE nehmen und Reste dieser Tabelle
einzeln `DELETE`n — ein CASCADE über sie ist in dieser Domäne nicht wiederherstellbar.

## Angesehen, nicht als Fund gewertet

- **Der Ownership-Check der Buchungsroute läuft gegen die Kinder im Rumpf**, wie der Plan ihn
  schneidet, und ist geprüft: `book_own` (bekanntes Kind) und `decl_own`, `note_own`, `fam_own`
  werden rot. Ebenso die vier Rollengatter `book_role`, `note_role`, `fam_role`, `part_own`.
- **`GET /holiday/sessions/{id}/participants` lässt `secretariat` und `day_care_staff` an jedem
  Programm vorbei an `_own_programme`.** Der Plan zählt beide ohne Einschränkung auf; die
  Hortkraft sieht damit auch die Kochwerkstatt, und ihr Gesundheits-Ausschnitt bleibt `care` — was
  der Plan so schreibt („folgt der Rolle des Aufrufers").
- **`_health_slice` prüft `user.roles` und nicht `staff_roles`**, `admin` bekommt also keinen
  Ausschnitt. Das ist `gemeinsam.md`: „Zweierlei bekommt er damit nicht … die engen Spalten."
  `health_care` wird rot, die Trennung `care`/`kitchen`/leer ist geprüft.
- **Wer beide Rollen hält (Hortleitung *und* Hauswirtschaftsleitung), bekommt `care`**, weil die
  erste Abfrage in `_health_slice` gewinnt. Konstruierter Randfall, keine Regel dagegen im Block.
- **`GET /holiday/families/{id}/bookings` prüft für Mitarbeiter nur die Existenz der Familie**, nicht
  `reach_family_as_staff`. Der Plan nennt für die drei Rollen keine Einschränkung, und ein Programm
  steht hier nicht im Pfad, an dem eine hinge.
- **Die Platzzahl wird nicht sperrend geprüft** — ausdrücklich so gewollt (Plan, Block 10 Z5).
- **`CANCELLATION_TARGETS[code]` würfe einen KeyError bei einer dritten anbietenden Rolle.**
  `_offering_role_id` lässt keine entstehen (`prog_offer` wird rot), und `offering_role_id` ist per
  Plan bewusst ohne CHECK.
- **`ModuleOut.starts_at_time`/`ends_at_time` sind `| None`, die Spalten NOT NULL.** Kosmetik im
  Antwortmodell, keine Regel.
- **`GET /holiday/programmes` öffnet ihre eigene Transaktion statt `get_db`** — sie liest nur und
  antwortet ohne Anmeldung; `TransactionRoute` hat dort nichts zu schließen.
- **Zwei Tests prüfen nur den Statuscode** (`test_a_programme_closes_exactly_once`,
  `test_a_booking_is_not_cancelled_twice`). Beide Regeln sind trotzdem gedeckt: `closed_twice` und
  `rec_twice` werden rot. Ein Zustandscheck wäre schärfer — beim zweiten würde sonst eine zweite
  Erstattungsaufgabe entstehen —, aber der Fund wäre keiner.
