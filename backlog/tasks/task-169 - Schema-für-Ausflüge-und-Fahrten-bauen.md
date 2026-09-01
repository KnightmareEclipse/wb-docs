---
id: TASK-169
title: Schema für Ausflüge und Fahrten bauen
status: To Do
assignee: []
created_date: '2026-09-01 18:44'
labels:
  - schema
  - veranstaltungen
  - wb-docs
dependencies:
  - TASK-168
references:
  - soll-prozesse/19-ausfluege-und-fahrten.md
  - grenzkarte.md
  - prompts/schema-bauen.md
ordinal: 181000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus Block 19. Neue Domäne, keine vorhandene trägt sie: der Ausflug samt Ziel, Zeitraum, Rahmenbedingungen, Kostenrahmen, verantwortlicher und begleitenden Lehrkräften, den eingeladenen Klassen und der Freigabe durch die Schulleitung; darunter die Teilnahme je Kind mit ihren vier Zuständen (angemeldet, nicht teilgenommen, vor Antritt ausgeschlossen, vorzeitig beendet), den tatsächlich angefallenen Kosten und — bei der freiwilligen Fahrt — Zustimmung, Vollmacht, Kostenzusage und den fahrtgebundenen Erlaubnissen.

Die Art (unterrichtlich/außerunterrichtlich) steuert, ob Anmeldung und Erklärung überhaupt existieren. Sie hängt an TASK-168 — solange die Schulleitung sie nicht bestätigt hat, wird sie nicht gebaut.

Die Vollmacht an die Lehrkraft und die unterschriebene Erklärung sind Q1 und Q2 und entstehen nicht neu. Der Ratenplan der mehrtägigen Fahrt ist Q3 und geht über die vorhandene Bezahlstrecke.

Nach prompts/schema-bauen.md, danach schema-pruefen.md in einer frischen Session.

Beschlossen am 01.09.2026 mit der Geschäftsführung, Ablauf in soll-prozesse/19-ausfluege-und-fahrten.md und soll-prozesse/20-ausflugskonto.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die vier Teilnahmezustände sind darstellbar und voneinander unterscheidbar
- [ ] #2 Die Freigabe der Schulleitung ist Bedingung dafür, dass Eltern etwas sehen — und das steht als Gegenprobe da
- [ ] #3 Kostenrahmen und tatsächliche Kosten sind zwei Angaben, nicht eine
- [ ] #4 Das Prüfskript weist eine Anmeldung an einem nicht freigegebenen Ausflug ab
- [ ] #5 Vollmacht und Erklärung nutzen Q1/Q2, der Ratenplan Q3 — keine zweite Bauform daneben
<!-- AC:END -->
