# Prüfbericht — Domäne `querschnitt`

Lauf: Sitzung 5, `prompts/schema-pruefen.md`, gegen `schema/querschnitt-schema.sql` und
`schema/querschnitt-schema-check.sql`. Alle vierzehn Schemata in dokumentierter Reihenfolge
geladen (rc=0 je Datei; `schema/ags-schema.sql` gibt es nicht — der Prompt nennt sie), alle
vierzehn Prüfskripte gegen die vollständige Datenbank gelaufen, **rc=0 je Skript**.
Die eigenen Angriffs-`INSERT`s stehen unter F2, F4, F12 und F14.

## querschnitt

### Funde, nach Gewicht

```
[F1] querschnitt · Klasse 3/4 · consents, Zeile 578–586
Der Kommentar sagt „Das Fotoeinverständnis ist davon ausgenommen: Es wird
**unbegrenzt** aufbewahrt (Datenschutzbeauftragter, 02.09.2026)". Block 08
(„Löschen") sagt das Gegenteil: „Gesundheitsangaben und Fotoeinverständnis
hängen am Kind und verschwinden mit ihm im Lösch-Lauf (17)". Gebaut ist Block 08
— `fk_consents_child` und `fk_consents_person` kaskadieren beide (Zeile 621/622),
und das eigene Prüfskript belegt es ausdrücklich („keine Zustimmung überlebt ihr
Kind"). Beschlossen ist „unbegrenzt" ebenfalls nicht: In
`pruefberichte/gespraech-geschaeftsfuehrung.md` (2.2) ist es eine vorbereitete
Frage samt Warnung, dass es „ein Eingriff in die Löschmechanik, kein Nachtrag"
wäre.
Vorschlag: Kommentar auf Block 08 zurückführen; wenn „unbegrenzt" gewollt ist,
wird es ein Ticket und ein Bestandscode, nicht ein Satz an einer Cascade.
```

```
[F2] querschnitt · Klasse 1/2 · documents, Zeile 492–535
Kein UNIQUE über (`sharepoint_library_id`, `graph_item_id`). Zwei Dokumentzeilen
zweier Kinder dürfen damit auf dieselbe Graph-Datei zeigen — nachgewiesen, geht
durch. Die Schwestertabelle `expense_claim_attachments` trägt genau diesen
Schlüssel (`uq_expense_claim_attachments`, rechnungsfreigabe-schema.sql:520), und
grenzkarte.md Q2 sagt „Jede Datei bekommt eine Zeile". Folge im Betrieb: Der
Lösch-Lauf räumt in Stufe 1 „erst die Datei in SharePoint … dann die Zeile" (17)
und entfernt dabei die Datei, auf die die Zeile des anderen Kindes noch zeigt.
Vorschlag: UNIQUE (sharepoint_library_id, graph_item_id), wie an den Anhängen.
```

```
[F3] querschnitt · Klasse 5 · querschnitt-schema-check.sql, Zeile 375–383
Die Probe „Q2 — Zustimmung mit einer Datei, die es nicht gibt" wird von
`fk_consents_person` abgewiesen, nicht von `fk_consents_document`: Sie benutzt
Person `…222223`, die erst 670 Zeilen später (Zeile 1049) angelegt wird. Einzeln
abgesetzt meldet Postgres „violates foreign key constraint fk_consents_person".
Die Probe belegt damit nichts über die Datei-Referenz, die sie zu prüfen behauptet.
Vorschlag: eine der beiden vorhandenen Personen einsetzen.
```

```
[F4] querschnitt · Klasse 1 · sync_tasks.school_branch_id, Zeile 795–802
Der Kommentar behauptet die Regel „Leer bei jedem Ziel, dessen Rolle nicht an eine
Schulart gebunden ist … (`roles.is_branch_bound`)". Nichts hält sie: Eine Aufgabe
zum Ziel `asv_bw` (Rolle Sekretariat, nicht schulartgebunden) mit gesetzter
Schulart geht durch — nachgewiesen. Das Muster steht zwei Dateien weiter und wird
dort genau dafür benutzt: `roles` trägt `uq_roles_branch_bound UNIQUE (role_id,
is_branch_bound)`, und `employee_roles` bindet daran plus
`CHECK (is_branch_bound = (school_branch_id IS NOT NULL))`
(stammdaten-schema.sql:243/905/917). Die eigene Probe „Q5 — Aufgabe mit Bezug und
Schulart" legt die Schulart selbst an ein Sekretariats-Ziel und ist grün.
Vorschlag: `is_branch_bound` an `sync_targets` mitführen, zusammengesetzter
Fremdschlüssel auf `roles`, CHECK wie an `employee_roles`.
```

