---
id: TASK-256
title: Die Tagesliste des Horts als Ausdruck bauen
status: To Do
assignee: []
created_date: '2026-09-04 20:39'
labels:
  - anmeldung
  - gesundheit
milestone: m-5
dependencies: []
ordinal: 269000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus dem Gespraech mit der Geschaeftsfuehrung am 04.09.2026: Wofuer der Hort seine Excel wirklich braucht, ist der **Ausdruck**. Fuer jeden Tag wird eine Liste aller Kinder frisch gedruckt, und auf ihr wird abgehakt, wer da ist — "im Trubel zwischen Kindern ergibt ein iPad keinen Sinn, Papier ist der beste Weg".

Die Betreuungsliste gibt es bereits als frisch erzeugte Sicht (TASK-216, Done). Was fehlt, ist die **Form**: druckfertig, jeden Tag neu, mit Platz zum Abhaken.

**Drei Dinge kommen dazu:**

1. **Die Marke direkt hinter dem Namen** — ein Zeichen, kein Inhalt: Auf einem Blatt, das in der Gruppe herumliegt, steht keine Diagnose. Sie folgt aus dem handlungsrelevanten Hinweis fuer den Hort (TASK-255): steht einer da, steht sie da. Fehlt sie, ist das keine Luecke — die Angaben sind freiwillig.
2. **Die Detailliste fuers Hortbuero** — dieselben Kinder mit dem Hinweis im Wortlaut. Als Sicht vorhanden, aber sie gehoert ausdruecklich nicht in die Gruppe.
3. **Die Klassen farbig unterschieden**, damit sich ein Kind schneller findet.

**Was nicht gebaut wird, und der Grund:** keine Oberflaeche, in der sich Spalten, Reihenfolge und Farben konfigurieren und speichern lassen (Betreiber, 04.09.2026, gegen die Alternative). Die Spaltenliste ist mit der Hortleitung abzustimmen, bevor die Liste steht (fragen.md); danach ist sie fest, und eine geaenderte Spalte ist ein kleiner Bau. Ein **Export der Rohdaten** ist das Ventil fuer alles, was allein das Layout betrifft.

**Ebenso wenig gebaut:** der Rueckweg der Anwesenheit. Was auf dem Blatt abgehakt wird, kommt nicht ins System — der laufende Hort-Alltag gehoert dem Hort (soll-prozesse/09-hortvertrag.md, "Gehoert nicht dazu"). Weltenbaum liefert die Liste, der Hort fuehrt den Tag.

**Und ausdruecklich nicht:** Weltenbaum erzeugt die Excel und der Hort pflegt sie weiter. Dann bliebe die Marke Handarbeit, die Datei laege dauerhaft ausserhalb mit Art.-9-Inhalt, und der Zweck der Domaene — eine Aenderung laeuft zuerst durch Weltenbaum — fiele.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Tagesliste ist druckfertig und wird je Tag frisch erzeugt, nicht gepflegt
- [ ] #2 Direkt hinter dem Namen steht eine Marke, wo ein Hinweis fuer den Hort vorliegt — das Zeichen, nie der Inhalt
- [ ] #3 Ohne Hinweis fuer den Hort traegt das Blatt keine Marke — als Gegenprobe
- [ ] #4 Die Detailliste mit dem Hinweis im Wortlaut ist eine eigene Sicht fuers Hortbuero
- [ ] #5 Die Klassen sind farbig unterschieden
- [ ] #6 Ein Export der Rohdaten steht daneben; eine Konfigurationsoberflaeche fuer Spalten und Farben entsteht nicht
- [ ] #7 Die Anwesenheit kommt nicht ins System zurueck
<!-- AC:END -->
