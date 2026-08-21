# Prompt: der Umzug — ein Repo statt zwei

> **Ausgeführt — `wb-brainstorming` ist in dieses Repo aufgelöst.** Er liegt als Beleg daneben und
> wird nicht nachgezogen; die Pfade darin nennen den Vorentwurf, den er gelöscht hat.

Einmalig, kein Zyklus. Danach ist dieser Prompt erledigt und wandert mit.

`wb-brainstorming` heißt so, ist es aber nicht mehr: dort liegen 100 Commits, fünf abgeschlossene
Prüfzyklen und der einzige vollständige Stand des Datenmodells — **ohne Remote**. `wb-docs` hat das
Remote, wurde zuletzt am 13. August angefasst und schickt über seine `CLAUDE.md` jede neue Sitzung
zuerst in den Vorentwurf, den derselbe Stand längst überholt hat. Dieser Prompt löst
`wb-brainstorming` in `wb-docs` auf.

Effort `xhigh`. Vorher `git status` in **beiden** Repos sauber (bis auf das, was dort schon
ungetrackt liegt — das bleibt, siehe unten). Alles unter dem Strich ist der Prompt.

---

## Die eine Regel, aus der der Rest folgt

**In `wb-docs` stehen zwei Sorten Inhalt, und nur eine zieht um.**

- **Prozess und Datenmodell** — wie ein Vorgang künftig läuft, wer welche Tatsache besitzt, welche
  Tabelle es gibt. Hier schlägt `wb-brainstorming` alles, was in `wb-docs` steht, ohne Ausnahme und
  ohne Abwägung im Einzelfall. Der Stand dort ist aus den Soll-Blöcken gebaut, gegen sie geprüft und
  fünfmal angegriffen worden; der Stand in `wb-docs/domains/` ist der Vorentwurf und „schlägt gar
  nichts" (`schema-reparatur-prompt.md`).
- **Alles andere** — VPS, Container-Runtime, Identität und Zugriff, Backup, DSGVO-Organisation,
  Repo-Struktur, das Rollen-Vokabular, die Planungsprinzipien. Das ist **nicht Gegenstand dieses
  Umzugs**. Es wird nicht bewertet, nicht nachgezogen und nicht angefasst — außer ein Pfad darin
  zeigt nach dem Umzug ins Leere.

Wo eine Datei beides trägt, gilt: **Pfade richten, Inhalt stehen lassen.** Ein Satz, der inhaltlich
veraltet ist, wird nicht umgeschrieben — er wird gemeldet. Die einzige Ausnahme steht unten bei
`CLAUDE.md`.

## Was umzieht

Aus `wb-brainstorming` nach `wb-docs`, mit `git mv` bzw. `git add`, damit die Historie lesbar bleibt
(59 getrackte Dateien, sonst nichts):

| von | nach |
|---|---|
| `schema/` (28 Dateien: 14 Schemata, 14 Prüfskripte) | `wb-docs/schema/` |
| `soll-prozesse/` (20 Dateien, darunter `hebel.md`, `README.md`, `anleitung.md`) | `wb-docs/soll-prozesse/` |
| `prozesse.md` (518 Zeilen) | `wb-docs/prozesse.md` — **ersetzt** die dortige (508 Zeilen) |
| `prozessblock-prompt.md`, `schema-prompt.md`, `schema-bau-prompt.md`, `schema-pruef-prompt.md`, `schema-reparatur-prompt.md` | `wb-docs/` |
| `pruefbericht-01.md` … `pruefbericht-05.md` | `wb-docs/` |
| diese Datei | `wb-docs/` |

Die beiden `prozesse.md` liegen 18 Zeilen auseinander; die neuere ist die ältere plus zehn Zeilen.
Trotzdem: **diffen, bevor du überschreibst**, und melden, was die alte trug und die neue nicht.

## Was weicht

Der Vorentwurf in `wb-docs/domains/`, weil er ab jetzt zwei Antworten auf dieselbe Frage gäbe:

- `domains/*-schema.sql`, `domains/*-schema-check.sql`, `domains/stammdaten-schema-plain.sql`
- die sieben Vorentwurfs-Notizen `domains/anmeldung.md`, `ferien.md`, `gesundheit.md`,
  `klassenorganisation.md`, `mensa.md`, `putzdienst.md`, `stammdaten.md`
- `domains/stammdaten-benchmark/` und `domains/stammdaten-schema-benchmark.md` — der Benchmark misst
  ein Schema, das es nicht mehr gibt

