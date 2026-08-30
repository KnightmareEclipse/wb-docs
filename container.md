# Container — Runtime, Stack, Anwendung

Umgesetzt in `wb-vps/ansible/roles/podman_rootful/` (die Runtime) und `wb-backend` (Compose-Stack
und Anwendung). Der Host darunter steht in `host.md`, das Ausrollen in `deploy.md`.

Podman als Container-Runtime, **rootful** betrieben. Veröffentlichte Ports leitet der Kernel per DNAT weiter — der Container sieht damit die echte Absenderadresse des Aufrufers, nachgewiesen gegen `db-prod-fsn-01` über IPv4 und IPv6 im Access-Log von Caddy.

## Warum rootful

Rootless leitet veröffentlichte Ports über `rootlessport`, einen Userspace-Proxy, der die Verbindung des Aufrufers beendet und eine neue öffnet. Die Absenderadresse kann dabei nicht ankommen — im Container erscheint das Bridge-Gateway statt des Clients. Das entwertet Access-Logs für Art. 33 und jedes IP-bezogene Rate-Limiting.

Der einzige Ausweg unter rootless wäre systemd-Socket-Activation. Sie erzwingt eine Quadlet-Unit neben Compose, ein eigenes Egress-Netz, abgeschaltetes HTTP/3 und einen trotzdem normal veröffentlichten Port 80, weil Caddys ACME-Löser keinen Dateideskriptor binden kann. Der saubere Upstream-Fix (`rootless_port_forwarder="pasta"`) setzt Podman 6 voraus; Debian 13 liefert Podman 5.4, auch `trixie-backports` hat nichts Neueres.

Podman bleibt gegenüber Docker gesetzt (`rules.md` Abschnitt 4): daemonlos, aus Debian main, kein dauerhaft laufender Root-Dienst mit root-äquivalentem Socket.

**Bewusst aufgegeben:** die Bedrohung, gegen die rootless gebaut war, ist ein kompromittierter Deploy-Pfad, der dann echtes Root erhält. Das wiegt hier leichter, weil der in `rules.md` Abschnitt 2 genannte CI-Deploy-Key nicht existiert — es gibt kein externes CI (`deploy.md`). Was bleibt, ist die Kette „RCE in der Anwendung → Container-Ausbruch"; die UID-Abbildung unten ist die kompensierende Kontrolle dagegen.

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

UFW bleibt damit eine echte zweite Ebene und behält die Begründung aus `host.md`, braucht aber vier Ergänzungen, alle in der `hardening`-Rolle und alle aus vorhandenen Quellen gespeist:

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

**`podman-compose` ist die schwächste Stelle der Boring-Technology-Wahl** — `rules.md` Abschnitt 4
misst an der Debugbarkeit durch einen Nachfolger, und der kennt `docker compose`, nicht dessen
Reimplementierung. Die beiden Eigenheiten unten sind erst im Betrieb aufgefallen und kosten je einen
Schalter im Deploy-Skript. Es bleibt trotzdem: die naheliegende Alternative, `docker compose` gegen
`podman.socket`, kauft Compose-Treue mit genau dem dauerhaft laufenden root-äquivalenten Socket,
wegen dessen Abwesenheit Podman überhaupt gewählt wurde — dazu mit Dockers Fremd-Repo, das mit der
Runtime-Wahl gerade entfallen ist. **Neu zu bewerten beim dritten Workaround** — oder sobald eine Eigenheit nicht mehr mit einem
Schalter zu beheben ist.

Drei Eigenheiten von `podman-compose` — die ersten beiden im Deploy-Skript aufgefangen, die dritte in der Compose-Datei selbst:

