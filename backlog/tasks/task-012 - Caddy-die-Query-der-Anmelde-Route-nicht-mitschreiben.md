---
id: TASK-012
title: 'Caddy: die Query der Anmelde-Route nicht mitschreiben'
status: Done
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:01'
labels:
  - wb-backend
  - dsgvo
  - infra
milestone: m-3
dependencies: []
references:
  - wb-backend/caddy/Caddyfile
  - container.md
ordinal: 12000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die log-Zeile im Caddyfile trägt den Hinweis, dass sie einen format filter braucht, sobald es die Route gibt. Sonst steht die Adresse in einem Bestand mit anderer Aufbewahrung und anderem Leserkreis als die Datenbank.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 format filter auf der Route, gegengeprüft an einer echten Anfrage im Log
<!-- AC:END -->
