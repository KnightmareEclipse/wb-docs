---
id: TASK-176
title: Schema für die Akademie bauen
status: Done
assignee: []
created_date: '2026-09-01 19:09'
updated_date: '2026-09-03 21:30'
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

Zu bauen: die Kategorie als Werteliste, das Angebot samt Thema, Zeitraum, Zielgruppe, Häkchen für fremde Kinder, harter Platzzahl, Betrag, Anmeldefenster, Abmeldebedingungen und Absage, die Anmeldung je Kind samt Zahlweg und Abmeldung, dazu der Kostenübernahme-Code wie in ferien-schema.sql.

**Die Kategorie ist Pflicht am Angebot, ihre Werteliste zunächst leer** (Betreiber, 03.09.2026): Gebaut wird beides, nur welche Werte es geben soll, wird später festgelegt. Daraus folgt eine Reihenfolge, die man einmal gesehen haben muss — **das erste Angebot braucht die erste Kategorie**: Solange die Liste leer ist, lässt sich kein Kurs anlegen. Das ist kein Fehler, sondern die Wirkung der Pflichtangabe, und die Oberfläche sagt es statt eine leere Auswahl zu zeigen.

**Die Verantwortlichen des Angebots sind Personen, keine Rolle** (03.09.2026): eine oder mehrere, dynamisch gesetzt. An ihnen hängt, wer die Teilnehmerliste sieht, wer den Gesundheitsausschnitt bekommt und wer die Löschankündigung erhält (hebel.md). Eine Rolle träfe alle, die sie tragen — beim Kurs einer einzelnen Person ist das zu breit, und der Kreis ändert sich je Angebot.

Zwei Dinge sind ausdrücklich keine Struktur: eine Angebotsart (Einzeltermin/Reihe/Schuljahr ist der Zeitraum, sonst nichts) und eine Terminliste (angemeldet wird zum Angebot als Ganzem). Der Zuschnitt der Zielgruppe ist derselbe wie beim Einsatz des Elternbonus — benannte Klasse oder Schulart samt Stufenspanne; nachsehen, ob elternbonus-schema.sql ihn hergibt, statt eine zweite Bauform zu bauen.

Zahlung: Familie mit SEPA-Mandat wird eingezogen und erzeugt keine Zahlungszeile, Familie ohne Mandat ist der fünfte Q3-Anlass (grenzkarte.md).

Nach prompts/schema-bauen.md, danach schema-pruefen.md in einer frischen Session.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Angebot und Anmeldung stehen; es gibt keine Spalte für eine Angebotsart
- [x] #2 Die Verantwortlichen sind eine oder mehrere Personen am Angebot, dynamisch setzbar — keine Rolle
- [x] #3 Der Zielgruppen-Zuschnitt ist der aus dem Elternbonus, keine zweite Bauform
- [x] #4 Die Platzzahl ist hart — das Prüfskript weist die Anmeldung über die Platzzahl hinaus ab
- [x] #5 Die Anmeldung ohne SEPA-Mandat hängt als fünfte Vorgangs-Spalte an payments, die mit Mandat erzeugt keine Zahlung
- [x] #6 Ein Angebot, das fremde Kinder nicht zulässt, weist die Anmeldung eines fremden Kindes ab — mit Gegenprobe
- [x] #7 Der Kostenübernahme-Code folgt der Form aus ferien-schema.sql
- [x] #8 Das Angebot trägt die Option 'Mittagessen enthalten' mit der Bedeutung aus ferien-schema.sql
- [x] #9 Das Angebot trägt neben dem Betrag einen zweiten — allgemein gehalten als Zusatzbetrag samt Etikett (Betreiber, 03.09.2026), die Lebensmittel der Kochwerkstatt sind sein erster Fall
- [x] #10 Die Absagefrist steht je Angebot als Tageszahl UND Uhrzeit; die Konvention für die leere Uhrzeit steht als Spaltenkommentar
- [x] #11 Der Stornotext bleibt als Verweis auf contract_texts daneben
- [x] #12 Die Abmeldung folgt der Bauform aus holiday_bookings: zwei Schritte und ein einbehaltener Betrag
- [x] #13 Eltern sehen nie einen Abstand, sondern den ausgerechneten Termin
- [x] #14 Der Erwachsenen-Zweig ist zum Start dabei: die Anmeldung hängt an einer Person und nicht am Kind
- [x] #15 Die Löschfrist der Erwachsenen-Teilnehmer ist dieselbe wie die schulfremder Kinder: sechs Monate nach dem letzten gebuchten Termin
- [x] #16 Die Kategorie ist Pflicht am Angebot; die Werteliste steht und ist zunächst leer
<!-- AC:END -->
