# Prüfbericht: Routen der Domäne stammdaten

Gegen `app/routers/stammdaten.py` (3259 Zeilen, 39 Routen) und `tests/test_stammdaten.py`
(47 Tests). Nullpunkt: 47 grün. Arbeitsbaum `wbp-stammdaten` mit eigener Datenbank.

## Funde

```
[STAMMDATEN-R1] Klasse 1 · PUT /persons/{person_id}/email + POST /persons/{person_id}/email/confirmation
Plan: „die eigene Person und die Personen der eigenen Kinder". `_reach_person` lässt
jede Person zu, die in einer erreichbaren Familie steht — also auch die zweite
sorgeberechtigte Person. Wer mit ihr in Familie A steht, setzt deren `persons.email`
auf die eigene Adresse, löst den Code an der eigenen Adresse ein, und `scope_for`
gibt danach **alle** Familien dieser Person frei — auch Familie B, die er nie erreichte.
Gemessen: die Route umgekehrt *enger* gemacht (404, sobald `person_id != acting_as`) →
47 grün. Kein Test sieht die weitere Reichweite, in keine der beiden Richtungen.
Vorschlag: beide Routen auf `acting_as` und die `person_id` der Kinder der eigenen
Familien einschränken, dazu ein Test mit der Person der zweiten Sorgeberechtigten.
```

```
[STAMMDATEN-R2] Klasse 1 · PUT /persons/{person_id}/address (`also_for_children`)
Das Häkchen zieht die Kinder **aller** Familien der Person mit
(`families_of_person`), nicht die der erreichbaren. `user.families` lässt eine
`blocked`-Sorgeberechtigung heraus, `family_guardians` trägt sie weiter — ein
gesperrter Elternteil ändert damit die Anschrift der Kinder einer Familie, die für
ihn leer ist, und ein `read_only`-Elternteil die einer Familie, in der er nichts darf
(die Stufenprüfung in `_reach_person` läuft nur, wenn `person_id != acting_as`).
Gemessen: die Menge für den OTP-Pfad auf `user.writable_families` geschnitten →
47 grün. Der vorhandene Test fährt eine Person mit genau einer Familie.
Vorschlag: für den OTP-Pfad gegen `user.writable_families` schneiden, dazu ein Test
mit einer zweiten, gesperrten Familie derselben Person.
```

```
[STAMMDATEN-R3] Klasse 1 · „Schulleitung nur die eigene Schulform" — von keinem Test der Suite gehalten
Acht Planzeilen tragen die Einschränkung: GET /families/{id}, GET /children/{id},
PATCH /persons/{id}, PATCH /children/{id}, PUT /children/{id}/departure, /repetition,
/enrolment, /class. Im Code steht sie (`reach_family_as_staff`, `staff_sees_child`),
im Test steht sie nirgends.
Gemessen, jeweils gegen die **ganze** Suite (alle zwanzig Dateien) und gegen deren
Nullpunkt von 2 rot / 604 grün (siehe R15), also ohne einen einzigen zusätzlichen Fehler:
- `reach_family_as_staff` nach der Existenzprüfung auf `return` gesetzt → unverändert.
  Der Hebel selbst wird von keinem Test der Suite gehalten, in keiner Domäne;
- alle sieben Aufrufe von `staff_sees_child` in diesem Router durch `pass` ersetzt →
  unverändert; die sechs Schreibrouten allein, ohne `GET /children/{id}` → ebenfalls
  unverändert. (Der Hebel selbst bleibt dabei stehen; über seine Aufrufe in
  `gesundheit.py` und `anmeldung.py` sagt die Messung nichts.)
Was die anderen Domänen prüfen, ist etwas anderes: `test_gesundheit.py` und
`test_anmeldung.py` fahren eine `school_management` **ohne** Zweig-Zuweisung und weisen
ihr eine Absage nach. Das ist die falsche Rolle, nicht die fremde Schulform — genau die
Unterscheidung, an der diese Fehlerklasse hängt.
Vorschlag: eine Schulleitung mit `EmployeeRole.school_branch_id` einer anderen
Schulform in `World`, dazu je Route ein 404 auf ein Kind bzw. eine Familie der anderen.
```

