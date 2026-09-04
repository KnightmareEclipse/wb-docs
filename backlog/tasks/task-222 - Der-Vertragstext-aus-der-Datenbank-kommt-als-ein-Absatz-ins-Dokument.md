---
id: TASK-222
title: contract_texts traegt die eingefrorene Vorlagendatei
status: To Do
assignee: []
created_date: '2026-09-03 22:40'
updated_date: '2026-09-04 00:17'
labels:
  - schema
  - wb-docs
  - wb-backend
milestone: m-2
dependencies:
  - TASK-186
references:
  - schema/querschnitt-schema.sql
  - soll-prozesse/hebel.md
ordinal: 199500
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
**Ersetzt die ursprüngliche Fragestellung.** Das Ticket fragte, welche Auszeichnungssprache `contract_texts.body` spricht und wer sie in Word-Absätze übersetzt. Die Frage ist hinfällig: Am 04.09.2026 gemessen und entschieden, dass die **Word-Datei selbst die Fassung ist** und `body` daraus abgeleitet wird. Damit übersetzt niemand etwas, und die drei dort vorgeschlagenen Wege entfallen alle drei.

**Warum.** Der reale Schulvertrag der Schule hat 682 Absätze, 4 Tabellen, 128 Listenabsätze in drei eigenen Ebenen, 10 Grafiken, zwei Kopf- und zwei Fußzeilen. Kein Fließtext- und kein Markdown-Feld trägt das. Die Datei ist ausserdem bereits eine Vorlage — 82 benannte Inhaltssteuerelemente, von Hand gebaut, weil Power Automate nicht anders in ein Word-Dokument schreiben konnte. Mit `docxtpl` im eigenen Backend braucht es diese Steuerelemente nicht.

**Was sich an `contract_texts` ändert:**

| Spalte | was |
|---|---|
| `body` | bleibt, aber **vom System geschrieben**: der aus der eingefrorenen Datei ausgelesene Text. `CLAUDE.md` erlaubt genau das — abgeleitet ja, gepflegt nein. Trägt weiter `GET /contract-texts`, den Textvergleich zweier Fassungen und die Volltextsuche |
| `template_docx` | neu, `bytea` — die eingefrorene Datei |
| `template_checksum` | neu, sha256 über die Bytes, dieselbe Bauform wie `contracts.document_checksum` |
| `frozen_at` | neu, wann eingefroren wurde |

**Die Datei liegt bewusst in Postgres und nicht in SharePoint**, abweichend von `grenzkarte.md` („Die Dateien selbst bleiben in SharePoint"). Sie trägt keine Personendaten, ist klein (400 KB beim echten Vertrag), **muss unveränderlich sein** — und in der Bibliothek ist sie das nicht, dort haben Sekretariat und Geschäftsführung Vollzugriff (`sharepoint_libraries`) — und sie gehört in dieselbe Sicherung wie die Zeile, die auf sie zeigt. Die Abweichung gehört als Absatz in `grenzkarte.md`, nicht in einen Nebensatz.

`code`, `valid_from` und `uq_contract_texts` bleiben unangetastet. Die Regel bleibt ebenfalls: eine angekündigte Fassung lässt sich ersetzen oder zurücknehmen, eine erreichte nie — auch dann nicht, wenn kein Vertrag auf sie zeigt, denn sie beantwortet „welcher Wortlaut galt am 1. September".
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `contract_texts` traegt Datei, Pruefsumme und Einfrierzeitpunkt; `body` wird beim Einfrieren aus der Datei ausgelesen und nicht mehr von Hand gesetzt
- [ ] #2 Der Kommentar an `body` sagt, dass die Spalte abgeleitet ist und woraus
- [ ] #3 Die Abweichung von der SharePoint-Regel steht als Absatz in `grenzkarte.md`, mit ihrem Preis
- [ ] #4 Gegenprobe: eine erreichte Fassung laesst sich nicht mehr aendern, eine angekuendigte schon
<!-- AC:END -->
