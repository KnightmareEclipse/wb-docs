Stand: c4ef05a, Nullpunkt: 64 Tests grün

# Prüfbericht Routen — stammdaten

Geprüft: `app/routers/stammdaten.py` (39 Routen) gegen `tests/test_stammdaten.py` (64 Tests) und
`wb-docs/api/stammdaten-api.md`, dazu `api/gemeinsam.md` und die Blöcke 02, 03, 04, 13, 15.
Die sechs Auth-Routen des Plans liegen in `app/routers/auth.py` und gehören zum Lauf `auth`;
39 + 6 = 45, die Zahl im Kopf des Plans stimmt.

## Funde

### [STAMM-R1] Klasse 5 · `GET /employees/selectable` steht dem OTP-Pfad offen
Plan, Spalte „Wer darf": **jede Mitarbeiterrolle**. `gemeinsam.md`: „Listen- und Exportrouten kennen
keinen Ownership-Check und gehen deshalb **nie** über den OTP-Pfad … Sie stehen ausschließlich
internen Rollen offen." Die Wache der Route lautet
`if not (user.roles or (user.is_guardian and user.families))` und lässt damit jede Elternsitzung mit
mindestens einer Familie herein; zurück kommt der vollständige Mitarbeitendenbestand mit Name,
`employee_id`, `person_id` und Rollencodes. Kein Aufrufer verlangt das: Die Route gehört 12 und 15,
beides interne Vorgänge, und keine Datei unter `api/` nennt einen Elternpfad zu ihr.
Gemessen: Wache auf `if not user.roles` verengt → `test_selectable_carries_no_personnel_facts`
(Zeile 1542) wird rot mit `assert 403 == 200`. Der Test **hält die Abweichung fest, statt sie zu
finden**: Er ruft die Route ausdrücklich `as_guardian` und erwartet 200.
Vorschlag: Wache auf `user.roles` verengen, den Test auf eine Mitarbeiterrolle umstellen.

### [STAMM-R2] Klasse 4 · Die fünf Fehleingaben des Bestätigungscodes werden nie gezählt
`confirm_email` erhöht `code_row.failed_attempts`, flusht und wirft danach `HTTPException(400)`. Die
Ausnahme verlässt den Handler, `TransactionRoute.close_transaction_first` wird nie erreicht, und
`get_db()` rollt die Transaktion samt Zähler zurück — `app/db/session.py` schreibt genau das aus:
„A handler that raised never gets here — the dependency rolls its transaction back as before."
`app/routers/auth.py` löst dasselbe Problem ausdrücklich andersherum: `_redeem` gibt `None` zurück
und wirft erst außerhalb der Transaktion, mit dem Kommentar „a six-digit code whose counter never
commits falls to brute force in minutes". Der Kommentar in `stammdaten.py` behauptet dieselbe
Wirkung und hat sie nicht. Folge: `.where(LoginCode.failed_attempts < otp.MAX_FAILED_ATTEMPTS)`
greift nie, `ck_login_codes_attempts` sieht nie einen Wert über 0, und ein sechsstelliger Code steht
15 Minuten lang ohne Zählwerk — die einzige Grenze ist die Notbremse mit 300 Anfragen je Minute und
Aufrufer. Es ist die einzige Stelle dieser Domäne, an der ein Schreibvorgang seine eigene Absage
überleben muss; jede andere 4xx rollt zu Recht mit zurück.
Gemessen, zweimal. (1) `code_row.failed_attempts += 1` entfernt → 64 Tests bleiben grün: Keine
Zeile der Suite sieht den Zähler an (M06). (2) Eine Wegwerf-Sonde an das Ende von
`tests/test_stammdaten.py` gehängt — Code anfordern, einmal falsch einlösen, danach die
`login_codes`-Zeile lesen — und wieder entfernt: `AssertionError: failed_attempts=0`. Der Zähler
steht nach der 400 auf null, die Regel ist also nicht nur ungeprüft, sondern wirkungslos.
Vorschlag: Die Form aus `auth.py` übernehmen — den Fehlschlag aus dem Transaktionsblock
zurückgeben und die 400 danach werfen —, dazu der Test, den `tests/test_auth.py:207` für den
Anmeldecode schon hat.

