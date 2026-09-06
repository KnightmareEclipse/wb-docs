---
id: TASK-187
title: 'Die Akte in Weltenbaum: hochladen, blättern, ausliefern'
status: To Do
assignee: []
created_date: '2026-09-01 20:17'
updated_date: '2026-09-01 20:41'
labels:
  - api
  - querschnitt
  - sharepoint
  - wb-docs
  - wb-backend
dependencies:
  - TASK-181
references:
  - grenzkarte.md
  - soll-prozesse/08-schulvertrag.md
  - api/rechnungsfreigabe-api.md
  - api/querschnitt-api.md
ordinal: 200000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Entschieden am 02.09.2026: An die Schülerakte kommt kein Mensch mehr direkt. Ablegen, Nachschlagen und Herausgeben laufen über Weltenbaum, die Bibliothek behält nur die Bytes.

Zu bauen sind vier Griffe, und der schreibende ist keine Premiere: POST /expense-claims legt seine Anhänge längst selbst über Graph ab (api/rechnungsfreigabe-api.md) — dieselbe Bauform, anderer Bezug.

1. **Hochladen** am Kind, mit Kategorie. Weltenbaum benennt die Datei nach dem Schema der Schule und legt sie in den Unterordner der Kategorie. Eine Datei je Unterlage.
2. **Blättern**: je Kind die Kategorien, die der Aufrufer sehen darf, und darin die Dateien — über Graph gelistet, nicht als zweiter Index in der Datenbank.
3. **Ausliefern**: die vorhandene Regel, wer die Zeile sehen darf (GET /documents/{id}/content), erweitert um die frei abgelegten Dateien.
4. **Entfernen** einer falsch hochgeladenen Datei — sonst gibt es keinen Weg zurück, weil niemand mehr in die Bibliothek kommt.

Der Stapelfall ist eigens zu bedenken: ein Jahrgang Zeugnisse darf nicht hundert einzelne Vorgänge werden.

Zwei Aussagen im Bestand sind damit überholt und werden ersetzt, nicht ergänzt: 'Das Papier legt ein Mensch in die Bibliothek, die er ohnehin offen hat' (api/querschnitt-api.md, PUT /documents/{id}) und der Kommentar an sharepoint_libraries über den Vollzugriff für Sekretariat und Geschäftsführung (schema/querschnitt-schema.sql).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Hochladen setzt Dateiname und Unterordner selbst — der Aufrufer wählt nur die Kategorie
- [ ] #2 Blättern zeigt je Kind nur die Kategorien, die der Aufrufer sehen darf
- [ ] #3 Ausliefern und Entfernen folgen derselben Regel wie die Zeile daneben, kein zweites Rechtesystem
- [ ] #4 Der Stapelfall ist gelöst oder als bewusst offen benannt
- [ ] #5 PUT /documents/{id} nimmt keine fremd abgelegte Graph-Kennung mehr entgegen
- [ ] #6 Ein von Weltenbaum erzeugtes Dokument lässt sich über keine Route ersetzen oder entfernen — mit Test
- [ ] #7 Entfernen räumt Zeile, Datei, Versionsverlauf und Papierkorb; ein Ersetzen tut das ausdrücklich nicht
- [ ] #8 Entfernen darf, wer in diese Kategorie ablegen darf, und es steht in der Änderungsspur
- [ ] #9 Eine Datei ohne Art ist für einen erweiterten Leserkreis unsichtbar — mit Test, nicht nur als Regel
- [ ] #10 Wer eine Kategorie nicht lesen darf, kann auch nicht in sie ablegen
- [ ] #11 Beim Ablegen gegen eine Anforderung kommt die Art aus der Anforderung, nicht aus einer Eingabe
- [ ] #12 Liste der unbestimmten Dokumente fürs Sekretariat
- [ ] #13 Die Kategorie ist beim Ablegen mit der engsten vorbelegt
<!-- AC:END -->
