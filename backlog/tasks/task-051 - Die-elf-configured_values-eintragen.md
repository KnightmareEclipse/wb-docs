---
id: TASK-051
title: Die elf configured_values eintragen
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-09-03 18:09'
labels:
  - wartet
  - geschaeftsfuehrung
  - werteliste
milestone: m-0
dependencies: []
references:
  - soll-prozesse/hebel.md
  - schema/querschnitt-schema.sql
priority: high
ordinal: 54000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Freikauf und Strafe im Putzdienst, Bearbeitungs- und Anmeldegebühr, Änderungsgebühr der Betreuungsmodule, Geschwisterermäßigung, Kilometersatz und Meldegrenze der Rechnungsfreigabe, die drei des Elternbonus. Der Anfangsbestand setzt sie bewusst nicht: jeder Wert trägt einen Gültigkeitstag, und den setzt, wer den Betrag verantwortet.

**Sechs sind am 01.09.2026 bestätigt, alle mit valid_from 2026-09-01** — cleaning_buyout_cents 35 €, cleaning_penalty_cents 45 €, application_fee_cents 25 €, contract_fee_cents 90 €, parent_work_hours_primary 15 (Grundschule), parent_work_hours_default 10 (Realschule).

**Fünf fehlen weiterhin**, Zahl wie Gültigkeitstag: care_change_fee_cents (20 €), care_sibling_discount_basis_points (10 %), mileage_rate_cents (0,30 €), expense_report_threshold_cents (250 €), parent_work_monthly_cents (10 €). Sie stehen in pruefberichte/fragen-geschaeftsfuehrung.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ohne Freikauf- und Strafbetrag bricht die Fenster-offen-Mail ab, bevor die erste Zeile rausgeht
- [ ] #2 Ohne Freikauf- und Strafbetrag bricht die Fenster-offen-Mail ab, bevor die erste Zeile rausgeht
- [ ] #3 Die sechs bestätigten Werte liegen mit valid_from 2026-09-01 im Seed
- [ ] #4 Kein zwölfter Wert für den Jahresfreikauf: er ist das Rechenergebnis aus sechs Pflichtterminen (5+1) à 35 € = 210 € (E3 geklärt 03.09.2026)
- [ ] #5 Die Anmeldegebühr ist 100 €, gültig ab 01.09.2026 für jeden neuen Vertrag (Geschäftsführung, 03.09.2026) — die 90 € aus dem Hebel sind ersetzt
- [ ] #6 Die Bedingung der Änderungsgebühr steht in Block 09 und nicht im Wert: Sie fällt nur an, wenn keine Stundenplananpassung vorliegt und kein Zeitpunkt greift, zu dem eine Anpassung kostenfrei möglich wäre
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Die fünf offenen Werte sind am 02.09.2026 bestätigt, alle mit Gültigkeit ab sofort: care_change_fee_cents 20 EUR, care_sibling_discount_basis_points 10 Prozent, mileage_rate_cents 0,30 EUR je km, expense_report_threshold_cents 250 EUR, parent_work_monthly_cents 10 EUR. Die Änderungsgebühr trägt eine Bedingung, die kein Betrag ist: sie fällt nur an, wenn keine Stundenplananpassung vorliegt und kein kostenfreier Anpassungszeitpunkt greift — das gehört in Block 09. Ungeklärt bleibt contract_fee_cents: hier stand 90 EUR, in der bestätigten Liste vom 01.09.2026 stehen 100 EUR.
<!-- SECTION:NOTES:END -->
