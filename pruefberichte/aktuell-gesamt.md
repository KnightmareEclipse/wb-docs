# Prüfbericht gesamt

Der Lauf über alle. Er liest keine Blöcke und urteilt über keine einzelne Regel, sondern prüft, was
keine einzelne Domäne sehen kann: Ladereihenfolge, alle vierzehn Prüfskripte gegen dieselbe
Datenbank, Fehlerklasse 6 über alle Dateien, die `[A!]` aller Domänen und die toten Namen.

**Ladelauf** (Postgres 18 im Container `wb-pruef-gesamt`, `ON_ERROR_STOP=1`, Rückgabewert je Datei):

- Dokumentierte Reihenfolge — `stammdaten`, `querschnitt`, Rest: **14 × rc=0**.
- Umgekehrt — `stammdaten`, `querschnitt`, Rest rückwärts: **14 × rc=0**.
- Je Domäne allein auf `stammdaten` + `querschnitt`, zwölfmal in einer frischen Datenbank:
  **12 × rc=0**. Keine Domäne hängt an einer anderen; die Ladereihenfolge des Rests ist frei.

**Prüfskripte gegen die vollständige Datenbank**: 14 × rc=0 — `stammdaten`, `querschnitt`,
`akademie`, `anmeldung`, `elternbonus`, `ferien`, `gesundheit`, `klassenbildung`,
`klassenorganisation`, `m365`, `mensa`, `putzdienst`, `rechnungsfreigabe`, `selfservice`. Keines
ist über die Domänengrenze rot geworden.

**Sollstand je Prüfskript gegen die geladene Datenbank**: 8, 26, 4, 9, 16, 0, 6, 0, 5, 10, 24, 10,
0, 28 — Summe 146, und 146 Tabellen stehen in `public`. Kein Kopfkommentar behauptet eine andere
Zahl als seine Datei baut.

## Funde

[GESAMT-F1] gesamt · Klasse 6 · `academy_cost_coverage_codes` / `holiday_cost_coverage_codes`
Derselbe Mechanismus steht zweimal (akademie-schema.sql:384, ferien-schema.sql:306), und die Regeln
sind auseinandergelaufen: `holiday_cost_coverage_codes` hat `ck_…_hash CHECK (code_hash <> '')`,
`academy_cost_coverage_codes` hat ihn nicht; `created_by` erlaubt dort `entra:|guardian:|system:`,
hier nur `entra:|system:`. Ein Code mit leerem Hash ist in der Akademie eintragbar, im
Ferienprogramm nicht — und wer einen Code ausstellen darf, beantworten die beiden Tabellen
verschieden.
Vorschlag: die abweichende Regel je Spalte an einer Stelle entscheiden und beide Tabellen gleich
ziehen — der fehlende Hash-CHECK ohne Rückfrage, das `guardian:`-Präfix nach dem Block, der sagt,
wer einen Kostenübernahme-Code ausstellt.

[GESAMT-F2] gesamt · `[A!]` akademie · `academy_approvers` (akademie-schema.sql:354)
Die Marke sagt „Die Freigabeberechtigung steht als Personenliste und nicht als Rolle" und beruft
sich auf die Entscheidung vom 03.09.2026. `hebel.md`, „Rollen", entscheidet die Sache aber:
„Rechte je Person gibt es nicht: Wer etwas anderes braucht, bekommt eine vorhandene Rolle, oder es
wird genau eine neue benannt", und die eine Ausnahme führt er als „ein einziger Fall" (12). Mit
`academy_approvers` sind es zwei — eine der beiden Stellen ist nicht nachgezogen.
Vorschlag: entweder `hebel.md` nennt den zweiten Fall samt Begründung, oder die Freigabe hängt an
einer Rolle; die Marke bleibt so oder so stehen.

[GESAMT-F3] gesamt · Klasse 6 · `expense_claim_attachments.graph_item_id`
Vier Tabellen führen eine Graph-Element-Kennung; `documents`, `child_file_folders` und
`photo_consent_records` weisen den Leerstring mit `ck_…_item CHECK (graph_item_id <> '')` ab,
`expense_claim_attachments` (rechnungsfreigabe-schema.sql:566) nicht — obwohl der Kommentar an
`uq_documents_graph_item` genau diese Tabelle als dieselbe Bauform benennt. Dort ist die Spalte
`NOT NULL`, ein Leerstring geht also durch: Der erste Anhang ohne Datei wird angelegt und zeigt auf
nichts, der zweite fällt am UNIQUE, das für zwei Zeilen auf demselben Element gedacht war.
Vorschlag: denselben CHECK nachziehen, Gegenprobe im `rechnungsfreigabe-schema-check.sql`.

