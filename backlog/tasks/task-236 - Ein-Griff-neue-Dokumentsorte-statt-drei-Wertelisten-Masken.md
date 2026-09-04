---
id: TASK-236
title: Ein Griff neue Dokumentsorte statt drei Wertelisten-Masken
status: To Do
assignee: []
created_date: '2026-09-04 12:35'
updated_date: '2026-09-04 12:38'
labels:
  - api
  - wb-backend
  - wb-docs
  - route
dependencies: []
references:
  - dokumente.md
  - api/querschnitt-api.md
ordinal: 249000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Heute wird jede Werteliste ueber die `value_list_seed`-Migration befuellt — eine neue Dokumentsorte kostet damit einen Deploy, und der Betreiber muss ran. `rules.md` Abschnitt 2 verlangt das Gegenteil: organisatorische Werte werden ueber die Verwaltungsoberflaeche gepflegt und erzwingen keinen Codetouch.

**Ein Griff, nicht drei Pflegeseiten.** Sorte, Dokumentart und Aktenkategorie entstehen in einer Transaktion; drei getrennte Masken liessen eine halbe Sorte zu — eine Sorte ohne Dokumentart, eine Kategorie ohne Frist. Dieselbe Bauform wie `POST /care-contracts`.

**Drei Regeln begrenzen ihn** (`dokumente.md`): was im Anwendungscode verankert ist, erreicht der Griff nicht (`school_contract`, `care_contract`, `sepa_mandate`, `photo_consent` — dieselbe Auslassung wie bei `consent_purposes`); der `code` ist nach dem Anlegen fest, der `name` wandert; die Klasse ist fest, sobald das erste Dokument dieser Sorte entstanden ist.

**Kein generischer Werteliste-Editor daneben** — `sync_targets`, `consent_purposes` und `retention_subjects` tragen Zustaendigkeiten und Loeschfristen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eine Route legt Sorte, Dokumentart und Aktenkategorie in einer Transaktion an
- [ ] #2 Rolle executive_management; die Geschaeftsfuehrung braucht dafuer keinen Entwickler
- [ ] #3 Die vier im Code verankerten Codes sind ueber den Griff weder umbenennbar noch deaktivierbar
- [ ] #4 Der code ist nach dem Anlegen fest, der name aenderbar
- [ ] #5 kind_class laesst sich nicht mehr aendern, sobald ein Dokument dieser Sorte existiert
- [ ] #6 Gegenproben: jede der drei Regeln weist den realen Fall ab, jede einzeln rot gezeigt
- [ ] #7 Der Griff steht als Route in api/querschnitt-api.md, mit Rolle, Einschraenkung und Quelle
<!-- AC:END -->
