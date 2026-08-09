Prompt für die nächste Session — Prozess-Berührungsanalyse und offene Schema-Punkte

---

Das Stammdaten-Schema steht und ist gegen vier reale Schulverwaltungs-Datenmodelle gegengelesen. Ein Review hat gezeigt: die Struktur trägt, aber mehrere Beschreibungen im Repo waren gegen die reale Prozesslage falsch — und zwar immer dann, wenn ein Prozess Stammdaten *schreibt*, nicht nur liest. Diese Session schließt diese Lücke systematisch statt weiter einzeln nachzuziehen, und arbeitet danach die offenen Punkte ab.

## Vorher lesen

1. `CLAUDE.md` und `rules.md` — die Maßstäbe. Besonders die Ladder aus §1 inklusive der Ausnahme für DB-Schema-Design, „Ein Ort pro Sachverhalt" (§1), Least Privilege (§2), Lookup-vs-Freitext (§3), Datensparsamkeit (§7), Testbarkeit (§8).
2. `PROZESSE-ROH.md` — die Rohsammlung des Betreibers, Arbeitsgrundlage dieser Session. Bewusst ohne Dokumentationsstil geschrieben; unvollständige und widersprüchliche Stellen sind erwartbar und werden nachgefragt, nicht stillschweigend interpretiert.
3. `domains/stammdaten-schema.sql`, `domains/stammdaten-schema.dbml`, `domains/stammdaten-schema-check.sql` — der Ist-Zustand. Die `.sql` ist die Quelle der Wahrheit; bei Abweichung gewinnt sie.
4. `domains/stammdaten.md`, `domains/putzdienst.md`, `fachdomaenen.md`, `TODO-SESSIONS.md`, `TODO.md`, `CONTEXT.md`, `idea/04-identitaet-zugriff.md`, `idea/06-dsgvo-organisatorisch.md`.

Referenzquelle für Fragen zum amtlichen Datenmodell: `~/Documents/projectNightmare/ASV-BW/asv_struktur.sql`. Der Wert steckt in den `COMMENT ON COLUMN`-Zeilen — sie markieren `*Statistikpflichtfeld*` und benennen die zugehörige Werteliste. Damit lässt sich empirisch entscheiden, ob ein Feld Lookup oder Freitext sein muss, statt es zu vermuten.

## Aufgabe A — Berührungsanalyse (zuerst)

`PROZESSE-ROH.md` auswerten. Für jeden dort beschriebenen Prozess genau drei Fragen beantworten:

1. **Liest** er Personendaten? Welche Felder — deckt das Schema sie?
2. **Verändert** er Personendaten? Welche Felder, wer löst es aus, wann im Jahr?
3. **Erzeugt** er Personen/Kinder/Familien? Woher, wie werden Dubletten erkannt, welche Löschfrist?

Die Schreib-Berührungen (2 und 3) sind die ergiebigen — alle bisherigen Fehlannahmen im Repo waren von dieser Art:

- Der Schulvertrag sammelt ein SEPA-Mandat ein, also *erzeugt* er Bankverbindungsdaten in Weltenbaum.
- Sitzenbleiben und Quereinstieg *verändern* `children.class_id` außerhalb des Jahreslaufs.
- Der Wechsel von der eigenen Grundschule in die eigene Realschule läuft durch die volle Voranmeldung, *referenziert* also ein Kind, das bereits in Stammdaten steht.

Ergebnis kommt als je eine Zeile pro Domäne nach `fachdomaenen.md` Abschnitt 6 — kein neues Dokument, das danebendriftet. Wo eine Antwort das Schema berührt, sofort nachziehen (nach Go, siehe Arbeitsweise). Wo `PROZESSE-ROH.md` einen bisher unbekannten Prozess nennt, gehört er in die Domänen-Liste. Nach dem Auswerten wird `PROZESSE-ROH.md` gelöscht.

