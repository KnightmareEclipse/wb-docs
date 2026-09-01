---
id: TASK-166
title: 'Routen des Elternbonus umbauen: Einsatz, Anmeldung, keine Bestätigung'
status: To Do
assignee: []
created_date: '2026-09-01 17:46'
updated_date: '2026-09-01 18:09'
labels:
  - wb-backend
  - elternbonus
  - route
  - test
dependencies:
  - TASK-165
references:
  - wb-backend/app/routers/elternbonus.py
  - wb-backend/tests/test_elternbonus.py
  - api/elternbonus-api.md
ordinal: 178000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Router trägt heute die Bestätigung samt _confirmable() und der Auswahlliste der bestätigenden Person. Beides fällt.

Neu: Die sechs ausschreibenden Rollen legen Einsätze an — für alle Familien oder für eine Zielgruppe aus benannten Klassen und Zuschnitten (Schulart, Stufenspanne) —, sehen die Angemeldeten mit Namen und sagen ab; die Absage schickt die Mail an alle Angemeldeten. Eltern sehen nur die Einsätze, die sie betreffen, melden sich an und ab und sehen dabei nur die Zahl der Angemeldeten.

Die Platzzahl hält der Trigger, nicht die Route — die Route fängt seine check_violation und macht daraus eine Meldung, die sagt, dass der Einsatz voll ist. Ein 500er wäre hier der Fehler.

Der Stundeneintrag verliert die bestätigende Person und bekommt den freiwilligen Bezug auf den Einsatz; ohne Einsatz eingetragen wird weiterhin, und das ist der häufigere Weg.

Die Tests ziehen mit: Was von der Bestätigung geprüft wurde, fällt; die neuen Fälle — Anmeldung doppelt, volle Platzzahl, Platz nach einer Abmeldung wieder frei, ein Einsatz einer fremden Klasse, ein Zuschnitt "ab Klasse 7", Absage mit Mail, Eintrag ohne Einsatz, Namen nur für den Ausschreibenden — werden je einmal rot gesehen, bevor sie grün sind.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die zwei Bestätigungsrouten sind entfernt, _confirmable() mit ihnen
- [ ] #2 Routen für Einsatz und Anmeldung stehen und folgen dem API-Plan
- [ ] #3 Die Eltern bekommen die Zahl der Angemeldeten, nie die Namen — ein Test hält das fest
- [ ] #4 Die Absage löst die Mail an die Angemeldeten aus
- [ ] #5 test_elternbonus.py läuft grün, jeder neue Fall war einmal rot
<!-- AC:END -->
