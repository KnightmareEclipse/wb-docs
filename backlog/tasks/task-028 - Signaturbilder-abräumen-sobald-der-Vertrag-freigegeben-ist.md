---
id: TASK-028
title: 'Signaturbilder abräumen, sobald der Vertrag freigegeben ist'
status: Done
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-29 20:22'
labels:
  - wb-backend
  - anmeldung
  - dsgvo
milestone: m-4
dependencies: []
references:
  - schema/anmeldung-schema.sql
ordinal: 28000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bei contracts.released_at: Datei in SharePoint löschen, Kennung an der Signaturzeile leeren. Vorher wird das Bild für die Neuerzeugung gebraucht, danach steckt es im PDF; bleibt es liegen, ist es eine zweite Kopie ohne Abnehmer, die kein Lösch-Job je anfasst — sein Anker ist die Frist des Dokuments.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ausgelöst von contracts.released_at
- [x] #2 Datei weg und Kennung geleert, beides
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Gebaut in wb-backend PR #5 als clear_signature_images() in app/services/anmeldung.py, gerufen von POST /contracts/{contract_id}/release direkt hinter dem Dokument — also ausgelöst davon, dass contracts.released_at gesetzt wird, und in derselben Transaktion. Beides: die Datei wird über Graph gelöscht und signature_image_library_id samt signature_image_item_id geleert. tests/test_anmeldung.py::test_the_release_builds_the_document_and_clears_the_images prüft beide Hälften.
<!-- SECTION:FINAL_SUMMARY:END -->
