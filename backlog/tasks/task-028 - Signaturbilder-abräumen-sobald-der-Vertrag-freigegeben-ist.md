---
id: TASK-028
title: 'Signaturbilder abräumen, sobald der Vertrag freigegeben ist'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - wb-backend
  - anmeldung
  - dsgvo
milestone: m-4
dependencies: []
references:
  - schema/anmeldung-schema.sql
ordinal: 28000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bei contracts.released_at: Datei in SharePoint löschen, Kennung an der Signaturzeile leeren. Vorher wird das Bild für die Neuerzeugung gebraucht, danach steckt es im PDF; bleibt es liegen, ist es eine zweite Kopie ohne Abnehmer, die kein Lösch-Job je anfasst — sein Anker ist die Frist des Dokuments.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ausgelöst von contracts.released_at
- [ ] #2 Datei weg und Kennung geleert, beides
<!-- AC:END -->
