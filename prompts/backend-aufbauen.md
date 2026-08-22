# Prompt: `wb-backend` bis zur ersten Endpunkt-Zeile aufbauen

Ein Durchgang, autonom, ohne Rückfrage. Am Ende steht das vollständige Schema in einer frisch
aufgesetzten Datenbank, und die nächste Session kann Endpunkte schreiben, ohne vorher etwas
nachzuholen.

Der Auftrag läuft in **`wb-backend`**. `wb-docs` ist Quelle und wird nur gelesen — mit der einen
Ausnahme unten.

Vorher `git status` sauber, Effort `xhigh`, Thinking an. Alles unter dem Strich ist der Prompt.

---

Du baust `wb-backend` von einem geprüften Gerüst bis zu dem Punkt aus, an dem die Fachlogik
anfangen kann: 99 Tabellen aus vierzehn Schema-Dateien als Modelle und Migrationen, die Rollen und
Spaltenrechte dazu, und die Schreibschicht, ohne die kein Endpunkt geschrieben werden darf.

**Du arbeitest durch, ohne mich zu fragen.** Jede offene Entscheidung wird eine `[A]`-Marke nach
`gemeinsam.md` und trägt weiter; eine Frage hielte an und ist deshalb hier keine Option. Kommst du
an eine Stelle, an der auch eine Annahme nicht trägt, hältst du **nur an dieser Stelle** an,
arbeitest alles andere fertig und schreibst am Ende hin, was blockiert ist und warum.

## Was du zuerst liest

`wb-backend/CLAUDE.md` (Code-Stil, verbindlich — **alle `§`-Verweise unten meinen sie**),
[`gemeinsam.md`](gemeinsam.md) und [`schema-uebertragen.md`](schema-uebertragen.md). Der letzte ist
der Auftrag für **eine** Domäne; er gilt hier je Domäne unverändert weiter, **bis auf** seine
Interaktionsregeln: kein „Datei anfassen erst nach meinem OK", keine Fragenrunde. Was er als Frage
vorsieht, wird hier eine `[A]`-Marke.

Dazu `../wb-docs/TODO-SESSIONS.md`, Abschnitt „Für `wb-backend`" — dort stehen die Fallen
ausgeschrieben, samt der an Postgres 18 gemessenen Mechaniken, nach denen die Migrationen aussehen
müssen.

**Das liest du selbst.** Ein Subagent darf eine Fundstelle suchen, nicht urteilen (`gemeinsam.md`).

## Die Reihenfolge, und warum sie so ist

**Schritt 1 — `stammdaten`.** Die Ladereihenfolge des Schemas beginnt hier, alles andere hängt
daran. Mit dieser Domäne entstehen auch die ersten beiden engen Rollen (`backend_sensitive`,
`backend_finance`) und das `deferred()` auf `children.denomination_id`/`congregation`. Letzteres
muss stehen, **bevor** die erste Abfrage gegen `children` läuft: ohne es scheitert jedes
Vollobjekt-Laden an „permission denied for column", und die naheliegende Reparatur unter Zeitdruck
wäre ein tabellenweites `GRANT`, das den ganzen Mechanismus abräumt.

**Schritt 2 — `querschnitt`.** Bringt `change_log` und damit die Voraussetzung für Schritt 3.

**Schritt 3 — die Schreibschicht.** Vor allen weiteren Domänen, weil sie kein Punkt ist, den man
nachträglich einzieht (`TODO-SESSIONS.md`). Sie besteht aus zwei Teilen, die zusammengehören:

- **`app/db/session.py` umbauen.** `get_db()` hat heute weder eine ausdrückliche
  Transaktionsgrenze noch Zugriff auf den Aufrufer. Beides braucht es: `SET LOCAL app.actor` je
  Transaktion, und `SET LOCAL ROLE` für eine enge Rolle im selben Block. **Kein zweiter Pool** —
  die enge Rolle ist `NOLOGIN` und wird in der laufenden Transaktion gewählt. Der Aktor trägt ein
  Präfix (`entra:`/`guardian:`/`system:`), das je Tabelle ein CHECK erzwingt; er kommt aus
  `CurrentUser` (`app/core/security.py`) und für Systemläufe von der aufrufenden Stelle.
- **Eine gemeinsame Stelle, durch die jede Änderung läuft**, die `created_by` setzt und die Zeile
  in `change_log` schreibt. Ein Schreibpfad daran vorbei hinterlässt keine Spur und meldet nichts —
  deshalb ist die Stelle die einzige, nicht die bequemste. Wie sie geschnitten ist, entscheidest du;
  schreib eine `[A]`-Zeile dazu.

Baue sie so klein, wie sie sein kann (§14). Sie hat heute genau einen Abnehmer — die Tests, die du
für sie schreibst —, und ihr Wert liegt darin, dass die vierzehn Domänen danach keine Wahl mehr
haben.

**Schritt 4 — die übrigen elf Domänen**, in beliebiger Folge, solange die Fremdschlüssel tragen.
Je Domäne ein eigener Durchlauf nach `schema-uebertragen.md`, ein eigener Commit.

**Schritt 5 — die Abnahme über alles.** Siehe unten.

## Je Domäne: fertig heißt fertig

