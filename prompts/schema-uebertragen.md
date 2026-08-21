# Prompt: eine Fachdomäne nach SQLAlchemy und Alembic übertragen

Gegenstück zu [`prompts/schema-bauen.md`](schema-bauen.md). Dort entsteht das SQL, hier wird daraus Code. **Eine Domäne je Durchgang**, in der Ladereihenfolge des Schemas: `stammdaten`, dann `querschnitt`, dann der Rest in beliebiger Folge — dieselbe Portionierung wie beim Bau, und aus demselben Grund.

Dieser Auftrag läuft in **`wb-backend`**, nicht hier. `wb-docs` ist dabei Quelle und wird nur gelesen.

Kopieren, `DOMÄNE` ersetzen, absenden. Alles unter dem Strich ist der Prompt. Effort `high`, bei `stammdaten`, `querschnitt` und `anmeldung` `xhigh`; Thinking anlassen.

---

Wir übertragen die Fachdomäne **DOMÄNE** aus dem geprüften Schema nach SQLAlchemy 2.0 und Alembic. Ergebnis sind ein Modellmodul und eine Migration in `wb-backend`. Nur diese Domäne, keine andere.

**Die `.sql` ist die Wahrheit, das Modell ist das Abgeleitete.** Was du nicht ausdrücken kannst, ist ein Fund und keine stille Vereinfachung.

Es gelten `CLAUDE.md` dieses Repos (Code-Stil, verbindlich) und [`../wb-docs/prompts/gemeinsam.md`](gemeinsam.md) (die `[A]`-Marke, wie du fragst, wie du mit mir redest, kein Subagent urteilt). Beides liest du zuerst und ich wiederhole es hier nicht.

## Was du vorher liest, und wozu

1. **`../wb-docs/schema/DOMÄNE-schema.sql`** — vollständig, samt aller Kommentare. Sie tragen die Begründungen, und ohne sie baust du zuverlässig genau das, was dort schon verworfen wurde.
2. **`../wb-docs/schema/DOMÄNE-schema-check.sql`** — der Sollstand im Kopfkommentar ist dein Abnahmekriterium, und die Gegenproben sagen dir, welche Regeln tatsächlich greifen müssen.
3. **`../wb-docs/TODO-SESSIONS.md`**, Abschnitt „Übertragung nach SQLAlchemy/Alembic" — dort stehen die Fallen dieses Auftrags ausgeschrieben.
4. **Die schon übertragenen Domänen** in diesem Repo. Präzedenz schlägt Geschmack: Tragen zwei Formen dieselbe Sache, nimm die, die hier schon vorkommt.

**Das liest du selbst** — aus dem Grund, der in `gemeinsam.md` steht. Ein Subagent darf eine Fundstelle suchen, nicht urteilen.

## Der erste Durchgang trägt zusätzlich die Konvention

Nur beim allerersten Mal, und **bevor das erste Modell entsteht**:

- **`naming_convention` auf `Base.metadata` setzen.** Ohne sie benennt Alembic autogenerierte Constraints unvorhersehbar, und eine spätere Migration kann sie nicht per `DROP CONSTRAINT` greifen. Steht sie erst nach dem ersten Modell, tragen die früh erzeugten Constraints andere Namen als alle späteren.
- Sie muss die **im Schema bereits explizit benannten** Constraints übernehmen, nicht überschreiben — die mehrspaltigen `CHECK`s, den Ausschluss-Constraint und die partiellen Unique-Indizes. Die Gegenprobe dafür ist billig: Die erzeugte Migration nennt dieselben Namen wie die `.sql`.
- **Wo das Modellmodul einer Domäne liegt**, entscheidest du einmal und hältst es durch (`CLAUDE.md` §3: ein Modul je Domäne, nie ein Sammel-`models.py`). Schreib eine `[A]`-Zeile dazu.

## Was das Modell trägt — und was ausdrücklich nicht

