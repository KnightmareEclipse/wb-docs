# Verarbeitungsverzeichnis — Weltenbaum (Art. 30 Abs. 1)

Der Eintrag für **dieses eine Verfahren**, nicht das Verzeichnis der Schule: Er wird dort
eingehängt, wo die übrigen Verfahren stehen (ASV-BW, Optigem, M365). Was ein Mensch darüber hinaus
veranlassen muss, steht in `dsgvo.md`; die technische Grundlage je Punkt in `container.md`,
`backup.md`, `zugang.md` und im jeweiligen `schema/*.sql`. Die **Folgenabschätzung nach Art. 35**
zum Art.-9-Bestand steht in `folgenabschaetzung.md`: Sie bewertet, was hier beschrieben ist, und
wiederholt es nicht — und sie sperrt den Livegang der fünf Vorgänge, die Gesundheitsangaben
erheben.

Zwei Sorten Lücke sind ausgeschrieben statt geraten: **`[?]`** liefert die Schule, **`[A]`** ist eine
Annahme, die die Datenschutzbeauftragte im Termin nach `fragen.md` bestätigt oder verwirft.

## a) Verantwortlicher und Datenschutzbeauftragte:r

| | |
|---|---|
| Verantwortlicher | `[?]` Träger in seiner Vereinsform samt Registernummer |
| Anschrift | `[?]` |
| Vertretungsberechtigte | `[?]` benannte Personen, keine Rolle |
| Datenschutzbeauftragte:r | `[?]` Name und Kontakt |
| Bezeichnung des Verfahrens | Weltenbaum — Verwaltungsdatenbank der Schule |
| Betreiber der Technik | derselbe Verantwortliche; die VPS ist angemietet, nicht ausgelagert (`host.md`) |

Dieselben vier Angaben trägt die Datenschutzerklärung des Elternportals — sie werden **einmal**
erhoben und dort wie hier eingesetzt.

## b) Zwecke und Rechtsgrundlagen

Je Fachdomäne ein Zweck; die Reihenfolge ist die aus `fachdomaenen.md` Abschnitt 6, gebaut ist, was
in `schema/` liegt.

| Domäne | Zweck | Rechtsgrundlage |
|---|---|---|
| Stammdaten | Kind, Familie und Erziehungsberechtigte als gemeinsame Grundlage aller Vorgänge | `[A]` Art. 6 Abs. 1 lit. b — Anbahnung und Durchführung des Schul- bzw. Betreuungsvertrags |
| Putzdienst | Zuteilung, Tausch, Freikauf und Abrechnung der Elternarbeitsstunden | `[A]` Art. 6 Abs. 1 lit. b — die Pflicht steht im Schulvertrag |
| Voranmeldung, Anmeldung, Schulvertrag | Aufnahmeverfahren vom Erstkontakt bis zum unterzeichneten Vertrag | `[A]` Art. 6 Abs. 1 lit. b, vorvertraglich |
| Ferienanmeldung | Buchung und Abrechnung des Ferienprogramms, auch für schulfremde Kinder | `[A]` Art. 6 Abs. 1 lit. b |
| Mensa | Essensanmeldung und ihre Abrechnung | `[A]` Art. 6 Abs. 1 lit. b |
| Gesundheitsdaten | Merkmale, die unterrichtende Personen kennen müssen, samt Masernnachweis | `[A]` Art. 9 Abs. 2 lit. a (Einwilligung) für die Merkmale; für den Masernnachweis Art. 9 Abs. 2 lit. i i. V. m. § 20 IfSG |
| Konfession, Staatsangehörigkeit, Beruf, Kirchengemeinde | Erhebung im Voranmeldebogen | **offen** — der Zweckbeschluss steht aus (TASK-038); ohne ihn trägt kein Feld eine Rechtsgrundlage |
| Rechnungsfreigabe, Elternbonus | interne Freigabe und Verrechnung von Auslagen und Elternmitarbeit | `[A]` Art. 6 Abs. 1 lit. b gegenüber Mitarbeitenden, lit. f gegenüber Eltern |
| Klassenbildung, Klassenorganisation, M365 | Zuordnung zu Klassen und Konten | `[A]` Art. 6 Abs. 1 lit. b |
| Newsletter und Schulinformation je Thema | Versand an Personen, die sich dafür eingetragen haben oder ihn nicht abgewählt haben — Ehemalige, Förderkreis, Interessenten, dazu die laufenden Familien; der Bestand ist eine Zeile je Person und Thema in `consents`, die Sorte eine Zeile in `mail_categories` (`schema/querschnitt-schema.sql`) | `[A]` Art. 6 Abs. 1 lit. a — Einwilligung, jederzeit widerrufbar; der Widerruf löscht die Zeile nicht, er setzt einen Zeitpunkt |

