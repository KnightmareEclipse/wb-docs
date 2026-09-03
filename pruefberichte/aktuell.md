# Prüfbericht — Domäne akademie

Gelesen: `soll-prozesse/hebel.md`, `rules.md` §1/§3/§7, `grenzkarte.md`, dann
`schema/akademie-schema.sql` samt `-check.sql` und Block 21; zum Abgleich Block 10, 09 und 14 sowie
`ferien-schema.sql`, `elternbonus-schema.sql`, `anmeldung-schema.sql`, `querschnitt-schema.sql`,
`stammdaten-schema.sql`, `gesundheit-schema.sql`.

Lauf: alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere Datenbank,
`rc=0` je Datei; danach alle vierzehn `*-schema-check.sql` gegen die vollständige Datenbank,
`rc=0` je Skript. Die Funde unten stammen aus eigenen `INSERT`s gegen dieselbe Datenbank.

## akademie

### Funde

```
[F1] akademie · Klasse 1/2 · academy_registrations, academy_cost_coverage_codes
21 Sonderfälle: der Code „gilt für diese eine Anmeldung" und wird „für eine Mailadresse und ein
Angebot" erzeugt. Beides ist nirgends gebunden: derselbe Code geht an beliebig vielen Anmeldungen
durch, und ein für die Kochwerkstatt erzeugter Code bezahlt den Chor (eigene INSERTs, beide
angenommen). Damit zahlt das Jugendamt einmal und die Schule berechnet mehrfach.
Vorschlag: partieller UNIQUE über `academy_cost_coverage_code_id` an den nicht abgemeldeten
Anmeldungen, dazu ein zusammengesetzter Fremdschlüssel (Angebot, Code) wie bei `for_adults`.
```

```
[F2] akademie · Klasse 2 · enforce_academy_registration()
Der Trigger liest „einen laufenden Hortvertrag hat (09)" als `released_at IS NOT NULL AND (end_date
IS NULL OR end_date >= current_date)`. `ex_contracts_care_period` (anmeldung-schema.sql) rechnet
denselben Vertrag als `daterange(admission_date, coalesce(end_date, runs_until), '[]')`. Verifiziert
in beide Richtungen: ein Kind mit `runs_until = 2021-07-31` ohne `end_date` und ein Kind mit
`admission_date = 2030-08-01` kommen beide an einem Angebot durch, das fremde Kinder ausschließt.
Vorschlag: im Trigger dieselbe daterange-Bedingung verwenden wie der Ausschluss in anmeldung.
```

```
[F3] akademie · Klasse 1 · academy_offerings, enforce_academy_registration()
21 Z2, im Schema an `approved_at` selbst zitiert: „Bis zur Freigabe steht das Angebot nirgends …
und niemand kann sich anmelden." Eine Anmeldung zu einem nicht freigegebenen, zurückgegebenen,
abgesagten oder außerhalb seines Anmeldefensters liegenden Angebot geht durch (eigene INSERTs,
alle angenommen) — die einzige Entscheidung, die den Vorgang anhält, hält ihn nicht an.
Vorschlag: die Zulassung im vorhandenen Trigger um Freigabe, Absage und Fenster erweitern, je mit
eigener Gegenprobe.
```

```
[F4] akademie · Klasse 1 · academy_registrations, Erwachsenen-Zweig
21 Z4: „Im Erwachsenen-Zweig trägt die teilnehmende Person dasselbe für sich ein — Name,
Geburtsdatum, Anschrift und Notfallnummer". Name, Anschrift und Notfallnummer tragen `persons`,
`addresses` und `phone_numbers`; für das Geburtsdatum gibt es keine Spalte, und `persons` schließt
es ausdrücklich aus: „Bewusst KEIN Geburtsdatum: Es steht am Kind" (stammdaten-schema.sql). Weder
der Dateikopf noch der `[A!]` an `for_adults` nennt den Konflikt.
Vorschlag: nullable `birth_date` an `persons` — noch vor dem Vollimport, sonst ist es eine Migration
— oder ein Satz in Block 21, dass der Erwachsenen-Zweig ohne Geburtsdatum auskommt.
```

```
[F5] akademie · Klasse 5 · akademie-schema-check.sql, vier Gegenproben
„Anmeldung ohne Teilnehmer", „Anmeldung mit Kind und Person zugleich", „Kind an einem
Erwachsenen-Seminar" und „Erwachsene an einem Kinder-Angebot" laufen gegen Angebote, die zu diesem
Zeitpunkt bereits voll sind (502 und 503 haben je einen Platz). Alle vier werden vom Trigger mit
„Angebot ist voll" abgewiesen, einzeln nachgestellt und abgelesen — `ck_academy_registrations_
participant` und der Zweig-Fremdschlüssel `fk_academy_registrations_offering` haben damit keine
wirksame Gegenprobe und gelten als nicht gebaut.
Vorschlag: die vier Proben gegen ein eigenes Angebot mit freien Plätzen führen.
```

