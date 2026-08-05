#!/usr/bin/env bash
# Phase 3 — Docker-Engine-Install (pipeline/vps-repo/03-docker-install.md)
# Rootless Docker unter dem deploy-User, ueber Docker's offizielles APT-Repo. Idempotent.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

TARGET_IP="${1:?Usage: $0 <server-ip>}"

# TODO: Docker APT-Repo einrichten (falls fehlend), docker-ce/docker-ce-cli/containerd.io/docker-rootless-extras installieren (No-Op falls vorhanden)
# TODO: als deploy-User: dockerd-rootless-setuptool.sh install
# TODO: als root, einmalig: setcap cap_net_bind_service=ep auf rootlesskit-Binary
# TODO: als root, einmalig: loginctl enable-linger deploy
# TODO: systemctl --user enable docker (als deploy-User)
# TODO: Netzwerk-Segmentierung (extern/intern) als Docker-Netzwerke anlegen
