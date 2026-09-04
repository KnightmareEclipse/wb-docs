---
id: TASK-226
title: Die vier Vorlagen auf Klartext-Platzhalter umstellen
status: To Do
assignee: []
created_date: '2026-09-04 00:18'
labels:
  - wb-backend
  - wartet
milestone: m-5
dependencies: []
ordinal: 238000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die heutige Vorlage `2026_01_22 Schulvertrag Vorlage ab 01-2026` trägt 82 benannte Inhaltssteuerelemente, davon 9 Bildfelder. Sie sind ein **Power-Automate-Artefakt**: Der Flow konnte nicht anders in ein Word-Dokument schreiben, deshalb wurden sie von Hand angelegt und jede Checkbox durch ein Textfeld mit einem Leerzeichen ersetzt, in das ein „X" getippt wird.

`docxtpl` braucht davon nichts. Seine Platzhalter sind **Klartext** im Fließtext — `{{ kind_name }}` —, und damit fällt die ganze Fehlerklasse weg: Ein Text lässt sich nicht in eine Checkbox verwandeln, und wer ihn löscht, hinterlässt ein sichtbares Loch statt einer unsichtbar kaputten Feldeigenschaft.

**Drei Umstellungen:**

- **Booleans** werden ein Tagpaar über denselben Wert: `Ja {{ gesundheit.zecke | ja }}   Nein {{ gesundheit.zecke | nein }}`. Der dritte Zustand („nicht gefragt") fällt von allein an — beide leer.
- **Listen werden Schleifen.** Die sechs festen Felder für Mutter und Vater und die drei Unterschriftsblöcke gehen nicht: `family_guardians` kennt weder „Mutter" noch „Vater" als Steckplatz, sondern N Sorgeberechtigte mit einem Verhältnis. Zwei Mütter, ein Amtsvormund (`acting_for`), eine einzelne sorgeberechtigte Person — feste Plätze verschlucken jeweils still jemanden. **Die Sortierung muss ausdrücklich sein**, sonst hängt `contracts.document_checksum` an der Zeilenreihenfolge der Datenbank.
- **Vier Dateien statt einer.** Die heutige Datei bündelt Schulvertrag, Gesundheitsangaben, Fotoeinverständnis und SEPA-Mandat. Das Bündel trägt für alles darin die längste Frist, und aus einem Bündel ist nichts einzeln zu löschen (08). Der Schnitt ist **mit der Schule zu verhandeln**, nicht einfach zu machen.

**Verhandelt am 04.09.2026:** Die Geschaeftsfuehrung traegt den Schnitt mit — sie hat eingesehen, dass ein Buendel ein Datenschutzthema ist, und definiert den Vertragsvorgang als mehrere Unterlagen mit **je eigener Loeschfrist**. Damit ist die eine Haelfte dieses Kriteriums erfuellt. Offen bleibt die andere: der **Wegfall der angehefteten Anlagen** (TASK-231) ist nicht mitverhandelt, und **welche** Unterlagen es am Ende sind und wie lange jede laeuft, folgt aus den Aktenkategorien — deren Liste setzt der Datenschutzbeauftragte (TASK-058.10), nicht die Geschaeftsfuehrung.

**Getestet am 04.09.2026:** `InlineImage` in einer Schleife setzt die richtigen Bilder zu den richtigen Namen — nachgeprüft über die Prüfsumme der Mediendatei im erzeugten Dokument. Die Paarung ist garantiert, weil Name, Verhältnis, Fassung, Bild und Datum Felder **eines** Objekts sind; zwei parallele Listen mit Index wären der Weg, auf dem die falsche Unterschrift unter den falschen Namen gerät.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die 82 Inhaltssteuerelemente sind durch Klartext-Tags ersetzt; keine Formularfelder mehr in den Vorlagen
- [ ] #2 Aus der einen Datei sind vier geworden — Schulvertrag, Gesundheitsblatt, Fotoeinverstaendnis, SEPA-Mandat
- [ ] #3 Sorgeberechtigte, Module und Unterschriften stehen als Schleife, nicht als feste Steckplaetze
- [ ] #4 Mit der Schule verhandelt: der Schnitt in vier Dateien und der Wegfall der angehefteten Anlagen
<!-- AC:END -->
