---
id: TASK-181
title: Hortakte und Kategorie-Unterordner im Querschnitt-Schema
status: To Do
assignee: []
created_date: '2026-09-01 19:25'
updated_date: '2026-09-04 00:32'
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
- [ ] #1 sharepoint_libraries trägt die Hortakte, der überholte Kommentar ist ersetzt
- [ ] #2 child_file_folders: Kategorie als Werteliste, UNIQUE über Kind, Bibliothek und Kategorie
- [ ] #3 Das Prüfskript weist einen zweiten Ordner derselben Kategorie in derselben Bibliothek ab
- [ ] #4 Der Löschanker bleibt ohne Cascade — der Lauf räumt SharePoint zuerst
- [ ] #5 Sollstand im Kopf des Prüfskripts nachgezogen, alle Prüfskripte grün gegen die vollständige Datenbank
- [ ] #6 Ein Hortakten-Ordner entsteht auf Anforderung und nicht je Kind — die Zeile existiert nur, wo ein Ordner ist
- [ ] #7 Der Kommentar an sharepoint_libraries über den Vollzugriff für Sekretariat und Geschäftsführung ist ersetzt — an die Schülerakte kommt kein Mensch direkt
- [ ] #8 documents: die Art wird freiwillig, dazu eine Pflicht-Bezeichnung und der Bezug auf den Ordner (und damit auf die Kategorie) statt auf die Bibliothek
- [ ] #9 Das Prüfskript weist eine Datei ab, deren Ordner einem anderen Kind gehört — zusammengesetzter Fremdschlüssel
- [ ] #10 GENERATED_LIBRARY heisst nicht mehr app_documents — der Code benennt die Schuelerakte, nicht ihren Erzeuger
<!-- AC:END -->
