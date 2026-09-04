---
id: TASK-231
title: Die mitgeltenden Anlagen als dritte Klasse
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
updated_date: '2026-09-04 13:30'
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

**Die Liste ist laenger als angenommen, aber nicht vollstaendig** (04.09.2026). Die Geschaeftsfuehrung nennt ausdruecklich die **Kleiderordnung** und die **Regeln zu Putzdienst und Elternmitarbeit** — und sagt zugleich, dass es **weitere gibt, die sie nicht auswendig kennt**. Was das Repo heute selbst kennt: Betreuungsordnung und Regelung zum Infektionsschutz (`prozesse.md`, "Weitere Anlagen ohne Datenfelder"), die **Putzdienstregelung** und die **Elternmitarbeit** — letztere dort woertlich als "Zweite Anlage zum Schulvertrag neben der Putzdienstregelung". Dazu kommt die Kleiderordnung, die das Repo bisher nicht kannte.

**Damit ist eine Annahme dieses Tickets ueberholt.** Hier stand: "Eine Kleiderordnung kommt im ganzen Repo nicht vor, Elternarbeit nur als Putzdienst und Elternbonus — beide als Pflicht im Vertragstext, nicht als eigene Anlage." Der Vertragstext behaelt die **Pflicht**; die **Regeln dazu** stehen daneben als mitgeltende Anlage und werden wie ein Preis gepflegt.

**Die vollstaendige Liste steht nicht im Kopf, sondern im Vertrag.** Sie ist aus dem realen Vertragsdokument samt seiner angehefteten Anlagen zu ziehen — dort haengen sie heute hinten dran — und mit der Geschaeftsfuehrung gegenzulesen. Erst danach ist dieses Kriterium erfuellt; bis dahin ist jede Aufzaehlung im Repo eine Teilmenge und als solche zu lesen.

**Was sich dadurch nicht aendert:** Diese Anlagen tragen keine Personendaten, entstehen nicht je Kind und haben keine Frist am Kind — genau deshalb sind sie Klasse `applies` und werden nicht ins erzeugte PDF geheftet.

<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Anlagen werden NICHT ins erzeugte PDF geheftet — der Vertrag verweist auf sie
- [ ] #2 Der Vertragstext nennt den Fundort im Portal statt einer Anlagennummer
- [ ] #3 Welche Anlagen es gibt, folgt aus dem ueberarbeiteten Vertragstext und wird nicht auf Vorrat angelegt
- [ ] #4 Betreuungsordnung, Infektionsschutz, Kleiderordnung und die Regeln zu Putzdienst und Elternmitarbeit stehen als Sorte der Klasse mitgeltend, mit valid_from und ohne Dokument am Kind
- [ ] #5 Die vollstaendige Anlagenliste ist aus dem realen Vertragsdokument gezogen und mit der Geschaeftsfuehrung gegengelesen — nicht aus dem Gedaechtnis
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Der Mechanismus steht seit TASK-225: contract_text_kinds.kind_class kennt die Klasse 'applies', und ck_contract_text_kinds_class_shape weist eine mitgeltende Anlage mit Arbeitsfassung ab — sie ist reiner Text mit valid_from, ohne Dokument am Kind und ohne Unterschrift. Das Pruefskript zeigt es (querschnitt-schema-check.sql, 'TASK-231 — mitgeltende Anlage als reiner Text mit Gueltigkeitstag').

Bewusst NICHT angelegt sind Zeilen fuer Betreuungsordnung und Infektionsschutz: Welche Anlagen es gibt, sagt der ueberarbeitete Vertragstext (TASK-042, fragen.md Frage 19), und das ist der Moment, in dem die Liste entsteht. Kriterium 1 bleibt deshalb offen, obwohl die Form steht. Kriterium 2 und 3 sind ohnehin Vertragstext und Erzeugung, nicht Schema.
<!-- SECTION:NOTES:END -->
