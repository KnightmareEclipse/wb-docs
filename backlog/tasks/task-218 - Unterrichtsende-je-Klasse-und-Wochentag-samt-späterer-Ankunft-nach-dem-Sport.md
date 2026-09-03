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

`[?]` **Nebenbefund für den Elternbonus:** Die Fahrten zur Sporthalle sind Elternarbeit. Ob sie als Einsatz im Portal ausgeschrieben und angemeldet werden sollen wie die übrigen (14), ist nicht gefragt worden — es liegt aber nahe und wäre ein Anlass mehr, kein neuer Mechanismus.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Zeile je Klasse und Wochentag mit Unterrichtsende und, wo abweichend, der Ankunftszeit im Hort
- [ ] #2 Der Grund steht als Notiz und nicht als Häkchen — kein Feld für 'Sport'
- [ ] #3 Kein Fach, keine Stunde, kein Raum: Die Tabelle bleibt eine Zeit je Klasse und Wochentag
- [ ] #4 Eine Ankunftszeit vor dem Unterrichtsende wird abgewiesen
- [ ] #5 Die Zeiten hängen am Schuljahr und werden wie die Unterrichtsverteilung gepflegt
<!-- AC:END -->
