---
id: TASK-264
title: >-
  Der Zahlweg wird je Vorgang entschieden, und eine Familie laesst sich auf
  Stripe festnageln
status: Done
assignee: []
created_date: '2026-09-05 00:18'
updated_date: '2026-09-05 00:40'
labels:
  - wb-docs
  - wb-backend
  - schema
  - zahlung
  - dsgvo
dependencies: []
references:
  - soll-prozesse/hebel.md
  - grenzkarte.md
  - schema/stammdaten-schema.sql
  - schema/putzdienst-schema.sql
  - schema/ferien-schema.sql
ordinal: 277000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Heute entscheidet allein die Akademie zwischen Einzug und Sofortzahlung ("Das Geld folgt dem Mandat", 21); Putzdienst-Freikauf und Ferienbuchung koennen nur Stripe, weil ihr Vorgang keinen Zahlweg traegt. Die Geschaeftsfuehrung klaert mit der Buchhaltung, wie weit Stripe kuenftig genutzt wird — damit diese Entscheidung spaeter eine Zeile im Soll-Block kostet und keine Migration, bekommen cleaning_buyouts, cleaning_slot_buyouts und holiday_bookings denselben payment_mode, den academy_registrations schon hat.

Dazu die Sperre, die die Geschaeftsfuehrung ausdruecklich will: Eine Familie in Zahlungsverzug soll nur noch ueber Stripe zahlen duerfen, damit die Schule nicht auf den Kosten sitzenbleibt. Sie steht als Spalten-Paar an families (direct_debit_blocked_at/_by), wird von Hand von Buchhaltung oder Geschaeftsfuehrung gesetzt — den Verzug kennt Optigem, Weltenbaum nie — und traegt bewusst keinen Grund-Freitext, keinen Saldo und keine Forderung: das waere die Schatten-Buchhaltung, die grenzkarte.md Q3 verbietet. Sie greift ab sofort, unabhaengig von der GF-Runde, weil die Akademie heute schon einzieht.

Die Regel steht danach einmal in hebel.md und in drei Stufen: Sperre schlaegt Mandat, Mandat schlaegt Anlass. Reihenfolge nach CLAUDE.md: Soll-Block, grenzkarte.md, wb-backend, dann schema/ samt Pruefskript und Kopfkommentar.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 hebel.md traegt den Zahlweg in drei Stufen als eigenen Abschnitt; 01, 10 und 21 verweisen darauf, statt ihn zu wiederholen
- [x] #2 families traegt direct_debit_blocked_at/_by als Paar, gesetzt nur von entra:-Akteuren, und das Pruefskript weist das halbe Paar ab
- [x] #3 cleaning_buyouts, cleaning_slot_buyouts und holiday_bookings tragen payment_mode; ferien laesst direct_debit zu, ohne den Kostenuebernahme-Code anzutasten
- [x] #4 Jede neue Regel hat ihre Gegenprobe im -schema-check.sql, und die Kopfkommentare tragen den neuen Sollstand
- [x] #5 verarbeitungsverzeichnis.md nennt die Sperre als Datenkategorie
- [x] #6 Alle Schemata und alle Pruefskripte laufen mit ON_ERROR_STOP=1 gegen die vollstaendige Datenbank gruen
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Reihenfolge wie in CLAUDE.md: hebel.md bekam den eigenen Abschnitt "Der Zahlweg" (der Anker #sofortzahlung bleibt, damit die zehn Verweise darauf stehen bleiben), danach 01, 10, 21, grenzkarte.md Q3, dann wb-backend, dann schema/ samt Pruefskripten, zuletzt api/gemeinsam.md und verarbeitungsverzeichnis.md.

wb-backend: app/services/payments.py traegt die Entscheidung als payment_mode_for() samt DIRECT_DEBIT_CAUSES — heute leer, weil Stufe 3 keinen der hier gebauten Anlaesse zum Einzug fuehrt; die drei Schreibstellen in services/cleaning.py und services/ferien.py rufen sie. Die Migrationen der drei Domaenen wurden nach CLAUDE.md Abschnitt 6 bearbeitet statt ergaenzt, die Datenbank also neu aufgesetzt. GRANT UPDATE auf das Sperr-Paar geht an backend_finance und nicht an die Laufzeitrolle.

Gegenproben: fuenf an families (halbes Paar in beide Richtungen, guardian:, system:, und der erlaubte Fall samt Ruecknahme), drei am Putzdienst (direct_debit erlaubt, invoiced an beiden Freikaeufen abgewiesen), zwei an der Ferienbuchung.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Der Zahlweg steht als eigene Regel in hebel.md und wird in drei Stufen entschieden: die Sperre der Familie schlaegt das Mandat, das Mandat schlaegt den Anlass. families traegt die Sperre als Paar aus Zeitpunkt und entra:-Akteur, cleaning_buyouts, cleaning_slot_buyouts und holiday_bookings tragen ihren payment_mode. Welcher Anlass eingezogen wird, bleibt TASK-265 — heute keiner ausser der Akademie. Alle 14 Schemata und alle 14 Pruefskripte gruen (ON_ERROR_STOP=1), wb-backend 805 Tests, ruff, ruff format und mypy gruen.
<!-- SECTION:FINAL_SUMMARY:END -->
