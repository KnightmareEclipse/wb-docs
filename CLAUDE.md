# yggdrasil

Konzept- und Architektur-Doku für einen selbstverwalteten, DSGVO-konformen Datenbank-/API-VPS (Hetzner) für Schulprozesse — Container-Netzwerk-Isolation, externer OIDC-Identitätsanbieter, verschlüsselte Backups. Das VPS/Host-Setup (Firewall, Härtung auf Debian 13) und die Container-Runtime (Podman, rootful) sind umgesetzt und automatisiert. Die App-Stack-Ebene darüber ist architektonisch fixiert (Datenbank: PostgreSQL, Backend: FastAPI, Reverse-Proxy: Caddy, Backup: `pg_dump`+`age`, Identitätsanbieter: M365/Entra-ID, kein externes CI/CD — Git-Push-Auslöser direkt auf der VPS) und wird im App-Stack-Repo (`wb-backend`) umgesetzt: Compose-Stack und Backend-Grundgerüst laufen produktiv auf der VPS, ausgelöst per Git-Push. Details in `idea/`, `pipeline/`, `project-parts.md`, `fachdomaenen.md`, `prozesse.md`, `domains/`. Die Planungsprinzipien, denen alle drei folgen, stehen in `rules.md` — jede neue Entscheidung in diesem Repo hält sich daran, insbesondere die dort explizit benannte Vertrauensgrenze (Abschnitt 2): Root-Admins und Hetzner selbst gelten als vertrauenswürdig, das Bedrohungsmodell zielt auf externe Angreifer.

Umsetzung erfolgt in getrennten Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) — siehe „Repo-Struktur" in `project-parts.md`.

## Leitprinzip: Stupidly Simple, aber sicher

Ziel jeder Entscheidung in diesem Repo: so einfach wie möglich, dabei sicher genug für echte personenbezogene Daten einer Schule ohne eigenes IT-Personal. Ausführliche Prüfleiter in `rules.md` Abschnitt 1 („Lean by Design") und Abschnitt 2 („Secure by Design"), hier die Kurzfassung, an der sich jeder neue Vorschlag messen lassen muss:

- **Kein Mechanismus ohne konkreten, aktuell vorliegenden Bedarf** — keine Komplexität „für später" oder „für den Fall dass". Bei jeder neuen Idee zuerst die Ladder aus `rules.md` Abschnitt 1 durchgehen und am ersten tragfähigen Punkt stehenbleiben.
- **Vertrauensgrenze** (`rules.md` Abschnitt 2): Root-Admins und Hetzner selbst gelten als vertrauenswürdig — abgesichert über Bus-Faktor-Regeln bzw. die AVV, nicht durch zusätzliche Technik gegen die eigene Root-Ebene. Schutz zielt auf externe Angreifer und kompromittierte Drittanbieter-Credentials (z. B. ein CI-Deploy-Key). Vor jedem neuen Sicherheitsmechanismus prüfen: schützt das wirklich vor einem Angreifer außerhalb dieser Grenze, oder nur gefühlt?
- **Alles, was wiederkehrt, wird automatisiert** — Ausnahme nur, wo ein Mensch zwingend ein bewusst nur ihm bekanntes Geheimnis eingeben muss oder echtes Urteilsvermögen braucht. Ziel: Das System läuft weiter und bleibt wartbar, auch wenn der aktuelle Betreiber weg ist.
- **Bei Zweifel gewinnt die einfachere Lösung**, solange sie das Sicherheits- und Automatisierungsniveau nicht senkt — nicht die technisch elegantere oder vollständigere.

## Git-Identität (gilt für alle Repos)

Commits in allen Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos, dieses Repo) laufen unter Pseudonym, nie Klarname oder private/Uni-Mail: GitHub-Nutzername `KnightmareEclipse`, E-Mail die von GitHub gestellte Noreply-Adresse (`312991717+KnightmareEclipse@users.noreply.github.com`, GitHub-Kontoeinstellungen → Emails). Gesetzt als repo-lokale `user.name`/`user.email` (nie global) — andere, projektfremde Repos auf derselben Maschine bleiben unberührt.

## Aktueller Fokus: VPS fertig, App-Stack-Repo im Aufbau

Das VPS-Repo ist in Phase 1–3 automatisiert: Phase 1 über das `hcloud`-CLI in `wb-vps/infra/`, Phase 2 als Ansible-Rolle `hardening`, Phase 3 (Podman, rootful) als Rolle `podman_rootful` — ein `site.yml`-Lauf richtet beide ein.

