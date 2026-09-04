# Elternbonus — Routen

Aus [`14-elternbonus.md`](../soll-prozesse/14-elternbonus.md); es gilt [`gemeinsam.md`](gemeinsam.md),
und was dort steht, wiederholt diese Datei nicht.

**Gegenprobe:** Die Ablauftabelle hat **7 Zeilen**; alle sieben handeln im System — **3** tragen
eine Route dieser Datei (Z1, Z2, Z4), **3** sind [Läufe](#drei-läufe) (Z3, Z5, Z6), **1** ist mit
der bereits gebauten Aufgabenroute des Querschnitts erledigt (Z7,
[`querschnitt-api.md`](querschnitt-api.md)). Es gibt **10 Routen**; **7** nennen eine Ablaufzeile,
**3** einen Abschnitt des Blocks. Keine Abweichung.

## Drei Grenzen, die jede Route dieser Domäne einhält

- **Eine Stunde ist eine Stunde.** Kein Bewertungsschlüssel, keine Kategorie — „ob eine Tätigkeit
  überhaupt zählt, entscheidet niemand im System, das sagt, wer sie aufruft, beim Aufrufen". Keine
  Route dieser Datei validiert die Tätigkeit inhaltlich.
- **Niemand bestätigt eine Stunde.** „Was die Eltern eintragen, zählt" (14, entschieden am
  01.09.2026). Es gibt keine bestätigende Person, keine Warteschlange, keine Entscheidung; eine
  eingetragene Stunde zählt sofort, und der Preis steht im Block: Die Jahresliste trägt ungeprüfte
  Zahlen. `GET /employees/selectable` ([`stammdaten-api.md`](stammdaten-api.md)) hat diese Domäne
  damit nicht mehr als Aufrufer.
- **Die Platzzahl hält die Datenbank.** `trg_parent_work_signups_capacity` zählt unter Sperre und
  wirft `check_violation`; die Route fängt sie und antwortet `400` mit „Der Einsatz ist voll" — ein
  500er wäre hier der Fehler. Sie zählt **nicht** selbst vor: Ein `SELECT count(*)` vor dem `INSERT`
  wäre die zweite Stelle derselben Regel und verlöre das Rennen, das der Trigger gewinnt.

## Enge Rolle

**Keine.** Datum, Stundenzahl, Tätigkeit, ein Einsatz mit Treffpunkt und Anmeldungen — kein
Art.-9-Feld, keine Bankverbindung. `backend_runtime` liest die vier Tabellen, legt an und löscht;
geändert wird am **Eintrag** nichts — er wird eingetragen, nie bearbeitet —, am **Einsatz** seine
Ausschreibung, die Absage und die Erinnerungsmarke.

## Pfad

Drei Sachen tragen ihn: der **Einsatz** (`/parent-work-sessions/…`) samt seinen Anmeldungen
(`…/signups`), der **Eintrag** (`/parent-work-entries`) und die **Ansichten**
(`/families/{family_id}/parent-work`, `/parent-work-entries/annual-list`).

**Der Eintrag hängt nicht unter der Familie:** `POST /parent-work-entries` legt ihn mit der Familie
im Rumpf an, denn die Route läuft auch für das Sekretariat, das keine Familie in der URL mitbringen
will, bevor es weiß, welche gemeint ist. Die Familienansicht dagegen steht unter
`/families/{family_id}/parent-work` — derselbe Anker wie `/families/{family_id}/meals`
([`mensa-api.md`](mensa-api.md)), weil sie eine Ansicht ist und kein Vorgang.

