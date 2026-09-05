Stand: c4ef05a, Nullpunkt: 806 Tests grün

# Gesamtlauf über die acht Domänenberichte

Kein Arbeitsbaum, keine eigene Datenbank, keine Mutation — im Hauptbaum, lesend und zählend.
Grundlage sind die acht Berichte, die alle `Stand: c4ef05a` im Kopf tragen: `klassenorganisation`,
`payments`, `auth`, `mensa`, `ferien`, `querschnitt`, `rechnungsfreigabe`, `stammdaten`. Die vier
weiteren Dateien in diesem Ordner (`anmeldung`, `cleaning`, `elternbonus`, `gesundheit`) stammen aus
einem früheren Zyklus (`1569109`) und zählen hier nicht mit; ihre Domänen sind unten nur dort
genannt, wo eine Zahl über alle Router läuft.

## 1. Plan gegen Router über alle Domänen

**240 Routen** in dreizehn Routern (239 fachlich, dazu `GET /health`), **247 Planzeilen** (241 verschiedene Method-Pfad-Paare) in zehn
`api/*.md`. Verglichen wurde in beide Richtungen und maschinell, gegen die 42 Tabellen mit dem
einheitlichen Kopf `| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | … |`.

**Methode und Pfad: drei Abweichungen, alle bereits benannt.**

| Befund | Wo |
|---|---|
| `GET /contracts/{contract_id}/document` steht im Plan, im Router nicht | `anmeldung-api.md:178` |
| `GET /photo-consent-records`, `PATCH /photo-consent-records/{id}` stehen im Plan, im Router nicht | `querschnitt-api.md`, = QS-R14 |
| `PUT /children/{child_id}/health-record/answers/{trait_type_code}` heißt im Router `{type_code}` | `gesundheit-api.md` gegen `app/routers/gesundheit.py` |

Alles Weitere deckt sich: Die vier Plan-Einträge, die auf eine andere Domäne zeigen
(`GET /children/{id}/photo-consent`, `PUT /children/{id}/enrolment`, drei `cleaning`-Routen in
`stammdaten-api.md`/`querschnitt-api.md`), sind Randverweise und dort gebaut. Die zwei Router-Routen
ohne eigene Planzeile (`DELETE /care-module-prices/{id}`, `DELETE /tuition-fees/{id}`) stehen als
`DELETE /…` in der Zeile ihres `PATCH`.

**Rolle: eine Abweichung über alle Domänen.** Von 189 Planzeilen mit Rollencodes sind 144
maschinell vergleichbar (44 nennen keine feste Liste — „jede Mitarbeiterrolle", „die anbietende
Rolle", „die Klassenlehrkraft"; 35 Routen haben kein Rollentor, weil die Reichweite die Daten
entscheidet; 2 lesen die Rolle erst zur Laufzeit). `admin` ist auf beiden Seiten
herausgerechnet — er erbt an jeder Route (`api/gemeinsam.md`).

Von den 144 weichen **zwei Routen** ab, und beide sind derselbe Fund:
`POST /meal-subscriptions/{id}/days` und `DELETE /meal-subscription-days/{id}` nehmen `BRANCH_ROLE`,
der Plan nennt nur `secretariat` (= MENSA-R3). Die vier weiteren Treffer der Maschine sind keine:
`GET /children/{id}/documents` (`teacher` „soweit freigeschaltet", im querschnitt-Bericht
entkräftet), `GET /documents/{id}/content` und `POST /persons/{id}/email/confirmation` (Planzelle
verweist statt aufzuzählen), `POST /claim-templates` (die Rolle hängt an der Zahl der Anteile).

**Ein neuer Fund entsteht damit nicht — und das ist die Aussage.** Der Bau trifft den Plan bei
Methode, Pfad und Rolle; was fehlt, fehlt an den Tests.

**Einschränkung, Richtung „Plan schränkt ein, Router nicht": null.** Fünf Treffer, alle
Falschmeldungen des Klassifikators: `GET /auth/roles` liest die eigene Sitzung, die zwei
`class_representatives`-Routen tragen `_class_to_read`/`_class_to_write`,
`GET /expense-claims/travel-suggestions` filtert über `_me()`, `PUT /tasks/{id}` über die Zielrolle
— jede dieser vier Bedingungen ist im jeweiligen Domänenbericht gemessen und rot geworden. **Keine
Route ist grün und offen zugleich**; die Klasse-1-Funde der acht Berichte betreffen ausnahmslos
Bedingungen, die *stehen* und die kein Test hält.

