# Weltenbaum

Konzept- und Architektur-Doku für einen selbstverwalteten, DSGVO-konformen Datenbank-/API-VPS
(Hetzner) für die Prozesse einer Schule ohne eigenes IT-Personal. Hier wird entschieden und
dokumentiert; gebaut wird in `wb-vps` und `wb-backend`. Reine Doku, alleiniger Betreiber —
Programmierstil-Regeln stehen in der `CLAUDE.md` des jeweiligen Umsetzungs-Repos, nie hier.

## Wo was steht

Jede Datei entscheidet genau eine Sorte Frage. Wer die falsche aufschlägt, bekommt eine plausible
Antwort auf die falsche Frage.

| Datei | Entscheidet |
|---|---|
| `rules.md` | Die Planungsprinzipien: Lean by Design (§1, **samt der ausdrücklichen Ausnahme für DB-Schema-Design**), Vertrauensgrenze (§2), Boring Technology (§4), Datensparsamkeit (§7) |
| `grenzkarte.md` | Wem welche Tatsache gehört, die Querschnitts-Entitäten Q1–Q5, die weißen Flecken, die Freeze-Definition |
| `soll-prozesse/` | Wie ein Vorgang künftig läuft — ein Block je Prozess. Die gemeinsamen Hebel in `hebel.md`, Prozessliste und Wegweiser in `README.md` |
| `schema/` | Das Datenmodell: je Domäne eine `-schema.sql` mit ihrem `-schema-check.sql` |
| `api/` | Die Routen je Domäne, das Gemeinsame in `api/gemeinsam.md`. Geplant wird hier, gebaut in `wb-backend` |
| `prozesse.md` | Wie es **heute** läuft, samt der real erhobenen Formularfelder |
| `fachdomaenen.md` | Scope, Reihenfolge und Stammdaten-Berührung je Fachdomäne |
| `glossar.md` | Das Rollen-Vokabular, repo-übergreifend gültig — Infra-Admin vs. Admin vs. Verwaltung |
| `host.md`, `container.md`, `deploy.md`, `runbook.md` | Die Maschine: Server und Firewall, Runtime und Stack, Ausrollen, Neuaufbau von Hand |
| `zugang.md`, `oberflaechen.md` | Wer wie hereinkommt (Entra-ID, OTP, Rollen) und wo die Oberflächen liegen |
| `backup.md`, `dsgvo.md`, `repos.md` | Sicherung und Wiederherstellung, die organisatorischen DSGVO-Pflichten, der Schnitt der Repos |
| `verarbeitungsverzeichnis.md` | Der Eintrag nach Art. 30 für dieses eine Verfahren — Zwecke, Datenkategorien, Empfänger, Fristen, Maßnahmen |
| `backlog/` | Der **gesamte** Arbeitsvorrat: die Aufgabe, ihre kurze Begründung, Reihenfolge, Milestone und Abnahmekriterien |
| `fragen.md` | Der Wortlaut der offenen Fragen an die Schule, je Gesprächspartner, samt dem Kriterium, wann eine Antwort reicht |
| `prompts/` | Die wiederkehrenden Aufträge. Was für alle gilt, steht einmal in `prompts/gemeinsam.md` |
| `werkzeuge.md` | Womit die Doku gelesen und bearbeitet wird (Quartz, Backlog.md), samt der verworfenen Werkzeuge und ihrem Preis |

**Rangfolge bei Widerspruch**, damit „zwei Quellen sagen Verschiedenes" keine Rückfrage wird:

1. Der **Soll-Block** schlägt alles — er ist die jüngste abgestimmte Fassung. Aus ihm entsteht das
   Schema, nie umgekehrt.
2. **`soll-prozesse/hebel.md`** schlägt einen einzelnen Block, wo der Block keine Abweichung
   ausschreibt.
3. **`grenzkarte.md`** schlägt alles Weitere — sie zieht die Grenzen.
4. **`prozesse.md`** liefert reale Formularfelder, nie eine Struktur.

## Leitprinzip: Stupidly Simple, aber sicher

So einfach wie möglich, dabei sicher genug für echte personenbezogene Daten. Ausführlich in
`rules.md` §1 und §2, hier die Sätze, an denen sich jeder Vorschlag messen lässt:

- **Kein Mechanismus ohne konkreten, aktuell vorliegenden Bedarf.** Keine Komplexität „für später";
  bei jeder Idee die Ladder aus `rules.md` §1 durchgehen und am ersten tragfähigen Punkt
  stehenbleiben. **Das DB-Schema ist die ausgeschriebene Ausnahme** — dort kostet eine Lücke einen
  Abnahmezyklus statt eines Refactorings.
- **Vertrauensgrenze:** Root-Admins und Hetzner selbst gelten als vertrauenswürdig, abgesichert über
  Bus-Faktor-Regeln bzw. die AVV. Vor jedem neuen Sicherheitsmechanismus prüfen: schützt das vor
  einem Angreifer **außerhalb** dieser Grenze, oder nur gefühlt?
