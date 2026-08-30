---
id: TASK-011
title: Personalisierter Link in der Ferienprogramm-Ankündigung
status: Done
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:02'
labels:
  - wb-backend
  - ferien
  - mail
milestone: m-3
dependencies: []
references:
  - soll-prozesse/10-ferienprogramm.md
  - zugang.md
  - wb-elternportal/src/Login.tsx
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Je Empfänger personalisiert, nicht einer für alle. Er meldet nicht an: er trägt die Adresse, an die er ging, füllt das Adressfeld und löst den Code aus. Weil er nichts freischaltet, braucht er keinen Token-Speicher und keine Gültigkeitsdauer.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Adresse als Query-Parameter, kein selbst authentifizierender Link
- [x] #2 Eine weitergeleitete Ankündigung nützt dem Empfänger nichts — der Code geht ans ursprüngliche Postfach
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut als allgemeine Form für jede Mail, die die Schule von sich aus verschickt, nicht für die eine Ankündigung: Block 10 kennt drei Mailanlässe und keinen davon als Ankündigung ('Keine Erinnerung vor dem Termin, keine weitere Meldung nach innen') — die Ankündigung schreibt die Schule selbst. Die Regel steht jetzt in zugang.md statt als Verweis auf backlog/, das Adressfeld füllt wb-elternportal/src/Login.tsx, und aus dem Zugriffsprotokoll hält die Adresse der Filter aus TASK-012 heraus. Eine Abweichung: Der Aufruf des Links fordert den Code nicht selbst an. Mailfilter rufen Links vor dem Menschen ab, und ein Code je Abruf verbrauchte das Stundenkontingent (fünf je Adresse, sechzig für alle, app/core/otp.py) — bei einem Rundschreiben an alle Familien reißt die zweite Grenze, und die Letzten bekämen dieselbe Antwort und keine Mail.
<!-- SECTION:NOTES:END -->