Die App-Stack-Architektur ist fixiert (`project-parts.md`) und wird im App-Stack-Repo (`wb-backend`) umgesetzt: Compose-Stack (DB/Backend/Caddy) und FastAPI-Grundgerüst (Health-Endpoint, JWT-Validierung, Alembic) laufen lokal wie produktiv auf der VPS, dort per Git-Push ausgelöst und über die echte Domäne mit automatischem HTTPS erreichbar. Noch nicht implementiert ist der OTP-Fallback-Pfad für externe Nutzer; offen bleiben die CORS-Policy und alles unter Teams-Apps-Repo (`project-parts.md` Abschnitt 10).

Gebaut sind die Schemata **Stammdaten**, **Putzdienst**, **Anmeldung** (Voranmeldung/Anmeldegespräch/Schulvertrag samt den Querschnitts-Entitäten Zustimmung, Dokument/Signatur und Nachzieh-Aufgabe), **Ferienanmeldung**, **Gesundheitsdaten**, der **Mensa-Kern** (Küchenprofil; die Buchung läuft über die Betreuungsmodul-Tabellen) und die **Klassenorganisation** (Elternvertretung), jeweils samt Prüfskript, dazu ein Performance-Benchmark (`domains/`). Die Entitäten- und Zuständigkeitsgrenzen **aller** Fachdomänen stehen vorab in `domains/grenzkarte.md` — bewusst ohne Spalten: eine Spalte lässt sich nachtragen, eine falsch gezogene Grenze nicht, und ohne diese Karte modellieren mehrere Domänen denselben Sachverhalt je einmal. Jedes neue Domänenschema entsteht gegen sie; Stammdaten sind ab dem Vollimport Ende August 2026 eingefroren (Definition dort).

**Nächster Schritt:** Übertragung aller sieben Schemata nach SQLAlchemy/Alembic in `wb-backend` (`TODO-SESSIONS.md`) — der engere Pfad bis September 2026, nicht der Entwurf. Was daneben bis dahin stehen muss, steht als kritischer Pfad in `fachdomaenen.md` Abschnitt 7 und in `TODO.md`; der Datenmodell-Entwurf blockiert nicht darauf, da lokale Entwicklung gegen den Compose-Stack läuft (`rules.md` Abschnitt 9).

## Einstieg in eine Session

Diese Datei wird automatisch geladen — verlinkt werden muss nichts, es genügt, in dieser Reihenfolge zu lesen:

- **Immer bei Schema- oder Domänenarbeit:** `rules.md` (die Maßstäbe, besonders die Ladder aus §1 **samt der ausdrücklichen Ausnahme für DB-Schema-Design**), `domains/grenzkarte.md` (wem welche Tatsache gehört, Freeze-Definition, weiße Flecken), `domains/stammdaten-schema.sql`, `domains/stammdaten.md`.
- **Begriffe:** `glossar.md` — Rollen (Infra-Admin vs. Admin vs. Verwaltung) und Kernbegriffe, repo-übergreifend gültig. Kurz, aber die einzige Quelle für das Rollen-Vokabular.
- **Neue Fachdomäne:** dazu `fachdomaenen.md` (Scope und Stammdaten-Berührung je Domäne), `prozesse.md` (Ist-Ablauf und die realen Formularfeldlisten je Prozess) und die vier Anmeldetag-Checklisten in `~/Downloads/CHECKLISTEN/`.
- **Putzdienst:** `domains/putzdienst.md`, `domains/putzdienst-schema.sql`.
- **Anmeldung/Ferien/Gesundheit:** `domains/anmeldung.md`, `domains/anmeldung-schema.sql`, `domains/ferien.md`, `domains/ferien-schema.sql`, `domains/gesundheit.md`, `domains/gesundheit-schema.sql`. Beide setzen Stammdaten und Putzdienst voraus und werden nach ihnen geladen — Ladereihenfolge im Kopf der jeweiligen Prüfskripte.
- **Mensa:** `domains/mensa.md`, `domains/mensa-schema.sql` — das Küchenprofil; die Buchung selbst lebt in den Betreuungsmodul-Tabellen des Anmelde-Schemas.
- **Klassenorganisation:** `domains/klassenorganisation.md`, `domains/klassenorganisation-schema.sql` — nur die Elternvertretung, setzt allein Stammdaten voraus.
- **Übertragung nach `wb-backend`:** `TODO-SESSIONS.md`, `project-parts.md`, `idea/04-identitaet-zugriff.md`.
- **Infrastruktur:** `pipeline/runbook.md`, `idea/03-container-anwendung.md`, `idea/05-backup-recovery.md`, `TODO.md`.