### [STAMM-R3] Klasse 8 (Plan gegen Block) · Jede Lehrkraft druckt jede Klassenliste
Block 15 „Dateien": „Sichtbar für die Lehrkräfte **dieser Klasse**, Sekretariat und Schulleitung."
Der Plan macht daraus „**unbeschränkt** für Lehrkräfte", der Router folgt dem Plan:
`require_role("teacher", "secretariat", "school_management")` und keine Bedingung auf die Klasse —
weder `is_class_teacher` noch `_branch_allows`, die die Nachbarroute
`GET /classes/{class_id}/selectable-guardians` beide zieht. Jede Lehrkraft erreicht damit jede
Klassenliste samt Notfallnummern der Familie, Abholberechtigten, handlungsrelevantem
Gesundheitshinweis und Fotoeinverständnis.
Die Weitung ist auch nicht von den Daten erzwungen: `class_teaching_assignments`
(`schema/klassenorganisation-schema.sql`) trägt das Paar Lehrkraft ↔ Klasse je Schuljahr, und der
Index darüber ist mit genau diesem Satz begründet — „Trägt die Frage der Klassenliste: wer
unterrichtet in dieser Klasse." Der Preis, den der Plan verschweigt, ist ein anderer: Die Tabelle
hat heute keinen Schreibpfad, eine Einschränkung darauf schlösse also erst einmal jede Lehrkraft aus.
Gemessen: nicht gemessen — gelesen: `test_the_roster_shows_the_everyday_facts_and_the_photo_answer`
ruft die Route `as_role("teacher")` mit einer Entra-Kennung ohne jede Beziehung zur Klasse und
erwartet 200; die Suite hält die weite Lesart fest.
Vorschlag: Im Plan die Weitung samt ihrem Preis ausschreiben, oder die Route an
`class_teaching_assignments` binden, sobald die Tabelle gefüllt wird.

### [STAMM-R4] Klasse 8 · Eine Namensänderung erzeugt keine Nachzieh-Aufgabe
Block 02 nennt die Namensänderung als Auslöser und lässt Z3 auf Z1 **und** Z2 folgen: „Erzeugt je
betroffenem Fremdsystem eine Nachzieh-Aufgabe." Der Plan setzt das an `PATCH /persons/{person_id}`
voraus — „Bei einem Kind zieht der Admin Konto **und** Schuladresse in derselben M365-Aufgabe nach
(13)" —, der Router tut es nicht: `_carry_over` hat genau zwei Aufrufer, `set_address` und
`update_child`, und `update_person` ist keiner von beiden. Ein umbenanntes Kind bleibt damit in
ASV-BW, Optigem und M365 still falsch, und die Schuladresse, die aus dem Namen gebaut ist, dazu.
Gemessen: nicht gemessen — gelesen; die Aufrufstellen von `_carry_over` und `raise_task` im Router
sind gezählt. Eine fehlende Handlung lässt sich nicht durch Herausnehmen einer Sicherung messen.
Vorschlag: `await _carry_over(session, [person_id], "Name geändert")` ans Ende von `update_person`,
dazu ein Test in der Form von `test_changing_the_child_raises_the_three_follow_up_tasks`.

### [STAMM-R5] Klasse 8 · Anschrift und Telefonnummern: der Plan ist enger als Block 02
Plan: „die eigene Person und die Personen der Kinder der eigenen Familien" (Anschrift) bzw. „die
eigene Person, die Personen der eigenen Kinder und die eigenen Notfallkontakte" (Nummern). Block 02
„Was dabei erhoben wird": „Je Sorgeberechtigtem die eigenen Kontaktdaten: Anschrift, Telefon,
Mailadresse. Sichtbar und **änderbar** nach der Einsichtsstufe — im Normalfall also für **alle
Sorgeberechtigten** und für das Sekretariat", zweimal bestätigt: „ändern zwei dieselbe Angabe
gegensätzlich, gilt schlicht die letzte Änderung" und „Die Änderungsspur macht bei getrennten Eltern
hinterher klärbar, wer die Adresse überschrieben hat". Der Router folgt dem Block — `_reach_person`
erreicht jede Person einer erreichbaren Familie, den zweiten Sorgeberechtigten eingeschlossen —, der
Plan trägt die engere Fassung. Bei der Mailadresse geht der Router umgekehrt den engeren Weg als der
Block und begründet ihn im Code (`_reach_own_person_or_child`: die Adresse ist der Schlüssel zum
Scope); der Plan spricht diese Ausnahme nicht aus.
Gemessen: `_reach_person` auf die Planfassung verengt (jede fremde `family_guardians`-Person
abgewiesen) → 64 Tests bleiben grün. Keine Zeile der Suite entscheidet, welche der beiden Lesarten
gilt.
Vorschlag: Die Spalte „Worauf eingeschränkt" der vier Routen an 02 angleichen — oder den Router
verengen —, und je Richtung ein Test mit dem zweiten Sorgeberechtigten, wie ihn die Mailadresse hat.

