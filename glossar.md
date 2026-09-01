# Weltenbaum — Domänen-Glossar

Fachbegriffe für den DSGVO-konformen Datenbank-/API-Stack einer Schule (technische Umsetzung: `container.md`, `zugang.md`). Gilt repo-übergreifend (`wb-backend`, künftige Frontend-/Teams-Apps-Repos) — lebt deshalb hier statt in einem einzelnen Umsetzungs-Repo.

## Language

### Rollen

Zwei Ebenen, nie nur eine: **welche** Rolle eine Anfrage bekommt, liest die API aus `employee_roles` — vergeben wird sie in Weltenbaum, nicht im Tenant (`zugang.md`); **welche Spalten** diese Rolle lesen und schreiben darf, entscheidet die DB-Rolle samt Spalten-GRANT (`schema/stammdaten-schema.sql`). Die Rollen hier sind fachlich benannt; ihr `code` steht als Zeile in `roles`, die DB-Rollen in `wb-backend/db/init-roles.sh`.

**Die `code`-Spalte ist die Gegenprobe, nicht die Behauptung:** Sie trägt genau die sechzehn Zeilen, die `roles` beim ersten Import bekommt (`wb-backend`, „value list seed"). Wer hier fehlt, bekommt keinen Zugang; eine neue Rolle entsteht nur zusammen mit der Domäne, die sie braucht — und wer eine erfindet, hinterlässt einen Code, den der Seed nicht kennt.

**Drei Zeilen tragen keinen Code, und deshalb listet diese Tabelle nicht nur Rollen:** Infra-Admin ist Betriebsebene und in der Anwendung gar nicht vorhanden, **Klassenlehrer:in** ist ein Ownership-Check über `classes.class_teacher_id` und keine Rolle (`api/klassenbildung-api.md`), und **Erziehungsberechtigte** ist aus der Sorgeberechtigung abgeleitet und wird nie vergeben (`soll-prozesse/hebel.md`). Alle drei kommen trotzdem herein, deshalb stehen sie hier.

| Rolle | `roles.code` | Zugang | sieht welche Kinder |
|---|---|---|---|
| Infra-Admin | — | SSH/Konsole, keine App-Rolle | — (Betriebsebene, nicht Fachebene) |
| Admin | `admin` | Entra | alle |
| Verwaltung (Sekretariat) | `secretariat` | Entra | alle |
| Geschäftsführung | `executive_management` | Entra | alle |
| Buchhaltung | `accounting` | Entra | alle |
| Schulleitung | `school_management` | Entra | ihren Zweig |
| Hortleitung | `day_care_management` | Entra | die vom Hort betreuten |
| Hort | `day_care_staff` | Entra | die vom Hort betreuten |
| Klassenlehrer:in | — | Entra | ihre Klasse |
| Lehrkraft | `teacher` | Entra | alle, aber nur Foto-Ja/Nein und den Handlungshinweis |
| Mensa | `canteen` | Entra | alle, aber nur das Küchenprofil |
| Hauswirtschaftsleitung | `domestic_services_management` | Entra | das Küchenprofil, dazu die Teilnehmer ihrer Akademie-Angebote |
| Personalverwaltung | `personnel` | Entra | — (führt Mitarbeitende, keine Kinder) |
| Führungskraft | `approver` | Entra | — (kennt keine Kinder) |
| Hausmeister | `caretaker` | Entra | — (bestätigt Mitarbeitsstunden) |
| Mitarbeitende | `staff` | Entra | — |
| KITA-Mitarbeitende | `kita_staff` | Entra | — |
| KITA-Leitung | `kita_management` | Entra | — |
| Erziehungsberechtigte | — | OTP | die eigenen |

**Jede Bereichsleitung hat inzwischen ihre Rolle** — Hort, Hauswirtschaft und KITA je eine, Grundschule und Realschule fallen mit der Schulleitung zusammen. **Keine hat der Vorstand**: Er ist nicht operativ am Prozess beteiligt (`fachdomaenen.md` Abschnitt 5). Ob er eine bekommt, hängt an genau einer Frage — ob er Belege freigibt —, und die entscheidet die Geschäftsführung mit der Rollenvergabe, nicht diese Datei. **Schüler** haben durchgängig keinen Zugang: Datenobjekt, nie Akteur.

**Infra-Admin**:
Person mit Root-SSH-Zugriff auf die VPS, eigenem Hetzner-API-Token, Zugriff auf GitHub-Org und gemeinsames KeePass — unabhängig von jeder Rolle innerhalb der Anwendung.
_Avoid_: Admin (allein, ohne Präfix — mehrdeutig)

**Admin** (Anwendungs-Rolle):
Rolle in Weltenbaum (`roles.code = 'admin'`), darf perspektivisch alle Fachdomänen exportieren/einsehen — Obermenge von Verwaltung. Unabhängig von Infra-Admin, keine Server-/GitHub-Berechtigung damit verbunden. Vergeben wird sie von Admins und Geschäftsführung im Portal (`soll-prozesse/hebel.md`).
_Avoid_: Infra-Admin, Root

**Verwaltung** (= Sekretariat):
Rolle in Weltenbaum (`roles.code = 'secretariat'`) für Schulsekretariats-Personal, darf Stammdaten aller Schüler exportieren — bewusst nicht automatisch auf künftige Fachdomänen erweitert, jede neue Fachdomäne bekommt bei Bedarf eine eigene Export-Berechtigung. Führt Bewerbung und Schulvertrag samt Vollständigkeitsprüfung (`schema/anmeldung-schema.sql`) und sieht den vollen Gesundheitssatz (`schema/gesundheit-schema.sql`).
**„Verwaltung" ist der Rollenname, „Sekretariat" die Stelle dahinter — dieselbe Rolle, ein GRANT.** Beide Wörter sind zulässig und stehen so in den Domänen-Dokumenten; im Ist-Ablauf (`prozesse.md`) ist „Sekretariat" ohnehin das richtige, weil es dort um die handelnde Stelle geht und nicht um eine Berechtigung.
_Avoid_: Admin

**Schulleitung**:
Je Schulzweig eine — und sieht ausschließlich ihren Zweig, nicht alle Schüler. Gibt den **Schulvertrag** frei und zeichnet ihn gegen, nachdem die Verwaltung ihn geprüft hat (`schema/anmeldung-schema.sql`); dafür braucht sie den Vertrag als Datei, bekommt ihn aber über Weltenbaum statt über die Bibliothek — sonst sähe sie beide Zweige (`grenzkarte.md`, Q2); darf zusammen mit der Geschäftsführung die Putzdienst-Strafe aussetzen und die Pflicht erlassen (`schema/putzdienst-schema.sql`). Der zweite Zugriff hängt an einem eigenen Spalten-GRANT, nicht an der Rolle allein.
Für **Hortverträge nicht zuständig** — die laufen vollständig über den Hort (siehe Hortleitung).
_Avoid_: Admin

**Geschäftsführung**:
Operativer Kopf des Trägervereins (`fachdomaenen.md` Abschnitt 5). Sieht wie Verwaltung und Buchhaltung **alle** Schüler — diese drei brauchen den Gesamtüberblick, alle übrigen Rollen sehen nur einen Teil der Schüler oder einen Teil der Daten. Drei eigene Zugriffe: Straf-Aussetzung und Pflicht-Erlass beim Putzdienst (gemeinsam mit der Schulleitung), direkter Zugriff auf die Dateibibliotheken (`grenzkarte.md`, Q2) und als Einzige das Hochladen der Vertragsvorlagen (`contract_texts`, `schema/querschnitt-schema.sql`) — sie verantwortet die Verwaltung und besonders die Verträge.

**Klassenlehrer:in**:
Die Lehrkraft, auf die `classes.class_teacher_id` ihrer Klasse zeigt. Sieht den vollen Gesundheitssatz der Kinder dieser Klasse und formuliert daraus den handlungsrelevanten Hinweis, den alle unterrichtenden Personen sehen (`schema/gesundheit-schema.sql`).
_Avoid_: Lehrkraft (weiter gefasst, siehe unten)

**Lehrkraft** (unterrichtende Person):
Jede unterrichtende Person. Sieht von den Gesundheitsdaten ausschließlich den handlungsrelevanten Hinweis, nie Diagnose oder vollständige Anweisung, und schlägt das Fotoeinverständnis nach (`grenzkarte.md`, Q1). Eine Zuordnung Lehrkraft↔Unterricht gibt es nicht — die lebt in Untis und bleibt draußen.

**Hort**:
Hortpersonal. Sieht den vollen Gesundheitssatz der betreuten Kinder (`schema/gesundheit-schema.sql`) und führt Hortvertrag samt Betreuungsmodulen (`schema/anmeldung-schema.sql`) — auch für Kinder, die weder Grund- noch Realschüler sind. Prüft den Hortvertrag auf Vollständigkeit; freigeben darf ihn die Hortleitung. **Die einzige Rolle mit einer eigenen Dateibibliothek**: der Hortakte, die niemand sonst sieht — auch das Sekretariat nicht (`grenzkarte.md`, Q2; `soll-prozesse/09-hortvertrag.md`).

**Hortleitung**:
Bereichsleitung Hort (`fachdomaenen.md` Abschnitt 5). Alles wie Hort, dazu die **Freigabe und Gegenzeichnung des Hortvertrags** — das Gegenstück der Schulleitung auf der Hortseite, und wie dort die Zweitprüfung: geprüft hat der Hort, wirksam macht ihn die Leitung (`schema/anmeldung-schema.sql`). Sie braucht denselben Ausgabe-Endpunkt wie die Schulleitung, um den Vertrag vor der Freigabe zu lesen, ohne Zugriff auf die Bibliothek der **Schülerakte** zu bekommen; die **Hortakte** dagegen ist ihre eigene (`grenzkarte.md`, Q2).

**Mensa**:
Küchenpersonal (`roles.code = 'canteen'`). Liest Küchenprofil, Essens-Tagesliste und Wochenübersicht für den Einkauf (`api/mensa-api.md`), **nie den Art.-9-Bestand der Gesundheitsdomäne**: Was sie von einer Unverträglichkeit sieht, kommt aus `kitchen_health_traits`, und mehr gibt ihre DB-Rolle `backend_kitchen` nicht frei.
_Avoid_: Küche (mehrdeutig — die Hauswirtschaftsleitung liest denselben Ausschnitt)

**Hauswirtschaftsleitung**:
Bereichsleitung (`roles.code = 'domestic_services_management'`). Alles wie die Mensa, dazu ihre **Angebote in der Akademie** — die Kochwerkstatt voran: Sie legt sie an und liest ihre Teilnehmerliste samt dem Küchen-Ausschnitt der Gesundheitsangaben (`soll-prozesse/21-akademie.md`) — dass sie es darf, steht als anbietende Rolle am Angebot und nicht als Regel im Code.
**Im Ist-Ablauf heißt dieselbe Stelle „Hausdienstverwaltung“** (`prozesse.md`, `fachdomaenen.md`) — dasselbe Verhältnis wie zwischen Verwaltung und Sekretariat: hier die Berechtigung, dort die handelnde Stelle.

**Personalverwaltung**:
Trägt Ein- und Austritt der Mitarbeitenden ein (`roles.code = 'personnel'`), **für beide Häuser, Schule wie KITA** — ein Bestand, ein Ablauf, und der Preis ist benannt: Die Schule führt die Personalangaben der KITA mit (`soll-prozesse/13-m365-konten.md`). Die Rolle heißt so, führt aber **sechs Angaben und keine siebte** — kein Vertrag, kein Stundenumfang, kein Gehalt. **Rollen vergibt sie nicht**, das bleiben Admins und Geschäftsführung, und die **Schuladresse** ändert allein der Admin. Sie sieht kein Kind.
_Avoid_: Personalabteilung (es gibt keine)

**Führungskraft**:
Rolle in Weltenbaum (`roles.code = 'approver'`) für die Rechnungsfreigabe, und nur für sie: Sie sieht kein Kind, keine Familie und keine Klasse. Der Einreicher **wählt** sie an seinem Beleg — sie entscheidet danach über genau diesen Beleg, nicht über eine Menge, und der Zugriff hängt deshalb an der Zeile und nicht an der Rolle (`api/rechnungsfreigabe-api.md`). Freigeben, ablehnen, korrigieren, weiterleiten, aufteilen. Welche Bereichsleitung sie trägt, **steht nirgends geschrieben und ändert sich**: Die Geschäftsführung vergibt sie wie jede andere Mitarbeiterrolle (`soll-prozesse/hebel.md`), und eine Zuordnung Projekt↔Führungskraft gibt es bewusst nicht — „das Haus ist klein genug, dass jeder weiß, wen er wählt" (`soll-prozesse/12-rechnungsfreigabe.md`). Die **Geschäftsführung ist hier immer auch Führungskraft**, ohne die Rolle zu tragen, und fängt jeden Ausfall auf.
_Avoid_: Manager (der Name im heutigen Beleg-Portal), Vorgesetzte:r (es gibt keine Hierarchie im System)

**Buchhaltung**:
Bestätigt Zahlungen, die nicht über Stripe hereinkommen (Überweisung, Bargeld — `schema/putzdienst-schema.sql`), und zieht Forderungen in Optigem. In Weltenbaum entsteht keine Buchhaltung (`grenzkarte.md`, Q3).
**Sieht dafür alle Kinder samt Familienzugehörigkeit** — die dritte Rolle mit vollem Überblick neben Verwaltung und Geschäftsführung. Grund ist die **Höhe des Schulgelds**: sie hängt daran, welche Kinder zu derselben Familie gehören (Geschwister zählen je Familie, nicht je Kind). Gerechnet und abgerechnet wird das in Optigem, aber die einzige gepflegte Wahrheit darüber, wer eine Familie ist, steht in Weltenbaum (`schema/stammdaten-schema.sql`) — deshalb liest sie sie dort und nicht aus einer zweiten Liste. Dieselbe Rolle stellt die Frage „welche Kinder zahlt diese Partei" vor dem Optigem-Übertrag (`sepa_mandates.account_holder_person_id`).
**Sie hält als Einzige die Bankverbindung** (`sepa_mandates.iban`/`bic`) — eigene, engere DB-Rolle mit Spalten-GRANT wie bei den Art.-9-Spalten, nicht Teil der pauschalen Laufzeit-Rolle (`schema/stammdaten-schema.sql`; `backlog/`). Sie ist der benannte Abnehmer dieser Spalten: die Bankverbindung wandert einmal von Hand nach Optigem, sobald die Verträge samt Mandat vorliegen (`fachdomaenen.md` Abschnitt 3). Die Mandatsreferenz daneben (`sepa_mandates.mandate_reference`) braucht keinen eigenen GRANT — das Mandat hängt am Kind, und die Kinder sieht sie ohnehin.

**Hausmeister**:
Rolle in Weltenbaum (`roles.code = 'caretaker'`) mit heute genau einem Anlass: Er **schreibt Einsätze der Elternmitarbeit aus** und sieht, wer sich angemeldet hat (`soll-prozesse/00-zugang-und-portal.md`). Ausschreiben dürfen das **sechs Rollen**, nicht nur er — Lehrkraft, Sekretariat, Schulleitung, Hauswirtschafts- und Hortleitung ebenso (`soll-prozesse/14-elternbonus.md`); diese Rolle steht deshalb nicht für ein Recht, sondern für den, dessen einziger Anlass sie ist. **Bestätigt wird eine Stunde nicht mehr** (`soll-prozesse/14-elternbonus.md`). **Die Putzdienstleitung ist er ausdrücklich nicht**: Das ist eine eigene Person, und sie hat keine Rolle im System (`soll-prozesse/01-putzdienst.md`).

**Mitarbeitende**:
Die schlichte Rolle (`roles.code = 'staff'`) für jeden, der nichts Spezielleres trägt. Sie ist **keine Rolle zweiter Klasse**: Ohne sie käme eine Integrationskraft oder ein FSJler gar nicht ins Portal, obwohl auch er einen Beleg einzureichen hat (`api/rechnungsfreigabe-api.md`) — und sie **zählt aus demselben Grund voll**, wo Mitarbeiterfamilien ausgenommen werden, beim Putzdienst wie beim Elternbonus (`soll-prozesse/hebel.md`). Wer sie trägt, arbeitet an der Schule. Sie sieht kein Kind.

**KITA-Mitarbeitende** und **KITA-Leitung**:
Die beiden Rollen des zweiten Betriebs im selben Haus (`kita_staff`, `kita_management`). Sie sehen **kein Kind der Schule** und handeln in **genau einem** Prozess: der Rechnungsfreigabe — sie reichen Belege ein, gebucht wird auf ihr eigenes Projekt, und dieselbe Buchhaltung schließt ab (`soll-prozesse/12-rechnungsfreigabe.md`). Die **KITA-Leitung ist die Führungskraft ihres Hauses, weil man sie wählt** und nicht weil eine Regel es erzwingt; sie trägt dafür zusätzlich `approver`. In der Kontenverwaltung kommt die KITA vor, **ohne etwas zu tun** (`soll-prozesse/13-m365-konten.md`), und beim Elternbonus fallen beide Rollen aus der Auswahl der bestätigenden Person heraus (`api/elternbonus-api.md`).

**Erziehungsberechtigte**:
Externe Nutzer ohne Entra-ID-Zugang (z. B. Eltern), Zugriff über einen OTP-Fallback-Pfad statt Login (`zugang.md`) — sehen ausschließlich die Daten der eigenen zugeordneten Schüler. Immer natürliche Personen, nie eine Institution (`schema/stammdaten-schema.sql`).
_Avoid_: Eltern (enger als der rechtliche Personenkreis)

### Daten

**Fachdomäne**:
Ein fachlich abgegrenzter Datenbereich im Backend (z. B. Stammdaten, künftig z. B. Noten), eigener Router/eigenes Model-Modul (`wb-backend/CLAUDE.md` Abschnitt 3), eigene mögliche Export-Berechtigung.

**Stammdaten**:
Feste Grunddaten einer Person in einer ihrer vier Rollen (Schüler, Erziehungsberechtigte, Kontaktperson, Mitarbeiter). Gemeinsam für alle Rollen an `persons`: Anrede, Name, Geschlecht, Anschrift, Telefonnummern, E-Mail. Alles Rollenspezifische steht an der jeweiligen Rollentabelle und ist für die übrigen Rollen strukturell gar nicht befüllbar. Felder, Begründungen, Sonderfälle und Zugriffsschutz: `schema/stammdaten-schema.sql`.

**Familie**:
Die Menge Erwachsener, die gemeinsam sorgeberechtigt für ein oder mehrere Kinder sind — **nicht** wer zusammenwohnt. Vom Sekretariat manuell gepflegt, nie algorithmisch hergeleitet. Grundlage des Ownership-Checks: wer Mitglied ist, sieht die Kinder dieser Familie (`zugang.md`). Modell und Sonderfälle: `schema/stammdaten-schema.sql`.
_Avoid_: Haushalt
