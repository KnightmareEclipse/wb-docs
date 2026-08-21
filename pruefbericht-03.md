# Prüfbericht — Zyklus 3

Gegen `schema/` in diesem Repo, gelesen je Domäne gegen die Blöcke in `soll-prozesse/`.
Funde durchlaufend nummeriert, unsortiert notiert; die Sortierung nach Gewicht steht am Ende.

**Lauf:** Alle 14 `*-schema.sql` laden in der Reihenfolge stammdaten → querschnitt → Rest
fehlerfrei in eine leere Postgres-17-Datenbank (je `rc=0`). Alle 14 `*-schema-check.sql` laufen
gegen die **vollständige** Datenbank mit `-v ON_ERROR_STOP=1` durch, je `rc=0`.

Zwei mechanische Vorprüfungen über alle Domänen, gegen instrumentierte Kopien der Prüfskripte
(die Skripte im Repo sind unverändert):

- **`expect_accept` ins Leere:** je Probe `ROW_COUNT` mitgeschrieben — **0 von 166** Proben
  treffen null Zeilen. Falle 1 tritt nirgends auf.
- **`expect_reject` aus dem falschen Grund:** je Probe `CONSTRAINT_NAME`/`SQLSTATE` mitgeschrieben.
  Die Abweichungen stehen je Domäne unten; wo nichts steht, trifft jede Probe den Constraint,
  den ihr Text behauptet.

---

## stammdaten

```
[F1] stammdaten · Klasse 5/1 · login_codes
hebel.md („Zugang und Anmeldecode") sagt „je Adresse und Stunde gibt es höchstens fünf";
`stammdaten-schema.sql:845` behauptet, `ix_login_codes_email_created` „trägt das
Ratelimit". Ein Index trägt keine Regel — es gibt keinen Constraint, keinen Trigger
(das Schema kennt keinen einzigen) und keine Gegenprobe im Prüfskript. Dieselbe Tabelle
benennt drei Nachbar-Auslassungen ausdrücklich („Bewusst KEINE Spalte für den Ablauf",
die fünf Fehleingaben als Constraint, die letzte Admin-Rolle als benannte Auslassung) —
diese vierte nicht.
Vorschlag: den Satz auf „stützt die Abfrage, die das Ratelimit in der Anwendung zählt"
zurücknehmen und die Auslassung wie bei der Notfallnummer mit einer `expect_accept`-Probe
festhalten.
```

```
[F2] stammdaten · Klasse 1 · persons.address_id
05 sagt zum Kind „Konfession und Anschrift (Pflicht)", 02 sagt „Am Kind die Anschrift
(Pflicht)". `persons.address_id` ist nullable, und anders als bei den beiden
Nachbarpflichten desselben Blocks — Notfallnummer (`phone_numbers`) und Mailadresse je
Familie (`families`) — steht dazu keine begründete Auslassung im Schema und keine
Gegenprobe im Prüfskript. Ein NOT NULL geht hier nicht (dieselbe Tabelle trägt
Mitarbeitende und Notfallkontakte), die Auslassung fehlt aber.
Vorschlag: dieselbe „steht bewusst NICHT als Constraint"-Notiz an `persons` plus eine
`expect_accept`-Probe, wie sie 02 für die Mailadresse schon hat.
```

```
[F18] stammdaten · Klasse 6 · sepa_mandates, die drei Spalten des abweichenden Inhabers
08 sagt: „**Weicht** der Kontoinhaber **ab**, stehen seine Anschrift und Mailadresse am
Mandat und nicht in den Stammdaten." Der Kommentar an der Tabelle sagt dasselbe („weicht
er ab, tragen die drei Spalten darunter seine Angaben"). Gebunden ist an diese Bedingung
aber nur eine der drei: `ck_sepa_mandates_holder` stellt `account_holder_person_id` und
`account_holder_name` gegeneinander, `account_holder_address_id` und
`account_holder_email` stehen frei daneben. Nachgestellt und ausgeführt: ein Mandat auf
eine Person **aus dem Bestand** nimmt zusätzlich Anschrift und Mailadresse an — genau der
Fall, den rules.md Abschnitt 1 ausschließt („kein Attribut darf je nach Fall in zwei
Tabellen stehen können").
Vorschlag: `CHECK (account_holder_person_id IS NULL OR (account_holder_address_id IS NULL
AND account_holder_email IS NULL))`.
```

**Prüfskript:** grün (`rc=0`), 36 Gegenproben, jede trifft den Constraint, den ihr Text nennt;
21 `expect_accept`, keine ins Leere. Der Lösch-Lauf am Ende der Datei zeigt die vier Anker
(`sepa_mandates` hält `children`, `employees` hält `persons`, Familie räumt Sorgerecht und
Kontakte, `classes` bleibt stehen) statt sie zu behaupten.

