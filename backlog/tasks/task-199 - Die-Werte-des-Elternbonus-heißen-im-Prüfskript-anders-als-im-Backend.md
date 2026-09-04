---
id: TASK-199
title: Die Werte des Elternbonus heißen im Prüfskript anders als im Backend
status: Done
assignee: []
created_date: '2026-09-02 07:55'
updated_date: '2026-09-04 01:05'
labels:
  - wb-docs
  - elternbonus
  - schema
dependencies: []
references:
  - schema/elternbonus-schema-check.sql
  - app/services/elternbonus.py
ordinal: 212000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Fund aus dem Nachtlauf 02.09.2026: schema/elternbonus-schema-check.sql legt die drei Werte im System als parent_bonus_monthly_cents, parent_bonus_required_hours_primary und parent_bonus_required_hours_secondary an; wb-backend (app/services/elternbonus.py, api/elternbonus-api.md, TASK-051) liest parent_work_monthly_cents, parent_work_hours_primary, parent_work_hours_default. Das Skript prüft nur seine eigenen Zeilen und bleibt deshalb grün — es hält aber die Codes „an den Namen fest, unter denen querschnitt-schema.sql sie aufzählt", und das sind nicht die, die die Anwendung liest. Eine der beiden Seiten ist nachzuziehen, die querschnitt-schema.sql-Aufzählung dazu.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Prüfskript, querschnitt-schema.sql und Backend nennen dieselben drei Codes
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Die drei Codes heissen jetzt ueberall parent_work_monthly_cents, parent_work_hours_primary und parent_work_hours_default — die Namen, unter denen app/services/elternbonus.py sie liest und unter denen die Tabellen dieser Domaene stehen (parent_work_sessions, parent_work_entries). Nachgezogen: die Aufzaehlung an configured_values in schema/querschnitt-schema.sql, schema/elternbonus-schema-check.sql und TASK-051, damit dort nicht die alten Codes eingetragen werden. api/elternbonus-api.md nannte sie schon richtig; im Backend war nichts zu aendern.
<!-- SECTION:NOTES:END -->
