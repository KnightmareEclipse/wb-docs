# rechnungsfreigabe

Lauf über `schema/rechnungsfreigabe-schema.sql` samt `schema/rechnungsfreigabe-schema-check.sql`
gegen `soll-prozesse/12-rechnungsfreigabe.md`, `hebel.md`, `rules.md` 1/3/7 und `grenzkarte.md`.

**Lauf:** alle vierzehn `*-schema.sql` in dokumentierter Reihenfolge in eine leere Datenbank —
`rc=0` je Datei. `rechnungsfreigabe-schema-check.sql` gegen diese vollständige Datenbank —
**`rc=0`**, alle Gegenproben grün. Danach eigene `INSERT`s gegen dieselbe Datenbank; was dabei
belegt ist, steht je Fund unter „Beleg".

## Funde

```
[RECHNUNGSFREIGABE-F1] rechnungsfreigabe · Klasse 1 · expense_claims.withdrawn_at
12, Schritt 1 sagt „Zurückziehen kann er ihn, solange keine Führungskraft ihn oder einen seiner
Teile freigegeben hat"; `ck_expense_claims_end` (Zeile 317) prüft nur, dass Rückzug, Buchung und
Storno sich nicht überlagern, und keine Zeile der Datei sagt, dass die Regel der Anwendung gehört —
anders als bei den vier Summen- und Folgeregeln, die sie ausdrücklich abgibt. Es gibt auch keine
Gegenprobe: `withdrawn_at` kommt im ganzen Prüfskript nicht vor.
Beleg: `UPDATE expense_claims SET withdrawn_at = now()` an einem Beleg, dessen einziger Teil
`approved_at` und `cost_project_id` trägt — durchgelassen.
Vorschlag: entweder ein Satz im Kommentar, der die Regel wie die übrigen an die Anwendung abgibt,
samt accept-Gegenprobe, die die Auslassung festhält — oder eine Spalte, an der ein CHECK greifen kann.
```

```
[RECHNUNGSFREIGABE-F2] rechnungsfreigabe · Klasse 2 · expense_claim_attachments
12, Sonderfälle: „Ein abgelehnter, stornierter oder zurückgezogener Beleg lässt sich als Kopie neu
einreichen, Anhänge inbegriffen". `uq_expense_claim_attachments` (Zeile 531) weist genau das ab:
Die Zeile ist über (Bibliothek, Graph-Kennung) eindeutig, dieselbe Datei kann also an keinem
zweiten Beleg hängen. Der Kommentar begründet den Schlüssel mit einem anderen Satz des Blocks
(„Anhänge lassen sich nach dem Absenden nicht austauschen") — der verbietet das Tauschen an einem
Beleg, nicht dieselbe Datei an zweien.
Beleg: Beleg angelegt, `01KASSENZETTEL` angehängt, Kopie angelegt, dieselbe Kennung angehängt —
`duplicate key value violates unique constraint "uq_expense_claim_attachments"`.
Vorschlag: entweder den Schlüssel auf (Beleg, Bibliothek, Graph-Kennung) legen — dann teilen sich
Original und Kopie die Datei —, oder in den Kommentar schreiben, dass die Kopie in SharePoint eine
eigene Datei bekommt, samt dem Preis (zweite Datei je Wiedereinreichung, beide von Hand zu räumen).
```

```
[RECHNUNGSFREIGABE-F3] rechnungsfreigabe · Klasse 2 · travel_details
`uq_travel_details` (Zeile 483) lässt genau eine Fahrt je Beleg zu, und `ck_travel_details_amount`
(Zeile 497) bindet den Belegbetrag an eben diese eine Fahrt. Eine Sammelabrechnung mehrerer Fahrten
auf einem Beleg ist damit unmöglich. Der Block schreibt das nirgends aus; seine Formulierung „die
Strecke ist auf 2000 km je Fahrt begrenzt" liest sich umgekehrt — „je Fahrt" statt „je Beleg" ist
nur dann eine Aussage, wenn ein Beleg mehrere tragen kann. Die Gegenprobe „zweite Fahrtangabe an
demselben Beleg" behauptet eine Regel, für die es keinen Blocksatz gibt.
Beleg: Beleg über 6000 mit einer Fahrt zu 100 km × 30 ct — `ck_travel_details_amount` weist ab,
weil der Belegbetrag die Summe zweier Fahrten wäre und nicht der einen.
Vorschlag: beim Sekretariat/der Buchhaltung klären, ob eine Fahrtkostenabrechnung mehrere Fahrten
trägt; trägt sie genau eine, gehört der Satz in den Block und der Grund in den Kommentar.
```

