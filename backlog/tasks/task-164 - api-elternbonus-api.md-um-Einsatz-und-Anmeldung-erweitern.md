---
id: TASK-164
title: api/elternbonus-api.md um Einsatz und Anmeldung erweitern
status: To Do
assignee: []
created_date: '2026-09-01 17:46'
updated_date: '2026-09-01 18:09'
labels:
  - wb-docs
  - api-plan
  - elternbonus
dependencies: []
references:
  - api/elternbonus-api.md
  - soll-prozesse/14-elternbonus.md
  - schema/elternbonus-schema.sql
  - prompts/api-planen.md
ordinal: 176000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zwei Routen fallen ersatzlos — PUT /parent-work-entries/{id}/decision und GET /parent-work-entries/confirmed —, denn es wird nicht mehr bestätigt. Mit ihnen fällt der Elternbonus als Aufrufer von GET /employees/selectable; die Route bleibt, weil 12 und 15 sie brauchen, aber die KITA-Ausnahme, die TASK-147 dort beschreibt, hat keinen Anlass mehr.

Neu zu planen sind die Routen für den Einsatz (anlegen, ändern, absagen, die Liste der Angemeldeten) und für die Anmeldung (an- und abmelden). Vier Punkte entscheiden sich dabei:

1. **Wer ausschreiben darf** — sechs Rollen, in 14 benannt: caretaker, teacher, secretariat, school_management, domestic_services_management, day_care_management. Keine neue Rolle, keine Spalte; die Route nennt ihre Rollen wie jede andere.
2. **Wer einen Einsatz sieht** — ohne Zielgruppe alle Familien, sonst die Vereinigung aus benannten Klassen und Zuschnitten (Schulart, Stufe ab, Stufe bis). Ausgewertet gegen das Kind (children.class_id, school_branch_id, grade_level). Das gehört in die Datenbank und nicht in den Anwendungscode — und es ist die Query, die diesen Plan am ehesten überrascht.
3. **Die Anmeldeliste** — Namen für den Ausschreibenden, für die Eltern nur die Zahl.
4. **Die volle Platzzahl** — der Trigger wirft check_violation. Die Route muss daraus eine Meldung machen, die sagt, was los ist ("Der Einsatz ist voll"), und keinen 500er.

Ein Durchgang nach prompts/api-planen.md samt der Gegenprobe Ablaufzeilen zu Routen.

Entschieden am 01.09.2026 mit der Geschäftsführung. Ablauf in soll-prozesse/14-elternbonus.md, Struktur in schema/elternbonus-schema.sql.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die zwei Bestätigungsrouten sind fort, keine Datei verweist noch auf sie
- [ ] #2 Routen für Einsatz und Anmeldung stehen, samt der Rolle, die ausschreiben darf
- [ ] #3 Der Sichtbarkeitsschnitt der Anmeldeliste ist begründet: Zahl für die Eltern, Namen für den Hausmeister
- [ ] #4 Die Absage nennt ihre Mail an die Angemeldeten
- [ ] #5 Die Gegenprobe Ablaufzeilen zu Routen ist gerechnet und ohne Abweichung
<!-- AC:END -->
