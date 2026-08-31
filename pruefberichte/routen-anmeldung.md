# Prüfbericht: Routen der Anmeldung

`app/routers/anmeldung.py` (54 Routen), `tests/test_anmeldung.py` (93 Tests) gegen
[`api/anmeldung-api.md`](../api/anmeldung-api.md) und [`api/gemeinsam.md`](../api/gemeinsam.md).

Nullpunkt: `pytest tests/test_anmeldung.py` — 93 passed. Arbeitsbaum `../wbp-anmeldung`, eigene
Datenbank `wbp-anmeldung`. 38 Sicherungen herausgenommen, 12 davon wurden rot; dazu vier Sonden, die
eine Antwort gelesen und Zeilen gezählt haben, statt eine Bedingung zu entfernen. Die Zahl der
Routen stimmt mit der Gegenprobe des Plans überein (54).

## Funde

```
[ANMELDUNG-R1] Klasse 5 · POST /applications/{id}/withdrawal, PUT /applications/{id}/waiting-confirmation
Plan: „Priorität und Position auf der Warteliste nie" (07 Z1; Block 07: „weder die Priorität noch
  ihre Position"); die enge Rolle „die eigene Einschätzung" nennt der Plan an GET /applications und
  GET /applications/{id} und an keiner dritten Route. Beide Routen hier stehen den Eltern offen und
  antworten mit ApplicationRowOut, und _application_rows liest darin assessed_level_id in einem
  narrow_role(ADMISSIONS)-Block. Der Elternteil bekommt damit beides: die Priorität und die
  Einschätzung der Lehrkräfte, „das engste Zugriffsprofil nach den Art.-9-Daten".
Gemessen: Sonde als as_mother, Antwort gelesen — withdrawal gibt
  `"assessed_level_code": "gym", "waiting_priority": 9`, waiting-confirmation `"waiting_priority": 7`.
  Dazu zwei Mutationen: waiting_priority=None erzwungen → 93 passed, assessed_level_code=None
  erzwungen → 93 passed. Kein Test sieht eines der beiden Felder, an keiner Route.
Vorschlag: beiden Routen ein schmales Antwortmodell für den OTP-Pfad geben — oder ApplicationRowOut
  maskieren, wie read_application es tut —, dazu je ein Test, der die Antwort liest.

[ANMELDUNG-R2] Klasse 3 · POST /applications/{id}/withdrawal
test_after_the_release_of_the_contract_it_is_a_departure behauptet „nach der Freigabe des Vertrags
  geht dieser Weg nicht mehr" und prüft dafür `status_code == 400`. Die 400 kommt aus der falschen
  Bedingung: Die Freigabe setzt selbst `application.ended_at`, und die Prüfung „That application has
  already ended" steht vor der Prüfung auf den freigegebenen Vertrag. Der Test hält also auch dann,
  wenn die Regel, die er benennt, ganz fehlt.
Gemessen: `if released is not None: 400` entfernt → 93 passed. Die andere Sicherung derselben Route
  (`application.ended_at is not None`) einzeln entfernt → ebenfalls 93 passed. Keine der beiden ist
  belegt; zusammen erzeugen sie die erwartete 400.
Vorschlag: den Test auf die Fehlermeldung stellen oder auf eine Bewerbung ohne `ended_at`.

[ANMELDUNG-R3] Klasse 3 · POST /contracts/{contract_id}/submission
test_the_submission_is_only_for_the_school_contract legt nur einen Schulvertrag vor und prüft, dass
  es klappt. Den Fall, den sein Name trägt — ein Hortvertrag, „das Sekretariat prüft und legt hier
  nicht vor" (09) —, ruft er nie auf.
Gemessen: `if contract.contract_type != "school": 400` entfernt → 93 passed.
Vorschlag: einen Hortvertrag vorlegen lassen; erwartet 400.

[ANMELDUNG-R4] Klasse 3 · GET /applications/{application_id}
test_a_parent_never_learns_a_decision_before_its_release sichert `waiting_priority is None` zu,
  entscheidet aber mit `status_code: "rejected"` — und set_decision setzt waiting_priority nur bei
  „waiting", sonst None. Die Spalte ist in diesem Test leer, die Zusicherung läuft ins Leere.
Gemessen: die Maskierung `waiting_priority=None if user.is_guardian else …` durch
  `waiting_priority=application.waiting_priority` ersetzt → 93 passed.
Vorschlag: den Test auf „waiting" samt gesetzter Priorität stellen.

[ANMELDUNG-R5] Klasse 1 · POST /children/{child_id}/sepa-mandates
Plan: „weicht der Kontoinhaber ab, stehen Anschrift und Mailadresse am Mandat" — der abweichende
  Inhaber kommt als Name. `body.account_holder_person_id` wird gegen nichts geprüft, weder gegen die
  Familie des Kindes noch gegen den Token. Dieselbe Id wird anschließend zur `person_id` der
  erzeugten `signatures`-Zeile („Name the person who signs"): Eine fremde Person bekommt eine
  Unterschrift unter ein Lastschriftmandat, das sie nie gesehen hat.
Gemessen: Sonde als as_mother mit der `account_holder_person_id` der fremden Mutter → 201, und die
  angelegte `signatures`-Zeile trägt genau diese fremde person_id.
Vorschlag: account_holder_person_id gegen persons_of_family(child.family_id) prüfen, sonst 404.

[ANMELDUNG-R6] Klasse 1 · GET /children/{child_id}/sepa-mandates
Plan: „nur Kinder der eigenen Familien". Die Bedingung steht im Router (reach_child), aber kein Test
  belegt sie: Die schreibende Schwesterroute hat ihren Test (fremdes Kind → 404), die lesende nicht.
Gemessen: reach_child durch load_child ersetzt → 93 passed (zweimal gemessen).
Vorschlag: ein Test, in dem as_mother die Mandatsliste von world.other_child abruft und 404 bekommt.

[ANMELDUNG-R7] Klasse 4 · achtzehn Regeln, die kein Constraint trägt und kein Test hält
Je Zeile: die Bedingung im Router entfernt, Suite blieb grün (93 passed). Der Plan schreibt jede
  davon aus, die Datenbank fängt keine.

| Route | Regel, die niemand hält |
|---|---|
| `PUT /applications/{id}/admission-slot` | „für die Eltern bis zum Beginn des eigenen Fensters" (06 Z3) |
| `PUT /applications/{id}/admission-slot` | das gewählte Fenster hat schon begonnen |
| `PUT /applications/{id}/admission-slot` | eine beendete Bewerbung bucht nicht mehr |
| `PUT /applications/{id}/admission-slot` | „abgesagte Tage fallen heraus", und ein nicht freigegebener Tag ist nicht buchbar (06 Z3) |
| `PUT /applications/{id}/waiting-confirmation` | nur eine Bewerbung, die einen Warteplatz hält (07 Z4) |
| `PUT /contracts/{id}/responses/{person_id}` | ein freigegebener Vertrag nimmt keine Antwort mehr |
| `POST /contracts/{id}/signatures` | ein freigegebener Vertrag nimmt keine Unterschrift mehr |
| `POST /contracts/{id}/release` | keine zweite Freigabe |
| `POST /care-module-agreements/{id}/release` | keine zweite Freigabe (09 Z6) |
| `POST /contracts/{id}/termination` | keine zweite Kündigung |
| `POST /applications/{id}/withdrawal` | keine zweite Beendigung (siehe R2) |
| `PATCH /applications/{id}/record` | `record_outcome` nur „completed" oder „no_show" (06 Z6) |
| `PUT /contracts/{id}/responses/{person_id}` u. a. | „wer nur lesen darf oder gesperrt ist, wird nicht erwartet" — der 403 in `_acting_person` (08 Z1) |
| `GET /contracts/{contract_id}` | derselbe Satz als Filter in `_expected`: erwartet wird nur `access_levels.code = 'full'` |
| `POST /care-contracts`, `POST /contracts/{id}/module-agreements` | ein Wochentag läuft von 1 bis 5 |
| `PATCH /enrolment-windows/{id}` | ein Fenster schließt nach seinem Öffnen |
| `POST /children/{child_id}/sepa-mandates` | Kontoinhaber entweder als Person oder als Name, nie beides und nie keines |
| `GET /admission/targets`, `GET /care/application-context` | „Erziehungsberechtigte" — der 403 für eine Mitarbeiterrolle |

Vorschlag: je Zeile ein Test; die vier Buchungsregeln zuerst, weil nur sie einen Platz vergeben, den
  ein anderer schon hat.

[ANMELDUNG-R8] Klasse 5 · PUT /contracts/{id}/responses/{person_id} und …/data-review
Plan: „Erziehungsberechtigte; `secretariat`, `school_management`" für beide Zeilen; Block 08
  „Sonderfälle" nennt für den offiziellen Umweg ebenfalls nur Sekretariat und Schulleitung, und 09
  kennt gar keine Annahme oder Ablehnung. _acting_person() prüft aber
  require_staff(_SECRETARIAT, BRANCH_ROLE, _DAY_CARE) — der Helfer ist mit
  POST /contracts/{id}/signatures geteilt, wo `day_care_management` laut Plan hingehört, und vererbt
  die Rolle an die beiden Routen, die sie nicht tragen.
Gemessen: nein, gelesen.
Vorschlag: die erlaubten Rollen je Route an _acting_person übergeben.

[ANMELDUNG-R9] Klasse 8 · POST /care-contracts
CareContractIn trägt ein Feld `family_id`, das die Route nirgends liest: Der Zweig für die unbekannte
  Familie legt über create_family() immer eine neue an, auch wenn der Aufrufer eine vorhandene
  benennt. Der Plan kennt hier nur „die eigene Familie, wo es sie gibt", und die trägt `child_id`.
Gemessen: nein, gelesen.
Vorschlag: das Feld streichen.

[ANMELDUNG-R10] Klasse 5 · GET /contracts/{contract_id}
Der Plan zählt auf, was die Route zeigt: „wer angenommen, durchgesehen und unterschrieben hat, was
  noch fehlt, welche Fassung gilt". ContractOut gibt zusätzlich `released_by` aus, und das ist der
  Aktor-String der Gegenzeichnung (`entra:<oid>`); er geht unverändert an die Eltern.
Gemessen: nein, gelesen.
Vorschlag: `released_by` für den OTP-Pfad weglassen.

[ANMELDUNG-R11] Klasse 8 · POST /contracts/{contract_id}/submission
Plan und Block 08 Z4: Die Aufgabe entsteht „bei der Schulleitung **dieser Schulart**". raise_task()
  kennt nur ein `sync_targets`-Ziel ohne Schulart, die Aufgabe erreicht also jede Schulleitung. Das
  Schema trägt die Unterscheidung nicht — der Fund liegt zwischen Plan und Schema, nicht im Router,
  und wiegt deshalb schwerer als eine Abweichung im Bau.
Gemessen: nein, gelesen.
Vorschlag: den Satz im Plan auf „bei der Schulleitung" zurücknehmen oder `sync_tasks` eine Schulart
  geben; beides ist eine Entscheidung, keine Reparatur.

[ANMELDUNG-R12] Klasse 6 · jede Route, die _store_signature_image() ruft
Das Bild geht nach SharePoint, bevor die Zeile steht, die es benennt. Bricht die Transaktion danach
  ab — unbekannter Modulcode, verletzter CHECK —, bleibt die PNG in der Bibliothek liegen, und
  clear_signature_images() findet sie nie, weil sie an keiner `signatures`-Zeile hängt. Die
  Datenbank ist sauber, die Bibliothek nicht.
Gemessen: nein, gelesen; die Gegenprobe für die Datenbankseite steht unten.
Vorschlag: eine Zeile im Plan, dass die Bibliothek verwaiste Bilder tragen darf — oder den Upload
  hinter den letzten Flush ziehen.
```

