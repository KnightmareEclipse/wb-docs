---
id: TASK-214
title: Notfallbetreuung als buchbarer Vorgang
status: In Progress
assignee: []
created_date: '2026-09-03 16:38'
updated_date: '2026-09-04 19:40'
labels:
  - schema
  - anmeldung
milestone: m-5
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

**Beantwortet am 04.09.2026 (Geschaeftsfuehrung), und anders als die drei vorgeschlagenen Stufen:** Der Nachweis am Telefonweg ist die **Sichtbarkeit im Portal**. Die Familie sieht den Eintrag, sobald er steht, und meldet sich, "bevor es auf einer Rechnung landet" — keine Unterschrift, keine gezeichnete Tagesliste. Korrigiert wird ueber den Hort; das Fenster ist der Monat bis zur Abrechnung.

**Vier Regeln kommen dazu:** ein **Buchungsschluss je Fall-Art** — die Fruehbetreuung endet frueher als der Nachmittag desselben Tages —, nach dem das Portal auf den Anruf verweist statt die Schaltflaeche zu entfernen; eine **Mail ins Hortpostfach** je Buchung, damit die Betreuung es weiss; die **Sichtbarkeit** oben; und die **Abrechnung ueber die Hortrechnung** — Sammelaufstellung zum Monatsende an die Buchhaltung fuer den naechsten Zahlungslauf, kein Einzug je Fall.

**Die Uhrzeiten sind keine Beispiele, sondern die Werte** (Geschaeftsfuehrung, 04.09.2026): Sie hat den Hort das letzte halbe Jahr interimsweise gefuehrt, und die Zahlen stammen aus dieser Zeit. Eine fruehere Runde hatte sie als Beispiele gelesen und die Antwort bei der Hortleitung erwartet — das ist damit ueberholt.

| Fall-Art | Buchungsschluss im Portal |
|---|---|
| Fruehbetreuung | 6:45 Uhr |
| Nachmittag desselben Tages (Module 1 bis 4) | 11:15 Uhr |
| Halbe Stunde ausserhalb der Oeffnungszeiten | 11:15 Uhr |

Gebaut als `emergency_care_types.booking_cutoff_time`, Pflichtwert je Fall-Art: eine **Uhrzeit am Betreuungstag**, keine Vorlauf-Spanne — eine Spanne muesste erst wissen, wann der Fall beginnt, und das steht am Modul. **Keine Gueltigkeitsstaffel wie an den Preisen:** Eine Aenderung wirkt ab der naechsten Buchung, rueckwirkend gibt es nichts einzufrieren, und "es muss noch anpassbar sein fuer die Zukunft" heisst genau das — ein Wert, den die Geschaeftsfuehrung aendert, kein Bau.

**KITA-Kinder sind ausdruecklich draussen** (ebenda): Sie gelten nicht als bekannt und bekommen keine Notfallbetreuung. Zu bauen ist dafuer nichts — sie stehen in keiner Zeile dieser Datenbank, die KITA kommt allein als Betrieb und als Mitarbeiterrolle vor.

**Beide letzten Fragen sind am 04.09.2026 beantwortet (Geschaeftsfuehrung):** Ablehnen duerfte der Hort, "es gab bisher noch nie einen Grund das zu tun" — ein Nein bleibt also kein Eintrag. Und eine gebuchte, aber nicht wahrgenommene wird **nicht** berechnet: "sofern das Kind nie da war, wird nichts berechnet", denn der Betrag laeuft ueber die monatliche Hortrechnung und entsteht nie als eigene Forderung. `attended_at` bleibt damit allein massgeblich fuer die Abrechnung.

**Dazu ein Storno und eine engere Grenze, beide vom 04.09.2026:**

**Storno** ist kostenlos und traegt dieselbe Frist wie die Buchung: bis zum Buchungsschluss im Portal, danach telefonisch ueber den Hort. **Die Mail an den Hort ist die Folge und nicht der Weg** — der Storno wird im Portal erklaert und loest von dort dieselbe Mail ins Hortpostfach aus wie die Buchung. Das ist auch der Grund fuer die Frist: Bis dahin sitzt im Hort noch jemand am Rechner, danach steht die Betreuung in der Gruppe, und dann kommt nur noch das Telefon an. Ein eigener Zustand entsteht daraus nicht: Ohne Betrag gibt es nichts festzuhalten, der Storno loescht die Zeile — anders als bei der Ferienbuchung, wo der Einbehalt die stornierte Zeile braucht.

**Der Kreis ist enger als bisher angenommen:** "Das Kind muss uns bekannt sein" — eingeschrieben oder externes Kind mit laufendem Betreuungsvertrag, sonst niemand. Der Grund ist nicht das Geld, sondern der Bestand dahinter: Gesundheitsangaben, Notfallnummer und Abholberechtigte entstehen erst mit einem Vertrag, und sie fuer einen einzelnen Tag zu erheben waere "fuer eine Notfallbetreuung zu viel". In `children` zu stehen genuegt damit nicht — eine Ferienbuchung oder eine Akademie-Anmeldung legt eine solche Zeile ebenfalls an. Gebaut als `enforce_emergency_care_booking` mit demselben Praedikat wie `enforce_holiday_booking` (ferien-schema.sql), aber fuer **beide** Eingaenge: Der offizielle Umweg traegt den Weg und nicht den Kreis.

