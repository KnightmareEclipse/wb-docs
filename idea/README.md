# Gesamtsystem-Konzept: Sicherer Datenbank- & API-VPS für Schulprozesse

Ein Abschnitt pro Datei, in derselben Reihenfolge wie das ursprüngliche Konzept:

1. [Fundament & Boot-Ebene](01-boot-verschluesselung.md) — LUKS-Verschlüsselung, automatischer Unlock, Bus-Faktor
2. [Netzwerk- & Firewall-Ebene](02-netzwerk-firewall.md) — Zero-Trust nach außen, SSH-Härtung
3. [Container- & Anwendungs-Ebene](03-container-anwendung.md) — Docker-Netz-Isolation, DB-Rollen, Secrets, Logging
4. [Identitäts- & Zugriffs-Ebene](04-identitaet-zugriff.md) — externer OIDC-Identitätsanbieter, Autorisierung
5. [Backup- & Recovery-Ebene](05-backup-recovery.md) — Push-/Prune-Split, Restore-Test
6. [Organisatorische DSGVO-Pflichten](06-dsgvo-organisatorisch.md) — AVV, Meldeprozess, Löschfristen
