---
id: TASK-087
title: 'Cyber-Versicherung: Verzicht auf Verschlüsselung at rest rückbestätigen'
status: Done
assignee: []
created_date: '2026-08-27 22:23'
updated_date: '2026-09-03 13:54'
labels:
  - wartet
  - infra
milestone: m-5
dependencies: []
references:
  - host.md
priority: low
ordinal: 99000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die vorliegenden Bedingungen fordern keine Verschlüsselung at rest — weder für den Host noch für Backups; der zweite Admin trägt den Verzicht mit. Reine Rückversicherung bei Jürgen, kein offener Blocker.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Bestätigt, dass die Bedingungen keine Verschlüsselung at rest verlangen
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Beantwortet am 03.09.2026, wörtlich: "Eine Verschlüsselung der Festplatten wird von unseren Bedingungen nicht gefordert, wir empfehlen diese jedoch dringend zum Schutz vor physischem Diebstahl." Die Empfehlung zielt auf physischen Diebstahl — genau das Risiko, das bei Hetzner liegt und vom AV-Vertrag getragen wird (Anlage 2 § 4 Datenträgerkontrolle). Der Verzicht bleibt, jetzt mit schriftlichem Beleg. Eingetragen in host.md und verarbeitungsverzeichnis.md.
<!-- SECTION:NOTES:END -->
