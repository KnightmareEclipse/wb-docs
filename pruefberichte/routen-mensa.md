Stand: c4ef05a, Nullpunkt: 38 Tests grün

# Routen-Prüflauf Mensa

16 Routen in `app/routers/mensa.py` gegen `api/mensa-api.md` und `soll-prozesse/11-mensa.md`.
Plan und Router stimmen in Zahl, Methode und Pfad paarweise überein; die Abweichungen liegen in
den Spalten „Wer darf" und „Worauf eingeschränkt".

25 Sicherungen herausgenommen, 5 davon blieben grün. Fehlerklasse 7 entfällt: die Domäne hat
keinen Lauf, der Jahreslauf findet `ends_on` vor, statt es zu setzen.

## Funde

```
[MENSA-R1] Klasse 1 · POST /meal-subscriptions/{id}/days, DELETE /meal-subscription-days/{id},
           POST .../reduction, POST .../termination
Plan: „eigene Familie". Der Check steht im Code — alle vier Routen gehen über
  `_reach_subscription` → `_reach_child_to_write` → `reach_child`/`reach_family`. Geprüft wird
  er von keinem Test dieser Datei: Der einzige Fremd-Id-Test der Domäne
  (`test_a_guardian_cannot_register_a_foreign_child`) trifft den Kind-Pfad, nicht den Abo-Pfad.
  Keine der vier Routen wird je mit einer fremden `meal_subscription_id` oder
  `meal_subscription_day_id` aufgerufen — auch nicht von der Schulleitung der falschen Schulform,
  die `as_branch_head` bereitstellt.
Gemessen: `_reach_child_to_write` in `_reach_subscription` durch ein blankes
  `session.get(Child, subscription.child_id)` ersetzt — `tests/test_mensa.py` bleibt bei
  38 grün. Zum Vergleich rot wird der Kind-Pfad (`reach_child` aus `read_meal_profile`
  entfernt: 1 failed, „assert 200 == 404").
Vorschlag: Je ein Test mit `as_other_mother` auf eine fremde Abo-Id und einer mit
  `as_branch_head` auf das Realschul-Abo.
```

```
[MENSA-R2] Klasse 5/8 · GET /children/{child_id}/meal-profile
Plan: „`secretariat`, `school_management`, `domestic_services_management`, `day_care_staff`";
  Block 11 „Was dabei erhoben wird": die Variante ist „sichtbar für Mensa,
  Hauswirtschaftsleitung, Hortkräfte und Sekretariat". Die Route lässt
  `domestic_services_management` durch `require_staff`, aber das zweite Tor,
  `reach_child` → `staff_sees_child` (`app/core/security.py`), kennt die Rolle nirgends: weder
  in `UNRESTRICTED_ROLES`, noch als Zweigrolle, noch als Hortrolle, noch als `teacher`. Die
  Rolle steht damit in der Route und erreicht kein einziges Kind.
Gemessen: In `test_the_canteen_reads_no_single_profile` `as_role("canteen")` durch
  `as_role("domestic_services_management")` ersetzt — `assert 404 == 403`. Die Rolle bekommt
  nicht die erwartete Absage der Rolle, sondern die Absage der Reichweite.
Vorschlag: `domestic_services_management` in `UNRESTRICTED_ROLES` aufnehmen — oder, wenn sie
  das einzelne Kind nicht sehen soll, aus der Route streichen und Plan und Block nachziehen.
```

```
[MENSA-R3] Klasse 8 · Plan gegen Block: der offizielle Umweg der Schulleitung
Block 11 „Sonderfälle": „Sekretariat und Schulleitung melden an, ändern, kündigen und setzen
  jedes Datum stellvertretend; da niemand freigibt, gibt es hier auch keine Ausnahme davon."
  Der Plan nennt in „Wer darf" bei vier Routen nur `secretariat`: `PUT .../meal-profile`,
  `POST .../meal-subscription`, `POST .../days`, `DELETE /meal-subscription-days/{id}`. Der
  Router folgt bei den ersten beiden dem Plan (Schulleitung 403) und bei den letzten beiden dem
  Block (`BRANCH_ROLE` steht im `require_staff`). Der Plan widerspricht sich zusätzlich selbst:
  bei `.../days` sagt seine Spalte „Worauf eingeschränkt" „Sekretariat und Schulleitung setzen
  auch hier jedes Datum", seine Spalte „Wer darf" nur `secretariat`.
Gelesen, nicht gemessen: die Rollen stehen im Klartext in beiden Dateien.
Vorschlag: `school_management` in alle vier Planzeilen, und `BRANCH_ROLE` in die zwei
  `require_staff`-Aufrufe von `set_meal_profile` und `register_for_meals`.
```

