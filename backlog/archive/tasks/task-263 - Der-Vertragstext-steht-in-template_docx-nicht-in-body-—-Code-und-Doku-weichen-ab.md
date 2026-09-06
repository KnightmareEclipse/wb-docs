---
id: TASK-263
title: Der Vertragstext gehoert in template_docx, gerendert wird aus body
status: To Do
assignee: []
created_date: '2026-09-04 23:57'
labels:
  - backend
  - dokumente
milestone: m-5
dependencies: []
ordinal: 276000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gefunden am 05.09.2026 beim Durchgehen des Renderpfads.

**`dokumente.md` sagt:** "Die Word-Datei selbst ist die Fassung, nicht der Text daneben. Der reale Schulvertrag hat 682 Absaetze, vier Tabellen, 128 Listenabsaetze in drei Ebenen, zehn Grafiken und je zwei Kopf- und Fusszeilen; kein Fliesstext- und kein Markdown-Feld traegt das." Und weiter: `contract_texts.body` sei "der ausgelesene Fliesstext fuer Volltextsuche und Fassungsvergleich".

**Der Code macht es umgekehrt:** `build_contract_document` (`wb-backend/app/services/anmeldung.py`) nimmt die Vorlage aus `settings.contract_template_path` — eine Datei im Image — und rendert `contract_texts.body` als `contract_body` hinein. Die Fassung aus der Datenbank ist damit ein Textblock in einer festen Rahmenvorlage, nicht die Datei selbst.

**Warum das jetzt zaehlt und nicht nur ordentlich waere:** Der Fassungsvergleich (TASK-259) laeuft auf `.docx`-Dateien. Steht die Fassung nur als Fliesstext in `body`, gibt es nichts zu vergleichen, das Tabellen, Nummerierung und Grafiken traegt — und genau daran ist der naive Weg schon einmal gescheitert (die Schulgeldtabelle fehlt im Rohtext vollstaendig). Auch der Import einer Arbeitsfassung aus SharePoint (`dokumente.md`, Station 2) setzt voraus, dass die Datei in `template_docx` landet und von dort gerendert wird.

**Die Absicht ist bestaetigt** (Betreiber, 05.09.2026): Die `.docx` steht in der Datenbank — alle eingefrorenen Fassungen samt Gueltigkeit und der eingelesene Zwischenstand. Gearbeitet wird an der Datei in SharePoint, die Datenbank haelt Staende. Der Code ist damit der Zwischenstand, nicht die Doku.

Haengt an TASK-226: Solange die Vorlage 82 Inhaltssteuerelemente traegt statt Klartext-Platzhaltern, ist sie ohnehin nicht die Fassung, die `docxtpl` fuellen kann.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Vertragstext wird aus contract_texts.template_docx gerendert, nicht aus body
- [ ] #2 body bleibt, wofuer dokumente.md ihn vorsieht: Volltextsuche und Fliesstext — nicht Renderquelle
- [ ] #3 settings.contract_template_path entfaellt oder traegt nur noch, was keine Fassung hat
- [ ] #4 Gegenprobe: eine Fassung mit Tabelle und Nummerierung kommt im erzeugten PDF vollstaendig an
<!-- AC:END -->