---

## querschnitt

```
[F3] querschnitt · Klasse 4 · Reihenfolge des Lösch-Laufs
Der Dateikopf von `querschnitt-schema.sql` (Zeile 33 ff.) legt Stufe 1 fest:
„`documents` und `child_file_folders` …, `sepa_mandates`, `contracts`, dann
`applications`". `contracts.document_id` zeigt aber mit NO ACTION auf `documents`
(`fk_contracts_document`, anmeldung-schema.sql:808) — `DELETE FROM documents` scheitert,
solange ein freigegebener Vertrag steht. Nachgestellt und ausgeführt:
  ERROR: update or delete on table "documents" violates foreign key constraint
         "fk_contracts_document" on table "contracts"
Der Lauf kommt damit über seinen ersten Schritt nicht hinaus.
Vorschlag: `documents` ans Ende von Stufe 1 stellen, hinter `contracts`.
```

```
[F4] querschnitt/gesundheit · Klasse 4 · Reihenfolge des Lösch-Laufs
Derselbe erste Schritt scheitert ein zweites Mal, und diesmal an einer Tabelle, die in
keiner der sechs Stufen vorkommt: `health_traits.certificate_document_id` hält das Attest
mit NO ACTION fest (`fk_health_traits_certificate`, gesundheit-schema.sql:193).
`health_traits` verschwindet laut Kopf erst in Stufe 2 per Cascade mit dem Kind
(„ohne dass der Lauf sie einzeln sieht"). Nachgestellt und ausgeführt:
  ERROR: update or delete on table "documents" violates foreign key constraint
         "fk_health_traits_certificate" on table "health_traits"
Vorschlag: `documents` hinter Stufe 2 ziehen — oder `health_traits` in Stufe 1 aufnehmen.
```

```
[F5] querschnitt · Klasse 5 · Wächter über die Lösch-Reihenfolge
`querschnitt-schema-check.sql:769` prüft die Aufzählung nur gegen Fremdschlüssel, deren
Ziel `children`, `families` oder `persons` ist. Genau die beiden Fremdschlüssel aus [F3]
und [F4] fallen aus diesem Fenster heraus — der Wächter, dessen erklärter Zweck es ist,
den Lauf „nicht beim ersten Lauf in Produktion" brechen zu lassen, meldet grün, während
der Lauf an seinem ersten Schritt hängt.
Vorschlag: die Zielmenge auf alle Tabellen der sechs Stufen erweitern und zusätzlich
prüfen, dass keine Tabelle einer späteren Stufe eine frühere festhält.
```

```
[F6] querschnitt · Klasse 4 · outbound_emails
`querschnitt-schema.sql:697` nennt als Löschanker: „geht mit der Person, an die sie ging;
eine Zeile ohne Person folgt der Adresse und verfällt mit ihr." Die Adresse ist
`recipient_email` in derselben Zeile — die Zeile verfällt also mit sich selbst. Für die
Mails an eine noch unbekannte Familie (05, 09, 10), bei denen `person_id` bewusst leer
bleibt, gibt es damit keinen Anker; die Mailadresse steht unbefristet.
Vorschlag: entweder eine feste Frist ab `sent_at` für Zeilen ohne Person benennen, oder
den Satz durch die begründete Auslassung ersetzen, die er heute vortäuscht.
```

**Prüfskript:** grün (`rc=0`), 39 Gegenproben, jede trifft den Constraint, den ihr Text nennt;
27 `expect_accept`, keine ins Leere. Ohne Gegenprobe bleiben `ck_payments_status`
(offen/bestätigt, grenzkarte Q3) sowie `ix_sync_tasks_open_family` und
`ix_sync_tasks_open_year` — dieselbe Regel ist für Kind und Zeitraum belegt.

---

## anmeldung

```
[F7] anmeldung · Klasse 1 · Änderungsgebühr
hebel.md („Geld im System") zählt die Werte auf, die „jederzeit änderbar und im System,
nie im Code" stehen, darunter „Änderung der Betreuungsmodule 20 € (09)"; 09 sagt
„gegen die Änderungsgebühr, derzeit 20 €". Im Schema steht nur, OB sie erlassen wurde
(`care_module_agreements.change_fee_waived`, anmeldung-schema.sql:926) — der Betrag
selbst hat keinen Ort: die Code-Aufzählung an `configured_values`
(querschnitt-schema.sql:634 ff.) führt sieben Codes und diesen nicht, und keine
Preistabelle der Domäne trägt ihn. Die Nachbargebühr `contract_fee_cents` (90 €), die
ebenso wenig über `payments` läuft, ist dort ausdrücklich aufgenommen.
Vorschlag: einen achten Code `care_change_fee_cents` in dieselbe Aufzählung.
```