**Richtung „Plan sagt unbeschränkt, Router schränkt ein": zwölf Treffer, keiner davon ein Fund.**
Sie entstehen, wo ein Handler einen Reichweiten-Hebel für die bloße Existenzprüfung nimmt
(`reach_family_as_staff`, `_reach_family_both_doors`) oder wo ein `require_staff` davor schon
abweist — `PUT /children/{id}/measles-proof` etwa ruft `reach_child`, aber erst hinter
`require_staff(user, _SECRETARIAT)`, und ein Elternteil kommt dort nie an.

## 2. Die zwei Zahlen

| | Zahl |
|---|---|
| Routen | **240** |
| davon mit mindestens einem Testaufruf | **232** |
| Routen mit einer Einschränkung je Datensatz im Handler | **119** |
| davon mit einem Test, der eine **fremde Kennung** an einem berechtigten Aufrufer probiert | **64** |

**Die Differenz sind 55 Routen**: Die Bedingung steht in der Query, und kein Test würde bemerken,
wenn sie verschwände. Genau das haben die acht Läufe an ihren eigenen Routen einzeln gemessen —
jede solche Messung blieb grün.

Gezählt wurde so: eine Route trägt eine Einschränkung, wenn ihr Handler einen der geteilten Hebel
ruft (`reach_family`, `reach_child`, `staff_sees_child`, `reach_family_as_staff`, `is_class_teacher`,
`cared_for`, `branches_of`, `_reach_*`, `_visible`, `_may_write`, `_branch_allows`,
`_load_contact`/`_load_guardianship`); sie trägt einen Fremd-Id-Test, wenn eine Testfunktion sie
aufruft, dabei eine fremde Kennung oder einen fremden Aufrufer benennt (`other_…`, `foreign…`,
`stranger`, `another`, `…_b`) **und** eine 403 oder 404 zusichert. Die Zahl ist die strenge Lesart:
Sie schreibt einer Route nichts gut, was nur der geteilte Hebel an anderer Stelle belegt. Der
`stammdaten`-Bericht zählt seine 27 Einschränkungsrouten deshalb mit 18 statt 15 — er rechnet fünf
Routen den anderswo geprüften Hebel an. Beide Lesarten sind vertretbar; die Differenz zwischen den
zwei Zahlen ändert sich dadurch nicht wesentlich.

Die acht Routen ohne jeden Testaufruf, über alle Testdateien geprüft:

```
GET  /tuition-fees                      GET   /meal-variants
GET  /meal-prices                       GET   /ledger-accounts
GET  /claim-templates                   GET   /children/{child_id}/departure
PATCH /classes/{class_id}               PATCH /persons/{person_id}/guardian
```

Fünf davon sind Wertelisten-Leser (= MENSA-R11), drei sind der Fund STAMM-R8.

## 3. Der volle Lauf

Auf `c4ef05a`, im Hauptbaum, gegen die laufende Compose-Datenbank. In den Bericht kommt der
Rückgabewert:

| Lauf | rc |
|---|---|
| `podman-compose --profile tools build test` | 0 |
| `pytest` (806 passed, 1 warning, 64,7 s) | 0 |
| `ruff check .` | 0 |
| `ruff format --check .` (89 Dateien) | 0 |
| `mypy app` (67 Dateien) | 0 |
| `./schema-check.sh` (14 Dateien, jede einzeln rc=0) | 0 |

**Die Testzahl stimmt.** 806 ist der Nullpunkt, mit dem der Zyklus begann; die acht Testdateien
tragen heute genau die Zahlen aus den acht Berichtsköpfen (28, 18, 26, 38, 56, 36, 61, 64 = 327 der
806). Keine Session hat etwas liegen lassen.

Am Rand: `README.md` spricht von „den dreizehn `*-schema-check.sql`", es sind seit `akademie`
vierzehn.

## 4. Die Gegenprobe aufs Aufräumen

| Probe | Ergebnis |
|---|---|
| `git status` (beide Repos) | sauber, bis auf die neun Berichtsdateien dieses Zyklus |
| `git worktree list` | nur der Hauptbaum |
| `podman ps -a` | vier Container, alle `wb-backend_*`; kein `wbp-` |
| `podman volume ls` | `wb-backend_db-data`, `_caddy-data`, `_caddy-config`; kein `wbp-` |
| `podman images` | **nicht sauber**: 13 `wbp-`-Images |

Die 13 liegengebliebenen Images gehören `wbp-anmeldung` (2), `wbp-elternbonus` (7), `wbp-cleaning`
(2) und `wbp-smoke` (2) — **keins den acht Domänen dieses Zyklus**. Die acht Läufe haben ihr
`--rmi local` also gemacht; die Reste stammen aus dem vorigen. Sie stellen dem nächsten Lauf jener
vier Domänen die Falle aus `api-pruefen.md` wieder auf und gehören gelöscht. Daneben liegen neun
`spur-*_test`/`spur-*_migrate`-Images aus den Schema-Läufen, die die Gegenprobe nicht nennt.

