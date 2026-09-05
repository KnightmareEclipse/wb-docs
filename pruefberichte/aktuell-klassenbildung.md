# Prüfbericht klassenbildung

Gegenstand: `schema/klassenbildung-schema.sql` samt `schema/klassenbildung-schema-check.sql`,
gegen `soll-prozesse/15-klassenbildung.md`, `soll-prozesse/hebel.md`, `rules.md` (1, 3, 7) und
`grenzkarte.md`.

Lauf: alle vierzehn `*-schema.sql` in eine leere `postgres:18` (Container `wb-pruef-klassenbildung`),
Ladereihenfolge `stammdaten`, `querschnitt`, Rest — **jede Datei rc=0**.
`klassenbildung-schema-check.sql` gegen diese vollständige Datenbank: **rc=0**.

## Funde

```
[KLASSENBILDUNG-F1] klassenbildung · Klasse 1 · stammdaten-schema.sql:461-479 (`classes`)
15 nennt die Kennung „eine Kennung, die ihr ganzes Leben gleich bleibt" und „die Kennung, die nie
geändert wird"; nachgestellt ließen sich `stream` und `start_school_year` einer **besetzten** Klasse
auf `('z', 1999)` umschreiben — nur der Zweig ist über `fk_children_class` gehalten. An der Kennung
hängen laut 15 (Fremdsysteme) M365-Gruppe, Mailverteiler und der Aktenordner; keine Zeile im Schema
sagt, wer die Unveränderlichkeit trägt.
Vorschlag: Spalten-GRANT — die Anwendungsrolle bekommt INSERT, aber kein UPDATE auf
(school_branch_id, start_school_year, stream); die Gegenprobe ist dann ein Rollenwechsel im Skript.
```

```
[KLASSENBILDUNG-F2] klassenbildung · Klasse 3 · klassenbildung-schema.sql:3-7 und grenzkarte.md:330-331
Das Kopfzitat übernimmt aus grenzkarte.md „eine Ansicht … mit Geschlecht, Wohnort, Geschwistern und
**Wunschnotiz**, aus der ein Mensch `children.class_id` setzt" als Sollstand — und dieselbe Datei
streicht in Zeile 20-24 und 44-45 genau diese Wunschnotiz („Die Ansicht zeigt ihn deshalb nicht"). Der Satz
ist wörtlich richtig zitiert und als Beleg trotzdem falsch. Mitgezogen wurde grenzkarte.md dabei
nicht: Zeile 330 verlangt weiter „es ist ein Freitextfeld an der Bewerbung", Zeile 331 die
Wunschnotiz in der Ansicht — die Nachzieh-Liste aus `CLAUDE.md` („… → grenzkarte.md") ist offen.
Vorschlag: grenzkarte.md 330/331 auf den Stand von Block 15 bringen, das Zitat im Schema hinter
„Datendomäne" enden lassen.
```

```
[KLASSENBILDUNG-F3] klassenbildung · Klasse 1 · klassenbildung-schema.sql:26-32
15, „Was dabei erhoben wird": „Je Kind seine Klasse (**Pflicht**, sobald beide Bedingungen erfüllt
sind)". Gebaut sind allein die beiden Bedingungen (`ck_children_class_needs_entry`,
`fk_children_class`); die Pflicht selbst hat weder Constraint noch begründete Auslassung — und das in
einer Datei, die vier andere Auslassungen ausdrücklich aufzählt. Ausdrückbar ist sie nicht (die
zweite Bedingung ist eine Existenzfrage über `classes`), und 15 sagt zugleich „Ein Kind ohne Klasse
ist kein Fehler".
Vorschlag: fünfter Punkt in der „bewusst keine Spalte"-Liste — die Pflicht ist eine Ansicht, kein
Constraint, weil „es gibt eine Klasse, in die es passt" zeilenübergreifend ist.
```

```
[KLASSENBILDUNG-F4] klassenbildung · Klasse 5 · klassenbildung-schema-check.sql:57-65
Die Probe auf `applications.class_placement_wish` ist rein negativ und läuft ins Leere, wenn
`applications` fehlt — sie meldet dann „ok", ohne etwas gesehen zu haben. Der Dateikopf nennt
`anmeldung-schema.sql` als Voraussetzung, das Skript prüft sie aber nirgends nach; für `classes`,
`children` und `persons` belegen die positiven Spaltenproben davor die Existenz, für `applications`
nichts.
Vorschlag: vor der Negativprobe ein `to_regclass('public.applications') IS NULL` → `RAISE EXCEPTION`.
```

```
[KLASSENBILDUNG-F5] klassenbildung · Klasse 1 · klassenbildung-schema.sql:32-45
15, Sonderfälle: „Wird eine Stufe geteilt oder **zusammengelegt**, legt die Schulleitung einen Zug an
oder **lässt ihn auslaufen** und setzt die betroffenen Kinder um". Für das Anlegen gibt es einen Weg,
für das Auslaufenlassen keinen: `classes` trägt kein `is_active`, und der einzige gebaute Ausgang ist
die gerechnete Stufe über `final_grade_level` — die trifft den geleerten Zug erst Jahre später. Bis
dahin steht er in jedem Auswahlfeld seiner Stufe.
Vorschlag: entweder `classes.is_active` wie bei den elf Wertelisten derselben Datei, oder ein Satz an
der Tabelle, dass ein leerer Zug bewusst stehenbleibt und die Ansicht ihn ausblendet.
```

