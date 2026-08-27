---
id: TASK-057
title: Entra-ID Client-Secret erneuern (läuft 06.08.2028 ab)
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
labels:
  - wartet
  - betreiber
  - infra
  - termin
milestone: m-5
dependencies: []
references:
  - TODO.md
  - pipeline/runbook.md
ordinal: 60000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Trägt den App-only-Graph-Zugriff Mail.Send, nicht den Login — läuft es ab, bricht der OTP-Versand und damit der gesamte Elternzugang. Rechtzeitig vorher neues Secret erzeugen, in der Secrets-Datei im KeePass ersetzen, ausrollen und einmal deployen.
<!-- SECTION:DESCRIPTION:END -->