**Besonders zu prüfen:** `fachdomaenen.md` Abschnitt 3 erwähnt beiläufig, dass **Gesundheitsinformationen** heute in Excel/SharePoint liegen. Das sind besondere Kategorien nach Art. 9 DSGVO und kommen im Schema bisher überhaupt nicht vor — anders als Konfession, für die es bereits ein Spalten-GRANT gibt. Ob sie nach Weltenbaum sollen, ist eine offene Frage; dass sie bisher nirgends betrachtet wurden, ist eine Lücke.

## Aufgabe B — offene Punkte

`TODO-SESSIONS.md` enthält die offenen Punkte mit Begründung und Failure-Modus, sortiert nach Dringlichkeit. Nicht hierher kopieren, sondern dort abarbeiten und den erledigten Eintrag entfernen (kein Verlauf, `CLAUDE.md`).

Der oberste Punkt wartet auf eine Tatsache, die nur der Betreiber kennt und die zu Beginn zu erfragen ist: **teilen sich Elternpaare an der Schule heute eine gemeinsame E-Mail-Adresse, und wie häufig?** Davon hängt ab, ob `persons.email UNIQUE` bleibt oder fällt.

## Bereits entschieden — nicht neu aufmachen

Mit Begründung am Feld bzw. im Fachdokument dokumentiert. Diese Punkte dürfen auf *innere Widersprüchlichkeit* geprüft werden, aber nicht als Vorschlag neu aufgerollt:

