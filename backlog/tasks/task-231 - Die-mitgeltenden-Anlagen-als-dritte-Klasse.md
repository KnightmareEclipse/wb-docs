---
id: TASK-231
title: Die mitgeltenden Anlagen als dritte Klasse
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
updated_date: '2026-09-05 00:58'
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
- [x] #1 Die Anlagen werden NICHT ins erzeugte PDF geheftet — der Vertrag verweist auf sie
- [ ] #2 Der Vertragstext nennt den Fundort im Portal statt einer Anlagennummer
- [ ] #3 Welche Anlagen es gibt, folgt aus dem ueberarbeiteten Vertragstext und wird nicht auf Vorrat angelegt
- [ ] #4 Die neun Anlagen aus prozesse.md 7.6 stehen als Sorte der Klasse mitgeltend, je mit valid_from und Vorlauf und ohne Dokument am Kind
- [x] #5 Die vollstaendige Anlagenliste ist aus dem realen Vertragsdokument gezogen und mit der Geschaeftsfuehrung gegengelesen — nicht aus dem Gedaechtnis
- [x] #6 Welche Anlage zu welcher Vertragssorte gehoert, ist ein Wert im System und wird je Textsorte gepflegt, nicht je Vertragsart
- [x] #7 Eine entfernte Zuordnung bleibt stehen und sagt, was damals galt; dieselbe Anlage laesst sich danach wieder anfuegen
- [x] #8 Jede mitgeltende Anlage traegt den Vorlauf ihrer Mitteilung als Wert, jede andere Klasse traegt keinen — beides als Gegenprobe
- [ ] #9 Eine neue Fassung erzeugt die Mail an die betroffenen Familien: je Person, ohne Abmeldelink, im Vorlauf der Anlage
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Der Mechanismus steht seit TASK-225: contract_text_kinds.kind_class kennt die Klasse 'applies', und ck_contract_text_kinds_class_shape weist eine mitgeltende Anlage mit Arbeitsfassung ab — sie ist reiner Text mit valid_from, ohne Dokument am Kind und ohne Unterschrift. Das Pruefskript zeigt es (querschnitt-schema-check.sql, 'TASK-231 — mitgeltende Anlage als reiner Text mit Gueltigkeitstag').

Bewusst NICHT angelegt sind Zeilen fuer Betreuungsordnung und Infektionsschutz: Welche Anlagen es gibt, sagt der ueberarbeitete Vertragstext (TASK-042, fragen.md, „Die vollstaendige Liste der Anlagen zum Vertrag"), und das ist der Moment, in dem die Liste entsteht. Kriterium 1 bleibt deshalb offen, obwohl die Form steht. Kriterium 2 und 3 sind ohnehin Vertragstext und Erzeugung, nicht Schema.

**Die Anlagenliste steht** (Betreiber, 05.09.2026, aus dem realen Vertragsdokument gezogen): Schulordnung, Kleiderordnung, Regelung im Krankheitsfall und Infektionsschutz, Kooperation Elternhaus und Schule, Bonussystem Elternmitarbeit, Putzdienstregeln, Versicherungsschutz der Eltern, Unser Leitbild, Informationen zum Datenschutz bei der CLEMENS BILDUNG.

Sie steht als prozesse.md 7.6 — dort, wo die realen Bestandteile des heutigen Vertrags stehen, und nur dort: soll-prozesse/08 und dokumente.md nennen sie jetzt statt sie aufzuzaehlen, und 'die Liste ist offen' ist aus beiden raus.

Neun statt der fuenf, die dieses Ticket annahm. Neu sind Schulordnung, Kooperation Elternhaus und Schule, Versicherungsschutz der Eltern, Unser Leitbild und die Informationen zum Datenschutz. **Die Betreuungsordnung ist nicht dabei** — sie haengt am Betreuungsvertrag (prozesse.md 8), nicht am Schulvertrag; die Zuordnung je Textsorte, die contract_kind_attachments traegt, ist damit keine Formalie, sondern trennt hier zwei echte Listen.

Kein Schema-Eingriff: Die neun sind Zeilen in contract_text_kinds der Klasse 'applies' und leben in der Migration (CLAUDE.md). Jede braucht dabei einen announcement_lead_days — ck_contract_text_kinds_lead macht ihn an dieser Klasse zur Pflicht, und die Zahl setzt die Geschaeftsfuehrung.

Zwei [?] in prozesse.md 7.6, beide beim Adressaten: ob dieselben neun auch am Betreuungsvertrag haengen und ob 'Regelung im Krankheitsfall und Infektionsschutz' dasselbe Blatt ist wie die 'Regelung zum Infektionsschutz' am Hortvertrag (Geschaeftsfuehrung); und ob die 'Informationen zum Datenschutz bei der CLEMENS BILDUNG' die Information nach Art. 13 DSGVO sind — sie ist die einzige der neun, die das Repo bisher gar nicht kannte, und weder dsgvo.md noch verarbeitungsverzeichnis.md fuehren eine Art.-13-Information (Datenschutzbeauftragter).

**Beide offenen Hälften von fragen.md 9 sind beantwortet (Geschäftsführung, 05.09.2026), die Frage ist dort gestrichen** — die Nummern sind mitgewandert, 10-20 wurden 9-19, und der Ausflug der Schulleitung heisst damit wieder 17 wie in TASK-168 notiert.

Erstens: **Die Anlagen werden nicht mehr ans erzeugte PDF geheftet, sondern im Portal bereitgestellt** — ein Ja. Bis dahin war der Wegfall ausdruecklich nicht mitverhandelt (TASK-226, 04.09.2026). Steht als bestaetigte Entscheidung in dokumente.md, 'Die Vorlage'; der zweite Satz derselben Regel im Klassen-Abschnitt verweist jetzt darauf, statt sie zu wiederholen.

Zweitens: **Die neun haengen am Schulvertrag.** Der Betreuungsvertrag traegt seine eigenen zwei — Regelung zum Infektionsschutz und Betreuungsordnung (prozesse.md 8). Damit ist die Zuordnung je Textsorte statt je Vertragsart keine Vorsichtsmassnahme mehr, sondern trennt zwei real verschiedene Listen.

Kriterium 1 ist damit abgehakt: Die Entscheidung steht, und kein Renderpfad heftet heute etwas an. Der zweite Halbsatz — der Vertrag verweist auf sie — ist Kriterium 2 und haengt am Vertragstext (TASK-042).

Offen bleibt eine Annahme, als [A] in prozesse.md 7.6: ob die 'Regelung im Krankheitsfall und Infektionsschutz' des Schulvertrags und die 'Regelung zum Infektionsschutz' des Hortvertrags zwei Sorten sind oder eine unter zwei Namen. Sie traegt weiter — beim Seed sind es zwei Zeilen statt einer.
<!-- SECTION:NOTES:END -->
