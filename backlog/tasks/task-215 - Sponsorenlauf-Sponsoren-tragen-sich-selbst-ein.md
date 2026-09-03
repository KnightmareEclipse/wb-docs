---
id: TASK-215
title: 'Sponsorenlauf: Sponsoren tragen sich selbst ein'
status: To Do
assignee: []
created_date: '2026-09-03 16:38'
updated_date: '2026-09-03 16:43'
labels:
  - schema
  - dsgvo
  - wartet
dependencies: []
references:
  - schema/stammdaten-schema.sql
  - schema/querschnitt-schema.sql
  - fragen.md
priority: low
ordinal: 228000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus [M3]: Ein Kind läuft Runden, Sponsoren aus seinem persönlichen Umfeld zeichnen einen Betrag je Runde. Heute QR-Code, Liste, hinterher ein Spendenaufforderungsbrief. Gewünscht ist, dass die Sponsoren sich **selbst eintragen, ohne Zugang zu meinCLEMENS**; die Buchhaltung braucht Person und Betrag, weil es spendenbescheinigungsrelevant ist, dazu den Abgleich mit dem Spendeneingang.

**Zwei Dinge sind daran neu, und beide sind der eigentliche Aufwand:**

- **Ein Personenkreis ohne jedes Vertragsverhältnis.** Fremde Erwachsene, die weder Eltern noch Mitarbeitende sind. `persons` trägt sie ohne Weiteres — kein Fremdschlüssel auf `families`, Adresse und Mail sind nullable. Was fehlt, ist ihre Löschfrist und die Rechtsgrundlage.
- **Ein Schreibweg ohne Anmeldung.** Bisher schreibt niemand ins System, ohne sich anzumelden; die Ausschreibung der Akademie ist der erste Endpunkt ohne Zugang, aber sie liest nur. Hier nimmt eine Route Namen fremder Erwachsener entgegen — das braucht einen Schutz gegen Müll und gegen das Eintragen im fremden Namen.

**Auf der langen Bank** (03.09.2026): Es war eine Idee, ob sich das über das Portal abbilden ließe — kein Auftrag. Der heutige Weg über QR-Code, Liste und Spendenaufforderungsbrief läuft weiter, und nichts hängt daran.

**Zwei Fragen wären zu stellen, wenn es soweit ist** — sie stehen bewusst *nicht* in fragen.md, weil Antworten auf etwas, das niemand bauen will, nur den Fragenkatalog aufblähen:

- **An den Datenschutzbeauftragten:** Rechtsgrundlage, Zweck und Frist für einen Personenkreis fremder Erwachsener, dazu die Pflichtangaben des Formulars. Ein Zugang ohne Anmeldung, der Namen Dritter entgegennimmt, wäre der erste seiner Art im System.
- **An die Geschäftsführung:** wie der Weg hinein aussehen soll — Link je Kind, QR-Code wie heute, offenes Formular — und wer den Abgleich mit dem Spendeneingang macht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Sponsor entsteht als Person ohne Familie und ohne Vertragsverhältnis — mit eigener Löschfrist
- [ ] #2 Der Schreibweg verlangt keine Anmeldung und ist gegen Müll und Fremdeintrag geschützt
- [ ] #3 Person und Betrag stehen der Buchhaltung als Liste zur Verfügung, samt Abgleich mit dem Eingang
- [ ] #4 Erst nach den Antworten auf fragen.md Frage 4 und 12
<!-- AC:END -->
