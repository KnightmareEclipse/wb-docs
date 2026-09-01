---
id: TASK-193
title: Datenexport je Person auf Knopfdruck
status: To Do
assignee: []
created_date: '2026-09-01 23:05'
labels:
  - wb-backend
  - dsgvo
  - querschnitt
milestone: m-1
dependencies: []
ordinal: 206000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der eine Mechanismus, den Weltenbaum zur Auskunft nach Art. 15 beiträgt: ein Knopf, der zu einer Person oder einem Kind alles ausgibt, was hier über sie steht — über alle Domänen hinweg, eingesammelt über persons.person_id bzw. children.child_id.

Bewusst klein gehalten (TASK-055): Kein Antrag im Portal, keine Fristenverwaltung, keine Statusverfolgung. Die Auskunft selbst bleibt organisatorisch bei der Arbeitshilfe des Sekretariats, unser Auszug wird eine weitere Zeile darin. Reicht das später nicht, wird erweitert — die umgekehrte Richtung wäre teurer.

Zwei Dinge sind nicht verhandelbar, weil sie den Sinn tragen:

- **Vollständig oder gar nicht.** Ein Export, der eine Domäne vergisst, ist schlechter als keiner: Er sieht nach Erfüllung aus. Die Gegenprobe ist eine Liste aller Tabellen mit Personenbezug — wer eine neue Domäne baut, trägt sie hier nach.
- **Eine benannte Rolle, und der Abruf wird protokolliert.** Es ist der größte Lesezugriff, den das System kennt. zugang.md führt Exporte bereits als eigenen Fall: keine Ownership-Prüfung schützt ihn, deshalb enge Rolle und zentrale Protokollierung, nie über den OTP-Pfad der Eltern.

Der Ablauf steht in soll-prozesse/18-dsgvo-auskunft.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Export sammelt über alle Domänen mit Personenbezug ein, belegt durch eine Gegenprobe gegen die Tabellenliste
- [ ] #2 Nur die benannte Rolle kommt heran, nie ein Eltern-Token
- [ ] #3 Jeder Abruf steht im zentralen Logging
- [ ] #4 Ein Test zeigt, dass eine neu hinzugefügte Tabelle mit Personenbezug auffällt
<!-- AC:END -->