## c) Kategorien betroffener Personen und ihrer Daten

| Personengruppe | Datenkategorien |
|---|---|
| Kinder (eingeschrieben) | Name, Geburtsdatum, Geschlecht, Anschrift, Staatsangehörigkeit, Muttersprache, Klassenzugehörigkeit, Ein- und Abgangsdatum |
| Kinder (schulfremd, Ferienprogramm und Akademie) | derselbe Kern, ohne Klassen- und Vertragsbezug |
| Erziehungsberechtigte | Name, Anschrift, Telefon, E-Mail, Familienzugehörigkeit, Vertrags- und Zahlungsbezug, Arbeitsstundenkonto |
| Notfallkontakte | Name und Telefonnummer, sonst nichts |
| Bewerber ohne Aufnahme | die Voranmeldedaten bis zum Ablauf ihrer Frist |
| Newsletter-Empfänger ohne Vertragsverhältnis | Anrede, Name und die Zustelladresse an der Einwilligung je Thema, dazu die Zugehörigkeit — welcher der drei Kreise, bei Kind und Mitarbeitendem das Jahr des Weggangs, beim Kind der Schulzweig. **Kein Abschluss, keine Note, kein Grund des Ausscheidens.** Mehr nicht; sie hängen an keiner Familie und an keinem Kind. Ihre Frist läuft ab dem Widerspruch: bis dahin unbegrenzt, danach mit dem nächsten Lösch-Lauf (`soll-prozesse/17`) |
| Mitarbeitende | Entra-Object-ID, Name, Rolle; kein Personalaktendatum — das bleibt außerhalb (`grenzkarte.md`) |
| Kinder im Hort | dazu die **Betreuungsakte** des Horts — Absprachen, Verhalten, Beobachtungsbögen. Sie enthält eine Bewertung, liegt in einer eigenen SharePoint-Bibliothek und wird allein vom Hort gelesen (`grenzkarte.md`, Q2) |
| **Besondere Kategorien (Art. 9)** | Gesundheitsmerkmale und Masernnachweis (`schema/gesundheit-schema.sql`), Konfession (`schema/stammdaten-schema.sql`) |

Die Art.-9-Spalten und die Bankverbindung liegen hinter eigenen Postgres-Rollen und sind für die
Laufzeitrolle nicht lesbar — die Grenze ist eine Datenbankberechtigung, keine Filterung in der API
(`glossar.md`, `wb-backend/README.md`).

## d) Kategorien von Empfängern

| Empfänger | Was er sieht | Grundlage |
|---|---|---|
| Hetzner Online GmbH | betreibt die VPS; sieht die Daten nicht, kann sie aber technisch erreichen | AVV, Art. 28 |
| Microsoft | Identitätsanbieter (Entra ID), Mailversand über Graph, Ablage von Schüler- und Hortakte in SharePoint | bestehender Tenant-AVV |
| Stripe | Betrag, Zahlungsreferenz und die vom Elternteil auf Stripes eigener Seite eingegebene Adresse — **kein Name** | AVV, offen bis TASK-034 |

**Kein weiterer Empfänger.** Das Backupziel ist das schuleigene NAS und damit kein Dritter
(`backup.md`), die Prüfläufe in GitHub Actions sehen Quellcode und einen synthetischen Seed, nie
einen Export (`rules.md` Abschnitt 2), und einen externen CI-Runner im Deploy-Pfad gibt es nicht
(`deploy.md`). Der Überwachungsdienst healthchecks.io steht nicht in der Tabelle, weil er kein
Personendatum empfängt, sondern einen Heartbeat (`dsgvo.md`).

