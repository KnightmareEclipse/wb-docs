---
id: TASK-211
title: Einschätzung zur LogaHR-Schnittstelle schreiben
status: To Do
assignee: []
created_date: '2026-09-03 14:51'
updated_date: '2026-09-03 18:20'
labels:
  - stammdaten
milestone: m-5
dependencies: []
references:
  - schema/stammdaten-schema.sql
  - soll-prozesse/13-m365-konten.md
ordinal: 224000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das HR-Tool heißt **LogaHR** (Geschäftsführung, 03.09.2026), Einführung voraussichtlich ab Januar. Gefragt ist eine erste Einschätzung: welche Mitarbeiterdaten Weltenbaum überhaupt braucht und was davon automatisiert übernommen werden könnte.

**Die halbe Antwort steht schon und ändert sich nicht:** Weltenbaum führt je Mitarbeitendem Name, dienstliche Mailadresse, Schule oder KITA, ersten und letzten Arbeitstag, die Rolle im System und eine Nachfolgenotiz — kein Gehalt, kein Arbeitsvertrag, keine Bewerbungsunterlagen. Genau das ist zu sagen, und zwar zuerst: Eine Schnittstelle, die mehr liefert, als hier stehen darf, ist keine Erleichterung, sondern ein Datenschutzproblem.

Zu recherchieren bleibt, **was LogaHR an Übergabewegen anbietet** — API, Export, LDAP —, und ob der Weg zu uns oder von uns geht. Der wertvolle Teil ist der **erste und letzte Arbeitstag**: An ihm hängt in Weltenbaum alles Weitere, denn mit seinem Ablauf enden alle Rollen von selbst.

**Die Richtung ist umgekehrt gedacht als zunächst angenommen** (03.09.2026): Nicht LogaHR füttert Weltenbaum, sondern Weltenbaum soll beim Eintritt das Microsoft-Konto anlegen und den Teams zuordnen — siehe das Ticket zum Onboarding. Diese Einschätzung sagt deshalb auch, was LogaHR dafür liefern müsste und was es nicht liefern kann.

Kein Bau in diesem Ticket, nur die Antwort an Jürgen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Liste dessen, was Weltenbaum an Mitarbeitenden führt, steht in der Antwort — samt dem Satz, dass mehr nicht hierher gehört
- [ ] #2 Benannt, welche Übergabewege LogaHR anbietet und in welche Richtung sie laufen sollen
- [ ] #3 Der erste und letzte Arbeitstag ist als der tragende Wert benannt
<!-- AC:END -->