- **Alles, was wiederkehrt, wird automatisiert** — Ausnahme nur, wo ein Mensch ein bewusst nur ihm
  bekanntes Geheimnis eingeben muss oder echtes Urteilsvermögen braucht.
- **Keine konstruierten Randfälle.** Statt „was, wenn genau dieser seltene Fall eintritt" die
  generelle Regel suchen, die ihn mit abdeckt. Wer durchs Raster fällt, hat eben Glück.
- **Kein Netz gegen menschliches Vergessen.** Bleibt ein Vorgang liegen, weil ihn niemand einträgt,
  ist das kein Modellierungsproblem und kein Befund.

## Stand

**Stand ist eine Datei-Existenz, kein Satz** — deshalb steht hier keiner. Was in `schema/` liegt,
ist gebaut; ein Häkchen in `soll-prozesse/README.md` trägt den Link auf den Block, den es behauptet;
was offen ist, steht als Ticket in `backlog/` — und nur dort. Daraus folgt:

- **Eine Standaussage ohne Pfad ist keine.** Die `(gebaut, schema/…)`-Marken in `fachdomaenen.md`
  tragen ihre Gegenprobe mit sich: Wer den Stand fälscht, hinterlässt einen toten Pfad.
- **Wird etwas fertig, darf sich höchstens eine Datei ändern.** Müssen zwei, ist die Aussage
  dupliziert — dann wird sie an einer der beiden Stellen gestrichen, nicht an beiden gepflegt.
- **Priorität und Fälligkeit setze ich.** Ein Termin, der nicht in `fachdomaenen.md` oder
  `soll-prozesse/README.md` steht, wird nicht erfunden — auch kein Importdatum: Der Vollimport folgt
  dem Stand der Entwicklung, keine Fachdomäne wird gegen einen Kalender gebaut.

Drei Dinge sagt das Dateisystem nicht, deshalb stehen sie hier:

- **`wb-backend` führt das Schema.** Die `.sql` hier bleibt die Begründungsquelle, ist aber nicht
  mehr die Quelle der Wahrheit: Eine Strukturänderung beginnt dort als Migration und wird hier
  nachgezogen, nie umgekehrt.
- **Vier Schemata ohne Tabellen sind ihr Ergebnis, kein Versäumnis:** AGs, M365-Kontenverwaltung,
  Eltern-Selfservice, Klassenbildung. Ihr Prüfskript belegt genau das — dass nichts auf Verdacht
  entstanden ist.
- **`schema/` ist durch fünf Prüfzyklen gegangen**, kein Fund blieb offen.

## Arbeitsgänge

Diese Datei wird automatisch geladen; verlinkt werden muss nichts. Je nach Arbeit zusätzlich:

- **Ein Vorgang:** sein Block in `soll-prozesse/`, dazu `hebel.md`. Neuen Block füllen:
  `prompts/block-fuellen.md` nach den Schreibregeln in `soll-prozesse/anleitung.md`. Einen
  bestehenden lesbar machen, ohne ihn umzuschreiben: `prompts/block-aufraeumen.md`.
- **Eine Domäne ins Schema:** `prompts/schema-bauen.md` → `schema-pruefen.md` **in einer frischen
  Session**, die den Bau nicht mitgemacht hat → `schema-reparieren.md` → `schema-uebertragen.md`.
  `schema-normalform.md` ist ein eigener Lauf mit einer einzigen Frage und wird mit dem Prüflauf
  gegen die Blöcke nicht vermischt.
- **Eine Domäne zur API:** `prompts/api-planen.md`, eine Domäne je Durchgang wie beim Schema. Die zwei Fundament-Domänen `stammdaten` und `querschnitt` haben mit `prompts/api-fundament.md` einen gemeinsamen Lauf — die Portionierung bleibt, geteilt wird nur der Durchgang.
- **Endpunkte in `wb-backend`:** `prompts/api-bauen.md`, eine Domäne je Durchgang; für `stammdaten`
  und `querschnitt` gemeinsam `prompts/api-fundament-bauen.md`, wie beim Planen. Dort
  `CLAUDE.md` und `README.md`, hier `api/`, `zugang.md` und `oberflaechen.md`. Die Schreibschicht dort ist nicht optional: ein Endpunkt, der
  an ihr vorbeischreibt, kommt nicht durch.
- **Infrastruktur:** `host.md`, `container.md`, `deploy.md`, `runbook.md`, `backup.md`.
- **Eine Fachdomäne verstehen:** `fachdomaenen.md`, `prozesse.md` und die vier
  Anmeldetag-Checklisten in `~/Downloads/CHECKLISTEN/`.

## Schemaarbeit

Zieldatenbank ist **PostgreSQL 18**, Bezeichner englisch, Kommentare deutsch;
`schema/stammdaten-schema.sql` ist die Referenzform für Schlüssel, Constraint-Namen und
Kommentarform.

