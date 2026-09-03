---
id: TASK-050
title: Die drei Preislisten eintragen
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-09-03 18:05'
labels:
  - wartet
  - geschaeftsfuehrung
  - werteliste
milestone: m-1
dependencies: []
references:
  - soll-prozesse/hebel.md
priority: high
ordinal: 53000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Tabellen stehen, die Beträge liegen vor: Schulgeld je Schulart und Geschwisterrang (`tuition_fees`), Hortbeitrag je Modul und Tageszahl (`care_module_prices`), Mittagessen je Zahl der Esstage (`meal_prices`). Die Geschäftsführung pflegt sie danach selbst.

**Schulgeld, gültig ab 01.08.2026:** Grundschule 145 €, Realschule 150 €. Geschwister gezählt über beide Schulen: das erste Kind (höchste Klassenstufe) ohne Ermäßigung, das zweite −20 €, das dritte −40 €, ab dem vierten beitragsfrei — je auf den Grundpreis der besuchten Schulart.

**Mensa, gültig ab September 2026:** 1 Tag 21,50 € · 2 Tage 42,50 € · 3 Tage 63,50 € · 4 Tage 84,50 € · 5 Tage 105,00 € je Monat, dazu das Tagesessen mit 5,90 € je Fall. **Auf elf Monate kalkuliert, der August ist beitragsfrei** — das ist eine Regel und kein Preis, sie steht als Kommentar an `meal_prices`.

**Hort, gültig ab September 2026** (Spalte „Neue Preise" der Preisliste):

| Modul | Beträge |
|---|---|
| Frühbetreuung | 12 € |
| Nachmittag 1, bis 13:00 | 12 € |
| Nachmittag 2, bis 14:30 | 1 Tag 27 €, 5 Tage 130 € |
| Nachmittag 3, bis 15:30 | 1 Tag 37 €, 5 Tage 175 € |
| Nachmittag 4, bis 17:00 | 1 Tag 73 €, 2 Tage 126 €, 3 Tage 168 €, 4 Tage 189 €, 5 Tage 210 € |
| Hort nach Mittagsschule (RS Klasse 5, 15:00–17:00) | 1 Tag 23 € |
| Ferien, 8–14 Uhr | 22 € |
| Ferien, 8–16 Uhr | 28 €, bei Selbstverpflegung |

**Die Notfallbetreuung steht nicht hier**, obwohl sie in derselben Liste stand: Sie wird je Fall berechnet und passt nicht in `care_module_prices` (TASK-214).

Die Zwischenstufen, die in der Liste fehlen — zwei bis vier Tage bei den Nachmittagen 2 und 3 —, sind vor dem Seed zu erfragen; die Tabelle verlangt je Modul und Tageszahl einen Betrag und rechnet keinen aus.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Alle drei Listen stehen als Werte mit Gültigkeitstag, keine im Code
- [ ] #2 Die fehlenden Zwischenstufen bei Nachmittag 2 und 3 sind erfragt und eingetragen
- [ ] #3 Die Elf-Monats-Regel der Mensa steht als Kommentar, nicht als gerechneter Preis
<!-- AC:END -->
