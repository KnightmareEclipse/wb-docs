---
id: TASK-234
title: Routen für den Nachtrag zum Vertrag planen
status: To Do
assignee: []
created_date: '2026-09-04 01:41'
labels:
  - api
  - anmeldung
  - wb-docs
milestone: m-5
dependencies:
  - TASK-126
references:
  - api/anmeldung-api.md
  - soll-prozesse/08-schulvertrag.md
  - schema/anmeldung-schema.sql
ordinal: 247000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`contract_amendments` steht im Schema (04.09.2026), `api/anmeldung-api.md` kennt keine Route dafür. Die Modulanlage hat ihr Gegenstück — `POST /contracts/{contract_id}/module-agreements` —, der Nachtrag nichts; damit ist eine Tabelle gebaut, die kein Endpunkt füllt.

Vier Griffe zeichnen sich ab, und die Bauform steht daneben:

- **Vorlegen**: eine Fassung allen betroffenen Verträgen vorlegen. Ein Lauf und keine Route je Familie — es sind fünfhundert Zeilen auf einmal. Die anbietende Stelle ist die Geschäftsführung, wie bei `POST /contract-texts`.
- **Ansehen**: was für meine Kinder aussteht, mit dem Text der neuen Fassung. Eltern, eigene Familie.
- **Zeichnen**: `POST /contract-amendments/{id}/signatures`, dieselbe Bauform wie `POST /contracts/{id}/signatures` — **alle Sorgeberechtigten**, nicht eine wie bei der Modulanlage (04.09.2026).
- **Abschließen**: mit der letzten Unterschrift `completed_at` setzen und, wo die Fassung Zustimmung verlangt, die Urkunde erzeugen und in die Akte legen. Läuft im Request wie `POST /contracts/{id}/release`, und scheitert Graph, fällt der Abschluss mit ihm zurück.

**Zwei Dinge sind offen und gehören nicht in diese Route**, sondern nach TASK-126: wen die Vorlage erreicht und wen ausdrücklich nicht (die Jahrgänge 1 und 5 haben gerade unterschrieben), und wann der erste Durchgang läuft. Solange das nicht steht, lässt sich das Vorlegen nicht abschließend planen — deshalb hängt dieses Ticket daran.

Dazu fehlt der **Wortlaut des Nachtrags** als Textsorte der Klasse `signed` samt Vorlage (TASK-042). Angelegt wird sie, wenn der erste Nachtrag ansteht, nicht auf Vorrat.

Nach `prompts/api-planen.md`, aber als Nachtrag zu einer geplanten Domäne und nicht als eigener Durchgang.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die vier Griffe stehen in api/anmeldung-api.md, je Route mit Rolle, Einschränkung und Quelle
- [ ] #2 Das Vorlegen ist ein Lauf über die betroffenen Verträge, keine Route je Familie
- [ ] #3 Alle Sorgeberechtigten zeichnen — die Route sagt es, und sie sagt auch, dass sie nicht rechnet, wie viele es sind
- [ ] #4 Der Abschluss erzeugt die Urkunde nur, wo die Fassung Zustimmung verlangt; die Kenntnisnahme kommt ohne aus
- [ ] #5 Die Urkunde landet im Unterordner ihrer Kategorie in der Akte des Kindes, dem der Vertrag gehört
- [ ] #6 Erst nach TASK-126: wen die Vorlage erreicht und wen nicht
<!-- AC:END -->
