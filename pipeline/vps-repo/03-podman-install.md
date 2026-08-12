# Phase 3 — Container-Runtime-Install (Podman)

`[AUTOMATISIERT — Ansible-Rolle podman_rootless, wb-vps/ansible/]`

Rootless Podman, installiert und betrieben unter dem `deploy`-User — macht „kein Root-Zugriff" für den `deploy`-User technisch verbindlich: ein Container mit Host-Mount (`-v /:/host`), erstellt über einen kompromittierten Deploy-Key, läuft im User-Namespace des `deploy`-Users, nicht als echter Root (`idea/03-container-anwendung.md`).

**Podman statt Docker**, entgegen der sonst überall geltenden Boring-Technology-Regel zugunsten des Verbreiteteren (`rules.md` Abschnitt 4) — die Regel zielt auf Debugbarkeit durch einen Nachfolger, und die bleibt hier erhalten: Podmans CLI ist docker-kompatibel (`alias docker=podman` deckt den Alltag ab), es liest dieselben Compose-Dateien, und es ist die Standard-Runtime der gesamten RHEL-Familie, kein Nischenwerkzeug. Ausschlaggebend sind drei Punkte, die sich alle auf Rootless-Betrieb zurückführen lassen — Docker ist rootful gebaut und wird rootless nachgerüstet, Podman ist daemonlos und läuft rootless als Normalfall:

*   **Kein Daemon, der nebenher als Root laufen könnte.** Unter Docker musste die Installation den system-weiten Root-Daemon (`docker.service`, `docker.socket`, `containerd.service`) erst wieder abschalten und vorab eine `/etc/docker/daemon.json` schreiben, damit dessen kurzer Auto-Start während `apt-get install` keine `docker0`-Bridge und keine `DOCKER`/`DOCKER-USER`-Chains dauerhaft ins Kernel-Netfilter des Hosts schreibt. Beides entfällt ersatzlos: Podman startet keinen Hintergrunddienst und legt beim Installieren nichts am Host-Netz an.
*   **Quell-IP bleibt erhalten.** Rootless Docker forwardet Ports per Default über rootlesskits `builtin`-Driver und ersetzt dabei die Absenderadresse durch `127.0.0.1` — Caddys Access-Log hätte für jeden Request dieselbe Adresse gezeigt, was die für Art. 33 nötige Nachvollziehbarkeit (`idea/03-container-anwendung.md`, Zentrales Logging) entwertet und jedes IP-bezogene Rate-Limiting aushebelt. Podman 5 nutzt `pasta` und reicht die echte Adresse durch. Live gegen `db-prod-fsn-01` geprüft: ein Request von außen erschien im Container-Log mit der tatsächlichen öffentlichen Absender-IP.
*   **Aus Debian main statt aus einem Fremd-Repo.** Podman, `netavark`, `aardvark-dns`, `passt` und `crun` liegen in Debians eigenen Quellen und fallen damit unter die Debian-Standard-Origins, die `unattended-upgrades` ohnehin patcht. Der Eintrag für die Docker-APT-Repo-Origin in [Phase 2](02-hardening.md) entfällt, ebenso das Einrichten von Keyring und Repo-Datei.

Kein Sicherheitsgewinn an der Vertrauensgrenze selbst: Rootless Docker hätte dieselbe User-Namespace-Isolation gegen einen kompromittierten Deploy-Key geliefert (`rules.md` Abschnitt 2). Der Unterschied liegt darin, dass diese Eigenschaft bei Podman der Auslieferungszustand ist und bei Docker aus mehreren Konfigurationsschritten entsteht, die alle korrekt bleiben müssen.

## Was ein Container-Ausbruch tatsächlich erreicht

Rootless heißt nicht, dass im Container niemand Root ist — dort ist sehr wohl `uid=0(root)`. Entscheidend ist, worauf diese 0 außerhalb abgebildet wird. Live gegen `db-prod-fsn-01` gemessen, `/proc/self/uid_map` eines Containers:

```
         0       1000          1      <- Container-root  = Host-UID 1000 (deploy)
         1     100000      65536      <- alles andere    = unprivilegierter subuid-Bereich
```

Ein Prozess, der sich im Container für Root hält, ist aus Sicht des Host-Kernels also der `deploy`-User. Gegenprobe auf demselben Host, jeweils als Container-Root ausgeführt: das gesamte Host-Dateisystem nach `/host` gemountet und `/host/etc/shadow` gelesen → *Permission denied*; `touch /host/root/PWNED` → *Permission denied*; eine im gemounteten `deploy`-Home angelegte Datei gehört anschließend `deploy:deploy`, nicht `root:root`. `deploy` selbst hat keinerlei `sudo`-Rechte.

Ein Ausbruch aus dem Container liefert damit genau die Rechte des `deploy`-Users — dieselben, die ein gestohlener Deploy-Key ohnehin liefern würde, und das ist die Bedrohung, gegen die diese Ebene gebaut ist. Für echtes Root braucht es eine **zweite**, davon unabhängige Lücke.

