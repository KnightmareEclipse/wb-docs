---
id: TASK-254
title: Papierkopie des privaten age-Schlüssels in den Safe
status: To Do
assignee: []
created_date: '2026-09-04 20:37'
labels:
  - backup
  - infra
milestone: m-1
dependencies: []
references:
  - backup.md
ordinal: 267000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der private age-Schlüssel liegt ausschließlich in der KeePass-Datenbank, und die liegt im M365-Tenant der Schule (host.md). Damit hängen Sicherung und Schlüssel an unterschiedlichen Orten, aber der Schlüssel an einem Dienst, dessen Ausfall genau im Wiederherstellungsfall plausibel ist — gesperrter Tenant, verlorener Zugang, kompromittiertes Konto. Ohne ihn ist jede Sicherung auf dem NAS wertlos. Der Schlüssel ist ein Bech32-String von rund 60 Zeichen und passt auf einen Zettel; eine ausgedruckte Kopie im Safe der Schule löst das vollständig, ohne einen weiteren Dienst.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ausdruck des privaten Schlüssels liegt im Safe der Schule, Fundort ist beiden Admins bekannt
- [ ] #2 Bei einer Schlüsselrotation wird der Ausdruck ersetzt, der alte erst vernichtet, wenn keine Sicherung ihn mehr braucht
<!-- AC:END -->
