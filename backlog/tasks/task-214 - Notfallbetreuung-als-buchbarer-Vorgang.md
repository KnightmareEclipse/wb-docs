---
id: TASK-214
title: Notfallbetreuung als buchbarer Vorgang
status: To Do
assignee: []
created_date: '2026-09-03 16:38'
labels:
  - schema
  - anmeldung
dependencies: []
references:
  - schema/anmeldung-schema.sql
  - soll-prozesse/09-hortvertrag.md
  - schema/mensa-schema.sql
ordinal: 227000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus [M3]: Eltern sollen die Notfallbetreuung im Portal buchen können — **Hortkinder wie Nicht-Hortkinder**. Die Mitarbeitenden haken ab beziehungsweise tragen nach. Für Kinder, die unangekündigt in der Notbetreuung landen, bleibt es bei Papier und Übertragung.

**Sie passt nicht in die Betreuungsmodule, und das ist der Kern dieses Tickets.** `care_module_prices` kennt einen Monatsbeitrag je Zahl der gebuchten Wochentage, gebunden an eine Modulanlage zum Betreuungsvertrag. Die Notfallbetreuung wird dagegen **je Fall** berechnet ("20 € pro Fall" für den Nachmittag bis 17 Uhr, "8 € pro Fall" für eine Stunde innerhalb der Öffnungszeiten) und steht Kindern offen, die gar keinen Betreuungsvertrag haben. Ein weiteres `care_module` wäre damit die falsche Bauform: Es hinge an einer Vereinbarung, die es bei diesen Kindern nicht gibt.

Gebraucht wird eine **Tagesbuchung** — Kind, Datum, Art des Falls, Betrag — mit dem Preis je Fall statt je Monat. Ob sie in `anmeldung-schema.sql` neben die Betreuung gehört oder daneben steht, entscheidet der Durchgang.

Berührt Block 09 und die Mensa: Wer über Mittag da ist, isst, und das Tagesessen kostet 5,90 € je Fall (11).

**Hängt an fragen.md Frage 11:** Welche Werte der Preisliste unsere sind, ist nicht eindeutig lesbar — die Spalte mit 8/8/12/16/20 ist anderswo mit "Stadt*" überschrieben. Vor dem Seed zu klären, nicht vor dem Bau.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Notfallbetreuung ist eine Tagesbuchung mit Preis je Fall, kein weiteres Betreuungsmodul
- [ ] #2 Ein Kind ohne Betreuungsvertrag kann gebucht werden — als Gegenprobe
- [ ] #3 Der Weg für unangekündigte Fälle ist beschrieben: Papier, danach Nachtrag durch die Mitarbeitenden
- [ ] #4 Das Mittagessen hängt daran, wo es anfällt, und wird nicht im Fallpreis versteckt
<!-- AC:END -->
