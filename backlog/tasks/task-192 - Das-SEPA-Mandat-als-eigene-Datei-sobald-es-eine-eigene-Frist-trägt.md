---
id: TASK-192
title: 'Mandat und Fotoeinverständnis als eigene Dateien erzeugen'
status: To Do
assignee: []
created_date: '2026-09-01 22:50'
updated_date: '2026-09-01 22:54'
labels:
  - wartet
  - dsgvo
  - anmeldung
milestone: m-2
dependencies: []
ordinal: 205000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
**Entschieden:** Jede Unterlage wird eine eigene Datei. SEPA-Mandat und Fotoeinverständnis werden erzeugt, unterschrieben und abgelegt wie der Vertrag — nicht als Teil von dessen PDF.

Damit gilt in soll-prozesse/08-schulvertrag.md durchgängig, was Zeile 235 schon sagt: "eine Datei je Unterlage, kein Sammel-PDF, denn ein Bündel liegt in einem Unterordner und trägt damit dessen Frist für alles, was darin steckt." Zeile 219 ist entsprechend geschärft: Das Mandat gehört zum Vertrag und wird nicht eigens geschlossen, steht als Datei aber für sich.

Der Grund ist die Frist: Das Blatt für den Datenschutzbeauftragten fragt Vertrag und Mandat getrennt ab (pruefberichte/fragen-datenschutz.txt, Punkt "Vier Fristen und die Fotoerlaubnis"). Aus einem Bündel lässt sich nichts einzeln löschen — der Lösch-Lauf müsste ein unterschriebenes PDF neu bauen, und das kann er nicht.

Die Arbeit:

- Eine **zweite Word-Vorlage** neben app/documents/contract-template.docx, gefüllt und über Graph konvertiert wie die erste (TASK-111 hat den Weg gebaut).
- Eine eigene Zeile in **document_types** und eine eigene **Aktenkategorie**, sonst liegt die Datei im selben Unterordner und erbt dessen Frist.
- Die **Unterschrift** landet auf dieser Datei; signatures kennt das Mandat längst als eigenen Bezug (schema/querschnitt-schema.sql, ck_signatures_subject), es fehlt allein die Datei.
- Ein **ersetztes Mandat** erzeugt eine zweite Datei neben der ersten; die alte bleibt mit ihrem Unterschriftsdatum stehen, wie 08 es für die Zeile schon vorsieht.

Dasselbe gilt für das **Fotoeinverständnis**: Es trägt heute eine Unterschrift ohne Datei — ab 14 die des Kindes über einen Signaturlink — und bekommt jetzt ebenfalls eine eigene. Damit sind es drei erzeugte Dateien je Vertragsvorgang statt einer.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Zweite Vorlage und zweite erzeugte Datei fürs Mandat
- [ ] #2 Eigener document_type und eigene Aktenkategorie, damit der Lösch-Lauf sie einzeln greift
- [ ] #3 Die Mandats-Unterschrift hängt an dieser Datei, nicht am Vertrag
- [ ] #4 Block 08 sagt danach an beiden Stellen dasselbe
- [ ] #5 Das Fotoeinverständnis wird ebenso erzeugt, abgelegt und einzeln befristet
<!-- AC:END -->
