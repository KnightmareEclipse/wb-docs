---
id: TASK-267
title: Schulart am Vertrag und die Pruefsummen in wb-backend nachziehen
status: To Do
assignee: []
created_date: '2026-09-05 00:34'
updated_date: '2026-09-05 19:56'
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
- [x] #1 Die Ursprungsrevision traegt alle vier Aenderungen, die Datenbank ist neu aufgesetzt
- [x] #2 build_contract_document schreibt die Pruefsumme mit sha256-Praefix; ein Test faellt ohne es rot
- [x] #3 Die Vertragsroute setzt school_branch_id aus der Bewerbung und waehlt die Textsorte danach — Gegenprobe: ein Rumpf mit fremder Schulart aendert nichts
- [ ] #4 Die Modulanlage legt ihre Ausfertigung samt Pruefsumme ab, sobald die Hortleitung sie freigibt
- [ ] #5 Der Loesch-Lauf raeumt die Modulanlage vor der Datei, die sie festhaelt
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gemessen am Baum von wb-backend (9be3efa, Branch wertelisten-und-log-filter).

Kriterium 1 steht. Alle vier Aenderungen stehen in der Ursprungsrevision ihrer Domaene, keine neue Revision daneben: `contracts.school_branch_id` samt `fk_contracts_application_branch`, `fk_contracts_text_branch`, `ck_contracts_branch` und `uq_applications_id_branch` sowie `ck_contracts_checksum` in der Anmeldung-Revision; `contract_text_kinds.school_branch_id` samt `uq_contract_text_kinds_code_branch` und `child_file_category_id` in der Querschnitt-Revision; die Pruefsummen an `sepa_mandates` (Stammdaten), `consents` (Querschnitt), `photo_consent_records` und `care_module_agreements` samt dessen `document_id` (Anmeldung). Die Datenbank traegt sie alle.

Kriterium 2 steht. `build_contract_document` schreibt `f"sha256:{hashlib.sha256(pdf).hexdigest()}"`, und `tests/test_anmeldung.py::test_the_release_builds_the_document_and_clears_the_images` vergleicht genau diese Form — ohne das Praefix faellt er rot.

Kriterium 3 steht. Die Route liest die Schulart aus der Bewerbung (`release_decisions` in app/routers/anmeldung.py: `branch` kommt aus `row.school_branch_id`, der Text ueber `school_contract_text(branch.code)`, der Vertrag bekommt `school_branch_id=branch.school_branch_id`), und `tests/test_anmeldung.py::test_the_released_contract_carries_the_application_s_own_school_form` haelt beide Haelften: der freigegebene Vertrag traegt die Schulart der Bewerbung samt der daraus gewaehlten Textsorte, und ein Rumpf mit fremder Schulart liefert `released: 0` ohne eine Vertragszeile.

Die Gegenprobe zur zweiten Haelfte liegt im Schema und nicht im Test, und das ist die staerkere Stelle: Ein Vertrag mit einer anderen Schulart als der seiner Bewerbung kommt an `fk_contracts_application_branch` gar nicht vorbei, einer ohne an `ck_contracts_branch`. Gezogen wurde die Sicherung deshalb am Schulart-Filter der Freigabe — dann faellt der Test an seiner eigenen Assertion (`assert foreign.json() == {"released": 0, "contracts": []}`) statt an einem Constraint.

Offen bleiben zwei:

- **Kriterium 4.** `release_module_agreement` setzt `valid_from`, `released_at`, `released_by` und stellt die Optigem-Aufgaben; eine Ausfertigung baut es nicht. Neben `build_contract_document`, `build_mandate_document` und `build_consent_document` steht kein Bau fuer die Modulanlage, `document_id` und `document_checksum` bleiben leer.
- **Kriterium 5.** Einen Loesch-Lauf gibt es in wb-backend nicht; er steht als Aufgabentext in app/services/rollover.py („Loesch-Lauf anstossen (04 Z4, bis Block 17 es anders regelt)"). Solange kein Lauf raeumt, kann seine Reihenfolge nirgends stehen.
<!-- SECTION:NOTES:END -->
