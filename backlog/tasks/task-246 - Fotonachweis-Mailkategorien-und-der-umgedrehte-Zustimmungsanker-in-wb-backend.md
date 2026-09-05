---
id: TASK-246
title: 'Fotonachweis, Mailkategorien und der umgedrehte Zustimmungsanker in wb-backend'
status: To Do
assignee: []
created_date: '2026-09-04 16:49'
labels:
  - schema
  - dsgvo
  - wb-backend
dependencies: []
ordinal: 259000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Doku ist nachgezogen (schema/querschnitt-schema.sql samt Pruefskript, 00, 04, 08, 17, grenzkarte.md, verarbeitungsverzeichnis.md); wb-backend fuehrt das Schema und hat nichts davon.

Drei Strukturaenderungen in einer Revision — solange nichts produktiv laeuft, wird die Ursprungsrevision ueberschrieben und die Datenbank neu aufgesetzt (CLAUDE.md):

1. **mail_categories** als Werteliste, consent_purposes.is_newsletter_topic faellt weg und wird mail_category_id + mitgefuehrtes is_unsubscribable; outbound_emails zieht mit.
2. **fk_consents_person** von ON DELETE CASCADE auf NO ACTION. Ab da raeumt der Lauf jede kindlose Zustimmung selbst und laesst genau die stehen, die abbestellbar und nicht widerrufen ist.
3. **photo_consent_records** neu, dazu die vierte SharePoint-Bibliothek.
4. **alumni_kinds und alumni** neu (stammdaten-schema.sql) — die Zugehoerigkeit der Ehemaligen neben der Person, je Person und Art eine Zeile. alumni haelt seine Person fest wie die Einwilligung und wird in Stufe 6 vor ihr geraeumt.

**Anfangsbestaende, die zu setzen sind** (Wertelisten leben in der Migration, nicht in der .sql hier):
- mail_categories: transactional, school_info (mit requires_family_recipient), newsletter.
- consent_purposes: drei Themen fuer die Ehemaligen — Kind, Elternteil, Mitarbeitende —, alle auf newsletter.
- alumni_kinds: former_pupil (mit Jahrgang), former_guardian (ohne), former_employee (mit).

Die Untergrenze je Familie bei der Schulinformation spannt ueber zwei Personenzeilen und kann kein CHECK sein — **sie steht seit dem Trigger `trg_consents_family_floor` in der Datenbank** (schema/querschnitt-schema.sql) und nicht mehr in der Schreibschicht. Der frueher hier stehende Nebensatz "Trigger sind ausgeschlossen" trug nicht: Er gilt der Aenderungsspur (ACHTUNG-Block im Kopf derselben Datei), und fuenf Domaenen fuehren laengst Zulassungs-Trigger. Fuer wb-backend bleibt damit **die Uebersetzung**: Die Route faengt den Fehler und macht eine Meldung daraus, statt die Regel ein zweites Mal zu fuehren.

Was der Trigger nicht sieht, weil dabei niemand `consents` anfasst: das Ausscheiden des zweiten Sorgeberechtigten. Ein Trigger auf `family_guardians` waere der falsche Ort — er muesste eine Einwilligung von Maschinenhand zuruecknehmen und feuerte auch fuer die Cascade des Loesch-Laufs. Das Wiedereinschalten bleibt deshalb Arbeit des Laufs (#5); das Pruefskript haelt die Luecke als benannte Auslassung fest.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 mail_categories steht, drei Zeilen als Anfangsbestand, ein viertes Thema ist eine Zeile
- [ ] #2 fk_consents_person haelt fest; die Gegenprobe: eine Person mit offener Newsletter-Zeile laesst sich nicht loeschen
- [ ] #3 photo_consent_records steht samt vierter Bibliothek; die Gegenprobe: Kind und Person gehen, der Nachweis bleibt
- [ ] #4 Die Route uebersetzt den Fehler von `trg_consents_family_floor` in eine Meldung, die sagt, wer die Schulinformation behalten muss — Test erst rot, dann gruen
- [ ] #5 Scheidet ein Sorgeberechtigter aus, ist der Verbliebene wieder eingeschaltet
- [ ] #6 alumni steht; die Gegenprobe: dieselbe Person als ehemaliges Kind und als ehemalige Mitarbeitende geht, zweimal dieselbe Art nicht
- [ ] #7 Der Juni-Lauf legt Einwilligung und Zugehoerigkeit zusammen an; ohne Zustimmung entsteht keine Zeile
- [ ] #8 Die drei Wertelisten tragen ihren Anfangsbestand
<!-- AC:END -->
