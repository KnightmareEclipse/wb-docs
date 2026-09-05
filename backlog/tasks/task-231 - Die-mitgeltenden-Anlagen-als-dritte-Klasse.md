---
id: TASK-231
title: Die mitgeltenden Anlagen als dritte Klasse
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
updated_date: '2026-09-04 21:30'
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

**Zwei Dinge kommen am 04.09.2026 dazu (Geschaeftsfuehrung), und beide sind gebaut.**

**Erstens die Zuordnung.** "Die Vertragsanlagen muessen dynamisch pro Vertragsprozess angefuegt werden koennen und geupdatet werden." Welche Anlage zu welcher Vertragssorte gehoert, war nirgends gespeichert — `contract_text_kinds` war eine flache Liste, und nichts verband die Betreuungsordnung mit dem Betreuungsvertrag. Neu: `contract_kind_attachments`, **je Textsorte und nicht je Vertragsart**. Heute tragen Grund- und Realschulvertrag dieselben Anlagen, "aktuell macht man es, weil der Prozess so leichter ist" — aber die Geschaeftsfuehrung kann das fuer die Zukunft nicht garantieren, und an der Vertragsart liesse es sich nie trennen. Fuer die Bedienung aendert das nichts: "fuer alle Schulvertraege" schreibt drei Zeilen statt einer, eine Anzeigeregel und kein zweiter Mechanismus.

Die Zeile traegt `created_at` und `removed_at` statt geloescht zu werden: "Welche Anlagen galten, als dieser Vertrag unterschrieben wurde" ist die Frage, die im Streitfall gestellt wird, und eine entfernte Zeile beantwortet sie nicht mehr. Dazu ein partieller Unique-Index ueber die geltenden, damit dieselbe Anlage nach dem Entfernen wieder angefuegt werden kann.

**Zweitens die Mitteilung.** "Sobald ein Anhang ein Update bekommt, gibt es eine automatische Mail an alle Eltern, die von diesem Anhangsupdate betroffen sind." Block 08 sah die Mitteilung schon vor ("es genuegt die Mitteilung"), aber niemand sagte, wer sie ausloest. Jetzt: Sie geht von selbst, und **wie viele Tage vor dem Gueltigkeitstag** steht als `contract_text_kinds.announcement_lead_days` — je Sorte einstellbar von der Geschaeftsfuehrung, null heisst "am Tag selbst". Je Sorte und nicht je Fassung: An der einzelnen Fassung muesste ihn jemand bei jeder Aenderung erneut setzen, und die vergessene Zahl waere eine Mitteilung, die zu spaet kommt.

Sie geht **je Person, nicht je Vertrag** — eine Familie mit drei Kindern bekommt eine. Betroffen ist, wer zum Versandzeitpunkt einen laufenden Vertrag der zugeordneten Sorte hat. Als Vorgangsmail traegt sie **keinen Abmeldelink**: Wer sich von der Betreuungsordnung abmelden koennte, bekaeme die naechste Vertragsfrist auch nicht mehr.

**Klasse `agreed` bleibt draussen** (Teilnahmebedingungen, Essensbedingungen): Dort merkt sich jeder Vorgang die Fassung, unter der er zustande kam, und eine neue betrifft kuenftige Buchungen statt bestehender. Der CHECK an `announcement_lead_days` haelt das fest — ein Vorlauf an einer anderen Klasse saehe aus wie eine Zusage, die der Versand nicht haelt.

<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Anlagen werden NICHT ins erzeugte PDF geheftet — der Vertrag verweist auf sie
- [ ] #2 Der Vertragstext nennt den Fundort im Portal statt einer Anlagennummer
- [ ] #3 Welche Anlagen es gibt, folgt aus dem ueberarbeiteten Vertragstext und wird nicht auf Vorrat angelegt
- [ ] #4 Betreuungsordnung, Infektionsschutz, Kleiderordnung und die Regeln zu Putzdienst und Elternmitarbeit stehen als Sorte der Klasse mitgeltend, mit valid_from und ohne Dokument am Kind
- [ ] #5 Die vollstaendige Anlagenliste ist aus dem realen Vertragsdokument gezogen und mit der Geschaeftsfuehrung gegengelesen — nicht aus dem Gedaechtnis
- [x] #6 Welche Anlage zu welcher Vertragssorte gehoert, ist ein Wert im System und wird je Textsorte gepflegt, nicht je Vertragsart
- [x] #7 Eine entfernte Zuordnung bleibt stehen und sagt, was damals galt; dieselbe Anlage laesst sich danach wieder anfuegen
- [x] #8 Jede mitgeltende Anlage traegt den Vorlauf ihrer Mitteilung als Wert, jede andere Klasse traegt keinen — beides als Gegenprobe
- [ ] #9 Eine neue Fassung erzeugt die Mail an die betroffenen Familien: je Person, ohne Abmeldelink, im Vorlauf der Anlage
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Der Mechanismus steht seit TASK-225: contract_text_kinds.kind_class kennt die Klasse 'applies', und ck_contract_text_kinds_class_shape weist eine mitgeltende Anlage mit Arbeitsfassung ab — sie ist reiner Text mit valid_from, ohne Dokument am Kind und ohne Unterschrift. Das Pruefskript zeigt es (querschnitt-schema-check.sql, 'TASK-231 — mitgeltende Anlage als reiner Text mit Gueltigkeitstag').

Bewusst NICHT angelegt sind Zeilen fuer Betreuungsordnung und Infektionsschutz: Welche Anlagen es gibt, sagt der ueberarbeitete Vertragstext (TASK-042, fragen.md, „Die vollstaendige Liste der Anlagen zum Vertrag"), und das ist der Moment, in dem die Liste entsteht. Kriterium 1 bleibt deshalb offen, obwohl die Form steht. Kriterium 2 und 3 sind ohnehin Vertragstext und Erzeugung, nicht Schema.
<!-- SECTION:NOTES:END -->
