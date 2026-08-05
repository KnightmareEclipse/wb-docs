# Planungsregeln

Prinzipien, nach denen jede Entscheidung in `idea/`, `pipeline/`, `project-parts.md` und den Umsetzungs-Repos getroffen wird. Bei Zielkonflikten sticht diese Reihenfolge: **Sicherheit vor Automatisierung vor Einfachheit vor Kosten** — wobei die vier sich in der Praxis meist ergänzen statt widersprechen. Kontext: mittelgroße Schule ohne eigenes IT-Personal, das System muss ohne den aktuellen Betreiber weiterlaufen und übergebbar sein.

## 1. Lean by Design (Ponytail-Prinzip)

Vor jeder neuen Komponente, jedem neuen Dienst, jeder neuen Abstraktion diese Leiter durchgehen, am ersten tragfähigen Punkt stehenbleiben:

1. **Braucht es das wirklich?** Kein Feature, kein Service für einen hypothetischen künftigen Bedarf — nur für einen konkret vorliegenden.
2. **Bietet Hoster/Plattform es schon nativ?** Hetzner Cloud Firewall, Entra ID, M365 statt Eigenbau.
3. **Löst Standardsoftware es?** Postgres statt eigener Datenhaltung, Caddy statt eigenem Reverse Proxy, Restic statt eigenem Backup-Tool, journald statt eigenem Log-Stack.
4. **Ist es schon im Stack vorhanden?** Kein zweites Tool für das, was ein bestehendes bereits kann.
5. **Erst dann:** neuer Dienst/eigener Code — minimal gehalten, mit klar benanntem Zweck.

Beispiele für bereits angewandte Entscheidungen nach dieser Leiter: kein Terraform (State-Overhead für eine VPS mit zwei Ressourcen), kein Ansible (ein Host mit statischer IP reicht für ein idempotentes Shell-Skript), kein Loki/Promtail (journald reicht für die Log-Menge). Neue Entscheidungen folgen demselben Muster.

Keine Hochverfügbarkeits-Infrastruktur (Multi-Server, Load-Balancer, Multi-Region) ohne konkreten Bedarf — eine VPS mit getesteten Backups und vollständiger Neuaufsetzbarkeit (Abschnitt 6) ist für diese Schulgröße ausreichend. Eine Wiederherstellungszeit von Stunden ist ein bewusst akzeptierter Trade-off gegen Komplexität, kein Mangel.

## 2. Secure by Design

- **Standardmäßig zu, explizit öffnen:** jede neue Netzwerkverbindung, jeder neue Port ist per Default geschlossen und wird nur für einen benannten Zweck freigegeben (Zero-Trust-Muster aus `idea/02-netzwerk-firewall.md` gilt für jede künftige Komponente).
- **Least Privilege:** jede neue Rolle, jeder neue Zugang bekommt nur die minimal nötige Berechtigung — nie „damit es bequemer ist" mehr.
- **Schreiben ≠ Löschen:** destruktive/unwiderrufliche Aktionen (Prune, Delete, Force-Push) laufen über ein eigenes, stärker geschütztes Credential, das nicht dauerhaft auf einem internetexponierten System liegt (Push-/Prune-Split aus `idea/05-backup-recovery.md` ist das Referenzmuster für jede künftige destruktive Aktion).
- **Ein Credential pro Person/Zweck**, nie geteilt — Admin-SSH-Keys, API-Tokens, Deploy-Keys. Ermöglicht Offboarding durch einfaches Widerrufen statt Rotation für alle.
- **MFA-Pflicht für kritische Admin-Konten:** Hetzner-Cloud-Konto, GitLab.com, Entra-ID-Admin-Portal, DNS-Provider der Schule und der gemeinsame Passwortmanager selbst — überall dort, wo die Web-Konsole eines kritischen Kontos das Login ist, nicht Key-only-SSH/Dropbear (die bereits passwortlos sind). Diese Web-Konsolen sind sonst der weiche Punkt in einem ansonsten Key-only gehärteten System (Phishing/Credential-Stuffing statt Bruteforce).
- **Secrets nie im Git, nie in CI-Logs, nie als Klartext-Env-Var in Containern.** Immer verschlüsselt at rest (age-Secrets-Datei) und als gemountete Datei (`/run/secrets/…`) in Container gereicht.
- **Verschlüsselung Pflicht** für alles, was Schülerdaten führt: at rest (LUKS, Restic-Repo) und in transit (TLS).
- **Patch-Kadenz:** monatlich für Host und Container-Images. Automatisiert, wo kein Reboot-/Downtime-Risiko besteht (`unattended-upgrades`-Muster); wo doch, gebündelt und manuell angestoßen statt einzeln.

## 3. Automatisierung

- Jeder wiederkehrende Vorgang wird skriptbar gebaut — Ausnahme nur, wenn er zwingend menschliches Urteilsvermögen erfordert oder ein Geheimnis voraussetzt, das bewusst nur ein Mensch halten darf (LUKS-Passphrase-Eingabe).
- Jedes Skript ist **idempotent** — beliebig oft wiederholbar, ohne Schaden anzurichten (Referenzmuster: die Wipe-/Bootstrap-Checks in `pipeline/vps-repo/01-provisioning.md`/`02-rescue-install.md`).
- Jeder automatisierte Job (Cronjob, Systemd-Timer, CI-Pipeline) **meldet Fehlschläge aktiv** (Push-Alert), statt dass jemand aktiv nachschauen muss — ein stiller Fehlschlag zählt als nicht vorhanden.
- **Eine Konfigurationsquelle pro Sachverhalt**, von allen Skripten referenziert, die sie brauchen (`ports.yml`, `admins.yml`-Muster) — keine duplizierten Listen, die auseinanderlaufen können.
- Abhängigkeits-Updates (npm/pip/Docker-Base-Images) laufen über automatisierte PRs (Renovate oder Dependabot, beide kostenlos) statt manuellem Nachschauen — reduziert die monatliche Handarbeit aus `project-parts.md` Abschnitt 1 auf einen Review-Klick pro PR.

