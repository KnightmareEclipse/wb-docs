# Planungsregeln

Prinzipien, nach denen jede Entscheidung in `idea/`, `pipeline/`, `project-parts.md` und den Umsetzungs-Repos getroffen wird. Bei Zielkonflikten sticht diese Reihenfolge: **Sicherheit vor Automatisierung vor Einfachheit vor Kosten** — wobei die vier sich in der Praxis meist ergänzen statt widersprechen. Kontext: mittelgroße Schule ohne eigenes IT-Personal, das System muss ohne den aktuellen Betreiber weiterlaufen und übergebbar sein.

## 1. Lean by Design (Ponytail-Prinzip)

Vor jeder neuen Komponente, jedem neuen Dienst, jeder neuen Abstraktion diese Leiter durchgehen, am ersten tragfähigen Punkt stehenbleiben:

1. **Braucht es das wirklich?** Kein Feature, kein Service für einen hypothetischen künftigen Bedarf — nur für einen konkret vorliegenden.
2. **Bietet Hoster/Plattform es schon nativ?** Hetzner Cloud Firewall statt Eigenbau; die ohnehin vorhandene Identitäts-/Office-Umgebung der Schule statt eigener Nutzerverwaltung.
3. **Löst Standardsoftware es?** Eine etablierte Standard-Datenbank statt eigener Datenhaltung, ein Standard-Reverse-Proxy statt Eigenbau, ein Standard-Backup-Tool statt Eigenbau, ein vorhandener Log-Mechanismus statt eigenem Log-Stack — konkrete Wahl folgt mit der App-Stack-Architektur.
4. **Ist es schon im Stack vorhanden?** Kein zweites Tool für das, was ein bestehendes bereits kann.
5. **Erst dann:** neuer Dienst/eigener Code — minimal gehalten, mit klar benanntem Zweck.

Beispiele für bereits angewandte Entscheidungen nach dieser Leiter: kein Terraform (State-Overhead für eine VPS mit zwei Ressourcen), kein Ansible (ein Host mit statischer IP reicht für ein idempotentes Shell-Skript), kein zusätzlicher Log-Stack, wenn ein bereits vorhandener Mechanismus für die Log-Menge reicht. Neue Entscheidungen folgen demselben Muster.

Keine Hochverfügbarkeits-Infrastruktur (Multi-Server, Load-Balancer, Multi-Region) ohne konkreten Bedarf — eine VPS mit getesteten Backups und vollständiger Neuaufsetzbarkeit (Abschnitt 6) ist für diese Schulgröße ausreichend. Eine Wiederherstellungszeit von Stunden ist ein bewusst akzeptierter Trade-off gegen Komplexität, kein Mangel.

## 2. Secure by Design

