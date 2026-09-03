---
id: TASK-157
title: Die Sichtkreise in der Datenbank durchsetzen statt in drei Views
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-03 16:39'
labels:
  - wb-backend
  - gesundheit
  - dsgvo
dependencies:
  - TASK-161
references:
  - wb-backend/tests/test_privileges.py
  - api/gesundheit-api.md
  - schema/gesundheit-schema.sql
ordinal: 169000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Heute tragen drei Rollen und zwei Views den Zuschnitt: backend_health, backend_health_everyday auf everyday_health_traits, backend_kitchen auf kitchen_health_traits. Das trug drei ineinanderliegende Stufen; bei überschneidenden Sichtkreisen wäre jeder weitere Zuschnitt eine weitere View und damit eine Migration.

Stattdessen eine Regel über Daten: **eine Policy**, die `health_trait_values` filtert. Sie prüft seit den Beschlüssen vom 02./03.09.2026 **drei Dinge** statt eines, und alle drei sind Zeilen:

1. **Trägt der Sichtkreis das Feld?** — `health_field_visibility`, samt `presence_only` für das Attest (TASK-206).
2. **Ist die Angabe dieser Instanz freigegeben?** — die Freigabe je Angabe und Instanz (TASK-205). Der Notfallausschnitt übergeht diese Bedingung ausdrücklich, die Küche erbt die Freigabe der Liste, auf der sie steht.
3. **Ist die aufrufende Person für dieses Kind zuständig?** — die zweite Achse (TASK-161): Klassenleitung, Unterricht in seiner Klasse, oder eine Wahlmodulgruppe, in der es Mitglied ist.

Drei Bedingungen, eine Policy. Ein neuer Sichtkreis bleibt eine Zeile, ein neues Feld ebenso, und eine neue Zuständigkeit ist eine Zeile in der zweiten Achse — kein Schema-Eingriff.

**Reihenfolge:** TASK-161 zuerst, sonst hat Bedingung 3 nichts zum Prüfen. TASK-205 und TASK-206 gehören in denselben Durchgang wie diese Policy, weil sie dieselben Tabellen und dieselben Kommentare anfassen.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf) und in grenzkarte.md ("Zugriff, je Angabe").
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Policy statt drei Views; die drei abgeleiteten Sichten sind fort oder als abgeleitet begründet
- [ ] #2 Alle drei Bedingungen greifen: Feld im Sichtkreis, Angabe freigegeben, Kind in der Zuständigkeit
- [ ] #3 Der Notfallausschnitt übergeht die Freigabe — als Gegenprobe
- [ ] #4 Ein neuer Sichtkreis ist eine Zeile und keine Migration — als Gegenprobe
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Zwischenstand aus dem Nachtlauf (02.09.2026): Bis zur Policy sind die Sichtkreise sechs Sichten health_values_<code> aus einer Definition in der Gesundheits-Revision, je mit eigener DB-Rolle (backend_health, _class_lead, _care, _sports, _emergency; kitchen liest backend_kitchen). everyday_health_traits und kitchen_health_traits bleiben als abgeleitete Sichten über care und kitchen, damit Ferien und Mensa nicht anfassen mussten. test_a_field_added_to_a_sight_is_a_row_and_not_a_release zeigt, dass ein Feld eine Zeile ist; ein neuer Sichtkreis ist bis hierhin noch eine Zeile plus eine Sicht.
<!-- SECTION:NOTES:END -->
