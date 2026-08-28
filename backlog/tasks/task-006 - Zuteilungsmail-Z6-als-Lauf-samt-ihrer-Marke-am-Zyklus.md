---
id: TASK-006
title: 'Zuteilungsmail (Z6) als Lauf, samt ihrer Marke am Zyklus'
status: Done
assignee: []
created_date: '2026-08-27 11:33'
updated_date: '2026-08-28 18:05'
labels:
  - wb-backend
  - putzdienst
  - lauf
  - schema
milestone: m-0
dependencies: []
references:
  - api/putzdienst-api.md
  - soll-prozesse/01-putzdienst.md
  - wb-backend/app/runs.py
  - wb-backend/app/services/cleaning.py
priority: high
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kein Teil der Freigabe-Route: Der Lauf sucht die Zyklen mit Freigabe und ohne Mail-Marke. Das hält die Route kurz, und ein Mailfehler kostet nicht die Freigabe. Zugleich die erste Erinnerung an den ersten Termin des Jahres — wer danach Z9 baut, darf den ersten nicht doppelt erinnern.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Marke an cleaning_cycles als Migration in wb-backend voran, Form wie registration_mail_sent_at/allocated_at
- [x] #2 Der Lauf sucht Zyklen mit Freigabe und ohne Mail-Marke
- [x] #3 Zeile im Register des Lauf-Diensts, Versand über services/mail.py
- [x] #4 Keine Zustandsdatei neben der Datenbank
<!-- AC:END -->
