# Prüfbericht — Domäne gesundheit

Eigener Bericht neben `pruefberichte/aktuell.md` und `pruefberichte/aktuell-klassenorganisation.md`;
die Nummern zählen weiter, damit ein `[F]` über alle drei eindeutig bleibt.

Gelesen: `soll-prozesse/hebel.md`, `rules.md` §1/§3/§7, `grenzkarte.md`, dann
`schema/gesundheit-schema.sql` samt `-check.sql`, danach Block 08 und die Gesundheitsstellen von 09,
11 und 15; zum Abgleich `folgenabschaetzung.md` (R1–R9), `api/gesundheit-api.md`,
`querschnitt-schema.sql`, `stammdaten-schema.sql`, `ferien-schema.sql` und TASK-160/162/205/206.

Lauf: alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere Datenbank,
`rc=0` je Datei; danach alle vierzehn `*-schema-check.sql` gegen die vollständige Datenbank,
`rc=0` je Skript. Die Funde stammen aus eigenen `INSERT`s gegen dieselbe Datenbank.

## gesundheit

### Funde

```
[F32] gesundheit · Klasse 1 · health_field_visibility, Sichtkreis `emergency`
Der Dateikopf zitiert die Auflage vom 02.09.2026: „Der Mitarbeitende sieht im Notfall **alles**,
nicht nur einen Ausschnitt, und ohne Rücksicht auf Freigaben." Gebaut ist die zweite Hälfte —
`needs_release = false` schließt eine Freigabe an den Notfallkreis strukturell aus, und das
Prüfskript belegt sie. Die erste hängt an je einer `health_field_visibility`-Zeile: Ein neues Paar
(Kategorie, Feld) ist im Notfall unsichtbar, bis jemand die Zeile für `emergency` nachträgt
(nachgestellt: Paar angelegt, Schulsicht gesetzt, `emergency` sieht null). `api/gesundheit-api.md`
liefert ausdrücklich „die Felder des Sichtkreises `emergency`" — also genau diese Zeilen. Kein
Constraint, keine Gegenprobe, kein Satz, wer die Vollständigkeit hält; der Fehler ist still und
trifft R8 der Folgenabschätzung.
Vorschlag: die Vollständigkeit erzwingen — ein Trigger auf `health_type_fields`, der das Paar für
`emergency` mitanlegt —, oder `is_emergency` lesend auswerten, statt den Kreis über Zeilen zu führen.
```

```
[F33] gesundheit · Klasse 2 · child_health_answers, health_traits
Der ganze Bau steht auf drei unterscheidbaren Zuständen; 08 nennt „will nicht sagen" ausdrücklich
keine Entwarnung, und der Tabellenkopf nennt die Verwechslung „die eine Fehldeutung, die bei
Art.-9-Daten wirklich schadet". Durch geht trotzdem: eine Kategorie mit `declined_at`, darunter ein
`health_traits`-Satz mit dem Wert „Diabetes" (eigene INSERTs, angenommen). Die Ansicht meldet dann
„will nicht sagen", und im Bestand steht genau die Angabe, die die Familie nicht nennen wollte.
`api/gesundheit-api.md` schreibt die Kategorie am Stück und erzeugt den Zustand nicht — verhindert
ihn aber nichts.
Vorschlag: `is_answered` an `child_health_answers` generiert speichern wie `is_released` an
`child_health_releases` und `health_traits` per zusammengesetztem Fremdschlüssel daran binden.
```

```
[F34] gesundheit · Klasse 1 · health_trait_values.value_document_id
Das Attest hängt als `documents`-Fremdschlüssel am Merkmal, ohne Bindung an das Kind des Bestands:
Das Attest eines fremden Kindes lässt sich an jedes Merkmal hängen (eigener INSERT, angenommen).
grenzkarte.md führt „eine Datei beim falschen Kind" als realen Fehlermodus und schreibt für Q2
eigens einen Weg dafür vor; hier fängt ihn nichts, und der Sichtkreis mit `presence_only` meldet
danach „Attest liegt vor", während das Sekretariat die Akte eines anderen Kindes öffnet.
Vorschlag: `uq_documents_id_child` in querschnitt und `child_id` am Wert mitführen — oder ein Satz,
der die Prüfung der Route zuweist, wie ihn `api/gesundheit-api.md` für andere Fälle schon trägt.
```

```
[F35] gesundheit · Klasse 3 · Dateikopf, child_health_records, health_traits
Drei Belegstellen tragen nicht. (a) Zweimal steht „grenzkarte.md, ‚Zugriff, je Angabe'" — der
Abschnitt heißt dort „Zugriff, drei Bedingungen"; dieselbe falsche Angabe steht in
`klassenorganisation-schema.sql` (F23) und in `api/gesundheit-api.md`. (b) Der handlungsrelevante
Hinweis wird mit „ein kurzer handlungsrelevanter Hinweis ('keine Sprungübungen', 'Notfallmedikament
im Sekretariat'), den die Klassenlehrkraft formuliert und den alle unterrichtenden Personen sehen"
zitiert; die Karte trägt davon nur den halben Satz ohne Beispiele und ohne Leserkreis, sonst steht
er nirgends. (c) `health_traits` stellt sich „hier gegen grenzkarte.md: die führt sie als Q1-Zweck
(‚Erlaubnis, kein Gesundheitsmerkmal')" — die Karte führt die Zeckenentfernung längst nicht mehr so
und sagt selbst, der Block schlage sie; der zitierte Wortlaut steht dort nicht mehr.
Vorschlag: Abschnittsnamen berichtigen, (b) auf den Satz der Karte kürzen, (c) streichen — der
Widerspruch, den er austrägt, ist auf beiden Seiten erledigt.
```

