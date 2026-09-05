Stand: c4ef05a, Nullpunkt: 36 Tests grün

# Prüfbericht Routen — querschnitt

27 Sicherungen herausgenommen, 14 wurden rot, 13 blieben grün. Jede grüne steht unten als Fund.

**Zum Messverfahren, weil es vom Rezept abweicht:** Der Bau je Messung
(`--profile tools build test`) wurde zweimal vom Speicher-Wächter der Maschine abgeräumt — sechs
Prüf-Sessions fahren gleichzeitig je eine Postgres. Gemessen wurde stattdessen mit demselben
`test`-Image, aber dem Quellbaum als Bind-Mount über `/app/app` und `/app/tests`. Die Gegenprobe
dafür steht in beide Richtungen: Nach einer Mutation misst dieser Weg sie, während der
`podman-compose`-Lauf ohne Neubau noch die Quellen des letzten Baus zeigte (`M25` lag im Image,
`test_a_parent_reaches_no_foreign_child_and_no_childless_purpose` fiel dort und nicht hier). Vor
der ersten und nach der letzten Messung lief er über den unveränderten Baum mit 36 grün.

## Funde

[QS-R1] Klasse 1 · GET /children/{child_id}/consents, Weg der Mitarbeitenden
Plan: „Schulleitung nur die eigene Schulform, Hortleitung nur die betreuten Kinder". Die Bedingung steht als `reach_child` im Code, kein Test hält sie: `test_the_consent_set_is_closed_to_a_foreign_family` rät die fremde Id nur über die Mutter, jeder Mitarbeitenden-Test bleibt beim eigenen Kind und trägt `secretariat`, das ohnehin unbeschränkt sieht.
Gemessen: `reach_child` durch `load_child` ersetzt, 36 Tests bleiben grün.
Vorschlag: ein Test mit `school_management` ohne passenden Zweig auf `world.other_child`, dazu einer mit `day_care_management` ohne Betreuungsvertrag.

[QS-R2] Klasse 1 · GET /children/{child_id}/documents, beide Türen
Plan: „Eltern sehen ihre offenen Unterlagen und nichts weiter; Schulleitung nur die eigene Schulform". Weder der Ownership-Check der einen noch der der anderen Tür wird von einem Test gehalten — es gibt keinen Aufruf dieser Liste mit fremdem Kind, in keiner der beiden Rollen.
Gemessen: zweimal einzeln. `reach_child` im Mitarbeitenden-Zweig durch `load_child` ersetzt → grün. `reach_family` im Elternzweig gestrichen → grün.
Vorschlag: je ein Test — die Mutter auf `world.other_child`, eine Schulleitung ohne passenden Zweig auf dasselbe Kind.

[QS-R3] Klasse 1 · GET /documents/{document_id}/content, Weg der Mitarbeitenden
Plan: „wer die Zeile daneben sehen darf". `test_the_file_is_no_wider_than_the_row_beside_it` weist eine falsche **Rolle** ab (`teacher` → 403) und sagt damit über die fremde Id nichts.
Gemessen: `reach_child` durch `load_child` ersetzt, 36 Tests bleiben grün.
Vorschlag: den vorhandenen Test um eine zweite Hälfte ergänzen — `day_care_management` auf die Unterlage eines nicht betreuten Kindes.

[QS-R4] Klasse 1 · PUT /documents/{document_id}
Der Ownership-Check der Ablageroute hängt an nichts: alle Tests dieser Route laufen als `secretariat`, das jedes Kind sieht.
Gemessen: `reach_child` durch `load_child` ersetzt, 36 Tests bleiben grün.
Vorschlag: ein Test, in dem eine Schulleitung die Unterlage eines Kindes der anderen Schulart ablegen will und 404 bekommt.

[QS-R5] Klasse 1 · DELETE /documents/{document_id}
Dasselbe an der Rücknahme: `test_a_bare_request_is_withdrawn_and_nothing_else_is` prüft den Zustand der Zeile, nie die Zugehörigkeit des Kindes.
Gemessen: `reach_child` durch `load_child` ersetzt, 36 Tests bleiben grün.
Vorschlag: ein Test mit `school_management` auf einer fremden Zeile.

