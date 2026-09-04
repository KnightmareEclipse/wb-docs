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

Dazu die Schreibschicht: Die Untergrenze je Familie bei der Schulinformation spannt ueber zwei Personenzeilen und kann kein CHECK sein (Trigger sind ausgeschlossen). Sie lebt in der Schreibschicht, und die Gegenprobe ist, dass die Route die Abwahl des Letzten abweist. Zwei Folgen: ein alleiniger Sorgeberechtigter kann nicht abwaehlen, und scheidet der zweite aus, wird der Verbliebene wieder eingeschaltet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 mail_categories steht, drei Zeilen als Anfangsbestand, ein viertes Thema ist eine Zeile
- [ ] #2 fk_consents_person haelt fest; die Gegenprobe: eine Person mit offener Newsletter-Zeile laesst sich nicht loeschen
- [ ] #3 photo_consent_records steht samt vierter Bibliothek; die Gegenprobe: Kind und Person gehen, der Nachweis bleibt
- [ ] #4 Die Route weist die Abwahl der letzten Schulinformation einer Familie ab — Test erst rot, dann gruen
- [ ] #5 Scheidet ein Sorgeberechtigter aus, ist der Verbliebene wieder eingeschaltet
- [ ] #6 alumni steht; die Gegenprobe: dieselbe Person als ehemaliges Kind und als ehemalige Mitarbeitende geht, zweimal dieselbe Art nicht
- [ ] #7 Der Juni-Lauf legt Einwilligung und Zugehoerigkeit zusammen an; ohne Zustimmung entsteht keine Zeile
- [ ] #8 Die drei Wertelisten tragen ihren Anfangsbestand
<!-- AC:END -->
