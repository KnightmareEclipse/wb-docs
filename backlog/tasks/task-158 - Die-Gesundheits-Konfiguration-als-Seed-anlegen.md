---
id: TASK-158
title: Die Gesundheits-Konfiguration als Seed anlegen
status: Done
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-02 00:40'
labels:
  - wb-backend
  - gesundheit
dependencies:
  - TASK-155
references:
  - wb-backend/tests/test_seed.py
  - soll-prozesse/08-schulvertrag.md
  - soll-prozesse/09-hortvertrag.md
ordinal: 170000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ohne Kategorien, Felder, Zuordnungen und Sichtkreise ist der Bestand nicht befüllbar — die Konfiguration ist keine Testdatenspielerei, sondern Voraussetzung des Betriebs.

Der Umfang folgt den Blöcken 08 und 09: die Merkmalsarten aus 08 samt Schulbegleitung und Zeckenentfernung, die Felder Bezeichnung, Beachten, Erlaubnis, Attest, Zeitraum und Selbsteinnahme, und die Sichtkreise Küche, Betreuung, Sport, Klassenleitung, volle Akte, Notfall.

Die vier Felder aus der Erklärung zur außerunterrichtlichen Veranstaltung — Impfschutz Tetanus und FSME mit Datum, Schwimmfähigkeit, private Haftpflicht — gehören noch nicht hierher: Sie hängen am Erhebungsanlass, der nicht gebaut ist.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Der Seed legt Wertarten, Kategorien, Felder, Zuordnungen und Sichtkreise an und ist wiederholbar
- [x] #2 Jede Zuordnung Sichtkreis × Kategorie × Feld ist im Seed begründet, nicht geraten
- [x] #3 Ein Lauf gegen die leere Datenbank ergibt einen Bestand, in dem eine Erhebung vollständig durchläuft
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Seed in der Wertelisten-Revision ebf1b8885558, Abschnitt Gesundheit: 5 Wertarten, 10 Kategorien, 6 Felder, 37 Paare, 6 Sichtkreise, Zuordnungen je Sichtkreis mit Begründung im Kommentar. Wiederholbar über den Downgrade/Upgrade der Revision; schema-check.sh truncatet die Tabellen je Prüfskript. test_seed.py prüft die sechs Tabellen; test_the_close_passes_once_every_category_has_an_answer läuft eine Erhebung komplett durch.
<!-- SECTION:NOTES:END -->
