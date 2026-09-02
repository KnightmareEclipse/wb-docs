# Ferien — Routen

Aus [`10-ferienprogramm.md`](../soll-prozesse/10-ferienprogramm.md); es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht. Ferienprogramm und
Kochwerkstatt sind zwei Angebote mit einem Ablauf — „was sie trennt, steht in Zahlen und nicht im
Ablauf", und deshalb trennt auch keine Route sie.

**Gegenprobe:** Die Ablauftabelle des Blocks hat **7 Zeilen**; alle sieben handeln im System — **6**
tragen hier eine Route, **1** trägt sie in einer anderen Domäne. Es gibt **19 Routen**; **12** nennen
eine Ablaufzeile, **7** einen Hebel oder einen Abschnitt des Blocks.

Die Zeilen: Z1 → die vier Routen für Programm und Termin · **Z2 → keine Route dieser Domäne**: Der
Anmeldecode ist der eine Zugangsweg für alle Formulare (`zugang.md`), und die Kinder der bekannten
Familie kommen aus dem Bestand ([`stammdaten-api.md`](stammdaten-api.md)) — hier entstünde eine
zweite Fassung desselben Flusses · Z3 → `GET /holiday/programmes` und
`PUT /children/{child_id}/holiday-care-notes/{holiday_programme_id}`; das Formular selbst legt
nichts an · Z4 → `POST /holiday/bookings` · Z5 → `POST /holiday/programmes/{id}/closure` ·
Z6 → die drei Storno-Routen · Z7 → `GET /holiday/sessions/{id}/participants`.

## Vier Grenzen, die jede Route dieser Domäne einhält

