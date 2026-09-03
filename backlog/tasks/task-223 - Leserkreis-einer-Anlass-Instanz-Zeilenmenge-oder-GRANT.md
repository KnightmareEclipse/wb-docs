---
id: TASK-223
title: 'Leserkreis einer Anlass-Instanz: Zeilenmenge oder GRANT'
status: To Do
assignee: []
created_date: '2026-09-03 23:15'
updated_date: '2026-09-03 23:15'
labels:
  - entscheidung
  - gesundheit
  - dsgvo
dependencies: []
references:
  - schema/gesundheit-schema.sql
  - api/gesundheit-api.md
  - soll-prozesse/19-ausfluege-und-fahrten.md
ordinal: 235000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Freigabe je Instanz steht (TASK-205), und eine außerunterrichtliche Veranstaltung ist eine solche Instanz: Die Eltern geben ihr die Angaben befristet frei, vier Wochen nach dem Ende der Fahrt sind sie fort (19, `health_trait_releases.is_temporary`). Offen ist die andere Hälfte — **wer die Instanz lesen darf**.

Block 19 sagt es namentlich: „Wer die Angaben sehen darf, bestimmt die Lehrkraft — sie benennt Verantwortlichen und Begleitperson, beides nur interne Mitarbeitende, dazu die Schulleitung." Das Modell kann das nicht ausdrücken. Ein Sichtkreis ist eine Sicht in der Datenbank mit einer eigenen DB-Rolle, vergeben per GRANT (`api/gesundheit-api.md`): Eine je Fahrt benannte Person ist darin nicht darstellbar, und jede Fahrt kostete eine Sicht und ein GRANT.

Zwei Wege, beide mit Preis:

- **Leserliste je Instanz** (Person × Instanz), die die Policy neben dem Sichtkreis prüft. Trifft Block 19 wörtlich. Preis: die erste Zuständigkeit im System, die nicht aus einer Rolle folgt — bisher gilt „Rechte je Person gibt es nicht" (hebel.md, „Rollen"), und diese Liste ist genau das für einen benannten Fall.
- **Fester Kreis je Fahrt**: Die Instanz gibt an „wer das Kind unterrichtet plus Schulleitung" frei, also an die vorhandene zweite Achse (TASK-161). Kein neuer Mechanismus. Preis: Die Begleitperson ohne Zuständigkeit für dieses Kind sieht nichts — und genau sie ist auf der Fahrt dabei.

**Entschieden werden muss es vor Domäne 19, nicht davor.** Bis dahin gibt es keine Anlass-Instanz, und das Schema trägt die Frage als `[A!]` am Dateifuß von `schema/gesundheit-schema.sql`. Gefunden im Prüflauf vom 03.09.2026.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob der Leserkreis einer Anlass-Instanz eine Zeilenmenge ist oder aus der zweiten Achse folgt
- [ ] #2 Die Entscheidung steht als Satz im Schema, nicht in einer Datei daneben; die `[A!]` verliert dabei ihre Marke nicht
- [ ] #3 Fällt sie auf die Leserliste, ist die Ausnahme von 'Rechte je Person gibt es nicht' in hebel.md benannt
<!-- AC:END -->
