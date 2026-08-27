---
id: TASK-011
title: Personalisierter Link in der Ferienprogramm-Ankündigung
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-27 22:23'
labels:
  - wb-backend
  - ferien
  - mail
milestone: m-3
dependencies: []
references:
  - soll-prozesse/10-ferienprogramm.md
  - zugang.md
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Je Empfänger personalisiert, nicht einer für alle. Er meldet nicht an: er trägt die Adresse, an die er ging, füllt das Adressfeld und löst den Code aus. Weil er nichts freischaltet, braucht er keinen Token-Speicher und keine Gültigkeitsdauer.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Adresse als Query-Parameter, kein selbst authentifizierender Link
- [ ] #2 Eine weitergeleitete Ankündigung nützt dem Empfänger nichts — der Code geht ans ursprüngliche Postfach
<!-- AC:END -->
