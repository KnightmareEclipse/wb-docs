# Phase 4b — App-Stack-Deploy

`[Konzept — konkrete CI/CD-Plattform und Tools folgen mit der App-Stack-Architektur, app-stack/]`

Reverse-Proxy, Datenbank, Backend-Container sowie ein Backup-Timer laufen hier — welche konkreten Images/Tools das sind, entscheidet sich erst, wenn die App-Stack-Entwicklung beginnt. Das grobe Ablaufmuster steht aber schon fest, unabhängig vom gewählten Tool:

## Build

Eine CI/CD-Pipeline baut das Backend-Image im isolierten Runner, testet es und pusht es erst bei grünem Testlauf in eine Container-Registry — hält Build-Toolchain und beliebige Third-Party-Dependencies von der Produktions-VPS fern, passend zur Rootless-Docker-Härtung (`idea/03-container-anwendung.md`). Jedes Image bekommt einen eindeutigen, auf den jeweiligen Commit rückführbaren Tag (z. B. Git-SHA), damit ein gezielter Rollback auf eine bekannt gute Version möglich bleibt (Reproduzierbarkeit, `rules.md` Abschnitt 6).

## Deploy

*   Verbindet sich per SSH mit einem eingeschränkten Deploy-Key (CI/CD-Secret) gegen den `deploy`-User aus Phase 3.
*   Zieht das Image aus der Registry.
*   Führt darüber (nicht vom CI-Runner selbst — die Datenbank ist nach außen komplett geschlossen, `idea/02-netzwerk-firewall.md`) die Schema-Migration gegen eine separate, privilegiertere DB-Rolle aus (`idea/03-container-anwendung.md`) — mit eigenem Secret, das der dauerhaft laufende Backend-Container nie zu sehen bekommt. Erreicht die DB über das interne Docker-Netz, deckt auch das initiale Schema beim allerersten Deploy ab.
*   Bricht bei einer fehlgeschlagenen Migration vor dem eigentlichen Neustart der Container ab — die zuvor laufenden Container bleiben unverändert aktiv, kein Teil-Deploy auf altem oder halb migriertem Schema.
*   Startet erst danach die Container neu (neues Image).

Kein Hetzner-Token, kein Root-Zugriff, keine dauerhaft lokal vorgehaltenen Secrets für Routine-Deploys.

## Rollback

Bei einem fehlgeschlagenen/fehlerhaften Deploy: Deploy-Job manuell mit dem Tag der letzten bekannt guten Version erneut anstoßen. Ein DB-Migrations-Rollback ist davon separat zu betrachten und wird pro Vorfall manuell entschieden, kein automatischer Schema-Rollback.

Der Reverse-Proxy übernimmt voraussichtlich auch das Ausliefern der statischen Teams-Tab-Seiten (Abschnitt 10 in `project-parts.md`) — kein separater Extra-Host nötig für den Staff-Kanal, sofern sich das mit der gewählten Architektur so umsetzen lässt.
