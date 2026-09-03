# Prüfbericht — Domäne `anmeldung`

Gelesen: `soll-prozesse/hebel.md`, `rules.md` §1/§3/§7, `grenzkarte.md`, dann
`schema/anmeldung-schema.sql` samt `-schema-check.sql`, dann die Blöcke 05, 06, 07, 08, 09 und die
Belegstellen in 03, 04 und 15.

Läufe: alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere Datenbank,
Rückgabewert 0 je Datei. Danach alle vierzehn Prüfskripte gegen die vollständige Datenbank —
dreizehnmal 0, **`querschnitt-schema-check.sql` rc=3** (F1). `anmeldung-schema-check.sql` selbst
läuft grün durch. Dazu eigene `INSERT`s gegen die Fälle aus den Blöcken.

## anmeldung

```
[F1] anmeldung · Klasse 5 · Lösch-Lauf über alle Domänen
`querschnitt-schema-check.sql` bricht mit rc=3: „hält den Lösch-Lauf auf, steht aber in
keiner Stufe: care_bridge_day_responses, emergency_care_bookings". Beide halten `children`
mit NO ACTION fest, stehen aber weder in der Stufenliste des Prüfskripts (Zeile 936 ff.)
noch im Kopfkommentar von `querschnitt-schema.sql` (Zeile 40 ff., „scheitert an sieben
Fremdschlüsseln" — es sind inzwischen zwölf). Der Lauf bliebe in Produktion an Stufe 2
stehen und ließe eine halb gelöschte Person zurück.
Vorschlag: beide Tabellen mit ihrem Platz in Stufe 1 in Liste und Kopfkommentar nachtragen,
die Zahl „sieben" gegen die tatsächliche ersetzen.

[F2] anmeldung · Klasse 4 · contracts
Löschanker ist „fünf Jahre nach dem Austritt des Kindes" (anmeldung-schema.sql Zeile 873).
Ein externes Hortkind bekommt nie ein `children.exit_date`: es hat keine Einschreibung, und
09 sagt es ausdrücklich — „bei einem externen Kind ist das sein letzter Betreuungstag, ein
Austrittsdatum hat es nicht". Der Hortvertrag genau der Kinder, für die die Tabelle den
Vertragstyp `care` überhaupt trägt, wird vom Lösch-Lauf nie erreicht.
Vorschlag: den Anker zweigeteilt schreiben — `children.exit_date` beim Schulkind,
`contracts.end_date` beim externen Kind — und die Gegenprobe auf den zweiten Fall legen.

[F3] anmeldung · Klasse 2 · applications
`ck_applications_final_ended` verlangt `ended_at`, sobald ein Endstatus eingetragen ist.
07 Schritt 2 trägt die Absage aber „zunächst still" ein und erst Schritt 3 gibt sie frei:
„erst damit endet die Bewerbung, und erst damit geht eine Mail" (07, Fristen). Nachgestellt:
das UPDATE auf Status 4 ohne `ended_at` wird abgewiesen — der einzige Weg durch Schritt 2
setzt also ein Ende, das es noch nicht gibt. `ended_at` ist der Löschanker (sechs Monate,
05) und der Auslöser der zwei Löschankündigungen: sie gingen über eine Bewerbung raus, von
deren Absage die Familie noch nichts weiß.
Vorschlag: das Ende an die Freigabe binden — `NOT is_final OR released_at IS NULL OR
ended_at IS NOT NULL` — und eine Gegenprobe für „Absage eingetragen, noch nicht freigegeben".

[F4] anmeldung · Klasse 5 · Sollstand
Der Kopfkommentar nennt „20 Tabellen" und die Existenzprüfung (Zeile 27–35) listet 20; die
Datei legt 25 an. Es fehlen `emergency_care_types`, `emergency_care_prices`,
`emergency_care_bookings`, `care_bridge_days`, `care_bridge_day_responses` — und mit ihnen
30 Constraints im Prüf-Array, darunter `ex_contracts_care_period`, das dort auch vorher
schon fehlte. CLAUDE.md verlangt den Sollstand im Kopfkommentar ausdrücklich.
Vorschlag: die fünf Tabellen und ihre Constraints in beide Aufzählungen nachtragen.

[F5] anmeldung · Klasse 2 · contracts
Es gibt keine Ordnungsprüfung zwischen `admission_date`, `end_date` und `runs_until` — die
Schwestertabelle `care_module_agreements` hat mit `ck_care_module_agreements_period` genau
diese. Nachgestellt: ein freigegebener Hortvertrag mit Aufnahme 01.10. und Ende 01.09.
scheitert an „range lower bound must be less than or equal to range upper bound" aus dem
GiST-Ausdruck — ein `data_exception`, den `expect_reject` gar nicht fängt. Derselbe
Zahlendreher am **Schulvertrag** (kein `admission_date`) geht vollständig durch.
Vorschlag: `ck_contracts_period` über beide Paare, damit ein benannter Constraint abweist
statt eines rohen Bereichsfehlers.

[F6] anmeldung · Klasse 4 · emergency_care_bookings, Prüfskript
Der Löschanker lautet „dieselbe offene Aufbewahrungsfrage wie Vertrag und Modulanlage (17)"
(Zeile 1158). Offen ist keine der beiden: 03 hat sie am 02.09.2026 entschieden („Der
Schulvertrag bleibt fünf Jahre nach dem Austritt"), und dieselbe Datei schreibt das an
`contracts` auch hin. Das Prüfskript wiederholt die veraltete Lesart zweimal (Zeile 1158,
Zeile 1377 „die offene Aufbewahrungsfrist für Vertragsdaten (03)"). Die Tagesbuchung bleibt
damit die einzige Tabelle der Domäne ohne belastbaren Anker.
Vorschlag: die Frist der Tagesbuchung benennen — oder, wenn sie dem Vertrag folgt, den
Anker von ihm übernehmen statt auf eine geschlossene Frage zu zeigen.

[F7] anmeldung · Klasse 1 · contracts
08 sagt „Der Vertragstext hängt an der Schulart — Grundschule und Realschule haben je einen
eigenen", 09 gibt dem Hortvertrag „seinen eigenen Vertragstext". `contract_text_id` ist ein
einspaltiger Fremdschlüssel ohne jede Bindung an `contract_type`. Nachgestellt: ein
Hortvertrag auf `school_contract_gs` und ein Schulvertrag auf `care_contract` gehen beide
durch — die Urkunde trüge den falschen Text und die falsche Unterschriftenlage.
Vorschlag: `contract_text_code` an `contracts` mitführen, zusammengesetzt auf
`contract_texts (contract_text_id, code)` binden und per CHECK an `contract_type` hängen.

[F8] anmeldung · Klasse 5 · application_offers
Das Skript legt keine einzige Zeile in `application_offers` an. Die Schlussprüfung „Angebot
oder Zahlung überlebt ihre Bewerbung" (Zeile 1399–1405) fragt damit eine leere Tabelle ab
und ist zwangsläufig grün; die Regel aus 06 („Ebenso ergänzt werden die wahrgenommenen
Angebote"), die Mehrfachauswahl und `uq_application_offers` sind nirgends belegt, obwohl der
Constraint im Prüf-Array steht.
Vorschlag: zwei Angebote an eine Bewerbung hängen, das doppelte abweisen lassen und die
Kaskade danach an einer gefüllten Tabelle prüfen.

[F9] anmeldung · Klasse 5 · Lösch-Stufen
Die Probe „17 — Kind gelöscht, während sein SEPA-Mandat es noch festhält" (Zeile 1409) wird
in Wahrheit von `fk_emergency_care_bookings_child` abgewiesen. Nachgestellt: das Mandat
vorher zu löschen ändert an der Fehlermeldung nichts. Die Probe belegt damit dieselbe Sache
wie die nächste und über `fk_sepa_mandates_child` gar nichts — die einzige Stelle im Repo,
die diesen Fremdschlüssel als Gegenprobe beansprucht.
Vorschlag: die Notfallbetreuung vor dieser Probe räumen, damit allein das Mandat übrig
bleibt.

[F10] anmeldung · Klasse 5 · Bewerbung und Anmeldetag
Zehn Spalten haben keine Gegenprobe: `kindergarten_id`, `kindergarten_consent_at`,
`enrolment_assessment_id`, `kindergarten_recommendation_id`,
`primary_school_recommendation_id`, `assessed_level_id` (nur Existenzprüfung),
`attended_info_evening`, `completeness_checked_at`, `change_fee_waived`, `places_override`
— dazu `application_statuses.keeps_connection`, an dem laut Vormerkung aus 05 „Portalzugang
und Löschfrist" hängen. `kindergarten_recommendations` und `enrolment_assessments` bekommen
im Skript nicht einmal eine Stammzeile.
Vorschlag: je Regel aus 06 („Pflicht" bei Einstufung und Empfehlung, „freiwillig" sonst)
eine Probe, mindestens eine Zeile je Werteliste.

[F11] anmeldung · Klasse 3 · Notfallbetreuung, Brückentage, Hausaufgabenbetreuung
Sieben als wörtlich ausgewiesene Sätze des Prüfskripts stehen so in keinem Block: „Ein Feld
für den Weg braucht es nicht: created_by trägt schon guardian: oder entra:" (Zeile 1176;
09 sagt „Ein Feld für den Weg gibt es nicht — er steht am Urheber der Zeile"), „Der
Fallpreis hängt an einem Modul oder steht allein" (1193), „Ein Kind ohne Betreuungsvertrag
kann gebucht werden" (1228), „…ein unangekündigtes Kind hat nur den zweiten, eine erledigte
Buchung nur den ersten" (1245), „care_modules trägt ein Häkchen…" und „Die Gruppeneinteilung
steht nicht in der Datenbank" (1298; 09 sagt „Die Gruppeneinteilung bleibt draußen"),
„Eine Anpassung … der Vertrag darunter bleibt stehen" (1085, aus zwei Absätzen
zusammengesetzt). Dieselben Proben tragen als Marke „214", „216", „217" — Ticketnummern aus
`backlog/`, während jede andere Probe der Datei ihren Block nennt. Im Schema zeigt die
Herkunft dreier Tabellen auf „die Schärfung/Beschreibung vom 03.09.2026" statt auf 09, das
die Sache seit d407a10 trägt.
Vorschlag: alle sieben gegen 09 neu zitieren und die Marken auf 09 umstellen.

[F12] anmeldung · Klasse 3 · care_bridge_days, care_bridge_day_responses
Zwei Zitate ändern die Aussage. Schema Zeile 1223 zitiert „wer sein Kind trotzdem bringt
und wer nicht" — 09 schreibt allein „wer sein Kind trotzdem bringt", und der Zusatz kehrt
gerade die Regel um, die eine Zeile weiter steht. Schema Zeile 1253 und Prüfskript Zeile
1346 zitieren „die stille Antwort muss die sichere sein" — 09 schreibt „Die stille Antwort
ist die sichere".
Vorschlag: beide auf den Wortlaut aus 09 zurücksetzen.

[F13] anmeldung · Klasse 3 · contracts
Zeile 880 zitiert „da wir eine Kündigung vor Schulbeginn vertraglich ausschließen, gibt es
auf jeden Fall einen Vorgang". Der Satz steht in keinem Block, in keiner `.md` und in keiner
anderen `.sql` des Repos; er trägt an dieser Stelle die Begründung dafür, dass der Vertrag
eines nie erschienenen Kindes dieselben fünf Jahre läuft.
Vorschlag: gegen die Belegstelle in 03 („Dieselben fünf Jahre trägt ein Vertrag, dessen Kind
nie kommt") austauschen.

[F14] anmeldung · Klasse 3 · tuition_fees
Prüfskript Zeile 990 zitiert hebel.md, „Geld im System": „das Schulgeld je Schulform —
Grundschule und Realschule kosten verschieden". Dieser Satz steht dort nicht; hebel.md
schreibt „Das Schulgeld hängt an Schulart und Geschwisterrang".
Vorschlag: das Zitat gegen den heutigen Wortlaut tauschen.

[F15] anmeldung · Klasse 3 · signatures
Prüfskript Zeile 967 führt „eine Zeile ohne Bild heißt ‚unterschrieben, Bild abgeräumt' —
‚hat nicht unterschrieben' sagt die fehlende Zeile" als Satz aus 08. Er steht in
`grenzkarte.md` (Q2) und lautet dort „Eine Zeile ohne Bild heißt **deshalb** …"; 08 kennt
ihn nicht.
Vorschlag: Quelle auf grenzkarte.md ändern und wörtlich zitieren.

[F16] anmeldung · Klasse 7 · Blöcke 08 und 09
08 („Löschen") sagt, die Aufbewahrung von Vertrag und Mandat „steht als offene Frage in 03",
09 („Löschen") spricht von „derselben offenen Aufbewahrungsfrage wie in 08". 03 hat sie am
02.09.2026 entschieden — fünf Jahre für den Vertrag, zwei für das Mandat. Zwei Blöcke stehen
damit gegen einen dritten, und das Schema folgt dem dritten, ohne dass die beiden anderen
nachgezogen wären.
Vorschlag: 08 und 09 auf den Stand aus 03 bringen; sonst ist bei der nächsten Prüfung nicht
entscheidbar, welcher Block gilt.

[F17] anmeldung · Klasse 1 · applications
`ck_applications_record_needs_slot` verlangt für `record_note` ein gebuchtes Zeitfenster.
Die drei Nachbarn aus derselben Aufzählung in 06 — `documents_checked_at`,
`information_given_at`, `attended_info_evening` — verlangen keines; nachgestellt gehen sie
ohne Zeitfenster durch, die Anmerkung nicht. Der Kommentar begründet die Bindung damit, dass
die Anmerkung „der letzte Punkt derselben Aufzählung" sei — dann trüge sie die Regel für
alle vier oder für keinen.
Vorschlag: entweder alle vier binden oder die Anmerkung freistellen und den Kommentar
entsprechend kürzen.

[F18] anmeldung · Klasse 1 · emergency_care_types
09 nennt „8 € für die Frühbetreuung **oder** das Modul bis 13:00" — ein Fall über zwei
Module. `uq_emergency_care_types_module` lässt je Modul nur eine Zeile zu, also braucht
dieser eine Fall zwei Zeilen und zwei Zeilen in `emergency_care_prices`; derselbe Betrag
steht danach an zwei Orten (rules.md §1). Der Kommentar zählt dagegen „fünf Fälle", was nur
aufgeht, wenn eines der beiden Module ohne Fall bleibt.
Vorschlag: entweder den Kommentar auf sechs Zeilen richtigstellen oder die Zuordnung
Fall↔Modul als eigene Zeilentabelle führen, damit der Betrag einmal steht.

[F19] anmeldung · Klasse 1 · admission_days
06 führt das Pausenfenster in derselben Aufzählung wie Datum, Von–Bis, Ziel, Fensterlänge
und Plätze, abgeschlossen mit „(Pflicht)"; `break_from_time`/`break_to_time` sind nullable,
und die Datei begründet die Abweichung nirgends — obwohl der Sondertermin („der kleinste
Anmeldetag") ein guter Grund dafür wäre. Nachgestellt geht ein Anmeldetag ohne Pause durch.
Vorschlag: die Auslassung als Kommentar an der Spalte begründen, oder mit 06 klären, ob
„(Pflicht)" das Pausenfenster mitmeint.

[F20] anmeldung · Klasse 1 · care_module_bookings
09 gibt „nach Mittagsschule" „allein für Realschule Klasse 5" frei, und `care_modules` führt
`school_branch_id` und `restricted_to_grade_level` genau dafür. Nichts bindet die Buchung an
das Kind: nachgestellt bucht ein Grundschulkind der Stufe 2 dieses Modul ohne Widerspruch.
Die harte Platzgrenze am Anmeldetag hat für dieselbe Lage einen Kommentar und eine Probe,
die die Auslassung festhalten — hier fehlt beides.
Vorschlag: entweder wie dort die Auslassung mit Kommentar und Probe festhalten (ein externes
Hortkind hat keine Schulart, ein Constraint träfe es mit) oder die Bindung bauen.

[F21] anmeldung · Klasse 7 · applications
Der Kommentar an `documents_checked_at` macht die Unterlagenprüfung des Anmeldetags zum
Anker des dritten Zustands für `kindergarten_consent_at` (grenzkarte.md, „Drei Zustände").
05 erhebt die Einwilligung aber schon in der Voranmeldung und nennt sie dort „(Pflicht)".
Zwischen Absenden und Anmeldetag liest ein leeres Feld deshalb als „nicht gefragt", obwohl
der Block es als Pflichtangabe führt; die Karte ist hier älter als der Block.
Vorschlag: den Anker auf `submitted_at` umschreiben oder mit 05 klären, ob die Einwilligung
bei der Grundschul-Voranmeldung wirklich Pflicht ist.
```

