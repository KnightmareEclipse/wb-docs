# Prüfbericht querschnitt

Gehalten gegen `soll-prozesse/hebel.md`, `rules.md` (1, 3, 7), `grenzkarte.md` und die Blöcke
00, 01, 02, 03, 04, 05, 06, 08, 09, 10, 11, 12, 13, 14, 17, 19, 21 — also gegen jeden, den
`schema/querschnitt-schema.sql` nennt.

**Läufe.** Alle vierzehn `*-schema.sql` in der dokumentierten Reihenfolge in eine leere
PostgreSQL-18-Datenbank: Rückgabewert 0 je Datei. `schema/querschnitt-schema-check.sql` gegen diese
vollständige Datenbank: **Rückgabewert 0**. Dazu zwei eigene Läufe: einer mit instrumentierten
Hilfsfunktionen, der je Gegenprobe den tatsächlich auslösenden Constraint und je `expect_accept` die
getroffene Zeilenzahl meldet (161 Proben, keine mit `rows=0`), und einer mit eigenen `INSERT`s gegen
die Fälle aus den Blöcken.

## Funde

```
[QUERSCHNITT-F1] querschnitt · Klasse 2 · payments
`ck_payments_amount CHECK (amount_cents > 0)`; akademie-schema.sql erlaubt mit
`ck_academy_offerings_amount` und `ck_academy_registrations_amount` ausdrücklich den
Betrag 0, und 21 verbietet ein kostenloses Angebot nirgends. Eine Familie ohne
SEPA-Mandat meldet sich zu ihm über die Sofortzahlung an — „die Anmeldung entsteht
erst mit der bestätigten Zahlung" (21 Z5) —, und genau diese Zahlungszeile ist nicht
eintragbar (eigener Angriff: 23514 ck_payments_amount).
Vorschlag: `>= 0` wie im Schwesterschema, oder in 21 entscheiden, dass ein Angebot
einen Betrag über null tragen muss.

[QUERSCHNITT-F2] querschnitt · Klasse 5 · consents / Prüfskript
Die Probe „Q2 — Zustimmung für ein Kind mit der Datei eines anderen"
(querschnitt-schema-check.sql, Z619) behauptet, „allein der zusammengesetzte
Fremdschlüssel" weise ab. Sie wird von `ck_consents_checksum` abgewiesen (23514):
der INSERT setzt `document_id` ohne `document_checksum`. `fk_consents_document` als
Paar (document_id, child_id) — die Regel „Eine Datei beim falschen Kind ist keine
ältere Fassung" (grenzkarte.md, Q2) — ist damit unbelegt; mit Prüfsumme im INSERT
trägt er (eigener Angriff A10: 23503 fk_consents_document).
Vorschlag: der Probe die Prüfsumme mitgeben, dann feuert der Fremdschlüssel.

[QUERSCHNITT-F3] querschnitt · Klasse 2 · documents / child_file_folders
`documents.child_file_folder_id` ist NOT NULL, also braucht auch die bloße
Anforderung ohne Datei (06, „Unterlagen, je Stück vorgelegt, fehlt oder nicht nötig")
schon einen Ordner. Der Kommentar an `child_file_folders` sagt das Gegenteil: „ein
Unterordner der Schülerakte entsteht, wenn das erste Blatt seiner Kategorie
hereinkommt". Am Anmeldetag entstehen fünf bis sechs Anforderungen je Kind — damit
legt die Anwendung in SharePoint Ordner an, in die nie etwas kommt, und der
Lösch-Lauf räumt sie später wieder.
Vorschlag: entweder den Kommentar auf „mit der ersten Zeile ihrer Kategorie"
richtigstellen, oder `child_file_folder_id` bei einer Zeile ohne `graph_item_id`
nullable lassen.

[QUERSCHNITT-F4] querschnitt · Klasse 1 · retention_subjects
Der Kommentar zählt „die Codes, die die Blöcke heute nennen" auf — „application",
„child_health_record", „health_occasion", „holiday_booking", „holiday_care_note",
„academy_registration", „excursion", „contract", „sepa_mandate", „child_file",
„care_file", „employee". Der Bestand der **Rechnungsfreigabe** fehlt, obwohl dieselbe
Datei ihn an `configured_values` über zwölf Zeilen beschreibt („Eine Frist kündigt
der Lösch-Lauf nur an: die der Rechnungsfreigabe") und 12 wie 17 ihn als Bestand mit
zwei Ankündigungen an Buchhaltung und Geschäftsführung ausschreiben.
Vorschlag: den Code („expense_claim") in die Aufzählung aufnehmen.

[QUERSCHNITT-F5] querschnitt · Klasse 1 · sync_targets
Der Kommentar erklärt, wo ein Block eine zweite Aufgabenart beim selben System und
derselben Rolle verlangt, und nennt zwei Fälle (Änderungsgebühr 09, berechnete
Ferienbuchungen 10). Er übergeht die beiden größten: die **Abgangsliste** (03 Z2)
führt je Kind mehrere Punkte beim Sekretariat — Schulvertrag, Mensa,
Bescheinigungen —, und der **Jahreslauf** (04 Z1 und Z4) vier Aufgaben zum selben
Bezug Schuljahr (Preise prüfen, Putzdienstjahr einrichten, Voranmeldung öffnen,
Lösch-Lauf anstoßen). `ix_sync_tasks_open_child` bzw. `ix_sync_tasks_open_year`
lassen sie nur mit je eigener Aufgabenart nebeneinander stehen.
Vorschlag: die Aufzählung um 03 und 04 ergänzen — die Zahl der Arten folgt aus den
Blöcken und nicht aus der Zahl der Fremdsysteme.

[QUERSCHNITT-F6] querschnitt · Klasse 5 · mail_categories / Prüfskript
`requires_family_recipient` trägt die Regel aus 00: „einer je Familie muss sie
bekommen", und der Kommentar sagt, sie lebe in der Schreibschicht. Geprüft wird nur
das Häkchen selbst (`ck_mail_categories_floor`). Für die zweite Regel derselben Art —
mindestens zwei Empfänger je Bestand — führt dasselbe Skript eine Abfrage als
Gegenprobe („die zugleich der Betrieb laufen lässt"); hier fehlt sie, obwohl die
Abwahl des Letzten „abgewiesen, nicht stillschweigend übergangen" wird.
Vorschlag: dieselbe Bauform — eine Abfrage über die Familien ohne Empfänger einer
Kategorie mit `requires_family_recipient`.

[QUERSCHNITT-F7] querschnitt · Klasse 3 · vier Zitate
Vier wörtliche Zitate stehen so nicht in dem Block, dem sie zugeschrieben sind
(mechanisch gegen alle `.md` und `.txt` geprüft):
  * Z207 „Schulinformationen darf man abwählen, aber einer in der Familie muss sie
    mindestens bekommen." (Herkunft: 00) — 00 sagt „ja, aber **einer je Familie muss
    sie bekommen**" in einer Tabelle und „Bei der Schulinformation greift die
    Untergrenze".
  * Z574 „genügt die Mitteilung, es entsteht nichts am Kind" (08) — 08 sagt „Es
    entsteht nichts am Kind, und **die Mitteilung geht von selbst hinaus**". Der
    Wortlaut stammt aus einer früheren Fassung von 08; TASK-231 zitiert ihn noch so.
  * Z1269 „wann von der Schule abgegangen und welcher Schulzweig" (im Herkunftsblock
    zu 08 „Löschen") — 08 zählt „Vorname, Nachname, Geburtsdatum, Abgangsdatum,
    Schulzweig" auf.
  * Z1013 „Die Art steht nur dort, wo ein Prozess nach genau dieser Unterlage fragt"
    (grenzkarte.md, Q2) — dort steht „**Sie** steht nur dort …"; Z678 „in **seiner**
    jeweils gültigen Fassung" (09) — dort steht „in **ihrer**".
Vorschlag: die vier gegen die Quelle richtigstellen; die Pronomen wie an anderer
Stelle in derselben Datei in Klammern auflösen („[Die Art] steht nur dort").

[QUERSCHNITT-F8] querschnitt · Klasse 3 · zwei Zitate aus einer Schwester-`.sql`
Am `payment_modes` stehen zwei Sätze als Blockzitate, die aus
`akademie-schema.sql` stammen und in 10 und 21 so nicht vorkommen:
„ein Code tritt an die Stelle der Zahlung und nur dort" (zugeschrieben 10/21;
akademie-schema.sql: `ck_academy_registrations_coverage`) und „der Einzug bleibt dem
Kinder-Zweig" (zugeschrieben 21; akademie-schema.sql:
`ck_academy_registrations_adult_payment`). Inhaltlich decken die Blöcke beides — 10
„Er tritt an die Stelle der Zahlung", 21 „Im Erwachsenen-Zweig wird nie eingezogen" —,
aber die Quellenangabe zeigt am Block vorbei auf einen Kommentar, der selbst kein
Beleg ist.
Vorschlag: entweder den Blockwortlaut zitieren oder die Datei als Quelle nennen.

[QUERSCHNITT-F9] querschnitt · Klasse 3 · drei Zitate der Geschäftsführung
  * Z1628 „Generell soll es möglich sein, die Löschfristen dynamisch anzupassen
    **durch die Geschäftsführung**, und sie sollen nicht fix im Code stehen."
    (Geschäftsführung, 04.09.2026) — TASK-251 hält den Satz ohne den eingefügten
    Halbsatz fest: „Generell soll es moeglich sein die Loeschfristen dynamisch
    anzupassen und sie sollen nicht fix im Code stehen." Eingefügt ist gerade die
    Zuständigkeit, um die es geht.
  * Z399 „Vorerst soll kein Lehrer Zugriff auf die direkte Schülerakte haben."
    und Z581 „kann man das als Variable einstellen lassen" — beide haben im ganzen
    Repo keine Fundstelle, während die übrigen Zitate desselben Termins in
    `backlog/tasks/` stehen (TASK-231, TASK-247, TASK-251).
Vorschlag: den ersten auf den Wortlaut aus TASK-251 zurücknehmen, die beiden anderen
in ihrem Ticket festhalten oder als Zusammenfassung ohne Anführungszeichen schreiben.

[QUERSCHNITT-F10] querschnitt · Klasse 5 · retention_holds / Prüfskript
Die Probe „17 — Anhalten ohne Grund aus der Werteliste" (Z1976) lässt
`retention_hold_reason_id` weg und wird deshalb vom NOT NULL abgewiesen (23502, ohne
Constraint-Namen). Belegt ist damit, dass ein Grund steht, nicht dass er aus der
Werteliste kommt — genau die Aussage des Kommentars („ein Freitext stünde daneben").
Der Fremdschlüssel trägt (eigener Angriff A9: 23503 fk_retention_holds_reason).
Vorschlag: eine zweite Probe mit einer Grund-Kennung, die es nicht gibt.

[QUERSCHNITT-F11] querschnitt · Klasse 5 · sync_tasks / Prüfskript
`fk_sync_tasks_target` hält das mitgeführte `is_branch_bound` an seinem Ziel. Für die
beiden Schwesterfälle gibt es je eine Gegenprobe („Q5 — Ziel mit dem Zweig-Flag einer
Rolle, die es nicht hat", „Q2 — Fotoeinverständnis mit dem Flag der
Werbe-Einwilligung"); für die Aufgabe selbst keine. Die beiden vorhandenen Proben
feuern beide auf `ck_sync_tasks_branch_bound`, nicht auf den Fremdschlüssel. Er trägt
(eigener Angriff A5: 23503 fk_sync_tasks_target).
Vorschlag: eine Probe mit `is_branch_bound = true`, gesetzter Schulart und einem
Ziel, dessen Rolle nicht zweiggebunden ist.

[QUERSCHNITT-F12] querschnitt · Klasse 5 · photo_consent_records / Prüfskript
`uq_photo_consent_records_graph_item` trägt denselben Satz wie
`uq_documents_graph_item` und `uq_child_file_folders_graph_item` — „zwei Zeilen auf
demselben Element ließen den Lösch-Lauf eine Datei entfernen, auf die die zweite noch
zeigt". Die beiden anderen haben je eine Gegenprobe, diese keine; sie trägt (eigener
Angriff A6: 23505).
Vorschlag: die dritte Probe nach dem Muster der beiden anderen.

[QUERSCHNITT-F13] querschnitt · Klasse 5 · sync_tasks / Prüfskript
Von den neun partiellen Unique-Indizes zu „Je Aufgabenart und Bezug höchstens eine
offene Aufgabe" haben hier zwei eine Gegenprobe (Kind, Zeitraum); drei stehen in den
Schwesterskripten (Ferienbuchung, Akademie-Anmeldung, Putztermin). Ohne Gegenprobe
bleiben `ix_sync_tasks_open_person` (02), `_family` (01), `_year` (04) und `_payment`
(api/gemeinsam.md) — alle vier gehören dieser Datei.
Vorschlag: vier Proben nach dem Muster der beiden vorhandenen.

[QUERSCHNITT-F14] querschnitt · Klasse 5 · Prüfskript, Abschnitt 10
Die Reihenfolge des Lösch-Laufs wird gegen `pg_constraint` gehalten, aber die
Tabellennamen in `loeschlauf` sind ungeprüfter Text: Ein Name, den es nicht mehr gibt,
fällt aus beiden Abfragen heraus, statt zu melden. Heute stimmen alle
vierunddreißig; eine Tabelle, die nichts mit NO ACTION festhält und von nichts so
festgehalten wird — `addresses` ist genau der Fall —, verschwände bei einer
Umbenennung spurlos aus der Prüfung, und der Lauf bliebe grün.
Vorschlag: eine Zeile davor, die jeden Namen gegen `to_regclass` hält.

[QUERSCHNITT-F15] querschnitt · Klasse 5 · Prüfskript, Kopf
Der Sollstand nennt „zwei Lese-Indizes, auf outbound_emails und auf change_log". Es
sind drei — `ix_retention_holds_held_until` steht seit dem Lösch-Lauf daneben und ist
in Abschnitt 2 auch geprüft. Tabellenzahl (24), Constraints und die siebzehn
partiellen Unique-Indizes stimmen.
Vorschlag: „drei" und den dritten Namen nachtragen.

[QUERSCHNITT-F16] querschnitt · Klasse 3 · drei Verweise auf einen Abschnitt, den es
nicht mehr gibt
Der Hebel heißt seit dem 04.09.2026 „Geld **und Fristen** im System, alles andere
fest". `querschnitt-schema.sql` verweist dreimal auf „hebel.md, „Geld im System,
alles andere fest"" (Z507, Z717, Z1617), das Prüfskript einmal auf „hebel.md, „Geld
im System"" (Z993) — ein toter Abschnittsname, und ausgerechnet an der Tabelle, die
die Löschfristen trägt.
Vorschlag: den heutigen Namen einsetzen.

[QUERSCHNITT-F17] querschnitt · Klasse 1 · retention_subjects / configured_values
17 verlangt „Eine Frist ohne Wert löscht nichts" und „der Löschtermin ist nie früher
als vierzehn Tage, nachdem der Wert eingetragen wurde" — der Lauf muss also je
Bestand seinen Wert finden. `retention_subjects.code` und `configured_values.code`
sind zwei getrennte Zeichenketten ohne Verbindung; welcher Wert zu welchem Bestand
gehört, steht nur im Anwendungscode. Ein Tippfehler dort sieht aus wie „noch nicht
eingetragen", und das ist derselbe stille Ausfall, den 17 als sicher beschreibt.
Vorschlag: eine Spalte an `retention_subjects`, die den `configured_values`-Code
nennt — oder im Kommentar festhalten, dass die Zuordnung bewusst im Code bleibt.

[QUERSCHNITT-F18] querschnitt · Klasse 5 · consents
`ix_consents_person_child_purpose` lässt eine zweite gültige Antwort erst zu, wenn
die erste widerrufen ist; `ck_consents_revocation` lässt aber nur eine **Erteilung**
widerrufen. Der Weg von „Nein" nach „Ja" — 08: „Gesundheitsangaben und
Fotoeinverständnis ändern die Eltern danach jederzeit im Portal" — geht deshalb nur
als `UPDATE` derselben Zeile, der Weg von „Ja" nach „Nein" als neue Zeile (eigene
Angriffe A1–A3). Geprüft ist allein die zweite Richtung („Q1 — neue Antwort nach
Widerruf der ersten").
Vorschlag: eine Gegenprobe für die erste Richtung, damit die Bauform festgehalten ist.
```

