# Prompt: die letzten Schritte vor dem ersten Endpunkt

Ein Durchgang, autonom, ohne Rückfrage. Am Ende hat eine frisch aufgesetzte Datenbank alles, was
ein Endpunkt an Werten voraussetzt, und der Backend-Container bekommt seine echte Tenant-Kennung,
ohne dass jemand eine Datei im Repo ändert.

Der Auftrag läuft in **`wb-backend`**. `wb-docs` ist Quelle und wird gelesen — mit den beiden
Ausnahmen unten.

Vorher `git status` sauber, Effort `xhigh`, Thinking an. **Dieser Prompt ist einmalig und wird nach
dem Lauf gelöscht.** Alles unter dem Strich ist der Prompt.

---

Drei Dinge stehen zwischen dem fertigen Datenmodell und dem ersten Endpunkt. Keines davon ist
Fachlogik, und keines davon lässt sich später nachziehen, ohne dass jemand in der Zwischenzeit eine
Abkürzung nimmt.

**Du arbeitest durch, ohne mich zu fragen.** Jede offene Entscheidung wird eine `[A]`-Marke nach
[`gemeinsam.md`](gemeinsam.md) und trägt weiter. Jeder Wert, den kein Dokument nennt, wird eine
`[?]`-Marke mit Adressat — **nichts ausdenken**. Kommst du an eine Stelle, an der auch eine Annahme
nicht trägt, hältst du nur dort an, arbeitest alles andere fertig und schreibst am Ende hin, was
blockiert ist und warum.

## Was du zuerst liest

`wb-backend/CLAUDE.md` (Code-Stil, verbindlich — **alle `§`-Verweise unten meinen sie**) und
[`gemeinsam.md`](gemeinsam.md). Dazu `../wb-docs/TODO-SESSIONS.md` (die Abschnitte „Die Wertelisten
sind leer" und „Dependabot") und die Zeilen in `../wb-docs/TODO.md`, die Entra-ID und die drei
Preislisten betreffen.

Für Aufgabe 2 zusätzlich `../wb-docs/soll-prozesse/hebel.md` (Rollen, Einsichtsstufe, Werte im
System), `../wb-docs/glossar.md` und **die Kopfkommentare der Wertelisten selbst** in
`../wb-docs/schema/*.sql` — dort steht je Liste, wofür ihr `code` einsteht und ob eine Regel auf ihn
verzweigt.

**Das liest du selbst.** Ein Subagent darf eine Fundstelle suchen, nicht urteilen (`gemeinsam.md`).

## Aufgabe 1 — die Tenant-Kennung muss von außen ankommen

