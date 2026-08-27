---
id: TASK-032
title: employees-Zeile mit der echten Entra-Object-ID auf der Produktiv-VPS anlegen
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
labels:
  - wartet
  - betreiber
  - infra
milestone: m-0
dependencies: []
references:
  - TODO.md
  - idea/04-identitaet-zugriff.md
ordinal: 32000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lokal steht sie, auf dem Server nicht — ohne sie antwortet dort jede rollengeschützte Route mit 403. Genommen wird das normale Benutzerkonto, nicht das Tenant-Admin-Konto: ein privilegiertes Verzeichniskonto gehört nicht in den Alltagszugriff einer Fachanwendung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Fällig mit dem ersten Deploy, der geschützte Routen mitbringt — nicht davor
<!-- AC:END -->