## 4. Kosten & Software-Auswahl

- Alles außer VPS-Miete und M365-Lizenz muss **quelloffen oder dauerhaft kostenlos** nutzbar sein — keine befristeten Trials, keine „kostenlos bis X Nutzer" ohne Wachstumsplan.
- Azure-Dienste (Functions, Static Web Apps) laufen ausschließlich innerhalb der kostenlosen monatlichen Kontingente. Bei jeder neuen Azure-Ressource: Budget-Alert in Azure Cost Management auf niedriger Schwelle einrichten, damit ein Überschreiten nicht unbemerkt Kosten verursacht.
- Vor jedem neuen Dienst: reicht eine bereits genutzte Lösung (Postgres, journald, healthchecks.io, GitLab CI)? Erst wenn nein — und dann bevorzugt ein Dienst mit großzügigem Free-Tier und EU-Sitz/-Hosting (vereinfacht Abschnitt 7).
- **Boring Technology:** etablierte, weit verbreitete, gut dokumentierte Software (Debian Stable, Postgres, Docker, Caddy, Restic) statt Nischentools, die nur der aktuelle Betreiber kennt und die im Ernstfall niemand sonst debuggen kann.

## 5. Dokumentation & Wissenstransfer

- Dokumentationsstil wie in `CLAUDE.md` festgelegt: ausschließlich aktueller Stand, keine Historie.
- Jeder manuelle Schritt bekommt ein Runbook, ausführbar von jemandem ohne Vorwissen (Referenz: „Runbook — Kompletter Neuaufbau" in `pipeline/runbook.md`).
- Wiederkehrende Wartungsaufgaben (Patch-Rebuild, Restore-Test, Secret-Rotation, Löschjob) hängen an einer **Rolle** bzw. einem gemeinsamen Kalender — nie an einer Einzelperson, die sich zufällig daran erinnert.
- Jede bewusste Vereinfachung wird als **akzeptiertes Risiko** explizit benannt (wie durchgängig in `idea/` praktiziert), nicht stillschweigend übernommen.

## 6. Bus-Faktor, Übergabefähigkeit & Reproduzierbarkeit

- Mindestens **zwei Admins** haben jederzeit vollen Zugriff auf alle kritischen Systeme und Credentials.
- Kritische Konten (Passwortmanager, healthchecks.io, GitLab, Entra-ID-Admin, Hetzner-Cloud-Konto, DNS-Provider) laufen auf organisationseigenen, nicht auf persönlichen Zugängen.
- Jeder personengebundene Zugang (Hetzner-API-Token, SSH-Key, Deploy-Key) hat einen dokumentierten, gleich einfachen Widerruf — Offboarding darf nie mehr sein als das Entfernen eines einzelnen Eintrags.
- Das gesamte System ist aus Git + verschlüsselter Secrets-Datei vollständig neu aufsetzbar, ohne Wissen, das nur im Kopf des aktuellen Betreibers existiert — keine Konfiguration, die nur manuell in einer Cloud-Konsole entsteht und nirgends als Skript/Doku existiert.
- **Umzugsfähig:** ein Wechsel des Hosters oder ein Neuaufbau auf einer neuen VPS ist mit vertretbarem Aufwand möglich, ohne Datenverlust — Hetzner-Spezifisches (hcloud-Skript, Firewall-API) bleibt sauber getrennt vom generischen Setup-Teil (LUKS, Docker, App-Stack), der 1:1 auf einen anderen Anbieter übertragbar ist.

## 7. Datenschutz (DSGVO by Design)

- **Datensparsamkeit:** nur speichern, was ein konkreter Schulprozess tatsächlich braucht.
- Löschfristen von Anfang an mitgeplant, nicht nachträglich ergänzt (siehe `idea/06-dsgvo-organisatorisch.md`).
- Jeder neue externe Dienst durchläuft vor Produktivsetzung eine AVV-Prüfung (Art. 28) — Kostenfaktor (Abschnitt 4) und Compliance-Faktor werden gemeinsam bewertet, nicht getrennt.
- Log- und Backup-Retention ist zeitlich begrenzt und dokumentiert, nie unbegrenzt.

## 8. Testbarkeit

- Ein Backup, das nie wiederhergestellt wurde, gilt als nicht vorhanden — jeder Recovery-Pfad hat einen wiederkehrenden Test (Referenz: quartalsweiser Restore-Test in `idea/05-backup-recovery.md`).
- Jedes Skript, das produktiv gegen den Server läuft, wird vorher gegen einen Wegwerf-Zustand geprüft (Scratch-Container, Rescue-System-Idempotenz), nicht direkt live.

## 9. Lokale Entwicklung

- Es gibt keinen dedizierten Dev-/Staging-Server — jede App-Stack-Komponente (Abschnitt 3/4 in `project-parts.md`) muss per Docker Compose lokal auf der Entwickler-Maschine lauffähig sein, unabhängig von der Produktions-VPS.
- Externe Abhängigkeiten (Entra-ID/OIDC, Microsoft Graph/SharePoint) werden lokal durch Dummy-Werte/Mocks ersetzt — Entwicklung hängt nie an Produktiv-Credentials.
- Neue Änderungen laufen erst gegen eine lokale Postgres-Instanz, bevor sie über die Pipeline (Phase 5b) deployt werden — die Produktiv-VPS ist kein Testfeld.
