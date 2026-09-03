---
id: TASK-173
title: Die vier Angaben des Fahrtformulars als Anlassangaben führen
status: To Do
assignee: []
created_date: '2026-09-01 18:45'
updated_date: '2026-09-03 12:34'
labels:
  - gesundheit
  - veranstaltungen
  - wb-backend
dependencies:
  - TASK-169
references:
  - soll-prozesse/19-ausfluege-und-fahrten.md
  - schema/gesundheit-schema.sql
ordinal: 185000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Anmeldebogen der Klassenfahrt fragt vier Dinge, die der Bestand nicht kennt: Tetanus- und FSME-Impfschutz je **mit Datum**, Schwimmfähigkeit samt Abzeichen und ob eine private Haftpflicht besteht.

**Sie gehören nicht in den Bestand** (entschieden am 03.09.2026): In den Bestand kommt nur, was der Vertrag erhebt. Alles, was allein über eine Veranstaltung hereinkommt, fällt vier Wochen nach ihr — auch der Impfschutz. Sie auf Vorrat zu behalten, weil vielleicht eine weitere Fahrt dieselbe Angabe braucht, ist keine Begründung: Dass sie kommt, ist nicht sicher.

Zu bauen bleibt trotzdem etwas, und deshalb steht dieses Ticket weiter: Die vier Felder muss es als `health_fields` geben, damit eine Fahrt sie überhaupt stellen kann. Das Impfdatum ist der Grund, warum das nicht bloß eine Zeile ist — ein Datum im Freitext ist nicht auswertbar, es braucht die Wertart "date". Die Antworten hängen dann am Anlass und tragen dessen Frist (TASK-162), nicht am Kind.

Dasselbe Los tragen Badeerlaubnis, Erlaubnis für besondere Aktivitäten und die Versicherung über ansteckende Krankheiten; sie waren schon vorher fahrtgebunden.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die vier Felder stehen als health_fields mit ihren Wertarten, darunter 'date' für die beiden Impfdaten
- [ ] #2 Keine der vier Angaben hängt am Kind: die Antwort hängt am Anlass und fällt vier Wochen nach der Fahrt
- [ ] #3 Das Prüfskript weist eine dieser Angaben ohne Anlassbezug ab
<!-- AC:END -->
