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
Externe Nutzer ohne Entra-ID-Zugang (z. B. Eltern), Zugriff über einen OTP-Fallback-Pfad statt Login (`idea/04-identitaet-zugriff.md`) — sehen ausschließlich die Daten der eigenen zugeordneten Schüler. Immer natürliche Personen — auch eine Amtsvormundin des Jugendamts, die als Person auftritt und deshalb denselben Zugangsweg hat (`domains/stammdaten.md`).
_Avoid_: Eltern (enger als der rechtliche Personenkreis)

### Daten

**Fachdomäne**:
Ein fachlich abgegrenzter Datenbereich im Backend (z. B. Stammdaten, künftig z. B. Noten), eigener Router/eigenes Model-Modul (`wb-backend/CLAUDE.md` Abschnitt 3), eigene mögliche Export-Berechtigung.

**Stammdaten**:
Feste Grunddaten einer Person (Schüler, Erziehungsberechtigte, Kontaktperson, Zahlungsverantwortliche) — für jede Rolle Anrede, akademischer Grad, Name, Geschlecht, Anschrift, Telefonnummern, E-Mail. Rollenspezifisch und für die übrigen Rollen strukturell gar nicht befüllbar: Geburtsdatum, Demografie, Rufname, Klasse und Anmelde-/Ein-/Abgangsdatum nur beim Schüler, Beruf nur beim Erziehungsberechtigten, Bankverbindung nur beim Zahlungsverantwortlichen, Dienstadresse und Beschäftigungszeitraum nur beim Mitarbeiter (eigene Rolle `employees`; die Dienstadresse liegt bewusst dort und nicht als persönliche E-Mail, die zugleich OTP-Identität ist). Konfession/Kirchengemeinde stehen nur beim Schüler und sind **Art.-9-DSGVO-Daten** — sie hängen wie die Bankverbindung an einer eigenen, engeren DB-Rolle, nicht an der allgemeinen Laufzeit-Rolle. Erziehungsberechtigte und Zahlende sind immer natürliche Personen; eine Amts- oder Vereinsvormundschaft läuft über die handelnde Sachbearbeiterin, für welche Institution sie handelt steht an der Familienzugehörigkeit. Die E-Mail eines Erziehungsberechtigten ist zugleich die Identifikation beim OTP-Login. Sie ist bewusst nicht eindeutig: zwei Erziehungsberechtigte dürfen sich eine Mailbox teilen, ein OTP-Treffer kann deshalb mehrere Personen ergeben. Nach Abgang gelten zwei Fristen: gesetzliche Mindestaufbewahrung, dann Löschung — beide getrennt von Log-/Backup-Retention. Details: `domains/stammdaten.md`.

**Familie**:
Die Menge Erwachsener, die gemeinsam sorgeberechtigt für ein oder mehrere Kinder sind — **nicht** wer zusammenwohnt. Vom Sekretariat manuell gepflegt, nie algorithmisch hergeleitet. Grundlage des Ownership-Checks: wer Mitglied ist, sieht die Kinder dieser Familie (`idea/04-identitaet-zugriff.md`). Eine Person kann mehreren Familien angehören (Patchwork).
_Avoid_: Haushalt
