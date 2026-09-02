# Prüfbericht: die Routen des Elternbonus

Geprüft auf `origin/gesundheit-umbau` (1569109) — zehn Routen in `app/routers/elternbonus.py`,
drei Läufe in `app/services/elternbonus.py`, 49 Tests in `tests/test_elternbonus.py`.
Nullpunkt grün. 16 Sicherungen herausgenommen, 6 davon wurden rot.

## Funde

[elternbonus-R1] Klasse 8 · GET /parent-work-entries/annual-list, Lauf `parent_work_year_end`
Block 14: „drei Werte … sie ändert sie mit Gültigkeit zum 1. August, damit keine mitten im
Schuljahr greift." Gerechnet wird aber mit dem Wert von **heute**: `configured_value(session, code)`
kennt kein Datum und nimmt `valid_from <= now()` (`app/services/querschnitt.py`). Der Jahresschluss
läuft am 1. August und schließt das am 31. Juli beendete Jahr — der neue Betrag gilt zu diesem
Zeitpunkt bereits. Das abgeschlossene Schuljahr wird damit zum Satz des folgenden abgerechnet,
Monatsbetrag wie Pflichtstunden, und dieselbe Liste über `?school_year=` liefert später wieder
andere Zahlen als die Aufgabe, die die Buchhaltung bekommen hat. Es ist derselbe Fehler, gegen den
`parent_work_year_end` in der anderen Achse ausdrücklich absichert (Lauf **vor** dem Jahreslauf,
sonst 10 statt 15 Stunden) — nur nicht abgesichert.
Gelesen, nicht gemessen: es gibt keine Sicherung, die man herausnehmen könnte.
Vorschlag: `configured_value` einen Stichtag mitgeben und hier das Schuljahresende (31. Juli)
übergeben, dazu ein Test mit zwei Werten und `valid_from` am 1. August.

[elternbonus-R2] Klasse 8 · die drei Werte der Geschäftsführung
Der Plan und der Code nennen `parent_work_monthly_cents`, `parent_work_hours_primary`,
`parent_work_hours_default`; `schema/querschnitt-schema.sql` nennt an `configured_values`
`parent_bonus_monthly_cents`, `parent_bonus_required_hours_primary`,
`parent_bonus_required_hours_secondary`. Drei Namen, zweimal verschieden.
Niemand merkt das: `configured_values` wird von keiner Migration und von `app/seed.py` nur für die
zwei Putzdienst-Preise gefüllt, die drei hier tippt die Geschäftsführung über
`/configured-values` selbst ein. Trifft sie den Namen aus dem Schema, wirft `configured_value`
`RuntimeError` — die Familienansicht antwortet 500 und beide Läufe fallen jeden Tick aus.
Gelesen, nicht gemessen: das Fixture der Suite legt die Werte unter den Code-Namen an und kann den
Unterschied deshalb nicht sehen.
Vorschlag: den Kommentar in `querschnitt-schema.sql` auf die drei Namen ziehen, die der Code nimmt.

[elternbonus-R3] Klasse 2 · POST /parent-work-sessions/{id}/signups
Der Umweg des Sekretariats nimmt `person_id` aus dem Rumpf und prüft nicht, ob es die Person gibt.
Der Fremdschlüssel wirft `23503`, und die Route fängt nur `23514` und `23505` — der Rest fliegt
weiter, `app/main.py` hat keinen Handler dafür.
Gemessen (Sonde gegen die laufende App, ohne Änderung am Baum): unbekannte `person_id` → **500**;
dieselbe Sonde gegen `POST /parent-work-entries` mit unbekannter `family_id` → 404. Die
Schwesterroute hat den Riegel (`if await session.get(Family, …) is None`) samt Test
(`test_the_secretariat_logs_an_hour_for_any_family`), diese hat weder noch.
Vorschlag: `person_id` vor dem `add` gegen `persons` prüfen und wie dort mit 404 antworten, dazu
denselben Test.

[elternbonus-R4] Klasse 1 · POST /parent-work-sessions/{id}/cancellation
Plan: „nur der eigene Einsatz" — der Ausschreibende, `secretariat`, `school_management`. Die Absage
setzt `cancelled_at`, ist nicht rücknehmbar und schickt sofort an **alle Angemeldeten** eine Mail.
Gemessen: `if not _is_offerer(user, work)` samt 404 entfernt, `tests/test_elternbonus.py` bleibt
grün (49 passed). Für `PUT` gibt es den Test auf den fremden Einsatz
(`test_only_the_one_who_put_it_out_changes_it`), für die Absage keinen — dabei ist sie die
teurere der beiden Handlungen: Die Hortleitung sagt den Ausflug der Lehrkraft ab, und die Eltern
bekommen die Mail dazu.
Vorschlag: derselbe Test wie für `PUT`, mit `POST …/cancellation` als Lehrkraft auf 404.