**Sortierung nach Gewicht:** F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15,
F16, F17, F18.

## Angesehen, nicht als Fund gewertet

```
querschnitt · Die Freigabe eines Akademie-Angebots (21 Z2) findet keinen der neun
        Bezüge von `sync_tasks` — akademie-schema.sql entscheidet das ausdrücklich:
        „die Aufgabe ist keine Zeile in `sync_tasks`, sondern folgt aus diesen
        beiden Spalten".
querschnitt · `ix_retention_holds_first` lässt je Bestand und Anker genau eine erste
        Zeile zu, für immer. Sah nach Klasse 2 aus; 17 trägt es — „Erneut anhalten
        darf sie beliebig oft" meint die Kette über `first_hold_id`, und der
        ursprüngliche Termin soll gerade stehenbleiben.
querschnitt · `photo_consent_records` hat keine Eindeutigkeit über Name und
        Geburtsdatum: zwei gleiche Nachweise ohne Datei gehen durch (eigener Angriff
        A7). Der Lauf räumt „einen Anker vollständig oder gar nicht" (17), ein
        Wiederholungslauf legt also keine zweite Zeile an; wo eine Datei dranhängt,
        fängt `uq_photo_consent_records_graph_item` es ohnehin.
querschnitt · `ck_payments_single_cause` erlaubt **keinen** Anlass. Sah nach einer
        zu weiten Regel aus; sie ist der ausgeschriebene Ausnahmefall aus
        api/gemeinsam.md samt der Aufgabe daneben.
querschnitt · `ck_signatures_agreement`, `ck_signatures_amendment` und die drei
        vertragsgebundenen Signaturindizes haben hier keine Gegenprobe — sie stehen
        in anmeldung-schema-check.sql (Z1394–Z1536), wie der Kopf es ankündigt;
        ebenso die Q3-Proben zu Status, Zeitpunkt, Betrag und Zahlungsreferenz in
        putzdienst-schema-check.sql (Z206–Z329).
querschnitt · Die erste der beiden Lehrerzugriff-Abfragen prüft Zeilen, die das
        Skript selbst mit der Voreinstellung angelegt hat, und kann nur scheitern,
        wenn die Voreinstellung falsch ist — was die zweite Abfrage ohnehin belegt.
        Redundant, aber kein Fund.
querschnitt · Die versandte Mail ohne Person hat keinen Löschanker. Das ist die
        offene `[?]`-Frage am Dateiende und keine Lücke.
querschnitt · Kein `expect_accept` traf null Zeilen (161 Proben instrumentiert
        nachgezählt) — die erste der vier Fallen ist zugeschnappt bei keiner.
```

