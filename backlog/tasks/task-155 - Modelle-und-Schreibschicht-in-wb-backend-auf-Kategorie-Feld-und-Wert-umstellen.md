---
id: TASK-155
title: >-
  Modelle und Schreibschicht in wb-backend auf Kategorie, Feld und Wert
  umstellen
status: Done
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-02 00:40'
labels:
  - wb-backend
  - gesundheit
dependencies:
  - TASK-154
references:
  - wb-backend/app/models/gesundheit.py
  - schema/gesundheit-schema.sql
ordinal: 167000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
app/models/gesundheit.py bildet heute das Merkmal mit seinen sechzehn Spalten ab. Neu sind vier Ebenen: Bestand, Antwort je Kategorie, Merkmal, Wert je Feld.

Die Schreibschicht trägt dabei die eine Regel, die die Datenbank nicht mehr deklarativ halten kann: dass ein Fragensatz vollständig beantwortet ist, wenn er als beantwortet gilt. Ein fehlendes Feld ist eine fehlende Zeile, und dagegen hilft kein CHECK — geprüft wird beim Abschluss der Erhebung, nicht beim Schreiben der einzelnen Zeile. Alles andere bleibt in der Datenbank: Feld an der falschen Kategorie, Wert im falschen Typ, Feld doppelt, zweite Zeile einer Kategorie, die nur eine erlaubt.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und in grenzkarte.md („Zugriff, je Angabe"). Entschieden am 01.09.2026 mit der Geschäftsführung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Die vier Ebenen sind als Modelle abgebildet, health_traits trägt keine Merkmalsspalten mehr
- [x] #2 Ein Wert wird nur über die Schreibschicht geschrieben, kein Endpunkt schreibt daran vorbei
- [x] #3 Die Vollständigkeitsprüfung beim Abschluss einer Erhebung ist gebaut und meldet, welches Feld fehlt
- [x] #4 Die Prüfung liegt genau einmal, nicht zusätzlich als Trigger in der Datenbank
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
app/models/gesundheit.py trägt die vier Ebenen; die fünf Wertspalten sind deferred und für backend_runtime nicht lesbar. app/services/health.py ist die Schreibschicht: replace_category schreibt eine Kategorie am Stück, close_record prüft die Vollständigkeit (jede aktive Kategorie beantwortet oder abgelehnt) und nennt die fehlende. test_only_the_write_layer_constructs_a_value liest die Quellen. Kein Trigger daneben.
<!-- SECTION:NOTES:END -->
