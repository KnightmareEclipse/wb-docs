# Phase 5b — App-Stack-Deploy

`[AUTOMATISIERT — GitLab CI, app-stack/compose/, app-stack/api/]`

Caddy, Postgres, API-Container (alle mit Docker-Log-Treiber `journald` statt eigenem Loki/Promtail-Stack, `idea/03-container-anwendung.md`), Secrets als von [Phase 4](../vps-repo/04-hardening.md) vorprovisionierte `/run/secrets/*`-Dateien (nur gemountet, keine Secret-Werte in GitLab CI), Restic-Systemd-Timer.

## Build

GitLab CI baut das API-Image im isolierten Runner und pusht es in die projekteigene GitLab Container Registry (gitlab.com, kostenloser Tier) — hält Build-Toolchain und beliebige Third-Party-Dependencies von der Produktions-VPS fern, passend zur Rootless-Docker-Härtung (`idea/03-container-anwendung.md`).

## Deploy

*   Verbindet sich per SSH mit einem eingeschränkten Deploy-Key (CI/CD-Variable, maskiert) gegen den `deploy`-User aus Phase 4.
*   Zieht das Image mit einem read-only GitLab-Deploy-Token.
*   Führt darüber (nicht vom GitLab-Runner selbst — Postgres ist nach außen komplett geschlossen, `idea/02-netzwerk-firewall.md`) `docker compose run --rm api alembic upgrade head` gegen die separate Migrations-DB-Rolle aus (`idea/03-container-anwendung.md`, Credential aus der age-verschlüsselten Secrets-Datei) — erreicht die DB so über das interne Docker-Netz, deckt auch das initiale Schema beim allerersten Deploy ab, kein separater Bootstrap-Schritt nötig.
*   Führt danach `docker compose up` aus.

Kein Hetzner-Token, kein Root-Zugriff, keine dauerhaft lokal vorgehaltenen Secrets für Routine-Deploys.

Caddy übernimmt zusätzlich das Ausliefern der statischen Teams-Tab-Seiten (Abschnitt 10 in `project-parts.md`) — kein separater Azure-Host nötig für den Staff-Kanal.
