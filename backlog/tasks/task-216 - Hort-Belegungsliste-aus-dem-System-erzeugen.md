---
id: TASK-216
title: Die Hort-Belegungsliste aus dem Bestand erzeugen
status: To Do
assignee: []
created_date: '2026-09-03 16:38'
updated_date: '2026-09-03 17:09'
labels:
  - anmeldung
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

**Zwei Dinge sind neu:**

- Die **Hausaufgabenbetreuung**: welche Kinder darin sind, ist ein Datum, das der Bestand heute nicht kennt. Erst zu klären ist, ob es aus dem gebuchten Modul folgt oder daneben steht — im ersten Fall entsteht gar nichts.
- Die **Abfrage an Brückentagen** — sie ist ein eigener Vorgang und steht in einem eigenen Ticket.

**Die Gruppeneinteilung der Hausaufgabenbetreuung bleibt draußen** (Betreiber, 03.09.2026): Klasse 1+2 und 3+4 werden in je zwei Gruppen betreut, aber das ändert sich, es hängt keine Zusage daran und keine Abrechnung. Im Frontend ist es eine Anzeigeregel, in der Datenbank wäre es eine Liste, die niemand pflegt. Eine Zuordnung entsteht erst, wenn jemand sie braucht — und dann trägt sie dieselbe Bauform wie die Wahlmodulgruppe (TASK-161).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Jede Sicht ist frisch erzeugt und liest den Bestand, keine wird gepflegt
- [ ] #2 Entschieden, ob die Hausaufgabenbetreuung aus dem Modul folgt oder ein eigenes Datum ist
- [ ] #3 Die Gruppeneinteilung steht nicht in der Datenbank — und der Grund steht als Kommentar da
- [ ] #4 Bei der Abrechnungsliste ist entschieden, ob sie rechnet oder zusammenstellt
<!-- AC:END -->
