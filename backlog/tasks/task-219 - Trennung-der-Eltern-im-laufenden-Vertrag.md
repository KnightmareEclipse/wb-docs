---
id: TASK-219
title: Trennung der Eltern im laufenden Vertrag
status: To Do
assignee: []
created_date: '2026-09-03 17:29'
updated_date: '2026-09-03 17:44'
labels:
  - anmeldung
  - stammdaten
dependencies: []
references:
  - soll-prozesse/02-datenaenderung.md
  - soll-prozesse/08-schulvertrag.md
  - schema/stammdaten-schema.sql
  - fragen.md
ordinal: 232000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Wörtlich aus [M2]: ob berücksichtigt ist, dass es im laufenden Vertrag zu Trennungen kommt und dann Änderungen vorgenommen werden können.

**Beantwortet am 03.09.2026, und es ändert sich fast nichts:**

- **Der Vertrag bleibt.** Es wird kein neuer geschlossen, keine Unterschrift neu eingeholt, kein Vertragspartner ausgetauscht. Was sich ändert, sind Daten — der Wohnort vor allem.
- **Der Vorgang startet im Sekretariat**, nicht im Portal. Er ist damit eine gewöhnliche Datenänderung nach [02](../../soll-prozesse/02-datenaenderung.md), angestoßen von der Stelle, der die Trennung mitgeteilt wird.
- **Wird es schwierig** — darf ein Sorgeberechtigter etwas nicht mehr sehen oder nicht mehr tun —, wird es je Person eingeschränkt. **Das Modell steht bereits:** `family_guardians` führt die Einsichtsstufe, „vom Sekretariat auf Vorlage eines Beschlusses gesetzt", und daneben das Häkchen, ob jemand in die Post einzubeziehen ist — „die Stufe nimmt jemandem den Zugriff, dieses Häkchen nur die Post. Wer beides hat, bekommt nichts."

Zu tun bleibt damit fast nichts: **prüfen, ob Block 02 den Fall ausdrücklich nennt.** Nennt er ihn, ist dieses Ticket erledigt; nennt er ihn nicht, fehlt ihm ein Satz — die Trennung ist der häufigste Anlass, aus dem eine Einsichtsstufe überhaupt gesetzt wird, und wer das nicht liest, hält die Stufe für einen Sonderfall.

**Das SEPA-Mandat wird neu erteilt** (03.09.2026), wenn der Kontoinhaber auszieht — derselbe Weg wie bei jedem Kontowechsel. Damit bleibt an diesem Ticket nur noch der Satz in Block 02.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden: die Trennung verschiebt Daten und löst keinen Vertragsvorgang aus
- [x] #2 Entschieden: zieht der Kontoinhaber aus, wird ein neues SEPA-Mandat erteilt
- [ ] #3 Block 02 nennt die Trennung ausdrücklich als Anlass für eine Einsichtsstufe — oder es steht begründet, warum nicht
<!-- AC:END -->
