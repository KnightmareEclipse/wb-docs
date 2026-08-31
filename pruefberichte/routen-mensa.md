# Prüfbericht: Routen der Mensa

16 Routen in `app/routers/mensa.py`, 24 Tests in `tests/test_mensa.py`. **Nullpunkt grün**
(26 passed — die Datei bringt zwei parametrisierte Fälle mit). Auftrag:
[`api/mensa-api.md`](../api/mensa-api.md) und Block [11](../soll-prozesse/11-mensa.md). Gemessen
nach der Methode aus `prompts/api-pruefen.md`.

## Funde

```
[MENSA-R1] Klasse 8 · GET /meals/week-overview
Plan, Zeile „Die zwei Listen der Küche": „Wer darf: `canteen`, `domestic_services_management`,
  `secretariat`" — für beide Listen dieselbe Rollenliste, und der Block nennt die Wochenübersicht
  ausdrücklich als das Blatt für den Einkauf.
  Der Router trägt an der Tagesliste `require_role(_CANTEEN, _DOMESTIC, _SECRETARIAT)`, an der
  Wochenübersicht aber `require_role(_DOMESTIC, _SECRETARIAT)`: **`canteen` fehlt.** Die Küche
  erreicht damit ihre eigene Wochenübersicht nicht, obwohl sie auf derselben Zeile des Plans steht
  wie die Tagesliste, die sie erreicht.
Nicht gemessen, gelesen: kein Test ruft die Wochenübersicht mit einer Rolle auf, nur der Elternteil
  wird an der Tagesliste abgewiesen.
Vorschlag: `_CANTEEN` in die Rollenliste der Wochenübersicht aufnehmen — oder, wenn die Küche sie
  nicht braucht, den Plan an dieser Stelle korrigieren.
```

```
[MENSA-R2] Klasse 1 · GET /families/{family_id}/meals
Plan: „nur die eigenen Familien; Schulleitung nur, wenn ein Kind dieser Familie ihre Schulform
  trägt." Die Mitarbeiterseite trägt dafür zwei Zeilen — `require_staff(user, _SECRETARIAT,
  BRANCH_ROLE)` und `reach_family_as_staff(...)`.
Gemessen, beide einzeln entfernt: tests/test_mensa.py bleibt je grün (26 passed). Ohne die zweite
  liest jede Schulleitung die Essensansicht **jeder** Familie — samt Namen der Kinder, laufendem Abo
  und der Essensvariante aus dem engen Block. Der einzige Ownership-Test dieser Route fährt über
  den Elternteil (M5, rot); für die Mitarbeiterseite gibt es keinen.
Vorschlag: ein Test, in dem die Schulleitung einer Schulart die Familie der anderen abruft, und
  einer mit `as_role("teacher")` gegen 403.
```

```
[MENSA-R3] Klasse 1 · GET /meal-subscriptions
Plan: „Schulleitung nur die Abos ihrer Schulform" und die Rollenliste
  `domestic_services_management`, `secretariat`, `school_management`.
Gemessen: der Schulart-Filter entfernt → grün (26 passed); die Rollenliste um `teacher` erweitert →
  grün. Der einzige Test dieser Route (`test_the_subscription_list_is_closed_to_the_otp_path`)
  weist den Elternteil ab und sagt über beides nichts.
Vorschlag: je ein Test — eine Schulleitung sieht nur die Abos ihrer Schulart, `teacher` bekommt 403.
```

