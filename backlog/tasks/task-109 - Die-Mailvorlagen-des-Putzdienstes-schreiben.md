---
id: TASK-109
title: Die Mailvorlagen des Putzdienstes schreiben
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-28 16:27'
labels:
  - wb-backend
  - putzdienst
  - mail
milestone: m-0
dependencies: []
references:
  - soll-prozesse/01-putzdienst.md
  - container.md
priority: high
ordinal: 121000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
mail.py trägt zwei Texte: Anmeldecode und Fenster-offen. Es fehlen Zuteilungsmail (Z6), Erinnerung (Z9), Bestätigung von Buchung und Freikauf, Tauschbestätigung an beide Familien und die Rundmail. Ohne Text kein Lauf.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Jede Vorlage geht über die Versandschicht, keine am send_tracked vorbei
- [ ] #2 Absender ist post@clemens.schule mit Anzeigenamen, kein noreply
- [ ] #3 Die Fenster-offen-Mail nennt den Freikaufbetrag und den Weg dorthin — beides gibt es ab Zyklus eins
<!-- AC:END -->
