---
id: TASK-031
title: Die Staatsangehörigkeitsbezeichnungen einmal lesen
status: Done
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-29 12:23'
labels:
  - wb-backend
  - werteliste
milestone: m-1
dependencies: []
references:
  - schema/stammdaten-schema.sql
ordinal: 31000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Alle 249 Zeilen gelesen, ohne Befund. Die zwei Regeln, die der Seed-Kommentar aufstellt, halten durchgehend: abhängige Gebiete tragen die Staatsangehörigkeit ihres Passstaats (13× britisch, 12× französisch, 5× amerikanisch, 4× niederländisch, 4× australisch, 3× neuseeländisch, 2× dänisch, 2× norwegisch, 2× chinesisch, 1× finnisch), und Antarktis und Westsahara tragen ihren Namen, weil sie als Geburtsort existieren und nicht als Staatsangehörigkeit. Die Bezeichnungen, die leicht falsch aussehen, sind die amtlich richtigen: 'dominicanisch' für Dominica neben 'dominikanisch' für die Dominikanische Republik, 'nigrisch' für Niger neben 'nigerianisch' für Nigeria, 'von St. Kitts und Nevis' und 'von Trinidad und Tobago' als Umschreibungen ohne Adjektiv. Die einzige schiefe Zeile ist keine Staatsangehörigkeit: CX heißt im Katalog 'Weihnachtsinseln'. Sie bleibt, weil die Spalte dem iso-codes-Katalog folgt — die Begründung steht jetzt im Seed-Kommentar.
<!-- SECTION:DESCRIPTION:END -->
