---
id: TASK-058.12
title: 'Frist: Newsletter-Empfänger ohne Vertragsverhältnis'
status: To Do
assignee: []
created_date: '2026-09-04 01:41'
labels:
  - wartet
  - dsgvo
milestone: m-5
dependencies: []
references:
  - fragen.md
  - verarbeitungsverzeichnis.md
parent_task_id: TASK-058
ordinal: 246000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Seit TASK-208 kann eine Person eine Newsletter-Einwilligung tragen, ohne je Familie, Kind oder Vertrag gehabt zu haben — Ehemalige, Förderkreis, Interessenten. Der Bestand ist eine `consents`-Zeile am `persons`-Eintrag; `fk_consents_person` kaskadiert, die Zeile geht also mit ihrer Person.

**Nur: für diese Person läuft keine Frist.** Jede andere Personengruppe rechnet an etwas — das Kind ab seinem Ende, der Sorgeberechtigte an der Familie, der Mitarbeitende am letzten Arbeitstag. Ein Ehemaliger hängt an keinem davon, und der Lösch-Lauf hat an ihm keinen Anker. Ohne Frist steht er unbegrenzt, und genau das verbietet Art. 5 Abs. 1 lit. e.

Zwei Wege, beide plausibel, keiner entschieden:

- **Ab dem Widerruf** — wer widerspricht, wird nach X gelöscht. Sauber, aber wer nie widerspricht, steht ewig.
- **Ab der letzten Zustellung** oder ab einer Zahl unzustellbarer Mails: Eine Adresse, die zwei Jahre lang keine Mail angenommen hat, ist tot. `outbound_emails.undeliverable_at` trägt das bereits.

Die Frist selbst gehört nicht ins Schema, sie ist eine Zahl im Lösch-Lauf. Was hier fehlt, ist die Antwort — und bis sie da ist, trägt `verarbeitungsverzeichnis.md` an dieser Personengruppe ein `[?]`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, woran die Frist eines Newsletter-Empfängers ohne Vertragsverhältnis rechnet
- [ ] #2 Der Widerruf selbst bekommt seine eigene Frist — er löscht die Zeile nicht, sie muss also irgendwann gehen
- [ ] #3 verarbeitungsverzeichnis.md trägt die Frist statt des [?]
- [ ] #4 Der Lösch-Lauf hat für diese Person einen Anker; ohne ihn räumt er sie nie
<!-- AC:END -->
