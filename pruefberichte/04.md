# Prüfbericht — unabhängiger Lauf gegen `schema/`

Gelesen wurde je Domäne zuerst das Schema samt Prüfskript, dann die Blöcke, die
es nennt; vorab `hebel.md`, `rules.md` 1/3/7 und `grenzkarte.md`. Alle vierzehn
Schemata wurden in eine leere Datenbank geladen und alle vierzehn Prüfskripte
gegen die **vollständige** Datenbank gefahren; die Angriffe unten sind eigene
INSERTs und UPDATEs gegen denselben Stand. Einzelheiten unter „Mechanischer
Lauf".

## Funde, nach Gewicht

```
[F7] stammdaten/anmeldung · Klasse 2 · children / fk_children_class
Block 04 zum 1. August: „Wer einen freigegebenen Schulvertrag für dieses
Schuljahr hat, ist zum 1. August eingeschrieben … ein neues Kind genauso wie
ein Viertklässler, der in die eigene Realschule wechselt; bei dem ändern sich
nur Schulart und Stufe." Genau das geht nicht: `fk_children_class` ist
zusammengesetzt über (class_id, school_branch_id), und die Klasse des Kindes
ist bis zum 31. Juli eine der Grundschule.
Nachgestellt: Kind in `GS22a`, Stufe 4, eingeschrieben — das UPDATE des Laufs
auf Realschule/Stufe 5 bricht mit `fk_children_class` ab; erst wenn dasselbe
UPDATE `class_id = NULL` mitsetzt, läuft es durch. Dass der Lauf das tun muss,
steht in keinem Block und in keinem Kommentar. Er ist maschinell, jährlich und
„niemand kann ihn aufhalten" (04): Er bleibt an der ersten solchen Zeile stehen
und lässt alle folgenden liegen. Dieselbe Kante trifft 15, Schritt 2 von vorn:
Solange die Schulart GS ist, lässt sich der Wechsler nicht in seine künftige
RS-Klasse setzen.
Vorschlag: In 04 den Satz ergänzen, dass der Lauf die Klassenzuordnung des
Wechslers mit der Schulart leert, dazu eine Gegenprobe in
stammdaten-schema-check.sql — der Constraint selbst ist richtig und ist das
Referenzbeispiel von rules.md 1.

[F3] anmeldung · Klasse 5 · contracts / ix_contracts_running
Block 09: „Je Kind ein laufender Hortvertrag, nie zwei nebeneinander."
`ix_contracts_running (child_id, contract_type, runs_until) NULLS NOT DISTINCT`
fängt davon nur die Fälle mit gleichem `runs_until`. Nachgestellt: zwei
freigegebene Hortverträge desselben Kindes — `admission_date` 2026-08-01 mit
`runs_until` 2027-07-31 und `admission_date` 2026-10-01 mit `runs_until` leer —
gehen beide durch: überlappende Laufzeiten, zwei Beitragslagen, und die eine
Optigem-Aufgabe je Kind trägt danach nur eine davon.
Der Kommentar nennt die Lücke, begründet sie aber falsch: „Dafür bräuchte der
Vertrag ein Startdatum, das er nicht hat" — der Hortvertrag trägt es als
`contracts.admission_date`, und derselbe Satz sagt das zwei Halbsätze später
selbst.
Vorschlag: EXCLUDE über (child_id, daterange(admission_date,
coalesce(end_date, runs_until), '[]')) WHERE contract_type = 'care' AND
released_at IS NOT NULL — dieselbe Bauform wie `ex_meal_subscriptions_period`,
das in mensa-schema.sql wörtlich dieselbe Blockregel vollständig trägt; der
Klasse-5-Fall aus 04 bleibt zulässig, weil der alte Vertrag am 31. Juli
schließt.

[F5] rechnungsfreigabe · Klasse 2 · expense_claims / ck_expense_claims_calendar_year
`CHECK (calendar_year = EXTRACT(year FROM created_at)::smallint)` über eine
`timestamptz`-Spalte. `date_part(text, timestamptz)` ist STABLE und nicht
IMMUTABLE — der CHECK hängt damit an der Zeitzone der Sitzung, in der er
geprüft wird. Nachgestellt: ein Beleg mit `created_at` 2026-12-31 23:30+00 und
`calendar_year` 2026 geht unter `SET TIME ZONE 'UTC'` durch; unter
`SET TIME ZONE 'Europe/Berlin'` scheitert danach jedes UPDATE auf dieselbe
Zeile an `ck_expense_claims_calendar_year`. Betroffen ist jede Sitzung mit
abweichender Zeitzone — der Ladebefehl dieses Repos selbst läuft in UTC — und,
weil COPY die CHECKs prüft, auch ein Restore in einen Server mit anderem
`timezone`; ein Backup, das sich nicht zurückspielen lässt, gilt nach rules.md 8
als nicht vorhanden. `ck_parent_work_entries_school_year` hat dasselbe Muster,
aber eine `date`-Spalte darunter und ist deshalb sauber.
Vorschlag: `created_at::date` in den CHECK ziehen oder die Zeitzone
festschreiben (`EXTRACT(year FROM created_at AT TIME ZONE 'Europe/Berlin')`).

[F4] anmeldung · Klasse 2 · applications / ck_applications_grade_level
Block 07, Schritt 5: „Der Jahreslauf rückt jeden Warteplatz eine Stufe auf,
dessen Zielschuljahr zum 31. Juli geendet hat" — ohne Halt am Ende der
Schulart. `ck_applications_grade_level` erlaubt nur `target_grade_level BETWEEN
first_grade_level AND final_grade_level`. Nachgestellt: ein Warteplatz
Grundschule Zielstufe 4 lässt sich nicht auf 5 fortschreiben, das UPDATE bricht
ab — und mit ihm derselbe 1.-August-Lauf wie in [F7]. Für `children` löst Block
04 dasselbe Problem ausdrücklich („bekommt das Austrittsdatum 31. Juli"); für
den Warteplatz sagt kein Block, was am Ende der Schulart geschieht.
**Hier fehlt mir eine Blockaussage, um zu urteilen**, ob der Warteplatz enden
soll oder die Stufe stehen bleiben.
Vorschlag: in 07 festlegen, dass ein Warteplatz am Ende der Schulart endet
(dann trägt es die Anwendung), oder den CHECK für Wartelisten-Status öffnen.

[F2] querschnitt/stammdaten · Klasse 4 · addresses
`addresses` behauptet als Löschanker „keiner eigener; eine Anschrift
verschwindet mit der letzten Person, die auf sie zeigt" (stammdaten-schema.sql,
Kopf von `addresses`). Nichts lässt das geschehen: `persons.address_id` zeigt
vorwärts auf die Anschrift, es gibt keine Cascade in diese Richtung, und die
sechsstufige Reihenfolge im Kopf von querschnitt-schema.sql nennt `addresses`
nicht. Nachgestellt an einem vollständigen Kind — Bewerbung, Vertrag, Mandat,
Dokument, Akte, Gesundheitssatz, Masernnachweis, Essensprofil, Zustimmung,
Unterschriften, Spur — läuft der Lauf über alle sechs Stufen sauber durch und
räumt alles ab; übrig bleibt genau eine Zeile: die Anschrift mit Straße,
Hausnummer, PLZ und Ort. Dasselbe gilt für die Anschrift eines abweichenden
Kontoinhabers (`sepa_mandates.account_holder_address_id`).
Die Gegenprobe in querschnitt-schema-check.sql Abschnitt 10 kann das nicht
finden: Sie prüft nur Tabellen, die den Lauf mit NO ACTION *aufhalten* — eine
reine Vorwärtsreferenz hält nichts auf und fällt aus dem Fenster.
Vorschlag: eine siebte Stufe „verwaiste `addresses`" im Kopf und eine
Gegenprobe, die nach dem Lauf zählt, was an Personendaten übrig ist.

[F1] stammdaten · Klasse 7 · family_guardians.access_level
rules.md 3 verlangt Kategoriewerte als Lookup und lässt eine fest verdrahtete
CHECK-Liste nur zu, „wenn eine Ausprägung strukturell entscheidet, welche
anderen Spalten derselben Zeile Pflicht sind"; die Einsichtsstufe entscheidet
das für keine Spalte. Der Kommentar beruft sich trotzdem wörtlich auf diese
Ausnahme („keine Bezeichnung, sondern eine strukturelle Tatsache"). Block 02
rechnet ausdrücklich mit einem vierten Grad: „Ein vierter Grad derselben Achse
ist ein Wert mehr und die Stelle im Portal, die ihn beachtet." Unter
`ck_family_guardians_access_level` ist er keine Zeile, sondern eine
Constraint-Migration — selfservice-schema.sql nennt sie selbst „eine Migration,
aber eine kleine", und `family_guardians` ist eine Stammdatentabelle: nach dem
Vollimport Ende August 2026 ist genau das ausgeschlossen („eingefroren heißt
keine Änderung an bestehenden Spalten, Typen oder Constraints", grenzkarte.md).
`care_need_levels` in anmeldung-schema.sql wendet dieselbe Regel korrekt an.
Vorschlag: Werteliste `access_levels` mit stabilem Code und Fremdschlüssel an
`family_guardians` — vor dem Stichtag ein Texteingriff, danach eine Migration.

[F6] rechnungsfreigabe · Klasse 5 · rechnungsfreigabe-schema-check.sql:472
Die Gegenprobe „12 — derselbe Empfängername zweimal" wird nicht von
`uq_payees_name` abgewiesen, sondern von `pk_payees`: Die Stammsätze legen
`payees` mit `OVERRIDING SYSTEM VALUE` und den festen Schlüsseln 1 und 2 an,
ohne die Identity-Sequenz weiterzudrehen; der INSERT der Probe bekommt deshalb
`payee_id = 1`. Einzeln abgesetzt meldet Postgres `23505 pk_payees`, nicht
`uq_payees_name`. Damit ist die Regel, auf der das Zusammenführen zweier
Einträge steht — „Es gibt eine Deutsche Bahn, und danach lässt sich filtern"
(12) —, über alle vierzehn Skripte hinweg ungeprüft. Es ist zugleich die
einzige Probe im ganzen Bestand, die an einem anderen Constraint scheitert als
an dem, den sie zu prüfen behauptet.
Vorschlag: die Probe auf einen Namen setzen, dessen Zeile nicht Schlüssel 1
trägt, oder die Stammsätze ohne OVERRIDING SYSTEM VALUE anlegen.
```

