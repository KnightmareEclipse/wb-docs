# Prüfbericht — Schema, Lauf vom 03.09.2026

Geprüft: `klassenorganisation` und `gesundheit`, nach `prompts/schema-pruefen.md`.
Dieser Lauf hat nichts geändert außer dieser Datei.

## Lauf

- Ladelauf aller vierzehn `*-schema.sql` in eine leere PostgreSQL-18-Datenbank, in der
  dokumentierten Reihenfolge: **rc=0 je Datei**.
- Alle vierzehn `*-schema-check.sql` gegen die **vollständige** Datenbank: **rc=0 je Datei**.
- Danach eigene `INSERT`s und `DELETE`s gegen das Schema, dazu eine instrumentierte Fassung beider
  Prüfskripte, die aus jeder `expect_reject`-Probe den tatsächlich greifenden Constraint-Namen
  ausliest (`GET STACKED DIAGNOSTICS`). Jeder Fund unten mit „belegt" ist so entstanden.

**Hinweis:** Während des Laufs hat eine parallele Sitzung `klassenorganisation-schema.sql` und ihr
Prüfskript geändert; **[F3] und [F5] sind darin bereits überarbeitet**. Sie stehen hier trotzdem,
weil der Bericht den Fund und nicht den Stand trägt.

---

## Funde, nach Gewicht

```
[F6] gesundheit · Klasse 4 · child_health_records, measles_proofs, health_emergency_accesses
Der Bestand hat keinen eigenen Löschtermin und keine eigene Stufe im Lösch-Lauf:
Er hängt allein per `ON DELETE CASCADE` an `children`, und `querschnitt-schema.sql`
nennt in Stufe 1 nur `health_trait_values`, den Bestand erst in Stufe 2 „per
Cascade mit — ohne dass der Lauf sie einzeln sieht". `children` hält aber der
Vertrag fest (`fk_contracts_child`, NO ACTION), und der „bleibt fünf Jahre nach
dem Austritt" (03). Die vom Datenschutzbeauftragten gesetzten **drei Monate nach
dem Austritt** (verarbeitungsverzeichnis.md, Zeile 94, verweist auf genau diese
Datei) treffen damit allein die Wertzeilen. Stehen bleiben: `action_note` — der
Freitext-Hinweis der Klassenlehrkraft —, je Kategorie die Tatsache „beantwortet"
samt Zahl der Merkmalszeilen darunter, der Masernnachweis (Impfstatus) und das
Notfallprotokoll. Belegt: Kind mit Vertrag lässt sich nicht löschen, der Bestand
steht; `DELETE FROM child_health_records` allein geht und räumt vier Ebenen.
Vorschlag: `child_health_records` als eigene Zeile in Stufe 1 der Reihenfolge,
mit dem Anker Austritt + 3 Monate.
```

```
[F7] gesundheit · Klasse 4 · fk_child_health_records_child
`ON DELETE CASCADE` — dieselbe Stelle, an der `ferien-schema.sql` NO ACTION setzt
und den Grund ausschreibt: „Eine Cascade nähme die angehaltene Zeile mit dem Kind
mit, ohne dass der Lauf sie sieht — genau das darf ein Anhalten nicht zulassen."
hebel.md nennt den Gesundheitsbestand am Kind ausdrücklich unter den Beständen mit
Löschankündigung und Anhalten (Empfänger: Sekretariat und Schul- bzw.
Hortleitung). Ein angehaltener Bestand überlebt sein Anhalten hier nicht.
Vorschlag: NO ACTION wie bei `holiday_care_notes`, sobald F6 dem Bestand seine
eigene Stufe gibt.
```

```
[F8] gesundheit · Klasse 1 · health_trait_releases.delete_on
Block 19: „Für die Angaben, die über diese Fahrt hereinkommen, gilt eine eigene
Aufbewahrung, gerechnet ab dem Ende der Fahrt … vier Wochen für die
Gesundheitsangaben." `delete_on` ist leerbar, und nichts unterscheidet eine
Anlass-Instanz von `school`/`care`: Eine Freigabe an die Fahrt ohne Löschtermin
wird angenommen (belegt) und ist von einer dauerhaften nicht zu unterscheiden;
der Lösch-Lauf findet sie über `ix_health_trait_releases_delete_on` nie.
Die Datei trägt das Muster dafür bereits dreimal — `needs_release`, `is_emergency`,
`is_answered` als mitgeführtes Flag mit zusammengesetztem Fremdschlüssel.
Vorschlag: ein `is_temporary` an `health_visibility_scopes`, mitgeführt an der
Freigabe, plus CHECK „temporär ⇒ delete_on gesetzt".
```

