Stand: c4ef05a, Nullpunkt: 61 Tests grün

# Prüfbericht Routen — rechnungsfreigabe

30 Routen in `app/routers/rechnungsfreigabe.py` gegen `wb-docs/api/rechnungsfreigabe-api.md` und
`soll-prozesse/12-rechnungsfreigabe.md`. 42 Sicherungen herausgenommen, 38 wurden rot, 4 blieben grün.

## Funde

[rechnungsfreigabe-R1] Klasse 4 · POST /expense-claim-items/{id}/forwarding
Block Z2: „An genau eine, nie an mehrere — dafür ist Aufteilen da." Die Sperre dagegen ist die
Bedingung `approved_at/rejected_at/forwarded_at is not None` in `forward_item`, und sie ist das
Einzige, was greift: `ck_expense_claim_items_decision` zählt Nicht-Nullen und sieht nicht, dass
`forwarded_at` schon stand. Wird dieselbe weitergeleitete Zeile ein zweites Mal weitergeleitet — ihr
`approver_employee_id` zeigt weiter auf die ursprüngliche Führungskraft, `_reach_item` lässt sie also
durch —, entsteht eine zweite lebende Zeile mit demselben Betrag: ein Beleg über 1000 trägt danach
zwei offene Teile über je 1000, und das Deckblatt zeigt der Buchhaltung 2000.
Gemessen: Bedingung entfernt (`if False:`), `tests/test_rechnungsfreigabe.py` bleibt **grün**
(61 Tests). Kein Test leitet einen schon entschiedenen oder schon weitergeleiteten Teil weiter.
Vorschlag: Test, der dieselbe Zeile zweimal weiterleitet und die zweite Absage samt der Zahl der
lebenden Teile prüft.

[rechnungsfreigabe-R2] Klasse 4 · POST /expense-claims/{id}/withdrawal
Block Z1: zurückziehen, „solange keine Führungskraft ihn **oder einen seiner Teile** freigegeben
hat". Die Route trägt das zweimal — `any(item.approved_at is not None ...)` und danach
`_claim_state(...) != "open"` —, und nur die erste hält den aufgeteilten Beleg: Ist Teil A
freigegeben und Teil B offen, ist der Zustand „open", die zweite Bedingung greift also nicht.
Gemessen: `any(...)`-Bedingung entfernt, Suite bleibt **grün** (61 Tests). Der vorhandene Test
`test_an_approved_claim_is_no_longer_withdrawable` prüft den einteiligen Beleg, den die zweite
Bedingung ohnehin abweist — er kann die erste nicht sehen.
Vorschlag: Test, der einen Beleg aufteilt, einen Teil freigeben lässt und den Rückzug abgewiesen
sieht, samt `withdrawn_at is None` danach.

[rechnungsfreigabe-R3] Klasse 2 · POST /expense-claims
Plan, „Am Schema aufgefallen": „Die Reihenfolge ist damit festgelegt: erst hochladen, dann
schreiben. **Bricht die Transaktion danach ab**, bleibt eine Datei ohne Zeile in der Bibliothek
liegen" — der hingenommene Schaden gilt dem Abbruch, nicht einer Absage. Heute steht jede Prüfung
vor den Uploads, aber nichts hält sie dort: Eine Bedingung, die hinter die Upload-Schleife rutscht,
lädt bei **jeder** abgewiesenen Einreichung eine Datei in die Bibliothek, die keine Zeile je
einholt.
Gemessen: Prüfung `not route.is_active` hinter die Uploads verschoben — die Route antwortet weiter
mit 400, die Suite bleibt **grün** (61 Tests). Kein Test sieht `files.uploaded` nach einer Absage an,
obwohl die Attrappe es mitschreibt.
Vorschlag: an einem der vorhandenen 400-Tests `assert files.uploaded == []` ergänzen.

