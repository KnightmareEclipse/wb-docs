---
id: TASK-194
title: Der Lösch-Lauf nimmt keine Datei mit
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
labels:
  - wb-backend
  - dsgvo
dependencies: []
references:
  - app/services/retention.py
  - schema/querschnitt-schema.sql
  - schema/querschnitt-schema-check.sql
ordinal: 207000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gefunden im Nachtlauf 02.09.2026 (TASK-192): app/services/retention.py behandelt documents und child_file_folders gar nicht — weder die Zeile noch die Datei in SharePoint. Damit bleibt jede erzeugte Datei (Vertrag, Mandat, Fotoeinverständnis, Attest) stehen, wenn Kind und Vorgang gehen; grenzkarte.md Q2: „eine verwaiste Datei in SharePoint ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile". Die Stufenfolge steht als Kommentar in querschnitt-schema.sql und als Selbstprüfung (Tabelle loeschlauf) in querschnitt-schema-check.sql; seit TASK-192 halten sepa_mandates und consents ihre Datei mit NO ACTION fest, der Lauf muss also Mandat und unterschriebene Zustimmung vor der Datei und die Datei vor dem Kind nehmen. Vorher braucht er die Fristen je Aktenkategorie vom Datenschutzbeauftragten (08, fragen.md).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Lauf entfernt die Datei in SharePoint zuerst und die documents-Zeile danach, in der Stufenfolge des Prüfskripts
- [ ] #2 Mandat und unterschriebene Zustimmung gehen mit ihrer Datei, ein Test hält die Reihenfolge fest
- [ ] #3 Ein Graph-Fehler beim Löschen der Datei lässt die Zeile stehen, statt eine verwaiste Datei zurückzulassen
<!-- AC:END -->
