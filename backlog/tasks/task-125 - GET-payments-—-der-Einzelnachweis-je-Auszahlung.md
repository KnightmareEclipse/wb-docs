---
id: TASK-125
title: GET /payments — der Einzelnachweis je Auszahlung
status: To Do
assignee: []
created_date: '2026-08-28 13:27'
labels:
  - route
  - wb-backend
  - zahlung
  - buchhaltung
milestone: m-5
dependencies: []
references:
  - soll-prozesse/hebel.md
  - api/gemeinsam.md
  - schema/querschnitt-schema.sql
ordinal: 137000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Zahlungsdienst überweist gesammelt; die Buchhaltung muss zur Sammelgutschrift belegen, wer was wofür gezahlt hat — heute die Handarbeit, die sie am jetzigen Weg stört. Zeitraum filtern, Bruttobeträge, Familie, Anlass, Referenz des Zahlungsdienstes. Zugeordnet wird nichts: Die Zahlung legt den Vorgang an, die Zuordnung steht schon da.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Zeitraum wählbar, Summe der Bruttobeträge steht darunter
- [ ] #2 Je Zeile Familie, Anlass und die Referenz des Zahlungsdienstes — von Stripe aus findet man die Zeile, von hier aus die Stripe-Zahlung
- [ ] #3 Von Hand bestätigte Zahlungen laufen mit und sind als solche erkennbar (leere Referenz)
- [ ] #4 Sichtbar für Buchhaltung und Geschäftsführung
<!-- AC:END -->
