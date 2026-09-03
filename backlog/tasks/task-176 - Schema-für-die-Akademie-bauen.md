---
id: TASK-176
title: Schema für die Akademie bauen
status: To Do
assignee: []
created_date: '2026-09-01 19:09'
updated_date: '2026-09-03 17:56'
labels:
  - schema
  - akademie
  - wb-docs
dependencies: []
references:
  - soll-prozesse/21-akademie.md
  - grenzkarte.md
  - prompts/schema-bauen.md
ordinal: 188000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus Block 21. Neue Domäne für Domäne 6, zweiter Teil — sie ersetzt das gelöschte schema/ags-schema.sql, dessen Begründung ("nichts bekannt, nichts zu bauen") mit dem Gespräch vom 01.09.2026 hinfällig ist.

Zu bauen: das Angebot samt Thema, Zeitraum, Zielgruppe, Häkchen für fremde Kinder, harter Platzzahl, Betrag, Anmeldefenster, Abmeldebedingungen und Absage, die Anmeldung je Kind samt Zahlweg und Abmeldung, dazu der Kostenübernahme-Code wie in ferien-schema.sql.

**Ohne Kategorien zum Start** (Betreiber, 03.09.2026): Welche es geben soll, wird erst später festgelegt — also entsteht die Werteliste jetzt nicht. Ein Angebot ohne Kategorie muss deshalb gültig sein, und wenn die Liste kommt, ist sie eine Tabelle daneben und eine nullable Spalte am Angebot, kein Umbau.

**Die Verantwortlichen des Angebots sind Personen, keine Rolle** (03.09.2026): eine oder mehrere, dynamisch gesetzt. An ihnen hängt, wer die Teilnehmerliste sieht, wer den Gesundheitsausschnitt bekommt und wer die Löschankündigung erhält (hebel.md). Eine Rolle träfe alle, die sie tragen — beim Kurs einer einzelnen Person ist das zu breit, und der Kreis ändert sich je Angebot.

Zwei Dinge sind ausdrücklich keine Struktur: eine Angebotsart (Einzeltermin/Reihe/Schuljahr ist der Zeitraum, sonst nichts) und eine Terminliste (angemeldet wird zum Angebot als Ganzem). Der Zuschnitt der Zielgruppe ist derselbe wie beim Einsatz des Elternbonus — benannte Klasse oder Schulart samt Stufenspanne; nachsehen, ob elternbonus-schema.sql ihn hergibt, statt eine zweite Bauform zu bauen.

Zahlung: Familie mit SEPA-Mandat wird eingezogen und erzeugt keine Zahlungszeile, Familie ohne Mandat ist der fünfte Q3-Anlass (grenzkarte.md).

Nach prompts/schema-bauen.md, danach schema-pruefen.md in einer frischen Session.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Angebot und Anmeldung stehen; es gibt keine Spalte für eine Angebotsart
- [ ] #2 Ein Angebot ohne Kategorie ist gültig — die Werteliste entsteht erst, wenn die Kategorien benannt sind
- [ ] #3 Die Verantwortlichen sind eine oder mehrere Personen am Angebot, dynamisch setzbar — keine Rolle
- [ ] #4 Der Zielgruppen-Zuschnitt ist der aus dem Elternbonus, keine zweite Bauform
- [ ] #5 Die Platzzahl ist hart — das Prüfskript weist die Anmeldung über die Platzzahl hinaus ab
- [ ] #6 Die Anmeldung ohne SEPA-Mandat hängt als fünfte Vorgangs-Spalte an payments, die mit Mandat erzeugt keine Zahlung
- [ ] #7 Ein Angebot, das fremde Kinder nicht zulässt, weist die Anmeldung eines fremden Kindes ab — mit Gegenprobe
- [ ] #8 Der Kostenübernahme-Code folgt der Form aus ferien-schema.sql
- [ ] #9 Das Angebot trägt die Option 'Mittagessen enthalten' mit der Bedeutung aus ferien-schema.sql
- [ ] #10 Das Angebot trägt neben dem Betrag einen zweiten, den die Hauswirtschaftsleitung setzt (Lebensmittel)
- [ ] #11 Die Absagefrist steht je Angebot als Tageszahl UND Uhrzeit; die Konvention für die leere Uhrzeit steht als Spaltenkommentar
- [ ] #12 Der Stornotext bleibt als Verweis auf contract_texts daneben
- [ ] #13 Die Abmeldung folgt der Bauform aus holiday_bookings: zwei Schritte und ein einbehaltener Betrag
- [ ] #14 Eltern sehen nie einen Abstand, sondern den ausgerechneten Termin
- [ ] #15 Der Erwachsenen-Zweig ist zum Start dabei: die Anmeldung hängt an einer Person und nicht am Kind
- [ ] #16 Die Löschfrist der Erwachsenen-Teilnehmer ist dieselbe wie die schulfremder Kinder: sechs Monate nach dem letzten gebuchten Termin
<!-- AC:END -->