### [STAMM-R6] Klasse 8 · Die Abgangsliste zeigt jede Aufgabe des Kindes, nicht die des Abgangs
Block 03 Z2: „die Abgangsliste nur die Sicht auf alle Punkte **eines Abgangs**." `_departure_out`
liest `SyncTask` über `or_(child_id == …, family_id == …)` ohne jede Bedingung auf die Ziele des
Abgangs, obwohl `withdraw_departure` mit `_DEPARTURE_TARGETS` genau diese Menge kennt. Eine
erledigte „Schulkonto anlegen"- oder „Klasse nachziehen"-Aufgabe desselben Kindes steht damit als
Abgangspunkt in der Ansicht — beim Elternteil sogar, sobald sie ein `confirmed_end_date` trüge.
Gemessen: nicht gemessen — `GET /children/{child_id}/departure` hat keinen Test (R8), jede Messung
an ihr wäre grün.
Vorschlag: Die Query auf `SyncTarget.code.in_(_DEPARTURE_TARGETS)` einschränken.

### [STAMM-R7] Klasse 6 · Der Graph-Zug der Klassenzuordnung steht vor zwei weiteren Schreibern
`set_child_class` verschiebt den Aktenordner (`files.move_to_folder`) und legt **danach** die zwei
Nachzieh-Aufgaben an. Die Richtung, die der Plan bedenkt, trägt: Scheitert der Zug, fällt die
Klassenzuordnung mit ihm zurück (`test_a_library_that_refuses_takes_the_class_change_with_it`). Die
Gegenrichtung nicht: Wirft `raise_task` — oder irgendetwas zwischen Zug und Commit —, rollt die
Datenbank zurück, während der Ordner in SharePoint schon unter der neuen Kennung liegt. Das ist
derselbe Zustand, gegen den 15 „Dateien" den Zug überhaupt verlangt, nur andersherum.
Gemessen: nicht gemessen — gelesen.
Vorschlag: Den Zug hinter die beiden `raise_task` ziehen, damit die unumkehrbare Handlung die letzte
vor dem Commit ist.

### [STAMM-R8] Klasse 3 · Drei Routen haben in keiner Testdatei des Repos einen Aufruf
`PATCH /persons/{person_id}/guardian`, `GET /children/{child_id}/departure` und
`PATCH /classes/{class_id}` kommen unter `tests/` nirgends vor (über alle Dateien geprüft, nicht nur
über `test_stammdaten.py`). Ungeprüft sind damit vier Regeln, die kein Constraint trägt: die
Freigabegrenze der Sorgeberechtigten-Angaben (`_any_release`), die Rollenfilterung der Abgangsliste,
das Verbergen des Austrittsgrunds vor den Eltern und die Schulform-Bindung von `PATCH /classes`
(`_branch_allows`).
Gemessen: M07, M10, M11, M12, M39 und M40 — jede dieser sechs Sicherungen einzeln herausgenommen,
jede Messung grün.
Vorschlag: Je Route ein Test; bei der Abgangsliste einer mit fremder Rolle und einer als Elternteil.

### [STAMM-R9] Klasse 4 · Die Nachweismarke ist nur an zwei der fünf Routen geprüft
Plan, Abschnitt „Rechtelage": „Jede dieser Routen setzt `change_log.proof_seen_at`, wo ein Nachweis
vorlag." Fünf Routen tun es. Zwei sind geprüft (`PATCH /persons/{person_id}` und
`DELETE /families/{family_id}/guardians/{person_id}`), drei nicht: `POST /families/{family_id}/guardians`,
`PATCH /families/{family_id}/guardians/{person_id}` und
`PUT /families/{family_id}/guardians/{person_id}/access-level` — bei der letzten ist der Nachweis
Pflicht, geprüft ist aber nur die 400 ohne ihn, nicht die Marke mit ihm. Die Marke lässt sich
nachträglich nicht heilen: `change_log` trägt für die Laufzeit-Rolle kein `UPDATE`.
Gemessen: `mark_proof_seen` je Route einzeln entfernt (M07 access-level, M08 add_guardian,
M09 update_guardianship) → jedes Mal 64 Tests grün.
Vorschlag: Die vorhandene `_proof_marks`-Hilfe an den drei Routen ansetzen.