## Angesehen, nicht als Fund gewertet

```
stammdaten · `login_codes.purpose` als CHECK statt Lookup sah nach [F1] aus;
        hebel.md nennt die beiden Anlässe abschließend („ein Mechanismus für
        beides, kein zweiter daneben"), kein Block lässt einen dritten erwarten.
stammdaten · `classes.class_teacher_id` nullable, obwohl 15 „Pflicht" sagt —
        begründet mit dem Vollimport, der die Klassen aus ihrer rückgerechneten
        Kohorten-Kennung anlegt, bevor jemand zuordnet. Dieselbe Lage bei
        `persons.gender_id`: dieselbe Tabelle trägt Mitarbeitende und
        Notfallkontakte, für die kein Block ein Geschlecht verlangt.
stammdaten · Die gemeinsame Pflichtmenge trägt keinen eigenen Gültigkeitstag,
        obwohl hebel.md ihn für jeden Wert im System verlangt; die Zeile je
        Zyklus (`cleaning_cycle_quotas`) leistet, was der Tag erreichen soll —
        „nie mitten im laufenden Jahr" ist dort strukturell.
querschnitt · `holiday_cost_coverage_codes`, `application_unlocks` und
        `login_codes` stehen wie `addresses` außerhalb der sechs Stufen, haben
        aber anders als diese je eine eigene Verfallsregel ([A] bzw. 05/hebel.md)
        und im Fall des Codes eine Gegenprobe in ferien-schema-check.sql.
anmeldung · `ix_contracts_running` fängt zwei laufende **Schul**verträge mit
        verschiedenem `runs_until` ebenfalls nicht; dort trifft die Begründung
        des Kommentars zu — die Zeile hat kein Startdatum, der Schulvertrag
        liest es an `children.entry_date`. [F3] betrifft nur den Hortvertrag.
anmeldung · Die harte Platzgrenze des Zeitfensters (06, ausdrücklich „anders als
        die überschreitbare Platzzahl beim Putzdienst") liegt in der Anwendung;
        eine Zählung über Zeilen trägt kein CHECK, und die Probe „Zeitfenster mit
        einem Platz, zweimal gebucht" hält die Auslassung fest.
anmeldung · `ck_applications_care_need` verlangt `care_interest IS TRUE`, bevor
        der Anmeldetag den Umfang einträgt — 06 nennt beides „dieselbe Angabe,
        hier um den Umfang ergänzt", der Umfang setzt den Bedarf also voraus.
mensa · Die eigenen Tabellen weichen von grenzkarte.md ab („die eine Stelle, an
        der bewusst zusammengelegt wurde, damit sie niemand später auftrennt");
        Block 11 entscheidet die Sache wirklich — eigener Beginn, eigene
        Kündigungsdaten, eigener Beitrag, „kein Vertragsdokument und keine
        Unterschrift", „keine Freigabe und keine entscheidende Stelle".
mensa · Dass nur ein Realschüler ein eigenständiges Abo hat (11), steht in
        keinem Constraint — die Schulart ist eine Datenzeile und in keinem CHECK
        ausdrückbar; dieselbe Lage wie bei `care_modules.school_branch_id`.
gesundheit · `ck_health_traits_permission_type` lässt eine Erlaubnis nur an
        Merkmalsarten mit `needs_permission` zu, obwohl 08 „je Punkt … ob die
        Schule handeln darf" sagt; welche Art eine trägt, ist eine Zeile in
        `health_trait_types` und keine Migration.
gesundheit · Der Behandlungszeitraum steht entgegen grenzkarte.md am Merkmal —
        Block 08 zählt ihn auf und ist jünger; die Sorge der Karte (ein breit
        sichtbarer Hinweis auf eine beendete Therapie) trifft nicht zu, weil die
        therapeutische Maßnahme nicht `is_everyday_relevant` ist.
rechnungsfreigabe · Weitere Constraints ohne Gegenprobe — `uq_payees_name`,
        `uq_claim_templates_name`, `uq_kindergartens_name`,
        `uq_previous_schools_name`, `ck_sepa_mandates_iban` —, aber nur bei
        `uq_payees_name` behauptet eine Probe, sie zu prüfen ([F6]).
ferien · `payments.amount_cents > 0` neben `holiday_bookings.amount_cents >= 0`
        sah nach Klasse 2 aus; eine berechnete Buchung bekommt gar keine
        Zahlungszeile (`ck_holiday_bookings_coverage`), und einen 0-€-Termin
        kennt kein Block.
```

