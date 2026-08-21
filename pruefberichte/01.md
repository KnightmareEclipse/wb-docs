# Prüfbericht — das gebaute Schema gegen die Soll-Blöcke

Lauf gegen Postgres 17 im Container. Ladelauf und alle vierzehn Prüfskripte gegen die
vollständige Datenbank: Rückgabewert 0 durchgängig, in der vorgegebenen Reihenfolge und
zusätzlich in umgekehrter — an `stammdaten` und `querschnitt` hängt tatsächlich keine
Domäne an einer anderen.

Sammlung je Domäne, in der Reihenfolge der Prüfung. Sortierung nach Gewicht am Ende.

**Zweiter, unabhängiger Lauf.** Ein weiterer Durchgang gegen dieselben Quellen hat die
Funde unten bestätigt und achtzehn ergänzt; sie stehen in ihren Domänen-Abschnitten und
tragen fortlaufende Kennungen (S12, Q8–Q13, A9–A14, F5/F6, G5, M3, N2). Zwei vorhandene
Funde sind erweitert: A1 um zwei weitere Fälle, G3 um die Stelle, an der die Auslassung im
Zitat den Widerspruch verbirgt. Ladelauf und alle vierzehn Prüfskripte auch in diesem Lauf
Rückgabewert 0; zusätzlich mechanisch geprüft, dass keine `expect_accept`-Probe null Zeilen
schreibt und dass jede `expect_reject`-Probe an dem Constraint scheitert, den ihre Regel
nennt (Instrumentierung der beiden Hilfsfunktionen in einer Kopie, die Skripte selbst
unverändert).

**Dritter, unabhängiger Lauf.** Ein dritter Durchgang, ohne Kenntnis dieses Berichts
geführt und erst danach eingearbeitet. Er hat die schweren Funde unabhängig
reproduziert — S1, S3, S4, S9, Q2, Q6, Q9, Q13, A1, A2, A4, A6, A7, E3, F2, F6, G1, G3,
M2, P1, R1, R2, R3, X2 sind darin ein zweites bzw. drittes Mal unabhängig gefunden
worden — und **neunzehn ergänzt**: S13–S16, Q14–Q16, A15/A16, P3/P4, F7/F8, G6/G7, M4,
R4, N3, X3. Ein Fund widerspricht dem zweiten Lauf und steht deshalb als solcher
gekennzeichnet da (**M4**). Ladelauf und alle vierzehn Prüfskripte auch hier
Rückgabewert 0; die Instrumentierung der Hilfsfunktionen ist unabhängig wiederholt
worden, mit demselben Ergebnis (keine Probe läuft ins Leere).

---

## stammdaten

