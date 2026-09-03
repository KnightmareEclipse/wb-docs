# Prüfbericht — Domäne klassenorganisation

Eigener Bericht neben `pruefberichte/aktuell.md`; die Nummern zählen dort weiter, weil beide
Berichte gleichzeitig im Baum liegen und ein `[F]` sonst zweimal vorkäme.

Gelesen: `soll-prozesse/hebel.md`, `rules.md` §1/§3/§7, `grenzkarte.md`, dann
`schema/klassenorganisation-schema.sql` samt `-check.sql`, danach Block 15 und Block 16; zum
Abgleich Block 14, `stammdaten-schema.sql`, `elternbonus-schema.sql`, `api/klassenorganisation-api.md`
und die Tickets TASK-161 und TASK-218.

Lauf: alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere Datenbank,
`rc=0` je Datei; danach alle vierzehn `*-schema-check.sql` gegen die vollständige Datenbank,
`rc=0` je Skript. Die Funde stammen aus eigenen `INSERT`s gegen dieselbe Datenbank.

## klassenorganisation

### Funde

```
[F23] klassenorganisation · Klasse 3 · Dateikopf, elective_modules, elective_groups,
      child_group_memberships, class_teaching_assignments
Die vier Tabellen der zweiten Achse tragen als Herkunft „grenzkarte.md, ‚Zugriff, je Angabe' —
‚Welche Kinder jemand sieht, ist die zweite Achse …: Sie folgt aus Stammklasse, Wahlmodul, AG oder
der Begleitung einer Veranstaltung.'" Der Abschnitt heißt dort „Zugriff, drei Bedingungen", der
Satz steht in keiner Datei dieses Repos, und sein Inhalt sagt das Gegenteil der genannten Quelle:
Die trägt „AG und Veranstaltungsbegleitung bekommen dafür keine eigene Kindermenge — die Anmeldung
dort ist sie." Vier Tabellen begründen sich damit aus einem Satz, der die Grenze weiter zieht als
die Karte, auf die er zeigt.
Vorschlag: den Bullet „Von welchen Kindern?" aus grenzkarte.md wörtlich zitieren und den
Abschnittsnamen berichtigen.
```

```
[F24] klassenorganisation · Klasse 1 · child_group_memberships
Der ganze Zweck dieser Datei ist, „wer diese Kinder sieht" eng zu halten — „achtzig statt der
fünfzehn, die sie unterrichtet". Die Mitgliedschaft ist aber an nichts gebunden: Ein
Grundschulkind der Kohorte 2026 wird Mitglied einer Realschul-Technikgruppe der Kohorte 2023
(eigener INSERT, angenommen), und die Gruppenlehrkraft sieht danach ein Kind, das sie nie
unterrichtet. Weder Schulart noch Kohorte werden geprüft, und kein Kommentar sagt, wer es prüft.
Vorschlag: `school_branch_id` an der Mitgliedschaft mitführen und über ein neues
`uq_children_id_branch` an beide Seiten binden — wie `classes.school_branch_id` (rules.md §1) —,
oder einen Satz, der die Prüfung der Route zuweist.
```

```
[F25] klassenorganisation · Klasse 1 · class_representatives.person_id
Der Spaltenkommentar sagt „Eine sorgeberechtigte Person aus dem Bestand, ausgewählt und nicht
eingetippt" und benennt danach nur die *andere* bewusst fehlende Prüfung. Durch geht jede Person:
eine Lehrkraft und sogar ein Kind (zwei eigene INSERTs, beide angenommen). 16 gibt dem Amt genau
eine Wirkung — „14 erlässt der Familie jedes Amtsträgers die vollen Mitarbeitsstunden" —, und die
findet über die Person ihre Familie oder eben keine. `api/klassenorganisation-api.md` benennt die
Lücke bereits und weist sie der Route zu; die `.sql` behauptet daneben die Eigenschaft, die sie
nicht trägt.
Vorschlag: den Kommentar auf den Stand der API-Datei bringen — Prüfung gegen `family_guardians`,
kein Constraint —, oder den Fremdschlüssel auf `guardians` (dort steht `uq_guardians_person`) legen.
```