```
[MENSA-R4] Klasse 2 · tests/test_mensa.py:440, test_a_begun_day_is_refused
Der Test datiert den einzigen Tag des Abos auf den 1. Oktober zurück (eingefroren ist der 15.) und
  verlangt 400. Der kommt aber nicht aus der Prüfung, die der Name nennt: Weil das Abo nur **einen**
  Tag hat, greift die Zeile darunter — „The last day is not taken back; that is a termination".
Gemessen: die Prüfung `day.valid_from <= _today()` vollständig entfernt — tests/test_mensa.py
  bleibt grün (26 passed). Damit ist die Regel „nur solange `valid_from` in der Zukunft liegt"
  ungeprüft, obwohl ein Test ihren Namen trägt. Der Nachbartest
  (`..._is_not_taken_back_and_the_last_one_never_is`) prüft die Letzter-Tag-Regel bereits, sie ist
  rot geworden.
Vorschlag: den Test auf ein Abo mit zwei Tagen umstellen und den begonnenen zurücknehmen lassen.
```

```
[MENSA-R5] Klasse 4 · jede schreibende Route der Domäne
`_reach_child_to_write()` trägt das `write=True` an `reach_family()` — die
  [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe), „nur lesen ruft keine schreibende
  Route". Sie hängt an dieser einen Stelle für Küchenprofil, Anmeldung, Tage, Verringerung und
  Kündigung zugleich.
Gemessen: auf `reach_family(user, child.family_id)` gekürzt — grün (26 passed). Kein Test hat einen
  Sorgeberechtigten mit Stufe „nur lesen".
Vorschlag: ein Test mit leerem `writable_families` gegen 403, an einer der fünf Routen.
```

```
[MENSA-R6] Klasse 5 · die Rollenschranken der beiden Küchenlisten
Plan: beide Listen für `canteen`, `domestic_services_management`, `secretariat`, beide nie über den
  OTP-Pfad.
Gemessen: an der Wochenübersicht `require_role` durch `get_current_user` ersetzt → grün
  (26 passed); an der Tagesliste die Liste um `teacher` erweitert → grün. Geprüft ist allein, dass
  der Elternteil die Tagesliste nicht bekommt — und das fängt schon die Türunterscheidung.
  Zusammen mit R1: an dieser Route ist die Rollenliste weder richtig noch geprüft.
Vorschlag: je ein Test mit `as_role("teacher")` gegen 403, und einer, der `canteen` die
  Wochenübersicht lesen lässt.
```

```
[MENSA-R7] Klasse 4 · das Datum, das nur das Sekretariat setzen darf
Plan: der Beginn des Abos „wird gerechnet", und an `days` setzen „Sekretariat und Schulleitung auch
  hier jedes Datum" — für die Eltern gilt der nächste Monatserste. Beides trägt je ein
  `not user.is_guardian` im Ausdruck.
Gemessen: an der Anmeldung `chosen` auf `body.starts_on` gesetzt → grün (26 passed); an `add_days`
  die Bedingung auf `body.valid_from if body.valid_from` gekürzt → grün. Danach setzte ein
  Elternteil selbst, ab wann ein Tag läuft — rückwirkend eingeschlossen, und der Monatsbeitrag
  hängt daran.
Vorschlag: je ein Test, der als Elternteil ein `starts_on`/`valid_from` mitschickt und nachweist,
  dass es ignoriert wird.
```

```
[MENSA-R8] Klasse 4 · POST /meal-subscriptions/{id}/days
Plan: „kein Tag, den ein Hortmodul mit Essen deckt" — dieselbe Regel wie an der Anmeldung, „je Kind
  und Tag gibt es höchstens ein Essen".
Gemessen: die Prüfung an der Anmeldung entfernt → rot; dieselbe Prüfung an `days` entfernt → grün
  (26 passed). Die Regel ist also nur auf einem ihrer beiden Wege geprüft, und `days` ist der Weg,
  auf dem ein Tag nachträglich dazukommt.
Vorschlag: den vorhandenen Kollisionstest auf `POST .../days` wiederholen.
```

