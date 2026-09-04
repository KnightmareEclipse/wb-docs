---
id: TASK-230
title: 'Kein zweites Erzeugen, wo document_id schon steht'
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
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
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Schreibschicht weist ein zweites Erzeugen ab, wo contracts.document_id gesetzt ist
- [ ] #2 Eine Gegenprobe belegt die Abweisung — ein gruener Test, der ohne die Sperre rot wird
<!-- AC:END -->