```
[STAMMDATEN-R4] Klasse 1/3 · PATCH+DELETE /families/{id}/contacts/{id}, PATCH+DELETE+PUT /families/{id}/guardians/{person_id}
Die Paarung Pfad-Familie ↔ Zeile steht in der Query (`_load_contact`,
`_load_guardianship`) und wird von keinem Test gehalten: Für die Eltern schlägt
schon `reach_family` zu, und für das Sekretariat prüft niemand nach. Eine
Schulleitung erreicht so über eine Familie ihrer Schulform den Kontakt oder die
Sorgeberechtigung einer fremden.
Gemessen: `.where(FamilyContact.family_id == family_id)` entfernt → 47 grün;
`.where(FamilyGuardian.family_id == family_id)` entfernt → 47 grün. Der Test
`test_a_contact_of_another_family_gets_404` prüft trotz seines Kommentars die
Familienreichweite und nicht die Paarung.
Vorschlag: dieselben zwei Fälle einmal als `secretariat` fahren.
```

```
[STAMMDATEN-R5] Klasse 5 · GET /employees/selectable
Plan: „jede Mitarbeiterrolle; Erziehungsberechtigte für die Wahl der bestätigenden
Person". Die Route hängt allein an `get_current_user` und prüft danach nichts.
`POST /auth/codes` antwortet auf jede Adresse gleich und `_redeem` stellt auch für
eine unbekannte Adresse eine Sitzung aus (leerer Scope) — wer irgendeine
Mailadresse besitzt, liest damit den vollständigen Mitarbeitendenbestand mit Namen,
`person_id` und Rollen. Dasselbe gilt für einen Mitarbeitenden nach seinem letzten
Arbeitstag, dessen `roles` leer sind.
Vorschlag: `require_staff(...)` **oder** `user.is_guardian and user.families` verlangen,
dazu ein Test mit einer Sitzung ohne Familien.
```

```
[STAMMDATEN-R6] Klasse 5 · GET /children/{child_id} (Lehrkraft)
Plan: „Lehrkraft nur Name, Klasse und die Alltagsangaben (`glossar.md`)". `everyday_only`
leert die Spalten von `children`, `person=people.out(...)` gibt aber ungefiltert
`AddressOut`, alle `phone_numbers` und `persons.email` des Kindes mit. Die
Wohnanschrift ist weder Name noch Klasse noch eine Alltagsangabe; der Roster, der die
Alltagssicht der Lehrkraft definiert, trägt sie bewusst nicht.
Vorschlag: für `everyday_only` ein `PersonOut` ohne Anschrift, Nummern und Mail,
dazu ein Test, der beides für `as_role("teacher")` leer erwartet.
```

```
[STAMMDATEN-R7] Klasse 3 · GET /classes/{class_id}/selectable-guardians
Plan: „Nur die Sorgeberechtigten der Kinder **dieser** Klasse, geprüft in der Query."
Der Test `test_the_selectable_guardians_are_the_ones_of_this_class` hält das nicht:
In seiner Welt ist nur ein Kind eingeschrieben, also ändert das Wegfallen der
Klassenbedingung an `["Alpha"]` nichts.
Gemessen: `.where(Child.class_id == class_id)` aus der Unterabfrage entfernt → 47 grün.
Vorschlag: ein zweites eingeschriebenes Kind in einer zweiten Klasse, dessen
Sorgeberechtigte nicht in der Antwort stehen darf.
```

```
[STAMMDATEN-R8] Klasse 8 · DELETE /children/{child_id}/departure
`drop_open_tasks(target_codes=(_IN_HOUSE,), family_id=child.family_id)` nimmt **jede**
offene in-house-Aufgabe am Familienbezug weg, nicht nur die dieses Abgangs. Gehen zwei
Kinder einer Familie und wird der Abgang des einen zurückgenommen, verschwindet der
Putzdienst-Punkt, den der Abgang des anderen — als letztes Kind — angelegt hat, und mit
ihm die offenen Termine, die neu zu besetzen sind.
Gemessen: die Zeile ganz entfernt → 47 grün; kein Test sieht die Familien-Aufgaben
dieser Route.
Vorschlag: den Familienpunkt nur streichen, wenn danach kein Kind der Familie mehr ein
Austrittsdatum trägt.
```

```
[STAMMDATEN-R9] Klasse 7 · Die vier Läufe des Plans
Der Plan nennt vier Läufe (`system:rollover` dreimal, `system:cleanup` einmal).
`app/runs.py` trägt elf Läufe, davon genau einen dieser Domäne: `login_purge`. Die
beiden Vorarbeits-Mails vom 1. Juli, **der Jahreslauf am 1. August** und die drei
Erinnerungen vom 1. September gibt es nicht, und `backlog/` hält dafür kein Ticket
(task-046 fragt nach dem *Inhalt* der dritten, nicht nach dem Lauf).
Vorschlag: entweder als drei `Run`-Zeilen bauen oder je ein Ticket in `backlog/` —
`GET /school-years/{school_year}/rollover` zeigt heute an, was nie geschieht.
```

