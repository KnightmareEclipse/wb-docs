# Deployment-Pipeline (Hetzner, End-to-End)

Ableitung aus `idea/` und `project-parts.md` — Phasen mit Automatisierungsgrad, sortiert nach Repo-Zuordnung (siehe „Repo-Struktur" in `project-parts.md`):

*   **`vps-repo/`** — Phasen 1, 2, 3. Leben im VPS-Repo (`wb-vps`, Unterordner `infra/`, `setup/`), laufen weiter lokal/manuell und werden jetzt konkret umgesetzt.
*   **`app-stack-repo/`** — Phase 4. Lebt im App-Stack-Repo (`wb-backend`) und läuft über einen Git-Push-Auslöser (Bare-Repo + `post-receive`-Hook) gegen einen eingeschränkten `deploy`-User — keine dauerhaft lokal vorgehaltenen Secrets für Routine-Deploys. Stack: FastAPI/PostgreSQL/Caddy, siehe `project-parts.md`.

## Phasen

1. [Provisioning](vps-repo/01-provisioning.md) — `[AUTOMATISIERT]`
2. [Key-Pflege + Host-Hardening](vps-repo/02-hardening.md) — `[AUTOMATISIERT]`
3. [Docker-Engine-Install](vps-repo/03-docker-install.md) — `[AUTOMATISIERT]`
4. [App-Stack-Deploy](app-stack-repo/04-app-stack-deploy.md) — `[Backend-Grundgerüst steht (wb-backend), VPS-Auslöser offen]`

Kompletter Ablauf für einen Neuaufbau von Grund auf: [Runbook](runbook.md).

## Automatisierungsgrenze

Server-Provisioning, Ersteinrichtung und jeder Reboot danach laufen komplett automatisch. Manuell bleiben nur die einmaligen Konto-Bootstrap-Schritte, die zwingend ein von einem Menschen gehaltenes Geheimnis voraussetzen — Schritte 3 (healthchecks.io), 5 (Deploy-Auslöser) und 7 (Identitätsanbieter-Registrierung) im [Runbook](runbook.md), die nur bei Neuanlage bzw. Rotation des jeweiligen Kontos/der Registrierung anfallen; Schritte 5 und 7 sind jetzt dran, da das App-Stack-Repo (`wb-backend`) existiert.

Phase 4 braucht zusätzlich keine dauerhaft lokal vorgehaltenen Secrets — der Deploy-Auslöser nutzt den vorhandenen, `git-shell`-beschränkten Admin-Key, kein separates CI-Credential nötig.

## Testbarkeit vor Prod-Lauf

Jeder Skriptlauf der Phasen 1–3 gegen die echte VPS wird vorher gegen eine temporäre Wegwerf-VPS (gleicher Typ/gleiches Image, danach gelöscht) durchgespielt, inklusive zweitem Lauf zum Idempotenz-Check (`rules.md` Abschnitt 8).
