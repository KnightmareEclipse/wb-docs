---
id: TASK-195
title: 'Elternantwort zum Fotoeinverständnis: Unterschrift und Datei entscheiden'
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
labels:
  - entscheidung
  - dsgvo
  - anmeldung
dependencies: []
references:
  - api/querschnitt-api.md
  - soll-prozesse/08-schulvertrag.md
ordinal: 208000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus TASK-192 (Nachtlauf 02.09.2026): Eine Datei entsteht dort, wo eine Unterschrift entsteht — beim Signaturlink des Kindes ab 14. Die Antwort der Eltern per PUT /children/{id}/consents/photo trägt keine Unterschrift und bekommt keine Datei; sie steht allein als Zeile mit granted_at (Art. 7 Abs. 1). 08 sagt „eine Unterlage, eine Datei" und TASK-192 „erzeugt, unterschrieben und abgelegt wie der Vertrag" — das passt für die Eltern nur, wenn ihre Antwort ebenfalls unterschrieben wird (image_base64 am PUT, Signature mit child_id, Datei wie beim Kind). Zu entscheiden, nicht nachts.

**Nachtrag 04.09.2026:** Die Abhaengigkeit von TASK-244 ist aufgeloest, die Frage selbst nicht. Der Nachweis steht jetzt in `photo_consent_records` und kommt **ohne Datei aus** — Name, Geburtsdatum, Abgang, Zweig und die beiden Zeitpunkte tragen ihn allein; der Dateiverweis ist deshalb nullable. Ob die Elternantwort eine Unterschrift bekommt, entscheidet damit nur noch, **wie viel** der Nachweis traegt, und haelt nichts mehr auf. Zu bedenken bleibt: Eine Datei, die unbegrenzt liegt, traegt den Namen des Einwilligenden unbegrenzt mit — bei einem Kind unter 14 entsteht heute gar keine.

<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob die Elternantwort eine Unterschrift und damit eine Datei bekommt
- [ ] #2 Falls ja: der PUT nimmt das Namensbild an, schreibt Signature und Datei; falls nein: der Satz in 08 ist entsprechend geschärft
<!-- AC:END -->
