---
id: TASK-122
title: CI-Plattform für die Umsetzungs-Repos entscheiden
status: Done
assignee: []
created_date: '2026-08-27 22:46'
updated_date: '2026-08-29 10:39'
labels:
  - entscheidung
  - infra
  - betreiber
milestone: m-5
dependencies: []
references:
  - rules.md
ordinal: 134000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Entschieden: GitHub Actions, ausgelöst allein durch `pull_request`, `permissions: contents: read`, nur GitHub-eigene Actions. Kein zweiter Anbieter — die Organisation steht schon auf der MFA-Liste —, kein Credential, kein AVV: in den Lauf gehen Quellcode und der synthetische Seed, nie ein Export. Deployt nie, der Auslöser bleibt der Push auf die VPS. Begründung samt Preis in rules.md Abschnitt 2. Gebaut in wb-backend, wb-elternportal, wb-intern; wb-vps hängt an seinem Idempotenz-Prüflauf (123).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden mit Preis: welcher Dienstleister, welcher AVV-Bedarf, welches Credential
- [ ] #2 Oder ausdrücklich verworfen, mit dem Grund
<!-- AC:END -->
