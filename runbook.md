# Runbook — Kompletter Neuaufbau

Reihenfolge für einen kompletten Neuaufbau der VPS von Grund auf (z. B. bei Totalausfall). Hier steht alles, was ein Mensch dabei tun muss — alles andere erledigen die Skripte in `wb-vps`. Ein vollständiger Durchlauf dauert wenige Minuten; die VPS führt keine unersetzlichen Daten, DB und Logs kommen aus dem Backup (`backup.md`).

**Nur beim allerersten Setup:**

- MFA ist auf dem Hetzner-Cloud-Konto und dem DNS-Provider-Konto der Schule aktiv, das gemeinsame KeePass ist mit einem starken Master-Passwort geschützt (kein MFA anwendbar, `rules.md` Abschnitt 2) — beides, bevor der erste persönliche Hetzner-API-Token entsteht.
- Die Secrets-Datei (`secrets.env`) liegt als Datei-Anhang in der gemeinsamen KeePass-Datenbank, nie in Git. Schema: `wb-vps/setup/secrets.example.env`; Format und Ablage: `host.md`. Jeder Schritt unten, der ein Secret erzeugt, trägt es dort ein — dieser Anhang ist die einzige Kopie, die einen Neuaufbau überlebt. Die DB-Rollen-Passwörter (`APP_*`) sind frei gewählte Zufallswerte und stehen dort ebenfalls; ohne sie scheitert Schritt 6.

1. **Admin-Rechner vorbereiten** (jedes Mal):

    ```bash
    cd wb-vps
    setup/preflight.sh     # nennt fehlende Werkzeuge samt Installationsbefehl, installiert nichts
    hcloud context create  # einmal je Rechner, mit dem eigenen persönlichen API-Token
    ```

    Dazu den `secrets.env`-Anhang aus KeePass lokal herunterladen — Schritt 4 liest ihn.

    **Und den Admin-Key dem SSH-Client anbieten**, einmal je Sitzung: `ssh-add <pfad-zum-key>`. Jeder Schritt unten spricht den Server über seine **IP** an, und ein Schlüssel, der nicht `~/.ssh/id_ed25519` heißt, wird dabei nur angeboten, wenn ein Agent ihn hält oder ein `Host`-Eintrag ihn nennt — ein Eintrag auf einen Alias greift nicht, wenn das Skript eine IP übergibt. Ohne das scheitern `deploy-secrets.sh`, `redeploy.sh`, der `ansible-playbook`-Lauf und der Deploy-Push gleichermaßen an `Permission denied (publickey)`, obwohl der Schlüssel in `admins.yml` steht und auf dem Server liegt.

2. **DNS** (einmalig bzw. bei IP-Wechsel): A/AAAA-Records für `api.clemens.schule`, `portal.clemens.schule` und `intern.clemens.schule` beim DNS-Provider der Schule (All-Inkl, KAS-Panel unter Tools → DNS-Verwaltung) auf dieselbe Server-IP setzen. `api.` ist reiner Backend-Endpunkt und wird nie als Seite aufgerufen; die beiden anderen tragen Eltern- und Personaloberfläche und rufen die API unter ihrem eigenen Namen (`oberflaechen.md`). Die Namenswahl ist ohne Sicherheitsrelevanz — Certificate-Transparency-Logs machen jeden Hostnamen öffentlich, sobald ein Zertifikat ausgestellt wird. Caddy holt je Name ein eigenes Zertifikat, ein Wildcard und damit ein DNS-Zugang für den Proxy sind nicht nötig. Bei einem Neuaufbau auf demselben Server bleibt die IP erhalten und der Schritt entfällt.
3. **healthchecks.io-Bootstrap** (nur beim allerersten Setup): ein Admin legt den Hobbyist-Account und den Check an, aktiviert MFA auf dem Konto (`rules.md` Abschnitt 2), trägt die Account-Zugangsdaten in den gemeinsamen Passwortmanager und die Ping-URL in die Secrets-Datei dort ein. Bei einem Neuaufbau mit bestehendem Account/Check entfällt der Schritt.
4. **Server und Host-Konfiguration** (`host.md` und `container.md`) — ein Befehl:

    ```bash
    infra/setup-rebuild.sh setup/secrets.env      # bestehenden Server platt machen und neu aufsetzen
    infra/setup-new-server.sh setup/secrets.env   # stattdessen, wenn noch kein Server existiert
    ```

    `setup-rebuild.sh` verlangt zur Bestätigung den Servernamen. Danach stehen: Server und Cloud Firewall aus `infra/ports.yml`, gehärteter Host mit verschlüsseltem Swap und Monitoring-Heartbeat, der `deploy`-User, die Container-Runtime sowie Bare-Repo, `post-receive`-Hook und die eine sudo-Regel, über die ein Push den Deploy auslöst. Am Ende steht die Server-IP in der Ausgabe.

    Danach die lokale Kopie löschen: `rm -f setup/secrets.env`.

