---
id: TASK-015
title: 'Entscheiden: Löschfrist einer nie zur Aufnahme geführten Fremdanmeldung'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:31'
labels:
  - entscheidung
  - anmeldung
  - dsgvo
milestone: m-1
dependencies:
  - TASK-058.04
references:
  - schema/anmeldung-schema.sql
  - schema/stammdaten-schema.sql
ordinal: 15000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Bewerbung hat eine eigene, kürzere Frist; die mit ihr angelegten Personenzeilen brauchen dieselbe, sonst wächst Stammdaten mit Leuten, die nie an der Schule waren.
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Dieselbe Frage wie TASK-058.04 ('Frist: Bewerbungen ohne Aufnahme'), nur von der anderen Seite: Dort geht es um die Bewerbung, hier um die Personenzeilen, die mit ihr entstanden sind. Beide hängen an einer Antwort der Datenschutzbeauftragten (fragen.md, Abschnitt Datenschutzbeauftragte:r), und beide zweimal zu stellen kostet im Termin Zeit und lädt zu zwei verschiedenen Antworten ein. Deshalb hängt dieses Ticket jetzt an TASK-058.04; zu entscheiden bleibt hier allein, ob die Personenzeilen dieselbe Frist tragen oder eine eigene.
<!-- SECTION:NOTES:END -->
