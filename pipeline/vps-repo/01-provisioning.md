# Phase 1 — Provisioning

`[AUTOMATISIERT — hcloud-CLI-Skript, vps/infra/]`

Idempotentes Skript gegen das offizielle `hcloud`-CLI (kein Terraform/IaC-State, `rules.md` Abschnitt 1; zusätzlich spräche hier das BSL-Lizenzrisiko des Terraform-Providers dagegen):

*   Prüft per `hcloud server describe` anhand eines festen Servernamens + Hetzner-Labels (beide als Konstante in `vps/infra/`), ob der Server schon existiert, legt ihn sonst neu an.
*   Die Firewall wird davon unabhängig bei jedem Skriptlauf idempotent auf den Soll-Zustand aus `ports.yml` gebracht (`hcloud firewall`-Regeln per festem Namen anlegen falls fehlend, sonst per `set-rules` synchronisieren) — nicht nur bei Server-Neuanlage, damit spätere `ports.yml`-Änderungen auch gegen einen bereits bestehenden Server automatisiert nachgezogen werden. Jede Freigabe-Regel wird für beide Quell-Familien gesetzt (`0.0.0.0/0` **und** `::/0`) — Hetzner wendet eine Regel nicht automatisch auf beide an, sonst bliebe der IPv6-Pfad (Hetzners natives Dual-Stack-Networking auf dem Standard-Image) ungefiltert (`idea/02-netzwerk-firewall.md`).
*   Servertyp `cx33` (4 vCPU shared, 8GB RAM, 80GB NVMe SSD — für den späteren App-Stack einer kleinen Schule ausreichend dimensioniert), Region `fsn1` (Falkenstein, Deutschland — einfachste DSGVO-Begründung ohne Drittland-Transfer), beide als Konstante in `vps/infra/`.
*   `--image debian-12` ist das tatsächlich laufende Image — Hetzners Standard-Cloud-Image, unverändert übernommen (`idea/01-boot-verschluesselung.md`). Die Admin-Public-Keys aus `vps/setup/admins.yml` (bewusst dieselbe einzige Key-Quelle wie in Phase 2, `rules.md` Abschnitt 3 — liegt in `setup/`, wird aber auch hier vom `infra/`-Skript gelesen) werden vom Skript zuvor idempotent als Hetzner-SSH-Key-Ressourcen im Projekt angelegt (`hcloud ssh-key create`, gleiches Anlegen-falls-fehlend-Muster wie die Firewall), damit `--ssh-key` sie bei `server create` referenzieren kann — Hetzners Cloud-Init injiziert sie automatisch in `root`s `authorized_keys`, der Server ist direkt nach Erstellung per Admin-Key erreichbar, kein Umgang mit einem API-Root-Passwort nötig.
*   Firewall-Portliste kommt aus einer gemeinsamen `ports.yml` in `vps/infra/`, die auch das UFW-Skript aus [Phase 2](02-hardening.md) liest — eine Änderung an einer Stelle wirkt auf beide Firewall-Ebenen.
*   Deckt „bestehende VPS" ohne `terraform import` ab. Jeder Admin nutzt seinen eigenen Hetzner-API-Token statt eines geteilten.
*   Output: Server-IP (bei Hetzner Cloud sofort und dauerhaft bei Server-Erstellung vergeben, ändert sich nicht bei Reboot).
