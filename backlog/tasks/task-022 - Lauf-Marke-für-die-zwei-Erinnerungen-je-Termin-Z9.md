---
id: TASK-022
title: Lauf-Marke für die zwei Erinnerungen je Termin (Z9)
status: Done
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - wb-backend
  - putzdienst
  - lauf
  - schema
milestone: m-0
dependencies: []
references:
  - schema/putzdienst-schema.sql
ordinal: 22000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
An cleaning_slots. Hängt an der Freigabe der Zuteilung. Welche Form sie bekommt, entscheidet der Bau des Laufs; eine Zustandsdatei neben der Datenbank ist keine davon. allocation_released_at ist dafür nicht zu gebrauchen — sie trägt die Freigabe durch das Sekretariat, nicht den Lauf.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Marke an cleaning_slots, als Migration in wb-backend voran
- [x] #2 Der erste Termin des Jahres wird nicht doppelt erinnert (die Zuteilungsmail ist bereits die erste Erinnerung)
<!-- AC:END -->
