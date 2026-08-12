# Phase 3 — Container-Runtime-Install (Podman, rootful)

`[NOCH NICHT UMGESETZT]`

Podman als Container-Runtime, **rootful** betrieben, mit `--userns=auto` je Container.

## Warum rootful

Rootless war zuerst gesetzt und ist gebaut, gemessen und wieder entfernt worden. Es funktionierte — die Isolation hielt, der App-Stack lief Ende zu Ende. Verworfen wurde es nicht am Ergebnis, sondern an den Sonderwegen, die es erzwingt:

*   Die Portweiterleitung läuft über `rootlessport`, einen Userspace-Proxy, der die Verbindung des Aufrufers beendet und eine neue öffnet. Die Absenderadresse kann dabei nicht ankommen — gemessen: der Container sieht das Bridge-Gateway statt des Clients. Das entwertet Access-Logs für Art. 33 und jedes IP-bezogene Rate-Limiting.
*   Der einzige heute verfügbare Ausweg ist systemd-Socket-Activation. Sie funktioniert (nachgewiesen: echte Adresse über IPv4 und IPv6, Zertifikat bezogen, Reboot überstanden), erzwingt aber eine Quadlet-Unit neben Compose, ein eigenes Egress-Netz, abgeschaltetes HTTP/3 und einen normal veröffentlichten Port 80, weil Caddys ACME-Löser keinen Dateideskriptor binden kann.
*   Der saubere Upstream-Fix (`rootless_port_forwarder="pasta"`) setzt Podman 6 und ein passt von Mai 2026 voraus. Debian 13 liefert Podman 5.4 und passt von Mai 2025; auch `trixie-backports` hat nichts Neueres.

Rootful erreicht dasselbe Ergebnis über Kernel-DNAT, ohne einen einzigen dieser Sonderwege. **`--userns=auto`** hält dabei den Großteil des Isolationsgewinns: jeder Container bekommt einen eigenen, automatisch vergebenen UID-Bereich, Container-Root ist also kein Host-Root.

Podman bleibt gegenüber Docker gesetzt (`rules.md` Abschnitt 4): daemonlos, aus Debian main, kein dauerhaft laufender Root-Dienst mit root-äquivalentem Socket.

**Bewusst aufgegeben:** die Bedrohung, gegen die rootless ursprünglich gebaut war, ist ein kompromittierter Deploy-Pfad, der dann statt `deploy` echtes Root erhält. Das wiegt heute leichter als früher, weil der in `rules.md` Abschnitt 2 namentlich genannte CI-Deploy-Key nicht mehr existiert — es gibt kein externes CI mehr (`pipeline/app-stack-repo/04-app-stack-deploy.md`). Was bleibt, ist die Kette „RCE in der Anwendung → Container-Ausbruch"; `--userns=auto` ist die kompensierende Kontrolle dagegen.

## Offen, zwingend vor der Umsetzung zu klären

*   **Firewall.** Rootless Podman fasste die Host-iptables nicht an — darauf beruht die Begründung der zweiten UFW-Ebene in [Phase 2](02-hardening.md). Rootful schreibt für veröffentlichte Ports eigene nftables-Regeln. Zu klären ist, ob diese Regeln UFW umgehen (wie bei Docker bekannt) und wie beide Ebenen wieder zu einem widerspruchsfreien Zustand kommen, in dem weiterhin `infra/ports.yml` die einzige Quelle bleibt.
*   Ob das Container-Management weiter über Compose läuft oder auf Quadlet wechselt — unter rootful verwaltet systemd Container ohnehin natürlich.
