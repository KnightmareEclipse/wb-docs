Prompt für die nächste Session — Stammdaten einfrieren, dann Putzdienst-Schema

---

## Ausgangslage

Das Stammdaten-Schema steht (25 Tabellen, `domains/stammdaten-schema.sql`) und ist gegen vier reale Schulverwaltungs-Datenmodelle gegengelesen. Die **Grenzkarte** (`domains/grenzkarte.md`) legt zusätzlich für *alle* Fachdomänen fest, welche Entitäten es gibt und wem welche Tatsache gehört — bewusst ohne Spalten. Sie ist neu und noch nie gegen ein gebautes Schema geprüft worden.

Der Auftrag dieser Session folgt aus einem Stichtag: **der Vollimport Ende August 2026.** Danach ist jede Änderung an bestehenden Stammdaten-Spalten eine Migration auf echten Personendaten, und die externe Abnahme liegt ebenfalls davor. Bis dahin ist Ändern billig.

## Vorher lesen

1. `CLAUDE.md` und `rules.md` — die Maßstäbe. Besonders die Ladder aus §1 **inklusive der ausdrücklichen Ausnahme für DB-Schema-Design**, „Ein Ort pro Sachverhalt" (§1), Least Privilege (§2), Lookup-vs-Freitext (§3), Datensparsamkeit (§7), Testbarkeit (§8).
2. `domains/grenzkarte.md` — die Entitäten- und Zuständigkeitskarte aller Domänen. Jedes neue Schema entsteht gegen sie; weicht ein Entwurf davon ab, ist entweder der Entwurf oder die Karte falsch, und beides muss dann ausdrücklich geändert werden.
3. `domains/stammdaten-schema.sql`, `domains/stammdaten-schema.dbml`, `domains/stammdaten-schema-plain.sql`, `domains/stammdaten-schema-check.sql` — der Ist-Zustand, 25 Tabellen. Die `.sql` ist die Quelle der Wahrheit; bei Abweichung gewinnt sie.
4. `domains/stammdaten.md`, `domains/putzdienst.md`, `fachdomaenen.md`, `TODO-SESSIONS.md`, `TODO.md`, `CONTEXT.md`, `idea/04-identitaet-zugriff.md`, `idea/06-dsgvo-organisatorisch.md`, `domains/stammdaten-schema-benchmark.md`.
5. Die vier Anmeldetag-Checklisten in `~/Downloads/CHECKLISTEN/` (Grundschule Klasse 1, Realschule Klasse 5, Quereinsteiger, Hort) — ausgewertet, ihre Befunde stecken in der Grenzkarte, aber für Aufgabe A als Primärquelle nützlich.
6. `PROZESSE-ROH.md` — die Rohsammlung des Betreibers. Ausgewertet, aber noch nicht gelöscht; enthält die realen Formularfeldlisten.

Referenzquelle für Fragen zum amtlichen Datenmodell: `~/Documents/projectNightmare/ASV-BW/asv_struktur.sql`. Der Wert steckt in den `COMMENT ON COLUMN`-Zeilen — sie markieren `*Statistikpflichtfeld*` und benennen die zugehörige Werteliste.

## Aufgabe A — Stammdaten-Rückwirkung klären (zuerst)

**Genau eine Frage, nicht mehr:** Was zwingen die Domänen **2/4 (Voranmeldung, Anmeldegespräch, Schulvertrag)**, **3 (Ferienanmeldung)** und **9 (Gesundheitsdaten)** dem Stammdaten-Schema auf?

Ausdrücklich **nicht** Aufgabe dieser Session: das vollständige Bewerbungs-, Ferien- oder Gesundheitsdatenschema. Dafür fehlen Antworten (Löschfristen, Niveau-Frage, Hortvertragsdetails), und die Deadlines liegen Monate später.

Der größte Teil der Rückwirkung ist bereits abgearbeitet — `children.registration_date`, das SEPA-Mandat an `payers`, `employees`, `family_guardians.include_in_correspondence`, die erweiterte Bedeutung von `previous_school_id`. Zu prüfen bleibt, ob die Checklisten und die Grenzkarte noch etwas enthalten, das eine **bestehende Spalte oder einen bestehenden Constraint** berührt. Neue Tabellen sind kein Problem und nicht Gegenstand dieser Aufgabe.

