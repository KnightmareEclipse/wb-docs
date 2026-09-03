---
id: TASK-216
title: Die Hort-Belegungsliste aus dem Bestand erzeugen
status: To Do
assignee: []
created_date: '2026-09-03 16:38'
updated_date: '2026-09-03 18:20'
labels:
  - anmeldung
milestone: m-5
dependencies: []
references:
  - soll-prozesse/09-hortvertrag.md
  - fragen.md
ordinal: 229000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus [M3]: Jürgen fragt, ob die Hort-Belegungsliste künftig aus Weltenbaum erzeugt werden kann. Ihre Struktur ist am 03.09.2026 mündlich beschrieben worden — die Datei selbst bleibt ungelesen, sie führt personenbezogene und sehr sensible Daten.

**Sieben der acht Sichten sind Sichten und kein neues Datum.** Sie stehen alle auf Beständen, die es schon gibt, und werden deshalb [frisch erzeugt](../../soll-prozesse/hebel.md#frisch-erzeugte-liste) statt gepflegt:

- **Gesamtübersicht** — Kind, Klasse, Wochentage, Modul: `care_module_agreements` und `care_module_bookings` (anmeldung-schema.sql) plus `children.class_id`.
- **Nach Tag** und **nach Klasse** — dieselben Daten, andere Gruppierung.
- **Auslastung** — welches Modul an welchem Tag wie oft gebucht ist: eine Zählung über dieselbe Tabelle.
- **Kinder mit dem, was zu beachten ist** — der Hinweis am Kind (`child_health_records.action_note`) im Sichtkreis des Horts; die Domäne trägt ihn bereits, dieses Ticket nur die Anzeige.
- **Abrechnungsliste** — Beitrag je Kind und Monat aus `care_module_prices`. Zu prüfen ist, ob sie rechnet oder nur zusammenstellt; die Buchhaltung führt Optigem, nicht Weltenbaum.

**Die Hausaufgabenbetreuung kostet nichts** (Betreiber, 03.09.2026): Sie steckt im Modul und wird nicht gesondert gebucht. Wer sie besucht, ist damit die Liste der Kinder mit dem entsprechenden Modul an diesem Tag — ein Filter, kein Datum am Kind. Es gibt aber Module über Mittag **ohne** Hausaufgabenbetreuung (Betreiber, 03.09.2026), also ist die Liste nicht einfach die Nachmittagsliste: `care_modules` braucht ein Häkchen daneben.

Der Unterschied zu seinem Nachbarn `includes_lunch` ist erwähnenswert, weil er die Begründung umdreht: Das Essens-Häkchen steht dort, obwohl es sich heute aus der Uhrzeit ableiten ließe — „derzeit trägt jedes Modul über 13 Uhr eines, aber das ist ein Häkchen". Die Hausaufgabenbetreuung lässt sich **nicht** ableiten, weder aus der Uhrzeit noch aus der Dauer. Das Häkchen trägt hier also wirklich etwas und ist keine Vorsorge.

Die Änderung ist eine Spalte an `care_modules` und beginnt als Migration in wb-backend; die `.sql` hier wird nachgezogen.

**Zwei Dinge sind neu:**
- Die **Abfrage an Brückentagen** — sie ist ein eigener Vorgang und steht in einem eigenen Ticket (TASK-217).
- **Unterrichtsende je Klasse und Wochentag**, samt der späteren Ankunft nach dem Sport: ebenfalls ein eigenes Ticket (TASK-218), weil es ein Datum ist und keine Sicht.

**Die Gruppeneinteilung der Hausaufgabenbetreuung bleibt draußen** (Betreiber, 03.09.2026): Klasse 1+2 und 3+4 werden in je zwei Gruppen betreut, aber das ändert sich, es hängt keine Zusage daran und keine Abrechnung. Im Frontend ist es eine Anzeigeregel, in der Datenbank wäre es eine Liste, die niemand pflegt. Eine Zuordnung entsteht erst, wenn jemand sie braucht — und dann trägt sie dieselbe Bauform wie die Wahlmodulgruppe (TASK-161).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Jede Sicht ist frisch erzeugt und liest den Bestand, keine wird gepflegt
- [ ] #2 care_modules trägt ein Häkchen für die Hausaufgabenbetreuung; die Liste ist ein Filter darüber und kein Datum am Kind
- [ ] #3 Der Kommentar an der Spalte sagt, warum sie sich nicht aus der Uhrzeit ableiten lässt — anders als includes_lunch
- [ ] #4 Die Gruppeneinteilung steht nicht in der Datenbank — und der Grund steht als Kommentar da
- [ ] #5 Bei der Abrechnungsliste ist entschieden, ob sie rechnet oder zusammenstellt
<!-- AC:END -->
