---
id: TASK-267
title: Schulart am Vertrag und die Pruefsummen in wb-backend nachziehen
status: To Do
assignee: []
created_date: '2026-09-05 00:34'
labels:
  - schema
  - wb-backend
  - anmeldung
  - dokumente
milestone: m-5
dependencies: []
references:
  - schema/anmeldung-schema.sql
  - schema/querschnitt-schema.sql
  - schema/stammdaten-schema.sql
ordinal: 280000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
wb-backend fuehrt das Schema; die Aenderungen dieses Laufs stehen hier in `schema/` und dort noch nicht. Solange nichts produktiv laeuft, wird die Ursprungsrevision ueberschrieben und die Datenbank neu aufgesetzt (CLAUDE.md).

Vier Strukturaenderungen in einer Revision:

1. **`contracts.school_branch_id`** samt `fk_contracts_application_branch`, `fk_contracts_text_branch` und `ck_contracts_branch` (TASK-262), dazu `uq_applications_id_branch` und `contract_text_kinds.school_branch_id` mit `uq_contract_text_kinds_code_branch`. Die Route setzt die Spalte aus der Bewerbung und waehlt danach die Textsorte — nie aus dem Rumpf.
2. **`ck_contracts_checksum`** erzwingt `sha256:<64 Hexstellen>` (TASK-240). `build_contract_document` schreibt heute den rohen `hexdigest()` und laeuft damit gegen den CHECK; dasselbe Format traegt `ck_contract_amendments_checksum` jetzt ebenfalls.
3. **Pruefsumme an jedem unterschriebenen Dokument** (TASK-247): `sepa_mandates.document_checksum`, `consents.document_checksum`, `care_module_agreements.document_id` samt `document_checksum`, `photo_consent_records.document_checksum`. Der Lauf, der den Fotonachweis kopiert, nimmt sie mit (TASK-246).
4. **`contract_text_kinds.child_file_category_id`** (TASK-235) — der Leser dieser Spalte ist TASK-235 Kriterium 4 und steht dort, nicht hier.

Der Loesch-Lauf raeumt `care_module_agreements` jetzt vor `documents`: Die Modulanlage haelt ihre Ausfertigung mit NO ACTION fest und geht per Cascade mit ihrem Vertrag.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Ursprungsrevision traegt alle vier Aenderungen, die Datenbank ist neu aufgesetzt
- [ ] #2 build_contract_document schreibt die Pruefsumme mit sha256-Praefix; ein Test faellt ohne es rot
- [ ] #3 Die Vertragsroute setzt school_branch_id aus der Bewerbung und waehlt die Textsorte danach — Gegenprobe: ein Rumpf mit fremder Schulart aendert nichts
- [ ] #4 Die Modulanlage legt ihre Ausfertigung samt Pruefsumme ab, sobald die Hortleitung sie freigibt
- [ ] #5 Der Loesch-Lauf raeumt die Modulanlage vor der Datei, die sie festhaelt
<!-- AC:END -->