```
[RECHNUNGSFREIGABE-F4] rechnungsfreigabe · rules.md 1 · expense_claim_items.last_action_at
`last_action_at` (Zeile 383) ist vollständig ableitbar: die letzte Handlung an einem Teil ist das
Größte aus `created_at`, `corrected_at`, `approved_at`, `rejected_at`, `forwarded_at` derselben
Zeile. rules.md Abschnitt 1 lässt einen ableitbaren Wert nur zusätzlich stehen, „wenn er ein
Constraint tragen muss, das sich über den Ableitungsweg nicht ausdrücken lässt" — hier trägt er
keines, sondern nur den Lese-Index `ix_expense_claim_items_waiting`. Die Datei beruft die Ausnahme
an drei anderen Stellen ausdrücklich (`calendar_year`, die beiden Zahlweg-Merkmale, `amount_cents`
an `travel_details`) und hier nicht.
Beleg: die Spalte ist an nichts gebunden; das Prüfskript setzt sie in der Freigabe-Gegenprobe von
Hand mit. Wird sie einmal vergessen, zeigt die Warteschlange stillschweigend ein falsches Alter.
Vorschlag: Spalte streichen und den Index über `greatest(...)` als Ausdrucksindex legen — oder die
Ausnahme aus rules.md 1 im Kommentar ausschreiben und benennen, welches Constraint sie trägt.
```

```
[RECHNUNGSFREIGABE-F5] rechnungsfreigabe · Klasse 1 · expense_claims.third_party_*
12: „nur ‚an Dritte' verlangt zusätzlich Kontoinhaber und IBAN". `ck_expense_claims_third_party`
(Zeile 303) prüft nur die Gegenrichtung — ohne den Zahlweg keine Bankverbindung. Dass die beiden
zusammengehören, prüft nichts, und die IBAN hat keine Form: dieselbe Angabe trägt an
`sepa_mandates` sowohl `NOT NULL` als auch `ck_sepa_mandates_iban`
(`schema/stammdaten-schema.sql:828`) — und dort kommt Geld herein, hier geht es hinaus.
Beleg: „an Dritte" mit Kontoinhaber und ohne IBAN geht durch; ebenso mit Kontoinhaber `''` und der
IBAN `keine IBAN`.
Vorschlag: `CHECK ((third_party_account_holder IS NULL) = (third_party_iban IS NULL))` samt
`ck_expense_claims_third_party_iban` in der Form von `ck_sepa_mandates_iban`, je mit Gegenprobe.
```

```
[RECHNUNGSFREIGABE-F6] rechnungsfreigabe · Klasse 5 · rechnungsfreigabe-schema-check.sql:408
Die Gegenprobe „12 — Einreicher gibt seine eigene Erstattung frei" ist die einzige für den
„an mich"-Zweig von `ck_expense_claim_items_self_approval` (der Fahrt-Zweig hat eine eigene, gültige).
Sie legt den Teil aber an Beleg 662 an, der über `to_company` läuft und `is_reimbursement = false`
trägt, während der Teil `true` setzt — die Zeile widerspricht damit ihrem Beleg.
Beleg: mit `ALTER TABLE expense_claim_items DROP CONSTRAINT ck_expense_claim_items_self_approval`
bleibt die Probe grün, sie scheitert dann an `fk_expense_claim_items_submitter_claim`. `expect_reject`
wirft beides in einen Topf. Die Sperre selbst greift (eigener Beleg über `to_me` mit
`is_reimbursement = true`: `ck_expense_claim_items_self_approval` weist ab) — nur ihre Probe belegt
das nicht.
Vorschlag: die Probe auf einen Beleg mit `to_me`/`is_reimbursement = true` stellen, dann wird sie
ohne die Sicherung rot.
```

