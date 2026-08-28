---
id: TASK-126
title: Soll-Block Schulvertragsupdate schreiben
status: In Progress
assignee: []
created_date: '2026-08-28 13:27'
updated_date: '2026-08-28 15:49'
labels:
  - wb-docs
  - soll-block
  - geschaeftsfuehrung
  - vertragstext
  - wartet
milestone: m-5
dependencies: []
references:
  - soll-prozesse/08-schulvertrag.md
  - soll-prozesse/README.md
  - schema/querschnitt-schema.sql
ordinal: 138000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Geschäftsführung will allen Familien die neueste Fassung des Schulvertrags vorlegen — die Änderungen der letzten Jahre grün markiert —, und alle bis auf die Jahrgänge 1 und 5, die gerade unterschrieben haben, bestätigen per Klick und Unterschrift die Kenntnisnahme. Zwei Drittel der Mechanik stehen: contract_texts trägt Fassungen mit Gültigkeitstag, Unterschriftenstrecke und Dokumenterzeugung gibt es aus 08. Es fehlt der Anker — ck_signatures_subject kennt Vertragsvorgang, Mandat und Kind, keine Kenntnisnahme einer Fassung durch eine bestehende Familie.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Wer stellt die Fassung ein, wen erreicht sie, wen ausdrücklich nicht
- [ ] #2 Kenntnisnahme je Familie oder je sorgeberechtigter Person — und Unterschrift oder Haken
- [ ] #3 Was geschieht, wenn niemand antwortet: Erinnerung, Sperre oder nichts
- [ ] #4 Der Anker entschieden — vierter Bezug in signatures oder eigene Tabelle, samt Löschanker
- [ ] #5 Termin gesetzt: die Geschäftsführung will ihn zum Schuljahresanfang, ein Elternportal gibt es dafür noch nicht
<!-- AC:END -->