```
[F2] klassenorganisation · Klasse 5 · klassenorganisation-schema-check.sql
Die Probe „Mitgliedschaft mit fremdem Modul eingetragen" (441 → Gruppe 3, Modul 1)
wird nicht von `fk_child_group_memberships_group` abgewiesen, sondern von
`uq_child_group_memberships_module` (belegt). Kind 441 hat Modul 1 zwei Proben
vorher bekommen; die Probe wiederholt damit „zweite Gruppe desselben Moduls", und
die Modul-Achse des zusammengesetzten Fremdschlüssels bleibt ohne Gegenprobe.
Vorschlag: 441 → Gruppe 3 mit `elective_module_id` 3 statt 1 — greift
nachweislich `fk_child_group_memberships_group`.
```

```
[F10] gesundheit · Klasse 5 · gesundheit-schema-check.sql
„TASK-206 — Sichtbarkeit mit falscher Wertart eingetragen" schreibt auf
Sichtkreis 5 (Notfall) und wird deshalb von `fk_health_field_visibility_scope`
abgewiesen (belegt), nie von `fk_health_field_visibility_kind`. Damit hat die
Regel „die Wertart kommt vom Feld und nicht vom Schreibenden" an dieser Tabelle
keine Gegenprobe; die Kontrollprobe (Sichtkreis 3, Feld 5 als `text`) greift den
richtigen Fremdschlüssel.
Vorschlag: Sichtkreis 3 statt 5 in derselben Probe.
```

```
[F11] gesundheit · Klasse 5 · gesundheit-schema-check.sql
„3a — Bezeichnung als Ja/Nein eingetragen" wird von `uq_health_trait_values`
abgewiesen (belegt): Merkmal 661 trägt Feld 1 schon aus der Probe darüber.
`fk_health_trait_values_kind` — der Fremdschlüssel, der „Kein Wert im falschen
Typ" hält — bleibt damit ungeprüft; die Kontrollprobe an einem frischen Merkmal
greift ihn.
Vorschlag: dieselbe Probe an einem Merkmal ohne Wert für dieses Feld.
```

```
[F9] gesundheit · Klasse 1 · health_visibility_scopes
Der Kommentar setzt „Der Anlass *ist* der Sichtkreis, an den freigegeben wird —
… befristet an die Instanz einer Veranstaltung". Block 19 sagt daneben: „Wer die
Angaben sehen darf, bestimmt die Lehrkraft — sie benennt Verantwortlichen und
Begleitperson, beides nur interne Mitarbeitende, dazu die Schulleitung." Sehen ist
in diesem Modell aber eine DB-Rolle auf einer Sicht je Sichtkreis
(`api/gesundheit-api.md`: „ein neuer Sichtkreis ist eine Zeile **und** eine
Sicht", Vergabe per GRANT) — eine je Fahrt benannte Person ist darin nicht
ausdrückbar, und jede Fahrt kostete eine Sicht und ein GRANT. Der Dateifuß nennt
als offen nur den Anlassgeber, nicht diesen Punkt.
Vorschlag: den Leserkreis der Anlass-Instanz als Zeilenmenge (Person × Instanz)
vorsehen, statt ihn dem GRANT zu überlassen — vor Domäne 19 zu entscheiden.
```

```
[F3] klassenorganisation · Klasse 1 · elective_groups.employee_id
Block 15: „Sie hat genau eine Lehrkraft, und an ihr — nicht am Modul — hängt, wer
diese Kinder sieht." Der Kommentar behauptete „Beim Anlegen ist sie Pflicht",
ohne dass ein Constraint, eine Probe oder eine Route sie trägt —
`api/klassenorganisation-api.md` sagt „Routen haben sie noch keine". Eine Gruppe
ganz ohne Lehrkraft geht durch (belegt).
Vorschlag: erledigt — die Fassung auf der Platte gibt die Pflicht ausdrücklich an
die Oberfläche ab.
```

