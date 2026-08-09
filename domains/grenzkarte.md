# Grenzkarte — Entitäten und Zuständigkeiten über alle Fachdomänen

Legt für **jede** Domäne aus `fachdomaenen.md` Abschnitt 6 fest, welche Entitäten es gibt und wem welche Tatsache gehört — bevor die einzelnen Tabellenschemata entstehen. Zweck ist nicht Vollständigkeit im Detail, sondern die Grenze: ein Sachverhalt bekommt genau einen Eigentümer, und jede spätere Domäne referenziert ihn, statt ihn nachzubauen.

**Was hier bewusst nicht steht:** Spalten, Typen, Constraints, Indizes. Die entstehen je Domäne in Deadline-Reihenfolge gegen diese Karte. Eine Spalte nachzutragen ist billig, eine falsch gezogene Grenze nicht — deshalb wird nur Letztere vorab entschieden.

Stand der Umsetzung: **Stammdaten** ist gebaut (`stammdaten-schema.sql`), ebenso **Putzdienst** samt der Querschnitts-Entität Q3 (`putzdienst-schema.sql`). Alles andere ist Karte, kein Schema.

## Freeze der Stammdaten

Stammdaten sind gegen die Rückwirkung der Domänen 2/4, 3 und 9 geprüft — der Domänen also, die vor der nächsten Gelegenheit zum Umbau fällig werden. **Keine von ihnen verlangt eine Änderung an einer bestehenden Spalte, einem Typ oder einem Constraint.** Was sie verlangen, steht unten je Domäne und läuft ausnahmslos auf neue Tabellen hinaus.

Ab dem **Vollimport Ende August 2026** gilt deshalb: eingefroren heißt **keine Änderung an bestehenden Spalten, Typen oder Constraints**. Neue Tabellen, die Stammdaten nur referenzieren, bleiben jederzeit erlaubt und stören keine lesende Domäne.

Der Stichtag trägt die Regel, nicht das Schema: davor ist eine Änderung ein Texteingriff in einen Entwurf, danach eine Migration auf echten Personendaten, und die externe Abnahme liegt ebenfalls davor. Wer nach dem Stichtag eine bestehende Spalte ändern zu müssen glaubt, prüft zuerst, ob eine neue Tabelle dasselbe leistet.

Drei Befunde aus dieser Prüfung sind keine Schemaänderung, sondern Festlegungen, die den Freeze überhaupt erst halten — sie stehen an ihrer jeweiligen Stelle und sind hier nur genannt, damit sie nicht als „noch offen" wieder aufgemacht werden: der Kindergarten bekommt eine eigene Werteliste statt `previous_schools` (unten), die Geburtsurkunde bleibt eine reine Q2-Zeile ohne Datumsfeld (unten), und die Notfallnummer bekommt kein eigenes Feld (`stammdaten.md`, „Kontakte").

## Vier Regeln, aus denen sich der Rest ergibt

1. **Ein Ort pro Sachverhalt** (`rules.md` Abschnitt 1). Der einzige Grund, warum es diese Karte gibt.
2. **Personendaten haben genau ein Zuhause:** `persons` plus die Rollentabellen in Stammdaten. Jede Domäne zeigt per Fremdschlüssel darauf und kopiert nie — auch nicht „nur den Namen für die Anzeige".
3. **Prozessdaten haben einen eigenen Lebenszyklus und eine eigene Löschfrist.** Eine Bewerbung, eine Buchung, ein Beleg überleben nicht so lange wie die Person und werden deshalb nie Teil ihrer Stammdatenzeile.
4. **Was in mehr als einer Domäne vorkommt, gehört keiner davon.** Es wird einmal gebaut (unten) und von allen referenziert. Diese vier Fälle sind der eigentliche Inhalt dieser Karte.

## Querschnitts-Entitäten

### Q1 — Zustimmung

Wer hat wann wozu zugestimmt, über welche Zustelladresse, und wurde es widerrufen. Form: *Person × (optional) Kind × Zweck × Zeitpunkt × Zustelladresse × Widerruf*.

Braucht sie: Schulvertrag, Gesundheitsdaten, Fotoeinverständnis, Werbe-Einwilligung Ferienbetreuung — und die Lastschrift-Ermächtigung für Mensa- und Hortbuchungen (siehe Q3), die trotz des Namens keine Zahlung ist, sondern eine Erlaubnis.