[rechnungsfreigabe-R4] Klasse 4 · PATCH /expense-claim-items/{id} gegen PUT …/decision
Block Z2: „ihre **lückenlose** Nummer für die Buchhaltung"; Plan: „lückenlos je Kalenderjahr … eine
Sequenz hätte Lücken". `correct_item` setzt bei einer Betragsänderung `claim.claim_number = None`
(Zeile 1748), `_draw_claim_number` zieht `max(claim_number) + 1` (Zeile 1596). Beleg A bekommt 1,
Beleg B bekommt 2, A wird korrigiert und verliert die 1, A wird erneut freigegeben und bekommt 3 —
die 1 füllt niemand mehr. Der Plan kennt die Lücke nur als Folge eines abgebrochenen Laufs, nicht
als Folge einer regulären Korrektur.
Gemessen: `claim.claim_number = None` entfernt → rot, aber nur, weil ein Test das Fallen der Nummer
prüft; kein Test sieht die Nummernfolge des Jahres über drei Belege an.
Vorschlag: die einmal gezogene Nummer am Beleg stehen lassen und `_draw_claim_number` nur beim
erstmaligen Erreichen von `approved` rufen; dazu ein Test mit einer Korrektur zwischen zwei Belegen.

[rechnungsfreigabe-R5] Klasse 8 · PATCH /expense-claim-items/{id} (Plan gegen Block)
Block Z4, „danach steht fest": „Ein **abgelehnter**, stornierter oder zurückgezogener Beleg lebt
nicht wieder auf; wer ihn anders will, reicht neu ein." Der Plan nimmt den Satz nur für Storno und
Rückzug auf; `_still_running()` kennt entsprechend `withdrawn_at`, `booked_at`, `voided_at` und
nicht die Ablehnung. Die Führungskraft, die abgelehnt hat, korrigiert ihren eigenen Teil,
`correct_item` setzt `rejected_at`/`rejected_reason` auf `NULL` — der abgelehnte Beleg ist wieder
offen und bekommt bei der nächsten Freigabe eine Nummer. Dasselbe gilt für Weiterleiten und
Aufteilen an einem abgelehnten Beleg.
Gelesen, nicht gemessen: Kein Test fasst einen abgelehnten Beleg noch einmal an —
`test_a_closed_claim_is_neither_decided_nor_corrected` prüft Rückzug und Buchung.
Vorschlag: entscheiden, ob die Ablehnung ein Endzustand ist; wenn ja, in `_still_running()`
aufnehmen, sonst im Plan ausschreiben, warum sie es nicht ist — der Plan wiegt schwerer, weil er
sich beim nächsten Bau fortpflanzt.