**Ohne Fund durchgekommen:** putzdienst, ferien, mensa, gesundheit, m365,
klassenbildung, klassenorganisation, selfservice, elternbonus, ags.

## Die `[A!]` dieses Bestands

```
mensa       · Eigene Tabellen statt der Betreuungsmodul-Tabellen aus 09
              — Block 11 entscheidet sie (drei eigene Mechaniken, kein Dokument,
                keine Freigabe).
querschnitt · Q1–Q5 in einer eigenen Datei statt in der ersten Domäne, die sie
              braucht — kein Block; grenzkarte.md Regel 4 stützt sie. Dateischnitt.
querschnitt · Eine Signatur hängt am Vertragsvorgang, nicht am Dokument
              — Block 08 entscheidet sie („Vor der Freigabe entsteht kein Dokument").
querschnitt · Der Bezug der Änderungsspur ist Tabellenname plus Schlüssel als
              Text, ohne Fremdschlüssel — kein Block; hebel.md sagt nur, dass es
                nur einen Mechanismus geben darf. Bauform, offen.
stammdaten  · Kein `updated_at`/`updated_by` auf irgendeiner Tabelle
              — hebel.md „Änderungsspur" trägt es; kein Block verlangt beides.
stammdaten  · Das SEPA-Mandat als eigene Tabelle mit Historie, keine `payers`
              — Block 08 entscheidet sie („Das abgelöste Mandat bleibt mit seinem
                Unterschriftsdatum stehen") und schlägt grenzkarte.md Q3.
stammdaten  · Der Anmeldecode bekommt eine Tabelle in Stammdaten — kein Block
              entscheidet den Ort; hebel.md verlangt Ratelimit und Fehleingaben,
                die sonst keinen hätten. Bauform, offen.
```

