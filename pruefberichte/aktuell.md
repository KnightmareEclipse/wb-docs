# Prüfbericht — Schema, Lauf vom 03.09.2026

Geprüft: `klassenorganisation`, `gesundheit`. Erzeugt nach `prompts/schema-pruefen.md`.
Der Lauf ändert nichts außer dieser Datei.

## Lauf

- Ladelauf aller vierzehn `*-schema.sql` in eine leere PostgreSQL-18-Datenbank, in der
  dokumentierten Reihenfolge: **rc=0 je Datei**.
- Alle vierzehn `*-schema-check.sql` gegen die **vollständige** Datenbank: **rc=0 je Datei**.
- Danach eigene `INSERT`s gegen das Schema und eine instrumentierte Fassung der beiden
  Prüfskripte, die den Constraint-Namen aus jeder `expect_reject`-Probe ausliest.

---

## klassenorganisation

```
[F1] klassenorganisation · Klasse 3 · child_group_memberships
`uq_child_group_memberships_module` trägt das Zitat „damit beim Eintragen die
richtigen Gruppen zur Auswahl stehen" (15); Block 15 hat diesen Satz nicht — er
sagt nur „erst wenn jemand eine zweite anlegt, erscheint eine Auswahl". Der Satz
stammt aus dem Kommentar an `elective_groups.start_school_year` derselben Datei:
ein Selbstzitat mit Blockzuschreibung.
Vorschlag: Anführungszeichen und „(15)" streichen, den Satz als eigene Begründung
stehen lassen.
```

```
[F2] klassenorganisation · Klasse 5 · klassenorganisation-schema-check.sql
Die Probe „Mitgliedschaft mit fremdem Modul eingetragen" (441 → Gruppe 3, Modul 1)
wird nicht von `fk_child_group_memberships_group` abgewiesen, sondern von
`uq_child_group_memberships_module` — belegt durch den ausgelesenen
Constraint-Namen. Kind 441 hat Modul 1 zwei Proben vorher schon bekommen; die
Probe wiederholt damit „zweite Gruppe desselben Moduls" und lässt die Modul-Achse
des zusammengesetzten Fremdschlüssels ohne Gegenprobe.
Vorschlag: 441 → Gruppe 3 mit `elective_module_id` 3 statt 1 (greift nachweislich
`fk_child_group_memberships_group`).
```

```
[F3] klassenorganisation · Klasse 1 · elective_groups.employee_id
Block 15: „Sie hat genau eine Lehrkraft, und an ihr — nicht am Modul — hängt, wer
diese Kinder sieht." Der Kommentar behauptet „Beim Anlegen ist sie Pflicht", aber
kein Constraint trägt das, das Prüfskript hat dafür keine Probe, und
`api/klassenorganisation-api.md` sagt ausdrücklich „Routen haben sie noch keine".
Eine Gruppe ganz ohne Lehrkraft geht durch (eigener INSERT, angenommen).
Vorschlag: entweder die Pflicht wie bei `class_representatives` an eine benannte
Route abgeben oder den Satz auf den Stand von `classes.class_teacher_id` bringen.
```

```
[F4] klassenorganisation · Klasse 5 · class_teaching_assignments
Block 15: „Wer in ihr unterrichtet (je Schuljahr, mehrere Personen, ohne Fach)."
Das Prüfskript trägt genau eine Lehrkraft in genau eine Klasse ein und hat keine
`expect_accept`-Probe für die zweite — die Regel, die `uq_class_teaching_assignments`
gegen eine Doppelbesetzung abgrenzt, ist damit nicht gebaut. Der eigene INSERT
zeigt, dass sie hält.
Vorschlag: eine `expect_accept`-Probe „zwei Lehrkräfte in derselben Klasse und im
selben Jahr" neben die vorhandene Reject-Probe.
```

```
[F5] klassenorganisation · Klasse 3 · elective_groups (Kopfkommentar)
„gepflegt wird sie wie die Klasse selbst" — Block 15 sagt das Gegenteil: „Die
Wahlmodulgruppen pflegen zusätzlich die Klassenlehrkräfte", und die Fußzeile
derselben Datei schreibt es richtig („Klassenlehrkraft, Sekretariat und
Schulleitung").
Vorschlag: den Halbsatz streichen, die Fußzeile trägt die Aussage bereits.
```

### Angesehen, nicht als Fund gewertet — klassenorganisation

```
klassenorganisation · `elective_groups.start_school_year` sah nach dem „trägt kein
        Schuljahr" aus Block 15 aus; gemeint ist dort das laufende Schuljahr, die
        Spalte trägt die Kohorte wie `classes.start_school_year`, und die Gruppe
        wird nie fortgeschrieben.
klassenorganisation · `ck_class_end_times_weekday BETWEEN 1 AND 5` verbietet
        Samstagsunterricht; kein Block erlaubt ihn, also keine Klasse 2.
klassenorganisation · Die Wahlmodule sind die Wahlpflichtfächer, die grenzkarte.md
        unter „Ebenfalls draußen" führt; Block 15 schreibt sie als Träger der
        Sichtbarkeit aus und schlägt die Karte (Rangfolge in CLAUDE.md).
klassenorganisation · `class_representatives` ohne Prüfung auf Sorgerecht: der
        Kommentar gibt die Prüfung an die Route ab, und
        `api/klassenorganisation-api.md` führt sie gegen `family_guardians` — der
        einzige der drei Verweise, der eingelöst ist.
klassenorganisation · Löschanker `employees.last_working_day` für
        `class_teaching_assignments`: kein RESTRICT im Weg, alle Verweise auf
        `employees` sind CASCADE oder SET NULL; der DELETE lief in der vollen
        Datenbank durch.
klassenorganisation · Löschanker „geht mit dem Kind" bzw. „verschwindet mit der
        Person": beide CASCADE, aber neun bzw. neun Fremdschlüssel auf `children`
        und `persons` stehen auf NO ACTION — der Lösch-Lauf muss die Fachdomänen
        vorher räumen. Das ist der in dsgvo.md beschriebene Ankerweg und kein
        blockierender Rest.
klassenorganisation · Die beiden `elective_groups`-Reject-Proben ohne eigene
        `elective_group_id` konnten am Identity-Zähler auf `pk_elective_groups`
        laufen statt auf ihren Constraint; der instrumentierte Lauf zeigt
        `uq_elective_groups` und `ck_elective_groups_label`. Trägt.
```
