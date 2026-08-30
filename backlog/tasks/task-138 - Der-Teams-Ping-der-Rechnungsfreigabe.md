---
id: TASK-138
title: Der Teams-Ping der Rechnungsfreigabe
status: To Do
assignee: []
created_date: '2026-08-30 18:50'
updated_date: '2026-08-30 18:29'
labels:
  - wb-backend
  - rechnungsfreigabe
  - m365
milestone: m-5
dependencies:
  - TASK-074
  - TASK-132
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Recherchiert, nicht gebaut — die Wege sind auf einen zusammengeschrumpft, und der hängt an einer App, die es noch nicht gibt.

Aus der Anwendung heraus, ohne angemeldeten Menschen, geht genau ein Graph-Aufruf: POST /users/{id}/teamwork/sendActivityNotification mit der Anwendungsberechtigung TeamsActivity.Send. Der activityType muss im Teams-App-Manifest stehen (Ausnahme: der reservierte systemDefault mit Freitext), und das Ziel ist entweder die installierte App (topic.source = entityUrl) oder ein freier Link (topic.source = text plus webUrl). Beides setzt die Teams-App voraus — deshalb hängt dieses Ticket jetzt an TASK-132, und das wiederum an TASK-117.

Die beiden naheliegenden Alternativen tragen nicht. Eine Chat- oder Kanalnachricht per Graph gibt es app-only nicht: ChatMessage.Send ist ausschließlich delegiert, und die einzige Anwendungsberechtigung dafür, Teamwork.Migrate.All, ist ausdrücklich nur für Migration. Und der eingehende Webhook, der das früher getan hätte, ist weg: Microsoft hat die Office-365-Connectors in Teams zwischen dem 18. und 22. Mai 2026 abgeschaltet; der Ersatz ist ein Power-Automate-Workflow, also ein Fluss je Kanal in genau dem Werkzeug, das Weltenbaum hier ablöst — und er postet in einen Kanal, nicht an die eine Führungskraft, die der Block meint.

Bleibt als dritter Weg ein Bot (Azure-Bot-Registrierung, eigener öffentlicher Endpunkt, gespeicherte conversation references). Der kann, was der Block will, kostet aber einen Dienst mehr und einen zweiten Weg ins Haus.

Quellen: learn.microsoft.com/graph/api/userteamwork-sendactivitynotification; learn.microsoft.com/graph/api/chatmessage-post; devblogs.microsoft.com/microsoft365dev/retirement-of-office-365-connectors-within-microsoft-teams/
<!-- SECTION:NOTES:END -->
