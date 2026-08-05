# cyborg

Konzept- und Architektur-Doku für einen selbstverwalteten, DSGVO-konformen Datenbank-/API-VPS (Hetzner) für Schulprozesse — LUKS-Verschlüsselung mit manuellem Unlock, Docker-Netzwerk-Isolation, OIDC/Entra-ID-Auth, Restic-Backups. Details in `idea.md`, `pipeline.md`, `project-parts.md`.

Umsetzung erfolgt in getrennten Repos (VPS-Repo, App-Stack-Repo, Teams-Apps-Repo, Static-Web-App-Repos) — siehe „Repo-Struktur" in `project-parts.md`.

## Dokumentationsstil

Alle `.md`-Dateien in diesem Repo bilden ausschließlich den **aktuellen Stand** ab — keine Historie, keine Changelogs, keine Formulierungen wie „früher", „vorher hatten wir", „wurde ersetzt durch". Beim Ändern von Inhalten wird der alte Stand ersetzt, nicht ergänzt oder als Verlauf stehen gelassen.
