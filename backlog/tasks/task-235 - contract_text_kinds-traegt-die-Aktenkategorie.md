---
id: TASK-235
title: contract_text_kinds traegt die Aktenkategorie
status: To Do
assignee: []
created_date: '2026-09-04 12:34'
updated_date: '2026-09-04 13:28'
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
- [ ] #1 contract_text_kinds traegt child_file_category_id mit Fremdschluessel auf child_file_categories
- [ ] #2 Der Kommentar sagt, warum die Spalte heute leer bleiben darf und woran das haengt
- [ ] #3 Gegenprobe: eine Sorte mit einer Kategorie, die es nicht gibt, wird abgewiesen
- [ ] #4 build_contract_document liest Unterordner und Dokumentart aus der Sorte statt sie zu verdrahten
- [ ] #5 Der Kommentar trennt die beiden Wege: eine erzeugte Datei geht mit ihrem Vorgang, ein gescanntes Blatt mit seiner Kategorie — die Spalte traegt den zweiten Fall
<!-- AC:END -->
