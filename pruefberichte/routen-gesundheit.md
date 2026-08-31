# Prüfbericht: Routen der Gesundheits-Domäne

Nullpunkt `tests/test_gesundheit.py`: 17 passed. 27 Sicherungen herausgenommen, 10 wurden rot.

## Funde

```
[gesundheit-R1] Klasse 1 · POST/PUT/DELETE /children/{child_id}/health-traits[/{id}]
Plan: „eigene Familie" für alle drei Merkmals-Routen; der Router prüft sie über
`_reach_child_to_write`. Kein Test ruft eine der drei mit einem fremden Kind.
Gemessen: `_reach_child_to_write` einzeln aus `add_health_trait`, `change_health_trait` und
`drop_health_trait` entfernt — je 17 passed.
Vorschlag: je Route ein Test, in dem `as_mother` auf `world.other_child` schreibt und 404 bekommt.
```

```
[gesundheit-R2] Klasse 1 · PUT/DELETE /children/{child_id}/health-traits/{health_trait_id}
Plan: „eigene Familie". `_owned_trait` bindet die `health_trait_id` über `child_health_records`
an das Kind im Pfad — kein Test rät eine fremde `health_trait_id` unter dem eigenen `child_id`.
Gemessen: `.where(ChildHealthRecord.child_id == child_id)` aus `_owned_trait` entfernt — 17 passed.
Vorschlag: ein Test, der die Merkmals-Id von `other_child` unter dem eigenen `child_id` ändert und
löscht, beide 404.
```

```
[gesundheit-R3] Klasse 8 · Plan gegen Block · GET /children/{child_id}/health-record
Block 08 Z. 95: „**Lehrkräfte und Hort** sehen davon, was im Alltag zu tun ist — Unverträglichkeit,
Allergie, Notfallmedikation samt Erlaubnis, Zeckenentfernung"; Block 15 Z. 71 wiederholt es
(„jede andere Lehrkraft, die nur die Alltagsangaben sieht ([08])"). Der Plan gibt `teacher`
dagegen „ausschließlich `child_health_records.action_note`" und beruft sich dafür auf
`grenzkarte.md` und `glossar.md` — Rang 3 gegen zwei Soll-Blöcke. Für den Hort hat derselbe Plan
genau diesen Konflikt benannt und zugunsten des Blocks entschieden; für die Lehrkraft ist er nicht
erwähnt. Der Router folgt dem Plan (`_tier` → `"note"`).
Vorschlag: entweder `teacher` auf die Alltags-Sicht heben (dieselbe View wie der Hort) oder die
Abweichung im Plan ausschreiben und 08/15 mit derselben Begründung nachziehen wie beim Hort.
```

```
[gesundheit-R4] Klasse 5 · GET /children/{child_id}/health-record
Plan: „**Eine Rolle ohne Nennung bekommt `404`, nicht `403`**". Der Router prüft die Rolle mit
`require_staff(...)`, das `403` wirft — `accounting`, `executive_management` und `canteen` bekommen
damit 403 statt 404. Dieselbe Zeile macht den `UNRESTRICTED_ROLES`-Zweig in `_tier` unerreichbar:
Wer dort „voll" bekäme, kommt am Rollentor gar nicht vorbei.
Gemessen: den ganzen `require_staff`-Block aus `read_health_record` entfernt — 17 passed. Kein Test
ruft die Route mit einer nicht genannten Rolle.
Vorschlag: statt `require_staff` das fehlende Recht als 404 beantworten (die Sicht ist ohnehin
`_tier`, und `_tier is None` ist bereits ein 404), dazu ein Test mit `as_role("accounting")`.
```

```
[gesundheit-R5] Klasse 5 · PUT /children/{child_id}/measles-proof
Plan: „`secretariat` … **keine Elternroute** — kein Block lässt die Familie selbst eintragen".
Der Router hat `require_staff(user, _SECRETARIAT)`, die Suite prüft es nicht.
Gemessen: `require_staff` aus `set_measles_proof` entfernt — 17 passed. Ohne die Zeile trägt ein
Elternteil den Masernnachweis seines eigenen Kindes selbst ein.
Vorschlag: ein Test, der als `as_mother` PUT ruft und 403 erwartet.
```