[rechnungsfreigabe-R6] Klasse 8 · POST /expense-claims (Router **und** Plan gegen Block)
Block, „Was dabei erhoben wird": bei Fahrtkosten „entweder Ticketbetrag **samt Beleg** oder die
Strecke …; **im zweiten Fall** gibt es keinen Anhang, weil es keinen gibt". Die Route verlangt einen
Anhang nur bei `claim_type == "invoice"`; eine Fahrt nach Ticket kommt ohne jeden Nachweis durch und
wird freigegeben und gebucht. Der Plan sagt denselben Satz nur zur Hälfte („bei `travel` nach
Strecke gibt es keinen") und deckt die Lücke damit ab.
Gelesen, nicht gemessen: Die Regel ist nicht gebaut, es gibt keine Sicherung herauszunehmen.
Vorschlag: Anhang auch verlangen, wo `travel.ticket_amount_cents` gesetzt ist, und den Satz im Plan
vervollständigen.

[rechnungsfreigabe-R7] Klasse 8 · GET /expense-claims/{id}/document
Block, „Dateien": „Bei einer Aufteilung nach Vorlage steht an jedem Teil dieselbe Führungskraft,
**daneben der Vermerk, aus welcher Vorlage der Schlüssel stammt**" — „damit ihr Name an einem
fremden Projekt nicht als ihre Entscheidung darüber gelesen wird"; der Plan trägt denselben Vermerk
ausdrücklich am Deckblatt. `cover_sheet()` (`app/services/rechnungsfreigabe.py:71`) nimmt keinen
solchen Parameter, `read_claim_document` liest `claim.claim_template_id` nicht — das Deckblatt trägt
ihn nirgends.
Gelesen, nicht gemessen: nicht gebaut.
Vorschlag: den Vermerk aus `claim_template_id` als weiteren Kopf-Absatz des Deckblatts erzeugen.

[rechnungsfreigabe-R8] Klasse 4 · POST /expense-claims
Die Absage „No such approver" (400) ist die einzige Stelle, die eine unbekannte Freigeber-Kennung
freundlich abweist; ohne sie antwortet `fk_expense_claim_items_approver` mit einer 500.
Gemessen: Bedingung entfernt, Suite bleibt **grün** (61 Tests) — kein Test reicht mit einer
erfundenen `approver_employee_id` ein.
Vorschlag: ein Test mit fremder Kennung auf 400; dieselbe Bedingung steht noch zweimal
(`forward_item`, `split_claim`) und ist dort mitgeprüft.

## Angesehen, nicht als Fund gewertet

- **Klasse 1 ist durchweg rot.** Acht Ownership-Bedingungen einzeln herausgenommen — `_visible()`,
  `_reach_item`, der Einreicher-Vergleich im Rückzug, die `mine`-Bedingung im Aufteilen, der
  Eigenfilter der Streckenvorschläge, die `_me()`-Sperre, `_reach_claim` am Anhang und der
  `_ALL_SEEING`-Zweig: jede Messung rot. Kein Endpunkt dieser Datei ist grün und offen zugleich.
- **Klasse 2 kann in dieser Datei nur außerhalb der Transaktion entstehen.** Jede Prüfung steht vor
  jeder Zuweisung, und eine `HTTPException` rollt die Transaktion ohnehin zurück
  (`app/db/session.py`) — eine Messung „schreiben und dann absagen" käme deshalb aus dem falschen
  Grund grün heraus. `patch_payee` weist den Namen zu, **bevor** es das Zusammenführungsziel prüft;
  getragen wird das allein von dieser Klammer. Die eine Wirkung außerhalb ist der Graph-Upload, und
  die steht als R3.
- **Klasse 3:** Jede Zusicherung über eine leere Liste hat ihre nicht-leere daneben — die
  Auswertungen (`claims >= 1` gegen `claims == 0`), die Streckenvorschläge (`["Ulm"]` gegen `[]`),
  die vier Sichten der Übersicht.
- **Klasse 7 entfällt:** Diese Domäne hat keinen Lauf, und das ist die ausdrückliche Aussage des
  Plans („Keine Läufe").
- **Der Dublettenhinweis nennt einen Beleg, den der Aufrufer nicht sehen darf** — Kennung,
  Einreichername, Datum und Betrag, ohne `_visible()`. Genau das schreibt der Plan aus („Er nennt
  den anderen Beleg mit Einreicher und Datum"), obwohl derselbe Plan den Auswertungen denselben
  Umweg verbietet. Öffnen lässt sich der andere Beleg nicht.
- **`internal_note` erreicht auch den Einreicher.** Der Name sagt „intern", der Block setzt für den
  Beleg aber genau einen Kreis, und der Einreicher steht darin; keine enge Rolle im Plan.
- **`PUT /claim-templates/{id}`:** `accounting` kann eine Aufteilungsvorlage auf einen Anteil
  zurückbauen, weil die Rolle an der Zahl der Anteile **nach** der Änderung hängt — so schreibt der
  Plan es aus.
- **Der Teams-Ping und die Meldegrenze fehlen** — TASK-138, geticketet.
- **`pg_advisory_xact_lock(:key)` mit dem blanken Kalenderjahr** statt `hashtext('<name>:<key>')`
  wie an den vier anderen Sperren des Repos (`anmeldung`, `cleaning`, `ferien`). Kollision
  theoretisch, Wirkung höchstens Wartezeit — die abweichende Bauform gehört in den Gesamtlauf.
- **Die `entra:`-Kennung wird an fünf Stellen einzeln zu `employees.employee_id` aufgelöst**
  (`core/security.py` dreimal, `routers/cleaning.py`, `routers/rechnungsfreigabe.py:150`), während
  `security.py` die beiden Familien-Auflösungen ausdrücklich zusammenhält, damit keine zweite
  Fassung entsteht. Für den Gesamtlauf.
- **Die Löschankündigung.** Der Block verlangt für diesen Bestand die zwei Meldungen an Buchhaltung
  und Geschäftsführung wie für jeden anderen; der Plan-Absatz zitiert nur die Aussparung beim
  Räumen. Gehört zu Block 17 und keiner Route dieser Datei — hier notiert, damit es nicht zwischen
  den Domänen verschwindet.
- **`read_claim_document` legt das Deckblatt zum Konvertieren in der Bibliothek ab** und entfernt es
  im `finally`; scheitert `remove`, bleibt eine `cover-*.docx` liegen. Ohne Datenbankfolge.
