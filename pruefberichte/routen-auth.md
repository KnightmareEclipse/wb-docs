# Prüfbericht: Routen des Zugangs

Sechs Routen in `app/routers/auth.py`, 12 Tests in `tests/test_auth.py`. **Nullpunkt grün**
(12 passed). Eine eigene `api/auth-api.md` gibt es nicht; der Auftrag sind
[`zugang.md`](../zugang.md), Block [`00-zugang-und-portal.md`](../soll-prozesse/00-zugang-und-portal.md)
und [`hebel.md#zugang-und-anmeldecode`](../soll-prozesse/hebel.md). Mitgeprüft wurden
`app/core/otp.py`, `app/core/throttle.py` und die beiden Auflösungen in `app/core/security.py`:
Sie tragen die Regeln dieser Routen und liegen nur in anderen Dateien.

## Funde

```
[AUTH-R1] Klasse 8 · die Anmeldung eines Schulkontos ohne Rolle
Block 00 Z3: „Meldet sich jemand mit einem gültigen Schulkonto ohne Rolle an ..., geht darüber eine
  Mail an die Admins. Wessen letzter Arbeitstag dagegen abgelaufen ist, ist kein Neuzugang: Er
  bekommt denselben Hinweis, die Admins aber keine Mail." Die Ablaufzeile schließt mit „dass ein
  fehlender Zugang gemeldet ist, statt still zu scheitern".
  Im Code passiert genau das stille Scheitern: app/core/security.py:320 wirft 403 „No employee
  record for this account", Zeile 325 gibt für den abgelaufenen letzten Arbeitstag eine
  rollenlose CurrentUser zurück — beide ohne Mail und ohne Aufgabe. `app/services/mail.py` kennt
  keinen `purpose` dafür, `sync_targets` kein Ziel, `app/runs.py` keinen Lauf.
Nicht gemessen, gelesen: es gibt nichts, dessen Sicherung man herausnehmen könnte.
Vorschlag: in `_staff()` beim fehlenden employees-Eintrag eine Mail über `send_tracked()` an die
  Admin-Rolle, mit der Unterscheidung, die der Block zieht — kein Versand, wenn nur der letzte
  Arbeitstag abgelaufen ist.
```

```
[AUTH-R2] Klasse 4 · POST /auth/sessions
hebel.md: „Er gilt 15 Minuten und nur einmal, verfällt nach fünf Fehleingaben." Zwei der drei
  Zusagen tragen kein Constraint, sondern je eine `where`-Zeile in `_redeem`.
Gemessen, beide einzeln: `LoginCode.failed_attempts < otp.MAX_FAILED_ATTEMPTS` entfernt →
  tests/test_auth.py bleibt grün (12 passed). `LoginCode.created_at > _now() - otp.CODE_TTL`
  entfernt → ebenfalls grün. Ohne die beiden ist ein sechsstelliger Code unbegrenzt oft und
  unbegrenzt lange probierbar; nur „einmal" (`consumed_at`) ist geprüft.
Vorschlag: ein Test, der fünf falsche Codes schickt und danach den richtigen abgewiesen bekommt,
  und einer, der `created_at` um 16 Minuten zurückdatiert.
```

```
[AUTH-R3] Klasse 4 · app/core/security.py, _guardian()
Der Kommentar dort: „The identity is re-checked, not trusted: the mailbox may have moved to another
  person since the session was opened." Die Zeile `row.person_id if row.person_id in candidates
  else None` ist die ganze Prüfung.
Gemessen: auf `row.person_id` verkürzt, tests/test_auth.py bleibt grün (12 passed). Danach handelt
  eine alte Sitzung weiter als eine Person, zu der ihr Postfach nicht mehr auflöst — die Reichweite
  bleibt zwar die des Postfachs, aber `change_log` trägt den falschen Menschen, und genau dafür ist
  die Spur da.
Vorschlag: ein Test, der `persons.email` nach dem Öffnen der Sitzung umhängt und `acting_as: null`
  verlangt.
```

```
[AUTH-R4] Klasse 4 · POST /auth/codes
zugang.md, „Vier Grenzen, und jede fängt etwas anderes": je Adresse fünf, je Absender zwanzig, für
  Unbekannte zehn, insgesamt sechzig. Zwei davon hält kein Test.
Gemessen: das Gesamtbudget (`MAX_CODES_PER_HOUR_TOTAL`) entfernt → grün (12 passed); die
  Absendergrenze (`not ip_ok`) entfernt → grün. Die Datei prüft nur die Adressgrenze und das
  Unbekannten-Budget. zugang.md nennt die Begrenzung „Teil des Flusses, nicht eine spätere
  Härtung" — das gilt für alle vier.
Vorschlag: je ein Test wie test_the_budget_for_unknown_addresses_stops_the_flood, einer über
  bekannte Adressen bis 60, einer mit gepatchtem _IP_LIMIT.
```

