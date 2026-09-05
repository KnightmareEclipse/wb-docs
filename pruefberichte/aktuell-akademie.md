# Prüfbericht Akademie

Geprüft: `schema/akademie-schema.sql` samt `schema/akademie-schema-check.sql` gegen
`soll-prozesse/21-akademie.md`, `soll-prozesse/hebel.md`, `rules.md` (1, 3, 7) und `grenzkarte.md`.
Gegengelesen wurden außerdem die Stellen, auf die das Schema verweist: `ferien-schema.sql`
(Absagefrist, Kostenübernahme-Code, Esstage), `querschnitt-schema.sql` (Zahlweg, Lösch-Lauf, Q3/Q5),
`elternbonus-schema.sql` (Zielgruppe) und `soll-prozesse/10-ferienprogramm.md`.

**Lauf:** Alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere
PostgreSQL-18-Datenbank (`wb-pruef-akademie`) — Rückgabewert 0 je Datei.
`akademie-schema-check.sql` gegen diese vollständige Datenbank: **Rückgabewert 0**.

## Funde

```
[AKADEMIE-F1] akademie · Klasse 2 · academy_offering_audiences / enforce_academy_registration
21 sagt „Ein fremdes Kind meldet sich an wie jedes andere, sobald das Angebot ihm
offensteht; es hat keine Klassenstufe, und gebraucht wird sie hier nicht" — der
Zielgruppen-Zweig des Triggers (akademie-schema.sql, `CASE WHEN a.class_id …`)
weist es trotzdem ab, sobald das Angebot **irgendeine** Zielgruppenzeile trägt:
Klasse, Schulart und Stufe sind an einem schulfremden Kind NULL, jeder Vergleich
wird NULL, und `allows_external_children = true` hilft nicht, weil die beiden
Prüfungen unabhängig voneinander sind. Nachgestellt: Angebot mit
`allows_external_children = true` und Zielgruppe „Grundschule, Stufe 1–4",
eingeschriebenes Kind kommt durch, schulfremdes bekommt „Kind … gehört nicht zur
Zielgruppe".
Vorschlag: im Trigger die Zielgruppenprüfung überspringen, wo das Kind weder
Klasse noch Schulart noch Stufe trägt — dann trägt allein das Häkchen, ob es
mitmachen darf.

[AKADEMIE-F2] akademie · Klasse 1 · academy_registrations.payment_mode
hebel.md („Der Zahlweg") und 21 Z5 („Das Geld folgt dem Mandat … auf Stripe
festgelegt ist die, bei der jemand die Sperre gesetzt hat") entscheiden den
Zahlweg in drei Stufen; der Kommentar an der Spalte schreibt alle drei aus, das
Schema prüft keine davon und nennt die Auslassung auch nicht. Nachgestellt:
Familie mit gesetztem `families.direct_debit_blocked_at`, Kind ohne
`sepa_mandates`-Zeile, `payment_mode = 'direct_debit'` — die Anmeldung geht durch.
Das eigene Prüfskript legt denselben Fall selbst an („Kind mit laufendem
Hortvertrag ist kein fremdes Kind", ohne Mandat).
Vorschlag: die zwei Stufen in `enforce_academy_registration()` mitprüfen — er
liest `children` und `contracts` bereits — oder die Auslassung als „bewusst KEINE
Prüfung, weil …" an die Spalte schreiben.

[AKADEMIE-F3] akademie · Klasse 7 · academy_offerings.cancellation_deadline_days/-_time
Die beiden Spalten heißen im Kommentar „Die Sperre der Eltern als Zahl und
Uhrzeit" und rechnen daraus einen Termin („Den Eltern wird nie der Abstand
gezeigt, sondern der daraus gerechnete Termin"). 21 kennt keine Sperre: „Die
Eltern melden ihr Kind im Portal ab oder rufen an", und die Bedingung „bis 9 Uhr
am Kurstag kostenlos, danach die halbe Kursgebühr" ist ein Preis, keine Frist,
hinter der nichts mehr geht — ausdrücklich „Das System rechnet daraus nichts".
Die Sperre stammt aus 10 („ab 3 Tagen ist ein Storno nicht mehr möglich"), und
genau diesen Satz hat 21 nicht. Das Prüfskript setzt für die Kochwerkstatt 0 Tage
und 09:00 — ab 09:01 am Kurstag wäre die Selbst-Abmeldung gesperrt, obwohl der
Block dort die halbe Gebühr vorsieht.
Vorschlag: die beiden Spalten streichen (die Bedingungen tragen der Text und die
Stelle, die den Betrag einträgt) oder einen Blocksatz für die Sperre einholen.

[AKADEMIE-F4] akademie · Klasse 1 · enforce_academy_registration()
Nach `IF NEW.created_by NOT LIKE 'guardian:%' THEN RETURN NEW` fällt auch die
Prüfung auf das abgesagte Angebot weg. 21 sagt „Umgekehrt sagt auch sie ab — …
das ganze Angebot", und der Kommentar am Trigger zählt „ein abgesagtes Angebot
nimmt niemanden mehr auf" selbst unter die Regeln. Der [offizielle
Umweg](hebel.md) trägt die anderen drei (Freigabe, Fenster, Zielgruppe: „jeden
Punkt selbst bestätigen, wenn die zuständige Stelle ausfällt"), für ein
abgesagtes Angebot nennt kein Block einen Ausweg — es gibt nichts, was das
Sekretariat dort stellvertretend täte. Nachgestellt: `entra:sekretariat` meldet
ein Kind zu einem abgesagten Angebot an, die Zeile entsteht.
Vorschlag: die Absage vor das `RETURN NEW` ziehen, zu Platzzahl und fremdem Kind.

[AKADEMIE-F5] akademie · Klasse 1 · trg_academy_registrations_admission
Der Trigger steht auf `BEFORE INSERT`; die harte Platzzahl („daran ändert der
Zufall zweier gleichzeitiger Anmeldungen nichts") gilt damit nur für neue Zeilen.
Nachgestellt: Angebot mit einem Platz, eine abgemeldete und eine offene Anmeldung,
dann `UPDATE … SET cancellation_recorded_at = NULL` an der abgemeldeten — zwei
offene Anmeldungen auf einem Platz. Dasselbe gilt für ein `UPDATE` des
`academy_offering_id`: es geht an Platzzahl, fremdem Kind und Zielgruppe vorbei.
Das Zurücknehmen eines versehentlich eingetragenen Abmeldevermerks ist der reale
Fall dahinter.
Vorschlag: `BEFORE INSERT OR UPDATE OF academy_offering_id, child_id, person_id,
cancellation_recorded_at`.

[AKADEMIE-F6] akademie · Klasse 5 · akademie-schema-check.sql
Zwei Lücken im Prüfskript. Erstens läuft die Probe „Ein Angebot ohne Esstag ist
der Normalfall" (Zeile 432) gegen Angebot `…502`, das erst 31 Zeilen später
angelegt wird — sie trifft nie eine Zeile und liefe auch grün, wenn das Angebot
ein `includes_lunch` trüge; die bewusste Auslassung dieser Spalte hat damit keine
Gegenprobe, anders als die von `offering_type`/`kind`. Zweitens hat die Regel aus
21 Z6 („Schließt die Anmeldung — zum gesetzten Datum oder jederzeit von Hand")
keine: weder `closed_at` noch ein erreichtes `registration_closes_at` werden
geprüft, obwohl der Trigger beide trägt (nachgestellt: beide weisen ab). Ebenso
ohne Gegenprobe: das lügende Zahlweg-Tripel (`'paid'` mit `is_direct_debit`),
das der zusammengesetzte Fremdschlüssel abweist, und
`ck_academy_offerings_approved`, das auch in der Constraint-Liste des Skripts
fehlt.
Vorschlag: die Esstag-Probe hinter die Anlage von `…502` ziehen und um eine
Spaltenprobe auf `includes_lunch` ergänzen, dazu drei `expect_reject` für
geschlossenes Fenster, geschlossene Anmeldung und lügendes Tripel.

[AKADEMIE-F7] akademie · Klasse 7 · grenzkarte.md
Die Karte ist nicht vollständig nachgezogen. Ihre „Weißen Flecken" führen weiter
„Welche Kategorien die Akademie führt und wer ein Angebot ausschreiben darf |
Geschäftsführung (`fragen.md`) | vor dem Akademie-Schema" — beides ist am
03.09.2026 entschieden und steht in 21 („Anlegen darf jede und jeder
Mitarbeitende"; die Kategorienliste ist bewusst leer), `fragen.md` kennt die
Frage nicht mehr, und das Schema steht. Und die Entitätenspalte der Akademie
nennt Kategorie, Angebot, Zielgruppe, Anmeldung und Kostenübernahme-Code, aber
weder die Verantwortlichen (`academy_offering_leads`) noch die Freigebenden
(`academy_approvers`) — zwei eigene Tabellen, die Zuständigkeit tragen.
Vorschlag: die Zeile aus den weißen Flecken streichen und die beiden Entitäten in
der Domänentabelle ergänzen.

[AKADEMIE-F8] akademie · Klasse 1 · academy_offerings.approved_at
Der Kommentar verweist für den Abschalter der Freigabe („dann gilt jedes Angebot
als angenommen", 21) auf `configured_values` (querschnitt-schema.sql). Deren
Kommentar zählt alle elf Codes auf, die es gibt — der Akademie-Schalter ist
nicht darunter, hat also keinen Namen, und keine Gegenprobe zeigt ihn. Dazu
kommt, dass `configured_values.value` ein `integer` mit Gültigkeitstag ist und
die Tabelle sich ausdrücklich als Ort für Geld und Fristen beschreibt.
Vorschlag: den Code dort benennen (etwa `academy_approval_required`) oder den
Schalter an einer Stelle unterbringen, die kein Geldwert ist.

[AKADEMIE-F9] akademie · Klasse 3 · akademie-schema.sql
Drei Zitate stehen so nicht in ihrer Quelle. `persons` „trägt keinen eigenen
[Anker]" — stammdaten-schema.sql schreibt „Löschanker: keiner eigener";
„sichtbar, bevor angemeldet wird" — 21 schreibt es ohne Komma; „kann jedes Datum
setzen, auch eines in der Vergangenheit" — hebel.md schreibt „können außerdem
jedes Datum setzen". Alle drei treffen die Sache, keines den Wortlaut. Die
übrigen der 67 Zitate dieser Datei sind gegen ihre Quelle gehalten und wörtlich,
die Sätze der Geschäftsführung und des Betreibers vom 03.09.2026 gegen
`pruefberichte/einarbeiten-2026-09-03.md`.
Vorschlag: die drei Stellen an den Wortlaut angleichen oder die
Anführungszeichen streichen.

[AKADEMIE-F10] akademie · Klasse 3 · academy_offerings.amount_cents
„die dritte benannte Ausnahme vom Geld-Hebel (hebel.md)" — hebel.md nennt sie als
**erste von zwei** („mit zwei benannten Ausnahmen: den Betrag eines
Akademie-Angebots … und die Ausflugspauschale") und führt sie an der zweiten
Stelle wieder zuerst. Die Zählung stammt aus 21, der Block schlägt hebel.md — die
Zahl bleibt trotzdem falsch, weil sie auf hebel.md zeigt.
Vorschlag: in 21 und in der `.sql` „die erste benannte Ausnahme" schreiben.
```

