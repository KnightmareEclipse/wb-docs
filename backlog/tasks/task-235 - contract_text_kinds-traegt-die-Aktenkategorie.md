---
id: TASK-235
title: contract_text_kinds traegt die Aktenkategorie
status: In Progress
assignee: []
created_date: '2026-09-04 12:34'
updated_date: '2026-09-05 00:35'
labels:
  - schema
  - wb-docs
  - wb-backend
dependencies: []
references:
  - dokumente.md
  - schema/querschnitt-schema.sql
ordinal: 248000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Heute folgt der Unterordner einer erzeugten Urkunde aus dem Anwendungscode; `contract_text_kinds` kennt `child_file_categories` nicht. Solange das so ist, landet jede neue Dokumentsorte am falschen Platz in der Akte, und die zweite Ebene aus `dokumente.md` ("eine neue Dokumentsorte ist ein Griff") bleibt ein Bau.

**Nicht die Frist ist der Grund, und das ist seit dem 04.09.2026 praezisiert:** Eine erzeugte Datei geht mit ihrem Vorgang — der Vertrag haelt sein Dokument, das Mandat seines. Die Kategorie ist fuer sie der **Unterordner**. Ihre Fristwirkung hat sie fuer das, was ein Mensch in die Akte legt: Zeugnis, Beobachtungsbogen, Schriftwechsel haengen an keinem Vorgang, und dort ist `child_file_categories.retention_subject_id` die einzige Uhr.

Eine Spalte `child_file_category_id` an der Sorte, Fremdschluessel auf die Werteliste. Nullable bleibt sie nicht auf Dauer, aber heute schon: Die Kategorien und ihre Fristen liegen beim Datenschutzbeauftragten (TASK-058.10), und dort wird nichts erfunden.

`documents` selbst braucht keine Spalte — es traegt `child_id`, `document_type_id`, `label`, Ordner und Bibliothek bereits generisch.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 contract_text_kinds traegt child_file_category_id mit Fremdschluessel auf child_file_categories
- [x] #2 Der Kommentar sagt, warum die Spalte heute leer bleiben darf und woran das haengt
- [x] #3 Gegenprobe: eine Sorte mit einer Kategorie, die es nicht gibt, wird abgewiesen
- [ ] #4 build_contract_document liest Unterordner und Dokumentart aus der Sorte statt sie zu verdrahten
- [x] #5 Der Kommentar trennt die beiden Wege: eine erzeugte Datei geht mit ihrem Vorgang, ein gescanntes Blatt mit seiner Kategorie — die Spalte traegt den zweiten Fall
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Schema gebaut: `contract_text_kinds.child_file_category_id` mit `fk_contract_text_kinds_category` auf `child_file_categories`. Die Spalte steht in `ck_contract_text_kinds_class_shape` neben Arbeitsfassung und Dokumentart — allein die Klasse 'signed' traegt sie, denn eine Kategorie ohne Datei benennt einen Ordner, in den nie etwas kommt.

Der Kommentar traegt die Trennung, um die es geht: die Kategorie ist fuer die erzeugte Datei der **Unterordner und nicht die Uhr** — sie geht mit ihrem Vorgang, und die Frist zaehlt allein fuer das, was ein Mensch in die Akte legt. Nullable bleibt sie, solange die Kategorien und ihre Fristen beim Datenschutzbeauftragten liegen (TASK-058.10); bis dahin verdrahtet der Anwendungscode den Ordner.

Zwei Gegenproben in querschnitt-schema-check.sql, beide gegen den benannten Constraint verifiziert: eine Kategorie, die es nicht gibt (fk_contract_text_kinds_category), und eine Kategorie an einer mitgeltenden Anlage (ck_contract_text_kinds_class_shape). Der Seed traegt sie jetzt an der Schulvertragssorte. dokumente.md sagt nicht mehr, die Aktenkategorie an der Sorte fehle.

Offen bleibt Kriterium 4: `build_contract_document` in wb-backend liest die Spalte nicht — die Spalte steht, der Leser fehlt. Die Migration dazu ist TASK-267.
<!-- SECTION:NOTES:END -->