```
[gesundheit-R6] Klasse 5 · PUT health-record, POST/PUT/DELETE health-traits
Plan: der Umweg gehört `secretariat` (plus `admin` über `gemeinsam.md`), keiner weiteren Rolle.
Gemessen: `if not user.is_guardian: require_staff(user, _SECRETARIAT)` aus `answer_health_record`
entfernt — 17 passed; dieselbe Zeile aus allen drei Merkmals-Routen entfernt — 17 passed. Kein Test
ruft eine der vier mit einer anderen Personalrolle; ohne die Zeilen schreibt jede angemeldete
Personalrolle Art.-9-Merkmale.
Vorschlag: ein Test je Route mit `as_role("teacher")` bzw. `as_role("canteen")`, 403 erwartet.
```

```
[gesundheit-R7] Klasse 4 · PUT /children/{child_id}/health-record
Plan: „nach Einsichtsstufe **nur ‚voll'**" — eine Regel, die kein Constraint trägt. Der Router
setzt sie über `reach_family(..., write=True)`.
Gemessen: `write=True` entfernt — 17 passed. Die Suite baut nirgends einen `read_only`-Zugang,
also prüft sie die Stufe in dieser Domäne überhaupt nicht.
Vorschlag: eine zweite Mutter mit `access_level = read_only` in `World`, die lesen darf und beim
PUT 403 bekommt.
```

```
[gesundheit-R8] Klasse 4 · POST /children/{child_id}/health-traits
Plan: „nur wo `answered_at` gesetzt ist — wer ablehnt, füllt die Strecke gar nicht erst aus";
kein Constraint trägt das. `test_a_trait_is_refused_before_the_record_is_answered` prüft nur den
Fall ohne Zeile, nicht den abgelehnten Bestand.
Gemessen: `if record is None or record.answered_at is None` auf `if record is None` verkürzt —
17 passed. Nach einem `{"accepted": false}` nimmt die Route damit Merkmale an.
Vorschlag: den vorhandenen Test um einen zweiten Fall ergänzen: erst ablehnen, dann POST, 400.
```

```
[gesundheit-R9] Klasse 4 · POST/PUT /children/{child_id}/health-traits
Plan: „Die vier Flags der Art … diktieren, welche Felder die Route annimmt; ein Feld außerhalb
seiner Art wird abgewiesen". Getestet ist genau eines davon (`has_treatment_reason`).
Gemessen: die drei übrigen Prüfungen einzeln entfernt — `is_medication`/`self_administered`
17 passed, `is_emergency_medication`/`emergency_description` 17 passed,
`needs_permission`/`permission` 17 passed.
Vorschlag: `test_a_field_outside_the_type_is_refused` um drei Fälle erweitern, je ein Feld an
einer Art, die es nicht trägt.
```

```
[gesundheit-R10] Klasse 2 · POST/PUT /children/{child_id}/health-traits
Plan: „Kein zweites Notfallmedikament mit derselben Beschreibung (`ix_health_traits_unique`)" —
die Regel hängt am Constraint. `app/routers/gesundheit.py` ist der einzige Router ohne
`except IntegrityError`, und `app/main.py` hat keinen Handler; der Verstoß wird eine 500 statt
einer 400/409. Dasselbe gilt für `ck_health_traits_certificate`
(`certificate_document_id` gesetzt, `has_certificate` false) — die Route prüft nur die
Zugehörigkeit des Dokuments, nicht die Kombination.
Gemessen: mittelbar — als die Typprüfung für `treatment_reason` entfernt war, endete der Testlauf
in `asyncpg.exceptions.CheckViolationError` statt in einer Antwort.
Vorschlag: `IntegrityError` in beiden Routen fangen wie in den acht anderen Routern, plus ein Test
auf den doppelten Eintrag.
```

```
[gesundheit-R11] Klasse 5 · GET /children/{child_id}/health-record
Plan: die vierte Sicht („Hinweis", `action_note`) gehört „jede[r] Rolle mit `teacher`";
`grenzkarte.md` sagt „den alle unterrichtenden Personen sehen". `_record_out` gibt `action_note`
in **jeder** Sicht mit — auch an die Eltern und an den Hort, für die ihn kein Block und kein Plan
vorsieht.
Gemessen: `action_note` für Eltern auf `None` gesetzt — 17 passed; kein Test hält fest, wer das
Feld bekommt.
Vorschlag: `action_note` nur bei Sicht „voll" und „note" ausliefern, dazu ein Test, der als
`as_mother` liest und `action_note is None` erwartet — oder die Ausweitung im Plan ausschreiben.
```

