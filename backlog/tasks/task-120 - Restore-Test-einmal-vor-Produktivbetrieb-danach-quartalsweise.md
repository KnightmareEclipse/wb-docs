---
id: TASK-120
title: 'Restore-Test einmal vor Produktivbetrieb, danach quartalsweise'
status: To Do
assignee: []
created_date: '2026-08-27 22:45'
labels:
  - infra
  - backup
  - test
  - betreiber
milestone: m-1
dependencies: []
references:
  - backup.md
ordinal: 132000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
backup.md verlangt ihn: Integritätsprüfung, Testrestore in eine Scratch-DB ohne Netzverbindung zum Produktiv-Netz, dazu das Aufräumen alter Sicherungen. Ungetestete Backups sind nur eine Hoffnung. Hängt am NAS-Bootstrap.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ein Testrestore ist einmal gegen echte Sicherungsdaten gelaufen
- [ ] #2 Der quartalsweise Rhythmus ist als wiederkehrender Termin verankert
<!-- AC:END -->
