---
id: TASK-132
title: 'Die Teams-App im Katalog eintragen: App-ID, Symbole, Rechtstexte'
status: To Do
assignee: []
created_date: '2026-08-29 00:35'
updated_date: '2026-08-29 12:03'
labels:
  - frontend
  - personal
  - betreiber
dependencies:
  - TASK-085
  - TASK-117
ordinal: 144000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Symbole und die zwei GUIDs stehen (`wb-intern/teams/`). Die `id` kam nicht aus dem Katalog — sie ist eine selbst vergebene GUID, die der Katalog danach nur führt; `webApplicationInfo` trägt die Anwendungs-ID der Registrierung und ihre `api://`-Form, und die zwei Teams-Client-IDs sind am Scope `access_as_user` vorautorisiert. Offen ist allein das Veröffentlichen: erst als benutzerdefinierte App nur für den Betreiber hochladen, dann im Katalog des Tenants freigeben. **Kein zweites Manifest für eine Dev-Umgebung** — anders als beim Belegportal, wo SPFx eine eigene `contentUrl` je Umgebung erzwingt, läuft diese Oberfläche im Browser eigenständig (`wb-intern/src/auth.ts`); ein Tunnel-Host für einen lokalen Tab kostete einen Drittanbieter im Pfad der Personal-Oberfläche. Die Rechtstext-Adressen zeigen auf Seiten, die mit TASK-117 entstehen. Bei jeder Katalog-Aktualisierung muss `version` hoch.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Die vier Platzhalter im Manifest sind durch echte Werte ersetzt
- [ ] #2 Die App ist im Teams-Katalog des Tenants veröffentlicht und der Tab öffnet sich beim Sekretariat
<!-- AC:END -->
