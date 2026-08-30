---
id: TASK-013
title: 'Dublettenhinweis an Bewerbung und Buchung, keine eigene Liste'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:23'
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
Geprüft, nicht gebaut, und der Schlüssel selbst trägt nicht: Nachname und Geburtsdatum sind nicht eindeutig, und der Regelfall dafür steht im Soll — 'Je Kind eine Bewerbung, Zwillinge sind zwei, die Angaben der Familie stehen trotzdem nur einmal da' (05, Z3); 'Zwillinge sind zwei Verträge' (08, schema/anmeldung-schema.sql). Zwei Geschwister derselben Geburt teilen beide Merkmale, ein Abgleich darüber schlägt bei ihnen also immer an. Das entwertet den Hinweis nicht, es begründet die erste Regel des Tickets: nie automatisch verknüpfen, weil der Treffer der häufigste echte Nicht-Treffer ist. Dazu kommt: Der Kandidatenabgleich steht in keinem Soll-Block. 05 erkennt eine wiederkehrende Familie über die bestätigte Mailadresse ('Die Frage wird an der bestätigten Adresse beantwortet und nicht im Browser', GET /admission/targets), und der einzige Dublettenhinweis, den das Soll kennt, ist der aus 12 — Empfänger und Betrag innerhalb von 30 Tagen, gebaut an GET /expense-claims/{id}. Vor dem Bau zu entscheiden: gehört der Abgleich in 05 und 10, welcher Schlüssel trennt Zwillinge, und wo verknüpft das Sekretariat — 'nie automatisch' braucht einen Ort, an dem es von Hand geschieht, und den gibt es heute nicht.
<!-- SECTION:NOTES:END -->
