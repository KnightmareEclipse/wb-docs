---
id: TASK-214
title: Notfallbetreuung als buchbarer Vorgang
status: To Do
assignee: []
created_date: '2026-09-03 16:38'
updated_date: '2026-09-03 16:57'
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

**Zwei Zeitpunkte statt eines Häkchens**, wie überall dort, wo eine Zusage und ihr Vollzug auseinanderfallen können: Die Buchung ist die Ankündigung, das Abhaken durch den Hort der Beleg. Abgerechnet wird, was stattgefunden hat — sonst zahlt eine Familie für einen Notfall, der sich erledigt hat, und ein unangekündigtes Kind fiele durchs Raster. Genau das ist auch der Papierfall: Wer unangekündigt kommt, hat keine Buchung, nur den Vollzug.

Berührt die Mensa: Wer über Mittag da ist, isst, und das Tagesessen kostet 5,90 € je Fall (11). Es hängt an dem Tag, an dem es anfällt, und wird nicht im Fallpreis versteckt.

**Der Nachtrag braucht einen Beleg, die Portalbuchung nicht.** Wer im Portal klickt, hat selbst gebucht — `created_by` trägt `guardian:`. Wer anruft, hat nichts Schriftliches, und dann steht Aussage gegen Aussage, sobald eine Familie sagt, ihr Kind sei an dem Tag nicht da gewesen. Dagegen die billigste Stufe, die trägt: **Jede nachgetragene Betreuung erzeugt eine Bestätigungsmail** an die Familie — Tag, Art des Falls, Betrag. `outbound_emails` hält fest, dass sie hinausging, an welche Adresse und ob sie zustellbar war; wer nicht widerspricht, hat es hingenommen. Das deckt zugleich das unangekündigte Kind ab, für das es nie eine Buchung gab.

Die härtere Stufe wäre die **gezeichnete Tagesliste** — die Bauform steht beim Putzdienst schon (Liste erzeugen, abzeichnen, als Vorgang abschließen). Sie kostet Papier und einen Handgriff je Tag und lohnt erst, wenn der Streitfall wirklich vorkommt. Eine **Unterschrift im Portal** wäre die Bauform des Schulvertrags und für einen Zwanzig-Euro-Vorgang unverhältnismäßig — bewusst nicht.

`[?]` **Drei Punkte für die Hortleitung**, beide in einem Satz zu beantworten und deshalb nicht in fragen.md: Gibt es eine Platzgrenze, kann eine Portalbuchung also abgelehnt werden? Wird eine gebuchte, aber nicht wahrgenommene Betreuung berechnet? Und reicht die Bestätigungsmail als Beleg, oder soll die Tagesliste gezeichnet werden?

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
- [ ] #7 Jeder Nachtrag erzeugt eine Bestätigungsmail an die Familie; die Portalbuchung braucht keine
- [ ] #8 Die Mail steht in outbound_emails samt Zustellstatus — sie ist der Beleg, nicht die Buchung selbst
<!-- AC:END -->
