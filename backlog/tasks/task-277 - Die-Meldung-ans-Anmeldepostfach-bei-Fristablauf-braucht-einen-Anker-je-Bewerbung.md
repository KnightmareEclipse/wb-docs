---
id: TASK-277
title: >-
  Die Meldung ans Anmeldepostfach bei Fristablauf braucht einen Anker je
  Bewerbung
status: To Do
assignee: []
created_date: '2026-09-06 16:25'
labels:
  - wb-backend
  - anmeldung
dependencies: []
ordinal: 289000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Prüfbericht ANMELDUNG-R8 (`pruefberichte/routen-anmeldung.md`) findet: `deadline_passed_report` (`app/services/anmeldung.py`) markiert seinen Lauf über `OutboundEmail.purpose == DEADLINE_PASSED_PURPOSE`, `recipient_email == settings.admissions_mailbox`, `sent_at >= deadline` und `person_id IS NULL` — `outbound_emails` trägt keine Spalte, die die Bewerbung oder das Kind nennt, denn die Mail geht an eine Mailbox und nicht an eine Person. `release_decisions` gibt jeder Zusage eines Ziels dasselbe Fristende, sie verstreichen also gemeinsam: Die erste Meldung des Ticks setzt `sent_at`, und jede weitere Bewerbung mit demselben `deadline`-Wert findet diese Zeile über `sent_at >= deadline" und hält sich für schon gemeldet — das Sekretariat erfährt von einem Kind statt von zwanzig.

Kein Fix ohne Schema: `outbound_emails` hat keine Spalte, die zwischen den Kindern eines gemeinsamen Fristendes unterscheidet, und `purpose` ist eine Kategorie-Spalte, die auch in `GET /outbound-emails/undeliverable" roh an das Sekretariat geht (`app/routers/querschnitt.py`) — eine je Bewerbung eingebettete Kennung würde dort als kaputte Kategorie erscheinen. `person_id` zweckzuentfremden (auf die Person des Kindes statt auf einen Empfänger) unterliefe die Spaltendokumentation und ließe `family_ids" in derselben Ansicht leer wirken, wo eigentlich ein Kind gemeint ist. Der im Bericht genannte Weg — eine `sync_tasks`-Zeile je Bewerbung statt einer Mail — würde `child_id` als vorhandenen Subject-Typ von `sync_tasks` nutzen (kein neuer, per `ck_sync_tasks_single_subject` bereits erlaubt), ändert aber den Zustellweg von einer Mail an eine feste Adresse zu einer Aufgabe, die jemand abarbeitet — eine Entscheidung, die der Block treffen muss, nicht ein Reparaturlauf (`prompts/api-reparieren.md`: "Braucht ein Fund DDL, ist er kein Routen-Fund mehr").
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Lösung (neue sync_targets-Zeile, eigene Anker-Spalte an outbound_emails, oder ein anderer Weg) unterscheidet die Meldung einer Bewerbung von der einer anderen mit demselben Fristende
- [ ] #2 deadline_passed_report meldet jede betroffene Bewerbung einzeln, auch wenn mehrere Bewerbungen desselben Ziels zeitgleich ihre Frist verstreichen lassen
- [ ] #3 Ein Test: zwei Bewerbungen mit identischem response_deadline_at lösen zwei Meldungen aus, nicht eine
<!-- AC:END -->
