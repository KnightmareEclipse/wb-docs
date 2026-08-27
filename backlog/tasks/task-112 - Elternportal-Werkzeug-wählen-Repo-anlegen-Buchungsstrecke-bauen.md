---
id: TASK-112
title: 'Elternportal: Werkzeug wählen, Repo anlegen, Buchungsstrecke bauen'
status: To Do
assignee: []
created_date: '2026-08-27 22:45'
labels:
  - frontend
  - eltern
  - putzdienst
milestone: m-0
dependencies: []
references:
  - oberflaechen.md
  - zugang.md
  - repos.md
priority: high
ordinal: 124000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das vorhandene Ticket setzt nur den Host auf. Was darin läuft, fehlt: Werkzeugwahl (in oberflaechen.md bewusst offengelassen, bis das Repo startet), eigenes Repo nach dem Namensschema, dann Anmeldemaske, Terminübersicht, Buchung, Freikauf und die eigene Terminliste. Für den ersten produktiven Zyklus ist das die Hälfte der Arbeit.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Kein Inline-Skript und kein onclick-Attribut — die CSP lässt nur eigene Dateien zu
- [ ] #2 Sitzung als __Host--Cookie, nicht im localStorage
- [ ] #3 Deploy über denselben Push wie der App-Stack, kein eigenes CI/CD
<!-- AC:END -->