## Mechanischer Lauf

Postgres 17 in Podman, leere Datenbank.

**Ladelauf** in der vorgegebenen Reihenfolge (`stammdaten`, `querschnitt`, Rest):
alle vierzehn `schema/*-schema.sql` mit Rückgabewert **0**.

**Prüfskripte** gegen die *vollständige* Datenbank, alle vierzehn mit
Rückgabewert **0**; jedes rollt zurück, `persons` ist danach leer.

**Alle 445 Gegenproben instrumentiert** (Kopien im Scratchpad, die Skripte im
Repo blieben unverändert): `expect_reject` gibt zusätzlich SQLSTATE und
Constraint-Namen aus, `expect_accept` die Zahl betroffener Zeilen.
- **Keine einzige `expect_accept`-Probe trifft null Zeilen** — die Falle „läuft
  ins Leere" ist über den ganzen Bestand ausgeschlossen, nicht nur stichprobenhaft.
- **Von 270 `expect_reject`-Proben scheitert genau eine am falschen Constraint**
  ([F6]); alle übrigen melden den Constraint, den ihr Regeltext nennt.
- Verteilung der Ablehnungsgründe: 159 CHECK, 62 UNIQUE, 38 Fremdschlüssel,
  5 NOT NULL, 4 EXCLUDE.

**Eigene Angriffe** (INSERT/UPDATE gegen den vollständigen Stand, alle
zurückgerollt): der Lösch-Lauf über alle sechs Stufen an einem vollständig
bestückten Kind ([F2]), zwei überlappende Hortverträge ([F3]), der Warteplatz am
Ende der Schulart ([F4]), der Zeitzonenwechsel am Belegjahr ([F5]), der
Schulartwechsel des Viertklässlers ([F7]).

**Constraints ohne Gegenprobe:** 79 nach Abzug der Leerstring-, Urheber- und
Lookup-Code-Constraints; davon tragen die meisten zusammengesetzte
Fremdschlüssel (`uq_*_id_type`, `uq_*_flags`) und werden über deren Proben
mitgeprüft. Die inhaltlich offenen stehen in der zweiten Liste.

**Fehlerklasse 6** mechanisch geprüft: 39 Spaltennamen kommen in mehr als einer
Tabelle vor; jeder einzeln angesehen. Alle sind entweder verschiedene
Sachverhalte gleichen Namens oder mitgeführte Werte, die ein zusammengesetzter
Fremdschlüssel an ihre Quelle bindet (rules.md 1, ausdrückliche Ausnahme). Kein
Fund.