5. **Identitätsanbieter-Registrierung-Bootstrap** (einmalig bzw. bei Wechsel, `zugang.md`): App-/Rollen-Registrierung beim M365/Entra-ID-Tenant der Schule anlegen, Redirect-URI auf `https://intern.clemens.schule` setzen — die Origin des internen Frontends, nicht die des Backend-Endpunkts aus Schritt 2 (`oberflaechen.md`), Tenant-Restriktion konfigurieren (kein Multi-Tenant-Fallstrick). Client-ID/Tenant-ID/Client-Secret vor Schritt 6 in die Secrets-Datei im Passwortmanager übernehmen und wie unten beschrieben auf den Host bringen — das Backend braucht sie beim ersten Start.

    Rotation eines einzelnen Secrets (auch der DB-Rollen-Passwörter, `container.md`) läuft **ohne** Neuaufbau: Wert beim Anbieter bzw. in der Datenbank ändern, in der Secrets-Datei ersetzen, dann

    ```bash
    setup/deploy-secrets.sh <ip> setup/secrets.env
    ```

    und einmal Schritt 6 auslösen — erst der Deploy schreibt die einzelnen Secret-Dateien neu und startet die Container, die sie lesen.
6. **App-Stack deployen** (`deploy.md`, Repo `wb-backend`):

    ```bash
    git remote add prod deploy@<ip>:wb-backend.git   # einmal je Rechner bzw. nach IP-Wechsel
    git push prod main:deploy
    ```

    **Nur `refs/heads/deploy` löst aus** — ein `git push prod main` legt den Commit ab und ändert auf der VPS nichts. Der auslösende Push führt Auschecken, Secret-Dateien, Build, Migration, Neustart und Smoke-Test aus; die Ausgabe kommt beim Push zurück. Ein fehlgeschlagener Build oder eine fehlgeschlagene Migration bricht ab, ohne die laufenden Container anzufassen. Zurück geht es über denselben Zeiger (`deploy.md`, Rollback).

**Fertig, wenn** `curl https://api.clemens.schule/health` über IPv4 und IPv6 mit `{"status":"ok"}` antwortet — das setzt Firewall, Runtime, Datenbank, Backend, Reverse-Proxy und automatisches HTTPS gemeinsam voraus. Nach einem Reboot muss dasselbe ohne Handanlegen wieder gelten.

## Runbook — Server bootet nicht mehr

Kommt praktisch nicht mehr vor: kein automatischer Unlock, kein Custom-Bootloader-Layout mehr im Spiel — Hetzners Standard-Debian-Image (`host.md`). Falls doch (z. B. defekter Kernel nach einem fehlgeschlagenen Update):

1. **Hetzner Cloud Console → Rescue-Modus** aktivieren (`hcloud server enable-rescue` + Reboot, Web-Konsole MFA-geschützt, `rules.md` Abschnitt 2).
2. Im Rescue-System die Root-Partition mounten, `chroot`, defektes Initramfs/Bootloader neu bauen (`update-initramfs -u` + `update-grub`).
3. Unmount, Rescue-Modus deaktivieren, Reboot.
4. Erreichbarkeit über den Dead-Man's-Switch (healthchecks.io) bestätigen.

Führt das nicht zum Erfolg oder ist der Datenträger endgültig defekt: kompletter Neuaufbau nach dem Runbook oben (die VPS führt keine unersetzlichen Daten — DB/Logs kommen aus dem Backup, `backup.md`).

## Runbook — Betriebsstörung im laufenden Betrieb

Der häufige Fall, und der einzige, bei dem draußen jemand wartet. Drei Sätze gelten für alle vier:

- **Erst messen, dann anfassen.** `curl https://api.clemens.schule/health` über IPv4 und IPv6 trennt „alles steht" von „ein Teil steht"; healthchecks.io sagt, seit wann — der Host-Herzschlag alle 15 Minuten (`host.md`), der eigene Check des Lauf-Dienstes daneben, und Image-GC wie NAS-Backup melden dorthin nur Fehlschläge (`container.md`, `backup.md`).
- **Keine Störung meldet sich von selbst bei den Eltern.** Der Betreiber sagt dem Sekretariat, was gilt und bis wann; hinaus geht es über `post@clemens.schule` wie jede andere Mail (`zugang.md`). Was unten unter *nach draußen* steht, ist der Inhalt und nicht der Wortlaut.
- **Eine Frist, die während der Störung abläuft, ist Handarbeit und kein Fall fürs System.** Anmeldefenster, Freikauf-Frist und Termin lassen sich von Hand zuteilen, verschieben oder erlassen (`soll-prozesse/01-putzdienst.md` Z5); ein Nachlauf, der Versäumtes selbst einholt, wird dafür nicht gebaut.

### Die API antwortet nicht

**Prüfen:** Antwortet gar nichts, steht Caddy oder die Firewall; antwortet 502, steht das Backend dahinter. Auf dem Host `podman-compose ps` — welcher Dienst fehlt oder ist `unhealthy`; ein `unhealthy` an `db` hält über `depends_on: service_healthy` alles andere auf (`container.md`). Dann `podman-compose logs --tail=200 backend` bzw. `db`. Lag ein Deploy davor, steht sein Verlauf in `/var/log/wb-app-stack-deploy.log` (`container.md`). War die Platte voll, ist es der vierte Fall unten.