[QS-R6] Klasse 1 · POST /children/{child_id}/documents
Die Anforderung prüft das Kind über `reach_child`, und kein Test ruft sie mit einem Kind, das der Rolle nicht gehört.
Gemessen: `reach_child` durch `load_child` ersetzt, 36 Tests bleiben grün.
Vorschlag: ein Test, in dem `school_management` für ein Kind der anderen Schulart anfordert.

[QS-R7] Klasse 1 · PUT und DELETE /children/{child_id}/consents/{purpose}, Weg des Sekretariats
Plan: „eigene Familie". `_answering` nimmt die `person_id` aus Rumpf bzw. Query ungeprüft, und `fk_consents_person` bindet allein an `persons` — das Sekretariat legt damit die Zustimmung einer beliebigen Person zu einem beliebigen Kind an oder widerruft sie. Für `GET …/photo-consent` bleibt sie folgenlos (`expected` zählt nur die `family_guardians` des Kindes), im Zustimmungssatz und im späteren Nachweis steht sie trotzdem.
Gemessen: nicht gemessen — es ist keine Bedingung da, die sich herausnehmen ließe.
Vorschlag: die `person_id` gegen `persons_of_family(session, child.family_id)` prüfen, dazu ein Test mit fremder Person am eigenen Kind.

[QS-R8] Klasse 1 · GET /documents/{document_id}/content, OTP-Pfad
Die Elternsicht auf die Datei ist weiter als die auf die Zeile: `GET /children/{child_id}/documents` filtert ihnen alles außer `missing` weg, `content` liefert jede abgelegte Unterlage des eigenen Kindes aus. Der Sonderzweig `_document_state(row) != "missing" and row.graph_item_id is None` fängt das nicht — eine Zeile ohne `graph_item_id` ist entweder `missing` (erste Hälfte falsch) oder `not_required`, und die fällt zwei Zeilen später ohnehin auf „This paper is not filed". Der Zweig ist tot.
Gemessen: zweimal grün. Den Zweig auf `if False` gesetzt → 36 grün (er trägt nichts). Den Elternfilter der Liste durch `rows = []` ersetzt → 36 grün (auch der Filter ist ungeprüft: `test_the_three_states_and_what_the_parents_see` sichert nur zu, dass die Liste leer *ist*).
Vorschlag: für den OTP-Pfad `_document_state(row) != "missing"` allein abweisen; dazu zwei Tests — die Mutter bekommt ihre offene Unterlage in der Liste zu sehen und die abgelegte Datei nicht.

[QS-R9] Klasse 4 · PATCH und DELETE /contract-texts/{contract_text_id}
Plan: „nur solange `valid_from` in der Zukunft liegt", und weil `now()` in keinem CHECK zulässig ist, trägt die Regel allein die Route. Sie hat keinen Test: `test_only_the_executive_management_writes_a_contract_text` arbeitet durchweg mit `2091-08-01`, `test_the_parents_read_the_text_they_sign` legt eine geltende Fassung an und ändert sie nie.
Gemessen: zweimal grün. Die Sperre in `_announced_text` auf `if False` → 36 grün. Die Zukunftsprüfung des neuen `valid_from` in `update_contract_text` auf `if False` → 36 grün.
Vorschlag: die Gegenprobe der Werte spiegeln — eine Fassung mit vergangenem `valid_from` anlegen, dann `PATCH` und `DELETE` darauf, beide 400.

[QS-R10] Klasse 4 · PATCH /configured-values/{configured_value_id}
Die Sperre in `_announced_value` hat ihren Test (`test_an_announced_value_can_be_changed_and_a_valid_one_cannot`), die zweite Hälfte der Regel nicht: dass ein angekündigter Wert nicht auf einen vergangenen Tag umgesetzt werden darf.
Gemessen: die Zukunftsprüfung des neuen `valid_from` auf `if False`, 36 Tests bleiben grün.
Vorschlag: eine Zeile im vorhandenen Test — `PATCH` mit `valid_from` in der Vergangenheit auf den angekündigten Wert, 400.

