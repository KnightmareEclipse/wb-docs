---
id: TASK-163
title: 'Fragensatz je Anlass: vorbefüllen und bestätigen statt neu erheben'
status: To Do
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-03 12:34'
labels:
  - wb-backend
  - wb-elternportal
  - gesundheit
dependencies:
  - TASK-162
references:
  - soll-prozesse/09-hortvertrag.md
  - soll-prozesse/10-ferienprogramm.md
  - pruefberichte/gespraech-geschaeftsfuehrung.md
ordinal: 175000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Gewinn aus dem Anlassbezug für die Eltern: Ein Anlass fragt nur die Felder, die er braucht, zeigt das Bekannte vorbefüllt und lässt es bestätigen. Eine neue Frage geht dann nur an die, die sie noch nicht beantwortet haben — keine Sammelaktion über alle 500 mehr.

Und die Bestätigung der Aktualität, die die Geschäftsführung am 01.09.2026 für den Hortvertrag verlangt hat, ist derselbe Mechanismus.

Ausdrücklich nicht dabei: Feldreihenfolge, Layout, bedingte Anschlussfragen, Formularversionierung. Ein Fragensatz ist eine Menge von Feldern; alles Weitere entsteht, wenn ein Fall dafür vorliegt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ein Anlass zeigt genau seine Felder, das Bekannte vorbefüllt und als bestätigbar markiert
- [ ] #2 Eine neu hinzugefügte Frage erreicht nur Kinder ohne Antwort darauf
- [ ] #3 Die Bestätigung der Aktualität ist festgehalten, nicht nur angezeigt
- [ ] #4 Kein Formularbaukasten: keine Reihenfolge, kein Layout, keine bedingten Fragen
- [ ] #5 Auch der Ausflug stellt seinen Fragensatz aus derselben Liste zusammen — ein Mechanismus für Ferienprogramm, Akademie und Fahrt, nicht drei
<!-- AC:END -->
