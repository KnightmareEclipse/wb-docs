# Putzdienst — Routen

Aus [`01-putzdienst.md`](../soll-prozesse/01-putzdienst.md); es gilt [`gemeinsam.md`](gemeinsam.md),
und was dort steht, wiederholt diese Datei nicht.

**Gegenprobe:** Die Ablauftabelle des Blocks hat **12 Zeilen**; **7** tragen eine Route, **4** einen
[Lauf](#die-vier-läufe), **1** liegt außerhalb des Systems. Es gibt **27 Routen**; **24** nennen eine
Ablaufzeile, **3** eine andere Stelle des Blocks:

- `POST …/cancellation` (Termin absagen) — Abschnitt „Sonderfälle", keine Ablaufzeile: Der Ablauf
  beschreibt das Putzdienstjahr, die Absage eines einzelnen Termins steht daneben. Die Mail geht
  hier aus demselben Grund raus wie beim Verschieben: Wer eingeteilt war, erfährt sonst nur beim
  Blick ins Portal, dass er nicht zu kommen braucht — und ein Termin, zu dem jemand umsonst
  erscheint, ist teurer als eine Mail. Sie sagt zugleich, dass die Pflicht damit erledigt ist („das
  geht dann zu Lasten der Schule"), sonst rechnet die Familie weiter mit einem offenen Termin.
- `PATCH /cleaning/cycles/{year}` — Ablaufzeile 1 legt an; ändern trägt die Standardantwort „Ändern"
  aus [`hebel.md`](../soll-prozesse/hebel.md#standardantworten).
- `GET /cleaning/families/{family_id}` — Abschnitt „Was dabei erhoben wird": „Eltern sehen ihre
  eigenen Termine und ihren Stand". Der Ablauf nennt die Ansicht nirgends, obwohl sie die Bestätigung
  jeder Buchung ist (Standardantwort „Bestätigungsmail").

**Enge Rolle: keine, in dieser ganzen Domäne.** Kein Art.-9-Feld, keine Bankverbindung — die Strafe
wird in Optigem gefordert, nicht hier (`glossar.md`, `wb-backend/README.md`). Die Spalte steht
trotzdem an jeder Route, damit ihr Fehlen eine Aussage bleibt und keine Auslassung.

**Zwei Grenzen, die jede Route dieser Domäne einhält:**

- **Alles hängt an der Familie, nie am Kind.** Keine Route nimmt eine `child_id`.
- **Ein freigekaufter Termin ist weg, seine Zeile bleibt stehen.** `cleaning_slot_buyouts` hängt an
  der Zuteilung und hält sie fest (`schema/putzdienst-schema.sql`). Jede Liste, jede Erinnerung, jede
  Anwesenheits- und Strafroute filtert Zuteilungen mit Freikauf aus; das Schema trägt dafür kein
  Kennzeichen, es ist eine Regel der Anwendung.

`[A]` Das Putzdienstjahr wird über `start_year` adressiert (`/cleaning/cycles/2026`), nicht über
seine ID. — Alternative: `cleaning_cycle_id`; Preis: jede Adresse braucht einen Nachschlag, und in
jedem Gespräch heißt der Zyklus ohnehin bei seinem Jahr.

## Putzdienstjahr und Termine

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /cleaning/cycles` — welche Putzdienstjahre eingerichtet sind, samt Fenster und Mengen, das jüngste zuerst | [01](../soll-prozesse/01-putzdienst.md) Z1 | `secretariat` | Listenroute, deshalb nie über den OTP-Pfad ([`gemeinsam.md`](gemeinsam.md)); ohne sie liest man einen Zyklus nur, indem man ihn ändert | liest | — |
| `POST /cleaning/cycles` — Putzdienstjahr einrichten: Jahr, Anmeldefenster und je Art Pflichtmenge und Standard-Platzzahl, in einer Transaktion | [01](../soll-prozesse/01-putzdienst.md) Z1 | `secretariat` | unbeschränkt | schreibt, `entra:` | — |
| `PATCH /cleaning/cycles/{year}` — Anmeldefenster, Pflichtmenge oder Standard-Platzzahl ändern | [01](../soll-prozesse/01-putzdienst.md) Z1 + `hebel.md` „Ändern" | `secretariat` | nur bis `registration_closes_at`; danach „bewirkt eine Änderung nichts mehr" | schreibt, `entra:` | — |
| `GET /cleaning/cycles/{year}/carry-over` — die Familien mit abweichender Pflichtzahl im Vorjahr, samt ihrer Zahl | [01](../soll-prozesse/01-putzdienst.md) Z1 | `secretariat` | unbeschränkt (interne Liste, nie über OTP) | liest | — |
| `PUT /cleaning/cycles/{year}/families/{family_id}/quota` — abweichende Pflichtmenge je Art setzen | [01](../soll-prozesse/01-putzdienst.md) Z1 und „Sonderfälle"; [08](../soll-prozesse/08-schulvertrag.md) Z5 | `secretariat`, `school_management`, `executive_management` | Schulleitung nur, wenn ein Kind dieser Familie ihre Schulform trägt (`hebel.md`, „Rollen") | schreibt, `entra:` | — |
| `POST /cleaning/cycles/{year}/slots` — Termin anlegen: Startzeitpunkt, Art, Hinweistext, abweichende Platzzahl | [01](../soll-prozesse/01-putzdienst.md) Z1, „Sonderfälle" | `secretariat` | unbeschränkt | schreibt, `entra:` | — |
| `PATCH /cleaning/slots/{slot_id}` — Startzeitpunkt, Art, Hinweistext oder Platzzahl ändern | [01](../soll-prozesse/01-putzdienst.md) Z1, „Sonderfälle" | `secretariat` | Platzzahl nur bis zur Zuteilung; ein belegter Termin löst die Mail an seine Familien aus | schreibt, `entra:` | — |
| `POST /cleaning/slots/{slot_id}/cancellation` — Termin absagen; die Zuteilungen bleiben sichtbar, die Anwesenheit ist gesperrt, und ein belegter Termin löst die Mail an seine Familien aus | [01](../soll-prozesse/01-putzdienst.md) „Sonderfälle" | `secretariat` | nicht nach `attendance_recorded_at` (`ck_cleaning_slots_cancelled`) | schreibt, `entra:` | — |
| `GET /cleaning/slots/{slot_id}` — der Termin samt der eingeteilten Familien | [01](../soll-prozesse/01-putzdienst.md) Z11 | `secretariat` | unbeschränkt | liest | — |

## Zuteilung

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /cleaning/cycles/{year}/allocation` — das Gesamtbild, mit den Terminen, an denen die Platzzahl überschritten wurde | [01](../soll-prozesse/01-putzdienst.md) Z5 | `secretariat` | unbeschränkt | liest | — |
| `GET /cleaning/cycles/{year}/families` — welche Familien das Jahr betrifft, **mit Namen**: wer etwas schuldet und wer auf einem Termin steht | [01](../soll-prozesse/01-putzdienst.md) Z5 | `secretariat` | Listenroute, deshalb nie über den OTP-Pfad ([`gemeinsam.md`](gemeinsam.md)); die Bezeichnung sind die Erziehungsberechtigten, dieselben Namen wie auf der Anwesenheitsliste — jede andere Route nennt die Familie nur als Kennung, und die trägt kein Bildschirm | liest | — |
| `POST /cleaning/cycles/{year}/allocation/release` — Zuteilung freigeben; setzt `allocation_released_at` und stößt die Zuteilungsmail an | [01](../soll-prozesse/01-putzdienst.md) Z5 | `secretariat` | erst nach dem Lauf (`ck_cleaning_cycles_release`), genau einmal | schreibt, `entra:` | — |
| `POST /cleaning/families/{family_id}/assignments` — einer Familie einen Termin von Hand zuteilen; die Familie bekommt ihre aktuelle Terminliste | [01](../soll-prozesse/01-putzdienst.md) Z5, „Sonderfälle" | `secretariat` | unbeschränkt; `source = 'manual'` | schreibt, `entra:` | — |
| `PATCH /cleaning/assignments/{assignment_id}` — eine Familie auf einen anderen Termin verschieben; die Familie bekommt ihre aktuelle Terminliste | [01](../soll-prozesse/01-putzdienst.md) Z5, „Sonderfälle" | `secretariat` | derselbe Zyklus, dieselbe Art; nicht nach `attendance_recorded_at` | schreibt, `entra:` | — |
| `DELETE /cleaning/assignments/{assignment_id}` — Termin streichen bzw. eine Reservierung freigeben | [01](../soll-prozesse/01-putzdienst.md) Z3 (Eltern), Z5 und „Sonderfälle" (Sekretariat) | `secretariat`; Erziehungsberechtigte | Eltern: nur die eigene Familie, nur `source = 'reserved'`, nur im offenen Anmeldefenster. Sekretariat: jeder Termin, auch ein selbst reservierter — und dann geht die aktuelle Terminliste an die Familie | schreibt, `entra:` / `guardian:` | — |

## Eltern: reservieren, freikaufen, tauschen

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /cleaning/families/{family_id}` — der Stand der Familie: Pflichtzahl je Art, eigene Termine, freigekauft, geleistet, offen, Strafen samt Rückzug, und „noch nicht ausgewertet" am gelaufenen Termin | [01](../soll-prozesse/01-putzdienst.md) „Was dabei erhoben wird" | Erziehungsberechtigte; `secretariat` | nur die eigene Familie; **zeigt nie, wer sonst an einem Termin steht** | liest | — |
| `GET /cleaning/cycles/{year}/slots` — die wählbaren Termine mit Startzeitpunkt, Art, Hinweistext und freien Plätzen | [01](../soll-prozesse/01-putzdienst.md) Z3 | Erziehungsberechtigte; `secretariat` | nur im offenen Anmeldefenster; Termine im September nur, wenn die Familie im dann laufenden Schuljahr planmäßig noch ein Kind an der Schule hat | liest | — |
| `POST /cleaning/families/{family_id}/reservations` — einen Termin reservieren | [01](../soll-prozesse/01-putzdienst.md) Z3 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie; offenes Fenster; höchstens die offene Pflichtzahl dieser Art; nicht zweimal derselbe Termin (`uq_cleaning_assignments`); `source = 'reserved'`. Eine sorgeberechtigte Person allein genügt | schreibt, `guardian:` / `entra:` | — |
| `POST /cleaning/families/{family_id}/buyouts` — Pflichttermine freikaufen, je Art eine Anzahl, auch alle auf einmal ohne einen einzigen gebuchten Termin; eröffnet die Zahlung | [01](../soll-prozesse/01-putzdienst.md) Z3 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie; höchstens die offene Pflichtzahl dieser Art; keine Frist, solange kein Termin daran hängt | schreibt erst im Rückruf, `system:payments` ([`gemeinsam.md`](gemeinsam.md#sofortzahlung)) | — |
| `POST /cleaning/assignments/{assignment_id}/buyout` — einen konkreten Termin freikaufen; eröffnet die Zahlung | [01](../soll-prozesse/01-putzdienst.md) Z7 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie; **bis drei Tage vor diesem Termin**, fest und nirgends einstellbar; höchstens einmal je Termin (`uq_cleaning_slot_buyouts`); kein Rücktritt | schreibt erst im Rückruf, `system:payments` | — |
| `POST /cleaning/assignments/{assignment_id}/swap-offer` — einen eigenen Termin zum Tausch stellen | [01](../soll-prozesse/01-putzdienst.md) Z8 | Erziehungsberechtigte | eigene Familie; je Termin nur ein offenes Angebot (`ix_cleaning_swap_offers_open`); nicht für einen gelaufenen Termin | schreibt, `guardian:` | — |
| `DELETE /cleaning/swap-offers/{offer_id}` — das eigene Angebot zurückziehen | [01](../soll-prozesse/01-putzdienst.md) Z8 | Erziehungsberechtigte | eigene Familie; nur solange `matched_at` leer ist | schreibt, `guardian:` | — |
| `GET /cleaning/swap-offers` — die angebotenen Termine des laufenden Jahres | [01](../soll-prozesse/01-putzdienst.md) Z8 | Erziehungsberechtigte | **nur Startzeitpunkt und Art, keine Namen, keine Kontaktdaten**; nur die Arten, die die Familie selbst anbietet; das eigene Angebot steht markiert darin, statt zu fehlen — die Haken hängen daran und **stehen mit an ihm**, weil `PUT …/acceptances` die ganze Menge setzt und eine Oberfläche, die sie nicht zurücklesen kann, sie beim nächsten Speichern leert; **nicht die fremden Termine, an denen die Familie schon steht** (`schema/putzdienst-schema.sql`: die Anwendung prüft das vor dem Ankreuzen) | liest | — |
| `PUT /cleaning/swap-offers/{offer_id}/acceptances` — setzt, welche fremden Termine diese Familie dafür nähme; akzeptieren sich zwei Angebote gegenseitig, **tauscht dieselbe Transaktion sofort** und schickt beiden Familien ihren neuen Termin | [01](../soll-prozesse/01-putzdienst.md) Z8 | Erziehungsberechtigte | eigene Familie; die Menge wird geladen und abgeglichen, nie als Menge gelöscht ([`gemeinsam.md`](gemeinsam.md#schreiben)); der Tausch setzt beide Zuteilungen auf `source = 'swapped'` | schreibt, `guardian:` | — |

## Anwesenheit und Strafe

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /cleaning/slots/{slot_id}/attendance-sheet` — die Unterschriftenliste als Druckansicht, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste), mit Startzeitpunkt, Art, Hinweistext und den Namen der Eltern | [01](../soll-prozesse/01-putzdienst.md) Z9, „Dateien" | `secretariat` | unbeschränkt; **ohne die freigekauften Familien** — genau dafür liegt die Freikauf-Frist drei Tage davor | liest | — |
| `PUT /cleaning/slots/{slot_id}/attendance` — eintragen, wer da war; setzt `attendance_recorded_at` und je Zuteilung `no_show`, in einer Transaktion | [01](../soll-prozesse/01-putzdienst.md) Z11 | `secretariat` | korrigierbar, solange `penalty_handed_over_at` leer ist; danach nur noch über den Rückzug. Nicht an einem abgesagten Termin | schreibt, `entra:` | — |
| `PUT /cleaning/slots/{slot_id}/attendance-sheet` — die eingescannte Liste am Termin ablegen | [01](../soll-prozesse/01-putzdienst.md) Z11, „Dateien" | `secretariat` | erst nach der Auswertung (`ck_cleaning_slots_sheet_recorded`); Bibliothek und Graph-Kennung stehen zusammen oder gar nicht | schreibt, `entra:` | — |
| `GET /cleaning/penalties?period=YYYY-MM-01` — die Strafen eines Monatslaufs als Liste zur Aufgabe, je Familie | [01](../soll-prozesse/01-putzdienst.md) Z12 („mit der Liste daran") | `accounting`, `secretariat` | unbeschränkt (interne Liste, nie über OTP) | liest | — |
| `POST /cleaning/assignments/{assignment_id}/penalty-waiver` — eine verhängte Strafe zurückziehen | [01](../soll-prozesse/01-putzdienst.md) Z12, „Entscheidungen" | `school_management`, `executive_management` | nur wo `no_show`; Schulleitung nur bei einem Kind ihrer Schulform in dieser Familie; **das Sekretariat nicht** — „wer entscheidet, trägt ein" | schreibt, `entra:` | — |

## Die fünf Läufe

Keine Route, kein Endpunkt von außen ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

| Lauf | Herkunft | Auslöser | Aktor |
|---|---|---|---|
| Mail „Anmeldefenster offen", mit der Pflichtzahl genau dieser Familie, den Preisen und dem Enddatum; nicht an Familien mit null | [01](../soll-prozesse/01-putzdienst.md) Z2 | `cleaning_cycles.registration_opens_at`, solange `registration_mail_sent_at` leer ist | `system:` |
| Fenster schließen und die offenen Pflichttermine verteilen, je Art getrennt; Reservierungen bleiben unberührt | [01](../soll-prozesse/01-putzdienst.md) Z4 | `cleaning_cycles.registration_closes_at`, solange `allocated_at` leer ist | `system:` |
| Mail mit den endgültigen Terminen an jede Familie, die welche hat — auch an die, die selbst reserviert hat; ohne die abgesagten und die freigekauften | [01](../soll-prozesse/01-putzdienst.md) Z6 | `cleaning_cycles.allocation_released_at`, solange `allocation_mail_sent_at` leer ist | `system:` |
| Die zwei Erinnerungen je Termin, jede mit Startzeitpunkt, Art und Hinweistext und ohne die freigekauften Familien. Zur zweiten die Aufgabe „Anwesenheitsliste drucken" beim Sekretariat, **samt eigener Mail**, weil sie noch in derselben Woche fällig ist | [01](../soll-prozesse/01-putzdienst.md) Z9 | der vorige Termin des Jahres, solange `first_reminder_sent_at` leer ist; zwei Tage vor dem Termin, solange `second_reminder_sent_at` leer ist. Beides erst nach der Freigabe, und der erste Termin des Jahres bekommt keine erste Erinnerung — er hat keinen Vorgänger, die Zuteilungsmail war sie | `system:` |
| Am 1. jedes Monats **eine** Aufgabe bei der Buchhaltung über alle bis dahin ausgewerteten Strafen; sie setzt `penalty_handed_over_at` | [01](../soll-prozesse/01-putzdienst.md) Z12 | der 1. des Monats, ein festes Datum; die Aufgabe des Zeitraums ist zugleich die Marke, eine eigene Spalte gibt es dafür nicht | `system:` |

**Wie der Zuteilungslauf verteilt** — je Terminart ein **Min-Cost-Flow**
(`wb-backend/app/services/cleaning.py`): Jeder offene Pflichttermin bekommt einen Zielzeitpunkt aus
einem gleichmäßigen Raster über das Putzdienstjahr, in das die schon gebuchten Termine der Familie
eingerechnet sind; die Kosten sind der quadrierte Tagesabstand zum Ziel, die Platzzahl ist eine
Kapazität mit teurer Überlaufkante. Alle Familien werden dabei in **einem** Problem gelöst, nicht
nacheinander.

`[A!]` — Alternative: Familie für Familie den passendsten freien Termin nehmen. Preis: Wer selbst
reserviert hat, bekommt den Rest über das ganze Jahr gestreut und damit auch direkt neben seine
Reservierung; und wo die Plätze knapp sind, bekommt dieselbe Familie in jeder Runde die Reste, weil
die Reihenfolge feststeht. Beides fällt als „schlecht verteilt" auf, und keine Reihenfolge repariert
es. Der Preis der gewählten Lösung ist eine Abhängigkeit mehr (`networkx`, reines Python) und ein
Zielraster, das eine Modellannahme ist und keine Regel des Blocks — es entscheidet, was „über das
Jahr verteilt" heißt, und ist die Stellschraube, wenn ein Jahrgang schief aussieht.

**Zeile 10 hat keine Route und keinen Lauf:** Eltern und Putzdienstleitung handeln vor Ort auf
Papier. Die Putzdienstleitung ist „eine eigene Person ohne Rolle" und bekommt keinen Zugang — was sie
braucht, steht auf der ausgedruckten Liste.

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant — jede gehört einer anderen Domäne:

- **Q5, Aufgabe abhaken** (`erledigt` / `war nichts zu tun`) und der Bestand der Wochenmail: die drei
  manuellen Schritte dieser Domäne hängen daran — Querschnitt.
- **Das hausinterne Q5-Ziel steht** — `in_house` („Im Haus"), angelegt mit dieser Domäne, weil sie
  es zuerst braucht: Daran hängt die Aufgabe „Anwesenheitsliste drucken" (Bezug
  `cleaning_slot_id`). Die zweite hausinterne Aufgabe, „Putzdienstjahr einrichten" aus
  [04](../soll-prozesse/04-schuljahreswechsel.md) Z4, nimmt dasselbe Ziel, sobald dieser Block
  gebaut wird — Querschnitt.
- **`POST /payments/callback`** samt Zahlungssitzung — Querschnitt, Form in
  [`gemeinsam.md`](gemeinsam.md#sofortzahlung).
- **`configured_values` pflegen** (`cleaning_buyout_cents`, `cleaning_penalty_cents`, Pflichtmenge
  mit Gültigkeitstag) — Querschnitt, `executive_management`.
- **Abgangspunkt bestätigen** ([03](../soll-prozesse/03-irregulaerer-abgang.md) Z3): Er lässt die
  offenen Termine der Familie ohne Strafe verfallen, aber nur beim letzten Kind — Anmeldung/Abgang.
- **Unzustellbare Mail sichtbar machen** (`outbound_emails`) — Querschnitt.
- **Anmeldung selbst** (Code anfordern, Code einlösen, als wer man weitermacht) —
  [00](../soll-prozesse/00-zugang-und-portal.md), Stammdaten.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- Der freigekaufte Termin hat kein Kennzeichen an `cleaning_assignments`; dass er „weg" ist, tragen
  die Routen. Ein `LEFT JOIN cleaning_slot_buyouts` in jeder Liste ist der Preis dafür, dass die
  Zeile den Freikauf festhält — beabsichtigt, aber leicht zu vergessen.
- Der Monatslauf braucht `cleaning_assignments.penalty_handed_over_at` **und** die Periode der
  Aufgabe; einen Verweis von der Zuteilung auf ihren Monatslauf gibt es nicht.
  `GET /cleaning/penalties` rechnet die Liste deshalb aus dem Zeitpunkt, nicht aus einer Zuordnung.
