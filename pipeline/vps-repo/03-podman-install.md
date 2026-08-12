# Phase 3 — Container-Runtime-Install (Podman, rootful)

`[AUTOMATISIERT — Ansible-Rolle podman_rootful, wb-vps/ansible/]`

Podman als Container-Runtime, **rootful** betrieben. Veröffentlichte Ports leitet der Kernel per DNAT weiter — der Container sieht damit die echte Absenderadresse des Aufrufers, nachgewiesen gegen `db-prod-fsn-01` über IPv4 und IPv6 im Access-Log von Caddy.

## Warum rootful

Rootless leitet veröffentlichte Ports über `rootlessport`, einen Userspace-Proxy, der die Verbindung des Aufrufers beendet und eine neue öffnet. Die Absenderadresse kann dabei nicht ankommen — im Container erscheint das Bridge-Gateway statt des Clients. Das entwertet Access-Logs für Art. 33 und jedes IP-bezogene Rate-Limiting.

Der einzige Ausweg unter rootless wäre systemd-Socket-Activation. Sie erzwingt eine Quadlet-Unit neben Compose, ein eigenes Egress-Netz, abgeschaltetes HTTP/3 und einen trotzdem normal veröffentlichten Port 80, weil Caddys ACME-Löser keinen Dateideskriptor binden kann. Der saubere Upstream-Fix (`rootless_port_forwarder="pasta"`) setzt Podman 6 voraus; Debian 13 liefert Podman 5.4, auch `trixie-backports` hat nichts Neueres.

Podman bleibt gegenüber Docker gesetzt (`rules.md` Abschnitt 4): daemonlos, aus Debian main, kein dauerhaft laufender Root-Dienst mit root-äquivalentem Socket.

**Bewusst aufgegeben:** die Bedrohung, gegen die rootless gebaut war, ist ein kompromittierter Deploy-Pfad, der dann echtes Root erhält. Das wiegt hier leichter, weil der in `rules.md` Abschnitt 2 genannte CI-Deploy-Key nicht existiert — es gibt kein externes CI (`pipeline/app-stack-repo/04-app-stack-deploy.md`). Was bleibt, ist die Kette „RCE in der Anwendung → Container-Ausbruch"; die UID-Abbildung unten ist die kompensierende Kontrolle dagegen.

## UID-Abbildung der Container

Alle Container laufen in einem festen, unprivilegierten UID-Bereich, gesetzt in `/etc/containers/containers.conf.d/00-wb-vps.conf`:

```
userns = "auto:uidmapping=0:200000:65536,gidmapping=0:200000:65536,size=65536"
```

Container-Root ist damit Host-UID 200000, nicht Host-Root. Die Einstellung steht auf Host-Ebene und nicht je Dienst — so bleibt die Compose-Datei frei von podman-spezifischer Syntax und lokal unverändert lauffähig (`rules.md` Abschnitt 9).

**Warum fest abgebildet statt `--userns=auto` in Reinform — gemessen:** `auto` vergibt jedem Container einen anderen Bereich, und Podman chownt ein Named Volume nur bei der ersten Benutzung. Der nächste Start desselben Dienstes kann seine eigenen Daten dann nicht mehr schreiben (`Permission denied`); dasselbe gilt für die gemounteten Secret-Dateien. Der Ausweg über die Mount-Option `:U` wäre podman-spezifische Syntax in der Compose-Datei und damit ein Verstoß gegen Abschnitt 9.

**Akzeptiertes Risiko:** Alle Container teilen sich einen UID-Bereich, unterscheiden sich also vom Host, aber nicht voneinander. Sie sind eine Anwendung mit gemeinsamem Netz, und die Eigenschaft, auf die es ankommt, ist Container-Root ≠ Host-Root.

Zwei Voraussetzungen, beide ohne Fehlermeldung, die auf die Ursache zeigt:

