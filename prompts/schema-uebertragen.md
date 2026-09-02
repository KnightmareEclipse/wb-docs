# Prompt: eine Fachdomäne nach SQLAlchemy und Alembic übertragen

Gegenstück zu [`prompts/schema-bauen.md`](schema-bauen.md). Dort entsteht das SQL, hier wird daraus Code. **Eine Domäne je Durchgang** — dieselbe Portionierung wie beim Bau, und aus demselben Grund. Die dreizehn Domänen des ersten Bestands sind übertragen; dieser Prompt gilt der vierzehnten.

Dieser Auftrag läuft in **`wb-backend`**, nicht hier. `wb-docs` ist dabei Quelle und wird nur gelesen.

Kopieren, `DOMÄNE` ersetzen, absenden. Alles unter dem Strich ist der Prompt. Effort `high`, bei einer Domäne mit vielen Berührungspunkten `xhigh`; Thinking anlassen.

---

Wir übertragen die Fachdomäne **DOMÄNE** aus dem geprüften Schema nach SQLAlchemy 2.0 und Alembic. Ergebnis sind ein Modellmodul und eine Migration in `wb-backend`. Nur diese Domäne, keine andere.

**Die `.sql` ist die Wahrheit, das Modell ist das Abgeleitete.** Was du nicht ausdrücken kannst, ist ein Fund und keine stille Vereinfachung.

Es gelten die `CLAUDE.md` von `wb-backend` (Code-Stil, verbindlich — **alle `§`-Verweise unten meinen sie**, nicht die von `wb-docs`) und [`../wb-docs/prompts/gemeinsam.md`](gemeinsam.md) (die `[A]`-Marke, wie du fragst, wie du mit mir redest, kein Subagent urteilt). Beides liest du zuerst und ich wiederhole es hier nicht.

## Was du vorher liest, und wozu

1. **`../wb-docs/schema/DOMÄNE-schema.sql`** — vollständig, samt aller Kommentare. Sie tragen die Begründungen, und ohne sie baust du zuverlässig genau das, was dort schon verworfen wurde.
2. **`../wb-docs/schema/DOMÄNE-schema-check.sql`** — der Sollstand im Kopfkommentar ist dein Abnahmekriterium, und die Gegenproben sagen dir, welche Regeln tatsächlich greifen müssen.
3. **Die schon übertragenen Domänen** in diesem Repo. Präzedenz schlägt Geschmack: Tragen zwei Formen dieselbe Sache, nimm die, die hier schon vorkommt.

**Das liest du selbst** — aus dem Grund, der in `gemeinsam.md` steht. Ein Subagent darf eine Fundstelle suchen, nicht urteilen.

## Was schon steht, und worauf du dich verlassen kannst

- **`naming_convention` steht** auf `Base.metadata` (`app/db/base.py`). Sie enthält bewusst kein `%(constraint_name)s` — ein ausdrücklich gesetzter Name kommt deshalb **wörtlich** durch. Trag die Namen aus der `.sql` genau so ins Modell, dann liest der Handabgleich beide Seiten als denselben String. Nur Namenloses bekommt die Vorlage.
- **Das Modellmodul liegt in `app/models/DOMÄNE.py`.** `app/db/base.py` liest jedes Modul dort automatisch ein; es gibt keine Importliste, in die du dich eintragen müsstest.
- **`btree_gist` legt `db/init-roles.sh` bei der Clustererstellung an.** Die `CREATE EXTENSION IF NOT EXISTS`-Zeile aus der `.sql` braucht die Migration deshalb nicht; ohne die Extension scheitert ein Ausschluss-Constraint von selbst und laut.
- **Die Schreibschicht steht** (`app/db/changelog.py`). Jedes neue Modell schuldet ihr `__change_anchor__` und `__protected_columns__`, sonst wirft sie beim ersten Flush. Der Anker ist ein **direktes** Attribut der Zeile — ist er nur über einen Join zu finden, ist er `None` und ein Fund, keine stille Erweiterung.
- **Kein ORM-seitiges `cascade="all, delete-orphan"`.** Die Kaskade steht im Schema; ein zweites Mal im Modell hieße, dass die ORM-Löschungen erst im Flush entstehen und `before_flush` sie nicht sieht.
- **Der Dateiname der Revision** kommt aus `file_template` in `alembic.ini`. Nicht umbenennen.

