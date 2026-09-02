# Routen-Prüflauf: anmeldung

Stand `origin/gesundheit-umbau` (1569109), 54 Routen. Nullpunkt
`pytest tests/test_anmeldung.py`: **118 passed**. Dreizehn Sicherungen herausgenommen, zwei davon
wurden rot.

## Funde

[anmeldung-R1] Klasse 1 · `_reach_contract` — `GET /contracts/{contract_id}`,
`PUT …/responses/{person_id}`, `PUT …/responses/{person_id}/data-review`, `POST …/signatures`,
`POST …/module-agreements`, `POST …/termination`
Plan: „Schulleitung nur ihre Schulart". Der Check liest `child.school_branch_id` — diese Spalte
setzt aber erst `POST /contracts/{id}/release` (`app/routers/anmeldung.py:2912`, der einzige
reguläre Schreiber; der Kommentar dort sagt es selbst: „the child gets `school_branch_id` at the
release"). Für jede Bewerberin ist sie bis dahin `None`, und `None in frozenset()` ist falsch: Die
Schulleitung bekommt auf dem **ganzen** Vertragsweg — Ansicht, stellvertretende Annahme,
Durchsicht, Unterschrift — 404, obwohl der Plan ihr genau diese vier Zeilen gibt.
Gemessen: Bedingung entfernt (`if BRANCH_ROLE in user.roles: return`), tests/test_anmeldung.py
bleibt grün (118 passed) — die Einschränkung hat in keiner Richtung einen Test.
Vorschlag: beim Schulvertrag `application.school_branch_id` prüfen, wie `release_contract` es
bereits tut, und beim Hortvertrag `child.school_branch_id` lassen.

[anmeldung-R2] Klasse 5 · `POST /contracts/{contract_id}/release` und
`POST /care-module-agreements/{care_module_agreement_id}/release`
`gemeinsam.md`: „Zweierlei bekommt er damit nicht … was einer Person zur Entscheidung zugewiesen
ist — Freigabe, Gegenzeichnung, Straf-Aussetzung —, bleibt bei ihr". 08 Z5 schreibt dazu aus: „das
Sekretariat nie, auch nicht vertretungsweise". Beide Tore laufen über `require_staff` bzw.
`require_role`, und beide legen `ADMIN_ROLE` unbedingt dazu (`app/core/security.py`,
`staff_roles`) — Admin ist die Obermenge der Verwaltung, zeichnet damit für die Schule gegen und
schreibt sich selbst in `contracts.released_by`.
Gemessen: Admin aus dem Rollentor von `release_contract` genommen, tests/test_anmeldung.py bleibt
grün (118 passed) — `test_the_office_never_releases` prüft das Sekretariat, den Admin nie.
Vorschlag: für die zwei Freigabe-Routen ein Tor ohne Admin-Ergänzung, dazu je ein Test auf 403.

[anmeldung-R3] Klasse 5 · `GET /children/{child_id}/sepa-mandates`
Dieselbe Stelle in `gemeinsam.md`, andere Hälfte: „die engen Spalten (Art. 9, IBAN) liegen hinter
eigenen DB-Rollen". Der Plan nennt als Abnehmer allein die Buchhaltung. Die Route zählt Admin mit:
`with_bank = not user.is_guardian and bool(user.roles & {_ACCOUNTING, ADMIN_ROLE})` — ein Admin
liest damit jede Kontonummer der Schule.
Gemessen: `ADMIN_ROLE` aus der Menge entfernt, tests/test_anmeldung.py bleibt grün (118 passed) —
`test_only_accounting_sees_the_account_number` prüft Mutter, Sekretariat und Buchhaltung.
Vorschlag: `{_ACCOUNTING}` allein, dazu ein Test, der `as_role("admin")` die IBAN verweigert.

[anmeldung-R4] Klasse 1 · `_acting_person` — `PUT /contracts/{id}/responses/{person_id}`,
`PUT …/data-review`, `POST …/signatures`
Für den Elternteil prüft der Helfer `person_id == user.acting_as`; für die Mitarbeiterseite prüft
er **nur die Rolle**. Die `person_id` aus dem Pfad wird nicht gegen die Familie des Vertrags
gehalten, also legt das Sekretariat mit einer geratenen fremden Kennung eine `contract_responses`-
oder `signatures`-Zeile an einem Vertrag an, zu dem die Person nicht gehört — und
`_contract_out` führt sie danach in `responses` auf, weil dort `set(expected) | set(answered)`
steht. Die Schwesterroute `POST /children/{id}/sepa-mandates` prüft genau das über
`persons_of_family` und nennt den Grund im Kommentar; hier fehlt derselbe Satz.
Gemessen: die `persons_of_family`-Prüfung auf der Mitarbeiterseite von `_acting_person` **ergänzt**,
tests/test_anmeldung.py bleibt grün (118 passed) — die Verschärfung kostet nichts und kein Test
beobachtet den Fall.
Vorschlag: die Prüfung dort einbauen, dazu ein Test, der das Sekretariat für `other_mother` am
Vertrag des eigenen Kindes mit 404 abweist.

[anmeldung-R5] Klasse 2 · `DELETE /applications/{application_id}`
Plan: „nur eine beendete (`ended_at`), sonst 400" — aber `release_contract` beendet die Bewerbung
selbst (Status *eingeschrieben*, `ended_at` gesetzt). Ein eingeschriebenes Kind hat damit eine
„beendete" Bewerbung, und die Route löscht ohne weitere Bedingung erst **jeden Vertrag dieser
Bewerbung**, dann die Bewerbung; `_last_connection` bricht danach ab, weil `child.entry_date`
steht. Ergebnis: Das Kind bleibt eingeschrieben, sein freigegebener Schulvertrag samt
`document_checksum` ist weg, die abgelegte PDF bleibt als verwaiste `documents`-Zeile stehen.
Gemessen: die Vertragsschleife aus `delete_application` entfernt, tests/test_anmeldung.py bleibt
grün (118 passed) — der einzige Löschtest nimmt eine Bewerbung ohne Vertrag.
Vorschlag: zusätzlich auf einen freigegebenen Vertrag prüfen und mit `400` abweisen, wie es
`withdraw_application` bereits tut.

[anmeldung-R6] Klasse 6 · `POST /applications/decisions/release`
Der Plan verspricht: „Keine Familie erfährt ihre Absage, während über die Zusagen noch geredet
wird … in **einer** Transaktion samt Mails". Die Mails sind aber nicht in ihr:
`send_tracked` öffnet eine **eigene** Transaktion, committet die `outbound_emails`-Zeile und
schickt sofort (`app/services/mail.py`). Die Schleife sendet je Zeile und kann danach noch werfen —
`raise HTTPException(400, "No contract text … in force")` steht für die nächste Zusage direkt hinter
der Absage-Mail der vorigen. Dann ist die Freigabe zurückgerollt, `released_at` leer, und die
Familie hat ihre Absage trotzdem gelesen; der zweite Anlauf schickt sie ein zweites Mal. Dieselbe
Form trägt `POST /admission-days/{id}/release`: die Einladungen gehen in der Schleife raus, bevor
`released_at` committet ist, und „einmal" gilt danach nicht mehr.
Nur gelesen, nicht gemessen: die Sicherung, die man dafür herausnehmen könnte, gibt es nicht.
Vorschlag: die Empfängerliste und die Prüfungen der Schleife vollständig durchlaufen, bevor die
erste Mail rausgeht — die Textfassung je Ziel also vor der ersten Zusage auflösen.

[anmeldung-R7] Klasse 6 · `POST /children/{child_id}/sepa-mandates`
Die Route baut die Mandatsdatei über Graph (`build_mandate_document`, mit IBAN im Dokument) und
dekodiert **erst danach** das Signaturbild — `base64.b64decode(..., validate=True)` in
`_store_signature_image` antwortet auf einen unlesbaren Rumpf mit `400`. Die Transaktion rollt
zurück, die PDF bleibt in der Bibliothek liegen, und keine `documents`-Zeile zeigt mehr auf sie:
Eine Datei mit Kontonummer, die kein Lösch-Lauf je findet. Der Plan nimmt genau einen Waisen in
Kauf — „die Bibliothek darf ein verwaistes **Signaturbild** tragen" —, und dieser ist ein anderer.
Nur gelesen, nicht gemessen: der Fall braucht einen ungültigen Rumpf, den kein Test schickt.
Vorschlag: das Bild vor dem ersten Graph-Aufruf dekodieren; die Prüfung kostet keine Zeile mehr,
nur eine andere Reihenfolge.

[anmeldung-R8] Klasse 7 · Lauf `deadline_passed_report` (07, „die Meldung ans Anmeldepostfach")
Der Kommentar sagt: „What is asked instead is the subject, which carries the child — one report per
child, not one per day". Die Abfrage filtert aber nur `purpose`, `recipient_email`,
`person_id IS NULL` und `sent_at >= deadline`; `outbound_emails` trägt **keine** Betreffspalte
(`app/models/querschnitt.py:584`). Die Marke sagt damit „irgendeine Fristmeldung ging seit diesem
Zeitpunkt". `release_decisions` gibt jeder Zusage eines Ziels **dasselbe** Fristende, sie
verstreichen also gemeinsam: Die erste Meldung des Ticks unterdrückt jede weitere desselben
Jahrgangs dauerhaft — das Sekretariat erfährt von einem Kind statt von zwanzig.
Nur gelesen, nicht gemessen: der vorhandene Test hat genau eine Bewerbung mit Frist.
Vorschlag: den Anker auf den Vorgang legen — eine `sync_tasks`-Zeile je Bewerbung statt einer Mail
ans Postfach.

[anmeldung-R9] Klasse 7 · `_already_sent` in `deadline_reminder`, `slot_reminder` und
`slot_missing_reminder`
Die Marke fragt „hat **diese Person** seit dem Zeitpunkt eine Mail dieser Sorte bekommen", nie „hat
**diese Bewerbung** ihre Erinnerung bekommen". Zwei Kinder einer Familie teilen sich Person, Zweck
und Zeitpunkt: Das zweite bekommt keine. Bei `deadline_reminder` ist der Zeitpunkt für den ganzen
Jahrgang identisch, bei `slot_reminder` reichen zwei Termine am selben Tag, bei
`slot_missing_reminder` zwei Ziele mit demselben frühesten Anmeldetag.
Nur gelesen, nicht gemessen: alle drei Testfälle haben je Familie ein Kind mit einem Vorgang.
Vorschlag: derselbe Anker wie R8.

[anmeldung-R10] Klasse 8 · `GET /applications/{application_id}` für den Elternpfad
Die Maske lautet `if user.is_guardian and application.released_at is None: running = "running"`,
und `ended_at` gibt die Route Eltern grundsätzlich nicht heraus. `POST …/withdrawal` setzt aber
weder `released_at` noch `decided_at`. Nach dem eigenen Rückzug — und nach dem des **anderen**
Sorgeberechtigten, was 07 Z4 mit „wer beendet, beendet für alle" ausdrücklich zulässt — meldet die
Bewerbungsansicht der Familie weiterhin `status_code: "running"` und `ended_at: null`. Der zweite
Sorgeberechtigte erfährt vom Ende nichts.
Gemessen: die Maske um `and application.ended_at is None` verengt, tests/test_anmeldung.py bleibt
grün (118 passed) — der Fall ist in keiner Richtung beobachtet.
Vorschlag: die Maske auf „entschieden, aber nicht freigegeben" beschränken und `ended_at`/
`status_code` einer beendeten Bewerbung auch nach außen zeigen.

[anmeldung-R11] Klasse 3 · Lauf `deadline_reminder`, Test
`test_the_deadline_reminder_spares_whoever_has_answered`
Die Regel, die der Testname behauptet, ist das `~exists(...)` über
`contract_responses.accepted_at`. Der Test schickt erst eine Erinnerung, lässt die Mutter dann
annehmen und prüft, dass der zweite Lauf schweigt — grün wird er aber schon durch `_already_sent`:
Die Marke des ersten Laufs unterdrückt die zweite Mail unabhängig von jeder Antwort.
Gemessen: das `~exists(...)` entfernt, tests/test_anmeldung.py bleibt grün (118 passed).
Vorschlag: die Annahme vor dem **ersten** Lauf setzen und prüfen, dass gar keine Mail geht.

[anmeldung-R12] Klasse 4 · acht Routen über `_reach_application`:
`GET/PUT /applications/{id}/admission-slot(s)`, `PATCH …/record`, `GET /applications/{id}`,
`PUT …/decision`, `PUT …/deadline`, `PUT …/waiting-confirmation`, `POST …/withdrawal`
Plan: „Schulleitung nur ihre eigene Schulart" an jeder dieser Zeilen. Die Bedingung steht im Code
(`_own_branch` in `_reach_application`) und kein Test fasst sie an: Die drei Tests mit
`as_role("school_management")` treffen `GET /admission-days/{id}/schedule`, `POST …/release`,
`GET /applications` und `POST /applications/decisions/release` — alle vier rufen `_own_branch`
selbst.
Gemessen: `await _own_branch(...)` aus `_reach_application` entfernt, tests/test_anmeldung.py
bleibt grün (118 passed).
Vorschlag: ein Test mit einer Schulleitung, die eine `employee_roles`-Zeile auf die andere
Schulart trägt, gegen `GET /applications/{id}` und `PUT …/decision`.

[anmeldung-R13] Klasse 5 · zwölf Routen mit beiden Türen:
`GET/PUT /applications/{id}/admission-slot(s)`, `GET /applications/{id}`,
`PUT …/waiting-confirmation`, `POST …/withdrawal`, `GET /contracts/{id}`,
`POST /children/{id}/sepa-mandates`, `GET …/sepa-mandates`, `POST …/photo-consent-invitation`,
`POST /care-contracts`, `POST /contracts/{id}/module-agreements`, `POST …/termination`
Weil beide Türen die Route erreichen, steht das Rollentor nicht als `Depends(require_role(...))`,
sondern als `require_staff(...)` im Rumpf — und kein Test gibt einer nicht genannten
Mitarbeiterrolle eine dieser Routen. Eine Lehrkraft bucht damit ungeprüft Anmeldetermine und liest
fremde Verträge, sobald das Tor je verrutscht.
Gemessen: alle zwölf `require_staff(...)` durch `pass` ersetzt, tests/test_anmeldung.py bleibt grün
(118 passed). Die vorhandenen Rollentests treffen `require_role`-Routen und `_acting_person`.
Vorschlag: je Route ein Test mit `as_role("teacher")` bzw. `as_role("day_care_staff")` auf 403.

[anmeldung-R14] Klasse 4 · `POST /contracts/{contract_id}/module-agreements` und
`POST /contracts/{contract_id}/termination`
Nur ein Hortvertrag trägt Module, und 09 Z6 kennt die Kündigung allein für ihn; kein Constraint
trägt das, beide Routen prüfen `contract.contract_type != "care"` selbst.
Gemessen: beide Prüfungen durch `pass` ersetzt, tests/test_anmeldung.py bleibt grün (118 passed) —
ein Elternteil hängt damit ungeprüft eine Modulanlage an den Schulvertrag und kündigt ihn.
Vorschlag: je ein Test, der beide Routen gegen einen Schulvertrag mit `400` beantwortet sieht.

[anmeldung-R15] Klasse 4 · fünf Zustandswächter ohne Test
`POST /admission-days/{id}/release` („That day is cancelled"),
`POST /admission-days/{id}/cancellation` („already cancelled"),
`POST /admission-days` („That raster produces no window at all"),
`POST /care-module-prices` und `POST /tuition-fees` („That amount is already announced").
Gemessen: alle fünf zusammen entfernt, tests/test_anmeldung.py bleibt grün (118 passed). Sie
wurden gemeinsam herausgenommen — grün heißt damit für jeden einzelnen, dass ihn kein Test hält.
Vorschlag: je eine Zeile im vorhandenen Nachbartest statt fünf neuer Testfälle.

[anmeldung-R16] Klasse 8 · `PATCH /care-module-prices/{id}` und `PATCH /tuition-fees/{id}`
`_announced_price`/`_announced_fee` prüfen den **alten** `valid_from`; danach schreibt
`model_dump(exclude_unset=True)` jedes Feld des Rumpfes, `valid_from` eingeschlossen. Ein
angekündigter Betrag lässt sich damit auf ein vergangenes Datum ziehen — er ist sofort in Kraft,
war nie angekündigt und ist ab da unveränderlich; „ein noch nicht gültiger Wert lässt sich ändern"
(hebel.md) wird so zu seinem Gegenteil. Ein ausdrückliches `{"valid_from": null}` läuft in die
NOT-NULL-Verletzung und antwortet 500, ein Status, den `gemeinsam.md` nicht kennt.
Nur gelesen, nicht gemessen.
Vorschlag: den neuen `valid_from` gegen `today()` prüfen und ihn im Rumpfmodell nicht nullable
machen.

[anmeldung-R17] Klasse 8 · `GET /care/application-context`
Die Route nimmt `families[0]` der sortierten Menge. `gemeinsam.md` sagt für den OTP-Pfad: „bei
Patchwork umfasst der Scope alle Familien der Person, und die Route prüft gegen diese Menge". Eine
sorgeberechtigte Person in zwei Familien sieht im Hortformular nur die Kinder der ersten und kann
für die zweite keinen Antrag stellen — sie füllt stattdessen das Formular „für eine Familie, die
wir nicht kennen" aus und legt ein zweites Kind an.
Nur gelesen, nicht gemessen.
Vorschlag: die Kinder aller Familien des Scopes ausliefern und `family_id` je Kind mitgeben.

## Angesehen, nicht als Fund gewertet

- **Klasse 2 durchgehend gehalten.** `TransactionRoute` und `transaction()` rollen bei jedem
  `raise` zurück, und zwei Tests zählen Zeilen statt Statuscodes
  (`test_an_application_writes_no_application`, `test_the_account_holder_is_a_person_of_this_family`).
  Gemessen: die `persons_of_family`-Prüfung in `add_sepa_mandate` entfernt — der Lauf wird rot, die
  Zustandszusicherung beißt also. Was diese Klasse hier trotzdem verletzt, steht als R5, R6 und R7
  und liegt außerhalb der Transaktion.
- **`clear_signature_images`** ist echt geprüft. Gemessen: die Funktion räumt nichts mehr, der Lauf
  wird rot — das `assert all(...)` über `_rows(Signature)` läuft nicht ins Leere.
- **Der Signaturlink.** Verbrauch, Ablauf, unbekanntes Token und die drei geschriebenen Zeilen sind
  belegt; die zweite Einladung, die die erste stehen lässt, ebenfalls.
- **Die Sofortzahlung.** Der sperrende Wiederholungscheck (`_same_child_applied` samt Advisory
  Lock), die zweite Zustellung als `known` und die Zahlung ohne Vorgang samt Aufgabe sind
  vollständig getestet; `POST /applications` legt nachweislich nichts an.
- **`PUT /contracts/{id}/end` prüft die Vertragsart nicht** — die Hortleitung trägt damit auch das
  Ende eines Schulvertrags ein. Der Plan nennt in derselben Zeile `day_care_management`,
  `executive_management` **und** `secretariat` und schreibt keine Einschränkung aus; die
  `[A!]`-Marke stellt beide Vertragsarten ausdrücklich auf dieselbe Route. Kein Fund.
- **`GET /application-unlocks` filtert nicht nach Schulart**, obwohl `school_management` sie liest.
  Die Plan-Zeile schreibt für diese Route keine Einschränkung aus, und eine Freischaltung trägt
  ihre Schulart im Rumpf. Kein Fund.
- **Der Upload vor der Zeile** an den drei Unterschriftsrouten ist der im Plan benannte und bezahlte
  Preis („die Bibliothek darf ein verwaistes Signaturbild tragen"). Nur R7 fällt nicht darunter.
- **`_named_id` legt Schule und Kindergarten ohne Sperre an**, zwei gleichzeitige Bewerbungen geben
  also eine Dublette. Der Plan nennt die Dublette als bezahlten Preis dieser Wahl.
