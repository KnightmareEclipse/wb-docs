---
id: TASK-244
title: Die Fotoerlaubnis ueberlebt Kind und Person — heute kaskadiert sie
status: To Do
assignee: []
created_date: '2026-09-04 13:34'
labels:
  - schema
  - dsgvo
  - wb-docs
dependencies: []
references:
  - soll-prozesse/08-schulvertrag.md
  - schema/querschnitt-schema.sql
ordinal: 257000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Datenschutzbeauftragte am 04.09.2026: die Fotoerlaubnis bleibt **unbegrenzt**. Die
Geschaeftsfuehrung hat am 04.09.2026 entschieden, **wie** — und es ist ein dritter Weg, der in der
Frage nicht stand: nicht der Nachweis allein im Dokument und nicht die Personenzeile, die
unbegrenzt stehen bleibt, sondern **ein eigener Bestand daneben**.

Wenn der Loesch-Lauf ein Kind raeumt, schreibt er vorher `photo_consent_records`: Vorname, Nachname,
Geburtsdatum, Abgangsdatum, Schulzweig und die beiden Zeitpunkte — und dupliziert die Datei in eine
vierte SharePoint-Bibliothek, die nur Fotoerlaubnisse fuehrt. Danach geht das Kind wie jedes andere,
und in den Stammdaten bleibt nichts stehen. Die Zustimmungszeile selbst kaskadiert weiter mit dem
Kind; ihr Nachweis steht bis dahin laengst daneben.

**Kopiert wird beim Loeschen, nicht beim Abgang.** Sonst liefen fuenf Jahre lang zwei Zeilen ueber
dieselbe Erlaubnis, und ein Widerruf traefe verlaesslich nur die, an der die Route haengt.

**Das Geburtsdatum steht mit im Nachweis**, weil der Bestand kein Ende hat: bei rund sechzig Zeilen
im Jahr kollidiert Name samt Abgangsjahr und Schulzweig ueber fuenfzig Jahre mit rund 14 %, mit dem
Geburtsdatum mit 0,04 %. Es loest nicht, welches Kind auf welchem Bild ist — dafuer ist die Datei
selbst der letzte Aufschluss, weil die Eltern darin stehen.

**Widerrufen wird nach dem Abgang ueber das Sekretariat, per Mail** — einen Portalzugang gibt es
dann nicht mehr, und ein Link, der unbegrenzt gilt, waere ein Zugang ohne Anmeldung.

Eingearbeitet in `schema/querschnitt-schema.sql` samt Pruefskript, `soll-prozesse/08`, `17`,
`grenzkarte.md` und `verarbeitungsverzeichnis.md`. **Gebaut ist nichts** — das ist TASK-246.

**Was hier offen bleibt und den Bestand nicht aufhaelt** (Geschaeftsfuehrung, 04.09.2026: „das soll
uns nicht aufhalten"): wer die Meldung eines Widerrufs bekommt und wer vorhandene Bilder zieht, und
die groessere Frage, welche Aufnahme welches Kind zeigt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Der Loeschanker ist entschieden und im Schema abgebildet: ein eigener Bestand, den der Lauf fuellt
- [x] #2 Gegenprobe: der Loesch-Lauf raeumt Kind und Person, der Nachweis bleibt stehen (querschnitt-schema-check.sql)
- [ ] #3 Der Widerruf hat einen benannten Weg: der Eingang steht (Mail ans Sekretariat), offen bleiben Empfaenger der Meldung und wer die Bilder zieht
- [x] #4 Beantwortet: weder noch — der Nachweis steht in einem eigenen Bestand, die Personenzeile geht regulaer
- [x] #5 verarbeitungsverzeichnis.md traegt den Bestand ohne Loeschtermin samt Begruendung; folgenabschaetzung.md fuehrt ihn nicht, weil er keine Art.-9-Angabe traegt
<!-- AC:END -->
