---
id: TASK-214
title: Notfallbetreuung als buchbarer Vorgang
status: To Do
assignee: []
created_date: '2026-09-03 16:38'
updated_date: '2026-09-03 17:00'
labels:
  - schema
  - anmeldung
dependencies: []
references:
  - schema/anmeldung-schema.sql
  - soll-prozesse/09-hortvertrag.md
  - schema/mensa-schema.sql
ordinal: 227000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus [M3], geschärft am 03.09.2026: Eine Notfallbetreuung entsteht aus einem Notfall — spontan, für einen einzelnen Tag, abgerechnet **je Fall**. Eltern sollen sie im Portal buchen können, **Hortkinder wie Nicht-Hortkinder**, und der Hort sieht sie. Wer stattdessen anruft, ist damit nicht draußen: Der Hort trägt sie nach.

**Ein Vorgang mit zwei Eingängen, nicht zwei Vorgänge.** Das ist der [offizielle Umweg](../../soll-prozesse/hebel.md#der-offizielle-umweg) — mit einer benannten Abweichung: Stellvertretend trägt hier nicht das Sekretariat ein, sondern der Hort, weil er den Anruf entgegennimmt. Danach läuft alles gleich weiter. **Ein Feld für den Weg braucht es nicht:** `created_by` trägt schon `guardian:` oder `entra:`, und daran ist ablesbar, ob die Buchung aus dem Portal kam oder nachgetragen wurde.

**Sie passt nicht in die Betreuungsmodule, und das ist der Kern.** `care_module_prices` kennt einen Monatsbeitrag je Zahl der gebuchten Wochentage, gebunden an eine Modulanlage zum Betreuungsvertrag. Die Notfallbetreuung wird je Fall berechnet ("20 € pro Fall" für den Nachmittag bis 17 Uhr, "8 € pro Fall" für eine Stunde innerhalb der Öffnungszeiten) und steht Kindern offen, die gar keinen Betreuungsvertrag haben. Ein weiteres `care_module` wäre die falsche Bauform: Es hinge an einer Vereinbarung, die es bei diesen Kindern nicht gibt.

Gebraucht wird eine **Tagesbuchung**: Kind, Datum, Art des Falls, der Betrag als das, was an diesem Tag galt.

**Zwei Zeitpunkte statt eines Häkchens**, wie überall dort, wo eine Zusage und ihr Vollzug auseinanderfallen können: Die Buchung ist die Ankündigung, das Abhaken durch den Hort der Vollzug. Abgerechnet wird, was stattgefunden hat — sonst zahlt eine Familie für einen Notfall, der sich erledigt hat, und ein unangekündigtes Kind fiele durchs Raster. Genau das ist auch der Papierfall: Wer unangekündigt kommt, hat keine Buchung, nur den Vollzug.

Der Hort sieht die Buchungen des Tages als [frisch erzeugte Liste](../../soll-prozesse/hebel.md#frisch-erzeugte-liste), nicht als gepflegten Bestand.

Berührt die Mensa: Wer über Mittag da ist, isst, und das Tagesessen kostet 5,90 € je Fall (11). Es hängt an dem Tag, an dem es anfällt, und wird nicht im Fallpreis versteckt.

`[?]` **Der Nachweis auf dem Telefonweg ist offen.** Wer im Portal klickt, hat selbst gebucht — `created_by` trägt `guardian:`, und mehr braucht es nicht. Wer anruft, hat nichts Schriftliches: Weigert sich eine Familie später zu zahlen, weil ihr Kind an dem Tag angeblich nicht da war, steht Aussage gegen Aussage. Drei Stufen wären denkbar, entschieden ist keine — eine Bestätigung an die Familie, eine gezeichnete Tagesliste nach der Bauform des Putzdienstes (01), oder gar nichts, weil der Fall in der Praxis nicht vorkommt. **Vor dem Bau mit der Geschäftsführung zu klären**, zusammen mit der Frage, ob eine Notfallbetreuung überhaupt abgelehnt werden darf und ob eine gebuchte, aber nicht wahrgenommene berechnet wird.

**Hängt an fragen.md Frage 10:** Welche Werte der Preisliste unsere sind, ist nicht eindeutig lesbar — die Spalte mit 8/8/12/16/20 ist anderswo mit "Stadt*" überschrieben. Vor dem Seed zu klären, nicht vor dem Bau.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Notfallbetreuung ist eine Tagesbuchung mit Preis je Fall, kein weiteres Betreuungsmodul
- [ ] #2 Ein Kind ohne Betreuungsvertrag kann gebucht werden — als Gegenprobe
- [ ] #3 Beide Eingänge schreiben dieselbe Zeile; der Weg ist an created_by ablesbar und braucht kein Feld
- [ ] #4 Buchung und Vollzug sind zwei Zeitpunkte: ein unangekündigtes Kind hat nur den zweiten, eine erledigte Buchung nur den ersten
- [ ] #5 Der Hort sieht die Buchungen des Tages als frisch erzeugte Liste
- [ ] #6 Das Mittagessen hängt an dem Tag, an dem es anfällt, und steckt nicht im Fallpreis
- [ ] #7 Entschieden mit der Geschäftsführung: Nachweis auf dem Telefonweg, Ablehnung einer Buchung, Berechnung einer nicht wahrgenommenen
<!-- AC:END -->
