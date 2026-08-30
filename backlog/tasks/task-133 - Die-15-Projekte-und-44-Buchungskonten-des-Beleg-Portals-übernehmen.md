---
id: TASK-133
title: Die 15 Projekte und 44 Buchungskonten des Beleg-Portals übernehmen
status: To Do
assignee: []
created_date: '2026-08-30 15:09'
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
