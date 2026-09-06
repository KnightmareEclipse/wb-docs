---
id: TASK-282
title: Antwort des Sekretariats zum Familien-Abgleich
status: To Do
assignee: []
created_date: '2026-09-07 10:30'
labels:
  - wartet
  - sekretariat
  - import
  - stammdaten
dependencies:
  - TASK-017
references:
  - wb-backend/etl/run.py
  - wb-backend/etl/persons.py
milestone: m-1
priority: high
ordinal: 294000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Zwei Arbeitsmappen liegen im Teams des Sekretariats, dazu die Bitte um Rückmeldung noch in
dieser Woche. **Daran hängt der Start des Putzdiensts:** Ohne die Familien lässt sich keine
Pflichtmenge zuteilen, und ohne die Mitarbeiterliste bekommen befreite Familien Termine, die
sie nicht schulden.

`zweifel-import.xlsx` — drei Blätter, die eine Antwort brauchen:

- **Gleiche Person** (heute 22 Fälle): Derselbe Name steht an zwei Anschriften. Eine Person
  oder zwei? Der Rechner führt bei gleichem Namen **und** gleicher Anschrift zusammen; bei
  verschiedenen Anschriften entscheidet ein Mensch.
- **Eine Familie** (heute 8 Fälle): Kinder mit überlappender, aber ungleicher Elternmenge —
  der Patchwork-Fall.
- **Eltern bei uns angestellt**: leer zum Eintragen. Wer angestellt ist und ein eigenes Kind
  an der Schule hat, ist vom Putzdienst befreit (`schema/putzdienst-schema.sql`,
  `cleaning_family_quotas`). In ASV steht das nicht — das `personal`-Flag ist bei einer von
  1722 Personenzeilen gesetzt, die Lehrer-Stammtabelle fehlt im Dump ganz.

`familien-vorschlag.xlsx` — 401 Zeilen, nur zum Nachsehen. Nach Familiengröße sortiert, die
größten oben: Eine falsche Zusammenführung ist dort eine Gruppe mit vier Kindern
verschiedener Nachnamen und fällt beim Durchscrollen auf.

**Eingelesen wird mit** `python etl/run.py … --antworten <Mappe>`. Der Lauf meldet, wie viele
Antworten verstanden wurden, welche Texte er nicht deuten konnte und welche Namen der
Mitarbeiterliste niemanden im Bestand treffen. Eine leere Zelle heißt „noch offen" und wird
nachgefragt — nichts wird geraten.

**Wenn zwischenzeitlich ein neuer Export gezogen wird**, verfallen Antworten, deren Fallgruppe
sich geändert hat: Der Schlüssel trägt alle beteiligten Kennungen, und eine veränderte Gruppe
ist ein neuer Fall. Der Lauf meldet das als „Antworten ohne heutigen Fall". Deshalb die
beantwortete Mappe aufheben und beim nächsten Lauf wieder mitgeben.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Beide Mappen liegen im Teams des Sekretariats, die Mail ist raus
- [ ] #2 Die ausgefüllte Mappe liegt vor und ist mit `--antworten` eingelesen
- [ ] #3 Kein Fall bleibt still offen: unbeantwortete und nicht verstandene Antworten sind nachgefragt
- [ ] #4 Die Namen der Mitarbeiterliste sind dem Bestand zugeordnet; nicht getroffene sind geklärt
- [ ] #5 Die beantwortete Mappe ist aufgehoben, damit ein zweiter Export sie wiederverwenden kann
<!-- AC:END -->
