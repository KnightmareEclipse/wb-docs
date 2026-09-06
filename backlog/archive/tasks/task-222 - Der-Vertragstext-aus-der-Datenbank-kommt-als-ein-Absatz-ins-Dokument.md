---
id: TASK-222
title: contract_texts traegt die eingefrorene Vorlagendatei
status: In Progress
assignee: []
created_date: '2026-09-03 22:40'
updated_date: '2026-09-04 01:05'
labels:
  - schema
  - wb-docs
  - wb-backend
milestone: m-2
dependencies: []
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

**Die Datei liegt bewusst in Postgres und nicht in SharePoint**, abweichend von `grenzkarte.md` („Die Dateien selbst bleiben in SharePoint"). Drei Gründe: Sie trägt keine Personendaten, sie ist klein (400 KB beim echten Vertrag), und sie **muss unveränderlich sein** — in einer Bibliothek ist sie das nicht, denn „wer Zugriff auf eine Bibliothek hat, kann dort löschen" (`oberflaechen.md`), und die App selbst schreibt dort. Dazu gehört sie in dieselbe Sicherung wie die Zeile, die auf sie zeigt: Eine Vorlage in SharePoint und ein Vertrag in Postgres können beim Wiederherstellen auseinanderlaufen.

Ein vierter Grund ist seit `5024721` weggefallen und steht hier, damit ihn niemand wieder aufgreift: Der Vollzugriff für Sekretariat und Geschäftsführung auf die erzeugten Unterlagen existiert nicht mehr — an Schülerakte und Belege kommt kein Mensch direkt. Das schwächt die Abweichung, hebt sie aber nicht auf.

Die Abweichung gehört als Absatz in `grenzkarte.md`, nicht in einen Nebensatz.

**Die Abhängigkeit auf TASK-186 ist gestrichen** (04.09.2026): Sie saß hier falsch. Diese Spalten sind eine Schemaänderung und warten auf nichts; PDF/UA trifft das **Einfrieren** und das **Rendern** — also TASK-228 und TASK-186 selbst.

`code`, `valid_from` und `uq_contract_texts` bleiben unangetastet. Die Regel bleibt ebenfalls: eine angekündigte Fassung lässt sich ersetzen oder zurücknehmen, eine erreichte nie — auch dann nicht, wenn kein Vertrag auf sie zeigt, denn sie beantwortet „welcher Wortlaut galt am 1. September".
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 `contract_texts` traegt Datei, Pruefsumme und Einfrierzeitpunkt; `body` wird beim Einfrieren aus der Datei ausgelesen und nicht mehr von Hand gesetzt
- [x] #2 Der Kommentar an `body` sagt, dass die Spalte abgeleitet ist und woraus
- [x] #3 Die Abweichung von der SharePoint-Regel steht als Absatz in `grenzkarte.md`, mit ihrem Preis
- [ ] #4 Gegenprobe: eine erreichte Fassung laesst sich nicht mehr aendern, eine angekuendigte schon
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Schema gebaut: contract_texts traegt template_docx (bytea), template_checksum und frozen_at; ck_contract_texts_frozen haelt die drei zusammen oder gar nicht, ck_contract_texts_checksum legt das Format sha256:<64 Hex> fest — nicht als Konvention, sondern weil TASK-232 es liest. Der Kommentar an body sagt, dass die Spalte abgeleitet ist und woraus, und dass eine Sorte ohne Arbeitsfassung (Klasse agreed/applies) ihn als Fassung selbst traegt. grenzkarte.md hat den Absatz zur Abweichung samt Preis (Binaerdaten in der Sicherung, eine Spalte, die kein Werkzeug lesbar anzeigt) — tragbar, weil es je Sorte und Gueltigkeitstag genau eine Fassung gibt und keine je Kind.

Offen bleibt Kriterium 4, und zwar bewusst: 'eine erreichte Fassung laesst sich nicht mehr aendern' vergleicht valid_from mit dem heutigen Tag, und now() ist in keinem CHECK zulaessig. Dieselbe ausgeschriebene Auslassung wie an configured_values und den beiden Preistabellen — die Regel prueft die Anwendung, und die Gegenprobe gehoert deshalb in die Testsuite von wb-backend, nicht ins Pruefskript.

Ebenfalls wb-backend: das Einfrieren selbst (Datei aus der Arbeitsfassung holen, body auslesen, Pruefsumme rechnen).
<!-- SECTION:NOTES:END -->
