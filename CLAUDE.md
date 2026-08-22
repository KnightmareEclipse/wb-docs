# yggdrasil

Konzept- und Architektur-Doku für einen selbstverwalteten, DSGVO-konformen Datenbank-/API-VPS
(Hetzner) für die Prozesse einer Schule ohne eigenes IT-Personal. Hier wird entschieden und
dokumentiert; gebaut wird in den Umsetzungs-Repos (`wb-vps`, `wb-backend`).

## Wo was steht

Jede Datei entscheidet genau eine Sorte Frage. Wer die falsche aufschlägt, bekommt eine plausible
Antwort auf die falsche Frage.

| Datei | Entscheidet |
|---|---|
| `rules.md` | Die Planungsprinzipien: Lean by Design (§1, **samt der ausdrücklichen Ausnahme für DB-Schema-Design**), Vertrauensgrenze (§2), Boring Technology (§4), Datensparsamkeit (§7) |
| `grenzkarte.md` | Wem welche Tatsache gehört, die Querschnitts-Entitäten Q1–Q5, die weißen Flecken, die Freeze-Definition |
| `soll-prozesse/` | Wie ein Vorgang künftig läuft — ein Block je Prozess. Die gemeinsamen Hebel in `hebel.md`, Prozessliste und Wegweiser in `README.md` |
| `schema/` | Das Datenmodell: je Domäne eine `-schema.sql` mit ihrem `-schema-check.sql` |
| `prozesse.md` | Wie es **heute** läuft, samt der real erhobenen Formularfelder |
| `fachdomaenen.md` | Scope, Reihenfolge und Stammdaten-Berührung je Fachdomäne |
| `glossar.md` | Das Rollen-Vokabular, repo-übergreifend gültig — Infra-Admin vs. Admin vs. Verwaltung |
| `idea/`, `pipeline/`, `project-parts.md` | Infrastruktur: Container, Identität, Backup, DSGVO-Organisation, Repo-Struktur |
| `TODO.md`, `TODO-SESSIONS.md` | Was reale Konten und Zugänge braucht bzw. was eine Session selbst abarbeiten kann |
| `fragen.md` | Der Wortlaut der offenen Fragen an die Schule, je Gesprächspartner, samt dem Kriterium, wann eine Antwort reicht |
| `prompts/` | Die wiederkehrenden Aufträge. Was für alle gilt, steht einmal in `prompts/gemeinsam.md` |
| `pruefberichte/` | Archiv der abgeschlossenen Prüfzyklen — ein neuer Lauf liest sie **nicht** |

**Rangfolge bei Widerspruch**, damit „zwei Quellen sagen Verschiedenes" keine Rückfrage wird:

1. Der **Soll-Block** schlägt alles — er ist die jüngste abgestimmte Fassung.
2. **`soll-prozesse/hebel.md`** schlägt einen einzelnen Block, wo der Block keine Abweichung
   ausschreibt.
3. **`grenzkarte.md`** schlägt alles Weitere — sie zieht die Grenzen.
4. **`prozesse.md`** liefert reale Formularfelder, nie eine Struktur.

Aus den Blöcken entsteht das Schema, nie umgekehrt.

## Leitprinzip: Stupidly Simple, aber sicher

So einfach wie möglich, dabei sicher genug für echte personenbezogene Daten. Ausführlich in
`rules.md` §1 und §2, hier die Kurzfassung, an der sich jeder Vorschlag messen lässt:

- **Kein Mechanismus ohne konkreten, aktuell vorliegenden Bedarf.** Keine Komplexität „für später".
  Bei jeder neuen Idee zuerst die Ladder aus `rules.md` §1 durchgehen und am ersten tragfähigen
  Punkt stehenbleiben.
- **Vertrauensgrenze** (`rules.md` §2): Root-Admins und Hetzner selbst gelten als vertrauenswürdig —
  abgesichert über Bus-Faktor-Regeln bzw. die AVV, nicht durch Technik gegen die eigene Root-Ebene.
  Vor jedem neuen Sicherheitsmechanismus prüfen: schützt das vor einem Angreifer **außerhalb** dieser
  Grenze, oder nur gefühlt?
- **Alles, was wiederkehrt, wird automatisiert** — Ausnahme nur, wo ein Mensch ein bewusst nur ihm
  bekanntes Geheimnis eingeben muss oder echtes Urteilsvermögen braucht.
- **Bei Zweifel gewinnt die einfachere Lösung**, solange sie das Sicherheits- und
  Automatisierungsniveau nicht senkt.

Zwei Regeln, die hier wiederholt gekostet haben:

