---
id: TASK-252
title: Der Schulleitung den Direktzugriff auf die Schuelerakte entziehen
status: To Do
assignee: []
created_date: '2026-09-04 19:12'
labels:
  - m365
  - dsgvo
milestone: m-1
dependencies: []
ordinal: 265000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Geschaeftsfuehrung, 04.09.2026: Die Schulleitung gibt ihren heutigen Direktzugriff auf den Kohorten-Ordner ab und liest ebenfalls ueber das Portal (TASK-184).

**Erst danach gilt die Zusage aus grenzkarte.md woertlich** — 'an die Schuelerakte kommt kein Mensch direkt'. Bis der Grant weg ist, steht dort eine Aussage, die der Tenant nicht haelt; das ist der einzige Grund, aus dem dieses Ticket existiert.

**Vorher pruefen, was danach fehlt:** Wofuer hat die Schulleitung den Ordner heute geoeffnet? Was sie dort tut, muss ueber das Portal gehen, sonst ist der Entzug ein Arbeitsverbot statt einer Umstellung. Die Leseroute ist gebaut (api/querschnitt-api.md), das Ablegen ebenfalls — zu pruefen ist, ob beides ihren Fall abdeckt.

Handarbeit im Tenant, kein Bau in Weltenbaum.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Schulleitung kommt nicht mehr direkt an die Bibliothek der Schuelerakte
- [ ] #2 Geprueft und benannt, was sie dort bisher getan hat und ueber welche Route es kuenftig laeuft
- [ ] #3 Die Gegenprobe: ein Aufruf der Bibliothek durch die Schulleitung schlaegt fehl, ein Aufruf ueber das Portal nicht
<!-- AC:END -->
