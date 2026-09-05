# Prüflauf klassenorganisation

Gegen `schema/klassenorganisation-schema.sql` und `schema/klassenorganisation-schema-check.sql`,
Quellen `soll-prozesse/15-klassenbildung.md` und `soll-prozesse/16-elternvertretung.md`, dazu
`hebel.md`, `rules.md` §1/§3/§7 und `grenzkarte.md`.

Lauf: alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere Datenbank
(`wb-pruef-klassenorganisation`, PostgreSQL 18), jede rc=0. `klassenorganisation-schema-check.sql`
gegen die vollständige Datenbank: **rc=0**.

## Funde, nach Gewicht

```
[KLASSENORGANISATION-F1] klassenorganisation · Klasse 2 · child_group_memberships
04 sagt „Niemand löst den Lauf aus, niemand gibt ihn frei, niemand kann ihn aufhalten";
`fk_child_group_memberships_child` (child_id, school_branch_id) hält den Jahreslauf an,
sobald ein Kind mit Mitgliedschaft die Schulart wechselt — nachgestellt, der UPDATE auf
`children.school_branch_id` scheitert mit genau diesem Constraint. Der Kommentar
(Z. 141–145) nennt das „dieselbe Handreichung wie bei der Klassenzuordnung, die derselbe
Lauf leert" — die leert der Lauf aber selbst (`children.class_id`,
stammdaten-schema.sql), hier räumt niemand: 15 („am 1. August geschieht hier nichts") und
04 („Wer in welche Klasse kommt … : 15") kennen die Handreichung nicht, und kein Block
benennt eine Stelle, die sie leistet. Heute leer, weil die drei Wahlmodule Realschule sind
und der Wechsel in Klasse 4/5 liegt; real mit der Fördergruppe, die dieselbe Datei als
umkehrbaren Weg B ausschreibt und die grenzkarte.md als `elective_groups`-Zeile bestätigt.
Vorschlag: der Jahreslauf löscht die Mitgliedschaft, wie er die Klassenzuordnung leert, und
der Kommentar sagt das statt der Handreichung — `ON UPDATE CASCADE` wäre falsch, es zöge
das Kind in eine Gruppe seiner alten Schulart.

[KLASSENORGANISATION-F2] klassenorganisation · Klasse 5 · vier Schuljahr-Spalten
16 sagt zum Amt „Es beginnt mit dem Eintrag und endet am 31. Juli von selbst"; nichts hält
`class_representatives.school_year` an seinem Entstehen, und dasselbe gilt für
`class_teaching_assignments.school_year`, `class_end_times.school_year` und
`elective_groups.start_school_year`. Nachgestellt: eine Unterrichtsverteilung mit
`school_year = 19` und ein Unterrichtsende mit `1899` gehen durch, ebenso eine
Elternvertretung mit `32767`. Das Repo kennt die Klammer zweimal
(`ck_parent_work_entries_school_year`, `ck_expense_claims_calendar_year`), und
mensa-schema-check.sql trägt genau dieses Argument ausgeschrieben („ein Abo vom 1.10.2026
mit `school_year = 2019` ging durch"). Keine der vier Spalten hat eine Gegenprobe.
Vorschlag: je Spalte ein Plausibilitäts-CHECK, und bei `class_representatives` die Bindung
an `created_at` wie `ck_expense_claims_calendar_year` — mit Luft nach hinten, weil der
offizielle Umweg das Nachtragen erlaubt.

[KLASSENORGANISATION-F3] klassenorganisation · Klasse 5 · Prüfskript, Constraint-Liste
Die sechs `ck_*_created_by` stehen weder in der geprüften Constraint-Liste (Z. 51–68) noch
in einer Gegenprobe, obwohl elternbonus, gesundheit, akademie, anmeldung und stammdaten
ihre eigenen dort führen. Gebaut sind sie — ein `created_by = 'wer auch immer'` weist
`ck_class_end_times_created_by` ab —, gegengeprüft nicht, und nach CLAUDE.md gilt das als
nicht gebaut.
Vorschlag: die sechs Namen in das Array aufnehmen, dazu eine `expect_reject` auf ein
`created_by` ohne Präfix.

[KLASSENORGANISATION-F4] klassenorganisation · Klasse 1 · class_representatives.person_id
14 verlangt für den Erlass „eine benannte Familie" (Vormerkung in 14), 16 antwortet „Der
Erlass hängt an der Familie und nicht am Amt". Die Zeile trägt eine `person_id`; die Familie
entsteht erst über `family_guardians`, und für den Patchwork-Fall, den stammdaten
ausdrücklich baut („Ist eine Person Mitglied mehrerer Familien"), liefert der Weg zwei
Familien statt einer. Weder 14 noch 16 sagt, welche den Erlass bekommt — mir fehlt damit
die Grundlage, das als gebaut oder als Lücke zu werten.
Vorschlag: keine Schemaänderung, sondern ein Satz in 16 oder 14, welche Familie eines
Amtsträgers mit zwei Familien den Erlass trägt.
```