```
[F8] anmeldung · Klasse 5 · Plätze je Zeitfenster
06 nennt die Platzzahl eines Zeitfensters ausdrücklich „eine harte Grenze — ein volles
Zeitfenster ist nicht buchbar, anders als die überschreitbare Platzzahl beim Putzdienst
(01) und beim Ferienprogramm (10)". Sie ist die einzige harte Kapazität im ganzen
Modell. `anmeldung-schema.sql:721` verweist sie in die Anwendung („die Grenze selbst
prüft die Anwendung, dieser Index trägt die Abfrage dazu") — ohne die Gegenprobe, mit
der dieses Projekt sonst jede benannte Auslassung festhält (02-Mailadresse und
Notfallnummer in stammdaten, der bereits gültige Wert in querschnitt). Im Prüfskript
kommt `places_per_slot` nur in `INSERT`-Spaltenlisten vor.
Vorschlag: eine `expect_accept`-Probe „Zeitfenster überbucht (die harte Grenze trägt die
Anwendung)", damit die Auslassung beim Bau des Backends nicht untergeht.
```

```
[F9] anmeldung · Klasse 5 · Gegenprobe trifft den falschen Constraint
`anmeldung-schema-check.sql:355` kündigt an: „rules.md 1: der zusammengesetzte
Fremdschlüssel bindet den Tag ans Ziel", und setzt dafür `school_branch_id = 2,
target_grade_level = 5`, lässt `first_grade_level`/`final_grade_level` aber auf 1/4
stehen. Abgewiesen wird die Probe deshalb von `ck_applications_grade_level`
(SQLSTATE 23514) und nie von `fk_applications_admission_day`; die Bindung Tag↔Ziel ist
durch keine Probe belegt. Eigener Lauf mit mitgeführten Grenzen 5/10 zeigt: die Regel
ist gebaut und weist korrekt ab — belegt wird sie vom Skript trotzdem nicht.
Vorschlag: in derselben Probe `first_grade_level = 5, final_grade_level = 10` mitsetzen.
```

**Prüfskript:** grün (`rc=0`), 58 Gegenproben, davon eine mit falschem Grund ([F9]);
34 `expect_accept`, keine ins Leere. Der Kopf der Datei zählt die fünf von der Grenzkarte
abweichenden Auslassungen auf und belegt jede mit einem jüngeren Blocksatz — Geschwister,
Hospitationszeitraum, Notiz, Zusammensetzungswunsch, Schulpflicht-Stichtag; alle fünf
gegen die Blöcke 05, 06, 07 und 15 nachgeschlagen und richtig zitiert. `ix_contracts_running`
nennt selbst, was er nicht fängt.

---

## putzdienst

```
[F10] putzdienst · Klasse 1 · die Aufgabe „Anwesenheitsliste ausdrucken"
01 („Mails und Schreiben") sagt: „Bei den manuellen Schritten entsteht statt einer
eigenen Erinnerung je eine offene Aufgabe bei der zuständigen Person, sobald sie dran
ist — Zuteilung freigeben, Anwesenheit eintragen, Anwesenheitsliste ausdrucken … und sie
läuft in der Wochenmail mit, bis sie abgehakt ist"; für die dritte ausdrücklich „eine
eigene Mail", weil sie „ein bis zwei Tage vor dem Termin fällig" ist. Zwei der drei
lassen sich ableiten, wie es die elternbonus-Domäne für ihre personengebundene Aufgabe
tut: „Zuteilung freigeben" aus `cleaning_cycles.allocation_released_at IS NULL`,
„Anwesenheit eintragen" aus `cleaning_slots.attendance_recorded_at IS NULL`. Für die
dritte gibt es nichts: Gedruckt wird eine frisch erzeugte Liste, und keine Spalte des
Schemas hält fest, dass es geschehen ist — „abgehakt" hat damit keinen Ort. Über
`sync_tasks` geht es auch nicht: `ck_sync_tasks_single_subject` kennt sechs Bezüge, und
der Putztermin ist keiner davon; `reference_period` trägt laut Kommentar den Monatslauf
der Strafen, und `ix_sync_tasks_open_period` ließe je Ziel und Datum ohnehin nur eine
Aufgabe zu. Im ganzen Schema kommt die Aufgabe nicht vor, auch nicht als begründete
Auslassung.
Vorschlag: `cleaning_slot_id` als siebten Bezug an `sync_tasks` (Summand im CHECK plus
Teilindex) — er trägt dann auch „Anwesenheit eintragen", wenn die Ableitung nicht reicht.
```

