---
id: TASK-132
title: 'Die Teams-App im Katalog eintragen: App-ID, Symbole, Rechtstexte'
status: To Do
assignee: []
created_date: '2026-08-29 00:35'
labels:
  - frontend
  - personal
  - betreiber
dependencies:
  - TASK-085
  - TASK-117
ordinal: 144000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vier Werte im Manifest (`wb-intern/teams/manifest.json`) sind Platzhalter, und alle vier gehören dem Betreiber, nicht dem Code: die App-ID aus dem Teams-Katalog (`id`), die Client-ID der Registrierung (`webApplicationInfo.id` samt `resource`), die beiden Symbole `teams/color.png` (192×192) und `teams/outline.png` (32×32) und die Adressen von Datenschutzerklärung und Nutzungsbedingungen. Entwickeln lässt sich die Oberfläche ohne alles davon, veröffentlichen nicht. Die drei technischen Bedingungen des Tabs trägt TASK-085, die Rechtstexte TASK-117; Begründung in `oberflaechen.md` und `wb-intern/README.md`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die vier Platzhalter im Manifest sind durch echte Werte ersetzt
- [ ] #2 Die App ist im Teams-Katalog des Tenants veröffentlicht und der Tab öffnet sich beim Sekretariat
<!-- AC:END -->
