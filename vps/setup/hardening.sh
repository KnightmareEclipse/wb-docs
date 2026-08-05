#!/usr/bin/env bash
# Phase 3 — Key-Pflege + Host-Hardening (pipeline/vps-repo/03-hardening.md)
# Idempotent gegen den laufenden Host per SSH, immer als root. IP als Skriptparameter.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

TARGET_IP="${1:?Usage: $0 <server-ip>}"

# TODO: admins.yml -> Host-authorized_keys idempotent abgleichen (hinzufuegen/entfernen)
# TODO: sshd_config: PasswordAuthentication no
# TODO: UFW aus ../infra/ports.yml, Reihenfolge: erst `ufw limit 22`, dann `ufw default deny incoming` + `ufw enable`
# TODO: unattended-upgrades inkl. Origin-Pattern fuer download.docker.com, Kernel-Update-Hook (update-initramfs/update-grub),
#       Remove-Unused-Kernel-Packages, festes woechentliches Reboot-Wartungsfenster
# TODO: healthchecks.io-Heartbeat-Timer (Disk-Space, reboot-required, unattended-upgrades-Fehlschlag), alle 15 Min
# TODO: deploy-User anlegen (kein Root), CI-Deploy-Pubkey aus admins.yml/Runbook Schritt 6 in dessen authorized_keys
# TODO: Secret-Dateien aus setup/secrets.age lokal entschluesseln (age-Private-Key) und mit deploy-Ownership auf Host schreiben