```
[F5] querschnitt · Klasse 3/7 · document_types, Zeile 247–249
„Herkunft: grenzkarte.md, Q2 — ‚Eine Dokumentzeile entsteht nur, wo ein Prozess
sie liest: die signierten Unterlagen und die am Anmeldetag angeforderten'." Der
Satz steht in der Grenzkarte nicht, und die heutige Fassung sagt das Gegenteil:
„**Jede Datei bekommt eine Zeile.** Das war einmal anders" (Q2). Die Begründung
der Tabelle stützt sich damit auf eine überholte Fassung.
Vorschlag: Herkunft auf den heutigen Q2-Absatz („Die Art ist freiwillig …")
umschreiben.
```

```
[F6] querschnitt · Klasse 3 · child_file_folders, Zeile 542–545
„Herkunft: grenzkarte.md, Q2 — ‚Nur der Ordner der Schülerakte braucht einen
Anker in der Datenbank: dort legen Menschen frei ab, und ohne ihn erreichte der
Lösch-Job das nicht.'" Der Satz steht dort nicht; die heutige Karte begründet den
Ordner-Anker anders („Der **Ordner-Anker** bleibt daneben bestehen … er trägt den
Ordner selbst, den der Lösch-Lauf zusätzlich zu seinen Dateien entfernen muss").
Vorschlag: Zitat gegen den heutigen Satz tauschen.
```

```
[F7] querschnitt · Klasse 3 · sharepoint_libraries, Zeile 210
„Herkunft: grenzkarte.md, Q2 — ‚Die Bibliotheksgrenze ist die Zugriffsgrenze.'"
Der Satz steht in grenzkarte.md nirgends; er steht in `oberflaechen.md:35` und
`folgenabschaetzung.md:114`, die beide ihrerseits auf Q2 verweisen. `oberflaechen.md`
spricht dabei von **drei** Bibliotheken, der Kommentar hier von zwei.
Vorschlag: Herkunft auf `oberflaechen.md` umhängen und die Zahl dort und hier
gleichziehen.
```

```
[F8] querschnitt · Klasse 3 · consent_purposes, Zeile 167–178
Zwei Behauptungen über die Grenzkarte, die sie nicht hergibt. Erstens zitiert die
„Herkunft" die Q1-Liste mit „Fotoeinverständnis, die Zeckenentfernung …,
Werbe-Einwilligung Ferienbetreuung" — die Zeckenentfernung steht in dieser Liste
nicht. Zweitens: „grenzkarte.md führt sie hier („Erlaubnis, kein
Gesundheitsmerkmal")" — die Wendung steht nirgends im Repo, und die Karte sagt
ausdrücklich „**Die Zeckenentfernung steht entgegen einer älteren Fassung dieser
Karte nicht hier**". Die Abgrenzung, die der Kommentar aufmacht, ist längst
geschlossen; sie zitiert die Karte gegen sich selbst.
Vorschlag: den Absatz auf einen Satz kürzen, der auf den heutigen Q1-Absatz zeigt.
```

```
[F9] querschnitt · Klasse 3/7 · retention_subjects, Zeile 1132
Die Aufzählung der Bestandscodes führt „change_log" (17). Block 17 sagt: „**Die
Änderungsspur bekommt keine eigene Frist.** Sie lebt genau so lange wie das,
worüber sie Auskunft gibt", und der Kopf derselben Datei sagt es auch („Eine achte
Stufe für die `change_log`-Zeilen gibt es **nicht**"). Ein Bestand ist laut
demselben Kommentar „**eine Frist mit einem Anker**" — die Spur hat keine. Der
Code ist ein Rest aus dem Stand vor bdcdd12.
Vorschlag: „change_log" aus der Liste streichen.
```

```
[F10] querschnitt · Klasse 3 · Schlussnotiz, Zeile 1333–1336
„`sharepoint_libraries` trägt beliebig viele Zeilen, gebraucht wird eine."
Gebraucht werden zwei: Der Kommentar an derselben Tabelle sagt „Zwei Zeilen, und
zwei Sites" (Zeile 211), und rechnungsfreigabe-schema.sql:501 sagt „Im Schema ist
das eine zweite Zeile in `sharepoint_libraries` und sonst nichts". Die Notiz
beantwortet die Hort-Frage richtig und zieht daraus die falsche Zahl.
Vorschlag: „gebraucht werden zwei — Schülerakte und Rechnungsfreigabe".
```

```
[F11] querschnitt · Klasse 5 · contract_texts / contract_text_kinds
`fk_contract_texts_kind` hat in keinem Prüfskript eine Gegenprobe: Kein Lauf legt
eine Fassung mit einer Sorte an, die es nicht gibt. Der Kommentar begründet die
Werteliste genau damit — „ein Tippfehler ließe die Bedingungen sonst still
verschwinden". Auch die Namensliste in Abschnitt 2 des Prüfskripts kennt weder
`fk_contract_texts_kind` noch `uq_contract_texts_id_code`,
`pk_contract_text_kinds` oder `uq_contract_text_kinds_code`.
Vorschlag: eine `expect_reject`-Probe mit unbekanntem `code`, die vier Namen in
die Liste.
```

