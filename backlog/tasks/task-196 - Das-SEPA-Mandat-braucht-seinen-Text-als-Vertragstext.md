---
id: TASK-196
title: Das SEPA-Mandat braucht seinen Text als Vertragstext
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
labels:
  - geschaeftsfuehrung
  - anmeldung
dependencies: []
references:
  - app/services/anmeldung.py
  - soll-prozesse/hebel.md
ordinal: 209000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus TASK-192: Die Mandatsdatei wird aus contract_texts mit dem Code sepa_mandate gefüllt (SEPA_MANDATE_TEXT in app/services/anmeldung.py) — bis jemand den Text einträgt, trägt die Datei nur Kontodaten, Referenz und Unterschrift, aber keinen Mandatswortlaut. Der Wortlaut des SEPA-Basislastschriftmandats ist von der Bank vorgegeben; wer ihn liefert und ob Gläubiger-ID und Gläubigername darin stehen müssen, entscheidet die Geschäftsführung mit der Buchhaltung. Dazu: Die Datei trägt die volle IBAN und liegt in der Bibliothek „Erzeugt", die Sekretariat und Geschäftsführung lesen — die enge DB-Rolle backend_finance schützt nur die Tabelle, nicht das PDF. Alternative wäre eine maskierte IBAN; dann belegt die Datei das Mandat nicht.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Mandatstext liegt als contract_text sepa_mandate vor (POST /contract-texts) und erscheint in der Datei
- [ ] #2 Entschieden, ob die Datei die volle IBAN trägt oder eine maskierte
<!-- AC:END -->