```
[F4] klassenorganisation · Klasse 5 · class_teaching_assignments
Block 15: „Wer in ihr unterrichtet (je Schuljahr, mehrere Personen, ohne Fach)."
Das Prüfskript trägt genau eine Lehrkraft in genau eine Klasse ein; für „mehrere
Personen" gibt es keine `expect_accept`-Probe, obwohl `uq_class_teaching_assignments`
genau daran grenzt. Der eigene INSERT zeigt, dass die Regel hält.
Vorschlag: eine Accept-Probe „zwei Lehrkräfte in derselben Klasse und im selben
Jahr" neben die vorhandene Reject-Probe.
```

```
[F1] klassenorganisation · Klasse 3 · child_group_memberships
Der Kommentar an `uq_child_group_memberships_module` zitiert „damit beim
Eintragen die richtigen Gruppen zur Auswahl stehen" (15). Block 15 hat diesen Satz
nicht; er sagt nur „erst wenn jemand eine zweite anlegt, erscheint eine Auswahl".
Der zitierte Satz stammt aus dem Kommentar an `elective_groups.start_school_year`
derselben Datei — ein Selbstzitat mit Blockzuschreibung.
Vorschlag: Anführungszeichen und „(15)" streichen, der Satz trägt als eigene
Begründung.
```

```
[F12] gesundheit · Klasse 3 · child_health_answers, health_trait_values, health_emergency_accesses
Drei Kommentare berufen sich auf „das Gespräch mit der Geschäftsführung vom
01.09.2026", zwei davon wörtlich: „das sollte eine Taste sein bei dem Schüler,
wodurch jeder Mitarbeiter im Notfall nachschauen kann" und „bei chronischer
Krankheit angeben und selber entscheiden, wie tief". Beide Sätze stehen in keiner
Quelle des Repos — nicht in `pruefberichte/gespraech-geschaeftsfuehrung.md` (dem
Laufzettel dieses Termins), nicht in `backlog/`, nicht in der Git-Historie
außerhalb von `schema/`. Der Wortlaut ist damit nicht nachprüfbar; die Sache
selbst steht in TASK-205/206.
Vorschlag: die Sätze gegen die Ticketformulierung tauschen oder die
Anführungszeichen fallen lassen.
```

```
[F13] gesundheit · Klasse 3 · health_visibility_scopes.is_emergency
Zitiert wird „der Mitarbeitende sieht im Notfall alles, nicht nur einen
Ausschnitt" (02.09.2026). Die Auflage lautet in TASK-205 wörtlich „der
Mitarbeitende sieht im Notfall alles"; TASK-206 gibt den Datenschutzbeauftragten
mit „Mitarbeiter sieht alles" wieder. Die vier Wörter nach „alles" sind die
Deutung des Schemas und stehen mit im Zitat — dieselbe Formel auch im Prüfskript
(Zeile 689) und im Kommentar an `health_emergency_accesses`.
Vorschlag: das Zitat nach „alles" schließen, den Rest als eigenen Satz.
```

```
[F14] gesundheit · Klasse 3 · health_traits
Das Zitat aus Block 08 endet nach „ob die Schule handeln darf." — im Block folgt
dort ein Semikolon und „bei Medikamenten dazu, ob das Kind sie selbst nimmt". Die
abgeschnittene Hälfte ist selbst eine Zusage aus „Was dabei erhoben wird", und die
Herkunftszeile ist genau die Stelle, an der ein späterer Leser die Feldliste
nachschlägt. Strukturell fehlt nichts — das Feld ist eine `health_fields`-Zeile.
Vorschlag: den Halbsatz mitzitieren oder die Kürzung mit „…" kenntlich machen.
```

