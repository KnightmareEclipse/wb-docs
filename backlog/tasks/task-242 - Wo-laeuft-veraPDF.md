---
id: TASK-242
title: Wo laeuft veraPDF
status: To Do
assignee: []
created_date: '2026-09-04 12:36'
labels:
  - wb-backend
  - infra
dependencies: []
references:
  - dokumente.md
  - container.md
ordinal: 255000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die dritte Pruefung beim Anlegen einer Fassung ist veraPDF gegen PDF/UA-1 (TASK-228, TASK-186). veraPDF ist eine Java-Anwendung; der Stack in `container.md` ist Python/FastAPI und hat keine JVM, das Root-Dateisystem ist read-only, und die drei CPU-Grenzen summieren sich bereits auf die vier vCPU.

Dazu kommt: `oberflaechen.md` verkauft den Graph-Weg gerade damit, dass **kein Konverter im Container** laeuft. Steht ohnehin ein Java-Prozess daneben, aendert sich die Rechnung — dann ist auch der lokale Konverter wieder eine Option, und der wuerde den Zwischenstand in der Bibliothek ueberfluessig machen.

Beide Fragen gehoeren zusammen entschieden oder gar nicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, wo der PDF/UA-Pruefer laeuft — im Container, als eigener Dienst oder gar nicht
- [ ] #2 container.md traegt die Entscheidung samt Preis, oder es steht begruendet, dass geprueft nicht wird
- [ ] #3 Zusammen entschieden mit der Frage, ob ein lokaler Konverter den Zwischenstand ersetzt
<!-- AC:END -->