```
[F6] akademie · Klasse 1 · academy_offering_audiences
21 Z4: „Geprüft wird, ob das Kind zur Zielgruppe gehört und ob noch ein Platz frei ist." Die zweite
Hälfte des Satzes trägt der Trigger, die erste niemand: ein Grundschulkind meldet sich an einem
Angebot an, dessen Zielgruppe Realschule Stufe 5–6 ist (eigener INSERT, angenommen). Kein
Constraint, keine Gegenprobe, keine begründete Auslassung — obwohl der Trigger daneben ausdrücklich
gebaut wurde, „weil die Regel sonst keine Gegenprobe hätte".
Vorschlag: entweder in denselben Trigger, oder ein Satz am Trigger, warum diese Hälfte anders liegt.
```

```
[F7] akademie · Klasse 4 · academy_registrations
Der Löschanker nennt „das Ende des letzten Angebots dieses Teilnehmers und sechs Monate danach" und
für die Erwachsenen dieselbe Frist. Er trägt aber nur die Anmeldezeile: `persons` hat „keinen
eigenen [Anker] — eine Person verschwindet erst, wenn alle ihre Rollenanker erreicht sind", und die
erwachsene Teilnehmerin hat keine Rollenzeile. ferien-schema.sql schreibt den entsprechenden Satz
fürs schulfremde Kind aus („geht mit der letzten Buchung: Es hat kein Austrittsdatum"), akademie
nicht — weder für die Erwachsene noch für das nur über die Akademie entstandene Kind.
Vorschlag: den Satz aus ferien-schema.sql sinngemäß an `academy_registrations` nachziehen.
```

```
[F8] akademie · Klasse 3 · academy_offerings.surcharge_cents
Der Kommentar zitiert „die Hauswirtschaftsleitung je Termin einkauft" und schreibt es Block 10 zu.
Der Satz steht in keiner Datei dieses Repos außer hier; Block 10 nennt weder Lebensmittel noch die
Hauswirtschaftsleitung — die Kochwerkstatt ist dort ausdrücklich nach 21 abgegeben. Die Aussage
stimmt, die Belegstelle nicht.
Vorschlag: durch den Satz aus Block 21 ersetzen („Bei der Kochwerkstatt weiß es die
Hauswirtschaftsleitung") oder die Anführungszeichen streichen.
```

```
[F9] akademie · Klasse 1 · Dateikopf, fremde Datei gesundheit-schema.sql
Der Kopf behauptet, bei einem Kind der Schule gäben die Eltern den Bestand „frei
(`gesundheit-schema.sql`), mit derselben eigenen Frist wie im Ferienprogramm, gerechnet vom Ende
des letzten Angebots". Dort steht das Gegenteil: „Was noch fehlt, ist der Anlassgeber", es gibt nur
die zwei dauerhaften Instanzen `school` und `care`, und die Frist des schulfremden Kindes wird
allein aus ferien-schema.sql geholt — die Akademie kommt als vierter Weg in den Bestand dort nicht
vor.
Vorschlag: in gesundheit-schema.sql die Akademie neben dem Ferienprogramm nennen (Sitzung 1), hier
den Verweis entsprechend abschwächen.
```

```
[F10] akademie · Klasse 2 · academy_registrations.payment_mode
grenzkarte.md Q3: „der Erwachsenen-Zweig hat nie eines [SEPA-Mandat]", und 21 sagt, für ihn
entstehe keine Familie. `payment_mode = 'direct_debit'` an einer Anmeldung mit `for_adults` geht
trotzdem durch (eigener INSERT, angenommen) — eingezogen würde von einem Mandat, das es nicht gibt.
Vorschlag: `CHECK (NOT for_adults OR payment_mode <> 'direct_debit')` samt Gegenprobe.
```

```
[F11] akademie · Klasse 1 · academy_offerings.cancellation_terms_code
21: die Abmeldebedingungen sind „sichtbar bevor angemeldet wird". Der Code ist Freitext ohne Bezug:
ein Angebot mit `cancellation_terms_code = 'gibtsnicht'` wird angelegt, und
`cancellation_terms_contract_text_id` an der Anmeldung darf auf jeden beliebigen Text zeigen, auch
auf einen Schulvertragstext (beide eigenen INSERTs angenommen). Ein Tippfehler lässt die
Bedingungen still verschwinden. ferien-schema.sql trägt dieselbe Form, der Fund gilt also beiden.
Vorschlag: eine Codeliste zu `contract_texts` samt Fremdschlüssel, oder ein Satz, warum der Bruch
hingenommen wird.
```

