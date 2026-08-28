---
id: TASK-037
title: 'Stammdaten-Schema: Durchsicht durch den zweiten Admin entfällt'
status: Done
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-08-28 16:32'
labels:
  - zweiter-admin
  - entscheidung
milestone: m-1
dependencies: []
references:
  - grenzkarte.md
  - schema/stammdaten-schema.sql
priority: high
ordinal: 37000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Verworfen, nicht vergessen. Der zweite Admin ist selbstständig und rechnet 95 EUR je Stunde ab, und seine Stärke ist der Betrieb von ASV-BW und M365, nicht das Lesen von DDL — eine Durchsicht hätte teuer bezahlt, was sie am wenigsten gut findet. An ihre Stelle tritt der Probelauf des Vollimports gegen eine Wegwerf-Datenbank (036): Der reale Export prüft dieselbe Frage schärfer, weil er jede Abweichung zeigt statt nur die, die jemandem beim Lesen auffällt. Was der Export nicht zeigt, ist ein Feld, das nie erhoben wurde und trotzdem fehlt — dafür tragen prozesse.md und die vier Anmeldetag-Checklisten die real erhobenen Felder, und die Soll-Blöcke sind ohnehin die Quelle. Sein operatives Wissen wird weiter gebraucht, aber als Frage im Gespräch (046) und nicht als bezahlte Sitzung.
<!-- SECTION:DESCRIPTION:END -->
