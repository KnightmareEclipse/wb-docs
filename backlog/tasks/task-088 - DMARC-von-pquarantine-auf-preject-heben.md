---
id: TASK-088
title: DMARC von p=quarantine auf p=reject heben
status: To Do
assignee: []
created_date: '2026-08-27 22:23'
labels:
  - infra
milestone: m-5
dependencies: []
references:
  - zugang.md
priority: low
ordinal: 100000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
SPF, DKIM und p=quarantine stehen; der letzte Schritt hängt allein daran, dass die rua-Berichte sauber sind. Gesetzt wird der Wert beim DNS-Provider der Schule (All-Inkl, KAS-Panel) an _dmarc.clemens.schule.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 rua-Berichte über einen vollen Zyklus ohne Fehlschläge
- [ ] #2 dig +short TXT _dmarc.clemens.schule zeigt p=reject
<!-- AC:END -->