### Angesehen, nicht als Fund gewertet

```
applications · `ck_applications_care_need` sah nach Klasse 2 aus — ein Umfang ohne
        Interesse. 06 nennt beide „dieselbe Angabe … hier um den Umfang ergänzt", der
        Constraint trägt also die Lesart des Blocks.
contracts · Die vom SQL selbst benannte Lücke in `ix_contracts_running` (zwei laufende
        Schulverträge mit verschiedenem `runs_until`) bleibt eine Lücke — kein Block gibt
        einen Tag her, ab dem der zweite gilt, also gibt es nichts zu bauen.
admission_day_slots · `places_override` erlaubt auch das Senken, 06 nennt nur „erhöhen".
        Die harte Grenze trägt ohnehin die Anwendung (dort mit Kommentar und Probe belegt),
        der Block gibt dem Constraint nichts her.
contract_responses · Der XOR über `accepted_at`/`declined_at` überschreibt eine
        Meinungsänderung. 08 kennt nur „an oder ab" und keine Historie — die trägt die
        Änderungsspur.
Unterlagen des Anmeldetags · keine eigene Tabelle hier; sie sind Q2 (grenzkarte.md,
        „Dokument"), der Elternfragebogen ist im Dateikopf begründet, der Masernnachweis
        steht in Domäne 9.
care_module_prices · Das Zitat zur Geschwisterermäßigung stammt aus dem Betreuungsvertrag,
        einem Dokument außerhalb des Repos. Nicht nachprüfbar, aber ehrlich als solches
        gekennzeichnet — die Fassung in 09 stimmt damit überein.
care_bridge_day_responses · Ein Kind ohne Betreuungsvertrag kann geantwortet bekommen. 09
        verbietet es nicht, und die Nachbartabelle steht Nicht-Hortkindern ausdrücklich
        offen.
signatures · Die Bindung der Unterschrift an den Vertrag unter der Modulanlage trägt
        (`ck_signatures_agreement`, querschnitt), und die Probe belegt sie am richtigen
        Constraint.
Q3 · Die Anmeldegebühr geht per Cascade mit ihrer Bewerbung; nachgeprüft, trägt.
```

### `[A!]` in dieser Domäne

```
anmeldung · `care_bridge_days`: dass an einem Tag mit Ferienprogramm keine Abfrage entsteht,
        prüft die Anwendung und kein Trigger. 09 entscheidet die Regel selbst („Läuft an dem
        Tag ein Ferienprogramm, entsteht keine Abfrage: Dort wird gebucht"), nicht aber ihre
        Durchsetzung — die Marke lässt damit nichts offen, was ein Block entscheidet.
```

### Sortierung nach Gewicht

Im Betrieb brechend: F1, F2, F3, F5, F7. Beleglage des Schemas: F4, F6, F8, F9, F10.
Zitate und Quellen: F11, F12, F13, F14, F15, F16. Unsauber, nicht brechend: F17, F18, F19,
F20, F21.

Ohne Fund durchgekommen: keine — geprüft wurde allein `anmeldung`.
