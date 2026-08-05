# Runbook — Kompletter Neuaufbau

Reihenfolge für einen kompletten Neuaufbau der VPS von Grund auf (z. B. bei Totalausfall). Die VPS läuft bereits, aber ohne schützenswerte Daten — der Neuaufbau beginnt daher direkt bei Schritt 2 auf dem bestehenden Server; Schritt 1 erkennt den existierenden Server per `hcloud server describe` und überspringt die Neuanlage.

**Voraussetzungen, einmalig (nur beim allerersten Setup):**

- MFA ist auf dem Hetzner-Cloud-Konto, dem DNS-Provider-Konto der Schule und dem gemeinsamen Passwortmanager aktiv (`rules.md` Abschnitt 2), bevor der erste persönliche Hetzner-API-Token für Schritt 1 erzeugt wird.
- Eine Secrets-Datei (`secrets.yml`, anfangs mit den ersten Einträgen) liegt als Anhang im gemeinsamen Passwortmanager (`idea/01-boot-verschluesselung.md`) — nicht in Git. Alle folgenden Schritte, die ein Secret ablegen (healthchecks-Ping-URL in Schritt 3, Deploy-/Identitätsanbieter-Secrets in Schritt 5/7), aktualisieren genau diese Datei dort. Bei einem Neuaufbau existiert sie bereits — dann entfällt dieser Punkt.

1. **[Phase 1](vps-repo/01-provisioning.md)** (`vps/infra/`, beliebiger Admin-Rechner mit eigenem Hetzner-API-Token): hcloud-Skript ausführen → Server + Firewall stehen, Hetzners Standard-Debian-Image läuft bereits per Cloud-Init mit den Admin-Keys erreichbar, Server-IP bekannt (neu angelegt oder bereits vorhanden).
2. **DNS** (manuell, einmalig bzw. bei IP-Wechsel): A/AAAA-Record der Subdomain (`idea/02-netzwerk-firewall.md`) beim bestehenden DNS-Provider der Schule auf die Server-IP aus Schritt 1 setzen.
3. **healthchecks.io-Bootstrap** (manuell, einmalig, nur beim allerersten Setup nötig): ein Admin legt den Hobbyist-Account und den Check an, trägt die Account-Zugangsdaten in den gemeinsamen Passwortmanager und die Ping-URL in die Secrets-Datei dort ein. Bei einem Neuaufbau mit bereits bestehendem Account/Check entfällt dieser Schritt.
4. **[Phase 2](vps-repo/02-hardening.md)** (`vps/setup/`, Admin-Rechner, IP aus Schritt 1 als Skriptparameter): Setup-Skript gegen die laufende VPS → Host-Hardening, verschlüsseltes Swap, `deploy`-User, Monitoring-Heartbeat.
5. **Deploy-Key-Bootstrap** (manuell, einmalig bzw. bei Rotation, Admin-Rechner; erst relevant, sobald das App-Stack-Repo/dessen CI/CD-Plattform feststeht): Admin generiert ein `ed25519`-Keypaar. Public Key wird in `vps/setup/admins.yml` ergänzt und per (erneutem) Lauf von Phase 2 in die `authorized_keys` des `deploy`-Users provisioniert. Private Key wird einmalig manuell als maskiertes, geschütztes Secret in der gewählten CI/CD-Plattform des App-Stack-Repos hinterlegt — nie im Repo selbst, nie dauerhaft auf der Admin-Maschine vorgehalten (gleiches Prinzip wie der Push-/Prune-Credential-Split in `idea/05-backup-recovery.md`).
6. **[Phase 3](vps-repo/03-docker-install.md)** (`vps/setup/`): Docker-Engine + Netzwerk-Segmentierung.
7. **Identitätsanbieter-Registrierung-Bootstrap** (manuell, einmalig bzw. bei Wechsel; erst relevant, sobald App-Stack-Architektur und Identitätsanbieter feststehen, `idea/04-identitaet-zugriff.md`): App-/Rollen-Registrierung beim gewählten Anbieter anlegen (Kandidat: M365/Entra-ID-Tenant der Schule), Redirect-URI auf die Subdomain aus `idea/02-netzwerk-firewall.md` setzen, Tenant-Restriktion konfigurieren (kein Multi-Tenant-Fallstrick). Client-ID/Tenant-ID/Client-Secret werden vor dem ersten Lauf von Schritt 8 in die Secrets-Datei im Passwortmanager übernommen — gleicher Provisionierungsweg wie die übrigen Secrets (`idea/03-container-anwendung.md`), da das Backend sie beim ersten Start braucht. Rotation wie bei Schritt 5: neues Secret beim Anbieter erzeugen, in der Secrets-Datei ersetzen, Phase 2 erneut laufen lassen.
8. **[Phase 4](app-stack-repo/04-app-stack-deploy.md)** (App-Stack-Repo, eigene CI/CD gegen `deploy`-User, sobald Architektur/Tools feststehen): App-Stack-Deploy, gehört zum App-Stack-Repo statt zum VPS-Repo.

## Runbook — Server bootet nicht mehr

Kommt praktisch nicht mehr vor: kein automatischer Unlock, kein Custom-Bootloader-Layout mehr im Spiel — Hetzners Standard-Debian-Image (`idea/01-boot-verschluesselung.md`). Falls doch (z. B. defekter Kernel nach einem fehlgeschlagenen Update):

1. **Hetzner Cloud Console → Rescue-Modus** aktivieren (`hcloud server enable-rescue` + Reboot, Web-Konsole MFA-geschützt, `rules.md` Abschnitt 2).
2. Im Rescue-System die Root-Partition mounten, `chroot`, defektes Initramfs/Bootloader neu bauen (`update-initramfs -u` + `update-grub`).
3. Unmount, Rescue-Modus deaktivieren, Reboot.
4. Erreichbarkeit über den Dead-Man's-Switch (healthchecks.io) bestätigen.

Führt das nicht zum Erfolg oder ist der Datenträger endgültig defekt: kompletter Neuaufbau nach dem Runbook oben (die VPS führt keine unersetzlichen Daten — DB/Logs kommen aus dem Backup, `idea/05-backup-recovery.md`).
