# Putzdienst — Fachdomäne

Erste Fachdomäne (`fachdomaenen.md` Abschnitt 7), Ziel: produktiv bis Schulanfang September 2026. Prozessbeschreibung + Design-Entscheidungen — Tabellen-Datenmodell folgt danach.

## Prozess

- **Pflicht:** pro Familie 5 reguläre + 1 Großputz-Termin/Jahr (Werte konfigurierbar, siehe Zyklus-Konfiguration unten) — unabhängig von Kinderzahl und Schulzweig (Grund-/Realschule). Eltern, die gleichzeitig Mitarbeiter sind, sind komplett befreit.
- **Buchungsphase** (September, innerhalb des Buchungsfensters des Zyklus): Eltern wählen ihre Pflichttermine aus den verfügbaren Slots oder kaufen sich komplett frei. Absenden → Prüfung → Bestätigungsmail.
- **Buchungsschluss:** Restplätze pro Termin werden automatisch an Familien mit noch offenem Bedarf verteilt (Verteilungslogik selbst noch zu entwerfen), danach Rundmail an alle. Ab hier ist die Buchungsphase abgeschlossen, der Prozess geht in den laufenden Betrieb über.
- **Laufender Betrieb** (Okt–Sept): Erinnerungsmail vor jedem zugeteilten Termin (Vorlaufzeiten konfigurierbar, aktuell 1 Woche + 1 Tag). Anwesenheit läuft über eine Papier-Unterschriftenliste vor Ort — bewusst nicht digital erfasst (siehe v1-Scope-Abgrenzung). Nichterscheinen zieht eine Strafzahlung nach sich (Betrag im Zyklus konfiguriert). Eltern können Termine tauschen oder sich nachträglich noch freikaufen.
- **Verantwortlich:** Sekretariat verwaltet den gesamten Prozess, inklusive Tausch-Abwicklung zwischen Eltern.

## Freikauf & Zahlung

- Freikauf gilt für die **gesamte** Jahrespflicht (regulär + Großputz zusammen) — kein Teil-Freikauf einzelner Termine oder Terminarten.
- Zahlungsstatus im Datenmodell zahlungswegneutral (offen/bestätigt).
- Garantierter Weg für September: manuelle Bestätigung durch die Buchhaltung.
- Stripe (wird für die Voranmeldung ohnehin eingeführt) ist angestrebtes Ziel, aber niedrigste Priorität — soll ohne Schema-Änderung nachrüstbar sein.

## Anteilige Pflicht bei unterjährigem Eintritt (Quereinsteiger)

**Offen — Berechnungsformel muss extern bei den fachlich Verantwortlichen erfragt werden**, bevor sie in die Buchungslogik einfließen kann. Unbestätigter Platzhalter-Vorschlag: anteilige reguläre Termine = (volle Monate von Eintrittsmonat bis Zyklusende / 12) × Pflichtanzahl, aufgerundet auf ganze Termine; Großputz volle Pflicht, außer der Eintritt liegt nach dem einzigen Großputztermin des Zyklus.

## Familie

- Familie ist eine eigene, **vom Sekretariat manuell gepflegte** Entität — **nicht** algorithmisch aus Erziehungsberechtigte↔Kind-Beziehungen hergeleitet. Grund: Patchwork-Fälle (ein Erziehungsberechtigter mit Kindern aus zwei Beziehungen) können real vorkommen, und nur ein Mensch weiß, ob das ein oder zwei Haushalte für die Putzdienst-Pflicht sind — reine Datenstruktur kann das nicht entscheiden.
- **Erziehungsberechtigte↔Familie ist eine Mehrfachbeziehung (M:N)**, nicht 1:1 — deckt den Patchwork-Fall ab (eine Person kann Mitglied mehrerer Familien sein), ohne den Normalfall (ein Erziehungsberechtigter = eine Familie) komplizierter zu machen.
- Dieselbe Erziehungsberechtigte↔Kind↔Familie-Struktur deckt auch den OTP-Ownership-Check (`idea/04-identitaet-zugriff.md`) ab — kein Putzdienst-Spezialfall, sondern gemeinsames Fundament.
- **Buchung bei Mehrfach-Mitgliedschaft:** OTP-Login identifiziert die Person. Gehört sie zu genau einer Familie, geht's direkt zur Buchung dieser Familie. Gehört sie zu mehreren, wählt sie zuerst die Familie (Übersicht mit offenem Bedarf je Familie).
- Zukunftsthema, jetzt nicht zu lösen: Geschwisterrabatt beim Anmeldeprozess könnte dieselbe Familie-Struktur nutzen.

## Mitarbeiter-Ausnahme

`ist_mitarbeiter` ist ein generisches Attribut auf dem Erziehungsberechtigten-Grunddatensatz, nicht Teil des Putzdienst-Schemas — befüllt beim Datenimport, für jede künftige Fachdomäne mitnutzbar.

## Zyklus-Konfiguration

Pro Schuljahr, als Daten in der DB, gepflegt über die Verwaltungsoberfläche — keine Code-Änderung/Redeploy für reine Werteänderungen (`rules.md` Abschnitt 3):
- Zeitraum (Okt–Sept) und Buchungsfenster (Start/Ende im September)
- Pflichtanzahl regulär + Großputz (aktuell 5+1, aber änderbar)
- Freikauf-Betrag
- Strafe-Betrag bei Nichterscheinen
- Konkrete Putztermine: Datum, Typ (regulär/Großputz), Kapazität
- Erinnerungsstufen als Liste („X Tage vorher") statt fester Felder — erweiterbar ohne Schema-Änderung

## v1-Scope-Abgrenzung

Bewusst nicht in der ersten Version, um bis September fertig zu werden:
- Digitales Anwesenheits-Tracking — bleibt Papier-Unterschriftenliste
- Self-Service-Terminaustausch für Eltern — bleibt Sekretariat-vermittelt

## Offene Punkte

- Proration-Formel für unterjährigen Eintritt (siehe oben) — extern zu klären
- Verteilungslogik für Restplätze nach Buchungsschluss (zufällig? nach geringstem bereits gebuchtem Anteil zuerst?) — noch zu entwerfen
- Application-Access-Policy-Scoping für Microsoft-Graph-`Mail.Send` (Bestätigung, Rundmail, Erinnerungen laufen alle darüber) — bisher nirgends entschieden, welches Postfach senden darf (`idea/04-identitaet-zugriff.md`)

## Technischer Punkt

Erinnerungsmails brauchen einen zeitgesteuerten Hintergrundjob im Backend (täglicher Check, für wen heute eine Erinnerungsstufe fällig ist) — bisher in keinem Pipeline-Dokument benannt, kommt mit dieser Fachdomäne neu auf den kritischen Pfad.