Die Begründungen des Datenmodells stehen als **Kommentare in der `.sql`**, nicht in der Prosa — wer nur `domains/stammdaten-schema-plain.sql` liest, sieht dieselbe Struktur ohne jedes „warum" und schlägt zuverlässig vor, was bereits verworfen wurde. Die `-plain.sql` ist abgeleitet und nie die Lesefassung. Eine zweite Darstellung des Schemas wird nicht **gepflegt** — abgeleitet werden darf sie. Sie geht gegen eine Wegwerf-Datenbank und nie gegen eine Handfassung: fürs vollständige Diagramm lädt pgModeler die Schemata dort hinein (Befehle im Kopf der Prüfskripte).

**Grenze zwischen `.sql` und `.md`** — sie entscheidet, wo eine Begründung hingehört, und verhindert, dass dieselbe zweimal dasteht:

> Hängt die Begründung an genau einer Spalte oder einem Constraint? → **`.sql`**.
> Braucht sie zwei Tabellen oder einen Prozess, um überhaupt formulierbar zu sein? → **`.md`**.

In die `.sql` gehören damit Typwahl, CHECK-Begründungen, nullable-ja/nein, Lookup-statt-Freitext an dieser Stelle, die Vergleiche gegen ASV-BW/SVWS/Gibbon und **warum eine Spalte bewusst fehlt** (als Kommentar an der betroffenen Tabelle — eine nicht existierende Spalte hat keinen anderen Anker). In die `.md` gehören Modelle über mehrere Tabellen hinweg (Familie, Ownership), Zugriffs- und Sichtbarkeitsregeln, Abläufe (Jahreslauf, Löschmechanik, Import) und die Domänengrenzen. Die `.md` sagt bei einem Feld *was* gilt und verweist fürs *warum* auf die `.sql`, statt es zu wiederholen. Referenzquelle für Fragen zum amtlichen Datenmodell: `~/Documents/projectNightmare/ASV-BW/asv_struktur.sql` — der Wert steckt in den `COMMENT ON COLUMN`-Zeilen, die `*Statistikpflichtfeld*` markieren.

## Pflichten bei jeder Schemaänderung

Zieldatenbank ist **PostgreSQL 18** (19 erscheint erst um September/Oktober 2026 und kommt für den Produktivstart zu spät — `rules.md` Abschnitt 4, Boring Technology).

Eine Schemaänderung ist erst fertig, wenn alle abhängigen Dateien mitgezogen sind — diese Liste steht nur hier, und eine vergessene Datei fällt sonst monatelang nicht auf:

`…-schema.sql` → `-plain.sql` (regenerieren, nie von Hand — `sed`-Befehl in `domains/stammdaten.md`) → Prüfskript **samt Sollstand** → `domains/stammdaten-schema-benchmark.md` und die Dateien in `domains/stammdaten-benchmark/` → die betroffenen `.md` → `domains/grenzkarte.md`.

Danach **einmal** validieren, nicht nach jedem Einzelpunkt: alle sieben Prüfskripte in Ladereihenfolge — Stammdaten (66/66), Putzdienst (22/22), Anmeldung (60/60), Ferien (14/14), Gesundheit (11/11), Mensa (4/4), Klassenorganisation (3/3); Aufruf und Sollstand stehen im jeweiligen Kopfkommentar. Bei Spaltenänderungen an Stammdaten zusätzlich der Benchmark-Generator mit `n_children=500`/`n_classes=20` — die Zeilenzahlen müssen denen aus `domains/stammdaten-schema-benchmark.md` (Durchlauf 1) entsprechen.

## Dokumentationsstil

Alle `.md`-Dateien in diesem Repo bilden ausschließlich den **aktuellen Stand** ab — keine Historie, keine Changelogs, keine Formulierungen wie „früher", „vorher hatten wir", „wurde ersetzt durch". Beim Ändern von Inhalten wird der alte Stand ersetzt, nicht ergänzt oder als Verlauf stehen gelassen.

Kurz, klar, präzise — kein Blähtext, keine Inhalte, die nur die Länge aufblasen ohne neue Information zu liefern.

## Geltungsbereich dieser Datei

Dieses Root-Repo (`yggdrasil`) ist reine Konzept-/Architektur-Doku, ausschließlich für mich als alleinigen Betreiber. Die Umsetzungs-Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) sind für weitere Personen gedacht — Programmierstil-Regeln (Sprache, Skript-Aufbau, Naming, Fehlerbehandlung etc.) stehen deshalb nicht hier, sondern in der `CLAUDE.md` des jeweiligen Umsetzungs-Repos (aktuell `wb-vps/CLAUDE.md`) — eigenständig, ohne Bezug auf dieses Repo, damit die Umsetzungs-Repos unabhängig funktionieren.
