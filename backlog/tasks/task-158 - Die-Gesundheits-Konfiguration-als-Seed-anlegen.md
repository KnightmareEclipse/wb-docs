---
id: TASK-158
title: Die Gesundheits-Konfiguration als Seed anlegen
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
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
- [ ] #1 Der Seed legt Wertarten, Kategorien, Felder, Zuordnungen und Sichtkreise an und ist wiederholbar
- [ ] #2 Jede Zuordnung Sichtkreis × Kategorie × Feld ist im Seed begründet, nicht geraten
- [ ] #3 Ein Lauf gegen die leere Datenbank ergibt einen Bestand, in dem eine Erhebung vollständig durchläuft
<!-- AC:END -->
