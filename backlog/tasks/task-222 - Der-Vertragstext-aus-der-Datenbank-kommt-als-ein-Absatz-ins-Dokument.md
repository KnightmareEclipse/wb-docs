---
id: TASK-222
title: Der Vertragstext aus der Datenbank kommt als ein Absatz ins Dokument
status: To Do
assignee: []
created_date: '2026-09-03 22:40'
labels:
  - wb-backend
  - anmeldung
  - dokument
milestone: m-2
dependencies:
  - TASK-186
references:
  - schema/querschnitt-schema.sql
  - soll-prozesse/hebel.md
ordinal: 199500
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`contract_texts.body` trägt den Wortlaut einer Fassung, `hebel.md` überlässt seine Form ausdrücklich dem Bau: „Wie ein solcher Text abgelegt und formatiert wird, entscheidet der Bau und nicht dieser Hebel — festgehalten wird, welche Fassung galt." Entschieden ist das bis heute nicht, und der gebaute Weg entscheidet es stillschweigend mit: In `contract-template.docx` steht `{{ contract_body }}` als einfacher Platzhalter, gefüllt in `build_contract_document` (`app/services/anmeldung.py`). docxtpl setzt den Wert damit als **einen Textlauf in einen Absatz** — ein Schulvertrag mit Gliederung, Überschriften und Aufzählungen wird zu einem Block. Dieselbe Form haben `mandate-template.docx` und `photo-consent-template.docx`.

Das steht gegen TASK-186: Die Vorlage kann echte Überschriftenebenen tragen, der Vertragstext selbst dann immer noch nicht — und er ist der längste Teil des Dokuments.

Zu entscheiden ist, was in `body` steht und wer es in Absätze übersetzt. Drei Wege:

- **Markdown in `body`, gerendert in `RichText`/Subdokument** — die Geschäftsführung schreibt mit Überschriften und Listen, der Bau übersetzt sie in Word-Formatvorlagen. Preis: eine Übersetzungsschicht, die nur die Auszeichnungen kann, die sie kennt.
- **Absätze als Schleife** (`{%p for absatz in contract_body %}`) — `body` bleibt Fließtext, Leerzeilen trennen Absätze. Billig, aber ohne Überschriften und Listen.
- **Die Gliederung wandert in die Vorlage**, `body` trägt nur noch den Fließtext je Abschnitt. Preis: je Vertragsart eine Vorlage, die bei jeder Textänderung mitgepflegt wird — genau das, was die Fassung in der Datenbank vermeiden wollte.

Empfehlung: der erste Weg, weil er die Fassung als Text erhält (und damit den Nachweis, welcher Wortlaut galt) und trotzdem Struktur trägt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden und an `contract_texts.body` als Kommentar festgehalten, was dort steht
- [ ] #2 Ein Vertragstext mit Überschriften und einer Aufzählung erzeugt ein PDF, das sie trägt
- [ ] #3 Die Regel gilt für alle drei Vorlagen, nicht nur für den Schulvertrag
<!-- AC:END -->
