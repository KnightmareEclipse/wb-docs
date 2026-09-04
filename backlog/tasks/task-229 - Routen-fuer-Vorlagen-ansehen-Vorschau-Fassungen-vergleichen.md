---
id: TASK-229
title: 'Routen fuer Vorlagen: ansehen, Vorschau, Fassungen vergleichen'
status: To Do
assignee: []
created_date: '2026-09-04 00:19'
labels:
  - wb-backend
  - route
  - api/querschnitt-api.md
milestone: m-5
dependencies: []
ordinal: 241000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Drei Einstiege in **dieselbe** Renderfunktion — die nimmt Bytes, nicht einen Ort:

| Aufruf | Bytes aus | Daten | Ergebnis |
|---|---|---|---|
| Vorschau der Arbeitsfassung | SharePoint (Graph) | Beispieldaten | verworfen |
| Ansicht einer geltenden Fassung | Postgres | Beispieldaten | verworfen |
| Ansicht vor der Unterschrift | Postgres | **echte Daten**, nach Einsichtsstufe | verworfen |
| Erzeugung der Urkunde | Postgres | echte Daten | abgelegt, Prüfsumme am Vertrag |

Es entsteht also **keine zweite Renderstrecke**, nur weitere Aufrufer.

**Vier statt drei, und der dritte ist der, den 08 Z3 verlangt:** Die Eltern lesen ihren gefüllten
Vertrag, bevor sie ihn unterschreiben — sonst zeichnen sie einen Text, den sie nie gesehen haben,
oder es entsteht eine HTML-Zweitfassung, die doppelt gepflegt werden müsste. Sie liegt als
`GET /contracts/{contract_id}/document` in `api/anmeldung-api.md` und gehört dieser Domäne, nicht
dieser Route hier.

**„Verworfen" heißt nicht „nie geschrieben":** Graph konvertiert nur ein Element, jeder Aufruf lädt
also erst eine `.docx` hoch. Wohin und wie sie wieder verschwindet, klärt TASK-238.

Die Vorschau ist [frisch erzeugt](../../soll-prozesse/hebel.md#frisch-erzeugte-liste) und nirgends gespeichert — Präzedenz ist das Deckblatt der Rechnungsfreigabe (`api/rechnungsfreigabe-api.md`).

Der Vergleich zweier Fassungen fällt ohne eigenen Bau ab: Der ausgelesene Text steht in `body` (TASK-222), zwei `body` sind ein gewöhnlicher Textvergleich. Ein Versionsbetrachter als Produkt wird nicht gebaut.

**Rollen:** Ansehen und Vorschau für Geschäftsführung und Sekretariat; das Anlegen einer Fassung bleibt allein bei der Geschäftsführung, wie heute schon bei `POST /contract-texts` — „sie verantwortet die Verwaltung und besonders die Verträge" (`glossar.md`).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 GET /contract-texts liefert je Code die geltende und die angekuendigte Fassung samt Pruefsumme und Einfrierzeitpunkt
- [ ] #2 GET /contract-texts/{id}/template liefert die eingefrorene .docx
- [ ] #3 GET /contract-texts/{id}/preview liefert ein frisch erzeugtes PDF mit Beispieldaten, nirgends gespeichert
- [ ] #4 Der Vergleich zweier Fassungen ist ein Textvergleich ueber body und braucht keinen Versionsbetrachter
<!-- AC:END -->
