# Mensa — Routen

Aus [`11-mensa.md`](../soll-prozesse/11-mensa.md); es gilt [`gemeinsam.md`](gemeinsam.md), und was
dort steht, wiederholt diese Datei nicht.

**Gegenprobe:** Die Ablauftabelle des Blocks hat **5 Zeilen**; alle fünf handeln im System — **4**
tragen eine Route, **1** einen [Lauf](#der-eine-lauf). Es gibt **16 Routen**; **8** nennen eine
Ablaufzeile, **8** einen Hebel oder einen Abschnitt des Blocks. Keine Abweichung.

Die Zeilen: Z1 → `GET /families/{family_id}/meals` · Z2 → `POST /children/{child_id}/meal-subscription`
und `PUT /children/{child_id}/meal-profile` · Z3 → `GET /meals/day-list` · Z4 → die vier Routen des
laufenden Betriebs · Z5 → der Lauf.

## Zwei Grenzen, die jede Route dieser Domäne einhält

- **Das Essen folgt dem Modul, wo eines eines trägt.** Für Hortkinder ([09](../soll-prozesse/09-hortvertrag.md))
  und für Kinder an einem Ferien- oder Werkstatttermin ([10](../soll-prozesse/10-ferienprogramm.md))
  erhebt diese Domäne **nichts** und berechnet **nichts** — sie liest. Was hier entsteht, ist das
  eigenständige Abo der Realschule und das Küchenprofil am Kind, und sonst nichts. Ein Grundschüler
  steht deshalb ohne eigene Anmeldung auf der Tagesliste, sobald sein Modul ein Essen trägt.
- **Nichts wartet auf jemanden.** Keine Freigabe, keine Entscheidung, keine Platzzahl, keine Mail,
  kein Dokument, keine Unterschrift und **keine Sofortzahlung** — eingezogen wird über das Mandat aus
  [08](../soll-prozesse/08-schulvertrag.md). Jede schreibende Route dieser Domäne gilt sofort, und
  die eigene Übersicht ist die Bestätigung ([`hebel.md`](../soll-prozesse/hebel.md#standardantworten)).

## Pfad

Vier Sachen tragen ihn, und alle vier stehen so im Block: das **Abo** (`/meal-subscriptions/…`, an
der Entstehung unter dem Kind), das **Küchenprofil** (`/children/{child_id}/meal-profile`), die
**Portalansicht** der Familie (`/families/{family_id}/meals`) und die **Werte** (`/meal-prices`,
`/meal-variants`).

**`/meals/` trägt allein die beiden Listen der Küche.** Sie gehören keinem Kind und keiner Familie,
sondern einem Tag bzw. einer Woche — für sie gibt es keinen anderen Anker. — Alternative: sie unter
`/children/…` hängen; Preis: ein Pfad, der ein einzelnes Kind verspricht und eine Menge liefert.

**Das Abo steht nicht unter der Familie.** Es hängt am Kind (`meal_subscriptions.child_id`),
Geschwister sind zwei Abos; die Familie steht nur dort im Pfad, wo das Portal die Familie anzeigt —
und dort trägt sie den Ownership-Check
([`gemeinsam.md`](gemeinsam.md#wer-darf-und-worauf-eingeschränkt)).

## Enge Rolle

**Eine, und sie ist gebaut: `backend_kitchen`** (`schema/mensa-schema.sql`, Migration der Domäne).
`backend_runtime` hat auf `child_meal_profiles` **kein `SELECT` auf `meal_variant_id`** — nur auf
Schlüssel, Kind und die Audit-Spalten. Daraus folgt für jede Route dieser Datei:

- **Jede Ansicht, die die Essensvariante zeigt, öffnet einen `narrow_role`-Block** derselben
  Transaktion — auch die der Eltern, die sie selbst eingetragen haben. Das ist kein Versehen des
  Schemas, sondern seine Aussage: „die engere Sicht liegt in der weiteren", und die Variante ist die
  einzige Angabe, die die Küche überhaupt bekommt.
- **Geschrieben wird sie ohne die Rolle** (`INSERT`, `UPDATE (child_id, meal_variant_id)` stehen bei
  `backend_runtime`), **zurückgelesen nicht**: Ein `RETURNING meal_variant_id` ist ein Lesen und
  scheitert — dieselbe Ebene wie `sepa_mandates.created_at` in
  [`anmeldung-api.md`](anmeldung-api.md). `PUT /children/{child_id}/meal-profile` gibt die Variante
  deshalb entweder gar nicht zurück oder liest sie im engen Block nach.

**Dieselbe Rolle trägt den Küchen-Ausschnitt der Gesundheitsangaben**: den Sichtkreis `kitchen`
([`gesundheit-api.md`](gesundheit-api.md)) über eine **View mit eigenem GRANT** statt über einen
Filter im Anwendungscode — die Grenze läuft **zeilenweise** über `health_field_visibility`, und ein
Spalten-GRANT kann keine Zeilen ausnehmen. Es ist der Aufstiegspfad, den `zugang.md` schon
beschreibt („View plus eigene DB-Rolle", `otp_eligible_persons`). — Alternative: die Werte unter
`backend_health` lesen und selbst auf den Sichtkreis filtern; Preis: die Küchenroute hielte eine
Rolle, die Diagnose, Attestlage und Notfallanweisung lesen darf, und der schmalste Ausschnitt des
Systems hinge an einem `if` statt an einem GRANT. Die Tagesliste liest `kitchen_health_traits`
(`child_id, description`), eine abgeleitete Sicht des Sichtkreises; was er trägt — Bezeichnung und
Beachten von Unverträglichkeit und Allergie —, steht als Seed in der Gesundheits-Domäne, und beide
Sichten entstehen dort, weil die Tabellen dorthin gehören.

**Die Küche ist kein Freigabeziel, sie erbt** (`schema/gesundheit-schema.sql`): Seit die Eltern je
Instanz freigeben, gilt über die Mensa-Tagesliste die Freigabe an die **Schule**, über die
Hortliste die an den **Hort** ([`ferien-api.md`](ferien-api.md), [09](../soll-prozesse/09-hortvertrag.md)).
Ohne diesen Satz wäre unbestimmt, was ein Kind isst, dessen Eltern die Schule freigegeben und den
Hort abgelehnt haben. Für diese Datei folgt daraus **eine** Änderung, und sie liegt in der
abgeleiteten Sicht und nicht in der Route: `kitchen_health_traits` nimmt die Freigabe an die Schule
in ihren Filter auf. Gebaut wird sie mit der Policy (`gesundheit-api.md`, TASK-157), nicht hier.

## Küchenprofil und Werte

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /meal-variants` — die Essensvarianten | [11](../soll-prozesse/11-mensa.md) „Was dabei erhoben wird" | jede Mitarbeiterrolle; Erziehungsberechtigte | unbeschränkt; nur die aktiven. **Keine Pflegeroute** — eine Werteliste entsteht im Seed und wächst über eine Migration ([`stammdaten-api.md`](stammdaten-api.md)) | liest | — |
| `GET /meal-prices` — die Staffel je Zahl der Esstage, der geltende und der angekündigte Betrag | [11](../soll-prozesse/11-mensa.md) „Was dabei erhoben wird" | jede Mitarbeiterrolle; Erziehungsberechtigte | unbeschränkt — **die ganze Staffel, nicht der eine Betrag, der auf dieses Kind passt**: „Der Monatsbeitrag steht als Summe daneben, bevor sie sich entscheiden" (Z1), und ein Tag mehr ändert den Rang. Eine angekündigte Erhöhung ist sichtbar, bevor jemand anmeldet | liest | — |
| `POST /meal-prices` — einen Betrag der Staffel ab einem Tag setzen | [`hebel.md`](../soll-prozesse/hebel.md#geld-und-fristen-im-system-alles-andere-fest) | `executive_management` | unbeschränkt; je Tageszahl und Tag einer (`uq_meal_prices`), Tageszahl 1–5 (`ck_meal_prices_days`). **Eine Liste für beide Wege** — dasselbe Abo-Kind und dasselbe Hortkind über 13 Uhr zahlen daraus (09, 11) | schreibt, `entra:` | — |
| `PATCH /meal-prices/{meal_price_id}` — einen angekündigten Betrag ändern | [`hebel.md`](../soll-prozesse/hebel.md#geld-und-fristen-im-system-alles-andere-fest) | `executive_management` | **nur solange sein Gültigkeitstag nicht erreicht ist**, sonst `400`; `now()` steht in keinem CHECK, die Regel prüft die Route — dieselbe Mechanik wie bei `care-module-prices` | schreibt, `entra:` | — |
| `DELETE /meal-prices/{meal_price_id}` — einen angekündigten Betrag zurücknehmen | [`hebel.md`](../soll-prozesse/hebel.md#geld-und-fristen-im-system-alles-andere-fest) | `executive_management` | wie oben; ein bereits gültiger bleibt stehen, „was schon berechnet ist, bleibt bei dem Betrag, der damals galt" | schreibt, `entra:` | — |
| `GET /children/{child_id}/meal-profile` — die Essensvariante dieses Kindes | [11](../soll-prozesse/11-mensa.md) „Was dabei erhoben wird" | `secretariat`, `school_management`, `domestic_services_management`, `day_care_staff`; Erziehungsberechtigte | nur Kinder der eigenen Familien; Schulleitung nur ihre Schulform; Hortkräfte nur die betreuten Kinder. **`canteen` steht nicht dabei**: Die Küche sieht ihre beiden Listen, und die Variante steht auf beiden — ein Kind einzeln nachzuschlagen hat sie keinen Anlass. Keine Zeile heißt „isst alles" und ist von der Vorgabe nicht zu unterscheiden | liest | `backend_kitchen` |
| `PUT /children/{child_id}/meal-profile` — die Variante eintragen oder ändern | [11](../soll-prozesse/11-mensa.md) Z2 | Erziehungsberechtigte; `secretariat` (Umweg) | nur Kinder der eigenen Familien; **eine sorgeberechtigte Person genügt, es gilt die letzte Handlung**. Sie steht am Kind und nicht am Abo: die Eltern eines Hortkindes tragen sie genauso ein, obwohl sie sich nie anmelden — und die Ferienbuchung fragt sie an derselben Route ab, wo ein Modul ein Essen trägt ([10](../soll-prozesse/10-ferienprogramm.md) Z3). **Keine `DELETE` daneben**: Zurück auf „isst alles" ist ein `PUT`, und die Zeile räumt der Lösch-Lauf | schreibt, `guardian:` / `entra:` | — |

## Das Abo

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /families/{family_id}/meals` — die Essensansicht der Familie: je Kind die Variante, das laufende Abo samt Tagen, Beginn und Ende, die **wählbaren Wochentage**, die durch ein Hortmodul mit Essen belegten, der Monatsbeitrag der aktuellen und der gewählten Tageszahl, der früheste Beginn und die drei Termine, bis zu denen was gilt | [11](../soll-prozesse/11-mensa.md) Z1, „Fristen und Termine" | Erziehungsberechtigte; `secretariat`, `school_management` | nur die eigenen Familien; Schulleitung nur, wenn ein Kind dieser Familie ihre Schulform trägt. **Sie ist zugleich die Bestätigung** jeder Handlung dieses Blocks — es geht keine Mail raus. Die [sparsame Ansicht](../soll-prozesse/hebel.md#sparsame-ansicht) filtert hier **nichts**: keine der einmal erhobenen Angaben kommt darin vor | liest | `backend_kitchen` |
| `POST /children/{child_id}/meal-subscription` — anmelden: Wochentage, Variante und die Zustimmung zu den Essensbedingungen in **einer** Transaktion; legt Abo, Tage, Küchenprofil und die Optigem-Aufgabe an | [11](../soll-prozesse/11-mensa.md) Z2 | Erziehungsberechtigte; `secretariat` (Umweg) | nur Kinder der eigenen Familien; **nur ein eingeschriebenes Kind der Realschule** — „ein Grundschüler isst über sein Modul oder gar nicht"; mindestens ein Wochentag; **kein Tag, den ein laufendes Hortmodul mit Essen schon abdeckt** — „je Kind und Tag gibt es höchstens ein Essen", und dass die Anwendung das prüft, sagt das Schema an `ex_meal_subscription_days_period`; kein zweites laufendes Abo (`ex_meal_subscriptions_period`). **Der Beginn wird gerechnet, das Ende ausgewählt**: der nächste Monatserste, frühestens der 1. Oktober (`ck_meal_subscriptions_start`), Ende der 31. Juli desselben Schuljahres. `terms_contract_text_id` friert die Fassung von `meal_terms` ein, die am Tag der Handlung gilt | schreibt, `guardian:` / `entra:` | — |
| `POST /meal-subscriptions/{meal_subscription_id}/days` — mehr Tage, gültig ab dem nächsten Monatsersten | [11](../soll-prozesse/11-mensa.md) Z4 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie; jederzeit und ohne Frist; nicht über `ends_on` hinaus; kein Tag, der schon läuft (`ex_meal_subscription_days_period`) oder den ein Hortmodul mit Essen deckt. Sekretariat und Schulleitung setzen auch hier **jedes Datum**, auch eines in der Vergangenheit ([offizieller Umweg](../soll-prozesse/hebel.md#der-offizielle-umweg)). Erneuert die Optigem-Aufgabe | schreibt, `guardian:` / `entra:` | — |
| `DELETE /meal-subscription-days/{meal_subscription_day_id}` — einen noch nicht begonnenen Tag zurücknehmen; die Zeile wird **gelöscht**, nicht beendet | [11](../soll-prozesse/11-mensa.md) Z4 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie; **nur solange `valid_from` in der Zukunft liegt** — „das ist keine Verringerung, sondern die Rücknahme einer Buchung, die nie lief", und sie hängt an der ohnehin vorhandenen Regel vom nächsten Monatsersten statt an einer eigenen Frist. **Nicht der letzte Tag**: ein laufendes Abo behält mindestens einen, sonst entstünde ein Monatsbeitrag für null Tage, den `meal_prices` gar nicht kennt (`ck_meal_prices_days` beginnt bei 1) — alle loszuwerden ist eine Kündigung. Erneuert die Optigem-Aufgabe | schreibt, `guardian:` / `entra:` | — |
| `POST /meal-subscriptions/{meal_subscription_id}/reduction` — weniger Tage: die genannten Wochentage zum 31. Januar beenden (`valid_until`) | [11](../soll-prozesse/11-mensa.md) Z4 | Erziehungsberechtigte; `secretariat`, `school_management` (Umweg) | eigene Familie; für die Eltern **nur bis zum 3. Januar**, und das Ende ist immer der 31. Januar — beide Daten sind fest und nirgends einstellbar. Danach `400`: „danach läuft das Abo bis zum 31. Juli aus". Mindestens ein Tag bleibt stehen — alle zu streichen ist eine Kündigung und geht die Zeile darunter. Sekretariat und Schulleitung setzen jedes Datum. Erneuert die Optigem-Aufgabe | schreibt, `guardian:` / `entra:` | — |
| `POST /meal-subscriptions/{meal_subscription_id}/termination` — das Abo beenden: `ends_on` setzen | [11](../soll-prozesse/11-mensa.md) Z4, „Sonderfälle" | Erziehungsberechtigte; `secretariat`, `school_management` (Umweg) | eigene Familie; für die Eltern **nur bis zum 3. Januar**, Ende immer der 31. Januar. **Für das Sekretariat ist dies zugleich der Abgangsweg**: Es trägt jedes Datum ein, auch eines in der Vergangenheit ([03](../soll-prozesse/03-irregulaerer-abgang.md)), und hakt den Punkt „Mensa" der Abgangsliste getrennt über den Querschnitt ab. Nicht vor `starts_on` (`ck_meal_subscriptions_period`). Erneuert die Optigem-Aufgabe („Beitrag stoppen") | schreibt, `guardian:` / `entra:` | — |
| `GET /meal-subscriptions` — die laufenden Abos, je Zeile Kind, Wochentage samt Zeitraum, Beginn, Ende und Monatsbeitrag | [11](../soll-prozesse/11-mensa.md) „Beteiligte" („sieht die einzelnen Abos") | `domestic_services_management`, `secretariat`, `school_management` | Listenroute, deshalb nie über den OTP-Pfad ([`gemeinsam.md`](gemeinsam.md)); Schulleitung nur die Abos ihrer Schulform — praktisch die Realschule, denn nur sie hat welche. **Ohne die Variante**, und deshalb ohne die enge Rolle: die steht auf den beiden Listen und am Kind | liest | — |

## Die zwei Listen der Küche

Beide sind [frisch erzeugte Listen](../soll-prozesse/hebel.md#frisch-erzeugte-liste) als
Druckansicht ([`gemeinsam.md`](gemeinsam.md#liste)) und beide nie über den OTP-Pfad.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /meals/day-list?day=YYYY-MM-DD` — **die Tagesliste**: wer heute isst, in welcher Variante, mit welcher Unverträglichkeit | [11](../soll-prozesse/11-mensa.md) Z3, „Dateien" | `canteen`, `domestic_services_management`, `secretariat` | unbeschränkt, aber **drei Herkünfte und sonst nichts** (unten). Sie zeigt Name, Variante und den **Küchen-Ausschnitt** der Gesundheitsangaben — „ohne Notfallmedikation, ohne Diagnose, ohne Attestlage". Die Hauswirtschaftsleitung druckt sie aus; wer ausgibt, braucht dafür keinen Zugang | liest | `backend_kitchen`, für Variante **und** Gesundheits-Ausschnitt |
| `GET /meals/week-overview?on=YYYY-MM-DD` — **die Wochenübersicht** für den Einkauf: je Wochentag, wie viele Kinder in welcher Variante essen | [11](../soll-prozesse/11-mensa.md) „Dateien" | `canteen`, `domestic_services_management`, `secretariat` | unbeschränkt. Sie zählt **den laufenden Betrieb** — Abos und Hortmodule —, **nicht** die Ferien- und Werkstatttermine: „ein Ferientermin passt in kein Wochenraster und wird als Termin geplant". Nur Zahlen, keine Namen. **Der Stichtag entscheidet, welche Tage gerade gelten**, Vorgabe heute — ohne ihn sähe die Hauswirtschaftsleitung einen zum 1. Dezember gebuchten Tag erst, wenn er läuft, und eingekauft wird vorher | liest | `backend_kitchen` |

**Die drei Herkünfte der Tagesliste**, und die Route führt sie zusammen — genau das ersetzt die zwei
Excel-Listen, die heute nebeneinander stehen:

1. **Abo** — `meal_subscription_days`, deren Wochentag auf den Tag fällt und deren Zeitraum ihn
   enthält, innerhalb von `starts_on`/`ends_on` des Abos.
2. **Hortmodul** — eine freigegebene, an diesem Tag laufende `care_module_agreements` mit einer
   `care_module_bookings`-Zeile für diesen Wochentag, deren `care_modules.includes_lunch` gesetzt ist
   ([09](../soll-prozesse/09-hortvertrag.md)). Das ist der einzige Weg, auf dem ein Grundschüler
   mitisst.
3. **Ferien- oder Werkstatttermin** — eine nicht stornierte `holiday_bookings`, deren Termin diesen
   Tag trägt und deren `holiday_modules.includes_lunch` gesetzt ist
   ([10](../soll-prozesse/10-ferienprogramm.md)).

Ein Kind steht **einmal** darauf, auch wenn zwei Herkünfte zusammenfallen: „je Kind und Tag gibt es
höchstens ein Essen". Gegen ein Hortmodul prüft schon die Anmeldung, gegen einen Ferientermin
niemand — deshalb entscheidet die Liste und nicht ein Constraint.

## Die Optigem-Aufgabe

Sie entsteht als Seiteneffekt jeder schreibenden Route oben, nie über eine eigene, und trägt den
Bezug `child_id` beim Ziel `optigem` ([`querschnitt-api.md`](querschnitt-api.md)). Daraus folgt eine
Regel, die diese Domäne **mit dem Hortvertrag teilt**: Ein Kind kann beides haben — ein Modul „nach
Mittagsschule" der Klasse 5 trägt kein Essen und schließt ein Abo nicht aus —, und
`ix_sync_tasks_open_child` lässt je Ziel und Kind nur **eine** offene Aufgabe zu.

**Der Text wird deshalb aus dem ganzen aktuellen Abrechnungsstand des Kindes gebaut** — Module,
Modulessen und Abo —, nie aus der Änderung, die ihn ausgelöst hat; sonst verschluckt die nächste
Hortanpassung das Essen. Gebaut wird er an **einer** Stelle, die beide Domänen rufen. — Alternative:
ein eigenes Ziel `optigem_meal` neben `optigem`; Preis: eine Migration und ein zweites Ziel für
dieselbe Stelle, gegen den Hebel „Die Art ist das Ziel, nicht der Anlass" — und die Buchhaltung
schlüge für ein Kind an zwei Orten nach. Die Änderungsgebühr des Horts bleibt davon unberührt, sie
hat aus dem umgekehrten Grund ihr eigenes Ziel `optigem_one_off`: eine Einmalforderung ist kein
Stand ([09](../soll-prozesse/09-hortvertrag.md)).

**Für ein Hortkind entsteht hier nichts**: Sein Essen steckt in derselben Aufgabe, aber es hat sie
schon.

## Der eine Lauf

Keine Route, kein Endpunkt von außen ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

| Lauf | Herkunft | Auslöser | Aktor |
|---|---|---|---|
| **Der Jahreslauf beendet die Essensabos zum 31. Juli — und schreibt dafür nichts.** Keine Mail, keine Erinnerung, weder nach außen noch nach innen | [11](../soll-prozesse/11-mensa.md) Z5, [04](../soll-prozesse/04-schuljahreswechsel.md) Z2 | der 1. August, ein festes Datum — Teil des [Jahreslaufs](../soll-prozesse/04-schuljahreswechsel.md) | `system:rollover` |

**Warum er nichts schreibt:** `meal_subscriptions.ends_on` ist `NOT NULL` und wird bei der Anmeldung
gesetzt; `ck_meal_subscriptions_start` verbietet einen Beginn im August und September, also liegt
jedes Abo in genau einem Schuljahr und kennt seinen 31. Juli von Anfang an. Der Lauf **findet das
Ende vor, statt es zu setzen** — dieselbe Form wie „Die Einschreibungen des neuen Jahres findet der
Lauf vor" (04 Z2). — Alternative: er setzt `ends_on` trotzdem; Preis: je Abo und Jahr eine Zeile in
der Änderungsspur für einen Wert, der schon dasteht.

**Diese Domäne hat sonst keinen Lauf**: „Keine Mail, aus keinem Anlass" — sie ist der einzige Block
ohne eigene, und der Hebel für [unzustellbare Mails](../soll-prozesse/hebel.md#unzustellbare-mail)
greift hier nie.

## Offene Fragen

Keine neuen. Die eine des Blocks steht dort und im Schema und ändert an keiner Route etwas, nur am
Text dahinter:

`[?]` Der Text der **Essensbedingungen** braucht zwei Anpassungen, bevor er so laufen kann: Anmeldung
und Kündigung **im Portal statt mit Unterschrift**, und die **Lastschrift-Ermächtigung nicht mehr aus
ihm selbst** — Geschäftsführung.

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Die Routen des Gesundheitsbestands** — die Tagesliste liest ihn nur, über
  `kitchen_health_traits`; erhoben und gepflegt wird er in der Gesundheits-Domäne.
- **Die Betreuungsmodule samt `includes_lunch` und ihre Anlagen**, aus denen das Essen der
  Hortkinder folgt (`GET /care-modules`, `POST /care-module-agreements/{id}/release`) —
  [Anmeldung](anmeldung-api.md); dieselbe Route baut den Optigem-Text nach der Regel oben.
- **Die Ferien- und Werkstattbuchungen samt Modul**, deren Kinder auf der Tagesliste stehen —
  Ferien; dort wird auch die Essensvariante erhoben, aber über die Route dieser Datei.
- **Die Fassung der Essensbedingungen** (`contract_texts`, Code `meal_terms`) pflegen —
  [Querschnitt](querschnitt-api.md), `executive_management`.
- **Aufgabe abhaken und der Bestand der Wochenmail** — [Querschnitt](querschnitt-api.md),
  `GET /tasks` und `PUT /tasks/{sync_task_id}`.
- **Die Änderungsspur** — [Querschnitt](querschnitt-api.md).
- **Die Abgangsliste**, auf der „Mensa" als Punkt steht: angelegt von
  `PUT /children/{child_id}/departure` ([`stammdaten-api.md`](stammdaten-api.md)); das Ende trägt
  `POST /meal-subscriptions/{id}/termination` ein.
- **Der Jahreslauf selbst** — [`stammdaten-api.md`](stammdaten-api.md).
- **Der Lösch-Lauf** (17), der Küchenprofil, Abo und Tage mitnimmt.
- **Kein Zahlungsweg.** Diese Domäne eröffnet keine Zahlungssitzung und ruft
  `POST /payments/callback` nie — abgerechnet wird über das Mandat aus 08 und Optigem.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **`backend_kitchen` konnte keine Zeile benennen, und das ist beim Bau nachgezogen.** Die
  Migration gab ihr `SELECT (meal_variant_id) ON child_meal_profiles` und sonst nichts — kein
  `child_id`, keinen Schlüssel. Postgres verlangt das Spaltenrecht auch für die `WHERE`-Klausel, ein
  `WHERE child_id = …` scheitert also mit „permission denied for table child_meal_profiles"
  (gemessen). Derselbe Fund wie bei `backend_sensitive` auf `children`
  ([`stammdaten-api.md`](stammdaten-api.md), „Die Prüfung"), und die Schlüsselspalten stehen jetzt
  im GRANT. Eine Ausweitung ist es nicht: **`meal_variants` bekommt die Rolle nicht**, der Code wird
  außerhalb des engen Blocks nachgeschlagen — gelesen wird dort weiterhin die eine Spalte.
- **Das Abo hat keine Marke für „gekündigt".** Ob eine Kündigung vorlag, steht allein daran, dass
  `ends_on` der 31. Januar ist — das genügt, weil es nur zwei mögliche Tage gibt und beide
  ausgewählt und nicht gerechnet werden; ein Abgang setzt einen dritten. Wer später einmal zählen
  will, wie viele gekündigt haben, findet es in der Änderungsspur und nicht in einer Spalte.
