---
id: TASK-119
title: Runbook für die Betriebsstörung schreiben
status: To Do
assignee: []
created_date: '2026-08-27 22:45'
labels:
  - infra
  - betreiber
milestone: m-0
dependencies: []
references:
  - runbook.md
  - container.md
  - deploy.md
ordinal: 131000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
runbook.md deckt den kompletten Neuaufbau und den Server, der nicht mehr bootet. Was zu tun ist, wenn die API mitten im Buchungsfenster steht oder der Mailversand ausfällt, steht nirgends — und genau das ist der Fall, der im Betrieb eintritt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Deckt: API antwortet nicht, Mailversand scheitert, Zahlungsdienst nicht erreichbar, Platte voll
- [ ] #2 Nennt je Fall, was der Betreiber prüft und was er den Eltern sagt
<!-- AC:END -->