- **Vertrauensgrenze:** Root-Zugriff auf die Maschine (die eigenen Admins) und der Hoster Hetzner selbst gelten als vertrauenswürdig — abgesichert über die Bus-Faktor-/Offboarding-Regeln unten bzw. über die AVV mit Hetzner (Art. 28), nicht durch zusätzliche technische Maßnahmen gegen die eigene Root-Ebene (jemand mit Root sieht ohnehin alles, was der Server sieht — das lässt sich auf einer einzelnen VPS ohne unverhältnismäßigen Aufwand nicht technisch verhindern). Jede Maßnahme in diesem Dokument zielt auf die Außengrenze: Angreifer aus dem Internet und kompromittierte Drittanbieter-Credentials (z. B. ein geleakter CI-Deploy-Key) — nicht auf die eigenen Admins oder Hetzner selbst.
- **Standardmäßig zu, explizit öffnen:** jede neue Netzwerkverbindung, jeder neue Port ist per Default geschlossen und wird nur für einen benannten Zweck freigegeben (Zero-Trust-Muster aus `pipeline/vps-repo/01-provisioning.md` gilt für jede künftige Komponente).
- **Least Privilege:** jede neue Rolle, jeder neue Zugang bekommt nur die minimal nötige Berechtigung — nie „damit es bequemer ist" mehr.
- **Schreiben ≠ Löschen:** destruktive/unwiderrufliche Aktionen (Prune, Delete, Force-Push) laufen über ein eigenes, stärker geschütztes Credential, das nicht dauerhaft auf einem internetexponierten System liegt (Push-/Prune-Split aus `idea/05-backup-recovery.md` ist das Referenzmuster für jede künftige destruktive Aktion).
- **Ein Credential pro Person/Zweck**, nie geteilt — Admin-SSH-Keys, API-Tokens, Deploy-Keys. Ermöglicht Offboarding durch einfaches Widerrufen statt Rotation für alle.
- **MFA-Pflicht für kritische Admin-Konten mit Login-Seite:** Hetzner-Cloud-Konto, DNS-Provider der Schule, GitHub-Organisation sowie — sobald gewählt — die Admin-Portale der weiteren App-Stack-Dienstleister (CI-Plattform, Identitätsanbieter) — überall dort, wo die Web-Konsole eines kritischen Kontos das Login ist, nicht Key-only-SSH (das bereits passwortlos ist). Diese Web-Konsolen sind sonst der weiche Punkt in einem ansonsten Key-only gehärteten System (Phishing/Credential-Stuffing statt Bruteforce).
- **Gemeinsamer Passwortmanager (KeePass):** keine Login-Seite, also kein Phishing-/Credential-Stuffing-Ziel und keine klassische MFA anwendbar. Schutz stattdessen über ein starkes, einzigartiges Master-Passwort zusammen mit KeePass' Argon2id-KDF, die Offline-Bruteforce gegen eine geleakte Datenbankdatei praktisch unmöglich macht. Bewusster Verzicht auf zusätzliche Schlüsseldatei/Hardware-Key als akzeptiertes Risiko (Abschnitt 5): der Aufwand, einen Zusatzfaktor sauber getrennt von der Datenbank über alle genutzten Geräte hinweg (inkl. Tablet ohne verlässlichen USB-Zugriff) zu verteilen, steht in keinem Verhältnis zum Sicherheitsgewinn gegenüber einem ausreichend starken Master-Passwort.
- **Secrets nie im Git, nie in CI-Logs, nie als Klartext-Env-Var in Containern.** Liegen als Datei im gemeinsamen Passwortmanager (nicht in Git), werden vor einem Setup-Lauf lokal heruntergeladen und als gemountete Datei (`/run/secrets/…`) in Container gereicht.
- **Verschlüsselung Pflicht** für alles, was Schülerdaten führt und den Host verlässt: at rest im Backup-Repo, in transit (TLS). Volle Festplattenverschlüsselung auf dem Host selbst ist bewusst keine Pflicht — Begründung in `pipeline/vps-repo/01-provisioning.md`.
- **Patch-Kadenz:** monatlich für Host und Container-Images. Host-Kernel-Updates laufen inklusive automatischem Reboot in einem festen wöchentlichen Wartungsfenster (Samstag, 03:00 Uhr, `unattended-upgrades`-Muster) — der anschließende Boot braucht keine menschliche Aktion (`pipeline/vps-repo/02-hardening.md`), überwacht durch den bestehenden Dead-Man's-Switch. Container-Image-Rebuilds bleiben monatlich manuell angestoßen (`idea/03-container-anwendung.md`).

## 3. Automatisierung

- Jeder wiederkehrende Vorgang wird skriptbar gebaut — Ausnahme nur, wenn er zwingend menschliches Urteilsvermögen erfordert oder ein Geheimnis voraussetzt, das bewusst nur ein Mensch halten darf (z. B. das Master-Passwort des gemeinsamen Passwortmanagers).
- Jedes Skript ist **idempotent** — beliebig oft wiederholbar, ohne Schaden anzurichten (Referenzmuster: die Bootstrap-Checks in `pipeline/vps-repo/01-provisioning.md`/`02-hardening.md`).
- Jeder automatisierte Job (Cronjob, Systemd-Timer, CI-Pipeline) **meldet Fehlschläge aktiv** (Push-Alert), statt dass jemand aktiv nachschauen muss — ein stiller Fehlschlag zählt als nicht vorhanden.
- **Eine Konfigurationsquelle pro Sachverhalt**, von allen Skripten referenziert, die sie brauchen (`ports.yml`, `admins.yml`-Muster) — keine duplizierten Listen, die auseinanderlaufen können.
- **Organisatorische Werte, die sich zyklisch ändern** (Fristen, Beträge, Stückzahlen, Kapazitäten, Vorlaufzeiten) liegen als Daten in der Datenbank, gepflegt über die jeweilige Verwaltungsoberfläche — nicht im Code oder einer Deploy-Konfigurationsdatei, die für eine reine Werteänderung einen Codetouch/Redeploy erzwingt. Gilt nur, wo der Mehraufwand dafür überschaubar bleibt (Abschnitt 1) — bei echtem Struktur-/Prozesswechsel bleibt eine Code-Änderung die richtige, nicht künstlich überkonfigurierte Lösung.
- Abhängigkeits-Updates (npm/pip/Docker-Base-Images) laufen über automatisierte PRs (Tool offen, z. B. Renovate oder Dependabot, beide kostenlos) statt manuellem Nachschauen — konkretes Tool folgt mit der Wahl der Code-/CI-Plattform, reduziert die monatliche Handarbeit aus `idea/03-container-anwendung.md` (Container-Image-Rebuilds) auf einen Review-Klick pro PR.

