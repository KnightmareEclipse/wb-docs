---
id: TASK-107
title: Erinnerungs-Lauf für die zwei Erinnerungen je Termin bauen (Z9)
status: Done
assignee: []
created_date: '2026-08-27 22:44'
labels:
  - wb-backend
  - putzdienst
  - lauf
  - mail
milestone: m-0
dependencies: []
references:
  - soll-prozesse/01-putzdienst.md
  - container.md
  - schema/putzdienst-schema.sql
priority: high
ordinal: 119000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das Ticket zur Lauf-Marke legt nur die Spalte an. Der Lauf selbst fehlt: er sucht die Termine, deren Erinnerung fällig ist, und verschickt sie über die Versandschicht. Die Zuteilungsmail Z6 ist zugleich die erste Erinnerung an den ersten Termin des Jahres — der darf nicht doppelt erinnert werden.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Der erste Termin des Jahres wird nicht doppelt erinnert
- [x] #2 Auslöser ist eine gesetzte Spalte, kein Kalenderausdruck
<!-- AC:END -->
