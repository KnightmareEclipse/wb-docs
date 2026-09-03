---
id: TASK-212
title: 'Mitarbeiter-Onboarding über das Portal: Konto anlegen und Teams zuordnen'
status: To Do
assignee: []
created_date: '2026-09-03 14:52'
updated_date: '2026-09-03 18:20'
labels:
  - m365
  - stammdaten
milestone: m-5
dependencies: []
references:
  - soll-prozesse/13-m365-konten.md
  - schema/stammdaten-schema.sql
  - zugang.md
ordinal: 225000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Idee der Geschäftsführung vom 03.09.2026: Beim Eintritt eines Mitarbeitenden legt **Weltenbaum** das Microsoft-Konto an und ordnet ihn den zuständigen Teams zu — statt dass der Admin eine Nachzieh-Aufgabe abarbeitet. Auf lange Sicht soll das ganze Onboarding hier laufen.

Das dreht Block 13 um: Heute führt der Admin die Konten und Weltenbaum erzeugt ihm Aufgaben (`sync_tasks`); künftig wäre Weltenbaum die schreibende Stelle und der Tenant das Ziel. Deshalb ist das kein Nachtrag zu 13, sondern ein eigener Durchgang.

**Der Preis steht ganz vorn, weil er die Entscheidung trägt:** Eine App-Registrierung, die Konten anlegen und Gruppen ändern darf, braucht `User.ReadWrite.All` und `Group.ReadWrite.All` — Rechte, mit denen sich der ganze Tenant umbauen lässt, einschließlich der Konten der Geschäftsführung. Heute hat die Anwendung nichts dergleichen. Das ist gegen die Vertrauensgrenze (`rules.md` Abschnitt 2) abzuwägen und nicht nebenbei zu vergeben; die Alternative bleibt die Aufgabe an den Admin, die es schon gibt.

**Die private Mailadresse ist der zweite Punkt.** Ein neuer Mitarbeitender hat noch kein Clemens-Konto, kann sich also nicht über den Tenant anmelden und ist nur privat erreichbar. Ein Ort dafür steht bereits: `persons.email` ist ausdrücklich die private Adresse, `employees.work_email` die dienstliche, und Letztere darf leer sein, „sie entsteht erst mit dem Konto". Zu entscheiden ist nur, **ob der Eintretende selbst hereinkommt** — dann bräuchte er vorübergehend den Einmalcode-Weg, der heute den Eltern gehört — **oder ob das Onboarding ohne seinen Login läuft** und jemand anders einträgt. Das Zweite ist deutlich kleiner und reicht für den ersten Schritt.

Und die Frist: Eine private Adresse, die allein dem Onboarding dient, hat danach keinen Zweck mehr. Sie geht mit dem Mitarbeitendeneintrag, dessen Frist noch offen ist (fragen.md).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob Weltenbaum schreibend in den Tenant greift — mit den nötigen Graph-Rechten und ihrem Preis benannt
- [ ] #2 Entschieden, ob der Eintretende selbst hereinkommt oder ob jemand anders einträgt
- [ ] #3 Die private Adresse steht an persons.email, nicht in einem neuen Feld
- [ ] #4 Die Teamzuordnung folgt der Rolle und dem Bereich, nicht einer Liste im Code
- [ ] #5 Der Weg zurück ist beschrieben: was geschieht, wenn das Anlegen im Tenant scheitert
<!-- AC:END -->