```
[F12] akademie · Klasse 3 · akademie-schema.sql und -check.sql, fünf Stellen
Fünf Zitate stehen so nicht in ihrer Quelle: `cancelled_at` fügt „Umgekehrt sagt auch sie ab" und
„das ganze Angebot samt Grund in einem Satz" ohne Auslassungszeichen zusammen und verliert dabei
„eine einzelne Anmeldung oder"; der Kopf von `academy_registrations` schneidet ebenso zwei
Einschübe heraus, darunter „im Erwachsenen-Zweig die teilnehmende Person"; der Trigger zitiert
„bekannt ist ein Kind …" ohne „dabei" und ohne Block 10 zu nennen, aus dem der Satz stammt; im
Prüfskript sind „Sagt sie selbst ab, gilt keine Frist und keine Gebühr …" und „Ein fünfter Anlass
folgt demselben Muster …" Umformulierungen von 21 bzw. grenzkarte.md. Dazu: „die Anmeldung hängt an
einer Person und nicht am Kind" ist der Geschäftsführung zugeschrieben, steht wörtlich aber allein
in TASK-176 AC #14.
Vorschlag: Wortlaut nachziehen, Auslassungen als … kennzeichnen, Quellen beim Block nennen.
```

```
[F13] akademie · Klasse 1 · sync_tasks, fremde Datei querschnitt-schema.sql
21 Z2: die freigebende Stelle „erfährt davon als Aufgabe". `sync_tasks` verlangt genau einen von
neun Bezügen, und keiner davon ist ein Angebot; die Aufgabe ist damit nicht eintragbar. Ableitbar
wäre sie aus `approved_at IS NULL AND returned_at IS NULL` — genau das schreibt querschnitt für die
beiden Putzdienst-Aufgaben hin, für diese nicht.
Vorschlag: ein Satz an `academy_offerings`, dass die Freigabe-Aufgabe aus dem Bestand folgt.
```

### Angesehen, nicht als Fund gewertet

```
akademie · `closed_at` neben `registration_closes_at` sah nach zwei Orten für eine Tatsache aus;
        21 Z6 nennt beide Wege („zum gesetzten Datum oder jederzeit von Hand"), und
        `holiday_programmes` trägt dasselbe Paar.
akademie · `ck_academy_offerings_surcharge_label` sah nach falscher Operator-Rangfolge aus; beide
        Richtungen greifen nachweislich — Betrag ohne Etikett und Etikett ohne Betrag werden
        abgewiesen, ein nachträglich auf null gesetzter Betrag ebenso.
akademie · `amount_cents` ohne Gültigkeitstag sah nach einem Verstoß gegen den Geld-Hebel aus; der
        Betrag gehört diesem einen Angebot, und die Anmeldung hält fest, was beim Absenden galt.
akademie · `for_adults` an der Anmeldung sah nach Klasse 6 aus; rules.md §1 erlaubt genau den
        abgeleiteten Wert, der ein Constraint tragen muss, und `uq_academy_offerings_id_branch`
        bindet ihn an sein Original.
akademie · `payment_mode` als fest verdrahtete CHECK-Liste sah nach der Lookup-Regel aus; rules.md
        §3 nimmt den Fall aus, in dem eine Ausprägung entscheidet, welche Spalte derselben Zeile
        Pflicht ist — 'invoiced' und der Kostenübernahme-Code sind genau das.
akademie · Eine Zahlung, die mehrere Kinder in einem Zug trägt, zeigt auf eine einzige Anmeldung;
        grenzkarte.md Q3 schreibt genau das vor („der Betrag der Zahlung ist die Summe und gleicht
        dem keiner einzelnen").
akademie · Die Abmeldung lässt sich eintragen, ohne je erklärt worden zu sein, und mit einem
        Eintrag vor der Erklärung; `holiday_bookings` trägt dieselbe Form, und kein Blocksatz
        verlangt die Reihenfolge.
akademie · Eine Zielgruppenzeile an einem Erwachsenen-Angebot geht durch, obwohl der Kommentar
        „Im Erwachsenen-Zweig bleibt sie leer" sagt; der Satz beschreibt die Praxis, kein Blockgebot.
```

### `[A!]` in dieser Domäne

- akademie · „Die beiden Zweige sind eine Domäne mit einem Häkchen" (`academy_offerings.for_adults`)
  — Block 21 entscheidet sie: „Sie teilen jeden Schritt dieses Blocks und unterscheiden sich in
  einem Punkt". Der Schnitt trägt; offen bleibt allein, was [F4] nennt.
- akademie · „Die Freigabeberechtigung steht als Personenliste und nicht als Rolle"
  (`academy_approvers`) — Block 21 entscheidet sie wörtlich: „benannte Personen und keine Rolle".

### Offene Marken

`[?]` Wer die freigebende Stelle ist, steht in Block 21 offen — Adressat Geschäftsführung. Das
Schema kommt ohne die Antwort aus; `academy_approvers` bleibt bis dahin leer, und dann kann niemand
freigeben. Ob das gewollt ist, entscheidet nicht dieser Lauf.

Ohne Fund durchgekommen: keine — geprüft wurde allein `akademie`.

### Sortierung nach Gewicht

F1, F2, F3, F4 brechen im Betrieb oder verhindern den Bau des Erwachsenen-Zweigs; F5, F6 nehmen
gebauten Regeln ihre Beweiskraft; F7 bis F13 sind Anker, Verweise und Zitate.
