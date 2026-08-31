---
id: TASK-115
title: AVV mit Hetzner und Microsoft abschließen und ablegen
status: In Progress
assignee: []
created_date: '2026-08-27 22:45'
updated_date: '2026-08-31 19:20'
labels:
  - dsgvo
  - betreiber
milestone: m-0
dependencies: []
references:
  - dsgvo.md
ordinal: 127000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
dsgvo.md verlangt Verträge mit Hetzner, Microsoft und Stripe; Stripe hat sein eigenes Ticket (TASK-034). Bei Hetzner ist der AV-Vertrag in der Cloud Console erstellt, Anlage 1 dabei um die besonderen Kategorien personenbezogener Daten nach Art. 9 sowie um Minderjährige und Dritte ergänzt — der Katalog kennt beides nicht. Bei Microsoft besteht die DPA seit Beginn der M365-Nutzung über die Produktbedingungen des Lizenzvertrags: Sie wird weder unterschrieben noch im Portal aktiviert und rollt weiter, abzulegen ist deshalb die jeweils aktuelle Fassung. healthchecks.io braucht keinen AVV, die Begründung steht in dsgvo.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Für Hetzner und Microsoft liegt ein erstellter bzw. über den Lizenzvertrag geltender AVV vor
- [ ] #2 Beide samt TOM-Anlage dort abgelegt, wo sie auch der zweite Admin findet
<!-- AC:END -->