```
[RECHNUNGSFREIGABE-F7] rechnungsfreigabe · Klasse 5 · rechnungsfreigabe-schema-check.sql:666
Die Gegenprobe „der Beleg hält den Lauf aus 17 an keiner Stelle auf" sucht nach Fremdschlüsseln mit
`confdeltype = 'a'` (NO ACTION). Ein `RESTRICT`-Fremdschlüssel trägt `'r'` und liefe an ihr vorbei —
und genau das ist der Fall, vor dem der Prüfauftrag warnt („oder blockiert ein RESTRICT unterwegs").
Beleg: die Kataloge zu `confdeltype` unterscheiden 'a' und 'r'; die Probe kennt nur 'a'.
Vorschlag: `confdeltype IN ('a','r')`.
```

```
[RECHNUNGSFREIGABE-F8] rechnungsfreigabe · Klasse 1 · ix_expense_claims_duplicate
Der Kommentar an Zeile 322 sagt, der Index trage den Dublettenhinweis, und zitiert dessen erste
Hälfte. Die zweite steht direkt daneben im Block: „bei einer Fahrt nach Strecke, die keinen
Empfänger trägt, treten Datum und Strecke an seine Stelle, denn zweimal abgerechnet wird gerade
dort am leichtesten." Für sie gibt es keinen Index, und die Auslassung ist nirgends genannt.
Beleg: `ix_expense_claims_duplicate` liegt auf `(payee_id, amount_cents, created_at)`; die zweite
Hälfte bräuchte `travel_details (travelled_on, distance_km)`.
Vorschlag: entweder den zweiten Index anlegen oder den Kommentar auf „trägt die eine Hälfte"
korrigieren und begründen, warum die andere ohne auskommt (rund tausend Belege im Jahr).
```

```
[RECHNUNGSFREIGABE-F9] rechnungsfreigabe · Klasse 1 · retention_subjects (querschnitt)
12, „Löschen": „Die zehn Jahre stehen als Wert im System, und der Lösch-Lauf kündigt sie an … Zwei
Wochen und eine Woche vor dem Termin melden sie Buchhaltung und Geschäftsführung, dass ein Jahrgang
fällig ist." 17 bestätigt das. Die Empfängerliste hängt in `retention_notice_recipients` an einem
`retention_subject_id`; die aufgezählten Bestände in `schema/querschnitt-schema.sql:1968-1977`
(„application", „child_health_record", „health_occasion", „holiday_booking", „holiday_care_note",
„academy_registration", „excursion", „contract", „sepa_mandate", „child_file", „care_file",
„employee") führen **keinen für die Belege** — obwohl derselbe Kommentar behauptet, es seien „die
Codes, die die Blöcke heute nennen". Ohne Bestand gibt es keine Empfängerliste und damit keine
Ankündigung, also genau das, was 12 als den eigentlichen Ertrag benennt: „daran zu denken".
Beleg: `grep -n "expense" schema/querschnitt-schema.sql` — der Code kommt in der Aufzählung nicht vor.
Vorschlag: einen Code („expense_claim") in die Aufzählung, dazu die Gegenprobe, dass für ihn zwei
Empfänger eintragbar sind.
```

