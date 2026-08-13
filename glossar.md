# Weltenbaum — Domänen-Glossar

Fachbegriffe für den DSGVO-konformen Datenbank-/API-Stack einer Schule (technische Umsetzung: `project-parts.md`, `idea/`). Gilt repo-übergreifend (`wb-backend`, künftige Frontend-/Teams-Apps-Repos) — lebt deshalb hier statt in einem einzelnen Umsetzungs-Repo.

## Language

### Rollen

Zwei Ebenen, nie nur eine: **welche** Rolle eine Anfrage bekommt, entscheidet die API anhand des Entra-Rollen-Claims; **welche Spalten** diese Rolle lesen und schreiben darf, entscheidet die DB-Rolle samt Spalten-GRANT (`domains/stammdaten.md`, „Datensichtbarkeit"). Die Rollen hier sind fachlich benannt; welcher Claim und welche DB-Rolle sie tragen, steht in `wb-backend/db/init-roles.sh`, die Liste der anzulegenden DB-Rollen in `TODO.md`.

**Infra-Admin**:
Person mit Root-SSH-Zugriff auf die VPS, eigenem Hetzner-API-Token, Zugriff auf GitHub-Org und gemeinsames KeePass — unabhängig von jeder Rolle innerhalb der Anwendung.
_Avoid_: Admin (allein, ohne Präfix — mehrdeutig)

**Admin** (Anwendungs-Rolle):
Entra-ID-Rollen-Claim, darf perspektivisch alle Fachdomänen exportieren/einsehen — Obermenge von Verwaltung. Unabhängig von Infra-Admin, keine Server-/GitHub-Berechtigung damit verbunden. Wo genau die Rollenzuweisung gepflegt wird, ist noch offen.
_Avoid_: Infra-Admin, Root

**Verwaltung**:
Entra-ID-Rollen-Claim für Schulsekretariats-Personal, darf Stammdaten aller Schüler exportieren — bewusst nicht automatisch auf künftige Fachdomänen erweitert, jede neue Fachdomäne bekommt bei Bedarf eine eigene Export-Berechtigung. Führt Bewerbung und Vertragsvorgang (`domains/anmeldung.md`) und sieht den vollen Gesundheitssatz (`domains/gesundheit.md`).
_Avoid_: Admin, Sekretariat

**Schulleitung**:
Je Schulzweig eine — und sieht ausschließlich ihren Zweig, nicht alle Schüler. Prüft den Vertrag nach der Verwaltung, gibt ihn frei und zeichnet gegen (`domains/anmeldung.md`); dafür braucht sie den Vertrag als Datei, bekommt ihn aber über Weltenbaum statt über die Bibliothek — sonst sähe sie beide Zweige (`domains/grenzkarte.md`, Q2); darf zusammen mit der Geschäftsführung die Putzdienst-Strafe aussetzen und die Pflicht erlassen (`domains/putzdienst.md`). Der zweite Zugriff hängt an einem eigenen Spalten-GRANT, nicht am Rollen-Claim allein.
_Avoid_: Admin

**Geschäftsführung**:
Operativer Kopf des Trägervereins (`fachdomaenen.md` Abschnitt 5). Sieht wie die Verwaltung **alle** Schüler — beide brauchen den Gesamtüberblick, alle übrigen Rollen sehen nur einen Teil der Schüler oder einen Teil der Daten. Drei eigene Zugriffe: Straf-Aussetzung und Pflicht-Erlass beim Putzdienst (gemeinsam mit der Schulleitung), direkter Zugriff auf die Dateibibliotheken (`domains/grenzkarte.md`, Q2) und als Einzige das Hochladen der Vertragsvorlagen (`domains/anmeldung.md`) — sie verantwortet die Verwaltung und besonders die Verträge.

**Klassenlehrer:in**:
Die Lehrkraft, auf die `classes.class_teacher_id` ihrer Klasse zeigt. Sieht den vollen Gesundheitssatz der Kinder dieser Klasse und formuliert daraus den handlungsrelevanten Hinweis, den alle unterrichtenden Personen sehen (`domains/gesundheit.md`).
_Avoid_: Lehrkraft (weiter gefasst, siehe unten)

**Lehrkraft** (unterrichtende Person):
Jede unterrichtende Person. Sieht von den Gesundheitsdaten ausschließlich den handlungsrelevanten Hinweis, nie Diagnose oder vollständige Anweisung, und schlägt das Fotoeinverständnis nach (`domains/grenzkarte.md`, Q1). Eine Zuordnung Lehrkraft↔Unterricht gibt es nicht — die lebt in Untis und bleibt draußen.

**Hort**:
Hortpersonal. Sieht den vollen Gesundheitssatz der betreuten Kinder (`domains/gesundheit.md`) und führt Hortvertrag samt Betreuungsmodulen (`domains/anmeldung.md`) — auch für Kinder, die weder Grund- noch Realschüler sind.

**Küche / Hausdienstverwaltung**:
Liest Küchenprofil und Essens-Tagesliste (`domains/mensa.md`), nie den Art.-9-Bestand der Gesundheitsdomäne. Führt daneben die Kochwerkstatt-Liste (`fachdomaenen.md` Abschnitt 3).

**Buchhaltung**:
Bestätigt Zahlungen, die nicht über Stripe hereinkommen (Überweisung, Bargeld — `domains/putzdienst.md`), und zieht Forderungen in Optigem. In Weltenbaum entsteht keine Buchhaltung (`domains/grenzkarte.md`, Q3).

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