[elternbonus-R5] Klasse 4 · die Zeitgrenze des Einsatzes, in vier Routen
Kein Test der Datei legt einen Einsatz an, der schon begonnen hat oder schon abgesagt ist — der
Fixture-Einsatz liegt immer nach `FROZEN`. Vier Regeln des Plans hängen daran, und keine trägt ein
Constraint. Vier Messungen, alle grün (je 49 passed):
- `POST …/signups`: „bis er beginnt (`400` danach)" — `work.starts_at <= _now()` entfernt.
- `DELETE …/signups/{id}`: „bis der Einsatz beginnt" — die ganze 400-Sperre entfernt.
- `PUT …/{id}`: „nicht mehr nach dem Beginn" — `work.starts_at <= _now()` entfernt.
- `PUT …/{id}`: „und nicht nach der Absage" — `work.cancelled_at is not None` entfernt. Geprüft ist
  nur, dass eine zweite **Absage** 400 gibt, nicht dass eine Änderung danach eine bekommt.
Dazu, aus demselben Loch: `GET /parent-work-sessions`, „Vergangene Einsätze fallen für die Eltern
heraus" — `.where(ParentWorkSession.starts_at >= now)` entfernt, ebenfalls grün.
Vorschlag: ein zweiter Einsatz im Fixture mit `starts_at` vor `FROZEN` und ein abgesagter dritter,
die fünf Regeln je einmal daran.

[elternbonus-R6] Klasse 1 · POST /parent-work-sessions, Zielgruppe der Schulleitung
Plan: „eine Klasse einer fremden Schulart ist für die Schulleitung nicht wählbar (`branches_of`)" —
und dasselbe gilt in `_check_audiences` für den **Zuschnitt**: eine Zeile ohne `class_id` muss die
eigene Schulart nennen, sonst spräche eine Schulleitung mit `grade_from: 7` die ganze Schule an.
Gemessen: die Bedingung des Zuschnitt-Zweigs auf `False` gesetzt, Suite bleibt grün (49 passed).
`test_school_management_names_no_class_of_the_other_branch` prüft nur den Klassen-Zweig.
Vorschlag: derselbe Test um einen Zuschnitt ohne `school_branch_id` und einen mit der fremden
Schulart erweitern, beide auf 400.

[elternbonus-R7] Klasse 4 · Lauf `parent_work_reminder`
Block 14 Z5: „Wer als voll gilt, ohne eine Stunde geleistet zu haben, bekommt sie nicht —
Elternvertreter- und Mitarbeiterfamilien."
Gemessen: `if await is_representative(...): continue` entfernt, `tests/test_runs.py` bleibt grün
(51 passed). Die Mitarbeiterfamilie hat ihren Test
(`test_a_staff_family_gets_no_reminder_without_a_single_entry`), die Elternvertreter-Familie nicht —
sie bekäme am 1. Juni eine Mahnung über 15 offene Stunden, die sie nicht leisten muss.
Vorschlag: derselbe Test noch einmal mit einer `class_representatives`-Zeile statt des `Employee`.

[elternbonus-R8] Klasse 6 · PUT /parent-work-sessions/{id}, die Platzzahl
Plan: „die Platzzahl darf nicht unter die Zahl der Angemeldeten fallen — sonst hielte der Trigger
einen Zustand, den niemand herbeigeführt hat." Genau das kann passieren: Die Route zählt die
Anmeldungen (`select(func.count())`) **ohne den Einsatz zu sperren**; der Trigger dagegen nimmt
`FOR UPDATE` auf die Einsatzzeile. Eine Anmeldung, die zwischen dem Zählen und dem `flush` der
neuen Platzzahl durchgeht, sieht die alte Kapazität und kommt durch — hinterher stehen mehr
Angemeldete als Plätze.
Gelesen, nicht gemessen: ein Rennen ist mit dieser Methode nicht messbar.
Vorschlag: den Einsatz beim Laden sperren (`_load_session` mit `with_for_update()` in dieser Route),
dann zählt die Route hinter derselben Sperre wie der Trigger.

