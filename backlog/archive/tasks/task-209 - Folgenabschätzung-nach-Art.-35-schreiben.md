---
id: TASK-209
title: Folgenabschätzung nach Art. 35 schreiben
status: To Do
assignee: []
created_date: '2026-09-03 13:55'
updated_date: '2026-09-03 18:35'
labels:
  - dsgvo
milestone: m-5
dependencies: []
references:
  - verarbeitungsverzeichnis.md
  - dsgvo.md
  - soll-prozesse/08-schulvertrag.md
priority: low
ordinal: 222000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Datenschutzbeauftragte hat sie am 02.09.2026 als fällig bezeichnet — **vor dem Livegang mit Gesundheitsdaten**; die übrigen Prozesse dürfen vorher starten.

**Spätestens der Schulvertrag erhebt sie** (Block 08), er ist damit der Anker der Fälligkeit: Kein Vorgang, der Gesundheitsangaben erhebt — Schulvertrag (08), Hortvertrag (09), Ferienbuchung (10), Ausflug (19) —, geht live, bevor die Folgenabschätzung steht.

Geschrieben wird sie vom Betreiber, **gegengelesen vom Datenschutzbeauftragten** (03.09.2026). Sie baut auf verarbeitungsverzeichnis.md auf, das Zwecke, Datenkategorien, Empfänger, Fristen und Maßnahmen bereits führt — sie wiederholt es nicht, sondern bewertet das Risiko für die betroffenen Personen und nennt die Abhilfen.

Niedrige Priorität, weil nichts sie heute aufhält: Sie ist ein Dokument, kein Bau, und ihr Anlass liegt hinter der Entwicklung. Sie darf nur nicht vergessen werden, wenn der Livegang näher rückt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Die Fälligkeit hängt am Livegang der Gesundheitsdaten, nicht an einem Kalendertag
- [x] #2 Sie wiederholt das Verarbeitungsverzeichnis nicht, sondern bewertet Risiko und Abhilfen
- [ ] #3 Der Datenschutzbeauftragte hat gegengelesen und das schriftlich bestätigt
- [ ] #4 Kein Vorgang, der Gesundheitsangaben erhebt, ist vorher live gegangen
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Die Folgenabschätzung steht als `folgenabschaetzung.md`: Schwellwert, Fälligkeitsanker am Livegang der fünf erhebenden Vorgänge (08, 09, 10, 19, 21), Notwendigkeit und Verhältnismäßigkeit, neun Risiken mit Abhilfe und Stand, Restrisiko samt Ergebnis zu Art. 36. Sechs der neun Abhilfen sind offene Tickets (157, 205, 206, 162, 183, 007) — sie gehören damit zur Sperre. Offen bleiben AC 3 und 4: die schriftliche Bestätigung des Datenschutzbeauftragten steht als [?] in der Datei, und AC 4 ist ein Zustand der Welt, kein Schreibvorgang.
<!-- SECTION:NOTES:END -->
