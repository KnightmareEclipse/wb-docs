---
id: TASK-007
title: 'Soll-Block 17 schreiben: Lösch-Lauf'
status: Done
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-09-03 22:11'
labels:
  - wb-docs
  - soll-block
  - dsgvo
milestone: m-1
dependencies: []
references:
  - prompts/block-fuellen.md
  - schema/querschnitt-schema.sql
priority: high
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Was verschwindet wann, in welcher Reihenfolge. Kein Nachzügler, sondern Voraussetzung: Jede Tabelle mit Personenbezug nennt im Schema ihren Löschanker, und viele zeigen auf einen Lauf, den bisher nur die Anker beschreiben. Solange er fehlt, ist die Frist selbst nirgends festgelegt.

Drei Fristen, die der Block nennen muss. Die Löschankündigung selbst — Vorlauf, Prüfauftrag, Anhalten im Einzelfall, Meldung an die Geschäftsführung — steht als Hebel in soll-prozesse/hebel.md und wird hier nicht wiederholt; dort steht auch, dass zwei Ankündigungen gehen — zwei Wochen und noch einmal eine Woche vorher — und dass je Bestand mindestens zwei Empfänger eingetragen sind.

- **Gesundheitsbestand am Kind: drei Monate nach dem Austritt** (03.09.2026). Ein schulfremdes Kind hat keinen Austritt — für es gilt die eigene Frist aus TASK-058.05: vier Wochen nach dem letzten gebuchten Termin.
- **Anlassbezogene Gesundheitsangaben: vier Wochen nach der Veranstaltung**, für Schulausflug, Ferienprogramm und Akademie. Nicht alles an einer Fahrt ist anlassbezogen: Tetanus, FSME, Schwimmfähigkeit und Haftpflicht bleiben am Kind (TASK-173), fahrtgebunden sind allein Badeerlaubnis und die Erlaubnis für besondere Aktivitäten.
- **DS9f, "drei Monate abrufbar": ab dem Abgang des Kindes** — aber nur für Mensa und Elternmitarbeit. Die Mensa hängt schon heute am "letzten bestätigten Ende dieses Kindes" (mensa-schema.sql), und beim Elternbonus ist es die Rückzahlung, die drei Monate nach dem Schulwechsel noch abrufbar sein muss.

Zwei Domänen fallen aus dieser Rechnung heraus, obwohl DS9f sie mit aufzählt:

- **Der Putzdienst** folgt der Jahrgangsfrist — Zyklusende plus ein Jahr — und ausdrücklich nicht dem Austritt des Kindes: "die Putzdienstdaten folgen weiter der Jahrgangsfrist aus 01" (Block 03, putzdienst-schema.sql).
- **Die Rechnungsfreigabe** kennt kein Kind, keine Familie und keine Klasse (Dateikopf rechnungsfreigabe-schema.sql), ihre Belege tragen bewusst keinen Löschanker und stehen zehn Jahre, und der Beleg überlebt seinen Einreicher — sein Name bleibt als Text daran. Offen ist dort nicht die Frist des Belegs, sondern die des Mitarbeitendeneintrags (DS10, weiter unbeantwortet).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Frist für eine change_log-Zeile ohne Anker ist entschieden (rund siebzig Tabellen erreichen ihren Anker nur über einen Join)
- [ ] #2 Welche Rolle die Spur löschen darf ist entschieden — backend_runtime liest und schreibt sie heute und löscht sie nicht
- [ ] #3 Häkchen und Link in soll-prozesse/README.md gesetzt
- [ ] #4 Entschieden, wer die Spur lesen darf: change_log trägt in old_value überschriebene Gesundheitsangaben und damit Art.-9-Daten
- [ ] #5 Die zwei Fristen stehen im Block: drei Monate ab Austritt für den Bestand, vier Wochen ab der Veranstaltung für den Anlass
- [ ] #6 Die Vorwarnung eine Woche vorher steht mit ihrem Adressaten je Anlass — Sekretariat beim Austritt, sonst die Stelle der Veranstaltung samt Leitung
- [ ] #7 1,2,3,4,5,6
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Block steht als soll-prozesse/17-loesch-lauf.md, Haken und Link in soll-prozesse/README.md. Entschieden: die ankerlose change_log-Zeile faellt drei Jahre nach der Aenderung ([A] im Block), loeschen darf sie allein der Lauf, lesen weiterhin nur Sekretariat und Schulleitung — kein Sichtkreis der Gesundheitsdomaene bekommt die Vorgeschichte einer Angabe. Der Empfaengerkreis steht als generelle Regel im Block; die derzeit besetzten bleiben in hebel.md.
<!-- SECTION:NOTES:END -->
