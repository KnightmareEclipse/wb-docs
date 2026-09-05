---
id: TASK-240
title: contracts.document_checksum braucht ein Format und einen Leser
status: Done
assignee: []
created_date: '2026-09-04 12:35'
updated_date: '2026-09-05 19:09'
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
- [x] #2 Der Bau schreibt dasselbe Format, das der CHECK verlangt
- [x] #3 Die Pruefsumme ist ueber eine Route erreichbar, sodass eine vorgelegte Fassung pruefbar wird
- [x] #4 Gegenproben fuer beide Richtungen: Dokument ohne Pruefsumme, Pruefsumme im falschen Format
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Schema gebaut: `ck_contracts_checksum` paart Pruefsumme und Dokument und erzwingt `sha256:<64 Hexstellen>` — dieselbe Form, die `ck_contract_texts_checksum` traegt und die die Aenderungsspur liest. `ck_contract_amendments_checksum` prueft das Format ebenfalls; damit tragen alle vier Pruefsummen dieser Domaene dieselbe Form.

Drei Gegenproben in anmeldung-schema-check.sql, alle gegen ck_contracts_checksum verifiziert: Urkunde ohne Pruefsumme, Pruefsumme im falschen Format, Pruefsumme ohne Urkunde.

Der Bau schreibt dieses Format: `build_contract_document` setzt `f"sha256:{hashlib.sha256(pdf).hexdigest()}"` (wb-backend app/services/anmeldung.py:768), ebenso der Mandats- und der Einverstaendnis-Bau. `tests/test_anmeldung.py::test_the_release_builds_the_document_and_clears_the_images` haelt das Praefix im Vergleich und faellt ohne es rot.

Der Leser steht und ist gehalten: `ContractOut.document_checksum` (wb-backend app/routers/anmeldung.py:2382) wird aus `contract.document_checksum` gefuellt und kommt ueber `GET /contracts/{contract_id}` heraus; `tests/test_anmeldung.py::test_the_checksum_comes_back_out_of_the_contract_route` liest sie aus der Antwort statt aus der Zeile. Die Sicherung wurde gezogen: mit `document_checksum=None` in `_contract_out` faellt der Test rot.
<!-- SECTION:NOTES:END -->
