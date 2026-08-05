# VPS-Repo

Reine Host-Ebene für die Hetzner-VPS: „VPS erstellen und verwalten" — Firewall, SSH-Härtung, Docker-Engine. Läuft manuell/lokal von einem Admin-Rechner aus (Root-SSH, eigener Hetzner-API-Token pro Admin). Details/Begründungen in `idea/` und `rules.md` des Hauptrepos; Phasenbeschreibung in `pipeline/vps-repo/`.

## Struktur

- `infra/` — [Phase 1](../pipeline/vps-repo/01-provisioning.md) (Server + Firewall per hcloud-CLI anlegen, Hetzners Standard-Debian-Image unverändert übernommen). `infra/lib/` enthält Hilfsskripte (YAML→hcloud-Input), keine eigenen Einstiegspunkte.
- `setup/` — [Phase 2](../pipeline/vps-repo/02-hardening.md) (Key-Pflege, SSH-Härtung, UFW, verschlüsseltes Swap, unattended-upgrades, `deploy`-User, Secret-Dateien) und [Phase 3](../pipeline/vps-repo/03-docker-install.md) (Rootless-Docker-Install).

Kompletter Ablauf für einen Neuaufbau: [Runbook](../pipeline/runbook.md).

`vps/setup/secrets.age` (age-verschlüsselte Secrets-Datei) entsteht beim ersten Runbook-Durchlauf, sobald ein age-Keypair erzeugt ist — kein Platzhalter hier, da eine leere/gefakte age-Datei nichts Sinnvolles darstellt.
