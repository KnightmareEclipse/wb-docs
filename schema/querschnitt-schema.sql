-- Querschnitt — was in mehr als einer Domäne vorkommt und deshalb keiner
-- gehört: Zustimmung (Q1), Dokument und Signatur (Q2), Zahlungsvorgang (Q3),
-- Nachzieh-Aufgabe (Q5), die vier Hebel aus hebel.md, die jede Domäne
-- braucht — die Änderungsspur, die versandte Mail, die Werte im System und die
-- Vertragstexte —, und der Lösch-Lauf (17), der wie sie keiner Domäne gehört.
-- Q4 (Mitarbeitende) steht als `employees` in stammdaten-schema.sql.
-- Lesepfad: `signatures` und `documents` zuerst — beide hängen am Kind bzw. am
-- Vertragsvorgang; `consents` zeigt optional auf eine Signatur. `payments`,
-- `sync_tasks`, `configured_values` und `change_log` stehen unabhängig daneben.
-- Der Lösch-Lauf am Ende ist zweigeteilt: `retention_notice_recipients` sagt,
-- wer je Bestand die Ankündigung bekommt, `retention_holds`, welcher Anker
-- gerade übersprungen wird.
--
-- [A!] Q1–Q5 stehen in einer eigenen Datei statt in der ersten Domäne, die sie
-- braucht. — Alternative: Q3 im Putzdienst, Q1/Q2/Q5 in der Anmeldung, wie im
-- Vorentwurf; Preis: „was in mehr als einer Domäne vorkommt, gehört keiner
-- davon" (grenzkarte.md, Regel 4) wäre eine Absichtserklärung statt einer
-- Dateigrenze, und die vierte Domäne fügte einer fremden Datei Spalten hinzu.
--
-- ===========================================================================
-- ACHTUNG BEIM BAU DER ANWENDUNG: Die Änderungsspur (`change_log`) wird von der
-- Anwendung geschrieben, nicht von einem Datenbank-Trigger — der Prompt
-- schließt Trigger aus, weil eine Regel, die nur in der Datenbank lebt, im Code
-- unsichtbar ist. Folge: **jeder Schreibpfad, der eine der Tabellen dieses
-- Modells ändert, muss die Spur selbst schreiben.** Wird das an einer Stelle
-- vergessen, fehlt dort die Spur lautlos — nichts in der Datenbank meldet es.
-- Die Absicherung gehört deshalb ins Backend-Repo (eine gemeinsame
-- Schreibschicht, durch die jede Änderung läuft), nicht hierher.
-- Falls doch je auf Trigger umgestellt wird: „wer hat geändert" ist lösbar,
-- ohne dass jede Person einen eigenen Datenbankbenutzer braucht — die
-- Anwendung setzt den Urheber je Transaktion als sitzungslokale Variable, der
-- Trigger liest sie. Das ist hier bewusst nicht gebaut, aber kein Hindernis.
-- ===========================================================================
--
-- ===========================================================================
-- DIE REIHENFOLGE DES LÖSCH-LAUFS (17). Jede Tabelle nennt ihren eigenen
-- Löschanker; die Abfolge über alle Domänen nennt keine, und ohne sie kommt der
-- Lauf beim ersten Versuch nicht durch: `DELETE FROM children` scheitert an
-- zwölf Fremdschlüsseln, die das Kind mit Absicht festhalten. Sie steht
-- deshalb hier, weil sie keiner Domäne gehört. Sieben Stufen:
--
--   1. Die Vorgänge am Kind, jeder erst, wenn seine eigene Frist abgelaufen
--      ist: `child_file_folders` (die Datei in SharePoint zuerst, „eine
--      verwaiste Datei … ist genauso ein DSGVO-Verstoß wie eine verwaiste
--      Zeile" — und mit ihr beide Papierkorb-Stufen, sonst liegt sie noch
--      93 Tage da, grenzkarte.md Q2), `sepa_mandates`, `contracts`, dann `applications` — der Vertrag
--      hält seine Bewerbung fest und geht ihr voraus —, `holiday_bookings`,
--      `meal_subscriptions`, `emergency_care_bookings` und
--      `care_bridge_day_responses` — beide hängen am Kind und an keinem
--      Vertrag, ein Kind ohne Betreuungsvertrag kann beide haben —,
--      `health_trait_values`, die unterschriebene
--      Zustimmung (`consents`, wo sie eine Datei trägt) und zuletzt
--      `documents`. Jeder nimmt mit, was an ihm hängt: Unterschriften,
--      Antworten, Modulanlagen, Zahlungen, Esstage.
--      `documents` steht am Ende dieser Stufe und nicht an ihrem Anfang: der
--      freigegebene Vertrag (`fk_contracts_document`), das Mandat
--      (`fk_sepa_mandates_document`), die unterschriebene Zustimmung
--      (`fk_consents_document`) und das Attest
--      (`fk_health_trait_values_document`) halten das Dokument mit NO ACTION
--      fest. Weiter nach hinten kann es nicht — es hält selbst das Kind
--      (`fk_documents_child`) und muss vor Stufe 2 fort sein. Deshalb steht
--      auch `health_trait_values` hier und nicht erst in Stufe 2, wo es per
--      Cascade mit dem Gesundheitssatz ginge, ohne dass der Lauf es sieht: bis
--      dahin hielte es das Attest fest. Merkmal und Antwortzeile darüber nennt
--      der Lauf nicht — sie halten nichts fest und gehen mit dem Bestand.
--      Der `child_health_records` selbst steht dagegen hier und nicht in
--      Stufe 2: **drei Monate nach dem Austritt** (Datenschutzbeauftragter,
--      02./03.09.2026), während der Vertrag fünf Jahre steht und das Kind so
--      lange festhält. Er hält sein Kind deshalb mit NO ACTION fest, statt per
--      Cascade mit ihm zu gehen — sonst überlebte kein Anhalten den Vertrag,
--      und der Handlungshinweis der Klassenlehrkraft stünde vier Jahre und neun
--      Monate zu lang. Was unter ihm hängt — Antwort, Merkmal, Freigabe —,
--      nimmt er mit.
--      Gleich nach `holiday_bookings` und noch in dieser Stufe steht der
--      eingelöste `holiday_cost_coverage_codes`: die Buchung hält ihn mit
--      NO ACTION fest (`fk_holiday_bookings_coverage_code`), und er trägt eine
--      Mailadresse und den Satz, an wen berechnet wird. Er ist die einzige
--      Zeile dieser Stufe, die keinem Kind gehört — der nicht eingelöste Code
--      geht deshalb nicht mit diesem Lauf, sondern nach seiner eigenen Frist
--      (ferien-schema.sql).
--      Ebenfalls in dieser Stufe, und vor der Buchung, die länger steht:
--      `holiday_care_notes` — vier Wochen nach dem letzten gebuchten Termin,
--      „nach dem Programm gibt es keinen Zweck mehr, sie zu halten" (10). Sie
--      hält ihr Kind fest, statt mit ihm zu gehen: Eine angehaltene Anmerkung
--      darf nicht per Cascade verschwinden.
--      Neben der Ferienbuchung steht `academy_registrations` mit demselben
--      Abstand zu ihrem Anker, und dahinter ihr eingelöster
--      `academy_cost_coverage_codes` (akademie-schema.sql). Die Anmeldung des
--      Erwachsenen-Zweigs gehört keinem Kind, sondern hält ihre Person fest;
--      auch sie geht hier und nicht erst in Stufe 6 — sonst bliebe der Lauf
--      dort an ihr stehen.
--   2. `children`. Von hier gehen Zustimmung, Unterschrift, Gesundheitssatz
--      (seine Merkmale sind in Stufe 1 schon fort), Masernnachweis,
--      Essensprofil, Nachzieh-Aufgabe und Änderungsspur per Cascade mit — ohne
--      dass der Lauf sie einzeln sieht.
--   3. Die Vorgänge an der Familie, jeder auf dem Jahreslauf seiner eigenen
--      Domäne und nicht auf dem Austritt: `parent_work_entries` (14) und
--      dahinter `parent_work_sessions` — der ausgeschriebene Einsatz gehört
--      keiner Familie, folgt aber derselben Schuljahresfrist und nimmt seine
--      Anmeldungen per Cascade mit; die Stunde daraus überlebt ihn und behält
--      ihre Tätigkeit (elternbonus-schema.sql). Dann `cleaning_slot_buyouts` — vor der Zuteilung, die er mit NO ACTION
--      festhält, damit das Streichen eines einzelnen Termins den bezahlten
--      Freikauf nicht mitnimmt (putzdienst-schema.sql) —, dann
--      `cleaning_assignments`, `cleaning_buyouts`, `cleaning_family_quotas`
--      (01).
--   4. `families`. Sorgerecht und Kontakte gehen per Cascade mit.
--   5. `employees`, ab `last_working_day` (13). Die Rollen gehen mit; was
--      seinen Namen anderswo trägt, überlebt ihn (Beleg 12) und braucht den
--      Namen vorher gesetzt.
--   6. `persons`. Telefonnummern, die Sorgeberechtigten-Angaben (`guardians`),
--      kindlose Zustimmungen, versandte Mails, Aufgaben, Spur und das
--      Elternvertretungsamt gehen mit.
--   7. Die verwaisten `addresses` — die, auf die danach weder eine Person noch
--      ein Mandat zeigt. Die Anschrift hat keinen eigenen Anker („eine
--      Anschrift verschwindet mit der letzten Person, die auf sie zeigt",
--      stammdaten-schema.sql), und keine Cascade bringt sie dorthin:
--      `persons.address_id` und `sepa_mandates.account_holder_address_id`
--      zeigen vorwärts auf sie. Deshalb folgt sie als einzige nicht aus
--      einem Fremdschlüssel, sondern allein aus ihrem Löschanker, und der Lauf
--      muss sie selbst berechnen. Ohne sie läuft er über
--      alle sechs Stufen davor sauber durch und lässt genau eine Zeile stehen:
--      Straße, Hausnummer, PLZ und Ort.
--   Eine achte Stufe für die `change_log`-Zeilen gibt es **nicht**, und das ist
--   das Ergebnis von Block 17: Die Spur bekommt keine eigene Frist, sondern
--   ihren Anker. Sie lebt genau so lange wie das, worüber sie Auskunft gibt —
--   wer nachweisen muss, wer eine Gesundheitsangabe entfernt hat, braucht sie,
--   solange das Kind da ist, und danach keinen Tag. Daraus folgen zwei Fälle:
--     * Die geänderte Zeile hängt an Kind, Person oder Familie — bei 66 der
--       hundert Tabellen, meist über zwei oder drei Tabellen hinweg. Dann trägt
--       die Spur diesen Anker und geht per Cascade mit ihm, in Stufe 2, 4 oder
--       6, ohne dass der Lauf sie einzeln sieht. **Die Schreibschicht muss ihn
--       über den Join setzen**, nicht nur aus einem direkten Attribut der
--       geänderten Zeile (`wb-backend/app/db/base.py`); heute tut sie das
--       nicht, und genau das ist die Lücke, die Block 17 schließt.
--     * Die geänderte Zeile hängt an keinem der drei — ein Wert im System, eine
--       Werteliste, `addresses` als Anschrift ohne Bewohner, die drei Marken an
--       einer bloßen Mailadresse (`application_unlocks`,
--       `holiday_cost_coverage_codes`, `academy_cost_coverage_codes`), `payees`.
--       Dann geht ihre Spur **mit dieser Zeile**: Wer die Zeile löscht, hält
--       ihren Schlüssel und nimmt die Spur im selben Schritt mit.
--   Löschen darf sie allein der Lauf — nicht `backend_runtime`, das sie liest
--   und schreibt, und kein Mensch: Eine Stelle, die die Spur löschen kann, kann
--   auch ihre eigene löschen (17).
--
-- Gebaut ist daran nichts — die Reihenfolge folgt aus den Fremdschlüsseln, die
-- schon stehen. Damit sie es bleibt, prüft `querschnitt-schema-check.sql` sie
-- gegen jeden Fremdschlüssel, der eine Tabelle dieser Stufen mit
-- NO ACTION festhält — nicht nur die auf Kind, Familie und Person: Eine neue
-- Tabelle, die eine davon festhält, bricht dort, statt beim ersten Lauf in
-- Produktion, und ebenso eine Tabelle, die weiter hinten steht als die, die sie
-- festhält.
-- ===========================================================================
--
-- Acht Fremdschlüssel dieser Datei zeigen vorwärts auf Domänen, die es hier
-- noch nicht gibt. Sie werden am Ende der besitzenden Domänendatei per
-- ALTER TABLE nachgetragen: `signatures.contract_id`,
-- `signatures.care_module_agreement_id` und `payments.application_id` in
-- anmeldung-schema.sql, `payments.cleaning_buyout_id`,
-- `payments.cleaning_slot_buyout_id` und `sync_tasks.cleaning_slot_id` in
-- putzdienst-schema.sql, `payments.holiday_booking_id` und
-- `sync_tasks.holiday_booking_id` in ferien-schema.sql.


