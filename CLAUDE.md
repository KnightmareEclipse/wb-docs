# cyborg

Konzept- und Architektur-Doku für einen selbstverwalteten, DSGVO-konformen Datenbank-/API-VPS (Hetzner) für Schulprozesse — LUKS-Verschlüsselung mit manuellem Unlock, Docker-Netzwerk-Isolation, externer OIDC-Identitätsanbieter, verschlüsselte Backups. Das VPS/Host-Setup (LUKS, Dropbear, Firewall, Docker-Engine) wird gerade konkret umgesetzt; die App-Stack-Ebene darüber (Datenbank, Backend, Reverse-Proxy, Backup-Tool, Identitätsanbieter, CI/CD) ist bewusst nur als Toolkategorie beschrieben, keine konkreten Produkte fixiert, bis die App-Stack-Entwicklung tatsächlich beginnt. Details in `idea/`, `pipeline/`, `project-parts.md`. Die Planungsprinzipien, denen alle drei folgen, stehen in `rules.md` — jede neue Entscheidung in diesem Repo hält sich daran.

Umsetzung erfolgt in getrennten Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) — siehe „Repo-Struktur" in `project-parts.md`.

## Aktueller Fokus: nur der VPS

Aktuell wird ausschließlich das VPS-Repo (Phasen 1–4, 5a, 6 in `pipeline/`: LUKS, Dropbear, Firewall, SSH-Härtung, Docker-Engine) tatsächlich entwickelt und dafür konkret ausdetailliert — das ist der einzige Teil, an dem gerade gearbeitet wird.

Alles, was auf dem VPS laufen soll (App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos — Backend, Datenbank, Reverse-Proxy, Backup-Tool, Identitätsanbieter, CI/CD) ist für die aktuelle Arbeit **irrelevant** und bewusst nicht festgelegt. Es taucht in der Doku nur grob auf, um zu wissen, welche Fähigkeiten die Infrastruktur/der VPS später bereitstellen muss (offene Ports, Docker als Laufzeit, Platz für Secrets-Dateien etc.) — nicht um es jetzt schon zu bauen oder zu entscheiden. Vorschläge, Code oder Detailausarbeitung für diesen Teil sind erst gefragt, wenn das VPS-Setup steht und explizit dazu übergegangen wird.

## Dokumentationsstil

Alle `.md`-Dateien in diesem Repo bilden ausschließlich den **aktuellen Stand** ab — keine Historie, keine Changelogs, keine Formulierungen wie „früher", „vorher hatten wir", „wurde ersetzt durch". Beim Ändern von Inhalten wird der alte Stand ersetzt, nicht ergänzt oder als Verlauf stehen gelassen.
