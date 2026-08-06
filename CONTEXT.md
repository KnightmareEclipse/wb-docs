# Weltenbaum — Domänen-Glossar

Fachbegriffe für den DSGVO-konformen Datenbank-/API-Stack einer Schule (technische Umsetzung: `project-parts.md`, `idea/`). Gilt repo-übergreifend (`wb-backend`, künftige Frontend-/Teams-Apps-Repos) — lebt deshalb hier statt in einem einzelnen Umsetzungs-Repo.

## Language

### Rollen

**Infra-Admin**:
Person mit Root-SSH-Zugriff auf die VPS, eigenem Hetzner-API-Token, Zugriff auf GitHub-Org und gemeinsames KeePass — unabhängig von jeder Rolle innerhalb der Anwendung.
_Avoid_: Admin (allein, ohne Präfix — mehrdeutig)

**Admin** (Anwendungs-Rolle):
Entra-ID-Rollen-Claim, darf perspektivisch alle Fachdomänen exportieren/einsehen — Obermenge von Verwaltung. Unabhängig von Infra-Admin, keine Server-/GitHub-Berechtigung damit verbunden. Wo genau die Rollenzuweisung gepflegt wird, ist noch offen.
_Avoid_: Infra-Admin, Root

**Verwaltung**:
Entra-ID-Rollen-Claim für Schulsekretariats-Personal, darf Stammdaten aller Schüler exportieren — bewusst nicht automatisch auf künftige Fachdomänen erweitert, jede neue Fachdomäne bekommt bei Bedarf eine eigene Export-Berechtigung.
_Avoid_: Admin, Sekretariat

**Erziehungsberechtigte**:
Externe Nutzer ohne Entra-ID-Zugang (z. B. Eltern), Zugriff über einen OTP-Fallback-Pfad statt Login (`idea/04-identitaet-zugriff.md`) — sehen ausschließlich die Daten der eigenen zugeordneten Schüler.
_Avoid_: Eltern (enger als der rechtliche Personenkreis)

### Daten

**Fachdomäne**:
Ein fachlich abgegrenzter Datenbereich im Backend (z. B. Stammdaten, künftig z. B. Noten), eigener Router/eigenes Model-Modul (`wb-backend/CLAUDE.md` Abschnitt 3), eigene mögliche Export-Berechtigung.

**Stammdaten**:
Feste Grunddaten eines Schülers — Adresse, Telefon, E-Mail, Geburtsdatum. Eigene Löschfrist nach Abgang, separat von Log-/Backup-Retention.
