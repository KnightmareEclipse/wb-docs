---
id: TASK-279
title: Die endgültige Absenderadresse der Schulmails festlegen und eintragen
status: To Do
assignee: []
created_date: '2026-09-06 17:38'
labels:
  - wartet
  - betreiber
  - zugang
milestone: m-0
dependencies: []
ordinal: 291000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Anmeldehinweis im Elternportal nennt seit AUTH-R8 die Absenderadresse, wie Block 00 Z1 es verlangt — aber als Platzhalter: Er trägt post@clemens.schule, die Adresse, unter der wb-backend heute versendet (mail_sender in app/core/config.py). Welche Adresse die Schule wirklich verwendet, ist nicht entschieden. Sie steht an zwei Stellen und muss an beiden dieselbe sein: als Vorgabe von mail_sender und als Konstante SENDER in wb-elternportal/src/Login.tsx. Steht ein falscher Absender im Hinweis, suchen Eltern im Spam-Ordner nach dem Falschen — genau der Fall, gegen den der Hinweis gebaut wurde.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Absenderadresse ist mit der Schule abgestimmt
- [ ] #2 mail_sender in wb-backend trägt sie als Vorgabe
- [ ] #3 SENDER in wb-elternportal/src/Login.tsx trägt dieselbe Adresse, der PLATZHALTER-Kommentar ist weg
- [ ] #4 Das Postfach existiert im Tenant und die App-Registrierung darf darüber senden (Mail.Send)
<!-- AC:END -->
