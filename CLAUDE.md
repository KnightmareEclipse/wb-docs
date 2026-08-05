# yggdrasil

Konzept- und Architektur-Doku für einen selbstverwalteten, DSGVO-konformen Datenbank-/API-VPS (Hetzner) für Schulprozesse — Docker-Netzwerk-Isolation, externer OIDC-Identitätsanbieter, verschlüsselte Backups. Das VPS/Host-Setup (Firewall, Docker-Engine) wird gerade konkret umgesetzt; die App-Stack-Ebene darüber (Datenbank, Backend, Reverse-Proxy, Backup-Tool, Identitätsanbieter, CI/CD) ist bewusst nur als Toolkategorie beschrieben, keine konkreten Produkte fixiert, bis die App-Stack-Entwicklung tatsächlich beginnt. Details in `idea/`, `pipeline/`, `project-parts.md`. Die Planungsprinzipien, denen alle drei folgen, stehen in `rules.md` — jede neue Entscheidung in diesem Repo hält sich daran, insbesondere die dort explizit benannte Vertrauensgrenze (Abschnitt 2): Root-Admins und Hetzner selbst gelten als vertrauenswürdig, das Bedrohungsmodell zielt auf externe Angreifer.

Umsetzung erfolgt in getrennten Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) — siehe „Repo-Struktur" in `project-parts.md`.

## Leitprinzip: Stupidly Simple, aber sicher

Ziel jeder Entscheidung in diesem Repo: so einfach wie möglich, dabei sicher genug für echte personenbezogene Daten einer Schule ohne eigenes IT-Personal. Ausführliche Prüfleiter in `rules.md` Abschnitt 1 („Lean by Design") und Abschnitt 2 („Secure by Design"), hier die Kurzfassung, an der sich jeder neue Vorschlag messen lassen muss:

- **Kein Mechanismus ohne konkreten, aktuell vorliegenden Bedarf** — keine Komplexität „für später" oder „für den Fall dass". Bei jeder neuen Idee zuerst die Ladder aus `rules.md` Abschnitt 1 durchgehen und am ersten tragfähigen Punkt stehenbleiben.
- **Vertrauensgrenze** (`rules.md` Abschnitt 2): Root-Admins und Hetzner selbst gelten als vertrauenswürdig — abgesichert über Bus-Faktor-Regeln bzw. die AVV, nicht durch zusätzliche Technik gegen die eigene Root-Ebene. Schutz zielt auf externe Angreifer und kompromittierte Drittanbieter-Credentials (z. B. ein CI-Deploy-Key). Vor jedem neuen Sicherheitsmechanismus prüfen: schützt das wirklich vor einem Angreifer außerhalb dieser Grenze, oder nur gefühlt?
- **Alles, was wiederkehrt, wird automatisiert** — Ausnahme nur, wo ein Mensch zwingend ein bewusst nur ihm bekanntes Geheimnis eingeben muss oder echtes Urteilsvermögen braucht. Ziel: Das System läuft weiter und bleibt wartbar, auch wenn der aktuelle Betreiber weg ist.
- **Bei Zweifel gewinnt die einfachere Lösung**, solange sie das Sicherheits- und Automatisierungsniveau nicht senkt — nicht die technisch elegantere oder vollständigere.

## Aktueller Fokus: nur der VPS

Aktuell wird ausschließlich das VPS-Repo (Phasen 1–3 in `pipeline/`: Provisioning, Firewall/SSH-Härtung, Docker-Engine) tatsächlich entwickelt und dafür konkret ausdetailliert — das ist der einzige Teil, an dem gerade gearbeitet wird.

Alles, was auf dem VPS laufen soll (App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos — Backend, Datenbank, Reverse-Proxy, Backup-Tool, Identitätsanbieter, CI/CD) ist für die aktuelle Arbeit **irrelevant** und bewusst nicht festgelegt. Es taucht in der Doku nur grob auf, um zu wissen, welche Fähigkeiten die Infrastruktur/der VPS später bereitstellen muss (offene Ports, Docker als Laufzeit, Platz für Secrets-Dateien etc.) — nicht um es jetzt schon zu bauen oder zu entscheiden. Vorschläge, Code oder Detailausarbeitung für diesen Teil sind erst gefragt, wenn das VPS-Setup steht und explizit dazu übergegangen wird.

## Dokumentationsstil

Alle `.md`-Dateien in diesem Repo bilden ausschließlich den **aktuellen Stand** ab — keine Historie, keine Changelogs, keine Formulierungen wie „früher", „vorher hatten wir", „wurde ersetzt durch". Beim Ändern von Inhalten wird der alte Stand ersetzt, nicht ergänzt oder als Verlauf stehen gelassen.

Kurz, klar, präzise — kein Blähtext, keine Inhalte, die nur die Länge aufblasen ohne neue Information zu liefern.

## Geltungsbereich dieser Datei

Dieses Root-Repo (`yggdrasil`) ist reine Konzept-/Architektur-Doku, ausschließlich für mich als alleinigen Betreiber. Die Umsetzungs-Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) sind für weitere Personen gedacht — Programmierstil-Regeln (Sprache, Skript-Aufbau, Naming, Fehlerbehandlung etc.) stehen deshalb nicht hier, sondern in der `CLAUDE.md` des jeweiligen Umsetzungs-Repos (aktuell `wb-vps/CLAUDE.md`) — eigenständig, ohne Bezug auf dieses Repo, damit die Umsetzungs-Repos unabhängig funktionieren.
