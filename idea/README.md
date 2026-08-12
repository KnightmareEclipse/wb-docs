# Gesamtsystem-Konzept: Sicherer Datenbank- & API-VPS für Schulprozesse

Fundament (Server-Image, physische Sicherheit, verschlüsseltes Swap, Bus-Faktor) und Netzwerk-/Firewall-Ebene (Zero-Trust nach außen, SSH-Härtung) sind VPS-Setup und stehen konkret in `pipeline/vps-repo/01-provisioning.md` und `02-hardening.md` — kein eigenes Konzept-Kapitel mehr hier. Die restlichen Ebenen sind architektonisch fixiert (Stack siehe `project-parts.md`) und werden im App-Stack-Repo (`wb-backend`) umgesetzt, bleiben aber als Konzept-Kapitel hier bestehen:

3. [Container- & Anwendungs-Ebene](03-container-anwendung.md) — Container-Netz-Isolation, DB-Rollen, Secrets, Logging
4. [Identitäts- & Zugriffs-Ebene](04-identitaet-zugriff.md) — externer OIDC-Identitätsanbieter, Autorisierung
5. [Backup- & Recovery-Ebene](05-backup-recovery.md) — Push-/Prune-Split, Restore-Test
6. [Organisatorische DSGVO-Pflichten](06-dsgvo-organisatorisch.md) — AVV, Meldeprozess, Löschfristen
