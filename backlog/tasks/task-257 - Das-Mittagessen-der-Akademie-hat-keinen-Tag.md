---
id: TASK-257
title: Das Mittagessen der Akademie hat keinen Tag
status: Done
assignee: []
created_date: '2026-09-04 23:05'
updated_date: '2026-09-04 23:30'
labels:
  - schema
  - akademie
  - mensa
  - entscheidung
dependencies: []
ordinal: 270000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beim Umzug der Kochwerkstatt (TASK-177) ist `includes_lunch` vom Ferienmodul an das Akademie-Angebot gewandert, mit derselben Bedeutung: "wo es gesetzt ist, steht das Kind an diesem Tag auf der Mensaliste (11)" (Spaltenkommentar in akademie-schema.sql, Block 21 Zeile 126). Der Tag laesst sich aber nicht ableiten.

Beim Ferienmodul ging es: `holiday_session_days` trug je Termin die Kalendertage, und die Buchung hing am Termin. Das Akademie-Angebot hat nur `starts_on`/`ends_on` und den Freitext `schedule_text` ("dienstags 14-15 Uhr") — eine Terminliste ist ausdruecklich keine Struktur (TASK-176). Fuer eine Reihe ueber sechs Wochen liefert der Zeitraum jeden Tag darin, der Freitext ist nicht rechenbar.

Folge in der Doku: api/mensa-api.md nennt als dritte Herkunft der Tagesliste noch "Ferien- oder Werkstatttermin" samt `holiday_modules.includes_lunch` — die Spalte gibt es nicht mehr, und ein Ferienmodul traegt heute ausdruecklich kein Essen. Die Zeile ist deshalb nicht bloss nachzuziehen: Ohne eine Entscheidung, woraus der Tag folgt, hat die dritte Herkunft keinen Nachfolger.

Drei Wege, deren Preis verschieden ist: ein Wochentag am Angebot (eine Spalte, deckt die Reihe, nicht den unregelmaessigen Kurs); eine Terminliste je Angebot (deckt alles, ist genau die Struktur, die TASK-176 verworfen hat); oder die Kueche traegt das Akademie-Essen von Hand ein (keine Struktur, dafuer die Excel-Liste zurueck, die die Tagesliste ersetzen sollte).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden, woraus der Kalendertag eines Akademie-Essens folgt
- [x] #2 api/mensa-api.md nennt keine Spalte mehr, die es nicht gibt; die dritte Herkunft der Tagesliste steht in der entschiedenen Form oder ist gestrichen
- [x] #3 Wenn es Struktur wird: Schema, Pruefskript samt Sollstand und die Gegenprobe stehen
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Entschieden am 05.09.2026 in zwei Schritten. Zuerst "Essen nur am durchgehenden Angebot" (`runs_daily`); der Betreiber hat den Fall nachgereicht, der das kippt: Bei einem mehrtaegigen Angebot faengt der erste Tag oft nach dem Mittag an, der letzte hoert davor auf, und ein Wochenende mittendrin kocht niemand. `runs_daily` ist deshalb wieder heraus.

Gebaut ist stattdessen `academy_offering_lunch_days` — eine Zeile je Tag mit Essen, exakt die Bauform von `holiday_session_days` und aus demselben Grund, den deren Kommentar schon traegt: "eine Zeile je Tag statt eines Von-Bis, weil eine Ferienwoche Feiertage aussparen darf". `includes_lunch` ist mit weggefallen: "enthaelt ein Mittagessen" ist die Frage, ob eine Zeile steht, und ein Haekchen daneben waere dieselbe Tatsache ein zweites Mal — auseinanderlaufen koennten sie auf drei Wegen, und ein CHECK sieht keine andere Tabelle.

Der Zeitraum wird an der Zeile mitgefuehrt (zusammengesetzter Fremdschluessel mit ON UPDATE CASCADE), damit `ck_academy_offering_lunch_days_period` ihn sehen kann — dasselbe Muster wie bei den Freigaben in gesundheit-schema.sql, und deshalb kein zweiter Trigger. Ein Verschieben des Angebots zieht die Grenze nach, ein Verkuerzen scheitert, solange ein Esstag drausssen laege: erst den Tag streichen, dann den Zeitraum.

Verworfen: ein Wochentag am Angebot (kennt keinen Ausfalltag), `runs_daily` (kennt keinen schiefen Rand), und die volle Terminliste mit Essens-Haekchen je Tag (genau die Struktur, die TASK-176 verworfen hat, plus fuenfunddreissig Zeilen am Chor, an denen nie jemand isst).

Nachgezogen: akademie-schema.sql (8 statt 7 Tabellen), akademie-schema-check.sql samt Sollstand im Kopf und acht Proben, Block 21, Block 11 an zwei Stellen, api/mensa-api.md und grenzkarte.md. Block 11 widersprach sich selbst — Zeile 13 verneinte das Ferienmodul, Zeile 183 fuehrte es noch als dritte Herkunft. Gegenprobe der Gegenprobe: CHECK auf CHECK (true) entschaerft, derselbe Lauf endet mit rc=3 und 'REGEL NICHT GEBAUT — durchgelassen: 21 — Esstag nach dem Ende des Angebots'. Alle 14 Pruefskripte rc=0.

Nicht hier gebaut: Tabelle und Route fehlen in wb-backend (TASK-180) und in api/akademie-api.md, die es noch nicht gibt (TASK-179) — dort ist es ein Schritt wie beim Ferientermin: Angebot und Esstage in einer Transaktion.
<!-- SECTION:NOTES:END -->
