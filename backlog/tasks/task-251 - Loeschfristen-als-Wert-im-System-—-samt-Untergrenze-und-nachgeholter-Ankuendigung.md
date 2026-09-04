---
id: TASK-251
title: >-
  Loeschfristen als Wert im System — samt Untergrenze und nachgeholter
  Ankuendigung
status: To Do
assignee: []
created_date: '2026-09-04 18:56'
labels:
  - dsgvo
  - querschnitt
  - wb-backend
milestone: m-1
dependencies: []
ordinal: 264000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Geschaeftsfuehrung, 04.09.2026: 'Generell soll es moeglich sein die Loeschfristen dynamisch anzupassen durch die GF und soll nicht fix im Code stehen.'

Das kehrt um, was soll-prozesse/anleitung.md bisher trug — eine Frist war eine feste Zahl, weil 'je weniger jemand einstellen muss, desto weniger geht schief'. Fuer Vorlaufzeiten und Stichtage gilt der Satz weiter; fuer die Aufbewahrung nicht mehr.

**Der Mechanismus steht schon:** configured_values traegt code, valid_from und value — eine Aenderung wirkt damit ab einem Datum und nie rueckwirkend. Zu bauen sind die Codes je Bestand und zwei Sicherungen, die heute fehlen:

1. **Die Untergrenze.** Wo eine Aufbewahrungspflicht dahintersteht — die zehn Jahre der Belege aus § 147 AO und § 257 HGB (soll-prozesse/12) —, darf auch die Geschaeftsfuehrung nicht darunter. Heute weist nichts das ab, und der Fehler faellt erst auf, wenn die Belege fort sind. Nach oben ist eine Frist harmlos; die Grenze ist einseitig.
2. **Die nachgeholte Ankuendigung.** Senkt jemand eine Frist, werden Bestaende faellig, die es gestern nicht waren — und ihr Ankuendigungstermin liegt dann in der Vergangenheit. Der Lauf muss ihnen zwei Wochen ab der Aenderung geben, statt am naechsten Morgen zu raeumen (soll-prozesse/17). Ohne das loescht eine Eingabe am Nachmittag, was am Abend niemand mehr pruefen konnte.

**Was daran nicht neu ist:** Die Aenderungsspur traegt den Vorgang wie bei jedem anderen Wert im System — wer eine Frist gesenkt hat und wann, ist dieselbe Frage wie 'wer hat den Preis geaendert'.

**Der Anfangsbestand ist der heutige Stand** aus verarbeitungsverzeichnis.md, nicht eine neue Setzung: Schulvertrag fuenf Jahre, SEPA-Mandat zwei, Gesundheitsbestand drei Monate, Hortakte zwei Jahre, Belege zehn Jahre (mit Untergrenze), und so fort. Die Tabelle dort nennt seither ausdruecklich den heutigen Stand und keine unveraenderliche Zahl.

**Nicht mit hinein gehoert der Nachweis der Fotoerlaubnis** (TASK-244): Er hat keine Frist, und eine Null in dieser Tabelle waere eine, die jemand versehentlich fuellen kann.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Je Bestand ein Code in configured_values, der Anfangsbestand ist der heutige Stand
- [ ] #2 Eine Frist mit gesetzlicher Untergrenze laesst sich nicht darunter setzen — die Gegenprobe: der Versuch wird abgewiesen, nicht protokolliert
- [ ] #3 Eine gesenkte Frist holt die beiden Ankuendigungen nach; die Gegenprobe: nach einer Senkung wird am naechsten Morgen nichts geraeumt
- [ ] #4 Eine Aenderung wirkt ab valid_from und nie rueckwirkend
- [ ] #5 hebel.md, Block 17 und das Verarbeitungsverzeichnis sagen dasselbe
<!-- AC:END -->
