# 6. Organisatorische DSGVO-Pflichten (schulweit, nicht VPS-spezifisch)

*   **AVV (Art. 28):** Verträge mit Hoster, Microsoft und healthchecks.io prüfen/abschließen. healthchecks.io (kostenloser Hobbyist-Plan, laut Anbieter-FAQ ausdrücklich auch für Firmen-/Organisationsnutzung, Limit 20 Checks pro juristischer Person, genutzt wird nur einer) läuft selbst auf Hetzner-Servern in Deutschland, Betreiberfirma in Lettland — DSGVO-pflichtig, eigener minimaler AVV nötig; es fließen aber nie Schülerdaten durch den Dienst, nur Heartbeat + Disk-Wert (`pipeline/vps-repo/02-hardening.md`). Sobald die App-Stack-Architektur steht, kommen die dafür gewählten Dienstleister (Code-/CI-Plattform, Backup-Ziel, ggf. weitere) mit eigener AVV-Prüfung hinzu (`rules.md` Abschnitt 7).
*   **Verarbeitungsverzeichnis (Art. 30):** dieses System ergänzen.
*   **Meldeprozess (Art. 33):** Zuständigkeit für 72h-Meldung klären; Logging (`idea/03-container-anwendung.md`) liefert die technische Grundlage.
*   **Betroffenenrechte (Art. 15/16/20):** bestehender Prozess gilt auch für diese Daten.
*   **Löschfristen der Fach-DB (Art. 5 Abs. 1 lit. c/e):** Stammdaten (Adresse, Telefon, E-Mail, Geburtsdatum) brauchen eigene Löschfrist nach Abgang, separat von Log- (`idea/03-container-anwendung.md`) und Backup-Retention (`idea/05-backup-recovery.md`) — bei kleiner Schule reicht ein jährlicher manueller Lösch-Job.
