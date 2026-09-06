---
id: TASK-160
title: Die Notfalleinsicht in der Oberfläche bauen
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-03 14:51'
labels:
  - wb-elternportal
  - wb-intern
  - gesundheit
  - dsgvo
  - wartet
dependencies:
  - TASK-156
references:
  - pruefberichte/fragen-datenschutz.txt
  - schema/gesundheit-schema.sql
  - oberflaechen.md
ordinal: 172000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beschlossen am 01.09.2026: eine Taste am Kind, die jedem Mitarbeitenden für jedes Kind einen engen Notfallausschnitt zeigt — Handlungshinweise, Notfallmedikation samt Erlaubnis, Allergien, Notfallkontakt. Kein Attest, keine Diagnose, kein Behandlungsgrund: Die retten niemanden und wären die Punkte, an denen die Konstruktion kippt.

Damit die Taste im Ernstfall etwas nützt, muss jeder Mitarbeitende jedes Kind finden können, über beide Schularten hinweg. Das ist eine eigene Offenlegung von Name und Klasse und gehört benannt, nicht nebenbei mitgeliefert.

Die Taste sagt vor dem Druck, dass der Zugriff protokolliert wird. Das Protokoll ist der Schutz — eine Genehmigungskette wäre bei einem Anfall auf dem Schulhof das falsche Bauteil.

Wer das Protokoll ansieht und wie lange es bleibt, entscheidet der Datenschutzbeauftragte.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Taste steht an jedem Kind und ist für jede Mitarbeitendenrolle erreichbar
- [ ] #2 Vor dem Druck steht, dass der Zugriff protokolliert wird
- [ ] #3 Der Ausschnitt enthält keine Diagnose, kein Attest und keinen Behandlungsgrund
- [ ] #4 Die Suche über alle Kinder beider Schularten steht jedem Mitarbeitenden offen
- [x] #5 Eine Ansicht des Protokolls existiert — wer sie sehen darf, folgt der Antwort des Datenschutzbeauftragten
- [ ] #6 Die Meldung an die Geschäftsführung geht direkt beim Auslösen der Einsicht, im selben Vorgang — kein Lauf, keine Frist dazwischen (03.09.2026). Die 'Frist 1 h' aus der Antwort des Datenschutzbeauftragten ist damit erfüllt und nicht die Dauer der Einsicht
- [ ] #7 Das Protokoll geht mit dem Kind: seine Frist beginnt mit dem Austritt, nicht mit dem Zugriff (03.09.2026)
<!-- AC:END -->
