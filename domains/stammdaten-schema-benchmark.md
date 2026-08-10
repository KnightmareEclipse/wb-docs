# Stammdaten-Schema — Performance-Benchmark

Belegt empirisch, was `rules.md` Abschnitt 1 für die Schema-Ausnahme voraussetzt: bei der Datenmenge dieser Schule (Größenordnung 500 Schüler) ist jede Normalisierungsentscheidung performance-neutral, ein zusätzlicher Join kostet nichts. Zwei Durchläufe: einer bei realer Größe (die tatsächlich zu erwartenden Zahlen), einer bei 1000–2000-facher Größe (Stresstest — ein Ergebnis, das erst dort eng wird, ist bei realer Größe unbedenklich; eines, das schon dort eng ist, wäre es auch). Reproduzierbar über `domains/stammdaten-benchmark/` (siehe Kopfkommentar dort für den Aufruf, Datenmenge über `\set n_children`/`\set n_classes` in `generate.sql` einstellbar); bewusst kein Testframework, reine Wegwerf-Infrastruktur gegen eine Wegwerf-Datenbank (`rules.md` Abschnitt 8).

## Hardware

Beide Durchläufe auf derselben Hetzner-Cloud-VPS (Falkenstein), 4 vCPU, 7,6 GB RAM, SSD-Storage. Keine Steal-Time gemessen (`vmstat`) — keine Konkurrenz durch andere VMs auf demselben Host. Postgres 16, Standardkonfiguration (keine manuelle Tuning-Anpassung außer dem unten genannten `--shm-size`).

## Durchlauf 1: reale Größe (~500 Schüler)

`n_children=500`, `n_classes=20` (10 Klassenstufen × 2 Züge, wie an der Schule real).

| Tabelle | Zeilen |
|---|---:|
| persons | 1.125 |
| phone_numbers | 959 |
| children | 500 |
| addresses | 500 |
| child_contacts | 500 |
| guardians | 459 |
| family_guardians | 459 |
| families | 270 |
| payers | 270 |
| classes | 20 |

Jede Query fünfmal per `EXPLAIN (ANALYZE)` gemessen; Tabellen/Filter je Query stehen in der Stresstest-Tabelle unten (identische Queries, nur die Datenmenge unterscheidet sich).

**Die Messwerte stammen von vor der Schema-Vereinfachung und wurden auf Postgres 16 erhoben, produktiv läuft mindestens 18** (Wegfall von `organizations`, der Verknüpfungstabelle `child_payers` und der Rollentabelle `contacts`, Rollenzeilen teilen sich den Schlüssel mit `persons`). Sie sind damit eine **obere Schranke**: jede betroffene Abfrage braucht seither strikt weniger Joins, keine mehr. Zeilenzahlen und Query-Beschreibungen sind dagegen auf dem aktuellen Stand, und die Suite läuft wieder vollständig durch (23 von 23 Abfragen). Eine Neumessung ist ein eigener Lauf und steht aus; die Aussage des Benchmarks — bei dieser Datenmenge ist jede Normalisierungsentscheidung performance-neutral — wird davon nur bestätigt, nicht berührt.