**Aus dem laufenden Review:**
- Die Putzdienst-Pflicht hängt an der `families`-Zeile — der Schulvertrag knüpft an dieselbe Einheit („einmal pro Familie"). Die Zeile wird **nie** nach Putzdienst-Gesichtspunkten geschnitten, weil sie zugleich die OTP-Ownership-Grenze ist. Sonderfälle inklusive Patchwork laufen über die abweichende Pflichtmenge je Familie und Zyklus, die auch die Quereinsteiger-Proration aufnimmt.
- `classes.is_active`: durchgelaufene Kohorten und aufgelöste Züge werden stillgelegt, nicht gelöscht. Bewusst gespeichert statt abgeleitet, bewusst kein „Ehemalige" als `grade_levels`-Zeile, bewusst `is_active` statt `is_alumni`.
- Prädikat „eingeschrieben": `exit_date IS NULL` **und** (aktive Klasse **oder** gesetzte `provisional_grade_level_id`).
- Die Klassenzeile ist stabil, ihre Besetzung nicht. Quereinsteiger treten bei, Wiederholer wechseln auf die Kohorte der zu wiederholenden Stufe, Abgänger behalten ihre `class_id` (Ablageort der digitalen Schülerakte). Kein Abgangsgrund, keine aufnehmende Schule.
- Interner Wechsel Grundschule → Realschule ist genau ein UPDATE auf `class_id`: kein `exit_date` (startete sonst die Löschfrist für ein Kind, das bleibt) und kein neues `entry_date` (das steht für den Eintritt in die Schule, nicht in den Zweig).
- Personendaten haben genau ein Zuhause. Eine Bewerbung ist eine eigene Entität mit eigener Löschfrist, die auf Stammdaten zeigt statt sie zu kopieren — interne Übergänger werden nie dupliziert. Offen bleibt allein, ob **externe** Bewerber ihre Personenzeilen ab Voranmeldung oder erst ab Aufnahme bekommen.
- `payers.iban`/`bic` sind durch ein reales Formular belegt (Schulvertrag mit SEPA-Mandat), nicht durch die Schema-Ausnahme.

**Aus der Schema-Arbeit davor:**
- Elf Lookup-Tabellen statt ENUM/CHECK — Projektregel aus schlechter Erfahrung (`rules.md` §3).
- Kohorten-Modell bei `classes` samt zusammengesetztem Fremdschlüssel — bildet die real genutzte Kennung „RS25a" ab.
- Keine Schuljahres-Historie, keine separate Änderungshistorie-Tabelle.
- Audit-Spalten auf allen veränderlichen Tabellen, ein einziger `set_row_audit`-Trigger; `families` behält sie trotz null Nutzlast-Spalten, weil ein Sonderfall teurer wäre.
- OTP-Zugang nur für natürliche Personen; `organizations.email` bewusst nicht UNIQUE.
- Normwahl: ISO 3166-1 **alpha-3** (`countries.code`), BCP 47 (`languages.code`), ISO 13616/9362 (`payers.iban`/`bic`), ASV-BW-Werteliste statt ISO 5218 (`genders.code`), E.164 als Speicherform für Telefonnummern **ohne** CHECK.
- Der Weg nach ASV-BW ist ein CSV-Export aus Weltenbaum, von Hand nachbearbeitet, dann importiert — das ist die Begründung für die `code`-Spalten und steht in `fachdomaenen.md` Abschnitt 4.
- Unveränderlichkeit (`id`, `person_id`/`organization_id`, Lookup-`code`) und der Art.-9-Schutz laufen über Spalten-GRANTs der Laufzeit-Rolle, nicht über Trigger. Deshalb bekommt `backend_runtime` auf keiner Tabelle ein tabellenweites `GRANT UPDATE`.

## Zeitlage

Stand dieser Planung ist August 2026; das Putzdienst-Buchungsfenster öffnet im September 2026. Auf dem kritischen Pfad stehen laut `fachdomaenen.md` Abschnitt 7 noch OTP-Implementierung, externes Frontend, Deploy-Auslöser, NAS-Backup und das Putzdienst-Tabellenschema selbst. Die Berührungsanalyse ist deshalb auf die Stammdaten-Schnittstelle zu begrenzen — nicht auf vollständiges Prozessdesign je Domäne. Wo eine Antwort das Schema nicht berührt, gehört sie notiert und nicht ausgearbeitet.

## Validierung — Pflicht

Der Kopfkommentar von `domains/stammdaten-schema-check.sql` nennt Aufruf und Fallstricke (frische Datenbank pro Lauf, Ströme im Container mergen, verankert auf der Ausgabe zählen, Sollstand-Paare, Benchmark-Nachlauf bei Spaltenänderungen). Er ist die Quelle, hier bewusst nicht wiederholt — befolgen und den dort dokumentierten Sollstand mitpflegen, wenn Prüffälle dazukommen.

Bei jeder Änderung alle abhängigen Dateien synchron halten: `domains/stammdaten-schema.sql`, `.dbml`, `-plain.sql` (regenerieren, nie von Hand), Prüfskript, Benchmark-Generator, betroffene `.md`-Abschnitte.

## Arbeitsweise

**Erst diskutieren, dann entscheiden** — kein fertiges Schema ungefragt hinknallen. Bei echten Entscheidungen (Feldtypen, Constraint in Postgres vs. Anwendung, Nullable-Verhalten, Normalisierung) Rückfrage statt stillschweigender Annahme, mit der Ausnahme, dass beim Schema eher zu vollständig als zu minimal geplant wird (`rules.md` §1).

Änderungen am Schema erst nach ausdrücklichem Go des Betreibers; bei Reviews einschätzen statt reparieren. Nach dem Go direkt umsetzen und gegen eine Wegwerf-Postgres-16-Instanz validieren.

Punkt für Punkt: Befunde mit genau einer offensichtlich richtigen Auflösung umsetzen und berichten. Echte Ermessensfragen mit **einer Empfehlung** vorlegen statt einer Optionsparade. Nach jedem erledigten Punkt direkt den nächsten vorstellen, keine Zwischenfrage.

**Kein Loch behaupten, das nicht reproduziert wurde.** Vermutete Lücken gegen die Wegwerf-Instanz nachstellen und die Ausgabe zeigen, sonst ausdrücklich als unverifiziert kennzeichnen. Eigene Fehleinschätzungen laut zurücknehmen, statt eine Änderung auf falscher Prämisse zu bauen.

Antworten auf Deutsch, kurz/klar/präzise im bestehenden Dokumentationsstil (`CLAUDE.md`).