[QS-R11] Klasse 4 · GET /children/{child_id}/photo-consent
„Ab 14 zählt das Kind mit" (`consent_purposes.self_consent_age`) trägt kein Constraint und hat keinen Test: beide Kinder der Testwelt sind 2016 geboren, der Zweig wird nie wahr.
Gemessen: `if self_consent_age is not None and _age(...) >= self_consent_age` in `app/services/querschnitt.py` auf `if False`, 36 Tests bleiben grün.
Vorschlag: ein drittes Kind mit Geburtsdatum vor 15 Jahren, dessen Antwort trotz beider Elternteile Nein bleibt, bis es selbst erteilt.

[QS-R12] Klasse 2 · POST /contract-texts
`fk_contract_texts_kind` bindet `contract_texts.code` an `contract_text_kinds.code`. Ein unbekannter Code läuft damit in denselben `except IntegrityError` wie ein zweiter Eintrag am selben Tag und bekommt `409 "This code already carries a version for that day"` — eine Antwort, die auf etwas anderes zeigt als den Fehler. `POST /configured-values` prüft seinen Code daneben ausdrücklich vorher und antwortet 400.
Gemessen: nicht gemessen, aus Constraint und `except` gelesen — kein Test schickt einen unbekannten Code.
Vorschlag: den Code vor dem Flush gegen `contract_text_kinds` prüfen und mit 400 abweisen, dazu ein Test mit erfundenem Code.

[QS-R13] Klasse 4 · DELETE /persons/{person_id}/consents/{purpose}
Plan: „die Route übersetzt seinen Fehler in eine Meldung, statt die Regel ein zweites Mal zu führen" — gemeint ist `trg_consents_family_floor`. Die Route fängt nichts; der `RAISE EXCEPTION` käme als abgebrochene Transaktion beim Aufrufer an. Heute nicht auslösbar: keine Migration füllt `mail_categories`, und alle fünf `consent_purposes` sind ohne `mail_category_id` geseedet — der Trigger fällt in sein erstes `RETURN NULL`. Mit dem Anfangsbestand aus TASK-246 AC#1 wird daraus eine 500.
Gemessen: nicht gemessen — die Regel ist ohne die Werteliste nicht scharf zu stellen.
Vorschlag: bei TASK-246 AC#4 bleiben; der Punkt steht hier, damit der nächste Bau die leere Werteliste nicht für die Abwesenheit der Regel hält.