### [STAMM-R10] Klasse 8 · Der Plan nennt für den Gesundheitshinweis der Klassenliste einen toten Code
Plan, Zeile zur Klassenliste: „Die Klassenliste zeigt den für `school`." `health_visibility_scopes`
trägt sechs Codes und `school` ist keiner davon: `full`, `class_lead`, `care`, `sports`, `kitchen`,
`emergency` (`value_list_seed`-Migration). Der Router liest `class_lead` und liegt damit richtig
(`grenzkarte.md`, „den alle unterrichtenden Personen sehen"); der Plan trägt einen Wert, den es
nicht gibt. Dazu: Kein Test sieht die Spalte an —
`test_the_roster_shows_the_everyday_facts_and_the_photo_answer` prüft Name, Nummer und Foto, der
Hinweis bleibt unberührt, und ein falscher Sichtkreis zeigt „—" und bleibt grün.
Gemessen: nicht gemessen — die sechs Codes sind aus der Seed-Migration abgelesen.
Vorschlag: Im Plan `school` durch `class_lead` ersetzen; im Test eine Zusicherung auf den Hinweis,
mit einer Notiz im Sichtkreis `class_lead` und einer im Sichtkreis `care`, die nicht erscheinen darf.

### [STAMM-R11] Klasse 3 · Ein Test begründet sich mit einem Constraint, den es gibt
`test_a_contact_cannot_be_patched_out_of_both_roles` schreibt aus: „`ck_family_contacts_role` does
not catch this: both columns are NOT NULL and may be false, so the row would stand." Das Gegenteil
steht im Schema: `CONSTRAINT ck_family_contacts_role CHECK (is_emergency_contact OR
is_pickup_authorised)` (`schema/stammdaten-schema.sql`). Die Prüfung in `update_contact` ist trotzdem
richtig — sie macht aus einer 500 eine 400 —, aber die Begründung des Tests führt den nächsten Leser
in die Irre: Er wird annehmen, die Datenbank halte die Regel nicht.
Gemessen: Prüfung in `update_contact` entfernt → der Test wird rot, aber mit `IntegrityError` statt
mit `assert 400`; der Constraint greift also (M19).
Vorschlag: Den Docstring auf „der Constraint greift, die Route macht daraus die richtige 400"
umschreiben.

## Angesehen, nicht als Fund gewertet

- **Die Ownership-Bedingung steht in jeder Query, in der der Plan sie verlangt.** `_load_contact` und
  `_load_guardianship` filtern auf das Paar aus Pfadfamilie und Zeile; `_reach_person`,
  `reach_family_as_staff` und `staff_sees_child` tragen die Reichweite beider Türen. Die Suite prüft
  sie durchweg mit einer **fremden Id** und nicht nur mit einer falschen Rolle — fünf Tests für den
  Elternpfad, zwei für die Schulleitung, einer für die Klassenlehrkraft. M02, M03, M04, M05, M14 und
  M15 bestätigen es: jede herausgenommene Bedingung wurde rot. **Nicht darunter ist
  `_branch_allows`** — siehe „Die zwei Zahlen".
- **`PUT /children/{child_id}/school-email` prüft `staff_sees_child` nicht** — die Route steht nur
  dem Admin offen (`require_role()`), und der ist unbeschränkt.
- **Der Jahreslauf am 1. August fehlt** (Plan, „Die vier Läufe"): `backlog/tasks/task-142` führt ihn,
  und `app/runs.py` benennt die Lücke im Kommentar. Die drei gebauten Läufe der Domäne werden in
  `tests/test_runs.py` je zweimal hintereinander gerufen und schreiben beim zweiten Mal nichts.
- **`denominations` bleibt im Seed leer** — „stays empty here on purpose" (`value_list_seed`). Die
  Art.-9-Spalte `denomination_id` ist deshalb in keinem Lauf mit einem Wert belegt; die enge Rolle
  ist über `congregation` belegt.
- **`test_selectable_can_exclude_named_roles` trägt nur verneinende Zusicherungen.** Es liefe auch
  über eine leere Liste durch — aber nicht ins Leere: Ohne den Ausschluss stünde `other_employee`
  darin, und der Test wäre rot.
- **`read_classes` filtert nicht auf die Schulform der Schulleitung.** Der Plan nennt die Route eine
  Listenroute ohne Einschränkung.
- **Die enge Rolle sitzt an beiden lesenden Routen und an keiner schreibenden.**
  `Child.denomination_id`/`congregation` und `Guardian.denomination_id` sind `deferred=True` und
  stehen in `__protected_columns__`; `_sensitive_children`/`_sensitive_guardians` sind die einzigen
  Leser und laufen in `narrow_role(NarrowRole.SENSITIVE)`. `PATCH /children/{child_id}` gibt keinen
  Rumpf zurück, genau wie der Plan es verlangt.
- **Klasse 2 trägt sonst überall.** Jede 4xx dieser Domäne rollt mit der Transaktion zurück, weil
  `TransactionRoute` nur den erfolgreichen Handler committet; die Tests, die es prüfen, lesen den
  Zustand und nicht nur den Code (`test_a_refused_departure_leaves_nothing_behind`,
  `test_a_refused_second_employee_row_leaves_no_task`, `test_a_duplicate_school_address_leaves_the_task_open`,
  `test_a_contact_cannot_be_patched_out_of_both_roles`, `test_a_class_change_writes_two_tasks_and_a_refused_one_writes_none`).
- **Zwei der gemessenen Regeln hält auch die Datenbank.** `PUT /children/{id}/departure` fällt ohne
  seine Prüfung in `ck_children_exit_after_entry` (M20), `PATCH …/contacts/{id}` in
  `ck_family_contacts_role` (M19) — die Route macht daraus die richtige 400 statt einer 500. Beim
  Abgang nennt der Plan den Constraint, beim Kontakt behauptet der Test das Gegenteil (R11).
- **Zwei 409-Wege haben keinen Test**: `POST /families/{family_id}/guardians` (`uq_family_guardians`)
  und `POST /classes` (`uq_classes_key`). Beide fangen den `IntegrityError` und antworten 409; die
  Zeile rollt mit zurück. Kein Fund, nur ungeprüft.
- **`_months_ago` in `GET /m365/deletable-accounts` ist am Monatsende nicht geprüft** — der Test
  setzt 400 Tage zurück, die Grenze bei genau sechs Monaten sieht niemand an.

## Was mir zum Urteilen fehlte

- **Ob die Weitung der Klassenliste (R3) so gewollt ist**, entscheidet der Betreiber; die Route
  ließe sich heute nicht verengen, ohne jede Lehrkraft auszusperren (`class_teaching_assignments`
  hat keinen Schreibpfad).

## Zum Prüfrezept selbst

`prompts/api-pruefen.md` gibt zum Aufräumen nach einer roten Messung
`TRUNCATE …, sharepoint_libraries RESTART IDENTITY CASCADE`. Das ist zerstörend:
`contract_text_kinds.working_library_id` zeigt auf `sharepoint_libraries`, das CASCADE räumt die
Wertelistentabelle mit und mit ihr die vierzehn gesäten Zeilen. Jeder folgende Lauf scheitert dann in
`_release()` an `fk_contract_texts_kind` — fünf Messungen sahen deshalb rot aus, ohne es zu sein, und
mussten nach einem `down -v` wiederholt werden. Gemessen: `contract_text_kinds` 14 → 0 nach dem
ersten Aufräumen, 14 nach dem Neuaufbau. Statt dessen genügt die Liste aus `tests/conftest.py` plus
`DELETE FROM sharepoint_libraries WHERE code = 'test-akte'`.

## Die zwei Zahlen dieser Domäne

39 Routen, **36 mit mindestens einem Test** (die drei ohne stehen in R8). **27 tragen im Plan eine
Einschränkung je Datensatz**; **18 davon haben einen Test mit fremder Id an einem berechtigten
Aufrufer**, neun nicht:

`POST /persons/{id}/phone-numbers`, `DELETE /phone-numbers/{id}`, `PATCH /persons/{id}/guardian`,
`POST /families/{id}/contacts`, `DELETE /children/{id}/departure`, `GET /children/{id}/departure`,
`POST /classes`, `PATCH /classes/{id}`, `GET /classes/placement`.

Bei fünf der neun greift eine Hilfe, die anderswo mit fremder Id geprüft ist (`_reach_person`,
`_reach_family_both_doors`, `staff_sees_child`). Bei vieren nicht: `PATCH /persons/{id}/guardian`
trägt seine eigene Prüfung, und die ist ungeprüft (M40 grün); und an `POST /classes`,
`PATCH /classes/{id}` und `GET /classes/placement` ist `_branch_allows` an keiner Route der Domäne
mit einer fremden Schulform gemessen — M15 nimmt beide Bedingungen zugleich heraus, und rot wird der
Test über die Klassenlehrkraft, nicht über die Schulform.

## Die Messungen

Herausgenommene Sicherungen, eine je Zeile, jede einzeln gebaut und gelaufen; **grün heißt: die Regel
ist nicht geprüft.**

| # | Herausgenommen | Ergebnis |
|---|---|---|
| M01 | `_reach_person` auf die Planfassung verengt (zweiter Sorgeberechtigter abgewiesen) | **grün** → R5 |
| M02 | `_reach_person`: die Familienprüfung des Elternpfads | rot |
| M03 | `_load_contact`: der `family_id`-Filter | rot |
| M04 | `_load_guardianship`: der `family_id`-Filter | rot |
| M05 | `_reach_own_person_or_child`: die Einschränkung auf eigene Kinder | rot |
| M06 | `confirm_email`: `failed_attempts += 1` | **grün** → R2 |
| M07 | `set_access_level`: `mark_proof_seen` | **grün** → R9 |
| M08 | `add_guardian`: `mark_proof_seen` | **grün** → R9 |
| M09 | `update_guardianship`: `mark_proof_seen` | **grün** → R9 |
| M10 | `_departure_out`: der Austrittsgrund wird den Eltern mitgegeben | **grün** → R8 |
| M11 | `_departure_out`: die Rollenfilterung der Punkte | **grün** → R8 |
| M12 | `_departure_out`: der Elternteil sieht auch offene Punkte | **grün** → R8 |
| M13 | `read_selectable`: die Wache auf den Elternpfad verengt | rot → R1 |
| M14 | `set_child_class`: `staff_sees_child` | rot |
| M15 | `read_selectable_guardians`: Schulform und Klassenlehrkraft | rot |
| M16 | `read_child`: `everyday_only` auf `False` | rot |
| M17 | `read_child`: `sees_exit` auf `True` | rot |
| M18 | `update_child`: `reach_family(write=True)` → `write=False` | rot |
| M19 | `update_contact`: beide Rollen leer abgewiesen | rot (per Constraint) |
| M20 | `set_departure`: Austritt vor Eintritt abgewiesen | rot (per Constraint) |
| M21 | `delete_phone_number`: die letzte Tagesnummer | rot |
| M22 | `delete_contact`: die letzte Tagesnummer | rot |
| M23 | `delete_guardianship`: die letzte Sorgeberechtigung | rot |
| M24 | `set_roles`: die letzte Admin-Rolle | rot |
| M25 | `add_contact`: mindestens eine der beiden Rollen | rot (per Constraint) |
| M26 | `set_access_level`: der Nachweis ist Pflicht | rot |
| M27 | `set_repetition`: nur bei eingeschriebenem Kind | rot (per Constraint) |
| M28 | `set_enrolment`: die Stufe passt zur Schulart | rot (per Constraint) |
| M29 | `set_roles`: Zweigbindung der Rolle | rot (per Constraint) |
| M30 | `set_email`: fünf je Person und Stunde | rot |
| M31 | `_carry_over`: nur für eingeschriebene Kinder | rot |
| M32 | `read_selectable`: nur heute Beschäftigte | rot |
| M33 | `read_classes`: ausgelaufene Klassen fallen heraus | rot |
| M34 | `update_child`: die Freigabegrenze der Eltern | rot |
| M35 | `read_family`: die sparsame Ansicht | rot |
| M36 | `_raise_departure_points`: Putzdiensttermine nur beim letzten Kind | rot |
| M37 | `withdraw_departure`: der Familienpunkt bleibt beim Geschwister | rot |
| M38 | `set_child_class`: das Kind ist eingeschrieben | rot (per Constraint) |
| M39 | `set_guardian_facts`: die Freigabegrenze | **grün** → R8 |
| M40 | `set_guardian_facts`: nur die eigene Person | **grün** → R8 |

Vierzig Messungen, davon **zehn grün** — zehn Regeln, die die Suite nicht abdeckt. Dazu eine
Wegwerf-Sonde für R2, die nach der Messung wieder entfernt wurde. Nicht gemessen, sondern gelesen
wurden R3, R4, R6, R7 und R10: Bei R4 und R10 fehlt eine Handlung, bei R3, R6 und R7 lässt sich
keine Sicherung herausnehmen, die es nicht gibt.

