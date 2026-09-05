# Routen-Prüflauf: auth

Stand: c4ef05a, Nullpunkt: 26 Tests grün

Kein `api/auth-api.md` — der Auftrag der sechs Routen steht in
[`api/stammdaten-api.md`](../api/stammdaten-api.md), Abschnitt „Zugang und Sitzung", dazu
`zugang.md`, `soll-prozesse/00-zugang-und-portal.md` und `hebel.md` („Zugang und
Anmeldecode"). Geprüft wurden `app/routers/auth.py`, `app/core/security.py`,
`app/core/otp.py`, `app/core/throttle.py`, `app/services/retention.py`, `tests/test_auth.py`
und `tests/test_security.py`.

Alle sechs geplanten Routen stehen mit Methode, Pfad und Aktor wie im Plan.

## Funde

[AUTH-R1] Klasse 1 · PUT /auth/identity, `app/routers/auth.py:311`
Plan: „nur ein Kandidat dieser Adresse". Der einzige Test dazu,
`test_identity_may_only_be_one_of_the_candidates`, schickt eine frische `uuid.uuid4()` —
eine Person, die es gar nicht gibt. Was den Fall hält, ist `fk_login_sessions_person`,
nicht die Regel.
Gemessen, zweimal: Bedingung `body.person_id not in user.candidates` ganz entfernt →
`tests/test_auth.py` rot, aber mit `sqlalchemy.exc.IntegrityError` statt `assert 200 == 403`.
Dieselbe Bedingung durch „irgendein Sorgeberechtigter existiert" ersetzt, so dass ein
**fremder, real angelegter** Sorgeberechtigter durchgeht → **26 Tests grün**. Die Sitzung
läuft dann unter einer fremden Person, und `change_log` trägt deren `guardian:`-Aktor.
Vorschlag: dem Test eine zweite, real angelegte Person mit eigener `family_guardians`-Zeile
und anderer Adresse mitgeben und gegen deren `person_id` die 403 zeigen.

[AUTH-R2] Klasse 5 · `login_codes`, Migration `20260822_1314_1ad9bc948973`, Zeile 1096–1099
Keine Route ändert `email`, `code_hash` oder `purpose` einer bestehenden Zeile; der Grant
lautet trotzdem `GRANT UPDATE (email, code_hash, purpose, consumed_at, failed_attempts)`.
`login_sessions` daneben schreibt die Enge aus („neither the hash nor the mailbox may move
after the row exists") und grantet nur `person_id, revoked_at`. Wer den Hash überschreiben
kann, setzt seinen eigenen Code auf eine fremde Anmeldung.
Gelesen, nicht gemessen: `tests/test_privileges.py` prüft an `login_codes` nur den
Änderungsanker, keine Spaltenliste — der Grant hat keine Gegenprobe.
Vorschlag: auf `(consumed_at, failed_attempts)` einengen, samt einer Zeile in
`test_privileges.py`, die `code_hash` und `email` namentlich ausschließt.

[AUTH-R3] Klasse 8 · `app/services/mail.py:56` und `app/routers/auth.py:145-148`
`zugang.md` schreibt aus, die Code-Mail trage „den Code zum Abtippen **und** als Klick-Link,
der die Sitzung direkt eröffnet". `_CODE_BODY` ist `"Ihr Anmeldecode: {code}\n\nEr gilt 15
Minuten."` — kein Link, und `wb-elternportal` kennt nur den `?email=`-Link, der nichts
freischaltet. Block 00 („Mails und Schreiben") und `hebel.md` nennen den Klick-Link **nicht**:
nach der Rangfolge weicht der Plan vom Block ab, nicht der Bau vom Plan — und das wiegt
schwerer, weil es sich beim nächsten Bau fortpflanzt.
Der Preis steht im Code: `_set_session_cookie` begründet `samesite="lax"` statt `strict`
allein mit diesem Link. Ohne ihn trägt die Begründung nicht, und `Strict` wäre frei.
Gelesen, nicht gemessen: kein Backlog-Ticket zum Klick-Link.
Vorschlag: den Satz in `zugang.md` streichen und `samesite` auf `strict` prüfen — oder den
Link in Block 00 aufnehmen und dann bauen.

[AUTH-R4] Klasse 4 · `app/core/security.py`, `_decode`
`hebel.md` („Zugang und Anmeldecode"): „Eltern bleiben 30 Tage angemeldet, **Mitarbeitende
acht Stunden**. Alle Zahlen sind fest und nirgends einstellbar." Die dreißig Tage stehen als
`otp.SESSION_TTL` und tragen `live_session`; die acht Stunden gibt es im Code nicht. `_decode`
prüft `exp` und sonst nichts — die Lebensdauer der Personal-Sitzung ist damit eine
Tenant-Einstellung, also genau das Gegenteil von „nirgends einstellbar". `zugang.md` löst es
mit „die Lebensdauer folgt dem Anbieter-Standard" auf; der Block schlägt den Plan.
Gelesen, nicht gemessen: keine Regel im Code, die eine Messung tragen könnte.
Vorschlag: entweder `hebel.md` auf „folgt dem Tenant" ändern, oder eine eigene Obergrenze
gegen `iat` prüfen und sie testen.

[AUTH-R5] Klasse 8 · das Aufräum-TRUNCATE in `prompts/api-pruefen.md` selbst
Das vorgegebene Aufräumen nennt `sharepoint_libraries`. `contract_text_kinds` trägt einen
Fremdschlüssel **auf** diese Tabelle, also nimmt `TRUNCATE … CASCADE` die Werteliste mit —
und die füllt nur die Migration `ebf1b8885558`.
Gemessen: nach dem Aufräumen scheitert `tests/test_anmeldung.py` mit `insert or update on
table "contract_texts" violates foreign key constraint "fk_contract_texts_kind" — Key
(code)=(school_contract_GS) is not present in table "contract_text_kinds"`. Fünf Messungen
dieses Laufs waren dadurch wertlos und wurden nach `down -v` und neuer Migration wiederholt.
Vorschlag: `sharepoint_libraries` aus der Zeile nehmen und, wo `uq_sharepoint_libraries_code`
wirklich stört, gezielt `DELETE FROM sharepoint_libraries WHERE code = …` nutzen.

[AUTH-R6] Klasse 8 · `app/routers/ferien.py:154` `optional_user` (fremde Domäne)
`get_current_user` antwortet 503, wenn Entra-ID nicht erreichbar ist — „the caller's token
may be fine". `optional_user` fängt `except HTTPException` und macht daraus `None`: aus dem
Ausfall des Identitätsanbieters wird „nicht angemeldet", und ein Mitarbeitender sieht still
die öffentliche Ansicht.
Gelesen, nicht gemessen: hier nur genannt, weil es der auth-Hebel ist, den sie umgeht.
Vorschlag: nur 401/403 zu `None` machen und die 503 durchreichen.

[AUTH-R7] Klasse 8 · `app/routers/auth.py:71-83` `FamilyOut.label`
Plan: `GET /auth/session` und `POST /auth/sessions` geben „Kandidaten, aktuelle Person,
erreichbare Familien". Die Antwort trägt zusätzlich je Familie ein `label` aus den Vor- und
Nachnamen **aller Kinder** dieser Familie. Der Docstring begründet es (Patchwork braucht
etwas Wiedererkennbares), der Plan nennt es nicht.
Gelesen, nicht gemessen: kein Zugriffsproblem — der Empfänger erreicht die Familie ohnehin,
`blocked` fällt vorher aus `scope.families`.
Vorschlag: die Spalte „Worauf eingeschränkt" der beiden Zeilen um das Label ergänzen.

[AUTH-R8] Klasse 8 · `wb-elternportal/src/Login.tsx:78` (fremdes Repo, keine Route)
Block 00 Z1: die Antwort des Feldes nennt „der Code sei unterwegs, dazu **die
Absenderadresse** und den Hinweis, im Spam-Ordner nachzusehen". Der Spam-Hinweis steht, die
Absenderadresse fehlt.
Gelesen, nicht gemessen.
Vorschlag: die Absenderadresse in den Hinweis aufnehmen; sie steht als `mail_sender` schon in
`app/core/config.py`.

## Angesehen, nicht als Fund gewertet

- **Der Aktor des Identitätswechsels.** `PUT /auth/identity` fährt `transaction(f"guardian:{body.person_id}")`, also unter der *neuen* Identität. Trägt: wer das Postfach hält, ist per `zugang.md` beide Personen zugleich.
- **`login_sessions.person_id` im UPDATE-Grant.** Ein Änderungsanker mit Schreibrecht — aber die namentlich gelistete Ausnahme (`tests/test_privileges.py:306 ANCHOR_MOVES`), und die Route dahinter ist genau die geplante.
- **Die Mail geht nach dem Commit raus.** `request_code` verlässt `transaction()`, bevor `background.add_task` läuft; ein gescheiterter Commit wirft, bevor die Mail eingereiht ist. Umgekehrt kann ein Code ohne Mail stehenbleiben — das ist der ausgeschriebene Fall samt `/fail`-Ping.
- **`send_login_code` schreibt keine `outbound_emails`-Zeile.** Die eine namentliche Ausnahme, `tests/test_mail.py::test_only_the_mail_module_sends` hält den dritten Weg zu.
- **Der Löschlauf.** `purge_expired_logins` ist über beide Fristen und beide Richtungen geprüft (`tests/test_runs.py::test_the_delete_run_holds_both_periods`), samt der jungen Zeile, die stehenbleibt. Eine Marke braucht er nicht, und ein DELETE ist von selbst wiederholbar.
- **Eine widerrufene Sitzung bleibt bis zu 30 Tage stehen.** Der Block sagt nur „30 Tage angemeldet", keine kürzere Frist fürs Abmelden.
- **`GET /auth/roles` antwortet einem Konto ohne Rolle mit `200` und `[]`.** Der Plan sagt „jede Mitarbeiterrolle"; die leere Liste ist die Antwort, aus der die Oberfläche Block 00 Z3 baut („kommt nicht hinein und bekommt den Hinweis").
- **Kein zweiter Auflösungsweg.** Außer `scope_for` joint nichts in `app/routers` und `app/services` `family_guardians`, um Zugriff zu entscheiden; die vier weiteren Joins bestimmen Mailempfänger oder prüfen Existenz.
- **Cookie-Vorrang in `get_current_user`.** Ein Cookie schlägt einen gültigen Bearer. Die beiden Türen liegen auf verschiedenen Hostnamen, und `__Host-` bindet das Cookie an genau einen — der Fall entsteht nur lokal.
- **`_no_role_reports` wird nie gesweept**, anders als `throttle._hits`. Es wächst nur mit gültigen Tenant-Tokens, also innerhalb der Vertrauensgrenze.
- **Das Anmeldefeld antwortet mit `{"status": "sent"}`.** Absenderadresse und Spam-Hinweis baut die Oberfläche; das ist keine Sache der Route (der fehlende Teil davon steht als AUTH-R4).
- **`_staff` rechnet das Rollenende gegen `_now().date()`, also UTC.** Zwischen Mitternacht und 02:00 lokaler Zeit trägt ein ausgeschiedener Mitarbeitender seine Rollen noch. Sein Tenant-Token lebt ohnehin länger als der Stichtag, und das Konto sperrt der Admin (13) — die zwei Stunden fügen dem nichts hinzu.
- **Zehn Sicherungen des Login-Pfads herausgenommen, alle rot**, jede an dem Test, dessen Name sie behauptet: einmal einlösbar (`consumed_at`), fünf Fehleingaben, fünfzehn Minuten, `revoked_at`, dreißig Tage, und alle vier Grenzen einzeln — je Adresse, je Absender, das Unbekannten-Budget und das Gesamtbudget. Die vier Grenzen tragen kein Constraint und sind trotzdem einzeln geprüft.
- **Die Einsichtsstufe ist geprüft, entgegen der Vermutung beim Lesen.** `scope_for` ist die einzige Stelle, die sie auswertet, und `tests/test_auth.py` fasst sie nicht an — aber `tests/test_stammdaten.py` tut es durch die Auflösung hindurch. `writable` auf „alles außer gesperrt" gestellt → `test_read_only_sees_the_family_and_changes_nothing` rot; `blocked` nicht mehr herausgefiltert → `test_a_blocked_guardian_reaches_no_family` rot.
- **`reach_family` hält in beide Richtungen.** Ownership-Zweig entfernt → `test_anmeldung.py::test_a_parent_cannot_apply_on_a_foreign_family` rot (`assert 403 == 404`); die Schreibsperre entfernt → `test_cleaning.py::test_a_read_only_guardian_reserves_nothing` rot (`assert 201 == 403`).