**Die Anmeldung hängt am Einsatz und an der Person**, nicht an der Familie: „Es können zwei aus
derselben Familie kommen" (`schema/elternbonus-schema.sql`). Der Elternteil meldet sich selbst an
(`acting_as`); das Sekretariat nennt die Person im Rumpf ([offizieller
Umweg](../soll-prozesse/hebel.md#der-offizielle-umweg)).

## Der Einsatz

**Ausschreiben dürfen sechs Rollen**, in 14 benannt: `caretaker`, `teacher`, `secretariat`,
`school_management`, `domestic_services_management`, `day_care_management`. Keine neue Rolle,
keine Spalte — die Route nennt ihre Rollen wie jede andere. **Draußen bleiben** `staff`,
`canteen`, `approver`, `personnel`, `accounting` und die beiden KITA-Rollen.

`[A]` **Ändern, absagen und die Namen sehen darf, wer ausgeschrieben hat** — geprüft über
`created_by` gegen den Aufrufer —, dazu `secretariat` und `school_management` als Umweg. Die
übrigen vier Rollen sehen einen fremden Einsatz wie die Eltern: mit der Zahl. — Alternative: jede
der sechs Rollen darf jeden Einsatz ändern; Preis: die Hortleitung sagt den Ausflug der Lehrkraft
ab, und die Anmeldeliste mit Namen läge sechs Rollen offen statt der einen, die „Hände braucht".

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /parent-work-sessions` — einen Einsatz ausschreiben: Tag und Beginn, Tätigkeit, freiwillig Beschreibung und Mitzubringendes, Treffpunkt, freiwillig die Platzzahl, und **wen er anspricht** als Liste aus benannten Klassen und Zuschnitten (Schulart, Stufe ab, Stufe bis) | [14](../soll-prozesse/14-elternbonus.md) Z1 | die sechs Rollen oben | unbeschränkt. Ohne Zielgruppenzeile alle Familien; jede Zeile entweder eine Klasse oder ein Zuschnitt, nie beides und nie keines (`ck_parent_work_session_audiences_form`); eine Klasse einer fremden Schulart ist für die Schulleitung nicht wählbar (`branches_of`). **Kein Ende und keine Dauer.** Keine Mail an alle Eltern: „Wer Hände anbietet, schaut ins Portal" | schreibt, `entra:` | — |
| `PUT /parent-work-sessions/{parent_work_session_id}` — Ausschreibung ändern, samt Zielgruppe | [14](../soll-prozesse/14-elternbonus.md) Z1 | der Ausschreibende; `secretariat`, `school_management` | nur der eigene Einsatz (oben); nicht mehr nach dem Beginn und nicht nach der Absage. Die Zielgruppe wird **ersetzt**, Zeile für Zeile ([`gemeinsam.md`](gemeinsam.md#schreiben)); die Platzzahl darf nicht unter die Zahl der Angemeldeten fallen — sonst hielte der Trigger einen Zustand, den niemand herbeigeführt hat | schreibt, `entra:` | — |
| `POST /parent-work-sessions/{parent_work_session_id}/cancellation` — den Einsatz absagen, freiwillig mit Grund | [14](../soll-prozesse/14-elternbonus.md) „Abgesagt wird von beiden Seiten" | der Ausschreibende; `secretariat`, `school_management` | nur der eigene Einsatz; einmal — ein abgesagter Einsatz wird nicht noch einmal abgesagt. Setzt `cancelled_at`, löscht **nichts**: „Der abgesagte Einsatz bleibt stehen und ist der Beleg dafür, dass die Mail rausging." **Schickt sofort die Mail an alle Angemeldeten**, mit dem Grund, wenn einer steht, über den einen Versandweg (`send_tracked`) | schreibt, `entra:` | — |
| `GET /parent-work-sessions` — die Einsätze: für Eltern die, die ihre Familie ansprechen, für Personal alle; je Einsatz die Ausschreibung, die Zahl der Angemeldeten, ob abgesagt, und für den Elternteil, ob er selbst angemeldet ist | [14](../soll-prozesse/14-elternbonus.md) Z2, „Sehen die Einsätze, die sie betreffen" | Erziehungsberechtigte; jede Mitarbeiterrolle | Eltern nur die Einsätze, deren Zielgruppe ein **eingeschriebenes Kind einer ihrer Familien** trifft — ausgewertet **in der Query** gegen `children.class_id`, `school_branch_id` und `grade_level`, oder ohne Zielgruppenzeile; **Zahl, nie Namen**. Vergangene Einsätze fallen für die Eltern heraus, abgesagte bleiben sichtbar markiert. Personal sieht alle, ebenfalls mit der Zahl; die Namen stehen in der Einzelansicht | liest | — |
| `GET /parent-work-sessions/{parent_work_session_id}` — ein Einsatz; für den Ausschreibenden, das Sekretariat und die Schulleitung **mit den Namen der Angemeldeten** | [14](../soll-prozesse/14-elternbonus.md) „Wer sich angemeldet hat, sieht der Hausmeister; die Eltern sehen nur die Zahl" | Erziehungsberechtigte; jede Mitarbeiterrolle | Eltern nur einen Einsatz, der ihre Familie anspricht (`404` sonst), und nur die Zahl; Namen allein für den Ausschreibenden, `secretariat`, `school_management` — für die übrigen Rollen die Zahl, denn wer nicht ausgeschrieben hat, „braucht Hände" nicht | liest | — |
| `POST /parent-work-sessions/{parent_work_session_id}/signups` — sich anmelden | [14](../soll-prozesse/14-elternbonus.md) Z2 | Erziehungsberechtigte; `secretariat` (Umweg, Person im Rumpf) | nur ein Einsatz, der die eigene Familie anspricht; **bis er beginnt** (`400` danach); nicht abgesagt; die Person ist der Aufrufer (`acting_as`), nach [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) **nur „voll"**. Zweimal ist einmal (`uq_parent_work_signups`, `409`); **voll ist `400`** „Der Einsatz ist voll", gefangen aus der `check_violation` des Triggers — wer zuerst kommt, kein Nachrücken | schreibt, `guardian:`/`entra:` | — |
| `DELETE /parent-work-sessions/{parent_work_session_id}/signups/{parent_work_signup_id}` — sich abmelden | [14](../soll-prozesse/14-elternbonus.md) Z2, „oder wieder ab" | Erziehungsberechtigte; `secretariat` (Umweg) | nur die eigene Anmeldung (`person_id` = `acting_as`), bis der Einsatz beginnt. Löscht die Zeile: „eine Anmeldung, die es nicht mehr gibt, ist keine". **Keine Mail an die Schule** — „wer ausgeschrieben hat, sieht seine Anmeldeliste" | schreibt, `guardian:`/`entra:` | — |

## Der Eintrag

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /parent-work-entries` — eine geleistete Stunde eintragen: Datum, halbe Stunden, Tätigkeit, freiwillig der Einsatz, aus dem sie kommt | [14](../soll-prozesse/14-elternbonus.md) Z4 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie, nach [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) **nur „voll"** — der Eintrag mindert das Schulgeld der ganzen Familie. **Zählt sofort.** Mit Einsatz sind Datum und Tätigkeit vorausgefüllt: Fehlen sie im Rumpf, kommen sie vom Einsatz, kopiert und nicht verwiesen; der Einsatz muss die Familie ansprechen, eine Anmeldung ist **nicht** Voraussetzung („auch wer sich nie angemeldet hat, trägt seine Stunde ein"). Ohne Einsatz ist der häufigere Weg. Eltern nur bis zum 31. Juli des Schuljahrs, dem das Datum gehört; Sekretariat setzt **jedes Datum**, solange die Jahresliste noch nicht übergeben ist | schreibt, `guardian:`/`entra:` | — |

## Die Ansichten

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /families/{family_id}/parent-work` — der Stand: die Einträge des Schuljahrs, die gezählten Stunden, die berechneten Monate und der voraussichtliche Rückzahlbetrag | [14](../soll-prozesse/14-elternbonus.md) „Die Eltern sehen jederzeit ihren Stand … und das ist die Bestätigung" | Erziehungsberechtigte; `secretariat`, `school_management` | eigene Familie; Schulleitung **nicht nach Schulform**, sondern „jede Schulleitung, die ein Kind dieser Familie hat" ([`hebel.md`](../soll-prozesse/hebel.md#rollen)). Zeigt bei Elternvertreter-Familien „voll, ohne Eintrag" (unten) und bei Mitarbeiterfamilien gar nichts statt einer Null. Der Betrag ist **gerechnet, nicht in `configured_values` verlinkt** | liest | — |
| `GET /parent-work-entries/annual-list?school_year=` — die **Jahresliste**: je Familie eingetragene Stunden, berechnete Monate, vorgeschlagener Rückzahlbetrag, samt Erlassgrund, wo einer greift | [14](../soll-prozesse/14-elternbonus.md) „Dateien" | `secretariat`, `school_management`, `accounting` | Schulleitung wie in der Familienansicht; Sekretariat und Buchhaltung unbeschränkt. [Frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste), nie über den OTP-Pfad. Ohne Mitarbeiterfamilien und ohne Familien ohne eingeschriebenes Kind | liest | — |

## Zwei Sonderfälle, gerechnet und nicht erhoben

- **Elternvertreter** (aus [16](../soll-prozesse/16-elternvertretung.md), gelesen über
  `class_representatives`) gelten für das Schuljahr ihres Amts als voll, ohne einen Eintrag. Beide
  Ansichten tragen das als eigenes Flag (`full_via_representation`) statt als erfundene Einträge.
- **Mitarbeiterfamilien** (eine Person mit `employees.house_id = school` irgendwann im Schuljahr)
  zahlen und leisten nichts. Beide Ansichten lassen sie **aus der Rechnung fallen** — kein Eintrag,
  kein Betrag, keine Zeile in der Jahresliste.

## Drei Läufe

Keine Route, kein Endpunkt von außen ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

| Lauf | Herkunft | Auslöser | Aktor |
|---|---|---|---|
| **Die Erinnerung am Vortag** an alle Angemeldeten eines Einsatzes: Tag, Beginn, Treffpunkt, Mitzubringendes — „das ist der Punkt, an dem heute Einsätze vergessen werden". Marke: `parent_work_sessions.reminder_sent_at`; abgesagte Einsätze bekommen keine | [14](../soll-prozesse/14-elternbonus.md) Z3 | der Tag vor `starts_at` | `system:parent_work_session_reminder` |
| **Die Erinnerungsmail** an jede Familie mit offenen Stunden: Stand, was fehlt, dass am 31. Juli Schluss ist | [14](../soll-prozesse/14-elternbonus.md) Z5 | der 1. Juni | `system:parent_work_reminder` |
| **Der Jahresschluss**: rechnet je Familie den Rückzahlbetrag, deckelt ihn auf das berechnete Jahr und legt die Jahresliste als **eine** Aufgabe bei der Buchhaltung an (`sync_targets`, Ziel `optigem`) | [14](../soll-prozesse/14-elternbonus.md) Z6 | der 1. August, **vor** dem [Jahreslauf](../soll-prozesse/04-schuljahreswechsel.md) desselben Tages | `system:rollover` |

**Warum die Aufgabe kein eigenes Ziel bekommt:** Es ist dieselbe Optigem-Verrechnung wie jede
Schulgeld-nahe Buchung — „die Art ist das Ziel, nicht der Anlass"
([`hebel.md`](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail)).

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Der Monatsbetrag und die beiden Pflichtstundenzahlen** — `configured_values`, die vier Routen
  auf `/configured-values` ([`querschnitt-api.md`](querschnitt-api.md)), `executive_management`:
  `parent_work_monthly_cents`, `parent_work_hours_primary`, `parent_work_hours_default`.
- **Das Abhaken der Buchhaltungs-Aufgabe** — `GET /tasks`, `PUT /tasks/{sync_task_id}`
  ([`querschnitt-api.md`](querschnitt-api.md)).
- **Wer Elternvertreter ist und für welchen Zeitraum** — [16](../soll-prozesse/16-elternvertretung.md);
  diese Domäne liest `class_representatives` nur.
- **Die Klassen zur Auswahl der Zielgruppe** — `GET /classes` ([`klassenorganisation-api.md`](klassenorganisation-api.md)).
- **Die Änderungsspur** — [`querschnitt-api.md`](querschnitt-api.md).
- **Der Lösch-Lauf** (17): nimmt Einsätze, Anmeldungen, Einträge und Jahresliste zum übernächsten
  Schuljahresanfang.
- **Kein Zahlungsweg.** Der Aufschlag läuft über das Schulgeld in Optigem.

## Offene Fragen

Keine neuen. Die zwei des Blocks stehen dort und im Schema, unverändert durch diesen Plan:

`[?]` Ist der Text der Anlage anzupassen — Eintragung im Portal statt Zettel und Frist 31. Juli? —
Geschäftsführung.