**Trägt es:** Tabellen, Spalten, Typen, `NULL`/`NOT NULL`, `DEFAULT`, Primär- und Fremdschlüssel, `UNIQUE`, `CHECK`, partielle Indizes, Ausschluss-Constraints. In SQLAlchemy-2.0-Form (`Mapped[...]`/`mapped_column(...)`), nie im Legacy-Stil (`CLAUDE.md` §6).

**Trägt es nicht: die Begründungen.** Die stehen in der `.sql` und bleiben dort. **Kein deutscher Kommentar wandert nach Python** — dieses Repo schreibt englisch (§1) und kommentiert nur das Nicht-Offensichtliche (§9). Ein Modell, das die Kommentare der `.sql` nachbaut, verdoppelt neunhundert Zeilen Begründung an einen zweiten Ort, der beim ersten Schemawechsel hinterherläuft. Ein Kommentar im Modell steht nur dort, wo **der Code selbst überrascht** — und dann sagt er warum, in einem Satz, mit Verweis auf die `.sql`.

## Drei Dinge, die `--autogenerate` nicht sieht

Sie sind der eigentliche Grund, warum dieser Auftrag Handarbeit ist. Alembic meldet nicht, dass sie fehlen; es ließe sie beim nächsten Regenerieren stillschweigend weg.

**1. Die Spalten-Rechte auf dem Art.-9-Bestand — und der Mechanismus dahinter.**
`db/init-roles.sh` hat `backend_runtime` über `ALTER DEFAULT PRIVILEGES` **tabellenweit** CRUD auf alles gegeben, was der Migrator anlegt. Ein zusätzlicher `GRANT` auf einzelne Spalten ändert daran **nichts** — das Recht ist schon da. Du musst auf Tabellenebene widerrufen und danach die erlaubten Spalten einzeln gewähren. Das gehört als `op.execute()` in die Migration, direkt hinter die Tabelle, für die es gilt. **Beleg es mit einer Gegenprobe, statt es zu behaupten:** ein `SELECT` auf die geschützte Spalte als `backend_runtime` muss scheitern.

**2. Die enger geschnittenen Rollen selbst.** Die Liste steht in `../wb-docs/TODO.md`. Sie werden **angelegt** wie die drei bestehenden, also in `db/init-roles.sh`; ihre **Spalten-Rechte** stehen in der Migration, weil dort erst die Tabellen existieren. Diese Trennung hältst du durch. `init-roles.sh` läuft nur bei der ersten Initialisierung eines Clusters — sag mir, wenn eine Rolle dazukommt, nachdem irgendwo schon eine Datenbank steht.

**3. `deferred()` auf `children.denomination_id` und `congregation`.** Sobald Punkt 1 sitzt, scheitert jedes Vollobjekt-Laden dieser Tabelle an „permission denied for column", weil SQLAlchemy per Default alle gemappten Spalten selektiert. Die Lösung ist klein und muss trotzdem **vor** dem Modell dastehen — sonst wird sie später unter Zeitdruck durch ein tabellenweites `GRANT` „gelöst", und der ganze Mechanismus ist weg.

## Was nicht in diesen Durchgang gehört

- **Die gemeinsame Schreibschicht für `change_log`.** Eigener Auftrag. Sie muss vor dem ersten Schreibpfad stehen, aber nicht vor dem ersten Modell — und wer sie nebenher baut, baut sie halb.
- **Router, Endpunkte, Pydantic-Modelle.** Erst wenn die Domäne steht.
- **Jede Änderung an `wb-docs`.** Auch keine „offensichtliche" Korrektur in der `.sql`. Was dort falsch aussieht, kommt auf die Findungsliste.

## Rangfolge bei Widerspruch

1. **`../wb-docs/schema/DOMÄNE-schema.sql`** — was dort steht, gilt.
2. **`CLAUDE.md` dieses Repos** — für die Form des Codes, nie für den Inhalt des Modells.
3. Sonst nichts. Dein Geschmack steht nicht in dieser Liste.