**Nicht** dazu gehört die Auskunftseinholung bei der abgebenden Schule. Sie ist ein einmaliger Vorgang bei der Voranmeldung: einmal erteilt, sofort verbraucht, danach nie wieder geprüft und sinnvollerweise auch nicht widerrufbar. Q1 trägt *fortbestehende* Zustimmungszustände, die abgefragt, widerrufen und erneut geprüft werden — ein verbrauchtes Einmal-Einverständnis ist ein Prozessereignis und bleibt als Zeitstempel dort, wo es hingehört (`children.previous_school_consent_at`). Das ist keine Doppelung, sondern eine Unterscheidung nach Lebensdauer.

Die **Zustelladresse gehört zwingend dazu** und ist nicht aus `persons.email` ableitbar: zwei Erziehungsberechtigte dürfen sich eine Mailbox teilen (`stammdaten.md`, „Geteilte Mailbox"), und nur mit festgehaltener Adresse ist hinterher auswertbar, ob zwei Zustimmungen über dasselbe Postfach kamen. Ebenso wenig ableitbar ist die Zustimmung aus der Login-Identität — die Oberflächen-Abfrage „als wer sind Sie angemeldet" ist Bedienführung, keine Sicherheitsgrenze (`idea/04-identitaet-zugriff.md`).

Ein Kind kann ab 14 Jahren selbst zustimmungspflichtig sein (Fotoeinverständnis) — die zustimmende Person ist deshalb nicht auf Erziehungsberechtigte eingeschränkt, sondern eine beliebige `persons`-Zeile.

### Q2 — Dokument und Signatur

Zwei getrennte Dinge, bewusst nicht mit Q1 verschmolzen: eine Zustimmung kann ohne Dokument existieren (Häkchen), und ein Dokument trägt oft mehrere Zustimmungen (ein Schulvertrag, zwei Unterschriften).

- **Dokument:** Typ, Bezug (Kind bzw. Vorgang), Ablageort, Erzeugungszeitpunkt.
- **Signatur:** Person × Dokument × Zeitpunkt × Signaturbild × Niveau (heute durchgängig einfache elektronische Signatur).
- Eine Zustimmung aus Q1 zeigt optional auf die Signatur, die sie belegt.

Braucht sie: Schulvertrag, Gesundheitsdatenblatt samt Attesten, Fotoeinverständnis, SEPA-Mandat, digitale Schülerakte.

**Die Dateien selbst bleiben in SharePoint, Weltenbaum führt nur die Referenz.** Entschieden, nicht offen. Gründe: der Speicher ist dort ohnehin bezahlt und vorhanden, Microsoft betreibt ihn mit höherem Aufwand, als eine selbstverwaltete VPS es kann, Versionierung ist eingebaut, und der Zugriff läuft über die Graph API, die für den OTP-Mailversand ohnehin schon angebunden wird (`idea/04-identitaet-zugriff.md`). Die Ordnerstruktur ist die Kohorten-Kennung („RS25a"), die dadurch stabil bleiben muss (`stammdaten.md`, `classes`).

Zwei Folgen dieser Entscheidung:

- **Das Backup bleibt wie es ist.** Es streamt ausschließlich einen `pg_dump` zum NAS (`idea/05-backup-recovery.md`) und deckt damit weiterhin den vollständigen Weltenbaum-Datenbestand ab. Wären die Dateien hier, bräuchte es eine zweite Sicherungsquelle samt eigenem Wiederherstellungstest.
- **Die Löschmechanik wird zweiteilig.** Läuft eine Aufbewahrungsfrist ab, muss der Lösch-Job die Datei in SharePoint mitentfernen, nicht nur die Referenzzeile (`idea/06-dsgvo-organisatorisch.md`). Eine verwaiste Datei in SharePoint ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile — und sie fällt niemandem auf.
- **Zusätzliche Graph-Berechtigung nötig,** über `Mail.Send` hinaus, mit derselben Frage nach engem Scoping (`putzdienst.md`, „Offene Punkte"): auf welche Site darf die Anwendung zugreifen, und nur lesend oder auch schreibend.

### Q3 — Zahlungsvorgang

**Keine Buchhaltung in Weltenbaum, keine Forderungsverwaltung, keine Fälligkeiten.** Optigem bleibt dafür führend. Weltenbaum berührt Geld nur an einer Stelle: wo ein Elternteil im Selbstservice bezahlt und der Prozess erst danach weiterlaufen darf.

Das trifft genau drei Anlässe, alle über **Stripe**: Voranmeldung samt Quereinstieg, Ferienprogramm-Buchung und Putzdienst-Freikauf. Form entsprechend schmal: *Anlass (Domäne + Vorgang) × Betrag × Status × Zahlungsreferenz*. Status bleibt trotzdem zahlungswegneutral (offen/bestätigt): neben Stripe bleibt die manuelle Bestätigung durch die Buchhaltung als benannter Ausweg für Überweisung und Bargeld bestehen (`putzdienst.md`) — dieselbe Zeile trägt beides, die Zahlungsreferenz bleibt dann leer.

**Gebaut ist Q3 mit dem Putzdienst-Freikauf als erstem und bisher einzigem Anlass** (`putzdienst-schema.sql`). Die beiden übrigen kommen als je eine weitere Vorgangs-Spalte samt erweitertem Entweder-oder-CHECK dazu, nicht als zweite Zahlungstabelle: der Fremdschlüssel trägt die Unterscheidung, wie bei `guardians` und `payers` in Stammdaten. Ein Typ-Feld plus untypisierte Vorgangs-ID gäbe die referenzielle Integrität auf, und genau die ist der Grund, Q3 überhaupt einmal zu bauen.

**Schulgeld, Mensa und Hort haben im System nichts verloren.** Sie werden vollständig über die Buchhaltung mit Optigem abgerechnet. Sollten Mensa- und Hortbuchungen später ein eigenes Portal bekommen, entsteht dort **keine** Zahlung, sondern eine Erlaubnis: „darf vom hinterlegten SEPA-Mandat abgebucht werden". Das ist eine Zustimmung und gehört nach Q1, nicht hierher — ein Zahlungsdatensatz ohne Zahlung wäre der Anfang einer Schatten-Buchhaltung.

Zwei Grenzen, die nicht verwischen dürfen:

- **`payers` in Stammdaten trägt das Einzugs*mittel*** (Bankverbindung, SEPA-Mandat) und ist von Q3 unabhängig: die drei Stripe-Anlässe brauchen weder IBAN noch Mandat, und das Mandat trägt keine Zahlung. Folge für die Ferienanmeldung: der regulär über Stripe zahlende Elternteil bekommt **keine** `payers`-Zeile — sie hätte keinen einzigen Nutzlast-Wert. Eine entsteht dort nur bei Kostenübernahme durch das Jugendamt (`stammdaten.md`, „Zahlungsverantwortliche").
- **Projektnummer und Buchungskonto** sind Attribute des Belegprozesses (Domäne 5) und haben mit Q3 nichts zu tun — dort geht Geld heraus, hier herein.

Die **Putzdienst-Strafzahlung** bei Nichterscheinen liegt ebenfalls außerhalb von Q3: sie entsteht nachträglich, wird nicht im Selbstservice bezahlt und läuft über die Buchhaltung mit Optigem. Weltenbaum hält nur fest, dass jemand nicht erschienen ist (Attribut der Zuteilung) — die Forderung daraus zieht die Buchhaltung.

### Q4 — Mitarbeiter und Bereichsstruktur

**`employees` ist gebaut** (Rolle auf `persons`, `stammdaten-schema.sql`) — vorgezogen, obwohl keine der Domänen, die sie braucht, gebaut ist: die Putzdienst-Befreiung fragt „aktuell beschäftigt" (`putzdienst.md`), die Gesundheitsdaten-Domäne braucht „Klassenlehrer:in dieses Kindes" (unten), und der Vollimport kommt komplett auf einmal. Ein Mitarbeiter-Flag am Erziehungsberechtigten gibt es deshalb nicht — es wäre ein zweiter Ort für dieselbe Tatsache, und ein Beschäftigungszeitraum lässt sich als Flag ohnehin nicht ausdrücken. Zur Dienstadresse an dieser Rolle: `stammdaten.md`, „Ausblick".

**Offen bleibt die Bereichs- und Vorgesetztenstruktur** (`fachdomaenen.md` Abschnitt 5). Sie braucht erst die Rechnungsfreigabe, und wie tief sie geschnitten ist, ist unbekannt — raten wäre teurer als später ergänzen.

### Q5 — Nachzieh-Aufgabe

Zielbild für Datenänderungen (`fachdomaenen.md` Abschnitt 3): die Änderung passiert zuerst in Weltenbaum, daraus entsteht eine benannte Aufgabe, sie in ASV-BW, Optigem oder Office 365 nachzuziehen.

Die Änderung selbst ist bereits erfasst (Audit-Spalten), und welches Feld welches Fremdsystem betrifft, ist eine statische Abbildung im Code — beides braucht keine Tabelle. Gespeichert wird nur, was sich nicht ableiten lässt: **ob die Aufgabe erledigt ist**.

Die „Abschließenden Aufgaben" der vier Anmeldetag-Checklisten sind die reale Vorlage dieser Liste — und zugleich der Nutzennachweis. Von den heute abzuarbeitenden Punkten entfallen mit Weltenbaum ersatzlos: Klassenlisten ausdrucken, Hort-/Mensaliste aktualisieren, Klassenverteiler in Outlook pflegen, Eintrag im Telefonbuch-PC, Kontaktdaten in die Putzliste übertragen. Als echte Nachzieh-Aufgaben bleiben ASV-BW und Optigem. Der Austausch der Schülerüberweisung mit der staatlichen Schule bleibt ebenfalls Handarbeit, gehört aber nicht hierher: er zieht keine Weltenbaum-Änderung in ein Fremdsystem nach, sondern ist ein Vorgangsschritt der Bewerbung (unten) — an zwei Orten geführt wäre derselbe Erledigt-Haken zweimal pflegbar. Solange ASV-BW und Optigem keine Update-Schnittstelle haben, ist das der einzige Weg, aus „hoffentlich hat es jemand gemacht" ein prüfbares Ergebnis zu machen.

## Je Domäne

Nummerierung wie `fachdomaenen.md` Abschnitt 6.

| Domäne | Eigene Entitäten | Nutzt Querschnitt | Schreibt Stammdaten |
|---|---|---|---|
| **Stammdaten** | Person, Anschrift, Telefon, Familie, Familienzugehörigkeit, Kind, Erziehungsberechtigte, Kontakt, Zahler, **Mitarbeiter**, Klasse/Klassenstufe/Zweig, 11 Lookups | — | besitzt sie |
| **1 Putzdienst** (gebaut) | Zyklus, Erinnerungsstufe, Terminart, Putztermin, Zuteilung, abweichende Pflichtmenge, Freikauf | Q3 | nein |
| **2 Voranmeldung** / **4 Anmeldeprozess und Anmeldegespräch** (eine Domäne, drei Phasen: Voranmeldung → Gespräch → Schulvertrag) | Bewerbung, Gesprächstermin, Vertragsvorgang, Betreuungsmodul (inkl. Hortvertrag) | Q1, Q2, Q3 | ja (viel) |
| **3 Ferienanmeldung** (Ferienprogramm, Kochwerkstatt) | Programm, Angebotstag, Buchung | Q1, Q3 | ja (legt schulfremde Kinder samt Familie, Erziehungsberechtigten und Notfallkontakt an) |
| **6 Mensa** | Essensanmeldung je Kind und Tag | Q1 (Lastschrift-Erlaubnis) | nein |
| **6 AGs** | unbekannt | unbekannt | vermutlich nein |
| **9 Gesundheitsdaten** | Gesundheitsmerkmal je Kind | Q1, Q2 | nein |
| **5 Rechnungsfreigabe** | Beleg, Freigabeschritt, Aufteilung | Q2, Q4 | nein |
| **7 M365-Kontenverwaltung** | Kontostatus, Offboarding-Schritt | Q4 | ja (`persons.email` beim Kind) |
| **8 Eltern-Selfservice** | keine | — | ja (eigene Daten) |
| **10 Krankmeldung** | Abwesenheit je Kind und Tag | — | nein |
| **11 Bonussystem** | unbekannt | unbekannt | nein |
| **12 Klassenbildung** | **keine** — alle Eingaben sind vorhanden oder ableitbar (siehe unten) | — | ja (`children.class_id`) |
| **13 Klassenorganisation** (neu) | Elternvertretung je Klasse | — | ja, falls Klassenlehrer/Raum an `classes` gehen |

**Die Hort-Buchung gehört dazu, der Hort-Alltag nicht.** Alle vier Anmeldetag-Checklisten erheben „Betreuungsbedarf: Kernzeit / Nachmittag / Ganztags", beim Quereinsteiger zusätzlich Lernbetreuung und Mittagessen für Realschüler, und es gibt einen eigenen **Hortvertrag** mit eigener Akte und eigenem Welcome-Brief. Eingezogen wird er über dasselbe SEPA-Mandat wie das Schulgeld — ein Mandat je Zahler, nicht je Zweck (`stammdaten.md`, „Zahlungsverantwortliche"); alle vier Checklisten haken genau eines ab. Das Betreuungsmodul ist damit Teil des Anmeldevorgangs (Domäne 2/4) und nicht abtrennbar. Out of scope bleibt allein der laufende **Hort-Alltag** — wer war wann da, Mittagessen je Tag —, für den der Hort eigene, sehr umfangreiche Excel-Dateien führt; sich dort einzuarbeiten lohnt den Aufwand derzeit nicht. Ebenfalls draußen: **Leihgeräte/iPads** (extern begleitet) und **Wahlpflichtfächer** (Schulalltag, Untis).

Vier Stellen brauchen eine Erläuterung, weil die Grenze dort nicht offensichtlich ist:

**Bewerbung (2/4).** Eine Bewerbung *zeigt* auf Kind und Familie, statt Personendaten zu kopieren — der Wechsel von der eigenen Grundschule in die eigene Realschule läuft durch denselben Prozess, und dieses Kind steht bereits vollständig in Stammdaten. Sie trägt nur, was die Bewerbung selbst betrifft: Zielschuljahr und Zielklassenstufe, Anmeldedatum, Quelle (Grundschule/Realschule/Quereinstieg), ausfüllende Person, Bestätigung dass der andere Elternteil informiert ist, wahrgenommene Angebote, Interesse an Hort und Hausaufgabenbetreuung, Status.

Der **Status** trägt dabei den gesamten Lebenslauf und ersetzt drei naheliegende Zusatzentitäten: die Warteliste ist ein Status samt jährlich fortgeschriebener Zielklassenstufe (sonst zwei Orte für „diese Familie will einen Platz"), die Absage ein Endstatus, und der Rücktritt oder die Kündigung vor dem ersten Schultag ebenfalls — ein Kind mit unterschriebenem Vertrag, das nie eingeschrieben war, ist kein Stammdaten-Fall, weil `entry_date` nie gesetzt wurde. Das reale Vokabular der beiden Wartelisten bestätigt das: „in Bearbeitung", „auf Warteliste", „abgesagt" sind Ausprägungen desselben Feldes, kein eigener Datensatz. Als Lookup, nicht als CHECK (`rules.md` Abschnitt 3).

**Die Warteliste selbst hat keine Rangfolge** — bei einem frei werdenden Platz entscheidet ein Mensch neu, und die Zahl der Wartenden ist klein. Es gibt dort deshalb kein Rangfeld, das beim jährlichen Fortschreiben mitwandern müsste. Eine Nummerierung gibt es sehr wohl, aber **eine Stufe früher**: in der Aufnahmeentscheidung (siehe „Bewertung"). Sie ordnet die Grenzfälle für die Entscheidungsrunde und wird danach nicht als Wartelisten-Priorität weitergeführt. Die übrigen Spalten der heutigen Listen sind Excel-Denormalisierung: Name, Telefonnummer und E-Mail für den Kontaktaufbau kommen in Weltenbaum über die Bewerbung aus `persons`, „aktuell an Schule X" ist `previous_school_id`, „Bruder wurde in Klasse 5 angemeldet" ist die Geschwister-Selbstauskunft. Übrig bleibt **ein** Freitextfeld für den Bearbeitungsstand — bewusst nicht zwei (Bemerkung und Stand getrennt), weil die Trennung im Alltag nicht eingehalten wird, und bewusst kein Notiz-Verlauf mit eigenen Zeilen, solange niemand danach sucht.

Beim Formularfeld **„Geschwister"** wird bewusst **nicht** gespeichert, wer die Geschwister sind — die Namensliste wird nicht ausgewertet und wäre eine Personenangabe ohne Zweck (`rules.md` Abschnitt 7). Interessant sind nur zwei Tatsachen: ob bereits Geschwister an der Schule sind (steuert Vorrang und später den Geschwisterrabatt) und die Anzahl der Geschwister insgesamt. Beides als Selbstauskunft an der Bewerbung, weil es bei externen Bewerbern noch keine Familie gibt, aus der es folgen könnte; bei der Aufnahme löst es sich gegen `families` auf.

Die Anmeldetag-Checklisten ergänzen je Schulart weitere Bewerbungsfelder: Grundschule ob das Kind zurückgestellt, schulpflichtig oder Kann-Kind ist und was der Kindergarten empfiehlt, Realschule die Grundschulempfehlung samt Zeugnis Klasse 3, Quereinstieg den Hospitationszeitraum. Dazu die Betreuungsmodule (siehe unten) und die Teilnahme am Infoabend.

Eigene, kürzere Löschfrist als Stammdaten, weil die meisten Bewerbungen nicht zur Aufnahme führen.

**Zwei Schulen, nicht eine.** `children.previous_school_id` trägt die staatliche Schule, mit der die **Schülerüberweisung** läuft — bei Quereinstieg und Realschulwechsel die Herkunftsschule, bei der Einschulung in Klasse 1 die zuständige örtliche Grundschule, bei der das Kind bis zur Zusage angemeldet sein muss. Verschiedene Herkunft, dieselbe Rolle im Prozess, deshalb eine Spalte. Der **Kindergarten** ist davon getrennt: er liefert den Beobachtungsbogen und braucht eine eigene Rücksprache-Erlaubnis, ist aber kein Überweisungspartner — beides gehört an die Bewerbung. Zwei Folgen, die sonst später als Eingriff in Stammdaten zurückkommen: Sein Name kommt aus einer **eigenen Werteliste in Domäne 2/4**, nicht aus `previous_schools` — die trägt seit der Bedeutungserweiterung genau die staatlichen Überweisungspartner, und ein Kindergarten darin verschöbe die Bedeutung einer bestehenden Spalte. Und die Rücksprache-Erlaubnis ist zwar wie `children.previous_school_consent_at` ein einmaliges, sofort verbrauchtes Einverständnis (also nicht Q1), steht aber trotzdem an der **Bewerbung** und nicht an `children`: die abgebende Schule wird über den Anmeldetag hinaus gebraucht, der Kindergarten nicht. Der Austausch der Überweisung selbst (erhalten, zurückgesendet) ist ein Vorgangsschritt, kein Stammdatum.

**Bewertung ist keine eigene Entität (2/4).** Im Gespräch beurteilen mehrere Lehrkräfte dasselbe Kind, festgehalten wird aber nur das **konsolidierte Ergebnis**: eine Einschätzung je Kind auf der Skala Zusage / Eher Ja / Eher Nein / Absage, in der Realschule dazu das Niveau (Hauptschule / Realschule / Gymnasium). Beides als Lookup (`rules.md` Abschnitt 3), beides als Attribut der Bewerbung — eine Zeile je Lehrkraft zu modellieren hieße, fünf konkurrierende Urteile ohne definierten Sieger zu speichern, die es so gar nicht gibt.

Beim Niveau **zwei Felder statt einem**, solange nicht bestätigt ist, dass es dasselbe ist: die **Grundschulempfehlung** ist das amtliche Dokument der abgebenden Schule, das die Checkliste unter „Unterlagen prüfen" als „Grundschulempfehlung Seite 2 + 3" abhakt und in derselben Zeile wie die Grundschule handschriftlich festhält; das Niveau in der eigenen Bewertungstabelle steht dagegen neben der eigenen Einschätzung und liest sich als eigenes Urteil aus Gespräch und Testblättern.

**Beide werden erst am Anmeldetag erhoben, nicht bei der Voranmeldung** — deren Formular fragt weder die Empfehlung noch das Niveau ab, nur die abgebende Schule und die Einwilligung zur Auskunftseinholung. Die Felder gehören damit in die zweite Phase der Bewerbung, bleiben nach dem Absenden der Voranmeldung zunächst leer und dürfen dort nicht als fehlende Pflichtangabe gelten. Beide teilen dieselbe Werteliste. Sind es doch zwei Namen für dieselbe Angabe, bleibt eine Spalte leer — der billigere Irrtum, denn ein Feld für zwei Sachverhalte verliert die Information, ob beide auseinandergehen, und genau das ist der interessante Fall. Zu bestätigen mit dem Sekretariat vor Domäne 2/4.

Dazu die **Rangnummer** aus der Entscheidungsrunde, nullable: vergeben wird sie nur für die Grenzfälle, klare Zusagen und klare Absagen brauchen keine. Nach der Entscheidung liest sie niemand mehr — sie bleibt als Beleg, wie entschieden wurde, und teilt die Löschfrist der Bewerbung. Diese Felder haben das engste Zugriffsprofil im System nach den Art.-9-Daten und brauchen deshalb ein eigenes Spalten-GRANT auf der Bewerbung, auch wenn sie keine eigene Tabelle bekommen. Das Gespräch selbst erhebt keine Stammdaten.

**Zwei Bemerkungen aus der heutigen Tabelle sind keine Bemerkungen.** „Nachrücker" ist eine Ausprägung des Bewerbungsstatus, kein Freitext — sonst steht dieselbe Tatsache neben dem Status ein zweites Mal. Und **Schulbegleitung** ist ein Unterstützungsbedarf, der über die Bewerbung hinaus gilt und im Schulalltag gebraucht wird; er gehört zu den Gesundheits- und Förderdaten (Domäne 9) mit deren Zugriffsprofil, nicht in ein Freitextfeld der Bewerbung. Beides steht heute in derselben Spalte, weil Excel keine andere anbietet.

**Gesundheitsmerkmal (9).** Der Satz ist größer als der Schulvertrag allein: die Anmeldetag-Checklisten ergänzen Seh-/Hörschwäche sowie therapeutische Maßnahmen mit Behandlungsgrund und -zeitraum, und **derselbe Satz wird auf allen vier Checklisten plus im Schulvertrag erhoben** — fünf Formulare, ein Datenbestand. Alle folgen demselben Muster: Merkmal vorhanden, Beschreibung, ggf. Behandlungszeitraum (von/bis, bei therapeutischen Maßnahmen real erhoben), ggf. Attest, ggf. Erlaubnis zur Verabreichung oder Durchführung. Also **eine Zeile je Merkmal mit Merkmalsart als Lookup**, nicht rund dreißig Spalten — eine weitere Merkmalsart ist damit ein Datensatz statt einer Migration, und das Spalten-GRANT der engeren DB-Rolle greift auf einer Tabelle statt auf dreißig Spalten.

Zwei Nachweise daneben, die keine Merkmale sind — und die trotz ähnlicher Form auseinandergehen:

- Der **Masernschutznachweis** ist gesetzlich verpflichtend (§20 IfSG) und wird auf allen vier Checklisten geprüft, aber nicht immer als Kopie: die Realschul-Checkliste hakt „Impfpass Masernschutzimpfung **dokumentiert**" ab, der Pass wird also nur vorgelegt. Es gibt damit Fälle ganz ohne Dokument, und Q2 allein trägt den Nachweis nicht — er braucht ein **Vorlagedatum in Domäne 9** (Impfstatus ist ein Gesundheitsdatum).
- Die **Geburtsurkunden-Kopie** steht auf allen vier Checklisten ausdrücklich als „Kopie", es entsteht also immer ein Dokument. Sie ist damit **eine Q2-Zeile mit Bezug Kind und sonst nichts** — kein eigenes Datumsfeld, weder an `children` noch in Domäne 9: sie ist kein Gesundheitsdatum und hätte dort das falsche Zugriffsprofil.

**Zugriff, zweistufig.** Den vollen Satz sehen Sekretariat, Klassenlehrer:in und Hort. Daneben steht ein kurzer **handlungsrelevanter Hinweis** („keine Sprungübungen", „Notfallmedikament im Sekretariat"), den die Klassenlehrkraft formuliert und den alle unterrichtenden Personen sehen. Grund: ein Fachlehrer braucht die Handlungsregel, nicht die Diagnose — der volle Satz wäre Über-Offenlegung nach Art. 9. Eine echte Fachlehrer-Berechtigung bräuchte ein Unterrichtszuordnungs-Modell, und das lebt in Untis, dauerhaft out of scope. Zwei Spalten mit unterschiedlichem GRANT auf derselben Tabelle, kein zweites Berechtigungssystem.

**Zuteilung (1).** Anwesenheit bleibt in v1 eine Papier-Unterschriftenliste, aber Nichterscheinen wird erfasst, weil es eine Strafzahlung auslöst. Das ist ein Attribut der Zuteilung, keine eigene Anwesenheits-Entität — und der Stundennachweis ist daraus plus der Stundenzahl je Termin ableitbar (`putzdienst.md`). Die Papierliste soll mittelfristig abgelöst werden; die Struktur trägt das bereits, aus „nicht erschienen" wird dann „erschienen um X, gegangen um Y" an derselben Zeile.

**Klassenbildung (12) braucht keine eigene Tabelle.** Die heutige Liste für die neuen Klassen 1 und 5 enthaelt Wohnort, Geschlechterverteilung, Klassenlehrer:in und die Zusammensetzungswuensche. Davon ist alles bereits vorhanden: Wohnort und Geschlecht stehen an `persons`, Geschwister folgen aus `families`, Klassenlehrer:in aus `classes.class_teacher_id`. Bleibt der Wunsch „mit wem möchte dieses Kind zusammen" — real drei Kinder je Jahrgang, eines davon mit zwei Nennungen. Dafür eine Kind-zu-Kind-Verknüpfung mit Richtung, Vorzeichen und Gegenseitigkeit zu bauen wäre ein Mechanismus ohne Bedarf (`rules.md` Abschnitt 1); es ist ein Freitextfeld an der Bewerbung, wo der Wunsch ohnehin geäußert wird.

Die Domäne ist damit **eine Oberfläche, keine Datendomäne**: eine Ansicht über alle Kinder einer künftigen Klassenstufe mit Geschlecht, Wohnort, Geschwistern und Wunschnotiz, aus der ein Mensch `children.class_id` setzt. Verwandt mit der Restplatz-Zuordnung des Putzdiensts — ein Zuordnungsproblem mit Nebenbedingungen, aber bei rund 50 Kindern und drei Wünschen eines, das ein Mensch am Tisch löst und kein Solver.

**Elternvertretung (13).** Je Klasse gibt es Elternvertreter:in und Stellvertretung — eine Verknüpfung Person↔Klasse, kein Stammdatum der Person. Ohne Schuljahres-Historie (`stammdaten.md`) trägt sie immer nur den aktuellen Stand, was hier genügt. Auf derselben Liste stehen **Klassenlehrer:in und Klassenzimmer**, die heute in `classes` keinen Platz haben — siehe „Weiße Flecken".

## Bewusst nicht zusammengelegt

Damit es niemand später „aufräumt":

- **Termine.** Putztermin, Ferien-Angebotstag und Gesprächstermin sehen ähnlich aus und sind es nicht: der eine hat Typ und Stundenzahl, der zweite zwei Betreuungsenden und eine Tageskapazität, der dritte ist ein Einzelslot. Eine gemeinsame Termin-Entität wäre eine Abstraktion über drei Fälle, die nichts teilen außer einem Datum.
- **Der Schulkalender.** Feste und Ferien werden im September festgelegt und sind die Grundlage der Putztermin-Planung — sie liegen aber in M365 und bleiben dort. Putztermine trägt ein Mensch danach von Hand ein; ein eigener Kalender in Weltenbaum wäre ein zweiter Ort für denselben Sachverhalt.
- **Zustimmung und Signatur** (Q1/Q2) — Begründung oben.
- **Forderung und Bankverbindung** (Q3 vs. `payers`) — Begründung oben.

## Weiße Flecken

Was diese Karte offenlässt, ist selbst Ergebnis: es sind die Fragen, die vor der jeweiligen Domäne zu stellen sind.

| Was fehlt | Wen fragen | Spätestens vor |
|---|---|---|
| Bereichs- und Vorgesetztenstruktur an `employees` (Q4) — Zuschnitt unbekannt | Geschäftsführung | Domäne 5 |
| Steht in der Realschul-Bewertungstabelle derselbe Wert wie im Feld „Empfehlung Schulart" der Papier-Checkliste, oder eine eigene Einschätzung? Bis zur Klärung zwei Felder — beantwortbar von den Personen, die beide ausfüllen | Sekretariat, Realschulleitung | Domäne 2/4 |
| Graph-Scoping für den SharePoint-Dateizugriff (welche Site, lesend oder schreibend) | zweiter Admin | Domäne 4 |
| AGs — nichts Konkretes bekannt | Schulleitung | offen |
| Bonussystem Elternmitarbeit: speist es sich aus dem Putzdienst-Stundennachweis | Vertragsanlage | Domäne 11 |
| Aufbewahrungs- und Löschfristen je Entität | Schulleitung bzw. Datenschutzbeauftragte:r (`TODO.md`) | vor dem Lösch-Job |
| Weitere Excel-Listen, die niemand vollständig kennt | Verwaltung, Hausdienstverwaltung | laufend |

**Ausgewertet:** die vier Anmeldetag-Checklisten (Grundschule Klasse 1, Realschule Klasse 5, Quereinsteiger, Hort), die beiden Wartelisten je Schulform und die Klassenbildungsliste. Ihre Befunde stecken in dieser Karte.

Die Listen-Eigentümer je Domäne stehen in `fachdomaenen.md` Abschnitt 3 — das ist die Ansprechpartnerliste für diese Fragen.
