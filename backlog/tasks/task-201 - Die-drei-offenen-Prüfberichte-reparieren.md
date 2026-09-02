---
id: TASK-201
title: Die drei offenen Prüfberichte reparieren
status: To Do
assignee: []
created_date: '2026-09-02 23:44'
labels:
  - wb-backend
  - pruefzyklus
dependencies: []
references:
  - prompts/api-reparieren.md
  - pruefberichte/routen-gesundheit.md
  - pruefberichte/routen-elternbonus.md
  - pruefberichte/routen-anmeldung.md
ordinal: 214000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Drei Routen-Prüfläufe liegen als Bericht in pruefberichte/ und sind weder repariert noch geticketet: routen-gesundheit.md (8 Funde), routen-elternbonus.md (10), routen-anmeldung.md (17). Geschlossen werden sie mit prompts/api-reparieren.md, ein Lauf je Bericht und je frischer Session; der Bericht wird dabei gelöscht, der Beleg ist die reparierte Route samt rot-dann-grünem Test (CLAUDE.md, Dokumentationsstil). TASK-198 nennt in seinem zweiten Abnahmekriterium nur gesundheit und elternbonus — anmeldung kam später dazu. Was ein Lauf nicht schließen darf, weil es am gemeinsamen Hebel liegt, steht in TASK-204.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 routen-gesundheit.md ist geschlossen und gelöscht, Suite und schema-check.sh danach grün
- [ ] #2 routen-elternbonus.md ist geschlossen und gelöscht, Suite und schema-check.sh danach grün
- [ ] #3 routen-anmeldung.md ist geschlossen und gelöscht, Suite und schema-check.sh danach grün
- [ ] #4 Kein Fund ist still liegengeblieben: was keine einzelne Domäne betrifft, steht in TASK-204
<!-- AC:END -->
