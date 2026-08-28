---
id: TASK-129
title: Seed für die Entwicklungsumgebung
status: Done
assignee: []
created_date: '2026-08-28 16:40'
updated_date: '2026-08-28 17:18'
labels:
  - wb-backend
  - test
  - putzdienst
milestone: m-0
dependencies: []
references:
  - schema/stammdaten-schema-check.sql
  - schema/putzdienst-schema-check.sql
ordinal: 500
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Entwickelt und geprüft wird gegen Mockdaten, nicht gegen einen Export — der Vollimport folgt erst, wenn die ersten Prozesse stehen (036). Dafür fehlt der Bestand: Ohne Familien, Kinder und ein eingerichtetes Putzdienstjahr lässt sich keine Route aufrufen. Die vierzehn Prüfskripte bauen genau solche Zeilen schon auf, nur mit ROLLBACK am Ende — der Seed ist dasselbe Muster ohne Rücknahme und wird nicht daneben neu erfunden. Er gehört nach wb-backend, weil dort das Schema geführt wird; hier steht nur, dass es ihn braucht. Er löst nebenbei die Handarbeit ab, mit der die lokale employees-Zeile heute nach jedem Migrations-Replay von Hand wiederkommt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Deckt ab, was Zyklus eins aufrufen kann: mehrere Familien mit eingeschriebenen Kindern, eine mit abweichender Pflichtzahl, eine Mitarbeiterfamilie, eine mit null Terminen, dazu ein Putzdienstjahr mit Terminen beider Arten und offenem Anmeldefenster
- [x] #2 Die lokale employees-Zeile entsteht mit, die Entra-Object-ID kommt aus der Umgebung und steht nicht im Git
- [x] #3 Läuft nur gegen eine leere Datenbank oder bricht ab — ein Seed, der gegen echte Daten laufen kann, ist einer zu viel
- [x] #4 Ein Kommando nach dem Migrationslauf, kein Framework und keine Faker-Abhängigkeit
<!-- AC:END -->
