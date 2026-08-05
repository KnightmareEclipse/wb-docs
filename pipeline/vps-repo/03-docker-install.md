# Phase 3 — Docker-Engine-Install

`[AUTOMATISIERT — Shell-Skript, wb-vps/setup/]`

Rootless Docker, installiert und betrieben unter dem `deploy`-User (kein system-weiter Root-Daemon) — macht „kein Root-Zugriff" für den `deploy`-User technisch verbindlich: ein Container mit Host-Mount (`-v /:/host`), erstellt über einen kompromittierten CI-Deploy-Key, läuft im User-Namespace des `deploy`-Users, nicht als echter Root (`idea/03-container-anwendung.md`).

Installation über Docker's offizielles APT-Repo (nicht das Convenience-Script/statische Binaries) — macht den Docker-Daemon selbst APT-verwaltet und damit über die in [Phase 2](02-hardening.md) hinterlegte Origin-Whitelist automatisiert patchbar wie jedes andere Systempaket.

Dazu Netzwerk-Segmentierung (extern/intern) als Host-Voraussetzung. Nach der Installation laufen — weil `rootlesskit` jetzt existiert — die beiden Root-Einmalschritte (als Root, danach nie wieder nötig): `setcap cap_net_bind_service=ep` auf das `rootlesskit`-Binary, damit der unprivilegierte Daemon Port 80/443 binden kann, sowie `loginctl enable-linger deploy`, damit der Daemon auch ohne aktive SSH-Session weiterläuft. Der Rootless-Docker-Daemon läuft als systemd-User-Unit (`systemctl --user enable docker`) und startet damit zusammen mit diesem Linger automatisch nach jedem Reboot — ohne aktive SSH-Session und ohne manuellen Start.

Bleibt im VPS-Repo, da es eine System-Paket-Installation ist, keine Anwendungslogik — ändert sich mit dem Host, nicht mit jedem App-Deploy.

Idempotent wie Phase 1–2: APT-Installation eines bereits installierten Pakets ist ein No-Op, `dockerd-rootless-setuptool.sh install` ist laut Docker-Dokumentation gefahrlos mehrfach ausführbar.

*   **Docker-GC:** wöchentlicher systemd-User-Timer unter dem `deploy`-User, `docker system prune -af --filter "until=336h"` (Images, gestoppte Container, Build-Cache älter als 14 Tage — **ohne** `--volumes`, DB-Daten bleiben unangetastet). Nötig, weil Builds direkt auf der VPS laufen (`idea/03-container-anwendung.md`, `pipeline/app-stack-repo/04-app-stack-deploy.md`) und dabei Image-Layer/Build-Cache auf der 80GB-SSD ansammeln, die sonst kein automatischer Mechanismus abräumt. Fehlschläge meldet der Timer über denselben healthchecks.io-Kanal wie der Monitoring-Heartbeat aus [Phase 2](02-hardening.md) (`rules.md` Abschnitt 3) — ergänzt dessen 85%-Schwelle um eine aktive Gegenmaßnahme statt nur einer Warnung.