[elternbonus-R9] Klasse 8, Plan gegen Block · POST /parent-work-entries
Block 14, „Fristen und Termine": „Für eine Familie, deren letztes Kind vorher abgeht, ist ihr
Austrittsdatum die Frist: der Stand friert ein, der Betrag steht sofort fest." Weder der Plan noch
die Route kennen diese Frist — für die Eltern gilt allein der 31. Juli
(`_school_year_window`), und eine Familie, deren letztes Kind im November geht, trägt bis Juli
weiter Stunden ein. Der Deckel (`counted_months`) begrenzt zwar den Betrag, aber nicht das
Eintragen, und der Betrag der Abgangsliste (03) steht damit nicht „sofort" fest.
Gelesen, nicht gemessen.
Vorschlag: entweder die Frist in Plan und Route nachziehen, oder im Block eine Zeile, dass der
Deckel sie ersetzt — der zweite Weg ist der billigere, aber er ist eine Entscheidung.

[elternbonus-R10] Klasse 5-nah · POST /parent-work-sessions/{id}/signups, Einsichtsstufe
Die Route verlangt `if not user.writable_families` — **irgendeine** schreibbare Familie, nicht die,
die der Einsatz anspricht. Bei Patchwork (voll in Familie A, nur lesen in Familie B) meldet sich
die Person zu einem Einsatz an, der allein B anspricht.
Gemessen als Gegenprobe: die Bedingung auf `False` gesetzt → Suite rot
(`test_a_read_only_guardian_signs_up_to_nothing`), die Sicherung als solche ist also geprüft — nur
eben grob. Kein Test hat einen Elternteil in zwei Familien.
Der Kommentar an der Stelle schreibt die Näherung aus, der Block sagt dazu nichts; ich kann nicht
entscheiden, ob sie gewollt ist. Vorschlag: die angesprochene Familie aus `session_reaches`
zurückgeben und gegen `writable_families` prüfen — oder eine Zeile im Plan, dass die Anmeldung an
der Person hängt und nicht an der Familie.

## Angesehen, nicht als Fund gewertet

- **Ein verworfener Einsatz hinterlässt keine Zeile.** `_replace_audiences` wirft die 400 erst,
  nachdem `parent_work_sessions` schon geschrieben ist. Gemessen mit einer Sonde gegen die laufende
  App: `audiences=[{}]` → 400, `parent_work_sessions` **0 → 0**. `TransactionRoute` rollt zurück,
  weil der Handler wirft. Der Test dazu prüft nur den Status — er ist nicht falsch, er belegt nur
  weniger, als sein Name verspricht.
- **`_require_offering` in der Absage.** Entfernt → Suite grün, aber die Mutation ist maskiert:
  `_is_offerer` weist dieselben Aufrufer danach ohnehin ab, nur mit 404 statt 403. Kein
  Erreichbarkeitsunterschied, deshalb kein Fund.
- **Die sechs Ownership-Sicherungen halten.** Je einzeln herausgenommen und je rot: der
  Zielgruppen-Filter des Elternteils in `_reach_session` (m10), `reach_family_as_staff` in der
  Familienansicht (m11), die fremde Anmeldung beim Abmelden (m12), `write=True` beim Eintrag (m13),
  der Schularten-Filter der Jahresliste (m14), `exists(enrolled)` in `session_reaches` (m08).
  Die Klasse, die der Prompt zuerst nennt, ist in dieser Domäne geschlossen.
- **Die Absage-Mail und die Transaktion.** `background.add_task` läuft erst, nachdem
  `TransactionRoute` committet hat; scheitert der Commit, geht keine Mail. Richtige Richtung.
- **`signup_recipients` und `guardian_recipients` lassen Personen ohne Adresse still fallen.**
  Hausweites Muster, nicht dieser Domäne anzulasten.
- **Das Sekretariat trägt eine Stunde für eine Familie ohne eingeschriebenes Kind ein.** Die Zeile
  entsteht, taucht aber in keiner Liste auf (`_eligible_families`). Folgenlos.
- **`POST /parent-work-sessions` nimmt ein `starts_at` in der Vergangenheit an.** Weder Block noch
  Plan verbieten es; für R5 braucht das Fixture es ohnehin.
- **`GET /employees/selectable`.** Der Wegfall des Elternbonus als Aufrufer steht im Docstring von
  `app/routers/stammdaten.py` und in Zeile 176 von `api/stammdaten-api.md`. Beide Seiten stimmen.
- **Zehn Routen, zehn Zeilen im Plan.** Methode, Pfad und Rolle stimmen an allen zehn überein,
  einschließlich der Vererbung von `admin`; die drei Läufe stehen mit ihrem Auslöser und ihrem
  Aktor in `app/runs.py` (`parent_work_year_end` unter `system:rollover`, vor dem Jahreslauf).
