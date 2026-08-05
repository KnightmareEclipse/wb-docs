# TODO — Organisatorische Vorbereitungen

Aufgaben, die reale Konten/Zugänge brauchen und die reine Konzept-Doku (`idea/`, `pipeline/`) nicht abdeckt — sortiert nach Phase.

## Optional, nicht blockierend (Phase 1–3)

- [ ] DNS A/AAAA-Record für `api.clemens.schule` setzen — bewusst zurückgestellt, bis der Server läuft, siehe `pipeline/runbook.md` Schritt 2, kein Muss für Phase 1–3

## Vor dem ersten Produktiv-Deploy nötig (Phase 4)

- [ ] Entra-ID-App-Registrierung im M365-Tenant der Schule anlegen (Tenant-Admin-Zugriff nötig, Redirect-URI, Tenant-Restriktion) — `pipeline/runbook.md` Schritt 7
- [ ] NAS-Backup-Bootstrap auf der Synology (DSM-Zugriff nötig): SSH-Keypair für den Pull-Key generieren (privat ausschließlich auf dem NAS), Task-Scheduler-Job anlegen, VPS-Host-Key vorab in `known_hosts` pinnen (nach jedem `rebuild.sh` neu zu wiederholen) — `idea/05-backup-recovery.md`
- [ ] Neue Secrets im gemeinsamen KeePass ablegen: DB-Rollen-Passwörter (Runtime/Migration/Backup), Entra-ID Client-ID/Tenant-ID/Client-Secret, `age`-Verschlüsselungs-Passphrase — Feldschema folgt mit der `secrets.example.env`-Erweiterung im App-Stack-Repo

## Später relevant, jetzt nicht klären

- Cyber-Versicherung: ob Verschlüsselung at rest unabhängig von der technischen Notwendigkeit gefordert wird — erst vor Vertragsabschluss prüfen (`pipeline/vps-repo/01-provisioning.md`)
