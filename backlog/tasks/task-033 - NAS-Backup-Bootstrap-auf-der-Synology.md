---
id: TASK-033
title: NAS-Backup-Bootstrap auf der Synology
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
labels:
  - wartet
  - zweiter-admin
  - infra
  - backup
milestone: m-1
dependencies: []
references:
  - TODO.md
  - idea/05-backup-recovery.md
priority: high
ordinal: 33000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
SSH-Keypair für den Pull-Key generieren (privat ausschließlich auf dem NAS), Task-Scheduler-Job anlegen, VPS-Host-Key vorab in known_hosts pinnen — nach jedem rebuild.sh neu zu wiederholen. Öffentlichen Pull-Key liefert der zweite Admin nach seiner Urlaubsrückkehr Ende August 2026.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Muss vor den ersten echten Elterndaten laufen, nicht nachträglich
<!-- AC:END -->