```
[F11] putzdienst · Klasse 2 · uq_cleaning_swap_offers
01 sagt „Eine Familie darf mehrere ihrer Termine **gleichzeitig** anbieten, je Termin
aber nur ein Angebot" — eine Aussage über offene Angebote. `uq_cleaning_swap_offers`
(putzdienst-schema.sql:317) ist dagegen unbedingt UNIQUE über
`cleaning_assignment_id`, und ein vollzogenes Angebot bleibt stehen („danach ist das
Angebot verbraucht", Kommentar an `matched_at`). Nach dem Modell, das das Prüfskript
selbst verwendet — der Tausch ist ein `UPDATE cleaning_assignments SET cleaning_slot_id`
(putzdienst-schema-check.sql:328) —, behält die Zuteilung ihr verbrauchtes Angebot und
lässt sich nie wieder zum Tausch stellen. Nachgestellt und ausgeführt:
  ERROR: duplicate key value violates unique constraint "uq_cleaning_swap_offers"
Jede Familie kann damit jeden ihrer Termine höchstens einmal je Putzdienstjahr tauschen;
kein Block sagt das.
Vorschlag: partieller Index `WHERE matched_at IS NULL` statt UNIQUE.
```

```
[F12] putzdienst · Klasse 5 · Gegenprobe trifft den falschen Constraint
`putzdienst-schema-check.sql:224` will „Q3 — unbekannter Zahlungsstatus" zeigen und
setzt dafür `status = 'refunded'` **zusammen mit** `confirmed_at = now()`. Abgewiesen
wird die Zeile von `ck_payments_confirmed` (SQLSTATE 23514, „bestätigt heißt: mit
Zeitpunkt"), nie von `ck_payments_status`. Über alle 14 Skripte hinweg ist das die
einzige Probe auf `ck_payments_status` — die Werteliste offen/bestätigt aus
grenzkarte.md Q3 ist damit durch keine Probe belegt.
Vorschlag: `confirmed_at` in dieser Probe weglassen.
```

**Prüfskript:** grün (`rc=0`), 29 Gegenproben, davon eine mit falschem Grund ([F12]);
11 `expect_accept`, keine ins Leere. Die bewusst nicht gebaute Regel „eine Familie kann
keinen Termin annehmen, an dem sie schon steht" ist mit zwei Proben eingefasst — Kreuz
geht durch, vollzogener Tausch nicht; die Platzzahl als weiche Grenze ebenfalls
(2 Familien auf 1 Platz). Der Jahreslauf über den Zyklus ist gezeigt, nicht behauptet.

---

## ferien

```
[F13] ferien · Klasse 1 · Stornobedingungen ohne Gültigkeitstag
10 („Beteiligte"): „Die Geschäftsführung pflegt Module, Beträge, Stornobedingungen und
Teilnahmebedingungen als [Werte im System](hebel.md#geld-im-system-alles-andere-fest)" —
und hebel.md sagt dort: „Jeder dieser Werte trägt ein Datum, ab dem er gilt … ein noch
nicht gültiger lässt sich bis dahin ändern oder zurücknehmen, ein bereits gültiger nicht
mehr. Beide sind sichtbar, damit eine Familie eine angekündigte Erhöhung sieht, bevor sie
sich entscheidet." `holiday_session_types.cancellation_terms` (ferien-schema.sql:56) ist
eine schlichte Textspalte ohne `valid_from` und ohne Historie; die Nachbarangabe, die
Teilnahmebedingungen, steht dagegen in `contract_texts` mit Gültigkeitstag und wird an
der Buchung als Fassung festgehalten. Folge: Eine angekündigte Storno-Erhöhung lässt sich
nicht vorab eintragen, und nach einer Änderung ist nicht mehr lesbar, welche Bedingungen
bei einer Buchung galten — obwohl 10 sie ausdrücklich „sichtbar bevor gebucht wird" nennt.
Vorschlag: die Stornobedingungen wie die Teilnahmebedingungen als `contract_texts`-Code
je Terminart führen.
```

