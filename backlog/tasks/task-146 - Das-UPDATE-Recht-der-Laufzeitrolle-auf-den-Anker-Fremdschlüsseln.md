---
id: TASK-146
title: Das UPDATE-Recht der Laufzeitrolle auf den Anker-Fremdschlüsseln
status: To Do
assignee: []
created_date: '2026-08-31 14:45'
labels:
  - wb-backend
  - gesundheit
  - schema
milestone: m-5
dependencies: []
references:
  - schema/gesundheit-schema.sql
  - container.md
ordinal: 158000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Migration der Gesundheits-Domäne gibt der Laufzeitrolle GRANT UPDATE (child_id, presented_on, measles_presentation_type_id) ON measles_proofs. Keine Route ändert je measles_proofs.child_id — set_measles_proof setzt ihn allein beim Anlegen. Das Recht erlaubt, einen vorhandenen Nachweis einem anderen Kind zuzuschreiben, und child_id ist zugleich der Änderungsanker der Tabelle.

Der Fund trägt weiter als die eine Zeile, und deshalb ist er ein Ticket statt einer Reparatur im Vorbeigehen: Dieselbe Bauform steht auf rund vierzig Tabellen quer durch alle Domänen — child_health_records.child_id in derselben Migration, child_meal_profiles.child_id, documents.child_id, family_guardians.family_id. Eine einzelne Zeile enger zu ziehen macht das Schema uneinheitlich, ohne die Klasse zu schließen; alle zusammen ist eine Schema-Entscheidung, die ihren eigenen Prüfzyklus verdient. CLAUDE.md des Backends verlangt heute nur, dass UPDATE spaltenweise steht, nicht dass der Ankerschlüssel draußen bleibt.

Zu entscheiden ist, ob der Änderungsanker einer Tabelle grundsätzlich aus dem UPDATE-GRANT fällt. Dagegen spricht, dass eine Route eine Zeile bewusst umhängen können muss, wo ein Block das vorsieht; dafür spricht, dass die Immutabilität der Schlüsselspalten laut container.md genau an diesen GRANTs hängt und sonst nur die Route sie trägt. Fällt die Entscheidung dafür, gehört sie in tests/test_privileges.py als vierte Bedingung aus dem Katalog — die Datei hält bewusst keine Liste sensibler Spalten von Hand.

Gefunden im dreizehnten API-Prüfzyklus als GESUNDHEIT-R14, der einzige offen gebliebene Fund der Domäne.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden: Ankerschlüssel grundsätzlich ohne UPDATE, oder ausgeschriebene Zeile, dass das Recht bleibt
- [ ] #2 Bei Entzug: alle betroffenen Migrationen in einem Zug, nicht die eine der Gesundheit
- [ ] #3 Bei Entzug: die Bedingung steht in tests/test_privileges.py, aus dem Katalog gelesen und nicht als Spaltenliste
- [ ] #4 Die Entscheidung steht als Satz in CLAUDE.md des Backends, Abschnitt 6
<!-- AC:END -->