```
[STAMMDATEN-R10] Klasse 4 · `change_log.proof_seen_at` an fünf Routen
Plan, Abschnitt „Rechtelage": „Jede dieser Routen setzt `change_log.proof_seen_at`, wo
ein Nachweis vorlag." Fünf Routen nehmen das Kennzeichen entgegen; kein Test sieht die
Spalte je an. Geprüft wird allein, dass `PUT …/access-level` ohne Nachweis 400 gibt —
nicht, dass mit Nachweis etwas in der Spur steht. Die Spur trägt kein UPDATE für die
Laufzeit-Rolle, ein fehlender Wert ist also nicht nachträglich zu heilen.
Vorschlag: ein Test, der nach `PATCH /persons/{id}` mit `proof_seen: true` die
`change_log`-Zeile liest und `proof_seen_at` nicht `NULL` erwartet.
```

```
[STAMMDATEN-R11] Klasse 8 · DELETE /families/{family_id}/guardians/{person_id}
Der Nachweis kommt hier als Query-Parameter `proof_seen_now`, an den vier
Schwesterrouten als Rumpffeld `proof_seen`. Zwei Namen und zwei Orte für dieselbe
Sache; ein Aufrufer, der `?proof_seen=true` schickt, setzt nichts und merkt es nicht.
Vorschlag: auf `proof_seen` vereinheitlichen (bei DELETE als Query-Parameter),
dazu ein Test.
```

```
[STAMMDATEN-R12] Klasse 3 · PUT /children/{child_id}/class — die zwei Bedingungen decken sich gegenseitig
Plan: „Zwei Bedingungen: das Kind ist eingeschrieben (`ck_children_class_needs_entry`)
und die Klasse trägt seine Schulart (`fk_children_class`, zusammengesetzt)."
`test_a_class_change_writes_two_tasks_and_a_refused_one_writes_none` fährt dafür
`child_b`, das **weder** eingeschrieben ist **noch** eine Schulart trägt — der
erwartete 400 kommt also aus beiden Gründen zugleich.
Gemessen: `if child.entry_date is None:` auf `False` → 47 grün (die Schulart-Prüfung
weist ab); `if child.school_branch_id != row.school_branch_id:` auf `False` → 47 grün
(die Einschreibung weist ab). Beide Regeln sind einzeln ungeprüft; belegt ist nur,
dass *irgendeine* der beiden greift.
Vorschlag: zwei Fälle statt einem — ein eingeschriebenes Kind der falschen Schulart,
und ein nicht eingeschriebenes Kind der richtigen.
```

```
[STAMMDATEN-R13] Klasse 4 · vier Regeln ohne Constraint und ohne Test
Alle vier stehen im Plan und tragen kein Constraint; die Suite hält keine von ihnen.
Gemessen, je einzeln, `tests/test_stammdaten.py` blieb bei 47 grün:
- `_is_last_child` auf `False` — „die offenen Putzdiensttermine stehen nur beim
  letzten Kind der Familie darauf" (PUT /children/{id}/departure);
- `if numbers and await _family_is_bound(...)` auf `False` in `delete_contact` —
  „nicht, wenn er die letzte tagsüber erreichbare Nummer trägt";
- die Rollenpflicht in `update_contact` auf `False` — `ck_family_contacts_role`
  greift beim PATCH nicht, weil beide Spalten NOT NULL und false sein dürfen;
- der Beschäftigungsfilter in `read_selectable` entfernt — „Nur Personen, die heute
  beschäftigt sind: wer gegangen ist, ist niemand zum Auswählen."
Vorschlag: je ein Test; der dritte ist der teuerste Fall — ein Kontakt ohne beide
Rollen bleibt als Zeile stehen und taucht in keiner Ansicht mehr auf.
```

```
[STAMMDATEN-R14] Klasse 5 · PUT /persons/{person_id}/email als Versandweg
Die Route schickt über Graph eine Mail an eine vom Aufrufer frei gewählte Adresse und
trägt — anders als `POST /auth/codes` — keines der vier Mailbudgets des Plans. Die
einzige Schranke ist die globale Notbremse von 300 Anfragen je Minute und Adresse.
Der Plan verlangt hier keines, deshalb steht das als Beobachtung und nicht als
Planabweichung; der Absenderruf der Schule hängt trotzdem daran.
Vorschlag: dasselbe Adressbudget wie am Anmeldecode anlegen — es liegt schon in
`app/routers/auth.py`.
```