`docker-compose.yml` schreibt `JWT_TENANT_ID: mock-tenant` und `JWT_AUDIENCE: mock-audience` als
literale Werte an den `backend`-Dienst. Ein literaler Wert im Compose-Dienst schlägt jede
Umgebungsdatei — die Produktion müsste also die Datei im Repo ändern, und genau das schließt §5 aus
(„production values come entirely from secret files / Compose environment, never hardcoded").

Nimm dieselbe Form, die `WB_SITE_ADDRESS` schon hat: eine Interpolation mit der Mock-Vorgabe als
Rückfall, für `backend` und für `test`. `README.md` sagt danach, welche Zeilen für die Produktion in
die (gitignorierte) `.env` gehören, und `secrets.example/` bleibt unberührt — eine Tenant-Kennung
ist kein Geheimnis, sondern öffentliche App-Konfiguration (`app/core/config.py`, Kopfkommentar).

**Was du nicht tust:** die Mock-Vorgaben aus `app/core/config.py` entfernen. Sie sind die lokale
Entwicklungsvorgabe (§5); ein Pflichtfeld ohne Wert bricht jeden Lauf, der keinen Tenant hat — und
das sind alle bis auf die Produktion.

Der Name des Rollen-Claims (`app/core/security.py` liest `roles`) lässt sich nur an einem echten
Token bestätigen. Das ist kein Codeschritt: er wird eine Zeile in `../wb-docs/TODO.md`, bei den
Punkten, die Tenant-Zugriff brauchen.

## Aufgabe 2 — die Wertelisten füllen, und zwar nur die richtigen

Einunddreißig Wertelisten stehen leer da. Der Schnitt ist nicht Geschmack, er folgt aus den
Kommentaren der `.sql`:

> Verzweigt der Anwendungscode auf den `code` einer Zeile, muss sie in **jedem** Cluster stehen —
> sie kommt mit einer Migration. Ist sie Inhalt, den ein Mensch pflegt, kommt sie **nicht** mit
> einer Migration; die Tabelle bleibt leer, bis er ihn einträgt.

Die erste Hälfte erkennst du am Kommentar „Der Code ist die Verankerung im Anwendungscode und wird
nie umbenannt; der Name darf jederzeit wandern" und an jeder Liste, deren Kennzeichen eine Regel
steuert — `application_statuses.is_final`, `health_trait_types` mit seinen fünf Flags,
`consent_purposes.requires_child`, `roles.is_branch_bound`, `school_branches` mit seinen beiden
Stufengrenzen. Die zweite Hälfte sind `kindergartens`, `previous_schools`, `payees`,
`cost_projects`, `ledger_accounts`, `sharepoint_libraries`, `contract_texts`, `configured_values`
und die vier Preistabellen: Namen, Beträge und Graph-Kennungen, die Geschäftsführung, Sekretariat,
Buchhaltung oder der Admin pflegen (`TODO.md`). **Eine leere Tabelle ist dort der richtige Zustand**
— prüf trotzdem jede einzeln gegen ihren Kommentar, statt der Aufzählung hier zu glauben.

**Woher der Inhalt kommt:** aus den Dokumenten, wo sie ihn nennen. Die sechzehn Rollen und die drei
Einsichtsstufen stehen in `hebel.md`, die Häuser und die beiden Schularten samt Stufengrenzen in
ihren Kommentaren, die Zwecke der Zustimmung in `grenzkarte.md` Q1. Nennt keine Quelle die Werte
einer Liste, **bleibt sie leer** und die Frage geht als `[?]`-Zeile mit Adressat nach
`../wb-docs/fragen.md`. Eine erfundene Zeile ist schlimmer als eine leere Tabelle: Sie sieht aus wie
eine Entscheidung.

**Wie die Zeilen hineinkommen:**

- Als ganz normale Revision in der Kette. Sie fügt Daten ein und keine Struktur; `alembic check`
  sieht sie deshalb nicht, und das ist richtig so.
- `created_by` trägt sein Präfix, sonst weist der CHECK die Zeile ab. `system:seed` genügt.
- **Kein `ON CONFLICT`, kein „falls schon da".** Alembic führt eine Revision genau einmal aus;
  Idempotenz noch einmal nachzubauen wäre der zweite Mechanismus für dieselbe Sache
  (`rules.md` Abschnitt 3). `downgrade()` räumt die Zeilen wieder weg.
- **Ein Fremdschlüssel zwischen zwei Listen wird über den `code` aufgelöst**, nie über eine geratene
  Zahl — jeder Schlüssel ist `GENERATED ALWAYS AS IDENTITY` und darf gar nicht mitgeschrieben
  werden. Das betrifft mindestens `sync_targets.role_id` und `care_modules.school_branch_id`.
- Ein Wert, der später wegfällt, wird `is_active = false` und keine Migration
  (`rules.md` Abschnitt 3). Die Migration setzt den Anfangsbestand; sie pflegt ihn nicht.

**Zwei Gegenproben, beide gehören zur Aufgabe:**

1. Ein Test, der für jede Liste, die mitkommen soll, prüft, dass sie nicht leer ist — mit einer
   Namensliste **im Test**, nicht aus der Migration abgeleitet. Sonst prüft er sich selbst.
2. Die Testfixtures dürfen den gesäten Bestand nicht wegräumen. `tests/test_changelog.py` leert
   heute unter anderem `denominations` mit `TRUNCATE … CASCADE`; nach dem Säen nimmt das den
   Anfangsbestand mit, und der nächste Test steht anders da als der erste. Das zu richten ist Teil
   dieser Aufgabe, nicht ein Nachzügler.

## Aufgabe 3 — Dependabot

`.github/dependabot.yml` nach `TODO-SESSIONS.md`, Abschnitt „Dependabot für die Base-Images
einschalten". Das `pip`-Ecosystem bewusst nicht; der Grund steht dort.

## Was nicht in diesen Durchgang gehört

- **Router, Endpunkte, Pydantic-Modelle.** Das ist der nächste Auftrag.
- **Die CORS-Policy.** Sie hängt am Hosting des Frontends (`project-parts.md` Abschnitt 10) und ist
  hier nicht entscheidbar.
- **Der OTP-Pfad und der `guardian:`-Aktor.** Das ist der erste Elternendpunkt, nicht seine
  Vorbereitung.
- **Echte Werte.** Tenant-Kennungen, Preise, Graph-Kennungen und Personendaten trägt ein Mensch ein.

## Änderungen an `wb-docs` — genau zwei Ausnahmen

1. `TODO.md` und `TODO-SESSIONS.md` nachziehen, wo dieser Lauf einen Punkt schließt oder einen neuen
   für einen Menschen hinterlässt.
2. `fragen.md`: jede Liste, deren Werte niemand benannt hat, wird dort eine `[?]`-Zeile mit
   Adressat.

Sonst nichts. Ein Fehler in einer `.sql` kommt auf die Findungsliste und wird nicht repariert.

## Rangfolge bei Widerspruch

1. **`../wb-docs/schema/*.sql`** — was dort steht, gilt, samt Kommentaren.
2. **`../wb-docs/soll-prozesse/`** und **`../wb-docs/idea/`** — die Blöcke für den Inhalt einer
   Liste, `idea/` für Rollen, Rechte, Netze, Secrets.
3. **`CLAUDE.md` von `wb-backend`** — für die Form des Codes, nie für den Inhalt.
4. Sonst nichts.

## Die Abnahme, mit Rückgabewerten

Gegen eine **frisch aufgesetzte** Datenbank, damit die Kette „leerer Cluster → `init-roles.sh` →
alle Migrationen → vollständiges Schema **mit Anfangsbestand**" bewiesen ist:

```
docker compose --profile tools down -v && docker compose up -d
docker compose --profile tools run --rm migrate
docker compose --profile tools run --rm migrate alembic check
for f in ../wb-docs/schema/*-schema-check.sql; do
    docker compose exec -T db psql -U backend_migrator -d weltenbaum -v ON_ERROR_STOP=1 -q < "$f"
    echo "$(basename "$f") rc=$?"
done
docker compose --profile tools run --rm test sh -c \
    'ruff check . && ruff format --check . && mypy app tests && pytest -q'
```

Dazu zwei Gegenproben, die keine Datei prüft, sondern das Verhalten:

- **Der Anfangsbestand:** die Liste aus Gegenprobe 1 oben, grün gegen die frische Datenbank.
- **Die Tenant-Werte:** mit gesetzter Umgebungsvariable trägt der laufende Container den echten
  Wert, ohne sie den Mock — beides gezeigt, nicht behauptet.

## Was du am Ende lieferst

Höchstens zwanzig Zeilen Prosa; Listen und Code zählen nicht mit.

- **Die Rückgabewerte:** vierzehn Prüfskripte, `alembic check`, die vier Werkzeuge, die zwei
  Gegenproben. Je einer eine Zeile.
- **Je Werteliste eine Zeile:** kommt sie mit der Migration, bleibt sie leer, oder wartet sie auf
  eine Antwort — und im dritten Fall, auf welche.
- **Die Annahmen** `A1, A2 …` — jede mit Aussage, Alternative, Preis, und jede außerdem als
  `[A]`-Zeile an ihrer Stelle.
- **Die Fragen** `?1, ?2 …`, die du nach `fragen.md` geschrieben hast, je mit Adressat.
- **Die Findungsliste** `R1, R2 …` — je Eintrag eine Zeile: was, wo, dein Vorschlag.
- **Was blockiert ist**, falls etwas blockiert ist — mit dem Grund, nicht mit einer
  Absichtserklärung.
- **Ein Satz zum Stand:** was die nächste Session vorfindet, wenn sie den ersten Endpunkt schreibt.

Kürze die Listen nie gegen ein Budget. Und schreib nicht, was du geprüft und nicht gefunden hast.
