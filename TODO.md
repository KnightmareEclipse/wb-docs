# TODO — Organisatorische Vorbereitungen

Aufgaben, die reale Konten/Zugänge brauchen und die reine Konzept-Doku (`idea/`, `pipeline/`) nicht abdeckt — sortiert nach Dringlichkeit. Fachliche/technische Punkte, die eine Entwicklungs-Session selbst abarbeiten kann, stehen in `TODO-SESSIONS.md`.

## Bis Schulanfang September 2026 (Putzdienst als erste Fachdomäne, `fachdomaenen.md` Abschnitt 7)

- [x] DNS A/AAAA-Record für `api.clemens.schule` beim DNS-Provider der Schule (All-Inkl, KAS-Panel) auf die Server-IP setzen — `pipeline/runbook.md` Schritt 2, Voraussetzung für Caddys automatisches HTTPS und damit für den externen Zugriffsweg
- [x] Entra-ID-App-Registrierung im M365-Tenant der Schule anlegen (Tenant-Admin-Zugriff nötig, Tenant-Restriktion) — `pipeline/runbook.md` Schritt 7, zwingend da die Verwaltung den Putzdienst-Prozess intern startet und die Termine pflegt
- [ ] Redirect-URI in der bestehenden Entra-ID-App-Registrierung nachtragen (Tenant-Admin-Zugriff nötig) — zeigt auf die Origin des internen Frontends, nicht auf die API (`idea/04-identitaet-zugriff.md`) — setzbar erst, wenn dessen Hosting steht (`project-parts.md` Abschnitt 10), dieselbe Abhängigkeit wie die CORS-Policy
- [ ] NAS-Backup-Bootstrap auf der Synology (DSM-Zugriff nötig): SSH-Keypair für den Pull-Key generieren (privat ausschließlich auf dem NAS), Task-Scheduler-Job anlegen, VPS-Host-Key vorab in `known_hosts` pinnen (nach jedem `rebuild.sh` neu zu wiederholen) — `idea/05-backup-recovery.md`, muss vor den ersten echten Elterndaten laufen. Öffentlichen Pull-Key liefert der zweite Admin nach seiner Urlaubsrückkehr Ende August 2026
- [x] Neue Secrets im gemeinsamen KeePass ablegen: DB-Rollen-Passwörter (Runtime/Migration/Backup), Entra-ID Client-ID/Tenant-ID/Client-Secret, `age`-Verschlüsselungs-Passphrase — Feldschema folgt mit der `secrets.example.env`-Erweiterung im App-Stack-Repo
- [ ] Passwörter der enger geschnittenen DB-Rollen nachtragen, sobald `wb-backend/db/init-roles.sh` steht — mindestens je eine für die Art.-9-Spalten (`denomination_id`/`congregation`) und für die Bankverbindung (`domains/stammdaten.md`); Phase 2 schreibt jede Rolle aus dieser Datei auf den Host (`pipeline/vps-repo/02-hardening.md`), fehlt eine, startet der Stack unvollständig
- [ ] MFA auf dem healthchecks.io-Konto aktivieren (TOTP, Kontoeinstellungen) — `rules.md` Abschnitt 2; ohne das schaltet ein übernommenes Konto den Dead-Man's-Switch stumm, und Backup-Fehlschlag/Disk-Voll/fehlgeschlagener Patch-Lauf melden ausschließlich dorthin
- [ ] Zweiter Admin: GitHub-Username + SSH-Key einholen, vollen Zugriff auf GitHub-Org und VPS einrichten — für die Entwicklung unkritisch (alles in Git reproduzierbar), muss aber vor dem Produktivbetrieb mit echten Elterndaten stehen (`rules.md` Abschnitt 6). SSH-Key zugesagt für die Urlaubsrückkehr Ende August 2026
- [x] Vis365-Feldliste beim zweiten Admin holen: Vis365 → Schulverwaltungsimport → ASV-BW, die Anleitung stammt von ihm. Definiert, welche Felder der M365-Kontenexport braucht — zweite reale Datenquelle für das Stammdaten-Schema neben den Voranmeldeformularen (`domains/stammdaten.md`). Blockiert den Schema-Entwurf nicht, muss aber vor der Abnahme abgeglichen sein
- [ ] Stammdaten-Schema gemeinsam mit dem zweiten Admin durchgehen (von ihm angeboten) — nach seiner Urlaubsrückkehr Ende August 2026, vor dem ersten Import echter Daten

## Unabhängig vom Putzdienst-Termin

- [ ] `wb-backend`-Grundgerüst (Compose-Skeleton, FastAPI-Grundgerüst) ist nicht selbst geschrieben und noch nicht gegen `wb-backend/CLAUDE.md` durchgesehen
- [ ] Aufbewahrungsfristen für Schülerunterlagen nach baden-württembergischem Schulrecht klären (Schulleitung bzw. Datenschutzbeauftragte:r) — bestimmt, wie lange Stammdaten nach dem Abgang **behalten** werden müssen, bevor die Löschfrist überhaupt greifen darf (`idea/06-dsgvo-organisatorisch.md`). Muss stehen, bevor der Lösch-Job gebaut wird

## Wiederkehrend / Ablauf-Termine

- [ ] Entra-ID Client-Secret der App-Registrierung „Clemens-Schule Weltenbaum" (trägt den App-only-Graph-Zugriff `Mail.Send`, nicht den Login — läuft es ab, bricht der OTP-Versand und damit der gesamte Elternzugang) läuft am **06.08.2028** ab — rechtzeitig vorher neues Secret erzeugen, in der Secrets-Datei im KeePass ersetzen, Phase 2 (`pipeline/vps-repo/02-hardening.md`) erneut laufen lassen (`pipeline/runbook.md` Schritt 7)

## Später relevant, jetzt nicht klären

- Cyber-Versicherung: bei Jürgen rückbestätigen, dass die Bedingungen keine Verschlüsselung at rest fordern. Die vorliegenden Bedingungen enthalten dazu nichts — weder für den Host noch für Backups; der zweite Admin trägt den Verzicht auf Festplattenverschlüsselung mit (`pipeline/vps-repo/01-provisioning.md`). Reine Rückversicherung, kein offener Blocker
