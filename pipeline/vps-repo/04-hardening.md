# Phase 4 — Key-Pflege + Host-Hardening

`[AUTOMATISIERT — Shell-Skript, vps/setup/]`

Idempotentes Bash-Skript im Stil von Phase 1/2 (kein Ansible — bei genau einer VPS mit statischer IP derselbe „Overkill"-Grund wie der Terraform-Verzicht in [Phase 1](01-provisioning.md), IP wird als Skriptparameter/Konstante übergeben, keine Inventory-Datei nötig), läuft über normales SSH, sobald die Platte entschlüsselt und der Host oben ist — immer als `root`, da der `deploy`-User laut `project-parts.md` kein Root ist und ohnehin erst durch diese Phase angelegt wird.

## Aufgaben

*   **Key-Pflege:** Dropbear-`authorized_keys` und Host-`authorized_keys` idempotent pflegen (Quelle: `vps/setup/admins.yml`; Admin hinzufügen/entfernen, ein Key pro Admin, kein geteilter Key/Keyset) + `update-initramfs` danach — keine erneute Installation von `dropbear-initramfs`, das übernimmt bereits [Phase 2](02-rescue-install.md).
*   **SSH-Härtung:** `PasswordAuthentication no`.
*   **Firewall (UFW):** zweite Firewall-Ebene neben der Hetzner Cloud Firewall aus [Phase 1](01-provisioning.md) — liest dieselbe `ports.yml` wie das hcloud-Skript, Cloud Firewall bleibt Quelle der Wahrheit. Der SSH-Port bekommt `ufw limit` statt `ufw allow` (UFWs `hashlimit`-basiertes Rate-Limiting, Default 6 Verbindungen/30s pro IP) — das ist die einzige der beiden in `idea/02-netzwerk-firewall.md` genannten Ebenen, die Rate-Limiting technisch tatsächlich liefert. Skript-Reihenfolge dabei verbindlich: erst `ufw limit` für den SSH-Port, danach erst `ufw default deny incoming` + `ufw enable`, sonst sperrt sich die laufende SSH-Session selbst aus.
*   **fail2ban:** schützt Host-SSH nach dem Boot gegen Verbindungsflut/Exploit-Versuche gegen sshd, nicht gegen Bruteforce — Key-only-Auth lässt kein Passwort zum Erraten. Dropbear-Zeitfenster vor Haupt-OS-Start bleibt für dasselbe Bedrohungsbild bewusst ungeschützt (kein `fail2ban`, kein Rate-Limiting — Begründung siehe `idea/02-netzwerk-firewall.md`).
*   **unattended-upgrades:** Konfiguration inkl. APT-Hook für automatisches `update-initramfs`/`update-grub` nach Kernel-Updates.
*   **Monitoring-Heartbeat:** Host-Cronjob/systemd-Timer für den healthchecks.io-Heartbeat (Disk-Space-Check + `reboot-required`-Check + `unattended-upgrades`-Fehlschlag-Check alle 15 Minuten, Ping-URL als Secret analog zu den übrigen Phase-4-Secrets behandelt) — Dead-Man's-Switch über healthchecks.io (kostenloser Hobbyist-Plan, Hetzner Deutschland), siehe `idea/01-boot-verschluesselung.md`.
*   **`deploy`-User:** legt einen eingeschränkten `deploy`-SSH-User an (kein Root) — die Schnittstelle, über die [Phase 5b](../app-stack-repo/05b-app-stack-deploy.md) später andockt.
    *   Der Public Key für den GitLab-CI-Deploy-Zugriff (Bootstrap siehe [Runbook, Schritt 7](../runbook.md)) wird dabei idempotent wie die übrigen Admin-Keys in die `authorized_keys` des `deploy`-Users provisioniert.
    *   Für den in [Phase 5a](05a-docker-install.md) installierten Rootless-Docker-Daemon zusätzlich einmalig (als Root, danach nie wieder nötig): `setcap cap_net_bind_service=ep` auf das `rootlesskit`-Binary sowie `loginctl enable-linger deploy`, damit Port 80/443 gebunden werden kann und der Daemon auch ohne aktive SSH-Session weiterläuft.
*   **Secret-Dateien:** schreibt die Secret-Dateien (DB-Zugangsdaten, OIDC-Client-Secret, Restic-Repo-Passwort) aus der age-verschlüsselten Secrets-Datei mit `deploy`-User-Ownership auf den Host (`idea/03-container-anwendung.md`) — [Phase 5b](../app-stack-repo/05b-app-stack-deploy.md) mountet sie nur noch, GitLab CI bekommt die Werte nie zu Gesicht.
