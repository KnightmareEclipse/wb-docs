---
id: TASK-240
title: contracts.document_checksum braucht ein Format und einen Leser
status: In Progress
assignee: []
created_date: '2026-09-04 12:35'
updated_date: '2026-09-05 00:35'
labels:
  - schema
  - api
  - wb-docs
dependencies: []
references:
  - dokumente.md
  - schema/anmeldung-schema.sql
ordinal: 253000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Pruefsumme am Vertrag ist als Gegenprobe angekuendigt — "damit sich jede spaetere Abweichung zeigt" (08), "die Pruefsumme an `contracts.document_checksum` ist die Gegenprobe" (`grenzkarte.md`). Gebaut ist sie nicht:

- Kein `ck_contracts_checksum`, weder Paarung mit `document_id` noch Format — waehrend `contract_amendments` beides hat (`ck_contract_amendments_checksum`) und `contract_texts.template_checksum` das Format erzwingt.
- Zwei Formate im Umlauf: der Bau schreibt `hexdigest()` ohne Praefix, das Pruefskript setzt `sha256:abc`.
- Kein Endpunkt liefert sie aus, kein Lauf haelt sie gegen die Datei. Nach `CLAUDE.md` gilt eine Regel ohne Gegenprobe als nicht gebaut.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 ck_contracts_checksum paart Pruefsumme und Dokument und erzwingt sha256:<64 Hex>
- [ ] #2 Der Bau schreibt dasselbe Format, das der CHECK verlangt
- [ ] #3 Die Pruefsumme ist ueber eine Route erreichbar, sodass eine vorgelegte Fassung pruefbar wird
- [x] #4 Gegenproben fuer beide Richtungen: Dokument ohne Pruefsumme, Pruefsumme im falschen Format
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Schema gebaut: `ck_contracts_checksum` paart Pruefsumme und Dokument und erzwingt `sha256:<64 Hexstellen>` — dieselbe Form, die `ck_contract_texts_checksum` schon traegt und die die Aenderungsspur liest.

Mitgenommen im selben Pfad: `ck_contract_amendments_checksum` prueft das Format jetzt ebenfalls; es paarte bisher nur. Damit tragen alle vier Pruefsummen dieser Domaene dieselbe Form.

Drei Gegenproben in anmeldung-schema-check.sql, alle gegen ck_contracts_checksum verifiziert: Urkunde ohne Pruefsumme, Pruefsumme im falschen Format, Pruefsumme ohne Urkunde. Die beiden Bestandsproben, die 'sha256:abc' setzten, tragen jetzt eine gueltige Summe — sonst waeren sie am Format gescheitert statt an der Regel, die sie belegen sollen.

Offen bleiben Kriterium 2 und 3, beide in wb-backend bzw. api/: Der Bau schreibt weiter den rohen `hexdigest()` und laeuft damit gegen den CHECK (TASK-267), und keine Route liefert die Pruefsumme aus. Der Satz in dokumente.md — 'eine Pruefsumme ohne Leser ist keine Gegenprobe' — bleibt deshalb stehen.
<!-- SECTION:NOTES:END -->
