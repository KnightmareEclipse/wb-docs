# Runbook — Kompletter Neuaufbau

Reihenfolge für einen kompletten Neuaufbau der VPS von Grund auf (z. B. bei Totalausfall). Die VPS läuft bereits, aber ohne schützenswerte Daten — der Neuaufbau beginnt daher direkt bei Schritt 2 auf dem bestehenden Server; Schritt 1 erkennt den existierenden Server per `hcloud server describe` und überspringt die Neuanlage.

**Voraussetzungen, einmalig (nur beim allerersten Setup):**

- MFA ist auf dem Hetzner-Cloud-Konto und dem DNS-Provider-Konto der Schule aktiv, das gemeinsame KeePass ist mit einem starken Master-Passwort geschützt (kein MFA anwendbar, `rules.md` Abschnitt 2) — beides bevor der erste persönliche Hetzner-API-Token für Schritt 1 erzeugt wird.
- Eine Secrets-Datei (`secrets.env`, anfangs mit den ersten Einträgen; Format/Schema/Ablage siehe `pipeline/vps-repo/02-hardening.md`) liegt als Datei-Anhang in der gemeinsamen KeePass-Datenbank — nicht in Git. Alle folgenden Schritte, die ein Secret ablegen (healthchecks-Ping-URL in Schritt 3, Identitätsanbieter-Secrets in Schritt 7), aktualisieren genau diese Datei dort. Bei einem Neuaufbau existiert sie bereits — dann entfällt dieser Punkt.

1. **[Phase 1](vps-repo/01-provisioning.md)** (`wb-vps/infra/`, beliebiger Admin-Rechner mit eigenem Hetzner-API-Token): hcloud-Skript ausführen → Server + Firewall stehen, Hetzners Standard-Debian-Image läuft bereits per Cloud-Init mit den Admin-Keys erreichbar, Server-IP bekannt (neu angelegt oder bereits vorhanden).
2. **DNS** (manuell, einmalig bzw. bei IP-Wechsel): A/AAAA-Record von `api.clemens.schule` beim DNS-Provider der Schule (All-Inkl, KAS-Panel unter Tools → DNS-Verwaltung) auf die Server-IP aus Schritt 1 setzen — reiner Backend-Endpunkt, wird nie als Seite aufgerufen (nur per API-Aufruf aus den Frontends), Namenswahl daher ohne Sicherheitsrelevanz (Certificate-Transparency-Logs machen den Hostnamen ohnehin öffentlich, sobald ein Zertifikat ausgestellt wird).
3. **healthchecks.io-Bootstrap** (manuell, einmalig, nur beim allerersten Setup nötig): ein Admin legt den Hobbyist-Account und den Check an, trägt die Account-Zugangsdaten in den gemeinsamen Passwortmanager und die Ping-URL in die Secrets-Datei dort ein. Bei einem Neuaufbau mit bereits bestehendem Account/Check entfällt dieser Schritt.
4. **[Phase 2](vps-repo/02-hardening.md)** (`wb-vps/setup/`, Admin-Rechner, IP aus Schritt 1 als Skriptparameter): Setup-Skript gegen die laufende VPS → Host-Hardening, verschlüsseltes Swap, `deploy`-User, Monitoring-Heartbeat.
5. **Deploy-Auslöser-Bootstrap** (App-Stack-Repo `wb-backend`): Build/Deploy laufen direkt auf der VPS, kein externer CI-Runner hält einen Deploy-Key (`idea/03-container-anwendung.md`, `pipeline/app-stack-repo/04-app-stack-deploy.md`). Auslöser: Bare Git-Repo unter dem `deploy`-User, Admin pusht mit vorhandenem Key, serverseitig per `git-shell`-Forced-Command auf Git-Operationen beschränkt — kein separater Key-Typ wie beim Backup-Pull-Key nötig, da hier immer ein vertrauter Admin auslöst, nicht ein unbeaufsichtigter Prozess auf fremder Maschine.
6. **[Phase 3](vps-repo/03-docker-install.md)** (`wb-vps/setup/`): Rootless-Docker-Engine.
7. **Identitätsanbieter-Registrierung-Bootstrap** (manuell, einmalig bzw. bei Wechsel, `idea/04-identitaet-zugriff.md`): App-/Rollen-Registrierung beim M365/Entra-ID-Tenant der Schule anlegen (final bestätigt, Tenant-Zugriff vorhanden), Redirect-URI auf die Origin des internen Frontends setzen (`idea/04-identitaet-zugriff.md` — nicht auf die Subdomain aus Schritt 2; steht erst mit der Frontend-/Domain-Struktur fest, `project-parts.md` Abschnitt 10), Tenant-Restriktion konfigurieren (kein Multi-Tenant-Fallstrick). Client-ID/Tenant-ID/Client-Secret werden vor dem ersten Lauf von Schritt 8 in die Secrets-Datei im Passwortmanager übernommen — gleicher Provisionierungsweg wie die übrigen Secrets (`idea/03-container-anwendung.md`), da das Backend sie beim ersten Start braucht. Rotation: neues Secret beim Anbieter erzeugen, in der Secrets-Datei ersetzen, Phase 2 erneut laufen lassen — gleiches Grundmuster wie DB-Rollen-Rotation (`idea/03-container-anwendung.md`).
8. **[Phase 4](app-stack-repo/04-app-stack-deploy.md)** (App-Stack-Repo, Git-Push-Auslöser gegen `deploy`-User, sobald das Repo existiert): App-Stack-Deploy, gehört zum App-Stack-Repo statt zum VPS-Repo.

## Runbook — Server bootet nicht mehr

Kommt praktisch nicht mehr vor: kein automatischer Unlock, kein Custom-Bootloader-Layout mehr im Spiel — Hetzners Standard-Debian-Image (`pipeline/vps-repo/01-provisioning.md`). Falls doch (z. B. defekter Kernel nach einem fehlgeschlagenen Update):

1. **Hetzner Cloud Console → Rescue-Modus** aktivieren (`hcloud server enable-rescue` + Reboot, Web-Konsole MFA-geschützt, `rules.md` Abschnitt 2).
2. Im Rescue-System die Root-Partition mounten, `chroot`, defektes Initramfs/Bootloader neu bauen (`update-initramfs -u` + `update-grub`).
3. Unmount, Rescue-Modus deaktivieren, Reboot.
4. Erreichbarkeit über den Dead-Man's-Switch (healthchecks.io) bestätigen.

Führt das nicht zum Erfolg oder ist der Datenträger endgültig defekt: kompletter Neuaufbau nach dem Runbook oben (die VPS führt keine unersetzlichen Daten — DB/Logs kommen aus dem Backup, `idea/05-backup-recovery.md`).
