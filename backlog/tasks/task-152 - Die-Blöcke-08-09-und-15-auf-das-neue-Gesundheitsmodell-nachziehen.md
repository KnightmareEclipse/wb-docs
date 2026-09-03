---
id: TASK-152
title: 'Die Blöcke 08, 09 und 15 auf das neue Gesundheitsmodell nachziehen'
status: Done
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-03 19:05'
labels:
  - wb-docs
  - gesundheit
  - dsgvo
dependencies:
  - TASK-205
references:
  - soll-prozesse/08-schulvertrag.md
  - soll-prozesse/09-hortvertrag.md
  - soll-prozesse/15-klassenbildung.md
  - schema/gesundheit-schema.sql
  - grenzkarte.md
ordinal: 164000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Schema-Umbau der Domäne 9 ist gefahren, die Blöcke behaupten noch den alten Ablauf: Pflicht auf alle Kategorien, drei ineinanderliegende Sichtstufen, kein Notfallweg. Der Block schlägt alles (CLAUDE.md-Rangfolge) — solange er das Alte sagt, ist das Schema unbegründet.

Nachzuziehen sind inzwischen **fünf** Dinge, nicht drei; die letzten beiden kamen am 02./03.09.2026 dazu:

- Die Angaben sind je Kategorie **freiwillig und in der Tiefe wählbar**.
- Sichtbar wird je Angabe an einen **Sichtkreis** statt je Stufe — und der Schnitt ist grob: Lehrkräfte und Hort sehen alles, allein die Küche ist auf Allergie und Lebensmittelunverträglichkeit reduziert.
- Die **Notfalleinsicht** steht jedem Mitarbeitenden für jedes Kind offen, protokolliert statt genehmigt; die Meldung an die Geschäftsführung geht unmittelbar beim Auslösen heraus, und das Protokoll geht mit dem Kind.
- **"Für ihre Kinder" heißt: wer das Kind unterrichtet** — Klassenleitung, Unterricht in seiner Klasse, oder seine Wahlmodulgruppe (TASK-161). Die Klasse bleibt dabei die Einheit, auch wo der Förderunterricht feiner wäre; die Begründung steht dort.
- Die **Freigabe je Angabe und Instanz** (TASK-205): Schule und Hort sind zwei Instanzen desselben Bestands, die Eltern geben je Instanz erst überhaupt und dann je Angabe frei — in einer Handlung für alles oder einzeln. In 09 ersetzt das die bisherige Fassung der Freigabe an den Hort samt Ablehnungsrecht.

Grund und Modell stehen in schema/gesundheit-schema.sql (Dateikopf) und in grenzkarte.md ("Zugriff, je Angabe").
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 08 Z2 beschreibt die Freiwilligkeit je Kategorie und den Unterschied zwischen 'nichts vorhanden' und 'nicht beantwortet'
- [x] #2 09 Z3 beschreibt die Freigabe an den Hort als Instanz-Freigabe je Angabe, samt Ablehnungsrecht und Sammelfreigabe
- [x] #3 15 beschreibt die Einsicht der Klassenlehrkraft als Sichtkreis, nicht als oberste Stufe
- [x] #4 Keine der drei Dateien nennt noch 'Alltagsangaben' als Stufe oder die drei konzentrischen Sichten
- [x] #5 Die Notfalleinsicht steht in genau einem Block und wird von den anderen nur genannt
- [x] #6 Wo ein Block 'die Lehrkräfte' sagt, steht jetzt, welche — die zweite Achse wird genannt, nicht wiederholt
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
08 trägt die Freiwilligkeit je Kategorie samt der drei Zustände, den groben Schnitt,
das Attest als Vorliegen, die Freigabe je Instanz und die Notfalleinsicht — Letztere
in genau diesem Block, 09 und 15 nennen sie nur. 09 beschreibt den Hort als eigene
Instanz desselben Bestands. 15 trägt die zweite Achse und nennt sie, statt sie zu
wiederholen. „Alltagsangaben" als Stufe kommt in keiner der drei Dateien mehr vor.
<!-- SECTION:NOTES:END -->
