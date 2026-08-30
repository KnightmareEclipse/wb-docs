---
id: TASK-086
title: Zentrales Logging für Host und Container entscheiden
status: Done
assignee: []
created_date: '2026-08-27 11:40'
updated_date: '2026-08-30 18:30'
labels:
  - entscheidung
  - infra
milestone: m-1
dependencies: []
references:
  - container.md
  - container.md
  - wb-vps/ansible/group_vars/all.yml
ordinal: 98000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die einzige offene Teilentscheidung des Monitoring-Abschnitts: eine gemeinsame Senke statt eigenem Log-Stack, naheliegender Kandidat journald. Die endgültige Wahl folgt mit dem tatsächlichen Log-Volumen. Retention 30–90 Tage gilt unabhängig vom Tool.
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
journald, kein Log-Stack daneben — und die Bedingung, an der die Wahl hing, ist gemessen: 712 Byte Log je Anfrage (Caddys Zeile plus die des Backends), im Leerlauf praktisch nichts. Selbst ein voller Schultag bleibt weit unter dem, was einen zweiten Dienst rechtfertigte, und CPU dafür gibt es ohnehin nicht — die vier vCPU sind unter den vier Containern aufgeteilt. Dabei sind zwei stille Lücken aufgefallen und geschlossen: Der Journal hatte außer journalds eigener Vorgabe keine Grenze, also entschied die Größe die Aufbewahrung statt umgekehrt (drei Einstellungen nötig, nicht eine — ohne MaxFileSec prüft journald das Alter je Datei und wirft eine monatelange erst weg, wenn ihr jüngster Eintrag alt genug ist); und der Log-Treiber der Container war der Voreinstellung überlassen, die beim nächsten Umzug auf k8s-file den Offsite-Auszug still leer laufen ließe. Retention 30 Tage, das kurze Ende des Richtwerts aus container.md, als wb_journal_retention_days — ein anderer Wert ist eine Zeile.
<!-- SECTION:NOTES:END -->
