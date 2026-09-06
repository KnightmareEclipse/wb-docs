---
id: TASK-281
title: Die drei Domänen umzugsfähig bauen
status: To Do
assignee: []
created_date: '2026-09-06 20:54'
labels:
  - schema
  - stammdaten
  - anmeldung
  - wb-backend
dependencies: []
references:
  - fokus.md
  - CLAUDE.md
  - schema/stammdaten-schema.sql
  - schema/putzdienst-schema.sql
  - schema/anmeldung-schema.sql
milestone: m-1
priority: high
ordinal: 293000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Stammdaten, Putzdienst und Voranmeldung gehen produktiv, bevor das Gesamtmodell steht — die zehn
ruhenden Domänen kommen später und werden die Struktur verändern. Damit das keine Sperre wird, wird
jetzt **nicht** vorsorglich schön gebaut, sondern umzugsfähig: Ein späterer Umbau ist ein Export
plus ein Import, kein Migrationsprojekt.

Das ist billiger als eine Struktur, die alle dreizehn Domänen im Voraus richtig rät, und es ist die
Bedingung, unter der die drei Domänen bewusst schnell entstehen dürfen.

**Zwei Dinge tragen einen Umzug nicht** und müssen deshalb von der ersten echten Zeile an stimmen:

- **Die externe Referenz einer Zahlung.** Was der Zahlungsdienst vergibt, wird gespeichert wie
  empfangen und nie überschrieben, nie normalisiert, nie neu vergeben. Reißt diese Kette, gibt es
  Geld ohne Vorgang, und das lässt sich nachträglich durch keinen Import heilen.
- **Der Nachweis einer Einwilligung.** Wann, von wem, und in welche Fassung welchen Textes. Ein
  Zeitstempel ohne die Fassung ist kein Nachweis, und eine Fassung ohne Zeitstempel auch nicht.
  Betrifft die Zweckfelder der Voranmeldung (TASK-038) zuerst.

Alles Übrige darf umgeworfen werden. Der Anspruch ist nicht Schönheit, sondern dass der Bestand die
Struktur überlebt, in der er zufällig zuerst stand.

**Am Schema gemessen (06.09.2026), und deshalb kürzer als zunächst notiert:**

- **Der fachliche Schlüssel steht schon.** Alle personentragenden Tabellen haben `uuid`-Primär-
  schlüssel, die einen Reimport unverändert überstehen; die Integer-Tabellen daneben tragen je ein
  natürliches UNIQUE (`code`, bei `classes` das Tripel aus Schulart, Startjahr und Zug). Daran ist
  nichts zu bauen.
- **Die externe Zahlungsreferenz steht schon** als `payments.payment_reference` mit UNIQUE. Offen
  ist allein der Schutz gegen ein späteres UPDATE — ein Spalten-GRANT auf die Laufzeitrolle, kein
  Schema-Eingriff, und derselbe Griff wie bei den Kennungsspalten von `classes` (container.md).
- **Außerhalb des Umfangs:** `sepa_mandates` (Block 08) und `alumni`/`alumni_kinds` (Block 22)
  stehen zwar in `stammdaten-schema.sql`, dienen aber keiner der drei Domänen. Weder der Export
  noch der Round-Trip muss sie abdecken.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Jede der drei Domänen lässt sich vollständig als flache Datei exportieren — ohne Kenntnis des Schemas lesbar, mit ausgeschriebenen Spaltennamen und den Codes der Wertelisten statt ihrer IDs
- [ ] #2 `payment_reference` ist gegen UPDATE geschützt — Spalten-GRANT, mit `wb-backend/tests/test_privileges.py` als Gegenprobe
- [ ] #3 Jede Einwilligung trägt Zeitstempel und die Fassung des Textes, dem zugestimmt wurde — als Gegenprobe: eine Zustimmung ohne Fassungsbezug wird abgewiesen
- [ ] #4 Der Export der Stammdaten, in eine leere Datenbank zurückgelesen, ergibt denselben Bestand — einmal gelaufen, nicht nur behauptet
- [ ] #5 Der Weg ist derselbe wie für die DSGVO-Auskunft (TASK-193), kein zweiter daneben
<!-- AC:END -->
