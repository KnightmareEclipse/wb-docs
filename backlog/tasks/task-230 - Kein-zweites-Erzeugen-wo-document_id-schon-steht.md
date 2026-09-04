---
id: TASK-230
title: 'Kein zweites Erzeugen, wo document_id schon steht'
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
updated_date: '2026-09-04 12:36'
labels:
  - wb-backend
milestone: m-5
dependencies: []
ordinal: 242000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nach dem Bauen des Dokuments sind die Unterschriftsbilder gelöscht — „sie stehen jetzt im Dokument" (08), und „eine Zeile ohne Bild heißt: unterschrieben, Bild abgeräumt" (`grenzkarte.md`).

Ein **zweiter** Rendervorgang desselben Vertrags lieferte damit eine Urkunde **ohne Unterschriften** — die aussieht wie ein nie unterschriebener Vertrag. `grenzkarte.md` verbietet das Ersetzen bereits in Prosa („Was Weltenbaum selbst erzeugt hat, lässt sich weder ersetzen noch entfernen"), im Code steht dagegen nichts.

Mit einem Vorlagensystem im Rücken ist die Versuchung groß, „einmal eben neu zu rendern" — etwa nach einer korrigierten Vorlage. Genau dann darf es nicht gehen. Korrigiert wird durch einen **neuen Vorgang**, der neben dem alten stehen bleibt.

Ein `CHECK` trägt das nicht, es ist eine Ablaufregel. Also die Schreibschicht, und eine Gegenprobe daneben.

**Es braucht zwei Sperren, nicht eine.** Die Prüfung auf `document_id` fängt den zweiten Aufruf der Route; sie fängt nicht den Upload selbst. Der lief mit `@microsoft.graph.conflictBehavior=replace` und hätte die Urkunde an Ort und Stelle überschrieben — gleicher Name, gleiche Item-ID, neue SharePoint-Version. **Diese zweite Hälfte ist gebaut** (04.09.2026): Die Urkunde geht mit `replace=False` hoch, Graph antwortet auf einen zweiten Versuch mit 409, und `test_the_deed_is_uploaded_so_a_second_render_cannot_overwrite_it` zeigt es — ohne die Sperre wird der Test rot. Entwurf und Signaturbilder bleiben ersetzbar, ein neu gezeichneter Namenszug soll den alten überschreiben.

Offen bleibt damit die erste Hälfte: die Prüfung auf `document_id` in der Schreibschicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Schreibschicht weist ein zweites Erzeugen ab, wo contracts.document_id gesetzt ist
- [ ] #2 Eine Gegenprobe belegt die Abweisung — ein gruener Test, der ohne die Sperre rot wird
- [x] #3 Der Upload der Urkunde ist nicht ersetzbar (replace=False), Graph antwortet auf den zweiten Versuch mit 409
<!-- AC:END -->
