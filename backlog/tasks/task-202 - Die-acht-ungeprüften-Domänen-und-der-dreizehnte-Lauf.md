---
id: TASK-202
title: Die acht ungeprüften Domänen und der dreizehnte Lauf
status: To Do
assignee: []
created_date: '2026-09-02 23:44'
updated_date: '2026-09-05 15:34'
labels:
  - wb-backend
  - pruefzyklus
dependencies:
  - TASK-198
references:
  - prompts/api-pruefen.md
ordinal: 215000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vier der zwölf Domänen sind durch prompts/api-pruefen.md gegangen: cleaning, gesundheit, elternbonus, anmeldung. Offen sind klassenorganisation, payments, auth, mensa, ferien, querschnitt, rechnungsfreigabe und stammdaten — je eine frische Session, höchstens drei nebeneinander —, danach der dreizehnte Lauf über alle zwölf. Geprüft wird wertelisten-und-log-filter (c4ef05a); der Nullpunkt sind 806 grüne Tests, und der Commit steht im Kopf jedes Berichts, damit die parallelen Sessions vergleichbar bleiben. Die zwei Lücken im Rezept sind mit TASK-203 geschlossen, der Rückstand der Schemata mit TASK-269 — die Läufe prüfen die Routen jetzt gegen dasselbe Schema, das wb-docs beschreibt. Solange Läufe offen sind, wird in keinem der beiden Hauptbäume gearbeitet: wb-backend ist der eingefrorene Prüfstand, wb-docs die Auftragsquelle.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Acht Berichte liegen in pruefberichte/, einer je Domäne
- [ ] #2 Der dreizehnte Lauf ist gelaufen, pruefberichte/routen.md liegt
- [ ] #3 Die zwei Zahlen stehen darin: wie viele der 235 Routen einen Test haben und wie viele einen auf die fremde Id
<!-- AC:END -->