## Angesehen, nicht als Fund gewertet

```
akademie · Die Gesundheitsfreigabe „für dieses Angebot" hat im Schema keinen Ort
        — das ist eine begründete Auslassung samt Ticket: der Anlassgeber fehlt
        in gesundheit-schema.sql, TASK-162 trägt ihn.
akademie · Die Löschankündigung an „die Verantwortlichen des Angebots"
        (hebel.md) sah nach einer fehlenden Zuordnung aus;
        `retention_notice_recipients.from_the_case` trägt sie und nennt 21
        ausdrücklich (querschnitt-schema.sql).
akademie · `payments` zeigt bei „Mehrere Kinder in einem Zug" nur auf eine der
        Anmeldungen; grenzkarte.md schreibt genau diese Form für die
        Ferienbuchung aus („der Betrag der Zahlung ist die Summe und gleicht dem
        keiner einzelnen").
akademie · Der Kopf nennt anmeldung-schema.sql als Voraussetzung; geladen wird
        die Datei auch ohne sie mit Rückgabewert 0 (der Trigger-Rumpf wird erst
        beim Aufruf aufgelöst). „Der Rest in beliebiger Folge" (CLAUDE.md) hält
        also, die Abhängigkeit greift zur Laufzeit.
akademie · Das Zitat „für dieses Angebot frei" ist die gekürzte Form von „für
        dieses Angebot freigegeben" (21) — die Zeichenfolge steht wörtlich da,
        der Sinn ist unverändert.
akademie · `academy_approvers` ist mit `approved_by` durch keinen Schlüssel
        verbunden; wer freigeben darf, ist überall in diesem Modell eine Frage
        der Berechtigung und nicht des Fremdschlüssels.
akademie · Die Probe „die Kategorienliste ist nicht leer" prüft einen
        Datenstand statt einer Struktur — das ist ausgeschrieben und gewollt
        („keine Lücke, sondern der Stand").
```

## Die `[A!]` dieser Domäne

- `academy_offerings.for_adults` — „Die beiden Zweige sind eine Domäne mit einem Häkchen." Kein Block entscheidet den Schnitt; 21 beschreibt beide Zweige als einen Ablauf („Sie teilen jeden Schritt dieses Blocks und unterscheiden sich in einem Punkt"), was die Annahme trägt, ohne sie auszusprechen.
- `academy_approvers` — „Die Freigabeberechtigung steht als Personenliste und nicht als Rolle." Das entscheidet 21 wörtlich („Es sind **benannte Personen und keine Rolle**"); die Marke bleibt trotzdem stehen, wie `prompts/gemeinsam.md` es für `[A!]` verlangt. Offen ist allein, **wer** es ist — als `[?]` an die Geschäftsführung im Block, nicht im Schema.

## Ergebnis

Die Domäne kommt **nicht ohne Fund** durch: zehn Funde, davon drei mit Wirkung im
Betrieb (F1, F2, F3). Prüfskript grün (Rückgabewert 0), Ladelauf aller vierzehn
Schemata grün.

**Nach Gewicht:** F1, F2, F3, F4, F5, F6, F7, F8, F9, F10.