```
[MENSA-R4] Klasse 8/2 · POST /meal-subscriptions/{id}/reduction, Sekretariatsweg
Plan: „Sekretariat und Schulleitung setzen jedes Datum." Die Route übernimmt
  `body.valid_until` ungeprüft. `ck_meal_subscription_days_end` lässt aber ausschließlich einen
  31. Januar zu — jedes andere Datum reißt die Transaktion als IntegrityError ab und wird 500
  statt der 400 aus `api/gemeinsam.md`. „Jedes Datum" ist an dieser Route gar nicht baubar,
  solange der CHECK steht.
Gelesen: `app/routers/mensa.py`, `reduce_days`, gegen die Migration der Domäne.
Vorschlag: Entweder die Route auf den 31. Januar festnageln und den Plan korrigieren, oder den
  CHECK für den Sekretariatsfall öffnen — die Entscheidung gehört in den Block.
```

```
[MENSA-R5] Klasse 8/2 · POST /meal-subscriptions/{id}/days, Sekretariatsweg
Plan: „Sekretariat und Schulleitung setzen auch hier jedes Datum, auch eines in der
  Vergangenheit." Die Route prüft `body.valid_from` allein gegen `subscription.ends_on`. Zwei
  weitere Schranken stehen in der Datenbank und werden nicht abgefangen:
  `ck_meal_subscription_days_start` (der Tag muss der 1. sein) und
  `trg_meal_subscription_days_period` (nicht vor `starts_on` des Abos). Ein Sekretariat, das den
  15.10. oder ein Datum vor dem Abo-Beginn schickt, bekommt 500 statt 400.
Gemessen (Nebenbefund): Wird der Elternzweig entfernt, sodass ein Elternteil `valid_from`
  wählt, endet der Lauf mit `CheckViolationError: Esstag 4 liegt außerhalb des Zeitraums seines
  Abos` — derselbe Weg, den das Sekretariat heute offen hat.
Vorschlag: Beide Bedingungen vor dem Schreiben prüfen und als 400 beantworten.
```

```
[MENSA-R6] Klasse 2 · POST /children/{child_id}/meal-subscription
`_variant_id()` wirft die 400 für einen unbekannten Variantencode, **nachdem** Abo und alle
  Esstage bereits `session.add` und `flush` gesehen haben. Getragen wird das allein vom
  Rollback der Schreibschicht — `TransactionRoute` committet nur, wenn der Handler nicht wirft.
  Kein Test dieser Datei schickt einen unbekannten Code, und keiner zählt nach einer Absage
  Zeilen: `test_a_second_running_subscription_is_refused` prüft die 400 und sonst nichts.
Gelesen: `register_for_meals` und `tests/test_mensa.py` vollständig.
Vorschlag: Den Variantencode vor dem ersten `add` auflösen, dazu ein Test, der nach der
  Absage `meal_subscriptions` zählt.
```

```
[MENSA-R7] Klasse 8 · POST /meal-subscriptions/{id}/termination, Sekretariatsweg
Setzt das Sekretariat `ends_on` zurück (Abgangsweg, „auch eines in der Vergangenheit"), bleiben
  Esstage stehen, deren `valid_from` hinter dem neuen Ende liegt.
  `trg_meal_subscription_days_period` feuert nur beim Schreiben eines Tages, nicht beim
  Verkürzen des Abos, und die Route zieht die Tage nicht mit. Die Tagesliste fällt nicht darauf
  herein (`subscription_days_on` filtert über `MealSubscription.ends_on`), `_subscription_out`
  liefert sie aber weiter aus.
Gelesen: `terminate_subscription` gegen die Migration der Domäne.
Vorschlag: Die Tage beim Verkürzen auf `ends_on` mitziehen oder ihr Ende in derselben
  Transaktion setzen.
```

```
[MENSA-R8] Klasse 4 · POST /children/{child_id}/meal-subscription — „eingeschrieben"
Plan und Block: „nur ein eingeschriebenes Kind der Realschule". Die Route prüft beides in einer
  Bedingung, geprüft ist nur die Schulform.
Gemessen: `or child.entry_date is None` entfernt — 38 grün. Umgekehrt wird der Schulform-Teil
  allein rot (`test_a_primary_school_child_gets_no_subscription`, dessen Kind ein `entry_date`
  trägt).
Vorschlag: Ein Realschulkind ohne `entry_date` in die Welt und ein Test darauf.
```

```
[MENSA-R9] Klasse 4 · POST /meal-subscriptions/{id}/days — „nicht über ends_on hinaus"
Plan schreibt die Regel aus, kein Constraint trägt sie.
Gemessen: `if valid_from > subscription.ends_on:` auf `False` — 38 grün.
Vorschlag: Ein Test, der über ein gekündigtes Abo hinaus Tage bucht.
```

```
[MENSA-R10] Klasse 4 · POST /meal-subscriptions/{id}/reduction — nicht laufender Wochentag
Die Route weist einen Wochentag ab, der auf dem Abo nicht läuft (`len(hit) != len(wanted)`);
  ohne sie antwortet sie 200 und ändert nichts, was für den Aufrufer wie ein Erfolg aussieht.
Gemessen: Bedingung auf `False` — 38 grün.
Vorschlag: Ein Test, der einen nicht gebuchten Wochentag verringert.
```