```
[F12] querschnitt · Klasse 1/2 · consents.document_id / consents.signature_id
Beide Fremdschlüssel binden nur die Zeile, nicht das Kind bzw. die Person. Eine
Zustimmung für Kind A darf auf die Datei von Kind B zeigen, und eine Zustimmung
der Person X auf die Unterschrift der Person Y — beides nachgewiesen, geht durch.
grenzkarte.md Q2 nennt genau diesen Fall den teuren („Eine Datei beim falschen
Kind … die Verwechslung wäre damit nicht behoben, sondern eingebaut"), und
dieselbe Datei löst ihn an anderer Stelle bereits mit einem zusammengesetzten
Fremdschlüssel (`fk_consents_purpose`, `fk_retention_holds_first`).
Vorschlag: `documents` und `signatures` je ein UNIQUE (id, child_id) bzw.
(id, person_id) geben und `consents` zusammengesetzt darauf zeigen lassen.
```

```
[F13] querschnitt · Klasse 2/5 · retention_holds, Zeile 1271–1305
Nichts verlangt, dass ein zweites Anhalten am selben Fall `first_hold_id` trägt.
Eine zweite Zeile ohne ihn und mit **neuem** `original_delete_on` geht durch —
nachgewiesen. Damit ist der zusammengesetzte Fremdschlüssel, der „Der
ursprüngliche Löschtermin bleibt beim Verlängern stehen" (hebel.md) hält,
freiwillig: Wer über die Oberfläche „neu anhalten" statt „verlängern" wählt,
setzt genau die Zählung zurück, um die es geht. Die Liste rettet sich heute nur,
weil ihre Abfrage `min(original_delete_on)` nimmt.
Vorschlag: partieller UNIQUE über (retention_subject_id, Anker) für laufende
Anhaltungen, oder `first_hold_id` gegen eine offene Kette erzwingen.
```

```
[F14] querschnitt · Klasse 5 · ck_retention_holds_first_other
Der CHECK steht nur in der Namensliste; eine Gegenprobe, die eine Zeile als ihre
eigene erste einträgt, gibt es nicht. „Eine Regel ohne Gegenprobe gilt als nicht
gebaut" (CLAUDE.md).
Vorschlag: eine `expect_reject`-Probe mit first_hold_id = retention_hold_id.
```

```
[F15] querschnitt · Klasse 3 · drei elidierte Zitate
„ein festes Datum schlägt ein gerechnetes" (Zeile 1156, hebel.md schreibt „ein
festes Datum wie ‚am 1. jedes Monats' schlägt ein gerechnetes"); „wer einen Grund
findet, den es geben muss, bekommt eine fünfte Zeile und keinen Freitext" (Zeile
1219, Block 17 schreibt „wer einen findet … eine fünfte Zeile **in der Liste**");
„sichtbar sein müssen, bevor angemeldet wird" (Zeile 317, 21 schreibt „sichtbar
bevor angemeldet wird", 10 „sichtbar bevor gebucht wird"). Sinngemäß richtig,
wörtlich keines.
Vorschlag: wörtlich zitieren oder die Anführungszeichen fallen lassen.
```

```
[F16] querschnitt · Klasse 3 · payments/sync_tasks, Zeile 724 und 756
`payments` nennt die Aufgabe zur vorgangslosen Zahlung „als achten Bezug"; sie ist
der neunte, und `ck_sync_tasks_single_subject` zählt neun. Die Aufzählung an
Zeile 756 sagt „Genau einer der neun Bezüge" und nennt danach acht — die Zahlung
fehlt. Dasselbe im Prüfskript, Zeile 534 („Der achte Bezug").
Vorschlag: beide Stellen auf neun ziehen und die Zahlung in die Aufzählung nehmen.
```

```
[F17] querschnitt · Klasse 6 · created_by der Wertelisten
`consent_purposes`, `sharepoint_libraries`, `document_types`, `sync_targets` und
`contract_texts` lassen `guardian:` als Urheber zu; `contract_text_kinds`,
`retention_subjects`, `retention_hold_reasons` und
`retention_notice_recipients` lassen nur `entra:|system:` zu. Eine Werteliste legt
kein Elternteil an, und `contract_texts` pflegt ausdrücklich die Geschäftsführung
(hebel.md) — die Sorte daneben ist bereits richtig eng.
Vorschlag: die fünf auf `^(entra:|system:)` ziehen.
```