*   `up -d` erkennt ein neu gebautes Image nicht — der Tag bleibt gleich, die Compose-Konfiguration damit auch, und der alte Container läuft weiter. Deshalb `--force-recreate`.
*   `run` stoppt jeden Dienst, den es nicht selbst startet. Eine fehlgeschlagene Migration hätte damit den gesamten Stack heruntergefahren, statt die laufenden Container unberührt zu lassen (`deploy.md`). Deshalb `--no-deps`.
*   Die **Exec-Form eines Healthchecks** (`test: [CMD, ...]`) wird zu einem Shell-Kommando plattgeklopft, ohne die Argumente zu quoten — `/bin/sh` liest dann die Klammern des Prüfbefehls als eigene Syntax. Der Container antwortet dabei völlig normal; unhealthy ist allein die Prüfung, und der Deploy wartet auf einen Zustand, der nie eintritt. `CMD-SHELL` mit einer ausgeschriebenen Zeichenkette läuft in beiden Laufzeiten durch `sh` und macht das Quoting zur Eigenschaft der Compose-Datei statt der Implementierung, die sie liest.

## Was die Rolle sonst einrichtet

*   `podman`, `aardvark-dns`, `podman-compose` und `git` aus Debian main. **`aardvark-dns` ausdrücklich:** Podman hängt hart an `netavark`, zieht die DNS-Hälfte aber weder als Depends noch als Recommends.
*   `podman-restart.service` aktiviert — die Reboot-Festigkeit des Stacks hängt daran.
*   Die Deploy-Unit läuft mit `KillMode=process`. Mit systemds Default reißt das Ende des Oneshot-Laufs die eben gestarteten Container wieder mit ab: die mit Restart-Policy kommen zurück, der zuletzt gestartete bleibt tot.
*   Bare-Repo samt Hook, die `.env` mit Domain und ACME-Verzeichnis, und das Deploy-Log unter `/var/log/wb-app-stack-deploy.log`, das der Push zurückliest — so sieht der auslösende Admin ohne Journal-Zugriff, woran ein Deploy gescheitert ist.
*   Die Secret-Dateien des App-Stacks entstehen beim Deploy aus den `APP_`-Schlüsseln der `secrets.env` (Schema: `wb-vps/setup/secrets.example.env`): ein Schlüssel wird zu einer Datei gleichen Namens ohne Präfix, klein geschrieben. Sie gehören der Container-UID und liegen in einem Verzeichnis, das nur Root betreten kann.

## Der Stack darüber

Vier Dienste in einem Compose-Stack: Reverse-Proxy (Caddy, automatisches HTTPS), Datenbank
(PostgreSQL 18), Backend und der Lauf-Dienst daneben. Der Backend-Dienst: Python, FastAPI +
SQLAlchemy 2.0 (async) + Alembic-Migrationen, Dependency-Management über `pip` + `pip-tools`
(Lockfile via `pip-compile`), Lint/Format über `ruff`, Typecheck über `mypy --strict`,
OIDC-Token-Validierung über `PyJWT`, Constraint-Solver `ortools` für die Putzdienst-Restzuordnung,
Zahlungsanbindung an Stripe für die drei Selbstservice-Anlässe (`grenzkarte.md`, Q3 — einziger
Dienstleister mit Personendaten-Berührung, AVV in `dsgvo.md`), Tests über `pytest` vor jedem Deploy
(lokal gegen den Compose-Stack, `rules.md` Abschnitt 9). Was die API dabei prüfen muss —
Token-Validierung, Ownership-Check, Bulk-/Export-Regel — steht in `zugang.md`.

### Netze

