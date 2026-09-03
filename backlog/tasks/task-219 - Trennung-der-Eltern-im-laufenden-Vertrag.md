---
id: TASK-219
title: Trennung der Eltern im laufenden Vertrag
status: To Do
assignee: []
created_date: '2026-09-03 17:29'
labels:
  - wartet
  - anmeldung
  - stammdaten
dependencies: []
references:
  - soll-prozesse/02-datenaenderung.md
  - soll-prozesse/08-schulvertrag.md
  - schema/stammdaten-schema.sql
  - fragen.md
ordinal: 232000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Wörtlich aus [M2]: ob berücksichtigt ist, dass es im laufenden Vertrag zu Trennungen kommt und dann Änderungen vorgenommen werden können. Das ist keine Randfrage — es berührt drei Dinge auf einmal: **Sorgerecht**, **Vertragspartnerschaft** und **wer künftig unterschreibt**.

**Was schon steht und vermutlich trägt:** `family_guardians` führt je Person eine Einsichtsstufe, „vom Sekretariat auf Vorlage eines Beschlusses gesetzt", und daneben das Häkchen, ob jemand in die Post einzubeziehen ist — „die Stufe nimmt jemandem den Zugriff, dieses Häkchen nur die Post". Für den Sorgerechtsteil ist damit die Mechanik da; Block 02 beschreibt den Vorgang, das Sekretariat trägt die neue Lage nach Vorlage des Nachweises ein.

**Was nicht steht, ist der Vertrag.** Wer Vertragspartner ist und wer unterschreibt, hängt an `contracts`, `contract_responses` und `signatures` — und ob eine Trennung daran etwas ändert, ist nirgends beschrieben. Zwei Lesarten mit sehr verschiedenem Umfang:

- **Es ist ein Feld.** Der Vertrag läuft weiter, nur die Zuordnung, wer in seiner Sache handelt, verschiebt sich — dann genügt, was in `family_guardians` schon steht, und der Vertrag bleibt unberührt.
- **Es ist ein Vorgang.** Der Vertrag wird neu geschlossen oder ergänzt, mit Unterschrift der verbliebenen Partei — dann ist es die Bauform des Schulvertragsupdates (TASK-126) mit eigenem Anlass.

**Blockiert von fragen.md Frage 7.** Vor der Antwort wird nichts gebaut: Die beiden Lesarten liegen zwei Größenordnungen auseinander, und die Wahl ist keine, die wir treffen können — sie hängt daran, wie die Schule ihre Verträge führt.

`[?]` Mitzuklären, weil es an derselben Antwort hängt: Was geschieht mit dem SEPA-Mandat, wenn der Kontoinhaber auszieht?
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob die Trennung ein Feld verschiebt oder einen Vertragsvorgang auslöst
- [ ] #2 Der Weg für den Nachweis steht: wer legt was vor, wer trägt ein
- [ ] #3 Geklärt, was mit dem SEPA-Mandat geschieht, wenn der Kontoinhaber auszieht
- [ ] #4 Erst nach der Antwort auf fragen.md Frage 7
<!-- AC:END -->
