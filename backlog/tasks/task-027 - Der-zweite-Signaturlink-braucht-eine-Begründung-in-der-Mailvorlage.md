---
id: TASK-027
title: Der zweite Signaturlink braucht eine Begründung in der Mailvorlage
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:11'
labels:
  - wb-backend
  - anmeldung
  - mail
milestone: m-4
dependencies: []
references:
  - soll-prozesse/08-schulvertrag.md
  - schema/anmeldung-schema.sql
ordinal: 27000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Er sieht aus wie der erste; ohne einen Satz dazu wirkt er wie ein Systemfehler, und die Eltern unterschreiben nicht.
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Geprüft, nicht gebaut: Es gibt genau einen Signaturlink, und er geht an das Kind ab 14 (Fotoeinverständnis, POST /children/{child_id}/photo-consent-invitation), nicht an die Eltern — worauf sich 'die Eltern unterschreiben nicht' bezieht, ist damit offen. Der Kern des Tickets stimmt trotzdem: Die Route lässt sich beliebig oft aufrufen und verschickt jedes Mal dieselbe Mail, Wort für Wort. Was der Satz sagen soll, hängt an einer Entscheidung, die dahinter liegt: Der ältere Token bleibt gültig, bis er nach 14 Tagen abläuft — die zweite Mail müsste also sagen, welcher der beiden Links gilt, oder der ältere wird beim Neuanfordern ungültig gemacht. Das ist eine Änderung am Verhalten und ein Text, den ein Kind liest.
<!-- SECTION:NOTES:END -->