## 4. Kosten & Software-Auswahl

- Alles außer VPS-Miete und M365-Lizenz muss **quelloffen oder dauerhaft kostenlos** nutzbar sein — keine befristeten Trials, keine „kostenlos bis X Nutzer" ohne Wachstumsplan.
- Azure-Dienste (Functions, Static Web Apps) laufen ausschließlich innerhalb der kostenlosen monatlichen Kontingente. Bei jeder neuen Azure-Ressource: Budget-Alert in Azure Cost Management auf niedriger Schwelle einrichten, damit ein Überschreiten nicht unbemerkt Kosten verursacht.
- Vor jedem neuen Dienst: reicht eine bereits genutzte Lösung (z. B. das bereits für den Host eingesetzte healthchecks.io)? Erst wenn nein — und dann bevorzugt ein Dienst mit großzügigem Free-Tier und EU-Sitz/-Hosting (vereinfacht Abschnitt 7).
- **Boring Technology:** etablierte, weit verbreitete, gut dokumentierte Software (Debian Stable, Docker als Basis; beim App-Stack ebenso etablierte statt exotische Wahlen) statt Nischentools, die nur der aktuelle Betreiber kennt und die im Ernstfall niemand sonst debuggen kann.

## 5. Dokumentation & Wissenstransfer

- Dokumentationsstil wie in `CLAUDE.md` festgelegt: ausschließlich aktueller Stand, keine Historie.
- Jeder manuelle Schritt bekommt ein Runbook, ausführbar von jemandem ohne Vorwissen (Referenz: „Runbook — Kompletter Neuaufbau" in `pipeline/runbook.md`).
- Wiederkehrende Wartungsaufgaben (monatlicher Image-Rebuild, quartalsweiser Restore-Test, Secret-Rotation, jährlicher Löschjob) haben je einen wiederkehrenden Termin im gemeinsamen M365-Gruppenkalender der Schule — nie an einer Einzelperson, die sich zufällig daran erinnert. Der Host-Reboot selbst läuft automatisch (`pipeline/vps-repo/02-hardening.md`) und braucht deshalb keinen eigenen Termin mehr.
- Jede bewusste Vereinfachung wird als **akzeptiertes Risiko** explizit benannt (wie durchgängig in `idea/` praktiziert), nicht stillschweigend übernommen.

## 6. Bus-Faktor, Übergabefähigkeit & Reproduzierbarkeit

- Mindestens **zwei Admins** haben jederzeit vollen Zugriff auf alle kritischen Systeme und Credentials.
- Kritische Konten (Passwortmanager, healthchecks.io, Hetzner-Cloud-Konto, DNS-Provider, Code-Plattform (GitHub-Organisation) sowie — sobald gewählt — CI-Plattform und Identitätsanbieter) laufen auf organisationseigenen, nicht auf persönlichen Zugängen.
- Jeder personengebundene Zugang (Hetzner-API-Token, SSH-Key, Deploy-Key) hat einen dokumentierten, gleich einfachen Widerruf — Offboarding darf nie mehr sein als das Entfernen eines einzelnen Eintrags.
- Das gesamte System ist aus Git + der Secrets-Datei im gemeinsamen Passwortmanager vollständig neu aufsetzbar, ohne Wissen, das nur im Kopf des aktuellen Betreibers existiert — keine Konfiguration, die nur manuell in einer Cloud-Konsole entsteht und nirgends als Skript/Doku existiert.
- **Umzugsfähig:** ein Wechsel des Hosters oder ein Neuaufbau auf einer neuen VPS ist mit vertretbarem Aufwand möglich, ohne Datenverlust — Hetzner-Spezifisches (hcloud-Skript, Firewall-API) bleibt sauber getrennt vom generischen Setup-Teil (Docker, App-Stack), der 1:1 auf einen anderen Anbieter übertragbar ist.

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
- Externe Abhängigkeiten (Identitätsanbieter/OIDC, ggf. Microsoft Graph/SharePoint) werden lokal durch Dummy-Werte/Mocks ersetzt — Entwicklung hängt nie an Produktiv-Credentials.
- Neue Änderungen laufen erst gegen eine lokale Instanz der gewählten Datenbank, bevor sie über die Pipeline (Phase 4) deployt werden — die Produktiv-VPS ist kein Testfeld.