- **Keine konstruierten Randfälle.** Statt „was, wenn genau dieser seltene Fall eintritt" die
  generelle Regel suchen, die ihn mit abdeckt. Wer durchs Raster fällt, hat eben Glück.
- **Kein Netz gegen menschliches Vergessen.** Bleibt ein Vorgang liegen, weil ihn niemand einträgt,
  ist das kein Modellierungsproblem und kein Befund.

## Stand

**Infrastruktur — steht.** VPS-Repo in Phase 1–3 automatisiert: Phase 1 über `hcloud` in
`wb-vps/infra/`, Phase 2 als Ansible-Rolle `hardening`, Phase 3 (Podman, rootful) als Rolle
`podman_rootful`; ein `site.yml`-Lauf richtet beide ein. Der App-Stack ist architektonisch fixiert
(PostgreSQL, FastAPI, Caddy, `pg_dump`+`age`, M365/Entra-ID, kein externes CI/CD — Git-Push-Auslöser
direkt auf der VPS) und läuft in `wb-backend` produktiv: Compose-Stack und FastAPI-Grundgerüst
(Health-Endpoint, JWT-Validierung, Alembic) über die echte Domäne mit automatischem HTTPS. Offen:
der OTP-Fallback-Pfad für externe Nutzer, die CORS-Policy und alles unter Teams-Apps-Repo
(`project-parts.md` §10).

**Datenmodell — geprüft.** Was in `schema/` liegt, ist gebaut; das `-schema-check.sql` daneben
belegt es. Abgeleitet aus den Soll-Blöcken, durch die Zyklen in `pruefberichte/` gegangen. Was das
Dateisystem *nicht* sagt und deshalb hier steht:

- **Vier Schemata ohne Tabellen, und das ist ihr Ergebnis:** AGs, M365-Kontenverwaltung,
  Eltern-Selfservice, Klassenbildung. Ihr Prüfskript belegt genau das — dass nichts auf Verdacht
  entstanden ist.

Welche Soll-Blöcke noch fehlen, sagt die Liste in `soll-prozesse/README.md`: ein offener Punkt trägt
dort kein Häkchen und keinen Link. Stammdaten sind ab dem Vollimport **Ende August 2026**
eingefroren; die Definition von „eingefroren" steht in `grenzkarte.md`.

**Backend — übertragen.** Alle 100 Tabellen stehen in `wb-backend` als SQLAlchemy-Modelle
(`app/models/`, ein Modul je Domäne) und als zehn Domänen-Migrationen (`app/alembic/versions/`),
denen der Werteliste-Anfangsbestand und die Normalform-Korrekturen folgen; die
Spalten-Rechte und die sieben engen Rollen entstehen in der Migration ihrer Domäne, weil
`--autogenerate` beides nicht sieht. Jede ORM-Änderung läuft durch die Schreibschicht
(`app/db/changelog.py`), die `change_log` aus Session-Events schreibt, den Aktor je Transaktion
setzt und Massenoperationen abweist. Belegt ist die Treue nicht mit Augenmaß: der Katalog der von
Alembic gebauten Datenbank ist zeilengleich mit dem einer Datenbank, in die die vierzehn `.sql`
geladen wurden, und alle vierzehn Prüfskripte laufen gegen sie mit Rückgabewert 0.

**Damit führt `wb-backend` das Schema.** Die `.sql` hier bleibt die Begründungsquelle und ist nicht
mehr die Quelle der Wahrheit; eine Strukturänderung beginnt ab jetzt als Migration und wird hier
nachgezogen, nicht umgekehrt.

**Nächster Schritt:** Die ersten Endpunkte in `wb-backend`. Was davor stehen muss, steht in
`TODO-SESSIONS.md`, Abschnitt „Für `wb-backend`". Was daneben stehen muss, steht als kritischer
Pfad in `fachdomaenen.md` §7 und in `TODO.md`.

## Einstieg in eine Session

Diese Datei wird automatisch geladen; verlinkt werden muss nichts. Je nach Arbeit zusätzlich:

- **Schema oder Domäne:** `rules.md`, `grenzkarte.md`, `soll-prozesse/hebel.md`,
  `schema/stammdaten-schema.sql`.
- **Ein Vorgang:** sein Block in `soll-prozesse/`, dazu `hebel.md`. Die Schreibregeln für einen
  neuen Block stehen in `soll-prozesse/anleitung.md`, der Auftrag dazu in `prompts/block-fuellen.md`.
- **Eine Domäne ins Schema:** `prompts/schema-bauen.md`. Gegenprüfen: `prompts/schema-pruefen.md` in einer
  **frischen** Session, die den Bau nicht mitgemacht hat. Funde schließen:
  `prompts/schema-reparieren.md`. Nach `wb-backend` tragen: `prompts/schema-uebertragen.md`. Für
  alle vier und den Blockprompt gilt `prompts/gemeinsam.md`.
