#!/usr/bin/env bash
# Gemeinsame Konstanten für infra/- und setup/-Skripte (rules.md Abschnitt 3: eine Quelle pro Sachverhalt).
# Wird von den anderen Skripten per `source` eingebunden, kein eigenständig lauffähiges Skript.

SERVER_NAME="db-prod-fsn-01"    # bestehender Server, wird von Phase 1 uebernommen statt neu bestellt
HETZNER_LABEL="managed-by=vps-repo"  # Hetzner-Label zur Server-Identifikation (Phase 1)
SERVER_TYPE="cx33"        # 4 vCPU shared, 8GB RAM, 80GB NVMe SSD
REGION="fsn1"             # Falkenstein — Fallback nbg1, beide DE
FIREWALL_NAME="vps-firewall"    # Name der Hetzner Cloud Firewall (Phase 1)