## e) Übermittlung in ein Drittland

Offen und an einem Ticket hängend: Welche **Stripe-Gesellschaft** Vertragspartner wird, entscheidet,
ob überhaupt ein Transfer nach Art. 44 ff. stattfindet (TASK-034). Für Microsoft gilt der bestehende
Tenant-Vertrag samt seinen Standardvertragsklauseln. Hetzner verarbeitet in Deutschland.

## f) Löschfristen

Die **Dauern** stehen seit dem 02./03.09.2026, bis auf zwei. Art. 30 Abs. 1 lit. f verlangt sie an
dieser Stelle; begründet sind sie je Bestand am Löschanker im Schema, und dort und nicht hier wird
geändert:

**Die Fristen stehen als Wert im System und nicht im Code** (Geschäftsführung, 04.09.2026): Geändert
werden sie von der Stelle, der der Bestand gehört — die Buchhaltung bei den Belegen, sonst die
Geschäftsführung —, wirksam ab einem Datum und nie rückwirkend. **Keine trägt eine Untergrenze**,
auch die zehn Jahre der Belege nicht: Wer eine Aufbewahrungspflicht kennt, ist die zuständige Stelle
und nicht das System. Die Belege sind zugleich der **einzige** Bestand, dessen Frist nichts auslöst —
sie ist ein Merkposten für die Handfreigabe durch die Geschäftsführung, gepflegt von der Buchhaltung
(`soll-prozesse/12`). Die Tabelle nennt deshalb den **heutigen** Stand, nicht eine unveränderliche
Zahl — und wo gar nichts eingetragen ist, wird auch nichts gelöscht
(`soll-prozesse/17`).

| Bestand | Frist | steht in |
|---|---|---|
| Schulvertrag | fünf Jahre nach dem Austritt | `soll-prozesse/03` |
| SEPA-Mandat | zwei Jahre nach dem Austritt | `soll-prozesse/03` |
| Bewerbung ohne Aufnahme | sechs Monate ab dem Endstatus | `schema/anmeldung-schema.sql` |
| Ferienbuchung samt schulfremdem Kind | sechs Monate nach dem letzten gebuchten Termin | `schema/ferien-schema.sql` |
| Gesundheitsbestand am Kind | drei Monate nach dem Austritt | `schema/gesundheit-schema.sql` |
| Hortakte | **zwei Jahre** nach dem letzten bestätigten Ende des Kindes — bei einem externen Hortkind ab seinem letzten Betreuungstag (Geschäftsführung, 04.09.2026) | `soll-prozesse/09` |
| Nachweis der Fotoerlaubnis je Kind | **unbegrenzt** — er belegt, bis zu welchem Tag sie galt (Datenschutzbeauftragter, 04.09.2026). Er entsteht erst beim Löschen des Kindes und trägt dann Name, Geburtsdatum, Abgangsdatum, Schulzweig und die beiden Zeitpunkte; die Zustimmungszeile selbst geht mit dem Kind | `soll-prozesse/08` |
| Newsletter-Einwilligung je Person | **unbegrenzt**, bis widersprochen wird; danach mit dem nächsten Lösch-Lauf. Die Person bleibt so lange mit Anrede und Namen stehen, ohne Anschrift und Telefonnummer | `soll-prozesse/00` |
| Zugehörigkeit der Ehemaligen (`alumni`) | dieselbe Frist wie die Einwilligung, an der sie hängt — sie entsteht nicht ohne Zustimmung und geht mit dem Widerruf | `soll-prozesse/22` |
| Gesundheitsangaben eines schulfremden Kindes | vier Wochen nach dem letzten gebuchten Termin | `schema/ferien-schema.sql` |
| Gesundheitsangaben einer Veranstaltung | vier Wochen nach ihrem Ende | `soll-prozesse/19`, `21` |
| Anmeldeformular einer Fahrt samt Unterschrift | drei Jahre nach dem Ende der Fahrt | `soll-prozesse/19` |
| Putzdienst und Elternmitarbeit | Zyklusende plus ein Jahr, nicht der Austritt | `schema/putzdienst-schema.sql` |
| Rückzahlung der Elternmitarbeit | drei Monate ab dem Abgang abrufbar | `soll-prozesse/03` |
| Mensa | letztes bestätigtes Ende dieses Kindes | `schema/mensa-schema.sql` |
| Belege der Rechnungsfreigabe | zehn Jahre, kein Löschanker | `schema/rechnungsfreigabe-schema.sql` |
| Anmeldecode und Sitzung | 24 Stunden bzw. 30 Tage | `schema/stammdaten-schema.sql` |

