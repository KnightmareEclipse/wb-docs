---
id: TASK-273
title: >-
  Schreibpfad für class_teaching_assignments und child_group_memberships, dann
  staff_sees_child verengen
status: To Do
assignee: []
created_date: '2026-09-06 00:09'
labels:
  - wb-backend
  - stammdaten
  - klassenorganisation
  - gesundheit
dependencies: []
ordinal: 286000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der geteilte Sichtkreis `staff_sees_child` (`app/core/security.py`) endet mit `TEACHER_ROLE in user.roles` — jede Lehrkraft erreicht jedes Kind, über `reach_child` an jeder Stelle, die ihn ruft, nicht nur an der Klassenliste. Das widerspricht dem eigenen Anspruch aus `api/stammdaten-api.md`, "Auf Zukunftssicherheit" 4: "Der Ownership-Check ist überall eine Bedingung über Daten … nie eine Aufzählung von Rollen."

Die engere Regel ist für Gesundheitsangaben bereits entschieden und dokumentiert (TASK-161, `api/gesundheit-api.md`, "Zuständig für ein Kind ist, wer es unterrichtet" — Klassenleitung, `class_teaching_assignments` oder `child_group_memberships`). Das Schema trägt beide Tabellen (`schema/klassenorganisation-schema.sql`), `wb-backend` aber keinen Schreibpfad dafür — eine Migration und die Pflege-Routen fehlen. `is_class_teacher` prüft heute nur `classes.class_teacher_id` und wird als zusätzliche, engere Prüfung neben `reach_child" nur an zwei Stellen in `app/routers/gesundheit.py` gerufen (Zeile 124, 531) — nicht an jeder Route, die ein Kind liest.

Solange der Schreibpfad fehlt, ließe eine Verengung von `staff_sees_child` selbst jede Fachlehrkraft ohne eigene Klassenleitung ins Leere laufen. Deshalb zwei Schritte in dieser Reihenfolge: erst die Pflege-Routen für beide Zuordnungen (wer pflegt, ist in TASK-161 bereits entschieden — Klassenlehrkraft, Sekretariat, Schulleitung), dann `staff_sees_child` auf die drei Zuordnungen verengen, und die beiden gesundheitsspezifischen Extra-Prüfungen in `gesundheit.py` können danach entfallen, weil der geteilte Hebel sie schon trägt.

Gefunden im dreizehnten API-Prüfzyklus als GESAMT-R5 (`pruefberichte/routen.md`, Abschnitt 6), aufbauend auf STAMM-R3 (`pruefberichte/routen-stammdaten.md`).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Route zum Setzen und Entfernen einer Lehrkraft-Klasse-Zuordnung je Schuljahr
- [ ] #2 Eine Route zum Setzen und Entfernen einer Wahlmodulgruppen-Lehrkraft
- [ ] #3 staff_sees_child prüft class_teacher_id, class_teaching_assignments und child_group_memberships statt der bloßen Rolle
- [ ] #4 gesundheit.py verliert seine beiden eigenen is_class_teacher-Zusatzprüfungen, sobald der Hebel sie trägt
- [ ] #5 Ein Test je Zuordnungsart: eine fremde Lehrkraft ohne Zuordnung bekommt 404
<!-- AC:END -->
