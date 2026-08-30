---
id: TASK-123
title: Idempotenz-Prüflauf für site.yml im Wegwerf-Container
status: Done
assignee: []
created_date: '2026-08-27 23:21'
updated_date: '2026-08-30 18:15'
labels:
  - infra
  - test
  - wb-vps
milestone: m-5
dependencies: []
references:
  - rules.md
  - host.md
  - container.md
  - wb-vps/ansible/tests/run-in-container.sh
ordinal: 135000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
rules.md Abschnitt 8 verlangt den Wegwerf-Lauf vor jedem Produktivlauf; heute wird er gegen einen echten neu aufgesetzten Server gefahren, was ihn teuer und damit selten macht. Eine verworfene Linie in wb-vps hatte dafür ansible/tests/run-in-container.sh samt Containerfile: site.yml zweimal gegen einen Wegwerf-Container, Fehlschlag wenn der zweite Lauf nicht changed=0 meldet. Das Muster ist richtig, die Fassung war es nicht — sie zielte auf Debian 12 und die Rollen harden/docker_rootless, die es nicht mehr gibt. Neu zu schreiben gegen Debian 13, hardening und podman_rootful, samt der Entscheidung, welche Tasks im Container nicht laufen können (netfilter-gestütztes UFW, cryptsetup-Swap, nicht namespace-fähige Sysctls) und deshalb eine Marke bekommen.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Zweiter Lauf meldet changed=0, sonst schlägt der Test fehl
- [x] #2 Was im Container nicht laufen kann, ist markiert und nicht stillschweigend übersprungen
- [x] #3 Die verworfene Fassung steht in der Git-Historie von wb-vps, Commit 1f9b4ee
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut gegen Debian 13, hardening und podman_rootful. 18 Tasks tragen tags: [host-only] — jede UFW-Regel, der verschlüsselte Swap und das sysctl-Drop-in; 55 Tasks laufen, 44 ändern beim ersten Durchgang etwas, der zweite meldet changed=0. Zwei Funde beim Bau: Das Testimage darf die Paketlisten nicht löschen, weil cache_valid_time den Refresh überspringt und der Lauf dann an 'No package matching ufw' scheitert; und die Marke am sysctl-Handler war wirkungslos, weil ein Handler laut Ansible-Doku alle Tags ignoriert — sie steht jetzt am Task, der ihn benachrichtigt. Beide Richtungen geprüft: grün wie er steht, rot mit einem absichtlich nicht-idempotenten Task, den er in der Fehlermeldung benennt. rules.md Abschnitt 8 nennt jetzt den Pfad.
<!-- SECTION:NOTES:END -->
