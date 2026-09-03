---
id: TASK-216
title: Hort-Belegungsliste aus dem System erzeugen
status: To Do
assignee: []
created_date: '2026-09-03 16:38'
labels:
  - wartet
  - anmeldung
dependencies: []
references:
  - soll-prozesse/09-hortvertrag.md
  - fragen.md
ordinal: 229000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus [M3]: Jürgen fragt, ob die Hort-Belegungsliste mit ihren verschiedenen Sheets künftig aus Weltenbaum erzeugt werden kann.

**Beantwortbar ist das erst mit ihrer Struktur.** Die Datei im Anhang ist bewusst ungelesen geblieben; gefragt ist nicht sie, sondern was in ihr steht: Sheet-Namen und Spaltenüberschriften (fragen.md Frage 10). Erst daran ist zu sehen, welche Spalten Weltenbaum schon führt und welche Angaben fehlen — und ob am Ende eine [frisch erzeugte Liste](../../soll-prozesse/hebel.md#frisch-erzeugte-liste) herauskommt oder ein Export.

Wahrscheinlich, aber unbelegt: Die Liste mischt Belegung, Abwesenheiten und Beiträge, also Dinge aus `anmeldung-schema.sql` und `mensa-schema.sql`. Das ist zu prüfen und nicht anzunehmen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Je Sheet ist benannt, welche Spalten Weltenbaum führt und welche fehlen
- [ ] #2 Entschieden, ob es eine frisch erzeugte Liste wird oder ein Export
- [ ] #3 Erst nach der Antwort auf fragen.md Frage 10
<!-- AC:END -->
