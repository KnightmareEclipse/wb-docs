---
id: TASK-133
title: Die 15 Projekte und 44 Buchungskonten des Beleg-Portals übernehmen
status: Done
assignee: []
created_date: '2026-08-30 15:09'
updated_date: '2026-08-30 18:02'
labels:
  - wb-backend
  - rechnungsfreigabe
  - werteliste
  - buchhaltung
milestone: m-5
dependencies:
  - TASK-074
references:
  - api/rechnungsfreigabe-api.md
  - schema/rechnungsfreigabe-schema.sql
  - prozesse.md
ordinal: 145000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Anfangsbestand für cost_projects und ledger_accounts. Die Werte stehen als Strings in ~/Documents/SPFX/bookingreceiptprocess/src/src/webparts/bookingReceiptProcess/models/enums.ts (ClaimProjectOptionValues, ClaimBookingAccountValues), je Zeile Code und Name in einem String ('200 - Grundschule', '6330 - Büromittel') — beim Übernehmen getrennt, weil das Schema zwei Spalten hat. Die Konten folgen dem Optigem-Kontenrahmen. Zwei Punkte klären: das Projekt 'Sonstiges' hat keinen Code, cost_projects.code ist aber NOT NULL UNIQUE; und die vier Bezeichnungen mit Tippfehler, die heute nicht korrigierbar sind, werden hier richtiggestellt.
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
15 Projekte und 44 Konten stehen im Seed der Werteliste-Revision, nicht in einer eigenen: dieselbe Datei, die payment_routes trägt. Vier Bezeichnungen richtiggestellt (Haustierkosten, Telekommunikation, Spendenweiterleitung, Außerordentlicher) plus die fehlende Klammer an 6470. 'Sonstiges' bekommt den nicht-numerischen Code 'sonstiges' — es ist kein Projekt, sondern das Loch in der Liste, und nichts, was nach Optigem geht, darf als buchbare Projektnummer lesbar sein; es bleibt, weil ck_expense_claim_items_approved ohnehin ein Projekt erzwingt und ein falsch gewähltes echtes Projekt für die Buchhaltung unsichtbar wäre. Nebenbefund und mitrepariert: Das Fixture in tests/test_rechnungsfreigabe.py leerte cost_projects und ledger_accounts ganz und hätte den Bestand mitgenommen. Zwei offene Punkte gingen an TASK-139.
<!-- SECTION:NOTES:END -->
