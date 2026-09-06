---
id: TASK-139
title: Zwei Rückfragen an die Buchhaltung zur Projekt- und Kontenliste
status: To Do
assignee: []
created_date: '2026-08-30 17:59'
labels:
  - wartet
  - buchhaltung
  - rechnungsfreigabe
  - werteliste
milestone: m-5
dependencies: []
references:
  - api/rechnungsfreigabe-api.md
  - >-
    wb-backend/app/alembic/versions/20260822_1458_ebf1b8885558_value_list_seed.py
priority: low
ordinal: 151000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beim Übernehmen der Liste aus dem Beleg-Portal (TASK-133) sind zwei Punkte aufgefallen, die keine Tippfehler sind und deshalb nicht mitkorrigiert wurden. Erstens: 'Sonstiges' ist der Auffangwert für Projekte, die nie abgebildet wurden — welche fehlen? Jede nachgetragene Zeile nimmt ihm Last ab; die Buchhaltung legt sie über POST /cost-projects selbst an. Zweitens: '6477 - Investitionen (>982€)' steht direkt über '6470 - GWG (Geringwertige Güter 297,50-952€)'. 297,50 und 952 sind 250 bzw. 800 Euro plus 19 Prozent, 982 fällt aus der Reihe — Zahlendreher oder so gewollt? Richtiggestellt wird er über PATCH /ledger-accounts, wenn die Antwort da ist.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die fehlenden Projekte sind benannt oder es sind keine
- [ ] #2 982 ist bestätigt oder auf 952 korrigiert
<!-- AC:END -->