**Kann das Modell etwas nicht ausdrücken, was die `.sql` verlangt** — eine Constraint-Form, ein Index-Prädikat, ein Typ —, geht die Regel als `op.execute()` in die Migration und der Punkt auf die Findungsliste. Sie geht nie verloren, und sie wird nie „vereinfacht".

## Die Abnahme

Nicht mit Augenmaß, sondern mit Rückgabewerten. Drei Läufe, alle drei nennst du am Ende:

1. **`mypy --strict app` und `ruff check .`** — beide sauber.
2. **`alembic upgrade head` gegen eine frische Datenbank.** Die Migration liest du vorher **von Hand durch**; `--autogenerate` ist ein Entwurf und kein Ergebnis (`CLAUDE.md` §6).
3. **Das Prüfskript der Domäne gegen die von Alembic gebaute Datenbank**, mit `-v ON_ERROR_STOP=1`. Ohne den Schalter endet auch ein gescheiterter Lauf mit 0, und dann ist jeder Lauf grün. Kommt der Sollstand aus dem Kopfkommentar heraus, ist die Übertragung nachweislich treu — das ist der Punkt der ganzen Übung.

```
docker compose --profile tools run --rm migrate
docker compose exec -T db psql -U backend_migrator -d weltenbaum -v ON_ERROR_STOP=1 -q \
    < ../wb-docs/schema/DOMÄNE-schema-check.sql ; echo "rc=$?"
```

**Beim letzten Durchgang laufen alle vierzehn Prüfskripte** gegen die vollständige Datenbank, nicht nur das der eigenen Domäne: Ein Skript mit erfundenen Fremdschlüssel-Werten läuft grün, solange die Zieltabelle fehlt.

## Was du lieferst

**Datei anfassen erst nach meinem OK.** Bis dahin steht alles in deiner Antwort.

1. **Das Modellmodul**, vollständig — kein Auszug, keine „hier analog weiter"-Stelle.
2. **Die Migration**, samt der `op.execute()`-Blöcke, von dir durchgesehen und nicht bloß erzeugt.
3. **Die drei Rückgabewerte** aus der Abnahme, je einer in einer Zeile.
4. **Die Findungsliste** als eigener Abschnitt, nie im Code.

## Die Findungsliste

Je Eintrag eine Zeile: was du gefunden hast, wo, dein Vorschlag. Darauf gehört dreierlei:

- **Die `.sql` verlangt etwas, das das Modell nicht ausdrücken kann** — samt der Stelle, an der du es stattdessen als `op.execute()` untergebracht hast.
- **Die `.sql` widerspricht sich oder ihrem Prüfskript.** Bau nichts, melde es.
- **Eine Regel aus dem Prüfskript hat im Modell keinen Träger.** Dann fehlt sie, und das fällt jetzt auf und nicht beim ersten echten Datensatz.

Nicht darauf gehört, dass du anders benennst oder schneidest, als du es anderswo getan hättest — das ist Handwerk und entscheidest du selbst.

## Drei Listen, drei Präfixe

Annahmen `A1, A2 …`, Fragen `F1, F2 …`, Findungen `R1, R2 …`. Dann ist „A2 ja, F1b, R3 so lassen" eine vollständige Antwort. Code zählt nie ins Zeilenbudget.

## Bevor du mir das Modell zeigst

Vier Nähte. **Melde davon nur, was etwas ergeben hat** — „geprüft, nichts gefunden" schreibst du nicht.

1. **Vollständigkeit.** Trägt das Modell jede Tabelle, jede Spalte und jedes benannte Constraint der `.sql` — und keines mehr?
2. **Namen.** Heißen die Constraints in der erzeugten Migration genauso wie in der `.sql`?
3. **Die drei Blinden.** Stehen Spalten-Rechte, Rollen und `deferred()` in der Migration bzw. im Modell — und greift die Gegenprobe aus Punkt 1 oben wirklich?
4. **Keine deutsche Prosa im Code.** Ist eine Begründung aus der `.sql` nach Python gewandert, gehört sie zurück.
