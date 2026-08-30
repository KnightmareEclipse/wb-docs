---
id: TASK-138
title: Der Teams-Ping der Rechnungsfreigabe
status: To Do
assignee: []
created_date: '2026-08-30 18:50'
labels:
  - wb-backend
  - rechnungsfreigabe
  - m365
milestone: m-5
dependencies:
  - TASK-074
references:
  - api/rechnungsfreigabe-api.md
  - soll-prozesse/12-rechnungsfreigabe.md
  - wb-backend/app/services/graph.py
priority: medium
ordinal: 150000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die 30 Routen stehen, der Anstoß fehlt: "In diesem Block geht keine Mail raus", der eine Kanal ist ein Teams-Ping, der auf den Beleg führt. Das Repo hat dafür heute nichts — `app/services/graph.py` liest und schreibt Dateien, kein Chat. Drei Anlässe, alle an der Handlung, die sie auslöst, nie als eigene Route: an die gewählte Führungskraft bei `POST /expense-claims`, `POST …/forwarding` und `POST …/split`; an den Einreicher, sobald etwas anders ist als eingereicht, bei `PATCH /expense-claim-items/{id}`, `PUT …/decision` (Ablehnung) und `POST …/void`; an `executive_management` bei `PUT …/decision`, wenn der letzte Teil freigegeben ist und der Beleg über der Meldegrenze liegt. Der Weg dorthin ist eine Entscheidung für sich (Graph-Chat, Bot oder Activity Feed samt eigener Berechtigung) und gehört vor den Bau geklärt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Weg nach Teams ist entschieden und in container.md samt Berechtigung begründet
- [ ] #2 Der Ping hängt an der Handlung, es entsteht keine Route, die ihn von außen auslöst
- [ ] #3 Die Meldegrenze misst am ganzen Beleg, mit dem Wert zur Freigabe
- [ ] #4 Wer eine Handlung selbst auslöst, bekommt dafür keinen Ping; die Buchhaltung bekommt keinen
- [ ] #5 Ein fehlgeschlagener Ping hält die Transaktion des Belegs nicht auf
<!-- AC:END -->
