---
id: TASK-220
title: 'Notizfeld an der Person, mit drei Auflagen'
status: In Progress
assignee: []
created_date: '2026-09-03 17:44'
updated_date: '2026-09-03 19:05'
labels:
  - dsgvo
  - stammdaten
milestone: m-5
dependencies: []
references:
  - schema/stammdaten-schema.sql
  - soll-prozesse/07-aufnahmeentscheidung.md
  - grenzkarte.md
ordinal: 233000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gefragt und entschieden am 03.09.2026: Es gibt heute kein Notizfeld je Kind — zweimal war es ausdrücklich abgelehnt (die Aufnahmeentscheidung „kennt kein Notizfeld", 07; `applications.record_note` gehört der Verwaltungsspur des Anmeldetags, nicht dem Kind). **Es wird jetzt gebaut**, mit drei Auflagen.

**Der Bedarf ist echt:** Das Sekretariat merkt sich Dinge, die in kein Feld passen. Ohne Ort landen sie auf einem Zettel oder in einer privaten Mail — dort schlechter aufgehoben als in einer Spalte mit Leserkreis und Löschanker. **Die Gefahr ist genauso echt:** Ein Freitext ohne Zweckbindung wird zur Schattenakte.

**Die Notiz steht an `persons`**, nicht an `children`. Kind und Sorgeberechtigter sind dieselbe Zeilensorte — `children.person_id` und `guardians.person_id` zeigen beide dorthin —, und zwei Spalten wären dieselbe Sache zweimal. Damit ist auch eine Notiz an einem Elternteil möglich, was gewünscht ist.

**Die Kante daran:** An `persons` hängen auch die Mitarbeitenden, und eine Notiz an einem Mitarbeitenden wäre ein Stück Personalakte — genau das, was Weltenbaum nicht führt („nur Name, dienstliche Mailadresse, Haus, erster und letzter Arbeitstag, Rolle, Nachfolgenotiz"). Das bleibt keine Konvention: **Keine Notiz an einer Person mit `employees`-Zeile**, als Gegenprobe im Prüfskript.

**Die drei Auflagen:**

- **Am Eingabefeld steht, dass die Familie die Notiz bei der Auskunft nach Art. 15 liest.** Das gilt ohnehin, ob es dort steht oder nicht — es dort hinzuschreiben ist der wirksamste Schutz gegen Missbrauch und kostet nichts. Wer es weiß, während er tippt, schreibt anders.
- **Ein Leserkreis, aber kein enger.** Die Notiz am Kind sieht, wer für das Kind zuständig ist — wer es unterrichtet oder betreut —, dazu Sekretariat und Schulleitung. Das ist dieselbe Achse wie bei den Gesundheitsangaben (TASK-161) und deshalb keine neue Regel. Die Notiz an einem Sorgeberechtigten sehen nur Sekretariat und Schulleitung: Ein Elternteil wird von niemandem unterrichtet, die Achse greift dort nicht.
- **Löschanker an der Person**, Änderungsspur über `change_log` wie überall.

**Warum der Kreis ausdrücklich nicht auf Sekretariat und Schulleitung verengt wird** — der erste Entwurf sah das vor und war vermutlich falsch: Ein enger Kreis fühlt sich privat an und lädt genau den Inhalt ein, den diese Auflagen verhindern sollen. Und er macht die Notiz nutzlos: Wer täglich mit dem Kind zu tun hat, sähe sie nicht, behielte seinen Zettel, und die Schattenakte entstünde trotzdem — nur außerhalb des Systems.

**Was die Notiz nicht werden darf**, als Kommentar an der Spalte: kein zweiter Ort für Gesundheitsangaben — die haben ihren, samt Sichtkreisen und Freigaben —, keine Verhaltensakte, kein Ersatz für ein fehlendes Feld. Taucht dieselbe Sorte Notiz dreimal auf, ist das kein Notizbedarf, sondern eine fehlende Spalte.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Die Notiz steht an persons und trägt damit Kind und Sorgeberechtigten
- [x] #2 Eine Notiz an einer Person mit employees-Zeile wird abgewiesen — als Gegenprobe
- [ ] #3 Am Eingabefeld steht, dass die Familie sie bei der Auskunft liest
- [ ] #4 Die Notiz am Kind sieht, wer für das Kind zuständig ist, dazu Sekretariat und Schulleitung; die am Sorgeberechtigten nur diese beiden
- [x] #5 Der Kommentar an der Spalte sagt, was dort nicht hingehört — Gesundheit, Einschätzungen, Verdacht
- [x] #6 Löschanker an der Person, Änderungsspur über change_log
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
persons.note steht, und die Grenze zu den Mitarbeitenden ist gebaut statt vereinbart:
persons.has_note ist abgeleitet, employees.has_note führt sie mit und ist per CHECK
immer falsch — der zusammengesetzte Fremdschlüssel weist beide Richtungen ab, die
Notiz an einer Person mit Mitarbeitendeneintrag wie den Eintrag für eine Person mit
Notiz. Ein Trigger war damit nicht nötig.

Offen: Kriterium 3 (der Hinweis am Eingabefeld) gehört nach oberflaechen.md, Kriterium
4 (der Leserkreis) nach grenzkarte.md — beide Dateien gehören in diesem Lauf keiner
Sitzung, die Sätze stehen im Bericht.
<!-- SECTION:NOTES:END -->