## Angesehen, nicht als Fund gewertet

- **Klasse 2 gemessen und entkräftet.** Der Hortantrag einer unbekannten Familie mit unbekanntem
  Modulcode legt über `create_family()` Familie, Person und Kind an und wird danach mit `400`
  abgewiesen. Sonde: `families 2->2, children 2->2` — die `HTTPException` reißt die Transaktion des
  Requests ab, und `TransactionRoute` committet nur einen zurückgekehrten Handler. Kein halb
  geschriebener Vorgang.
- **`POST /applications` schreibt vor der Zahlung** — `kindergartens` und `previous_schools`. Der
  Plan nennt das als ausdrückliche Ausnahme zu „legt nichts an", samt Preis (Dublette).
- **`PUT /applications/{id}/deadline`** steht im Plan als „unbeschränkt", der Router lässt eine
  Schulleitung über `_reach_application` nur ihre eigene Schulart. Enger als der Plan und
  gleichförmig mit jeder Nachbarroute — keine Abweichung, die etwas öffnet.
- **`_reach_contract` lässt `day_care_staff` an einen Hortvertrag**, aber keine Route, die den Helfer
  ruft, lässt diese Rolle durch ihr eigenes Rollentor. Nicht erreichbar.
- **Beide engen Rollen sind belegt, nicht behauptet.** `test_the_own_reading_is_written_under_its_own_role`
  und `test_the_runtime_role_cannot_write_a_bank_detail` fragen `has_column_privilege` gegen die
  echte Datenbank; sie prüfen den GRANT und nicht nur die Route.
- **Die vier Läufe und die Idempotenz des Rückrufs** tragen je einen Test, der ein zweites Mal
  aufruft und zählt, dass nichts Zweites entsteht — Fehlerklasse 7 fand hier nichts.
- **Die Ownership-Bedingung hält an sieben gemessenen Stellen**: `_reach_application`,
  `_reach_contract`, `_own_branch`, `_acting_person`, `GET /admission/targets`, `POST /applications`
  und `POST /children/{child_id}/sepa-mandates` wurden einzeln entfernt und wurden einzeln rot. Die
  Ausnahme ist R6.

## Wo dieser Lauf aufgehört hat

38 Mutationen und vier Sonden. Nicht gemessen wurden die Regeln der beiden Preistabellen jenseits
ihrer Gültigkeitsprüfung, `_slot_starts` jenseits seines einen Tests und die Mail-Wege der vier
Läufe; für sie stand Lesen.
