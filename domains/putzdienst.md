# Putzdienst — Fachdomäne

Erste Fachdomäne (`fachdomaenen.md` Abschnitt 7), Ziel: produktiv bis Schulanfang September 2026. Prozessbeschreibung + Design-Entscheidungen — Tabellen-Datenmodell folgt danach.

## Prozess

- **Pflicht:** pro Familie 5 reguläre + 1 Großputz-Termin/Jahr (Werte konfigurierbar, siehe Zyklus-Konfiguration unten) — unabhängig von Kinderzahl und Schulzweig (Grund-/Realschule). Eltern, die gleichzeitig Mitarbeiter sind, sind komplett befreit.
- **Buchungsphase** (September, innerhalb des Buchungsfensters des Zyklus): Eltern wählen ihre Pflichttermine aus den verfügbaren Slots oder kaufen sich komplett frei. Absenden → Prüfung → Bestätigungsmail. Setzt voraus, dass der Jahreslauf (`domains/stammdaten.md`) vorher durchgelaufen ist — sonst tragen fortbestehende Klassen noch die Vorjahresstufe und die Abschlussklassen-Regel unten greift bei den falschen Familien.
- **Buchungsschluss:** Restplätze pro Termin werden automatisch an Familien mit noch offenem Bedarf verteilt (siehe „Restplatz-Zuordnung" unten), danach Rundmail an alle. Ab hier ist die Buchungsphase abgeschlossen, der Prozess geht in den laufenden Betrieb über.
- **Laufender Betrieb** (Okt–Sept): Erinnerungsmail vor jedem zugeteilten Termin (Vorlaufzeiten konfigurierbar, aktuell 1 Woche + 1 Tag). Anwesenheit läuft über eine Papier-Unterschriftenliste vor Ort — bewusst nicht digital erfasst (siehe v1-Scope-Abgrenzung). Nichterscheinen zieht eine Strafzahlung nach sich (Betrag im Zyklus konfiguriert). Eltern können Termine tauschen oder sich nachträglich noch freikaufen.
- **Verantwortlich:** Sekretariat verwaltet den gesamten Prozess, inklusive Tausch-Abwicklung zwischen Eltern.

## Restplatz-Zuordnung nach Buchungsschluss

Kein reines Transportproblem, sondern ein Scheduling-Problem mit Nebenbedingungen — Zuordnung über einen Constraint-Solver statt handgeschriebenem Greedy-/Backtracking-Code, damit einzelne Regeln (siehe unten) sich ohne Umbau der Logik ändern/entfernen lassen.

- **Tool:** Google OR-Tools, CP-SAT-Solver (`ortools`, Python-Paket, Apache-2.0, kostenlos). Reine Library, läuft in-process im Backend, kein eigener Dienst, keine Netzwerkverbindung nach außen, keine AVV-Prüfung nötig (`rules.md` §7) — passt in die bestehende `pip-tools`-Lockfile-Verwaltung (`project-parts.md` Abschnitt 4).
- **Nebenbedingungen** (je eine Constraint im Solver-Modell):
  - Eine Familie ist maximal einmal pro Termin eingetragen
  - Jede Familie muss zwingend ihren vollen Restbedarf zugeordnet bekommen
  - Mindestabstand 2 Kalenderwochen zwischen zwei Terminen derselben Familie (Ferienwochen zählen dabei nicht extra — ein durch Ferien ohnehin entstandener größerer Abstand erfüllt die Regel automatisch)
  - Keine gleichzeitige Zuordnung zu Großputz und regulärem Putzdienst am selben Kalendertag — Regel selbst noch unbestätigt (Klärung Anfang September), aber als eigene, leicht entfernbare Constraint gebaut
  - Familien, deren Kinder alle in der letzten Klassenstufe ihres Zweigs sind (`grade_levels.is_final_grade`), werden nicht den Terminen im letzten Zyklusmonat (September) zugeordnet (siehe „Abgänge & Klassenstufen-Übergänge")
- **Kapazität pro Termin — zweistufig:**
  - **Live-Obergrenze während der Buchungsphase:** Zielkapazität je Termin = Gesamtbedarf des jeweiligen Typs (regulär/Großputz) gleichverteilt auf die Anzahl Termine dieses Typs, abzüglich eines Puffers (Zyklus-Konfigurationswert, siehe unten). Verhindert, dass beliebte frühe Termine (Erfahrungswert: Okt/Nov) live komplett volllaufen und dem Solver am Ende nur noch die unbeliebten späten Termine (Jul–Sep) zur Verteilung übrigbleiben. Wird periodisch neu berechnet (z. B. täglich), nicht bei jeder einzelnen Buchung live neu — die Live-Obergrenze muss nur grob balancieren, nicht exakt aktuell sein, die verbindliche Verteilung übernimmt ohnehin der Solver am Ende.
  - **Endgültige Kapazität bei Buchungsschluss:** aus dem tatsächlichen Restbedarf berechnet (Gesamtbedarf abzüglich Freikäufe). Der Solver darf dabei auch über die Live-Obergrenze hinaus in die durch den Puffer freigehaltenen Restplätze einsortieren, solange die reale Gesamtkapazität eines Termins nicht überschritten wird.
  - **Manuelle Eingriffe durchs Sekretariat sind davon ausgenommen:** weder die Live-Obergrenze noch die bei Buchungsschluss berechnete Kapazität binden das Sekretariat — beide gelten nur für die automatisierten Pfade (Selbstbuchung, Solver-Zuordnung). Bei manuellen Terminverschiebungen (z. B. Restrisiko-Fälle unten) darf das Sekretariat eine berechnete Kapazität überschreiten; die Werte sind dort nur Leitlinie, kein hartes Limit.

## Freikauf & Zahlung

- Freikauf gilt für die **gesamte** Jahrespflicht (regulär + Großputz zusammen) — kein Teil-Freikauf einzelner Termine oder Terminarten.
- Zahlungsstatus im Datenmodell zahlungswegneutral (offen/bestätigt).
- Garantierter Weg für September: manuelle Bestätigung durch die Buchhaltung.
- Stripe (wird für die Voranmeldung ohnehin eingeführt) ist angestrebtes Ziel, aber niedrigste Priorität — soll ohne Schema-Änderung nachrüstbar sein.

## Anteilige Pflicht bei unterjährigem Eintritt (Quereinsteiger)

Sekretariat prorationiert nach verbleibendem Schuljahresanteil, Ferien fließen dabei mit ein. Berechnungsgrundlage: die ohnehin gepflegte Putztermin-Liste des Zyklus statt ein separater Ferienkalender — *anteilige Termine = (Anzahl noch bevorstehender Putztermine ab Eintrittsdatum / Gesamtzahl Putztermine im Zyklus) × Pflichtanzahl*, aufgerundet auf ganze Termine. Rechnet Ferien automatisch mit ein, da die Termin-Liste sie schon ausspart. Feinschliff (z. B. exaktes Rundungsverhalten) folgt bei Bedarf, Grundmechanik steht.

## Familie

- Familie ist eine eigene, **vom Sekretariat manuell gepflegte** Entität — **nicht** algorithmisch aus Erziehungsberechtigte↔Kind-Beziehungen hergeleitet. Grund: Patchwork-Fälle (ein Erziehungsberechtigter mit Kindern aus zwei Beziehungen) können real vorkommen, und nur ein Mensch weiß, ob das ein oder zwei Haushalte für die Putzdienst-Pflicht sind — reine Datenstruktur kann das nicht entscheiden.
- **Erziehungsberechtigte↔Familie ist eine Mehrfachbeziehung (M:N)**, nicht 1:1 — deckt den Patchwork-Fall ab (eine Person kann Mitglied mehrerer Familien sein), ohne den Normalfall (ein Erziehungsberechtigter = eine Familie) komplizierter zu machen.
- Dieselbe Erziehungsberechtigte↔Kind↔Familie-Struktur deckt auch den OTP-Ownership-Check (`idea/04-identitaet-zugriff.md`) ab — kein Putzdienst-Spezialfall, sondern gemeinsames Fundament.
- **Die Pflicht erfüllen ausschließlich natürliche Personen.** Eine Organisation als Erziehungsberechtigte (Jugendamt, Vereinsvormund, `domains/stammdaten.md`) ist nie putzdienstpflichtig — und hat konsequenterweise auch keinen Zugangsweg zur Buchung (`idea/04-identitaet-zugriff.md`). Eine Familie ganz ohne natürliche Person kommt an der Schule nicht vor: Pflegeeltern werden immer als natürliche Person erfasst.
- **Buchung bei Mehrfach-Mitgliedschaft:** OTP-Login identifiziert die Person. Gehört sie zu genau einer Familie, geht's direkt zur Buchung dieser Familie. Gehört sie zu mehreren, wählt sie zuerst die Familie (Übersicht mit offenem Bedarf je Familie).
- Zukunftsthema, jetzt nicht zu lösen: Geschwisterrabatt beim Anmeldeprozess könnte dieselbe Familie-Struktur nutzen.

## Abgänge & Klassenstufen-Übergänge

Buchung findet im September, also zu Zyklusbeginn, statt — zu diesem Zeitpunkt ist bereits bekannt, welche Kinder in der letzten Klassenstufe ihres Zweigs sind (`grade_levels.is_final_grade`, heute Klasse 4 in der Grundschule bzw. 10 in der Realschule). Statt eines nachträglichen Abgleichs wird das **proaktiv** in die Buchung eingebaut:

- Familien, bei denen **alle** Kinder in einer Klassenstufe mit `is_final_grade` sind, wird der September-Termin (letzter Monat des Zyklus) gar nicht erst als Buchungsoption angezeigt, und dieselbe Regel gilt als Constraint im OR-Tools-Modell bei der automatischen Restzuordnung (siehe „Restplatz-Zuordnung").
- Die Klassenstufe steht nicht als eigene Spalte am Kind, sondern kommt über zwei Wege (`domains/stammdaten.md`): bei zugeteilter Klasse per Join `children.class_id → classes.grade_level_id`, bei neu eingeschulten Kindern ohne Klassenzuteilung aus `children.provisional_grade_level_id`. Die Regel muss beide abfragen — ein direkter Lesezugriff auf `provisional_grade_level_id` liefert bei zugeteilter Klasse NULL.
- Die Grundschul-Abschlussklasse zählt bewusst mit, weil ein Grundschulkind nicht zwingend intern in die Realschule wechselt — ob es danach bleibt oder geht, steht zum Buchungszeitpunkt noch nicht fest. Maßgeblich ist immer die ganze Familie: sobald **ein** Kind nicht in einer Abschlussklasse ist, ist dieses Kind im September des Folgejahres sicher noch da, also bleibt September für die ganze Familie buchbar. Nur wenn wirklich alle Kinder einer Familie in einer Abschlussklasse sind, wird September gesperrt.
- **Restrisiko** (unerwarteter/vorzeitiger Abgang außerhalb der Abschlussklassen-Regel): wird nicht automatisch erkannt. Läuft über manuelle Terminverschiebung durchs Sekretariat, das dabei die berechnete Kapazität überschreiten darf (siehe „Restplatz-Zuordnung").
- `children.exit_date` bleibt trotzdem als Feld sinnvoll — wird ohnehin für die Löschfrist gebraucht (`idea/06-dsgvo-organisatorisch.md`), auch wenn der Putzdienst selbst dank der Abschlussklassen-Regel oben meist nicht mehr darauf angewiesen ist.

## Mitarbeiter-Ausnahme

`guardians.is_employee` ist ein generisches Attribut auf dem Erziehungsberechtigten-Datensatz (`domains/stammdaten-schema.sql`), nicht Teil des Putzdienst-Schemas — befüllt beim Datenimport, für jede künftige Fachdomäne mitnutzbar.

## Zyklus-Konfiguration

Pro Schuljahr, als Daten in der DB, gepflegt über die Verwaltungsoberfläche — keine Code-Änderung/Redeploy für reine Werteänderungen (`rules.md` Abschnitt 3):
- Zeitraum (Okt–Sept) und Buchungsfenster (Start/Ende im September)
- Pflichtanzahl regulär + Großputz (aktuell 5+1, aber änderbar)
- Freikauf-Betrag
- Strafe-Betrag bei Nichterscheinen
- Konkrete Putztermine: Datum, Typ (regulär/Großputz) — Kapazität wird nicht hier eingetragen, sondern in zwei Stufen berechnet (siehe „Restplatz-Zuordnung")
- Puffer für die Live-Obergrenze pro Termin während der Buchungsphase (siehe „Restplatz-Zuordnung")
- Erinnerungsstufen als Liste („X Tage vorher") statt fester Felder — erweiterbar ohne Schema-Änderung

## v1-Scope-Abgrenzung

Bewusst nicht in der ersten Version, um bis September fertig zu werden:
- Digitales Anwesenheits-Tracking — bleibt Papier-Unterschriftenliste
- Self-Service-Terminaustausch für Eltern — bleibt Sekretariat-vermittelt

## Offene Punkte

- Anfang September zu bestätigen: gilt die Großputz/regulär-selber-Tag-Ausschluss-Regel wirklich (siehe „Restplatz-Zuordnung")
- Application-Access-Policy-Scoping für Microsoft-Graph-`Mail.Send` (Bestätigung, Rundmail, Erinnerungen laufen alle darüber) — bisher nirgends entschieden, welches Postfach senden darf (`idea/04-identitaet-zugriff.md`)

## Technischer Punkt

Erinnerungsmails brauchen einen zeitgesteuerten Hintergrundjob im Backend (täglicher Check, für wen heute eine Erinnerungsstufe fällig ist) — bisher in keinem Pipeline-Dokument benannt, kommt mit dieser Fachdomäne neu auf den kritischen Pfad.
