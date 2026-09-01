---
id: TASK-118
title: >-
  Klären, ob das Barrierefreiheitsstärkungsgesetz auf das Elternportal anwendbar
  ist
status: Done
assignee: []
created_date: '2026-08-27 22:45'
updated_date: '2026-09-01 20:14'
labels:
  - wartet
  - schulleitung
  - frontend
  - entscheidung
milestone: m-0
dependencies: []
references:
  - oberflaechen.md
ordinal: 130000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Seit 28.06.2025 in Kraft; die Kleinstunternehmer-Ausnahme greift bei einer Schule dieser Größe vermutlich nicht. Bisher nirgends bewertet. Die Antwort entscheidet, wie das Portal gebaut wird, nicht wie es nachgebessert wird — deshalb vor der Werkzeugwahl.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Anwendbar ja oder nein, mit Begründung
- [x] #2 Falls ja: welche Anforderungen der Portal-Entwurf erfüllen muss
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Beantwortet am 01.09.2026 von der Geschäftsführung: Ja, das BFSG gilt — die Kleinstunternehmer-Ausnahme greift nicht. Der Maßstab steht schon in oberflaechen.md: WCAG 2.1 AA, worauf EN 301 549 und damit das BFSG zeigen, umgesetzt über React Aria. Kein Nachrüsten und damit kein Extra-Aufwand, solange von Anfang an so gebaut wird — Tastaturbedienung, Kontrast, echte Beschriftungen, vorlesbare Fehlermeldungen. Nicht in diesem Ticket: Die Pflicht trifft auch die erzeugten Vertrags-PDFs, nicht nur die Oberfläche (TASK-186).
<!-- SECTION:NOTES:END -->