## Was bleibt, obwohl es nach Schema aussieht

Nicht anfassen, nicht ersetzen, nicht in den neuen Ordner ziehen:

- **`domains/grenzkarte.md`** — Rang 3 der Rangfolge und aus den Schemadateien 97× zitiert. Sie ist
  kein Vorentwurf, sie ist die Karte, gegen die gebaut wurde. Sie bleibt, wo sie ist.
- **`rules.md`** — 112× zitiert, und trägt daneben die Planungsprinzipien des ganzen Vorhabens.
- **`glossar.md`** — das repo-übergreifende Rollen-Vokabular.
- **`idea/`, `pipeline/`, `project-parts.md`** — Infrastruktur. Kein Blick hinein außer wegen Pfaden.

## Was du nicht löschst

**Was `git` nicht kennt, fasst du nicht an.** In `wb-docs` liegen ungetrackt: `.claude/`, die sieben
`*.dbm` (pgModeler-Modelle des Vorentwurfs) und `soll-prozesse.md` (die leere Vorlage, deren
ausgefüllte Form als `soll-prozesse/README.md` mitkommt). Alles davon ist inhaltlich überholt und
alles davon ist unwiederbringlich, wenn du danebengreifst. Du **listest** es am Ende auf, mit einem
Satz je Datei, was ich damit tun sollte. Entscheiden tue ich.

## Die Verweise

Das ist das eigentliche Stück Arbeit. Nach dem Umzug zeigen Pfade quer durch `wb-docs` ins Leere.
Bekannte Fundstellen mit Trefferzahl, als Anhalt und nicht als Liste zum Abhaken — du zählst selbst
nach:

`domains/grenzkarte.md` 27 · `fachdomaenen.md` 28 · `TODO.md` 22 · `glossar.md` 16 ·
`.claude/commands/pruefen.md` 14 (ungetrackt) · `CLAUDE.md` 11 · `TODO-SESSIONS.md` 10 ·
`idea/03`, `idea/04`, `idea/06` zusammen 11 · `project-parts.md` 4 · `rules.md` 3

Die Regel je Fundstelle:

- **Zeigt der Pfad auf etwas, das es weiter gibt** (nur woanders) — Pfad richten, Satz stehen lassen.
- **Zeigt er auf etwas, das gestorben ist** — gibt es ein Gegenstück im neuen Stand, zeig darauf;
  gibt es keines, nimm den Verweis heraus und lass den Satz sonst, wie er ist.
- **Steht der Satz inhaltlich quer zum neuen Stand** — nicht umschreiben. Eine Zeile in den Bericht,
  und ich entscheide. Das gilt besonders für `fachdomaenen.md` und `TODO.md`: dort steht Planung,
  keine Wegweisung, und Planung ändere ich selbst.
- **Ungetrackte Datei** (`.claude/commands/pruefen.md`) — nicht anfassen, nur melden.

## `CLAUDE.md` ist die eine Ausnahme

Sie ist der Wegweiser, den jede Sitzung automatisch liest. Bleibt sie, wie sie ist, liest die nächste
Sitzung wieder den Vorentwurf — dann war der ganze Umzug umsonst. Hier schreibst du, und zwar nur
diese drei Dinge:

1. Der Satz „Gebaut sind die Schemata **Stammdaten**, **Putzdienst**, … " nennt sieben Domänen. Es
   sind vierzehn, samt Querschnitt, jede mit Prüfskript, und der Stand ist durch fünf Prüfzyklen
   gegangen. Nenn sie und nenn den Ort.
2. Der Abschnitt „Einstieg in eine Session" schickt in `domains/*.md` und `domains/*-schema.sql`.
   Er schickt künftig in `soll-prozesse/` und `schema/`; `domains/grenzkarte.md` und `rules.md`
   bleiben darin stehen, wo sie stehen.
3. Der Satz unter „Nächster Schritt" nennt die „Übertragung aller sieben Schemata". Vierzehn.

**Alles Übrige in `CLAUDE.md` — VPS, Härtung, Podman, Compose-Stack, Git-Identität,
Vertrauensgrenze, Leitprinzip — rührst du nicht an.** Auch nicht, wenn dir etwas veraltet vorkommt.

## Wann du fragst

Dieselbe Frage wie sonst: **Entscheidet der Auftrag die Sache?**

- **Er entscheidet sie** — mach es. Das ist der Normalfall: verschieben, löschen, Pfad richten.
- **Zwei Formen tragen sie gleich gut** — nimm die, die weniger Zeilen bewegt, und schreib es in den
  Bericht.
