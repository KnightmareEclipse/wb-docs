---
id: TASK-179
title: api/akademie-api.md planen
status: To Do
assignee: []
created_date: '2026-09-01 19:10'
updated_date: '2026-09-03 17:56'
labels:
  - api
  - akademie
  - wb-docs
dependencies:
  - TASK-176
references:
  - soll-prozesse/21-akademie.md
  - prompts/api-planen.md
  - api/gemeinsam.md
ordinal: 191000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Routen der Akademie, eine Domäne je Durchgang nach prompts/api-planen.md. Drei Stellen sind die eigentliche Arbeit:

Die Ausschreibung muss **ohne Anmeldung** lesbar sein — das ist der erste Endpunkt des Systems, der keinen Zugang verlangt, und er darf nichts über Kinder verraten. Die Zielgruppe filtert die Anzeige im Portal, verbirgt aber nichts.

Der Zahlweg hängt am SEPA-Mandat der Familie und nicht an einer Wahl der Eltern: mit Mandat entsteht eine Aufgabe bei der Buchhaltung, ohne Mandat läuft die Anmeldung über die vorhandene Bezahlstrecke (api/gemeinsam.md) und entsteht erst mit der bestätigten Zahlung.

**Die Freigabe hängt an Personen, nicht an einer Rolle** (03.09.2026): eine oder mehrere, dynamisch gesetzt, und wer es ist, entscheidet die Geschäftsführung später. Eine Rolle träfe alle, die sie tragen; hier prüft eine benannte Person Rahmen und Wording. Dasselbe gilt für die anbietende Stelle am Angebot — auch sie sind Personen (TASK-176). Die Freigabe bleibt außerdem abschaltbar bzw. auf "automatisch akzeptieren" setzbar.

**Kategorien gibt es zum Start nicht** — die Routen dürfen sie deshalb nicht voraussetzen, weder als Filter noch als Pflichtangabe.

Die harte Platzzahl muss beim Absenden zählen, nicht beim Anzeigen — anders als im Ferienprogramm, das eine Überschreitung um eins hinnimmt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Ausschreibung ist ohne Anmeldung abrufbar und trägt keine personenbezogene Angabe
- [ ] #2 Der Zahlweg folgt dem Mandat, nicht einer Eingabe
- [ ] #3 Die Platzzahl ist beim Absenden hart und die Route sagt, was der Elternteil bei Gleichstand sieht
- [ ] #4 Teilnehmerliste und Gesundheitsausschnitt hängen an der anbietenden Rolle am Angebot, nicht an einer Regel im Code
- [ ] #5 Die Freigabe ist abschaltbar bzw. auf 'automatisch akzeptieren' setzbar — ein Wert im System, kein fest verdrahteter Schritt (03.09.2026)
- [ ] #6 Die anbietende Stelle am Angebot ist nicht auf eine Rolle festgelegt: eine Person, mehrere Personen oder eine Rollengruppe, änderbar ohne Bau
- [ ] #7 Die Freigabe hängt an einer oder mehreren Personen, nicht an einer Rolle — dynamisch setzbar
- [ ] #8 Keine Route setzt eine Kategorie voraus; zum Start gibt es keine
<!-- AC:END -->
