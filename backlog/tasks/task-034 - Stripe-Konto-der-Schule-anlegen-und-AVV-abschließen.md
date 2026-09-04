---
id: TASK-034
title: Stripe-Konto der Schule anlegen und AVV abschließen
status: In Progress
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-08-28 16:27'
labels:
  - wartet
  - geschaeftsfuehrung
  - zahlung
  - dsgvo
milestone: m-0
dependencies: []
references:
  - api/gemeinsam.md
  - dsgvo.md
priority: high
ordinal: 34000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das private Testkonto deckt davon nichts ab: kein AVV, keine Gesellschaftsfrage, und im Testmodus verschickt Stripe keine Belege. Trägt den Putzdienst-Freikauf und damit die erste Q3-Zahlung. **Die Geschäftsführung legt das Konto selbst an und zeichnet, fällig 14.09.2026** — das Konto kostet nichts, solange nichts darüber läuft, die Prüfung durch Stripe dauert einige Tage, und ohne Konto kann niemand online freikaufen.

**Stand 04.09.2026 (Geschaeftsfuehrung): Das Konto ist angelegt**, aber es fehlen noch Angaben, und dort haengt es beim Vorstand. Die Geschaeftsfuehrung ist dran. Damit ist die Frage 'wer legt es an' beantwortet und durch eine schaerfere ersetzt: **welche Angaben fehlen, und wer beschafft sie** (fragen.md). Ein Termin allein traegt nicht, solange niemand sagt, worauf gewartet wird — die Frist 14.09. steht.

**Beim Ausfuellen entscheidet sich etwas mit, das niemand als Frage stellt:** welche Stripe-Gesellschaft Vertragspartner wird. Davon haengt ab, ob ueberhaupt ein Drittlandtransfer nach Art. 44 ff. stattfindet (verarbeitungsverzeichnis.md). Wer das Formular abschickt, hat es entschieden — deshalb gehoert die Antwort in die Akte und nicht in die Erinnerung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Welche Stripe-Gesellschaft Vertragspartner ist (EU-Sitz vs. Drittland-Transfer nach Art. 44 ff.)
- [ ] #2 Welche Personendaten übertragen werden — Betrag und Referenz unvermeidlich, kein Name
- [ ] #3 Belegversand für erfolgreiche Zahlungen eingeschaltet (nur am echten Konto prüfbar)
- [x] #4 Wer legt das Konto an und wer zeichnet den AVV — eine benannte Person, nicht eine Rolle
- [ ] #5 Rückmeldung an den Betreiber, sobald das Konto freigeschaltet ist — vorher ist die Bezahlstrecke nicht testbar
<!-- AC:END -->
