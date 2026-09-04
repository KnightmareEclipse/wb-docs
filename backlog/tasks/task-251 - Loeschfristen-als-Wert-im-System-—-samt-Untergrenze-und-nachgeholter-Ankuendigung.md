---
id: TASK-251
title: >-
  Loeschfristen als Wert im System — samt Untergrenze und nachgeholter
  Ankuendigung
status: To Do
assignee: []
created_date: '2026-09-04 18:56'
labels:
  - dsgvo
  - querschnitt
  - wb-backend
milestone: m-1
dependencies: []
ordinal: 264000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Geschaeftsfuehrung, 04.09.2026: 'Generell soll es moeglich sein die Loeschfristen dynamisch anzupassen und sie sollen nicht fix im Code stehen.'

Das kehrt um, was soll-prozesse/anleitung.md bisher trug — eine Frist war eine feste Zahl. Fuer Vorlaufzeiten und Stichtage gilt der Satz weiter; fuer die Aufbewahrung nicht mehr.

**Der Mechanismus steht schon:** configured_values traegt code, valid_from und value. Zu bauen sind die Codes je Bestand und die eine Rechnung unten.

**Keine Untergrenze, und kein Anfangswert** (04.09.2026, zweite Runde): 'Wir akzeptieren das Risiko mit zu geringen Werten in der DB.' Auch die zehn Jahre der Belege sind ein Wert wie jeder andere, aenderbar durch die **Buchhaltung** — sie fuehrt den Bestand und kennt die Pflicht, nicht dieses System. Weltenbaum setzt den finalen Wert gar nicht: Eine Frist, die niemand eingetragen hat, steht leer, und **ein Anker ohne Ziel loescht nichts** (Block 17, bereits geltende Regel). Das ist der sichere Ausfall — wer nichts eintraegt, verliert nichts. Eine Null waere das Gegenteil, deshalb ist die fehlende Zeile die richtige Form und nicht value = 0.

**Die gesenkte Frist ist geloest, und zwar ohne Mechanismus:**

> Loeschtermin = **spaeter von beidem** — Anker plus Frist, oder Eintragung des Wertes plus 14 Tage.

Damit fallen die beiden Loeschankuendigungen von selbst in das Fenster, das eine Senkung oeffnet. Es gibt nichts nachzuholen, nichts zu merken und keine zweite Zustandshaltung — eine Zeile in der Berechnung statt einer Tabelle 'wann wurde angekuendigt'. Gerechnet wird ab `created_at` der Wertzeile und **nicht** ab `valid_from`: Eine Gueltigkeit laesst sich rueckdatieren, der Zeitpunkt der Eingabe nicht. Wer eine Frist verlaengert, merkt von der Regel nichts — dann ist Anker plus Frist ohnehin spaeter.

Derselbe Satz traegt nebenbei den Erstbezug: Wird ein Wert zum ersten Mal gesetzt, wird nichts sofort faellig.

**Was daran nicht neu ist:** Die Aenderungsspur traegt den Vorgang wie bei jedem anderen Wert im System.

**Ein Sonderfall, und er bleibt einer: die Rechnungsfreigabe.** Ihre zehn Jahre stehen als Wert, aber der Lauf **liest ihn nicht** — er spart die Belege aus, weil eine Aufbewahrungspflicht darauf liegt und die Freigabe eines Jahrgangs eine menschliche Handlung bleibt (Block 12). Der Wert ist dort ein **Merkposten fuer die Handfreigabe**, gepflegt von der Buchhaltung: Er sagt, ab wann freigegeben werden darf, und laesst sich heraufsetzen, wenn etwas laenger liegen soll. Bei jedem anderen Bestand ist die Frist der Ausloeser — wer diese Bauform anderswo hintraegt, baut eine Frist, die nie etwas tut.

**Nicht mit hinein gehoert der Nachweis der Fotoerlaubnis** (TASK-244): Er hat keine Frist, und eine Zeile in dieser Tabelle waere eine, die jemand versehentlich fuellen kann.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Je Bestand ein Code in configured_values — **ohne** Anfangsbestand: Was niemand eintraegt, bleibt leer
- [ ] #2 Eine fehlende Frist loescht nichts — die Gegenprobe: der Lauf laesst einen Bestand ohne Wert stehen, statt ihn sofort zu raeumen
- [ ] #3 Der Loeschtermin ist nie frueher als created_at des Wertes plus 14 Tage; die Gegenprobe: nach einer Senkung wird am naechsten Morgen nichts geraeumt
- [ ] #4 Eine Aenderung wirkt ab valid_from und nie rueckwirkend
- [ ] #5 hebel.md, Block 17 und das Verarbeitungsverzeichnis sagen dasselbe
- [ ] #6 Die Buchhaltung darf die Frist der Belege aendern, die Geschaeftsfuehrung die uebrigen
- [ ] #7 Die Frist der Belege loest nichts aus; die Gegenprobe: der Lauf raeumt sie auch dann nicht, wenn ihr Wert abgelaufen ist
<!-- AC:END -->