```
[F5] klassenorganisation · Klasse 3 · elective_groups (Kopfkommentar)
„gepflegt wird sie wie die Klasse selbst" — Block 15 sagt das Gegenteil: „Die
Wahlmodulgruppen pflegen zusätzlich die Klassenlehrkräfte", und die Fußzeile
derselben Datei schreibt es richtig.
Vorschlag: erledigt — der Halbsatz ist auf der Platte bereits fort.
```

---

## Angesehen, nicht als Fund gewertet

```
gesundheit · Die fünf mitgeführten Spalten (`is_answered`, `is_released`,
        `needs_release`, `is_emergency`, `allows_multiple`, dazu
        `health_trait_type_id`, `value_kind_code`, `child_health_record_id`) sahen
        nach rules.md §1 „ein Ort pro Sachverhalt" aus; jede hängt an einem
        zusammengesetzten Fremdschlüssel an ihrer Quelle — genau die
        ausgeschriebene Ausnahme.
gesundheit · Dass ein Widerruf der Instanz-Freigabe scheitert, solange
        Einzelfreigaben hängen, und dass eine Kategorie nicht nachträglich auf
        „will nicht sagen" geht, solange eine Angabe darunter steht: beides steht
        Block 08 „ändern die Eltern danach jederzeit" nicht entgegen — die Route
        schreibt die Kategorie am Stück (api/gesundheit-api.md).
gesundheit · `child_health_records` mit beiden Zeitpunkten leer ist erlaubt; das
        ist der Vollimport-Fall, den Block 08 ausschreibt.
gesundheit · „er gehört zu den Gesundheits- und Förderdaten mit deren
        Zugriffsprofil" lässt gegenüber grenzkarte.md ein „(Domäne 9)" ohne
        Auslassungszeichen fallen — eine Verweisklammer, kein Sinnunterschied.
gesundheit · Der Notfallausschnitt ohne Zeile in `health_field_visibility`:
        `ck_health_field_visibility_emergency` und der zusammengesetzte
        Fremdschlüssel weisen beide Wege ab, und das Prüfskript belegt beide.
gesundheit · Die Frist „vier Wochen nach dem letzten gebuchten Termin" für ein
        schulfremdes Kind steht in ferien-schema.sql und nicht hier — richtig, das
        Kind hat keinen Austritt.
klassenorganisation · `elective_groups.start_school_year` sah nach dem „trägt kein
        Schuljahr" aus Block 15 aus; gemeint ist dort das laufende Schuljahr, die
        Spalte trägt die Kohorte wie `classes.start_school_year`.
klassenorganisation · `ck_class_end_times_weekday BETWEEN 1 AND 5` verbietet
        Samstagsunterricht; kein Block erlaubt ihn, also keine Klasse 2.
klassenorganisation · Die Wahlmodule sind die Wahlpflichtfächer, die grenzkarte.md
        unter „Ebenfalls draußen" führt; Block 15 schreibt sie als Träger der
        Sichtbarkeit aus und schlägt die Karte.
klassenorganisation · `class_representatives` ohne Prüfung auf Sorgerecht: der
        Kommentar gibt sie an die Route ab, und api/klassenorganisation-api.md
        führt sie gegen `family_guardians` — dieser Verweis ist eingelöst.
klassenorganisation · Löschanker `employees.last_working_day`: kein RESTRICT im
        Weg, alle Verweise auf `employees` sind CASCADE oder SET NULL, der DELETE
        lief in der vollen Datenbank durch.
klassenorganisation · Die beiden `elective_groups`-Reject-Proben ohne eigene
        `elective_group_id` konnten am Identity-Zähler auf `pk_elective_groups`
        laufen; der instrumentierte Lauf zeigt `uq_elective_groups` und
        `ck_elective_groups_label`. Trägt.
```

## `[A!]`

```
klassenorganisation · „Die Werteliste der Wahlmodule steht hier und nicht in
        `stammdaten`." Kein Block entscheidet den Schnitt; Block 15 verlangt die
        Gruppe, sagt aber nichts über die Datei. Die Marke bleibt zu Recht offen.
gesundheit · keine.
```

## Ohne Fund durchgekommen

Keine der beiden Domänen. Beide Prüfskripte sind grün (rc=0) und beide tragen
einen Fund an einer Gegenprobe, die aus dem falschen Grund abgewiesen wird.
