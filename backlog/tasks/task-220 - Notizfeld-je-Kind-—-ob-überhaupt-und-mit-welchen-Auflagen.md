---
id: TASK-220
title: 'Notizfeld je Kind — ob überhaupt, und mit welchen Auflagen'
status: To Do
assignee: []
created_date: '2026-09-03 17:44'
labels:
  - entscheidung
  - dsgvo
  - stammdaten
dependencies: []
references:
  - schema/stammdaten-schema.sql
  - soll-prozesse/07-aufnahmeentscheidung.md
  - grenzkarte.md
ordinal: 233000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gefragt am 03.09.2026: Gibt es ein Notizfeld je Kind? **Nein — und zweimal ist es ausdrücklich abgelehnt worden.** Die Aufnahmeentscheidung „kennt kein Notizfeld" (07), und der einzige Freitext dieser Art, `applications.record_note`, gehört der Verwaltungsspur des Anmeldetags und der Bewerbung, nicht dem Kind.

**Der Bedarf ist trotzdem echt.** Das Sekretariat merkt sich Dinge, die in kein Feld passen — eine Absprache, eine Eigenheit im Ablauf, ein Hinweis, den man beim nächsten Anruf wissen will. Ohne Ort dafür landet er auf einem Zettel oder in einer privaten Mail, und dort ist er schlechter aufgehoben als in einer Spalte mit Leserkreis und Löschanker.

**Die Gefahr ist genauso echt und vom Betreiber selbst benannt:** Ein Freitext ohne Zweckbindung wird zur Schattenakte. Was dort landet, ist unstrukturiert, von keiner Regel erfasst und im Zweifel genau das, was nirgends stehen soll — eine Einschätzung über eine Familie, ein Verdacht, eine Gesundheitsangabe am falschen Ort mit dem falschen Leserkreis.

**Drei Auflagen, wenn es kommt:**

- **Ein benannter Leserkreis**, nicht „alle Mitarbeitenden". Sekretariat und Schulleitung; wer mehr braucht, begründet es.
- **Es ist Teil der Auskunft nach Art. 15.** Die Eltern lesen es — das gilt ohnehin, ob wir es hinschreiben oder nicht. Es hinzuschreiben, und zwar an das Eingabefeld selbst, ist der wirksamste Schutz gegen Missbrauch und kostet nichts: Wer weiß, dass die Familie es lesen kann, schreibt anders.
- **Löschanker am Kind**, Änderungsspur über `change_log` wie überall.

**Und was es nicht werden darf:** kein zweiter Ort für Gesundheitsangaben — die haben ihren, samt Sichtkreisen und Freigaben —, keine Verhaltensakte und kein Ersatz für ein Feld, das eigentlich fehlt. Taucht dieselbe Sorte Notiz dreimal auf, ist das kein Notizbedarf, sondern eine fehlende Spalte.

**Zu entscheiden ist zuerst, ob überhaupt.** Fällt die Antwort auf ja, ist es eine Spalte und keine Domäne.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob es ein Notizfeld je Kind gibt
- [ ] #2 Falls ja: benannter Leserkreis, am Eingabefeld steht, dass die Eltern es lesen können, Löschanker am Kind
- [ ] #3 Falls ja: der Kommentar an der Spalte sagt, was dort nicht hingehört — Gesundheit, Einschätzungen, Verdacht
- [ ] #4 Falls nein: die Ablehnung steht als Kommentar an der Tabelle, damit sie nicht dreimal neu gefragt wird
<!-- AC:END -->
