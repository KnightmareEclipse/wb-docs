---
id: TASK-157
title: Die Sichtkreise in der Datenbank durchsetzen statt in drei Views
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-03 19:10'
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
Die drei Bedingungen stehen jetzt alle als Zeilen, die Policy fehlt: Bedingung 1
health_field_visibility samt presence_only (TASK-206), Bedingung 2
health_trait_releases (TASK-205), Bedingung 3 die Tabellen der zweiten Achse in
klassenorganisation (TASK-161). Aus sechs Sichtkreisen sind fünf geworden, sports
ist fort (TASK-197).

Zu bauen bleibt der wb-backend-Teil, und er beginnt erst mit dem grünen
Prüfbericht zum Schema: eine Policy statt der fünf Sichten, die zusammengelegten
DB-Rollen, und der Seed mit needs_release, value_kind_code und presence_only.
Bis dahin filtert jede Sicht allein über den Sichtkreis, Zuständigkeit und
Freigabe prüft die Route (api/gesundheit-api.md).
<!-- SECTION:NOTES:END -->