[QS-R14] Klasse 8 · zwei geplante Routen fehlen
`PATCH /photo-consent-records/{photo_consent_record_id}` und `GET /photo-consent-records` stehen im Plan unter Q1; Tabelle, Modell und Rechte stehen (`20260822_1323`), Routen gibt es keine. TASK-246 nennt die Tabelle (AC#3), nicht die beiden Routen — sie fallen zwischen Plan und Ticket.
Gemessen: nicht gemessen, gelesen.
Vorschlag: die beiden Routen als eigenes Abnahmekriterium an TASK-246 hängen.

[QS-R15] Klasse 8 · POST /contract-texts und PATCH /contract-texts/{id}
Plan: „die Word-Datei aus der Arbeitsfassung holen, `body` daraus auslesen, Prüfsumme rechnen … sie sagt zugleich, ob die Fassung eine wesentliche Änderung ist (`requires_consent`)". Die Route nimmt `body` als Text entgegen und lässt `template_docx`, `template_checksum`, `frozen_at` und `requires_consent` unberührt; `ck_contract_texts_frozen` ist mit `num_nonnulls(...) = 0` erfüllt, also fällt es nirgends auf. TASK-228 und TASK-263 stehen beide auf `To Do`.
Gemessen: nicht gemessen, Plan gegen Router gelesen.
Vorschlag: nichts hier — der Punkt hängt an TASK-228 und steht im Bericht, damit der nächste Bau ihn nicht für erledigt hält.

[QS-R16] Klasse 8 · der zweite Lauf des Plans ist nicht gebaut
Der Plan zählt zwei Läufe; `app/runs.py` führt nur `weekly_task_mail`. Der Lauf, der die unzustellbaren Mails einsammelt (`system:bounces`), fehlt — `app/services/mail.py` setzt `undeliverable_at` allein dort, wo Graph die Annahme verweigert. `container.md` trägt den Vorbehalt dazu ausdrücklich („Der Rückläufer aus dem Postfach wird noch nicht gelesen"), der Plan nicht.
Gemessen: nicht gemessen, `app/runs.py` und die Schreiber von `undeliverable_at` gelesen.
Vorschlag: den Vorbehalt aus `container.md` in die Lauf-Tabelle des Plans übernehmen, damit ihn der nächste Prüflauf nicht wieder als Lücke zählt.

[QS-R17] Klasse 8 · das Räum-Rezept in `prompts/api-pruefen.md` zerstört eine Werteliste
Das dort ausgeschriebene `TRUNCATE … sharepoint_libraries … CASCADE` nimmt `contract_text_kinds` mit (`fk_contract_text_kinds_working_library`), und deren vierzehn Zeilen legt keine Migration zurück. Der nächste Lauf scheitert dann an `fk_contract_texts_kind` statt an der Mutation — genau die Sorte falscher Fund, gegen die der Absatz geschrieben ist. Sechs Tabellen zeigen auf `sharepoint_libraries`, eine davon ist eine Werteliste.
Gemessen: dreizehn Messungen dieses Laufs mussten deswegen verworfen und wiederholt werden; die Datenbank war danach nur über `down -v` samt Migration wiederherzustellen.
Vorschlag: im Rezept `sharepoint_libraries` nicht truncaten, sondern die Zeile des Fixtures löschen — `DELETE FROM sharepoint_libraries WHERE code = 'app_documents'`.

## Angesehen, nicht als Fund gewertet

- `GET /children/{child_id}/photo-consent` prüft kein Ownership — der Plan schreibt „unbeschränkt", und `test_the_photo_answer_names_seven_readers_and_no_eighth` hält den Leserkreis gegen die volle Rollenliste.
- `GET /children/{child_id}/documents` nennt `teacher` nicht, obwohl der Plan ihn kennt: „soweit freigeschaltet", und `child_file_categories.is_teacher_readable` steht für die einzige geseedete Kategorie auf `false` — „dann antwortet die Route ihr wie einem Unberechtigten" ist genau das gebaute Verhalten.
- `GET /change-log` gibt dem Sekretariat auch die Spur von `health_trait_values` und `sepa_mandates`. Die Schreibschicht maskiert die engen Spalten mit `<protected>`, und der Plan sagt „das Sekretariat sieht sie überall" — ob das über Domänengrenzen trägt, gehört in den Gesamtlauf. Die Rollenprüfung selbst ist gemessen: auf `True` gesetzt wird `test_the_trace_needs_a_subject_and_follows_the_right_to_see_the_row` rot.
- `request_document` legt über `child_folder` einen Graph-Ordner an, bevor die Transaktion steht. Ein Rollback lässt ihn stehen, aber `files.folder()` findet vor dem Anlegen — der zweite Aufruf legt keinen zweiten an.
- `weekly_task_mail` hält seine Marke in `outbound_emails` statt in einer eigenen Spalte; zweimal hintereinander gerufen schickt er einmal.
- `_answer`, `close_task` und `create_configured_value` weisen vor jedem `session.add` und jedem Attributschreiben ab — der 400 dieser drei Wege lässt keine halbe Zeile zurück; die drei Prüfungen sind einzeln gemessen und alle rot.
- `sync_tasks.confirmed_end_date` trägt laut Plan „allein ein Vertragspunkt". Kein Constraint hält das und die Route setzt sie an jedem Ziel — heute löst nichts einen solchen Punkt aus, und der Router schreibt genau das aus.
