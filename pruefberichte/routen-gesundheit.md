# Prüfbericht: Routen der Domäne gesundheit

Gegen `origin/gesundheit-umbau` (`1569109`), nicht gegen `main` — dort steht noch das alte
Merkmalsmodell. Eigener Arbeitsbaum, eigene Datenbank, Nullpunkt `tests/test_gesundheit.py` grün
mit 42 Tests. 19 Sicherungen herausgenommen, 14 davon wurden rot.

## Funde

[GESUNDHEIT-R1] Klasse 1 · GET /children/{child_id}/health-record, PUT /children/{child_id}/health-note
Plan: Sichtkreis `class_lead` „nur die Kinder der eigenen Klasse", der Hinweis „nur die eigene
Klasse". Die Bedingung steht in `is_class_teacher` (`app/core/security.py`) als zweite
`where`-Klausel neben dem Aufrufer.
Gemessen: `.where(Class.class_id == class_id)` entfernt, tests/test_gesundheit.py bleibt grün
(42 passed). Der Grund liegt in der Welt der Suite: Sie legt **eine** Klasse an, und das Kind
„außerhalb der Klasse" (`world.child`) trägt gar keine `class_id` — es fällt schon in den Zweig
`if class_id is None`. Eine Klassenlehrkraft, die die Id eines Kindes einer **anderen** Klasse rät,
bekommt damit ungeprüft `class_lead` — Bezeichnung und Diagnosename, Art. 9 — und darf dessen
Hinweis schreiben.
Vorschlag: ein zweites Kind in einer zweiten Klasse in `world`, dazu je ein Test auf 404 beim Lesen
und 403 beim Hinweis; die vorhandene `class_id is None`-Prüfung ist nicht dieselbe Aussage.

