---
id: TASK-142
title: Der Jahreslauf am 1. August
status: To Do
assignee: []
created_date: '2026-08-31 00:59'
labels:
  - wb-backend
  - stammdaten
  - lauf
milestone: m-5
dependencies: []
references:
  - api/stammdaten-api.md
  - soll-prozesse/04-schuljahreswechsel.md
ordinal: 154000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der zweite der drei fehlenden Läufe der Stammdaten (api/stammdaten-api.md, "Die vier Läufe"). Er ist der größte und der einzige, der über die Domänengrenze greift.

Aus 04 Z2, am 1. August, ein festes Datum: alles rückt eine Stufe auf, was im endenden Schuljahr eingeschrieben war (Wiederholer ausgenommen, Warteplätze mit); wer einen freigegebenen Schulvertrag für dieses Schuljahr hat, ist eingeschrieben; wer am Ende seiner Schulart steht und keinen hat, bekommt den 31. Juli als Austrittsdatum; die Klassenzuordnung des Schulartwechslers wird geleert; zum selben Tag enden Schulvertrag, Hortvertrag samt Modulen und Essensabo. Mails an alle Sorgeberechtigten abgehender Kinder und an jede Familie, deren Hortvertrag endet, ohne dass das Kind abgeht. Der Elternbonus-Lauf geht ihm voraus (14).

GET /school-years/{school_year}/rollover zeigt heute an, was nie geschieht — die Ansicht ist gebaut, der Lauf nicht.

Zwei Dinge sind vor dem Bau zu entscheiden und nicht zu raten: woran der Lauf erkennt, dass er dieses Jahr schon lief (die Enden, die er setzt, sind keine eindeutige Marke — eine Spalte dafür wäre eine Migration), und wie er die Enden der drei fremden Verträge abruft, statt ihre Regeln selbst zu kennen (api/stammdaten-api.md, "Was an den Rand stößt").

Gefunden im dreizehnten API-Prüfzyklus als STAMMDATEN-R9.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Marke ist entschieden und benannt, bevor Code entsteht
- [ ] #2 Eine Run-Zeile in app/runs.py unter dem Aktor system:rollover
- [ ] #3 Zweimal hintereinander gerufen passiert beim zweiten Mal nichts
- [ ] #4 Die Enden der Verträge holt der Lauf bei den Domänen, die sie führen
- [ ] #5 Ein Test in tests/test_runs.py deckt Aufsteiger, Wiederholer, Neuzugang und Abgang ab
<!-- AC:END -->