Getrennte Container-Netze, damit ein Einbruch nicht das gesamte System offenlegt:
*   **Externes Netz:** genau eine Komponente mit Internet-Zugang (Reverse-Proxy/TLS-Terminierung: Caddy, automatisches HTTPS, kein Zugriff auf einen Runtime-Socket nötig), kein direkter DB-Zugriff von dort.
*   **Internes Netz:**
    *   **Backend:** verarbeitet Anfragen, validiert Auth-Tokens, spricht mit der Datenbank über ein ORM (SQL-Injection soll durch die Wahl des Datenzugriffswerkzeugs gar nicht erst als eigenes Thema entstehen). Python, FastAPI + SQLAlchemy 2.0 (async) + Alembic-Migrationen.
    *   **Datenbank:** akzeptiert ausschließlich Verbindungen aus dem Backend über das interne Container-Netz. Ein Backup-Prozess (`backup.md`) braucht ebenfalls Zugriff, ohne dass dafür ein Port nach außen oder auf den Host veröffentlicht wird — Exec-Zugriff auf den DB-Container über die Podman-CLI statt eines gemappten Ports — unter rootful als Root, nicht als `deploy` (`container.md`), Details in `backup.md`.
    *   **Transportverschlüsselung intern:** Reverse-Proxy→Backend und Backend→Datenbank laufen voraussichtlich unverschlüsselt (kein TLS) über das interne Container-Netz. **Akzeptiertes Risiko:** Netzwerk-Isolation (kein extern erreichbarer Port) ist die kompensierende Kontrolle — Traffic verlässt nie den Host. Die Verschlüsselungspflicht aus `rules.md` Abschnitt 2 gilt für alles, was den Host verlässt.
    *   **Least-Privilege DB-Rollen (PostgreSQL):**
        *   Laufzeit-Rolle nur CRUD (kein `DROP`/`ALTER`) — und nicht auf allen Daten: besonders geschützte Spalten und Tabellen (Art.-9-Daten, Bankverbindungen) hängen an eigenen, enger geschnittenen Rollen (`schema/stammdaten-schema.sql`). Jede entsteht in der Migration ihrer Domäne, `NOLOGIN` und ohne Passwort, gewählt per `SET LOCAL ROLE` (`prompts/schema-uebertragen.md`); drei Bedingungen muss jede Umsetzung erfüllen: die Laufzeit-Rolle darf **keine** der Tabellen besitzen (gegen den Eigentümer greift kein Spalten-GRANT), sie bekommt auf keiner Tabelle ein tabellenweites `GRANT UPDATE` (das deckt alle Spalten ab und lässt sich durch ein nachträgliches `REVOKE UPDATE (spalte)` nicht wieder einschränken — auch die Unveränderlichkeit von Schlüsselspalten hängt daran, `schema/stammdaten-schema.sql`), und jede neue Spalte braucht eine bewusste GRANT-Entscheidung statt stillschweigender Aufnahme. Alle drei prüft `wb-backend/tests/test_privileges.py` gegen die laufende Datenbank — weder Alembics `--autogenerate` noch die Prüfskripte in `schema/` sehen Privilegien an, eine Migration, die zu breit vergibt, fiele sonst nirgends auf.
        *   Migrationen über eine separate, privilegiertere Rolle — im laufenden Betrieb ungenutzt **und unzugänglich** (eigener Prozess/Service-Definition mit eigenem Secret, das der dauerhaft laufende Backend-Container nie zu sehen bekommt).
        *   Der Backup-Prozess (`backup.md`) nutzt eine eigene Rolle mit reinem Lesezugriff.
        *   **Rotation:** Neues Passwort in die Secrets-Datei im gemeinsamen Passwortmanager eintragen, auf DB-Seite ändern, danach `deploy-secrets.sh` ausführen und einmal deployen — der Deploy schreibt die einzelnen Secret-Dateien neu und startet die Container, die sie lesen (`runbook.md` Schritt 5) — der Deploy-Auslöser braucht keine eigene Rotation, er nutzt den ohnehin per `admins.yml` gepflegten Admin-Key.

### Secrets

*   DB-Zugangsdaten und weitere App-Secrets liegen als Dateien auf dem Host, in einem Verzeichnis, das nur Root betreten kann. Eigentümer ist die Host-UID, auf die Container-Root abgebildet wird (`container.md`); die Dateien selbst sind innerhalb dieser Grenze lesbar, weil die lesenden Prozesse in ihren Containern nicht Root sind (Postgres, `appuser`) und eine Datei nicht mehreren UIDs zugleich gehören kann. Auf dem Host kommt außer Root niemand an das Verzeichnis, in einen Container nur, was die Compose-Datei ausdrücklich mountet.
*   Werden als gemountete Secret-Dateien (`/run/secrets/…`) in Container gereicht — nicht als `.env`/Env-Vars, da diese über `podman inspect`, `/proc/<pid>/environ` oder Logging-Tools leicht abgreifbar sind.
*   Die Werte selbst kommen aus der Secrets-Datei im gemeinsamen Passwortmanager und werden vom Setup-Skript aus `host.md` (Root-Rechte) auf den Host geschrieben — der Git-Push-Deploy-Auslöser (`deploy.md`) bekommt diese Werte nie zu sehen, er deployt ausschließlich Code/Images.