## `[A!]` dieser Domäne

```
Z15   Q1–Q5 stehen in einer eigenen Datei statt in der ersten Domäne, die sie
      braucht. — Kein Block entscheidet das; es trägt grenzkarte.md, Regel 4 („Was
      in mehr als einer Domäne vorkommt, gehört keiner davon").
Z815  Eine Signatur hängt am Vertragsvorgang, nicht am Dokument. — **Ein Block
      entscheidet sie:** 08, „Vor der Freigabe entsteht kein Dokument", und die
      beiden Unterschriften ohne Vertrag (Mandat, Kind ab 14) stehen dort ebenfalls.
Z1846 Der Bezug der Änderungsspur ist Tabellenname plus Schlüssel als Text, ohne
      Fremdschlüssel. — Kein Block entscheidet das; hebel.md verlangt nur, dass es
      ein Mechanismus ist und kein zweiter daneben, und 17 verlangt den Anker als
      Spalte — beides ist erfüllt.
```

## Ergebnis

Die Domäne kommt **nicht ohne Fund** durch: achtzehn, davon sechs an der Struktur
(F1, F3, F4, F5, F17 und, als falsche Belegstelle, F2) und zwölf am Beleg — Zitate,
fehlende oder aus dem falschen Grund abgewiesene Gegenproben und ein Sollstand, der
um einen Index danebenliegt. Das Prüfskript selbst läuft grün.
