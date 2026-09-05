Stand: c4ef05a, Nullpunkt: 28 Tests grün

# Prüflauf `klassenorganisation` — Routen und Tests

Geprüft: `app/routers/klassenorganisation.py` (vier Routen), `app/models/klassenorganisation.py`,
`tests/test_klassenorganisation.py`, dazu die geteilten Hebel, die dieser Router nimmt
(`app/core/security.py`: `require_staff`, `staff_roles`, `branches_of`, `is_class_teacher`;
`app/db/changelog.py`; `app/db/session.py`). Plan: `api/klassenorganisation-api.md` samt
`api/gemeinsam.md`, Block: `soll-prozesse/16-elternvertretung.md`.

Einen Service hat die Domäne nicht, einen Lauf auch nicht — `app/runs.py` nennt sie nirgends, und
der Plan schreibt „Kein Lauf" aus. **Fehlerklasse 6 und 7 haben hier keinen Gegenstand:** Keine
Route schreibt mehr als eine Tabelle, keine ruft Graph, keine verschickt Mail, keine trägt eine
Marke.

20 Sicherungen herausgenommen, **16 davon wurden rot**. Die fünf Funde unten hängen an den vier
grünen Messungen (R1, R2 zweimal, R4), an einer Stelle, an der der Plan vom Block abweicht (R3),
und an drei Zusicherungen, die den Statuscode nicht lesen (R5).

## Funde

```
[klassenorganisation-R1] Klasse 5, Wirkung wie 1 · POST /classes/{class_id}/representatives
                                  · DELETE /class-representatives/{id}
Plan: „die Klassenlehrkraft dieser Klasse; secretariat, school_management", und die
Klassenlehrkraft ist `classes.class_teacher_id` und nicht die Rolle. `_may_write` gibt aber
jeder Rolle aus `UNRESTRICTED_ROLES` frei — darin stehen auch `accounting` und
`executive_management`, die der Plan an keiner der beiden Schreibrouten nennt. Erreichbar nur in
Kombination, weil `require_staff(user, *_WRITE_ROLES)` davor sitzt: Wer `teacher` **und**
`accounting` hält, kommt als Lehrkraft durch das Rollentor und überspringt danach genau den
Ownership-Check, für den die Route existiert — er schreibt und trägt aus an jeder Klasse.
Gemessen: `_may_write` auf `{_SECRETARIAT}` und admin verengt — 28 passed. Die Freigabe an
`accounting` und `executive_management` deckt kein Test, in keine Richtung.
Vorschlag: `_may_write` auf die Rollen des Plans verengen (`secretariat`, `admin`) und einen
Test mit `teacher` + `accounting` an einer fremden Klasse.
```

```
[klassenorganisation-R2] Klasse 5 · GET /classes/{class_id}/representatives
                                  · GET /class-representatives
Plan: `executive_management` darf die Klassenansicht lesen und die Jahresliste **nicht**. Beide
Hälften stehen im Code (`require_staff(…, _EXECUTIVE)` bzw. `require_role(_SECRETARIAT,
BRANCH_ROLE)`), und **keine der beiden hat einen Test**: keiner der 28 nimmt die Rolle in die
Hand.
Gemessen: `_EXECUTIVE` aus dem Rollentor der Klassenansicht genommen — 28 passed. `_EXECUTIVE`
ins Rollentor der Jahresliste gesetzt — 28 passed. Die Grenze wäre in beide Richtungen
verschiebbar, ohne dass etwas rot wird.
Vorschlag: ein Test, der `executive_management` die Klassenansicht liest und an der Jahresliste
eine 403 bekommt.
```

```
[klassenorganisation-R3] Klasse 8 · GET /classes/{class_id}/representatives
                                  · GET /class-representatives
Block 16 nennt beim Sehen „Lehrkräfte, Sekretariat und Schulleitung" und bei den Dateien „für
Sekretariat und Schulleitung mit den Mailadressen" — die Geschäftsführung an keiner der beiden
Stellen. Der Plan setzt sie an die erste und lässt sie an der zweiten weg. Trägt
`hebel.md` §Rollen („Die Geschäftsführung ist an keine Schulform gebunden und fängt deshalb den
Ausfall beider auf"), dann trägt es für beide Routen; trägt es nicht, dann für keine. Der Plan
schreibt keine Abweichung aus, und der Block schlägt ihn (`wb-docs/CLAUDE.md`, Rangfolge).
Gelesen: nicht gemessen — die Frage ist, was gelten soll, und nicht, ob der Code den Plan trifft.
Vorschlag: Im Plan eine Zeile, die die Geschäftsführung an beiden Routen gleich behandelt, und
den Code danach ziehen.
```