```
[S1] stammdaten · Klasse 1 · children
Block 04, „Was dabei erhoben wird": „Dazu, wer seine Stufe wiederholt — ohne Grund,
der fällt außerhalb." Block 15 liest es ebenfalls („Ausgelesen wird … wer wiederholt").
Es gibt dafür in keiner der vierzehn .sql eine Spalte, keinen Constraint und keine
begründete Auslassung; `grep -rin "wiederhol\|repeat" schema/*.sql` ist leer.
Vorschlag: `children.repeats_grade_school_year smallint` (das Schuljahr, für das es gilt)
statt eines Booleans, das jemand jedes Jahr zurücksetzen müsste.
```

```
[S2] stammdaten · Klasse 4 · class_teachers
stammdaten-schema.sql:696 sagt „Löschanker: keiner eigener, die Zuordnung geht mit dem
Mitarbeitenden". `fk_class_teachers_employee` (Z. 714) hat kein ON DELETE, also NO ACTION:
Sie geht nicht mit, sie blockiert das Löschen des Mitarbeitenden. `employee_roles`, im
selben Abschnitt und mit derselben Begründung, steht auf CASCADE.
Vorschlag: ON DELETE CASCADE wie bei `employee_roles` — oder den Kommentar auf das
umschreiben, was der Fremdschlüssel wirklich tut.
```

```
[S3] stammdaten · Klasse 5 · employee_roles
`uq_employee_roles UNIQUE (employee_id, role_id, school_branch_id)` (Z. 690) trägt für
alle Rollen außer der Schulleitung nichts: `school_branch_id` ist dort NULL, und NULL ist
in einem UNIQUE nicht mit NULL identisch. Empirisch geprüft — dieselbe Rolle „Sekretariat"
liegt zweimal an derselben Person, ohne dass etwas eingreift.
Vorschlag: `UNIQUE NULLS NOT DISTINCT (employee_id, role_id, school_branch_id)`.
```

```
[S4] stammdaten · Klasse 1 · employee_roles / roles
hebel.md, „Rollen": „Die Schulleitung gibt es zweimal, je Schulform eine … Eine
Schulleitung sieht und entscheidet, was zu einem Kind ihrer Schulform gehört … und für die
andere Schulform nichts." `roles.is_branch_bound` steht da und steuert nichts: empirisch
lässt sich eine Schulleitungs-Rolle ohne `school_branch_id` speichern (sie sähe dann beide
Schulformen) und eine zweigfreie Rolle mit Zweig.
Vorschlag: zusammengesetzter Fremdschlüssel (`role_id`, `is_branch_bound`) plus CHECK
„is_branch_bound = (school_branch_id IS NOT NULL)" — dasselbe Muster wie
`fk_children_class` es für Klasse und Schulart schon nutzt.
```

```
[S5] stammdaten · Klasse 5 · employee_roles
`employee_roles` kommt in stammdaten-schema-check.sql überhaupt nicht vor — kein INSERT,
keine Gegenprobe, der Constraintname steht nicht in der Liste in Abschnitt 2. Die Tabelle
trägt die Rollenvergabe aus Block 00 und die Zweigbindung aus hebel.md; beides gilt damit
nach dem Maßstab des Prüfskripts als nicht gebaut. Dasselbe für `uq_family_contacts`.
Vorschlag: je eine Gegenprobe für S3 und S4, sobald sie gebaut sind.
```

```
[S6] stammdaten · Klasse 6 · phone_numbers
`note` trägt laut eigenem Kommentar (Z. 322) „die Erreichbarkeit dieser Nummer („mobil,
tagsüber") — der Sachverhalt, den 02 abfragt, wenn eine Notfallnummer gesucht wird".
Genau denselben Sachverhalt trägt zwei Zeilen weiter `reachable_daytime`. rules.md
Abschnitt 1: „kein Attribut darf je nach Fall in zwei Tabellen stehen können" — hier steht
es in zwei Spalten derselben Zeile, und die Pflicht aus 02 hängt an der einen davon.
Vorschlag: den Kommentar an `note` auf das reduzieren, was `reachable_daytime` nicht
trägt (die Art der Erreichbarkeit), oder `note` streichen.
```

```
[S7] stammdaten · Klasse 3 · stammdaten-schema-check.sql
Drei Gegenproben belegen ihre Regel mit einer Quelle, die es nicht gibt: „W7: „dadurch
wissen wir, wo wir zuerst anrufen sollen"" (Z. 419), „W3: „eine fixe ID ist immer besser
als etwas, das sich ändern kann."" (Z. 434), „W12: „alte Werte deaktivieren, aber den
Altbestand nicht verlieren."" (Z. 442). Weder die Kürzel W3/W7/W12 noch die drei Sätze
stehen irgendwo in wb-brainstorming oder wb-docs.
Vorschlag: auf einen Soll-Block bzw. rules.md Abschnitt 3 umhängen — oder, wo es keinen
gibt (die Hauptnummer, siehe S8), die Probe streichen.
```

```
[S8] stammdaten · Klasse 7 · phone_numbers
`is_primary` samt `ix_phone_numbers_primary` steht gegen grenzkarte.md („die Notfallnummer
bekommt kein eigenes Feld"), und der Kommentar dazu (Z. 317–320) räumt selbst ein: „kein
Block nennt eine solche Reihenfolge". Belegt ist damit allein `reachable_daytime` — das
verlangt Block 02 wörtlich. Die einzige Begründung für `is_primary` ist das nicht
existierende W7 aus S7.
Vorschlag: `is_primary` und seinen Index streichen, bis ein Block eine Reihenfolge nennt.
```

```
[S9] stammdaten · Klasse 1 · persons / family_guardians
Block 02: „Mindestens eine Mailadresse je Familie ist Pflicht, damit keine Familie ohne
Kanal ist" und „die letzte Mailadresse und die letzte Notfallnummer lassen sich nur
ersetzen, nie löschen". Für die Notfallnummer steht die begründete Auslassung im Schema
(Z. 310–311, „bewusst NICHT als Constraint"), für die Mailadresse steht nichts — weder
Spalte noch Constraint noch Satz. Empirisch legt eine `families`-Zeile ohne jede Adresse
sich ohne Weiteres an.
Vorschlag: dieselbe begründete Auslassung wie bei der Notfallnummer an `families`
notieren, damit sichtbar bleibt, dass die Pflicht in der Anwendung liegt.
```

```
[S10] stammdaten · Klasse 3 · family_guardians
`ck_family_guardians_access_level` als CHECK statt Lookup wird begründet mit „weil die
Ausprägung strukturell entscheidet, wer unterschreiben muss und was das Portal zeigt
(rules.md Abschnitt 3, Ausnahme)". Die Ausnahme in rules.md Abschnitt 3 lautet aber:
„wenn eine Ausprägung strukturell entscheidet, welche anderen **Spalten derselben Zeile**
Pflicht sind". Das tut die Einsichtsstufe nicht; die Begründung verbreitert die Regel.
Vorschlag: entweder Lookup wie bei den übrigen Kategoriewerten, oder die Begründung auf
das stützen, was wirklich trägt (drei feste Stufen aus hebel.md, nicht umbenennbar).
```

```
[S11] stammdaten · Klasse 3 · children (Kommentar Z. 528–529)
Zitiert wird 02 mit „einmal an der Familie gemacht wird, nicht je Kind". Der Block sagt:
„Eine Änderung, die mehrere Kinder betrifft, wird einmal an der Familie gemacht, nicht je
Kind." Sinngemäß richtig, wörtlich nicht.
Vorschlag: Wortlaut übernehmen.
```

```
[S12] stammdaten · Klasse 3 · stammdaten-schema.sql:766
„Trägt das Ratelimit „höchstens fünf je Adresse und Stunde" (hebel.md)." hebel.md schreibt
„je Adresse und Stunde gibt es höchstens fünf". Umgestellt, nicht zitiert — und zwei Sätze
weiter oben (Z. 724–726) steht derselbe hebel.md-Absatz korrekt wörtlich da.
Vorschlag: Wortlaut übernehmen.
```

```
[S13] stammdaten · Klasse 1 · login_codes
Der Kommentar (Z. 724–726) zitiert hebel.md vollständig: „Er gilt 15 Minuten und nur
einmal, verfällt nach fünf Fehleingaben, und je Adresse und Stunde gibt es höchstens
fünf." Zwei der drei Zahlen sind gebaut (`ck_login_codes_attempts`,
`ck_login_codes_purpose`), die dritte trägt nur `expires_at > created_at` — ein Code mit
drei Stunden Gültigkeit geht durch, empirisch geprüft. Die fünfte Zahl je Stunde trägt
ehrlich nur ein Index („Trägt das Ratelimit"). Für die 15 Minuten steht weder ein
Constraint noch eine begründete Auslassung, obwohl derselbe Absatz „Alle Zahlen sind fest
und nirgends einstellbar" als Herkunft dient. Dasselbe Muster bei den 14 Tagen der
Freischaltung (`application_unlocks`) und des Kostenübernahme-Codes.
Vorschlag: `CHECK (expires_at = created_at + interval '15 minutes')` — oder eine Zeile,
die die Frist ausdrücklich der Anwendung überlässt, wie es die Notfallnummer vormacht.
```

```
[S14] stammdaten · Klasse 6 · children.grade_level
`ck_children_grade_level CHECK (grade_level BETWEEN 1 AND 10)` schreibt die beiden
Grenzen hart hin, obwohl `school_branches.first_grade_level`/`final_grade_level` sie
tragen — und der Kommentar an `school_branches` diese beiden Spalten ausdrücklich als die
Quelle nennt („`final_grade_level` entscheidet im Jahreslauf (04), wer zum 31. Juli
abgeht"). Damit steht dieselbe Tatsache zweimal, und die harte Fassung ist nicht an die
weiche gebunden: empirisch geprüft, ein Grundschulkind mit `grade_level = 9` geht durch.
Anders als der Klassenfall, den Block 15 bewusst offen lässt („gesperrt wird nichts"),
geht es hier nicht um eine Zuordnung, sondern um einen Wert, den keine Schulart hergibt.
Vorschlag: gegen `school_branches` binden (zusammengesetzter Fremdschlüssel auf
`(school_branch_id, first_grade_level, final_grade_level)`) oder 1..10 als abgeleitete
Grenze im Kommentar kennzeichnen.
```

```
[S15] stammdaten · Klasse 3 · login_codes ([A!], Z. 730–733)
„weil grenzkarte.md dem Eltern-Selfservice (8) „keine eigenen Entitäten" gibt". In
grenzkarte.md steht in der Tabellenzelle allein das Wort „keine", unter der
Spaltenüberschrift „Eigene Entitäten". Der zitierte Ausdruck ist aus Zelle und
Spaltenkopf zusammengesetzt — die Aussage stimmt, die Anführungszeichen tragen sie nicht.
Vorschlag: ohne Anführungszeichen wiedergeben.
```

```
[S16] stammdaten · Klasse 5 · stammdaten-schema-check.sql
Der Sollstand-Kommentar (Z. 9–10) nennt „zwei partielle bzw. unterstützende Indizes
(ix_sepa_mandates_current, ix_login_codes_email_created)"; Abschnitt 2 prüft nur den
ersten auf Existenz. Der zweite trägt laut Schema das Ratelimit aus hebel.md und fiele
beim Streichen unbemerkt weg.
Vorschlag: zweiten Index in dieselbe Existenzprüfung aufnehmen.
```

**Angesehen, nicht als Fund gewertet**

- `class_teachers` trägt „mehrere möglich" aus Block 15, das „Pflicht" desselben Satzes
  verliert sie: keine Klasse braucht eine Zeile. Nicht als Fund gewertet, weil es die
  unvermeidliche Folge der `[A!]`-Entscheidung ist — erwähnenswert bleibt, dass der
  `[A!]` diesen Preis nicht nennt, während er den der Gegenrichtung nennt.
- `employees.first_working_day` nullable, obwohl grenzkarte.md Q4 den Zeitraum „beidseitig
  nötig" nennt: Block 13 sagt „auf Wunsch der erste Arbeitstag" und „Freiwillig sind zwei:
  der erste Arbeitstag" — der Block ist jünger und entscheidet die Sache, die Grenzkarte
  ist damit zulässig überstimmt.
- `ck_sepa_mandates_holder`, `ck_sepa_mandates_bic` und `uq_sepa_mandates_reference`:
  jede der drei Gegenproben verletzt zugleich `ix_sepa_mandates_current`. Einzeln
  abgesetzt und den Constraintnamen gelesen — es greift jeweils der gemeinte.
- `children` ohne eigene `address_id`: die Anschrift steht an `persons`, das Kind ist eine
  Person. Kein zweiter Ort.
- Kind in einer Klasse falscher Stufe ist nicht gesperrt — Block 15 will das so
  („steht das Kind sichtbar ohne passende Klasse … gesperrt wird nichts").

---

## querschnitt

```
[Q1] querschnitt · Klasse 2 · consents
`delivery_address text NOT NULL` (Z. 306). README.md, „Was danach passiert":
„Der Vollimport bringt die eingeschriebenen Kinder mit, aber nicht die Bestände …
Gesundheitsangaben, Fotoeinverständnis … Das Sekretariat trägt sie aus den Akten
nach, Kind für Kind." Ein aus der Papierakte nachgetragenes Fotoeinverständnis hat
keine Zustelladresse; grenzkarte.md begründet das Feld gegen die Ableitung aus
`persons.email`, nicht gegen den Papierfall. Das NOT NULL zwingt beim Vollimport
Ende August 2026 zu einer erfundenen Adresse.
Vorschlag: nullable, mit CHECK „delivery_address IS NOT NULL OR created_by LIKE
'entra:%'" — oder schlicht nullable und die Regel in der Strecke.
```

```
[Q2] querschnitt · Klasse 1 · consent_purposes / consents
`consent_purposes.requires_child` sagt laut Kommentar (Z. 58–59): „Wahr, wo die
Zustimmung ein Kind betrifft und `consents.child_id` deshalb gesetzt sein muss".
Nichts erzwingt das — empirisch legt sich ein Fotoeinverständnis ohne `child_id`
ohne Weiteres an. Es fiele danach aus beiden Unique-Indizes heraus und aus jeder
Ansicht, die je Kind fragt (08: „für alle Lehrkräfte, Hortkräfte und das
Sekretariat ohne Umweg sichtbar"). Dieselbe Bauform wie `roles.is_branch_bound`
in S4: eine Spalte, die eine Regel benennt und keine trägt.
Vorschlag: zusammengesetzter Fremdschlüssel (`consent_purpose_id`,
`requires_child`) plus CHECK „NOT requires_child OR child_id IS NOT NULL".
```

```
[Q3] querschnitt · Klasse 1 · change_log
Block 02, „Was dabei erhoben wird": „Bei einer Rechteänderung zusätzlich, dass ein
Nachweis vorlag und wer ihn gesehen hat." `change_log` trägt Tabelle, Zeile,
Spalte, Alt- und Neuwert — „dass ein Nachweis vorlag" ist kein Spaltenwert der
geänderten Zeile und hat damit keinen Ort. selfservice-schema.sql:37–39 behauptet
das Gegenteil: „im System steht nur, dass einer vorlag" — und das trägt die
Änderungsspur … nicht ein eigenes Feld". Sie trägt es nicht.
Vorschlag: `family_guardians.proof_seen_at`/`proof_seen_by` an der Zeile, die die
Rechtelage trägt — oder eine benannte Spalte in `change_log`, wenn es dort
bleiben soll.
```

```
[Q4] querschnitt · Klasse 4 · consents
„Löschanker: geht mit dem Kind bzw. mit der Person" (Z. 289). `fk_consents_child`
und `fk_consents_person` stehen auf NO ACTION: sie gehen nicht mit, sie halten
das Löschen des Kindes bzw. der Person auf. Wo dieselbe Formel im Bestand steht,
steht CASCADE daneben (`phone_numbers`, `employee_roles`, `family_contacts`);
wo NO ACTION gewollt ist, steht der Grund dabei (`documents`: „bewusst OHNE
Cascade", weil zuerst die SharePoint-Datei weg muss). Hier steht keiner.
Vorschlag: CASCADE, oder den Grund für NO ACTION hinschreiben.
```

```
[Q5] querschnitt · Klasse 6 · sync_tasks
`created_by` trägt in allen vierzehn Dateien den Präfix-CHECK
„^(entra:|guardian:|system:)"; `completed_by` (Z. 409) trägt keinen — empirisch
geht „irgendwer" als Abhaker durch. Block 02 verlangt „wer sie abgehakt hat",
Block 03 „durch wen", und die Änderungsspur nebenan lässt genau diesen Wert nicht
formlos zu.
Vorschlag: `ck_sync_tasks_completed_by` analog zu `ck_sync_tasks_created_by`.
```

```
[Q6] querschnitt · Klasse 3 · child_file_folders
Zitiert wird grenzkarte.md mit „Der Ordner der Schülerakte braucht einen Anker in
der Datenbank". Die Quelle sagt: „**Nur** der Ordner der Schülerakte braucht
einen Anker". Das weggelassene Wort ist genau das, das die zweite Bibliothek von
der ersten trennt — und die Tabelle daneben legt die beiden Bibliotheken zu einer
zusammen. Ein Zitat, das die Abweichung, die es begründen soll, aus der Quelle
herausschneidet.
Vorschlag: Wortlaut übernehmen; die Zusammenlegung steht ohnehin eine Zeile
weiter oben mit eigener Begründung da und braucht das Zitat nicht.
```

```
[Q7] querschnitt · Klasse 3 · Dateikopf
Z. 32: „Fünf Fremdschlüssel dieser Datei zeigen vorwärts" — es sind sechs. In der
Aufzählung fehlt `signatures.care_module_agreement_id`, nachgetragen in
anmeldung-schema.sql:711. Wer die Liste als vollständig liest, hält die Spalte
für einen Verweis ohne Fremdschlüssel.
Vorschlag: sechs, und die Spalte in die Aufzählung.
```

```
[Q8] querschnitt · Klasse 4 · outbound_emails
„Löschanker: geht mit der Person, an die sie ging" (Z. 492). Gebaut ist
`fk_outbound_emails_person … ON DELETE SET NULL` — die Zeile geht gerade **nicht** mit:
sie bleibt stehen, behält `recipient_email` (ein Personendatum) und verliert den einzigen
Bezug, an dem eine Frist noch rechnen könnte. Von allen personengebundenen Tabellen ist
sie die einzige mit SET NULL; alle anderen sind CASCADE oder NO ACTION. rules.md
Abschnitt 7 („Log- und Backup-Retention ist zeitlich begrenzt und dokumentiert, nie
unbegrenzt") trifft genau diesen Rest.
Vorschlag: CASCADE, und für die Zeilen ohne Person (05, 09, 10) eine eigene benannte
Frist an der Adresse.
```

```
[Q9] querschnitt · Klasse 1 · configured_values
hebel.md, „Geld im System": „ein noch nicht gültiger lässt sich bis dahin ändern oder
zurücknehmen, **ein bereits gültiger nicht mehr**." Der Kommentar an der Tabelle (Z. 478–479)
übernimmt die erste Hälfte des Satzes wörtlich und lässt die zweite weg; für sie steht
weder ein Constraint noch eine begründete Auslassung da. Dieselbe Regel trägt
`contract_texts` und die beiden Preistabellen der Domänen (`care_module_prices`,
`holiday_module_prices`) — an keiner der vier steht sie.
Vorschlag: die Unveränderlichkeit ab `valid_from` als benannte Auslassung an
`configured_values` festhalten; in reinem SQL ist sie nicht ausdrückbar, weil `now()` in
keinem CHECK zulässig ist.
```

```
[Q10] querschnitt · Klasse 1 · signatures (zweiter Beleg zu P2)
`signature_image_item_id text` (Z. 198) trägt den Namenszug als Graph-Element-Kennung ohne
Bibliothek — dieselbe halbe Referenz wie `cleaning_slots.attendance_scan_item_id` in P2,
gegen denselben Satz aus grenzkarte.md („Bibliothek plus Element, beide nur gemeinsam
gültig"). `expense_claim_attachments` zeigt die vollständige Form daneben, samt
`UNIQUE (sharepoint_library_id, graph_item_id)`. Damit sind es zwei von fünf
Dateireferenzen im Schema, die nur die halbe Kennung führen.
Vorschlag: `sharepoint_library_id` an beiden Stellen ergänzen.
```

```
[Q11] querschnitt · Klasse 4 · consents (Ergänzung zu Q4)
Der Löschanker nennt zwei: „geht mit dem Kind **bzw.** mit der Person, je nachdem, worauf
die Zeile zeigt". Eine Fotoeinverständnis-Zeile zeigt auf beide — `person_id` ist Pflicht,
`child_id` steht daneben —, und die beiden Anker laufen auseinander: das Kind rechnet ab
seinem Ende (03), der Sorgeberechtigte an der Familie. Welcher der beiden die Zeile
löscht, sagt keine Zeile im Schema.
Vorschlag: den maßgeblichen Anker benennen — naheliegend das Kind, wo `child_id` steht,
sonst die Person.
```

```
[Q12] querschnitt · Klasse 5 · ix_consents_person_purpose
Die kindlose Variante des Eindeutigkeits-Index hat keine Gegenprobe. Geprüft wird allein
`ix_consents_person_child_purpose` („zweite gültige Antwort derselben Person zu demselben
Kind und Zweck"); für einen Zweck ohne Kindbezug — die Werbe-Einwilligung der
Ferienbetreuung, im Skript als Stammsatz vorhanden — belegt nichts, dass die zweite
gültige Antwort abgewiesen wird.
Vorschlag: eine Gegenprobe mit `marketing_holiday` ohne `child_id`.
```

```
[Q13] querschnitt · Klasse 3 · querschnitt-schema.sql:437
„Höchstens eine offene Aufgabe je Art und Bezug" in Anführungszeichen; hebel.md schreibt
„Je Aufgabenart und Bezug gibt es höchstens eine offene Aufgabe". Umgestellt — und
48 Zeilen darüber (Z. 389) steht derselbe Satz wörtlich richtig.
Vorschlag: Anführungszeichen streichen oder den Wortlaut von oben übernehmen.
```

```
[Q14] querschnitt · Klasse 1 · change_log gegen employee_roles
Block 00: „je Mitarbeitendem seine Rollen, samt wer sie wann vergeben **oder entzogen**
hat (Änderungsspur), sichtbar für Admins und Geschäftsführung", und stammdaten verweist
dafür ausdrücklich auf die Spur („Bewusst KEIN Entzugsdatum als eigener Lebenslauf …
die Spur trägt den Verlauf"). Ein Entzug ist im Modell aber das Löschen einer
`employee_roles`-Zeile, und `change_log` kennt nur Spaltenänderungen: `column_name` ist
NOT NULL, `old_value`/`new_value` sind Werte einer Spalte, ein Feld für die Art der
Änderung gibt es nicht. Eine gelöschte Zeile lässt sich darin nur als Konvention
abbilden — je Spalte eine Zeile mit leerem Neuwert —, und diese Konvention steht
nirgends: nicht im Schema, nicht im Prüfskript, das dazu keine Gegenprobe hat. Damit ist
die einzige Stelle, an der der Entzug einer Rolle nachlesbar sein soll, nicht
verabredet.
Vorschlag: `change_log.operation text CHECK (operation IN ('insert','update','delete'))`
— dann trägt eine Zeile den gelöschten Datensatz auch ohne Spaltennamen.
```

```
[Q15] querschnitt · Klasse 2 · consents
`ck_consents_revocation` prüft, dass ein Widerruf eine Erteilung voraussetzt, nicht aber
ihre Reihenfolge: empirisch geprüft steht `revoked_at` zehn Tage **vor** `granted_at`.
Dieselbe Datei und ihre Nachbarn bauen die Reihenfolge sonst überall
(`ck_children_exit_after_entry`, `ck_employees_working_days`,
`ck_care_module_agreements_period`, `ck_meal_subscriptions_period`). Grenzkarte.md, Q1:
der Zeitpunkt ist der Nachweis nach Art. 7 Abs. 1 DSGVO — eine Erteilung, die nach ihrem
Widerruf datiert, ist als Nachweis wertlos.
Vorschlag: `CHECK (revoked_at IS NULL OR revoked_at >= granted_at)`.
```

```
[Q16] querschnitt · Klasse 7 · signatures.signature_level
`ck_signatures_level CHECK (signature_level IN ('simple','advanced','qualified'))`.
rules.md Abschnitt 3 verlangt für Kategoriewerte eine Lookup-Tabelle und nimmt davon nur
aus, was „strukturell entscheidet, welche anderen Spalten derselben Zeile Pflicht sind" —
das Niveau tut das nicht, und anders als bei `family_guardians.access_level` (S10) steht
hier gar keine Begründung. Dazu nennt kein Block die beiden Werte `advanced` und
`qualified`: grenzkarte.md schreibt „heute durchgängig einfache elektronische Signatur",
und Block 08 verwirft das elektronische Siegel ausdrücklich („wird bewusst **nicht**
beschafft"). Zwei Ausprägungen auf Vorrat, gegen rules.md Abschnitt 1 Punkt 1.
Vorschlag: auf `'simple'` verengen und die Begründung danebenschreiben — oder Lookup.
```

**Angesehen, nicht als Fund gewertet**

- `signatures` und der größte Teil von `payments` haben in querschnitt-schema-check.sql
  keine Gegenprobe — beides steht dort begründet (der Fremdschlüssel entsteht erst in
  anmeldung bzw. putzdienst) und die Proben stehen wirklich dort.
- `ix_consents_person_child_purpose` sah nach Klasse 2 aus (nur eine gültige Antwort je
  Person, Kind und Zweck): grenzkarte.md und Block 08 wollen genau das, die frühere
  Antwort wird ersetzt und der Verlauf steht in der Änderungsspur.
- `documents.child_id NOT NULL`, obwohl grenzkarte.md „Bezug (Kind bzw. Vorgang)" sagt:
  jeder in den Blöcken genannte Dokumenttyp hängt an einem Kind.

---

## anmeldung

```
[A1] anmeldung · Klasse 2 · contracts
`ix_contracts_running ON contracts (child_id, contract_type) WHERE end_date IS NULL`
(Z. 597). Block 08: „Die Einschreibung besteht ab der Freigabe und wirkt zum
Eintrittsdatum"; Block 04: der Schulvertrag der auslaufenden Schulart endet erst
zum 31. Juli. Der eigene Viertklässler, der in die eigene Realschule wechselt
(05, 07, 08), hat damit von der Freigabe im Winter bis zum 31. Juli **zwei**
laufende Schulverträge. Empirisch geprüft: der zweite wird abgewiesen. Der Fall
ist in vier Blöcken als Normalfall benannt und im Prüfskript nicht abgedeckt —
es gibt keine Gegenprobe zu einem zweiten laufenden Schulvertrag.
Zwei weitere Fälle brechen an demselben Index: der **Hortvertrag für Klasse 5**,
den Block 04 verlangt („Wer in Klasse 5 weiter Betreuung braucht, schließt einen
neuen") und dessen Antrag ebenfalls vor dem 31. Juli entsteht — empirisch
geprüft, abgewiesen —, und der **Rücktritt vor der Freigabe** (08): die
`contracts`-Zeile bleibt ohne `released_at` und ohne `end_date` stehen, und der
zweite Anlauf („nach Absage oder Rückzug ist der zweite Anlauf eine neue
Bewerbung", 05) kollidiert mit ihr.
Vorschlag: den Index auf (child_id, contract_type, school_branch_id des
Vertrags) ziehen oder die Überlappung über `runs_until` statt `end_date IS NULL`
abgrenzen.
```

```
[A2] anmeldung · Klasse 2 · care_module_agreements
`ix_care_module_agreements_running ON care_module_agreements (contract_id)
WHERE valid_until IS NULL` (Z. 675). Block 09, Schritt 6: „Eine Anpassung
beantragen die Eltern im Portal und **unterschreiben die neue Modulanlage** …,
die Hortleitung gibt sie frei." Die neue Anlage muss also existieren und
unterschrieben sein, bevor sie freigegeben ist — `valid_until` ist dann NULL,
genau wie bei der laufenden. Empirisch geprüft: der Antrag wird abgewiesen.
Damit gibt es im Modell keinen Weg, eine Anpassung zu beantragen.
Das Prüfskript zementiert die falsche Lesart: `'09 — zweite laufende Anlage an
demselben Vertrag'` ist eine `expect_reject`-Probe.
Vorschlag: das Kriterium der „laufenden" Anlage auf `released_at IS NOT NULL AND
valid_until IS NULL` verengen — dann steht die beantragte daneben.
```

```
[A3] anmeldung · Klasse 2 · sync_tasks (querschnitt) gegen Block 09
Block 09, Fremdsysteme: „Nur Optigem …: je Kind **eine** Aufgabe … Die
Änderungsgebühr läuft darin nicht mit … Sie wird deshalb eine **eigene
Aufgabe** — angelegt mit der Freigabe der Anpassung." `ix_sync_tasks_open_child
(sync_target_id, child_id) WHERE completed_at IS NULL` lässt genau eine offene
Optigem-Aufgabe je Kind zu. Empirisch geprüft: die zweite wird abgewiesen.
Die Ursache ist, dass „Aufgabenart" im Schema als Zielsystem modelliert ist
(`sync_targets`, Kommentar: „Die Art ist das Ziel, nicht der Anlass") — für die
Änderungsgebühr verlangt der Block aber eine zweite Art beim selben Ziel.
Vorschlag: `sync_targets` in Ziel + Aufgabenart trennen (zwei Zeilen „Optigem
Beitragslage" und „Optigem Einmalforderung") und die Indizes auf die Art ziehen.
```

```
[A4] anmeldung · Klasse 1 · applications
Block 06: „Der **Betreuungsbedarf** — Kernzeit, Nachmittag, Ganztags
(freiwillig) — ist dieselbe Angabe wie das Betreuungsinteresse aus 05, **hier um
den Umfang ergänzt**." Block 09 liest ihn („der Betreuungsbedarf aus 06 … die
einzige Vorschau darauf, mit wie vielen Kindern die Hortleitung im nächsten Jahr
rechnen muss"), grenzkarte.md nennt ihn auf allen vier Checklisten.
Im Schema steht dafür allein `applications.care_interest boolean` — der Umfang
hat keine Spalte, keine Werteliste und keine begründete Auslassung.
Vorschlag: `care_need_level_id` als Werteliste (Kernzeit / Nachmittag /
Ganztags) neben dem Boolean, nullable.
```

```
[A5] anmeldung · Klasse 1 · documents (querschnitt) gegen Block 06
Block 06: „**Unterlagen**, je Stück vorgelegt, fehlt oder **nicht nötig**".
`documents` trägt drei Stände: keine Zeile = nie verlangt, `requested_at` ohne
`graph_item_id` = fehlt, mit Datei = vorgelegt. „nicht nötig" — die ausdrückliche
Feststellung des Sekretariats, dass diese Unterlage bei diesem Kind entfällt —
hat keinen Ort und ist von „fehlt" nicht zu unterscheiden.
Vorschlag: `documents.not_required_at timestamptz`, im `ck_documents_purpose`
als dritter Summand.
```

```
[A6] anmeldung · Klasse 1 · applications
Block 06: „Für alles, was am Anmeldetag nur erklärt wird — Elternmitarbeit (14)
und Putzdienst, dass die örtlich zuständige Schule bis zur Zusage angemeldet
bleibt, dass der Schulvertrag per Mail kommt, begrenzte Hortplätze und feste
Tage, Förderverein, VVS-Infoblatt und Preisliste —, gibt es **einen** Haken,
nicht je Punkt einen." Diesen einen Haken gibt es im Schema nicht;
`documents_checked_at` ist die Unterlagenprüfung, `attended_info_evening` der
Infoabend. Ohne ihn ist am Ende der Spur nicht ablesbar, ob die Punkte
besprochen wurden.
Vorschlag: `applications.information_given_at timestamptz`.
```

```
[A7] anmeldung · Klasse 6 · contracts / signatures
`contracts.contract_text_id` und `signatures.contract_text_id` tragen denselben
Sachverhalt: Block 08 sagt „Die **Fassung friert mit der Zusage ein** und nicht
erst mit der einzelnen Unterschrift — sonst unterschreiben Mutter und Vater
verschiedene Texte" — genau der Satz, den das Schema an `signatures` zitiert.
Damit ist die Fassung je Vertrag eine, und die zweite Spalte ist der ableitbare
Wert, den rules.md Abschnitt 1 verbietet; nichts bindet sie aneinander.
Vorschlag: zusammengesetzter Fremdschlüssel (`contract_id`, `contract_text_id`)
auf `contracts` — der Ausnahmefall, den rules.md Abschnitt 1 ausdrücklich
erlaubt — oder die Spalte an `signatures` streichen.
```

```
[A8] anmeldung · Klasse 2 · signatures (querschnitt-[A!]) gegen Block 08
`signatures.contract_id uuid NOT NULL`, dazu `ix_signatures_contract
(contract_id, person_id)`. Block 08: „Ab 14 unterschreibt das Kind sein
Fotoeinverständnis mit — über einen Signaturlink, keinen Zugang", und
grenzkarte.md Q2: „Eine Zustimmung aus Q1 zeigt optional auf die Signatur, die
sie belegt." Diese Unterschrift gilt der Zustimmung, nicht dem Vertrag: sie
lässt sich nur speichern, indem das Kind als Unterzeichner des Schulvertrags
erscheint — und in das fertige Dokument gerät, das „alle Unterschriften" trägt.
Zugleich lässt der Unique-Index je Person und Vertrag nur eine Unterschrift zu,
womit ein zweites Ändern des Fotoeinverständnisses („ändern die Eltern danach
jederzeit im Portal", 08) keine Unterschrift mehr tragen kann.
Vorschlag: `contract_id` nullable und ein dritter Bezug `consent_id`, im selben
Entweder-oder-CHECK wie `care_module_agreement_id`.
```

```
[A9] anmeldung · Klasse 1 + Klasse 7 · children.previous_school_id
Block 05: „Bei jedem Ziel in der Grundschule kommt die **örtlich zuständige Schule**
hinzu, über welchen Weg die Bewerbung auch läuft — auch ein Quereinsteiger in
Klasse 2 bleibt dort bis zur Zusage angemeldet. **Das sind zwei Einrichtungen mit
zwei verschiedenen Rollen im Verfahren, keine Alternative zueinander.**"
Das Schema führt für staatliche Schulen genau **eine** Spalte
(`children.previous_school_id`) und folgt damit grenzkarte.md („Verschiedene
Herkunft, dieselbe Rolle im Prozess, deshalb eine Spalte") gegen den jüngeren
Block. Beim Grundschul-Quereinsteiger fallen abgebende und örtlich zuständige
Schule auseinander und passen nicht beide hinein; `applications.kindergarten_id`
trägt nur den Kindergarten. Block 07 hängt die Absage-Mail daran („bei einem Ziel
in der Grundschule dazu, dass die Anmeldung an der örtlich zuständigen Schule
damit trägt"), Block 08 die Schülerüberweisung an die abgebende.
Vorschlag: zweite Spalte für die örtlich zuständige Grundschule — an der
Bewerbung, weil sie nur bis zur Zusage gebraucht wird —, beide auf
`previous_schools`.
```

```
[A10] anmeldung · Klasse 1 · Schulgeld
hebel.md, „Geld im System": „Dazu die beiden größten Beträge, das **Schulgeld je
Schulform** — Grundschule und Realschule kosten verschieden — und der
**Hortbeitrag**." querschnitt-schema.sql:461–464 verweist dafür ausdrücklich
weiter: „Was je Modul, Termin oder Schulart verschieden ist — Hortbeitrag,
Ferienaufschlag, **Schulgeld**, Vertragstext —, trägt seine eigene Tabelle in der
zuständigen Domäne." Der Hortbeitrag hat sie (`care_module_prices`) samt `[?]`;
das Schulgeld hat nichts — keine Tabelle, keine Spalte, keine offene Frage.
`grep -rin "schulgeld\|tuition\|school_fee" schema/*.sql` findet nur zwei
Kommentare und einen Aufgabentext. Block 08 braucht es zweimal: im Vertragstext
und in der Regel „das Schulgeld darin ist der Betrag, der ab dem Eintrittsdatum
gilt, nicht der am Tag der Unterschrift geltende".
Vorschlag: `tuition_fees (school_branch_id, valid_from, monthly_amount_cents)`
nach dem Muster von `care_module_prices`, dazu das `[?]` für die fehlende
Preisliste, das hebel.md ohnehin offen führt.
```

```
[A11] anmeldung + selfservice · Klasse 4 · contracts.released_at als Grenze
selfservice-schema.sql:16–19: wer die Stammdaten des Kindes ändern darf,
entscheide „eine Grenze und keine Feldliste": die Freigabe des ersten Vertrags am
Kind — „im Schema `contracts.released_at` …, **nicht ein Flag daneben**". Für die
Kinder des Vollimports gibt es diese Zeile nicht: README.md — „Der Vollimport
bringt die eingeschriebenen Kinder mit, aber nicht die Bestände, die 08 und 09
sonst anlegen" —, und Block 08 nennt sie „erkennbar daran, dass diese Strecke bei
ihnen nie lief". Nach der gebauten Grenze gehören die Stammdaten dieser Kinder
damit dauerhaft den Eltern, obwohl ASV-BW, Optigem und Akte sie längst kennen —
genau der Fall, den Block 02 mit der Grenze verhindern will.
Vorschlag: die Grenze auf „`contracts.released_at` **oder** `children.entry_date`
gesetzt" stellen und das im Kommentar benennen.
```

```
[A12] anmeldung · Klasse 3 · anmeldung-schema.sql:386
Der Kommentar „Trägt zugleich den dritten Zustand für `attended_info_evening`."
steht unmittelbar über `attended_info_evening` und beschreibt die Spalte damit
durch sich selbst. Gemeint ist `documents_checked_at` eine Zeile darüber — der
Anker aus grenzkarte.md, „Drei Zustände", der die Tabelle dort auch ausdrücklich
nennt. So gelesen behauptet der Kommentar etwas Unmögliches, und der Anker, den
die Grenzkarte verlangt, steht nirgends benannt.
Vorschlag: den Satz an `documents_checked_at` hängen.
```

```
[A13] anmeldung · Klasse 3 · anmeldung-schema.sql:556–557
„ob das Kind den Heimweg allein antreten darf (Pflicht, Ja oder Nein)" (09).
Block 09 schreibt: „Je Kind, ob **es** den Heimweg allein antreten darf (Pflicht,
Ja oder Nein, sichtbar für Hortkräfte und Sekretariat)." Ein Wort ersetzt, das
Ende ohne Auslassungszeichen abgeschnitten.
Vorschlag: Wortlaut übernehmen.
```

```
[A14] anmeldung · Klasse 3 · anmeldung-schema-check.sql:173
„Eine beendete steht dagegen nicht im Weg — der zweite Anlauf ist eine neue
Bewerbung" (05). Der Block schreibt „… — **nach Absage oder Rückzug (07)** ist der
zweite Anlauf eine neue Bewerbung **und kostet die Gebühr erneut**." Zwei
Auslassungen ohne Zeichen, dazu umgestellt.
Vorschlag: Wortlaut übernehmen oder die Anführungszeichen streichen.
```

```
[A15] anmeldung · Klasse 1 · contracts.may_walk_home_alone
Block 09: „Je Kind, ob es den **Heimweg allein** antreten darf (Pflicht, Ja oder Nein,
sichtbar für Hortkräfte und Sekretariat)." `ck_contracts_care_only` baut nur die eine
Richtung — die drei Hort-Angaben stehen nicht am Schulvertrag —, die Pflicht am
Hortvertrag baut es nicht: empirisch geprüft, ein freigegebener Hortvertrag mit
`may_walk_home_alone IS NULL` geht durch. Die Zeile entsteht erst mit dem Absenden des
vollständig ausgefüllten Antrags (09, Schritt 4), ein CHECK wäre also erfüllbar. Dieselbe
Datei baut solche Pflichten sonst genau so (`ck_children_enrolment`).
Vorschlag: `CHECK (contract_type <> 'care' OR may_walk_home_alone IS NOT NULL)`.
```

```
[A16] anmeldung · Klasse 3 · drei Belegstellen
- Z. 320–321: „Nur gesetzt, wo von der Zahl des Tages abgewichen wird; leer heißt „es
  gilt die Zahl des Tages"." Dieser Satz steht in keinem Block und in keiner Referenz
  (grep über soll-prozesse/ und wb-docs/) — er ist die Formulierung des Autors im
  Zitatgewand. Dasselbe Muster wie P4 im Putzdienst („es gilt der Standard").
- Z. 226–227: „bleibt offen, bis eines gesetzt wird" — Block 05 schreibt „bleibt **sie**
  offen, bis eines gesetzt wird".
- Z. 535–536: „die Vollständigkeit sichert der Vorgang, nicht die Alltagsansicht" —
  grenzkarte.md schreibt „Die Vollständigkeit sichert **damit** der Vorgang …".
Vorschlag: beim ersten die Anführungszeichen streichen, bei den beiden anderen den
Wortlaut übernehmen.
```

**Angesehen, nicht als Fund gewertet**

- `applications.waiting_priority` sah nach Klasse 7 aus (grenzkarte.md: „Die Warteliste
  selbst hat keine Rangfolge"): Block 07 entscheidet die Sache anders und wörtlich —
  „Beim Warteplatz die Priorität — eine frei gesetzte Zahl, nach der die Liste sortiert".
- Die harte Platzgrenze je Zeitfenster (06) ist kein Constraint, sondern eine Notiz
  („die Grenze selbst prüft die Anwendung"): Trigger sind für dieses Schema
  ausgeschlossen, und ein Constraint über Zeilen hinweg ginge nicht anders.
- `applications.processing_note` als einziges Freitextfeld für Bearbeitungsstand und
  Anmerkung aus 06 — grenzkarte.md verlangt ausdrücklich eines statt zweier.

---

## putzdienst

```
[P1] putzdienst · Klasse 3 + Klasse 1 · cleaning_slots / cleaning_swap_acceptances
`uq_cleaning_slots_id_type UNIQUE (cleaning_slot_id, cleaning_slot_type_id)`
(Z. 126) trägt den Kommentar „Trägt den zusammengesetzten Fremdschlüssel des
Tauschs weiter unten." Diesen Fremdschlüssel gibt es nicht: beide Fremdschlüssel
auf `cleaning_slots` sind einspaltig, und `cleaning_swap_acceptances` hat gar
keine Typspalte. Damit ist Block 01 — „Getauscht wird eins zu eins, nur gegen
einen bestehenden Termin **derselben Art**" — nirgends gebaut, und das Unique
steht ohne Zweck da.
Das Prüfskript belegt sogar das Gegenteil: `'01 — mehrere angekreuzte
Zieltermine an einem Angebot'` (putzdienst-schema-check.sql:250) kreuzt zu einem
Angebot über einen **regulären** Termin (Slot …881, Art 1) den **Großputz**
…883 (Art 2) an — und gilt als bestanden.
Vorschlag: `cleaning_slot_type_id` an `cleaning_swap_offers` und
`cleaning_swap_acceptances` mitführen und beide per zusammengesetztem
Fremdschlüssel an `uq_cleaning_slots_id_type` binden; dann trägt das Unique, was
sein Kommentar behauptet.
```

```
[P2] putzdienst · Klasse 1 · cleaning_slots
`attendance_scan_item_id text` trägt die eingescannte Unterschriftenliste als
Graph-Element-Kennung — ohne Bibliothek. grenzkarte.md, Q2: „Die Referenz ist die
Graph-Kennung, nie ein Pfad: **Bibliothek plus Element, beide nur gemeinsam
gültig**." Jede andere Dateireferenz im Schema führt beides (`documents`,
`child_file_folders` je mit `sharepoint_library_id`). Hier fehlt die Hälfte, und
es ist zugleich die einzige Datei des Systems, die in keiner der in
querschnitt-schema.sql angelegten Bibliotheken einen Platz hat — sie gehört
keinem Kind.
Vorschlag: `sharepoint_library_id` daneben, und die Bibliothek in die offenen
Fragen von querschnitt-schema.sql aufnehmen.
```

```
[P3] putzdienst · Klasse 4 · cleaning_cycles über cleaning_slot_buyouts an payments
Jede Putzdienst-Tabelle nennt als Löschanker den Zyklus (01: „Gelöscht wird einmal
jährlich zum Schuljahresanfang, und zwar nicht das gerade vergangene Putzdienstjahr,
sondern das davor"). Der Lauf kommt dort nicht an; beide Stufen empirisch geprüft:
- `DELETE FROM cleaning_cycles` scheitert an `fk_cleaning_slots_cycle` (NO ACTION),
- `DELETE FROM cleaning_slots` kaskadiert über Zuteilung auf den Einzel-Freikauf und
  scheitert dann an `fk_payments_cleaning_slot_buyout` (NO ACTION) — die Zahlung hält
  den Vorgang fest, dessen Löschanker sie selbst ist (querschnitt: „geht mit dem
  Vorgang, an dem die Zahlung hängt").
Erst `payments` → `cleaning_slots` → `cleaning_cycles` läuft durch. Diese Reihenfolge
steht in keiner der drei Dateien; dasselbe gilt für `cleaning_buyouts` (Jahres-Freikauf).
Siehe X3 — derselbe Fremdschlüsseltyp trifft die Ferienbuchung.
Vorschlag: `payments` auf den beiden Freikauf-Spalten (und der Buchungsspalte) auf
`ON DELETE CASCADE` — die Zahlung überlebt ihren Anlass ohnehin nicht — oder die
Reihenfolge am Zyklus-Kommentar benennen.
```

```
[P4] putzdienst · Klasse 3 · zwei Belegstellen
- Z. 106: „leer heißt „es gilt der Standard" und nicht „keine Grenze"." Der zitierte
  Satz steht nirgends in den Blöcken oder Referenzen; Block 01 sagt die Sache anders
  („die Platzzahl … steht als Standard je Art einmal für das ganze Jahr").
- Z. 243–244: „Die Frist … steht bewusst nicht als Spalte: sie ist „fest, für alle
  Termine gleich und nirgends einstellbar"." Block 01 schreibt „die Frist ist fest: drei
  Tage vor genau diesem Putzdienst, für alle Termine gleich und nirgends einstellbar" —
  das Zitat setzt zwei Satzteile ohne Auslassungszeichen zusammen.
Vorschlag: beim ersten die Anführungszeichen streichen, beim zweiten den Wortlaut
übernehmen oder mit „…" kürzen.
```

**Angesehen, nicht als Fund gewertet**

- „eine Familie kann keinen Termin annehmen, an dem sie schon steht" (01) ist als
  Ankreuzregel nicht gebaut — das Ergebnis trägt trotzdem
  `uq_cleaning_assignments`: der Tausch selbst scheiterte.
- Keine Entität „Erinnerungsstufe", obwohl grenzkarte.md sie in der
  Putzdienst-Zeile führt: Block 01 entscheidet die Sache — „Nichts davon wird
  konfiguriert, es hängt am vorigen Termin und am Termin selbst".
- Der Freikauf trägt keinen Betrag: er steht in `payments` und als Wert im System,
  und Block 01 will genau das („der Freikauf des ganzen Jahres ist die Summe der
  offenen Pflichttermine … passt sich mit").

---

## ferien

```
[F1] ferien · Klasse 2 · sync_tasks gegen Block 10 (zweiter Beleg zu A3)
Block 10, Sonderfälle: „Sie bekommt je Kind eine Aufgabe mit den berechneten
Terminen", Fremdsysteme: „Erstattungen sind kein Fremdsystem, aber Handarbeit,
die auf einen Menschen wartet: **je Fall eine Aufgabe bei der Buchhaltung**."
Beide liegen bei derselben Stelle wie die Hortbeitrags-Aufgabe aus 09, und
„je Fall" heißt mehrere gleichzeitig für dasselbe Kind.
`ix_sync_tasks_open_child (sync_target_id, child_id) WHERE completed_at IS NULL`
lässt eine zu. Damit sind es drei in den Blöcken benannte Fälle (09 zweimal, 10
zweimal), in denen der Index eine geforderte Aufgabe abweist.
Vorschlag: siehe A3 — `sync_targets` in Zielsystem und Aufgabenart trennen; für
die Erstattung zusätzlich einen eigenen Bezug (die Buchung) statt des Kindes.
```

```
[F2] ferien · Klasse 1 · holiday_sessions
Block 10 erhebt je Termin „das **Thema** — Titel (Pflicht), Beschreibung und
Bilder (freiwillig), für alle sichtbar, auch ohne Anmeldung, denn es ist die
Ausschreibung", und unter Dateien: „Dateien gibt es nur an einer Stelle: die
Bilder am Thema eines Termins". Das Schema streicht sie (Z. 141–145) mit
„entschieden nach der Abnahme, dass die Ausschreibung auf der Webseite der
Schule steht" — eine Überlegung, kein Blocksatz; Block 10 sagt weiterhin das
Gegenteil, und die Rangfolge des Baus stellt den Block obenan.
Vorschlag: entweder die Tabelle bauen oder Block 10 an zwei Stellen ändern —
solange beides nebeneinander steht, ist nicht entscheidbar, was gilt.
```

```
[F3] ferien · Klasse 6 · holiday_bookings
`cancellation_declared_by` und `cancellation_recorded_by` tragen als einzige
Urheberspalten neben `sync_tasks.completed_by` (Q5) keinen Präfix-CHECK. Block 10
verlangt „wer sie abgegeben hat" und „wer ihn eingetragen hat"; das Prüfskript
setzt selbst „guardian:x" und „entra:hort" ein, also ist das Format gemeint.
Drei von rund fünfzig Urheberspalten fallen damit aus der Konvention.
Vorschlag: `ck_holiday_bookings_declared_by` und `_recorded_by` analog zu
`ck_cleaning_assignments_waived_by`.
```

```
[F4] ferien · Klasse 5 · ferien-schema-check.sql
Z. 297 endet das Skript mit dem Kommentar „-- 10: die Ausschreibungsbilder hängen
am Termin, nicht am Kind." und danach unmittelbar dem Schlussblock — die
angekündigte Gegenprobe fehlt. Ein Rest der gestrichenen Bildertabelle (F2), der
im Skript wie eine geprüfte Regel aussieht.
Vorschlag: streichen — oder, wenn F2 anders entschieden wird, die Probe
nachtragen.
```

```
[F5] ferien · Klasse 2 · uq_holiday_bookings
`UNIQUE (child_id, holiday_session_id)` (Z. 314), ohne Rücksicht auf den Storno.
Block 10, „Was dabei erhoben wird": „die Buchung selbst ändern Eltern nicht, **sie
stornieren und buchen neu**" — und zwei Sätze davor: „die Buchung bleibt stehen und gilt
als storniert, **sie verschwindet nicht**". Beides zusammen heißt, dass nach einem
eingetragenen Storno die alte Zeile noch steht und die neue Buchung desselben Kindes für
denselben Termin am UNIQUE abprallt. Damit ist der einzige Weg versperrt, den der Block
für den Wechsel des Moduls vorsieht. Empirisch geprüft: `23505 duplicate key …
"uq_holiday_bookings"`. Der Lese-Index daneben schließt den Storno korrekt aus
(`ix_holiday_bookings_session … WHERE cancellation_recorded_at IS NULL`), das UNIQUE nicht
— dieselbe Bedingung fehlt an der Stelle, an der sie wirkt.
Vorschlag: partieller Unique-Index `… WHERE cancellation_recorded_at IS NULL`, wie beim
Lese-Index daneben.
```

```
[F6] ferien · Klasse 3 · ferien-schema.sql:218–224
Ein vollständiger Herkunfts-Kommentar für eine Tabelle, die es nicht gibt: „Herkunft: 10 —
„die Bilder am Thema eines Termins …" Löschanker: keiner, und das ist die Aussage. Bewusst
KEINE Q2-Zeile …" — und unmittelbar darauf der Abschnittstrenner „Kostenübernahme und
Buchung". Der Block widerspricht zugleich der Entscheidung 70 Zeilen weiter oben
(„Bewusst KEINE Bilder … die Ausschreibung steht auf der Webseite der Schule"). Zwei
gegenläufige Aussagen zur selben Sache in einer Datei, und zu einer davon keine Tabelle.
Zweiter Rest derselben Streichung neben F4.
Vorschlag: den Kommentarblock streichen — oder, wenn F2 anders entschieden wird, beide
Reste zur Tabelle zurückführen.
```

```
[F7] ferien · Klasse 1 · holiday_session_types.allows_external_children
Block 10, Schritt 3: „**Geprüft wird nur eines:** ob die Terminart fremden Kindern
offensteht; das Alter nicht." Genau diese eine Prüfung ist nicht gebaut — das Flag steht
da, und nichts hindert die Buchung eines unbekannten Kindes an einer Kochwerkstatt mit
`allows_external_children = false`. Der Kommentar an `fk_holiday_bookings_module` zitiert
den Satz sogar, belegt damit aber die Modul-Terminart-Bindung und nicht die Prüfung, von
der der Satz handelt. Eine Gegenprobe gibt es dazu ebenfalls nicht. Dieselbe Bauform wie
S4, Q2 und G1 — ein Flag, das eine Regel benennt und keine trägt —, hier zusätzlich mit
einem Zitat, das an der falschen Stelle steht.
Vorschlag: „bekannt" läuft über zwei Tabellen (`children.entry_date`, laufender
Hortvertrag) und ist im triggerfreien Schema nicht ausdrückbar — dann eine Zeile „prüft
die Anwendung" wie bei der Platzgrenze in 06, und das Zitat an die Stelle hängen, die es
trägt.
```

```
[F8] ferien · Klasse 3 · ferien-schema.sql:32–33
„Bekannt ist ein Kind, das eingeschrieben ist oder einen laufenden Hortvertrag hat" —
Block 10 schreibt „Bekannt ist **dabei** ein Kind, das eingeschrieben ist (08) oder einen
laufenden Hortvertrag hat (09)".
Vorschlag: Wortlaut übernehmen.
```

**Angesehen, nicht als Fund gewertet**

- `uq_holiday_bookings (child_id, holiday_session_id)` als Sperre gegen Vormittags- **und**
  Nachmittagsmodul am selben Kochwerkstatt-Termin ist richtig: Block 10 sagt „Wählen je
  Kind die Termine und je Termin **das Modul**", Einzahl. Der Storno-Fall ist ein anderer
  und steht als F5.
- `holiday_bookings.holiday_session_type_id` als zusätzlich gespeicherter ableitbarer
  Wert: genau der Ausnahmefall aus rules.md Abschnitt 1 — er trägt zwei
  zusammengesetzte Fremdschlüssel und ist damit an sein Original gebunden.

---

## gesundheit

```
[G1] gesundheit · Klasse 1 + Klasse 3 · health_trait_types / health_traits
Der Kommentar an `health_trait_types` (Z. 21–22) sagt: „Audit-Spalten, weil die
drei Flags steuern, welche Spalten des Merkmals überhaupt gelten." Es sind vier
Flags, und keines steuert etwas. Empirisch geprüft: eine Allergie mit
`needs_permission = false` nimmt eine Verabreichungserlaubnis an, eine
Nicht-Medikamentart ein `self_administered`, eine Art ohne
`has_treatment_reason` einen Behandlungsgrund, und `emergency_description`
(„Nur beim Notfallmedikament") hat gar kein Flag neben sich.
Block 08 verlangt die Zuordnung ausdrücklich — „bei Medikamenten dazu, ob das
Kind sie selbst nimmt", „therapeutische Maßnahme samt Grund" —, und rules.md
Abschnitt 3 nennt genau diesen Fall als Grund, das Flag überhaupt zu führen.
Vorschlag: zusammengesetzte Fremdschlüssel (`health_trait_type_id`, Flag) plus
je ein CHECK, wie bei S4 und Q2; `emergency_description` bekommt ein eigenes
Flag oder wird an `is_medication` gehängt.
```

```
[G2] gesundheit · Klasse 6 · health_traits
`has_certificate boolean` und `certificate_document_id` tragen dieselbe Tatsache;
der Kommentar sagt es selbst: „Ob ein Attest vorlag; **das Attest selbst ist eine
Q2-Zeile**." Ist jedes Attest eine Q2-Zeile, ist das Flag der ableitbare Wert,
den rules.md Abschnitt 1 verbietet — und `ck_health_traits_certificate` sichert
nur die eine Richtung: `has_certificate = true` ohne Dokument geht durch und
heißt dann „vorlag, aber keine Zeile", also das Gegenteil des Kommentars.
Vorschlag: `has_certificate` streichen und die Frage über `certificate_document_id`
beantworten — oder den Kommentar auf den Fall umschreiben, den das Flag wirklich
trägt (auf Papier gesehen, nicht abgelegt).
```

```
[G3] gesundheit · Klasse 7 · health_trait_types gegen Block 08
Block 08 zählt auf: „Je Punkt — Unverträglichkeit, Allergie, chronische
Erkrankung, Medikament, Notfallmedikament samt Notfallbeschreibung, körperliche
Einschränkung, Seh- oder Hörschwäche, therapeutische Maßnahme samt Grund und
Zeitraum, **Zeckenentfernung** — steht, was, ob ein Attest vorlag und ob die
Schule handeln darf", und nennt sie unter dem, was Lehrkräfte und Hort im Alltag
sehen. Das Schema führt sie allein als Q1-Zweck (querschnitt-schema.sql, Zitat
aus grenzkarte.md) und erwähnt den Widerspruch nirgends. Der Block ist jünger
und schlägt die Grenzkarte.
Nachtrag aus dem zweiten Lauf: das Zitat aus Block 08 an `health_traits`
(gesundheit-schema.sql:99–103) bricht mit einem „…" genau vor dem Wort ab, an dem
Block und Karte auseinandergehen — die Auslassung verbirgt den Widerspruch,
statt ihn zu benennen. Derselbe Bautyp wie Q6.
Vorschlag: entweder als Merkmalsart aufnehmen oder in einer Zeile hinschreiben,
warum grenzkarte.md hier trotz Block 08 gilt.
```

```
[G4] gesundheit · Klasse 3 · measles_proofs
`uq_measles_proofs UNIQUE (child_id)` wird begründet mit „„Er muss schnell
nachprüfbar sein" — je Kind genau eine Zeile". grenzkarte.md führt genau diesen
Satz als das Gegenteil ein: „Dazu eine **Anforderung an die Ansicht statt an das
Schema**: er muss schnell nachprüfbar sein." Das Constraint mag richtig sein,
sein Beleg ist es nicht.
Vorschlag: mit dem begründen, was trägt — Block 06 kennt je Kind einen Nachweis,
„bei dem allein zählt, ob und wie er vorlag".
```

```
[G5] gesundheit · Klasse 3 + Klasse 4 · gesundheit-schema-check.sql:201
„03: „Die Gesundheitsangaben verschwinden mit dem Kind"" — der Satz steht so in Block 03
nicht. Dort steht: „die Gesundheitsangaben **nach dem letzten bestätigten Ende dieses
Kindes**", und Block 09 wiederholt es wörtlich. Der erfundene Satz nennt einen anderen
Löschanker als den geltenden — und einen anderen als der Kommentar am eigenen Schema
(`child_health_records`, Z. 70: „das letzte bestätigte Ende dieses Kindes (03)"). Das Kind
überlebt sein Ende um die noch offene Vertrags- und Zahlungsfrist; wer dem Zitat folgt,
lässt Art.-9-Daten genau so lange stehen. Es ist damit das einzige falsche Zitat im Lauf,
das nicht nur den Beleg, sondern die Sache selbst verschiebt.
Vorschlag: Zitat und Probe auf den tatsächlichen Anker umstellen — die Probe daneben
(`DELETE FROM children`) belegt ohnehin nur den Cascade, nicht die Frist.
```

```
[G6] gesundheit · Klasse 3 · gesundheit-schema.sql:52–53
„„Viele Wege gehen dafür durch" (prozesse.md)". Dieser Satz steht in prozesse.md nicht —
in keiner der beiden Fassungen; ein `grep -rin "viele wege"` über wb-docs und
wb-brainstorming findet ihn ausschließlich als Umformulierung. Die Quelle, auf die sich
alle berufen, ist grenzkarte.md, und dort steht `„viele Wege" gehen dafür durch
(prozesse.md Abschnitt 5.2)` — zwei Wörter in Anführungszeichen; der Vorentwurf schreibt
„hier gehen viele Wege". Das Schema zitiert damit die Umformulierung einer
Umformulierung und hängt sie an die Quelle, die sie am wenigsten trägt. Sie belegt die
Entscheidung, `measles_presentation_types` als Werteliste statt als CHECK zu bauen.
Vorschlag: `„viele Wege" gehen dafür durch (grenzkarte.md)` — oder die Anführungszeichen
weglassen; rules.md Abschnitt 3 trägt die Entscheidung ohnehin.
```

```
[G7] gesundheit · Klasse 3 · child_health_records.action_note
„Ein kurzer handlungsrelevanter Hinweis ('keine Sprungübungen'), den die Klassenlehrkraft
formuliert und den alle unterrichtenden Personen sehen". grenzkarte.md nennt an dieser
Stelle **zwei** Beispiele: „keine Sprungübungen", „Notfallmedikament im Sekretariat".
Das zweite ist ohne Auslassungszeichen aus dem Zitat entfernt — und es ist gerade das,
das den Umfang der breit sichtbaren Spalte zeigt (siehe M3).
Vorschlag: Wortlaut übernehmen.
```

**Angesehen, nicht als Fund gewertet**

- `ck_child_health_records_answer` lässt beide Zeitpunkte leer, obwohl der Kommentar
  „nie beides" sagt: das leere Feld ist der ausdrücklich gewollte Vollimport-Fall
  („erkennbar daran, dass diese Strecke bei ihnen nie lief", 08).
- Der Löschpfad ist im Prüfskript wirklich durchlaufen — `DELETE FROM children`
  scheitert am Attest in SharePoint und geht durch, sobald die Datei fort ist.
  Die einzige Domäne, die ihren Löschanker nicht behauptet, sondern zeigt.

---

## mensa

```
[M1] mensa · Klasse 3 + Klasse 7 · care_modules gegen meal_subscriptions
anmeldung-schema.sql:160–162 sagt zu `care_modules.includes_lunch`: „Trägt
zugleich das **RS-Mensa-Abo, das als Katalogzeile „Mittagessen" dieselbe
Struktur bucht** (11)." Das tut es nicht — mensa-schema.sql baut mit
`meal_subscriptions` und `meal_subscription_days` eine zweite
Wochentags-Buchungsmechanik daneben. grenzkarte.md nennt genau diese
Zusammenlegung als die eine Stelle, „an der **bewusst zusammengelegt** wurde,
damit sie niemand später ‚auftrennt'".
Die Trennung ist gegen Block 11 verteidigbar (eigener Beginn, eigene
Kündigungstage, eigener Beitrag) — nur steht das nirgends, und der
Kommentar in der Nachbardatei behauptet weiter das Gegenteil. Der Preis steht
schon im Schema: „gegen ein Hortmodul mit Essen prüft die Anwendung, weil beide
in verschiedenen Tabellen stehen".
Vorschlag: den Kommentar an `includes_lunch` richtigstellen und die Abweichung
von grenzkarte.md dort begründen, wo sie geschieht (mensa-schema.sql, Kopf).
```

```
[M2] mensa · Klasse 3 + Klasse 5 · meal_subscription_days
`uq_meal_subscription_days UNIQUE (meal_subscription_id, weekday, valid_from)`
trägt den Kommentar: „„Je Kind und Tag gibt es höchstens ein Essen" — innerhalb
des Abos trägt das dieser Schlüssel". Er trägt nur „nicht zweimal ab demselben
Tag". Empirisch geprüft: Montag ab 1.10. (offen) und Montag ab 1.12. stehen
nebeneinander, und am 15.12. gelten beide — der Monatsbeitrag zählt den Montag
doppelt.
Die Gegenprobe prüft genau den Fall, den der Schlüssel abdeckt („derselbe
Wochentag zweimal **ab demselben Tag**"), und keinen anderen.
Vorschlag: `EXCLUDE USING gist (meal_subscription_id WITH =, weekday WITH =,
daterange(valid_from, valid_until, '[]') WITH &&)` samt `btree_gist` — das ist
die Regel, die der Kommentar meint.
```

```
[M3] mensa + gesundheit · Klasse 1 · health_trait_types.is_everyday_relevant
Block 11: „die **Mensa sieht davon allein diese beiden Punkte** — Unverträglichkeit,
Allergie —, den schmalsten Ausschnitt, den 08 kennt: **ohne Notfallmedikation**, ohne
Diagnose, ohne Attestlage." Block 08 nennt daneben die Alltagssicht von Lehrkräften und
Hort, die die Notfallmedikation ausdrücklich **einschließt** („Unverträglichkeit, Allergie,
Notfallmedikation samt Erlaubnis, Zeckenentfernung"). Das sind drei Stufen; das Schema
trägt zwei — `is_everyday_relevant`, und der Kommentar dort beruft sich sogar auf „(08, 11)",
obwohl 11 die engere verlangt. Für die Küche gibt es damit kein Merkmal, an dem die
Notfallmedikation ausgeschlossen wäre; die Rolle Mensa liest denselben Ausschnitt wie der
Hort. Bei Art.-9-Daten ist das eine Über-Offenlegung und keine Unschärfe.
Vorschlag: `is_kitchen_relevant` als zweite Spalte an `health_trait_types` mit eigenem
GRANT — dieselbe Bauform, die `child_health_records` mit zwei unterschiedlich
freigegebenen Spalten schon nutzt.
```

```
[M4] mensa · Klasse 2 · uq_meal_subscriptions — den beiden Läufen widersprechend
`UNIQUE (child_id, school_year)`, begründet mit „Das Abo ist ein Schuljahres-Abo und
endet **immer am 31. Juli**; deshalb gibt es je Kind und Schuljahr genau eines". Der
zweite Lauf hat das als Fund verworfen („Block 11 kennt keinen Wiedereinstieg"); der
dritte hält dagegen, und zwar nicht wegen des Wiedereinstiegs, sondern wegen der
Begründung: Das „immer am 31. Juli" gilt nach Block 11 gerade nicht durchgängig. Eine
Kündigung zum 3. Januar beendet das Abo am **31. Januar**, ein Abgang zu jedem anderen
Tag („Der Punkt ‚Mensa' steht auf der Abgangsliste, und das Sekretariat trägt das Ende
ein wie jedes andere"), und die Spalte `ends_on` bildet beides ab. Damit trägt der
Schlüssel eine Annahme, die das eigene Schema zwei Zeilen weiter widerlegt, und sperrt
für den Rest des Schuljahres, was Block 11 zweimal offen lässt: „Kein Stichtag,
angemeldet wird jederzeit" und „Wer später anmeldet, beginnt zum nächsten Monatsersten".
Empirisch geprüft: nach einem Abo mit `ends_on = 31.01.` wird das zweite abgewiesen.
Überall sonst im Schema ist „nie zwei nebeneinander" ein partieller Index über das
offene Ende (`ix_contracts_running`, `ix_sepa_mandates_current`,
`ix_care_module_agreements_running`); hier allein ist es ein voller UNIQUE über ein
gerechnetes Jahr.
Vorschlag: `EXCLUDE USING gist (child_id WITH =, daterange(starts_on, ends_on, '[]')
WITH &&)` — dann trägt der Schlüssel genau „nie zwei nebeneinander" und nicht mehr.
Zu entscheiden bleibt die Sachfrage: Darf sich ein Kind nach der Halbjahreskündigung im
selben Schuljahr neu anmelden? Sagt die Schule nein, ist der UNIQUE richtig und nur
seine Begründung falsch.
```

**Angesehen, nicht als Fund gewertet**

- Kein Küchen-Freitextfeld neben der Variante: Block 11 benennt den Preis dafür
  ausdrücklich und entscheidet dagegen.
- Der 1. Oktober, der nächste Monatserste und die beiden Endtage stehen als Kommentar
  ohne CHECK: Block 11 nennt für das Ende ausdrücklich einen dritten Fall (den Abgang),
  ein harter CHECK trüge also nicht.
- Dass gegen ein Hortmodul mit Essen „die Anwendung prüft, weil beide in verschiedenen
  Tabellen stehen", steht offen im Kommentar — so soll eine Auslassung aussehen.

---

## klassenorganisation

Kein Fund. Eine Tabelle, jede Zusage aus Block 16 mit Spalte oder benannter
Auslassung, jeder Ausschluss („kein Wahltag, kein Protokoll, keine Stimmenzahl,
kein Amtstitel") im Prüfskript negativ nachgewiesen, und der Löschpfad
(`DELETE FROM persons`) wirklich durchlaufen statt behauptet.

---

## elternbonus

```
[E1] elternbonus · Klasse 4 · parent_work_entries
`fk_parent_work_entries_confirmer` → `employees`, ohne ON DELETE, also NO ACTION.
Block 00 und Block 13 sagen beide: „Was seinen Namen anderswo trägt, überlebt
ihn: eine bestätigte Mitarbeitsstunde (14) folgt ihrer eigenen Frist." Sie
überlebt ihn nicht — sie hält den Löschanker `employees.last_working_day` auf,
solange sie steht. Eine der beiden Fristen kann so nicht laufen, und keine Zeile
im Schema sagt, welche.
Vorschlag: `ON DELETE SET NULL` samt einer daneben festgehaltenen Kennung des
Bestätigers, oder die Reihenfolge im Lösch-Lauf (17) ausdrücklich festlegen.
```

```
[E2] elternbonus · Klasse 4 · parent_work_entries
`fk_parent_work_entries_family` steht auf CASCADE. Block 03: „die Putzdienstdaten
folgen weiter der Jahrgangsfrist aus 01, nicht dem Austritt; ebenso die
Elternbonus-Daten (14), die dieselbe Frist tragen." Für dieselbe Regel steht im
Putzdienst NO ACTION (`cleaning_assignments`, `cleaning_buyouts`) — dort hält
die Zeile das Löschen der Familie auf, hier nimmt das Löschen der Familie die
Zeile mit, bevor ihre eigene Frist abgelaufen ist. Zwei Domänen, eine Regel,
gegensätzliche Fremdschlüssel.
Die Gegenprobe verdeckt das: `'14 — Einträge verschwinden mit der Familie'`
trägt als Beleg den Satz über die Jahresfrist, prüft aber die CASCADE.
Vorschlag: NO ACTION wie im Putzdienst, damit die Jahresfrist beide gleich trägt.
```

```
[E3] elternbonus · Klasse 6 · parent_work_entries
`school_year` steht neben `worked_on`, ohne dass etwas die beiden bindet: eine
Stunde vom 5. Oktober 2026 lässt sich dem Schuljahr 2030 zurechnen. Der
Dateikopf von stammdaten-schema.sql sagt „eine Schuljahrestabelle gibt es nicht,
das Jahr folgt aus dem Datum (Block 04)" — dann ist die Spalte der ableitbare
Wert aus rules.md Abschnitt 1, und sie trägt kein Constraint, das die Ausnahme
rechtfertigte.
Vorschlag: CHECK, der `school_year` gegen `worked_on` bindet — mit der einen
Ausnahme, die Block 14 nennt (der nachgetragene Zettel), als ausdrücklichem
Spielraum statt als stiller Freiheit.
```

---

## rechnungsfreigabe

```
[R1] rechnungsfreigabe · Klasse 1 · expense_claim_items
Block 12, Schritt 1: „Die eigene Person ist als Führungskraft wählbar, **außer
das Geld geht an ihn selbst**: Wer sich etwas erstatten lässt, gibt es nicht
selbst frei, und dieselbe Sperre gilt fürs Weiterleiten und Aufteilen — sonst
käme der Beleg über den Umweg doch bei ihm an. Weil eine Fahrtkostenabrechnung
immer eine Erstattung ist, trifft sie das ausnahmslos."
Diese Sperre steht nirgends: kein Constraint, kein Kommentar, keine Gegenprobe.
Empirisch geprüft — ein Fahrtkostenbeleg mit `submitter_employee_id =
approver_employee_id` und gesetztem `approved_at` geht durch. Es ist die einzige
Kontrolle des einzigen Prozesses, in dem Geld an Mitarbeitende fließt, rund
tausend Belege im Jahr.
Vorschlag: `submitter_employee_id` an `expense_claim_items` mitführen, per
zusammengesetztem Fremdschlüssel an `expense_claims` gebunden (rules.md
Abschnitt 1, ausdrückliche Ausnahme), plus CHECK
„payment_route NOT IN ('to_me') AND claim_type <> 'travel'
 OR approver_employee_id <> submitter_employee_id".
```

```
[R2] rechnungsfreigabe · Klasse 1 · expense_claim_items / expense_claims
Zwei weitere Zusagen aus Block 12 ohne Constraint und ohne begründete Auslassung:
„Aufteilen … auf mindestens zwei Projekte, und die **Teilbeträge müssen den
Betrag genau treffen**" — empirisch stehen 10.059,99 € Teile an einem Beleg über
60 €; und „ihre **lückenlose** Nummer für die Buchhaltung" — `claim_number` ist
nur je Kalenderjahr eindeutig, lückenlos wird sie von nichts gemacht. Beides ist
in einem triggerfreien Schema nicht erzwingbar, aber beides ist eine Zusage, und
das Schema sagt an keiner Stelle, dass die Anwendung sie trägt — anders als etwa
bei der Platzgrenze in 06 oder der Rollenprüfung in 14.
Vorschlag: je eine Zeile „prüft die Anwendung" wie an den vergleichbaren Stellen,
damit beim Bau des Backends niemand sie für gebaut hält.
```

```
[R3] rechnungsfreigabe · Klasse 4 · expense_claims / expense_claim_items
Beide Fremdschlüssel auf `employees` stehen ohne ON DELETE. Block 12, Löschen:
„Der Beleg **überlebt seinen Einreicher**: Scheidet er aus, bleibt sein Name
daran" — und der Beleg bleibt zehn Jahre, während `employees.last_working_day`
laut stammdaten-schema.sql der Löschanker des Mitarbeitendeneintrags ist. Der
Beleg überlebt ihn nicht, er hält ihn fest. Derselbe Fall wie E1, hier mit einer
zehnjährigen Aufbewahrung auf der einen und einer offenen Frist auf der anderen
Seite.
Vorschlag: den Namen des Einreichers am Beleg festhalten (wie
`sepa_mandates.account_holder_name` es für den abweichenden Kontoinhaber tut)
und den Fremdschlüssel auf SET NULL — oder im Lösch-Lauf (17) festschreiben,
dass ein Mitarbeitender mit Belegen zehn Jahre bleibt.
```

```
[R4] rechnungsfreigabe · Klasse 1 · expense_claim_attachments und claim_template_shares
Zwei weitere Zusagen ohne Constraint und ohne die Zeile, die sie der Anwendung überträgt
— derselbe Bautyp wie R2, aber andere Stellen:
- Block 12: bei der Rechnung „Zahlungsempfänger, Betrag, Zweck in einem Satz, der
  Zahlweg und **mindestens ein angehängter Beleg** (alles Pflicht)". Empirisch geprüft:
  eine Rechnung ohne einen einzigen Anhang lässt sich anlegen, freigeben und buchen. Die
  Ausnahme für die Fahrt nach Strecke benennt der Block ausdrücklich („im zweiten Fall
  gibt es keinen Anhang, weil es keinen gibt"), das Schema zu beidem nichts.
- Bei den Aufteilungsvorlagen ist `share_basis_points` je Zeile auf 1–10000 begrenzt,
  die **Summe** über eine Vorlage nicht: zwei Anteile zu je 30 % gehen durch, obwohl der
  Schlüssel den Beleg vollständig aufteilen muss („was beim Runden übrig bleibt, fällt
  auf den größten Anteil" setzt eine vollständige Aufteilung voraus).
Vorschlag: je eine Zeile „prüft die Anwendung" — oder beim zweiten ein `DEFERRABLE`
Constraint über die Vorlage.
```

**Angesehen, nicht als Fund gewertet**

- `expense_claims.calendar_year` neben `created_at` ist ein zusätzlich gespeicherter
  ableitbarer Wert — hier zu Recht: er trägt `uq_expense_claims_number`, genau der
  Ausnahmefall aus rules.md Abschnitt 1.
- `ix_expense_claims_duplicate` deckt nur die Rechnungs-Variante des
  Dublettenhinweises ab, nicht die Fahrt nach Strecke (Datum und Strecke). Ein Index
  ist keine Regel, und die Abfrage läuft auch ohne ihn.
- `ck_travel_details_distance BETWEEN 1 AND 2000` greift beim Ticketfall nicht, weil
  `distance_km` dort NULL ist — gewollt, `ck_travel_details_mode` trägt die Trennung.

---

## m365, klassenbildung, ags, selfservice (vier Dateien ohne CREATE)

```
[N1] selfservice + stammdaten · Klasse 3 · Prüfskripte
selfservice-schema-check.sql:138 und stammdaten-schema-check.sql:367 begründen die
fehlende Eindeutigkeit von `persons.email` mit „05: „an der Schule teilen sich real
1–2 Elternpaare je Klasse eine Mailbox"". Der Satz steht nicht in Block 05, sondern
in `wb-docs/domains/stammdaten.md` — im Vorentwurf, der nach der Rangfolge des Baus
gar nichts schlägt. Block 05 trägt die Sache mit einem anderen Satz („die zweite wird
übernommen"), und genau den zitiert `persons.email` selbst richtig.
Vorschlag: auf den Satz aus 05 umhängen, den die Spalte daneben schon führt.
Zusammen mit S7 sind das vier Belegstellen in Prüfskripten, die auf eine Quelle
außerhalb der Blöcke zeigen.
```

```
[N2] m365 · Klasse 3 · m365-schema.sql:23 und m365-schema-check.sql:104
Zwei Zitate, die so nirgends stehen. „mit dem Ablauf des letzten Arbeitstags von selbst
enden" — hebel.md schreibt „sie **enden von selbst mit dem letzten Arbeitstag**", Block 13
„Mit seinem Ablauf **enden alle Mitarbeiterrollen von selbst**"; das Zitat mischt beide.
Und „KITA-Mitarbeitende laufen denselben Ablauf, nur ihre Domain ist eine andere" — dort
fällt ohne Auslassungszeichen „eingetragen von derselben Stelle und angelegt vom selben
Admin —" heraus. Beide Aussagen stimmen in der Sache; die Anführungszeichen tragen sie
nicht.
Vorschlag: beide Wortlaute übernehmen.
```

```
[N3] ags · Klasse 3 · ags-schema.sql
Zwei Belegstellen, die mehr behaupten, als die Quelle hergibt:
- „Nachrüsten ist **ausdrücklich** der vorgesehene Weg, nicht der Notnagel." Die Quelle
  (`wb-docs/domains/stammdaten.md` bzw. `stammdaten-schema.sql:60`) schreibt „Nachrüsten
  ist der vorgesehene Weg, nicht der Notnagel." Das Wort „ausdrücklich" ist in das Zitat
  hineingeschrieben — im ganzen Lauf die einzige Stelle, an der ein Zitat nicht gekürzt
  oder umgestellt, sondern erweitert wurde.
- „`prozesse.md` Abschnitt 20, **vollständig**: „AGs — Zukunftsprojekt, nichts Konkretes
  bekannt."" Dort steht die Überschrift „## 20. AGs" und darunter der Satz
  „Zukunftsprojekt, nichts Konkretes bekannt." Überschrift und Satz sind mit einem
  Gedankenstrich zu einem Zitat verbunden und als „vollständig" ausgegeben.
In der Sache ändert beides nichts — die Zurückhaltung der Domäne ist richtig und über
rules.md Abschnitt 1 und 7 gedeckt. Es ist die Belegstelle, die nicht trägt.
Vorschlag: „ausdrücklich" streichen; die Aufzählung ohne Anführungszeichen wiedergeben.
```

Sonst kein Fund in diesen vier. Die drei „nichts zu bauen"-Befunde sind negativ
nachgewiesen statt behauptet: Die Prüfskripte suchen die Tabellen und Spalten, die
nicht entstehen durften, und melden ihr Vorhandensein als Fehler. Die
Grenzkarten-Abweichung in m365 (Kontostatus, Offboarding-Schritt) trägt einen
Blocksatz, der die Sache wirklich entscheidet („Weltenbaum schreibt dabei nichts in
den Tenant und liest keine Gruppen"). Der Löschanker der Zustimmung aus Block 02
(„dass ein Nachweis vorlag") steht als Q3 im Querschnitt.

**Angesehen, nicht als Fund gewertet**

- ags-schema.sql belegt seine Zurückhaltung mit „Nachrüsten ist ausdrücklich der
  vorgesehene Weg, nicht der Notnagel" — ein Satz aus dem Vorentwurf
  (`wb-docs/domains/stammdaten-schema.sql:60`), ohne Quellenangabe zitiert. Die
  Aussage selbst deckt rules.md Abschnitt 1 ab; die Fundstelle wiegt leichter als
  N1, weil sie keine Regel trägt, sondern eine Haltung.
- Die Negativlisten der drei leeren Domänen raten Tabellennamen (`clubs`,
  `m365_accounts`, `portal_accounts`): ein anders benannter Nachbau fiele durch.
  ags-schema-check.sql fängt das über einen Spaltennamen-Regex zusätzlich ab.

---

## Über alle Domänen (Fehlerklasse 6, mechanisch)

Grundlage: die Liste aller Spaltennamen, die in mehr als einer Tabelle vorkommen,
aus der geladenen Datenbank gezogen (27 Namen). Die meisten sind zwei Sachverhalte
mit demselben Wort — `source`, `purpose`, `day`, `valid_from`. Zwei sind einer:

```
[X1] übergreifend · Klasse 6 · sepa_mandates gegen signatures
`sepa_mandates.signed_by_person_id` und `signed_at` sind eine zweite
Unterschriftsmechanik neben Q2. Block 08 verlangt für das Ersetzen des Mandats
eine eigene Unterschrift („Eine sorgeberechtigte Person füllt im Portal ein neues
aus **und unterschreibt** … der Vertrag darunter bleibt unberührt"), und
grenzkarte.md zählt das SEPA-Mandat ausdrücklich unter dem auf, was Q2 braucht.
Über `signatures` ginge sie nicht: `contract_id` ist NOT NULL, und
`ix_signatures_contract` lässt je Person und Vertrag nur eine zu — dieselbe Enge
wie in A8. Der Namenszug des zweiten Mandats hat damit gar keinen Ort, obwohl
Q2 „Signaturbild" als Teil jeder Signatur führt.
Vorschlag: mit A8 zusammen lösen — `signatures` einen dritten Bezug geben
(`sepa_mandate_id`) und die beiden Spalten am Mandat streichen.
```

```
[X2] übergreifend · Klasse 6 · holiday_bookings gegen payments
Der Betrag einer bezahlten Ferienbuchung steht zweimal:
`holiday_bookings.amount_cents` („der gezahlte Betrag als das, was an diesem Tag
galt", Block 10) und `payments.amount_cents` (Q3, „Anlass × Betrag × Status ×
Zahlungsreferenz"). Beide Quellen verlangen ihn, nichts bindet sie aneinander,
und `ck_holiday_bookings_retained` rechnet gegen den einen von beiden.
Vorschlag: den Betrag der bezahlten Buchung aus `payments` lesen und an
`holiday_bookings` nur führen, wo es keine Zahlung gibt (`invoiced`) — oder
beide per CHECK gleichhalten und das hinschreiben.
```

```
[X3] übergreifend · Klasse 4 · payments hält vier Löschanker fest
`payments` zeigt mit NO ACTION auf `cleaning_buyouts`, `cleaning_slot_buyouts`,
`applications` und `holiday_bookings` — auf alle vier Anlässe also, deren Löschanker
jeweils in ihrer eigenen Domäne steht, während `payments` selbst keinen eigenen hat
(„geht mit dem Vorgang, an dem die Zahlung hängt"). Das ist zirkulär: Der Vorgang kann
nicht gehen, weil die Zahlung auf ihn zeigt, und die Zahlung geht mit dem Vorgang.
Betroffen sind zwei Fristen, die in ihren Blöcken ausdrücklich stehen — das
Putzdienstjahr (01, siehe P3, empirisch geprüft) und der letzte gebuchte Ferientermin
(10, derselbe Fremdschlüsseltyp) —, und die Bewerbung (05/07). Nirgends steht, dass
`payments` zuerst zu löschen ist.
Vorschlag: alle vier auf `ON DELETE CASCADE` — die Zahlung ist der Beleg eines Vorgangs
und überlebt ihn nirgends — oder die Reihenfolge einmal an `payments` festschreiben.
```

Dazu ein Muster statt eines Einzelfunds: **„Löschanker: geht mit X" ist einmal
CASCADE und einmal NO ACTION.** Bei `phone_numbers`, `employee_roles`,
`family_guardians`, `family_contacts`, `child_health_records`, `measles_proofs`,
`child_meal_profiles` und `class_representatives` steht CASCADE; bei
`class_teachers` (S2), `consents` (Q4), `parent_work_entries` (E1/E2),
`expense_claims` (R3) steht dieselbe Formel über einem NO ACTION. Wo NO ACTION
gewollt ist, steht der Grund nur an einer Stelle dabei (`documents`, `sepa_mandates`).

## Die sieben `[A!]`

| Domäne | Aussage | entscheidet ein Block sie? |
|---|---|---|
| querschnitt | Q1–Q5 stehen in einer eigenen Datei | nein — kein Block sagt etwas zur Dateiaufteilung; grenzkarte.md Regel 4 stützt sie, keiner widerspricht |
| querschnitt | Eine Signatur hängt am Vertragsvorgang, nicht am Dokument | **nur halb** — Block 08 stützt „vor der Freigabe entsteht kein Dokument", verlangt aber die Kind-Unterschrift ab 14 am Fotoeinverständnis, die kein Vertragsvorgang ist (A8, X1) |
| querschnitt | Der Bezug der Änderungsspur ist Text ohne Fremdschlüssel | nein — hebel.md verlangt einen Mechanismus, nicht seine Bauform |
| stammdaten | Kein `updated_at`/`updated_by` auf irgendeiner Tabelle | nein, und keiner verlangt es; rules.md Abschnitt 1 stützt sie |
| stammdaten | Das SEPA-Mandat ist eine eigene Tabelle mit Historie, keine `payers` | **ja** — Block 08 wörtlich: „Geändert wird es nicht, es wird ersetzt … Das abgelöste Mandat bleibt mit seinem Unterschriftsdatum stehen" |
| stammdaten | `class_teachers` statt `classes.class_teacher_id` | **ja** — Block 15: „mehrere möglich und ohne Rangfolge, Doppelbesetzungen sind normal"; der `[?]` daneben hält die Gegenfrage offen |
| stammdaten | Der Anmeldecode bekommt eine Tabelle in Stammdaten | **ja** — hebel.md setzt fünf Zahlen fest (15 Minuten, fünf Fehleingaben, fünf je Adresse und Stunde), die einen Ort brauchen |

Keine der sieben lässt etwas offen, das ein Block längst entscheidet — mit der einen
Ausnahme in der zweiten Zeile, und sie wiegt schwer, weil an ihr der Schnitt von Q2
hängt und nicht ein Feld.

Der dritte Lauf kommt zu derselben Einschätzung und ergänzt eine Beobachtung zur Triage:
Bei den drei Marken, die ein Block entscheidet (SEPA-Mandat, `class_teachers`,
Anmeldecode), ist jedes Mal **die Variante gebaut, die der Block verlangt** — die Marken
kosten also eine Triage-Runde, ohne dass eine Entscheidung daran hinge. Offen bleibt
allein die zweite Zeile.

## Wo mir etwas fehlt, um zu urteilen

- **Wie der Tausch im Putzdienst vollzogen wird** — ob die beiden Zuteilungszeilen ihre
  Familie tauschen oder neu entstehen. Im ersten Fall verhindert
  `uq_cleaning_swap_offers` (eine Zeile je Zuteilung), dass eine Familie einen
  eingetauschten Termin je wieder anbietet; im zweiten nicht. Block 01 sagt es nicht,
  und beide Lesarten sind mit dem Schema vereinbar.
- **Ob die Zeckenentfernung Q1-Zweck oder Gesundheitsmerkmal ist** (G3) — Block 08 und
  grenzkarte.md sagen Verschiedenes, und keine der Wertelisten ist befüllt, an der man
  die getroffene Wahl ablesen könnte.
- **Die Spalten-GRANTs**, die drei Kommentare ankündigen (`applications`
  Bewertungsfelder, `child_health_records.action_note`): keine `.sql` enthält ein
  GRANT. Ob das in dieses Schema gehört oder in den Bau, sagt kein Prompt, den ich
  gelesen habe — ich habe es deshalb nicht als Fund gewertet.
- **Ob ein Kind Vormittags- und Nachmittagsmodul desselben Ferientags zusammen buchen
  darf** (dritter Lauf). Block 10 sagt „Wählen je Kind die Termine und je Termin **das
  Modul**" (Einzahl) und „Die Platzzahl gilt für den Termin, nicht je Modul" —
  `uq_holiday_bookings` nimmt das beim Wort. Wäre die Ganztagsbuchung gemeint, wäre der
  UNIQUE ein zweiter Klasse-2-Fund neben F5. — Hortleitung
- **Ob sich ein Kind nach der Halbjahreskündigung im selben Schuljahr neu zum Essen
  anmelden darf** (M4). Zweiter und dritter Lauf lesen Block 11 hier verschieden; die
  Frage entscheidet, ob `uq_meal_subscriptions` bleibt oder fällt. — Sekretariat,
  Hauswirtschaftsleitung

---

# Nach Gewicht

84 Funde aus drei Läufen. Die Kennungen verweisen auf die Domänen-Abschnitte oben.

**Bricht im Betrieb — ein realer Fall wird abgewiesen oder eine Regel kann nicht laufen**

1. **A2** — Eine Hort-Anpassung lässt sich im Modell nicht beantragen: die neue
   Modulanlage kollidiert mit der laufenden, bevor die Hortleitung sie freigeben
   kann. Block 09, Schritt 6 hat damit keinen Weg.
2. **A1** — Der Viertklässler, der in die eigene Realschule wechselt, bekommt seinen
   zweiten Schulvertrag nicht: der alte läuft bis 31. Juli. Vier Blöcke nennen den
   Fall als Normalfall, das Prüfskript kennt ihn nicht. Derselbe Index weist zwei
   weitere Blockfälle ab: den Hortvertrag für Klasse 5 und den zweiten Anlauf nach
   einem Rücktritt vor der Freigabe.
3. **S1** — „wer seine Stufe wiederholt" (04) hat in keiner der vierzehn Dateien eine
   Spalte. Der Lauf am 1. August liest sie, und 15 liest sie auch.
4. **A3 / F1** — `ix_sync_tasks_open_child` weist die zweite Optigem-Aufgabe ab, die
   09 (Änderungsgebühr) und 10 (berechnete Buchung, Erstattung je Fall) ausdrücklich
   verlangen. Vier Blockstellen, ein Index.
5. **F5** — Storno und Neubuchung desselben Ferientermins prallen an
   `uq_holiday_bookings` ab, obwohl Block 10 genau diesen Weg als den einzigen für
   einen Modulwechsel nennt („sie stornieren und buchen neu", „die Buchung bleibt
   stehen").
6. **A10** — Das **Schulgeld je Schulform** hat im ganzen Schema keinen Ort, obwohl
   hebel.md es als einen der beiden größten Beträge führt und
   querschnitt-schema.sql dafür ausdrücklich auf eine Tabelle „in der zuständigen
   Domäne" verweist. Block 08 braucht es im Vertragstext und in der
   Eintrittsdatums-Regel.
7. **R1** — „Wer sich etwas erstatten lässt, gibt es nicht selbst frei" (12) ist
   nirgends gebaut. Bei rund tausend Belegen im Jahr die einzige Kontrolle des
   einzigen Prozesses, in dem Geld an Mitarbeitende geht.
8. **Q1** — `consents.delivery_address NOT NULL` zwingt beim Vollimport Ende
   August 2026 zu einer erfundenen Adresse für jede aus der Akte nachgetragene
   Einwilligung.
9. **A9** — Beim Grundschul-Quereinsteiger fallen abgebende und örtlich zuständige
   Schule auseinander; für die zweite gibt es keine Spalte. Block 05 nennt sie
   ausdrücklich „zwei Einrichtungen mit zwei verschiedenen Rollen im Verfahren,
   keine Alternative zueinander".
10. **M2** — Derselbe Wochentag steht zweimal im selben Essensabo, sobald die
    Startdaten sich unterscheiden; der Monatsbeitrag zählt ihn doppelt.
11. **A4** — Der Umfang des Betreuungsbedarfs (Kernzeit / Nachmittag / Ganztags, 06)
    hat keinen Ort; 09 liest ihn als einzige Vorschau auf die Hortplanung.
12. **X3 · P3** — Der jährliche Lösch-Lauf des Putzdienstjahres (01) bricht ab: die
    Zahlung hält den Freikauf fest, dessen Löschanker sie selbst ist. Empirisch
    nachvollzogen; derselbe Fremdschlüsseltyp trifft die Ferienbuchung (10) und die
    Bewerbung. Die einzige Reihenfolge, die durchläuft, steht nirgends.
13. **M4** — Nach einer Kündigung zum 31. Januar nimmt `uq_meal_subscriptions` im selben
    Schuljahr kein zweites Essensabo an, obwohl Block 11 „Kein Stichtag, angemeldet wird
    jederzeit" sagt — und die Begründung des Schlüssels („endet immer am 31. Juli")
    widerlegt das eigene Schema zwei Zeilen weiter. Zweiter und dritter Lauf lesen den
    Block hier verschieden; die Sachfrage steht unten offen.

**Regel benannt, nicht gebaut — fällt erst auf, wenn jemand hinsieht**

14. **M3** — Die Küchen-Sicht auf den Gesundheitsbestand (Block 11: „allein diese
    beiden Punkte … **ohne Notfallmedikation**") hat kein Merkmal; das Schema kennt
    zwei Stufen, die Blöcke drei. Bei Art.-9-Daten eine Über-Offenlegung.
15. **S3** — `uq_employee_roles` trägt für fünfzehn von sechzehn Rollen nichts (NULL).
16. **S4 · Q2 · G1** — Dreimal dieselbe Bauform: `roles.is_branch_bound`,
    `consent_purposes.requires_child` und die vier `health_trait_types`-Flags benennen
    je eine Regel und tragen keine. Alle drei empirisch durchgelassen.
17. **A8 · X1** — `signatures.contract_id NOT NULL` trägt weder die Kind-Unterschrift
    ab 14 noch die des ersetzten SEPA-Mandats; Letztere hat deshalb eine zweite
    Mechanik neben Q2 bekommen.
18. **P1** — Der Tausch „nur gegen einen Termin derselben Art" ist nicht gebaut, das
    Unique dafür steht ungenutzt da, und die Gegenprobe belegt das Gegenteil.
19. **A5** — Der dritte Unterlagenstand „nicht nötig" (06) ist von „fehlt" nicht zu
    unterscheiden.
20. **A6** — Der eine Haken für alles, was am Anmeldetag nur erklärt wird (06), fehlt.
21. **Q3** — „dass ein Nachweis vorlag" (02) hat keinen Ort; selfservice-schema.sql
    behauptet, die Änderungsspur trage es.
22. **R2** — Aufteilungssumme und lückenlose Belegnummer sind Zusagen ohne Constraint
    und ohne die Zeile, die sie der Anwendung überträgt.
23. **Q9** — „ein bereits gültiger [Wert] nicht mehr" (hebel.md) fehlt an
    `configured_values`, `contract_texts` und den beiden Preistabellen; der Kommentar
    zitiert die erste Hälfte des Satzes und lässt die zweite weg.
24. **F2** — Die Ausschreibungsbilder aus Block 10 sind gestrichen, ohne dass ein
    Block das hergibt; Block und Schema sagen jetzt Verschiedenes.
25. **S9** — „Mindestens eine Mailadresse je Familie ist Pflicht" (01, 02) steht
    weder als Constraint noch als benannte Auslassung.
26. **F7** — „Geprüft wird nur eines: ob die Terminart fremden Kindern offensteht" (10)
    ist die eine Prüfung, die der Block benennt, und die einzige, die nicht gebaut ist;
    das Zitat daneben belegt etwas anderes. Vierter Fall des Flag-Musters aus Nr. 16.
27. **Q14** — Der Entzug einer Rolle (00: „wer sie wann vergeben **oder entzogen** hat")
    ist das Löschen einer Zeile, und `change_log` hat kein Feld für die Art der
    Änderung. Die Konvention, mit der ein Entzug lesbar würde, ist nirgends verabredet.
28. **A15** — „ob es den Heimweg allein antreten darf (Pflicht)" (09) ist am Hortvertrag
    nicht erzwungen, obwohl die Zeile erst mit dem vollständigen Antrag entsteht.
29. **R4** — Zwei weitere Zusagen aus 12 ohne Constraint und ohne die Zeile, die sie der
    Anwendung überträgt: „mindestens ein angehängter Beleg" und die Summe der
    Vorlagen-Anteile.
30. **S13** — Von den drei festen Zahlen des Anmeldecodes (hebel.md) sind zwei gebaut;
    die 15 Minuten trägt nur „später als angelegt". Dasselbe bei den beiden 14-Tage-Fristen.
31. **Q15** — Ein Widerruf darf vor seiner Erteilung datieren; der Zeitpunkt ist nach
    Art. 7 Abs. 1 DSGVO der Nachweis.
32. **Q16** — `signature_level` als CHECK statt Lookup, ohne die Begründung, die das
    Schema an vergleichbarer Stelle gibt — und mit zwei Ausprägungen, die kein Block
    kennt und Block 08 ausdrücklich verwirft.

**Der Löschanker trägt nicht, was der Kommentar über ihm behauptet**

33. **S2 · Q4 · E1 · E2 · R3** — Fünfmal „geht mit X" über einem Fremdschlüssel, der
    festhält statt mitzugehen; bei E2 umgekehrt eine CASCADE, wo der Nachbar mit
    derselben Regel NO ACTION hat.
34. **Q8** — `outbound_emails.person_id ON DELETE SET NULL`: die einzige
    personengebundene Zeile, die den Bezug kappt und das Personendatum (die Adresse)
    behält — der Kommentar darüber sagt „geht mit der Person".
35. **G5** — Ein erfundenes Zitat verschiebt den Löschanker der Gesundheitsangaben vom
    „letzten bestätigten Ende dieses Kindes" auf „mit dem Kind" und damit um die ganze
    offene Vertragsfrist.
36. **A11** — Die Grenze „ab `contracts.released_at` ändert nur noch das Sekretariat"
    greift bei den Kindern des Vollimports nie, weil sie keinen Vertrag haben.
37. **Q11** — `consents` nennt zwei Löschanker für eine Zeile, die auf beide zeigt, und
    sagt nicht, welcher gilt.

**Ein Sachverhalt an zwei Orten**

**A7** (Vertragsfassung), **G2** (`has_certificate`), **E3** (`school_year` neben
`worked_on`), **X2** (Betrag der Ferienbuchung), **S6** (Erreichbarkeit),
**M1** (zweite Wochentags-Buchungsmechanik), **S14** (`grade_level` 1..10 hart neben
`school_branches`, nicht daran gebunden).

**Der Beleg stimmt nicht — nichts bricht, aber die Begründung trägt nicht**

**S7 · N1 · G6** — Belegstellen, die auf eine Quelle zeigen, die den Satz nicht trägt:
W3, W7, W12 gibt es nirgends, der Mailbox-Satz steht im Vorentwurf, und „Viele Wege
gehen dafür durch" steht in prozesse.md in keiner Fassung — grenzkarte.md zitiert dort
zwei Wörter, der Vorentwurf formuliert anders. Fünf Stellen insgesamt.

**Sätze in Anführungszeichen, die kein Zitat sind:** **A16** („es gilt die Zahl des
Tages"), **P4** („es gilt der Standard"), **N3** („ausdrücklich" ins Zitat geschrieben,
Überschrift plus Satz als „vollständig" ausgegeben), **G5** (erfundener Löschanker,
oben schon eingeordnet).

**Zitate, die umgestellt oder ohne Zeichen gekürzt sind:** **S11 · S12 · S15 · Q6 ·
Q13 · A13 · A14 · A16 · P4 · F8 · G7 · N2** — zwölf Stellen. Zweimal schneidet die
Kürzung genau das Wort weg, an dem die Sache hängt: **Q6** („Nur") und **G3**
(Zeckenentfernung).

**Der Rest:** **S8** (`is_primary` ohne Blocksatz), **S10** (rules.md-Ausnahme
verbreitert), **G4** (Ansichts-Anforderung als Constraint-Beleg), **A12** (Kommentar
über der falschen Spalte), **Q7** (fünf statt sechs Fremdschlüssel), **P2 · Q10** (zwei
Graph-Kennungen ohne Bibliothek), **Q5 · F3** (drei Urheberspalten ohne Präfix-CHECK),
**F4 · F6** (zwei Reste der gestrichenen Bildertabelle), **Q12 · S16** (Index ohne
Gegenprobe, Index ohne Existenzprüfung).

**Ohne Fund durchgekommen:** klassenorganisation und klassenbildung. Letztere ist eine
Datei ohne CREATE, und ihr Prüfskript weist das negativ nach, statt es zu behaupten —
dasselbe gilt für ags, selfservice und m365, deren Strukturentscheidungen alle tragen;
ihre Funde (N1, N2, N3) betreffen ausnahmslos Belegstellen in Kommentaren und
Prüfskripten. Die drei Läufe sind sich darin einig.
