# Prüfbericht: Routen der Klassenorganisation

Vier Routen in `app/routers/klassenorganisation.py`, 26 Tests in `tests/test_klassenorganisation.py`.
**Nullpunkt grün** (26 passed). Gemessen nach der Methode aus `prompts/api-pruefen.md`: Sicherung
heraus, `--profile tools build test`, `pytest tests/test_klassenorganisation.py -x -q`, danach
`git checkout -- app/` und die Datenbank leergeräumt. **16 Läufe, 14 gültige Messungen, 12 rot.**
Zwei Läufe waren keine Messung und sind unten benannt.

## Funde

```
[KLASSENORG-R1] Klasse 5 · POST /classes/{class_id}/representatives
Plan: „die Klassenlehrkraft dieser Klasse; secretariat, school_management". Die Rollenschranke ist
  require_staff(user, *_WRITE_ROLES) am Kopf von _class_to_write — kein Test hält sie fest.
Gemessen: Zeile entfernt, tests/test_klassenorganisation.py bleibt grün (26 passed). Ohne sie
  schreibt jede Rolle aus UNRESTRICTED_ROLES an jeder Klasse — accounting und
  executive_management stehen dort und nennt der Plan an dieser Route nicht. Die drei vorhandenen
  Verweigerungstests bleiben grün, weil sie über den zweiten Zweig laufen: der Elternteil und die
  fremde Lehrkraft fallen ohnehin auf „Not your class".
Vorschlag: ein Test, der mit as_role("accounting") auf POST ein 403 verlangt.
```

```
[KLASSENORG-R2] Klasse 5 · GET /classes/{class_id}/representatives
Plan: „teacher, secretariat, school_management, executive_management; Erziehungsberechtigte". Die
  Schranke ist require_staff(...) in _class_to_read — kein Test hält sie fest.
Gemessen: Zeile entfernt, tests/test_klassenorganisation.py bleibt grün (26 passed). Ohne sie liest
  accounting jede Klassenvertretung, weil die Rolle in UNRESTRICTED_ROLES steht und der Zweig
  darunter sie durchlässt.
Vorschlag: ein Test, der mit as_role("accounting") auf die Klassenansicht ein 403 verlangt.
```

```
[KLASSENORG-R3] Klasse 8 · DELETE /class-representatives/{class_representative_id}
gemeinsam.md, „Fehler": 404 heißt „gibt es nicht oder gehört nicht dir", und beide antworten gleich,
  wo die Unterscheidung eine Auskunft wäre. Der Router antwortet hier 403 (_class_to_write), mit der
  Begründung im Kommentar, jede Rolle lese ohnehin GET /classes. Das trägt für class_id, nicht für
  class_representative_id: Eine Schulleitung sieht die Vertretung fremder Schularten weder über
  GET /classes/{id}/representatives noch über GET /class-representatives — sie erfährt aus dem 403
  statt eines 404, dass dieser Eintrag existiert. Für teacher fällt es nicht ins Gewicht (der liest
  jede Klassenansicht), für school_management schon.
Nicht gemessen, gelesen: test_the_school_management_strikes_out_only_in_its_own_school_form
  schreibt das 403 fest.
Vorschlag: für den Zweig, der nicht über die eigene Klasse verfügt, 404 statt 403 antworten.
```

```
[KLASSENORG-R4] Klasse 8 · app/routers/klassenorganisation.py:73 _school_year()
Der Router zieht class_key() aus app/routers/stammdaten.py und begründet das im Import-Kommentar:
  „a second copy of the format here would be the one that stays behind when it changes". Für die
  Schuljahresgrenze tut er das Gegenteil — _school_year() ist Zeile für Zeile
  stammdaten.school_year_of(), samt derselben Begründung im Docstring. Beide sagen heute dasselbe;
  die zweite Fassung ist die, die beim nächsten Griff an die Grenze stehen bleibt.
Nicht gemessen, gelesen.
Vorschlag: school_year_of aus app/routers/stammdaten.py importieren, wie class_key daneben.
```

## Angesehen, nicht als Fund gewertet

- **Ownership in der Query (Klasse 1), alle vier Wege gemessen und alle rot.** Elternteil gegen
  fremde Klasse (`Child.family_id.in_(...)` entfernt →
  `test_a_parent_does_not_see_another_class`); Schulleitung lesend und schreibend gegen fremde
  Schulart (Bedingung auf True → `test_the_school_management_sees_only_its_own_school_form`,
  `..._reaches_only_its_own_school_form`); Klassenlehrkraft gegen fremde Klasse (`is_class_teacher`
  auf True → `test_a_teacher_of_another_class_may_not_enter`). Der Test mit der **fremden Id** durch
  einen Berechtigten liegt in allen vier Fällen vor.