```
[F36] gesundheit · Klasse 1 · die `[?]` am Dateiende
Sie sagt zur Aufbewahrung des Notfallprotokolls „Die Frist nicht" — beantwortet ist sie vierzig
Zeilen darüber in derselben Datei: „Die Aufbewahrung des Protokolls steht seit dem 03.09.2026: es
geht mit dem Kind", samt der Rechnung „ein Vorfall im September 2026 an einem Kind, das 2031 abgeht,
beginnt seine Frist 2031". Block 08 sagt „Das Protokoll geht mit dem Kind", und der Löschanker der
Tabelle sagt dasselbe. Dieselbe erledigte Frage steht offen in `api/gesundheit-api.md` und in
`folgenabschaetzung.md` (R2), dort neben dem Satz, der sie beantwortet.
Vorschlag: die `[?]` streichen und die beiden anderen Stellen mitziehen.
```

```
[F37] gesundheit · Klasse 1 · child_health_records.action_note
Der leere Hinweis geht durch (eigener INSERT, angenommen). Die Nachbarspalte trägt den CHECK samt
Begründung — „Eine leere Angabe ist keine" (`ck_health_trait_values_text`) —, und der Hinweis ist
die Spalte, die alle unterrichtenden Personen lesen: ein leerer Satz sieht dort aus wie ein
geprüfter.
Vorschlag: `ck_child_health_records_action_note CHECK (action_note <> '')` samt Gegenprobe.
```

### Angesehen, nicht als Fund gewertet

```
gesundheit · Ein als Ganzes verweigerter Bestand mit beantworteten Kategorien darunter geht durch;
        `api/gesundheit-api.md` entscheidet das ausdrücklich — „Ablehnen ist jederzeit möglich und
        rührt vorhandene Zeilen nicht an".
gesundheit · Das Notfallprotokoll lässt sich ändern und löschen; welche Rolle das darf, entscheidet
        der GRANT und nicht das Schema — die Datei weist ihn `backend_health_emergency` zu.
gesundheit · `measles_proofs.presented_on` nimmt den 01.01.2099; kein Blocksatz verlangt eine
        Grenze, und die Zeile trägt allein, „ob und wie er vorlag".
gesundheit · Die drei Monate nach dem Austritt stehen an der Freigabe, während der Betreuungsvertrag
        „nach Austritt gelöscht" zusagt; die Frist hat der Datenschutzbeauftragte am 02./03.09.2026
        gesetzt, und drei Monate danach liegen danach.
gesundheit · Die mitgeführten Spalten (`value_kind_code`, `health_trait_type_id`,
        `child_health_record_id`, `allows_multiple`, `needs_release`, `is_released`) sahen nach
        Klasse 6 aus; jede ist per zusammengesetztem Fremdschlüssel an ihre Quelle gebunden — genau
        die Ausnahme, die rules.md §1 dafür ausschreibt.
gesundheit · `health_value_kinds` ist eine Werteliste, deren Erweiterung doch eine Migration ist;
        die Ausnahme steht am Kopf der Tabelle und nennt ihren Preis.
gesundheit · Eine Freigabe an `full`, `kitchen` oder `emergency` ist strukturell ausgeschlossen und
        im Prüfskript belegt, ebenso die Einzelfreigabe an einer abgelehnten Instanz.
gesundheit · Der Notfallausschnitt übergeht die Freigabe — belegt mit einer Probe, die ohne den Join
        auf die Freigabe zählt; nur die Breite des Ausschnitts trägt niemand (F32).
```

### `[A!]` in dieser Domäne

Keine. `schema/gesundheit-schema.sql` trägt eine einzige Marke, die `[?]` aus [F36].

### Offene Marken

`[?]` Die Aufbewahrungsfrist des Notfallprotokolls — Adressat: der Datenschutzbeauftragte. Sie ist
der Gegenstand von [F36]: derselbe Dateikopf und Block 08 beantworten sie.

### Sortierung nach Gewicht

F32 und F33 treffen den Bestand selbst — der Notfallausschnitt kann zu schmal sein, ohne dass es
jemand merkt, und eine verweigerte Kategorie kann ihren Wert tragen. F34 trägt ein Attest ans
falsche Kind. F35 und F36 sind Belegstellen und eine beantwortete Frage, F37 ein fehlender CHECK.

Ohne Fund durchgekommen: keine — geprüft wurde allein `gesundheit`.
