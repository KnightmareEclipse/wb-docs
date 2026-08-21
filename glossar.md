# Weltenbaum — Domänen-Glossar

Fachbegriffe für den DSGVO-konformen Datenbank-/API-Stack einer Schule (technische Umsetzung: `project-parts.md`, `idea/`). Gilt repo-übergreifend (`wb-backend`, künftige Frontend-/Teams-Apps-Repos) — lebt deshalb hier statt in einem einzelnen Umsetzungs-Repo.

## Language

### Rollen

Zwei Ebenen, nie nur eine: **welche** Rolle eine Anfrage bekommt, entscheidet die API anhand des Entra-Rollen-Claims; **welche Spalten** diese Rolle lesen und schreiben darf, entscheidet die DB-Rolle samt Spalten-GRANT (`schema/stammdaten-schema.sql`). Die Rollen hier sind fachlich benannt; welcher Claim und welche DB-Rolle sie tragen, steht in `wb-backend/db/init-roles.sh`, die Liste der anzulegenden DB-Rollen in `TODO.md`.

**Das sind alle Rollen — diese Liste ist vollständig.** Wer hier fehlt, bekommt keinen Zugang; eine neue Rolle entsteht nur zusammen mit der Domäne, die sie braucht.

| Rolle | Zugang | sieht welche Kinder |
|---|---|---|
| Infra-Admin | SSH/Konsole, keine App-Rolle | — (Betriebsebene, nicht Fachebene) |
| Admin | Entra | alle |
| Verwaltung (Sekretariat) | Entra | alle |
| Geschäftsführung | Entra | alle |
| Schulleitung | Entra | ihren Zweig |
| Hortleitung | Entra | die vom Hort betreuten |
| Hort | Entra | die vom Hort betreuten |
| Klassenlehrer:in | Entra | ihre Klasse |
| Lehrkraft | Entra | alle, aber nur Foto-Ja/Nein und den Handlungshinweis |
| Küche / Hausdienstverwaltung | Entra | alle, aber nur das Küchenprofil |
| Buchhaltung | Entra | alle |
| Erziehungsberechtigte | OTP | die eigenen |

**Keine Rolle im System haben** Vorstand und die übrigen Bereichsleitungen (KITA, Grundschule/Realschule fallen mit der Schulleitung zusammen) — sie sind nicht operativ am Prozess beteiligt (`fachdomaenen.md` Abschnitt 5); mit der Rechnungsfreigabe (Domäne 5) ist das neu zu prüfen. **Schüler** haben durchgängig keinen Zugang: Datenobjekt, nie Akteur.

**Infra-Admin**:
Person mit Root-SSH-Zugriff auf die VPS, eigenem Hetzner-API-Token, Zugriff auf GitHub-Org und gemeinsames KeePass — unabhängig von jeder Rolle innerhalb der Anwendung.
_Avoid_: Admin (allein, ohne Präfix — mehrdeutig)

**Admin** (Anwendungs-Rolle):
Entra-ID-Rollen-Claim, darf perspektivisch alle Fachdomänen exportieren/einsehen — Obermenge von Verwaltung. Unabhängig von Infra-Admin, keine Server-/GitHub-Berechtigung damit verbunden. Wo genau die Rollenzuweisung gepflegt wird, ist noch offen.
_Avoid_: Infra-Admin, Root

**Verwaltung** (= Sekretariat):
Entra-ID-Rollen-Claim für Schulsekretariats-Personal, darf Stammdaten aller Schüler exportieren — bewusst nicht automatisch auf künftige Fachdomänen erweitert, jede neue Fachdomäne bekommt bei Bedarf eine eigene Export-Berechtigung. Führt Bewerbung und Schulvertrag samt Vollständigkeitsprüfung (`schema/anmeldung-schema.sql`) und sieht den vollen Gesundheitssatz (`schema/gesundheit-schema.sql`).
**„Verwaltung" ist der Rollenname, „Sekretariat" die Stelle dahinter — dieselbe Rolle, ein GRANT.** Beide Wörter sind zulässig und stehen so in den Domänen-Dokumenten; im Ist-Ablauf (`prozesse.md`) ist „Sekretariat" ohnehin das richtige, weil es dort um die handelnde Stelle geht und nicht um eine Berechtigung.
_Avoid_: Admin

