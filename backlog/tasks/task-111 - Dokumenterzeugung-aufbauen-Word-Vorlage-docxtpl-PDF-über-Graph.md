---
id: TASK-111
title: 'Dokumenterzeugung aufbauen: Word-Vorlage, docxtpl, PDF über Graph'
status: Done
assignee: []
created_date: '2026-08-27 22:44'
updated_date: '2026-08-29 20:22'
labels:
  - wb-backend
  - anmeldung
  - sharepoint
milestone: m-2
dependencies: []
references:
  - oberflaechen.md
  - schema/anmeldung-schema.sql
ordinal: 123000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
In oberflaechen.md entschieden, nirgends beauftragt: Word-Vorlage mit Platzhaltern, gefüllt per docxtpl im Backend, PDF-Konvertierung über Graph (content?format=pdf). Ohne sie steht die Vertragsstrecke.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Kein Konverter im Container, kein Premium-Konnektor
- [x] #2 Die erzeugte Datei landet in der Bibliothek der Schuelerakte — an die seit dem 04.09.2026 kein Mensch direkt kommt
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Gebaut in wb-backend PR #5. Word-Vorlage app/documents/contract-template.docx, gefüllt per docxtpl, PDF-Konvertierung über Graph (content?format=pdf) — kein Konverter im Container und kein Premium-Konnektor. Die erzeugte Datei landet in der Bibliothek mit dem Code app_documents — das ist die Schuelerakte, und an sie kommt seit 5024721 kein Mensch direkt: abgelegt, angesehen und herausgegeben wird ueber Weltenbaum (grenzkarte.md, oberflaechen.md). Der Satz 'in der Menschen nur lesen' stammt aus dem Zwei-Bibliotheken-Modell und gilt nicht mehr; das gerenderte .docx war nur der Weg zur Konvertierung und wird danach entfernt. Die Prüfsumme über die PDF-Bytes steht als contracts.document_checksum. Läuft im Request der Freigabe: scheitert Graph, fällt die Freigabe mit ihm zurück.
<!-- SECTION:FINAL_SUMMARY:END -->