```
[KLASSENBILDUNG-F6] klassenbildung · Klasse 1 · klassenbildung-schema.sql:26-27
„Was die Domäne schreibt, ist eine einzige Spalte: `children.class_id`". 15, Ablauf Schritt 1, gibt
derselben Schulleitung im selben Block das Anlegen der Klassen: „Je Klasse Schulart, Startschuljahr
und Zug …, die Klassenlehrkraft und der Raum". Das sind fünf weitere geschriebene Spalten, alle an
`classes`. Die Aussage folgt der Tabellenzeile in grenzkarte.md („Schreibt Stammdaten: ja
(`children.class_id`)"), und die ist gegen Block 15 zu schmal.
Vorschlag: Satz auf „schreibt `children.class_id` und legt die `classes`-Zeile an (15, Schritt 1)"
erweitern — sonst plant `api-planen.md` für 12 nur ein PATCH auf das Kind.
```

## Angesehen, nicht als Fund gewertet

```
klassenbildung · `classes.class_teacher_id` ist nullable, 15 sagt „Pflicht" — begründete
        Auslassung an der Spalte (Vollimport legt die Klassen aus der rückgerechneten
        Kohorten-Kennung an, bevor jemand zuordnet), gedeckt von soll-prozesse/README.md:87.
klassenbildung · „in welcher Klasse jedes Kind sitzt **und seit wann**" (15, Schritt 2) ohne eigene
        Spalte — `change_log` trägt es generisch über (table_name, row_id, column_name), das Schema
        verweist korrekt darauf.
klassenbildung · Beide `expect_reject`-Proben einzeln nachgestellt: die erste scheitert an
        `ck_children_class_needs_entry`, die zweite an `fk_children_class` — beide aus dem Grund,
        den sie belegen sollen, keine an einem `NOT NULL` vorbei.
klassenbildung · Alle vier `expect_accept`-Proben treffen genau eine Zeile (`UPDATE 1`), keine läuft
        ins Leere.
klassenbildung · Die Probe „keine eigenen Tabellen" prüft vier fest verdrahtete Namen
        (`class_formations`, `class_placement_wishes`, `class_capacities`, `grade_levels`), von denen
        keiner je existierte. Sie belegt nichts, was der Datei nicht ohnehin anzusehen ist — schadet
        aber auch nicht und ist kein eigener Fund neben F4.
klassenbildung · Zweig einer besetzten Klasse umgehängt: `fk_children_class` weist es ab („Key
        (class_id, school_branch_id)=(5,1) is still referenced") — der Kennungsteil, der ein Kind in
        die falsche Schulart trüge, ist als einziger gehalten.
klassenbildung · Wiederholer mit Stufe ≠ Kohorte der Klasse, Kind in einer ausgelaufenen Klasse,
        abgegangenes Kind mit Klasse: alle drei durchgelassen — so will es 15 („steht sichtbar ohne
        passende Klasse … gesperrt wird nichts", „fällt ohne Zutun heraus").
klassenbildung · Dieselbe Lehrkraft in zwei Klassen: durchgelassen, kein `UNIQUE` daneben (15:
        „dieselbe Lehrkraft darf mehrere Klassen führen").
klassenbildung · Zwillinge derselben Familie in zwei Zügen: durchgelassen — die Zuordnung hängt am
        Kind (15, Beteiligte).
klassenbildung · „eine noch offene [Aufgabe] wird ersetzt statt verdoppelt" (15, Schritt 3) — trägt
        `ix_sync_tasks_open_child` in querschnitt-schema.sql, einmal für alle Domänen; kein Nachbau
        hier.
klassenbildung · `classes` ohne Löschanker, obwohl `class_teacher_id` auf eine Person zeigt —
        `fk_classes_teacher … ON DELETE SET NULL` löst es, die Klasse bleibt ohne Personenbezug
        stehen (15, „tragen für sich keine Personendaten").
klassenbildung · „Die heutige Liste … verlangt fünf Angaben" gegen grenzkartes Aufzählung von vier —
        gedeckt durch den zitierten Satz selbst (Geschlecht, Wohnort, Geschwister, Wunschnotiz plus
        Klassenlehrer:in).
```

## `[A!]` dieser Domäne

Keine. `klassenbildung-schema.sql` und ihr Prüfskript tragen weder `[A]` noch `[A!]` noch `[?]`.

## Ergebnis

Nicht ohne Fund durchgekommen: sechs Funde, davon einer (F1) mit Wirkung im Betrieb. Das Prüfskript
läuft grün (rc=0) und bleibt auch gegen die vollständige Datenbank grün.
