---
id: TASK-144
title: Ein Adressbudget für die Mailadress-Bestätigung
status: To Do
assignee: []
created_date: '2026-08-31 01:11'
labels:
  - wb-backend
  - stammdaten
  - mail
milestone: m-5
dependencies: []
references:
  - api/stammdaten-api.md
  - api/gemeinsam.md
ordinal: 156000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
PUT /persons/{person_id}/email schickt über Graph eine Mail an eine vom Aufrufer frei gewählte Adresse und trägt — anders als POST /auth/codes — keines der vier Mailbudgets aus api/stammdaten-api.md, "Zugang und Sitzung". Die einzige Schranke ist die globale Notbremse von 300 Anfragen je Minute und Adresse (app/core/throttle.py).

Der Plan verlangt für diese Route kein Budget, deshalb ist das eine Beobachtung und keine Planabweichung. Der Absenderruf der Schule hängt trotzdem daran: Wer eine Sitzung hat, löst damit beliebig viele Mails an beliebige Adressen aus.

Zu entscheiden ist, ob dieselben fünf je Adresse und Stunde gelten wie am Anmeldecode — der Code dafür liegt schon in app/routers/auth.py — oder ob die Notbremse für einen angemeldeten Aufrufer genügt. Gegen das Budget spricht, dass ein Elternteil mit Tippfehler nach fünf Versuchen gegen eine Wand läuft; für das Budget spricht, dass die Adresse frei wählbar ist und die Route deshalb ein Versandweg nach draußen ist.

Gefunden im dreizehnten API-Prüfzyklus als STAMMDATEN-R14, der einzige offen gebliebene Fund der Domäne.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden: Budget wie am Anmeldecode oder ausgeschriebene Zeile im Plan, dass keines gilt
- [ ] #2 Bei Budget: der Hebel aus auth.py wird genutzt, nicht in der Route nachgebaut
- [ ] #3 Die Entscheidung steht als Satz in api/stammdaten-api.md
<!-- AC:END -->
