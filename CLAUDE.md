# yggdrasil

Konzept- und Architektur-Doku für einen selbstverwalteten, DSGVO-konformen Datenbank-/API-VPS (Hetzner) für Schulprozesse — Docker-Netzwerk-Isolation, externer OIDC-Identitätsanbieter, verschlüsselte Backups. Das VPS/Host-Setup (Firewall, Docker-Engine) ist fertig umgesetzt. Die App-Stack-Ebene darüber ist architektonisch fixiert (Datenbank: PostgreSQL, Backend: FastAPI, Reverse-Proxy: Caddy, Backup: `pg_dump`+`age`, Identitätsanbieter: M365/Entra-ID, kein externes CI/CD — Git-Push-Auslöser direkt auf der VPS) — das App-Stack-Repo selbst ist aber noch nicht angelegt. Details in `idea/`, `pipeline/`, `project-parts.md`. Die Planungsprinzipien, denen alle drei folgen, stehen in `rules.md` — jede neue Entscheidung in diesem Repo hält sich daran, insbesondere die dort explizit benannte Vertrauensgrenze (Abschnitt 2): Root-Admins und Hetzner selbst gelten als vertrauenswürdig, das Bedrohungsmodell zielt auf externe Angreifer.

Umsetzung erfolgt in getrennten Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) — siehe „Repo-Struktur" in `project-parts.md`.

## Leitprinzip: Stupidly Simple, aber sicher

Ziel jeder Entscheidung in diesem Repo: so einfach wie möglich, dabei sicher genug für echte personenbezogene Daten einer Schule ohne eigenes IT-Personal. Ausführliche Prüfleiter in `rules.md` Abschnitt 1 („Lean by Design") und Abschnitt 2 („Secure by Design"), hier die Kurzfassung, an der sich jeder neue Vorschlag messen lassen muss:

- **Kein Mechanismus ohne konkreten, aktuell vorliegenden Bedarf** — keine Komplexität „für später" oder „für den Fall dass". Bei jeder neuen Idee zuerst die Ladder aus `rules.md` Abschnitt 1 durchgehen und am ersten tragfähigen Punkt stehenbleiben.
- **Vertrauensgrenze** (`rules.md` Abschnitt 2): Root-Admins und Hetzner selbst gelten als vertrauenswürdig — abgesichert über Bus-Faktor-Regeln bzw. die AVV, nicht durch zusätzliche Technik gegen die eigene Root-Ebene. Schutz zielt auf externe Angreifer und kompromittierte Drittanbieter-Credentials (z. B. ein CI-Deploy-Key). Vor jedem neuen Sicherheitsmechanismus prüfen: schützt das wirklich vor einem Angreifer außerhalb dieser Grenze, oder nur gefühlt?
- **Alles, was wiederkehrt, wird automatisiert** — Ausnahme nur, wo ein Mensch zwingend ein bewusst nur ihm bekanntes Geheimnis eingeben muss oder echtes Urteilsvermögen braucht. Ziel: Das System läuft weiter und bleibt wartbar, auch wenn der aktuelle Betreiber weg ist.
- **Bei Zweifel gewinnt die einfachere Lösung**, solange sie das Sicherheits- und Automatisierungsniveau nicht senkt — nicht die technisch elegantere oder vollständigere.

## Aktueller Fokus: VPS fertig, App-Stack-Architektur geplant

Das VPS-Repo (Phasen 1–3 in `pipeline/`: Provisioning, Firewall/SSH-Härtung, Docker-Engine) ist fertig entwickelt und automatisiert.

Die App-Stack-Architektur (Backend-Stack, Reverse-Proxy, Deploy-Auslöser, Identitätsanbieter, Backup-Tool — siehe `project-parts.md`, `idea/03`–`05`, `pipeline/app-stack-repo/04-app-stack-deploy.md`) ist geplant und fixiert. Noch offen: Fallback-Zugriffsweg für externe Nutzer und CORS-Policy (warten auf die Domain-/Frontend-Struktur), sowie alles unter Teams-Apps-Repo/Static-Web-App-Repos (Abschnitt 9/10 in `project-parts.md`).

Nächster Schritt: das App-Stack-Repo tatsächlich anlegen und bauen.

## Dokumentationsstil

Alle `.md`-Dateien in diesem Repo bilden ausschließlich den **aktuellen Stand** ab — keine Historie, keine Changelogs, keine Formulierungen wie „früher", „vorher hatten wir", „wurde ersetzt durch". Beim Ändern von Inhalten wird der alte Stand ersetzt, nicht ergänzt oder als Verlauf stehen gelassen.

Kurz, klar, präzise — kein Blähtext, keine Inhalte, die nur die Länge aufblasen ohne neue Information zu liefern.

## Geltungsbereich dieser Datei

Dieses Root-Repo (`yggdrasil`) ist reine Konzept-/Architektur-Doku, ausschließlich für mich als alleinigen Betreiber. Die Umsetzungs-Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) sind für weitere Personen gedacht — Programmierstil-Regeln (Sprache, Skript-Aufbau, Naming, Fehlerbehandlung etc.) stehen deshalb nicht hier, sondern in der `CLAUDE.md` des jeweiligen Umsetzungs-Repos (aktuell `wb-vps/CLAUDE.md`) — eigenständig, ohne Bezug auf dieses Repo, damit die Umsetzungs-Repos unabhängig funktionieren.