```
[F26] klassenorganisation · Klasse 1 · die `[?]` am Dateiende
Sie fragt, „wer die Unterrichtsverteilung und die Wahlmodulgruppen pflegt", nennt die Schulleitung
je Schulart als Annahme und schließt mit „Ungeprüft". Block 15 entscheidet jeden Teil davon
wörtlich: „Die Schulleitung ihrer Schulform … pflegt Unterrichtsverteilung, Unterrichtsende und
Wahlmodulgruppen; das Sekretariat darf dasselbe", dazu „je Schuljahr nachgezogen" und „von Hand
gepflegt, nicht aus ASV-BW oder dem Deputatsplan übernommen". Der Block ist jünger als die Datei.
`api/klassenorganisation-api.md` trägt die Frage weiter und hängt die Rechte des ganzen Durchgangs
an ihr auf.
Vorschlag: die `[?]` streichen und in beiden Dateien durch den Satz aus Block 15 ersetzen.
```

```
[F27] klassenorganisation · Klasse 5 · klassenorganisation-schema-check.sql
Die Probe „ein Kind in einer Gruppe und ein Kind in zweien" belegt den Fall nicht, den sie meint:
Beide Gruppen sind desselben Moduls (`Technik 8 · A` und `· B`, beide `elective_module_id = 1`).
Ein Kind in zwei Technikgruppen ist gerade der Fall, den 15 ausschließt — „Technik, AES und
Französisch werden einmal gewählt" —, und der Nachweis für „ein Kind in zwei *Modulen*" fehlt
damit. Verhindert wird der falsche Fall auch von keinem Constraint.
Vorschlag: die zweite Mitgliedschaft an eine Gruppe eines anderen Moduls hängen und, wenn die
Einmalwahl je Modul gelten soll, sie als partiellen Unique-Index dazu bauen.
```

```
[F28] klassenorganisation · Klasse 3 · class_end_times
Der Tabellenkopf zitiert „15 (Klassenbildung) — ‚Je Klasse und Schuljahr, an welchem Wochentag der
Unterricht wann endet'". Der Satz steht weder in Block 15 noch sonst im Repo. Der Block sagt „Das
Unterrichtsende je Wochentag (Uhrzeit, Pflicht, sobald es feststeht)" und in Z1 „wann sie an
welchem Wochentag Unterrichtsende hat"; das Schuljahr folgt dort aus „drei Dinge, die je Schuljahr
nachgezogen werden". Die Struktur stimmt, die Belegstelle ist erfunden.
Vorschlag: die beiden echten Sätze zitieren.
```

```
[F29] klassenorganisation · Klasse 6 · grenzkarte.md, Absatz „Elternvertretung (13)"
Dort steht weiterhin „Je Klasse gibt es Elternvertreter:in und Stellvertretung" und „Ohne
Schuljahres-Historie … trägt sie immer nur den aktuellen Stand, was hier genügt". Gebaut ist das
Gegenteil, und zu Recht: 16 verlangt „Je Klasse und Schuljahr die gewählten Personen … mehrere ohne
Rangfolge" und schließt einen Amtstitel aus, 14 braucht das Schuljahr, um zu wissen, für welches es
erlässt. Die Tabellenzeile derselben Datei ist auf Stand, der Absatz nicht — die Mitzieh-Liste aus
CLAUDE.md endet bei `grenzkarte.md`.
Vorschlag: den Absatz auf Schuljahr und „mehrere ohne Rangfolge" nachziehen.
```

```
[F30] klassenorganisation · Klasse 1 · Block 15, fremde Datei soll-prozesse/15
Der Block sagt beides über die Wahlmodulgruppe: in Z1 gehört sie zu den „drei Dinge[n], die je
Schuljahr nachgezogen werden", im Abschnitt „Was dabei erhoben wird" heißt es „die Gruppe lebt
deshalb so lange wie die Kohorte und trägt kein Schuljahr". Das Schema folgt dem zweiten und
verbietet die Spalte sogar im Prüfskript; dass der Block sich widerspricht, hält keine Datei fest.
Vorschlag: Z1 auf die spätere Stelle bringen — die Gruppe wird je Kohorte gepflegt, nicht je
Schuljahr (Sitzung 1, ihr gehört Block 15).
```

