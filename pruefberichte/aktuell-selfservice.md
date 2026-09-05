# Prüfbericht selfservice

Lauf gegen `schema/selfservice-schema.sql` und `schema/selfservice-schema-check.sql`, gegen die
Blöcke 00, 02, 05, 08, `soll-prozesse/README.md` und `hebel.md`.

Ladelauf in der dokumentierten Reihenfolge, alle vierzehn `-schema.sql` in eine leere Datenbank:
rc=0 je Datei. `selfservice-schema-check.sql` gegen diese vollständige Datenbank: **rc=0**.

Sortierung nach Gewicht: **F1, F5, F2, F3, F4**.

## Funde

[SELFSERVICE-F1] selfservice · Klasse 1 · `children.entry_date` als zweite Grenze
`selfservice-schema.sql` Z. 24–26: „Die Grenze ist deshalb `released_at` **oder**
`children.entry_date` gesetzt — die Einschreibung ist bei ihnen, was sonst die Freigabe ist."
Block 02 nennt genau eine Grenze: „Bis zur Freigabe des ersten Vertrags am Kind ([08], beim
externen Hortkind [09]) ändern die Eltern sie selbst" / „Ab der Freigabe ändert sie allein das
Sekretariat". Die zweite Hälfte entscheidet kein Block: Beide Belegstellen — `README.md` („Der
Vollimport bringt die eingeschriebenen Kinder mit …") und 08 Z. 77 („erkennbar daran, dass diese
Strecke bei ihnen nie lief") — reden über den fehlenden Gesundheits- und Vertragsbestand, nicht
über den Schreibpfad der Stammdaten. Die einzige Stelle, die für Bestandskinder überhaupt eine
Folge zieht, zieht die umgekehrte: „Auch die Notfallnummer-Pflicht ([02]) greift deshalb für neue
Verträge und sperrt bei einem Bestandskind nichts" (README). `api/selfservice-api.md` Z. 49 trägt
die Ableitung inzwischen mit.
Vorschlag: als `[A]` mit Alternative und Preis markieren, statt sie als Ableitung zu führen — oder
einen Satz in 02 nachziehen, der die Bestandskinder entscheidet.

[SELFSERVICE-F5] selfservice · Klasse 1/7 · die Nachzieh-Aufgabe fehlt in der Bestandsaufnahme
Block 02 zählt unter „Was dabei erhoben wird" einen eigenen Abschnitt auf: „Je Nachzieh-Aufgabe:
Welche Aufgabenart … Ob sie offen ist … Wer sie abgehakt hat und mit welchem Ergebnis", dazu die
Schritte 3 und 4 des Ablaufs. `selfservice-schema.sql` nennt unter den fünf Strukturen keine
davon, und das Prüfskript prüft sie nicht. Gebaut ist der Sachverhalt — `sync_tasks`
(`querschnitt-schema.sql` Z. 1476 ff.) trägt `task_text`, `completed_at`, `completed_by` und
`outcome` und zitiert dafür an `ck_sync_tasks_completed_by` selbst Block 02 —, nur gehört er nach
dieser Datei nicht zur Domäne. `grenzkarte.md` führt Domäne 8 folgerichtig mit „Nutzt
Querschnitt: —"; der Block ist jünger und schlägt sie (Rangfolge in `CLAUDE.md`).
Vorschlag: `sync_tasks` als sechste Struktur aufnehmen, Existenzprüfung ins Skript, und die
Grenzkarten-Zeile auf Q5 setzen.

[SELFSERVICE-F2] selfservice · Klasse 1 · `guardians` fehlt in der Bestandsaufnahme
`selfservice-schema.sql` zählt fünf Strukturen auf, `guardians` ist keine davon; das Prüfskript
prüft dieselben fünf. `hebel.md`, Sparsame Ansicht, zählt den **Beruf** zu den Angaben, die „der
Familie bis zur Freigabe des ersten Vertrags am Kind" gehören und die „von da an nur noch das
Sekretariat (02)" ändert — er steht samt Konfession und Staatsangehörigkeit der Sorgeberechtigten
an `guardians` (`stammdaten-schema.sql` Z. 653–673, so auch `grenzkarte.md`, Freeze). Dieselbe
Grenze aus 02 trägt damit eine Tabelle, die diese Domäne nirgends nennt — und der Selfservice ist
der Ort, an dem sie greift.
Vorschlag: `guardians.occupation`/`denomination_id`/`nationality_country_id` als weitere Struktur
aufnehmen und in die Existenzliste des Prüfskripts.

