---
id: TASK-242
title: Wo laeuft veraPDF
status: Done
assignee: []
created_date: '2026-09-04 12:36'
labels:
  - wb-backend
  - infra
dependencies: []
references:
  - dokumente.md
  - container.md
ordinal: 255000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die dritte Pruefung beim Anlegen einer Fassung ist veraPDF gegen PDF/UA-1 (TASK-228, TASK-186). veraPDF ist eine Java-Anwendung; der Stack in `container.md` ist Python/FastAPI und hat keine JVM, das Root-Dateisystem ist read-only, und die drei CPU-Grenzen summieren sich bereits auf die vier vCPU.

Dazu kommt: `oberflaechen.md` verkauft den Graph-Weg gerade damit, dass **kein Konverter im Container** laeuft. Steht ohnehin ein Java-Prozess daneben, aendert sich die Rechnung — dann ist auch der lokale Konverter wieder eine Option, und der wuerde den Zwischenstand in der Bibliothek ueberfluessig machen.

Beide Fragen gehoeren zusammen entschieden oder gar nicht.

**Entschieden am 04.09.2026, und zwar beide zusammen: Konverter und Pruefer laufen im Container.**

Der **Konverter** ist Gotenberg mit LibreOffice (`gotenberg/gotenberg:8-libreoffice`), der **Pruefer** veraPDF als Aufruf beim Anlegen einer Fassung, nicht als dauernder Dienst. Damit faellt der Graph-Weg fuer die Konvertierung weg — Entra-ID fuer Nutzer und SharePoint fuer Dateien bleiben, der Mechanismus geht.

**Drei Gruende, keiner davon PDF/UA:**
1. **Der Zwischenstand entfaellt.** Graph konvertiert ein Element, nicht einen Rumpf — jede Ansicht lud eine gefuellte `.docx` hoch und wieder weg, und was blieb, lag in zwei Papierkoerben (R10, TASK-238).
2. **Unabhaengigkeit von Microsoft fuer einen Mechanismus** (Betreiber, 04.09.2026: abhaengig nur bei Nutzern und Dateien).
3. **Lokal testbar.** Eine neue Vertragsfassung laesst sich vor dem Ausrollen durchspielen; ueber Graph ging das nie.

**Gemessen am realen Schulvertrag** (30 Seiten, 400 KB), auf dieser Maschine: 4,9 MB im Ruhezustand — der Konverterprozess startet erst mit der ersten Anfrage —, 245 MB Spitze, **0,72 s je Dokument**, Durchsatz ~1,4 Dokumente je Sekunde **ob nacheinander oder gleichzeitig**. Der Durchsatz ist die Grenze, nicht der Speicher: Ein Lauf ueber fuenfhundert Vertraege dauert rund sechs Minuten und gehoert in den Lauf-Dienst.

**Verworfen, mit Preis:** OnlyOffice Document Server — mindestens 4 GB RAM plus 4 GB Swap, bei 8 GB neben Postgres und Anwendung ausgeschlossen. Der nackte `x2t`-Konverter braucht zwoelf Bibliotheken von Hand nach `/usr/lib`; ein Bauteil, das niemand pflegt, ist in einem Haus ohne IT-Personal der falsche Handel. Euro-Office ist von OnlyOffice abgeleitet und eine Editier-Komponente, kein Konverter.

**Der Stand der Barrierefreiheit, gemessen statt angenommen:** Das erzeugte PDF ist getaggt und traegt PDF/A-2b und PDF/UA-1; `/Lang` steht auf `de-DE`, sofern die Vorlage eine Sprache fuehrt — LibreOffice uebernimmt sie und erfindet keine. veraPDF meldet **sechs** verletzte Regeln; die Nachbearbeitung aus `dokumente.md` traegt davon den Titel im XMP (gemessen: sechs auf fuenf). Von den restlichen fuenf sind zwei ebenfalls Nachbearbeitung (Alternativtext an Bildern, Beschreibung an Links), eine liegt an der Vorlage — sie fuehrt keinen einzigen Ueberschriften-Stil, das gehoert in TASK-226 — und eine am Export (`LI` ausserhalb von `L`). **PDF/UA-konform ist das Ergebnis noch nicht**, und der Weg dahin ist bekannt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden, wo der PDF/UA-Pruefer laeuft — im Container, als eigener Dienst oder gar nicht
- [x] #2 container.md traegt die Entscheidung samt Preis, oder es steht begruendet, dass geprueft nicht wird
- [x] #3 Zusammen entschieden mit der Frage, ob ein lokaler Konverter den Zwischenstand ersetzt
<!-- AC:END -->