```
[klassenorganisation-R4] Klasse 4 · GET /class-representatives
Die Druckansicht setzt drei Werte aus dem Bestand in HTML — Klassenschlüssel, Name, Mailadresse —
und schützt sie mit `html.escape`. Das ist eine Regel, die kein Constraint trägt: Namen und
Adressen kommen aus der Datenänderung (02) und aus der Bewerbung (05), also von außen.
Gemessen: alle drei `html.escape` entfernt, tests/test_klassenorganisation.py bleibt grün
(28 passed).
Vorschlag: ein Test, der einen Namen mit `<` in die Liste bringt und ihn escaped wiederfindet.
```

```
[klassenorganisation-R5] Klasse 3 · tests/test_klassenorganisation.py
Drei Zusicherungen halten auch gegen eine Antwort, die gar keine Liste ist:
`test_the_annual_list_answers_for_a_past_school_year` prüft `"mutter@test.invalid" not in
running.text`, ohne `running.status_code` anzusehen — eine 403 oder eine 500 erfüllt sie
ebenfalls. `test_a_teacher_sees_every_class` und die `allowed`-Hälfte von
`test_the_school_management_sees_only_its_own_school_form` legen je ein Amt an und sichern danach
nur den Statuscode zu, nie den Inhalt; eine leere Liste hielte beide.
Gemessen: nicht eigens — M10 zeigt, dass der Jahresfilter der Jahresliste heute an genau diesem
Test hängt, und damit an einer Zusicherung, die den Statuscode nicht liest.
Vorschlag: die drei Stellen um `status_code == 200` bzw. um eine Zusicherung über den Namen
ergänzen.
```

## Angesehen, nicht als Fund gewertet

- **Fehlerklasse 1 an allen vier Routen sonst.** Jede trägt einen Test, in dem ein *Berechtigter*
  eine fremde Kennung nimmt und eine Absage bekommt: die Lehrkraft einer anderen Klasse beim
  Eintragen (403) und beim Austragen (404), die Schulleitung der anderen Schulart an allen vier,
  der Elternteil an der Klassenansicht (404). Alle vier Bedingungen herausgenommen — jedes Mal rot
  (M1, M2, M5, M6, M9, M11).
- **Fehlerklasse 2.** Beide Schreibrouten weisen ab, bevor irgendetwas an der Session hängt:
  `_class_to_write` und die Sorgeberechtigten-Prüfung laufen vor `session.add`, das Rollentor des
  Austragens vor dem `session.get`. Ein halb geschriebener Zustand ist hier nicht baubar.
- **Der 409-Weg.** `IntegrityError` → `HTTPException`; `get_db()` öffnet die Transaktion über
  `session.begin()`, das bei einer Ausnahme zurückrollt, und `TransactionRoute` committet nur eine
  zurückgegebene Antwort. Die zweite Eintragung hinterlässt nichts.
- **Enge Rolle: keine, wie der Plan sagt.** Die Migration gibt `SELECT, INSERT, DELETE ON
  class_representatives` und **kein UPDATE** — „das Amt ist ein Eintrag" trägt damit das Privileg
  und nicht nur die fehlende Route. `persons` trägt tabellenweites `SELECT`, `persons.email` steht
  hinter keiner engeren Rolle. `tests/test_privileges.py` prüft tabellenweites UPDATE generisch
  über alle Tabellen.
- **403 statt 404 an `_class_to_write` und `_class_to_read`.** Das Argument im Kommentar trägt:
  `GET /classes` (`app/routers/stammdaten.py`) steht `school_management`, `secretariat`, `teacher`
  und `executive_management` offen und filtert nicht nach Schulart — welche Klassen es gibt, ist
  für jede Rolle, die so weit kommt, keine Auskunft.
- **Die beiden Ränder, die der Plan benennt, sind gebaut**:
  `GET /classes/{class_id}/selectable-guardians` und `GET /classes` stehen in
  `app/routers/stammdaten.py`.
- **`staff_roles(user)` neben `user.roles & UNRESTRICTED_ROLES`** ist an allen vier Stellen tot:
  `ADMIN_ROLE` steht schon in `UNRESTRICTED_ROLES`. Ändert nichts, deshalb kein Fund.
- **Austragen eines Amts aus einem vergangenen Schuljahr** ist möglich und ungetestet. Der Plan
  schreibt „Kein Zustand hindert das Austragen: Es gibt keinen" — es gibt also keine Regel, gegen
  die eine Gegenprobe liefe.
- **`test_last_school_years_office_is_not_shown` sichert eine leere Liste zu** — die Bauform von
  Fehlerklasse 3. M8 zeigt, dass sie trägt: Fällt der Jahresfilter, wird der Test rot.
- **`?school_year=` ohne Grenzen.** Ein Lesevorgang, und der Vergleich gegen eine `smallint`-Spalte
  kostet nichts.