## 5. Die schwersten Funde aus den acht Berichten

**83 Funde**, kein einziger Bericht ohne. Sechs Berichte weisen ihre Messreihe als Zahl aus: 194
herausgenommene Sicherungen, **147 rot, 47 grün** (`klassenorganisation` 20/16, `mensa` 25/20,
`ferien` 40/29, `querschnitt` 27/14, `rechnungsfreigabe` 42/38, `stammdaten` 40/30). `auth` und
`payments` messen ebenfalls, weisen aber keine Gesamtzahl aus.

**Eine fremde Zeile wird erreichbar** — die Klasse, für die es diesen Zyklus gibt:

1. **[AUTH-R1]** `PUT /auth/identity` nimmt jede real angelegte fremde Person an. Gemessen: Sitzung
   läuft unter der fremden Identität, `change_log` trägt deren Aktor, 26 Tests bleiben grün. Was den
   heutigen Test hält, ist ein Fremdschlüssel, nicht die Regel.
2. **[STAMM-R1]** `GET /employees/selectable` steht dem OTP-Pfad offen und gibt jeder Elternsitzung
   den vollständigen Mitarbeitendenbestand. Der Test hält die Abweichung fest, statt sie zu finden.
   **Es ist die einzige Route des Repos, deren Wache eine Elternsitzung auf eine Listenroute lässt.**
3. **[QS-R1] bis [QS-R8]** — acht Ownership-Bedingungen in `querschnitt`, jede einzeln durch
   `load_child` ersetzt, jedes Mal 36 grün: Zustimmungssatz, Unterlagenliste (beide Türen),
   Dateiinhalt, Ablegen, Rücknahme, Anfordern. Dazu **[QS-R7]**: das Sekretariat legt die Zustimmung
   einer *beliebigen* Person an — hier gibt es gar keine Bedingung zum Herausnehmen.
4. **[FERIEN-R3]** `POST /holiday/sessions/{id}/cancellation` — beide Schranken ungeprüft. Gemessen:
   Ein Elternteil sagt einen ganzen Termin ab, samt Erstattungsaufgaben und Mail an alle Familien.
5. **[MENSA-R1]** vier Abo-Routen: Der Check steht, kein Test dieser Datei ruft je eine fremde
   `meal_subscription_id`.
6. **[FERIEN-R4]**, **[FERIEN-R5]**, **[klassenorganisation-R1]** — fremde `family_id` beim Buchen,
   jede Mitarbeiterrolle in der Storno-Erklärung, `accounting`/`executive_management` an jeder
   Klasse.

**Daten werden halb geschrieben oder eine Regel wirkt nicht:**

7. **[STAMM-R2]** `confirm_email` zählt die Fehleingaben in einer Transaktion, die die 400 gerade
   zurückrollt. Mit einer Wegwerf-Sonde gemessen: `failed_attempts=0` nach dem Fehlversuch. Die
   fünf Versuche des Bestätigungscodes sind **nicht nur ungeprüft, sondern wirkungslos**; `auth.py`
   löst dasselbe Problem zwei Dateien weiter ausdrücklich andersherum.
8. **[rechnungsfreigabe-R1]** Ein weitergeleiteter Beleg lässt sich ein zweites Mal weiterleiten:
   zwei lebende Teile über denselben Betrag, das Deckblatt zeigt der Buchhaltung das Doppelte.
9. **[MENSA-R6]**, **[rechnungsfreigabe-R3]**, **[payments-R3]** — 400 nach dem ersten `flush`,
   Graph-Upload vor der Absage, halbe `holiday_bookings` hinter einem `None`.
10. **[STAMM-R7]** Der Ordnerzug nach SharePoint steht vor zwei weiteren Schreibern: rollt die
    Transaktion zurück, liegt der Ordner schon unter der neuen Kennung.

**Zu weite Rechte an der Datenbank** (Klasse 5, beide ohne Nutzer im Code):
**[payments-R6]** `GRANT UPDATE` auf neun Spalten von `payments`, obwohl keine Route eine Zahlung
ändert — Betrag, Referenz und Bestätigungszeitpunkt sind überschreibbar; **[AUTH-R2]**
`GRANT UPDATE (email, code_hash, purpose, …)` auf `login_codes`, wo `login_sessions` daneben die
Enge ausschreibt.

