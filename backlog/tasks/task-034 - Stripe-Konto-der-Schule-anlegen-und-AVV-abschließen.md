---
id: TASK-034
title: Stripe-Konto der Schule anlegen und AVV abschließen
status: To Do
assignee: []
created_date: '2026-08-27 11:37'
labels:
  - wartet
  - geschaeftsfuehrung
  - zahlung
  - dsgvo
milestone: m-0
dependencies: []
references:
  - TODO.md
  - api/gemeinsam.md
  - idea/06-dsgvo-organisatorisch.md
priority: high
ordinal: 34000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das private Testkonto deckt davon nichts ab: kein AVV, keine Gesellschaftsfrage, und im Testmodus verschickt Stripe keine Belege. Trägt den Putzdienst-Freikauf und damit die erste Q3-Zahlung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Welche Stripe-Gesellschaft Vertragspartner ist (EU-Sitz vs. Drittland-Transfer nach Art. 44 ff.)
- [ ] #2 Welche Personendaten übertragen werden — Betrag und Referenz unvermeidlich, kein Name
- [ ] #3 Belegversand für erfolgreiche Zahlungen eingeschaltet (nur am echten Konto prüfbar)
<!-- AC:END -->