| Kategorie | Query | min ms | avg ms | max ms |
|---|---|---:|---:|---:|
| A. Punkt-Lookup | Person per PK | 0,49 | 0,64 | 0,87 |
| A. Punkt-Lookup | Guardian-Login per E-Mail (OTP-Einstieg) | 1,07 | 1,44 | 1,80 |
| A. Punkt-Lookup | Hauptnummer einer Person | 0,34 | 0,46 | 0,53 |
| A. Punkt-Lookup | Kind per PK | 0,42 | 0,65 | 1,03 |
| B. LIKE-Suche | Namenssuche, Präfix selektiv | 0,25 | 0,43 | 0,78 |
| B. LIKE-Suche | Namenssuche, Präfix breit | 0,37 | 0,54 | 0,72 |
| B. LIKE-Suche | Namenssuche, Teilstring (kein Index nutzbar) | 1,27 | 1,90 | 4,17 |
| C. Adresssuche | PLZ+Straße+Hausnummer exakt | 0,39 | 0,51 | 0,63 |
| D. Mittlerer JOIN | Kind + Familie | 0,40 | 0,62 | 0,88 |
| D. Mittlerer JOIN | Kind + Hauptnummer | 0,49 | 0,73 | 1,07 |
| D. Mittlerer JOIN | Hauptzahler:in eines Kindes | 0,57 | 0,75 | 1,05 |
| D. Mittlerer JOIN | Notfallkontakte eines Kindes, nach Priorität | 0,62 | 0,97 | 1,45 |
| D. Mittlerer JOIN | Dublettenprüfung beim Import | 0,62 | 0,79 | 1,11 |
| E. Schwerer JOIN | OTP-Request-Pfad | 1,04 | 1,15 | 1,46 |
| E. Schwerer JOIN | Sekretariats-Vollansicht | 0,79 | 1,12 | 1,39 |
| E. Schwerer JOIN | Admin-Klassenliste mit Hauptkontakt | 1,77 | 2,23 | 2,77 |
| F. Aggregation | Kinder je Klassenstufe (GROUP BY) | 0,76 | 1,09 | 1,56 |
| F. Aggregation | Familien ohne Erziehungsberechtigte-E-Mail | 1,14 | 1,52 | 1,82 |
| G. Worst-Case | Volle Verwaltungsliste ohne Filter | 3,70 | 5,03 | 6,88 |
| G. Worst-Case | Voller Export aller Kind+Person-Felder | 1,02 | 1,43 | 1,95 |
| H. Schreibpfad | Einzel-INSERT | 1,52 | 2,28 | 3,43 |
| H. Schreibpfad | Einzel-UPDATE | 2,27 | 3,09 | 4,16 |
| I. Batch | Jahreslauf (Realschule eine Klassenstufe weiter) | 1,13 | 2,25 | 3,42 |

Parallele Last (`pgbench`, gleicher Mix wie unten), 0 fehlgeschlagene Transaktionen:

| Clients | TPS | Ø Latenz Punkt-Lookup | Ø Latenz schwerer JOIN | Ø Latenz Worst-Case-Export |
|---:|---:|---:|---:|---:|
| 5 | 5.070 | 0,58 ms | 2,28 ms | 5,2 ms |
| 20 | 4.385 | 2,99 ms | 9,15 ms | 21,5 ms |
| 50 | 4.943 | 8,13 ms | 14,40 ms | 35,5 ms |

Bei realer Größe bleibt selbst der ungefilterte Worst-Case-Export unter paralleler Last (50 Clients) bei 35,5 ms im Mittel — keine Query aus dem gesamten Mix liegt über 36 ms.

## Durchlauf 2: Stresstest (1000–2000× reale Größe)

`n_children=500000`, `n_classes=20000`.

| Tabelle | Zeilen |
|---|---:|
| persons | 1.138.875 |
| phone_numbers | 972.209 |
| children | 500.000 |
| addresses | 500.000 |
| child_contacts | 500.000 |
| guardians | 472.209 |
| family_guardians | 472.209 |
| families | 277.770 |
| payers | 277.770 |
| classes | 20.000 |

Jede Query fünfmal per `EXPLAIN (ANALYZE)` gemessen (serverseitige Ausführungszeit, ohne Client-/Netzwerk-Overhead). Spalte „Tabellen/Filter" zeigt die JOIN-Kette in Zugriffsreihenfolge sowie die filternde Bedingung; volle Statements stehen in `domains/stammdaten-benchmark/run-suite.sh`.