### Zentrales Logging

*   **Eine einzige Log-Senke für Host- und Container-Logs, und es ist journald** — kein eigener Log-Stack daneben (`wb-vps/ansible/roles/hardening/`, journald; `…/podman_rootful/templates/containers.conf.j2`, der Treiber). Es läuft auf Hetzners Standard-Debian-Image vorkonfiguriert, und der Treiber ist ausdrücklich gesetzt statt der Voreinstellung überlassen: Zöge die auf `k8s-file` um, erreichten Container-Logs die Senke nicht mehr, und der Offsite-Auszug unten würde still leer. Das Volumen, an dem die Wahl hing, ist gemessen: **712 Byte Log je Anfrage** (Caddys Zeile plus die des Backends), im Leerlauf praktisch nichts. Selbst ein voller Schultag bleibt damit weit unter dem, was einen zweiten Dienst rechtfertigte — und CPU dafür gibt es nicht, die vier vCPU sind unter den vier Diensten aufgeteilt (oben). — Alternative: Loki/Vector neben dem Stack; Preis: ein fünfter Dienst ohne CPU-Deckel, ein zweiter Aufbewahrungsort für dieselben personenbezogenen Zeilen und ein eigener Wiederherstellungspfad, für ein Volumen, das in eine Textdatei passt.
*   **Der Reverse-Proxy muss Zugriffe überhaupt protokollieren.** Caddy tut das ohne ausdrückliche `log`-Direktive nicht — ohne sie existiert schlicht kein Zugriffsprotokoll, und die 72h-Meldefrist hätte keine Grundlage. Steht im Caddyfile des App-Stack-Repos (`wb-backend/caddy/Caddyfile`), und zwar mit einem `format filter`: Die protokollierte URI trägt die Query, und die Adresse aus einem personalisierten Link (`zugang.md`) läge damit in einem Bestand mit anderer Aufbewahrung und anderem Leserkreis als die Datenbank. Der Filter ersetzt ihren Wert, statt den Parameter zu streichen — zum selben Preis bleibt sichtbar, **dass** ein solcher Link benutzt wurde, und genau das fragt Art. 33.
*   Die Absenderadresse des Aufrufers steht darin, weil rootful Podman Ports per Kernel-DNAT weiterleitet statt über einen Userspace-Proxy — nachgewiesen über IPv4 und IPv6 gegen `db-prod-fsn-01` (`container.md`). Das interne Container-Netz braucht dafür IPv6, sonst schreibt die Runtime keine v6-Weiterleitungsregeln und Anfragen über IPv6 erreichen den Reverse-Proxy nie.
*   **Retention: 30 Tage**, das kurze Ende des Richtwerts 30–90 — sie begrenzt die Aufbewahrung (Art. 5 Abs. 1 lit. e) und trägt zugleich die Grundlage für die 72h-Meldefrist (Art. 33), die erst ab **Kenntnis** läuft und deshalb Vorlauf braucht. Gesetzt als `wb_journal_retention_days` in `wb-vps/ansible/group_vars/all.yml`, damit ein anderer Wert eine Zeile ist. **Drei Grenzen und nicht eine**: ohne `MaxRetentionSec` löscht journald überhaupt nicht nach Alter, ohne `MaxFileSec` prüft es das Alter je Datei und wirft eine monatelange erst weg, wenn ihr *jüngster* Eintrag alt genug ist, und ohne eigenes `SystemMaxUse` entschiede journalds Vorgabe von 4 GB die Aufbewahrung still mit — sie wirft die ältesten Einträge zuerst weg, genau die, nach denen Art. 33 fragt.
*   **Offsite-Kopie:** Die zentrale Log-Senke ist ausschließlich lokal auf der VPS — bei Totalausfall oder Kompromittierung des Hosts wären damit auch die für Art. 33 nötigen Logs weg. Derselbe Backup-Job, der die DB sichert (`backup.md`), sichert deshalb zusätzlich einen aktuellen Log-Auszug offsite — kein eigenes Log-Shipping-Tool nötig.

### Änderungsspur