**Plan gegen Block** (wiegt schwerer, weil es sich beim nächsten Bau fortpflanzt):
**[FERIEN-R11]** die Warnung bei den letzten Plätzen — Block und Schema fordern den Lauf, der Plan
behauptet „kein Lauf", `app/runs.py` kennt ihn nicht, und `akademie` trägt dieselben zwei Spalten;
**[AUTH-R3]** der Klick-Link der Code-Mail, an dem `samesite="lax"` hängt;
**[rechnungsfreigabe-R6]** die Fahrt nach Ticket ohne Beleg; **[MENSA-R3]**, **[STAMM-R3]**,
**[STAMM-R5]**, **[klassenorganisation-R3]** — vier Rollen- und Reichweitensätze, in denen Plan und
Block auseinanderlaufen.

**Ohne Fund durchgekommen ist keine Domäne.** Am dünnsten fällt `klassenorganisation` aus (5 Funde,
16 von 20 Messungen rot), am dichtesten `querschnitt` (17 Funde, 13 von 27 Messungen grün).

## 6. Was keine einzelne Domäne sieht

```
[GESAMT-R1] Klasse 0 · das Räum-Rezept in prompts/api-pruefen.md
Sechs der acht Berichte melden denselben Schaden, jeder für sich und keiner voneinander:
`TRUNCATE … sharepoint_libraries … CASCADE` reißt über `fk_contract_text_kinds_working_library`
die Werteliste `contract_text_kinds` mit und über deren Code-Fremdschlüssel `contract_texts`,
`holiday_session_types`, `holiday_modules`, `holiday_module_prices` und `academy_offerings`.
Keine Migration außer dem Seed legt sie zurück. Der Absatz begründet die Zeile ausdrücklich damit,
dass `sharepoint_libraries` nicht in `WIPED` stehe — `tests/conftest.py:34` führt heute genau
`change_log, persons, families, cleaning_cycles, configured_values, contract_texts`, und der Grund
für das Fehlen ist nicht, dass die Tabelle vergessen wurde, sondern dass sie nicht geräumt werden
darf.
Gemessen (in den Berichten, nicht hier): querschnitt 13 verworfene Messungen, ferien die ganze
Reihe, stammdaten 5, auth 5, payments 4, mensa eine komplette Reihe samt falschem rotem Nullpunkt.
Das sind über dreißig Messungen, die kein Ergebnis hatten, und mindestens vier Datenbanken, die
nur über `down -v` samt Migration zurückkamen.
Vorschlag: `sharepoint_libraries` aus der Zeile streichen und die eine Fixture-Zeile gezielt
löschen (`DELETE FROM sharepoint_libraries WHERE code = …`); der Rest der Zeile ist die Liste aus
`tests/conftest.py`.
```

```
[GESAMT-R2] Klasse 4 · sieben Druckansichten, ein einziger Escaping-Test
Sechs Router bauen HTML von Hand und schützen 24 Stellen mit `html.escape`
(`anmeldung` 6, `stammdaten` 7, `cleaning` 4, `klassenorganisation` 3, `mensa` 2, `payments` 2).
In der ganzen Suite sichert **eine** Zeile eine escapte Ausgabe zu: `tests/test_cleaning.py:2185`.
Kein Constraint trägt hier etwas, und die Namen kommen aus der Datenänderung und der Bewerbung,
also von außen.
Gemessen (in den Berichten): klassenorganisation-R4 nimmt alle drei `html.escape` heraus — grün;
payments-R8 nimmt zwei heraus — grün. Zwei Domänen haben unabhängig dasselbe gefunden, und die
Zahl zeigt, dass es an fünf weiteren Ansichten genauso steht.
Vorschlag: je Druckansicht ein Name mit `<` oder `&` durch den vorhandenen Test, nicht sieben
neue Tests.
```

```
[GESAMT-R3] Klasse 8 · dieselbe Auflösung `entra:` → `employees.employee_id` an fünf Stellen
`app/core/security.py` (`_staff`, `branches_of`, `is_class_teacher`), `app/routers/cleaning.py:410`,
`app/routers/rechnungsfreigabe.py:150`. Dieselbe Datei hält die beiden Familien-Auflösungen
ausdrücklich zusammen, damit keine zweite Fassung entsteht — für die Mitarbeitenden-Seite gilt das
nicht, und der Router baut sie nach. Der rechnungsfreigabe-Bericht hat es für diesen Lauf notiert;
hier gezählt und bestätigt.
Gelesen, nicht gemessen.
Vorschlag: eine Hilfe `employee_of(session, user)` in `core/security.py`, die beiden Router darauf.
```