## Was das Modell trägt — und was ausdrücklich nicht

**Trägt es:** Tabellen, Spalten, Typen, `NULL`/`NOT NULL`, `DEFAULT`, Primär- und Fremdschlüssel, `UNIQUE`, `CHECK`, partielle Indizes, Ausschluss-Constraints. In SQLAlchemy-2.0-Form (`Mapped[...]`/`mapped_column(...)`), nie im Legacy-Stil (`CLAUDE.md` §6).

**Trägt es nicht: die Begründungen.** Die stehen in der `.sql` und bleiben dort. **Kein deutscher Kommentar wandert nach Python** — dieses Repo schreibt englisch (§1) und kommentiert nur das Nicht-Offensichtliche (§9). Ein Modell, das die Kommentare der `.sql` nachbaut, verdoppelt neunhundert Zeilen Begründung an einen zweiten Ort, der beim ersten Schemawechsel hinterherläuft. Ein Kommentar im Modell steht nur dort, wo **der Code selbst überrascht** — und dann sagt er warum, in einem Satz, mit Verweis auf die `.sql`.

## Drei Dinge, die `--autogenerate` nicht sieht

Sie sind der eigentliche Grund, warum dieser Auftrag Handarbeit ist. Alembic meldet nicht, dass sie fehlen; es ließe sie beim nächsten Regenerieren stillschweigend weg.

**1. Sämtliche Tabellenrechte, nicht nur die auf dem Art.-9-Bestand.**
`backend_runtime` startet **ohne jedes Tabellenrecht** — es gibt keine Default-Privilegien mehr. Jede Tabelle deiner Domäne braucht deshalb ihren `GRANT` als `op.execute()` in der Migration, direkt hinter der Tabelle, für die er gilt. Zwei Regeln dabei, beide aus `container.md`: **`UPDATE` immer spaltenweise**, nie tabellenweit — daran hängt auch die Unveränderlichkeit der Schlüsselspalten —, und für eine geschützte Spalte gehört sie schlicht nicht in die Liste der gewährten. Ein vergessener `GRANT` fällt als „permission denied" auf; ein zu breiter fällt in `tests/test_privileges.py` auf. **Beleg das Ergebnis mit einer Gegenprobe:** ein `SELECT` auf die geschützte Spalte als `backend_runtime` muss scheitern.

**2. Eine enger geschnittene Rolle, falls die Domäne eine braucht.** Welche es gibt und welche Spalte an welcher hängt, liest du an `__protected_columns__` der bestehenden Modelle und an den `GRANT`s ihrer Migrationen; die bindenden Bedingungen stehen in `../wb-docs/container.md`. Eine neue entsteht **in derselben Migration** wie ihre Spalten-Rechte: `NOLOGIN`, ohne Passwort, erreichbar allein über `GRANT <rolle> TO backend_runtime WITH INHERIT FALSE, SET TRUE` und ein `SET LOCAL ROLE` in der Transaktion, die sie braucht. `db/init-roles.sh` legt keine davon an — es läuft nur bei der ersten Initialisierung eines Clusters und erreicht eine bestehende Datenbank nicht mehr; `backend_migrator` trägt dafür `CREATEROLE`.

**3. `deferred=True` auf jeder geschützten Spalte.** Fehlt es, scheitert jedes Vollobjekt-Laden dieser Tabelle an „permission denied for column", weil SQLAlchemy per Default alle gemappten Spalten selektiert. Dieselben Spalten stehen in `__protected_columns__` — und eine geschützte Spalte ist eine **Lese**beschränkung: sie fällt aus der `SELECT`-Liste der Laufzeit-Rolle und geht an die enge Rolle, `INSERT` und `UPDATE` bleiben. Wird sie auch schreibend entzogen, liefe der Spur-Insert der Schreibschicht unter der engen Rolle und scheiterte an `change_log` statt an der Spalte. Die einzige Ausnahme — Straf-Aussetzung und Pflicht-Erlass im Putzdienst, eine Schreib- und keine Lesebeschränkung — steht in `schema/putzdienst-schema.sql`.

