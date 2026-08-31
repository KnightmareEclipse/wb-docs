---
id: TASK-144
title: Ein Adressbudget für die Mailadress-Bestätigung
status: Done
assignee: []
created_date: '2026-08-31 01:11'
updated_date: '2026-08-31 21:40'
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

Gebaut: fünf je Person und Stunde (otp.MAX_EMAIL_CHANGES_PER_HOUR), gezählt über die `login_codes`-Zeilen, die die Route selbst schreibt — dieselbe Tabelle und dieselbe Stunde wie der Anmeldepfad, kein neuer Mechanismus. Je Person und nicht je Adresse, weil der Aufrufer angemeldet ist und nur die eigene Person und die eigenen Kinder erreicht, während die Empfängeradresse gerade das ist, was er variiert; das Sekretariat trifft es nicht, seine zwanzig Familien sind zwanzig Personen mit je eins. Abgewiesen wird laut mit 429 und nicht still wie der Anmeldecode: Dort hält die identische Antwort das Feld davon ab, über eine fremde Adresse Auskunft zu geben, hier erreicht der Aufrufer die Person ohnehin.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden: Budget wie am Anmeldecode oder ausgeschriebene Zeile im Plan, dass keines gilt
- [x] #2 Bei Budget: der Hebel aus auth.py wird genutzt, nicht in der Route nachgebaut
- [x] #3 Die Entscheidung steht als Satz in api/stammdaten-api.md
<!-- AC:END -->
