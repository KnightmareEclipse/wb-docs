---
id: TASK-126
title: Soll-Block Schulvertragsupdate schreiben
status: In Progress
assignee: []
created_date: '2026-08-28 13:27'
updated_date: '2026-09-04 01:35'
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
- [x] #2 Kenntnisnahme je Familie oder je sorgeberechtigter Person — und Unterschrift oder Haken
- [x] #3 Was geschieht, wenn niemand antwortet: Erinnerung, Sperre oder nichts
- [x] #4 Der Anker entschieden — vierter Bezug in signatures oder eigene Tabelle, samt Löschanker
- [ ] #5 Termin gesetzt: die Geschäftsführung will ihn zum Schuljahresanfang, ein Elternportal gibt es dafür noch nicht
- [ ] #6 Beantwortet am 02.09.2026: erst Erinnerung, dann Sperre im Portal — und in beiden Fällen ein Hinweis ans Sekretariat, damit es nachgehen kann. Begründung: ob ein Vertrag ohne bestätigte wesentliche Änderung weiterläuft, ist eine Prüfung und kein Automatismus
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Beantwortet am 04.09.2026 (Betreiber): Es zeichnen ALLE Sorgeberechtigten — nicht eine Person wie bei der Modulanlage, sondern wie beim Vertrag selbst, den der Nachtrag aendert. Und der Vorgang steht JE VERTRAG, also je Kind: drei Kinder heissen drei Nachtraege, vorgelegt in einem Griff. Der Anker bleibt damit contract_id, wie gebaut.

Die verworfene Alternative samt Preis steht als Absatz am Tabellenkommentar: ein Vorgang je Familie und Fassung haette eine zweite Tabelle allein dafuer gebraucht, die Urkunde je betroffenem Vertrag zu tragen — eine Datei in der Akte gehoert immer genau einem Kind (grenzkarte.md Q2 und der Loesch-Lauf). Bei zwei Schularten in einer Familie sind es ohnehin zwei Vorgaenge, weil der Vertragstext an der Schulart haengt.

Dass die Unterschriften vollzaehlig sind, prueft die Anwendung und kein Constraint: Wie viele es sind, steht in family_guardians und nicht in der Nachtragszeile — dieselbe Auslassung wie am Vertrag, wo released_at das Ergebnis traegt.

Offen bleiben Kriterium 1 (wen die Vorlage erreicht, wen ausdruecklich nicht) und 5 (Termin).
<!-- SECTION:NOTES:END -->
