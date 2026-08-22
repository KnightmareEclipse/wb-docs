# Prompt: das Grundgerüst von `wb-backend` gegenlesen

Einmalig, kein Zyklus. Danach ist dieser Prompt erledigt und wird gelöscht — wie der Umzugs-Prompt vor ihm.

Der Anlass steht in `TODO.md`: Das Grundgerüst ist **nicht selbst geschrieben** und noch nie gegen die eigene `CLAUDE.md` gelesen worden. Darauf sollen als Nächstes vierzehn Domänen stapeln.

Der Lauf ist nur etwas wert, wenn er unabhängig ist: **eine frische Session in `wb-backend`**, die das Gerüst nicht gebaut hat. Vorher `git status` sauber. Effort `high`; Thinking anlassen. Alles unter dem Strich ist der Prompt.

---

Wir lesen das Grundgerüst dieses Repos gegen. Es sind rund 700 Zeilen in 20 Dateien, sie laufen produktiv, und niemand hat sie je gegen die Regeln geprüft, die in `CLAUDE.md` dieses Repos stehen.

**Du meldest, ich entscheide.** Du reparierst nichts — auch nicht „das eine offensichtliche". Ein Bericht, den ich lese, ist mehr wert als ein Diff, den ich nachvollziehen muss.

## Der Maßstab

Zwei Fragen, in dieser Reihenfolge:

1. **Hält das Gerüst seine eigenen Regeln?** `CLAUDE.md`, sechzehn Abschnitte, jeder einzeln. Sie sind der Maßstab, nicht dein Geschmack und nicht das, was anderswo üblich ist.
2. **Trägt es vierzehn Domänen?** Nicht „läuft es" — es läuft ja. Sondern: Was bricht beim zehnten Modell, beim dritten Router, bei der ersten Migration mit `op.execute()`? Ein Fundament, das mit einem Health-Endpoint zufrieden ist, sagt darüber nichts.

## Zwei Läufe zuerst, sie nehmen dir Arbeit ab

```
docker compose --profile tools run --rm test ruff check .
docker compose --profile tools run --rm test mypy app
```

Beide mit Rückgabewert in den Bericht. Was sie melden, ist ein Fund wie jeder andere — was sie **nicht** melden, ist deine Arbeit: `ruff` und `mypy` sehen keinen der Abschnitte 4, 6, 7, 12, 14 und 16.

## Wonach du besonders siehst

Nicht als Liste zum Abhaken — das sind die Stellen, an denen die nächste Sitzung aufsetzt und ein Fehler teuer wird:

- **`app/db/base.py`** — trägt `Base` alles, was die vierzehn Domänen brauchen? Dass die `naming_convention` noch fehlt, ist bekannt und **kein Fund**; sie kommt mit der ersten Domäne.
- **`app/alembic/env.py`** — läuft es wirklich unter der Migrations-Rolle und nie unter der Laufzeit-Rolle (§6)? Findet `target_metadata` die Modelle, sobald es welche gibt?
- **`app/db/session.py`** — 19 Zeilen. Nutzt der Laufzeit-Pfad die Laufzeit-Rolle? Und: Die Übertragung wird je Transaktion `SET LOCAL app.actor` setzen müssen und für den Art.-9-Bestand eine zweite, engere Rolle wählen (`../wb-docs/TODO-SESSIONS.md`). Ist dafür Platz, oder muss die Datei dafür umgebaut werden?
- **`app/core/config.py`** — hält die `<NAME>_FILE`-Konvention aus §4 wirklich, und gibt es irgendwo ein `os.environ` daneben (§5)?
- **`app/core/security.py`** — Token-Validierung genau **einmal**, als Dependency (§7). Landet nie ein Claim in einem Log, auch nicht im Fehlerfall?
- **`docker-compose.yml`** — §16 Punkt für Punkt: non-root, read-only Rootfs samt `tmpfs`, CPU-/Speichergrenzen, `backend` und `db` nur im internen Netz, Secrets als Dateien, voll qualifizierte Images, `:z` an Bind-Mounts.
- **`db/init-roles.sh`** — es legt drei Rollen an und läuft **nur bei der Erstinitialisierung eines Clusters**. Dass die enger geschnittenen Rollen fehlen, ist **kein Fund** — sie entstehen je Domäne in deren Migration und nicht hier (`../wb-docs/TODO-SESSIONS.md`).
- **`Dockerfile`, `requirements*.in/.txt`** — die pip-tools-Kette (§2): Ist `requirements.txt` wirklich aus `requirements.in` kompiliert, und kann jemand sie versehentlich direkt bearbeiten?
- **`tests/`** — ein Test für einen Health-Endpoint. §12 verlangt echte Postgres statt Mock und einen Test je nicht-trivialem Zweig. Was fehlt, das **jetzt** fehlen darf, und was nicht?

## Was du nicht tust

- **Nichts reparieren.** Kein Diff, kein Commit, keine „ich hab's gleich mit erledigt"-Zeile.
- **Keine Modelle, keine Router, keine Migration.** Das ist der nächste Auftrag und nicht dieser.
- **`wb-docs` nicht anfassen.** Du liest dort, mehr nicht. Was dir dort falsch vorkommt, ist ein Fund.
- **Keine neue Abhängigkeit vorschlagen**, ohne die Leiter aus §14 durchgegangen zu sein — und dann mit dem Satz, an welcher Sprosse sie hängen bleibt.
- **Kein Subagent urteilt.** Suchen darf er; entscheiden nicht.

## Was du meldest

Höchstens fünfundzwanzig Zeilen Prosa, die Fundliste zählt nicht mit.

**Je Fund eine Zeile**, mit Kennung `F1, F2 …`, nach Gewicht sortiert:

> `F3` `app/core/config.py:31` — §5: liest `os.environ` direkt am `Settings` vorbei. Vorschlag: ins `Settings`-Feld ziehen.

Ein Fund nennt **Datei und Zeile, den verletzten Abschnitt, und was zu tun wäre** — in dieser Reihenfolge, ein Satz je Teil. Wo du dir nicht sicher bist, ob es einer ist, schreibst du ihn trotzdem hin und sagst dazu, was dagegen spricht.

Getrennt davon, als eigener kurzer Abschnitt: **Was bricht beim zehnten Modell?** Das ist die Frage aus Punkt 2 oben, und sie ist mir wichtiger als jeder Stilverstoß.

Am Ende die beiden Rückgabewerte von `ruff` und `mypy`.

**Kürze die Fundliste nie gegen ein Budget.** Ein unterschlagener Fund kostet mich mehr als zehn Zeilen. Und schreib nicht, was du geprüft und nicht gefunden hast — „sauber" sagt der fehlende Fund.