```
[RECHNUNGSFREIGABE-F10] rechnungsfreigabe · Klasse 1 · retention_subjects (querschnitt)
12: „dass hier nicht geräumt wird, bleibt ein Sonderfall, ausdrücklich … Wer die Bauform von hier
anderswo hinträgt, baut eine Ankündigung ohne Folgen." 17: „der einzige Bestand, bei dem die beiden
Schritte auseinanderfallen." In den Daten steht davon nichts: `retention_subjects` trägt Code, Name
und `is_active` und keine Marke, die einen Bestand als nur-ankündigend ausweist. Der eine Bestand,
bei dem Löschen selbst der Fehler wäre (§ 379 AO, § 257 HGB), sieht für den Lauf aus wie die zwölf
anderen; die Unterscheidung lebt allein im Anwendungscode und hat keine Gegenprobe.
Beleg: Spaltenliste von `retention_subjects`, `schema/querschnitt-schema.sql:1966-1991`.
Vorschlag: ein Flag `announce_only` an `retention_subjects` — dieselbe Bauform wie die
strukturellen Flags aus rules.md Abschnitt 3 —, samt Gegenprobe, dass es an genau diesem Bestand steht.
```

```
[RECHNUNGSFREIGABE-F11] rechnungsfreigabe · offen · expense_claim_items.approver_employee_id
12, Schritt 3: „Läuft er über eine Aufteilungsvorlage, entfällt dieser Umlauf: Der Schlüssel steht
fest, die Zustimmung der anderen steht in der Vorlage." `ck_expense_claim_items_approver` (Zeile
402) verlangt an **jedem** Teil eine Führungskraft — auch an dem, über den niemand entschieden hat.
Und das Deckblatt nennt „bei einem aufgeteilten Beleg je Teil … Projekt, Buchungskonto und
Freigeber". Wer bei der Vorlagen-Aufteilung als Freigeber des zweiten Teils dasteht — die eine
gewählte Führungskraft, die Geschäftsführung als Urheberin der Vorlage, oder niemand —, entscheidet
der Block nicht, und das Schema markiert die Lücke nicht.
Beleg: Teil ohne Führungskraft und ohne Namen → `ck_expense_claim_items_approver` weist ab.
Vorschlag: als `[?]` an die Geschäftsführung — wessen Name bei einer Vorlagen-Aufteilung als
Freigeber auf dem Deckblatt steht.
```

## Angesehen, nicht als Fund gewertet

```
rechnungsfreigabe · `ck_expense_claim_items_self_approval` sah nach einer Lücke aus, weil sie bei
        fehlendem Mitarbeitendeneintrag nicht mehr greift; der Kommentar schreibt genau das hin,
        und ohne Eintrag ist auch die Führungskraft nur noch ein Name. Die Sperre selbst greift für
        „an mich" wie für jede Fahrt — belegt mit einem eigenen `INSERT`. Nur ihre Probe trägt
        nicht (F6).
rechnungsfreigabe · Vier Regeln des Blocks stehen bewusst in der Anwendung und nicht im Schema —
        „die Teilbeträge müssen den Betrag genau treffen", „mindestens zwei Projekte",
        „mindestens ein angehängter Beleg", die lückenlose Nummer. Jede ist im Kommentar als
        Auslassung benannt und im Prüfskript mit einer accept-Gegenprobe festgehalten, die zeigt,
        dass hier nichts abgewiesen wird. Das ist die geforderte Form, kein Fund.
rechnungsfreigabe · Die Lösch-Gegenprobe gegen `children`, `families`, `persons` kann heute nicht
        fehlschlagen, weil die Domäne keinen dieser Fremdschlüssel trägt — sie ist eine Sperre
        gegen einen künftigen, kein Leerlauf im Sinne der Falle. Ihre Lücke ist eine andere (F7).
rechnungsfreigabe · Das Zitat an `payment_routes` bricht bei „wird abgebucht." ab, wo der Block
        „, das Mandat liegt vor" fortsetzt — der Wortlaut bis dahin ist wörtlich, und der
        weggelassene Halbsatz trägt nichts, was der Zahlweg-Werteliste fehlte.
rechnungsfreigabe · Alle 28 wörtlichen Zitate der beiden Dateien gegen 12 und 13 abgeglichen, auch
        „ein Beleg, der noch bei ihm liegt, trägt dort den Vermerk …" (13, Schritt 3). Alle tragen;
        Abweichungen sind Kleinschreibung am Zitatanfang und aufgelöste Markdown-Links.
rechnungsfreigabe · `payees` ohne `is_active`: `merged_into_payee_id` trägt dieselbe Tatsache —
        ein zweites Feld wäre der zweite Ort, den rules.md 1 verbietet.
rechnungsfreigabe · `claim_templates` ohne Sorte: „welche es ist, sagt die Zahl ihrer Anteile"
        trägt; wer welche anlegen darf, ist eine Zugriffsregel und gehört nicht ins Schema.
rechnungsfreigabe · `booked_by` steht, `voided_by` nicht. Beide Urheber trägt die Änderungsspur;
        `booked_by` ist der Abschlussvermerk des Vorgangs („abgehakt heißt gebucht") und nicht die
        zweite Hälfte eines Paares.
rechnungsfreigabe · Die Domäne liest `employees.house_id` nicht, obwohl grenzkarte.md Q4 sie als
        möglichen ersten Leser nennt. Der Block trägt das: „Einen eigenen Kreis bildet sie dabei
        nicht — jede Führungskraft ist für jeden Beleg wählbar." Die Spalte ist in Stammdaten von
        13 begründet, nicht von hier.
rechnungsfreigabe · Marken: die Domäne trägt keine `[A]`, `[A!]` oder `[?]`. „Offene Fragen an die
        Schule: Keine" am Dateiende ist damit belegt, nicht behauptet.
```

