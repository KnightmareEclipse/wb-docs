---
id: TASK-231
title: Die mitgeltenden Anlagen als dritte Klasse
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
labels:
  - wb-docs
  - schema
  - wartet
milestone: m-5
dependencies: []
ordinal: 243000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
09 hat die Regel schon entschieden: „Die übrigen Anlagen — Fotoeinwilligung, Infektionsschutz, Betreuungsordnung — gelten laut Vertrag **in ihrer jeweils gültigen Fassung**: eine geänderte Betreuungsordnung erzeugt deshalb keine neue Unterschrift, sie wird wie ein Preis gepflegt und gilt ab ihrem Tag."

Sie brauchen deshalb denselben `contract_texts`-Mechanismus mit `valid_from` — und **sonst nichts**: kein Dokument je Kind, keine Unterschrift, keinen Löschanker. Welche Fassung beim Unterschreiben galt, folgt aus `signatures.signed_at` und den Gültigkeitstagen; gespeichert werden muss dafür nichts.

**Die Konsequenz, die man leicht übersieht:** Die Anlagen dürfen **nicht in das erzeugte PDF geheftet** werden. Steckten sie darin, wäre eine geänderte Betreuungsordnung je Vertrag eingefroren — genau das, was 09 ausschließt. Auf Papier hängen sie heute hinten dran; das ist eine sichtbare Änderung am Dokument und gehört mit der Schule besprochen. Der Vertragstext muss dann sagen, wo die jeweils gültige Fassung zu finden ist, statt „siehe Anlage 3".

**Nicht auf Vorrat anlegen.** `prozesse.md` kennt als „weitere Anlagen ohne Datenfelder" die Regelung zum Infektionsschutz und die Betreuungsordnung. Eine **Kleiderordnung kommt im ganzen Repo nicht vor**, Elternarbeit nur als Putzdienst und Elternbonus — beide als Pflicht im Vertragstext, nicht als eigene Anlage. Welche Anlagen es gibt, sagt der überarbeitete Vertragstext; das ist der Moment, in dem die Liste entsteht (TASK-042, `fragen.md` Frage 10).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Betreuungsordnung und Infektionsschutz stehen als Sorte der Klasse mitgeltend, mit valid_from und ohne Dokument am Kind
- [ ] #2 Die Anlagen werden NICHT ins erzeugte PDF geheftet — der Vertrag verweist auf sie
- [ ] #3 Der Vertragstext nennt den Fundort im Portal statt einer Anlagennummer
- [ ] #4 Welche Anlagen es gibt, folgt aus dem ueberarbeiteten Vertragstext und wird nicht auf Vorrat angelegt
<!-- AC:END -->
