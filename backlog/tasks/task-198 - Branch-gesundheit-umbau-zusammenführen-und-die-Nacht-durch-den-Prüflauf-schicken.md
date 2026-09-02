---
id: TASK-198
title: >-
  Branch gesundheit-umbau zusammenführen und die Nacht durch den Prüflauf
  schicken
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
labels:
  - wb-backend
dependencies: []
references:
  - prompts/api-pruefen.md
ordinal: 211000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Nachtlauf 02.09.2026 hat in wb-backend auf dem Branch gesundheit-umbau (ab wertelisten-und-log-filter) sieben Commits hinterlassen: Gesundheit (TASK-154–159), Elternbonus (TASK-165/166), Mandat und Fotoeinverständnis (TASK-192). main liegt weiter hinter wertelisten-und-log-filter. Zu tun: die Branches zusammenführen, und die zwei umgebauten Domänen bekommen ihren Prüflauf in frischer Session (CLAUDE.md, prompts/api-pruefen.md) — die Gegenprobe je Ticket in der Nacht war kein Ersatz dafür. Dabei mitprüfen: die Sichten health_values_<code> gegen die Zeilenfilterung, die TASK-157 später als Policy baut, und die Lösch-Stufe consents vor documents.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 gesundheit-umbau ist in wertelisten-und-log-filter (oder main) gemergt, Suite und schema-check.sh danach grün
- [ ] #2 api-pruefen.md ist für gesundheit und elternbonus gelaufen, die Berichte sind repariert oder als Tickets abgelegt
<!-- AC:END -->
