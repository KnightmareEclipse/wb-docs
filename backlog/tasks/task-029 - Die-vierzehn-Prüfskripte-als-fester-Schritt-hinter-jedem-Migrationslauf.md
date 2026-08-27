---
id: TASK-029
title: Die vierzehn Prüfskripte als fester Schritt hinter jedem Migrationslauf
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
labels:
  - wb-backend
  - schema
  - test
milestone: m-1
dependencies: []
references:
  - TODO-SESSIONS.md
ordinal: 29000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gegen die von Alembic gebaute Datenbank braucht der Schritt seit dem Anfangsbestand einen Vorspann, sonst scheitern dreizehn von vierzehn an einem doppelten Schlüssel. Der Rückgabewert wird vor jeder anderen Auswertung in eine Variable geschrieben — sonst ist der Lauf grün, auch der gescheiterte.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 TRUNCATE-Vorspann in derselben Transaktion, Tabellenliste aus SEEDED_TABLES
- [ ] #2 rc=$? direkt hinter dem Aufruf, vor jeder Kommando-Ersetzung
- [ ] #3 Läuft als Schritt, nicht als einmalige Sichtprüfung
<!-- AC:END -->