**Schulleitung**:
Je Schulzweig eine — und sieht ausschließlich ihren Zweig, nicht alle Schüler. Gibt den **Schulvertrag** frei und zeichnet ihn gegen, nachdem die Verwaltung ihn geprüft hat (`schema/anmeldung-schema.sql`); dafür braucht sie den Vertrag als Datei, bekommt ihn aber über Weltenbaum statt über die Bibliothek — sonst sähe sie beide Zweige (`grenzkarte.md`, Q2); darf zusammen mit der Geschäftsführung die Putzdienst-Strafe aussetzen und die Pflicht erlassen (`schema/putzdienst-schema.sql`). Der zweite Zugriff hängt an einem eigenen Spalten-GRANT, nicht am Rollen-Claim allein.
Für **Hortverträge nicht zuständig** — die laufen vollständig über den Hort (siehe Hortleitung).
_Avoid_: Admin

**Geschäftsführung**:
Operativer Kopf des Trägervereins (`fachdomaenen.md` Abschnitt 5). Sieht wie Verwaltung und Buchhaltung **alle** Schüler — diese drei brauchen den Gesamtüberblick, alle übrigen Rollen sehen nur einen Teil der Schüler oder einen Teil der Daten. Drei eigene Zugriffe: Straf-Aussetzung und Pflicht-Erlass beim Putzdienst (gemeinsam mit der Schulleitung), direkter Zugriff auf die Dateibibliotheken (`grenzkarte.md`, Q2) und als Einzige das Hochladen der Vertragsvorlagen (`schema/anmeldung-schema.sql`) — sie verantwortet die Verwaltung und besonders die Verträge.

**Klassenlehrer:in**:
Die Lehrkraft, auf die `classes.class_teacher_id` ihrer Klasse zeigt. Sieht den vollen Gesundheitssatz der Kinder dieser Klasse und formuliert daraus den handlungsrelevanten Hinweis, den alle unterrichtenden Personen sehen (`schema/gesundheit-schema.sql`).
_Avoid_: Lehrkraft (weiter gefasst, siehe unten)

**Lehrkraft** (unterrichtende Person):
Jede unterrichtende Person. Sieht von den Gesundheitsdaten ausschließlich den handlungsrelevanten Hinweis, nie Diagnose oder vollständige Anweisung, und schlägt das Fotoeinverständnis nach (`grenzkarte.md`, Q1). Eine Zuordnung Lehrkraft↔Unterricht gibt es nicht — die lebt in Untis und bleibt draußen.

**Hort**:
Hortpersonal. Sieht den vollen Gesundheitssatz der betreuten Kinder (`schema/gesundheit-schema.sql`) und führt Hortvertrag samt Betreuungsmodulen (`schema/anmeldung-schema.sql`) — auch für Kinder, die weder Grund- noch Realschüler sind. Prüft den Hortvertrag auf Vollständigkeit; freigeben darf ihn die Hortleitung.

**Hortleitung**:
Bereichsleitung Hort (`fachdomaenen.md` Abschnitt 5). Alles wie Hort, dazu die **Freigabe und Gegenzeichnung des Hortvertrags** — das Gegenstück der Schulleitung auf der Hortseite, und wie dort die Zweitprüfung: geprüft hat der Hort, wirksam macht ihn die Leitung (`schema/anmeldung-schema.sql`). Sie braucht denselben Ausgabe-Endpunkt wie die Schulleitung, um den Vertrag vor der Freigabe zu lesen, ohne Zugriff auf die Dateibibliothek zu bekommen (`grenzkarte.md`, Q2).

