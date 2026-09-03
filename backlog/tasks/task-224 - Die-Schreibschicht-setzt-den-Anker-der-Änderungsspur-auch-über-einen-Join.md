---
id: TASK-224
title: Die Schreibschicht setzt den Anker der Änderungsspur auch über einen Join
status: To Do
assignee: []
created_date: '2026-09-03 22:26'
labels:
  - wb-backend
  - dsgvo
  - querschnitt
dependencies: []
priority: high
ordinal: 236000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Block 17 hat entschieden: Die Änderungsspur trägt keine eigene Frist, sondern den Anker der Sache, über die sie Auskunft gibt — sie lebt genau so lange wie das Kind, die Person oder die Familie und geht per Cascade mit ihnen. Eine feste Frist wäre in beide Richtungen falsch: Wer nachweisen muss, wer den Vermerk 'kein Epileptiker' entfernt hat, braucht die Spur, solange das Kind an der Schule ist.

Heute setzt app/db/base.py den Anker nur aus einem direkten Attribut der geänderten Zeile. 66 der hundert Tabellen erreichen Kind, Person oder Familie erst über zwei oder drei Tabellen hinweg; ihre Spur bleibt damit ankerlos und würde nie gelöscht. Je Modell gehört deshalb der Ankerpfad deklariert, und die Schreibschicht folgt ihm.

Die Gegenprobe steht schon: querschnitt-schema-check.sql rechnet über die Fremdschlüssel aus, welche Tabellen bei einem der drei ankommen, und meldet jede Spurzeile ohne Anker. Sie wächst von selbst mit — eine neue Tabelle mit Personenbezug fällt dort auf, ohne dass jemand eine Liste pflegt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Je Modell mit Personenbezug ist der Ankerpfad deklariert und die Schreibschicht folgt ihm
- [ ] #2 Ein Test schreibt in eine Tabelle, die ihren Anker erst über zwei Joins erreicht, und die Spurzeile trägt ihn
- [ ] #3 Die Abfrage aus querschnitt-schema-check.sql läuft als Test gegen die Testdatenbank und findet nichts
- [ ] #4 Ankerlos bleibt allein, was keinen Personenbezug hat; ihre Spur nimmt der Lauf mit der Zeile selbst
<!-- AC:END -->