```
[AUTH-R5] Klasse 5 · GET /auth/session und GET /auth/roles
Block 00 Z2: „nie beides gleichzeitig, der Weg entscheidet, welcher Hut aufliegt." Beide Routen
  weisen die jeweils andere Tür mit 403 ab, und beide 403 hält kein Test.
Gemessen, beide einzeln entfernt → tests/test_auth.py bleibt grün (12 passed). `GET /auth/roles`
  hat überhaupt keinen Test: weder die Antwort für ein Schulkonto noch die Abweisung des
  Elternteils.
Vorschlag: je ein Test über die falsche Tür, dazu einer, der die Rollenliste eines Schulkontos
  liest.
```

```
[AUTH-R6] Klasse 4 · die Sitzungsdauer und das Cookie
hebel.md: „Eltern bleiben 30 Tage angemeldet." zugang.md nennt `HttpOnly` „den Kern" des
  Cookie-Entwurfs — „zwei Minuten fremder Missbrauch gegen ein Monat von einem fremden Rechner".
Gemessen: `LoginSession.created_at > _now() - otp.SESSION_TTL` aus `live_session()` entfernt →
  grün (12 passed); `httponly=True` auf `False` gesetzt → grün. Eine Sitzung ohne Ablauf und ein
  auslesbares Cookie fallen beide nicht auf.
Vorschlag: eine Sitzung mit zurückdatiertem `created_at` gegen 401 prüfen und die
  `set-cookie`-Kopfzeile der Anmeldung auf `HttpOnly`, `Secure` und `SameSite=Lax` zusichern.
```

```
[AUTH-R7] Klasse 4 · app/core/otp.py, keyed_hash()
Der Docstring: „Keyed, so a database copy alone is worth nothing." Der Schlüssel liegt in einer
  gemounteten Secret-Datei, der Digest in der Tabelle — beides zusammen braucht ein Angreifer.
Gemessen: durch ein schlüsselloses `hashlib.sha256` ersetzt → tests/test_auth.py bleibt grün
  (12 passed), weil jeder Test nur den Hin- und Rückweg derselben Funktion fährt. Ein
  sechsstelliger Code fällt gegen einen ungeschlüsselten Digest sofort.
Vorschlag: einen bekannten Wert gegen einen fest hinterlegten Erwartungswert prüfen, oder
  zusichern, dass `keyed_hash` sich mit einem anderen Schlüssel ändert.
```

## Angesehen, nicht als Fund gewertet

- **Das Anmeldefeld als Orakel.** Für eine unbekannte Adresse eine eigene Antwort eingebaut → rot
  (`test_code_answer_is_the_same_for_known_and_unknown`). Die Antwort ist auch bei erschöpftem
  Budget dieselbe, und die Mail geht als Hintergrundaufgabe raus, damit die Laufzeit das Orakel
  nicht wieder aufmacht.
- **Klasse 2 an der einen Stelle, an der sie hier hängt.** `POST /auth/sessions` schreibt vor
  seiner Absage — der Fehlversuchszähler —, und das ist Absicht: die Absage steht deshalb
  *außerhalb* der Transaktion. Der vorhandene Test zählt danach die Zeile
  (`row.failed_attempts == 1`) und nicht nur den Status; das Hochzählen entfernt → rot. Genau die
  Form, die die Prüfliste verlangt.
- **Einmaligkeit des Codes**, `consumed_at`-Filter entfernt → rot. **Abmelden**, `revoked_at` nicht
  gesetzt → rot; und derselbe Filter in `live_session()` entfernt → ebenfalls rot.
- **Die Adressgrenze und das Unbekannten-Budget** je entfernt → rot.
- **Die fremde Id an `PUT /auth/identity`.** Der Kandidaten-Check entfernt → rot; der vorhandene
  Test rät eine fremde `person_id` und ist damit der Test, der zählt.
- **Die Notbremse.** `>=` auf `>` verschoben → rot (`test_the_general_limit_answers_429`).
- **Klasse 1 hat in dieser Domäne keine zweite Form.** Keine Route trägt eine `family_id` oder eine
  Datensatz-Id im Pfad; die einzige Ownership-Frage ist der Kandidaten-Check oben, und der ist rot
  geworden.
- **Klasse 6 und 7 entfallen.** Die Code-Mail läuft als Hintergrundaufgabe hinter der committeten
  Transaktion, keine Route schreibt zwei Tabellen, und die Domäne hat keinen Lauf — der
  Lösch-Lauf über `login_codes`/`login_sessions` gehört zur Aufbewahrung
  (`app/services/retention.py`) und nicht hierher.
- **Ein älterer Code bleibt einlösbar, wenn der neuere seine fünf Fehlversuche verbraucht hat.**
  `_redeem` nimmt den jüngsten Code, der *noch* einlösbar ist. Das ist keine Abweichung: hebel.md
  sagt „gesperrt wird nie ein Zugang, immer nur der einzelne Code", und die Adressgrenze deckelt
  die Summe bei fünf Codes je Stunde.
- **Das Gesamtbudget von sechzig sperrt im Ernstfall die ganze Schule aus.** In `zugang.md`
  ausgeschrieben und abgewogen („weisen ab, statt zu stauen") — eine Entscheidung, kein Fund.
