---
id: TASK-105
title: Die Bezahlstrecke zum Zahlungsdienst aufbauen
status: To Do
assignee: []
created_date: '2026-08-27 22:44'
labels:
  - wb-backend
  - zahlung
  - putzdienst
milestone: m-0
dependencies: []
references:
  - api/gemeinsam.md
  - soll-prozesse/hebel.md
  - dsgvo.md
priority: high
ordinal: 117000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Stripe kommt im Code bisher nicht vor. Fehlt: die Checkout-Session erzeugen, die Referenz mitgeben, den Elternteil hinschicken und zurückholen. Trägt Jahres- und Einzel-Freikauf des Putzdienstes und damit die erste Zahlung überhaupt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Kein Name geht hinaus; die Mailadresse tippt der Elternteil auf der Bezahlseite selbst ein
- [ ] #2 Betrag und Referenz kommen aus configured_values bzw. dem Vorgang
- [ ] #3 Der Belegversand läuft über den Dienst, nicht über Weltenbaum
<!-- AC:END -->
