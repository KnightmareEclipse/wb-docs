---
id: TASK-016
title: 'Import: Adressen über den Suchindex nachschlagen statt blind einfügen'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - import
  - stammdaten
milestone: m-1
dependencies: []
references:
  - TODO-SESSIONS.md
  - schema/stammdaten-schema.sql
priority: high
ordinal: 16000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
addresses hat bewusst kein UNIQUE (der „nur für diese Person"-Split legt wertgleiche Zweitzeilen an). Der Import muss vor jedem Insert über (postal_code, street, house_number) nachschlagen und eine bestehende Zeile wiederverwenden — sonst bekommt jede Familie so viele Adresszeilen wie Mitglieder.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Nachschlagen über den vorhandenen Suchindex vor jedem Insert
- [ ] #2 Gegenprobe: eine Familie mit vier Mitgliedern an einer Anschrift bekommt eine Adresszeile
<!-- AC:END -->
