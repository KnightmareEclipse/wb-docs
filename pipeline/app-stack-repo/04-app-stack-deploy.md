# Phase 4 — App-Stack-Deploy

`[Konzept + Tools fixiert — Build läuft direkt auf der VPS statt über einen externen CI-Runner, app-stack/ noch nicht angelegt]`

Reverse-Proxy (Caddy), Datenbank (PostgreSQL) und Backend-Container (eigenes FastAPI-Image) laufen hier — Details `project-parts.md`. Der Backup-Dump wird bei Bedarf vom NAS der Schule abgeholt (`idea/05-backup-recovery.md`), kein eigener Timer auf der VPS. Das Ablaufmuster:

## Build

Build läuft direkt auf der VPS, kein externer CI-Runner (kein GitHub-Actions-/GitLab-Runner-Konto, kein damit verbundenes Drittanbieter-Deploy-Credential) — eliminiert genau die in `rules.md` Abschnitt 2 benannte Bedrohung eines geleakten CI-Deploy-Keys, da es keinen gibt. **Akzeptierter Trade-off:** Build-Toolchain und Third-Party-Dependencies (npm/pip etc.) laufen damit zeitweise auf der Produktions-VPS statt isoliert davon — die Rootless-Docker-Härtung (`idea/03-container-anwendung.md`) bleibt die kompensierende Kontrolle, ergänzt um den Docker-GC-Job (unten) gegen die dadurch anfallenden Image-Layer/Build-Caches. Auslöser: Bare Git-Repo unter dem `deploy`-User, ein `post-receive`-Hook stößt Build → Migration → Neustart an. Admin pusht mit seinem vorhandenen personengebundenen Key (`admins.yml`-Muster, `pipeline/vps-repo/02-hardening.md`) — der Key-Eintrag in `deploy`s `authorized_keys` ist per `command="git-shell ..."` auf Git-Operationen beschränkt, kein freier Shell-Zugriff als `deploy`. Kein Registry-Push/-Pull-Umweg nötig, da Build- und Laufzeitumgebung dieselbe Maschine sind. Benötigt zusätzlich zur Rootless-Docker-Grundlage aus `pipeline/vps-repo/03-docker-install.md` `docker-buildx-plugin` und `docker-compose-plugin` — beide zieht diese Phase nach, sobald das konkrete Build-/Compose-Setup feststeht.

**Docker-GC:** wöchentlicher systemd-User-Timer unter dem `deploy`-User, `docker system prune -af --filter "until=336h"` (Images, gestoppte Container, Build-Cache älter als 14 Tage — **ohne** `--volumes`, DB-Daten bleiben unangetastet). Räumt die durch den VPS-seitigen Build anfallenden Image-Layer/Caches von der 80GB-SSD ab, die sonst kein automatischer Mechanismus abräumt. Fehlschläge meldet der Timer über denselben healthchecks.io-Kanal wie der Monitoring-Heartbeat aus `pipeline/vps-repo/02-hardening.md` (`rules.md` Abschnitt 3) — ergänzt dessen 85%-Schwelle um eine aktive Gegenmaßnahme statt nur einer Warnung.

## Deploy

*   Baut das Image lokal (siehe Build) bzw. verwendet das zuletzt lokal gebaute.
*   Führt darüber die Schema-Migration gegen eine separate, privilegiertere DB-Rolle aus (`idea/03-container-anwendung.md`) — mit eigenem Secret, das der dauerhaft laufende Backend-Container nie zu sehen bekommt. Erreicht die DB über das interne Docker-Netz, deckt auch das initiale Schema beim allerersten Deploy ab.
*   Bricht bei einer fehlgeschlagenen Migration vor dem eigentlichen Neustart der Container ab — die zuvor laufenden Container bleiben unverändert aktiv, kein Teil-Deploy auf altem oder halb migriertem Schema.
*   Startet erst danach die Container neu (neues Image).

Kein Hetzner-Token, kein Root-Zugriff über den `deploy`-User hinaus, keine dauerhaft lokal vorgehaltenen Drittanbieter-Secrets für Routine-Deploys.

## Rollback

Bei einem fehlgeschlagenen/fehlerhaften Deploy: letzten bekannt guten Commit/Tag lokal auschecken und den Build-/Deploy-Schritt erneut anstoßen — setzt voraus, dass alte Image-Layer/Tags nicht vom Docker-GC-Job (oben) bereits entfernt wurden; Details zur Aufbewahrung bekannter guter Versionen folgen mit der App-Stack-Architektur. Ein DB-Migrations-Rollback ist davon separat zu betrachten und wird pro Vorfall manuell entschieden, kein automatischer Schema-Rollback.

Der Reverse-Proxy übernimmt voraussichtlich auch das Ausliefern der statischen Teams-Tab-Seiten (Abschnitt 10 in `project-parts.md`) — kein separater Extra-Host nötig für den Staff-Kanal, sofern sich das mit der gewählten Architektur so umsetzen lässt.
