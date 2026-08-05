# Deployment-Pipeline (Hetzner, End-to-End)

Ableitung aus `idea/` und `project-parts.md` — Phasen mit Automatisierungsgrad, sortiert nach Repo-Zuordnung (siehe „Repo-Struktur" in `project-parts.md`):

*   **`vps-repo/`** — Phasen 1, 2, 3. Leben im VPS-Repo (lokal `vps/`, Unterordner `infra/`, `setup/`), laufen weiter lokal/manuell und werden jetzt konkret umgesetzt.
*   **`app-stack-repo/`** — Phase 4. Lebt im späteren App-Stack-Repo (lokal `app-stack/`) und läuft über eine eigene CI/CD gegen einen eingeschränkten `deploy`-User — keine dauerhaft lokal vorgehaltenen Secrets für Routine-Deploys. Konkrete Tools/Plattform noch offen (`project-parts.md`).

## Phasen

1. [Provisioning](vps-repo/01-provisioning.md) — `[AUTOMATISIERT]`
2. [Key-Pflege + Host-Hardening](vps-repo/02-hardening.md) — `[AUTOMATISIERT]`
3. [Docker-Engine-Install](vps-repo/03-docker-install.md) — `[AUTOMATISIERT]`
4. [App-Stack-Deploy](app-stack-repo/04-app-stack-deploy.md) — `[Konzept, Tools/Plattform offen]`

Kompletter Ablauf für einen Neuaufbau von Grund auf: [Runbook](runbook.md).

## Automatisierungsgrenze

Server-Provisioning, Ersteinrichtung und jeder Reboot danach laufen komplett automatisch. Manuell bleiben nur die einmaligen Konto-Bootstrap-Schritte, die zwingend ein von einem Menschen gehaltenes Geheimnis voraussetzen — Schritte 3 (healthchecks.io), 5 (Deploy-Key) und 7 (Identitätsanbieter-Registrierung, sobald App-Stack-Architektur/-Anbieter feststehen) im [Runbook](runbook.md), die nur bei Neuanlage bzw. Rotation des jeweiligen Kontos/der Registrierung anfallen.

Phase 4 braucht zusätzlich keine dauerhaft lokal vorgehaltenen Secrets, da die Deploy-Pipeline eigene, zentral rotierbare CI-Credentials nutzt statt der Admin-Maschine.