- **Der Ownership-Check des DELETE**, `_class_to_write(session, user, row.class_id)` entfernt →
  rot (`test_a_teacher_of_another_class_may_not_strike_out`).
- **Die drei Regeln ohne Constraint (Klasse 4), alle drei rot.** Sorgeberechtigung gegen
  `family_guardians` (`or guardian is None` entfernt → `test_a_person_who_is_no_guardian_is_refused`);
  gerechnetes Schuljahr (`_school_year(_today()) - 1` → `test_the_class_teacher_enters_a_representative`);
  Schuljahresfilter der Klassenansicht (`where` entfernt → `test_last_school_years_office_is_not_shown`).
- **Die Zusage „kein Kontaktweg" der Klassenansicht.** Ein zusätzliches Feld an `RepresentativeOut`
  → rot: `test_the_class_view_carries_names_and_no_way_to_reach_anybody` prüft die Schlüsselmenge
  der Antwort exakt, nicht nur das Fehlen der einen Adresse aus dem Fixture.
- **Die Jahresliste geht nie über den OTP-Pfad.** `require_role` durch `get_current_user` ersetzt →
  rot (`test_the_annual_list_is_closed_to_teachers_and_parents`). Ihr Schulart-Filter neutralisiert
  → rot (`test_the_annual_list_shows_a_head_only_its_own_school_form`).
- **Klasse 2 lässt sich in dieser Domäne nicht herstellen.** Kein Endpunkt schreibt vor seiner
  Absage; und `TransactionRoute` (`app/db/session.py`) committet erst nach der Rückkehr des
  Handlers, eine `HTTPException` kommt dort nie an. Gemessen: die Sorgeberechtigten-Prüfung hinter
  `session.add()` + `flush()` gestellt — rot, aber am Fehlercode
  (`test_an_unknown_person_is_refused` bekommt 409 aus dem Fremdschlüssel statt 400) und nicht am
  Zustand. Eine geschriebene Zeile bleibt in keiner Variante stehen.
- **Klasse 6 und 7 entfallen.** Jede schreibende Route berührt genau eine Tabelle, es gibt keine
  Mail und kein Fremdsystem — der Plan schreibt beides aus. Kein Lauf berührt die Domäne
  (`app/runs.py` nennt `class_representatives` nicht).
- **`GET /class-representatives` für `executive_management`.** Der Router lässt die Rolle nicht
  herein, Plan und Block 16 („für Sekretariat und Schulleitung") auch nicht. Dass die Rolle
  umgekehrt die **Klassenansicht** lesen darf, steht im Plan und nicht im Block — `glossar.md`
  gibt der Geschäftsführung aber ausdrücklich den Umfang „alle", der Plan weicht hier also nicht ab.
- **400 statt 404 für eine unbekannte `person_id` im Rumpf.** Beide Fälle — unbekannte Person und
  bekannte ohne `family_guardians`-Zeile — antworten gleich; der Aufrufer erfährt aus dem Status
  nicht, ob es die Person gibt. Das ist dieselbe Nichtauskunft, die `gemeinsam.md` für 404 verlangt.
- **`GRANT SELECT, INSERT, DELETE` und kein UPDATE** in der Migration der Domäne — passend dazu,
  dass die Zeile weggeht und kein Ende bekommt.
- **HTML der Druckansicht.** Klassenschlüssel, Name und Mailadresse laufen je durch `html.escape`;
  `_LIST.format()` liest die eingesetzten Werte nicht erneut als Format-String.
- **Zwei Läufe waren keine Messung.** „Schulart-Filter der Jahresliste entfernt" hinterließ ein
  leeres `if` und scheiterte am Import (wiederholt als M12b, dann rot). „Sorgeberechtigten-Prüfung
  entfernt" wurde ein zweites Mal in identischer Form gefahren.
- **Zwei schwache Zusicherungen, beide beißen trotzdem.** `test_last_school_years_office_is_not_shown`
  hält eine leere Liste fest — die Messung oben zeigt, dass sie bei entferntem Jahresfilter rot
  wird. In `test_the_annual_list_answers_for_a_past_school_year` ist die Hälfte
  „`mutter@test.invalid` not in running.text" trivial wahr, weil im laufenden Jahr in diesem Test
  überhaupt kein Amt steht; die zweite Hälfte trägt den Test.
