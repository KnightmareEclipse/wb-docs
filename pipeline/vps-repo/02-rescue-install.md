# Phase 2 — Rescue-Boot + verschlüsselte OS-Installation

`[SKRIPTBAR, einmalig]`

Hetzner **Cloud** (nicht Robot) — kein `installimage` mit eingebauter LUKS-Option, daher eigenes Setup-Skript nötig, einmal geschrieben und danach wiederverwendbar.

Mehr Handarbeit als Robot's `installimage`-Autosetup, aber trotzdem ein einziges, wiederverwendbares Skript — kein Grund für ein Custom-Tool.

## Ablauf

1. Rescue-Modus aktivieren + Reboot auslösen (`hcloud`-Skript/API).
2. Skript pollt per SSH-Connect-Versuch in kurzen Intervallen bis Timeout (z. B. 2 Min.), bis das Rescue-Live-System erreichbar ist (Boot-Zeit variiert, kein fester Sleep) — bei Timeout bricht das Skript mit Fehlermeldung ab statt zu hängen. Danach Verbindung ins Rescue-Live-System (Root-Passwort von der API).
3. **Disk wipen + Basis-OS installieren:**
    *   Ziel-Disk automatisch erkennen (`lsblk -d -n -o NAME,TYPE` gefiltert auf `type=disk`, ohne Loop-/ROM-Devices — bei `cx33` genau ein Treffer erwartet; findet das Skript mehr als eine Disk, bricht es mit Fehlermeldung ab statt zu raten, gleiches Muster wie die Interface-Autoerkennung in Schritt 4).
    *   Komplett wipen (`wipefs`/`sgdisk --zap-all`), dann partitionieren (unverschlüsseltes `/boot`, 512MB, + Rest verschlüsselt inkl. 4GB-Swapfile darin).
    *   Passphrase wird vom Skript selbst generiert (`openssl rand -base64 32`), non-interaktiv per stdin an `cryptsetup luksFormat` übergeben und danach einmalig im Terminal ausgegeben — Admin trägt sie sofort in den gemeinsamen Passwortmanager ein, sie landet nie auf der Ziel-Disk.
    *   **Akzeptiertes Risiko:** Läuft die SSH-Sitzung des Admin-Rechners mit aktivem Terminal-/Scrollback-Logging (tmux/screen-Log, Terminal-History-Tool), kann die Passphrase dort trotzdem landen — Admin ist selbst für saubere Terminal-Hygiene (kein Session-Logging, Scrollback danach löschen) verantwortlich.
    *   Danach `luksOpen`, Dateisystem anlegen, Basis-OS reinziehen (`debootstrap`, Debian Stable), mounten, `chroot`.
    *   Im Chroot: Hostname setzen (`/etc/hostname` + `/etc/hosts`, aus derselben Servername-Konstante wie `vps/infra/`), `systemd-machine-id-setup` ausführen (`debootstrap` legt kein `/etc/machine-id` an, ohne das journald u. a. nicht persistent loggt — relevant für den Audit-Trail aus `idea/03-container-anwendung.md`/`idea/06-dsgvo-organisatorisch.md`), `systemd-timesyncd` aktivieren (`systemctl enable --now systemd-timesyncd`, Debian-Stable-Default) für korrekte Zeitstempel in TLS-Validierung und Logs.
    *   Der Wipe zu Skriptbeginn macht das gesamte Skript idempotent — ein Abbruch mittendrin ist unkritisch, ein Neustart führt zum selben Ergebnis (keine Daten auf der Ziel-VPS betroffen, da dort keine schützenswerten Daten liegen).
4. **Im Chroot: Netzwerk, Dropbear, Bootloader:**
    *   Kernel, GRUB, `dropbear-initramfs` installieren.
    *   Statische IP als Kernel-Parameter (`ip=<ip>::<gateway>:255.255.255.255:<hostname>:<interface>:off`) für die Initramfs-Netzwerkkonfiguration setzen (kein DHCP) — IP und Gateway per `hcloud server describe -o json` vom Admin-Rechner vor dem Rescue-Lauf ermittelt und als Skriptparameter übergeben (Netmask bei Hetzner Cloud IPv4 immer `/32`, Point-to-Point-Gateway, keine Abfrage nötig); Interface-Name im Chroot automatisch erkannt (`ip -o link show`, einzige Nicht-Loopback-NIC einer frischen Hetzner-Cloud-VM).
    *   Der `ip=`-Parameter konfiguriert nur das Initramfs-Netzwerk für Dropbear und wirkt nicht ins Haupt-OS weiter — dieselben Werte daher zusätzlich als statischer Eintrag in `/etc/network/interfaces` (`ifupdown`, Debian-Stable-Default) im Chroot hinterlegen, sonst kein Netzwerk nach dem Boot.
    *   Dropbear-Listen-Port explizit auf den custom SSH-Port aus `ports.yml` setzen (`DROPBEAR_OPTIONS="-p <port>"` in `/etc/dropbear/initramfs/dropbear.conf`) — Dropbear lauscht sonst per Default auf Port 22, den die Firewall (öffnet nur den custom Port, `idea/02-netzwerk-firewall.md`) blockt, was den Reboot-Unlock in [Phase 6](06-reboot-unlock.md) aussperren würde.
    *   Davor `/etc/crypttab` im Chroot mit dem LUKS-Root-Eintrag befüllen (`<name> UUID=<luks-uuid> none luks,initramfs`, UUID per `blkid` nach `luksFormat` ermittelt statt Device-Pfad — robust gegen abweichende Device-Namen zwischen Rescue- und Live-System) sowie `/etc/fstab` entsprechend, danach `update-initramfs`/`update-grub`.
    *   Aktuelle Admin-Public-Keys (Quelle: `vps/setup/admins.yml`, gleiches Prinzip wie `ports.yml` für die Firewall) in die Host-`~/.ssh/authorized_keys` schreiben — löst das SSH-Bootstrap-Henne-Ei-Problem, da [Phase 4](04-hardening.md) sonst beim ersten Lauf keinen SSH-Zugriff aufs Haupt-OS hätte. Phase 4 verwaltet diese Datei danach idempotent weiter.
    *   Zum Schluss den Fingerprint des neu erzeugten Host-Keys ausgeben (`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`) — bei Neuaufbau einer bestehenden IP ändert sich der Host-Key gegenüber dem alten Eintrag, der Admin vergleicht den Fingerprint beim ersten Connect in Phase 4 manuell und räumt vorher einen etwaigen alten Eintrag per `ssh-keygen -R <ip>` aus dem lokalen `known_hosts` auf.
5. Unmount, Rescue-Modus explizit deaktivieren (`hcloud server disable-rescue`) — sonst bootet der Server wieder ins Rescue-System statt ins neue OS —, danach Reboot (API).