**Akzeptiertes Risiko:** Diese zweite Lücke wäre typischerweise ein Kernel-Exploit über die User-Namespace-Schnittstelle selbst — rootless Container setzen unprivilegierte User-Namespaces voraus, die sich deshalb nicht abschalten lassen (`kernel.unprivileged_userns_clone`/`user.max_user_namespaces` sind hier keine Option, sie würden den Betrieb beenden). Kompensiert wird das über die monatliche Kernel-Patch-Kadenz mit automatischem Reboot ([Phase 2](02-hardening.md)) und `kernel.yama.ptrace_scope=1`, das die seitliche Bewegung zwischen Prozessen derselben `deploy`-UID einschränkt.

## Installation

Debian 13 (trixie) liefert Podman 5.4, netavark/aardvark-dns 1.14, passt und crun 1.21 — der Versionsstand, auf dem die oben genannten Eigenschaften beruhen. Debian 12 lieferte nur Podman 4.3 und ist deshalb keine Grundlage für diese Phase; die Imagewahl in [Phase 1](01-provisioning.md) hängt daran.

Installierte Pakete: `podman passt uidmap` — nur was der Rootless-Betrieb selbst braucht. `netavark`, `aardvark-dns` und `crun` zieht `podman` als Abhängigkeit. Compose- und Build-Werkzeug ziehen erst mit [Phase 4](../app-stack-repo/04-app-stack-deploy.md) nach, wenn feststeht, womit gebaut wird. Netzwerk-Segmentierung (extern/intern, `idea/03-container-anwendung.md`) ist aus demselben Grund kein Phase-3-Schritt: die konkreten Netze entstehen erst mit den tatsächlichen App-Stack-Containern in Phase 4.

**Root-Einmalschritte** (als Root, danach nie wieder nötig):

*   `net.ipv4.ip_unprivileged_port_start=0` per Datei in `/etc/sysctl.d/`, damit die unprivilegierten Container-Prozesse Port 80/443 binden können. **Akzeptiertes Risiko:** die Einstellung senkt die privilegierte-Port-Schwelle host-weit, nicht nur für Podman. Da auf diesem Host außer `root` und `deploy` keine weiteren, potenziell nicht vertrauenswürdigen lokalen Accounts existieren (`rules.md` Abschnitt 2), bringt eine engere Fassung per `setcap` keinen echten Sicherheitsgewinn, verlöre die Capability aber bei jedem Paket-Update und bräuchte einen eigenen Hook, der sie wiederherstellt.
*   `loginctl enable-linger deploy`, damit die systemd-User-Instanz des `deploy`-Users und damit seine Container auch ohne aktive SSH-Session laufen und nach jedem Reboot automatisch starten.

**Nicht nötig, anders als unter Docker:**

*   Kein `Delegate=`-Drop-in für `user@.service`. Debian 13 delegiert `cpu memory pids` an User-Sessions bereits ab Werk — die in `idea/03-container-anwendung.md` vorgesehenen CPU-/Memory-Limits greifen ohne Zutun. Live geprüft: `--memory=128m --cpus=0.5` ergaben im Container exakt `memory.max=134217728` und `cpu.max=50000 100000`. (Nicht delegiert sind `cpuset` und `io`; beide werden von der geplanten Härtung nicht verwendet — bei Bedarf wäre das Drop-in nachzuholen.)
*   Kein subuid/subgid-Setup. Debians `useradd` legt den Bereich beim Anlegen des `deploy`-Users in [Phase 2](02-hardening.md) selbst an (`deploy:100000:65536`).
*   Kein Warten auf die User-systemd-Instanz und kein Setzen von `XDG_RUNTIME_DIR` für ein Setup-Tool. Podman braucht keinen Installationsschritt im Kontext des Users; die erste Container-Ausführung richtet ein, was sie braucht.

## Offen

*   **Compose gegen Podman ist noch nicht verifiziert.** Geprüft sind die Primitive über die Podman-CLI: Cgroup-Limits, Secrets als Datei unter `/run/secrets/`, ein `--internal`-Netz ohne Egress und die Quell-IP — alle vier live gegen `db-prod-fsn-01` und über einen Reboot hinweg. Ob `wb-backend/docker-compose.yml` unverändert über Podmans docker-kompatiblen Socket läuft — insbesondere `depends_on: condition: service_healthy`, `profiles` und die Secret-Definitionen — muss vor Phase 4 einmal gegen den echten Stack laufen.
*   Beim Entfernen eines Containers an einem internen Netz meldet netavark einen aardvark-Cleanup-Fehler (`remove aardvark entries: IO error`). Folgenlos für Funktion und Isolation, taucht aber in Logs auf.

Bleibt im VPS-Repo, da es eine System-Paket-Installation ist, keine Anwendungslogik — ändert sich mit dem Host, nicht mit jedem App-Deploy.

Idempotent wie Phase 1–2: APT-Installation eines bereits installierten Pakets ist ein No-Op, `enable-linger` und die Sysctl-Datei sind Zustandsbeschreibungen ohne Seiteneffekt bei Wiederholung.
