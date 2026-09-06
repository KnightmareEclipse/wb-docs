---
id: TASK-088
title: DMARC von p=quarantine auf p=reject heben
status: To Do
assignee: []
created_date: '2026-08-27 22:23'
updated_date: '2026-08-30 18:31'
labels:
  - infra
milestone: m-5
dependencies: []
references:
  - zugang.md
priority: low
ordinal: 100000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
SPF, DKIM und p=quarantine stehen; der letzte Schritt hängt allein daran, dass die rua-Berichte sauber sind. Gesetzt wird der Wert beim DNS-Provider der Schule (All-Inkl, KAS-Panel) an _dmarc.clemens.schule.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 rua-Berichte über einen vollen Zyklus ohne Fehlschläge
- [ ] #2 dig +short TXT _dmarc.clemens.schule zeigt p=reject
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Der Ausgangspunkt des Tickets stimmt so nicht: Es gibt keine rua-Berichte, an denen sich der Schritt messen ließe. Gemessen am 30.08.2026 liefert dig +short TXT _dmarc.clemens.schule genau 'v=DMARC1;p=quarantine' — kein rua, kein ruf, kein sp, kein pct. AC #1 ('rua-Berichte über einen vollen Zyklus ohne Fehlschläge') ist damit heute nicht erreichbar, sondern beginnt mit einer Zeile davor: rua=mailto:<Adresse> in denselben Eintrag im KAS-Panel, danach einen Zyklus warten und erst dann p=reject. Die Empfängeradresse ist eine extern sichtbare Festlegung und gehört besprochen — sie steht in jedem DNS-Lookup. zugang.md hält den Befund jetzt fest.
<!-- SECTION:NOTES:END -->
