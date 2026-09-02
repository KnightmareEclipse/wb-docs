---
id: TASK-200
title: >-
  Notfalleinsicht: Notfallkontakt in der Antwort und die Leseroute des
  Protokolls
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
labels:
  - entscheidung
  - gesundheit
  - dsgvo
dependencies: []
references:
  - api/gesundheit-api.md
ordinal: 213000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Annahmen aus TASK-153/156 (Nachtlauf 02.09.2026): POST /children/{id}/emergency-accesses liefert neben dem Sichtkreis emergency (Allergie, Notfallmedikament samt Erlaubnis) und dem Hinweis der Klassenlehrkraft auch die Notfallkontakte der Familie mit Telefonnummern — die vier Dinge aus Frage 5 an den Datenschutzbeauftragten, in einem Aufruf, weil ein zweiter Aufruf einer Stammdaten-Route im Notfall das falsche Bauteil ist; den Kontakt sähe die Rolle sonst vielleicht gar nicht. Zu bestätigen. Offen bleibt außerdem, wer das Protokoll health_emergency_accesses ansieht und wie lange es bleibt (fragen-datenschutz.txt, Frage 5); bis dahin hat es keine Leseroute.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Bestätigt, dass die Notfallantwort die Notfallkontakte trägt — oder die Route auf den Gesundheitsausschnitt verengt
- [ ] #2 Nach der Antwort des Datenschutzbeauftragten: Leseroute und Frist des Protokolls geplant
<!-- AC:END -->
