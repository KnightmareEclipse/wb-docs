# Deployment-Pipeline (Hetzner, End-to-End)

Ableitung aus `idea/` und `project-parts.md` — Phasen mit Automatisierungsgrad, sortiert nach Repo-Zuordnung (siehe „Repo-Struktur" in `project-parts.md`):

*   **`vps-repo/`** — Phasen 1, 2, 3, 4, 5a, 6. Leben im VPS-Repo (lokal `vps/`, Unterordner `infra/`, `setup/`) und laufen weiter lokal/manuell.
*   **`app-stack-repo/`** — Phase 5b. Lebt im App-Stack-Repo (lokal `app-stack/`, Unterordner `compose/`, `api/`) und läuft über dessen eigene CI/CD gegen einen eingeschränkten `deploy`-User — keine dauerhaft lokal vorgehaltenen Secrets für Routine-Deploys.

## Phasen

1. [Provisioning](vps-repo/01-provisioning.md) — `[AUTOMATISIERT]`
2. [Rescue-Boot + verschlüsselte OS-Installation](vps-repo/02-rescue-install.md) — `[SKRIPTBAR, einmalig]`
3. [Erstes Unlock (Bootstrap)](vps-repo/03-erstes-unlock.md) — `[MANUELL, einmalig]`
4. [Key-Pflege + Host-Hardening](vps-repo/04-hardening.md) — `[AUTOMATISIERT]`
5a. [Docker-Engine-Install](vps-repo/05a-docker-install.md) — `[AUTOMATISIERT]`
5b. [App-Stack-Deploy](app-stack-repo/05b-app-stack-deploy.md) — `[AUTOMATISIERT — GitLab CI]`
6. [Wiederkehrendes Reboot-Unlock](vps-repo/06-reboot-unlock.md) — `[MANUELL, dauerhaft]`

Kompletter Ablauf für einen Neuaufbau von Grund auf: [Runbook](runbook.md).

## Automatisierungsgrenze

Alles ist skriptbar/CI-fähig außer:

*   (a) dem einmaligen Konsolen-Bootstrap in Phase 3,
*   (b) der wiederkehrenden Passphrase-Eingabe in Phase 6 — dauerhaft und beabsichtigt,
*   (c) den einmaligen manuellen Bootstrap-Schritten 3b (healthchecks.io), 4b (Deploy-Key) und 5c (Entra-ID-App-Registrierung) im [Runbook](runbook.md), die nur bei Neuanlage bzw. Rotation des jeweiligen Kontos/der App-Registrierung anfallen.

Phase 5b braucht zusätzlich keine dauerhaft lokal vorgehaltenen Secrets mehr, da die Deploy-Pipeline eigene, zentral rotierbare CI-Credentials nutzt statt der Admin-Maschine.
