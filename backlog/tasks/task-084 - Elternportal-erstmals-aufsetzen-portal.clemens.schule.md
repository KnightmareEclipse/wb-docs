---
id: TASK-084
title: Elternportal erstmals aufsetzen (portal.clemens.schule)
status: To Do
assignee: []
created_date: '2026-08-27 11:40'
labels:
  - frontend
  - eltern
milestone: m-0
dependencies: []
references:
  - project-parts.md
  - idea/04-identitaet-zugriff.md
priority: high
ordinal: 96000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Statische Oberfläche, ausgeliefert vom Reverse-Proxy derselben VPS. Ruft dieselbe wb-backend-Haupt-API wie interne Nutzer, unter ihrer eigenen Herkunft über /api/* — damit ist jede Anfrage gleichursprünglich und es entsteht keine CORS-Policy, die jemand pflegt. Eigenes Repo, Deploy über denselben Push wie der App-Stack.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eigene Herkunft am Hostnamen, getrennt von intern.clemens.schule
- [ ] #2 CSP nur eigene Skripte, keine base-Umleitung, X-Content-Type-Options: nosniff
- [ ] #3 frame-ancestors 'none' — nicht in Teams einbettbar
<!-- AC:END -->