- **Das Schema auf Normalform prüfen:** `prompts/schema-normalform.md` — eigener Lauf, eine einzige
  Frage, und nicht mit dem Prüflauf gegen die Blöcke zu vermischen.
- **Neue Fachdomäne verstehen:** `fachdomaenen.md`, `prozesse.md` und die vier
  Anmeldetag-Checklisten in `~/Downloads/CHECKLISTEN/`.
- **Eine Domäne zur API planen:** `prompts/api-planen.md` — eine Domäne je Durchgang, wie beim
  Schema. Der Plan entsteht hier, gebaut wird danach in `wb-backend`.
- **Endpunkte in `wb-backend`:** `TODO-SESSIONS.md`, `project-parts.md`,
  `idea/04-identitaet-zugriff.md`, dazu `CLAUDE.md` und `README.md` dort. Die Schreibschicht steht
  und ist nicht optional: ein Endpunkt, der an ihr vorbei schreibt, kommt nicht durch.
- **Infrastruktur:** `pipeline/runbook.md`, `idea/03-container-anwendung.md`,
  `idea/05-backup-recovery.md`, `TODO.md`.

## Schemaarbeit

Zieldatenbank ist **PostgreSQL 18**. Bezeichner englisch, Kommentare deutsch. Die Konventionen für
Schlüssel, Constraint-Namen und Kommentarform zeigt `schema/stammdaten-schema.sql`; ausgeschrieben
stehen sie in `prompts/schema-bauen.md`.

**Die Begründungen stehen als Kommentare in der `.sql`, nicht in der Prosa.** Wer die Struktur ohne
ihre Kommentare liest, schlägt zuverlässig genau das vor, was schon verworfen wurde. Eine zweite
Darstellung des Schemas wird deshalb **nicht gepflegt** — abgeleitet werden darf sie, aber immer
gegen eine Wegwerf-Datenbank und nie gegen eine Handfassung (fürs Diagramm lädt pgModeler die
Schemata dort hinein).

**Grenze zwischen `.sql` und `.md`** — sie entscheidet, wo eine Begründung hingehört:

> Hängt sie an genau einer Spalte oder einem Constraint? → **`.sql`**.
> Braucht sie zwei Tabellen oder einen Prozess, um formulierbar zu sein? → **`.md`**.

In die `.sql` gehören damit Typwahl, CHECK-Begründungen, nullable-ja/nein, Lookup-statt-Freitext und
**warum eine Spalte bewusst fehlt** (als Kommentar an der Tabelle — eine nicht existierende Spalte
hat keinen anderen Anker). In die `.md` gehören Modelle über mehrere Tabellen (Familie, Ownership),
Zugriffsregeln, Abläufe und die Domänengrenzen. Die `.md` sagt *was* gilt und verweist fürs *warum*
auf die `.sql`, statt es zu wiederholen.

**Eine Schemaänderung ist erst fertig, wenn alles mitgezogen ist** — diese Liste steht nur hier:

`…-schema.sql` → das zugehörige `-schema-check.sql` **samt Sollstand im Kopfkommentar** → die
betroffenen `.md` → `grenzkarte.md`.

**Eine Regel ohne Gegenprobe gilt als nicht gebaut.** Der Constraint allein zählt nicht; das
Prüfskript muss den realen Fall abweisen, den der Block verbietet.

Validiert wird **einmal am Ende**, nicht nach jedem Einzelpunkt — Postgres ist hier nicht
installiert, Podman schon:

```
podman run --rm -d --name wb-pruef -e POSTGRES_PASSWORD=x docker.io/library/postgres:18
podman exec -i wb-pruef psql -U postgres -v ON_ERROR_STOP=1 -q < schema/stammdaten-schema.sql
```

- **`-v ON_ERROR_STOP=1` ist kein Beiwerk.** Die Skripte melden über `RAISE EXCEPTION`; ohne den
  Schalter liest psql darüber hinweg und endet mit Rückgabewert 0 — dann ist jeder Lauf grün, auch
  der gescheiterte. In den Bericht kommt der Rückgabewert je Datei, nicht der Text auf dem Schirm.
- **Ladereihenfolge:** `stammdaten`, dann `querschnitt`, dann der Rest in beliebiger Folge.
- **Alle Prüfskripte gegen die vollständige Datenbank**, nicht einzeln gegen ihre
  Voraussetzungen: ein Skript mit erfundenen Fremdschlüssel-Werten läuft grün, solange die
  Zieltabelle fehlt. Jedes rollt am Ende zurück, keines stört das nächste.

