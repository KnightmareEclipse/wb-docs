# Runbook — Kompletter Neuaufbau

Reihenfolge für einen kompletten Neuaufbau der VPS von Grund auf (z. B. bei Totalausfall). Hier steht alles, was ein Mensch dabei tun muss — alles andere erledigen die Skripte in `wb-vps`. Ein vollständiger Durchlauf dauert wenige Minuten; die VPS führt keine unersetzlichen Daten, DB und Logs kommen aus dem Backup (`idea/05-backup-recovery.md`).

**Nur beim allerersten Setup:**

- MFA ist auf dem Hetzner-Cloud-Konto und dem DNS-Provider-Konto der Schule aktiv, das gemeinsame KeePass ist mit einem starken Master-Passwort geschützt (kein MFA anwendbar, `rules.md` Abschnitt 2) — beides, bevor der erste persönliche Hetzner-API-Token entsteht.
- Die Secrets-Datei (`secrets.env`) liegt als Datei-Anhang in der gemeinsamen KeePass-Datenbank, nie in Git. Schema: `wb-vps/setup/secrets.example.env`; Format und Ablage: [Phase 2](vps-repo/02-hardening.md). Jeder Schritt unten, der ein Secret erzeugt, trägt es dort ein — dieser Anhang ist die einzige Kopie, die einen Neuaufbau überlebt. Die DB-Rollen-Passwörter (`APP_*`) sind frei gewählte Zufallswerte und stehen dort ebenfalls; ohne sie scheitert Schritt 6.

1. **Admin-Rechner vorbereiten** (jedes Mal):

    ```bash
    cd wb-vps
    setup/preflight.sh     # nennt fehlende Werkzeuge samt Installationsbefehl, installiert nichts
    hcloud context create  # einmal je Rechner, mit dem eigenen persönlichen API-Token
    ```

    Dazu den `secrets.env`-Anhang aus KeePass lokal herunterladen — Schritt 4 liest ihn.

    **Und den Admin-Key dem SSH-Client anbieten**, einmal je Sitzung: `ssh-add <pfad-zum-key>`. Jeder Schritt unten spricht den Server über seine **IP** an, und ein Schlüssel, der nicht `~/.ssh/id_ed25519` heißt, wird dabei nur angeboten, wenn ein Agent ihn hält oder ein `Host`-Eintrag ihn nennt — ein Eintrag auf einen Alias greift nicht, wenn das Skript eine IP übergibt. Ohne das scheitern `deploy-secrets.sh`, `redeploy.sh`, der `ansible-playbook`-Lauf und der Deploy-Push gleichermaßen an `Permission denied (publickey)`, obwohl der Schlüssel in `admins.yml` steht und auf dem Server liegt.

2. **DNS** (einmalig bzw. bei IP-Wechsel): A/AAAA-Records für `api.clemens.schule`, `portal.clemens.schule` und `intern.clemens.schule` beim DNS-Provider der Schule (All-Inkl, KAS-Panel unter Tools → DNS-Verwaltung) auf dieselbe Server-IP setzen. `api.` ist reiner Backend-Endpunkt und wird nie als Seite aufgerufen; die beiden anderen tragen Eltern- und Personaloberfläche und rufen die API unter ihrem eigenen Namen (`project-parts.md` Abschnitt 9). Die Namenswahl ist ohne Sicherheitsrelevanz — Certificate-Transparency-Logs machen jeden Hostnamen öffentlich, sobald ein Zertifikat ausgestellt wird. Caddy holt je Name ein eigenes Zertifikat, ein Wildcard und damit ein DNS-Zugang für den Proxy sind nicht nötig. Bei einem Neuaufbau auf demselben Server bleibt die IP erhalten und der Schritt entfällt.
3. **healthchecks.io-Bootstrap** (nur beim allerersten Setup): ein Admin legt den Hobbyist-Account und den Check an, aktiviert MFA auf dem Konto (`rules.md` Abschnitt 2), trägt die Account-Zugangsdaten in den gemeinsamen Passwortmanager und die Ping-URL in die Secrets-Datei dort ein. Bei einem Neuaufbau mit bestehendem Account/Check entfällt der Schritt.
4. **Server und Host-Konfiguration** ([Phase 1](vps-repo/01-provisioning.md) bis [Phase 3](vps-repo/03-podman-install.md)) — ein Befehl:

    ```bash
    infra/setup-rebuild.sh setup/secrets.env      # bestehenden Server platt machen und neu aufsetzen
    infra/setup-new-server.sh setup/secrets.env   # stattdessen, wenn noch kein Server existiert
    ```

    `setup-rebuild.sh` verlangt zur Bestätigung den Servernamen. Danach stehen: Server und Cloud Firewall aus `infra/ports.yml`, gehärteter Host mit verschlüsseltem Swap und Monitoring-Heartbeat, der `deploy`-User, die Container-Runtime sowie Bare-Repo, `post-receive`-Hook und die eine sudo-Regel, über die ein Push den Deploy auslöst. Am Ende steht die Server-IP in der Ausgabe.

    Danach die lokale Kopie löschen: `rm -f setup/secrets.env`.

