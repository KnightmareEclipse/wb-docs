---
id: TASK-176
title: Schema für die Akademie bauen
status: To Do
assignee: []
created_date: '2026-09-01 19:09'
updated_date: '2026-09-03 14:51'
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

Zwei Dinge sind ausdrücklich keine Struktur: eine Angebotsart (Einzeltermin/Reihe/Schuljahr ist der Zeitraum, sonst nichts) und eine Terminliste (angemeldet wird zum Angebot als Ganzem). Der Zuschnitt der Zielgruppe ist derselbe wie beim Einsatz des Elternbonus — benannte Klasse oder Schulart samt Stufenspanne; nachsehen, ob elternbonus-schema.sql ihn hergibt, statt eine zweite Bauform zu bauen.

Zahlung: Familie mit SEPA-Mandat wird eingezogen und erzeugt keine Zahlungszeile, Familie ohne Mandat ist der fünfte Q3-Anlass (grenzkarte.md).

Nach prompts/schema-bauen.md, danach schema-pruefen.md in einer frischen Session.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Kategorie, Angebot und Anmeldung stehen; es gibt keine Spalte für eine Angebotsart
- [ ] #2 Der Zielgruppen-Zuschnitt ist der aus dem Elternbonus, keine zweite Bauform
- [ ] #3 Die Platzzahl ist hart — das Prüfskript weist die Anmeldung über die Platzzahl hinaus ab
- [ ] #4 Die Anmeldung ohne SEPA-Mandat hängt als fünfte Vorgangs-Spalte an payments, die mit Mandat erzeugt keine Zahlung
- [ ] #5 Ein Angebot, das fremde Kinder nicht zulässt, weist die Anmeldung eines fremden Kindes ab — mit Gegenprobe
- [ ] #6 Der Kostenübernahme-Code folgt der Form aus ferien-schema.sql
- [ ] #7 Das Angebot trägt die Option 'Mittagessen enthalten' mit der Bedeutung aus ferien-schema.sql: im Preis enthalten und das Kind an dem Tag auf der Mensaliste
- [ ] #8 Das Angebot trägt neben dem Betrag einen zweiten, den die Hauswirtschaftsleitung je Angebot setzt (Lebensmittel) — aus TASK-177 übernommen, nicht neu erfunden
- [ ] #9 Die Absagefrist steht je Angebot als Tageszahl UND Uhrzeit statt je Kategorie: 'bis 3 Tage vorher' ist (3, leer), 'bis 9 Uhr am Kurstag' ist (0, 09:00); die Konvention für die leere Uhrzeit steht als Spaltenkommentar
- [ ] #10 Der Stornotext bleibt als Verweis auf contract_texts daneben — die Zahl sperrt, der Text erklärt, was ein Storno kostet
- [ ] #11 Die Abmeldung folgt der Bauform aus holiday_bookings: zwei Schritte und ein einbehaltener Betrag, den die anbietende Stelle einträgt
- [ ] #12 Eltern sehen nie einen Abstand, sondern den ausgerechneten Termin — 144 Stunden rechnet niemand im Kopf
- [ ] #13 Der Erwachsenen-Zweig ist zum Start dabei (03.09.2026): die Anmeldung hängt an einer Person und nicht am Kind, und der Zweig trägt seine eigene Löschfrist
- [ ] #14 Das Angebot trägt seine Verantwortlichen: eine Person, mehrere Personen oder eine ganze Rollengruppe — und für die Löschankündigung mindestens zwei Empfänger (hebel.md)
- [ ] #15 Die Löschfrist der Erwachsenen-Teilnehmer ist dieselbe wie die schulfremder Kinder: sechs Monate nach dem letzten gebuchten Termin (03.09.2026)
<!-- AC:END -->
