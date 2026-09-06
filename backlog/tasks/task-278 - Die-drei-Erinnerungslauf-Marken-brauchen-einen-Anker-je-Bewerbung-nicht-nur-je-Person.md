---
id: TASK-278
title: >-
  Die drei Erinnerungslauf-Marken brauchen einen Anker je Bewerbung, nicht nur
  je Person
status: To Do
assignee: []
created_date: '2026-09-06 16:25'
labels:
  - wb-backend
  - anmeldung
dependencies: []
ordinal: 290000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Prüfbericht ANMELDUNG-R9 (`pruefberichte/routen-anmeldung.md`) findet: `_already_sent` in `app/services/anmeldung.py` fragt "hat diese Person seit dem Zeitpunkt eine Mail dieser Sorte bekommen" über `(purpose, person_id, sent_at >= since)` — nie "hat diese Bewerbung ihre Erinnerung bekommen". Zwei Kinder einer Familie teilen sich denselben Sorgeberechtigten (`person_id`), denselben Zweck und oft denselben Zeitpunkt: `deadline_reminder" hat für den ganzen Jahrgang eines Ziels dasselbe `response_deadline_at" (aus `release_decisions"), `slot_reminder" trifft zusammen, sobald zwei Termine desselben Elternteils innerhalb der Vorlaufzeit liegen, `slot_missing_reminder" sobald zwei Ziele denselben frühesten Anmeldetag haben. Das zweite Kind bekommt in jedem der drei Fälle keine Erinnerung, weil die erste `OutboundEmail"-Zeile des ersten Kindes den Marker für denselben Empfänger schon setzt.

Kein Fix ohne Schema: `outbound_emails" trägt nur `person_id" als Subjekt-Spalte, und die Person ist hier zugleich der echte Empfänger — anders als bei ANMELDUNG-R8 lässt sich hier kein bereits vorhandener Wert zweckentfremden, ohne den Empfängerbezug zu verlieren, den die Spalte sonst trägt. Eine zweite Anker-Spalte (Bewerbung oder Kind) an `outbound_emails", oder ein Wechsel des Markierungswegs auf `sync_tasks" mit `child_id" je Bewerbung, ist eine Schemaentscheidung (`prompts/api-reparieren.md": "Braucht ein Fund DDL, ist er kein Routen-Fund mehr").
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Lösung unterscheidet, welche Bewerbung eine Erinnerung schon bekommen hat, unabhängig davon, ob derselbe Sorgeberechtigte noch eine zweite erwartet
- [ ] #2 deadline_reminder, slot_reminder und slot_missing_reminder erinnern jedes Kind einzeln, auch wenn ihr gemeinsamer Sorgeberechtigter im selben Lauf schon eine Mail für ein anderes Kind bekommen hat
- [ ] #3 Ein Test je Lauf: ein Elternteil mit zwei Kindern in der auslösenden Lage bekommt zwei Mails, nicht eine
<!-- AC:END -->