Konkret gegenzuprüfen:
- Die Betreuungsmodule (Kernzeit / Nachmittag / Ganztags, Lernbetreuung, Mittagessen) samt Hortvertrag — Annahme: eigene Tabellen in Domäne 2/4, keine Stammdaten-Wirkung. Bestätigen.
- Masernschutznachweis und Geburtsurkunde — Annahme: Q2 plus ein Datum in Domäne 9, nicht `children`. Bestätigen.
- Schulbegleitung — Annahme: Domäne 9, nicht Bewerbung, nicht Stammdaten.
- Die schulfremden Ferienprogramm-Kinder samt anmeldendem Elternteil: `children.family_id` ist nullable, Familie und Erziehungsberechtigte werden auch dort angelegt (`domains/stammdaten.md`, „Familie"). Prüfen, ob das ohne Schemaänderung trägt.
- Der Löschfrist-Anker für nie eingeschriebene Kinder (`idea/06`) — hängt an der jeweiligen Fachdomäne, nicht an `children.exit_date`. Prüfen, ob Stammdaten dafür etwas liefern muss.

## Aufgabe B — Stammdaten einfrieren

Ergebnis von A festhalten und den Freeze in `domains/grenzkarte.md` definieren, damit eine spätere Session ihn nicht versehentlich bricht. Die Definition lautet:

> Eingefroren heißt: **keine Änderung an bestehenden Spalten, Typen oder Constraints** ab dem Vollimport. Neue Tabellen, die Stammdaten nur referenzieren, bleiben jederzeit erlaubt und stören keine lesende Domäne.

Dazu in `TODO.md` vermerken, dass die gemeinsame Durchsicht mit dem zweiten Admin gegen den eingefrorenen Stand läuft.

## Aufgabe C — Putzdienst-Tabellenschema und Q3

Erst nach A und B. Erste Fachdomäne mit harter Deadline (Buchungsfenster September 2026), Prozessbeschreibung vollständig in `domains/putzdienst.md`.

Zu entwerfen, gegen die Grenzkarte:
- **Zyklus** (Zeitraum Okt–Sept, Buchungsfenster, Pflichtanzahl regulär + Großputz, Freikauf-Betrag, Strafe-Betrag, Puffer für die Live-Obergrenze)
- **Erinnerungsstufen** als Liste am Zyklus, nicht als feste Felder
- **Putztermin** (Datum, Typ regulär/Großputz, **Stundenzahl**)
- **Zuteilung** Familie↔Termin, mit Nichterscheinen als Attribut
- **Abweichende Pflichtmenge** je Familie und Zyklus (nimmt auch die Quereinsteiger-Proration auf)
- **Freikauf** je Familie und Zyklus
- **Q3 Zahlungsvorgang** — die erste Querschnitts-Entität überhaupt. Schmal: Anlass × Betrag × Status (offen/bestätigt) × Zahlungsreferenz. Keine Buchhaltung, keine Fälligkeiten.

Das Prädikat „eingeschrieben" ist festgelegt und zu verwenden: `exit_date IS NULL` **und** (aktive Klasse **oder** gesetzte `provisional_grade_level_id`).

Q3 ist zugleich die Belastungsprobe der Grenzkarte. Trägt die Grenze zwischen Q3 und `payers` beim Bauen nicht, ist das ein Befund über die Karte, kein Grund, sie stillschweigend zu umgehen.

## Bereits entschieden — nicht neu aufmachen

Mit Begründung am Feld bzw. im Fachdokument dokumentiert. Diese Punkte dürfen auf *innere Widersprüchlichkeit* geprüft werden, aber nicht als Vorschlag neu aufgerollt:

**Stammdaten-Schema:**
- `persons.email` ist **nicht** UNIQUE. An der Schule teilen sich real 1–2 Elternpaare je Klasse eine Mailbox, und die Voranmeldung erzeugt den Fall aktiv. Ein UNIQUE versteckte ihn nur (erfundene Zweitadresse), statt ihn zu lösen. Ein OTP-Treffer liefert die Vereinigung der Familien aller Treffer; die Oberfläche fragt danach, als wer die Sitzung läuft — Bedienführung, keine Sicherheitsgrenze. Begründung in `domains/stammdaten.md`, „Geteilte Mailbox".
- OTP-Eintrittsbedingung: E-Mail auf einer Person mit mindestens einer `family_guardians`-Zeile.
- SEPA-Mandat als zwei Spalten an `payers` (`mandate_reference`, `mandate_signed_at`) — **ein Mandat je Zahler, nicht je Zweck**. Kein Kreditinstitut (folgt aus der BIC), keine Mandatshistorie. Das signierte PDF liegt in Q2 und trägt **kein eigenes Unterschriftsdatum**.
- `employees` ist vorgezogen gebaut, mit `work_email` getrennt von `persons.email` (Letztere ist privat und OTP-Identität). Kein `is_employee`-Flag an `guardians` — die Putzdienst-Befreiung fragt `employment_end IS NULL`.
- `children.registration_date` neben `entry_date`/`exit_date`, mit CHECK gegen vertauschte Importspalten.
- `family_guardians.include_in_correspondence`, Default true. Steuert auch die Putzdienst-Erinnerungen.
- `classes.class_teacher_id` (FK per `ALTER TABLE` nachgezogen, Definitionsreihenfolge) und `classes.room`.
- Audit-Verursacher trägt durchgängig ein Präfix: `entra:` / `guardian:` / `system:`; der Trigger prüft das Präfix, nicht die Nutzlast.
- `phone_numbers`: `UNIQUE (person_id, number)` und `(organization_id, number)` — der Typ ist eine Eigenschaft der Nummer, nicht ihre Identität.
- Elf Lookup-Tabellen statt ENUM/CHECK; Kohorten-Modell bei `classes`; keine Schuljahres-Historie; keine separate Änderungshistorie-Tabelle; Unveränderlichkeit und Art.-9-Schutz über Spalten-GRANTs, deshalb **nirgends** ein tabellenweites `GRANT UPDATE`.
- Normwahl: ISO 3166-1 alpha-3, BCP 47, ISO 13616/9362, ASV-BW-Werteliste für `genders.code`, E.164 ohne CHECK.
- Der **Jahreslauf läuft Ende Juli**, nicht im September — er folgt dem ASV-BW-Import und dem M365-Klassenumzug. Für September 2026 ist er nicht auf dem kritischen Pfad: der maßgebliche Lauf ist bereits von Hand passiert, der Vollimport bringt den Stand mit.

**Grenzkarte:**
- **Q1 Zustimmung** trägt *fortbestehende* Zustimmungszustände samt Zustelladresse. Die Auskunftseinholung bei der abgebenden Schule gehört **nicht** dazu (einmalig, sofort verbraucht) und bleibt `children.previous_school_consent_at`. Die Lastschrift-Erlaubnis für Mensa/Hort **gehört** dazu — sie ist eine Erlaubnis, keine Zahlung.
- **Q2**: die Dateien bleiben in SharePoint, Weltenbaum führt nur die Referenz. Folge: das Backup bleibt ein reiner `pg_dump`, und die Löschmechanik wird zweiteilig.
- **Q3** umfasst genau drei Stripe-Anlässe (Voranmeldung/Quereinstieg, Ferienprogramm, Putzdienst-Freikauf). Schulgeld, Mensa, Hort und die Putzdienst-Strafzahlung laufen über Optigem und haben im System nichts verloren.
- **Q4**: `employees` steht, die Bereichsstruktur bewusst noch nicht.
- **Q5** speichert nur, ob die Nachzieh-Aufgabe erledigt ist — die Änderung selbst steht in den Audit-Spalten, die Zuordnung Feld→Fremdsystem ist Code.
- Die **Bewertung** im Anmeldeprozess ist **keine eigene Entität**: eine konsolidierte Einschätzung je Kind (Zusage / Eher Ja / Eher Nein / Absage), in der Realschule dazu das Niveau, plus eine Rangnummer nur für die Grenzfälle — alles Attribute der Bewerbung mit eigenem Spalten-GRANT.
- Die **Warteliste** ist ein Bewerbungsstatus ohne Rangfolge, mit **einem** Freitextfeld.
- **Klassenbildung** braucht keine Tabelle — reine Oberfläche über vorhandene Daten; der Klassenwunsch (drei Kinder je Jahrgang) ist eine Notiz an der Bewerbung.
- Beim Formularfeld „Geschwister" werden nur zwei Tatsachen gespeichert (schon Geschwister an der Schule ja/nein, Anzahl), keine Namensliste.
- **Hort-Alltag out of scope**, Hort-**Buchung** dagegen fester Bestandteil des Anmeldevorgangs. Ebenfalls draußen: Leihgeräte, Wahlpflichtfächer, Untis (WebUntis gibt es an der Schule nicht).
- **Gesundheitsdaten** zweistufig: voller Satz für Sekretariat, Klassenlehrer:in und Hort; daneben ein handlungsrelevanter Hinweis für alle Unterrichtenden. Eine Zeile je Merkmal mit Merkmalsart als Lookup, nicht dreißig Spalten.
- Termine der drei Domänen (Putztermin, Ferien-Angebotstag, Gesprächstermin) werden **nicht** zusammengelegt. Der Schulkalender bleibt in M365.

## Offene Punkte — in dieser Session nicht zu klären

Stehen in `domains/grenzkarte.md`, „Weiße Flecken", jeweils mit Adressat und Frist:
- Bereichs- und Vorgesetztenstruktur an `employees` (erst mit Domäne 5)
- Graph-Scoping für den SharePoint-Dateizugriff (vor Domäne 4)
- Ist das Niveau in der Realschul-Bewertungstabelle die amtliche Grundschulempfehlung oder eine eigene Einschätzung? Bis zur Klärung **zwei Felder** (vor Domäne 2/4)
- Aufbewahrungs- und Löschfristen je Entität (`TODO.md`, vor dem Lösch-Job)

Dazu in `TODO-SESSIONS.md`: Art.-9-Spalten-GRANT und ORM-Verhalten in `wb-backend`, die Import-Prozedur (Adress-Nachschlag vor dem Insert), und die Frage, ob der Putzdienst-Stundennachweis das Bonussystem Elternmitarbeit speist.

## Zeitlage

Stand der Planung ist August 2026.
- **Ende August 2026:** zweiter Admin zurück, NAS-Backup-Bootstrap, gemeinsame Schema-Durchsicht, danach Vollimport → **Freeze-Stichtag**
- **September 2026:** Putzdienst-Buchungsfenster, muss produktiv sein
- **Ende Oktober 2026:** Voranmeldung
- **Weihnachten 2026:** Ferienanmeldung
- **Februar 2027:** Anmeldeprozess und Anmeldegespräche

Nicht vergessen: `domains/stammdaten-schema.sql` ist ein Entwurfsdokument, keine Migration. Die Übertragung nach SQLAlchemy/Alembic passiert in `wb-backend` und hat noch nicht begonnen — das ist der engere Pfad bis September, nicht der Entwurf.

## Validierung — Pflicht

Der Kopfkommentar von `domains/stammdaten-schema-check.sql` nennt Aufruf und Fallstricke (frische Datenbank pro Lauf, Ströme im Container mergen, verankert auf der Ausgabe zählen, Sollstand-Paare, Benchmark-Nachlauf bei Spaltenänderungen). Er ist die Quelle, hier bewusst nicht wiederholt — befolgen und den dort dokumentierten Sollstand mitpflegen, wenn Prüffälle dazukommen. Aktueller Sollstand: **56 Ankündigungen zu 56 ERROR-Zeilen**, unmittelbar gepaart außer bei den beiden `app.actor`-Fällen, wo das `BEGIN` ihrer Transaktion dazwischensteht.

Zusätzlich nach jeder Schemaänderung der Spalten-Abgleich `.sql` gegen `.dbml` — der Aufruf steht im Kopfkommentar von `domains/stammdaten-schema.dbml` und liefert Exit-Code 1 bei Drift.

Ändern sich Spalten, zusätzlich `domains/stammdaten-benchmark/generate.sql` mit `n_children=500`/`n_classes=20` laufen lassen; die zwölf Zeilenzahlen müssen exakt denen aus `domains/stammdaten-schema-benchmark.md` (Durchlauf 1) entsprechen.

Bei jeder Änderung alle abhängigen Dateien synchron halten: `.sql`, `.dbml`, `-plain.sql` (regenerieren, nie von Hand), Prüfskript, Benchmark-Doku, betroffene `.md`-Abschnitte, `domains/grenzkarte.md`.

## Arbeitsweise

**Erst diskutieren, dann entscheiden** — kein fertiges Schema ungefragt hinknallen. Bei echten Entscheidungen (Feldtypen, Constraint in Postgres vs. Anwendung, Nullable-Verhalten, Normalisierung) Rückfrage statt stillschweigender Annahme, mit der Ausnahme, dass beim Schema eher zu vollständig als zu minimal geplant wird (`rules.md` §1).

**Offene Punkte bündeln, einmal validieren.** Nicht Punkt für Punkt umsetzen und nach jedem einen Container hochfahren: erst alle Befunde mit Empfehlung vorlegen, ein Go einholen, dann sämtliche Änderungen umsetzen und **einmal** validieren. Ausnahme nur, wenn eine Änderung die nächste inhaltlich bedingt.

Änderungen am Schema erst nach ausdrücklichem Go des Betreibers; bei Reviews einschätzen statt reparieren.

Echte Ermessensfragen mit **einer Empfehlung** vorlegen statt einer Optionsparade. Befunde mit genau einer offensichtlich richtigen Auflösung umsetzen und berichten. Nach jedem erledigten Punkt direkt den nächsten vorstellen, keine Zwischenfrage.

**Kein Loch behaupten, das nicht reproduziert wurde.** Vermutete Lücken gegen die Wegwerf-Instanz nachstellen und die Ausgabe zeigen, sonst ausdrücklich als unverifiziert kennzeichnen. Eigene Fehleinschätzungen laut zurücknehmen, statt eine Änderung auf falscher Prämisse zu bauen.

Antworten auf Deutsch, kurz/klar/präzise im bestehenden Dokumentationsstil (`CLAUDE.md`).