-- ---------------------------------------------------------------------------
-- Wertelisten
-- ---------------------------------------------------------------------------

-- Herkunft: grenzkarte.md, Q1 — „Braucht sie: Schulvertrag, Gesundheitsdaten,
-- Fotoeinverständnis, Werbe-Einwilligung Ferienbetreuung, die Einwilligung zum
-- Informationsaustausch zwischen Hort und Schule … und die
-- Lastschrift-Ermächtigung". Kein Löschanker: keine Personendaten.
-- Audit-Spalten, weil ein hier ergänzter Zweck sofort eine abzufragende
-- Einwilligung wird.
-- Die Zeckenentfernung fehlt in dieser Liste, und das ist keine Abweichung von
-- der Karte, sondern ihr eigener Satz: „Die Zeckenentfernung steht entgegen
-- einer älteren Fassung dieser Karte nicht hier" (Q1) — sie ist eine
-- Merkmalsart in `health_trait_types` (gesundheit-schema.sql).
-- Ebenso ohne die Lastschrift-Ermächtigung: 11 sagt „Das Schulgeld-Mandat steht
-- schon (08), eingezogen wird darüber", 08 sagt zum Mandat „hier steht nur, dass
-- eingezogen werden darf", und die Karte selbst „ein Mandat je Kind, aber nicht
-- je Zweck". Die Erlaubnis steht damit am Mandat (`sepa_mandates`,
-- stammdaten-schema.sql); ein Zweck daneben wäre ihr zweiter Ort
-- (rules.md Abschnitt 1).
CREATE TABLE consent_purposes (
    consent_purpose_id integer GENERATED ALWAYS AS IDENTITY,
    code               text NOT NULL,
    name               text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active           boolean NOT NULL DEFAULT true,
    -- Wahr, wo die Zustimmung ein Kind betrifft und `consents.child_id`
    -- deshalb gesetzt sein muss (Fotoeinverständnis).
    requires_child     boolean NOT NULL DEFAULT false,
    -- Ab diesem Alter antwortet das Kind selbst mit — 14 beim
    -- Fotoeinverständnis, sonst leer (grenzkarte.md, Q1).
    self_consent_age   smallint,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_consent_purposes      PRIMARY KEY (consent_purpose_id),
    CONSTRAINT uq_consent_purposes_code UNIQUE (code),
    -- Trägt den zusammengesetzten Fremdschlüssel von `consents` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_consent_purposes_requires_child UNIQUE (consent_purpose_id, requires_child),
    -- Ohne `guardian:`, wie an den Wertelisten des Lösch-Laufs: Eine Werteliste
    -- legt kein Elternteil an, sie entsteht im Haus.
    CONSTRAINT ck_consent_purposes_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: oberflaechen.md — „die Bibliotheksgrenze ist die Zugriffsgrenze".
-- Der Satz steht dort und nicht in der Grenzkarte; die Karte trägt die Regel
-- dahinter: „Direkten Zugriff auf eine Bibliothek bekommt nur, wer *in* den
-- Dateien arbeitet" (Q2).
-- Zwei Zeilen, und zwei Sites: die digitale Schülerakte mit einem Ordner je
-- Kind, in dem alles liegt — die von Weltenbaum erzeugten Unterlagen wie das,
-- was Menschen dazulegen —, und die Ablage der Rechnungsfreigabe, die eine
-- eigene Site mit eigenen Rechten hat (12). Dass eine Bibliothek in einer
-- anderen Site liegt, sieht dieses Schema nicht und muss es nicht sehen: Die
-- `graph_drive_id` benennt sie eindeutig, ganz gleich wo sie hängt — „nie ein
-- Pfad" (grenzkarte.md, Q2).
-- Kein Löschanker: keine Personendaten.
-- Entschieden nach der Abnahme, abweichend von den zwei Bibliotheken der
-- Grenzkarte: ein Ordner je Kind statt zweier. Der Preis ist benannt — die
-- erzeugten Unterlagen sind für Sekretariat und Geschäftsführung nicht mehr nur
-- lesbar. Dass ein Vertrag nachträglich verändert wurde, zeigt danach allein
-- die Prüfsumme an `contracts.document_checksum`; verhindern kann sie es nicht.
-- Die Bibliothek steht: eine bestehende der Schule, mit Vollzugriff für
-- Sekretariat und Geschäftsführung, Zugriff für die Admins und einem auf ihren
-- Ordner beschränkten Zugriff für die Schulleitungen — die Zweigbindung aus
-- hebel.md („für die andere Schulform nichts") setzt sich dort als Ordnerrecht
-- fort, weil die Akte ohnehin unter der Kohorten-Kennung liegt (`GS26a`). Damit
-- ist auch die Annahme der Grenzkarte, SharePoint könne Rechte nur je
-- Bibliothek, für dieses Haus nicht die ganze Wahrheit; an der Entscheidung für
-- eine Bibliothek ändert das nichts.
CREATE TABLE sharepoint_libraries (
    sharepoint_library_id integer GENERATED ALWAYS AS IDENTITY,
    code                  text NOT NULL,
    name                  text NOT NULL,
    -- Die Graph-Kennung der Bibliothek; zusammen mit der Element-Kennung ist sie
    -- die einzige gültige Referenz — ein Pfad bräche bei jedem Verschieben.
    graph_drive_id        text NOT NULL,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_sharepoint_libraries      PRIMARY KEY (sharepoint_library_id),
    CONSTRAINT uq_sharepoint_libraries_code UNIQUE (code),
    -- Ohne `guardian:`: eine Bibliothek richtet ein Admin ein, kein Elternteil.
    CONSTRAINT ck_sharepoint_libraries_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: grenzkarte.md, Q2 — „Damit muss niemand die Liste der
-- Dokumentarten vorher kennen. Sie ist eine Werteliste und wächst um eine
-- Zeile, sobald ein Prozess eine Unterlage beim Namen nennen will — nie um eine
-- Migration, und nie auf Vorrat: Eine Art, nach der kein Prozess fragt, hätte
-- keinen Leser." Die Zeile daneben entsteht trotzdem für jede Datei („Jede
-- Datei bekommt eine Zeile", Q2); nur die **Art** bleibt der Teilmenge
-- vorbehalten, nach der ein Prozess fragt.
-- Kein Löschanker: keine Personendaten.
CREATE TABLE document_types (
    document_type_id integer GENERATED ALWAYS AS IDENTITY,
    code             text NOT NULL,
    name             text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active         boolean NOT NULL DEFAULT true,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_document_types      PRIMARY KEY (document_type_id),
    CONSTRAINT uq_document_types_code UNIQUE (code),
    -- Ohne `guardian:`: eine Dokumentart legt an, wer den Prozess pflegt.
    CONSTRAINT ck_document_types_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: hebel.md, „Nachzieh-Aufgabe und Wochenmail" — „Was nach draußen
-- muss, wird eine offene Aufgabe je Fremdsystem bei der Stelle, die dieses
-- System ohnehin pflegt: Sekretariat ASV-BW, Buchhaltung Optigem, Admin M365."
-- Kein Löschanker: keine Personendaten. Die zuständige Rolle steht hier und
-- nicht an der Aufgabe: „die zuständige Stelle folgt daraus und wird nicht
-- eigens festgehalten" (02). Ein Ziel ist dabei nicht zwingend ein System, das
-- die Schule pflegt: Die Meldung eines fehlenden Masernnachweises ans
-- Gesundheitsamt ist eine eigene Aufgabenart, deren Ziel Weltenbaum nie
-- anfasst — sie hält allein fest, dass die gesetzliche Meldung erledigt ist
-- (09, hebel.md). Und es muss überhaupt kein System sein: `in_house` trägt die
-- Arbeit, die im Haus bleibt und trotzdem eine Aufgabe braucht, weil sie keine
-- Spur hinterlässt, an der man sie ablesen könnte — „Anwesenheitsliste
-- drucken" (01, Z9).
CREATE TABLE sync_targets (
    sync_target_id integer GENERATED ALWAYS AS IDENTITY,
    -- Eine Zeile ist eine Aufgabenart, nicht der Anlass: „Umzug und Abgang
    -- derselben Person werden eine Aufgabe je System, nicht zwei" (hebel.md).
    -- Im Regelfall hat ein System genau eine Art; wo ein Block eine zweite
    -- benennt, bekommt sie ihre eigene Zeile bei demselben System und derselben
    -- Rolle: die Änderungsgebühr — „Die Änderungsgebühr läuft darin nicht mit
    -- … Sie wird deshalb eine eigene Aufgabe" (09) — und die berechneten
    -- Ferienbuchungen, die „alle seine berechneten Termine" tragen (10) und
    -- keine Beitragslage sind. Der Index unten rechnet je Art, nicht je System.
    code           text NOT NULL,
    name           text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus
    -- jedem Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn
    -- zeigt (rules.md Abschnitt 3).
    is_active       boolean NOT NULL DEFAULT true,
    role_id        integer NOT NULL,
    -- Das Flag der Rollenzeile, hier mitgeführt, damit `sync_tasks` es sehen
    -- kann; `fk_sync_targets_role` hält beide zusammen (rules.md Abschnitt 1).
    -- Dieselbe Bauform wie an `employee_roles` (stammdaten-schema.sql) und aus
    -- demselben Grund: Ohne sie bliebe „leer bei jedem Ziel, dessen Rolle nicht
    -- an eine Schulart gebunden ist" ein Satz ohne Halt.
    is_branch_bound boolean NOT NULL DEFAULT false,
    created_at     timestamptz NOT NULL DEFAULT now(),
    created_by     text NOT NULL,

    CONSTRAINT pk_sync_targets      PRIMARY KEY (sync_target_id),
    CONSTRAINT uq_sync_targets_code UNIQUE (code),
    CONSTRAINT fk_sync_targets_role
        FOREIGN KEY (role_id, is_branch_bound) REFERENCES roles (role_id, is_branch_bound),
    -- Trägt den zusammengesetzten Fremdschlüssel von `sync_tasks` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_sync_targets_branch_bound UNIQUE (sync_target_id, is_branch_bound),
    -- Ohne `guardian:`: eine Aufgabenart legt ein Admin an, kein Elternteil.
    CONSTRAINT ck_sync_targets_created_by CHECK (created_by ~ '^(entra:|system:)')
);


-- ---------------------------------------------------------------------------
-- Q2 — Dokument und Signatur
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md, „Geld im System, alles andere fest" — „Dasselbe gilt für
-- die Texte, an denen ein Vertrag hängt … Es gilt die Fassung, deren
-- Gültigkeitstag zuletzt erreicht wurde, geändert von der Geschäftsführung."
-- Welche Textsorten es gibt, ist damit eine Werteliste und kein Freitext
-- (Betreiber, 03.09.2026): Die Geschäftsführung pflegt die Fassungen, und wer
-- einen Text an ein Angebot oder eine Terminart bindet, wählt aus dieser Liste
-- — ein Tippfehler ließe die Bedingungen sonst still verschwinden, obwohl sie
-- „sichtbar bevor angemeldet wird" (21) bzw. „sichtbar bevor gebucht wird"
-- (10) sein müssen.
-- Kein Löschanker: keine Personendaten.
CREATE TABLE contract_text_kinds (
    contract_text_kind_id integer GENERATED ALWAYS AS IDENTITY,
    -- Der Code ist die Verankerung im Anwendungscode und wird nie umbenannt;
    -- der Name darf jederzeit wandern (rules.md Abschnitt 3). Er trägt hier
    -- ausnahmsweise auch die Fremdschlüssel: `contract_texts` und die Spalten
    -- der Domänen suchen die Sorte als Code, und ein zweiter Weg über die
    -- Kennung stünde daneben, ohne etwas zu tragen.
    code                  text NOT NULL,
    name                  text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus jedem
    -- Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn zeigt
    -- (rules.md Abschnitt 3).
    is_active             boolean NOT NULL DEFAULT true,
    created_at            timestamptz NOT NULL DEFAULT now(),
    created_by            text NOT NULL,

    CONSTRAINT pk_contract_text_kinds      PRIMARY KEY (contract_text_kind_id),
    CONSTRAINT uq_contract_text_kinds_code UNIQUE (code),
    CONSTRAINT ck_contract_text_kinds_code CHECK (code <> ''),
    CONSTRAINT ck_contract_text_kinds_name CHECK (name <> ''),
    CONSTRAINT ck_contract_text_kinds_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: hebel.md, „Geld im System, alles andere fest" — „Dasselbe gilt für
-- die Texte, an denen ein Vertrag hängt … Es gilt die Fassung, deren
-- Gültigkeitstag zuletzt erreicht wurde, geändert von der Geschäftsführung."
-- Löschanker: keiner, keine Personendaten — eine Fassung überlebt jeden
-- Vertrag, der sie trägt. Bewusst KEIN Gültigkeits-Ende und kein
-- Freigabevermerk: das Ende folgt aus der nächsten Fassung, und „wie ein
-- solcher Text abgelegt und formatiert wird, entscheidet der Bau". Dass „ein
-- bereits gültiger nicht mehr" geändert wird, prüft die Anwendung — dieselbe
-- Auslassung wie an `configured_values`, aus demselben Grund.
CREATE TABLE contract_texts (
    contract_text_id integer GENERATED ALWAYS AS IDENTITY,
    -- Welcher Text: Schulvertrag je Schulart (08), Hortvertrag und
    -- Betreuungsordnung (09), Teilnahmebedingungen und Stornobedingungen je
    -- Terminart (10), Essensbedingungen (11).
    code             text NOT NULL,
    valid_from       date NOT NULL,
    body             text NOT NULL,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_contract_texts PRIMARY KEY (contract_text_id),
    CONSTRAINT fk_contract_texts_kind
        FOREIGN KEY (code) REFERENCES contract_text_kinds (code),
    CONSTRAINT uq_contract_texts UNIQUE (code, valid_from),
    -- Trägt den zusammengesetzten Fremdschlüssel von `contracts`
    -- (anmeldung-schema.sql): Der Vertrag führt die Sorte seines Textes mit,
    -- damit ein CHECK sie gegen den Vertragstyp halten kann.
    CONSTRAINT uq_contract_texts_id_code UNIQUE (contract_text_id, code),
    CONSTRAINT ck_contract_texts_code CHECK (code <> ''),
    CONSTRAINT ck_contract_texts_body CHECK (body <> ''),
    -- Ohne `guardian:`: „geändert von der Geschäftsführung" (hebel.md).
    CONSTRAINT ck_contract_texts_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: 08 (Schulvertrag) — „Namenszug zeichnen, dazu hält das System fest,
-- wer wann welche Fassung bestätigt hat". Löschanker: geht mit dem
-- Vertragsvorgang und damit mit dem Kind, mit dem Mandat, oder — wo sie
-- keines von beiden trägt — unmittelbar mit dem Kind. Genau einer der drei
-- steht je Zeile; ohne ihn bliebe eine Unterschrift stehen und sperrte danach
-- das Löschen ihrer Person. Das Signaturbild wird schon vorher
-- gelöscht: „Mit dem Abschluss des Vorgangs wird es gelöscht … eine Zeile ohne
-- Bild heißt deshalb ‚unterschrieben, Bild abgeräumt'."
-- [A!] Eine Signatur hängt am Vertragsvorgang, nicht am Dokument. —
-- Alternative: Person × Dokument, wie grenzkarte.md Q2 es beschreibt; Preis:
-- „Vor der Freigabe entsteht kein Dokument" (08), die Signatur bräuchte also
-- einen Bezug, den es zum Zeitpunkt des Unterschreibens noch gar nicht gibt.
-- Der Vertragsvorgang ist dabei nicht der einzige Bezug: Block 08 nennt zwei
-- Unterschriften, die zu keinem gehören — „Ab 14 unterschreibt das Kind sein
-- Fotoeinverständnis mit — über einen Signaturlink, keinen Zugang" und „Eine
-- sorgeberechtigte Person füllt im Portal ein neues [Mandat] aus und
-- unterschreibt … der Vertrag darunter bleibt unberührt".
CREATE TABLE signatures (
    signature_id     uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Der Vertragsvorgang aus Domäne 2/4; der Fremdschlüssel wird dort
    -- nachgetragen, weil die Tabelle hier noch nicht existiert. Leer bei den
    -- beiden Unterschriften ohne Vertrag: die des Mandats trägt die Spalte
    -- darunter, die des Kindes ab 14 die Spalte `child_id`; ihre `consents`-Zeile
    -- findet sie zusätzlich über `consents.signature_id` (grenzkarte.md, Q1:
    -- „Eine Zustimmung aus Q1 zeigt optional auf die Signatur, die sie belegt").
    contract_id      uuid,
    -- Das abgelöste bzw. neue SEPA-Mandat, das diese Unterschrift trägt (08);
    -- die Tabelle steht in stammdaten-schema.sql und existiert hier schon.
    sepa_mandate_id  uuid,
    -- Gesetzt, wo nicht der Vertrag selbst unterschrieben wird, sondern eine
    -- seiner Modulanlagen: „Eine Anpassung beantragen die Eltern im Portal und
    -- unterschreiben die neue Modulanlage … der Vertrag darunter bleibt
    -- stehen" (09). Leer heißt: die Unterschrift unter dem Vertrag selbst.
    care_module_agreement_id uuid,
    -- Der Löschanker der dritten Unterschrift: „Ab 14 unterschreibt das Kind
    -- sein Fotoeinverständnis mit — über einen Signaturlink, keinen Zugang"
    -- (08). Sie hängt an keinem Vertragsvorgang und an keinem Mandat, und über
    -- `consents.signature_id` ist sie nicht erreichbar — die Zustimmung
    -- kaskadiert mit dem Kind weg, bevor ein Lauf ihren Schlüssel gesehen hat.
    -- Gesetzt genau dann, wenn Vertrag und Mandat leer sind.
    child_id         uuid,
    person_id        uuid NOT NULL,
    signed_at        timestamptz NOT NULL,
    -- Bewusst KEINE eigene Spalte für die bestätigte Fassung: „Die Fassung
    -- friert mit der Zusage ein und nicht erst mit der einzelnen Unterschrift —
    -- sonst unterschreiben Mutter und Vater verschiedene Texte" (08). Damit ist
    -- sie je Vertrag eine und steht an `contracts.contract_text_id`; eine
    -- zweite Spalte hier wäre der ableitbare Wert aus rules.md Abschnitt 1.
    -- Der Namenszug, als vollständige Graph-Kennung: „Die Referenz ist die
    -- Graph-Kennung, nie ein Pfad: Bibliothek plus Element, beide nur gemeinsam
    -- gültig" (grenzkarte.md, Q2) — wie an `documents` und
    -- `child_file_folders`. Beide leer heißt „unterschrieben, Bild abgeräumt",
    -- nicht „hat nicht unterschrieben".
    signature_image_library_id integer,
    signature_image_item_id text,
    -- „heute durchgängig einfache elektronische Signatur" (grenzkarte.md, Q2) —
    -- und nur die: das elektronische Siegel „wird bewusst nicht beschafft"
    -- (08). Die Spalte hält fest, welches Niveau eine Unterschrift hatte, damit
    -- ein später ergänztes Niveau die alten Zeilen nicht umdeutet; die zwei
    -- Ausprägungen auf Vorrat, die kein Block kennt, sind gestrichen.
    signature_level  text NOT NULL DEFAULT 'simple',
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_signatures        PRIMARY KEY (signature_id),
    CONSTRAINT fk_signatures_person FOREIGN KEY (person_id) REFERENCES persons (person_id),
    -- Trägt den zusammengesetzten Fremdschlüssel von `consents` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_signatures_id_person UNIQUE (signature_id, person_id),
    -- Löschanker: geht mit dem Mandat, das sie trägt.
    CONSTRAINT fk_signatures_mandate
        FOREIGN KEY (sepa_mandate_id) REFERENCES sepa_mandates (sepa_mandate_id) ON DELETE CASCADE,
    -- Löschanker: geht mit dem Kind, dessen Fotoeinverständnis sie belegt — wie
    -- `consents.child_id`, das die Zustimmung daneben mitnimmt.
    CONSTRAINT fk_signatures_child
        FOREIGN KEY (child_id) REFERENCES children (child_id) ON DELETE CASCADE,
    -- Genau ein Bezug je Unterschrift und damit genau ein Löschanker: der
    -- Vertragsvorgang, das Mandat, oder das Kind ab 14 unter seinem
    -- Fotoeinverständnis (08). Vorher stand hier „Vertrag oder Mandat, nie
    -- beides" — das ließ die dritte Unterschrift ohne jeden Anker durch.
    CONSTRAINT ck_signatures_subject CHECK (
        (contract_id     IS NOT NULL)::int
      + (sepa_mandate_id IS NOT NULL)::int
      + (child_id        IS NOT NULL)::int = 1),
    -- Eine Modulanlage gehört ihrem Vertrag: „der Vertrag darunter bleibt
    -- stehen" (09) — vorher trug das `contract_id NOT NULL`.
    CONSTRAINT ck_signatures_agreement
        CHECK (care_module_agreement_id IS NULL OR contract_id IS NOT NULL),
    CONSTRAINT fk_signatures_image_library
        FOREIGN KEY (signature_image_library_id) REFERENCES sharepoint_libraries (sharepoint_library_id),
    -- „beide nur gemeinsam gültig" (grenzkarte.md, Q2): eine halbe Referenz
    -- findet die Datei nicht.
    CONSTRAINT ck_signatures_image
        CHECK ((signature_image_library_id IS NULL) = (signature_image_item_id IS NULL)),
    CONSTRAINT ck_signatures_level  CHECK (signature_level = 'simple'),
    CONSTRAINT ck_signatures_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Je Person und Vorgang eine Unterschrift — und je Person und Modulanlage
-- ebenfalls eine, weil jede Anpassung neu unterschrieben wird (09). Zwei
-- Indizes, weil ein NULL in der Anlage sonst jede Zeile für sich einzigartig
-- machte.
CREATE UNIQUE INDEX ix_signatures_contract ON signatures (contract_id, person_id)
    WHERE care_module_agreement_id IS NULL AND contract_id IS NOT NULL;
CREATE UNIQUE INDEX ix_signatures_agreement
    ON signatures (care_module_agreement_id, person_id)
    WHERE care_module_agreement_id IS NOT NULL;
-- Je Mandat eine Unterschrift: „Eine sorgeberechtigte Person füllt im Portal
-- ein neues aus und unterschreibt" (08) — eine, nicht alle.
CREATE UNIQUE INDEX ix_signatures_mandate ON signatures (sepa_mandate_id)
    WHERE sepa_mandate_id IS NOT NULL;

-- Herkunft: grenzkarte.md, Q2 — „Dokument: Typ, Bezug (Kind bzw. Vorgang),
-- Ablageort, Erzeugungszeitpunkt — dazu, ob es angefordert wurde." Löschanker:
-- geht mit dem Kind, aber bewusst OHNE Cascade — der Lösch-Lauf muss die Datei
-- in SharePoint zuerst mitentfernen, samt beiden Papierkorb-Stufen und dem
-- Versionsverlauf (grenzkarte.md, Q2), und „eine verwaiste Datei in SharePoint
-- ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile". Bewusst KEIN Pfad,
-- sondern die Graph-Kennung: „Ein Pfad bräche bei jedem Verschieben, und das
-- ist der real belegte Fehlermodus dieser Schule."
CREATE TABLE documents (
    document_id      uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id         uuid NOT NULL,
    document_type_id integer NOT NULL,
    -- Wo die Datei liegt. Sie steht an der Datei und nicht an ihrer Art: käme
    -- die Trennung nach Bibliotheken je zurück, wäre das eine Datenänderung
    -- statt einer Migration.
    sharepoint_library_id integer NOT NULL,
    -- Gesetzt, wo ein Mensch die Unterlage verlangt hat; zusammen mit einem
    -- leeren `graph_item_id` heißt das „fehlt noch", ohne Zeile „nie verlangt".
    requested_at     timestamptz,
    -- Der dritte Stand aus 06: „Unterlagen, je Stück vorgelegt, fehlt oder
    -- nicht nötig" — die ausdrückliche Feststellung des Sekretariats, dass
    -- diese Unterlage bei diesem Kind entfällt. Ohne ihn ist „nicht nötig" von
    -- „fehlt" nicht zu unterscheiden.
    not_required_at  timestamptz,
    -- Die Element-Kennung in der Bibliothek des Typs; sie überlebt Umbenennen
    -- und Verschieben, weshalb ein Zug- oder Zweigwechsel hier nichts ändert.
    graph_item_id    text,
    -- Wann die Datei entstanden ist bzw. nachgereicht wurde.
    filed_at         timestamptz,
    created_at       timestamptz NOT NULL DEFAULT now(),
    created_by       text NOT NULL,

    CONSTRAINT pk_documents       PRIMARY KEY (document_id),
    CONSTRAINT fk_documents_child FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_documents_type  FOREIGN KEY (document_type_id) REFERENCES document_types (document_type_id),
    CONSTRAINT fk_documents_library
        FOREIGN KEY (sharepoint_library_id) REFERENCES sharepoint_libraries (sharepoint_library_id),
    -- „Jede Datei bekommt eine Zeile" (grenzkarte.md, Q2) — und keine Datei
    -- zwei. Ohne diesen Schlüssel zeigten die Zeilen zweier Kinder auf dasselbe
    -- Graph-Element, und der Lösch-Lauf entfernte in Stufe 1 die Datei, auf die
    -- die Zeile des anderen Kindes noch zeigt. Derselbe Schlüssel wie an den
    -- Beleganhängen (`uq_expense_claim_attachments`,
    -- rechnungsfreigabe-schema.sql). Ein schlichtes UNIQUE genügt: NULL zählt
    -- in Postgres als verschieden, die bloße Anforderung ohne Datei fällt also
    -- von selbst heraus.
    CONSTRAINT uq_documents_graph_item UNIQUE (sharepoint_library_id, graph_item_id),
    -- Trägt den zusammengesetzten Fremdschlüssel von `consents` (rules.md
    -- Abschnitt 1) und ist deshalb zusätzlich zum Primärschlüssel nötig.
    CONSTRAINT uq_documents_id_child UNIQUE (document_id, child_id),
    -- Eine Zeile, die weder angefordert wurde noch eine Datei trägt noch als
    -- nicht nötig festgestellt ist, sagt nichts.
    CONSTRAINT ck_documents_purpose
        CHECK (requested_at IS NOT NULL OR graph_item_id IS NOT NULL
               OR not_required_at IS NOT NULL),
    -- „vorgelegt, fehlt oder nicht nötig" (06) sind drei Stände und nicht zwei
    -- zugleich: was vorliegt, war nötig.
    CONSTRAINT ck_documents_not_required
        CHECK (not_required_at IS NULL OR graph_item_id IS NULL),
    -- Abgelegt ist, wo eine Datei liegt — beides gehört zusammen.
    CONSTRAINT ck_documents_filed
        CHECK ((graph_item_id IS NULL) = (filed_at IS NULL)),
    CONSTRAINT ck_documents_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Das Mandat zeigt auf seine Datei; die Tabelle steht in stammdaten-schema.sql,
-- die Datei entsteht erst hier — deshalb der Schlüssel an dieser Stelle.
ALTER TABLE sepa_mandates
    ADD CONSTRAINT fk_sepa_mandates_document
        FOREIGN KEY (document_id) REFERENCES documents (document_id);

-- Herkunft: grenzkarte.md, Q2 — „Der Ordner-Anker bleibt daneben bestehen
-- (`child_file_folders`): Er trägt den Ordner selbst, den der Lösch-Lauf
-- zusätzlich zu seinen Dateien entfernen muss, und er ist der Bezug, über den
-- die Zeile ihre Kategorie kennt." Löschanker: geht mit dem Kind, aber bewusst OHNE
-- Cascade — wie bei `documents` muss der Lösch-Lauf den Ordner in SharePoint
-- zuerst mitentfernen, mit Papierkorb und Versionsverlauf; er erwischt damit
-- auch, was Weltenbaum nie gesehen hat.
-- Je Kind genau einer, seit alles in derselben Bibliothek liegt.
CREATE TABLE child_file_folders (
    child_file_folder_id uuid NOT NULL DEFAULT gen_random_uuid(),
    child_id             uuid NOT NULL,
    sharepoint_library_id integer NOT NULL,
    graph_item_id        text NOT NULL,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_child_file_folders       PRIMARY KEY (child_file_folder_id),
    CONSTRAINT fk_child_file_folders_child FOREIGN KEY (child_id) REFERENCES children (child_id),
    CONSTRAINT fk_child_file_folders_library
        FOREIGN KEY (sharepoint_library_id) REFERENCES sharepoint_libraries (sharepoint_library_id),
    CONSTRAINT uq_child_file_folders UNIQUE (child_id),
    CONSTRAINT ck_child_file_folders_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Q1 — Zustimmung
-- ---------------------------------------------------------------------------

-- Herkunft: grenzkarte.md, Q1 — „Wer hat wann wozu geantwortet — erteilt oder
-- abgelehnt —, über welche Zustelladresse, und wurde eine Erteilung
-- widerrufen." Löschanker: geht mit dem Kind bzw. mit der Person, je nachdem,
-- worauf die Zeile zeigt. Maßgeblich ist das Kind, wo `child_id` steht, sonst
-- die Person; beide Fremdschlüssel kaskadieren, weil die Zeile in keinem der
-- beiden Fälle stehen bleiben darf — die beiden Anker rechnen verschieden (das
-- Kind ab seinem Ende (03), der Sorgeberechtigte an der Familie), und es
-- löscht, wessen Frist zuerst abläuft.
-- Das Fotoeinverständnis macht davon keine Ausnahme: Es „hängt am Kind und
-- verschwindet mit ihm im Lösch-Lauf (17)" (08). Der Widerruf beendet die
-- Nutzung und nicht die Zeile — `revoked_at` setzen, die weitere Verwendung
-- unterbinden, das Bildmaterial auf Verlangen löschen. Ob der Nachweis der
-- Erlaubnis das Kind überdauern muss, ist offen und steht als Frage am Ende
-- dieser Datei. Bewusst KEIN Boolean und keine
-- Werteliste für die Antwort: der Zeitpunkt ist der Nachweis nach Art. 7
-- Abs. 1 DSGVO.
CREATE TABLE consents (
    consent_id         uuid NOT NULL DEFAULT gen_random_uuid(),
    person_id          uuid NOT NULL,
    -- Gesetzt, wo die Zustimmung einem Kind gilt; die Zweckzeile sagt, wann das
    -- Pflicht ist.
    child_id           uuid,
    consent_purpose_id integer NOT NULL,
    -- Das Flag der Zweckzeile, hier mitgeführt, damit der CHECK unten es sehen
    -- kann; `fk_consents_purpose` hält beide zusammen (rules.md Abschnitt 1).
    requires_child     boolean NOT NULL DEFAULT false,
    -- Zwei Zeitpunkte statt eines Ja/Nein: „sonst sieht die vergessene Frage aus
    -- wie ein Nein". Genau einer von beiden ist gesetzt.
    granted_at         timestamptz,
    declined_at        timestamptz,
    -- „über welche Zustelladresse" (grenzkarte.md, Q1) — nicht aus
    -- `persons.email` ableitbar: zwei Erziehungsberechtigte dürfen sich eine
    -- Mailbox teilen, und nur so ist hinterher auswertbar, ob zwei Zustimmungen
    -- über dasselbe Postfach kamen. Leer allein bei einer Antwort, die keinen
    -- Kanal hatte: das aus der Papierakte nachgetragene Fotoeinverständnis der
    -- Kinder des Vollimports (README, „Das Sekretariat trägt sie aus den Akten
    -- nach"). Ein NOT NULL zwänge dort zu einer erfundenen Adresse.
    delivery_address   text,
    revoked_at         timestamptz,
    signature_id       uuid,
    -- Die erzeugte Datei einer unterschriebenen Zustimmung — beim
    -- Fotoeinverständnis ab 14 die des Kindes über den Signaturlink (08):
    -- „eine Unterlage, eine Datei", einzeln befristet statt im Vertrag gebündelt.
    -- Leer, wo eine Antwort ohne Unterschrift steht.
    document_id        uuid,
    created_at         timestamptz NOT NULL DEFAULT now(),
    created_by         text NOT NULL,

    CONSTRAINT pk_consents           PRIMARY KEY (consent_id),
    CONSTRAINT fk_consents_person    FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT fk_consents_child     FOREIGN KEY (child_id)  REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT fk_consents_purpose
        FOREIGN KEY (consent_purpose_id, requires_child)
        REFERENCES consent_purposes (consent_purpose_id, requires_child),
    -- Ohne `child_id` fiele die Zeile aus beiden Unique-Indizes unten und aus
    -- jeder Ansicht, die je Kind fragt — „für alle Lehrkräfte, Hortkräfte und
    -- das Sekretariat ohne Umweg sichtbar" (08).
    CONSTRAINT ck_consents_child
        CHECK (NOT requires_child OR child_id IS NOT NULL),
    -- Die Datei gehört demselben Kind wie die Zustimmung, die auf sie zeigt:
    -- „Eine Datei beim falschen Kind ist keine ältere Fassung … die
    -- Verwechslung wäre damit nicht behoben, sondern eingebaut"
    -- (grenzkarte.md, Q2). Der einspaltige Fremdschlüssel band nur die Zeile.
    -- Bei einer Zustimmung ohne Kind greift er nicht (MATCH SIMPLE) — die
    -- kindlose Antwort trägt keine erzeugte Datei, und ein NOT NULL auf
    -- `child_id` verböte die Werbe-Einwilligung.
    CONSTRAINT fk_consents_document
        FOREIGN KEY (document_id, child_id) REFERENCES documents (document_id, child_id),
    -- Und dieselbe Bindung an der Unterschrift: Sie gehört der Person, deren
    -- Antwort sie belegt, nicht irgendeiner.
    CONSTRAINT fk_consents_signature
        FOREIGN KEY (signature_id, person_id) REFERENCES signatures (signature_id, person_id),
    CONSTRAINT ck_consents_answer
        CHECK ((granted_at IS NOT NULL) <> (declined_at IS NOT NULL)),
    -- Widerrufen wird eine Erteilung, nie eine Ablehnung.
    CONSTRAINT ck_consents_revocation
        CHECK (revoked_at IS NULL OR granted_at IS NOT NULL),
    -- Und nie vor ihr: der Zeitpunkt ist der Nachweis nach Art. 7 Abs. 1
    -- DSGVO (grenzkarte.md, Q1) — eine Erteilung, die nach ihrem Widerruf
    -- datiert, belegt nichts.
    CONSTRAINT ck_consents_revoked_after_granted
        CHECK (revoked_at IS NULL OR revoked_at >= granted_at),
    CONSTRAINT ck_consents_delivery_address CHECK (delivery_address <> ''),
    CONSTRAINT ck_consents_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- Je Person, Kind und Zweck gibt es höchstens eine gültige Antwort; eine spätere
-- ersetzt die frühere, statt sich danebenzulegen. Zwei Indizes, weil ein NULL in
-- `child_id` sonst jede Zeile für sich einzigartig machte.
CREATE UNIQUE INDEX ix_consents_person_child_purpose
    ON consents (person_id, child_id, consent_purpose_id)
    WHERE child_id IS NOT NULL AND revoked_at IS NULL;
CREATE UNIQUE INDEX ix_consents_person_purpose
    ON consents (person_id, consent_purpose_id)
    WHERE child_id IS NULL AND revoked_at IS NULL;


-- ---------------------------------------------------------------------------
-- Q3 — Zahlungsvorgang
-- ---------------------------------------------------------------------------

-- Herkunft: grenzkarte.md, Q3 — „Weltenbaum berührt Geld nur an einer Stelle:
-- wo ein Elternteil im Selbstservice bezahlt und der Prozess erst danach
-- weiterlaufen darf." Löschanker: geht mit dem Vorgang, an dem die Zahlung
-- hängt. Bewusst KEINE Fälligkeit, keine Forderung und kein Betrag 0 für eine
-- ausgesetzte Strafe: „hier steht, was hereinkommt, dort, was gar nicht erst
-- gefordert wird".
CREATE TABLE payments (
    payment_id     uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Fünf nullable Vorgangs-Spalten für vier Anlässe: der Putzdienst trägt
    -- zwei. Der Fremdschlüssel trägt die Unterscheidung — ein Typ-Feld plus
    -- untypisierte ID gäbe die referenzielle Integrität auf.
    cleaning_buyout_id      uuid,
    cleaning_slot_buyout_id uuid,
    application_id          uuid,
    holiday_booking_id      uuid,
    -- Der fünfte Anlass: die Akademie-Anmeldung einer Familie **ohne**
    -- SEPA-Mandat (21). Die mit Mandat erzeugt keine Zahlung, sondern wird
    -- eingezogen wie das Schulgeld — und der Erwachsenen-Zweig hat nie eines.
    -- Der Fremdschlüssel wird in akademie-schema.sql nachgetragen, weil die
    -- Tabelle hier noch nicht existiert.
    academy_registration_id uuid,
    -- Der Betrag, der zur Zahlung galt, und nicht der heutige: Freikauf und
    -- Bearbeitungsgebühr folgen aus `configured_values` („cleaning_buyout_cents",
    -- „application_fee_cents") zu ihrem Gültigkeitstag, und „eine spätere
    -- Änderung rechnet nichts rückwirkend um" (hebel.md). Eine festgehaltene
    -- Tatsache also, keine vergessene Ableitung. Bei keinem der vier Anlässe
    -- bindet ein Schlüssel ihn an einen zweiten Ort: Eine Sitzung wird genau
    -- eine Zahlungszeile, auch wo der Vorgang dahinter aus mehreren Zeilen
    -- besteht (api/gemeinsam.md), und dann ist dieser Betrag die Summe und
    -- gleicht dem keiner einzelnen Zeile — beim Jahres-Freikauf des Putzdiensts
    -- wie bei der Ferienbuchung über mehrere Kinder (api/ferien-api.md). Bei
    -- der Akademie-Anmeldung ist er die Summe aus Betrag und Zusatzbetrag des
    -- Angebots (akademie-schema.sql).
    amount_cents   integer NOT NULL,
    -- Offen oder bestätigt, zahlungswegneutral: neben Stripe bleibt die
    -- manuelle Bestätigung durch die Buchhaltung für Überweisung und Bargeld.
    status         text NOT NULL DEFAULT 'open',
    -- Die Stripe-Referenz; sie bleibt leer, wo die Buchhaltung von Hand
    -- bestätigt hat.
    payment_reference text,
    confirmed_at   timestamptz,
    created_at     timestamptz NOT NULL DEFAULT now(),
    created_by     text NOT NULL,

    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    -- Der Anker der Idempotenz an der Rückrufroute (api/gemeinsam.md): Der
    -- Zahlungsdienst wiederholt ein Ereignis, bis er eine 2xx bekommt, und die
    -- zweite Zustellung darf keine zweite Zahlung anlegen. Bewusst ein
    -- schlichtes UNIQUE und kein partieller Index: NULL zählt in Postgres als
    -- verschieden, der Schlüssel greift also von selbst nur für belegte Werte —
    -- und leer bleibt die Spalte genau dort, wo die Buchhaltung von Hand
    -- bestätigt. Er allein macht die Route nicht idempotent; was die Route
    -- zusätzlich tun muss, steht dort und nicht hier.
    CONSTRAINT uq_payments_payment_reference UNIQUE (payment_reference),
    -- Höchstens ein Anlass je Zahlung. Jeder weitere Anlass ist eine Spalte und
    -- ein Summand mehr, nie eine zweite Zahlungstabelle.
    -- **Keiner ist erlaubt, und das ist der Ausnahmefall, kein Schlupfloch:**
    -- „Trägt die Bedingung beim Rückruf nicht mehr, wird nichts automatisch
    -- erstattet" (api/gemeinsam.md) — das Geld ist da, der Termin gestrichen
    -- oder das Fenster zu. Mit `= 1` wäre diese Zahlung nicht eintragbar und
    -- verschwände still, was der einzige Fall ist, in dem das System Geld
    -- verlöre. Wer sie hält, hält auch die Aufgabe daran: `sync_tasks`
    -- trägt sie als neunten Bezug, Ziel `payment_without_cause`, damit ein
    -- Mensch über die Rückzahlung entscheidet. Ein Constraint, der das
    -- Aufgaben-Paar erzwingt, ginge nur über zwei Tabellen und steht deshalb
    -- nicht hier, sondern an der Rückrufroute.
    CONSTRAINT ck_payments_single_cause CHECK (
        (cleaning_buyout_id      IS NOT NULL)::int
      + (cleaning_slot_buyout_id IS NOT NULL)::int
      + (application_id          IS NOT NULL)::int
      + (holiday_booking_id      IS NOT NULL)::int
      + (academy_registration_id IS NOT NULL)::int <= 1),
    CONSTRAINT ck_payments_status CHECK (status IN ('open', 'confirmed')),
    -- Bestätigt heißt: mit Zeitpunkt. „Der Vorgang entsteht mit der bestätigten
    -- Zahlung und nicht mit der Rückkehr aus der Bezahlung" (hebel.md).
    CONSTRAINT ck_payments_confirmed
        CHECK ((status = 'confirmed') = (confirmed_at IS NOT NULL)),
    CONSTRAINT ck_payments_amount CHECK (amount_cents > 0),
    CONSTRAINT ck_payments_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Q5 — Nachzieh-Aufgabe
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md — „Je Aufgabenart und Bezug gibt es höchstens eine offene
-- Aufgabe; eine weitere Änderung ersetzt sie, statt sich danebenzulegen."
-- Löschanker: „die erledigten Nachzieh-Aufgaben gehen mit den Daten, auf die sie
-- sich beziehen" (02). Bewusst KEINE Frist und keine Eskalationsstufe: „Eine
-- Aufgabe hat keine Frist und verfällt nicht."
CREATE TABLE sync_tasks (
    sync_task_id   uuid NOT NULL DEFAULT gen_random_uuid(),
    sync_target_id integer NOT NULL,
    -- Genau einer der neun Bezüge: die Person (02), das Kind (03, 08), die
    -- Familie (01), das Schuljahr (04), ein Zeitraum (01, Monatslauf der
    -- Strafen; als Erster des Monats), die einzelne Ferienbuchung (10), die
    -- einzelne Akademie-Anmeldung (21), der einzelne Putztermin (01) oder die
    -- einzelne Zahlung ohne Vorgang (api/gemeinsam.md).
    person_id        uuid,
    child_id         uuid,
    family_id        uuid,
    school_year      smallint,
    reference_period date,
    -- 10: „Erstattungen sind kein Fremdsystem, aber Handarbeit, die auf einen
    -- Menschen wartet: je Fall eine Aufgabe bei der Buchhaltung." „Je Fall"
    -- heißt mehrere gleichzeitig für dasselbe Kind — der Bezug ist deshalb die
    -- Buchung und nicht das Kind. Der Fremdschlüssel wird in ferien-schema.sql
    -- nachgetragen, weil die Tabelle hier noch nicht existiert.
    holiday_booking_id uuid,
    -- 21: „je Anmeldung eine Aufgabe bei der Buchhaltung mit dem einzuziehenden
    -- oder zu berechnenden Betrag; für online Bezahltes entsteht keine." Der
    -- Bezug ist die Anmeldung und nicht die Familie, aus demselben Grund wie
    -- bei der Ferienbuchung: Zwei Anmeldungen derselben Familie sind zwei
    -- Einzüge. Der Fremdschlüssel wird in akademie-schema.sql nachgetragen,
    -- weil die Tabelle hier noch nicht existiert.
    academy_registration_id uuid,
    -- 01: „Bei den manuellen Schritten entsteht statt einer eigenen Erinnerung
    -- je eine offene Aufgabe bei der zuständigen Person, sobald sie dran ist —
    -- Zuteilung freigeben, Anwesenheit eintragen, Anwesenheitsliste ausdrucken
    -- —, und sie läuft in der Wochenmail mit, bis sie abgehakt ist." Die ersten
    -- beiden folgen aus dem Bestand (`cleaning_cycles.allocation_released_at`,
    -- `cleaning_slots.attendance_recorded_at`); die dritte hat keine Spur, denn
    -- gedruckt wird eine frisch erzeugte Liste — „abgehakt" braucht deshalb
    -- diesen Bezug. Er ist der Termin und nicht das Jahr: Die Aufgabe ist „ein
    -- bis zwei Tage vor dem Termin fällig" und bekommt dafür eine eigene Mail.
    -- Der Fremdschlüssel wird in putzdienst-schema.sql nachgetragen, weil die
    -- Tabelle hier noch nicht existiert.
    cleaning_slot_id uuid,
    -- api/gemeinsam.md, „Sofortzahlung": eine Zahlung, deren Vorgang beim
    -- Rückruf nicht mehr möglich war. Der Bezug ist die Zahlung und nicht die
    -- Familie, weil zwei solche Fälle derselben Familie zwei Entscheidungen
    -- sind — und weil nur die Zahlung den Betrag trägt, um den es geht.
    payment_id       uuid,
    -- Wen die Aufgabe erreicht, nicht worum sie geht — deshalb steht sie
    -- bewusst außerhalb von ck_sync_tasks_single_subject und zählt dort nicht
    -- mit. 08 Z4 will die Freigabe „bei der Schulleitung dieser Schulart"; ohne
    -- diese Spalte liest die Grundschulleitung in ihrer Wochenmail die Namen
    -- der Realschulkinder. Leer bei jedem Ziel, dessen Rolle nicht an eine
    -- Schulart gebunden ist — das ist jede außer der Schulleitung
    -- (`roles.is_branch_bound`); `ck_sync_tasks_branch_bound` hält das.
    school_branch_id integer,
    -- Das Flag des Ziels, hier mitgeführt, damit der CHECK unten es sehen kann;
    -- `fk_sync_tasks_target` hält beide zusammen (rules.md Abschnitt 1).
    is_branch_bound  boolean NOT NULL DEFAULT false,
    -- Was zu tun ist, in einem Satz; die zuständige Stelle folgt aus dem Ziel
    -- und steht deshalb nicht hier.
    task_text      text NOT NULL,
    completed_at   timestamptz,
    completed_by   text,
    -- „Abgehakt wird als erledigt oder als war nichts zu tun" — häufen sich die
    -- zweiten bei einem Ziel, ist die Zuordnung dort zu weit gefasst.
    outcome        text,
    -- Nur bei einem Vertragspunkt der Abgangsliste: das Enddatum, mit dem er
    -- bestätigt wurde (03); ein Fremdsystempunkt hat keines.
    confirmed_end_date date,
    created_at     timestamptz NOT NULL DEFAULT now(),
    created_by     text NOT NULL,

    CONSTRAINT pk_sync_tasks        PRIMARY KEY (sync_task_id),
    CONSTRAINT fk_sync_tasks_target
        FOREIGN KEY (sync_target_id, is_branch_bound)
        REFERENCES sync_targets (sync_target_id, is_branch_bound),
    CONSTRAINT fk_sync_tasks_person FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT fk_sync_tasks_child  FOREIGN KEY (child_id)  REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT fk_sync_tasks_family FOREIGN KEY (family_id) REFERENCES families (family_id) ON DELETE CASCADE,
    CONSTRAINT fk_sync_tasks_payment FOREIGN KEY (payment_id) REFERENCES payments (payment_id) ON DELETE CASCADE,
    CONSTRAINT fk_sync_tasks_branch FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    -- Die Schulart steht an jedem zweiggebundenen Ziel und nur dort: ohne sie
    -- sähe die Grundschulleitung die Realschulkinder (08 Z4), mit ihr an einem
    -- zweigfreien Ziel verlöre die Aufgabe die Hälfte ihrer Empfänger.
    -- Dieselbe Form wie `ck_employee_roles_branch_bound` (stammdaten-schema.sql).
    CONSTRAINT ck_sync_tasks_branch_bound
        CHECK (is_branch_bound = (school_branch_id IS NOT NULL)),
    CONSTRAINT ck_sync_tasks_single_subject CHECK (
        (person_id        IS NOT NULL)::int
      + (child_id         IS NOT NULL)::int
      + (family_id        IS NOT NULL)::int
      + (school_year      IS NOT NULL)::int
      + (reference_period IS NOT NULL)::int
      + (holiday_booking_id IS NOT NULL)::int
      + (academy_registration_id IS NOT NULL)::int
      + (cleaning_slot_id  IS NOT NULL)::int
      + (payment_id        IS NOT NULL)::int = 1),
    CONSTRAINT ck_sync_tasks_outcome CHECK (outcome IN ('done', 'nothing_to_do')),
    CONSTRAINT ck_sync_tasks_completed
        CHECK ((completed_at IS NULL) = (outcome IS NULL)
               AND (completed_at IS NULL) = (completed_by IS NULL)),
    -- „wer sie abgehakt hat" (02), „durch wen" (03) — derselbe Urheber in
    -- derselben Form wie überall, sonst geht „irgendwer" als Abhaker durch.
    CONSTRAINT ck_sync_tasks_completed_by
        CHECK (completed_by ~ '^(entra:|guardian:|system:)'),
    CONSTRAINT ck_sync_tasks_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);

-- „Je Aufgabenart und Bezug gibt es höchstens eine offene Aufgabe" — neun
-- Indizes, weil ein NULL im Bezug sonst jede Zeile für sich einzigartig machte.
CREATE UNIQUE INDEX ix_sync_tasks_open_person ON sync_tasks (sync_target_id, person_id)
    WHERE completed_at IS NULL AND person_id IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_child ON sync_tasks (sync_target_id, child_id)
    WHERE completed_at IS NULL AND child_id IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_family ON sync_tasks (sync_target_id, family_id)
    WHERE completed_at IS NULL AND family_id IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_year ON sync_tasks (sync_target_id, school_year)
    WHERE completed_at IS NULL AND school_year IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_period ON sync_tasks (sync_target_id, reference_period)
    WHERE completed_at IS NULL AND reference_period IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_booking ON sync_tasks (sync_target_id, holiday_booking_id)
    WHERE completed_at IS NULL AND holiday_booking_id IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_academy ON sync_tasks (sync_target_id, academy_registration_id)
    WHERE completed_at IS NULL AND academy_registration_id IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_slot ON sync_tasks (sync_target_id, cleaning_slot_id)
    WHERE completed_at IS NULL AND cleaning_slot_id IS NOT NULL;
CREATE UNIQUE INDEX ix_sync_tasks_open_payment ON sync_tasks (sync_target_id, payment_id)
    WHERE completed_at IS NULL AND payment_id IS NOT NULL;


-- ---------------------------------------------------------------------------
-- Werte im System
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md, „Geld im System, alles andere fest" — „Alles, woran Geld
-- oder ein Vertrag hängt — Preise, Beträge, Pflichtmengen —, ist jederzeit
-- änderbar und steht im System, nie im Code … Jeder dieser Werte trägt ein
-- Datum, ab dem er gilt." Löschanker: keiner, keine Personendaten. Bewusst KEIN
-- Gültigkeits-Ende: „Es gilt immer der Wert, dessen Datum zuletzt erreicht
-- wurde", das Ende folgt aus dem nächsten Eintrag.
-- Hier stehen die Werte, die für das ganze Haus gelten. Was je Modul, Termin
-- oder Schulart verschieden ist — Hortbeitrag, Ferienaufschlag, Schulgeld,
-- Vertragstext —, trägt seine eigene Tabelle in der zuständigen Domäne, dort
-- aber mit demselben `valid_from` und derselben Auswahlregel.
CREATE TABLE configured_values (
    configured_value_id integer GENERATED ALWAYS AS IDENTITY,
    -- Der Code ist die Verankerung im Anwendungscode („cleaning_buyout_cents",
    -- „cleaning_penalty_cents", „application_fee_cents", „mileage_rate_cents",
    -- „expense_report_threshold_cents", „contract_fee_cents",
    -- „care_sibling_discount_basis_points", „care_change_fee_cents",
    -- „parent_bonus_monthly_cents", „parent_bonus_required_hours_primary",
    -- „parent_bonus_required_hours_secondary",
    -- „meal_single_amount_cents"). Jeder von ihnen ist von der
    -- Geschäftsführung änderbar und trägt seinen Gültigkeitstag; im Code steht
    -- nur der Code, nie die Zahl.
    -- „expense_report_threshold_cents" ist die Meldegrenze der
    -- Rechnungsfreigabe, derzeit 250 €: „Zwei Werte im System gehören der
    -- Geschäftsführung, beide mit Gültigkeitsdatum: der Kilometersatz … und die
    -- Meldegrenze, derzeit 250 €, gemessen am ganzen Beleg und nicht am Teil
    -- einer Aufteilung; es gilt jeweils der Wert zu der Handlung, die ihn
    -- braucht — der Kilometersatz zum Einreichen, die Meldegrenze zur Freigabe"
    -- (12). Anders als der Kilometersatz wird sie am Beleg NICHT mitgeführt: Aus
    -- ihr wird kein Betrag gerechnet, sie löst nur den Ping an die
    -- Geschäftsführung aus, und ein zweiter Ort für dieselbe Zahl wäre genau
    -- das, was rules.md Abschnitt 1 verbietet.
    -- „care_sibling_discount_basis_points" ist die Geschwisterermäßigung auf die
    -- Betreuungskosten (derzeit 1000, also 10 %); gerechnet wird sie nicht hier,
    -- siehe `care_module_prices` in anmeldung-schema.sql. Von der
    -- Notfallbetreuung nimmt der Betreuungsvertrag sie ausdrücklich aus.
    -- „meal_single_amount_cents" ist das einzelne Mittagessen ohne Abo, derzeit
    -- 5,90 € je Fall. Es fällt an, wo ein Fall der Notfallbetreuung über Mittag
    -- reicht (anmeldung-schema.sql), und steht hier statt in `meal_prices`
    -- (mensa-schema.sql), weil es weder je Modul noch je Schulart verschieden
    -- ist und keine Zahl von Esstagen kennt, an der es hinge.
    -- „care_change_fee_cents" ist die Änderungsgebühr der Betreuungsmodule,
    -- derzeit 20 €: hebel.md zählt sie unter den Werten auf, von denen gilt
    -- „ist jederzeit änderbar und steht im System, nie im Code" („Änderung der
    -- Betreuungsmodule 20 € (09)"), und 09 sagt „gegen die Änderungsgebühr,
    -- derzeit 20 €". Ob sie im Einzelfall erlassen wurde, steht am Vorgang
    -- (`care_module_agreements.change_fee_waived`, anmeldung-schema.sql); der
    -- Betrag hat dort keinen Ort und gehört hierher — wie
    -- „contract_fee_cents", die ebenso wenig über `payments` läuft. Der
    -- kostenfreie September (09) ist kein Wert, sondern eine Regel der
    -- Anwendung: er nennt keinen Betrag, sondern einen Monat.
    -- „contract_fee_cents" ist die Anmeldegebühr des Schulvertrags. Sie gilt
    -- schon länger unverändert und bekommt deshalb den Importtag als
    -- `valid_from` — einen früheren braucht niemand, weil kein Vertrag von
    -- davor im System steht. Derzeit 90 €: sie entsteht, sobald der Vertrag
    -- rechtsgültig geschlossen ist, und ist nicht die Bearbeitungsgebühr der
    -- Voranmeldung (derzeit 25 €,
    -- „application_fee_cents"), die 05 im Portal bezahlt. Sie läuft nicht über
    -- `payments`, sondern wird wie das Schulgeld eingezogen — hebel.md zählt
    -- drei Zahlungen über Weltenbaum auf, und diese ist keine davon.
    -- Die drei des Elternbonus: „Drei Werte im System gehören der
    -- Geschäftsführung: der Monatsbetrag (derzeit 10 €) und die beiden
    -- Pflichtstundenzahlen (derzeit 15 und 10)" (14).
    -- „parent_bonus_monthly_cents" ist der Monatsbetrag, den jede Familie
    -- zusätzlich zum Schulgeld zahlt, elf Monate im Jahr;
    -- „parent_bonus_required_hours_primary" die Pflichtstunden, wenn ein
    -- Grundschüler dabei ist, „parent_bonus_required_hours_secondary" die
    -- sonst — „nicht additiv, der größere Wert entscheidet" (14), und welcher
    -- gilt, rechnet die Anwendung aus der Schulart der Kinder. Die Stundenzahl
    -- ist eine Stückzahl und kein Betrag; welche Einheit gilt, sagt der Code
    -- (siehe `value` unten). Die Geschäftsführung „ändert sie mit Gültigkeit
    -- zum 1. August, damit keine mitten im Schuljahr greift" (14) — das ist
    -- ein Datum wie jedes andere und kein eigener Constraint.
    code                text NOT NULL,
    valid_from          date NOT NULL,
    -- Trägt Beträge in Cent ebenso wie Stückzahlen; welche Einheit gilt, sagt
    -- der Code. Ein zweiter Typ daneben wäre eine Spalte, die immer leer ist.
    value               integer NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    created_by          text NOT NULL,

    CONSTRAINT pk_configured_values PRIMARY KEY (configured_value_id),
    -- Je Wert und Gültigkeitstag genau ein Eintrag; ein noch nicht gültiger
    -- lässt sich bis dahin ändern oder zurücknehmen, „ein bereits gültiger
    -- nicht mehr" (hebel.md). Die zweite Hälfte des Satzes steht bewusst NICHT
    -- als Constraint: sie vergleicht `valid_from` mit dem heutigen Tag, und
    -- `now()` ist in keinem CHECK zulässig. Sie prüft die Anwendung — an dieser
    -- Tabelle wie an `contract_texts` und den beiden Preistabellen der Domänen.
    CONSTRAINT uq_configured_values UNIQUE (code, valid_from),
    CONSTRAINT ck_configured_values_code CHECK (code <> ''),
    CONSTRAINT ck_configured_values_created_by CHECK (created_by ~ '^(entra:|guardian:|system:)')
);


-- ---------------------------------------------------------------------------
-- Versandte Mail
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md, „Unzustellbare Mail" — „Bleibt eine Mail unzustellbar,
-- ist das im System sichtbar, und das Sekretariat geht dem nach. Das gilt für
-- jede Mail aus jedem Prozess." Löschanker: geht mit der Person, an die sie
-- ging (`fk_outbound_emails_person`, Cascade). Für eine Zeile OHNE Person —
-- die Mail an eine noch unbekannte Familie (05, 09, 10) — gibt es bewusst
-- keinen: Ihre einzige Personenangabe ist `recipient_email` in derselben Zeile,
-- ein Anker „verfällt mit der Adresse" zeigte also auf sich selbst. Eine Frist
-- ab `sent_at` wäre der Anker, den sie braucht; welche, entscheidet die
-- Datenschutzbeauftragte und nicht dieses Schema — die Frage steht unten.
-- Bewusst KEIN Mailtext und kein Anhang: die Zeile belegt den Versand, sie archiviert
-- ihn nicht — der Text steht in der Vorlage, der Anhang im Vorgang.
-- Sie trägt zugleich den Nachweis, dass eine Bestätigung hinausging: deshalb
-- braucht der Vertrag daneben kein eigenes `confirmation_sent_at`.
CREATE TABLE outbound_emails (
    outbound_email_id uuid NOT NULL DEFAULT gen_random_uuid(),
    -- Die Adresse, an die sie ging — nicht die heutige der Person: nur so ist
    -- eine Unzustellbarkeit später noch der richtigen Adresse zuzuordnen.
    recipient_email   text NOT NULL,
    -- Gesetzt, wo die Adresse zu einer bekannten Person gehört; bei einer noch
    -- unbekannten Familie (05, 09, 10) bleibt sie leer.
    person_id         uuid,
    -- Welcher Anlass, als Code — „Zusage", „Erinnerung Fristende",
    -- „Aufnahmebestätigung"; die Blöcke zählen sie je Prozess auf.
    purpose           text NOT NULL,
    sent_at           timestamptz NOT NULL DEFAULT now(),
    -- Der Rückläufer. Solange er leer ist, gilt die Mail als zugestellt; steht
    -- er, sieht das Sekretariat sie in seiner Liste.
    undeliverable_at  timestamptz,
    undeliverable_reason text,

    CONSTRAINT pk_outbound_emails PRIMARY KEY (outbound_email_id),
    CONSTRAINT fk_outbound_emails_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT ck_outbound_emails_email   CHECK (recipient_email <> ''),
    CONSTRAINT ck_outbound_emails_purpose CHECK (purpose <> ''),
    CONSTRAINT ck_outbound_emails_bounce
        CHECK ((undeliverable_at IS NULL) = (undeliverable_reason IS NULL))
);

-- Trägt die Liste, der das Sekretariat nachgeht.
CREATE INDEX ix_outbound_emails_undeliverable ON outbound_emails (undeliverable_at)
    WHERE undeliverable_at IS NOT NULL;


-- ---------------------------------------------------------------------------
-- Änderungsspur
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md, „Änderungsspur" — „Zu jeder Änderung wird festgehalten,
-- wer sie wann gemacht hat und was vorher dastand … einen zweiten Mechanismus
-- zum Protokollieren gibt es nicht." Sie trägt deshalb auch das Anlegen und das
-- Löschen einer Zeile (00, Rollenvergabe und -entzug) und den Nachweis einer
-- Rechteänderung (02). Löschanker: „die Änderungsspur und die erledigten
-- Nachzieh-Aufgaben gehen mit den Daten, auf die sie sich beziehen" (02) — als
-- Spalte, siehe unten; Tabellenname und Schlüssel allein tragen ihn nicht.
-- Bewusst KEIN Datenbank-Trigger: die Anwendung schreibt die Zeile, sonst
-- lebte die Regel nur in der Datenbank.
-- [A!] Der Bezug ist Tabellenname plus Schlüssel als Text, ohne Fremdschlüssel.
-- — Alternative: je Tabelle eine eigene Spurtabelle mit echtem Fremdschlüssel;
-- Preis: rund zwanzig Tabellen für einen Hebel, den hebel.md ausdrücklich als
-- einen beschreibt, und die Spur stürbe mit der Zeile, deren Löschung sie
-- belegen soll.
CREATE TABLE change_log (
    change_log_id bigint GENERATED ALWAYS AS IDENTITY,
    table_name    text NOT NULL,
    -- Der Primärschlüssel der geänderten Zeile als Text, weil die Spur uuid- und
    -- integer-Schlüssel gleich trägt.
    row_id        text NOT NULL,
    -- Der Löschanker zum Bezug darüber. Tabellenname und Schlüssel sind Text
    -- und tragen keinen: ein `DELETE FROM children` räumt über Cascade rund
    -- zwanzig Tabellen ab, ohne dass ein Lauf ihre Schlüssel je gesehen hätte —
    -- die Spur zur kaskadierten Zeile bliebe mit ihrem Altwert stehen, und der
    -- ist ein Personendatum. Gesetzt wird der Anker von derselben
    -- Schreibschicht, die die Spur ohnehin schreibt (siehe die Warnung im Kopf
    -- dieser Datei), auf das Kind, die Person oder die Familie, an der die
    -- geänderte Zeile hängt — **auch wo das erst über einen Join zu finden
    -- ist**: Die Spur trägt keine Frist und lebt allein von diesem Anker (17).
    -- Leer heißt deshalb nicht „Anker nicht gefunden", sondern „die geänderte
    -- Zeile hat keinen"; die Gegenprobe im Prüfskript hält die beiden
    -- auseinander. Dieselbe Bauform wie an `sync_tasks`, deren Löschanker aus
    -- demselben Satz aus 02 stammt.
    person_id     uuid,
    child_id      uuid,
    family_id     uuid,
    -- 00: „je Mitarbeitendem seine Rollen, samt wer sie wann vergeben oder
    -- entzogen hat (Änderungsspur)". Vergeben und Entziehen sind das Anlegen
    -- und das Löschen einer `employee_roles`-Zeile und keine Spaltenänderung;
    -- ohne diese Spalte ließen sie sich nur als Konvention abbilden, und die
    -- stünde nirgends.
    operation     text NOT NULL DEFAULT 'update',
    -- Nur bei einer Spaltenänderung gesetzt; das Anlegen und das Löschen einer
    -- Zeile hat keinen Spaltennamen.
    column_name   text,
    old_value     text,
    new_value     text,
    changed_at    timestamptz NOT NULL DEFAULT now(),
    -- Dieselben drei Präfixe wie `created_by`; bei einem maschinellen Lauf steht
    -- er hier als Urheber („system:rollover").
    changed_by    text NOT NULL,
    -- 02: „Bei einer Rechteänderung zusätzlich, dass ein Nachweis vorlag und wer
    -- ihn gesehen hat — der Nachweis selbst kommt nicht ins System." Er hängt an
    -- der Änderung und nicht an der geänderten Zeile: der Wegfall eines
    -- Elternteils löscht sie. „Wer ihn gesehen hat" trägt `changed_by` — „Das
    -- Sekretariat sieht den Nachweis an und trägt die neue Lage ein" (02), also
    -- dieselbe Person; eine zweite Spalte daneben wäre ein zweiter Ort für
    -- dieselbe Tatsache (rules.md Abschnitt 1).
    proof_seen_at timestamptz,

    CONSTRAINT pk_change_log PRIMARY KEY (change_log_id),
    CONSTRAINT fk_change_log_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT fk_change_log_child
        FOREIGN KEY (child_id)  REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT fk_change_log_family
        FOREIGN KEY (family_id) REFERENCES families (family_id) ON DELETE CASCADE,
    -- Höchstens einer — zwei Anker löschten die Spur mit dem, der zuerst geht,
    -- und die beiden rechnen verschieden (das Kind ab seinem Ende (03), die
    -- Familie am letzten ihrer Kinder). Keiner heißt „ohne Personenbezug": die
    -- Änderung an einem Wert im System oder an einer Werteliste hat keinen.
    CONSTRAINT ck_change_log_single_anchor CHECK (
        (person_id IS NOT NULL)::int
      + (child_id  IS NOT NULL)::int
      + (family_id IS NOT NULL)::int <= 1),
    CONSTRAINT ck_change_log_table  CHECK (table_name <> ''),
    CONSTRAINT ck_change_log_row    CHECK (row_id <> ''),
    CONSTRAINT ck_change_log_operation
        CHECK (operation IN ('insert', 'update', 'delete')),
    CONSTRAINT ck_change_log_column CHECK (column_name <> ''),
    -- Der Spaltenname gehört zur Spaltenänderung und nur zu ihr.
    CONSTRAINT ck_change_log_column_scope
        CHECK ((operation = 'update') = (column_name IS NOT NULL)),
    -- Eine Zeile ohne Alt- und Neuwert protokolliert nichts; das Anlegen trägt
    -- den neuen Stand, das Löschen den alten.
    CONSTRAINT ck_change_log_values CHECK (
        CASE operation
            WHEN 'insert' THEN old_value IS NULL     AND new_value IS NOT NULL
            WHEN 'delete' THEN old_value IS NOT NULL AND new_value IS NULL
            ELSE old_value IS NOT NULL OR new_value IS NOT NULL
        END),
    CONSTRAINT ck_change_log_changed_by CHECK (changed_by ~ '^(entra:|guardian:|system:)')
);
-- Siehe die Warnung im Kopf dieser Datei: diese Tabelle füllt allein die
-- Anwendung. Eine vergessene Stelle fällt hier nicht auf.

CREATE INDEX ix_change_log_row ON change_log (table_name, row_id, changed_at DESC);


-- ---------------------------------------------------------------------------
-- Lösch-Lauf (17)
-- ---------------------------------------------------------------------------

-- Herkunft: hebel.md, „Löschankündigung und Anhalten" — „je Bestand eine Liste,
-- deren Eintrag eine einzelne Person oder eine ganze Rollengruppe sein kann".
-- Kein Löschanker: keine Personendaten. Audit-Spalten, weil eine Zeile hier
-- entscheidet, wer eine Löschung überhaupt anhalten kann.
CREATE TABLE retention_subjects (
    retention_subject_id integer GENERATED ALWAYS AS IDENTITY,
    -- Ein Bestand ist **eine Frist mit einem Anker**, nicht eine Tabelle:
    -- Vertrag und Mandat rechnen verschieden und sind deshalb zwei, der
    -- Gesundheitsbestand am Kind und die anlassbezogene Angabe ebenso (17). Die
    -- Codes, die die Blöcke heute nennen: „application" (05),
    -- „child_health_record" und „health_occasion" (17), „holiday_booking" (10),
    -- „holiday_care_note" (10), „academy_registration" (21), „excursion" (19),
    -- „contract" und „sepa_mandate" (08), „child_file" (08), „care_file" (09),
    -- „employee" (13). Der Code ist die Verankerung im
    -- Anwendungscode; wächst die Liste, ist das eine Zeile und keine Migration.
    code                 text NOT NULL,
    name                 text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus jedem
    -- Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn zeigt
    -- (rules.md Abschnitt 3).
    is_active            boolean NOT NULL DEFAULT true,
    created_at           timestamptz NOT NULL DEFAULT now(),
    created_by           text NOT NULL,

    CONSTRAINT pk_retention_subjects      PRIMARY KEY (retention_subject_id),
    CONSTRAINT uq_retention_subjects_code UNIQUE (code),
    CONSTRAINT ck_retention_subjects_code CHECK (code <> ''),
    CONSTRAINT ck_retention_subjects_name CHECK (name <> ''),
    CONSTRAINT ck_retention_subjects_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: hebel.md, „Löschankündigung und Anhalten" — „Empfänger sind immer
-- mindestens zwei … Sie stehen als Wert im System und nicht im Code."
-- Kein Löschanker: die Zeile nennt eine Zuständigkeit, keine Person im Bestand;
-- sie geht mit der Mitarbeitendenzeile, auf die sie zeigt.
-- Bewusst KEINE Tabelle für die versandten Ankündigungen daneben: Der Lauf
-- läuft täglich und schickt am Tag vor dem Termin minus vierzehn und minus
-- sieben — „ein festes Datum wie ‚am 1. jedes Monats' schlägt ein gerechnetes"
-- (hebel.md); was er
-- geschickt hat, steht als Zeile in `outbound_emails`.
CREATE TABLE retention_notice_recipients (
    retention_notice_recipient_id integer GENERATED ALWAYS AS IDENTITY,
    retention_subject_id          integer NOT NULL,
    -- Die benannte Person, als Mitarbeitendenzeile und nicht als Person —
    -- dieselbe Form wie die Freigabeberechtigten der Akademie
    -- (akademie-schema.sql).
    employee_id                   uuid,
    -- Oder die ganze Rollengruppe.
    role_id                       integer,
    -- Oder: der Empfänger folgt aus dem Vorgang selbst — die Lehrkraft einer
    -- Fahrt (19), die Verantwortlichen eines Angebots (21). Ohne diesen dritten
    -- Fall wären genau die zwei Bestände nicht eintragbar, deren zuständige
    -- Stelle je Instanz eine andere ist; eine Rolle träfe dort alle Lehrkräfte.
    from_the_case                 boolean NOT NULL DEFAULT false,
    -- Grenzt eine Rollengruppe auf eine Schulart ein: „die Lehrkräfte" ohne
    -- Zusatz wären beide Zweige, und manche Lehrkraft ist nur für einen
    -- zuständig. Leer heißt beide. Nur bei einer Rollengruppe zulässig — eine
    -- benannte Person ist schon eingegrenzt.
    school_branch_id              integer,
    created_at                    timestamptz NOT NULL DEFAULT now(),
    created_by                    text NOT NULL,

    CONSTRAINT pk_retention_notice_recipients PRIMARY KEY (retention_notice_recipient_id),
    CONSTRAINT fk_retention_notice_recipients_subject
        FOREIGN KEY (retention_subject_id) REFERENCES retention_subjects (retention_subject_id),
    -- Cascade wie bei den Freigabeberechtigten: Wer geht, ist kein Empfänger
    -- mehr; dass dann nur noch einer übrig ist, meldet die Prüfung unten.
    CONSTRAINT fk_retention_notice_recipients_employee
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_retention_notice_recipients_role
        FOREIGN KEY (role_id) REFERENCES roles (role_id),
    CONSTRAINT fk_retention_notice_recipients_branch
        FOREIGN KEY (school_branch_id) REFERENCES school_branches (school_branch_id),
    -- Genau eine Art je Zeile: Person, Rollengruppe oder „die Stelle dieses
    -- Vorgangs".
    CONSTRAINT ck_retention_notice_recipients_kind CHECK (
        (employee_id IS NOT NULL)::int
      + (role_id     IS NOT NULL)::int
      + (from_the_case)::int = 1),
    CONSTRAINT ck_retention_notice_recipients_branch
        CHECK (school_branch_id IS NULL OR role_id IS NOT NULL),
    -- Ein Empfänger steht je Bestand einmal. `NULLS NOT DISTINCT` (Postgres 15+,
    -- Ziel ist 18) statt vier partieller Indizes: Hier ist die ganze Zeile die
    -- Kennung, und zwei gleiche Zeilen wären zwei gleiche Mails.
    CONSTRAINT uq_retention_notice_recipients UNIQUE NULLS NOT DISTINCT
        (retention_subject_id, employee_id, role_id, school_branch_id, from_the_case),
    CONSTRAINT ck_retention_notice_recipients_created_by
        CHECK (created_by ~ '^(entra:|system:)')
);

-- Die Mindestzahl zwei steht bewusst NICHT als Constraint: Sie zählt über die
-- Zeilen einer Gruppe, und das trüge nur ein Trigger, den dieses Schema
-- nirgends kennt (dieselbe begründete Auslassung wie beim Ratelimit an
-- `login_codes`). Sie hält die Schreibschicht, und
-- `querschnitt-schema-check.sql` weist den Ein-Empfänger-Fall mit genau dieser
-- Abfrage nach — sie ist zugleich die, die der Betrieb regelmäßig laufen lässt.

-- Herkunft: hebel.md, „Löschankündigung und Anhalten" — „ob ein Vorgang
-- vorliegt, der die Löschung verzögert — Arztbesuch, Unfall, medizinische
-- Ausnahmesituation, drohender Rechtsstreit". Kein Löschanker: keine
-- Personendaten. Werteliste und kein CHECK, weil sie wächst: „wer einen
-- findet, den es geben muss, bekommt eine fünfte Zeile in der Liste und keinen
-- Freitext" (17) — ein Freitext stünde daneben, und danach ließe sich nicht mehr zählen,
-- warum angehalten wird.
CREATE TABLE retention_hold_reasons (
    retention_hold_reason_id integer GENERATED ALWAYS AS IDENTITY,
    code                     text NOT NULL,
    name                     text NOT NULL,
    -- Deaktiviert statt gelöscht: „is_active = false" nimmt den Wert aus jedem
    -- Auswahlfeld, lässt aber jede Zeile stehen, die schon auf ihn zeigt
    -- (rules.md Abschnitt 3).
    is_active                boolean NOT NULL DEFAULT true,
    created_at               timestamptz NOT NULL DEFAULT now(),
    created_by               text NOT NULL,

    CONSTRAINT pk_retention_hold_reasons      PRIMARY KEY (retention_hold_reason_id),
    CONSTRAINT uq_retention_hold_reasons_code UNIQUE (code),
    CONSTRAINT ck_retention_hold_reasons_code CHECK (code <> ''),
    CONSTRAINT ck_retention_hold_reasons_name CHECK (name <> ''),
    CONSTRAINT ck_retention_hold_reasons_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Herkunft: hebel.md, „Löschankündigung und Anhalten" — „Die Stelle kann die
-- Löschung für einen einzelnen Fall anhalten … Ein Anhalten gilt bis zu einem
-- Datum, nie unbefristet." Löschanker: geht mit dem Anker, den es hält
-- (Cascade) — ist der Bestand geräumt, ist die Zeile gegenstandslos, und der
-- Beleg, dass angehalten wurde, steht in `change_log` (17).
-- Bewusst KEINE Spalte für die Zahl der Verlängerungen: Verlängern ist eine
-- weitere Zeile mit demselben `first_hold_id`, und die Zahl ist deren Anzahl
-- (rules.md Abschnitt 1).
CREATE TABLE retention_holds (
    retention_hold_id        uuid NOT NULL DEFAULT gen_random_uuid(),
    retention_subject_id     integer NOT NULL,
    -- Genau einer der drei Anker, dieselbe Bauform wie an `change_log` und
    -- `sync_tasks`: „ein Anhalten muss der Lauf finden, bevor er die Zeilen
    -- überhaupt gesammelt hat" — Tabellenname plus Schlüssel als Text fände er
    -- erst danach.
    child_id                 uuid,
    person_id                uuid,
    family_id                uuid,
    retention_hold_reason_id integer NOT NULL,
    -- Der Tag, an dem ohne dieses Anhalten gelöscht worden wäre. Er wird beim
    -- Verlängern **mitgenommen und nicht neu gesetzt**: „sonst begänne die
    -- Zählung mit jedem Anhalten von vorn, und genau die Zahl, um die es geht,
    -- wäre fort" (hebel.md). Der Fremdschlüssel unten hält ihn daran.
    original_delete_on       date NOT NULL,
    -- Bis wann angehalten ist. Danach beginnt die Ankündigung von vorn, nicht
    -- die Löschung (17) — der Lauf rechnet den neuen Termin ab hier und nicht
    -- ab `original_delete_on`, der allein die Fälligkeit trägt.
    held_until               date NOT NULL,
    -- Die erste Zeile dieses Falls; bei ihr selbst leer. Sie ist es, die den
    -- ursprünglichen Termin festhält: Eine Verlängerung kommt nur herein, wenn
    -- sie denselben trägt.
    first_hold_id            uuid,
    created_at               timestamptz NOT NULL DEFAULT now(),
    -- Wer angehalten hat. Eine zweite Spalte daneben wäre der zweite Ort für
    -- dieselbe Tatsache (rules.md Abschnitt 1).
    created_by               text NOT NULL,

    CONSTRAINT pk_retention_holds PRIMARY KEY (retention_hold_id),
    CONSTRAINT fk_retention_holds_subject
        FOREIGN KEY (retention_subject_id) REFERENCES retention_subjects (retention_subject_id),
    CONSTRAINT fk_retention_holds_reason
        FOREIGN KEY (retention_hold_reason_id)
        REFERENCES retention_hold_reasons (retention_hold_reason_id),
    CONSTRAINT fk_retention_holds_child
        FOREIGN KEY (child_id)  REFERENCES children (child_id) ON DELETE CASCADE,
    CONSTRAINT fk_retention_holds_person
        FOREIGN KEY (person_id) REFERENCES persons (person_id) ON DELETE CASCADE,
    CONSTRAINT fk_retention_holds_family
        FOREIGN KEY (family_id) REFERENCES families (family_id) ON DELETE CASCADE,
    CONSTRAINT ck_retention_holds_single_anchor CHECK (
        (child_id  IS NOT NULL)::int
      + (person_id IS NOT NULL)::int
      + (family_id IS NOT NULL)::int = 1),
    -- Trägt den Fremdschlüssel darunter und ist deshalb zusätzlich zum
    -- Primärschlüssel nötig (rules.md Abschnitt 1).
    CONSTRAINT uq_retention_holds_original UNIQUE (retention_hold_id, original_delete_on),
    CONSTRAINT fk_retention_holds_first
        FOREIGN KEY (first_hold_id, original_delete_on)
        REFERENCES retention_holds (retention_hold_id, original_delete_on),
    -- Eine Zeile ist nicht ihre eigene erste; sonst ginge der Fremdschlüssel
    -- oben für jede beliebige Verlängerung auf.
    CONSTRAINT ck_retention_holds_first_other
        CHECK (first_hold_id IS NULL OR first_hold_id <> retention_hold_id),
    -- Ein Anhalten, das vor dem Löschtermin endet, hält nichts auf.
    CONSTRAINT ck_retention_holds_held_until CHECK (held_until > original_delete_on),
    CONSTRAINT ck_retention_holds_created_by CHECK (created_by ~ '^(entra:|system:)')
);

-- Trägt beide Fragen des Laufs: welche Anhaltungen laufen ab, und was steht
-- heute in der Liste der angehaltenen Löschungen.
CREATE INDEX ix_retention_holds_held_until ON retention_holds (held_until);

-- Je Bestand und Anker gibt es höchstens **eine erste** Zeile; jede weitere ist
-- eine Verlängerung und muss `first_hold_id` tragen. Erst damit greift der
-- zusammengesetzte Fremdschlüssel darüber, und „der ursprüngliche Löschtermin
-- bleibt beim Verlängern stehen" (hebel.md) gilt auch für den, der über die
-- Oberfläche „neu anhalten" statt „verlängern" wählt — sonst setzte genau er
-- die Zählung zurück, um die es geht. `NULLS NOT DISTINCT` (Postgres 15+, Ziel
-- ist 18), weil zwei der drei Ankerspalten je Zeile leer sind und die Zeile
-- sonst für sich einzigartig wäre; dieselbe Form wie `uq_employee_roles`
-- (stammdaten-schema.sql). Bewusst KEIN Index über die *laufenden* Anhaltungen:
-- „laufend" verglich `held_until` mit dem heutigen Tag, und `current_date` ist
-- in keinem Indexprädikat zulässig — dieselbe Grenze wie beim Gültigkeitstag an
-- `configured_values`.
CREATE UNIQUE INDEX ix_retention_holds_first
    ON retention_holds (retention_subject_id, child_id, person_id, family_id)
    NULLS NOT DISTINCT
    WHERE first_hold_id IS NULL;


-- ---------------------------------------------------------------------------
-- Offene Fragen an die Schule
-- ---------------------------------------------------------------------------

-- [?] Wie lange bleibt eine versandte Mail stehen, die an keiner Person hängt?
--     Die Mail an eine noch unbekannte Familie (05, 09, 10) trägt deren
--     Adresse und sonst nichts; sie geht mit keinem Cascade fort, und ohne eine
--     Frist ab `sent_at` steht die Adresse unbefristet. Geraten wird sie nicht.
--     Am 02.09.2026 vorgelegt und **nicht bewertbar zurückgekommen**: „kann
--     nicht bewertet werden, da wir Kontext nicht verstehen. Wer sind die
--     betroffenen Personen / warum kein Text". Die Frist fehlt damit weiter,
--     und die nächste Vorlage muss zwei Dinge mitliefern, statt nach einer Zahl
--     zu fragen: dass die Empfänger Eltern sind, die eine Bestätigung bekommen,
--     bevor sie überhaupt als Familie geführt werden, und dass der Mailtext
--     bewusst nicht gespeichert wird — die Zeile trägt Adresse, Anlass in einem
--     Wort, Versandzeitpunkt und Zustellbarkeit. — Datenschutzbeauftragte
--     Was daran hängt: Bis die Frist steht, räumt der Lösch-Lauf diese Zeilen
--     gar nicht; danach ist es eine WHERE-Bedingung und keine Migration.

-- [?] Muss der Nachweis des Fotoeinverständnisses das Kind überdauern?
--     Heute nicht: Die Zustimmung hängt am Kind und geht mit ihm (08, Block
--     „Löschen"), beide Fremdschlüssel kaskadieren. Dagegen steht, dass ein
--     einmal veröffentlichtes Bild nicht mehr verschwindet und Jahre später
--     ersichtlich bleiben muss, dass die Erlaubnis bis zu einem bestimmten Tag
--     galt (Art. 7 Abs. 1 DSGVO). Am 02.09.2026 zusammen mit den vier Fristen
--     vorgelegt und **nicht beantwortet** zurückgekommen.
--     — Datenschutzbeauftragte
--     Was daran hängt: Fällt die Antwort auf „ja", ist das ein eigener
--     Bestandscode in `retention_subjects` und ein Eingriff in die
--     Löschmechanik — die Cascade an `fk_consents_child` müsste fallen —, kein
--     Satz an einem Kommentar.

-- Beantwortet: Der Hort bekommt keine eigene Bibliothek. Es bleibt bei der
-- einen Schülerakte, ein Ordner je Kind; was der Hort sieht, sieht er über
-- Weltenbaum und nicht über SharePoint. `sharepoint_libraries` trägt beliebig
-- viele Zeilen, gebraucht werden zwei — die Schülerakte und die Ablage der
-- Rechnungsfreigabe (rechnungsfreigabe-schema.sql). Käme je eine dritte dazu,
-- wäre das eine Zeile und ein weiteres Grant, kein Umbau.
