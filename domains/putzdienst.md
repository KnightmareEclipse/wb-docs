# Putzdienst — Fachdomäne

Erste Fachdomäne (`fachdomaenen.md` Abschnitt 7), Ziel: produktiv bis Schulanfang September 2026. Prozessbeschreibung + Design-Entscheidungen; das Tabellenschema dazu steht in `domains/putzdienst-schema.sql`, belegt durch `domains/putzdienst-schema-check.sql`.

## Prozess

- **Pflicht:** pro Familie 5 reguläre + 1 Großputz-Termin/Jahr (Werte konfigurierbar, siehe Zyklus-Konfiguration unten) — unabhängig von Kinderzahl und Schulzweig (Grund-/Realschule). Eltern, die gleichzeitig Mitarbeiter sind, sind komplett befreit.
- **Buchungsphase** (September, innerhalb des Buchungsfensters des Zyklus): Eltern wählen ihre Pflichttermine aus den verfügbaren Slots oder kaufen sich komplett frei. Absenden → Prüfung → Bestätigungsmail. Setzt voraus, dass der Jahreslauf (`domains/stammdaten.md`) vorher durchgelaufen ist — sonst tragen fortbestehende Klassen noch die Vorjahresstufe und die Abschlussklassen-Regel unten greift bei den falschen Familien. Er liegt Ende Juli und damit gut einen Monat davor; eng wird es nur bei den Einzelfällen daneben (Wiederholer, Quereinsteiger, Zugwechsler), die ein Mensch entscheidet und die bis zur Freigabe gesetzt sein müssen.
- **Buchungsschluss:** Restplätze pro Termin werden automatisch an Familien mit noch offenem Bedarf verteilt (siehe „Restplatz-Zuordnung" unten), danach Rundmail an alle. Ab hier ist die Buchungsphase abgeschlossen, der Prozess geht in den laufenden Betrieb über.
- **Laufender Betrieb** (Okt–Sept): Erinnerungsmail vor jedem zugeteilten Termin (Vorlaufzeiten konfigurierbar, aktuell 1 Woche + 1 Tag). Anwesenheit läuft über eine Papier-Unterschriftenliste vor Ort — bewusst nicht digital erfasst (siehe v1-Scope-Abgrenzung). Nichterscheinen zieht eine Strafzahlung nach sich (Betrag im Zyklus konfiguriert) und wird dafür ohnehin erfasst. Eltern können Termine tauschen oder sich nachträglich noch freikaufen; die Tauschanfrage kommt dabei regelmäßig als Antwort auf die Erinnerungsmail, deren `Reply-To` deshalb auf das Sekretariat zeigt (`idea/04-identitaet-zugriff.md`).
- **Stundennachweis:** Der Schulvertrag verlangt ihn schriftlich. Er ergibt sich aus der Stundenzahl **je Terminart** mal den wahrgenommenen Terminen — abgeleitet, kein eigenes Feld. Die Dauer hängt an der Terminart und nicht am einzelnen Termin: ein Großputz dauert immer gleich lang, ein regulärer Putzdienst ebenso. Eine abweichende Dauer ist deshalb eine neue Terminart, keine Änderung der bestehenden — sonst verschöbe sie rückwirkend jeden schon geleisteten Termin. Die **Pflichtmenge** bleibt trotzdem in Terminen bemessen (5+1), nicht in Stunden: regulär und Großputz werden getrennt gezählt und sind nicht gegeneinander verrechenbar, ein Stundenkonto hätte also keinen Abnehmer.
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
- **Bezahlt wird über Stripe**, wie die beiden anderen Selbstservice-Anlässe (`domains/grenzkarte.md`, Q3). Der Freikauf ist damit der erste gebaute Q3-Vorgang.
- Die **manuelle Bestätigung durch die Buchhaltung** bleibt daneben bestehen — für Überweisung oder Bargeld. Nicht als Notnagel, sondern als der benannte legitime Ausweg, ohne den eine harte Sperre an dieser Schule umgangen statt eingehalten wird (`fachdomaenen.md` Abschnitt 3). Im Schema ist das dieselbe Zahlungszeile ohne Zahlungsreferenz.
- Zahlungsstatus deshalb zahlungswegneutral: `payments.settled_at` leer heißt offen, gesetzt heißt bestätigt — ein Zeitpunkt statt eines Status-Lookups, gleiche Bauform wie `children.previous_school_consent_at`.

## Anteilige Pflicht bei unterjährigem Eintritt (Quereinsteiger)

Sekretariat prorationiert nach verbleibendem Schuljahresanteil, Ferien fließen dabei mit ein. Ergebnis landet in der abweichenden Pflichtmenge je Familie und Zyklus (siehe „Familie"), nicht in einem eigenen Feld. Berechnungsgrundlage: die ohnehin gepflegte Putztermin-Liste des Zyklus statt ein separater Ferienkalender — *anteilige Termine = (Anzahl noch bevorstehender Putztermine ab Eintrittsdatum / Gesamtzahl Putztermine im Zyklus) × Pflichtanzahl*, aufgerundet auf ganze Termine. Rechnet Ferien automatisch mit ein, da die Termin-Liste sie schon ausspart. Die Formel trifft damit die geübte Praxis: bei Eintritt zum Halbjahr ergibt sie 3 + 1.

Dazu ein **Stichtag** (`cleaning_cycles.proration_cutoff_on`, real um die Pfingstferien): wer ab diesem Tag eintritt, bekommt für den laufenden Zyklus gar keine Pflicht mehr. Ohne ihn ergäbe die Formel bis zum letzten Termin immer noch aufgerundet einen Termin, und für die verbleibenden Schulwochen teilt die Schule niemanden mehr ein. Beides zusammen ist die ganze Regel — weitere Staffelungen gibt es nicht.

`children.entry_date` ist nullable. Fehlt es, gilt die **volle** Pflichtmenge, keine Proration — ein leeres Eintrittsdatum ist eine Importlücke, kein Quereinstieg, und eine Proration darauf senkte still die Pflicht jeder Familie, deren Datum der Import nicht gefüllt hat. Dieselbe Behandlung wie bei einem Eintritt vor Zyklusbeginn, wo die Formel ohnehin die volle Menge ergibt. Ist der Fall real anders, korrigiert ihn das Sekretariat über die abweichende Pflichtmenge (siehe „Familie") — derselbe Weg wie für jeden anderen Sonderfall, kein eigener Mechanismus.

## Familie

- Familie ist die Sorgerecht-Konstellation aus `domains/stammdaten.md`, „Familie" — der Schulvertrag knüpft die Pflicht an genau dieselbe Einheit: „Personensorgeberechtigte, die mehrere Schüler/innen beim Schulträger angemeldet haben, erbringen die Mitarbeit einmal pro Familie."
- **Die `families`-Zeile wird nie nach Putzdienst-Gesichtspunkten geschnitten.** Sie ist zugleich die Ownership-Grenze des OTP-Zugriffs (`idea/04-identitaet-zugriff.md`) — zwei Sorgerecht-Konstellationen zusammenzulegen, damit die Pflichtmenge stimmt, gäbe fremden Personen Zugriff auf die Daten des jeweils anderen Kindes. Abweichungen sind ein Wert, keine andere Familienstruktur (nächster Punkt).
- **Pflichtig ist eine Familie, sobald sie mindestens ein eingeschriebenes Kind hat** — „eingeschrieben" ist dabei das Stammdaten-Prädikat (`domains/stammdaten.md`, „Felder"), kein Putzdienst-eigenes Kennzeichen. Ein reines Ferienprogramm-Kind (`fachdomaenen.md` Abschnitt 1) erfüllt es nicht und löst damit keine Pflicht aus.
- **Ermittelt wird die Pflicht einmal je Zyklus, beim Buchungsfenster** — nicht fortlaufend. Das trennt sie von der Klassenzuteilung: ein im Februar aufgenommenes Kind bekommt seine `class_id` schon bei der Klassenbildung im Juli (`fachdomaenen.md` Abschnitt 6, Domäne 12) und ist damit mitten im laufenden Zyklus „eingeschrieben", startet aber erst im September. Ohne festen Ermittlungszeitpunkt zöge es seine Familie noch in die letzten Termine des auslaufenden Zyklus. Mitten im Zyklus kommt eine Familie nur durch einen echten Quereinstieg dazu, und den prorationiert das Sekretariat von Hand (siehe „Anteilige Pflicht bei unterjährigem Eintritt").
- **Abweichende Pflichtmenge je Familie und Zyklus**, leer = Standard aus der Zyklus-Konfiguration. Zwei Werte, nicht einer — regulär und Großputz werden getrennt gezählt, und aus einer Gesamtzahl ließe sich nicht rekonstruieren, welcher Teil noch offen ist. Leer gilt je Wert einzeln („3 regulär, Großputz wie Standard"); **0 ist dagegen ein gültiger Wert** und nicht dasselbe wie leer — es ist der Fall Eintritt nach dem Stichtag. Der Schulvertrag sieht sie ausdrücklich vor („In besonderen Fällen kann mit dem Schulträger eine abweichende Regelung getroffen werden", Anlage Putzdienstregelung). Dasselbe Feld nimmt die Quereinsteiger-Proration auf (unten) — deshalb kein eigener Mechanismus für Sonderfälle. Darunter fällt auch Patchwork (eine Person in zwei Konstellationen, ein Haushalt, nach Standard zwei Pflichten): an der Schule bisher kein bekannter Fall, tritt einer auf, ist er ein besonderer Fall nach Vertrag (`rules.md` Abschnitt 1).
- **Innerhalb der Familie benennt das Modell niemanden.** Der Vertrag legt die Pflicht auf die Personensorgeberechtigten gemeinsam und überlässt ihnen Ersatz und Termintausch ausdrücklich selbst — Erinnerungsmails gehen deshalb an alle natürlichen Personen der Familie, nicht an eine ausgewählte. Ausgenommen sind Mitglieder, die von der Schulkorrespondenz abgewählt wurden (`family_guardians.include_in_correspondence`, `domains/stammdaten.md`): wer keine Schulpost bekommt, bekommt auch keine Putzdienst-Erinnerung.
- **Amts- und Vereinsvormundschaft sind befreit, aber nicht weil sie keine Personen wären.** Eine Amtsvormundin ist im Schema eine ganz normale Erziehungsberechtigte (`domains/stammdaten.md`, „Familie") und hat deshalb auch einen Buchungszugang. Dass sie keine Pflicht auslöst, liest der Putzdienst an `guardian_categories.exempt_from_parent_duties` ab — eine ausdrückliche Aussage über diese Erziehungsberechtigung statt eines Nebeneffekts der Rechtsform.
- **Buchung bei Mehrfach-Mitgliedschaft:** OTP-Login identifiziert die Person. Gehört sie zu genau einer Familie, geht's direkt zur Buchung dieser Familie. Gehört sie zu mehreren, wählt sie zuerst die Familie (Übersicht mit offenem Bedarf je Familie).
- Zukunftsthema, jetzt nicht zu lösen: Geschwisterrabatt beim Anmeldeprozess könnte dieselbe Familie-Struktur nutzen.

## Abgänge & Klassenstufen-Übergänge

Buchung findet im September, also zu Zyklusbeginn, statt — zu diesem Zeitpunkt ist bereits bekannt, welche Kinder in der letzten Klassenstufe ihres Zweigs sind (`grade_levels.is_final_grade`, heute Klasse 4 in der Grundschule bzw. 10 in der Realschule). Statt eines nachträglichen Abgleichs wird das **proaktiv** in die Buchung eingebaut:

- Familien, bei denen **alle** Kinder in einer Klassenstufe mit `is_final_grade` sind, wird der September-Termin (letzter Monat des Zyklus) gar nicht erst als Buchungsoption angezeigt, und dieselbe Regel gilt als Constraint im OR-Tools-Modell bei der automatischen Restzuordnung (siehe „Restplatz-Zuordnung").
- Die Klassenstufe steht nicht als eigene Spalte am Kind, sondern kommt über zwei Wege (`domains/stammdaten.md`): bei zugeteilter Klasse per Join `children.class_id → classes.grade_level_id`, bei neu eingeschulten Kindern ohne Klassenzuteilung aus `children.provisional_grade_level_id`. Die Regel muss beide abfragen — ein direkter Lesezugriff auf `provisional_grade_level_id` liefert bei zugeteilter Klasse NULL. Sie greift ohnehin nur für eingeschriebene Kinder (siehe „Familie"): eine bereits stillgelegte Kohorte (`classes.is_active` false) zählt gar nicht erst mit.
- Die Grundschul-Abschlussklasse zählt bewusst mit, weil ein Grundschulkind nicht zwingend intern in die Realschule wechselt — ob es danach bleibt oder geht, steht zum Buchungszeitpunkt noch nicht fest. Maßgeblich ist immer die ganze Familie: sobald **ein** Kind nicht in einer Abschlussklasse ist, ist dieses Kind im September des Folgejahres sicher noch da, also bleibt September für die ganze Familie buchbar. Nur wenn wirklich alle Kinder einer Familie in einer Abschlussklasse sind, wird September gesperrt.
- **Restrisiko** (unerwarteter/vorzeitiger Abgang außerhalb der Abschlussklassen-Regel): wird nicht automatisch erkannt. Läuft über manuelle Terminverschiebung durchs Sekretariat, das dabei die berechnete Kapazität überschreiten darf (siehe „Restplatz-Zuordnung").
- `children.exit_date` bleibt trotzdem als Feld sinnvoll — wird ohnehin für die Löschfrist gebraucht (`idea/06-dsgvo-organisatorisch.md`), auch wenn der Putzdienst selbst dank der Abschlussklassen-Regel oben meist nicht mehr darauf angewiesen ist.

## Mitarbeiter-Ausnahme

Befreit ist, wer **aktuell** beschäftigt ist: eine `employees`-Zeile zu dieser Person mit leerem `employment_end`. Genau diese Abfrage ist der Grund, warum `employees` eine eigene Rolle mit Beschäftigungszeitraum ist und kein Kennzeichen am Erziehungsberechtigten (`domains/grenzkarte.md`, Q4) — ein ausgeschiedener Mitarbeiter wird wieder pflichtig. Die Tabelle gehört zu den Stammdaten, nicht zum Putzdienst-Schema.

## Zyklus-Konfiguration

Pro Schuljahr, als Daten in der DB, gepflegt über die Verwaltungsoberfläche — keine Code-Änderung/Redeploy für reine Werteänderungen (`rules.md` Abschnitt 3):
- Zeitraum (Okt–Sept) und Buchungsfenster (Start/Ende im September)
- Pflichtanzahl regulär + Großputz (aktuell 5+1, aber änderbar)
- Freikauf-Betrag
- Strafe-Betrag bei Nichterscheinen
- Stichtag der Quereinsteiger-Proration (siehe „Anteilige Pflicht bei unterjährigem Eintritt")
- Konkrete Putztermine: Datum und Terminart — die Stundenzahl steht an der Terminart (trägt den Stundennachweis, siehe „Prozess"), die Kapazität wird gar nicht eingetragen, sondern in zwei Stufen berechnet (siehe „Restplatz-Zuordnung")
- **Terminarten als Werteliste**, nicht als festes Begriffspaar: es gab bereits einen Termin, an dem nur Gartenarbeit anstand und der trotzdem als regulärer Putzdienst zählte. Eine weitere Art ist damit eine Zeile statt einer Migration. Woran die Art nichts ändern darf, ist die Zählung — deshalb trägt jede Zeile zusätzlich ein nicht umbenennbares Kennzeichen, ob sie gegen die Großputz- oder gegen die reguläre Pflicht zählt (`cleaning_duty_types.is_major`; „Gartenarbeit" und „Regulär" tragen dasselbe)
- Puffer für die Live-Obergrenze pro Termin während der Buchungsphase (siehe „Restplatz-Zuordnung")
- Erinnerungsstufen als Liste („X Tage vorher") statt fester Felder — erweiterbar ohne Schema-Änderung

## v1-Scope-Abgrenzung

Bewusst nicht in der ersten Version, um bis September fertig zu werden:
- Digitales Anwesenheits-Tracking — bleibt Papier-Unterschriftenliste
- Self-Service-Terminaustausch für Eltern — bleibt Sekretariat-vermittelt

## Offene Punkte

- Anfang September zu bestätigen: gilt die Großputz/regulär-selber-Tag-Ausschluss-Regel wirklich (siehe „Restplatz-Zuordnung")

## Technischer Punkt

Erinnerungsmails brauchen einen zeitgesteuerten Hintergrundjob im Backend (täglicher Check, für wen heute eine Erinnerungsstufe fällig ist) — bisher in keinem Pipeline-Dokument benannt, kommt mit dieser Fachdomäne neu auf den kritischen Pfad.