## Sortierung nach Gewicht

1. `[RECHNUNGSFREIGABE-F9]` — die Löschankündigung, die 12 und 17 zusagen, hat keinen Bestand und
   damit keine Empfänger; sie geht nie hinaus, und niemand merkt es.
2. `[RECHNUNGSFREIGABE-F1]` — ein Beleg lässt sich zurückziehen, nachdem er freigegeben ist; die
   Entscheidung fällt still weg.
3. `[RECHNUNGSFREIGABE-F2]` — die Wiedereinreichung als Kopie bricht am Anhang ab, ein Weg, den der
   Block ausdrücklich vorsieht.
4. `[RECHNUNGSFREIGABE-F10]` — nichts in den Daten hält den Lauf davon ab, den einen Bestand zu
   räumen, bei dem das der Fehler wäre.
5. `[RECHNUNGSFREIGABE-F3]` — eine Fahrt je Beleg, ohne dass der Block das sagt.
6. `[RECHNUNGSFREIGABE-F6]` — die einzige Probe des „an mich"-Zweigs bleibt ohne die Sicherung grün.
7. `[RECHNUNGSFREIGABE-F4]` — `last_action_at` ist ein zweiter Ort für eine ableitbare Tatsache.
8. `[RECHNUNGSFREIGABE-F5]` — Kontoinhaber ohne IBAN und IBAN ohne Form, dort wo Geld hinausgeht.
9. `[RECHNUNGSFREIGABE-F7]` — ein `RESTRICT` liefe an der Lösch-Gegenprobe vorbei.
10. `[RECHNUNGSFREIGABE-F8]` — der Dublettenindex trägt die eine Hälfte der Regel, der Kommentar
    behauptet beide.
11. `[RECHNUNGSFREIGABE-F11]` — offen: wer bei einer Vorlagen-Aufteilung als Freigeber dasteht.

## Ergebnis

Die Domäne ist **nicht ohne Fund durchgekommen**: elf, davon vier mit Wirkung im Betrieb. Das
Prüfskript selbst läuft grün (`rc=0`) — zwei seiner Proben belegen aber nicht, was sie behaupten
(F6, F7).

Außerhalb der Domäne aufgefallen, nicht angefasst: `schema/querschnitt-schema.sql` nennt an
`configured_values` „contract_fee_cents … Derzeit 90 €", `soll-prozesse/hebel.md` dagegen
„Anmeldegebühr des Schulvertrags 100 € ab dem 01.09.2026". Gehört zu 08, nicht hierher.
