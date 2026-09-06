---
id: TASK-258
title: Die Konvertierung von Graph auf den Container umstellen
status: To Do
assignee: []
created_date: '2026-09-04 23:09'
labels:
  - backend
  - infra
milestone: m-5
dependencies: []
ordinal: 271000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Entschieden in TASK-242 (04.09.2026): Die PDF-Konvertierung laeuft kuenftig im Container (Gotenberg mit LibreOffice) statt ueber Graph. Begruendung, Messwerte und verworfene Alternativen stehen dort und in `container.md`; hier steht die Arbeit.

**Der Eingriff ist klein, und das ist der Punkt.** `render_and_file` in `wb-backend/app/services/anmeldung.py` bleibt, wie sie ist — sie nimmt Bytes und keinen Ort. Auszutauschen sind drei Zeilen: der Upload der gefuellten `.docx`, der Aufruf `files.as_pdf(drive_id, draft_id)` und das anschliessende `files.remove(...)`. An ihre Stelle tritt ein HTTP-Aufruf an den Konverter im internen Netz. `docxtpl` bleibt, die Ablage des PDF bleibt, die Pruefsumme bleibt.

**Der Compose-Stack bekommt einen fuenften Dienst**, nur im internen Netz erreichbar, mit `cpus: 0.5` und `mem_limit: 384m` — aus dem Vorhandenen geschnitten, nicht danebengelegt (`container.md`).

**Gegen den Renderpfad ist lokal geprueft:** docxtpl fuellen, an den Konverter, PDF zurueck — 18 ms Rendern, 174 ms Konvertieren bei einer kleinen Vorlage, 0,72 s beim realen Vertrag. Werte eingesetzt, keine Platzhalter uebrig, Sonderzeichen aus Freitextfeldern unbeschaedigt (`autoescape=True` haelt), Schleife ueber die Sorgeberechtigten gelaufen, PDF getaggt.

**Was an die Eltern geht, ist immer ein PDF** (Betreiber, 04.09.2026) — nie eine `.docx`, auch nicht die Redline. Die Word-Datei ist Zwischenprodukt und verlaesst das Haus nicht. Das entschaerft zugleich eine Frage, die sich sonst gestellt haette: Word zeigt Aenderungsverfolgungen im Auslieferungszustand nur als Strich am Rand ("Simple Markup"), und ob ein Elternteil die Markierungen saehe, haenge dann an dessen Einstellung. Im PDF ist die Formatierung eingebrannt — gemessen am Pixel, die Farben kommen unveraendert an.

**Ein Fund aus dem Test, der in den Bau gehoert:** LibreOffice uebernimmt die Dokumentsprache aus der Vorlage und erfindet keine. Fuehrt eine Vorlage keine Sprache, steht im PDF `en-US` — ein Screenreader laese den deutschen Vertrag englisch vor. Die Nachbearbeitung muss `/Lang` deshalb setzen und nicht nur korrigieren.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Upload der gefuellten .docx und das anschliessende Entfernen sind ersatzlos weg
- [ ] #2 render_and_file ruft den Konverter im internen Netz auf; die Funktion selbst bleibt unveraendert
- [ ] #3 Der fuenfte Dienst steht im Compose-Stack, nur intern erreichbar, mit CPU- und Speichergrenze
- [ ] #4 Die Nachbearbeitung setzt /Lang und den Titel im XMP — als Gegenprobe mit veraPDF gemessen
- [ ] #5 Gegenprobe: nach einer Ansicht liegt in keiner SharePoint-Bibliothek eine Datei ohne documents-Zeile
- [ ] #7 Keine Route liefert eine .docx an Eltern — was hinausgeht, ist PDF; als Gegenprobe
- [ ] #6 Im Papierkorb der Site verbliebene Zwischenstaende aus der bisherigen Laufzeit sind einmalig geraeumt
<!-- AC:END -->