**Beheben:** `wb-vps/setup/redeploy.sh <ip>` fährt denselben Stand noch einmal aus — ein Push mit demselben Commit bewegt nichts und sieht dabei aus wie ein gelaufener Deploy (`deploy.md`). Hilft das nicht und lag ein Deploy davor, geht es über denselben Zeiger zurück (`deploy.md`, Rollback).

**Nach draußen:** Das Portal ist vorübergehend nicht erreichbar; was gebucht war, ist gebucht — die Terminübersicht ist nach der Störung unverändert. Wer gerade etwas eintragen wollte, macht es danach.

### Der Mailversand scheitert

Zwei Sorten mit verschiedenen Adressaten, und die Unterscheidung ist der erste Schritt.

**Eine einzelne Mail** an eine Familie ist keine Störung: Sie steht mit `undeliverable_at` und Grund in `outbound_emails`, und ihr nachzugehen ist Sekretariatsarbeit (`soll-prozesse/hebel.md`, „Unzustellbare Mail").

**Alle Mails** heißt: der Weg selbst. Sichtbar wird er am Alarm-Check, auf den der Anmeldecode seinen Fehlschlag als `/fail` meldet (`container.md`) — und damit steht zugleich der Elternzugang, denn ohne Code keine Anmeldung.

**Prüfen:** Das Log des Backend- und des Lauf-Containers trägt Microsofts Fehlerobjekt samt Statuscode. Scheitert schon der Token-Endpunkt, ist es die App-Registrierung — meist ein abgelaufenes Client-Secret (`backlog/`); die Rotation läuft ohne Neuaufbau über Schritt 5 oben. Scheitert erst das Senden, ist es die Application Access Policy — Gegenprobe `Test-ApplicationAccessPolicy` (`zugang.md`) — oder dem Container fehlt das `external`-Netz (`container.md`).

**Was nicht passiert:** Es gibt keine Warteschlange und keinen zweiten Zustellversuch (`container.md`), und die Läufe setzen ihre Marke unabhängig davon, ob Graph angenommen hat. Was in die Störung fiel, steht als abgewiesene Zeile in `outbound_emails` und wird von Hand nachgeholt, nicht vom nächsten Tick.

**Nach draußen:** Solange es steht, kommt keine Anmeldung im Portal zustande — das Sekretariat gibt Auskunft am Telefon. Nach der Behebung geht die liegengebliebene Post von Hand hinterher; eine Erinnerung, die ausgefallen ist, sagt das Sekretariat den betroffenen Familien direkt.

### Der Zahlungsdienst ist nicht erreichbar

Betrifft genau einen Weg, den Freikauf; alles andere am Putzdienst läuft weiter.

**Prüfen:** Die Statusseite des Dienstes, im Backend-Log die Antwort auf das Eröffnen der Zahlung, und ob Rückrufe ankommen — eine `payments`-Zeile entsteht erst im Rückruf (`api/putzdienst-api.md`).

**Kein halber Zustand:** Der Vorgang entsteht mit der bestätigten Zahlung und nicht mit der Rückkehr aus der Bezahlung (`soll-prozesse/hebel.md`). Der Dienst wiederholt seinen Rückruf, bis er eine 2xx bekommt; was während der Störung bezahlt wurde, trägt sich danach von selbst nach, und die zweite Zustellung legt keine zweite Zahlung an (`schema/querschnitt-schema.sql`).

**Nach draußen:** Freikaufen geht gerade nicht, der Termin bleibt bestehen. Wer bezahlt hat und es nicht gebucht sieht, muss nichts tun — es trägt sich nach. Läuft die Freikauf-Frist währenddessen ab, erlässt das Sekretariat den Termin, statt ihn zu berechnen.

### Die Platte ist voll

**Prüfen:** `df -h /`. Der Host-Heartbeat schlägt schon unter 85 % Alarm (`host.md`) — das ist die Vorwarnung, nicht die Störung. Es geht in drei Richtungen: Image-Layer und Build-Cache, weil auf dieser Maschine gebaut wird (`deploy.md`), das persistente Journal (`host.md`) und das DB-Volume.

**Beheben:** Der wöchentliche GC räumt Images älter als 14 Tage; von Hand derselbe Befehl unter dem `deploy`-User und **ohne** `--volumes` (`deploy.md`) — mit ihm wäre die Datenbank weg. Journal per `journalctl --vacuum-size=`. Danach den Deploy wiederholen, der an der vollen Platte gescheitert ist (`redeploy.sh`, siehe erster Fall).

**Postgres hält an, wenn es sein WAL nicht mehr schreiben kann**, und kommt nach dem Aufräumen mit einem Neustart des Containers zurück: Was committet war, ist da; die abgebrochene Transaktion nicht. Ein NAS-Pull, der in dieselbe Zeit fiel, hat seinen Fehlschlag gemeldet (`backup.md`) und läuft am nächsten Tag wieder.

**Nach draußen:** wie beim ersten Fall.