```
[F18] querschnitt · Klasse 7 · Quellenlage zum Fotoeinverständnis
grenzkarte.md Q1 sagt: „Ja, **wenn mindestens eine** dieser Personen erteilt hat
und keine von ihnen abgelehnt hat" und „**Eine fehlende zweite Antwort sperrt
dagegen nicht**". Block 08 sagt: „**Ja nur, wenn alle erwarteten Personen Ja
gesagt haben** — ein Nein und ein noch offenes Feld wiegen dabei gleich schwer",
und `soll-prozesse/README.md` folgt ihm. Nach der Rangfolge schlägt der Block die
Karte; die Karte trägt die überholte Regel trotzdem weiter und wird im Schema an
mehreren Stellen als Q1-Quelle zitiert. Das Schema selbst ist davon nicht
betroffen (es baut die Ansicht nicht), der nächste Leser aber schon.
Vorschlag: den Q1-Absatz der Grenzkarte auf Block 08 ziehen.
```

### Angesehen, nicht als Fund gewertet

```
querschnitt · `documents` ohne Aktenkategorie und ohne Pflicht-Bezeichnung, `document_type_id`
        NOT NULL, obwohl grenzkarte.md Q2 „Die Art ist freiwillig" sagt — offen als
        TASK-181 (AC #8), samt Hortakte und Kategorie-Unterordner (AC #1, #2).
        Ein offener Punkt gehört ins Board und nicht in diesen Bericht; die
        falschen Zitate daneben (F5–F7, F10) deckt das Ticket nicht ab.
querschnitt · `child_file_folders` mit UNIQUE (child_id) und der Schlusssatz „Der Hort bekommt
        keine eigene Bibliothek" — dieselbe TASK-181, AC #1 und #2.
querschnitt · `ck_payments_single_cause` mit `<= 1` statt „genau einen Anlass je Zahlung"
        (grenzkarte.md Q3) — der Grund steht am Constraint, api/gemeinsam.md trägt
        ihn („Trägt die Bedingung beim Rückruf nicht mehr, wird nichts automatisch
        erstattet"), und beide Gegenproben stehen (Zahlung ohne Anlass erlaubt,
        zwei Anlässe abgewiesen).
querschnitt · `consents.delivery_address` nullable, obwohl Q1 sagt, sie „gehört zwingend
        dazu" — der Fall ist benannt und belegt (README: „Das Sekretariat trägt sie
        aus den Akten nach"), und die Gegenprobe steht.
querschnitt · `ix_consents_person_child_purpose` sah nach Klasse 2 aus (die zweite Antwort
        derselben Person wird abgewiesen); „eine spätere ersetzt die frühere" ist
        ein UPDATE derselben Zeile, und nach einem Widerruf lässt der partielle
        Index die neue Zeile zu — beides ist geprobt.
querschnitt · `signatures` ohne Gegenprobe zum Vertragsbezug im eigenen Skript — sie steht
        in anmeldung-schema-check.sql (Zeile 1061 ff.), weil der Fremdschlüssel
        erst dort entsteht; `ck_signatures_agreement` ebenso.
querschnitt · `payments` ohne Gegenprobe zu Status, Betrag und Zahlungsreferenz — sie stehen
        in putzdienst-schema-check.sql, weil sie einen echten Anlass brauchen.
querschnitt · `outbound_emails` ohne Löschanker für die Zeile ohne Person — benannte offene
        Frage an die Datenschutzbeauftragte im Dateikopf, keine Auslassung.
querschnitt · Mindestens zwei Empfänger je Bestand nicht als Constraint — begründete
        Auslassung (zählt über Zeilen), und das Prüfskript weist den
        Ein-Empfänger-Fall mit der Abfrage nach, die auch der Betrieb laufen lässt.
querschnitt · `sync_tasks` mit Schuljahr oder Zeitraum als Bezug hat keinen Löschanker —
        an diesen Bezügen hängt kein Personendatum, `task_text` trägt den Vorgang.
```

### `[A!]`-Marken dieser Domäne

- **Q1–Q5 in einer eigenen Datei statt in der ersten Domäne, die sie braucht** (Zeile 14) — kein
  Block entscheidet den Schnitt; grenzkarte.md Regel 4 tut es („Was in mehr als einer Domäne
  vorkommt, gehört keiner davon").
- **Eine Signatur hängt am Vertragsvorgang, nicht am Dokument** (Zeile 383) — Block 08 entscheidet
  sie: „Vor der Freigabe entsteht kein Dokument."
- **Der Bezug der Änderungsspur ist Tabellenname plus Schlüssel als Text** (Zeile 1025) — kein Block
  entscheidet die Bauform; hebel.md verlangt nur, dass es genau einen Mechanismus gibt.

### Ohne Fund durchgekommen

Keine. Geprüft wurde allein `querschnitt`; die dreizehn übrigen Domänen waren geladen, damit die
Prüfskripte gegen die vollständige Datenbank laufen konnten, und sind nicht Gegenstand dieses Laufs.
