# Prüfbericht: Routen des Elternbonus

Fünf Routen in `app/routers/elternbonus.py`, 25 Tests in `tests/test_elternbonus.py`.
**Nullpunkt grün** (25 passed). Auftrag: [`api/elternbonus-api.md`](../api/elternbonus-api.md) und
Block [14](../soll-prozesse/14-elternbonus.md). Gemessen nach der Methode aus
`prompts/api-pruefen.md`.

## Funde

**Nach Gewicht:** R5 (fremde Familie erreichbar), R6 (Schreibrecht trotz „nur lesen"), dann die
Abweichungen R1–R4 gegen den Block, dann R7–R9.

```
[BONUS-R1] Klasse 8 · was die bestätigende Person schon bestätigt hat
Block 14, „Was dabei erhoben wird": „die bestätigende Person sieht die Einträge, die auf sie warten,
  **und was sie in diesem Schuljahr schon bestätigt hat** — wer, wann, wie lange, wofür — und keinen
  Schritt weiter in die Akte."
  Die zweite Hälfte hat keine Route. `GET /parent-work-entries/pending` filtert auf
  `confirmed_at IS NULL AND rejected_at IS NULL`, liefert also genau das Gegenteil;
  `GET /families/{family_id}/parent-work` setzt die Familie voraus und steht der bestätigenden
  Person ohne Sekretariats- oder Schulleitungsrolle nicht offen; die Jahresliste ist aggregiert und
  trägt eine engere Rollenliste. Der Plan hat die Zusage nicht aufgenommen — er weicht hier vom
  Block ab, und das wiegt schwerer als eine Abweichung der Route vom Plan.
Nicht gemessen, gelesen.
Vorschlag: `GET /parent-work-entries/pending` um einen Zustandsfilter erweitern oder eine zweite
  Liste daneben, beide über denselben Ownership-Check auf confirming_employee_id.
```

```
[BONUS-R2] Klasse 8 · wer als bestätigende Person wählbar ist
Plan: „Wählbar ist dafür jede Person mit einer Mitarbeiterrolle der Schule außer den beiden
  KITA-Rollen — **das prüft bereits `GET /employees/selectable`**, diese Datei erfindet keine zweite
  Prüfung."
  `GET /employees/selectable` (app/routers/stammdaten.py:2634) prüft das nicht: Es filtert allein
  auf den Beschäftigungszeitraum, kennt keine KITA-Ausnahme und verlangt überhaupt keine Rolle. Der
  optionale `role_code` hilft nicht — „jede Rolle außer zwei" ist mit einem einzelnen Code nicht
  ausdrückbar. Die Prüfung steht ausschließlich in `_confirmable()` dieser Domäne, also genau in der
  zweiten Fassung, die der Plan ausschließt. Praktische Folge: Die Auswahlliste im Portal bietet
  KITA-Personal und rollenlose Mitarbeitende an, und `POST /parent-work-entries` antwortet darauf
  400.
Nicht gemessen, gelesen.
Vorschlag: die beiden Enden angleichen — entweder `GET /employees/selectable` um dieselbe Bedingung
  erweitern, oder den Satz im Plan streichen und `_confirmable()` als die eine Quelle benennen.
```

```
[BONUS-R3] Klasse 8 · die Frist des 31. Juli gilt nur halb
Block 14, „Fristen und Termine": „Eingetragen **und bestätigt** wird bis zum 31. Juli, für alle
  gleich und nirgends einstellbar."
  `POST /parent-work-entries` prüft die Frist (für Erziehungsberechtigte),
  `PUT /parent-work-entries/{id}/decision` prüft sie nicht — eine Bestätigung kann jederzeit
  nachkommen. Der Plan hat die Bedingung an der Entscheidungsroute nicht aufgeführt („Nur solange
  noch nicht entschieden"), weicht also selbst vom Block ab.
  Gegenargument, das trägt, aber nicht gebaut ist: Der Jahresschluss am 1. August rechnet mit dem
  Stand von dann, eine spätere Bestätigung zählte also ohnehin nicht — nur gibt es diesen Lauf
  nicht (R4).
Nicht gemessen, gelesen.
Vorschlag: entweder dieselbe Fristprüfung an der Entscheidungsroute, oder der Satz im Plan, dass
  allein die Zeitpunkt des Jahresschlusses sie trägt.
```

```
[BONUS-R4] Klasse 8 · die beiden Läufe der Domäne gibt es nicht
Der Plan führt sie in der Gegenprobe („5 Zeilen; ... 2 sind Läufe (Z3, Z4)") und in einer eigenen
  Tabelle: die Erinnerungsmail am 1. Juni (`system:parent_work_reminder`) und den Jahresschluss am
  1. August (`system:rollover`), der die Jahresliste als eine Aufgabe bei der Buchhaltung anlegt.
  `app/runs.py` kennt beide nicht — die Registertabelle trägt die fünf des Putzdienstes, die vier
  der Anmeldung und die zwei domänenlosen. Der Router sagt es an einer Stelle selbst
  („the year-end run is not part of this pass"), der Plan sagt es nirgends.
Nicht gemessen, gelesen.
Vorschlag: keine Reparatur an den Routen — die Zeile gehört als offener Punkt ins `backlog/`,
  damit die Gegenprobe des Plans nicht länger etwas behauptet, das nicht steht.
```

```
[BONUS-R5] Klasse 1 · GET /families/{family_id}/parent-work
Plan: „Schulleitung nicht nach Schulform, sondern jede Schulleitung, die ein Kind dieser Familie
  hat." Genau das leistet `reach_family_as_staff()`, und es ist die einzige Einschränkung der
  Mitarbeiterseite dieser Route.
Gemessen: den Aufruf entfernt, tests/test_elternbonus.py bleibt grün (25 passed). Eine Schulleitung
  erreicht damit den Stand jeder Familie, auch einer ohne ein Kind ihrer Schulart — samt jedem
  Eintrag mit Datum, Tätigkeit und bestätigender Person. Der Test, der zählt, fehlt: die Datei
  prüft die Schulart nur an der Jahresliste, nie an der Familienansicht.
Vorschlag: ein Test, in dem die Schulleitung der einen Schulart die Familie der anderen abruft und
  404 bekommt.
```

```
[BONUS-R6] Klasse 4 · POST /parent-work-entries
Plan: „eigene Familie, nach Einsichtsstufe **nur ‚voll'** — der Eintrag mindert das Schulgeld der
  ganzen Familie, keine ‚eigene Angabe' einer eingeschränkten Person." Das trägt allein das
  `write=True` an `reach_family()`.
Gemessen: auf `reach_family(user, body.family_id)` gekürzt — tests/test_elternbonus.py bleibt grün
  (25 passed). Kein Test hat einen Sorgeberechtigten mit Stufe „nur lesen"; danach trüge eine
  eingeschränkte Person Stunden für die ganze Familie ein.
Vorschlag: ein Test mit einem CurrentUser, dessen `writable_families` leer ist, gegen 403.
```

```
[BONUS-R7] Klasse 4 · die Rechnung ist nur im Vollfall geprüft
Block 14: „jeder Monat, in dem die Familie mindestens einen Tag ein eingeschriebenes Kind hatte,
  den August ausgenommen" und „höchstens aber, was der Familie in diesem Schuljahr berechnet wurde
  — der Deckel trägt Quereinsteiger und Abgänger ohne eigene Regel".
Gemessen, zweimal grün: `min(raw, cap)` auf `raw` gekürzt → 25 passed; das Monatsfenster von
  September auf August verschoben → 25 passed. Beides bleibt unsichtbar, weil jede Familie der
  Testwelt das ganze Schuljahr eingeschrieben ist: Der Deckel greift nie, und ein verschobenes
  Fenster zählt dieselben elf Monate. Damit ist genau der Fall ungeprüft, für den der Deckel da
  ist.
Vorschlag: eine Familie mit `entry_date` im Januar und eine mit `exit_date` im November, dazu eine
  Zusicherung auf `counted_months` und auf den gedeckelten Betrag.
```

```
[BONUS-R8] Klasse 4 · POST /parent-work-entries, _confirmable()
Der Docstring: „any current staff role except the two KITA ones" — „current" trägt die beiden
  `first_working_day`/`last_working_day`-Bedingungen, dieselbe Regel, mit der
  `GET /employees/selectable` Ausgeschiedene ausblendet („whoever has left is nobody to pick").
Gemessen: beide Zeilen entfernt, tests/test_elternbonus.py bleibt grün (25 passed). Die
  KITA-Ausnahme daneben ist geprüft, der Beschäftigungszeitraum nicht — eine längst ausgeschiedene
  Person ließe sich weiter als bestätigende benennen, und ihr Eintrag wartete auf jemanden, der
  sich nie anmeldet.
Vorschlag: ein Test mit einem Mitarbeitenden, dessen letzter Arbeitstag vorbei ist, gegen 400.
```

```
[BONUS-R9] Klasse 5 · die beiden Rollenschranken der Ansichten
`GET /families/{family_id}/parent-work` trägt `require_staff(user, _SECRETARIAT, BRANCH_ROLE)`,
  `GET /parent-work-entries/annual-list` trägt `require_role(_SECRETARIAT, BRANCH_ROLE,
  _ACCOUNTING)`. Beide Listen nennt der Plan namentlich, beide hält kein Test.
Gemessen: die erste Schranke entfernt → grün (25 passed); die zweite um `teacher` erweitert → grün.
  Die vorhandenen Verweigerungstests fahren beide über den Elternteil, und der fällt schon an der
  Türunterscheidung heraus.
Vorschlag: je ein Test mit `as_role("teacher")` gegen 403.
```

## Angesehen, nicht als Fund gewertet

- **Ownership in der Query, alle drei Wege gemessen und alle rot.** Eintrag für eine fremde Familie
  (`reach_family` entfernt → `test_a_guardian_cannot_log_an_hour_for_a_foreign_family`);
  Familienansicht einer fremden Familie (→ `test_a_guardian_cannot_read_a_foreign_familys_stand`);
  und die Entscheidung durch eine andere Mitarbeiterin, die die Id rät (`_is_confirmer` entfernt →
  `test_a_different_employee_guessing_the_id_cannot_decide_it`). Der Test mit der **fremden Id**
  durch einen Berechtigten liegt in allen drei Fällen vor. Die vierte Ownership-Frage, die
  Warteschlange, ist ebenfalls rot geworden (`test_a_different_employee_sees_none_of_it`).
- **Die Frist des Eintrags.** Für Erziehungsberechtigte entfernt → rot
  (`test_a_guardian_cannot_backdate_into_a_closed_school_year`); dass das Sekretariat sie nicht
  trägt, hält ein eigener Test.
- **Die KITA-Ausnahme** entfernt → rot. **Die Endgültigkeit der Entscheidung** entfernt → rot.
  **Die Rollenschranke des Eintrags** entfernt → rot. **Die Türunterscheidung der Warteschlange**
  entfernt → rot (Elternteil und rollenloser Mitarbeitender haben je einen Test).
- **Die beiden Sonderfälle.** Mitarbeiterfamilie und Elternvertretung je auf `False` gezwungen →
  beide rot, in der Familienansicht wie in der Jahresliste; dazu die Schulart-Einschränkung und der
  Einschreibungsfilter der Jahresliste, beide rot.
- **Die 15-gegen-10-Stunden-Regel** entfernt → rot.
- **Klasse 2 lässt sich hier nicht herstellen.** Beide schreibenden Routen prüfen vollständig, bevor
  sie `session.add()` bzw. die Entscheidung setzen, und `TransactionRoute` committet nach einer
  `HTTPException` nie.
- **Klasse 6 entfällt.** Keine Route schreibt zwei Tabellen, keine ruft Graph, keine schickt eine
  Mail — die beiden Mails der Domäne sind Läufe, und die gibt es nicht (R4).
- **`GET /employees/selectable` und `_confirmable()` doppelt geprüft?** Der Router baut den
  gemeinsamen Hebel nicht nach, sondern prüft eine Bedingung je Datensatz in der eigenen Query, wie
  `CLAUDE.md` §6 es verlangt — eine HTTP-Antwort ließe sich hier gar nicht lesen. Der Fund liegt
  nicht im zweiten Check, sondern darin, dass die beiden Enden verschiedene Mengen meinen (R2).
- **Kein Höchstdatum an `worked_on`.** Eine Stunde für ein künftiges Schuljahr wird angenommen, weil
  dessen 31. Juli noch nicht vorbei ist. Ein Tippfehler im Jahr landet damit in einem Schuljahr, das
  niemand ansieht — aber der Block sagt zum künftigen Datum nichts, und `wb-docs/CLAUDE.md` verbietet
  den konstruierten Randfall. Genannt, nicht gewertet.
- **Die Jahresliste rechnet je Familie vier Abfragen.** Bei einer ganzen Schule sind das einige
  tausend Abfragen je Aufruf. Keine Regel dieses Laufs, deshalb kein Fund — genannt, weil es an
  einer Liste hängt, die einmal im Jahr über den ganzen Bestand läuft.