5. **Identitätsanbieter-Registrierung-Bootstrap** (einmalig bzw. bei Wechsel, `idea/04-identitaet-zugriff.md`): App-/Rollen-Registrierung beim M365/Entra-ID-Tenant der Schule anlegen, Redirect-URI auf `https://intern.clemens.schule` setzen — die Origin des internen Frontends, nicht die des Backend-Endpunkts aus Schritt 2 (`project-parts.md` Abschnitt 10), Tenant-Restriktion konfigurieren (kein Multi-Tenant-Fallstrick). Client-ID/Tenant-ID/Client-Secret vor Schritt 6 in die Secrets-Datei im Passwortmanager übernehmen und wie unten beschrieben auf den Host bringen — das Backend braucht sie beim ersten Start.

    Rotation eines einzelnen Secrets (auch der DB-Rollen-Passwörter, `idea/03-container-anwendung.md`) läuft **ohne** Neuaufbau: Wert beim Anbieter bzw. in der Datenbank ändern, in der Secrets-Datei ersetzen, dann

    ```bash
    setup/deploy-secrets.sh <ip> setup/secrets.env
    ```

    und einmal Schritt 6 auslösen — erst der Deploy schreibt die einzelnen Secret-Dateien neu und startet die Container, die sie lesen.
6. **App-Stack deployen** ([Phase 4](app-stack-repo/04-app-stack-deploy.md), Repo `wb-backend`):

    ```bash
    git remote add prod deploy@<ip>:wb-backend.git   # einmal je Rechner bzw. nach IP-Wechsel
    git push prod main:deploy
    ```

    **Nur `refs/heads/deploy` löst aus** — ein `git push prod main` legt den Commit ab und ändert auf der VPS nichts. Der auslösende Push führt Auschecken, Secret-Dateien, Build, Migration, Neustart und Smoke-Test aus; die Ausgabe kommt beim Push zurück. Ein fehlgeschlagener Build oder eine fehlgeschlagene Migration bricht ab, ohne die laufenden Container anzufassen. Zurück geht es über denselben Zeiger (`pipeline/app-stack-repo/04-app-stack-deploy.md`, Rollback).

**Fertig, wenn** `curl https://api.clemens.schule/health` über IPv4 und IPv6 mit `{"status":"ok"}` antwortet — das setzt Firewall, Runtime, Datenbank, Backend, Reverse-Proxy und automatisches HTTPS gemeinsam voraus. Nach einem Reboot muss dasselbe ohne Handanlegen wieder gelten.

## Runbook — Server bootet nicht mehr

Kommt praktisch nicht mehr vor: kein automatischer Unlock, kein Custom-Bootloader-Layout mehr im Spiel — Hetzners Standard-Debian-Image (`pipeline/vps-repo/01-provisioning.md`). Falls doch (z. B. defekter Kernel nach einem fehlgeschlagenen Update):

1. **Hetzner Cloud Console → Rescue-Modus** aktivieren (`hcloud server enable-rescue` + Reboot, Web-Konsole MFA-geschützt, `rules.md` Abschnitt 2).
2. Im Rescue-System die Root-Partition mounten, `chroot`, defektes Initramfs/Bootloader neu bauen (`update-initramfs -u` + `update-grub`).
3. Unmount, Rescue-Modus deaktivieren, Reboot.
4. Erreichbarkeit über den Dead-Man's-Switch (healthchecks.io) bestätigen.

Führt das nicht zum Erfolg oder ist der Datenträger endgültig defekt: kompletter Neuaufbau nach dem Runbook oben (die VPS führt keine unersetzlichen Daten — DB/Logs kommen aus dem Backup, `idea/05-backup-recovery.md`).
