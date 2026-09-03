---
id: TASK-197
title: 'Die Sichtkreise von sechs auf fünf zurückbauen, sports fällt weg'
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
updated_date: '2026-09-03 16:39'
labels:
  - entscheidung
  - gesundheit
  - dsgvo
dependencies:
  - TASK-152
references:
  - api/gesundheit-api.md
  - fragen.md
ordinal: 210000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Frage, die dieses Ticket ursprünglich stellte, ist beantwortet: Der Datenschutzbeauftragte hat den feinen Schnitt verworfen, Lehrkräfte und Hort sehen **alles** — für ihre Kinder —, und die Geschäftsführung hat am 03.09.2026 verschärft: nur wer das Kind unterrichtet. Damit ist `sports` gegenstandslos. Er war die Krücke für "jede Lehrkraft ohne Klassenleitung ist Fachlehrkraft für jedes Kind", und diese Krücke fällt mit TASK-161.

Zu tun bleibt der Rückbau, und er fasst gebauten Code an:

- **Sechs Sichtkreise werden fünf.** `class_lead` und `sports` fallen zu einem zusammen — beide sehen jetzt dasselbe. `care` bleibt ausdrücklich eigen: nicht weil er andere Felder sieht, sondern weil er ein eigenes **Freigabeziel** ist (TASK-205). `full`, `kitchen` und `emergency` bleiben unverändert.
- **Die Feld-Matrix schrumpft auf zwei echte Unterscheidungen:** die Küche auf Allergie und Lebensmittelunverträglichkeit, und das Attest als bloßes Vorliegen (TASK-206). Alles andere ist für Lehrkräfte und Hort offen. Das ist ein Wechsel im Seed, keine Migration — genau dafür ist die Matrix gebaut.
- **Drei DB-Rollen werden eine.** `backend_health_class_lead` und `backend_health_sports` verschmelzen; welche Rolle welchen Sichtkreis bekommt, steht heute allein in api/gesundheit-api.md und ist dort nachzuziehen — die Tabelle mit sechs Zeilen und die `[A]`-Begründung zu `sports` werden hinfällig.

Die Begründung im Kopf von schema/gesundheit-schema.sql nennt als Beispiel für "eine Zeile je Feld" ausgerechnet den Sportunterricht — sie wird mit TASK-205 auf Küche und Attest umgeschrieben und nicht hier.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 class_lead und sports sind ein Sichtkreis; care ist eigen geblieben, und der Grund steht als Kommentar
- [ ] #2 Der Seed trägt die zwei verbliebenen Unterscheidungen: Küche und Attest
- [ ] #3 api/gesundheit-api.md nennt fünf Sichtkreise und keine sports-Begründung mehr
- [ ] #4 Die zusammengelegten DB-Rollen sind in wb-backend zurückgebaut, kein Grant zeigt auf eine entfallene Rolle
<!-- AC:END -->