```
[MENSA-R11] Klasse 4 · GET /meal-variants — „nur die aktiven"
Plan schreibt es aus, kein Test ruft die Route überhaupt auf.
Gemessen: `.where(MealVariant.is_active)` entfernt — 38 grün. `_variant_id` trägt denselben
  Filter und hat denselben Stand.
Vorschlag: Eine deaktivierte Variante in die Welt, dazu je ein Test auf Liste und Eintrag.
```

```
[MENSA-R12] Klasse 3 · Der eingefrorene Termin erreicht die Optigem-Aufgabe nicht
`tests/test_mensa.py` schreibt im Kopf aus, der Termin sei je Test eingefroren. Die
  `frozen`-Fixture patcht allein `app.routers.mensa._today`. Die Zusicherung
  „Essensabo Mo, Mi" in `test_registering_writes_...` entsteht aber in
  `optigem_billing_text` (`app/services/querschnitt.py`), das `datetime.now()` liest und das
  Abo über `ends_on >= today` sucht. Sie misst damit die Wanduhr des Prüfrechners: Ab dem
  1. August 2027 findet die Abfrage das Abo nicht mehr und der Test wird rot, ohne dass sich
  etwas geändert hätte.
Gelesen: `optigem_billing_text` gegen die `frozen`-Fixture.
Vorschlag: Die Uhr des Dienstes über denselben Weg einfrieren wie die des Routers.
```

```
[MENSA-R13] Klasse 0 · Das Prüfrezept selbst: die Aufräumzeile zerstört Wertelisten
Nicht die Domäne, aber jeder Lauf nach diesem Prompt — auch die zwei, die parallel zu diesem
  laufen. `prompts/api-pruefen.md` gibt zum Aufräumen nach einer roten Messung:
    TRUNCATE change_log, persons, families, cleaning_cycles, configured_values,
             contract_texts, sharepoint_libraries RESTART IDENTITY CASCADE
  `contract_text_kinds` trägt `fk_contract_text_kinds_working_library` auf
  `sharepoint_libraries`. CASCADE nimmt die Werteliste deshalb mit, und mit ihr
  `holiday_session_types` und `contract_kind_attachments`.
Gemessen: Erster Messlauf 23 von 24 Mutationen rot — darunter eine, die eine Route mutiert, die
  kein Test dieser Datei aufruft. Nullpunkt danach 3 passed, 35 errors, alle mit
  `fk_contract_texts_kind: Key (code)=(meal_terms) is not present in table
  contract_text_kinds`. Nach `down -v`, Neuaufbau und Migration wieder 38 grün; mit
  `academy_categories` statt `sharepoint_libraries` in der Zeile bleibt der Nullpunkt vor und
  nach dem Truncate bei 38 grün.
Vorschlag: `sharepoint_libraries` aus der Zeile streichen und `academy_categories` aufnehmen —
  die überlebt einen Truncate von `persons`/`families` und kollidiert nach einer roten Messung
  über `uq_academy_categories_code`.
```

## Angesehen, nicht als Fund gewertet

- **Die Einsichtsstufe steht an einer Stelle.** `_reach_child_to_write` trägt sie für alle fünf
  schreibenden Routen; ohne den `write=True`-Zweig wird der Lauf rot.
- **Die enge Rolle `backend_kitchen` trägt wirklich.** Ohne den `narrow_role`-Block scheitert
  der Lauf an `InsufficientPrivilegeError: permission denied for table child_meal_profiles` —
  der GRANT ist echt, nicht nur der `if`.
- **Der Ownership-Check am Kind-Pfad** (`GET`/`PUT meal-profile`, `POST meal-subscription`) ist
  geprüft: ohne ihn „assert 200 == 404".
- **Die Schulform-Grenze der Schulleitung** ist an der Familienansicht und an der Abo-Liste
  geprüft; beide Mutationen werden rot.
- **Die drei Herkünfte der Tagesliste**: die Akademie-Herkunft ist geprüft (Mutation rot), und
  dass ein Kind nur einmal daraufsteht, hält `page.count("Lena Mensa") == 1`.
- **Fehlerklasse 6**: keine Route dieser Domäne ruft Graph oder verschickt Mail — der Block
  schreibt „keine Mail, aus keinem Anlass" aus. `raise_task` schreibt in derselben Transaktion,
  `TransactionRoute` schließt sie vor der Antwort.
- **Fehlerklasse 3**: keine Zusicherung dieser Datei hängt an einer leeren Liste; der einzigen
  `== []`-Zeile geht eine nicht-leere voran.
- **`GRANT UPDATE (meal_subscription_id, …)` auf `meal_subscription_days`** erlaubt, einen
  Esstag auf ein fremdes Abo umzuhängen. `__change_anchor__` ist dort `None`, die Regel aus
  `wb-backend/CLAUDE.md` §6 greift wörtlich nicht — genannt, nicht gewertet.
- **`GET /meal-variants` und `GET /meal-prices` ohne Rollentor**: der Plan sagt „jede
  Mitarbeiterrolle; Erziehungsberechtigte", und `get_current_user` bildet genau das ab.