**Damit faellt die Mandatsfrage weg:** Wer bucht, ist eingeschrieben oder hat einen Betreuungsvertrag, und beide bringen das SEPA-Mandat mit. Ein Kind ohne Mandat gibt es in diesem Vorgang nicht.

**Die Sammelaufstellung weist jeden Fall einzeln aus** — Kind, Tag, Fall-Art, Betrag: "Diese Info mit der Notfallbetreuung muss dann sichtbar sein fuer die Buchhaltung." Der Anlass ist der Papierfall, den der Hort nachtraegt; er steht auf keiner Buchung und kaeme sonst auf keiner Rechnung an.

**Die Preise stehen seit dem 03.09.2026**, und sie hängen an denselben Modulen wie die Monatsbeiträge — der Fall ist also ein Modul, nur je Tag statt je Monat abgerechnet:

| Fall | je Fall |
|---|---|
| Frühbetreuung oder Modul 1 (bis 13:00) | 8 € |
| Modul 2 (Schulende bis 14:30) | 12 € |
| Modul 3 (Schulende bis 15:30) | 16 € |
| Modul 4 (Schulende bis 17:00) | 20 € |
| eine halbe Stunde außerhalb der Öffnungszeiten | 20 € |

**Bei den Modulen 2 bis 4 gehört ein Essen dazu und wird zusätzlich berechnet** — es steckt in keinem dieser Preise. Das ist dieselbe Regel wie beim Monatsbeitrag, und `care_modules.includes_lunch` sagt sie bereits: „Das Häkchen sagt, DASS ein Essen dazugehört, nicht, dass es im Modulpreis steckt."

Damit ist auch der Fund E2 erledigt: Die Spalte mit 8/8/12/16/20 war doch unsere und nicht die der Stadt.

**Ein Fall hängt an keinem Modul**, und das gehört als Kommentar ans Schema: Die halbe Stunde außerhalb der Öffnungszeiten liegt außerhalb jedes Moduls, es gibt sie als Monatsbeitrag nicht. Der Fallpreis hängt also an einem Modul **oder** steht allein, und beides muss die Preistabelle hergeben.

**Vor dem Seed zu klären, und nur hier festgehalten:** Welche Werte der Preisliste unsere sind, ist nicht eindeutig lesbar — die Spalte mit 8/8/12/16/20 ist anderswo mit "Stadt*" überschrieben. Vor dem Seed zu klären, nicht vor dem Bau.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Die Notfallbetreuung ist eine Tagesbuchung mit Preis je Fall, kein weiteres Betreuungsmodul
- [x] #2 Der Fallpreis hängt an einem Modul oder steht allein — die halbe Stunde außerhalb der Öffnungszeiten hat kein Modul
- [x] #3 Ein eingeschriebenes Kind ohne Betreuungsvertrag und ein externes Kind mit Betreuungsvertrag koennen gebucht werden, ein dem Haus unbekanntes nicht — je als Gegenprobe, ueber beide Eingaenge
- [x] #4 Beide Eingänge schreiben dieselbe Zeile; der Weg ist an created_by ablesbar und braucht kein Feld
- [x] #5 Buchung und Vollzug sind zwei Zeitpunkte: ein unangekündigtes Kind hat nur den zweiten, eine erledigte Buchung nur den ersten
- [x] #6 Der Hort sieht die Buchungen des Tages als frisch erzeugte Liste
- [x] #7 Bei den Modulen 2 bis 4 wird das Essen zusätzlich berechnet — es steckt in keinem Fallpreis
- [ ] #8 Nach dem Schluss zeigt das Portal den Hinweis auf den Anruf, statt die Schaltflaeche zu entfernen
- [ ] #9 Jede Buchung und jeder Storno gehen als Mail ins Hortpostfach, gleich ueber welchen Eingang sie kamen
- [ ] #10 Die Familie sieht den Eintrag im Portal, sobald er steht — das ist der Nachweis am Telefonweg und ersetzt Unterschrift und gezeichnete Tagesliste
- [ ] #11 Zum Monatsende geht eine Sammelaufstellung an die Buchhaltung; einzeln eingezogen wird nichts
- [x] #12 Eine Ablehnung ist kein Eintrag, eine nicht wahrgenommene Buchung wird nicht berechnet — `attended_at` allein traegt die Abrechnung
- [x] #13 Die Mandatsfrage ist gegenstandslos: Der Kreis der Buchenden traegt in jedem Fall ein SEPA-Mandat
- [x] #14 Jede Fall-Art traegt ihren eigenen Buchungsschluss als Wert im System — die Uhrzeiten stehen nicht im Code und nicht in der Doku
- [x] #17 Ein KITA-Kind bekommt keine Notfallbetreuung — es gilt nicht als bekannt
- [ ] #15 Bis zum Buchungsschluss storniert die Familie im Portal, danach telefonisch ueber den Hort; der Storno kostet nichts und loescht die Zeile
- [ ] #16 Die Sammelaufstellung weist jeden Fall einzeln aus, damit die Buchhaltung auch den nachgetragenen Papierfall sieht
<!-- AC:END -->