- **Vor der bestätigten Zahlung entsteht nichts** — dieselbe Grenze wie in der Bewerbung
  ([`anmeldung-api.md`](anmeldung-api.md)). `POST /holiday/bookings` prüft und eröffnet die
  Zahlungssitzung; Buchung, Familie, Kind und Sorgeberechtigte entstehen im Rückruf
  ([`gemeinsam.md`](gemeinsam.md#sofortzahlung)). **Der Kostenübernahme-Code ist die eine Ausnahme
  und tritt an die Stelle der Zahlung**: Dann schreibt dieselbe Route sofort.
- **Diese Domäne führt keinen eigenen Gesundheitsbestand und kein eigenes Fotoeinverständnis** —
  „Der Bestand steht am Kind (08, 09) und nirgends sonst" (10). Erhoben wird er über sie trotzdem:
  bei einem fremden Kind entsteht er mit der Buchung, bei einem Kind der Schule geben die Eltern den
  vorhandenen frei. Beides sind Routen der Gesundheits-Domäne
  ([`gesundheit-api.md`](gesundheit-api.md)), die diese Strecke ruft. Fotoeinverständnis
  und Werbe-Einwilligung sind Q1-Routen ([`querschnitt-api.md`](querschnitt-api.md)), die
  Essensvariante eine Mensa-Route ([`mensa-api.md`](mensa-api.md)), die Notfallnummer eine
  Stammdaten-Route — das Formular führt sie zusammen, die API nicht.
- **Für die Mensa entsteht hier nichts.** Ob ein Kind an einem Ferientag isst, sagt
  `holiday_modules.includes_lunch`; die Tagesliste der Küche liest das selbst
  ([`mensa-api.md`](mensa-api.md)). Diese Domäne erzeugt dafür keine Zeile und zeigt keine Liste.
- **Nichts wartet auf eine Entscheidung, und nichts läuft ab.** Keine Aufnahme, keine Warteliste,
  kein Nachrücken, keine Freigabe: „Wer bezahlt hat, ist dabei." Die Platzzahl ist eine Obergrenze
  für die Anzeige und keine Sperre.

## Pfad

Drei Sachen tragen ihn: das **Programm** samt seinen Terminen (`/holiday/programmes/…`,
`/holiday/sessions/…`), die **Buchung** (`/holiday/bookings/…`) und die **Werte**
(`/holiday/session-types`, `/holiday/module-prices`). Dazu der **Kostenübernahme-Code**
(`/holiday/cost-coverage-codes`).

**Die Buchung steht nicht unter der Familie, das Absenden auch nicht.** Sie hängt am Kind
(`holiday_bookings.child_id`), und ein Absenden trägt „mehrere Kinder in einem Zug" (Z3) — für eine
Familie, die es beim Absenden oft noch gar nicht gibt. Es ist derselbe Schnitt wie bei
`POST /applications`: Der Ownership-Check läuft gegen die Kinder im Rumpf und nicht gegen einen Pfad.
**Die Ansicht trägt die Familie dagegen**, weil sie eine Familienansicht ist
(`GET /holiday/families/{family_id}/bookings`), und mit ihr den Check aus
[`gemeinsam.md`](gemeinsam.md#wer-darf-und-worauf-eingeschränkt).

**Die Anmerkung steht unter dem Kind** (`/children/{child_id}/holiday-care-notes/{programme_id}`),
weil sie je Kind und Programm steht und nicht je Buchung — dieselbe Form wie
`/children/{child_id}/consents/{purpose}`.

## Enge Rolle

**Diese Domäne trägt keine enge Spalte.** Kein Art.-9-Feld, keine Bankverbindung: Der regulär
zahlende Elternteil bekommt kein SEPA-Mandat, „es hätte keinen einzigen Nutzlast-Wert"
(`grenzkarte.md`), und die Kostenübernahme ist ein Code und kein Einzugsmittel. Die Spalte steht
trotzdem an jeder Route, damit ihr Fehlen eine Aussage bleibt.

**Eine Route liest trotzdem eng, und die Regel dafür gehört nicht hierher:** Die Teilnehmerliste
zeigt „bei bekannten Kindern das, was die Betreuung ohnehin sehen darf (08)". Was das je Rolle ist,
hat die Gesundheits-Domäne entschieden — der Hort sieht den Sichtkreis `care` (`backend_health_care`),
die Hauswirtschaftsleitung den Sichtkreis `kitchen` (`backend_kitchen`); was jeder Sichtkreis
trägt, ist dort Konfiguration ([`gesundheit-api.md`](gesundheit-api.md), [`mensa-api.md`](mensa-api.md)).

Der Gesundheits-Ausschnitt der Teilnehmerliste folgt der Rolle des Aufrufers und wird an einer
Stelle gerechnet, die der Gesundheits-Domäne gehört. — Alternative: die Liste trägt gar keine
Gesundheitsangabe und die Betreuung schlägt sie einzeln nach; Preis: Das Papier, das die Stelle für
den Tag ausdruckt, trüge genau die Angabe nicht, für die es gedruckt wird — in der Kochwerkstatt,
wo gekocht wird, am meisten.

## Werte: Terminart, Module, Beträge

Die Terminart und ihre Module sind eine Werteliste und keine Pflegemaske.

**Keine Pflegeroute für `holiday_session_types` und `holiday_modules`** — sie entstehen im Seed
und wachsen über eine Migration, wie jede Werteliste ([`stammdaten-api.md`](stammdaten-api.md)). —
Alternative: eine Pflegemaske für die Geschäftsführung; Preis: vier Routen für drei Zeilen, die seit
Jahren dieselben sind, und ein `is_active`, das jemand pflegen müsste.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /holiday/session-types` — die Terminarten samt ihren Modulen, Uhrzeiten, `includes_lunch`, dem Häkchen für fremde Kinder, dem Code ihrer Stornobedingungen und je Modul dem geltenden und dem angekündigten Betrag | [10](../soll-prozesse/10-ferienprogramm.md) „Was dabei erhoben wird" | `day_care_management`, `domestic_services_management`, `executive_management`, `secretariat` | **interne Route**: Die Eltern sehen den Betrag am Termin, der ihn braucht ([`querschnitt-api.md`](querschnitt-api.md)). Ein angekündigter Betrag geht sie hier auch nichts an — bezahlt wird im selben Zug, also gilt für jede Buchung der heutige | liest | — |
| `POST /holiday/module-prices` — einen Modulbetrag ab einem Tag setzen | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | unbeschränkt; je Modul und Tag einer (`uq_holiday_module_prices`). **Der Aufschlag je Termin gehört nicht hierher** — ihn setzt die anbietende Stelle am Termin, „der einzige Betrag in diesem Block, den nicht die Geschäftsführung setzt" | schreibt, `entra:` | — |
| `PATCH /holiday/module-prices/{holiday_module_price_id}` — einen angekündigten Betrag ändern | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | **nur solange sein Gültigkeitstag nicht erreicht ist**, sonst `400`; `now()` steht in keinem CHECK, die Regel prüft die Route — dieselbe Mechanik wie bei `meal-prices` | schreibt, `entra:` | — |
| `DELETE /holiday/module-prices/{holiday_module_price_id}` — einen angekündigten Betrag zurücknehmen | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | wie oben; ein bereits gültiger bleibt stehen, „was schon berechnet oder bezahlt ist, bleibt bei dem Betrag, der damals galt" | schreibt, `entra:` | — |

## Programm und Termine

**Programm und Termine legen allein die anbietenden Rollen an** — das Sekretariat nicht: „Das
Sekretariat handelt hier nur an zwei Stellen mit: Es erzeugt Kostenübernahme-Codes und bucht wie
überall stellvertretend." — Alternative: `secretariat` an allen fünf schreibenden Routen; Preis: Der
Satz des Blocks über die zwei Stellen wäre eine Aufzählung ohne Kraft, und die Zuständigkeit für das
Ferienprogramm läge bei drei Stellen statt bei einer.

**Deshalb steht `admin` hier ausgeschrieben, und nur hier.** Sonst nennt ihn keine Domänendatei — er
ist die Obermenge der Verwaltung und erbt ihre Rechte an jeder Route
([`gemeinsam.md`](gemeinsam.md#wer-darf-und-worauf-eingeschränkt)). Genau das trägt hier nicht: Wo
das Sekretariat nichts darf, erbt er nichts. Ohne die ausdrückliche Nennung richtete niemand das
Programm ein, wenn die Hortleitung ausfällt — der Hebel „jeden Punkt selbst bestätigen, wenn die
zuständige Stelle ausfällt" greift fürs Einrichten nicht.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /holiday/programmes` — **die Ausschreibung**: je Programm sein Fenster, je Termin Tage, Terminart, Thema, freie Plätze und je Modul der Preis (geltender Modulbetrag plus Aufschlag), dazu Storno- und Teilnahmebedingungen in der heute geltenden Fassung | [10](../soll-prozesse/10-ferienprogramm.md) Z3, Z1 „danach steht fest" | jede Mitarbeiterrolle; Erziehungsberechtigte und **jeder ohne Anmeldung** | „für alle sichtbar, auch ohne Anmeldung, denn es ist die Ausschreibung" — dieselbe Lage wie `GET /enrolment-windows` ([`anmeldung-api.md`](anmeldung-api.md)). **Bilder liefert sie nie**, die liegen auf der Webseite der Schule. Ein Filter zeigt den internen Rollen auch geschlossene und vergangene Programme; ohne ihn steht nur, was offen ist. Ein **abgesagter Termin bleibt sichtbar** und ist nicht buchbar. Sie zeigt **keine Namen und keine Zahl über die Buchungen** außer den freien Plätzen | liest | — |
| `POST /holiday/programmes` — ein Programm anlegen: Name, anbietende Rolle, Anmeldefenster | [10](../soll-prozesse/10-ferienprogramm.md) Z1 | `day_care_management`, `domestic_services_management`, `admin` | unbeschränkt; die anbietende Rolle ist eine der beiden und wird nicht frei gewählt. Ein Schließdatum ist nicht Pflicht (`ck_holiday_programmes_window`) | schreibt, `entra:` | — |
| `PATCH /holiday/programmes/{holiday_programme_id}` — Name oder Anmeldefenster ändern, vorziehen oder verschieben | [10](../soll-prozesse/10-ferienprogramm.md) Z1, „Fristen und Termine" | die anbietende Rolle des Programms, `admin` | nur die Programme der eigenen Rolle, `admin` alle; „jederzeit vorziehbar oder verschiebbar wie das Voranmeldefenster (05)", **auch nachdem das Datum verstrichen ist** | schreibt, `entra:` | — |
| `POST /holiday/programmes/{holiday_programme_id}/closure` — die Anmeldung von Hand schließen | [10](../soll-prozesse/10-ferienprogramm.md) Z5 | die anbietende Rolle des Programms, `admin` | nur die Programme der eigenen Rolle, `admin` alle; **auch wenn rechnerisch noch Platz wäre**, „denn eingekauft und geplant wird vorher". Genau einmal; ein zweiter Aufruf ist `400`. **Kein Weg zurück** — wer danach doch noch mitsoll, kommt über den [offiziellen Umweg](gemeinsam.md#der-offizielle-umweg) hinein, den der Block ausdrücklich dafür benennt | schreibt, `entra:` | — |
| `POST /holiday/programmes/{holiday_programme_id}/sessions` — einen Termin anlegen: Tage, Terminart, Platzzahl, Titel und Beschreibung **und den Aufschlag je Modul dieser Terminart**, alles in **einer** Transaktion | [10](../soll-prozesse/10-ferienprogramm.md) Z1 | die anbietende Rolle des Programms, `admin` | nur die Programme der eigenen Rolle, `admin` alle; mindestens ein Tag, Platzzahl > 0 (`ck_holiday_sessions_places`), je Tag eine Zeile (`uq_holiday_session_days`), je Modul der Terminart genau ein Aufschlag (`uq_holiday_session_surcharges`, Pflicht, meist null). **Termin, Tage und Aufschläge sind ein Schritt** — ein Termin ohne Tag oder ohne Aufschlag ist ein Zustand, den kein Block kennt | schreibt, `entra:` | — |
| `PATCH /holiday/sessions/{holiday_session_id}` — Thema, Platzzahl, Tage oder Aufschlag ändern | [10](../soll-prozesse/10-ferienprogramm.md) Z1 + [`hebel.md`](../soll-prozesse/hebel.md#standardantworten) „Ändern" | die anbietende Rolle des Programms, `admin` | nur die Programme der eigenen Rolle, `admin` alle; nicht an einem abgesagten Termin. **Auch nach den ersten Buchungen** — eine Platzzahl unter den bereits Gebuchten sperrt nur die Anzeige, sie wirft niemanden hinaus; der Aufschlag gilt ab dann und rechnet nichts zurück ([`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest)) | schreibt, `entra:` | — |

## Buchen und bezahlen

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /holiday/bookings` — **das Absenden**: je Kind die gewählten Termine und Module, dazu Anmerkung, Notfallnummer, Fotoeinverständnis, Essensvariante und Werbe-Einwilligung, für eine unbekannte Familie zusätzlich Kind und Sorgeberechtigte. Prüft und **eröffnet die Zahlungssitzung** — oder löst einen Kostenübernahme-Code ein und schreibt sofort | [10](../soll-prozesse/10-ferienprogramm.md) Z4 | Erziehungsberechtigte, **auch mit dem reinen Anlege-Token** (`zugang.md`); `secretariat` und die anbietende Rolle (Umweg) | bekannte Kinder nur aus den eigenen Familien; ein unbekanntes Kind wird eingetragen und tritt der vorhandenen Familie bei, wo es eine gibt. Geprüft wird: offenes Fenster (`registration_opens_at`, `registration_closes_at`, `closed_at`), Termin nicht abgesagt, Modul gehört zur Terminart des Termins (`fk_holiday_bookings_module`), `allows_external_children` für ein Kind ohne Schul- oder Hortvertrag — **das Alter nicht**. **Kein zweites Mal dasselbe Kind auf denselben Termin** (`ix_holiday_bookings_active`). Zustimmung zu den Teilnahmebedingungen ist Pflicht; ihre Fassung friert mit dem Absenden ein (`holiday_terms`). **Eine sorgeberechtigte Person allein genügt** | liest, eröffnet die Sitzung — oder schreibt, `guardian:` / `entra:` | — |
| `GET /holiday/families/{family_id}/bookings` — die Ferienansicht der Familie: je Kind die Buchungen samt Termin, Modul, Betrag, Zahlweg, den Stornobedingungen und dem Stand einer Erklärung | [10](../soll-prozesse/10-ferienprogramm.md) „Was dabei erhoben wird" | Erziehungsberechtigte; `secretariat`, die anbietende Rolle | nur die eigenen Familien. **Sie ist der Ort, an dem der Storno erklärt wird**, und trägt dafür die Bedingungen samt Beträgen — „was ein Storno kostet, weiß heute nur, wer die Bedingungen zur Hand hat". Eine stornierte Buchung bleibt sichtbar. Die [sparsame Ansicht](../soll-prozesse/hebel.md#sparsame-ansicht) filtert hier **nichts**: keine der einmal erhobenen Angaben kommt darin vor | liest | — |
| `PUT /children/{child_id}/holiday-care-notes/{holiday_programme_id}` — die Anmerkung für die Betreuung eintragen oder ändern | [10](../soll-prozesse/10-ferienprogramm.md) Z3, „Was dabei erhoben wird" | Erziehungsberechtigte; `secretariat`, die anbietende Rolle | nur Kinder der eigenen Familien; je Kind und Programm eine (`uq_holiday_care_notes`). Erhoben wird sie beim Absenden, geändert nach der [Standardantwort](../soll-prozesse/hebel.md#standardantworten). **Keine `DELETE` daneben**: eine falsche Anmerkung wird ersetzt, und die Zeile räumt der Lösch-Lauf mit dem Kind | schreibt, `guardian:` / `entra:` | — |

**Was `POST /holiday/bookings` an den Zahlungsdienst übergibt**, ist der Formularinhalt als Metadaten
der Sitzung, in derselben Form wie bei der Bewerbung: ein JSON über mehrere Metadaten-Schlüssel, weil
ein Schlüssel bei Stripe 500 Zeichen fasst ([`anmeldung-api.md`](anmeldung-api.md)). Der **Betrag je
Buchung** reist mit — Modulbetrag zum Tag der Handlung plus Aufschlag —, denn genau ihn zieht die
Sitzung ein, und „eine spätere Änderung rechnet nichts rückwirkend um".

`[A!]` **Ein Absenden ist eine Sitzung und eine Zahlungszeile, auch wenn drei Kinder an vier Terminen
gebucht werden**; die Zahlung hängt an der ersten entstandenen Buchung, und was gekauft wurde, steht
an ihr über Kind, Familie und Zeitpunkt — dieselbe Form wie beim Jahres-Freikauf des Putzdiensts
([`gemeinsam.md`](gemeinsam.md#sofortzahlung)). **`fk_payments_holiday_booking` zeigt deshalb einfach
auf `holiday_booking_id`** wie die drei übrigen Anlässe: Der Betrag der Zahlung ist die Summe und
gleicht dem keiner einzelnen Buchung (siehe „Am Schema aufgefallen"). — Alternative: je Buchung eine eigene Sitzung;
Preis: der Elternteil bezahlt bei drei Kindern an vier Terminen zwölfmal, samt zwölf
Transaktionsgebühren — eine Barriere vor dem Bezahlen, wo heute ein Formular reicht, und „mehrere
Kinder in einem Zug, drei Kinder sind kein drittes Formular" (Z3) fällt.

**Ein Absenden trägt die Termine genau eines Programms.** Anmerkung und Kostenübernahme-Code stehen
je Programm, nicht je Buchung — ein Absenden über zwei Programme hätte für beide keinen eindeutigen
Bezug, und `uq_holiday_care_notes` fasst genau diesen Fall nicht. Zwei Programme sind zwei Absenden,
und je Programm bleibt es bei „mehrere Kinder in einem Zug" (Z3).

**Die Notfallnummer kommt an der sorgeberechtigten Person und nicht in einem eigenen Feld.** Für eine
bekannte Familie ruft das Formular `POST /persons/{person_id}/phone-numbers`
([`stammdaten-api.md`](stammdaten-api.md)); für eine unbekannte trägt die sorgeberechtigte Person im
Rumpf ihre tagsüber erreichbare Nummer, und **ohne sie weist die Route ab** — „ihre Pflicht greift
mit der ersten Buchung". Ein zweites Feld daneben wäre ein zweiter Ort für dieselbe Nummer.

**Ein Absenden ist ganz bezahlt oder ganz berechnet.** Der Code „gilt für diese eine
Anmeldung" und tritt an die Stelle der Zahlung, nicht neben sie. — Alternative: je Kind wählbar;
Preis: eine Sitzung über den Rest, ein Code über den anderen Teil und zwei Wege, auf denen dieselbe
Anmeldung halb entstehen kann.

**Die Platzzahl wird nicht sperrend geprüft**, weder beim Absenden noch im Rückruf: „Senden
zwei Familien im selben Moment ab, wird der Termin um eins überschritten." Der Anker, den
[`gemeinsam.md`](gemeinsam.md#sofortzahlung) verlangt, ist `ix_holiday_bookings_active` — er hält
dasselbe Kind auf demselben Termin fest und genügt. — Alternative: die Zeilen des Termins sperren;
Preis: eine Sperre gegen einen Fall, den der Block ausdrücklich in Kauf nimmt, auf dem
meistgenutzten Schreibpfad dieser Domäne.

**Was der Rückruf hier anlegt** (`POST /payments/callback`, [`querschnitt-api.md`](querschnitt-api.md)):
die Buchungen, und wo die Schule die Familie nicht kannte, Person, Kind, Familie und
Sorgeberechtigte ([`hebel.md`](../soll-prozesse/hebel.md#familie-und-kind)) — dazu Notfallnummer,
Fotoeinverständnis, Essensvariante, Werbe-Einwilligung und Anmerkung. **Keine davon über ihre eigene
Route**: Für ein Kind, das es beim Absenden noch nicht gibt, gäbe es keine Kennung, unter der man sie
riefe. Für ein bekanntes Kind ruft das Formular sie einzeln und vorher — dort sind sie schon
gespeichert, wenn die Zahlung abbricht, und das ist richtig so: Es sind Angaben am Kind und keine
Angaben der Buchung. Er prüft erneut, **was zwischen den beiden Aufrufen weggehen kann**: Fenster
geschlossen, Termin abgesagt. Trägt es nicht mehr, entstehen Zahlung **und** Aufgabe
`payment_without_cause` bei der Buchhaltung — ganz oder gar nicht.

## Storno und Absage

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /holiday/bookings/{holiday_booking_id}/cancellation-declaration` — den Storno erklären; setzt `cancellation_declared_at`/`_by`, legt die Aufgabe bei der anbietenden Stelle an und schickt ihr die Mail | [10](../soll-prozesse/10-ferienprogramm.md) Z6 | Erziehungsberechtigte; `secretariat`, die anbietende Rolle (Umweg) | nur Kinder der eigenen Familien; nicht an einer bereits eingetragenen Stornierung. **Für die Eltern nur innerhalb der Stornofrist der Terminart** — beim Ferienprogramm bis drei Tage vor Programmbeginn, danach `400` und „die Buchung bleibt bestehen"; die Kochwerkstatt trägt keine Sperre. Für Sekretariat und anbietende Stelle gilt die Frist nicht. **Wirksam wird die Erklärung nicht** — das tut erst die Zeile darunter | schreibt, `guardian:` / `entra:` | — |
| `POST /holiday/bookings/{holiday_booking_id}/cancellation` — den Storno eintragen: einbehaltenen Betrag setzen, Platz freigeben, Mail an die Familie; erzeugt die Erstattungsaufgabe, wo etwas zurückfließt, und erneuert die Optigem-Aufgabe, wo berechnet wurde | [10](../soll-prozesse/10-ferienprogramm.md) Z6 | die anbietende Rolle des Programms; `secretariat` | „Der offizielle Umweg gilt im Übrigen ohne Einschränkung: Sekretariat und anbietende Stelle buchen, stornieren und setzen jedes Datum stellvertretend." **Auch ohne Erklärung** — die Stelle storniert von sich aus. Betrag zwischen 0 und dem gezahlten (`ck_holiday_bookings_retained`); Zeitpunkt, Urheber und Betrag stehen zusammen oder gar nicht (`ck_holiday_bookings_recorded`). **Auch ein später Storno**, für den die Eltern gesperrt waren. Die Buchung bleibt stehen | schreibt, `entra:` | — |
| `POST /holiday/sessions/{holiday_session_id}/cancellation` — den **Termin absagen** samt Grund in einem Satz; storniert alle seine Buchungen, erstattet Bezahltes voll, berechnet Berechnetes nicht, und schickt allen betroffenen Familien dieselbe Mail mit dem Grund | [10](../soll-prozesse/10-ferienprogramm.md) Z6 | die anbietende Rolle des Programms; `secretariat` | Grund ist Pflicht (`ck_holiday_sessions_cancellation`); nicht zweimal. **„Alle in einem Griff" heißt eine Transaktion, keine Massenoperation**: Die Route lädt die Buchungen und ändert sie einzeln ([`gemeinsam.md`](gemeinsam.md#schreiben)), mit `retained_amount_cents = 0` — „für ihre eigene Absage gilt keine Frist und keine Gebühr". Der Termin bleibt sichtbar stehen, „damit hinterher unterscheidbar ist, ob er lief oder ausfiel" | schreibt, `entra:` | — |

**Die Stornofrist der Eltern steht als Zahl an der Terminart** und nicht im Code: eine
Spalte `cancellation_deadline_days` (nullable, gezählt zum ersten Tag des Programms; die
Kochwerkstatt trägt keine). — Alternative: die Frist als `if` über die drei bekannten `code`-Werte;
Preis: eine vierte Terminart bräuchte einen Deploy statt einer Zeile, und die Regel stünde an einer
Stelle, die kein Prüfskript sieht. **Der Betrag bleibt Handarbeit**: „Das System rechnet daraus
nichts" — es sperrt nur, wo der Block sperrt, und die Stelle trägt ein.

## Kostenübernahme

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /holiday/cost-coverage-codes` — einen Code für eine Mailadresse und ein Programm erzeugen, dazu der Satz, an wen berechnet wird; gibt den Klartext **genau einmal** zurück, gespeichert wird sein Hash | [10](../soll-prozesse/10-ferienprogramm.md) „Sonderfälle" | `secretariat`, die anbietende Rolle des Programms | unbeschränkt. Er gilt für **diese eine Anmeldung**, nur für seine Adresse, und verfällt **14 Tage** nach `created_at` — die Frist ist fest und steht in keiner Spalte (`schema/ferien-schema.sql`). Die Adresse prüft die Buchungsroute gegen die der Sitzung; auf dem [offiziellen Umweg](gemeinsam.md#der-offizielle-umweg) gibt es keine, und die Stelle, die stellvertretend bucht, ist dieselbe, die den Code erzeugt hat. Wie die Freischaltung in 05 „die benannte Ausnahme von einer Sperre samt [Änderungsspur](../soll-prozesse/hebel.md#änderungsspur)" | schreibt, `entra:` | — |
| `GET /holiday/cost-coverage-codes` — die erzeugten Codes samt Adresse, Programm, Abrechnungssatz, Urheber und der Angabe, ob eingelöst | [10](../soll-prozesse/10-ferienprogramm.md) „Was dabei erhoben wird" | `secretariat`, die anbietende Rolle des Programms | Listenroute, deshalb nie über den OTP-Pfad. **Nie den Code selbst** — gespeichert ist sein Hash, und wer ihn verloren hat, bekommt einen neuen. Abgelaufene und nicht eingelöste fallen heraus; „eingelöst" ist ein `EXISTS` auf `holiday_bookings` und keine Spalte | liest | — |

## Die Teilnehmerliste

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /holiday/sessions/{holiday_session_id}/participants` — wer an diesem Termin kommt: Name, Modul, Notfallnummer, Anmerkung, Fotoeinverständnis und bei bekannten Kindern der Gesundheits-Ausschnitt seiner Rolle; dazu je Zeile die Kennung der Buchung | [10](../soll-prozesse/10-ferienprogramm.md) Z7, „Dateien" | die anbietende Rolle des Programms, `day_care_staff`, `secretariat` | Listenroute, deshalb nie über den OTP-Pfad. [Frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste); **ohne die stornierten Buchungen**. Wer den Tag betreut, braucht keinen Zugang — die Stelle druckt sie aus | liest | die des Gesundheitsbestands, je nach Rolle (oben) |

**Der Gesundheits-Ausschnitt steht heute für zwei Rollen.** Die Hortleitung und die Hortkraft lesen
den Sichtkreis `care` über `backend_health_care`, die Hauswirtschaftsleitung den Sichtkreis `kitchen`
über `backend_kitchen`. Für das **Sekretariat trägt die Liste keinen**, obwohl es nach
[`gesundheit-api.md`](gesundheit-api.md) die volle Sicht hätte — diese Route ist beim Bau der
Domäne nicht mitgezogen und braucht dafür ein eigenes Ticket, keinen hier erfundenen dritten
Ausschnitt.

**Sie kommt als Zeilen, nicht als Druckansicht** — die Ausnahme, die
[`gemeinsam.md`](gemeinsam.md#liste) benennt und die schon `GET /applications` trägt: Aus dieser
Liste heraus storniert die Stelle einzelne Buchungen, also braucht die Oberfläche die Kennungen und
druckt ihren eigenen Bildschirm. — Alternative: eine Druckansicht daneben; Preis: zwei Routen auf
dieselbe Abfrage, deren zweite beim ersten Feld auseinanderläuft.

## Die drei Aufgaben

Keine entsteht über eine Route; jede ist Seiteneffekt der Handlung darüber
([`querschnitt-api.md`](querschnitt-api.md)). Gelesen und geschlossen werden sie über `GET /tasks`
und `PUT /tasks/{sync_task_id}`.

| Aufgabe | Ziel | Bezug | Wann |
|---|---|---|---|
| **Storno erklärt** — samt eigener Mail an die Stelle, „weil ein Storno drei Tage vor einem Ausflug ankommen muss, bevor die Wochenmail läuft"; sie läuft in der Wochenmail **neben** ihr weiter ([`hebel.md`](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail)) | ein Ziel je anbietender Rolle | `holiday_booking_id` | mit `POST …/cancellation-declaration`; geschlossen mit dem Eintrag |
| **Erstattung** — „je Fall eine Aufgabe bei der Buchhaltung, die die Rückzahlung auslöst"; kein Fremdsystem, sondern Handarbeit, die auf einen Menschen wartet | eigenes Ziel bei `accounting` | `holiday_booking_id` | mit `POST …/cancellation` und `POST …/sessions/{id}/cancellation`, wo `retained_amount_cents < amount_cents` **und** online bezahlt wurde. Eine berechnete Buchung erzeugt keine: „Wird eine berechnete Buchung storniert, fließt nichts zurück" |
| **Berechnete Buchungen nach Optigem** — eine je Kind, die **alle** seine berechneten Termine trägt und „von einer weiteren Buchung ersetzt statt verdoppelt wird" | `optigem_holiday` | `child_id` | mit jedem eingelösten Code und mit jedem Storno einer berechneten Buchung — dann trägt sie „den einbehaltenen Betrag statt des vollen", und nach einer Absage steht dort nichts mehr |

**Der Text der dritten wird aus dem ganzen aktuellen Stand der berechneten Buchungen dieses Kindes
gebaut**, nie aus der Änderung, die ihn ausgelöst hat — dieselbe Regel wie beim Beitragsstand
([`mensa-api.md`](mensa-api.md)), aus demselben Grund: `ix_sync_tasks_open_child` lässt je Ziel und
Kind nur eine offene Aufgabe zu. **Gebaut wird er hier und nicht in
`app/services/querschnitt.py:optigem_billing_text`**: Der trägt den Beitragsstand aus Hortmodulen und
Essensabo, und die Ferienbuchung ist keiner — sie hat mit `optigem_holiday` ihr eigenes Ziel, weil
sie eine Einzelforderung an ein Amt ist und kein laufender Beitrag ([09](../soll-prozesse/09-hortvertrag.md),
`optigem_one_off` aus demselben Grund).

**Die Storno-Aufgabe bekommt zwei Zielzeilen, je anbietender Rolle eine**, und die Route
wählt nach `holiday_programmes.offering_role_id`. Das ist die vorhandene Bauform und keine neue:
`optigem`, `optigem_one_off` und `optigem_holiday` sind schon heute drei Zeilen bei derselben Rolle
für dasselbe System. `GET /tasks` bleibt unberührt — sie „zählt keine Rolle auf", sondern vergleicht
`sync_targets.role_id` mit den Rollen des Aufrufers ([`querschnitt-api.md`](querschnitt-api.md)). —
Alternative: `sync_targets.role_id` wird nullable und die Aufgabe erbt ihre Rolle vom Programm;
Preis: eine Migration am Querschnitt und ein zweiter Weg, auf dem `GET /tasks` die Zuständigkeit
bestimmt — für den einzigen Fall im System, in dem sie wechselt.

**Die Erstattung bekommt ein eigenes Ziel** und läuft nicht unter `optigem_holiday`.
— Alternative: dasselbe Ziel für beides; Preis: „Die Art ist das Ziel, nicht der Anlass" — Geld
holen und Geld zurückzahlen sind zwei Arbeiten, und der Block sagt ausdrücklich, dass die Erstattung
kein Fremdsystem ist.

## Kein Lauf

**Diese Domäne hat keinen** ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)), und das ist eine
Aussage und keine Lücke:

- **Die Anmeldung schließt sich nicht selbst.** `registration_closes_at` ist ein Datum, gegen das
  jede Buchung prüft; `closed_at` ist der Griff von Hand. Ein Lauf, der das eine ins andere schriebe,
  legte je Programm eine Zeile in der Änderungsspur für einen Wert, der schon dasteht — dieselbe Form
  wie beim Jahreslauf der Essensabos ([`mensa-api.md`](mensa-api.md)).
- **Keine Erinnerung vor dem Termin**, keine Meldung nach innen außer der einen zum Storno.
- **Der Code verfällt ohne Lauf**: „verfällt nach 14 Tagen" ist `created_at + interval '14 days'`;
  weggeräumt wird die Zeile vom Lösch-Lauf (17), der auch den Anker dieser Domäne rechnet — den
  letzten gebuchten Termin des Kindes.

## Offene Fragen

Keine neue `[?]`. Die eine des Blocks steht dort und im Schema und ändert an keiner Route etwas:

`[?]` Wie lange werden Buchung und Kind nach dem letzten gebuchten Termin aufbewahrt —
**Datenschutzbeauftragte**. Ohne die Antwort hat der Löschanker dieser Domäne kein Ziel.

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Der Anmeldecode und die Sitzung dahinter** (Z2) — `zugang.md`, `app/routers/auth.py`; er trägt
  jedes öffentliche Formular und gehört keiner Fachdomäne.
- **Die Kinder der bekannten Familie zur Auswahl** — [`stammdaten-api.md`](stammdaten-api.md).
- **Die Notfallnummer** (`POST /persons/{person_id}/phone-numbers`) —
  [`stammdaten-api.md`](stammdaten-api.md); ihre Pflicht „greift mit der ersten Buchung", und die
  Regel steht dort.
- **Das Fotoeinverständnis** (`PUT /children/{child_id}/consents/photo`) und die **Werbe-Einwilligung**
  (`PUT /persons/{person_id}/consents/marketing_holiday`) — [`querschnitt-api.md`](querschnitt-api.md).
- **Die Essensvariante** (`PUT /children/{child_id}/meal-profile`) — [`mensa-api.md`](mensa-api.md);
  hier abgefragt, wo ein Modul ein Essen trägt, geführt dort.
- **Die Tagesliste der Küche**, auf der ein Kind mit `includes_lunch` steht —
  [`mensa-api.md`](mensa-api.md); sie liest `holiday_bookings` selbst.
- **`POST /payments/callback`** — [`querschnitt-api.md`](querschnitt-api.md), Form in
  [`gemeinsam.md`](gemeinsam.md#sofortzahlung). **Die Zahlungssitzung eröffnet diese Domäne selbst**,
  in `POST /holiday/bookings`; sie wandert nicht mit. Der **Einzelnachweis** `GET /payments` liest die
  Ferienzahlungen wie jede andere.
- **Aufgabe abhaken und der Bestand der Wochenmail** — [`querschnitt-api.md`](querschnitt-api.md),
  `GET /tasks` und `PUT /tasks/{sync_task_id}`.
- **Die Fassungen von `holiday_terms` und der drei Stornotexte** pflegen —
  [`querschnitt-api.md`](querschnitt-api.md), `POST /contract-texts`, `executive_management`.
- **Die Änderungsspur** — [`querschnitt-api.md`](querschnitt-api.md).
- **Der Gesundheits-Ausschnitt der Teilnehmerliste** — [`gesundheit-api.md`](gesundheit-api.md);
  beide Sichtkreise stehen dort.
- **Der Lösch-Lauf** (17), der Buchung, Anmerkung, Code und — über den letzten gebuchten Termin —
  Kind und Familie mitnimmt.
- **Keine Abgangsroute.** Eine gebuchte Teilnahme steht nicht auf der Abgangsliste
  ([`stammdaten-api.md`](stammdaten-api.md)), und der Jahreslauf sieht sie nicht.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **`fk_payments_holiday_booking` band `amount_cents` und vertrug sich nicht mit „mehrere Kinder in
  einem Zug".** Solange er das tat, musste der Betrag der Zahlung dem Betrag **einer** Buchung
  gleichen — ein Absenden über drei Kinder und vier Termine konnte dann entweder nicht als eine
  Zahlung entstehen oder gar nicht. **Gebaut ist er einfach über `holiday_booking_id`**, dieselbe
  Form wie die drei übrigen Anlässe; `uq_holiday_bookings_amount` ist mit ihm gefallen, weil kein
  Schlüssel mehr darauf zeigt, und der Kommentar an `payments.amount_cents` sagt jetzt, was für alle
  vier gilt: Eine Sitzung wird eine Zahlungszeile, und wo der Vorgang aus mehreren besteht, ist der
  Betrag die Summe.
- **`holiday_session_types` trug keine Stornofrist.** Der Text sagt sie einem Menschen, aber die
  Sperre der letzten drei Tage ist eine Maschinenregel, und sie gilt nur für zwei der drei
  Terminarten. Ohne Spalte hinge sie an `code`-Werten im Anwendungscode. **Gebaut ist sie als
  `cancellation_deadline_days`**, nullable `smallint` an `holiday_session_types`, gezählt zum ersten
  Tag des Programms — leer heißt „keine Sperre", und die Kochwerkstatt trägt leer.
- **`sync_targets` hatte für diese Domäne nur `optigem_holiday`.** Dazu stehen jetzt drei Zielzeilen
  im Seed: `holiday_cancellation_day_care` und `holiday_cancellation_domestic` je anbietender Rolle
  für die Storno-Meldung, `holiday_refund` für die Erstattung bei der Buchhaltung. Seed-Zeilen, keine
  Strukturänderung.
- **`holiday_programmes.offering_role_id` zeigt auf `roles` und ist damit frei wählbar.** Kein
  Constraint hält, dass es Hortleitung oder Hauswirtschaftsleitung ist; die Route prüft es. Ein CHECK
  ginge nur gegen eine Kennung, die der Seed vergibt, und das wäre schlechter als die Prüfung.
- **`holiday_bookings.amount_cents` erlaubt 0.** Ein Termin, dessen Modulbetrag und Aufschlag beide
  null sind, ließe sich buchen, ohne dass eine Zahlung entstehen kann (`ck_payments_amount` verlangt
  > 0). Der Fall kommt heute nicht vor, und die Route weist ihn ab, statt eine Sitzung über 0 € zu
  eröffnen.

## Festlegungen

Bestätigt und damit normaler Text; der verworfene Weg samt Preis bleibt überall stehen, weil er
sonst als Vorschlag wiederkommt. Die beiden `[A!]` behalten ihre Marke auch bestätigt: Ihr Wert ist,
dass jeder Prüflauf den Schnitt wiedersieht (`prompts/gemeinsam.md`) — der eine steht oben an der
Zahlung, der andere hier.

`[A!]` **Die Kochwerkstatt hat Kinder als Teilnehmer und keine Erwachsenen** — sie wird seit Jahren
ausschließlich für sie geplant, „gedacht für 8 bis 13, und wie das Ferienprogramm offen für alle
Kinder" (10). Diese Domäne legt deshalb **keine `persons`-Zeile ohne Kind** an, und keine Route nimmt
einen erwachsenen Teilnehmer entgegen. — Alternative: ein zweiter Buchungsweg für Erwachsene; Preis:
eine Buchung ohne Kind, also ohne Notfallnummer, ohne Anmerkung, ohne Löschanker — und ein zweiter
Zweig durch jede Route dieser Datei, für einen Fall, den kein Block beschreibt.
