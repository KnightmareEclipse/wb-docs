---
id: TASK-228
title: 'Fassung anlegen — pruefen, vorschauen, einfrieren'
status: To Do
assignee: []
created_date: '2026-09-04 00:19'
labels:
  - wb-backend
milestone: m-5
dependencies: []
ordinal: 240000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Eine Datei in SharePoint **lässt sich nicht einfrieren**, weil sie bearbeitbar bleibt. Zeigt `contracts.contract_text_id` auf eine Datei, die morgen jemand in Word öffnet, ist der Nachweis „welche Fassung galt" wertlos — lautlos.

Der Schnitt muss deshalb eine **Handlung** sein, kein Speichervorgang:

- **Die Arbeitsfassung** liegt in SharePoint, die Geschäftsführung bearbeitet sie in Word im Browser, so oft sie will. Nichts zeigt darauf, sie hat keinen Gültigkeitstag.
- **„Fassung anlegen"** liest die Arbeitsfassung über Graph, prüft sie und legt bei Erfolg eine unveränderliche Kopie mit `valid_from` und Prüfsumme an (TASK-222).
- Danach ist die Arbeitsfassung wieder frei.

Dasselbe Muster wie eine Ebene tiefer: Der Vorgang ist beweglich, die Urkunde eingefroren und mit Prüfsumme belegt.

**Die Prüfung, dreifach:**

1. `get_undeclared_template_variables()` gegen die Freigabe der Sorte (TASK-227). Ein unbekannter oder nicht freigegebener Name weist die Fassung ab — **mit Namen und den nächstähnlichen erlaubten**.
2. Probelauf mit Beispieldaten. Die Beispieldaten tragen **zwei unterscheidbare Sorgeberechtigte mit zwei unterscheidbaren Unterschriften**, damit eine vertauschte Paarung sofort auffällt.
3. veraPDF gegen PDF/UA-1 (TASK-186).

**Die eine Regel, an der alles hängt:** Geprüft und gerendert werden **die Bytes, die gerade eingefroren werden**. Nie im Vertrauen auf eine Vorschau von vorhin — sonst sieht sich jemand die Arbeitsfassung an, ändert danach noch etwas und friert eine Fassung ein, die nie durch die Prüfung lief.

**Das ist die Stelle, an der der Betreiber aus der Schleife fällt:** Die Prüfung sagt Nein, nicht er.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Pruefung laeuft auf den Bytes, die eingefroren werden — nie im Vertrauen auf eine fruehere Vorschau
- [ ] #2 Geprueft wird dreifach: Feldliste gegen die Freigabe, Probelauf mit Beispieldaten, veraPDF
- [ ] #3 Scheitert eine Pruefung, entsteht keine Fassung — mit benanntem Fehler, nicht mit einem leeren Feld
- [ ] #4 Die Arbeitsfassung bleibt danach frei bearbeitbar, ohne dass ein Vertrag es merkt
<!-- AC:END -->
