---
id: TASK-001
title: 'GET /cleaning/cycles/{year}/allocation — das Gesamtbild der Zuteilung'
status: To Do
assignee: []
created_date: '2026-08-27 11:33'
updated_date: '2026-08-27 23:29'
labels:
  - wb-backend
  - putzdienst
  - route
milestone: m-0
dependencies:
  - TASK-106
references:
  - api/putzdienst-api.md
  - soll-prozesse/01-putzdienst.md
  - wb-backend/app/routers/cleaning.py
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das Gesamtbild je Termin und je Familie. Samt der Termine, an denen die Platzzahl überschritten wurde: Der Lauf darf sie überschreiten, und das Sekretariat entscheidet am Bild, ob es so trägt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Rolle secretariat, keine enge Rolle
- [ ] #2 Termine über Platzzahl sind im Ergebnis erkennbar
- [ ] #3 Je Familie ihre Termine, je Termin seine Familien
<!-- AC:END -->