Referenzquelle für das amtliche Datenmodell: `~/Documents/projectNightmare/ASV-BW/asv_struktur.sql`
— der Wert steckt in den `COMMENT ON COLUMN`-Zeilen, die `*Statistikpflichtfeld*` markieren. Sie ist
eine Quelle für Randfälle, nie für Felder (`rules.md` §7).

## Stand und Begründung

Zwei Sorten Text laufen sonst über: was schon gebaut ist, und warum es so und nicht anders gebaut
ist. Beide werden nicht erzählt, sondern verankert.

**Stand ist eine Datei-Existenz, kein Satz.** Was in `schema/` liegt, ist gebaut; ein Häkchen in
`soll-prozesse/README.md` trägt den Link auf den Block, den es behauptet. Daraus folgen zwei Regeln:

- **Eine Standaussage ohne Pfad ist keine.** Die `(gebaut, schema/…)`-Marken in `fachdomaenen.md`
  tragen ihre Gegenprobe mit sich: Wer den Stand fälscht, hinterlässt einen toten Pfad.
- **Wird etwas fertig, darf sich höchstens eine Datei ändern.** Müssen zwei, ist die Aussage
  dupliziert — dann wird sie an einer der beiden Stellen gestrichen, nicht an beiden gepflegt.

**Grenze zwischen Kommentar und `.md`** — dieselbe Mechanik wie die `.sql`/`.md`-Grenze oben, eine
Ebene höher:

> Der Kommentar am Artefakt trägt, **was gilt**. Die `.md` trägt, **was nicht gilt und warum nicht**.

Ein verworfener Weg hat im Code keinen Anker — es gibt keine Zeile für eine Option, die nie gebaut
wurde. Der Kommentar trägt deshalb den Nebensatz („rootful, weil rootless die Absenderadresse
verliert"), die abgewogene Alternative samt Preis steht in `pipeline/` oder `idea/`. Umgekehrt bleibt
eine Begründung, zu der nie eine Alternative abgewogen wurde, allein am Code.

- **Kein verworfener Weg ohne Preis.** „Wir könnten auch X" ist Blähtext; „X kostet eine
  Quadlet-Unit neben Compose, HTTP/3 aus und Port 80 trotzdem offen" ist ein Grund. An dieser Regel
  hört eine `.md` auf zu wachsen.
- **Der Verweis geht in beide Richtungen, über einen Pfad.** Jede Datei in `pipeline/` und `idea/`
  nennt im Kopf den Pfad, der sie umsetzt — kein Rollen- oder Skriptname in Prosa. Jeder Mechanismus
  im Code, dessen Alternative abgewogen wurde, nennt die `.md` beim Pfad: Zusammenfassung plus
  Verweis, nie eine zweite Vollfassung.

## Dokumentationsstil

Alle `.md` in diesem Repo bilden ausschließlich den **aktuellen Stand** ab — keine Historie, keine
Changelogs, keine Formulierungen wie „früher", „vorher hatten wir", „wurde ersetzt durch". Beim
Ändern wird der alte Stand ersetzt, nicht ergänzt. Kurz, klar, präzise, kein Blähtext.

Ausnahme ist `pruefberichte/`: Archiv abgeschlossener Zyklen, wird nicht nachgezogen.

Und jede Regel steht **genau einmal**. Was hier steht, wiederholt kein Prompt; was in
`prompts/gemeinsam.md` steht, wiederholt kein einzelner Prompt; was in `soll-prozesse/hebel.md`
steht, wiederholt kein Block. Wer eine Regel an zweiter Stelle braucht, nennt sie, statt sie
abzuschreiben.

## Git-Identität (gilt für alle Repos)

Commits laufen unter Pseudonym, nie Klarname oder private/Uni-Mail: GitHub-Nutzername
`KnightmareEclipse`, E-Mail die von GitHub gestellte Noreply-Adresse
(`312991717+KnightmareEclipse@users.noreply.github.com`). Gesetzt als repo-lokale
`user.name`/`user.email`, **nie global** — projektfremde Repos auf derselben Maschine bleiben
unberührt.

## Geltungsbereich dieser Datei

Dieses Repo ist reine Konzept-/Architektur-Doku, ausschließlich für mich als alleinigen Betreiber.
Die Umsetzungs-Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) sind für
weitere Personen gedacht — Programmierstil-Regeln stehen deshalb nicht hier, sondern in der
`CLAUDE.md` des jeweiligen Umsetzungs-Repos (aktuell `wb-vps/CLAUDE.md`), eigenständig und ohne
Bezug auf dieses Repo.
