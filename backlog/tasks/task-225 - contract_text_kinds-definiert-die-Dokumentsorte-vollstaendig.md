---
id: TASK-225
title: contract_text_kinds definiert die Dokumentsorte vollstaendig
status: In Progress
assignee: []
created_date: '2026-09-04 00:18'
updated_date: '2026-09-04 12:37'
labels:
  - schema
  - wb-docs
  - wb-backend
milestone: m-5
dependencies:
  - TASK-235
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
- [x] #2 Die Sorte traegt die Graph-Kennung ihrer Arbeitsfassung — Bibliothek und Element, nie ein Pfad
- [x] #3 Die Sorte sagt, welcher der drei Klassen sie angehoert: unterschrieben, zugestimmt, mitgeltend
- [x] #4 Eine Sorte ohne Arbeitsfassung ist reiner Text und erzeugt keine Urkunde — als Gegenprobe
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Schema gebaut: contract_text_kinds traegt kind_class (CHECK auf signed/agreed/applies, Bauform von ck_contracts_type), document_type_id und die Graph-Kennung der Arbeitsfassung als working_library_id + working_item_id. ck_contract_text_kinds_working laesst die Kennung nur ganz oder gar nicht zu, ck_contract_text_kinds_class_shape gibt Arbeitsfassung und Dokumentart allein der Klasse signed — eine mitgeltende Anlage mit Vorlage wird abgewiesen.

Eine Entscheidung dabei, die vom Ticketwortlaut abweicht: Eine signed-Sorte OHNE Vorlage bleibt zulaessig. Ein NOT NULL waere heute falsch — die drei Vertragstexte werden gerade ueberarbeitet (TASK-042) und der Mandatswortlaut steht noch aus (TASK-196); die Sorte gibt es vor ihrer Datei. Kriterium 4 ist damit als Gegenprobe gebaut, aber in der Richtung 'ohne Arbeitsfassung keine Urkunde' und nicht als Pflichtfeld.

Offen ist Kriterium 1: build_contract_document in wb-backend verdrahtet type_code weiter fest. Die Spalte steht, der Leser fehlt.

Die Feldfreigabe je Sorte ist NICHT hierher gewandert und steht als Satz am Tabellenkommentar.
<!-- SECTION:NOTES:END -->