*   Ein Eintrag für den Benutzernamen `containers` in `/etc/subuid` und `/etc/subgid`. Debian liefert keinen; Podman verweigert sonst jeden Container mit „no subuid ranges found for user containers".
*   **Kein Pod.** `podman-compose` steckt alle Dienste per Default in einen Pod, und ein Pod-Mitglied bekommt die Abbildung oben nicht — gemessen war `uid_map` in allen drei Containern die Identitätsabbildung, Container-Root also echtes Host-Root. `x-podman: in_pod: false` in der Compose-Datei schaltet das ab; Docker ignoriert `x-`-Schlüssel, die Datei bleibt eine.

## Firewall: UFW wird nicht umgangen — es blockierte zu viel

Gemessen gegen `db-prod-fsn-01` statt aus der Docker-Literatur übernommen: Auf Debian 13 schreibt netavark seine Regeln in eine eigene nftables-Tabelle (`inet netavark`), UFW seine in `ip filter`/`ip6 filter`. Beide hängen an denselben Hooks, und ein `accept` in netavarks Kette beendet nur diese eine Kette — UFWs Kette läuft danach trotzdem, deren `drop` gewinnt. Die von Docker bekannte Umgehung tritt hier also nicht ein.

Der tatsächliche Befund war das Gegenteil: Ein Container, der Port 80 veröffentlichte, war von außen **nicht** erreichbar, obwohl die Hetzner Cloud Firewall Port 80 offen hatte. Grund: `ufw allow` schreibt nur eine INPUT-Regel, ein veröffentlichter Container-Port wird aber in PREROUTING per DNAT umgeschrieben und danach geforwardet — INPUT sieht ihn nie.

UFW bleibt damit eine echte zweite Ebene und behält die Begründung aus [Phase 2](02-hardening.md), braucht aber vier Ergänzungen, alle in der `hardening`-Rolle und alle aus vorhandenen Quellen gespeist:

*   **`ufw route allow <port>/<proto>` je Eintrag aus `infra/ports.yml`**, zusätzlich zum bestehenden `ufw allow`. `ports.yml` bleibt die einzige Quelle; ob ein Host-Prozess oder ein Container antwortet, ist für diese Liste unerheblich.
*   **`DEFAULT_FORWARD_POLICY="DROP"`** ausdrücklich festgeschrieben. Daran hängt die ganze Zusage — ohne sie könnte jeder Container jeden Port an beiden Firewall-Ebenen vorbei veröffentlichen.
*   **`ufw route allow out on <WAN-Interface>`.** Die Forward-Policy blockiert sonst auch den ausgehenden Container-Verkehr; das fällt zuerst beim Image-Build auf, der an der Namensauflösung scheitert. Geöffnet wird nur die Richtung aus dem Host heraus — Verkehr von außen verlässt den Host in Richtung einer Container-Bridge und muss weiterhin auf eine der Port-Regeln passen. Das Interface wird aus der Default-Route gelesen statt fest eingetragen: ein veralteter Name nähme sonst den ganzen Stack still vom Netz.
*   **`ufw allow in from <Container-Subnetz> to any port 53`.** Der DNS-Dienst der Runtime lauscht auf dem Bridge-Gateway, also auf einer Host-Adresse — die Anfragen sind eingehender Host-Verkehr, kein geforwardeter. Ohne die Regel kommt der Stack „healthy" hoch, während jede Verbindung zwischen zwei Diensten am Namen scheitert. Die Subnetze stehen deshalb zusätzlich in `containers.conf`, damit Runtime und Firewall nicht auseinanderlaufen können.

**Nachgewiesen:** Ein Container, der Port 9999 veröffentlicht (nicht in `ports.yml`), ist von außerhalb des Hosts weder über IPv4 noch über IPv6 erreichbar.

## Wer startet Container

Root startet sie. Der `deploy`-User darf per `sudo` genau eine Unit starten und sonst nichts:

```
deploy ALL=(root) NOPASSWD: /usr/bin/systemctl start wb-app-stack.service
```