[GESAMT-F4] gesamt · Klasse 6 · `login_codes.code_hash`, `login_codes.purpose`
Dieselbe Lücke ein zweites Mal: `holiday_cost_coverage_codes.code_hash` trägt einen Leer-CHECK,
`login_codes.code_hash` nicht; `expense_claims.purpose` und `outbound_emails.purpose` tragen einen,
`login_codes.purpose` nicht — dort steht statt dessen nur die Werteliste
`ck_login_codes_purpose`, die den Leerstring ebenfalls abweist. Der Hash ist die offene Stelle: eine
Zeile mit leerem `code_hash` ist ein Anmeldecode, gegen den jeder leere Vergleich trifft.
Vorschlag: `CHECK (code_hash <> '')` an `login_codes` nachziehen, Gegenprobe im
`stammdaten-schema-check.sql` (stammdaten-schema.sql:1108); `purpose` bleibt, wie es ist.

[GESAMT-F5] gesamt · Klasse 6 · `code` und `name` der Wertelisten, über alle Domänen
Fünfzehn Wertelisten weisen den leeren Code ab (`academy_categories`, `alumni_kinds`,
`child_file_categories`, `configured_values`, `contract_text_kinds`, `contract_texts`,
`elective_modules`, `emergency_care_types`, `holiday_modules`, `holiday_session_types`,
`mail_categories`, `payment_modes`, `payment_routes`, `retention_hold_reasons`,
`retention_subjects`), einunddreißig weitere nicht — darunter `roles`, `school_branches`,
`document_types`, `sync_targets`, `health_fields` und die dreizehn Wertelisten der Stammdaten. Bei
`name` dasselbe Bild. Keine einzelne Domäne sieht das, weil jede in sich einheitlich ist.
Vorschlag: einmal entscheiden — überall oder nirgends — und die Entscheidung an der Referenzform
in `stammdaten-schema.sql` festschreiben, statt sie je Datei neu zu treffen.

## Angesehen, nicht als Fund gewertet

Fehlerklasse 6, geprüft über alle Dateien: 146 Tabellen, jede Spalte, deren Name in mehr als einer
Tabelle vorkommt. `rules.md` Abschnitt 1 lässt den zweiten Ort zu, wo er ein Constraint trägt und
per zusammengesetztem Fremdschlüssel gebunden ist — **jeder** mitgeführte Wert im Schema ist so
gebunden oder trägt eine Bindung im CHECK:

- `first_grade_level`/`final_grade_level` in `enrolment_windows`, `admission_days`, `children` —
        zusammengesetzt auf `uq_school_branches_grades`, die Grenzen können nicht abweichen.
- `is_branch_bound` in `employee_roles` und `sync_tasks` — zusammengesetzt auf `roles` bzw.
        `sync_targets`; der Kommentar benennt genau diesen Punkt.
- `payment_mode`/`is_invoiced`/`is_direct_debit` in `academy_registrations`, `holiday_bookings`,
        `cleaning_buyouts`, `cleaning_slot_buyouts` — zusammengesetzt auf `payment_modes`; die
        beiden Zuschnitte sind an `payment_modes` begründet.
- `sharepoint_library_id`/`child_id` in `documents` — zusammengesetzt auf `child_file_folders`,
        damit die Datei im Ordner desselben Kindes liegt.
- `school_year` in `parent_work_entries` — kein Fremdschlüssel möglich, dafür rechnet
        `ck_parent_work_entries_school_year` den Wert aus `worked_on`.
- `document_checksum` an sechs Vorgängen statt einmal an `documents` — `grenzkarte.md` (120) und
        `dokumente.md` legen die Prüfsumme ausdrücklich an den Vorgang; alle sechs tragen
        denselben `sha256:`-Regex und dieselbe Paarung mit `document_id`.
- `first_name`/`last_name`/`birth_date`/`exit_date` in `photo_consent_records` — Kopie mit
        benannter Begründung: Kind und Person sind fort, wenn die Zeile entsteht.
- `amount_cents` in `payments` neben den Vorgangstabellen — festgehaltene Tatsache, nicht
        vergessene Ableitung: eine Sitzung wird eine Zahlungszeile, auch wo der Vorgang aus
        mehreren besteht.
- `activity` in `parent_work_entries` neben `parent_work_sessions` — kopiert, weil der Eintrag
        den Einsatz überlebt (`ON DELETE SET NULL`).
- `email` in `login_sessions` neben `person_id` — das Postfach, das sich ausgewiesen hat, ist
        nicht die Person, auf die es auflöst.
- Das Storno- und Zahlmuster in `academy_registrations` und `holiday_bookings`
        (`cancellation_declared_*`, `cancellation_recorded_*`, `retained_amount_cents`) — gleiche
        Form, zwei Vorgänge; anders als bei den Kostenübernahme-Codes (F1) laufen die Regeln
        hier nicht auseinander.
- `low_places_threshold`/`low_places_notice_sent_at` in `academy_offerings` und
        `holiday_sessions` — `hebel.md` verlangt die Schwelle ausdrücklich „je Termin bzw. je
        Angebot und nicht als eine Zahl fürs ganze Haus".
