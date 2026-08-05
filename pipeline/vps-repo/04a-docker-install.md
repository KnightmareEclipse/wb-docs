# Phase 4a — Docker-Engine-Install

`[AUTOMATISIERT — Shell-Skript, vps/setup/]`

Rootless Docker, installiert und betrieben unter dem `deploy`-User (kein system-weiter Root-Daemon) — macht „kein Root-Zugriff" für den `deploy`-User technisch verbindlich: ein Container mit Host-Mount (`-v /:/host`), erstellt über einen kompromittierten CI-Deploy-Key, läuft im User-Namespace des `deploy`-Users, nicht als echter Root (`idea/03-container-anwendung.md`).

Installation über Docker's offizielles APT-Repo (nicht das Convenience-Script/statische Binaries) — macht den Docker-Daemon selbst APT-verwaltet und damit über die in [Phase 3](03-hardening.md) hinterlegte Origin-Whitelist automatisiert patchbar wie jedes andere Systempaket.

Dazu Netzwerk-Segmentierung (extern/intern) als Host-Voraussetzung. Nach der Installation laufen — weil `rootlesskit` jetzt existiert — die beiden Root-Einmalschritte (als Root, danach nie wieder nötig): `setcap cap_net_bind_service=ep` auf das `rootlesskit`-Binary, damit der unprivilegierte Daemon Port 80/443 binden kann, sowie `loginctl enable-linger deploy`, damit der Daemon auch ohne aktive SSH-Session weiterläuft. Der Rootless-Docker-Daemon läuft als systemd-User-Unit (`systemctl --user enable docker`) und startet damit zusammen mit diesem Linger automatisch nach jedem Reboot — ohne aktive SSH-Session und ohne manuellen Start.

Bleibt im VPS-Repo, da es eine System-Paket-Installation ist, keine Anwendungslogik — ändert sich mit dem Host, nicht mit jedem App-Deploy.

Idempotent wie Phase 1–3: APT-Installation eines bereits installierten Pakets ist ein No-Op, `dockerd-rootless-setuptool.sh install` ist laut Docker-Dokumentation gefahrlos mehrfach ausführbar.