**Küche / Hausdienstverwaltung**:
Liest Küchenprofil und Essens-Tagesliste (`schema/mensa-schema.sql`), nie den Art.-9-Bestand der Gesundheitsdomäne. Führt daneben die Kochwerkstatt-Liste (`fachdomaenen.md` Abschnitt 3).

**Buchhaltung**:
Bestätigt Zahlungen, die nicht über Stripe hereinkommen (Überweisung, Bargeld — `schema/putzdienst-schema.sql`), und zieht Forderungen in Optigem. In Weltenbaum entsteht keine Buchhaltung (`grenzkarte.md`, Q3).
**Sieht dafür alle Kinder samt Familienzugehörigkeit** — die dritte Rolle mit vollem Überblick neben Verwaltung und Geschäftsführung. Grund ist die **Höhe des Schulgelds**: sie hängt daran, welche Kinder zu derselben Familie gehören (Geschwister zählen je Familie, nicht je Kind). Gerechnet und abgerechnet wird das in Optigem, aber die einzige gepflegte Wahrheit darüber, wer eine Familie ist, steht in Weltenbaum (`schema/stammdaten-schema.sql`) — deshalb liest sie sie dort und nicht aus einer zweiten Liste. Dieselbe Rolle stellt die Frage „welche Kinder zahlt diese Partei" vor dem Optigem-Übertrag (`sepa_mandates.account_holder_person_id`).
**Sie hält als Einzige die Bankverbindung** (`sepa_mandates.iban`/`bic`) — eigene, engere DB-Rolle mit Spalten-GRANT wie bei den Art.-9-Spalten, nicht Teil der pauschalen Laufzeit-Rolle (`schema/stammdaten-schema.sql`; `TODO.md`). Sie ist der benannte Abnehmer dieser Spalten: die Bankverbindung wandert einmal von Hand nach Optigem, sobald die Verträge samt Mandat vorliegen (`fachdomaenen.md` Abschnitt 3). Die Mandatsreferenz daneben (`sepa_mandates.mandate_reference`) braucht keinen eigenen GRANT — das Mandat hängt am Kind, und die Kinder sieht sie ohnehin.

**Erziehungsberechtigte**:
Externe Nutzer ohne Entra-ID-Zugang (z. B. Eltern), Zugriff über einen OTP-Fallback-Pfad statt Login (`idea/04-identitaet-zugriff.md`) — sehen ausschließlich die Daten der eigenen zugeordneten Schüler. Immer natürliche Personen, nie eine Institution (`schema/stammdaten-schema.sql`).
_Avoid_: Eltern (enger als der rechtliche Personenkreis)

### Daten

**Fachdomäne**:
Ein fachlich abgegrenzter Datenbereich im Backend (z. B. Stammdaten, künftig z. B. Noten), eigener Router/eigenes Model-Modul (`wb-backend/CLAUDE.md` Abschnitt 3), eigene mögliche Export-Berechtigung.

**Stammdaten**:
Feste Grunddaten einer Person in einer ihrer fünf Rollen (Schüler, Erziehungsberechtigte, Kontaktperson, Zahlungsverantwortliche, Mitarbeiter). Gemeinsam für alle Rollen an `persons`: Anrede, Name, Geschlecht, Anschrift, Telefonnummern, E-Mail. Alles Rollenspezifische steht an der jeweiligen Rollentabelle und ist für die übrigen Rollen strukturell gar nicht befüllbar. Felder, Begründungen, Sonderfälle und Zugriffsschutz: `schema/stammdaten-schema.sql`.

**Familie**:
Die Menge Erwachsener, die gemeinsam sorgeberechtigt für ein oder mehrere Kinder sind — **nicht** wer zusammenwohnt. Vom Sekretariat manuell gepflegt, nie algorithmisch hergeleitet. Grundlage des Ownership-Checks: wer Mitglied ist, sieht die Kinder dieser Familie (`idea/04-identitaet-zugriff.md`). Modell und Sonderfälle: `schema/stammdaten-schema.sql`.
_Avoid_: Haushalt
