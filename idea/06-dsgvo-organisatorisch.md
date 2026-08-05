# 6. Organisatorische DSGVO-Pflichten (schulweit, nicht VPS-spezifisch)

*   **AVV (Art. 28):** Verträge mit Hoster, Microsoft und healthchecks.io (`idea/01-boot-verschluesselung.md`) prüfen/abschließen — sobald die App-Stack-Architektur steht, kommen die dafür gewählten Dienstleister (Code-/CI-Plattform, Backup-Ziel, ggf. weitere) mit eigener AVV-Prüfung hinzu (`rules.md` Abschnitt 7).
*   **Verarbeitungsverzeichnis (Art. 30):** dieses System ergänzen.
*   **Meldeprozess (Art. 33):** Zuständigkeit für 72h-Meldung klären; Logging (`idea/03-container-anwendung.md`) liefert die technische Grundlage.
*   **Betroffenenrechte (Art. 15/16/20):** bestehender Prozess gilt auch für diese Daten.
*   **Löschfristen der Fach-DB (Art. 5 Abs. 1 lit. c/e):** Stammdaten (Adresse, Telefon, E-Mail, Geburtsdatum) brauchen eigene Löschfrist nach Abgang, separat von Log- (`idea/03-container-anwendung.md`) und Backup-Retention (`idea/05-backup-recovery.md`) — bei kleiner Schule reicht ein jährlicher manueller Lösch-Job.
