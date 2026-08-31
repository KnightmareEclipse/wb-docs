# Prüfbericht: Routen des Ferienprogramms

22 Routen in `app/routers/ferien.py`, 42 Tests in `tests/test_ferien.py`. **Nullpunkt grün**
(42 passed). Auftrag: [`api/ferien-api.md`](../api/ferien-api.md) und Block
[10](../soll-prozesse/10-ferienprogramm.md). Gemessen nach der Methode aus
`prompts/api-pruefen.md`.

## Funde

```
[FERIEN-R1] Klasse 1 · GET /holiday/cost-coverage-codes
Plan: „`secretariat`, die anbietende Rolle des Programms". Der Router baut dafür `mine` — die
  Programme, deren anbietende Rolle der Aufrufer trägt — und filtert dann:

      if (not mine or row.holiday_programme_id in mine)

  `not mine` ist wahr, sobald die Menge **leer** ist. Eine Hortleitung, die gerade kein eigenes
  Programm angelegt hat, fällt damit nicht in den engen, sondern in den offenen Zweig und liest
  **alle** Codes — samt Mailadresse der Familie, Abrechnungssatz und Urheber, auch die der
  Hauswirtschaft. Der Filter kippt genau dort um, wo er greifen soll.
Nicht gemessen als Sicherung, sondern als Zustand gelesen; die Messung dazu steht unten: den Filter
  ganz zu entfernen lässt tests/test_ferien.py grün (42 passed) — es gibt zu dieser Route keinen
  Test.
Vorschlag: `if row.holiday_programme_id in mine or staff_roles(user, _SECRETARIAT)`, dazu ein Test
  mit einer anbietenden Rolle ohne eigenes Programm.
```

```
[FERIEN-R2] Klasse 1 · POST /holiday/bookings/{holiday_booking_id}/cancellation-declaration
Plan: „nur Kinder der eigenen Familien". Der Router lädt die Buchung über die Id aus dem Pfad und
  prüft dann `reach_family(user, child.family_id, write=True)`.
Gemessen: die Prüfung entfernt, tests/test_ferien.py bleibt grün (42 passed). Ein Elternteil, der
  eine fremde `holiday_booking_id` rät, erklärt damit den Storno für ein fremdes Kind — das legt
  eine Aufgabe bei der anbietenden Stelle an und schickt ihr eine Mail. Die Datei hat einen Test
  für die fremde Familienansicht und einen für die fremde Anmerkung, an dieser Route keinen.
Vorschlag: ein Test, in dem ein Elternteil die Buchungs-Id einer fremden Familie schickt und 404
  bekommt.
```

```
[FERIEN-R3] Klasse 1 · POST /holiday/bookings/{holiday_booking_id}/cancellation
Plan: „`secretariat`, die anbietende Rolle" — die Bindung an *die* Rolle, die dieses Programm
  anbietet, steht als `require_staff(user, _SECRETARIAT, await _offering_code(session, programme))`.
Gemessen: durch die feste Liste beider anbietender Rollen ersetzt — grün (42 passed). Danach trüge
  die Hauswirtschaftsleitung Stornos in Buchungen des Hortprogramms ein, samt einbehaltenem Betrag
  und Erstattungsaufgabe. Der Nachbarcheck an derselben Route (`_own_programme` bei den Programmen)
  ist geprüft, dieser nicht.
Vorschlag: ein Test, in dem die eine anbietende Rolle eine Buchung der anderen einzutragen versucht.
```

```
[FERIEN-R4] Klasse 4 · POST /holiday/programmes, _offering_role_id()
Der Test `test_admin_lays_a_programme_down_and_the_offering_role_is_not_free` deckt nur den ersten
  der beiden Zweige: eine Rolle, die keine der zwei anbietenden ist, gibt 400. Der zweite —
  „der Aufrufer muss sie halten, `admin` ausgenommen" — ist ungeprüft.
Gemessen: `if code not in user.roles and _ADMIN not in user.roles: 403` entfernt → grün
  (42 passed). Danach legte die Hauswirtschaftsleitung ein Programm im Namen der Hortleitung an,
  und `_own_programme` gäbe es danach an sie ab.
Vorschlag: den Test um einen Aufruf ergänzen, der die fremde der beiden Rollen als
  `offering_role_code` schickt.
```

```
[FERIEN-R5] Klasse 4 · POST /holiday/bookings
Block 10 Z3 und der Plan: die eine Prüfung am Kind ist `allows_external_children` — „nicht das
  Alter, es wird nirgends geprüft". Sie steht in `_external_allowed()`.
Gemessen: entfernt → grün (42 passed). Ein Kind ohne Schul- oder Hortvertrag käme damit auf jeden
  Termin, auch auf den, den die Terminart ausdrücklich nicht für Fremde öffnet.
Vorschlag: ein Test mit einem unbekannten Kind auf einer Terminart mit
  `allows_external_children = false`.
```

