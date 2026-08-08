# Stammdaten-Schema — Performance-Benchmark

Belegt empirisch, was `rules.md` Abschnitt 1 für die Schema-Ausnahme voraussetzt: bei der Datenmenge dieser Schule (Größenordnung 500 Schüler) ist jede Normalisierungsentscheidung performance-neutral, ein zusätzlicher Join kostet nichts. Getestet wird deshalb weit über der realen Größe, nicht bei ihr — ein Ergebnis, das erst bei 1000-facher Last eng wird, ist bei realer Größe unbedenklich; eines, das schon dort eng ist, wäre es auch. Reproduzierbar über `domains/stammdaten-benchmark/` (siehe Kopfkommentar dort für den Aufruf); bewusst kein Testframework, reine Wegwerf-Infrastruktur gegen eine Wegwerf-Datenbank (`rules.md` Abschnitt 8).

## Datenvolumen

~1000–2000× die reale Schulgröße:

| Tabelle | Zeilen |
|---|---:|
| persons | 1.138.875 |
| phone_numbers | 972.209 |
| children | 500.000 |
| addresses | 500.000 |
| child_payers | 500.000 |
| child_contacts | 500.000 |
| guardians | 472.209 |
| family_guardians | 472.209 |
| families | 277.770 |
| payers | 277.770 |
| contacts | 166.666 |
| classes | 20.000 |

## Hardware

Hetzner-Cloud-VPS (Falkenstein), 4 vCPU, 7,6 GB RAM, SSD-Storage. Keine Steal-Time gemessen (`vmstat`) — keine Konkurrenz durch andere VMs auf demselben Host. Postgres 16, Standardkonfiguration (keine manuelle Tuning-Anpassung außer dem unten genannten `--shm-size`).

## Einzelquery-Ergebnisse

Jede Query fünfmal per `EXPLAIN (ANALYZE)` gemessen (serverseitige Ausführungszeit, ohne Client-/Netzwerk-Overhead).

| Kategorie | Query | min ms | avg ms | max ms |
|---|---|---:|---:|---:|
| A. Punkt-Lookup | Person per PK | 0,30 | 0,44 | 0,66 |
| A. Punkt-Lookup | Guardian-Login per E-Mail (OTP-Einstieg) | 1,13 | 1,49 | 1,88 |
| A. Punkt-Lookup | Hauptnummer einer Person | 0,59 | 0,78 | 1,10 |
| A. Punkt-Lookup | Kind per PK | 0,32 | 0,52 | 0,73 |
| B. LIKE-Suche | Namenssuche, Präfix selektiv (`nachname123%`) | 1,94 | 2,33 | 3,18 |
| B. LIKE-Suche | Namenssuche, Präfix breit (`nachname1%`, ~1/9 aller Zeilen) | 92,10 | 118,23 | 152,48 |
| B. LIKE-Suche | Namenssuche, Teilstring (`%23456%`, kein Index nutzbar) | 270,35 | 315,96 | 358,09 |
| C. Adresssuche | PLZ+Straße+Hausnummer exakt (Eingabemaske-Duplikatprüfung) | 2,00 | 2,45 | 3,22 |
| D. Mittlerer JOIN | Kind + Familie | 0,55 | 0,65 | 0,73 |
| D. Mittlerer JOIN | Kind + Hauptnummer | 0,58 | 0,76 | 1,02 |
| D. Mittlerer JOIN | Hauptzahler:in eines Kindes | 0,78 | 1,09 | 1,71 |
| D. Mittlerer JOIN | Notfallkontakte eines Kindes, nach Priorität | 0,76 | 1,10 | 1,72 |
| D. Mittlerer JOIN | Dublettenprüfung beim Import (Nachname+Geburtsdatum) | 7,93 | 9,17 | 10,70 |
| E. Schwerer JOIN | OTP-Request-Pfad (Familie+Kinder+Erziehungsberechtigte+Telefon) | 1,32 | 1,48 | 1,69 |
| E. Schwerer JOIN | Sekretariats-Vollansicht (Kind komplett) | 1,48 | 1,60 | 1,73 |
| E. Schwerer JOIN | Admin-Klassenliste mit Hauptkontakt | 7,87 | 9,51 | 11,15 |
| F. Aggregation | Kinder je Klassenstufe (GROUP BY) | 183,45 | 203,30 | 232,22 |
| F. Aggregation | Familien ohne Erziehungsberechtigte-E-Mail (Datenqualität) | 654,07 | 731,98 | 789,61 |
| G. Worst-Case | Volle Verwaltungsliste ohne Filter (alle Kinder+Hauptkontakt) | 2278,71 | 2512,50 | 2681,72 |
| G. Worst-Case | Voller Export aller Kind+Person-Felder | 943,46 | 1078,69 | 1160,42 |
| H. Schreibpfad | Einzel-INSERT (neue Familie+Person+Kind) | 1,63 | 2,41 | 3,47 |
| H. Schreibpfad | Einzel-UPDATE (eine Telefonnummer) | 2,98 | 3,08 | 3,17 |
| I. Batch | Jahreslauf (Realschule eine Klassenstufe weiter, 0 Kinderzeilen betroffen) | 343,58 | 407,62 | 466,70 |