Beantwortet eine andere Frage als die Infra-Logs oben — Zugriffs-/Fehler-Logs zeigen Requests, nicht wer welchen Datensatz geändert hat. Bleibt bewusst getrennt vom zentralen Logging, da Datensatz-Historie strukturiert abfragbar sein muss (SQL), nicht nur als Log-Zeile. Gebaut ist er zweiteilig: zwei Erzeuger-Spalten (`created_at`/`created_by`) je Tabelle, dazu die Änderungsspur `change_log` als **eine** Tabelle über alle Fachdomänen, die wer, wann und was vorher dastand trägt (`schema/querschnitt-schema.sql`). Ein zweites Spaltenpaar für die letzte Änderung gibt es daneben auf keiner Tabelle: der letzte Änderer ist aus der Spur ableitbar, und zwei Orte für dieselbe Tatsache wären der eine, den das erste Massen-Update vergisst (`schema/stammdaten-schema.sql`, `rules.md` Abschnitt 1). Geschrieben wird die Spur von der **Anwendung** und nicht von einem DB-Trigger — eine Regel, die nur in der Datenbank lebt, ist im Code unsichtbar; die Absicherung ist eine gemeinsame Schreibschicht in `wb-backend` (`wb-backend/app/db/changelog.py`). Den Verursacher kennt nur die Anwendung: sie setzt ihn einmal je Transaktion als Sitzungsvariable (`app.actor`); fehlt er, scheitert der Schreibpfad hart an `created_by`, statt einen leeren Verursacher zu hinterlassen. Verursacher-Format: Kopfkommentar von `schema/stammdaten-schema.sql`, ein CHECK je Tabelle weist alles ohne Präfix ab.

### Versandschicht

