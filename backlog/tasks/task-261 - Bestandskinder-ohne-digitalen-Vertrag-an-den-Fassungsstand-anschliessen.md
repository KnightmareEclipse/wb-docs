---
id: TASK-261
title: Bestandskinder ohne digitalen Vertrag an den Fassungsstand anschliessen
status: To Do
assignee: []
created_date: '2026-09-04 23:46'
labels:
  - import
  - anmeldung
milestone: m-5
dependencies: []
ordinal: 274000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Beim Vollimport kommen Kinder ins System, die ihren Vertrag **auf Papier** geschlossen haben. Fuer sie gibt es keine Fassung, keinen Diff und kein erzeugtes PDF — der Vertragsupdate-Prozess (08, TASK-259) haette an ihnen keinen Ansatzpunkt.

**Der Anker ist Pflicht, und das entscheidet den Weg:** `contracts.contract_text_id` ist NOT NULL. Ein importierter Altvertrag muss also auf eine Fassung zeigen; die Frage ist nur, auf welche.

**Der Weg in drei Schritten:**

1. **Die geltende Papierfassung wird eine `contract_texts`-Zeile** — mit ihrem Gueltigkeitstag und ihrem Text. Fuer den Betreuungsvertrag ist das die Fassung vom 11.12.2025. Eine Datei muss sie nicht tragen: `template_docx` ist nullable, und eine `signed`-Sorte ohne Vorlage ist ausdruecklich zulaessig (`schema/querschnitt-schema.sql`) — "die Sorte gibt es vor ihrer Datei".
2. **Die importierten Vertraege zeigen darauf.** Damit steht fuer jedes Kind ein Fassungsstand, und der Empfaengerkreis eines kuenftigen Updates rechnet sich von selbst aus (TASK-259): betroffen ist, wessen juengste bestaetigte Fassung aelter ist als die neue.
3. **Der erste Durchgang ist eine Erstvorlage, kein Vergleich.** Ohne Word-Fassung des alten Textes gibt es nichts zu diffen — die Familien bekommen den vollen neuen Text ohne Markierungen. Das ist der Durchgang, den der Betreiber als "einmal alle abholen" beschrieben hat; danach ist jeder Vertrag auf einem bekannten Stand und jede weitere Aenderung erzeugt einen echten Vergleich.

**Ein Diff waere schon beim ersten Durchgang moeglich**, aber nur, wenn die alte Fassung als `.docx` vorliegt und nicht bloss als PDF. Ob das der Fall ist, ist vor dem Import zu pruefen und keine Annahme.

**Was dabei nicht passieren darf:** den Altvertraegen die *neue* Fassung zuzuweisen, weil sie gerade gilt. Dann waeren alle scheinbar auf dem neuesten Stand, der erste Durchgang traefe niemanden, und die Papierunterschrift stuende unter einem Text, den die Familie nie gesehen hat.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die geltende Papierfassung steht als contract_texts-Zeile mit ihrem Gueltigkeitstag, auch ohne Datei
- [ ] #2 Jeder importierte Vertrag zeigt auf die Fassung, die bei seinem Abschluss galt — nicht auf die aktuelle
- [ ] #3 Der erste Durchgang legt den vollen Text vor, ohne Markierungen; ein Vergleich entsteht erst ab der naechsten Aenderung
- [ ] #4 Vor dem Import ist geprueft, ob die alte Fassung als .docx vorliegt — nur dann traegt schon der erste Durchgang einen Vergleich
<!-- AC:END -->