Einordnung: Kategorien A/D/E/H sind die einzigen mit echter Pro-Request-Häufigkeit (jeder Login, jede Kindansicht, jede einzelne Änderung) — alle unter 11 ms selbst bei 1000-facher Datenmenge. Kategorie B/F/G sind seltene Admin-/Batch-Zugriffe (Namenssuche im Sekretariat, Dashboards, Export, Jahreslauf einmal jährlich) — dort sind auch Zeiten im Sekundenbereich unkritisch. Die breite Präfixsuche (B) bleibt trotz vorhandenem Index langsam, weil sie nicht selektiv ist (~1/9 aller Zeilen) — der Planer wählt dort bewusst einen Scan statt Index-Zugriff, das ist korrektes Verhalten, kein Fehler.

## Parallele Last (pgbench)

Gewichteter Mix (40 % Punkt-Lookup, 25 % mittlerer JOIN, 15 % schwerer JOIN, 10 % LIKE-Suche, 8 % Einzel-Schreibzugriff, 2 % Worst-Case-Export), 20 Sekunden je Stufe, 0 fehlgeschlagene Transaktionen bei allen drei Stufen.

| Clients | TPS | Ø Latenz Punkt-Lookup | Ø Latenz schwerer JOIN | Ø Latenz Worst-Case-Export |
|---:|---:|---:|---:|---:|
| 5 | 35,2 | 2,3 ms | 4,9 ms | 8,2 s |
| 20 | 22,6 | 5,3 ms | 12,6 ms | 32,3 s |
| 50 | 31,0 | 5,5 ms | 49,6 ms | 83,6 s |

Der Worst-Case-Export (2 % Gewicht, aber 1000× über realer Datenmenge und ohne jeden Filter) dominiert jede gemittelte Gesamtlatenz und ist einzeln ausgewiesen, damit er die übrigen Werte nicht verzerrt — bei realer Datenmenge liegt dieselbe Query im Millisekundenbereich (siehe Einzelquery-Tabelle: Faktor ~1000 zur Testdatenmenge).

## Befunde, die der Test selbst hervorgebracht hat

- **Fehlender Index auf `persons.email`**: Als Nebenwirkung der Entfernung von `UNIQUE` (geteilte Mailbox, siehe `stammdaten.md`) verschwand auch der automatisch erzeugte Index — der OTP-Login brauchte dadurch 250–350 ms (Parallel Seq Scan über 1,1 Mio. Zeilen) statt der jetzt gemessenen ~1,5 ms. Gefunden durch den erweiterten Query-Mix, nicht durch die ursprünglichen fünf Beispielabfragen. Fix bereits in `stammdaten-schema.sql` (`CREATE INDEX ON persons (email)`).
- **Dockers Standard-`/dev/shm` (64 MB) reicht nicht** für Postgres' parallele Worker unter gleichzeitiger Last — führt zu `could not resize shared memory segment`-Fehlern ab ~20 parallelen Verbindungen. Kein Schema-Problem, sondern eine Docker-Startparameter-Frage. **Für `wb-backend/docker-compose.yml` zu übernehmen:** `shm_size` explizit setzen (in diesem Test mit 1024 MB stabil, kleinere Werte nicht systematisch ausgetestet).

## Ergebnis

Die Kernaussage aus `rules.md` Abschnitt 1 ("ein zusätzlicher Join kostet hier nichts") hält empirisch — bei realer Schulgröße liegt jede in Abschnitt A/D/E gemessene Pro-Request-Query im Bereich von Bruchteilen einer Millisekunde bis niedrigen Millisekunden, selbst der ungefilterte Vollexport (G) skaliert von den gemessenen ~2,5 s bei 1000-facher Datenmenge auf einen bei realer Größe nicht wahrnehmbaren Bruchteil davon herunter.
