---
id: TASK-033
title: NAS-Backup-Bootstrap auf der Synology
status: In Progress
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-09-04 22:20'
labels:
  - wartet
  - zweiter-admin
  - infra
  - backup
milestone: m-1
dependencies: []
references:
  - backup.md
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Pull-Key am 04.09.2026 vom zweiten Admin erhalten (ClemensNAS02), VPS-Seite gebaut und in
wb-vps: Dump-Skript, sudoers-Zeile, Forced-Command in deploys authorized_keys, age-Empfänger
in group_vars. Kette lokal end-to-end geprüft (SSH -> Forced-Command -> pg_dump -> age ->
Restore), Idempotenzlauf grün. Der private age-Schlüssel muss noch in die KeePass-Datenbank.

Offen auf dem NAS: Task-Scheduler-Job mit dem Pull-Skript anlegen, VPS-Host-Key in known_hosts
pinnen (nach jedem rebuild.sh erneut), healthchecks.io-Check für den Pull einrichten. Nicht ABB:
das braucht eine Datei auf der Gegenseite und damit einen zweiten Auslöser auf der VPS.
<!-- SECTION:NOTES:END -->