```
[STAMMDATEN-R15] Klasse 7 · zwei Tests, die sieben Stunden je Woche rot sind — außerhalb dieser Domäne
`tests/test_runs.py::test_the_weekly_mail_goes_to_the_role_and_carries_only_its_own`
und `::test_the_mail_of_the_week_is_the_mark` scheitern mit `assert 0 == 1`.
Ursache: `weekly_task_mail` gibt vor Montag 07:00 Ortszeit auf (`_week_start`), die
Tests stellen die Uhr aber nicht. Gemessen am Montag, den 31.08.2026 um 01:30 CEST —
`tests/test_runs.py` allein: 2 rot / 38 grün, `outbound_emails` dabei leer, es ist also
keine liegengebliebene Marke. Jeden Montag zwischen 00:00 und 07:00 ist die Suite rot.
Der Fund gehört dem Querschnitt und steht hier, weil er den Nullpunkt jeder
Voll-Suite-Messung verschiebt: **606 Tests, 604 grün**, und die zwei sind keine
Hinterlassenschaft einer Prüfsession.
Vorschlag: `_week_start` in den Tests über einen festen Zeitpunkt fahren (monkeypatch
auf `datetime` oder ein Parameter an `weekly_task_mail`).
```

## Zahlen

- **Nullpunkt** `tests/test_stammdaten.py`: 47 grün. Ganze Suite: 606 Tests, 604 grün,
  2 rot (R15) — dieselben zwei vor und nach jeder Messung.
- **37 Messungen** ausgeführt (ein Patch-Versuch schlug fehl und wurde wiederholt),
  davon **4 verworfen**: sie liefen mit `-x` gegen die ganze Suite und brachen am
  vorbestehenden Fehler aus R15 ab, statt an der Mutation. Drei Läufe ohne `-x` haben
  sie ersetzt.
- Von den **33 gültigen**: **16 wurden rot** — die Regel ist geprüft —, **17 blieben
  grün**, und jede von ihnen steht als Fund oben.
- **39 Routen** im Router, **39 Planzeilen** außerhalb des Zugangs — Methode und Pfad
  stimmen durchweg überein.

## Angesehen, nicht als Fund gewertet

- **Die Mail nach dem Rollback.** `TransactionRoute` committet **vor** den
  Hintergrundaufgaben, ein Handler, der wirft, kommt dort nie an — eine Mail zu einer
  zurückgerollten Transaktion ist strukturell ausgeschlossen. `set_departure` belegt
  beide Richtungen (Mutation der Datumsprüfung → rot, `mailer.sent == []`).
- **Klasse 3 im Übrigen.** Jede Listen-Zusicherung der Datei läuft gegen eine nicht
  leere Liste oder indiziert `[0]`: Rollover, Placement, Roster, `selectable`,
  `deletable-accounts`, Abgangsliste, `selectable-guardians`. Kein zweiter Fall wie R7.
- **Die enge Rolle.** Nur `GET /families/{id}` und `GET /children/{id}` lesen
  `denomination`/`congregation`, beide unter `backend_sensitive` und beide vom Plan
  benannt; `PATCH /children/{id}` und `PATCH /persons/{id}/guardian` schreiben sie mit
  der Laufzeit-Rolle, was der Plan ausdrücklich verlangt. Keine Route dieser Domäne
  berührt `sepa_mandates`. Keine Antwort trägt eine enge Spalte, die der Plan nicht nennt.
- **`GET /classes/{class_id}/roster` ohne Klassenbindung.** Der Plan schreibt
  „unbeschränkt für Lehrkräfte" aus und begründet es („neue Einsicht entsteht durch die
  Liste nicht"). Keine Abweichung.
- **Methode, Pfad und Rolle über alle 39 Routen.** Gegen die Plantabellen abgeglichen;
  die 45 Routen des Plans sind diese 39 plus die 6 des Zugangs, die `auth.py` trägt.
  Außer R5 und R11 keine Abweichung in Methode, Pfad oder „Wer darf".
- **`_reach_person` ist strenger als nötig**, wenn eine Person über mehrere Familien
  erreichbar ist: Eine einzige `read_only`-Familie darunter weist den Schreibversuch ab,
  auch wenn eine andere `full` ist. Falsch ist es nicht.
- **Zwei Kleinigkeiten ohne Gewicht:** `_ = ending` in `read_rollover` ist eine tote
  Zuweisung; ein unbekannter `role_code` an `GET /employees/selectable` gibt eine leere
  Liste statt der 400, die `_lookup_id` sonst überall gibt.
