---
id: TASK-085
title: Interne Oberfläche aufsetzen (intern.clemens.schule)
status: To Do
assignee: []
created_date: '2026-08-27 11:40'
labels:
  - frontend
  - personal
milestone: m-0
dependencies: []
references:
  - project-parts.md
  - idea/04-identitaet-zugriff.md
priority: high
ordinal: 97000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Für Personal, bildet größere Prozesse ab. Voraussichtlich TypeScript, kein SPFx, kein schweres UI-Framework. Hosting auf derselben VPS mit demselben /api/*-Pfad. Die Werkzeugwahl innerhalb der Oberfläche bleibt bewusst offen, bis das Repo startet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Drei Bedingungen für den Teams-Tab: frame-ancestors für teams.microsoft.com und *.cloud.microsoft, kein X-Frame-Options, validDomains im Manifest, gültiges HTTPS
- [ ] #2 Keine Cookie-Sitzung — Teams-SSO über getAuthToken, dann Bearer-Token im Header
<!-- AC:END -->
