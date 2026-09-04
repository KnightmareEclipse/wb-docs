---
id: TASK-225
title: contract_text_kinds definiert die Dokumentsorte vollstaendig
status: To Do
assignee: []
created_date: '2026-09-04 00:18'
labels:
  - schema
  - wb-docs
  - wb-backend
milestone: m-5
dependencies: []
ordinal: 237000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`contract_text_kinds` ist heute eine Werteliste aus Code und Name. Sie wird der Ort, an dem eine Dokumentsorte vollständig definiert ist — sonst steht dieselbe Tatsache im Code.

**Drei Spalten kommen dazu:**

- `document_type_id` → `document_types`. Heute steht in `build_contract_document` fest `type_code="school_contract" if … else "care_contract"`. Mit dem Verweis ist eine neue Dokumentsorte **eine Zeile plus eine Vorlage**, kein Deploy.
- `working_library_id` + `working_item_id` — wo die Arbeitsfassung liegt, als Graph-Kennung. „Ein Pfad bräche bei jedem Verschieben" (`grenzkarte.md`).
- Die **Klasse**, als CHECK mit drei Codes nach der Bauform von `ck_contracts_type`:

| Klasse | Beispiele | Was entsteht |
|---|---|---|
| `signed` | Schulvertrag, Betreuungsvertrag, Fotoeinverständnis, SEPA-Mandat | Urkunde je Kind, Prüfsumme, Unterschriftszeilen |
| `agreed` | Teilnahmebedingungen (10), Essensbedingungen (11) | keine Datei, aber der Vorgang merkt sich die Fassung |
| `applies` | Betreuungsordnung, Infektionsschutz | nichts am Kind — es gilt „die jeweils gültige Fassung" (09) |

Die Klasse ist nicht ableitbar: Die Anwendung muss beim Anzeigen wissen, ob sie eine Zustimmung festhält oder nicht, und das steht sonst nirgends.

**Was ausdrücklich NICHT hierher wandert:** die Feldfreigabe je Sorte. Wer sie verbreitern kann, kann Daten in ein Dokument ziehen, das der falsche Leserkreis sieht — und das darf nicht dieselbe Person sein, die die Vorlage schreibt. Sie bleibt im Code.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Sorte traegt ihren Dokumenttyp; build_contract_document verdrahtet ihn nicht mehr fest
- [ ] #2 Die Sorte traegt die Graph-Kennung ihrer Arbeitsfassung — Bibliothek und Element, nie ein Pfad
- [ ] #3 Die Sorte sagt, welcher der drei Klassen sie angehoert: unterschrieben, zugestimmt, mitgeltend
- [ ] #4 Eine Sorte ohne Arbeitsfassung ist reiner Text und erzeugt keine Urkunde — als Gegenprobe
<!-- AC:END -->