```
[F14] ferien · Klasse 1 · Anmerkung für die Betreuung
10 („Was dabei erhoben wird"): „Dazu **je Kind** eine **Anmerkung** für die Betreuung
(freiwillig, Freitext …)". `holiday_bookings.care_note` (ferien-schema.sql:326) steht je
Buchung, also je Kind **und Termin**. In den kurzen Ferien ist ein Termin ein Tag; ein
Kind, das eine Woche bucht, trägt dieselbe Anmerkung fünfmal, und eine Korrektur erreicht
eine davon (rules.md Abschnitt 1, „Ein Ort pro Sachverhalt"). Der Kommentar an der Spalte
nennt nur die Herkunft („heute die Spalte ‚Wichtige Notizen'"), nicht den Wechsel des
Bezugs.
Vorschlag: entweder je Kind und Programm eine Zeile, oder den Wechsel auf die Buchung
begründen — die Excel-Spalte von heute ist keine.
```

```
[F15] ferien · Klasse 6 · holiday_cost_coverage_codes.redeemed_at
Ob ein Code eingelöst ist, sagt bereits die Buchung, die auf ihn zeigt
(`fk_holiday_bookings_coverage_code`); wann, sagt deren `created_at`. `redeemed_at`
(ferien-schema.sql:283) speichert dieselbe Tatsache ein zweites Mal, ohne ein Constraint
zu tragen — genau der Fall, den rules.md Abschnitt 1 ausschließt („kein ableitbarer Wert
wird zusätzlich gespeichert. Einzige Ausnahme: … wenn er ein Constraint tragen muss").
Kein Constraint dieser Datei nennt die Spalte, und der Kommentar begründet sie nicht.
Vorschlag: streichen; „eingelöst" ist ein `EXISTS` auf `holiday_bookings`.
```

**Prüfskript:** grün (`rc=0`), 22 Gegenproben, jede trifft den Constraint, den ihr Text
nennt; 12 `expect_accept`, keine ins Leere. Der zusammengesetzte Schlüssel über den Betrag
(`fk_payments_holiday_booking`) ist in beide Richtungen belegt — Zahlung mit fremdem
Betrag und wandernder Buchungsbetrag.

---

## gesundheit

Kein eigener Fund. Der Fremdschlüssel `fk_health_traits_certificate`, der den Lösch-Lauf
aufhält, steht als [F4] unter querschnitt, weil dort die Reihenfolge und ihr Wächter liegen.

