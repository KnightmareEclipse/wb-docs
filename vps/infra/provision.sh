#!/usr/bin/env bash
# Phase 1 — Provisioning (pipeline/vps-repo/01-provisioning.md)
# Idempotent gegen hcloud-CLI: legt Server + Firewall + Admin-SSH-Keys an, falls nicht vorhanden,
# synchronisiert die Firewall bei jedem Lauf gegen ports.yml. Deckt "bestehende VPS" ohne
# terraform import ab (rules.md Abschnitt 1) — server describe entscheidet uebernehmen vs. neu anlegen.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

command -v hcloud >/dev/null || { echo "hcloud-CLI nicht gefunden." >&2; exit 1; }

# --- SSH-Keys aus admins.yml idempotent anlegen (eine Quelle, rules.md Abschnitt 3) ---
ADMIN_KEYS=$(python3 ./lib/admins_to_ssh_keys.py ../setup/admins.yml)

SSH_KEY_NAMES=()
while IFS=$'\t' read -r name pubkey; do
    [[ -z "$name" ]] && continue
    if hcloud ssh-key describe "$name" >/dev/null 2>&1; then
        echo "SSH-Key '$name' existiert bereits."
    else
        echo "Lege SSH-Key '$name' an..."
        hcloud ssh-key create --name "$name" --public-key "$pubkey" >/dev/null
    fi
    SSH_KEY_NAMES+=("$name")
done <<<"$ADMIN_KEYS"

if [[ ${#SSH_KEY_NAMES[@]} -eq 0 ]]; then
    echo "Keine Admins in admins.yml eingetragen — Skript kann keinen Server anlegen." >&2
    exit 1
fi

# --- Firewall idempotent anlegen + bei jedem Lauf gegen ports.yml synchronisieren ---
RULES_JSON=$(python3 ./lib/ports_to_firewall_rules.py ./ports.yml)

if hcloud firewall describe "$FIREWALL_NAME" >/dev/null 2>&1; then
    echo "Firewall '$FIREWALL_NAME' existiert, synchronisiere Regeln aus ports.yml..."
else
    echo "Lege Firewall '$FIREWALL_NAME' an..."
    hcloud firewall create --name "$FIREWALL_NAME" >/dev/null
fi
echo "$RULES_JSON" | hcloud firewall replace-rules --rules-file - "$FIREWALL_NAME" >/dev/null

# --- Server: uebernehmen falls vorhanden, sonst neu anlegen ---
if hcloud server describe "$SERVER_NAME" >/dev/null 2>&1; then
    echo "Server '$SERVER_NAME' existiert bereits, uebernehme ihn."
    ACTUAL_TYPE=$(hcloud server describe "$SERVER_NAME" -o json | jq -r '.server_type.name')
    if [[ "$ACTUAL_TYPE" != "$SERVER_TYPE" ]]; then
        echo "WARNUNG: Server-Typ ist '$ACTUAL_TYPE', erwartet '$SERVER_TYPE' (vars.sh) — pruefen." >&2
    fi
    hcloud server add-label --overwrite "$SERVER_NAME" "$HETZNER_LABEL" >/dev/null
else
    echo "Server '$SERVER_NAME' nicht gefunden, lege neu an..."
    SSH_KEY_ARGS=()
    for k in "${SSH_KEY_NAMES[@]}"; do SSH_KEY_ARGS+=(--ssh-key "$k"); done
    # --image debian-12 ist nur ein Platzhalter, Disk wird in Phase 2 komplett neu installiert.
    hcloud server create --name "$SERVER_NAME" --type "$SERVER_TYPE" --location "$REGION" \
        --image debian-12 --label "$HETZNER_LABEL" --firewall "$FIREWALL_NAME" \
        "${SSH_KEY_ARGS[@]}" >/dev/null
fi

# Firewall auch am bereits bestehenden Server sicherstellen (server create haengt sie oben schon an)
if ! hcloud firewall describe "$FIREWALL_NAME" -o json |
    jq -e --arg s "$SERVER_NAME" '[.applied_to[]?.server.name] | index($s)' >/dev/null; then
    echo "Haenge Firewall '$FIREWALL_NAME' an Server '$SERVER_NAME' an..."
    hcloud firewall apply-to-resource --type server --server "$SERVER_NAME" "$FIREWALL_NAME" >/dev/null
fi

echo "Server-IP: $(hcloud server ip "$SERVER_NAME")"