```
[GESAMT-R4] Klasse 8 · vier Sperren rechnen mit `hashtext`, eine ohne
`app/services/ferien.py:377`, `app/services/cleaning.py:295`, `app/services/anmeldung.py:543` und
`app/routers/anmeldung.py:1341` fahren `pg_advisory_xact_lock(hashtext(:key))`;
`app/routers/rechnungsfreigabe.py:1589` fährt `pg_advisory_xact_lock(:key)` mit dem blanken
Kalenderjahr. Die Wirkung bleibt Wartezeit, aber die abweichende Bauform ist die Sorte, die beim
nächsten Bau kopiert wird.
Gelesen, nicht gemessen.
Vorschlag: dieselbe Form wie an den vier anderen Stellen.
```

```
[GESAMT-R5] Klasse 5 · `staff_sees_child` endet mit `return TEACHER_ROLE in user.roles`
Der geteilte Hebel lässt jede Lehrkraft an jedes Kind — nicht nur an die Klassenliste, sondern
überall, wo `reach_child` steht. STAMM-R3 findet es an einer Route und misst den Preis
(`class_teaching_assignments` hat keinen Schreibpfad); der Satz gilt aber für alle Domänen mit
Kindbezug zugleich, und er steht in `security.py` als Zeile ohne Bedingung.
Gegenprobe in die andere Richtung: **genau eine** Route im ganzen Repo lässt eine Rolle durch ihr
Rollentor, die der Hebel danach nicht kennt — `GET /children/{child_id}/meal-profile` mit
`domestic_services_management` (= MENSA-R2). Es ist ein Einzelfall, kein Muster.
Gelesen und gezählt, nicht gemessen.
Vorschlag: den Satz aus STAMM-R3 an `staff_sees_child` entscheiden, nicht an der Klassenliste.
```

```
[GESAMT-R6] Klasse 8 · drei geplante Läufe fehlen, jeder von einer anderen Domäne bemerkt
`app/runs.py` führt 17 Läufe. Es fehlen: die Warnung bei den letzten Plätzen (FERIEN-R11, teilt sich
den Lauf laut `hebel.md` mit `akademie` — „es ist ein Lauf und nicht zwei"), der Lauf, der die
unzustellbaren Mails einsammelt (QS-R16, `container.md` trägt den Vorbehalt, der Plan nicht), und
der Jahreslauf am 1. August (stammdaten, TASK-142). Drei Berichte nennen je einen; keiner konnte
sehen, dass es drei sind und dass einer davon für zwei Domänen zugleich fehlt.
Gelesen: `grep low_places app/runs.py` leer, `undeliverable_at` nur im Graph-Fehlerpfad gesetzt.
Vorschlag: die drei in ein Ticket, den ersten mit dem Hinweis, dass `akademie` dieselben zwei
Spalten trägt.
```

```
[GESAMT-R7] Klasse 8 · „Admin erbt die Rechte der Verwaltung — an jeder Route"
`api/gemeinsam.md` sagt es ohne Ausnahme; `app/routers/rechnungsfreigabe.py` baut mit `_only()`
ausdrücklich eine, und begründet sie aus Block 12 („Der Admin sieht hier nichts"). Die Ausnahme ist
richtig gebaut und im Code begründet — sie fehlt in der Datei, die die Regel trägt, und der nächste
Bau liest dort weiter „an jeder Route".
Gelesen, nicht gemessen.
Vorschlag: einen Halbsatz in `gemeinsam.md`, der die Ausnahme samt ihrem Ort nennt.
```

## Angesehen, nicht als Fund gewertet

- **Die enge Rolle wird überall über denselben Hebel genommen.** `narrow_role(session, NarrowRole.…)`
  in sieben Routern, kein zweiter Weg zu einer geschützten Spalte, kein Router mit eigener Fassung.
- **Alle sieben Druckansichten stehen hinter `require_role`** und damit internen Rollen; die
  Listenroute über den OTP-Pfad ist die eine aus STAMM-R1 und keine zweite.
- **Die Nullpunkte sind untereinander konsistent** — 766 Testfunktionen, 806 gesammelte Tests; die
  Differenz sind parametrisierte Fälle, keine verlorene Datei.
- **Vier Domänen ohne Lauf melden das übereinstimmend** (`klassenorganisation`, `payments`,
  `rechnungsfreigabe`, `mensa`); `app/runs.py` bestätigt es.
- **Die vier Berichte des vorigen Zyklus** (`1569109`) wurden nicht gegen `c4ef05a` nachgezählt.
  Wo eine Zahl dieses Berichts über alle 240 Routen läuft, sind ihre Domänen enthalten; ihre Funde
  sind es nicht.