Eine Domäne ist erst abgeschlossen, wenn sie **alle fünf** Punkte hat. Nicht vier, und der Rest
kommt später — genau daraus entsteht der Bestand, dem hinterher niemand ansieht, wo er unfertig ist.

1. Modellmodul in `app/models/DOMÄNE.py`, jede Tabelle und jedes benannte Constraint der `.sql`.
2. Eine Migration, von Hand durchgesehen — `--autogenerate` ist ein Entwurf (§6).
3. Die `GRANT`s je Tabelle als `op.execute()`, `UPDATE` spaltenweise, geschützte Spalten außen vor.
4. Das Prüfskript der Domäne grün, mit `-v ON_ERROR_STOP=1`.
5. Ein Commit, dessen Nachricht sagt, warum etwas anders ist als in der `.sql` — nicht, was drinsteht.

## Die Abnahme, mit Rückgabewerten

Nicht mit Augenmaß. Am Ende führst du alles gegen eine **frisch aufgesetzte** Datenbank aus
(`docker compose --profile tools down -v`, dann hoch), damit die Kette „leerer Cluster →
`init-roles.sh` → alle Migrationen → vollständiges Schema" bewiesen ist und nicht bloß der Zustand,
der bei dir gewachsen ist.

```
docker compose --profile tools down -v && docker compose up -d
docker compose --profile tools run --rm migrate
for f in ../wb-docs/schema/*-schema-check.sql; do
    docker compose exec -T db psql -U backend_migrator -d weltenbaum -v ON_ERROR_STOP=1 -q < "$f"
    echo "$(basename "$f") rc=$?"
done
docker compose --profile tools run --rm test sh -c \
    'ruff check . && ruff format --check . && mypy app tests && pytest -q'
```

**Alle vierzehn Prüfskripte, nicht nur die der zuletzt gebauten Domäne.** Ein Skript mit erfundenen
Fremdschlüssel-Werten läuft grün, solange die Zieltabelle fehlt — erst gegen die vollständige
Datenbank sagt es etwas aus.

Dazu drei Gegenproben, die keine Datei prüft, sondern das Verhalten:

- **Art. 9:** ein `SELECT children.denomination_id` als `backend_runtime` scheitert; über
  `SET LOCAL ROLE backend_sensitive` in derselben Transaktion gelingt er.
- **Schlüsselspalten:** ein `UPDATE` auf eine Primärschlüsselspalte scheitert als `backend_runtime`.
- **Die Spur:** ein Schreibvorgang über die Schreibschicht hinterlässt genau eine `change_log`-Zeile
  mit präfigiertem `created_by`; einer daran vorbei ist im Code nicht möglich, und du zeigst, woran.

## Was nicht in diesen Durchgang gehört

- **Router, Endpunkte, Pydantic-Modelle.** Das ist der nächste Auftrag, und dieser hier hat ihn
  vorzubereiten, nicht vorwegzunehmen.
- **Import echter Daten.** `TODO-SESSIONS.md` hat dazu eigene offene Punkte.
- **Änderungen an `wb-docs`** — mit einer Ausnahme: Findest du in einer `.sql` einen echten Fehler,
  änderst du sie **nicht**, sondern schreibst ihn auf die Findungsliste. Erledigt eine deiner
  Entscheidungen einen offenen Punkt in `TODO-SESSIONS.md`, darfst du dort nachziehen.

## Rangfolge bei Widerspruch

1. **`../wb-docs/schema/*.sql`** — was dort steht, gilt, samt Kommentaren.
2. **`../wb-docs/idea/`** — die bindenden Bedingungen für Rollen, Rechte, Netze, Secrets. Sie werden
   in `TODO-SESSIONS.md` nicht wiederholt; lies sie, bevor du an einer davon etwas anders machst.
3. **`CLAUDE.md` von `wb-backend`** — für die Form des Codes, nie für den Inhalt des Modells.
4. Sonst nichts.

## Was du am Ende lieferst

Höchstens fünfundzwanzig Zeilen Prosa; Listen und Code zählen nicht mit.

- **Die Rückgabewerte:** vierzehn Prüfskripte, die vier Werkzeuge, die drei Gegenproben. Je einer
  eine Zeile.
- **Die Annahmen** `A1, A2 …` — jede mit Aussage, Alternative, Preis (`gemeinsam.md`). Sie stehen
  außerdem als `[A]`-Zeile an der Stelle, an die sie gehören.
- **Die Findungsliste** `R1, R2 …` — je Eintrag eine Zeile: was, wo, dein Vorschlag. Darauf gehört,
  was die `.sql` verlangt und das Modell nicht ausdrücken kann (samt der Stelle, an der es als
  `op.execute()` gelandet ist), wo die `.sql` sich selbst oder ihrem Prüfskript widerspricht, und
  welche Regel aus einem Prüfskript im Modell keinen Träger hat.
- **Was blockiert ist**, falls etwas blockiert ist — mit dem Grund, nicht mit einer Absichtserklärung.
- **Ein Satz zum Stand:** was die nächste Session vorfindet, wenn sie den ersten Endpunkt schreibt.

Kürze die Listen nie gegen ein Budget. Und schreib nicht, was du geprüft und nicht gefunden hast.
