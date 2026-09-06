---
id: TASK-149
title: Signal als zweiten Alarmweg für healthchecks.io einrichten
status: To Do
assignee: []
created_date: '2026-08-31 19:30'
labels:
  - infra
  - betreiber
milestone: m-5
dependencies: []
references:
  - host.md
priority: low
ordinal: 161000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Dead-Man's-Switch meldet heute nur per Mail an das Sammelpostfach von Admins und Geschäftsführung (host.md). Ein Postfach, in das nachts niemand sieht, nimmt dem Schalter genau die Eigenschaft, für die er da ist. Signal ist bei healthchecks.io eine eingebaute Integration und braucht deshalb nichts auf der VPS — einrichten, Nummer verifizieren, fertig. Auf dem kostenlosen Plan steht es nicht unter den Kredit-Kontingenten, die erst ab Business laufen; das ist im Integrationsmenü zu bestätigen. Dienstliche Nummern verwenden: Der Dienst erfährt damit, dass diese Nummer benachrichtigt werden will, und das bleibt sein eigenes Kundenverhältnis, kein Auftrag nach Art. 28 (dsgvo.md).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Signal-Integration eingerichtet und mit einem absichtlich ausbleibenden Heartbeat erprobt
- [ ] #2 host.md nennt beide Alarmwege
<!-- AC:END -->