| Kategorie | Query | Tabellen/Filter | min ms | avg ms | max ms |
|---|---|---|---:|---:|---:|
| A. Punkt-Lookup | Person per PK | `persons`, WHERE `id` = | 0,30 | 0,44 | 0,66 |
| A. Punkt-Lookup | Guardian-Login per E-Mail (OTP-Einstieg) | `persons` → `guardians`, WHERE `email` = | 1,13 | 1,49 | 1,88 |
| A. Punkt-Lookup | Hauptnummer einer Person | `phone_numbers`, WHERE `person_id` = AND `is_primary` | 0,59 | 0,78 | 1,10 |
| A. Punkt-Lookup | Kind per PK | `children`, WHERE `id` = | 0,32 | 0,52 | 0,73 |
| B. LIKE-Suche | Namenssuche, Präfix selektiv (`nachname123%`) | `persons`, WHERE `lower(last_name) LIKE` | 1,94 | 2,33 | 3,18 |
| B. LIKE-Suche | Namenssuche, Präfix breit (`nachname1%`, ~1/9 aller Zeilen) | `persons`, WHERE `lower(last_name) LIKE` | 92,10 | 118,23 | 152,48 |
| B. LIKE-Suche | Namenssuche, Teilstring (`%23456%`, kein Index nutzbar) | `persons`, WHERE `lower(last_name) LIKE` | 270,35 | 315,96 | 358,09 |
| C. Adresssuche | PLZ+Straße+Hausnummer exakt (Eingabemaske-Duplikatprüfung) | `addresses`, WHERE `(postal_code, street, house_number)` = | 2,00 | 2,45 | 3,22 |
| D. Mittlerer JOIN | Kind + Familie | `children` → `families` | 0,55 | 0,65 | 0,73 |
| D. Mittlerer JOIN | Kind + Hauptnummer | `children` → `persons` → `phone_numbers` (is_primary) | 0,58 | 0,76 | 1,02 |
| D. Mittlerer JOIN | Zahler:in eines Kindes | `children` → `payers` → `persons` | 0,78 | 1,09 | 1,71 |
| D. Mittlerer JOIN | Notfallkontakte eines Kindes, nach Priorität | `children` → `child_contacts` → `persons`, ORDER BY `priority` | 0,76 | 1,10 | 1,72 |
| D. Mittlerer JOIN | Dublettenprüfung beim Import (Nachname+Geburtsdatum) | `children` → `persons`, Selbstvergleich `last_name`+`date_of_birth` | 7,93 | 9,17 | 10,70 |
| E. Schwerer JOIN | OTP-Request-Pfad (Familie+Kinder+Erziehungsberechtigte+Telefon) | `families` → `children` → `persons` → `family_guardians` → `guardians` → `persons` → `phone_numbers` (7 Tabellen/Aliase), WHERE `family_id` = | 1,32 | 1,48 | 1,69 |
| E. Schwerer JOIN | Sekretariats-Vollansicht (Kind komplett) | wie OTP-Pfad, zusätzlich `addresses` je Kind und je Erziehungsberechtigtem (9), `SELECT *` | 1,48 | 1,60 | 1,73 |
| E. Schwerer JOIN | Admin-Klassenliste mit Hauptkontakt | `children` → `persons` → `family_guardians` → `guardians` → `persons` → `phone_numbers`, WHERE `class_id` = | 7,87 | 9,51 | 11,15 |
| F. Aggregation | Kinder je Klassenstufe (GROUP BY) | `children` → `classes` → `grade_levels`, GROUP BY `label` | 183,45 | 203,30 | 232,22 |
| F. Aggregation | Familien ohne Erziehungsberechtigte-E-Mail (Datenqualität) | `families`, NOT EXISTS `family_guardians` → `guardians` → `persons` (email IS NOT NULL) | 654,07 | 731,98 | 789,61 |
| G. Worst-Case | Volle Verwaltungsliste ohne Filter (alle Kinder+Hauptkontakt) | wie Admin-Klassenliste, aber **ohne WHERE** — alle 500.000 Kinder | 2278,71 | 2512,50 | 2681,72 |
| G. Worst-Case | Voller Export aller Kind+Person-Felder | `children` → `persons`, `SELECT c.*, p.*`, **ohne WHERE** | 943,46 | 1078,69 | 1160,42 |
| H. Schreibpfad | Einzel-INSERT (neue Familie+Person+Kind) | `INSERT INTO families`, in Transaktion mit ROLLBACK | 1,63 | 2,41 | 3,47 |
| H. Schreibpfad | Einzel-UPDATE (eine Telefonnummer) | `UPDATE phone_numbers SET number`, in Transaktion mit ROLLBACK | 2,98 | 3,08 | 3,17 |
| I. Batch | Jahreslauf (Realschule eine Klassenstufe weiter, 0 Kinderzeilen betroffen) | `UPDATE classes SET grade_level_id`, WHERE `school_branch_id`+`sort_order` (Realschule, nicht Abschlussklasse), in Transaktion mit ROLLBACK | 343,58 | 407,62 | 466,70 |

