---
id: TASK-249
title: >-
  Geraete- und Druckerverwaltung in Weltenbaum — nicht ausgeschlossen, weit
  hinten
status: To Do
assignee: []
created_date: '2026-09-04 18:33'
labels:
  - m365
  - geraete
  - zurueckgestellt
milestone: m-5
dependencies: []
priority: low
ordinal: 262000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Geschaeftsfuehrung, 04.09.2026: **Weltenbaum soll die Plattform fuer alles sein**, und dazu gehoert am Ende auch das Management von Microsoft 365 im Gesamtpaket — Konten, Gruppen, Verteiler und Geraete. Ausgeschlossen ist davon nichts mehr; Prioritaet hat es vorerst nicht.

Heute laeuft die Geraeteverwaltung ueber **Numiato** (Numiato GmbH), eine Oberflaeche ueber Microsoft Intune fuer Windows, iPad und macOS: Richtlinien, App-Store, Geraeteaktionen, Druckerverwaltung, Ordnung nach Kategorien und Raeumen. Sie steckt im Premium-Paket von Vis365 (2.100 EUR netto statt 600 EUR im Jahr) und wird von DrVis mitbetreut.

**Warum es weit hinten steht, in einem Satz je Grund:**

- Es folgt aus **keinem Schulprozess**: Ein Geraet wird beschafft, repariert, umgestellt — nichts davon steht in Weltenbaum, und der ganze Gewinn bei Konten und Verteilern war, dass Weltenbaum den Anlass kennt.
- Der **physische Vorgang bleibt**: Jemand packt das Geraet aus und stellt es in einen Raum; die Oberflaeche davor spart nicht den Menschen, sondern nur seinen Klick.
- **Fremde Aenderungsrate, alleiniger Betreiber**: Intune-APIs, Windows-Feature-Updates, iPadOS, App-Pakete, jaehrlich ablaufende Apple-Business-Manager-Token — Wartung, die von aussen getaktet wird und niemanden findet, wenn der Betreiber ausfaellt (rules.md Abschnitt 4).
- Die **Zahl dreht sich um**: Die Geraeteverwaltung ist die Differenz zwischen Standard und Premium, also 1.500 EUR im Jahr. Wer sie nachbaut, um sie zu sparen, traegt danach ihre Pflege allein.

**Die Grenze, an der Weltenbaum sehr wohl etwas beitraegt, und sie steht heute in keiner Domaenenliste:** die **Ausgabe** eines Leihgeraets. Wer hat welches Geraet, seit wann, und ist es beim Abgang zurueckgekommen — das haengt an der Person, nicht am Geraet, und es hat genau den Anlass, den Weltenbaum kennt. Heute muss beim Abgang jemand daran denken, und das ist derselbe reissende Faden wie beim M365-Konto (prozesse.md, Abschnitt 16). Die Seriennummer waere der Anker zwischen beiden Seiten, mehr braucht es nicht.

**Erst zu klaeren, bevor daraus etwas wird:** Gibt es ueberhaupt Leihgeraete an Kinder oder Mitarbeitende? Ohne ein Ja entsteht hier nichts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob es Leihgeraete gibt und ob ihre Ausgabe ein eigener Vorgang wird
- [ ] #2 Falls ja: der Vorgang haengt an der Person und endet mit dem Abgang, das Geraet selbst bleibt bei Numiato
- [ ] #3 Die vollstaendige Ablösung von Vis365 ist erst sinnvoll, wenn die Geraeteverwaltung mitgeht — vorher zahlt die Schule Premium und baut den enthaltenen Teil nach
<!-- AC:END -->
