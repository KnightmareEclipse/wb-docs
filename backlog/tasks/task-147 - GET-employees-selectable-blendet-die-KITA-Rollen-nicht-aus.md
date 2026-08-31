---
id: TASK-147
title: GET /employees/selectable blendet die KITA-Rollen nicht aus
status: To Do
assignee: []
created_date: '2026-08-31 15:30'
labels:
  - wb-backend
  - stammdaten
  - elternbonus
milestone: m-5
dependencies: []
references:
  - api/stammdaten-api.md
  - api/elternbonus-api.md
  - soll-prozesse/14-elternbonus.md
ordinal: 159000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
GET /employees/selectable (app/routers/stammdaten.py) filtert allein auf den Beschäftigungszeitraum. Es verlangt keine Rolle und kennt die KITA-Ausnahme nicht, obwohl api/stammdaten-api.md sie ihm zuschreibt ("beim Elternbonus fallen die beiden KITA-Rollen heraus (14)") und Block 14 sie ausschreibt. Der optionale role_code trägt sie nicht: "jede Rolle außer zwei" ist mit einem einzelnen Code nicht ausdrückbar.

Folge: Die Auswahlliste im Portal bietet KITA-Personal und rollenlose Mitarbeitende als bestätigende Person an, und POST /parent-work-entries weist die Wahl danach mit 400 ab. Die verbindliche Prüfung steht richtig in _confirmable() der Elternbonus-Route — eine Bedingung je Datensatz in der eigenen Query, wie wb-backend/CLAUDE.md §6 es verlangt. Der Fund liegt allein darin, dass Liste und Eintrag verschiedene Mengen meinen.

Ein Ticket und keine Reparatur im Vorbeigehen: Die Route gehört den Stammdaten und wird von drei Blöcken gerufen (14, 12, 15). Was für den Bonus herausfällt, fällt für Rechnungsfreigabe und Klassenbildung nicht heraus, ein fest eingebauter Ausschluss wäre also falsch. Zu entscheiden ist die Form — ein Parameter, der die Ausnahme nennt, gegen einen zweiten Endpunkt für diesen einen Fall.

Gefunden im API-Prüfzyklus als BONUS-R2.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Form ist entschieden, bevor Code entsteht: die Ausnahme steht am Aufruf, nicht in der Route
- [ ] #2 Ein Test mit einer KITA-Person und einem rollenlosen Mitarbeitenden zeigt, dass Liste und _confirmable() dieselbe Menge meinen
- [ ] #3 api/stammdaten-api.md und api/elternbonus-api.md sagen danach dasselbe über diese Route
<!-- AC:END -->
