---
id: TASK-013
title: 'Dublettenhinweis an Bewerbung und Buchung, keine eigene Liste'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:11'
labels:
  - wb-backend
  - anmeldung
milestone: m-4
dependencies: []
references:
  - fachdomaenen.md
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kandidatenabgleich Nachname + Geburtsdatum. Zwei Regeln: nie automatisch verknüpfen und das Ergebnis nie an den Absender — sonst bekäme jeder, der Name und Geburtsdatum eines Schulkindes kennt, Zugriff auf dessen Familie. Der Hinweis gehört an den Vorgang, den das Sekretariat ohnehin sichtet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Nie automatisch verknüpfen
- [ ] #2 Das Ergebnis erreicht den Absender nie
- [ ] #3 Knopf zum Verknüpfen am Vorgang, keine eigene Dublettenliste
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Geprüft, nicht gebaut: Der Kandidatenabgleich über Nachname und Geburtsdatum steht in keinem Soll-Block. 05 erkennt eine wiederkehrende Familie über die bestätigte Mailadresse ('Die Frage wird an der bestätigten Adresse beantwortet und nicht im Browser', GET /admission/targets), und der einzige Dublettenhinweis, den das Soll kennt, ist der aus 12 — Empfänger und Betrag innerhalb von 30 Tagen, gebaut an GET /expense-claims/{id}. Dieses Ticket würde ein zweites, schwächeres Erkennungsverfahren daneben stellen, das kein Block verlangt. Vor dem Bau zu entscheiden: gehört der Abgleich in 05 und 10, und was tut er, wenn er anschlägt — denn 'nie automatisch verknüpfen' braucht einen Ort, an dem das Sekretariat verknüpft, und den gibt es heute nicht.
<!-- SECTION:NOTES:END -->