Nachgeprüft und getragen: der **Behandlungszeitraum** steht im Schema, obwohl grenzkarte.md
ihn weglassen wollte — Block 08 („therapeutische Maßnahme samt Grund und **Zeitraum**") ist
jünger und entscheidet die Sache, der Dateikopf zitiert ihn richtig. Dasselbe für die
**Zeckenentfernung**, die grenzkarte.md unter Q1 führt und die Block 08 unter den Punkten
des Gesundheitsbestands aufzählt. Beide Male ist die Rangfolge richtig angewandt und der
Satz aus der Karte, der weiter gilt, ausdrücklich mitgenommen.

**Prüfskript:** grün (`rc=0`), 17 Gegenproben, jede trifft den Constraint, den ihr Text
nennt; 9 `expect_accept`, keine ins Leere. Die vier Flags der Merkmalsart sind über
`fk_health_traits_type` in beide Richtungen belegt.

---

## mensa

```
[F16] mensa/querschnitt · Klasse 7 · Q1-Zweck „Lastschrift-Ermächtigung"
Die Herkunft von `consent_purposes` (querschnitt-schema.sql:81) zitiert grenzkarte.md Q1
samt „und die Lastschrift-Ermächtigung" und annotiert daneben ausdrücklich, dass die
Zeckenentfernung dort **nicht** mehr hingehört, weil Block 08 jünger ist. Für die
Lastschrift-Ermächtigung fehlt dieselbe Annotation, obwohl sie denselben Weg gegangen
ist: 11 sagt „Das Schulgeld-Mandat steht schon (08), eingezogen wird darüber", 08 sagt
zum Mandat „hier steht nur, dass eingezogen werden darf", und grenzkarte.md selbst
„ein Mandat je Kind, aber nicht je Zweck". Ein Q1-Zweck daneben wäre der zweite Ort für
die Einzugserlaubnis (rules.md Abschnitt 1) — und `consent_purposes` ist eine Werteliste,
die Zeile entsteht also aus genau diesem Kommentar.
Vorschlag: den Satz um dieselbe Klammer ergänzen, die die Zeckenentfernung schon hat.
```

**Prüfskript:** grün (`rc=0`), 12 Gegenproben, jede trifft den Constraint, den ihr Text
nennt — die beiden `EXCLUDE`-Regeln (SQLSTATE 23P01) eingeschlossen, deren Ausnahme
`expect_reject` hier als einziges der 13 Skripte eigens mitfängt; 11 `expect_accept`,
keine ins Leere. Der [A!] gegen grenzkarte.md („eigene Tabellen statt der
Betreuungsmodul-Tabellen") ist mit drei Blocksätzen aus 11 belegt, die eine andere
Laufzeit- und Kündigungsmechanik setzen als 09 — damit fällt die Prämisse der Karte, und
die Abweichung trägt.

---

## klassenbildung, klassenorganisation, m365, selfservice, ags, elternbonus

Kein Fund in diesen sechs. Zusammen sind es fünf Dateien ohne eine einzige
`CREATE`-Anweisung und eine mit genau einer Tabelle; geprüft wurde deshalb vor allem, ob
die Begründungen tragen — und ob nichts an anderer Stelle heimlich doch entstanden ist.

- **klassenbildung** und **ags** bauen nichts und belegen genau das: ags-check sucht
  sechs mögliche Tabellennamen und jede Spalte, die „ag" als eigenes Wort oder „club"
  enthält. Der ags-Kopf schreibt ausdrücklich hin, dass sein Kernsatz „kein Zitat" ist —
  die einzige Stelle im ganzen Schema, die das über sich selbst sagt. `prozesse.md`
  Abschnitt 20 nachgeschlagen: „Zukunftsprojekt, nichts Konkretes bekannt", mehr steht
  dort nicht. Einen Soll-Block 20 gibt es nicht.
- **m365** und **selfservice** überstimmen grenzkarte.md (Kontostatus und
  Offboarding-Schritt bzw. „keine" Entitäten) und belegen es mit Block 13 bzw. 02.
- **elternbonus**: `ck_parent_work_entries_confirmer` zusammen mit `ON DELETE SET NULL`
  erzwingt die Reihenfolge, die der Lösch-Lauf braucht — der Mitarbeitendeneintrag lässt
  sich erst löschen, wenn sein Name am Eintrag steht. Im Lauf nachgestellt und bestätigt.
- **klassenorganisation** trägt eine Tabelle und schließt sie sauber: kein Wahltag, kein
  Protokoll, keine Höchstzahl, und die drei Sonderfälle aus 16 (zwei Ämter, dritte Person,
  Amt ohne Kind in der Klasse) stehen als `expect_accept` im Skript.

**Prüfskripte:** alle sechs grün (`rc=0`).

---

## rechnungsfreigabe

```
[F17] rechnungsfreigabe · Klasse 6 · expense_claims.calendar_year
12 sagt: „Ein Beleg gehört zu dem Jahr, in dem er eingereicht wurde", und der Kommentar
nennt `calendar_year` „das Kalenderjahr der Einreichung" — also einen Wert, der aus
`created_at` folgt. Er trägt zwar ein Constraint (`uq_expense_claims_number`) und fällt
damit unter die Ausnahme aus rules.md Abschnitt 1 — die verlangt aber, dass er „an sein
Original gebunden bleibt, damit beide gar nicht auseinanderlaufen können". Diese Bindung
fehlt; die Nachbardomäne baut genau sie (`ck_parent_work_entries_school_year` bindet
`school_year` an `worked_on`). Nachgestellt und ausgeführt: ein heute angelegter Beleg
nimmt `calendar_year = 1999` an und landet damit im Nummernkreis eines fremden Jahres.
Ein CHECK auf `EXTRACT(year FROM created_at)` nimmt Postgres an — im Lauf geprüft.
Vorschlag: denselben CHECK wie in elternbonus, oder ein `submitted_on date` daneben.
```

**Prüfskript:** grün (`rc=0`), 31 Gegenproben, jede trifft den Constraint, den ihr Text
nennt; 17 `expect_accept`, keine ins Leere. Die Sperre gegen die eigene Freigabe ist in
beiden Richtungen belegt — Fahrtkosten und „an mich" abgewiesen, „direkt an die Firma"
erlaubt —, und die drei Regeln, die eine Summe über mehrere Zeilen brauchen (Teilbeträge,
Vorlagenanteile, lückenlose Nummer), stehen je als `expect_accept` mit dem Zusatz „prüft
die Anwendung" im Skript. `ck_travel_details_amount` zusammen mit
`fk_travel_details_claim` schließt die Lücke, die der Kommentar selbst benennt (9.999,99 €
über 1 km), und beide Richtungen sind geprüft.

---

## Über alle Domänen

**Fehlerklasse 6, mechanisch.** Alle 98 Tabellen nach Spaltennamen durchgesehen, die in
mehr als einer Tabelle vorkommen (ohne `created_at`/`created_by`/`is_active`/`code`/
`name`). Übrig bleiben nach Abzug der Fremdschlüssel die mitgeführten Werte —
die beiden Stufengrenzen an vier Tabellen, `is_final`, `is_branch_bound`,
`requires_child`, die vier Flags der Merkmalsart, `cleaning_slot_type_id` an drei
Putzdienst-Tabellen, `claim_type`/`payment_route`/`submitter_employee_id` am Belegteil,
`holiday_session_type_id` an der Ferienbuchung und `amount_cents` an Zahlung und
Fahrtangabe. **Jeder einzelne hängt an einem mehrspaltigen Fremdschlüssel** auf seine
Quelle; die Datenbank zählt 19 solcher Schlüssel, und keiner der mitgeführten Werte fällt
aus ihnen heraus. Die Ausnahme aus rules.md Abschnitt 1 ist damit überall
vollständig angewandt — bis auf die beiden Fälle [F15] und [F17], die keinen tragen.

**Zitate, mechanisch.** 807 wörtliche Zitate aus allen 28 Dateien gegen die Blöcke,
`hebel.md`, `grenzkarte.md`, `rules.md`, `prozesse.md` und die Nachbar-Schemadateien
gehalten, Auslassungspunkte als Platzhalter behandelt. **Kein einziges sinngemäßes Zitat.**
Die verbliebenen 46 Abweichungen sind alle derselbe Fall: Das Zitat lässt eine
Quellenangabe der Vorlage weg — „Weltenbaum schreibt dabei nichts in den Tenant *(00)* und
liest keine Gruppen" wird zu „… in den Tenant und liest keine Gruppen" — ohne
Auslassungszeichen. Wortlaut und Aussage bleiben unberührt; als Fund gewertet ist das nicht.

**`[A!]`, alle sieben.** Keine lässt etwas offen, das ein Block längst entscheidet:

| Domäne | Aussage | entscheidet ein Block sie? |
|---|---|---|
| stammdaten | kein `updated_at`/`updated_by` auf irgendeiner Tabelle | Kein Soll-Block; `hebel.md` („Änderungsspur", „einen zweiten Mechanismus … gibt es nicht") gibt sie her |
| stammdaten | Mandat als eigene Tabelle mit Historie, keine `payers` | **Ja**, 08: „damit nachvollziehbar ist, wovon wann eingezogen werden durfte" — schlägt grenzkarte Q3 |
| stammdaten | `login_codes` bekommt eine Tabelle in Stammdaten | Kein Block; `hebel.md` nennt die drei Zahlen, die sonst keinen Ort hätten |
| querschnitt | Q1–Q5 in einer eigenen Datei | Kein Block — eine Dateigrenze, die keiner entscheiden muss; grenzkarte Regel 4 stützt sie |
| querschnitt | Signatur hängt am Vertragsvorgang, nicht am Dokument | **Ja**, 08: „Vor der Freigabe entsteht kein Dokument" |
| querschnitt | `change_log`-Bezug als Tabellenname plus Schlüssel als Text | Kein Block; `hebel.md` gibt nur die Ein-Mechanismus-Regel her |
| mensa | eigene Tabellen statt der Betreuungsmodul-Tabellen | **Ja**, 11 (drei eigene Mechaniken) und 09 — schlägt grenzkarte |

**Was mir fehlt, um zu urteilen.** `querschnitt-schema.sql:126` begründet die eine
SharePoint-Bibliothek statt der zwei der Grenzkarte mit „Entschieden nach der Abnahme".
Diese Entscheidung kann ich nicht nachschlagen — sie steht in keinem Block und in keiner
Referenz. Getragen wird die Abweichung trotzdem, siehe zweite Liste.

---

## Sortierung nach Gewicht

1. **[F3]** querschnitt — Lösch-Lauf scheitert an `fk_contracts_document`
2. **[F4]** querschnitt/gesundheit — Lösch-Lauf scheitert an `fk_health_traits_certificate`
3. **[F5]** querschnitt — der Wächter über die Reihenfolge sieht beide nicht
4. **[F11]** putzdienst — jeder Termin lässt sich nur einmal je Jahr tauschen
5. **[F10]** putzdienst — die Aufgabe „Anwesenheitsliste ausdrucken" hat keinen Ort
6. **[F7]** anmeldung — die Änderungsgebühr hat keinen Ort
7. **[F13]** ferien — Stornobedingungen ohne Gültigkeitstag
8. **[F6]** querschnitt — `outbound_emails` ohne tragenden Löschanker
9. **[F18]** stammdaten — Kontoinhaber-Angaben lassen sich doppelt führen
10. **[F14]** ferien — Betreuungs-Anmerkung je Buchung statt je Kind
11. **[F17]** rechnungsfreigabe — `calendar_year` an nichts gebunden
12. **[F15]** ferien — `redeemed_at` neben seiner Ableitung
13. **[F1]** stammdaten — der Ratelimit-Satz behauptet, was ein Index nicht trägt
14. **[F9]** anmeldung — Gegenprobe belegt den Constraint nicht, den sie ankündigt
15. **[F12]** putzdienst — dasselbe für `ck_payments_status`
16. **[F8]** anmeldung — die einzige harte Kapazität ohne Gegenprobe
17. **[F16]** mensa/querschnitt — Q1-Zweck „Lastschrift-Ermächtigung" nicht nachgezogen
18. **[F2]** stammdaten — Anschrift-Pflicht ohne begründete Auslassung

**Ohne Fund durchgekommen:** gesundheit, klassenbildung, klassenorganisation, m365,
selfservice, ags, elternbonus — sieben der vierzehn Domänen.

---

## Angesehen, nicht als Fund gewertet

```
querschnitt · Eine SharePoint-Bibliothek statt der zwei der Grenzkarte, begründet mit
        „Entschieden nach der Abnahme" — also mit etwas, das ich nicht nachschlagen
        kann. Block 08 trägt sie trotzdem: „ein Ordner je Kind", „Papier … legt wie
        bisher ein Mensch dazu" und „wird von Weltenbaum in die Schülerakte gelegt" —
        Weltenbaum und Mensch schreiben in dieselbe Ablage. Der Preis (ein Vertrag ist
        für Sekretariat und GF nicht mehr nur lesbar) steht im Kommentar selbst.
stammdaten · `addresses.district` nennt kein Block; begründet allein mit „ASV-BW
        verlangt ihn für die Schulstatistik". rules.md 7 schließt die bloße Existenz in
        einem Export aus, lässt „ein benannter Prozess braucht es" aber zu — und das
        Nachziehen in ASV-BW ist einer (02, 04, 08).
stammdaten · `employees.entra_object_id` als siebte Angabe neben den sechs, die 13
        zählt. Der Kommentar trennt richtig: 13 zählt Personalangaben auf, die
        Anmeldeidentität ist keine davon und hat sonst keinen Ort.
stammdaten · `employees.first_working_day` nullable, obwohl grenzkarte Q4 den
        beidseitigen Beschäftigungszeitraum verlangt. 13 ist jünger: „Freiwillig …, weil
        an ihm nichts hängt."
putzdienst · Die Mitarbeiterausnahme liest das Haus und schließt die KITA aus,
        entgegen grenzkarte Q4 („sie fragt nach der Zeile, nicht nach dem Arbeitgeber").
        01 entscheidet es anders: „die KITA ist ein eigener Betrieb und zählt nicht mit".
putzdienst · `cleaning_cycle_quotas.required_count` ohne eigenen Gültigkeitstag, obwohl
        hebel.md die Pflichtmenge unter den Werten im System führt. Der Zyklus ist der
        Gültigkeitszeitraum; der Preis ist, dass die Geschäftsführung eine künftige
        Pflichtmenge erst eintragen kann, wenn das Sekretariat das Jahr angelegt hat.
anmeldung · `contracts.external_school_note` ist laut 09 beim externen Kind Pflicht,
        steht aber nullable. „Extern" ist eine Tatsache an `children` (kein
        `entry_date`) — ein CHECK über zwei Tabellen gibt es nicht, und Trigger kennt
        dieses Schema nirgends.
anmeldung · `ix_contracts_running` sah nach Klasse 2 aus; die drei Fälle, die 04, 05, 08
        und 09 ausdrücklich zulassen, gehen durch, und der Kommentar nennt selbst, was
        er nicht fängt.
querschnitt · `ck_consents_revocation` verbietet den Widerruf einer Ablehnung, und der
        Unique-Index lässt daneben keine zweite Antwort zu — eine Ablehnung wäre damit
        endgültig. Sie ist es nicht: die spätere Antwort ist ein UPDATE derselben Zeile
        („eine spätere ersetzt die frühere"), und was vorher dastand, hält die
        Änderungsspur.
mensa · Die beiden `EXCLUDE`-Regeln sahen nach einer Lücke aus, weil `expect_reject` in
        zwölf der dreizehn Skripte `exclusion_violation` nicht fängt. In mensa fängt es
        sie, und beide Regeln sind belegt (SQLSTATE 23P01 im Lauf).
gesundheit · Behandlungszeitraum und Zeckenentfernung stehen gegen grenzkarte.md im
        Schema; beide Male entscheidet Block 08 anders, und beide Male ist der Satz der
        Karte, der weiter gilt, im Kommentar mitgenommen.
```
