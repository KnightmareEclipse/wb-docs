# Prüfbericht — Stammdaten

Geprüft: `schema/stammdaten-schema.sql` samt `schema/stammdaten-schema-check.sql` gegen
`soll-prozesse/00, 02, 03, 04, 05, 06, 08, 13, 15, 22`, `hebel.md`, `rules.md` (1, 3, 7) und
`grenzkarte.md`.

**Lauf:** alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere Datenbank —
Rückgabewert **0** je Datei. `stammdaten-schema-check.sql` gegen diese vollständige Datenbank —
Rückgabewert **0**, 105 Gegenproben grün.

## Funde

```
[STAMMDATEN-F1] stammdaten · Klasse 1 · alumni
22 sagt „**Eltern tragen keinen Jahrgang:** … eine Zahl, die nichts benennt, ist
schlechter als keine", und `alumni_kinds.requires_exit_year` nennt das „**Falsch beim
Elternteil**" (Zeile 948–952). `ck_alumni_exit_year` (Zeile 1004) prüft aber nur die eine
Richtung — `NOT requires_exit_year OR exit_year IS NOT NULL`. Nachgestellt: eine
`former_guardian`-Zeile mit `requires_exit_year = false` und `exit_year = 2010` läuft durch.
Vorschlag: aus dem CHECK eine Gleichheit machen — `requires_exit_year = (exit_year IS NOT NULL)`.
```

```
[STAMMDATEN-F2] stammdaten · Klasse 1 · alumni
22 gibt den Schulzweig allein dem Kind („beim Kind mit dem Schulzweig"), und der Kommentar an
`alumni.school_branch_id` behauptet dasselbe: „Leer beim Elternteil und beim Mitarbeitenden, die
keinem Zweig angehören" (Zeile 982–983). Kein Constraint hält das; nachgestellt: eine
`former_guardian`-Zeile mit Zweig `GS` läuft durch. Das `[A]` daneben deckt es nicht — es
entscheidet, dass der Zweig **nicht Pflicht** wird, nicht, dass er erlaubt ist, wo er nichts benennt.
Vorschlag: ein zweites mitgeführtes Flag an `alumni_kinds` wie bei `requires_exit_year`, oder ein
CHECK gegen den Code der Art.
```

```
[STAMMDATEN-F3] stammdaten · Klasse 5 · vier Regeln ohne Gegenprobe
„Eine Regel ohne Gegenprobe gilt als nicht gebaut" (CLAUDE.md). Ohne Probe im Prüfskript stehen
`ck_sepa_mandates_iban` (Zeile 828 — die einzige Formatregel auf dem Zahlweg),
`uq_children_person` (592), `uq_employees_work_email` (894 — `uq_employees_entra` daneben hat eine)
und `ck_alumni_kinds_created_by` (964, das als einziges `created_by` dieser Datei `guardian:`
ausschließt).
Vorschlag: je eine `expect_reject`-Probe, die IBAN-Müll, ein zweites Kind an derselben Person, eine
doppelte Dienstadresse und eine von `guardian:` angelegte Artzeile abweist.
```

```
[STAMMDATEN-F7] stammdaten · Klasse 1 · family_guardians
Der Kommentar an `include_in_correspondence` (Zeile 693–696) entscheidet die Wirkung des Häkchens
selbst — „dieses Häkchen nur die Post. Wer beides hat, bekommt nichts". 06 und 09 erheben nur „wer
in Briefe einzubeziehen ist" und verweisen fürs Ändern auf 02, dessen „Was dabei erhoben wird" die
Angabe gar nicht führt; die Standardantwort in `hebel.md` nennt für Mail allein die Einsichtsstufe
als Ausschluss. Ob das Häkchen auch Mail abschaltet, entscheidet damit kein Block.
Vorschlag: die Frage an 02 stellen (`[?]` Sekretariat), bis dahin im Kommentar auf Papierpost
begrenzen statt auf „die Post".
```

```
[STAMMDATEN-F4] stammdaten · Klasse 7 · grenzkarte.md nicht nachgezogen
Die Stammdaten-Zeile der Domänentabelle (`grenzkarte.md:247`) zählt „Anmeldecode, 11 Lookups"; das
Schema hat 13 Wertelisten und trägt zusätzlich `alumni`, `alumni_kinds` und `login_sessions`. Die
Ehemaligen (22) kommen in `grenzkarte.md` als Entität überhaupt nicht vor. Das Schema hat recht — 22
ist ein Block und schlägt die Karte —, aber die Nachziehliste aus `CLAUDE.md` endet bei
`grenzkarte.md`, und dort steht der alte Stand.
Vorschlag: die Zeile auf 13 Lookups setzen und `alumni`/`login_sessions` aufnehmen.
```

```
[STAMMDATEN-F5] stammdaten · Klasse 3 · stammdaten-schema-check.sql
Zeile 971–972 zitiert als 08: „Löschanker: geht mit dem Kind, aber erst nach der
Aufbewahrungsfrist für Zahlungsdaten". Der Satz steht in keiner `.md` des Repos; 08 („das SEPA-Mandat
**zwei** [Jahre nach dem Austritt]") und 03 sagen es anders, und die `.sql` selbst sagt es auch anders
(Zeile 743–747). Das Zitat ist ein stehengebliebener älterer Kommentar.
Vorschlag: durch den Wortlaut aus 08/03 ersetzen — „das SEPA-Mandat zwei Jahre nach dem Austritt".
```

```
[STAMMDATEN-F6] stammdaten · Klasse 3 · Kopf der Wertelisten
Der Kommentar an `salutations` (Zeile 29–30) sagt: „die **drei** Listen mit Regelwirkung tragen sie
[die Audit-Spalten] unten selbst". Es sind vier — `school_branches`, `houses`, `roles` und seit den
Ehemaligen `alumni_kinds` (Zeile 953–954).
Vorschlag: „drei" durch „vier" ersetzen, oder die Zahl weglassen.
```