```
[F31] klassenorganisation · Klasse 1 · elective_modules.code, .name
Beide sind `NOT NULL` ohne Leerstring-CHECK; ein Modul mit leerem Code und leerem Namen geht durch
(eigener INSERT, angenommen). Die Nachbartabelle trägt `ck_elective_groups_label`, und jede
vergleichbare Werteliste des Repos prüft beide Spalten.
Vorschlag: `ck_elective_modules_code` und `ck_elective_modules_name` nachziehen.
```

### Angesehen, nicht als Fund gewertet

```
klassenorganisation · `school_year` an Elternvertretung und Unterrichtsverteilung ist an nichts
        gebunden — 1800 geht durch; `api/klassenorganisation-api.md` benennt die Lücke bereits, und
        `classes.start_school_year` trägt dieselbe Freiheit.
klassenorganisation · „Drei Zeilen — Technik, AES, Französisch" liest sich wie ein Bestand, den die
        Datei anlegt; keine `-schema.sql` dieses Repos legt Wertelistenzeilen an, das Prüfskript
        füllt sie.
klassenorganisation · Der Löschanker der Unterrichtsverteilung („geht mit dem Mitarbeitendeneintrag,
        also mit `employees.last_working_day`") trägt — `employees` nennt genau diesen Anker, und
        der Cascade ist im Prüfskript belegt.
klassenorganisation · Eine Zuordnung überlebt den Austritt ihrer Lehrkraft (Austritt 2020, neue
        Zeile für 2026 angenommen); das ist keine Lücke, sondern die Regel der Grenzkarte — gegen
        welchen Stichtag geprüft wird, entscheidet der fragende Prozess.
klassenorganisation · Eine Gruppe darf eine Kohorte tragen, in der ihre Schulart keine Klasse hat;
        daran hängt nichts, und „eine noch leere Gruppe hat ein Zuhause" ist der ausgeschriebene
        Zweck der Spalte.
klassenorganisation · Das Prüfskript zitiert einmal die eigene `.sql` („Die Gruppe steht still, wenn
        ihre Lehrkraft geht") statt eines Blocks — die Aussage stimmt, ein Beleg ist sie nicht.
klassenorganisation · `class_end_times` ohne Ankunftszeit, Fach, Stunde und Raum: begründet und mit
        einer eigenen Gegenprobe belegt, ebenso der Samstag.
klassenorganisation · Die Klasse als Einheit, auch wo der Förderunterricht feiner wäre: von Block 15
        ausdrücklich entschieden, samt Fehlerrichtung und Preis.
```

### `[A!]` in dieser Domäne

- klassenorganisation · „Die Werteliste der Wahlmodule steht hier und nicht in `stammdaten`"
  (Dateikopf) — kein Block entscheidet, in welcher Datei eine Werteliste liegt; der Schnitt trägt
  sich selbst, und der genannte Preis (Stammdaten-Freeze gegen eine mit jeder Kohorte wachsende
  Struktur) hält.

### Offene Marken

`[?]` Wer die Unterrichtsverteilung und die Wahlmodulgruppen pflegt — Adressat: die Schulleitung je
Schulart. Sie ist der Gegenstand von [F26]: Block 15 beantwortet sie bereits.

### Sortierung nach Gewicht

F23, F24 und F25 gehen an die Sichtbarkeit selbst — eine erfundene Begründung, eine ungebundene
Mitgliedschaft, ein Amt ohne Sorgeberechtigung. F26 und F27 halten Entschiedenes offen bzw. belegen
das Falsche. F28 bis F31 sind Zitat, Karte, Blockwiderspruch und ein fehlender CHECK.

Ohne Fund durchgekommen: keine — geprüft wurde allein `klassenorganisation`.
