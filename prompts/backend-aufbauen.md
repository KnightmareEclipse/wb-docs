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
nachträglich einzieht (`TODO-SESSIONS.md`). **Der Entwurf steht, du baust ihn** — nicht deiner.

Sie hängt an **SQLAlchemy-Session-Events und nicht an einer Repository-API**. Der Grund ist der
Zweck der Schicht: Eine API mit `writer.update(...)` ist umgehbar, weil `session.add()` daneben
weiter funktioniert und nichts meldet, wenn jemand sie nimmt. Ein Event sieht jede ORM-Änderung
bauartbedingt. Vier Haken, alle gegen Postgres 18 vorgemessen:

- **`get_db()`** öffnet **eine** Transaktion je Anfrage, setzt darin den Aktor über
  `select set_config('app.actor', :actor, true)` — der dritte Parameter ist `SET LOCAL`, und nur
  diese Form nimmt einen gebundenen Wert (§6) — und legt ihn zusätzlich in `session.info`. Die
  Endpunkte committen damit nicht mehr selbst: Änderung, Spur und `app.actor` sind eine Einheit
  oder keine.
- **`before_flush`** setzt `created_by` an jeder neuen Zeile aus dem Aktor. Hier, weil die Objekte
  noch veränderbar sind.
- **`after_flush`** schreibt die `change_log`-Zeilen. Hier, weil die Schlüssel erst danach stehen —
  gemessen: der Haken sieht `insert` mit vergebenem Schlüssel, `update` mit Alt- und Neuwert je
  Spalte (`get_history`) und `delete`.
- **`do_orm_execute`** wirft, wenn ein `update()`/`delete()` gegen eine gemappte Tabelle läuft. Das
  ist der einzige Weg am ORM vorbei, und er wird damit laut statt still.

**Zwei Verträge, die jedes Modell erfüllt.** Fehlt einer, wirft die Schicht beim Flush — ein Modell
kann sie also nicht vergessen:

- `__change_anchor__: ClassVar[str | None]` — `"person_id"`, `"child_id"`, `"family_id"` oder
  ausdrücklich `None`. Die Schicht liest das gleichnamige Attribut und setzt daraus den Löschanker;
  `None` heißt „ohne Personenbezug" und gilt für Wertelisten. `ck_change_log_single_anchor` lässt
  höchstens einen zu. **Grenze, benannt:** gelesen wird ein direktes Attribut. Eine Tabelle, deren
  Anker erst über einen Join zu finden ist, ist ein Fund und keine stille Erweiterung.
- `__protected_columns__: ClassVar[frozenset[str]]` — dieselben Spalten, die `deferred()` tragen.
  Ihre Werte gehen **nicht** in die Spur, sondern als Platzhalter hinein.

Der letzte Punkt ist keine Vorsicht, sondern eine Lücke, die sonst offen bliebe: `change_log` trägt
keine enge Rolle, `backend_runtime` liest es tabellenweit. Schriebe die Schicht den Konfessionswert
in `old_value`, wäre das Spalten-GRANT auf `children` über die Spur umgangen — und
`tests/test_privileges.py` sähe es nicht, weil an `change_log` keine enge Rolle hängt. **Bau die
Gegenprobe dazu:** eine Änderung an einer geschützten Spalte hinterlässt eine Spurzeile, die den
Wert nicht enthält.

**Die Zeilenform** folgt den CHECKs in `querschnitt-schema.sql`: je geänderter Spalte eine Zeile mit
`column_name`, `old_value`, `new_value`; `insert` und `delete` je eine Zeile ohne `column_name`, mit
dem neuen bzw. alten Stand als kompaktes JSON der Zeile ohne die geschützten und ohne die
Audit-Spalten. Nicht nur der Schlüssel: den trägt `row_id` schon, ein zweites Mal daneben wäre ein
zweiter Ort für dieselbe Tatsache (`rules.md` Abschnitt 1) und ließe `ck_change_log_values` leer
laufen, dessen Kommentar ausdrücklich „das Anlegen trägt den neuen Stand, das Löschen den alten"
verlangt. Nach dem Löschen einer `employee_roles`-Zeile wäre sonst auch nicht mehr feststellbar,
welche Rolle entzogen wurde — und genau dafür steht `operation` laut Schema-Kommentar da.

**Die enge Rolle** kommt über einen Kontextmanager, der `SET LOCAL ROLE` und danach `RESET ROLE` in
der laufenden Transaktion fährt — **kein zweiter Pool**. Der Rollenname kommt aus einem Enum und nie
aus einem String: `SET ROLE` nimmt keinen gebundenen Wert.

**Der Aktor** trägt sein Präfix (`entra:`/`guardian:`/`system:`) und wird **im Code** geprüft, bevor
er gesetzt wird — sonst schlägt er erst als CHECK-Verletzung beim Insert auf, und dann steht der
Fehler weit weg von der Ursache. Er kommt aus `CurrentUser` (`app/core/security.py`), bei einem
maschinellen Lauf als `system:<name>` von der aufrufenden Stelle.

**Der Preis, ausdrücklich:** Massenoperationen sind damit verboten. Der Schuljahreswechsel und der
Lösch-Lauf gehen später Objekt für Objekt durchs ORM oder melden sich ausdrücklich ab und schreiben
ihre Spur selbst. Das ist die Absicht — nicht ein Versehen, das später jemand „optimiert".

Wohnort: `app/db/changelog.py` für die Schicht, `app/db/session.py` für Aktor und
Transaktionsgrenze, die beiden Verträge an `Base` (`app/db/base.py`). Sonst nichts (§14).

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
