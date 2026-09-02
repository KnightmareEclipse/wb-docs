---
id: TASK-202
title: Die acht ungeprüften Domänen und der dreizehnte Lauf
status: To Do
assignee: []
created_date: '2026-09-02 23:44'
labels:
  - wb-backend
  - pruefzyklus
dependencies:
  - TASK-198
references:
  - prompts/api-pruefen.md
ordinal: 215000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vier der zwölf Domänen sind durch prompts/api-pruefen.md gegangen: cleaning, gesundheit, elternbonus, anmeldung. Offen sind klassenorganisation, payments, auth, mensa, ferien, querschnitt, rechnungsfreigabe und stammdaten — je eine frische Session, höchstens drei nebeneinander —, danach der dreizehnte Lauf über alle zwölf. Geprüft wird der Stand, auf dem gebaut wurde; solange der Merge aus TASK-198 aussteht, ist das origin/gesundheit-umbau und nicht main. Die zwei Lücken im Rezept stehen in TASK-203 und sollten davor geschlossen sein.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Acht Berichte liegen in pruefberichte/, einer je Domäne
- [ ] #2 Der dreizehnte Lauf ist gelaufen, pruefberichte/routen.md liegt
- [ ] #3 Die zwei Zahlen stehen darin: wie viele der 235 Routen einen Test haben und wie viele einen auf die fremde Id
<!-- AC:END -->
