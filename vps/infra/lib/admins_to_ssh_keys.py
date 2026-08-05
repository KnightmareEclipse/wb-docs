#!/usr/bin/env python3
# Liest admins.yml und gibt je Admin eine Zeile "name<TAB>ssh_key" aus.
# Genutzt von provision.sh (Hetzner-SSH-Key-Ressourcen) und spaeter hardening.sh (authorized_keys).
import sys
import yaml

path = sys.argv[1]
with open(path) as f:
    data = yaml.safe_load(f) or {}

for admin in data.get("admins", []):
    print(f"{admin['name']}\t{admin['ssh_key']}")