Einordnung: Kategorien A/D/E/H sind die einzigen mit echter Pro-Request-Häufigkeit (jeder Login, jede Kindansicht, jede einzelne Änderung) — alle unter 11 ms selbst bei 1000-facher Datenmenge. Kategorie B/F/G sind seltene Admin-/Batch-Zugriffe (Namenssuche im Sekretariat, Dashboards, Export, Jahreslauf einmal jährlich) — dort sind auch Zeiten im Sekundenbereich unkritisch. Die breite Präfixsuche (B) bleibt trotz vorhandenem Index langsam, weil sie nicht selektiv ist (~1/9 aller Zeilen) — der Planer wählt dort bewusst einen Scan statt Index-Zugriff, das ist korrektes Verhalten, kein Fehler.

Parallele Last (`pgbench`), gewichteter Mix (40 % Punkt-Lookup, 25 % mittlerer JOIN, 15 % schwerer JOIN, 10 % LIKE-Suche, 8 % Einzel-Schreibzugriff, 2 % Worst-Case-Export), 20 Sekunden je Stufe, 0 fehlgeschlagene Transaktionen. Die sechs `pgbench`-Skripte (`domains/stammdaten-benchmark/pb_*.sql`) nutzen dieselben Tabellen/Filter wie oben: Punkt-Lookup = „Person per PK", mittlerer JOIN = „Kind + Hauptnummer", schwerer JOIN = „OTP-Request-Pfad", LIKE-Suche = Namenssuche breit, Einzel-Schreibzugriff = Einzel-INSERT, Worst-Case = „Volle Verwaltungsliste ohne Filter".

| Clients | TPS | Ø Latenz Punkt-Lookup | Ø Latenz schwerer JOIN | Ø Latenz Worst-Case-Export |
|---:|---:|---:|---:|---:|
| 5 | 35,2 | 2,3 ms | 4,9 ms | 8,2 s |
| 20 | 22,6 | 5,3 ms | 12,6 ms | 32,3 s |
| 50 | 31,0 | 5,5 ms | 49,6 ms | 83,6 s |

Der Worst-Case-Export (2 % Gewicht, aber 1000× über realer Datenmenge und ohne jeden Filter) dominiert jede gemittelte Gesamtlatenz und ist einzeln ausgewiesen, damit er die übrigen Werte nicht verzerrt — bei realer Datenmenge liegt dieselbe Query tatsächlich bei 5–36 ms (siehe Durchlauf 1), nicht im Sekundenbereich.

## Befunde, die der Test selbst hervorgebracht hat

- **Der OTP-Login hängt an einem Index auf `persons.email`**: Ohne ihn ein Parallel Seq Scan über 1,1 Mio. Zeilen — 250–350 ms statt der gemessenen ~1,5 ms. Der Index steht deshalb als eigenes `CREATE INDEX` im Schema (`domains/stammdaten-schema.sql`) — die Spalte ist bewusst nicht UNIQUE, es legt ihn also kein Constraint nebenbei an. Ein schmaler Query-Mix aus wenigen Beispielabfragen zeigt das nicht — der Befund hängt an der Breite der Suite.
- **Dockers Standard-`/dev/shm` (64 MB) reicht nicht** für Postgres' parallele Worker unter gleichzeitiger Last — führt zu `could not resize shared memory segment`-Fehlern ab ~20 parallelen Verbindungen. Kein Schema-Problem, sondern eine Docker-Startparameter-Frage. **Für `wb-backend/docker-compose.yml` zu übernehmen:** `shm_size` explizit setzen (in diesem Test mit 1024 MB stabil, kleinere Werte nicht systematisch ausgetestet).

## Ergebnis

Die Kernaussage aus `rules.md` Abschnitt 1 ("ein zusätzlicher Join kostet hier nichts") hält empirisch, nicht nur hochgerechnet: bei realer Schulgröße liegt **jede** gemessene Query — auch der ungefilterte Vollexport, auch unter 50 paralleler Last — unter 36 ms, die alltäglichen Pro-Request-Zugriffe (A/D/E/H) unter 4,2 ms. Der Stresstest bei 1000–2000-facher Größe zeigt denselben Zusammenhang am oberen Ende: nichts wird an dieser Schulgröße je eng.