**Nach Gewicht:** `[STAMMDATEN-F1]`, `[STAMMDATEN-F2]`, `[STAMMDATEN-F3]`, `[STAMMDATEN-F7]`,
`[STAMMDATEN-F4]`, `[STAMMDATEN-F5]`, `[STAMMDATEN-F6]`.

## Angesehen, nicht als Fund gewertet

```
stammdaten · Die vier SEPA-Gegenproben ab Zeile 614 setzen ein zweites Mandat an ein Kind, das
        schon ein gültiges trägt — sie könnten alle an `ix_sepa_mandates_current` scheitern statt
        an ihrer Regel. Einzeln abgesetzt: `ck_sepa_mandates_holder` (zweimal),
        `ck_sepa_mandates_bic` und `uq_sepa_mandates_reference` schlagen zu, der partielle Index
        nie. Postgres prüft CHECK vor dem Index, und die Referenz vor dem später angelegten.
stammdaten · „15 — Klasse ohne Einschreibung" (Zeile 253) lässt `school_branch_id` weg und könnte
        deshalb am Fremdschlüssel statt am CHECK scheitern. Einzeln abgesetzt:
        `ck_children_class_needs_entry`. Der zusammengesetzte FK ist MATCH SIMPLE und greift bei
        einem NULL-Anteil nicht.
stammdaten · Der Löschanker jeder Tabelle dieser Datei trägt: von den 72 Fremdschlüsseln auf
        `persons`, `children`, `families`, `employees`, `classes` und `addresses` hält keiner mit
        NO ACTION fest, was der Lauf aus `querschnitt-schema.sql` in seiner Stufe nicht schon
        geräumt hätte — `employees` (Stufe 5) wird ausschließlich per CASCADE und SET NULL
        gehalten, `addresses` von genau den zwei Vorwärtsreferenzen, die Stufe 7 nennt.
stammdaten · `employee_roles` hat kein Entzugsdatum, obwohl 00 „wer sie wann vergeben oder
        entzogen hat" verlangt. `change_log.operation` ('insert'/'delete') trägt genau das
        (`querschnitt-schema.sql:1862`), samt `changed_by` — der Kommentar dort nennt 00 wörtlich.
stammdaten · 02 verlangt bei einer Rechteänderung „dass ein Nachweis vorlag und wer ihn gesehen
        hat"; das steht nicht an `family_guardians`, sondern als `change_log.proof_seen_at`.
stammdaten · 05 verlangt bei jedem Grundschulziel zusätzlich die örtlich zuständige Schule neben
        der abgebenden — `children.previous_school_id` ist nur eine Spalte. Die zweite steht als
        `applications.local_school_id` (anmeldung-schema.sql:693) auf derselben Werteliste.
stammdaten · 22 verlangt „dass gefragt wurde — und bei wem, damit niemand zweimal gefragt wird";
        `alumni` entsteht erst mit dem Ja. Die Frage selbst ist eine Mail und steht mit
        `person_id`, `purpose` und `sent_at` in `outbound_emails`.
stammdaten · Der Kopf des Prüfskripts zitiert „alle Dokumente, unter denen unterschrieben wird,
        müssen eine Prüfsumme haben" (Geschäftsführung, 04.09.2026). Der Wortlaut steht nicht in
        `grenzkarte.md`, wohl aber wörtlich in `backlog/tasks/task-247`.
stammdaten · `login_codes.purpose` ist eine CHECK-Liste und keine Werteliste — die Ausnahme aus
        `rules.md` Abschnitt 3 greift, weil der Wert entscheidet, ob `person_id` Pflicht ist
        (`ck_login_codes_person`). Der Kommentar beruft sich nur nicht darauf, anders als
        `access_levels` daneben, das die umgekehrte Wahl ausführlich begründet.
stammdaten · `children.congregation` ist Freitext statt Werteliste. `rules.md` Abschnitt 3 lässt
        das zu, solange niemand danach gruppiert — und ein Zweck für das Feld steht gerade aus
        (`[?]`, Zeile 1224).
stammdaten · `employees.work_email` ist nullable, obwohl 13 „die Schuladresse (Pflicht, vom Admin)"
        sagt. 13 verlangt zugleich, dass am leeren Feld ablesbar ist, „dass ihr Konto noch fehlt" —
        die Auslassung steht begründet an der Spalte.
```

## Die Marken dieser Domäne

- `[A!]` Zeile 15 — kein `updated_at`/`updated_by` auf irgendeiner Tabelle. **Kein Block entscheidet
  das**; `hebel.md` („Änderungsspur") verlangt nur wer, wann und was vorher dastand, und das trägt
  `change_log`. Die Annahme trägt.
- `[A!]` Zeile 761 — `sepa_mandates` als eigene Tabelle mit Historie, ohne Zahler-Entität. **Ein Block
  entscheidet es, und zwar so:** 08, „Das abgelöste Mandat bleibt mit seinem Unterschriftsdatum
  stehen"; `grenzkarte.md` („Freeze der Stammdaten") trägt die Umstellung ausdrücklich nach.
- `[A!]` Zeile 1093 — `login_codes` bekommt eine Tabelle in Stammdaten. **Kein Block entscheidet den
  Ort**; `hebel.md` verlangt nur Ratelimit und fünf Fehleingaben, und die brauchen eine Zeile. Die
  Annahme trägt.

**Stammdaten ist nicht ohne Fund durchgekommen: sieben, davon zwei, die falsche Daten durchlassen.**