[GESUNDHEIT-R2] Klasse 5 · POST /children/{child_id}/emergency-accesses
Plan: „**jede Mitarbeiterrolle**". Die Route prüft allein `if user.is_guardian` und nimmt sonst
jeden Aufrufer, der durch die Entra-Tür kam — auch einen ohne jede Rolle. `_staff()`
(`app/core/security.py`) gibt für zwei Fälle ausdrücklich `roles=frozenset()` zurück, statt
abzuweisen: das Konto, dessen Rolle noch niemand vergeben hat, und das, dessen
`employees.last_working_day` vorbei ist („gets the same dead end"). An jeder anderen Route endet
das in `require_role`; hier nicht. Eine ausgeschiedene Lehrkraft mit noch gültigem Token liest
damit den Notfallausschnitt samt Notfallkontakt und Telefonnummer jedes Kindes.
Gelesen, nicht gemessen: eine fehlende Prüfung wird durch Entfernen nicht sichtbar. Kein Test ruft
die Route mit einem Aufrufer ohne Rolle — `test_any_staff_member_…` nimmt `as_role("caretaker")`.
Vorschlag: `if not user.roles: raise 403` neben der Eltern-Prüfung, dazu ein Test mit `as_role()`.

[GESUNDHEIT-R3] Klasse 5 · GET /children/{child_id}/health-record
Plan: Masernnachweis „**nur `full`, nur Personal**".
Gemessen: `if sight == "full" and not user.is_guardian` → `if not user.is_guardian`,
tests/test_gesundheit.py bleibt grün (42 passed). Nur die Eltern-Hälfte der Regel trägt einen Test
(`test_a_guardian_never_sees_the_measles_proof`); die Beschränkung auf `full` trägt keinen, weil
die Kinder der Sicht-Tests (`class_child`, `day_care_child`) gar keinen Nachweis haben. Eine
Fachlehrkraft (`sports`) oder der Hort erführe ungeprüft, ob und wie der Nachweis vorlag.
Vorschlag: im Test der Sport-Sicht denselben Nachweis anlegen wie beim Sekretariat und
`measles_proof is None` zusichern.

[GESUNDHEIT-R4] Klasse 5 · GET /children/{child_id}/health-record, PUT /children/{child_id}/health-note
Plan: `class_lead` gehört „der Klassenlehrkraft (`classes.class_teacher_id`, **keine `roles`-Zeile**)".
Im Code entscheidet `reach_child` vor `_sight`, und dessen `staff_sees_child` endet mit
`return TEACHER_ROLE in user.roles`: Wer Klassenlehrkraft ist, die Rolle `teacher` aber nicht
trägt, bekommt 404, bevor `is_class_teacher` überhaupt gefragt wird — lesend wie schreibend. Der
Sichtkreis hängt damit doch an einer `roles`-Zeile.
Gemessen: `return TEACHER_ROLE in user.roles` → `return False`, `test_sports_sees_…` wird rot
(404 statt 200) — die Erreichbarkeit hängt an genau dieser Zeile. Kein Test setzt eine
Klassenlehrkraft ohne `teacher`-Rolle; `as_class_teacher` vergibt sie immer.
Vorschlag: in `staff_sees_child` die Klassenlehrkraft als eigenen Zweig führen, wie `cared_for`,
dazu ein Test mit `roles=frozenset()` und gesetzter `class_teacher_id`.

[GESUNDHEIT-R5] Klasse 2 · PUT /children/{child_id}/health-record, PUT …/answers/{type_code}
Plan: „Fehlt eine, antwortet die Route `400` … **nichts wird geschrieben**". Beide Routen legen den
Bestand vorher an (`record_of(…, create=True)` samt `flush`), und `replace_category` schreibt
Merkmal und Werte feldweise, bevor der zweite Wert die Ausnahme wirft — bei
`{"label": "x", "period": {…}}` steht das Merkmal samt Bezeichnung bereits in der Session. Getragen
wird die Zusage allein vom Rollback der Anfragetransaktion.
Gelesen, nicht gemessen: kein Test zählt Zeilen um eine 400 herum.
`test_the_close_names_the_categories_without_an_answer` prüft danach `answered_at is None`, aber an
einem Bestand, den der vorige Aufruf schon angelegt hatte — das ist nicht das Rollback.
`tests/test_changelog.py` prüft nur, dass jeder Router `TransactionRoute` trägt, nicht dass eine
geworfene `HTTPException` zurückrollt.
Vorschlag: ein Test, der auf einem Kind ohne Bestand eine 400 auslöst und danach zusichert, dass
`child_health_records` und `health_traits` für dieses Kind leer sind.

[GESUNDHEIT-R6] Klasse 4 · Die Schulart-Bedingung der Schulleitung steht zweimal
Plan: `full` für `school_management` „nur ihre Schulart". Die Bedingung steht in
`staff_sees_child` (`app/core/security.py`) **und** noch einmal in `_sight`
(`app/routers/gesundheit.py`).
Gemessen: zweimal, je eine der beiden entfernt — beide Male bleibt tests/test_gesundheit.py grün
(42 passed). Rot wird der Lauf erst, wenn beide fallen.
`test_school_management_is_bound_to_its_own_branch` belegt damit die Regel, aber keine der beiden
Zeilen: Wer eine davon beim Aufräumen streicht, kommt durch die Suite.
Vorschlag: die Kopie in `_sight` streichen und die eine in `staff_sees_child` stehen lassen; zwei
Kopien einer Zugriffsregel sind eine zu viel.

[GESUNDHEIT-R7] Klasse 4 · GET /children/{child_id}/health-record
`_categories_of_sight` filtert auf `HealthTraitType.is_active`. Eine deaktivierte Kategorie
verschwindet damit aus jeder Antwort, während ihre Werte stehenbleiben — und der Abschluss
(`close_record`) fragt sie danach auch nicht mehr ab.
Gemessen: `.where(HealthTraitType.is_active)` entfernt, tests/test_gesundheit.py bleibt grün
(42 passed). Der Seed kennt keine deaktivierte Kategorie, also prüft nichts, was beim Deaktivieren
geschieht.
Vorschlag: ein Test, der eine beantwortete Kategorie deaktiviert und zusichert, was die Antwort
dann trägt — oder die Zeile streichen, wenn der Plan sie nicht verlangt.

[GESUNDHEIT-R8] Klasse 8 · Die Gegenprobe des Plans zählt eine Route zu viel
Plan: „Es gibt **8 Routen**; **4** nennen eine dieser Zeilen, **4** einen Hebel oder Abschnitt der
Karte." Die Tabelle darunter trägt **7** Zeilen, und der Router baut genau diese sieben
(`@router.` siebenmal, Methoden und Pfade stimmen). Vier nennen eine Ablaufzeile (Fragensatz, PUT
Bestand, PUT Kategorie, Masernnachweis), **drei** einen Hebel oder die Karte (GET Bestand, Hinweis,
Notfalleinsicht). Nicht der Router weicht ab, sondern die Gegenprobe des Plans — und eine falsche
Gegenprobe ist die, die beim nächsten Bau niemand nachzählt.
Vorschlag: im Plan auf „7 Routen; 4 … 3 …" korrigieren.

## Angesehen, nicht als Fund gewertet

- **Die enge Rolle des Hinweises trägt.** `narrow_role(NarrowRole.HEALTH_NOTE)` aus
  `set_health_note` entfernt → rot mit `ProgrammingError`; `backend_runtime` hält auf
  `child_health_records` nur `UPDATE (answered_at, declined_at)`.
- **Die sechs Sichten tragen die Feldgrenze.** Jede Sicht durch `health_values_full` gelesen → rot
  (`test_the_day_care_sees_…`). Ebenso der Sichtkreis-Filter von `_categories_of_sight` → rot
  (`chronic_illness` im Notfallausschnitt).
- **Ownership des Horts und des Attests sind geprüft.** `cared_for` ohne `child_id`-Filter → rot;
  `owner != child_id` → `owner is None` → rot.
- **Die vier Regeln ohne Constraint sind geprüft:** Vollständigkeit des Abschlusses, Merkmal ohne
  Wert, Ersetzen der Kategorie am Stück, Einsichtsstufe „nur lesen" — jede einzeln gemessen, jede rot.
- **Die Eltern-Sperre der Notfalltür ist doppelt getragen.** Ohne die Prüfung in der Route fängt
  `ck_health_emergency_accesses_created_by` den Fall ab; der Test wird rot, aber mit einer
  `IntegrityError` statt der 403. Ausgeliefert wird nichts, weil der Flush vor der Antwort steht.
- **`_values_of_sight` baut sein SQL mit einer f-String-Interpolation**, der Wert kommt aber
  ausschließlich aus den Schlüsseln von `_ROLE_OF_SIGHT` und nie aus einer Anfrage.
- **Der Hinweis erreicht die Eltern auch nicht über die Änderungsspur.** `action_note` steht
  bewusst nicht in `__protected_columns__`, die Spur trägt ihn also im Klartext — aber
  `GET /change-log` weist `user.is_guardian` mit 403 ab, und `child_health_records` steht dort nur
  Sekretariat und Admin offen, die den Hinweis ohnehin sehen.
- **08 nennt für Lehrkräfte noch die Alltagsliste samt Bezeichnung** („Unverträglichkeit, Allergie,
  Notfallmedikation samt Erlaubnis, Zeckenentfernung"); der Sichtkreis `sports` liefert zur Allergie
  keine Bezeichnung. Der Plan trägt das als `[A]` samt Preis — keine Abweichung, sondern eine
  markierte Entscheidung.
- **08: „Widersprechen sich zwei Sorgeberechtigte, gilt der Widerspruch als Nein."** Es gibt eine
  Zeile je Kind, und der letzte Schreiber gewinnt. Der Block hängt die Entscheidung an die
  Unterschriften unter dem Vertrag, entscheidet also außerhalb des Systems — kein Fund.
- **`ferien.py::_health_slice`** liest `everyday_health_traits` unter `backend_health_care` und
  `kitchen_health_traits` unter `backend_kitchen`. Genau das verlangt „Korrigiert an anderer
  Stelle"; beide Sichten sind in den Migrationen an diese Rollen vergeben.
- **`test_only_the_write_layer_constructs_a_value` kann nicht leer grün werden** — es vergleicht
  gegen eine einelementige Menge, nicht auf Abwesenheit.
- **Der Pfadparameter heißt `{type_code}`, der Plan schreibt `{trait_type_code}`** — dieselbe URL.
