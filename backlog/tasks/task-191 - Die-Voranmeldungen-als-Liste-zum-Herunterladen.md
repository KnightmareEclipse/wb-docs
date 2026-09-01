---
id: TASK-191
title: Die Voranmeldungen als Liste zum Herunterladen
status: To Do
assignee: []
created_date: '2026-09-01 21:30'
labels:
  - wb-backend
  - anmeldung
  - schulleitung
milestone: m-5
dependencies: []
ordinal: 204000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Entscheidungsrunde bleibt in Excel und bei der Schulleitung (TASK-128). Damit sie dort arbeiten kann, muss die Grundlage aus Weltenbaum kommen: eine Liste der Voranmeldungen eines Aufnahmejahrgangs, die sie herunterlädt und in Excel öffnet. Heute tippt oder kopiert sie zusammen, was auf den Formularen steht.

Eine [frisch erzeugte Liste](../../soll-prozesse/hebel.md) wie die des Jahreswechsels, kein zweiter Bestand — sie entsteht beim Abruf und wird nicht gespeichert. Wer sie zieht, ist ein Export im Sinne von zugang.md: Rolle Schulleitung, im zentralen Logging erfasst.

Zwei Dinge entscheiden sich beim Bauen. Welche Spalten sie trägt — sie ist die Arbeitsgrundlage einer Auswahlentscheidung, also mehr als Name und Klasse, aber nicht der ganze Bewerbungsbestand. Und das Format: Eine CSV-Datei öffnet Excel nur dann ohne Zerlegen der Umlaute und Datumsspalten, wenn sie Semikolon und BOM trägt; sonst ist es eine echte .xlsx.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Spalten sind benannt und begründet — Arbeitsgrundlage, nicht Vollauszug
- [ ] #2 Die Datei öffnet sich in einem deutschen Excel ohne Nacharbeit an Umlauten und Datum
- [ ] #3 Der Abruf steht im zentralen Logging und hängt an der Rolle Schulleitung
<!-- AC:END -->
