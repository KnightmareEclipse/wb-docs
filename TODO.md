# TODO — Organisatorische Vorbereitungen

Aufgaben, die reale Konten/Zugänge brauchen und die reine Konzept-Doku (`idea/`, `pipeline/`) nicht abdeckt — sortiert nach Dringlichkeit.

## Bis Schulanfang September 2026 (Putzdienst als erste Fachdomäne, `fachdomaenen.md` Abschnitt 7)

- [ ] DNS A/AAAA-Record für `api.clemens.schule` beim DNS-Provider der Schule (All-Inkl, KAS-Panel) auf die Server-IP setzen — `pipeline/runbook.md` Schritt 2, Voraussetzung für Caddys automatisches HTTPS und damit für den externen Zugriffsweg
- [ ] Entra-ID-App-Registrierung im M365-Tenant der Schule anlegen (Tenant-Admin-Zugriff nötig, Redirect-URI, Tenant-Restriktion) — `pipeline/runbook.md` Schritt 7, zwingend da die Verwaltung den Putzdienst-Prozess intern startet und die Termine pflegt
- [ ] NAS-Backup-Bootstrap auf der Synology (DSM-Zugriff nötig): SSH-Keypair für den Pull-Key generieren (privat ausschließlich auf dem NAS), Task-Scheduler-Job anlegen, VPS-Host-Key vorab in `known_hosts` pinnen (nach jedem `rebuild.sh` neu zu wiederholen) — `idea/05-backup-recovery.md`, muss vor den ersten echten Elterndaten laufen
- [ ] Neue Secrets im gemeinsamen KeePass ablegen: DB-Rollen-Passwörter (Runtime/Migration/Backup), Entra-ID Client-ID/Tenant-ID/Client-Secret, `age`-Verschlüsselungs-Passphrase — Feldschema folgt mit der `secrets.example.env`-Erweiterung im App-Stack-Repo
- [ ] Zweiter Admin: GitHub-Username + SSH-Key einholen, vollen Zugriff auf GitHub-Org und VPS einrichten — für die Entwicklung unkritisch (alles in Git reproduzierbar), muss aber vor dem Produktivbetrieb mit echten Elterndaten stehen (`rules.md` Abschnitt 6)

## Unabhängig vom Putzdienst-Termin

- [ ] `wb-backend`-Grundgerüst (Compose-Skeleton, FastAPI-Grundgerüst) wurde in einer früheren Claude-Session erstellt und noch nicht selbst gegen `wb-backend/CLAUDE.md` durchgesehen

## Später relevant, jetzt nicht klären

- Cyber-Versicherung: ob Verschlüsselung at rest unabhängig von der technischen Notwendigkeit gefordert wird — erst vor Vertragsabschluss prüfen (`pipeline/vps-repo/01-provisioning.md`)
