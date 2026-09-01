---
id: TASK-167
title: Die Ferienbuchung erhebt Gesundheitsangaben
status: To Do
assignee: []
created_date: '2026-09-01 17:48'
labels:
  - wb-backend
  - ferien
  - gesundheit
  - dsgvo
  - wartet
dependencies:
  - TASK-162
references:
  - soll-prozesse/10-ferienprogramm.md
  - schema/ferien-schema.sql
  - api/ferien-api.md
  - pruefberichte/fragen-datenschutz.txt
ordinal: 179000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Entschieden am 01.09.2026: Das Ferienprogramm braucht Gesundheitsangaben — die Programme sind interaktiv geworden, mit Unternehmungen, bei denen eine Allergie oder eine Medikation zählt. Bis dahin sagte der Block ausdrücklich, er erhebe keine; Block 10, ferien-schema.sql, ferien-api.md und fachdomaenen.md sind nachgezogen, gebaut ist nichts.

Zwei Wege, je nachdem wer bucht: Ein **Kind der Schule** hat den Bestand schon — die Eltern geben ihn beim Buchen für dieses Programm frei und dürfen die Freigabe verweigern. Ein **fremdes Kind** hat keinen; bei ihm entsteht er mit der Buchung, denn es gibt keinen anderen Weg, auf dem er entstünde.

Welche Fragen ein einzelnes Programm zusätzlich stellt, steht noch nicht fest und muss es auch nicht: Ein Fragensatz ist eine Menge von Feldern (TASK-163). Was hier fehlt, ist der Anlass und seine Frist — der Bestand eines fremden Kindes rechnet vom letzten gebuchten Termin und nicht vom Austritt, den es nicht hat, und gelöscht wird erst nach der Nachweisfrist des Datenschutzbeauftragten (Briefing, Punkt 3c und 4).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Buchung eines fremden Kindes legt seinen Gesundheitsbestand an
- [ ] #2 Die Buchung eines Kindes der Schule fragt die Freigabe ab und lässt sie verweigern
- [ ] #3 Eine verweigerte Freigabe verhindert die Buchung nicht — das Kind fährt mit, die Betreuung sieht nichts
- [ ] #4 Der Bestand eines fremden Kindes trägt seine eigene Frist ab dem letzten gebuchten Termin
- [ ] #5 Die Teilnehmerliste zeigt den Ausschnitt des Sichtkreises der lesenden Rolle
<!-- AC:END -->