- **Er entscheidet sie nicht** — frag, in einem Zug am Ende. Nicht raten, und nichts
  „vorsichtshalber" stehenlassen oder löschen. Je Frage: Datei, was die Antwort entscheidet, zwei bis
  vier Möglichkeiten, deine Empfehlung zuerst.

## Die Gegenprobe

Ohne sie ist der Umzug nicht fertig. Drei Läufe, jeder mit Rückgabewert und nicht mit Augenmaß:

1. **Kein toter Pfad.** Über alle `*.md` in `wb-docs` jeden Markdown-Link und jeden Pfad in
   Backticks einsammeln, der auf eine Datei im Repo zeigt, und prüfen, ob es sie gibt. Ein kleines
   Skript, kein Werkzeug. Es läuft danach ohne Treffer — und du zeigst mir, dass es vor dem Richten
   Treffer hatte, sonst prüft es nichts.
2. **Das Schema lädt weiter.** Aus dem neuen Ort in eine leere Datenbank, in der Reihenfolge
   `stammdaten`, `querschnitt`, Rest; danach alle vierzehn Prüfskripte gegen die vollständige
   Datenbank. Rückgabewert je Datei.

   ```
   podman run --rm -d --name wb-umzug -e POSTGRES_PASSWORD=x docker.io/library/postgres:17
   podman exec -i wb-umzug psql -U postgres -v ON_ERROR_STOP=1 -q < schema/stammdaten-schema.sql
   ```

   `-v ON_ERROR_STOP=1` ist kein Beiwerk: ohne den Schalter endet auch ein gescheiterter Lauf mit 0.
3. **Nichts verloren.** `git -C wb-docs status` ist sauber bis auf genau das, was vorher schon
   ungetrackt war — keine Datei mehr, keine weniger. Und `git -C wb-brainstorming status` ist
   unverändert: dieses Repo rührst du nicht an.

## Die Commits

Vier, alle in `wb-docs`, alle am Ende, wenn die drei Läufe durch sind. **Nicht pushen.**

```
Schema: der geprüfte Stand ersetzt den Vorentwurf
Soll-Prozesse und prozesse.md ziehen nach
Prüfberichte und Prompts ziehen nach
Verweise gerichtet, CLAUDE.md zeigt auf den neuen Stand
```

`wb-brainstorming` bleibt vollständig stehen, bis ich den Umzug abgenommen habe. Es zu löschen ist
ein eigener Schritt und nicht deiner.

## Was du nicht tust

- **Kein Inhalt wird umgeschrieben.** Du bewegst Dateien und richtest Pfade. Ein Satz, der falsch
  geworden ist, wird gemeldet, nicht repariert — `CLAUDE.md` mit ihren drei benannten Stellen
  ausgenommen.
- **Nichts an der Infrastruktur.** `idea/`, `pipeline/`, `project-parts.md`, `wb-vps`, `wb-backend`
  bleiben unberührt. Auch `wb-backend` bekommt jetzt nichts — das Schema ist die Quelle, die
  Alembic-Migration das Abgeleitete, und das ist ein eigener Auftrag.
- **Nichts Ungetracktes wird gelöscht.**
- **`wb-brainstorming` wird nicht angefasst.**
- **Kein Aufräumen im Vorbeigehen.** Keine Umbenennung, keine Formatierung, kein „das war schon
  vorher unsauber".
- **Kein Subagent bewegt Dateien oder entscheidet.** Suchen darf er — eine Fundstelle, ein Pfad über
  alle Dateien. Nicht ändern, nicht nachprüfen, was du geändert hast.

## Was du meldest

Je Schritt **eine Zeile**: was bewegt wurde, wie viele Dateien, Gegenprobe ja oder nein. Kein
Vorlesen dessen, was du gerade liest.

Am Ende höchstens zwanzig Zeilen:

- die drei Rückgabewerte (toter Pfad, Ladelauf, Prüfskripte),
- die ungetrackten Dateien in `wb-docs`, je eine Zeile mit deinem Vorschlag,
- jeder Satz, den du inhaltlich quer zum neuen Stand fandest und **nicht** angefasst hast — Datei,
  Zeile, worum es geht. Die führst du vollständig auf; die kürze ich nicht gegen ein Budget ein.
- was an einer Antwort von mir hängt.

Kein Schlussabsatz, der das Ergebnis würdigt, keine „nächsten Schritte": Der nächste Schritt ist,
dass ich lese.
