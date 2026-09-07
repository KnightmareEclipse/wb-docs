---
id: TASK-038
title: >-
  Zweck der Voranmeldefelder Beruf, Konfession, Staatsangehörigkeit,
  Kirchengemeinde beschließen
status: In Progress
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-09-03 00:44'
labels:
  - wartet
  - schulleitung
  - dsgvo
milestone: m-1
dependencies: []
references:
  - fragen.md
priority: high
ordinal: 38000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Alle vier Felder bleiben erhoben — entschieden am 07.09.2026 im Gespräch aller Beteiligten. Damit ist kein DROP COLUMN mehr in Sicht und keine Frist an den Vollimport gebunden. Offen ist allein der benannte Zweck je Feld: Konfession ist ein Art.-9-Datum, ein Feld ohne beschlossenen Zweck mit echten Personendaten zu füllen schließt rules.md Abschnitt 7 aus, und das Verarbeitungsverzeichnis führt diese vier als einzige Zeile ohne Rechtsgrundlage.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Je Feld ein benannter Zweck, belastbar genug für die Zeile im Verarbeitungsverzeichnis
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Am 02.09.2026 datenschutzrechtlich beantwortet: kein Erlaubnistatbestand, die vier Felder können nur als freiwillige stehen bleiben, und die Freiwilligkeit muss beim Ausfüllen ersichtlich sein. Am 07.09.2026 fachlich zur Hälfte: Alle vier bleiben. Beides eingetragen in schema/stammdaten-schema.sql und soll-prozesse/05-bewerbung.md. Offen bleibt der Zweck je Feld; das entscheidet die Schulleitung.
<!-- SECTION:NOTES:END -->