**Die Begründungen stehen als Kommentar in der `.sql`, nicht in der Prosa.** Wer die Struktur ohne
ihre Kommentare liest, schlägt zuverlässig genau das vor, was schon verworfen wurde. Eine zweite
Darstellung des Schemas wird deshalb **nicht gepflegt** — abgeleitet werden darf sie, aber immer
gegen eine Wegwerf-Datenbank und nie als Handfassung (fürs Diagramm lädt pgModeler die Schemata
dort hinein).

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
- **Alle Prüfskripte gegen die vollständige Datenbank**, nicht einzeln gegen ihre Voraussetzungen:
  ein Skript mit erfundenen Fremdschlüssel-Werten läuft grün, solange die Zieltabelle fehlt. Jedes
  rollt am Ende zurück, keines stört das nächste.

## Wohin eine Begründung gehört

Zwei Grenzen, dieselbe Mechanik auf zwei Ebenen:

> Hängt sie an genau einer Spalte oder einem Constraint? → **`.sql`**.
> Braucht sie zwei Tabellen oder einen Prozess, um formulierbar zu sein? → **`.md`**.

> Der Kommentar am Artefakt trägt, **was gilt**. Die `.md` trägt, **was nicht gilt und warum nicht**.

In die `.sql` gehören damit Typwahl, CHECK-Begründungen, nullable-ja/nein, Lookup-statt-Freitext und
**warum eine Spalte bewusst fehlt** (als Kommentar an der Tabelle — eine nicht existierende Spalte
hat keinen anderen Anker). In die `.md` gehören Modelle über mehrere Tabellen (Familie, Ownership),
Zugriffsregeln, Abläufe und die Domänengrenzen; sie sagt *was* gilt und verweist fürs *warum* auf
die `.sql`, statt es zu wiederholen. Ein verworfener Weg hat im Code keinen Anker — der Kommentar
trägt deshalb nur den Nebensatz („rootful, weil rootless die Absenderadresse verliert"), die
abgewogene Alternative samt Preis steht in der Architektur-Datei, die den Mechanismus trägt.

- **Kein verworfener Weg ohne Preis.** „Wir könnten auch X" ist Blähtext; „X kostet eine
  Quadlet-Unit neben Compose, HTTP/3 aus und Port 80 trotzdem offen" ist ein Grund. An dieser Regel
  hört eine `.md` auf zu wachsen.
- **Der Verweis geht in beide Richtungen, über einen Pfad.** Jede Architektur-Datei (`host.md`,
  `container.md`, `deploy.md`, `zugang.md`, `oberflaechen.md`, `backup.md`) nennt im Kopf den Pfad,
  der sie umsetzt — kein Rollen- oder Skriptname in Prosa. Jeder Mechanismus
  im Code, dessen Alternative abgewogen wurde, nennt die `.md` beim Pfad: Zusammenfassung plus
  Verweis, nie eine zweite Vollfassung.

## Dokumentationsstil

Alle `.md` bilden ausschließlich den **aktuellen Stand** ab — keine Historie, keine Changelogs,
keine Formulierungen wie „früher", „vorher hatten wir", „wurde ersetzt durch". Beim Ändern wird der
alte Stand ersetzt, nicht ergänzt. Kurz, klar, präzise, kein Blähtext. Ein abgeschlossener
Prüfbericht wird gelöscht, nicht abgelegt: Der Beleg ist die reparierte `.sql` samt grünem
Prüfskript, und die Git-Historie hält den Bericht.

**`backlog/` ist die eine Ausnahme, und sie ist keine Aufweichung.** Ein Ticketsystem lebt davon,
dass ein erledigter Punkt erledigt *bleibt* — der Status `Done` und die Ablage unter
`backlog/completed/` sind Historie mit Absicht, und wer sie räumt, kann eine Frage nicht mehr
beantworten, die im Gespräch mit der Schule zuverlässig kommt: „das war doch schon entschieden?".
Die Ausnahme gilt für das Ticket und nur dafür. Aus einem abgeschlossenen Ticket wird nie eine
Zeile in einer `.md`: Wer den Vorgang wissen will, öffnet das Board, und wer den Stand wissen will,
sieht die Datei, die dabei entstanden ist.

Und jede Regel steht **genau einmal**. Was hier steht, wiederholt kein Prompt; was in
`prompts/gemeinsam.md` steht, wiederholt kein einzelner Prompt; was in `soll-prozesse/hebel.md`
steht, wiederholt kein Block; ein Ticket in `backlog/` verweist auf seine Begründung, statt sie
abzuschreiben. Wer eine Regel an zweiter Stelle braucht, nennt sie, statt sie zu kopieren.

## Git-Identität (gilt für alle Repos)

Commits laufen unter Pseudonym, nie Klarname oder private/Uni-Mail: GitHub-Nutzername
`KnightmareEclipse`, E-Mail `312991717+KnightmareEclipse@users.noreply.github.com`. Gesetzt als
repo-lokale `user.name`/`user.email`, **nie global** — projektfremde Repos auf derselben Maschine
bleiben unberührt.
