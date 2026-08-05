#!/usr/bin/env python3
# Liest ports.yml und gibt die Regelliste im Hetzner-Cloud-Firewall-API-Format als JSON aus
# (Input fuer `hcloud firewall create/replace-rules --rules-file -`).
import json
import sys
import yaml

path = sys.argv[1]
with open(path) as f:
    data = yaml.safe_load(f)

rules = [
    {
        "direction": "in",
        "protocol": port["proto"],
        "port": str(port["port"]),
        "source_ips": ["0.0.0.0/0", "::/0"],
        "description": port.get("purpose", ""),
    }
    for port in data["ports"]
]

print(json.dumps(rules))
