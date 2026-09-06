---
id: TASK-181
title: Hortakte und Kategorie-Unterordner im Querschnitt-Schema
status: In Progress
assignee: []
created_date: '2026-09-01 19:25'
updated_date: '2026-09-04 01:06'
labels:
  - schema
  - querschnitt
  - sharepoint
  - wb-docs
  - wb-backend
dependencies: []
references:
  - schema/querschnitt-schema.sql
  - grenzkarte.md
  - soll-prozesse/09-hortvertrag.md
  - soll-prozesse/08-schulvertrag.md
ordinal: 193000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zwei Beschlüsse vom 01.09.2026 treffen dieselbe Tabelle. wb-backend führt das Schema, es beginnt dort als Migration.

Erstens die **Hortakte**: eine zweite Zeile in sharepoint_libraries und ein zweites Grant. Der Kommentar an der Tabelle sagt heute das Gegenteil — 'Beantwortet: Der Hort bekommt keine eigene Bibliothek' — und beschreibt zugleich, dass genau das der vorgesehene Weg wäre; er wird ersetzt, nicht ergänzt.

Zweitens die **Unterordner je Kategorie** in der Schülerakte, jeder mit eigener Frist. Damit trägt child_file_folders eine Zeile je Kind, Bibliothek und Kategorie statt einer je Kind: uq_child_file_folders UNIQUE (child_id) fällt, die Kategorie kommt als Werteliste dazu.

Der Klassenwechsel zieht nur den Ordner der Schülerakte um (api/stammdaten-api.md) — die Hortakte kennt keine Kohorte und bleibt, wo sie ist.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 sharepoint_libraries trägt die Hortakte, der überholte Kommentar ist ersetzt
- [x] #2 child_file_folders: Kategorie als Werteliste, UNIQUE über Kind, Bibliothek und Kategorie
- [x] #3 Das Prüfskript weist einen zweiten Ordner derselben Kategorie in derselben Bibliothek ab
- [x] #4 Der Löschanker bleibt ohne Cascade — der Lauf räumt SharePoint zuerst
- [x] #5 Sollstand im Kopf des Prüfskripts nachgezogen, alle Prüfskripte grün gegen die vollständige Datenbank
- [x] #6 Ein Hortakten-Ordner entsteht auf Anforderung und nicht je Kind — die Zeile existiert nur, wo ein Ordner ist
- [x] #7 Der Kommentar an sharepoint_libraries über den Vollzugriff für Sekretariat und Geschäftsführung ist ersetzt — an die Schülerakte kommt kein Mensch direkt
- [x] #8 documents: die Art wird freiwillig, dazu eine Pflicht-Bezeichnung und der Bezug auf den Ordner (und damit auf die Kategorie) statt auf die Bibliothek
- [x] #9 Das Prüfskript weist eine Datei ab, deren Ordner einem anderen Kind gehört — zusammengesetzter Fremdschlüssel
- [ ] #10 GENERATED_LIBRARY heisst nicht mehr app_documents — der Code benennt die Schuelerakte, nicht ihren Erzeuger
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut in schema/querschnitt-schema.sql:
- Neue Werteliste child_file_categories (code, name, is_active, retention_subject_id). Der Verweis auf den Bestand ist nullable und traegt den Grund, aus dem es die Kategorien ueberhaupt gibt: die eigene Frist. Er bleibt leer, solange die Liste und ihre Fristen beim Datenschutzbeauftragten liegen — dort wird nichts erfunden. Der Fremdschluessel steht als ALTER hinter retention_subjects, wie fk_sepa_mandates_document.
- child_file_folders: Kategorie als Pflichtspalte, uq_child_file_folders jetzt UNIQUE (child_id, sharepoint_library_id, child_file_category_id). Dazu uq_child_file_folders_graph_item — ohne es waere mit dem alten UNIQUE (child_id) der Schutz weggefallen, dass zwei Zeilen auf dasselbe Graph-Element zeigen, und der Lauf entfernte einen Ordner, auf den die zweite noch zeigt.
- documents: document_type_id ist nullable, label ist Pflicht, und der Bezug geht auf child_file_folder_id statt auf die Bibliothek. fk_documents_folder ist zusammengesetzt ueber (Ordner, Kind, Bibliothek) und weist eine Datei in fremder Akte ab; er ersetzt fk_documents_library, der daneben nichts mehr geprueft haette. sharepoint_library_id bleibt mitgefuehrt, damit uq_documents_graph_item die Datei je Bibliothek eindeutig haelt.

Der Fallstrick, der dabei aufkam und geschlossen ist: documents zeigt jetzt auf child_file_folders, der Ordner muss im Loesch-Lauf also HINTER die Dateien. Der Kopfkommentar von querschnitt-schema.sql und die Selbstpruefung (Tabelle loeschlauf) sind umnummeriert — child_file_folders von Platz 1 auf Platz 10, alles ab children eins weiter. Die Selbstpruefung haette es sonst als 'der Lauf raeumt zu frueh' gemeldet; genau dafuer steht sie da. gesundheit-schema-check.sql raeumt den Ordner jetzt hinter der Datei.

Nachgezogen: anmeldung- und gesundheit-schema-check.sql (Kategorie, Ordner, label an jedem documents-INSERT; Bibliothekscode 'generated' zu 'student_file'), api/querschnitt-api.md (POST nimmt Kategorie und Bezeichnung statt der Bibliothek, PUT nennt fk_documents_folder). Alle 14 Pruefskripte rc=0 gegen die vollstaendige Datenbank.

Kriterium 1 und 7 waren mit 5024721 schon erfuellt: Der Kommentar an sharepoint_libraries nennt die drei Bibliotheken und sagt, dass an Schuelerakte und Belege kein Mensch direkt kommt. Geseedet wird die Tabelle bewusst nicht, die Zeile legt ein Mensch beim Aufsetzen an (TASK-053).

Offen ist allein Kriterium 10: GENERATED_LIBRARY heisst in wb-backend weiter app_documents. Die Pruefskripte hier nennen die Bibliothek jetzt durchgaengig student_file; die Umbenennung der Konstanten und der Fehlermeldung 'The generated-documents library carries no drive id' gehoert in wb-backend, zusammen mit der Migration fuer diesen ganzen Umbau.
<!-- SECTION:NOTES:END -->
