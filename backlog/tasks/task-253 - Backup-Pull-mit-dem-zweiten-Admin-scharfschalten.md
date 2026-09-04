---
id: TASK-253
title: Backup-Pull mit dem zweiten Admin scharfschalten
status: To Do
assignee: []
created_date: '2026-09-04 20:28'
labels:
  - infra
  - backup
  - zweiter-admin
milestone: m-1
dependencies: []
references:
  - backup.md
priority: high
ordinal: 266000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die VPS-Seite ist gebaut und lokal end-to-end geprüft, aber nirgends ausgerollt: Tims Admin-Key, der Pull-Key und das Dump-Skript werden erst mit einem Ansible-Lauf gegen db-prod-fsn-01 wirksam. Danach bekommt der zweite Admin das Pull-Skript aus wb-vps/nas/ samt Serverdaten und Host-Key-Fingerprint, und der erste echte Lauf vom NAS wird gemeinsam nachgewiesen — inklusive Restore, denn eine Sicherung, die niemand zurückgespielt hat, ist eine Hoffnung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ansible-Lauf gegen db-prod-fsn-01 ausgerollt, zweiter Lauf meldet changed=0
- [ ] #2 Privater age-Schlüssel liegt in der KeePass-Datenbank, die lokale Kopie ist gelöscht
- [ ] #3 Zweiter Admin hat Skript, Benutzername, Serveradresse und Host-Key-Fingerprint
- [ ] #4 Ein echter Pull vom NAS liegt als Datei vor und ließ sich in eine Wegwerf-DB zurückspielen
- [ ] #5 Fehlschlag des Pull-Laufs meldet an healthchecks.io
<!-- AC:END -->
