# Phase 5a — Docker-Engine-Install

`[AUTOMATISIERT — Shell-Skript, vps/setup/]`

Rootless Docker, installiert und betrieben unter dem `deploy`-User (kein system-weiter Root-Daemon) — macht „kein Root-Zugriff" für den `deploy`-User technisch verbindlich: ein Container mit Host-Mount (`-v /:/host`), erstellt über einen kompromittierten CI-Deploy-Key, läuft im User-Namespace des `deploy`-Users, nicht als echter Root (`idea/03-container-anwendung.md`).

Dazu Netzwerk-Segmentierung (extern/intern) als Host-Voraussetzung. Der Rootless-Docker-Daemon läuft als systemd-User-Unit (`systemctl --user enable docker`) und startet damit zusammen mit dem `deploy`-User-Linger aus [Phase 4](04-hardening.md) automatisch nach jedem Reboot-Unlock — ohne aktive SSH-Session und ohne manuellen Start.

Bleibt im VPS-Repo, da es eine System-Paket-Installation ist, keine Anwendungslogik — ändert sich mit dem Host, nicht mit jedem App-Deploy.
