# Phase 5b — App-Stack-Deploy

`[AUTOMATISIERT — GitLab CI, app-stack/compose/, app-stack/api/]`

Caddy, Postgres, API-Container (alle mit Docker-Log-Treiber `journald` statt eigenem Loki/Promtail-Stack, `idea/03-container-anwendung.md`), Secrets als von [Phase 4](../vps-repo/04-hardening.md) vorprovisionierte `/run/secrets/*`-Dateien (nur gemountet, keine Secret-Werte in GitLab CI), Restic-Systemd-Timer.

## Build

GitLab CI baut das API-Image im isolierten Runner, testet es (Testfall/Framework siehe `project-parts.md` Abschnitt 4) und pusht es erst bei grünem Testlauf in die projekteigene GitLab Container Registry (gitlab.com, kostenloser Tier) — hält Build-Toolchain und beliebige Third-Party-Dependencies von der Produktions-VPS fern, passend zur Rootless-Docker-Härtung (`idea/03-container-anwendung.md`). Tag ist der Git-Commit-SHA (`registry/api:<sha>`), zusätzlich `latest` für den normalen Deploy — der SHA-Tag macht jede deployte Version eindeutig referenzierbar (Reproduzierbarkeit, `rules.md` Abschnitt 6).

## Rollback

Bei einem fehlgeschlagenen/fehlerhaften Deploy: Deploy-Job manuell mit dem SHA-Tag der letzten bekannt guten Version erneut anstoßen (GitLab-CI-Variable oder manueller Pipeline-Run) — zieht dieses Image statt `latest`, führt `docker compose up` erneut aus. Ein DB-Migrations-Rollback ist davon separat zu betrachten (Alembic-Downgrade nur, wenn das jeweilige Migrationsskript eines definiert) und wird pro Vorfall manuell entschieden, kein automatischer Schema-Rollback.

## Deploy

*   Verbindet sich per SSH mit einem eingeschränkten Deploy-Key (CI/CD-Variable, maskiert) gegen den `deploy`-User aus Phase 4.
*   Zieht das Image mit einem read-only GitLab-Deploy-Token.
*   Führt darüber (nicht vom GitLab-Runner selbst — Postgres ist nach außen komplett geschlossen, `idea/02-netzwerk-firewall.md`) `docker compose run --rm migrate alembic upgrade head` gegen die separate Migrations-DB-Rolle aus (`idea/03-container-anwendung.md`) — `migrate` ist ein eigener Compose-Service-Block auf demselben Image wie `api`, aber mit eigenem Secret-Mount (`/run/secrets/db_migration_role`) und `profiles: ["migrate"]`, damit er nicht Teil des normalen `docker compose up` wird. Erreicht die DB über das interne Docker-Netz, deckt auch das initiale Schema beim allerersten Deploy ab, kein separater Bootstrap-Schritt nötig.
*   Der SSH-Deploy-Job läuft mit `set -e`: Ein nicht-null Exit-Code von `alembic upgrade head` bricht den Job vor dem nachfolgenden `docker compose up` ab — die zuvor laufenden Container bleiben unverändert aktiv, kein Teil-Deploy mit neuem Image auf altem oder halb migriertem Schema.
*   Führt erst danach `docker compose up` aus.

Kein Hetzner-Token, kein Root-Zugriff, keine dauerhaft lokal vorgehaltenen Secrets für Routine-Deploys.

Caddy übernimmt zusätzlich das Ausliefern der statischen Teams-Tab-Seiten (Abschnitt 10 in `project-parts.md`) — kein separater Azure-Host nötig für den Staff-Kanal.