- Die zwölf CHECK-Wertelisten (`payments.status`, `contracts.contract_type`,
        `expense_claims.claim_type`, `change_log.operation`, …) — `rules.md` Abschnitt 3 lässt
        die „kurze fest verdrahtete CHECK-Liste" dort zu, wo die Ausprägung entscheidet, welche
        anderen Spalten Pflicht sind; das trifft auf jede der zwölf zu, und über die einzelne
        Regel urteilt der Lauf über alle ohnehin nicht.

**Tote Namen: keiner.** Geprüft wurden alle 584 Backtick-Bezeichner mit Unterstrich und alle 212
`tabelle.spalte`-Nennungen aus sämtlichen `.md` gegen Tabellen, Spalten, Constraints, Indizes,
Funktionen und Trigger der geladenen Datenbank. Was übrig blieb, ist keine Schemaleiche:
Dateinamen, DB-Rollen (`backend_*`), Rollen- und Wertelisten-Codes (die `.sql` legt keine Seeds an,
sie stehen nur in den Prüfskripten), Systemdateien und ausdrücklich hypothetische Namen —
`otp_eligible_persons` (`zugang.md`: „Aufstiegspfad, falls ein zweiter Aufrufer dazukommt"),
`ended_school_year` (`api/klassenbildung-api.md`: „Fällt es je zur Last"), `is_primary`/
`is_final_grade` (`rules.md`, als Beispiel für ein Ja/Nein-Merkmal). Einzige Grenzzeile:
`api/ferien-api.md`:315 nennt `uq_holiday_bookings_amount` und sagt im selben Satz, dass es ihn
nicht mehr gibt — kein toter Name, aber Historie in einer `.md`.

## Die `[A!]` aller Domänen

| Domäne | Aussage | Entscheidet ein Block sie? |
|---|---|---|
| akademie:75 | Beide Zweige sind eine Domäne mit einem Häkchen (`for_adults`) | Nein — Block 21 führt beide gemeinsam, entscheidet aber keinen Dateischnitt |
| akademie:354 | Freigabeberechtigung als Personenliste statt Rolle | Ja, und dagegen — `hebel.md`, „Rollen" (→ GESAMT-F2) |
| anmeldung:1633 | Kein Trigger gegen die Abfrage am Ferientag, das prüft die Anwendung | Nein — kein Block sagt etwas zur Bauform; das Ladeargument trägt (siehe Ladelauf oben) |
| klassenorganisation:14 | Werteliste der Wahlmodule hier statt in `stammdaten` | Teils — `grenzkarte.md` (Stammdaten-Freeze) trägt den Preis, kein Block widerspricht |
| gesundheit:877 | Leserliste je Anlass-Instanz offen, `origin_scope_id` bleibt leer | Nein, und ausdrücklich so: „zu entscheiden vor Domäne 19" |
| mensa:12 | Eigene Tabellen statt der Betreuungsmodul-Struktur aus 09 | Ja — Block 11 mit drei eigenen Mechaniken; er schlägt `grenzkarte.md` |
| stammdaten:15 | Kein `updated_at`/`updated_by` auf irgendeiner Tabelle | Ja — `rules.md` Abschnitt 1, die Änderungsspur trägt es |
| stammdaten:763 | Mandat als eigene Tabelle mit Historie und eigener Bankverbindung | Ja — Block 08 verlangt lesbar, von welchem Konto wann eingezogen werden durfte |
| stammdaten:1099 | Anmeldecode bekommt eine Tabelle in Stammdaten | Ja — `hebel.md`, „Zugang und Anmeldecode": Ratelimit und fünf Fehleingaben brauchen einen Ort |
| querschnitt:15 | Q1–Q5 in einer eigenen Datei statt in der ersten Domäne | Ja — `grenzkarte.md`, Regel 4 |
| querschnitt:815 | Signatur hängt am Vertragsvorgang, nicht am Dokument | Ja — Block 08: „Vor der Freigabe entsteht kein Dokument" |
| querschnitt:1848 | Änderungsspur mit Tabellenname plus Schlüssel als Text, ohne Fremdschlüssel | Ja — `hebel.md`, „Änderungsspur": genau ein Mechanismus |

## Ergebnis

Fünf Funde, keiner davon bricht im Betrieb. Der Ladelauf trägt in beiden Richtungen und je Domäne
einzeln, alle vierzehn Prüfskripte sind gegen die vollständige Datenbank grün, Fehlerklasse 6
findet keinen ungebundenen zweiten Ort, und keine `.md` nennt einen Namen, den keine `.sql` mehr
trägt. Was bleibt, sind vier auseinandergelaufene Bauformen (F1, F3, F4, F5) und eine `[A!]`, die
gegen einen Hebel steht (F2).

**Nach Gewicht:** `[GESAMT-F1]`, `[GESAMT-F2]`, `[GESAMT-F3]`, `[GESAMT-F4]`, `[GESAMT-F5]`.
