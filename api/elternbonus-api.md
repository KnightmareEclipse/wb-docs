# Elternbonus — Routen

Aus [`14-elternbonus.md`](../soll-prozesse/14-elternbonus.md); es gilt [`gemeinsam.md`](gemeinsam.md),
und was dort steht, wiederholt diese Datei nicht.

**Gegenprobe:** Die Ablauftabelle hat **5 Zeilen**; alle fünf handeln im System — **2** tragen eine
Route dieser Datei (Z1, Z2), **2** sind [Läufe](#zwei-läufe) (Z3, Z4), **1** ist mit der bereits
gebauten Aufgabenroute des Querschnitts erledigt (Z5, [`querschnitt-api.md`](querschnitt-api.md)).
Es gibt **5 Routen**; **3** nennen eine Ablaufzeile, **2** einen Abschnitt des Blocks. Keine
Abweichung.

## Zwei Grenzen, die jede Route dieser Domäne einhält

- **Eine Stunde ist eine Stunde.** Kein Bewertungsschlüssel, keine Kategorie — „ob eine Tätigkeit
  überhaupt zählt, entscheidet niemand im System, das sagt, wer sie aufruft, beim Aufrufen". Keine
  Route dieser Datei validiert die Tätigkeit inhaltlich.
- **Die bestätigende Person ist eine Identität, keine Rolle.** „Genau die gewählte Person bestätigt
  oder lehnt ab; niemand sonst … kann ihn abnehmen" — der Ownership-Check vergleicht
  `employees.entra_object_id` des Aufrufers gegen `parent_work_entries.confirming_employee_id`,
  dieselbe Mechanik wie die Klassenlehrkraft in [`gesundheit-api.md`](gesundheit-api.md). Wählbar ist
  dafür jede Person mit einer Mitarbeiterrolle der Schule außer den beiden KITA-Rollen — das prüft
  bereits `GET /employees/selectable` (unten), diese Datei erfindet keine zweite Prüfung.

## Enge Rolle

**Keine.** Datum, Stundenzahl, Tätigkeit und eine bestätigende Person — kein Art.-9-Feld, keine
Bankverbindung. `backend_runtime` liest die ganze Tabelle, legt an und löscht; **geändert wird nur
die Entscheidung** — `confirmed_at`, `rejected_at` und `confirming_employee_name` sind die einzigen
drei Spalten im `GRANT UPDATE`. Ein abgesendeter Eintrag wird nie bearbeitet, sondern nur
entschieden, und den Namen schreibt allein der Lösch-Lauf (unten) neben eine ausgeschiedene Person.

## Pfad

Der Eintrag hängt nicht unter der Familie: `POST /parent-work-entries` legt ihn mit der Familie im
Rumpf an, denn die Route läuft auch für Sekretariat und Schulleitung, die keine Familie in der URL
mitbringen wollen, bevor sie wissen, welche gemeint ist. Die Familienansicht dagegen steht unter
`/families/{family_id}/parent-work` — derselbe Anker wie `/families/{family_id}/meals`
([`mensa-api.md`](mensa-api.md)), weil sie eine Ansicht ist und kein Vorgang. `/parent-work-entries/`
ohne Anker trägt die beiden Listen, die keinem Kind und keiner Familie gehören: die Warteschlange
einer Person und die Jahresliste — dieselbe Form wie `/meals/day-list` und `/meals/week-overview`.

## Die Einträge

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /parent-work-entries` — eine geleistete Stunde eintragen: Datum, halbe Stunden, Tätigkeit, die bestätigende Person | [14](../soll-prozesse/14-elternbonus.md) Z1 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie, nach [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) **nur „voll"** — der Eintrag mindert das Schulgeld der ganzen Familie, keine „eigene Angabe" einer eingeschränkten Person. Die bestätigende Person muss unter `GET /employees/selectable` stehen (unten); Sekretariat setzt **jedes Datum**, auch eines nach dem 31. Juli, solange die Jahresliste noch nicht übergeben ist ([offizieller Umweg](../soll-prozesse/hebel.md#der-offizielle-umweg)) | schreibt, `guardian:`/`entra:` | — |
| `PUT /parent-work-entries/{parent_work_entry_id}/decision` — bestätigen oder ablehnen | [14](../soll-prozesse/14-elternbonus.md) Z2 | die gewählte Person; `secretariat`, `school_management` (Umweg, „wenn die gewählte Person ausfällt") | genau die gewählte Person, per Ownership-Check (oben) — nicht per Rolle. **Ohne Begründung** — „Abgelehnt wird ohne Begründung im System". Nur solange noch nicht entschieden (`ck_parent_work_entries_decision`); eine Ablehnung ist endgültig, die Eltern tragen bei Bedarf neu ein | schreibt, `entra:` | — |
| `GET /parent-work-entries/pending` — die eigene Warteschlange: alle Einträge, die auf eine Entscheidung warten | [14](../soll-prozesse/14-elternbonus.md) Z2, „eine offene Aufgabe mit allen Einträgen, die auf sie warten — nicht eine je Eintrag" | jede Mitarbeiterrolle; `secretariat`, `school_management` | die eigenen wartenden Einträge (`confirming_employee_id` = Aufrufer); **Sekretariat und Schulleitung sehen alle**, dieselbe Allsicht wie `GET /tasks` ([`querschnitt-api.md`](querschnitt-api.md)) — ohne sie liefe der Umweg ins Leere, weil niemand die fremden Einträge fände. Listenroute, deshalb nie über den OTP-Pfad | liest | — |

## Die Ansichten

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /families/{family_id}/parent-work` — der Stand: bestätigt, offen, abgelehnt je Eintrag, dazu die berechneten Monate und der voraussichtliche Rückzahlbetrag nach dem laufenden Schuljahr | [14](../soll-prozesse/14-elternbonus.md) „Die Eltern sehen jederzeit ihren Stand … und das ist die Bestätigung" | Erziehungsberechtigte; `secretariat`, `school_management` | eigene Familie; Schulleitung **nicht nach Schulform**, sondern „jede Schulleitung, die ein Kind dieser Familie hat" ([`hebel.md`](../soll-prozesse/hebel.md#rollen)) — derselbe Satz wie beim Putzdienst, weil der Bonus ebenso an der Familie und keiner Schulform hängt. Zeigt bei Elternvertreter-Familien „voll, ohne Eintrag" (unten) und bei Mitarbeiterfamilien gar nichts (unten) statt einer Null. Der Betrag ist **gerechnet, nicht in `configured_values` verlinkt** — die Eltern sehen nie den rohen Wert, nur das Ergebnis (`gemeinsam.md`) | liest | — |
| `GET /parent-work-entries/annual-list?school_year=` — die **Jahresliste**: je Familie bestätigte Stunden, berechnete Monate, vorgeschlagener Rückzahlbetrag, samt Erlassgrund, wo einer greift | [14](../soll-prozesse/14-elternbonus.md) „Dateien" | `secretariat`, `school_management`, `accounting` | Schulleitung wie in der Familienansicht — jede Schulform, die in dieser Familie ein Kind trägt; Sekretariat und Buchhaltung unbeschränkt. [Frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste), nie über den OTP-Pfad. Ohne Mitarbeiterfamilien und ohne Familien ohne eingeschriebenes Kind — sie tauchen nicht als Nullzeile auf, sondern gar nicht | liest | — |

## Zwei Sonderfälle, gerechnet und nicht erhoben

- **Elternvertreter** (aus [16](../soll-prozesse/16-elternvertretung.md), gelesen über
  `class_representatives`) gelten für das Schuljahr ihres Amts als voll, ohne einen Eintrag. Beide
  Ansichten oben tragen das als eigenes Flag (`full_via_representation`) statt als erfundene
  Einträge — eine Familie mit dem Amt und null Zeilen soll nicht wie eine aussehen, die nichts
  geleistet hat.
- **Mitarbeiterfamilien** (eine Person mit `employees.house_id = school` irgendwann im Schuljahr)
  zahlen und leisten nichts. Beide Ansichten lassen sie **aus der Rechnung fallen** — kein Eintrag,
  kein Betrag, keine Zeile in der Jahresliste — statt eine Ausnahme im Frontend zu markieren.

## Zwei Läufe

Keine Route, kein Endpunkt von außen ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

| Lauf | Herkunft | Auslöser | Aktor |
|---|---|---|---|
| **Die Erinnerungsmail** an jede Familie mit offenen Stunden: Stand, was fehlt, was unbestätigt ist, dass am 31. Juli Schluss ist | [14](../soll-prozesse/14-elternbonus.md) Z3 | der 1. Juni | `system:parent_work_reminder` |
| **Der Jahresschluss**: rechnet je Familie den Rückzahlbetrag, deckelt ihn auf das berechnete Jahr und legt die Jahresliste als **eine** Aufgabe bei der Buchhaltung an (`sync_targets`, Ziel `optigem`, [`querschnitt-api.md`](querschnitt-api.md)) | [14](../soll-prozesse/14-elternbonus.md) Z4 | der 1. August, **vor** dem [Jahreslauf](../soll-prozesse/04-schuljahreswechsel.md) desselben Tages | `system:rollover` |

**Warum die Aufgabe kein eigenes Ziel bekommt:** Es ist dieselbe Optigem-Verrechnung wie jede
Schulgeld-nahe Buchung — „die Art ist das Ziel, nicht der Anlass" ([`hebel.md`](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail)).
Ein zweites Ziel `optigem_parent_work` würde dieselbe Regel verletzen, die
[`mensa-api.md`](mensa-api.md) für das Essen der Hortkinder schon zieht.

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Die wählbare Person** — `GET /employees/selectable` ([`stammdaten-api.md`](stammdaten-api.md)),
  bereits gebaut und bereits auf diese Domäne zugeschnitten (die beiden KITA-Rollen fallen heraus).
- **Der Monatsbetrag und die beiden Pflichtstundenzahlen** — `configured_values`, die vier Routen
  auf `/configured-values` ([`querschnitt-api.md`](querschnitt-api.md)), `executive_management`.
  Drei Codes nach demselben Muster wie `cleaning_buyout_cents`: `parent_work_monthly_cents`,
  `parent_work_hours_primary`, `parent_work_hours_default` — so gebaut, einzutragen mit den
  übrigen (`backlog/`, TASK-051).
- **Das Abhaken der Buchhaltungs-Aufgabe** — `GET /tasks`, `PUT /tasks/{sync_task_id}`
  ([`querschnitt-api.md`](querschnitt-api.md)).
- **Wer Elternvertreter ist und für welchen Zeitraum** — [16](../soll-prozesse/16-elternvertretung.md),
  sofern dort geplant; diese Domäne liest `class_representatives` nur.
- **Die Wochenmail-Zuordnung an die benannte Person** — Mail-Mechanismus, keine Route
  ([`hebel.md`](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail)).
- **Die Änderungsspur** — [`querschnitt-api.md`](querschnitt-api.md).
- **Der Lösch-Lauf** (17): nimmt Einträge und Jahresliste zum übernächsten Schuljahresanfang; trägt
  den Namen der bestätigenden Person nach, bevor ein gelöschter Mitarbeitendeneintrag seine Zeile
  mitnimmt (`schema/elternbonus-schema.sql`).
- **Kein Zahlungsweg.** Der Aufschlag läuft über das Schulgeld in Optigem, diese Domäne eröffnet
  keine Zahlungssitzung.

## Offene Fragen

Keine neuen. Die zwei des Blocks stehen dort und im Schema, unverändert durch diesen Plan:

`[?]` Ist der Text der Anlage anzupassen — Eintragung im Portal statt Zettel, Frist 31. Juli, und
dass nur bestätigte Stunden zählen? — Geschäftsführung.

`[?]` Wird der Bonus in Optigem als eigene Position geführt? — Buchhaltung.
