---
id: TASK-250
title: Serienbrief aus dem Portal — Platzhalter aus Livedaten statt Schatten-Excel
status: To Do
assignee: []
created_date: '2026-09-04 18:40'
labels:
  - mail
  - dokumente
  - querschnitt
milestone: m-5
dependencies: []
priority: low
ordinal: 263000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Geschaeftsfuehrung, 04.09.2026: 'Es soll moeglich sein, Serienbriefe ueber das Portal zu erstellen und dann so Platzhalter zu verwenden wie es bei Vertraegen gemacht wird, dass direkt die Livedaten genommen werden koennen, ohne selber eine Excel im Hintergrund schattenpflegen zu muessen. Wichtig ist natuerlich, dass so Serienbriefe immer nur an einen bestimmten Verteiler gehen sollen.'

**Das Teure steht schon.** Die Platzhalter-Mechanik ist gebaut: Word mit Klartext-Platzhaltern, gefuellt per docxtpl (dokumente.md). Ein Serienbrief ist ein zweiter Verbraucher derselben Sache, kein neues Bauteil — und die Klartext-Form ist ohnehin gerade Thema (TASK-226).

**Drei Dinge sind zu klaeren, und das zweite ist der Haken:**

1. **Was hinten herauskommt.** Eine Mail mit personalisiertem Text, oder je Empfaenger ein erzeugtes Dokument zum Ausdrucken? Der Wortlaut sagt 'Serienbrief', der Empfaengerkreis sagt 'Verteiler' — beides ist plausibel, und die Mechanik traegt beides. Zu entscheiden, bevor gebaut wird.
2. **Ein Verteiler hat Adressen, Platzhalter brauchen Personen.** Steht der Verteiler in Exchange und traegt jemand dort von Hand eine Adresse nach, hat Weltenbaum zu diesem Empfaenger keine Daten — seine Platzhalter blieben leer. Der Serienbrief kann deshalb nur an einen Kreis gehen, dessen Mitglieder Weltenbaum selbst kennt. Das ist dieselbe Bedingung wie in TASK-248 ('Weltenbaum ist alleinige Quelle') und faellt mit ihr.
3. **Genau ein Verteiler je Sendung**, ausdruecklich. Kein Mischen zweier Kreise, keine Ad-hoc-Auswahl von Empfaengern: Der Empfaengerkreis wird beim Senden aufgeloest und dann festgeschrieben (TASK-208) — eine Sendung, die ihre Empfaenger spaeter neu berechnet, zeigt im naechsten Jahr eine andere Liste als die, die sie hatte.

**Was das an TASK-208 aendert:** Dort stand 'Ein Newsletter wird jedes Mal neu geschrieben — dafuer braucht es ein Textfeld, keine Vorlage'. Der Satz ist ueberholt und dort als solcher gekennzeichnet. Ein Textfeld bleibt es; was dazukommt, ist das Fuellen der Platzhalter, nicht ein Editor.

**Nicht gebaut wird**, was TASK-208 schon ausschliesst: kein Layout-System, kein Vorlagen-Editor mit Formatierung und Vorschau, kein Oeffnungstracking. Die Platzhalter werden getippt wie der Text daneben.

**Welche Platzhalter es gibt, ist die eigentliche Arbeit** und faellt nicht vom Himmel: Eine Vertragsvorlage kennt ein Kind und eine Familie, ein Serienbrief an Ehemalige kennt weder das eine noch das andere. Je Empfaengerkreis ist deshalb zu benennen, welche Felder ueberhaupt zur Verfuegung stehen — sonst steht im Brief ein Platzhalter, den niemand fuellen kann.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob eine Sendung Mails oder Dokumente erzeugt
- [ ] #2 Je Empfaengerkreis steht die Liste der verfuegbaren Platzhalter; ein Platzhalter ausserhalb der Liste wird beim Speichern abgewiesen, nicht erst beim Senden
- [ ] #3 Eine Sendung haengt an genau einem Kreis — die Gegenprobe: zwei Kreise in einer Sendung kommen nicht durch
- [ ] #4 Der Empfaengerkreis wird beim Senden aufgeloest und festgeschrieben, nicht als Abfrage gespeichert
- [ ] #5 Ein Empfaenger ohne Personenbezug bekommt keine Sendung mit Platzhaltern — er faellt auf, statt einen leeren Brief zu bekommen
<!-- AC:END -->
