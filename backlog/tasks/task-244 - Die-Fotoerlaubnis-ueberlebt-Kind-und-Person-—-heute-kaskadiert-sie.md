---
id: TASK-244
title: Die Fotoerlaubnis ueberlebt Kind und Person — heute kaskadiert sie
status: To Do
assignee: []
created_date: '2026-09-04 13:34'
labels:
  - schema
  - dsgvo
  - wb-docs
dependencies: []
references:
  - soll-prozesse/08-schulvertrag.md
  - schema/querschnitt-schema.sql
ordinal: 257000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Datenschutzbeauftragte am 04.09.2026: die Fotoerlaubnis bleibt **unbegrenzt** — "es muss ersichtlich sein, dass bis zum Tag die Fotoerlaubnis gegolten hat". Heute traegt `consents` genau das Gegenteil: `fk_consents_person` und `fk_consents_child` stehen beide auf `ON DELETE CASCADE`, die Zeile verschwindet also mit dem Kind (fuenf Jahre nach dem Austritt) und mit der Person.

**Drei Dinge sind zu entscheiden, und das dritte ist unangenehm:**

1. Der Loeschanker der `consents`-Zeile fuer den Fotozweck — kein Cascade, oder ein eigener Bestand daneben.
2. Der **Widerruf muss wirken koennen**: die weitere Nutzung unterbinden und das Loeschen vorhandener Bilder anstossen. Heute traegt `revoked_at` den Zeitpunkt und sonst nichts; wohin die Meldung geht und wer die Bilder zieht, steht nirgends.
3. **Eine Einwilligung ohne Einwilligenden belegt nichts.** Bleibt die Zeile unbegrenzt, bleibt auch die Person, die sie gegeben hat — sonst steht dort ein Nachweis ohne Namen. Damit reicht "unbegrenzt" ueber den Fotozweck hinaus in die Stammdaten, und das ist dem Datenschutzbeauftragten in dieser Form nicht vorgelegt worden. Vor dem Bau zurueckzufragen: Genuegt der Name im erzeugten PDF der Fotoerlaubnis, das ohnehin unbegrenzt liegt, sodass die Personenzeile regulaer loeschen darf?
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Loeschanker der Foto-Einwilligung ist entschieden und im Schema abgebildet — nicht Cascade mit Kind und Person
- [ ] #2 Gegenprobe: der Loesch-Lauf raeumt ein Kind, die Foto-Einwilligung bleibt nachweisbar stehen
- [ ] #3 Der Widerruf hat einen benannten Weg: Nutzung unterbinden, Bilder anstossen, Empfaenger der Meldung
- [ ] #4 Rueckgefragt: reicht der Name im PDF, oder muss die Personenzeile selbst unbegrenzt bleiben
- [ ] #5 verarbeitungsverzeichnis.md und folgenabschaetzung.md tragen den Bestand ohne Loeschtermin samt Begruendung
<!-- AC:END -->