Sudo vergleicht den gesamten Argumentvektor — ein abweichender Aufruf passt nicht. `sudo podman` wäre root-äquivalent und würde den Zweck des eingeschränkten Users aufheben (`rules.md` Abschnitt 2, Least Privilege).

Die Unit führt ein root-eigenes Skript aus: Auschecken des letzten Push, Secret-Dateien schreiben, bauen, migrieren, neu starten. Ausgelöst wird sie vom `post-receive`-Hook des Bare-Repos unter `deploy`; dessen `authorized_keys` sind per `command="git-shell …"` auf Git-Operationen beschränkt, eine interaktive Shell als `deploy` gibt es nicht. Der Checkout läuft als Root aus dem Bare-Repo in ein root-eigenes Arbeitsverzeichnis — `deploy` hält zu keinem Zeitpunkt eine beschreibbare Kopie dessen, was Root gleich baut.

**Verbleibende Angriffsfläche, akzeptiertes Risiko:** Wer in das Repo pushen kann, bestimmt, was Root anschließend baut und startet. Das gilt für jede Deploy-Strecke und lässt sich nicht wegkonfigurieren. Eine Rechteausweitung ist es hier nicht: Die einzigen Schlüssel in `deploy`s `authorized_keys` sind die Admin-Keys aus `setup/admins.yml`, und Admins liegen innerhalb der Vertrauensgrenze (`rules.md` Abschnitt 2). Was die enge sudo-Regel liefert, ist kein Root-Shell-Zugang für den Deploy-Weg, ein einziger auditierbarer Einstiegspunkt und ein Auslöser, der als Commit nachvollziehbar bleibt.

## Compose, nicht Quadlet

Compose bleibt auch produktiv. `rules.md` Abschnitt 9 verlangt, dass dieselbe Datei lokal läuft, und „ein Ort pro Sachverhalt" verbietet eine zweite Beschreibung desselben Stacks. Quadlet gäbe beides auf, um eine systemd-Integration zu kaufen, die hier bereits vorhanden ist: `podman-restart.service` bringt nach einem Reboot jeden Container mit Restart-Policy genau `always` zurück.

Zwei Eigenheiten von `podman-compose`, beide im Deploy-Skript berücksichtigt:

*   `up -d` erkennt ein neu gebautes Image nicht — der Tag bleibt gleich, die Compose-Konfiguration damit auch, und der alte Container läuft weiter. Deshalb `--force-recreate`.
*   `run` stoppt jeden Dienst, den es nicht selbst startet. Eine fehlgeschlagene Migration hätte damit den gesamten Stack heruntergefahren, statt die laufenden Container unberührt zu lassen (`pipeline/app-stack-repo/04-app-stack-deploy.md`). Deshalb `--no-deps`.

## Was die Rolle sonst einrichtet

*   `podman`, `aardvark-dns`, `podman-compose` und `git` aus Debian main. **`aardvark-dns` ausdrücklich:** Podman hängt hart an `netavark`, zieht die DNS-Hälfte aber weder als Depends noch als Recommends.
*   `podman-restart.service` aktiviert — die Reboot-Festigkeit des Stacks hängt daran.
*   Die Deploy-Unit läuft mit `KillMode=process`. Mit systemds Default reißt das Ende des Oneshot-Laufs die eben gestarteten Container wieder mit ab: die mit Restart-Policy kommen zurück, der zuletzt gestartete bleibt tot.
*   Bare-Repo samt Hook, die `.env` mit Domain und ACME-Verzeichnis, und das Deploy-Log unter `/var/log/wb-app-stack-deploy.log`, das der Push zurückliest — so sieht der auslösende Admin ohne Journal-Zugriff, woran ein Deploy gescheitert ist.
*   Die Secret-Dateien des App-Stacks entstehen beim Deploy aus den `APP_`-Schlüsseln der `secrets.env` (Schema: `wb-vps/setup/secrets.example.env`): ein Schlüssel wird zu einer Datei gleichen Namens ohne Präfix, klein geschrieben. Sie gehören der Container-UID und liegen in einem Verzeichnis, das nur Root betreten kann.