**Offen sind zwei:** die Aufbewahrung des Notfallprotokolls und die Frist des Eintrags eines
ausgeschiedenen Mitarbeitenden — an der zweiten hängt zugleich, was in der Rechnungsfreigabe je
verschwindet (TASK-058.07, TASK-160).

Vor jeder Löschung gehen **zwei Ankündigungen** an mindestens zwei Empfänger, zwei Wochen und eine
Woche vorher; sie tragen einen Prüfauftrag, und die Löschung lässt sich für den Einzelfall anhalten
— unbegrenzt verlängerbar, solange der Grund trägt (Art. 17 Abs. 3 lit. e), dafür mit sichtbarer
Fälligkeit. Der Ablauf steht einmal in `soll-prozesse/hebel.md`.

Der **Anker**, an dem jede Frist hängt, steht ebenfalls fest und ist eine Kaskade je Kind
(`dsgvo.md`): eingeschrieben → nichts löschen; `exit_date` gesetzt → dieser Anker; sonst der
späteste Anker der berührten Fachdomäne; bleibt auch der leer → `children.created_at`.

Beim schulfremden Kind reicht der Lauf über das Kind hinaus auf anmeldenden Elternteil, Familie und
Notfallkontakt — sonst bleiben Daten Dritter für ein Kind stehen, das die Schule nie besucht hat.
Log- und Backup-Retention laufen getrennt davon (`container.md`, `backup.md`).

## g) Technische und organisatorische Maßnahmen

Zusammenfassung; die Begründung je Maßnahme steht dort, wo sie umgesetzt ist, und wird hier nicht
zweitgefasst.

- **Zugriff:** Anmeldung ausschließlich über den Tenant (Personal) bzw. Einmalcode per Mail
  (Eltern); Rollen und Ownership-Prüfung je Route, feingranulare Sichtbarkeit über Postgres-Rollen
  und GRANTs (`zugang.md`, `glossar.md`).
- **Netz:** Die Datenbank ist ausschließlich über das interne Containernetz erreichbar, kein
  veröffentlichter Port; Transportverschlüsselung durchgängig, Firewall nur TCP (`container.md`,
  `host.md`).
- **Sicherung:** Pull vom schuleigenen NAS, die VPS hält kein Credential nach außen; getestete
  Wiederherstellung als wiederkehrender Termin (`backup.md`, TASK-120).
- **Nachvollziehbarkeit:** Änderungsspur an den Fachtabellen, Zugriffslog im Reverse-Proxy — die
  Grundlage jeder Meldung nach Art. 33 (`container.md`).
- **Betrieb:** monatliche Patchkadenz, wöchentliches Wartungsfenster mit automatischem Neustart,
  Dead-Man's-Switch auf Backup, Plattenfüllstand und Patchlauf (`rules.md` Abschnitt 2, `host.md`).
- **Geheimnisse:** nie im Git, nie im CI-Log, nie als Klartext-Umgebungsvariable — gemountete
  Dateien aus dem gemeinsamen Passwortmanager (`rules.md` Abschnitt 2).
- **Keine Verschlüsselung at rest**, bewusst und mit Preis: Sie schützt gegen den physischen Zugriff
  auf eine Platte, den die Vertrauensgrenze bereits Hetzner zuschreibt, und kostete eine Passphrase
  bei jedem Neustart (`rules.md` Abschnitt 2). Die Cyber-Versicherung fordert sie nicht und hat das
  am 03.09.2026 schriftlich bestätigt; ihre Empfehlung zielt auf physischen Diebstahl und damit auf
  das Risiko, das der AV-Vertrag mit Hetzner trägt (`host.md`).