[SELFSERVICE-F3] selfservice · Klasse 5 · Gegenprobe „Umzug einer Familie" ohne Kind
`selfservice-schema-check.sql` Z. 130–136 belegt „Wer die eigene Anschrift ändert, wird gefragt,
ob sie auch für die Kinder gilt — ein Häkchen, kein zweiter Vorgang" (02) mit einem `UPDATE` auf
`addresses`, an dem allein die beiden Sorgeberechtigten hängen. Ein `children`-Satz kommt im
ganzen Skript nicht vor; der Fall, um den die Regel geht — zieht die Anschrift des Kindes mit oder
nicht —, wird nicht angefasst. Nachgestellt trägt die Struktur ihn (eigene Probe: Kind und Mutter
auf derselben `addresses`-Zeile, die Mutter auf eine neue umgehängt, das Kind bleibt stehen) —
belegt hat das Skript es nicht.
Vorschlag: ein Kind mit derselben `address_id` in die Stammsätze aufnehmen und beide Richtungen
über es führen.

[SELFSERVICE-F4] selfservice · Klasse 3 · Zitat der falschen Quelle zugeordnet
`selfservice-schema-check.sql` Z. 172–173: „hebel.md, Anmeldecode: … „bevor dort irgendetwas
entsteht, bestätigen sie ihre Mailadresse"". Der Satz steht in Block 00 Z. 138, nicht in
`hebel.md`; die Probe darunter ist dann auch mit `00 —` beschriftet.
Vorschlag: Quellenangabe im Kommentar auf 00 ziehen.

## Angesehen, nicht als Fund gewertet

selfservice · Beide `expect_reject`-Proben scheitern aus dem richtigen Grund, einzeln abgesetzt
        nachgeprüft: `fk_family_guardians_access_level` (23503) bzw. `ck_phone_numbers_created_by`
        (23514) — nicht an einem `NOT NULL`.

selfservice · „im System steht nur, dass einer vorlag" (02): Die Behauptung, das trage die
        Änderungsspur, hält — `change_log.proof_seen_at` samt der Begründung, dass `changed_by`
        die zweite Hälfte des Satzes trägt (`querschnitt-schema.sql`).

selfservice · Die Bestätigung einer neu eingetragenen Mailadresse (02) hat hier keine Gegenprobe,
        aber `login_codes.purpose = 'email_confirmation'` samt `ck_login_codes_person` steht, und
        die Gegenproben dazu stehen in `stammdaten-schema-check.sql` Z. 686–711 — dort entsteht
        die Tabelle.

selfservice · Vier Regeln aus 02 und `hebel.md` sind angegriffen und stehen als begründete
        Auslassung im Schema, jede an ihrem Anker: Kind ohne Anschrift (`persons.address_id`),
        Familie ohne Mailadresse und ohne Notfallnummer (`families`, `phone_numbers`), sechs
        Codes je Adresse und Stunde (`ix_login_codes_email_created`). Alle vier gehen in der
        Datenbank durch — genau wie dort geschrieben.

selfservice · Einsichtsstufe an `family_guardians` statt an `guardians`, obwohl `hebel.md` sagt
        „Die Stufe hängt an der Person": Der Satz stellt sie der Feldliste gegenüber, nicht der
        Familie. Dieselbe Person trägt damit in zwei Familien zwei Stufen (nachgestellt: geht
        durch); `stammdaten-schema.sql` Z. 675–678 schreibt genau das aus.

selfservice · `access_levels` trägt die drei Zeilen voll/nur lesen/gesperrt nicht als Saatgut, das
        Prüfskript legt sie selbst an. Keine `-schema.sql` dieses Repos enthält ein `INSERT` —
        Wertelisten kommen mit dem Import, das ist keine Eigenheit dieser Domäne.

selfservice · Die Negativprobe „keine eigenen Tabellen" prüft vier geratene Namen und bliebe bei
        einem fünften grün. `klassenbildung-` und `m365-schema-check.sql` bauen sie genauso — eine
        Konvention der drei tabellenlosen Domänen, kein Fund dieser einen.

## `[A!]` dieser Domäne

Keine in `selfservice-schema.sql`. Die eine `[A!]`, an der ihr Schnitt hängt, steht in
`stammdaten-schema.sql` Z. 1093: „Der Anmeldecode bekommt eine Tabelle in Stammdaten." Ein Block
entscheidet sie nicht, `grenzkarte.md` schon — sie führt den Anmeldecode unter den eigenen
Entitäten der Stammdaten und Domäne 8 mit „keine".

## Ergebnis

Die Domäne ist **nicht ohne Fund** durchgekommen: fünf, davon zwei an derselben Stelle — die
Bestandsaufnahme dieser Domäne ist ihr einziger Inhalt, und sie ist an zwei Punkten unvollständig.
Das Prüfskript läuft grün.
