---
id: TASK-272
title: Wochenlauf über unzustellbare Mails bauen
status: To Do
assignee: []
created_date: '2026-09-05 23:50'
labels:
  - wb-backend
  - lauf
  - mail
dependencies: []
ordinal: 285000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
hebel.md, "Unzustellbare Mail": Bleibt eine Mail unzustellbar, ist das im System sichtbar, und das Sekretariat geht dem nach — für jede Mail aus jedem Prozess außer dem Anmeldecode. `outbound_emails.undeliverable_at` wird im Graph-Fehlerpfad gesetzt (`app/services/mail.py`), aber nirgends eingesammelt: `app/runs.py` kennt keinen Lauf dafür, und der Vorbehalt steht nur in `container.md`, nicht im Plan.

Gefunden im dreizehnten API-Prüfzyklus als GESAMT-R6 (`pruefberichte/routen.md`, Abschnitt 6), einer von drei dort gemeldeten fehlenden Läufen — die anderen zwei sind bereits eigene Tickets (TASK-142, TASK-207).

Bauform wie beim bestehenden Wochenmail-Lauf über `sync_tasks` (TASK-110): eine Abfrage über `outbound_emails`, gesammelt statt einzeln, an die Stelle, die die jeweilige Mail ohnehin verantwortet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Lauf sammelt jede offene undeliverable_at-Zeile ein, außer dem Anmeldecode-Pfad
- [ ] #2 Eine Zeile gilt nach dem Einsammeln als erledigt, wie jede andere Lauf-Marke
- [ ] #3 Ein Test in tests/test_runs.py deckt den Lauf ab
<!-- AC:END -->
