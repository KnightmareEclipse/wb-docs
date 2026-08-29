---
id: TASK-029
title: Die vierzehn Prüfskripte als fester Schritt hinter jedem Migrationslauf
status: Done
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-28 22:40'
labels:
  - wb-backend
  - schema
  - test
milestone: m-1
dependencies: []
references:
  - wb-backend/CLAUDE.md
  - schema/stammdaten-schema-check.sql
  - prompts/schema-uebertragen.md
ordinal: 29000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gegen die von Alembic gebaute Datenbank braucht der Schritt seit dem Anfangsbestand einen Vorspann, sonst scheitern dreizehn von vierzehn an einem doppelten Schlüssel. Der Rückgabewert wird vor jeder anderen Auswertung in eine Variable geschrieben — sonst ist der Lauf grün, auch der gescheiterte.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 TRUNCATE-Vorspann in derselben Transaktion, Tabellenliste aus SEEDED_TABLES
- [x] #2 rc=$? direkt hinter dem Aufruf, vor jeder Kommando-Ersetzung
- [x] #3 Läuft als Schritt, nicht als einmalige Sichtprüfung
<!-- AC:END -->