```
[MENSA-R9] Klasse 4 · POST /meal-subscriptions/{id}/termination
Plan: für die Eltern „nur bis zum 3. Januar, Ende immer der 31. Januar".
Gemessen: das Fenster an der Kündigung entfernt → grün (26 passed); dieselbe Prüfung an der
  Verringerung entfernt → rot. Der Test der Kündigung ruft nur innerhalb des Fensters auf und hält
  deshalb nur das Ergebnisdatum fest, nicht die Frist.
Vorschlag: den `AFTER_DEADLINE`-Zweig aus `test_a_guardian_reduces_only_up_to_the_third_of_january`
  auch für die Kündigung fahren.
```

```
[MENSA-R10] Klasse 5 · PUT /children/{child_id}/meal-profile
Plan: „Erziehungsberechtigte; `secretariat` (Umweg)" — die Schranke steht als
  `require_staff(user, _SECRETARIAT)`.
Gemessen: entfernt → grün (26 passed). Danach trüge jede Mitarbeiterrolle, die das Kind über
  `reach_child` erreicht, die Essensvariante ein. Die Leseroute daneben hat den Test
  (`test_the_canteen_reads_no_single_profile`, rot geworden), die Schreibroute nicht.
Vorschlag: ein Test mit `as_role("canteen")` oder `as_role("teacher")` gegen 403.
```

## Angesehen, nicht als Fund gewertet

- **Ownership in der Query, wo es Tests gibt.** Elternteil gegen fremde Familie an der
  Essensansicht → rot; Elternteil gegen fremdes Kind am Küchenprofil → rot; die Rollenschranke der
  Profil-**Lese**route → rot (`test_the_canteen_reads_no_single_profile` — die Küche liest kein
  einzelnes Profil, genau wie der Plan es sagt).
- **Die drei harten Bedingungen der Anmeldung** je entfernt und je rot: nur ein eingeschriebenes
  Realschulkind, kein vom Hortmodul gedeckter Tag, kein zweites laufendes Abo. Dazu die
  Optigem-Aufgabe: ihr Aufruf entfernt → rot.
- **Der laufende Betrieb.** Ein schon laufender Wochentag → rot; der letzte Tag wird nicht
  zurückgenommen → rot; alle Tage streichen ist eine Kündigung → rot; die 3.-Januar-Frist der
  Verringerung → rot; ein Ende vor dem Beginn → rot.
- **Die Werte.** Ein bereits geltender Betrag bewegt sich nicht mehr → rot; dass allein die
  Geschäftsführung setzt, hält ein eigener Test.
- **Die enge Rolle.** `_variants_of()` und der Küchen-Ausschnitt der Gesundheitsangaben laufen je in
  einem `narrow_role`-Block derselben Transaktion, und `PUT .../meal-profile` liest die Variante
  nach dem Schreiben nicht zurück — genau die drei Punkte, die der Plan unter „Enge Rolle"
  ausschreibt. Zwei Tests halten das fest.
- **Klasse 2 sonst.** Außer R4 schreibt keine Route vor ihrer Absage; `TransactionRoute` committet
  nach einer `HTTPException` nie.
- **Klasse 6.** `POST /children/{child_id}/meal-subscription` schreibt Abo, Tage, Küchenprofil und
  die Optigem-Aufgabe in einer Transaktion — der Plan verlangt genau das, und der erste Test der
  Datei prüft alle vier zusammen. Keine Mail, kein Graph-Aufruf in dieser Domäne.
- **Klasse 7 entfällt.** Der eine Lauf des Plans (Jahreslauf, 1. August) **schreibt nichts** und
  gehört zum Jahreslauf der Stammdaten; er hat hier keine Marke und keinen Endpunkt.
- **`GET /meal-variants` und `GET /meal-prices` tragen keine Rollenschranke.** Der Plan sagt „jede
  Mitarbeiterrolle; Erziehungsberechtigte", der Router lässt jeden Angemeldeten durch — auch ein
  Konto ohne Rolle und die Sitzung einer der Schule unbekannten Adresse. Beides sind Wertelisten
  ohne Personenbezug, deshalb genannt und nicht gewertet.
