---
id: TASK-140
title: 'Die Oberflächen zu den elf Prozessen, die keine haben'
status: To Do
assignee: []
created_date: '2026-08-30 18:45'
labels:
  - frontend
  - wb-elternportal
  - wb-intern
dependencies: []
references:
  - oberflaechen.md
  - soll-prozesse/README.md
  - api/gemeinsam.md
  - wb-elternportal/src/api.ts
  - wb-intern/src/api.ts
ordinal: 152000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gemessen am 30.08.2026: 235 Routen in wb-backend, 37 davon haben eine Oberfläche vor sich — Putzdienst (29), der Anmeldeweg selbst (6) und die Zahlungen (2). Beide Oberflächen rufen genau eine Fachdomäne auf, cleaning, intern dazu payments. Anmeldung (54 Routen), Stammdaten (39), Rechnungsfreigabe (30), Querschnitt (23), Ferien (19), Mensa (16), Gesundheit (7), Elternbonus (5) und Klassenorganisation (4) sind vollständig gebaut, getestet und für keinen Menschen erreichbar; bedienbar sind sie allein per curl.

Das ist der größte verbliebene Bauposten und hatte bis hierher kein Ticket: TASK-112 und TASK-113 sind Done, weil sie 'Werkzeug wählen, Repo anlegen, erste Ansichten bauen' hießen — das Werkzeug steht, die Ansichten fehlen.

Nicht zu raten, sondern zu entscheiden, bevor das Ticket zerlegt wird: ob die Portionierung dem Soll-Block folgt (ein Vorgang, beide Oberflächen) oder der Oberfläche (ein Repo, viele Vorgänge). Der Schnitt der Publika steht fest und ist keine Frage — oberflaechen.md trennt am Hostnamen, Eltern auf portal., Personal auf intern. im Teams-Tab. Eine Domäne verteilt sich dabei regelmäßig über beide: Die Bewerbung füllen Eltern aus, entschieden wird sie intern.

Zwei Dinge hängen daran und werden hier nicht mitentschieden: TASK-010 (ein Formular je Vorgang, zwei Einstiege) ist die Regel für die Anmelde- und Buchungsformulare und gehört in den Teil, der sie baut; TASK-117 (Datenschutzerklärung und Impressum) muss stehen, bevor der erste echte Elternzugriff läuft.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Portionierung ist entschieden und das Ticket danach zerlegt
- [ ] #2 Je Teil: jede Route der Domäne hat entweder eine Ansicht oder eine Zeile, warum keine
- [ ] #3 Kein Inline-Skript und kein onclick — die CSP lässt nur ausgelieferte Dateien zu
- [ ] #4 Die Ownership-Bedingung bleibt Sache der Route; die Auswahl in der Oberfläche ist Bedienführung, keine Sicherheitsgrenze
<!-- AC:END -->
