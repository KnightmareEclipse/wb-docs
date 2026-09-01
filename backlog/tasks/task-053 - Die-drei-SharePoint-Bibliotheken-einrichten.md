---
id: TASK-053
title: Die drei SharePoint-Bibliotheken einrichten
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-09-01 20:18'
labels:
  - wartet
  - zweiter-admin
  - sharepoint
milestone: m-4
dependencies: []
references:
  - grenzkarte.md
  - api/rechnungsfreigabe-api.md
  - oberflaechen.md
priority: high
ordinal: 56000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Eine für die **Schülerakte** — was Weltenbaum erzeugt und was Menschen dazulegen, in einem Ordner je Kind mit Unterordnern je Kategorie. **Kein Mensch bekommt Direktzugriff** (entschieden am 02.09.2026): Die App schreibt und liest, alles Weitere läuft über Weltenbaum (TASK-187). Eine für die **Hortakte** — Absprachen, Verhalten, Beobachtungsbögen; allein Hortkräfte und Hortleitung, die dort in fortgeschriebenen Dokumenten arbeiten. Eine für die **Beleganhänge** der Rechnungsfreigabe — App schreibt und liest, kein Mensch direkt, Ordner je Kalenderjahr, kein Kindbezug.

Je Bibliothek ein Sites.Selected-Grant. Form und Begründung stehen fest (grenzkarte.md, Q2), offen sind die konkreten Sites.

**Bis Weltenbaum ablegen kann, behält das Sekretariat seinen Zugriff auf die Schülerakte** — er wird mit TASK-187 entzogen, nicht vorher.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Keine Berechtigung je Kind — der Zuschnitt ist die Bibliothek
- [ ] #2 Die vorhandenen Aktenordner einmalig mit child_file_folders verknüpfen
- [ ] #3 Auf Belege und Schülerakte hat kein Mensch Direktzugriff, auch nicht Sekretariat und Geschäftsführung
- [ ] #4 Auf die Hortakte hat niemand außer Hortkräften, Hortleitung und der App Zugriff
- [ ] #5 Die Hortakte steht auf „Offline und Synchronisierung = Nein"; geprüft ist, ob „In Desktop-App öffnen" erhalten bleibt
- [ ] #6 Der Zugriff des Sekretariats auf die Schülerakte wird mit TASK-187 entzogen, nicht früher
<!-- AC:END -->