## Was nicht in diesen Durchgang gehört

- **Änderungen an der Schreibschicht.** Sie steht und trägt dreizehn Domänen; eine vierzehnte fügt sich ein oder meldet einen Fund.
- **Router, Endpunkte, Pydantic-Modelle.** Erst wenn die Domäne steht.
- **Jede Änderung an `wb-docs`.** Auch keine „offensichtliche" Korrektur in der `.sql`. Was dort falsch aussieht, kommt auf die Findungsliste.

## Rangfolge bei Widerspruch

1. **`../wb-docs/schema/DOMÄNE-schema.sql`** — was dort steht, gilt.
2. **`CLAUDE.md` dieses Repos** — für die Form des Codes, nie für den Inhalt des Modells.
3. Sonst nichts. Dein Geschmack steht nicht in dieser Liste.

**Kann das Modell etwas nicht ausdrücken, was die `.sql` verlangt** — eine Constraint-Form, ein Index-Prädikat, ein Typ —, geht die Regel als `op.execute()` in die Migration und der Punkt auf die Findungsliste. Sie geht nie verloren, und sie wird nie „vereinfacht".

## Die Abnahme

Nicht mit Augenmaß, sondern mit Rückgabewerten. Vier Läufe, alle vier nennst du am Ende:

1. **`ruff check .`, `ruff format --check .`, `mypy app tests` und `pytest`** — alle vier sauber. `pytest` schließt `tests/test_privileges.py` ein: es meldet jedes Tabellenrecht, das zu breit vergeben ist.
2. **`alembic upgrade head` gegen eine frische Datenbank**, danach `alembic check` — es meldet jede Abweichung zwischen Modell und Datenbank. Die Migration liest du vorher **von Hand durch**; `--autogenerate` ist ein Entwurf und kein Ergebnis (`CLAUDE.md` §6).
3. **Alle Prüfskripte gegen die von Alembic gebaute Datenbank**, nicht nur das der eigenen Domäne: `./schema-check.sh` in `wb-backend`. Es druckt je Datei einen Rückgabewert und endet selbst rot, sobald einer nicht 0 ist.
4. **Der Katalogabgleich.** Lade die `.sql` in eine zweite Datenbank desselben Clusters und vergleiche beide Kataloge — Spalten mit Typ, Nullbarkeit, Vorgabe und Identity, Constraints mit `pg_get_constraintdef`, Indizes mit `pg_get_indexdef`, alles sortiert. Kein Unterschied heißt: treu übertragen, und zwar ohne Augenmaß. Ein Prüfskript sieht nur, wonach es fragt; der Abgleich sieht alles.

```
docker compose --profile tools down -v && docker compose up -d
docker compose --profile tools run --rm migrate && docker compose --profile tools run --rm migrate alembic check
./schema-check.sh
docker compose --profile tools run --rm test sh -c \
    'ruff check . && ruff format --check . && mypy app tests && pytest -q'
```

**Die Skripte selbst bleiben unverändert**, und was der Lauf um sie herum tun muss — die gesäten Wertelisten in derselben Transaktion räumen, den Rückgabewert vor jeder Kommando-Ersetzung sichern —, steht im Skript und in `README.md` von `wb-backend`, nicht hier.

**Alle Prüfskripte, nicht nur das der eigenen Domäne.** Ein Skript mit erfundenen Fremdschlüssel-Werten läuft grün, solange die Zieltabelle fehlt — erst gegen die vollständige Datenbank sagt es etwas aus.

## Was du lieferst

**Datei anfassen erst nach meinem OK.** Bis dahin steht alles in deiner Antwort.

1. **Das Modellmodul**, vollständig — kein Auszug, keine „hier analog weiter"-Stelle.
2. **Die Migration**, samt der `op.execute()`-Blöcke, von dir durchgesehen und nicht bloß erzeugt.
3. **Die Rückgabewerte** aus der Abnahme, je einer in einer Zeile.
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