```
[gesundheit-R12] Klasse 1 · GET /children/{child_id}/health-record
Plan: „Schulleitung nur ihre Schulart". Die Bedingung steht zweimal — in
`security.staff_sees_child` und noch einmal in `_tier` — und der einzige Test dazu
(`test_school_management_is_bound_to_its_own_branch`) hält nur ihre Konjunktion.
Gemessen: `child.school_branch_id in await branches_of(...)` allein aus `_tier` entfernt —
17 passed; allein aus `staff_sees_child` entfernt — ebenfalls 17 passed. Erst beide zusammen
würden auffallen. Die Suite legt zudem nirgends eine `employee_roles`-Zeile mit
`school_branch_id` an, die Gegenrichtung („die eigene Schulart wird erreicht, die fremde nicht")
ist damit ungebaut.
Vorschlag: eine Schulleitung mit echter Branch-Zeile in `World`, die ihr eigenes Kind voll sieht
und ein Kind der anderen Schulart mit 404.
```

```
[gesundheit-R13] Klasse 5 · PUT /children/{child_id}/measles-proof
Der Existenz-Check (`reach_child`) trägt hier allein das 404 für ein unbekanntes Kind; das
Sekretariat erreicht ohnehin jedes.
Gemessen: `reach_child` entfernt — 17 passed. Ohne die Zeile wird aus einer unbekannten `child_id`
eine Fremdschlüsselverletzung, also eine 500 statt einer 404 (siehe R10).
Vorschlag: ein Test mit `uuid.uuid4()` als `child_id`, 404 erwartet.
```

```
[gesundheit-R14] Klasse 5 · Migration 08fc49476134
`GRANT UPDATE (child_id, presented_on, measles_presentation_type_id) ON measles_proofs` — keine
Route ändert je `measles_proofs.child_id`, `set_measles_proof` setzt ihn nur beim Anlegen. Ein
Update-Recht auf dem Fremdschlüssel erlaubt, einen vorhandenen Nachweis einem anderen Kind
zuzuschreiben.
Vorschlag: `child_id` aus dem UPDATE-GRANT streichen.
```

## Angesehen, nicht als Fund gewertet

- **Die drei engen Rollen tragen.** `narrow_role` einzeln aus `_full_traits`, `_everyday_traits`
  und `set_health_note` entfernt — alle drei rot. Die GRANTs sind wirklich eng, und die Suite
  belegt es.
- **Die Zusicherungen über leere Listen greifen.** `traits == []` in
  `test_a_plain_teacher_sees_only_the_note` und
  `test_the_class_teacher_falls_back_to_the_note_tier_outside_their_class`: `_tier` für `teacher`
  auf „full" gesetzt — rot. Ebenso `descriptions == ["Bienengift"]` beim Hort — rot.
- **`test_a_guardian_never_sees_the_measles_proof` trägt**, obwohl der vorbereitende PUT nicht auf
  200 geprüft wird: `and not user.is_guardian` entfernt — rot.
- **`test_only_the_class_teacher_may_write_the_note` trägt**: die
  `is_class_teacher`-Prüfung entfernt — rot.
- **`test_a_guardian_cannot_reach_another_familys_child` trägt**: `reach_family` aus dem
  Eltern-Zweig von `reach_child` entfernt — rot.
- **`everyday_health_traits`** liefert genau die neun Spalten, die der Plan aufzählt, gefiltert auf
  `is_everyday_relevant`.
- **`cared_for` steht zweimal** (in `staff_sees_child` und in `_tier`), aber `reach_child` läuft
  zuerst — die zweite Prüfung ist redundant, nicht ausnutzbar.
- **Klasse 6 und 7 treffen nicht zu:** kein Endpunkt dieser Domäne ruft Graph oder verschickt Mail,
  und `app/runs.py` führt keinen Lauf der Gesundheit.
- **`TransactionRoute`** liegt am Router, keine Massenoperation, kein `commit` — die Schreibschicht
  wird nirgends umgangen.