## Angesehen, nicht als Fund gewertet

```
klassenorganisation · `elective_groups.employee_id` ist leerbar, obwohl 15 sagt „Sie hat
        genau eine Lehrkraft" und TASK-161 sie „einzige Pflichtangabe" nennt. Der Kommentar
        schreibt die Auslassung aus und nennt ihre Bedeutung („niemand sieht diese Kinder
        über diese Gruppe"); ein Constraint könnte „Pflicht beim Anlegen, leerbar danach"
        ohnehin nicht ausdrücken, und ON DELETE SET NULL ist die Regel, die 15 verlangt.
klassenorganisation · Alle fünf verdächtigen `expect_reject`-Proben einzeln abgesetzt: sie
        werden aus dem richtigen Grund abgewiesen — „geliehene Schulart" und „Kind ohne
        Einschreibung" an `fk_child_group_memberships_child`, „Grundschulkind in
        Realschulgruppe" und „fremdes Modul" an `fk_child_group_memberships_group`,
        „Samstag" an `ck_class_end_times_weekday`. Keine läuft ins Leere.
klassenorganisation · Der DO-Block „ohne Zuordnung sieht die Lehrkraft nichts" zählt für
        eine Lehrkraft ohne Zeile null — er läuft aber nicht ins Leere: zu diesem Zeitpunkt
        sehen andere Lehrkräfte sehr wohl Kinder, die Null unterscheidet sich also von der
        leeren Datenbank.
klassenorganisation · `uq_child_group_memberships_module` sah nach Klasse 2 aus; 15 kennt
        die Einmalwahl je Modul („einmal gewählt und bis zum Abgang behalten"), zwei Module
        nebeneinander lässt der Schlüssel zu, der Wechsel zwischen zwei Gruppen desselben
        Moduls bleibt ein UPDATE. Er trägt.
klassenorganisation · Eine Lehrkraft ohne Sorgeberechtigung lässt sich als Elternvertretung
        eintragen — gewollt: 16 hängt das Amt an der Klasse, der Fremdschlüssel zeigt
        deshalb auf `persons`, und `guardians` wäre als Ziel zu eng, weil es nach
        stammdaten-schema.sql nur trägt, wer eine der drei freiwilligen Angaben gemacht hat.
        Geprüft wird es in der Route (`api/klassenorganisation-api.md`).
klassenorganisation · Alle wörtlichen Zitate gegen ihre Quelle gehalten — 15, 16, TASK-161
        (auch die Akzeptanzkriterien 3, 6, 8, 11), TASK-218 und grenzkarte.md. Keines weicht
        ab; die Auslassungen stehen an Satzgrenzen.
klassenorganisation · Löschanker geprüft: `child_group_memberships` → Kind (Cascade,
        nachgestellt), `class_representatives` → Person (Cascade, nachgestellt),
        `class_teaching_assignments` → `employees` (Cascade; `classes.class_teacher_id`
        steht auf ON DELETE SET NULL und blockiert unterwegs nichts). Dass die Frist des
        Mitarbeitendeneintrags selbst offen ist, führt grenzkarte.md unter den weißen
        Flecken und ist kein Fund dieser Domäne. `elective_modules`, `elective_groups` und
        `class_end_times` tragen keinen und brauchen keinen.
klassenorganisation · Kein Seed der drei Wahlmodule in der `.sql` — Hauskonvention: keine
        einzige `*-schema.sql` trägt ein `INSERT`.
```

## `[A!]` dieser Domäne

```
[A!] Die Werteliste der Wahlmodule steht in klassenorganisation und nicht in stammdaten.
     Kein Block entscheidet sie — 15 und 16 sagen zur Dateiaufteilung nichts; entschieden
     hat es die Implementation Note von TASK-161, und ein Ticket ist kein Block. Die Marke
     steht damit zu Recht offen.
```

## Ergebnis

Vier Funde, davon einer (F1) mit Wirkung im Betrieb, sobald Weg B gebaut wird. Prüfskript
grün (rc=0) gegen die vollständige Datenbank.
