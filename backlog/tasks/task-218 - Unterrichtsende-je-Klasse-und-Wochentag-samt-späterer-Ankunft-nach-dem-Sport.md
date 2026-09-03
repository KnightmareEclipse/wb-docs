---
id: TASK-218
title: 'Unterrichtsende je Klasse und Wochentag, samt späterer Ankunft nach dem Sport'
status: To Do
assignee: []
created_date: '2026-09-03 17:11'
labels:
  - schema
  - klassenorganisation
dependencies: []
references:
  - schema/klassenorganisation-schema.sql
  - soll-prozesse/09-hortvertrag.md
  - schema/stammdaten-schema.sql
ordinal: 231000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beschrieben am 03.09.2026: Der Hort führt heute, **wann welche Klasse Unterrichtsende hat**. Das ist keine Neugier, sondern Betriebsplanung — er weiß daran, wann er mit wie vielen Kindern rechnet.

Und er führt eine Abweichung mit: **Wo Sport am Unterrichtsende liegt, kommen die Kinder später.** Die Schule hat keine eigene Sporthalle, die Halle ist extern, und die Eltern fahren die Kinder anschließend zur Schule zurück — das ist Teil der Elternarbeit. Für den Hort heißt das schlicht: An diesem Wochentag trifft diese Klasse später ein.

**Gebraucht wird eine Zeile je Klasse und Wochentag** mit zwei Zeiten: wann der Unterricht endet, und — wo es abweicht — wann die Kinder im Hort ankommen. Der Grund gehört als kurze Notiz daneben und nicht als Struktur: „Sport, Rückfahrt" trägt keine Regel, es erklärt nur die zweite Zeit. Ein Häkchen „Sport" wäre die Struktur für genau einen Fall und ließe den nächsten (Schwimmen, ein Ausflug am Vormittag) wieder daneben stehen.

**Das ist kein Stundenplan und wird keiner.** Eine Zeit je Klasse und Wochentag beantwortet die Frage des Horts vollständig; Untis bleibt out of scope, und weder Fächer noch Stunden noch Räume entstehen hier. Wer später eine Stundenplanfrage stellt, bekommt eine eigene Domäne und nicht diese Tabelle.

Sie gehört zu `klassenorganisation` — dieselbe Domäne wie das Unterrichtsverhältnis, dieselbe Pflege: je Schuljahr, von der Stelle, die den Deputatsplan ohnehin macht (TASK-161).

**Die Fahrten zur Sporthalle werden nicht ausgeschrieben** (Betreiber, 03.09.2026). Sie sind Elternarbeit, aber die Eltern regeln sie unter sich und tragen die Stunden hinterher ein — die Eintragung läuft ohnehin auf Vertrauensbasis. Das Schema trägt das bereits und nennt genau diesen Fall: `parent_work_entries.parent_work_session_id` ist freiwillig, „Was die Eltern unter sich regeln — der Fahrdienst der Grundschule vor allem — wird ohne Einsatz eingetragen" (14 Z4). Für dieses Ticket folgt daraus nichts als die Feststellung, dass daraus nichts folgt.
