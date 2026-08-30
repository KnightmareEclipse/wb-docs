---
id: TASK-017
title: 'Import: Dublettenerkennung Kind und Erziehungsberechtigte'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:23'
labels:
  - import
  - stammdaten
milestone: m-1
dependencies: []
references:
  - schema/stammdaten-schema.sql
ordinal: 17000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nachname + Geburtsdatum beim Kind, Vor- + Nachname bei Erziehungsberechtigten. Die E-Mail trägt dort nicht mehr.
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Der genannte Schlüssel trennt Zwillinge nicht: 'Nachname + Geburtsdatum beim Kind' trifft bei zwei Geschwistern derselben Geburt immer, und das Soll führt sie ausdrücklich als zwei Kinder ('Zwillinge sind zwei', 05 Z3; 'Zwillinge sind zwei Verträge', 08). Ein Import, der darüber zusammenführt, macht aus zwei Kindern eines — und das fällt erst auf, wenn eines von beiden in keiner Klassenliste steht. Der Vorname muss in den Schlüssel, oder der Abgleich meldet und führt nicht zusammen. Bei den Erziehungsberechtigten ist der genannte Schlüssel (Vor- und Nachname) aus demselben Grund ein Hinweis und keine Entscheidung. Derselbe Befund steht an TASK-013, das denselben Schlüssel für die laufende Bewerbung vorschlägt.
<!-- SECTION:NOTES:END -->
