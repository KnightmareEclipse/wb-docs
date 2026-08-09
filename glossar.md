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
Externe Nutzer ohne Entra-ID-Zugang (z. B. Eltern), Zugriff über einen OTP-Fallback-Pfad statt Login (`idea/04-identitaet-zugriff.md`) — sehen ausschließlich die Daten der eigenen zugeordneten Schüler. Immer natürliche Personen, nie eine Institution (`domains/stammdaten.md`, „Familie").
_Avoid_: Eltern (enger als der rechtliche Personenkreis)

### Daten

**Fachdomäne**:
Ein fachlich abgegrenzter Datenbereich im Backend (z. B. Stammdaten, künftig z. B. Noten), eigener Router/eigenes Model-Modul (`wb-backend/CLAUDE.md` Abschnitt 3), eigene mögliche Export-Berechtigung.

**Stammdaten**:
Feste Grunddaten einer Person in einer ihrer fünf Rollen (Schüler, Erziehungsberechtigte, Kontaktperson, Zahlungsverantwortliche, Mitarbeiter). Gemeinsam für alle Rollen an `persons`: Anrede, Name, Geschlecht, Anschrift, Telefonnummern, E-Mail. Alles Rollenspezifische steht an der jeweiligen Rollentabelle und ist für die übrigen Rollen strukturell gar nicht befüllbar. Felder, Begründungen, Sonderfälle und Zugriffsschutz: `domains/stammdaten.md`.

**Familie**:
Die Menge Erwachsener, die gemeinsam sorgeberechtigt für ein oder mehrere Kinder sind — **nicht** wer zusammenwohnt. Vom Sekretariat manuell gepflegt, nie algorithmisch hergeleitet. Grundlage des Ownership-Checks: wer Mitglied ist, sieht die Kinder dieser Familie (`idea/04-identitaet-zugriff.md`). Modell und Sonderfälle: `domains/stammdaten.md`, „Familie".
_Avoid_: Haushalt