Dasselbe Muster wie die Schreibschicht oben, eine Ebene daneben — **jede Mail an eine Familie geht denselben Weg hinaus, und der schreibt seine Zeile selbst.** Sie läuft über eine Funktion, die `outbound_emails` schreibt und danach über Graph sendet (`zugang.md`); kein Endpunkt und kein Lauf ruft den Mailversand direkt. Daneben steht **genau ein** zweiter Weg, der Anmeldecode ganz unten — zwei Wege insgesamt, beide benannt, damit ein dritter auffällt. Reihenfolge ausdrücklich so: erst die Zeile, dann das Senden, und scheitert Graph, trägt dieselbe Zeile `undeliverable_at` samt Grund. Andersherum — senden und nur im Erfolgsfall ablegen — hinterließe die gescheiterte Mail nirgends, und genau die ist die, der das Sekretariat nachgehen soll (`soll-prozesse/hebel.md`, „Unzustellbare Mail"). **Kein Wiederholungsversuch und keine Warteschlange:** Ein Fehlschlag ist sichtbar, und was danach geschieht, entscheidet ein Mensch; ein Zustellversuch im Hintergrund bräuchte einen zweiten Lauf und eine zweite Zustandshaltung für einen Fall, der selten ist.

*   **Die Schicht führt eigene Transaktionen, und daran hängt die ganze Zusage.** Eine Anfrage läuft in **einer** Transaktion, die am Ende committet (`wb-backend/README.md`, „Writing data") — läge die Zeile darin, risse ein Graph-Fehler sie mit zurück, und die gescheiterte Mail hinterließe genau nichts. Also: Zeile schreiben und committen, senden, im Fehlerfall die Marke in einer zweiten Transaktion. Preis: zwei eigene Commits statt eines mitgenutzten und zwei `change_log`-Zeilen mehr je Fehlschlag, dazu ein Versand, der nicht mehr am Erfolg der Anfrage hängt, die ihn auslöst — was richtig herum ist: Der Vorgang ist geschehen, die Mail nicht.
*   **An einer abgewiesenen Zeile heißt `sent_at` „versucht", nicht „versandt".** Weist Graph ab, ist nie etwas hinausgegangen; die Zeile steht trotzdem, weil sie sonst nirgends stünde. Für das Sekretariat sind das zwei Handlungen — eine zurückgekommene Mail will eine berichtigte Adresse, eine abgewiesene nur einen zweiten Versuch —, und `undeliverable_reason` trägt den Unterschied.
*   **Der Rückläufer aus dem Postfach wird noch nicht gelesen.** `undeliverable_at` trägt vorerst nur, was der Versand selbst bemerkt (Graph weist ab). Der Unzustellbarkeitsbericht, der später im Postfach ankommt, wird erst ausgewertet, wenn dort ohnehin Menschen mitlesen — die Bedingung dafür steht in `zugang.md`.
*   **Die eine Ausnahme ist der Anmeldecode**, ausgeschrieben in `soll-prozesse/hebel.md` („Unzustellbare Mail"). Er geht weiter direkt über `wb-backend/app/routers/auth.py`, und das ist der zweite Weg hinaus — der einzige, und er ist benannt, damit ein dritter auffällt. Was hier daran hängt: Sein Fehlschlag betrifft keine Familie, sondern den Betrieb, und geht deshalb als `/fail` auf den Monitoring-Check des Hosts, wie Image-GC und NAS-Backup (`host.md`). Ohne ihn legt ein abgelaufenes Client-Secret den gesamten Elternzugang still und nichts sagt es — eine Logzeile ist keine Meldung (`rules.md` Abschnitt 3). **Nicht tragfähig wäre die naheliegendere Begründung**, die Zeile fehle wegen des Löschankers: Den hat auch die Mail an eine noch unbekannte Familie (05, 09, 10) nicht, und die wird abgelegt (`schema/querschnitt-schema.sql`). Was den Code trennt, ist die Zahl — jede je eingetippte Adresse gegen die einer Familie, die einen Vorgang begonnen hat.

### Läufe

Was zu einem Zeitpunkt von selbst geschieht, hat keinen Aufrufer und keinen Endpunkt (`api/gemeinsam.md`, „Was keine Route ist"). Gebaut wird es als **vierter Dienst im selben Compose-Stack** — dasselbe Backend-Image, eine Schleife, die tickt und schläft, `restart: always` wie die anderen drei —, und **die Anwendung fragt die Datenbank, was fällig ist**, statt dass irgendwo ein Zeitplan stünde. Das folgt aus der Natur der Auslöser: Sie stehen als Daten (`cleaning_cycles.registration_opens_at`, ein Termindatum, der Monatserste), nicht als Uhrzeit. Drei Eigenschaften fallen dadurch gratis an: Ein verpasster Tick holt beim nächsten alles Fällige nach, ein Wartungsfenster oder ein Deploy braucht keine Nachholmechanik, und ein geänderter Zeitpunkt ist eine Datenänderung statt eines Deploys.

*   **Jeder Lauf ist wiederholbar, und die Marke dafür steht in den Daten** — in einer Spalte, die sagt, dass **dieser Lauf** gelaufen ist, nie in einer, die einen benachbarten Vorgang führt. `cleaning_cycles.allocation_released_at` ist gerade **keine**: Sie trägt die Freigabe durch das Sekretariat (01, Z5), nicht den Zuteilungslauf (Z4). Wer sie als „noch nicht gelaufen" liest, teilt zwischen Fensterschluss und Freigabe alle fünf Minuten neu zu und überschreibt genau die Handarbeit, für die dieser Zwischenraum da ist. Findet sich keine passende Spalte, ist das ein Fund am Schema der Domäne und **keine** Zustandsdatei neben der Datenbank — sonst kennt der Lauf einen Zustand, den kein Block kennt. Im Putzdienst fehlen vier solche Spalten (`backlog/`); allein der Monatslauf hat seine.
*   **Ein Prozess, der nichts tut, sieht aus wie einer, der wartet.** Der Dienst bekommt deshalb einen **eigenen** healthchecks.io-Check und nicht den des Hosts. An dem hängt genau ein Herzschlag (`host.md`, alle 15 Minuten); Image-GC und NAS-Backup melden dorthin nur Fehlschläge. Ein zweiter Herzschlag daneben hielte den Check grün, während der Host-Timer tot ist — und umgekehrt —, und der Dead-Man's-Switch verlöre beide Richtungen auf einmal. Ein Lauf, der wirft, pingt `/fail` und die Schleife läuft weiter: Ein Fehlschlag darf den Container nicht in eine Neustartschleife schicken, in der er die Datenbank hämmert, aber geloggt-und-vergessen wäre ein stiller Fehlschlag (`rules.md` Abschnitt 3).
*   **Was der Dienst zusätzlich braucht**, weil das Backend-Image es nicht mitbringt: das `external`-Netz — `internal: true` sperrt auch ausgehend, ohne es erreicht weder der Ping healthchecks.io noch der Versand Graph —, die Ping-URL als Secret-Datei wie in Phase 2, und `otp_signing_key` gemountet, obwohl er keinen Code hasht (`Settings` verlangt es ohne Default, `wb-backend/CLAUDE.md` Abschnitt 5). Grenzen: `cpus: 0.5`, `mem_limit: 256m` — der laufende Dienst misst 60 MB, die Anwendung samt Web-Teil 77 — und ein Verbindungspool von zwei statt der voreingestellten fünfzehn: Die Schleife ist einfädig, aber ein Lauf, der seine Transaktion offen hält und dabei eine Mail schickt, braucht die zweite — der Versand committet auf einer eigenen. Bei eins liefe er in den Pool-Timeout. Die drei vorhandenen CPU-Grenzen summieren sich bereits auf die vier vCPU der Maschine; die vierte wird aus dem Vorhandenen geschnitten und nicht danebengelegt. **Und die Schleife hört auf ein Signal**: Der Prozess ist PID 1 in seinem Container, und PID 1 bekommt keine Standardbehandlung für SIGTERM — ohne eigenen Handler wartet ein schlafender Tick die Gnadenfrist der Runtime ab und wird dann hart getötet, gemessen zehn Sekunden je Deploy. Später wäre der Preis größer als die Sekunden: Ein abgewürgter Lauf sieht von außen aus wie einer, der still nichts getan hat. Das Signal beendet dabei das **Warten**, nicht einen laufenden Tick — ein Lauf, der länger dauert als die Gnadenfrist, wird weiter getötet; neu zu bewerten mit dem ersten, der Minuten braucht, und das ist der Zuteilungs-Solver. Dass ein Solver-Lauf den Web-Prozess nicht aushungert, kauft nicht die Existenz der Grenze, sondern ihre Höhe.
*   Verworfen: **ein Scheduler im Web-Prozess** (APScheduler o. Ä.). Preis: eine Abhängigkeit mehr, Läufe, die mit dem Prozess sterben, und ein zweiter Worker täte alles doppelt. Verworfen: **ein Timer je Lauf**. Preis: jede Fälligkeit stünde zweimal — als Datum in der Datenbank und als Kalenderausdruck in einer Unit —, und die Zuteilung eines Putzdienstjahres bekäme einen eigenen Timer je Jahrgang. Verworfen: **ein systemd-Timer beim `deploy`-User, der je Tick einen Container startet** (das Muster des Image-GC). Preis nicht die Rechenzeit — zwei Sekunden CPU alle fünf Minuten sind Rauschen — und auch nicht ein zweites Repo je Lauf: Eine einzige Unit ruft alle auf, und der fünfte Lauf ist so oder so eine Funktion in `wb-backend`. Der Preis ist der Containerstart je Tick samt kaltem Verbindungspool, und dass die Taktweite hinter einem Ansible-Lauf im VPS-Repo läge statt in der Compose-Datei neben dem Dienst. Der Preis der Schleife dagegen sind 60 MB Arbeitsspeicher, die dauerhaft belegt sind, und ein Hängenbleiben, das erst der eigene Check oben sichtbar macht.

### Container-Hardening

Non-Root-User, Root-Filesystem read-only + gezielte `tmpfs`-Mounts, CPU-/Memory-Limits (`--memory=…`/`--cpus=…`) — Standardhärtung unabhängig vom konkreten Image. Image-Patches im selben monatlichen Rhythmus wie Host-Patches — anders als bei `unattended-upgrades` auf dem Host kein automatischer Mechanismus: ein Admin stößt monatlich manuell einen Rebuild + Redeploy mit aktuellen Base-Images an. Dass ein Base-Image überhaupt eine neue Version hat, meldet Dependabot per PR (`rules.md` Abschnitt 3) — der Rebuild-/Redeploy-Anstoß selbst bleibt manuell.
