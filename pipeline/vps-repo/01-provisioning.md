# Phase 1 — Provisioning

`[AUTOMATISIERT — hcloud-CLI-Skript, vps/infra/]`

Idempotentes Skript gegen das offizielle `hcloud`-CLI (kein Terraform/IaC-State — BSL-Lizenzrisiko und Overkill für eine VPS mit zwei Ressourcen):

*   Prüft per `hcloud server describe` anhand eines festen Servernamens + Hetzner-Labels (beide als Konstante in `vps/infra/`), ob der Server schon existiert, legt ihn sonst neu an.
*   Die Firewall wird davon unabhängig bei jedem Skriptlauf idempotent auf den Soll-Zustand aus `ports.yml` gebracht (`hcloud firewall`-Regeln per festem Namen anlegen falls fehlend, sonst per `set-rules` synchronisieren) — nicht nur bei Server-Neuanlage, damit spätere `ports.yml`-Änderungen auch gegen einen bereits bestehenden Server automatisiert nachgezogen werden.
*   Servertyp `cx33` (4 vCPU shared, 8GB RAM, 80GB NVMe SSD — für den späteren App-Stack einer kleinen Schule ausreichend dimensioniert), Region `fsn1`/`nbg1` (Falkenstein/Nürnberg, Deutschland — einfachste DSGVO-Begründung ohne Drittland-Transfer), beide als Konstante in `vps/infra/`.
*   Firewall-Portliste kommt aus einer gemeinsamen `ports.yml` in `vps/infra/`, die auch das UFW-Skript aus [Phase 4](04-hardening.md) liest — eine Änderung an einer Stelle wirkt auf beide Firewall-Ebenen.
*   Deckt „bestehende VPS" ohne `terraform import` ab. Jeder Admin nutzt seinen eigenen Hetzner-API-Token statt eines geteilten.
*   Output: Server-IP (bei Hetzner Cloud sofort und dauerhaft bei Server-Erstellung vergeben, ändert sich nicht bei Reboot).
