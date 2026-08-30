---
id: TASK-134
title: Der Zahlweg wird eine Werteliste statt eines CHECK
status: Done
assignee: []
created_date: '2026-08-30 15:19'
updated_date: '2026-08-30 18:35'
labels:
  - wb-backend
  - schema
  - rechnungsfreigabe
  - werteliste
milestone: m-5
dependencies: []
references:
  - schema/rechnungsfreigabe-schema.sql
  - api/rechnungsfreigabe-api.md
  - wb-backend/app/models/rechnungsfreigabe.py
  - wb-backend/app/alembic/versions/20260822_1348_2f7799ca9013_rechnungsfreigabe_domain.py
priority: medium
ordinal: 146000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
ck_expense_claims_route zählt sechs Werte auf; ein siebter kostet heute eine Migration. Neue Tabelle payment_routes (code, name, requires_bank_details, is_reimbursement, is_active). Die zwei CHECKs, die den Wert lesen, sehen keine zweite Tabelle: ck_expense_claims_third_party und ck_expense_claim_items_self_approval brauchen die beiden Merkmale an der Belegzeile mitgeführt, gehalten von zusammengesetzten Fremdschlüsseln — dieselbe Bauform wie Einreicher, Belegart und Betrag in derselben Datei. Angelegt werden Zeilen von Buchhaltung und Geschäftsführung. Migration zuerst in wb-backend, danach schema/rechnungsfreigabe-schema.sql samt Prüfskript und Kopfkommentar nachziehen. Vor TASK-074, sonst baut der Router gegen den alten Stand.
<!-- SECTION:DESCRIPTION:END -->
