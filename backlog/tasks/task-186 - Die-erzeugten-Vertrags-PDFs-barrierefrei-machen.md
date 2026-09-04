---
id: TASK-186
title: Die erzeugten PDFs barrierefrei machen — gemessene Arbeitsliste
status: To Do
assignee: []
created_date: '2026-09-01 20:14'
updated_date: '2026-09-04 00:17'
labels:
  - wb-backend
  - anmeldung
  - frontend
milestone: m-2
dependencies: []
ordinal: 199000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das BFSG gilt (Geschäftsführung, 01.09.2026, TASK-118), damit fällt auch der erzeugte Vertrag darunter. **Am 04.09.2026 gemessen** — Gotenberg 8 als Vergleichskonverter, veraPDF 1.30.2 als Prüfer, gegen eine saubere Referenzvorlage und gegen den echten Schulvertrag. Ergebnis: erreichbar, auf dem gebauten Weg, ohne den Konverter zu tauschen.

**Der Word/M365-Weg liefert einen vollständigen Tag-Baum** — `H1`, `H2×5`, `H3`, `Table`, `TH`, `TR`, `L`/`LI`/`Lbl`/`LBody`, `Figure`, echte `/P`-Absätze. Er scheitert an genau zwei Regeln, beide nachbearbeitbar. Nach der Nachbearbeitung: **PASS, null verletzte Regeln.**

**Drei Schritte im Code**, alle in `render_and_file()`, wo jedes erzeugte Dokument ohnehin durchläuft:

1. **XMP-Metadatenstrom** setzen — `dc:title`, `dc:language`, `pdfuaid:part`. Ohne ihn fehlt die PDF/UA-Kennung (veraPDF 5-1). Fünf Zeilen `pikepdf`.
2. **`/Lang` korrigieren.** Word schrieb `en`, obwohl die Vorlage `de-DE` an drei Stellen setzt. **veraPDF meldet das nicht** — es prüft nur, dass eine Sprache dasteht, nicht welche. Praktisch liest ein Screenreader den deutschen Vertrag mit englischer Stimme; die einzige echte Barriere im ganzen Test, und die einzige, die durch jede formale Prüfung rutscht.
3. **`Scope` an die `TH`-Zellen** (veraPDF 7.5-1). Word markiert Kopfzeile *und* erste Spalte als `TH`, damit ist die Tabellenstruktur nicht mehr aus sich heraus lesbar.
4. **Alternativtext an jedes eingefügte Bild.** `docxtpl` setzt keinen — gemessen: 0 von 2 Unterschriftsbildern, veraPDF 7.3-1 zweimal verletzt. Mit `descr` je Bild: PASS. Der Text kommt aus demselben Objekt wie das Bild („Unterschrift von {Name}") und skaliert damit von allein.

**Sechs Regeln am echten Schulvertrag**, alle in Word zu beheben, keine davon Code:

| Regel | Was fehlt |
|---|---|
| 7.1-9 | Kein Dokumenttitel in den Dateieigenschaften |
| 7.4.2-1 | Keine Überschriftenebenen — die Datei nutzt `Listenabsatz`, `StandardWeb`, `Auflistung1–3`, keine einzige `Überschrift 1/2/3` |
| 7.2-17 (6×) | Kaputte Listenstruktur, `LI` ausserhalb von `L` — von den drei eigenen Aufzählungsformatvorlagen |
| 7.18.5-2, 7.18.1-2 | Der eine Hyperlink hat keine QuickInfo |
| 7.3-1 | Eine Grafik ohne Alternativtext |

**Eine Falle, die ohne Test niemand sieht:** `generateTaggedPdf` und `pdfua` zusammen zerstören den Tag-Baum. Die `pdfua`-Nachbearbeitung läuft durch LibreOffice, das das fertige PDF neu interpretiert — aus zwölf sauberen Tag-Arten wurden 24 `Figure` ohne Alternativtext. Gilt nur, wenn je auf Gotenberg umgestellt wird; hier festgehalten, damit es dann niemanden kostet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `render_and_file()` setzt XMP (`dc:title`, `dc:language`, `pdfuaid:part`), korrigiert `/Lang` und ergaenzt `Scope` an den `TH`-Zellen
- [ ] #2 Jedes eingefuegte Bild bekommt einen Alternativtext aus demselben Objekt, aus dem es stammt
- [ ] #3 Die vier Word-Vorlagen tragen Ueberschriftenebenen, Dokumenttitel, echte Listen, ausgezeichnete Kopfzeile und Alternativtexte
- [ ] #4 Ein erzeugtes PDF ist gegen veraPDF gelaufen und besteht PDF/UA-1 — nicht nur angesehen
- [ ] #5 Die Regel steht bei der Vorlage, damit die naechste sie mitbekommt
<!-- AC:END -->