```
[FERIEN-R6] Klasse 5 · drei Rollenschranken der Mitarbeiterseite
`POST /holiday/bookings`, `GET /holiday/families/{family_id}/bookings` und
  `PUT /children/{child_id}/holiday-care-notes/{programme_id}` tragen je ein
  `require_staff(user, _SECRETARIAT, _DAY_CARE, _DOMESTIC)`. Der Plan nennt für alle drei genau
  diese Menge.
Gemessen, alle drei einzeln entfernt → je grün (42 passed). Die vorhandenen Verweigerungstests
  fahren über den Elternteil und fangen schon an der Türunterscheidung.
Vorschlag: je ein Test mit `as_role("teacher")` gegen 403.
```

```
[FERIEN-R7] Klasse 4 · drei Zustandsprüfungen ohne Test
Gemessen, je entfernt und je grün (42 passed):
  · „That booking would cost nothing" — der Plan begründet sie eigens damit, dass
    `holiday_bookings.amount_cents` die Null erlaubt und `ck_payments_amount` nicht: ohne sie
    entstünde eine Buchung, zu der nie eine Zahlung entstehen kann.
  · „More was retained than the booking ever cost" — der einbehaltene Betrag ist danach unbegrenzt.
  · „That booking is already cancelled" an der **Erklärung**; der Test dieses Namens
    (`test_a_booking_is_not_cancelled_twice`) hält nur die Eintragungsroute fest.
Vorschlag: je ein Test; für den ersten ein Modul mit Betrag und Aufschlag null.
```

```
[FERIEN-R8] Klasse 5 · GET /holiday/sessions/{id}/participants, der Gesundheits-Ausschnitt
Plan: „bei bekannten Kindern der Gesundheits-Ausschnitt **seiner Rolle**" — die Hortrollen lesen die
  Beschreibungen über `backend_health`, die Hauswirtschaft den Küchen-Ausschnitt über
  `kitchen_health_traits`, alle anderen nichts.
Gemessen: den Hort-Zweig von `_health_slice()` abgeschaltet → grün (42 passed). Der Test der Liste
  prüft Namen, Modul und das Fehlen der stornierten Buchungen, aber keine Gesundheitszeile — der
  engste Ausschnitt des Systems steht ohne Gegenprobe.
Vorschlag: je ein Test für die zwei Rollen mit Ausschnitt und einen für `secretariat` ohne.
```

```
[FERIEN-R9] Klasse 4 · GET /holiday/cost-coverage-codes hat keinen Test
Gemessen: der Eigen-Programm-Filter entfernt → grün; der Verfallsfilter entfernt → grün (je 42
  passed). Beide Regeln des Plans — „nur die eigene anbietende Rolle" und „abgelaufene und nicht
  eingelöste fallen heraus" — sind ungeprüft; die 14-Tage-Frist steht dabei ausdrücklich in keiner
  Spalte, trägt also allein die Route. Der Fund R1 ist die Folge davon.
Vorschlag: ein Test über zwei Programme zweier anbietender Rollen, plus einer mit einem
  zurückdatierten `created_at`.
```

## Angesehen, nicht als Fund gewertet

- **Ownership in der Query, wo es Tests gibt.** Kind einer fremden Familie in der Buchung → rot;
  fremde Familienansicht → rot; fremde Anmerkung → rot; das Programm einer fremden anbietenden
  Rolle (`_own_programme`) → rot, und dieselbe Bindung an der Teilnehmerliste → rot.
- **Die Bedingungen der Buchung.** `picks_still_hold` — geschlossenes Fenster, abgesagter Termin,
  Modul einer anderen Terminart, dasselbe Kind zweimal am selben Termin — ignoriert → rot. Die
  Teilnahmebedingungen entfallen → rot. Die Stornofrist der Eltern entfällt → rot.
- **Die Werte.** Ein geltender Modulbetrag bewegt sich nicht mehr → rot; ein Termin ohne Aufschlag
  je Modul → rot.
- **Klasse 6.** Der einzige Endpunkt, der zwei Tabellen und eine Mail zugleich berührt, ist
  `POST /holiday/bookings` auf dem Kostenübernahme-Weg: `write_bookings` schreibt in der
  Transaktion, die Mail läuft als Hintergrundaufgabe hinter dem Commit — der Kommentar sagt es und
  `send_tracked` schreibt seine Zeile in einer eigenen Transaktion. Dieselbe Form bei beiden
  Storno-Routen. Kein Weg, auf dem eine Mail zu einer zurückgerollten Transaktion hinausginge.
- **Die 403 der Eltern an der Eintragungsroute ist doppelt gesichert.** Entfernt bleibt die Suite
  grün, weil das `require_staff` darunter denselben Status liefert — die Messung sagt hier nichts
  über den Test aus, die Sicherung ist redundant und nicht wirkungslos.
- **Ein Lauf gehört dieser Domäne nicht.** Der Plan nennt keinen; die Wochenmail und die
  Nachzieh-Aufgaben sind Querschnitt.
- **F4 war keine Messung.** Der Einsichtsstufen-Ausdruck `reach_family(..., write=True)` steht in
  dieser Datei dreimal; der Mustertreffer war nicht eindeutig und der Lauf hat ihn übersprungen.
  Für die Anmeldung und die Anmerkung ist die Stufe damit ungeprüft geblieben — dieselbe Lücke, die
  in `routen-mensa.md` und `routen-elternbonus.md` gemessen ist.
