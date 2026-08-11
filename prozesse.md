# Prozesse — Ist-Stand und erhobene Daten

Wie die Prozesse der Schule **heute** ablaufen und **welche Felder** sie dabei real erheben. Ausgewertete Fassung der Prozesserhebung; die Rohsammlung dahinter wird nicht weitergeführt.

Abgrenzung zu den Nachbardateien, damit nichts zweimal dasteht:

| Datei | trägt |
|---|---|
| **hier** | Ablauf heute, Beteiligte, Werkzeug, erhobene Felder, bekannte Bruchstellen |
| `fachdomaenen.md` | Scope, Zielbild, Domänen-Liste samt Priorität, Jahreskalender der Verwaltung |
| `domains/grenzkarte.md` | Entitäten je Domäne, wem welche Tatsache gehört |
| `domains/*.md` + `.sql` | die gebauten Domänen (Stammdaten, Putzdienst) |

Zeitliche Einordnung steht im Jahreskalender in `fachdomaenen.md` Abschnitt 1; hier nur die prozesseigenen Termine, die dort nicht auflösbar sind.

---

## 1. Prozesslandkarte

| Prozess | Werkzeug heute | führende Stelle | Zahlung | Domäne |
|---|---|---|---|---|
| Alltägliche Datenänderung | Mail/Telefon/persönlich, kein Prozess | Sekretariat | — | Stammdaten |
| Voranmeldung GS/RS | Jotform + Power Automate → Excel | Sekretariat + Schulleitung | Anmeldegebühr beim Absenden | 2/4 |
| Quereinsteiger | dito, eigenes Formular | Sekretariat | Anmeldegebühr | 2/4 |
| Anmeldetag (Sekretariats-Checkliste) | Papier, Ergebnis in Excel | Sekretariat | — | 2/4 |
| Anmeldegespräch (Lehrer-Checkliste) | Papier, bleibt Papier | Lehrkräfte | — | 2/4 (nur Ergebnis) |
| Aufnahmeentscheidung, Warteliste | Excel | Schulleitung + benannte Lehrkräfte | — | 2/4 |
| Schulvertrag | Jotform + Power Automate, private Excel-Tabellen | Betreiber selbst | SEPA-Mandat wird hier erhoben | 2/4 |
| Hortvertrag | Papier | Hort | über dasselbe SEPA-Mandat | 2/4 (Betreuungsmodul) |
| Mensa-Anmeldung | Excel, Buchung über Sekretariat | Hausdienstverwaltung + Sekretariat | Optigem-Lastschrift | 6 |
| Ferienprogramm / Kochwerkstatt | Jotform + Power Automate → Excel | Hort bzw. Hausdienstverwaltung | Stripe-Anlass, Zahlung beim Absenden | 3 |
| Putzdienst | Jotform + Power Automate, vor Ort Papier | Sekretariat | Freikauf/Strafe | 1 (gebaut) |
| Elternbonus Elternmitarbeit | reiner Papierprozess | Sekretariat | Rückzahlung über Schulgeldabrechnung | 11 |
| Rechnungsfreigabe | SPFx-Teams-App + Power Automate + SharePoint | Buchhaltung/Führungskräfte | — | 5 |
| M365-Konten | Vis365, Handarbeit | zweiter Admin | — | 7 |
| Schuljahreswechsel | ASV-BW-CSV + Handarbeit | Sekretariat + zweiter Admin | — | — |
| Abgang/Schulwechsel | Zuruf, kein Prozess | Sekretariat + Schulleitung | — | — |
| DSGVO-Auskunft | kein Prozess, digitale Schülerakte in SharePoint | Sekretariat | — | — |
| Krankmeldung | Mail an mehrere Empfänger | Eltern selbst | — | **entfällt**, siehe 19 |
| AGs | nichts bekannt | Schulleitung | — | 6 |

Alle Excel-Listen außer der des Anmeldeprozesses liegen außerhalb des Zugriffs des Betreibers; welche Listen darüber hinaus existieren, weiß niemand vollständig.

---

## 2. Alltägliche Datenänderungen

Der häufigste Vorgang überhaupt und der einzige ohne jede Automatisierung.

**Ablauf:** Umzug, neue Telefonnummer, neue E-Mail-Adresse, Namensänderung (Heirat, Scheidung, Einbürgerung), Trennung oder neuer Sorgerechtsbeschluss, Wegfall eines Elternteils, neuer Notfallkontakt oder neue Abholberechtigung kommen per Mail, Telefon oder persönlich ans Sekretariat. Von dort muss die Änderung je nach Art und Status der Familie nach **ASV-BW**, **Optigem** und in die betroffenen **Excel-Listen** nachgezogen werden, bei einer E-Mail-Adresse zusätzlich nach **Office 365**.

**Bruchstelle:** Nichts prüft, ob das überall passiert ist. Änderungen landen in einem System und in den übrigen nicht, und es fällt niemandem auf. Stärkster einzelner Treiber für Weltenbaum überhaupt.

**Wunsch der Schule:** Eltern sollen ihre Daten selbst ändern können. Häufigkeit ist nicht hoch, der Aufwand pro Fall aber vollständig manuell.

Zielbild und die daraus folgende Nachzieh-Aufgabe: `fachdomaenen.md` Abschnitt 3, `domains/grenzkarte.md` Q5.

---

## 3. Voranmeldung

### 3.1 Ablauf

1. **Anfang der Herbstferien:** Voranmeldung für Grund- und Realschule des Folgeschuljahres wird veröffentlicht.
2. Es bewerben sich alle Interessenten. Für die **Grundschule sind alle Bewerber extern** — KITA-Kinder werden nicht vorgehalten. Für die **Realschule** laufen auch eigene Grundschüler durch denselben vollständigen Prozess.
3. **Anmeldegebühr** wird beim Absenden des Formulars gezahlt.
4. **Januar:** Infoabend. Alle bereits angemeldeten Eltern bekommen eine Einladungsmail; danach kommt regelmäßig ein zweiter Anmeldeschub.
5. **Januar/Februar:** Anmeldung wird je Schule geschlossen — Zeitpunkt hängt an der Bewerberzahl und muss dynamisch setzbar sein, teils war sie bis Juni offen.

### 3.2 Erhobene Felder

Grundschul- und Realschulformular sind **feldgleich**. Das Quereinsteigerformular ist das Realschulformular **plus Zielklasse und Zielschuljahr**.

**Kind:** `kindVorname`, `kindNachname`, `kindGeschlecht`, `kindGeburtsort`, `kindGeburtsland`, `kindGeburtsdatum`, `kindMuttersprache`, `kindStaatsangehoerigkeit1`, `kindStaatsangehoerigkeit2`, `kindKonfession`, `kindKirchengemeinde`

**Anschrift Kind:** `kindStrasse`, `kindHausnummer`, `kindPLZ`, `kindWohnort`, `kindTeilort`

**Bisherige Einrichtung:** `kindSchule`, `auskunftSchuleEinholen` (Einwilligung, dort Auskunft einzuholen) — **dasselbe Feldpaar, je Schulart etwas anderes:**

| | `kindSchule` ist | `auskunftSchuleEinholen` erlaubt |
|---|---|---|
| Realschule, Quereinstieg | die abgebende Schule | Auskunft bei dieser Schule |
| Grundschule | der **Kindergarten** | Rücksprache mit dem Kindergarten |

**Formularkopf:** `ausfuellendePerson`, `vaterMutterInformiert` (Bestätigung, dass der andere Elternteil informiert ist), `Anmeldedatum`

**Angebote:** `wahrgenommeneAngebote`, `interesseHort`

**Je Erziehungsberechtigte:r (`erz1…`/`erz2…`, identischer Block):** `Art`, `Geschlecht`, `Vorname`, `Nachname`, `Konfession`, `Beruf`, `TelefonPrivat`, `TelefonMobil`, `Email`, `Staatsangehoerigkeit`, `Strasse`, `Hausnummer`, `PLZ`, `Wohnort`, `Teilort`

**Geschwister:** `Geschwister` (heute Freitext-Namensliste)

**Was auf dem Grundschulformular fehlt: die örtlich zuständige Grundschule.** Weil `kindSchule` dort den Kindergarten trägt, erhebt die Voranmeldung die staatliche Schule gar nicht — sie kommt heute erst am Anmeldetag auf der Sekretariats-Checkliste vor (Abschnitt 5.2), zusammen mit dem Hinweis, dass das Kind dort bis zur Zusage angemeldet bleiben muss. **Sie muss künftig zusätzlich abgefragt werden**, und zwar als eigenes Feld neben dem Kindergarten, nicht statt seiner: die beiden sind verschiedene Einrichtungen mit verschiedenen Rollen im Verfahren (`domains/grenzkarte.md`, „Zwei Schulen, nicht eine").

### 3.3 Wozu die Schule die erklärungsbedürftigen Felder braucht

Ausdrücklich benannt, weil ohne Zweck kein Feld bleibt (`rules.md` Abschnitt 7):

- **Beruf der Eltern** — für die Elternmitarbeit: wenn ein Thema ansteht, für das ein bestimmter Beruf hilft, liegt die Information direkt vor.
- **Konfession der Eltern** — macht sichtbar, ob es eine christliche Familie ist (Aufnahmekriterium einer christlichen Schule).
- **Staatsangehörigkeit der Eltern** — Einschätzung, mit welchen Wurzeln das Kind aufgewachsen ist.
- **Kirchengemeinde** — Interesse, kein benannter Verarbeitungszweck.
- **Geschwister und wahrgenommene Angebote** (Musikarche, Ferienprogramm, Clemens-KITA) — geben einen **Bonus bei der Zusage** und sind damit entscheidungsrelevant, nicht dekorativ.

Der Betreiber will diese Felder zunächst mitspeichern und intern erst **nach dem Import** endgültig klären, welche bleiben. Das ist eine bewusste Entscheidung mit Preis: Konfession ist ein Art.-9-Datum, und ein Feld ohne beschlossenen Zweck mit echten Personendaten zu füllen, ist genau der Fall, den `rules.md` Abschnitt 7 ausschließt. Reihenfolge muss deshalb umgekehrt sein — Zweck vor Vollimport, nicht danach; das Schema trägt beides bereits (Spalten-GRANT auf den Konfessionsspalten, `domains/stammdaten.md`).

### 3.4 Bruchstellen

- Eltern, die die Voranmeldung verpassen, gehen heute über das **Quereinsteigerformular** und landen damit in der falschen Liste. Gewünscht: harte Sperre, dazu **einzelne Nachmeldelinks über das Sekretariat** in die reguläre Voranmeldung der jeweiligen Schule — die Sperre braucht diesen benannten Ausweg, sonst wird sie umgangen statt eingehalten.
- Die Geschwister-Namensliste wird nicht ausgewertet (`domains/grenzkarte.md`, „Bewerbung"): gebraucht werden nur „Geschwister bereits an der Schule" und die Anzahl.

---

## 4. Quereinsteiger

Ganzjährig, eigenes Formular.

- Felder wie Realschule, zusätzlich **Zielklasse** und **Zielschuljahr**.
- Anmeldegebühr wie bei der Voranmeldung.
- Bearbeitung sofort: Prüfung, ob in der Zielklassenstufe überhaupt ein Platz frei wäre. Nur dann folgt ein Anmeldegespräch.
- Der Schulvertragsprozess (Abschnitt 7) läuft für Quereinsteiger identisch und muss deshalb ganzjährig funktionieren.

---

## 5. Anmeldetag

### 5.1 Organisation und Terminvergabe

| | Grundschule | Realschule |
|---|---|---|
| Regeltermin | ein Samstag | ein Donnerstag und ein Freitag |
| Sondertermine | donnerstags | nicht bekannt |

- **Gesprächszeit 08:00–16:00**, Mittagspause 12:00–13:00.
- **4–5 Kinder pro Stunde.**
- Heute werden Termine **zugeteilt und per Brief verteilt**. Terminverschiebungen sind der große Schmerzpunkt des Sekretariats — sehr hoher Aufwand.
- **Gewünscht:** Eltern buchen ihren Termin selbst aus einer angebotenen Auswahl.

Daraus folgt eine Slot-Struktur mit Kapazität je Slot, Tagesraster und Pausenfenster — der Gesprächstermin ist damit mehr als ein Einzelslot mit Datum (`domains/grenzkarte.md`, „Bewusst nicht zusammengelegt: Termine").

**Die Werte oben sind der Ausgangsstand, nicht die Regel.** Wochentage, Zeitfenster, Pause und Kinder je Stunde setzen die zuständigen Personen selbst, weil sich das immer wieder ändert — das gilt ausdrücklich auch für die Sondertermine, die deshalb nicht als Festlegung fehlen, sondern gepflegt werden wie jeder andere Termin (`rules.md` Abschnitt 3).

### 5.2 Zwei Checklisten

**Lehrer-Checkliste — bleibt zwingend Papier.** Darauf stehen sehr sensible Notizen, die nach Abschluss des Prozesses zügig vernichtet werden. Digitalisiert wird nur das konsolidierte Ergebnis: **„Passt zur Schule": Ja / Eher Ja / Eher Nein / Nein**, dazu wenige Notizen — heute in Excel. Die Lehrkräfte stehen dem kritisch gegenüber und würden Excel vermutlich weiter bevorzugen.

Anforderung ans Schema daraus: Die Felder werden mitgebaut, aber **nicht öffentlich sichtbar** abgelegt, mit der Möglichkeit, sie später umzuschalten, falls die Lehrkräfte überzeugt werden können. Das deckt sich mit dem engsten Zugriffsprofil im System nach den Art.-9-Daten (`domains/grenzkarte.md`, „Bewertung").

**Sekretariats-Checkliste — wird digitalisiert.** Inhalt vollständig, `GS` = Grundschule, `RS` = Realschule:

| | Punkt |
|---|---|
| GS | Einstufung: zurückgestellt / schulpflichtig / Kann-Kind (Stichtage siehe 5.3) |
| GS | Kindergartenempfehlung: Einschulung oder Zurückstellung |
| GS | Teilnahme an Musikarche, Ferienprogramm, Clemens-KITA |
| GS | Zuständige örtliche Schule — mit dem Hinweis, dass das Kind dort trotzdem angemeldet bleiben muss, bis die eigene Zusage vorliegt |
| GS | Beobachtungsbogen des Kindergartens einholen; falls nicht mitgebracht, bekommen die Eltern einen Bogen zum Ausfüllenlassen |
| GS | Erlaubnis zur Rücksprache mit dem Kindergarten |
| GS | Einschulungsuntersuchungsbericht (dürfte das interne Lehrerformular sein — zu bestätigen) |
| GS | Elternfragebogen zum Ausfüllen — könnte vorab digital laufen |
| GS | Förderverein Schönbühl wird **nur erwähnt**, mehr nicht |
| GS | Hortvertrag kann ausgefüllt werden, mit Hinweis auf feste Tage und begrenzte Plätze. Bisher wurden alle Verträge angenommen, künftig eventuell nicht mehr |
| RS | Grundschüler an der eigenen Schule? Geschwister an der eigenen Schule? |
| RS | Aktuelle Grundschule und deren Empfehlung: Hauptschule / Realschule / Gymnasium |
| RS | Grundschulempfehlung Seite 2 + 3 prüfen |
| RS | Kopie des Zeugnisses Klasse 3 einholen |
| GS+RS | Notfalltelefonnummer, vormittags erreichbar — darf eine nicht sorgeberechtigte Person sein (Oma/Opa/Tante/Nachbarn) |
| GS+RS | Adresse bestätigen, Sorgeberechtigung klären, wer in Briefe einzubeziehen ist; dazu E-Mail und Telefon |
| GS+RS | Geburtsurkunde mitgebracht? Kopie wird angenommen oder vom Original erstellt |
| GS+RS | Masernschutzimpfung dokumentiert? Es zählt nur **ob** und **wie vorgelegt** — es wird ausdrücklich **keine Kopie** gespeichert |
| GS+RS | Hinweis: Schulvertrag kommt per Mail oder mit der Zusage |
| GS+RS | Teilnahme am Infoabend? |
| GS+RS | Elternmitarbeit und Putzdienst werden erklärt |
| GS+RS | Betreuungsbedarf: nur Kernzeit / Nachmittag / Ganztags |
| GS+RS | Gesundheitsabfrage: Allergien und Unverträglichkeiten, regelmäßige Medikamente samt Welche, Seh- oder Hörschwäche, therapeutische Maßnahmen (LRS, ADHS, Logopädie, …) |
| GS+RS | Vollständigkeitsprüfung aller Unterlagen |
| GS+RS | Freitext für zusätzliche Anmerkungen |

### 5.3 Kann-Kind, schulpflichtig, zurückgestellt

Aktuelle Regel:

- Sechs Jahre alt bis zum **30.06** → schulpflichtig (kann trotzdem zurückgestellt werden).
- Sechs Jahre alt **ab dem 01.07** → Kann-Kind.
- Sieben Jahre alt → zurückgestelltes Kind.

**Die Stichtage ändern sich immer mal wieder und müssen deshalb dynamisch konfigurierbar sein** — als Wert in der Datenbank, nicht als Konstante im Code (`rules.md` Abschnitt 3). Die Einstufung selbst ist damit ableitbar, wird aber am Anmeldetag festgehalten, weil die Zurückstellung eine Entscheidung ist und keine Rechnung.

---

## 6. Anmeldegespräch, Bewertung und Aufnahmeentscheidung

1. Termin wird heute per Mail vereinbart (künftig Selbstbuchung, siehe 5.1). Kind und Eltern kommen in die Schule.
2. **Bewertung durch Lehrkräfte:** verschiedene, nicht alle Lehrkräfte bewerten einzeln, wie gut ein Kind passt, und erstellen daraus ein Ranking. Dazu Notizen. In der **Realschule lösen die Kinder zusätzlich Blätter**, die bewertet werden.
3. **Parallel dazu das Sekretariat:** es prüft am selben Tag die Verwaltungssachen — Unterlagen, Nachweise, Adressen, Betreuungsbedarf, also die vollständige Checkliste aus Abschnitt 5.2 — und gibt die allgemeinen Informationen zum Schulalltag weiter. Der Anmeldetag hat damit zwei Spuren nebeneinander, nicht nur die Lehrerbewertung: eine urteilende und eine verwaltende.
4. Das Gespräch **erhebt keine Stammdaten** — es gibt nur Informationen über den weiteren Ablauf heraus. Die Stammdaten-Bestätigung der Checkliste läuft über die Sekretariatsspur.
4. Nach allen Gesprächen entscheiden **Schulleitung und benannte Lehrkräfte** über Zusage, Warteliste oder Absage. Grundlage ist das Feedback aus den Gesprächen (angenommen / vielleicht / eher nicht).

**Absage:** Die Eltern bekommen eine Mail, der Vorgang ist abgeschlossen.

**Warteliste:** Die Eltern bekommen eine Mail mit Link und bestätigen, ob sie den Warteplatz annehmen. Bei Ablehnung wird das Kind gestrichen. Bei Annahme bleibt es auf der Liste und wird **jährlich in die nächste Klassenstufe fortgeschrieben** (Warteliste Klasse 5 → im Folgejahr Warteliste Klasse 6). Gewünscht ist eine jährliche Rückfrage per Mail, ob das Interesse weiterbesteht.

**Zusage:** **Mutter und Vater bekommen je eine eigene Mail mit einem persönlichen Link** in den Schulvertragsprozess.

**Bruchstelle und Importrisiko:** Die Warteliste wird vom Sekretariat heute faktisch **nicht gepflegt**. Beim Vollimport ist ihr Stand deshalb nicht belastbar — Einträge können längst erledigt sein.

---

## 7. Schulvertrag

### 7.1 Ablauf

1. Jeder Elternteil öffnet **seinen eigenen Link** und entscheidet, ob der Schulplatz angenommen wird. **Konfliktfall:** Sagt einer ja und einer nein, wird das Sekretariat benachrichtigt und klärt telefonisch, was gilt.
2. **Stammdatenbestätigung:** Jeder bestätigt **seine eigenen** Daten aus der Voranmeldung — nicht die des anderen. Die Daten des Kindes bestätigen beide.
3. **Schulvertrag** wird zum Lesen verlinkt und digital unterschrieben. **Beide Unterschriften nötig**, heute als einfache elektronische Signatur.
4. **Gesundheitsdaten** — Abfrage ist freiwillig, es wird zuerst gefragt, ob man sie beantworten will.
5. **Fotoeinverständnis** — kann angenommen oder abgelehnt werden.
6. **SEPA-Mandat** — **eine** der beiden Personen füllt es aus.
7. **Frist 14 Tage.** Sind beide durch und alle Konflikte geklärt, prüft das **Sekretariat** auf Vollständigkeit und Richtigkeit und bestätigt. Danach kontrolliert die **Schulleitung**, gibt frei und setzt ihre Unterschrift. Erst dann geht die Bestätigungsmail mit dem abgeschlossenen Vertrag an die Eltern.
8. Danach: Neuanlage in ASV-BW.

### 7.2 Erhobene Felder — Gesundheitsdaten

`Einwilligung Mutter`, `Einwilligung Vater`, `Lebensmittelunverträglichkeit` + `Art`, `Allergien` + `Art`, `Chronisch krank` + `Art`, `Medikamente` + `Welche`, `Kind braucht Unterstützung` + `Welche`, `Attest für Medikamente`, `Erlaubnis für Unterstützung`, `Akuter Notfall`, `Notfallmedikamente`, `Beschreibung Notfallsituation`, `Attest zur Notfallmedikation`, `Erlaubnis zur Verabreichung im Notfall`, `Körperliche Einschränkung` + `Art`, `Diese Tätigkeiten dürfen nicht ausgeführt werden`, `Attest zur Einschränkung`, `Zecken entfernen`, `SignaturMutter`, `SignaturVater`

Derselbe Satz wird zusätzlich auf allen vier Anmeldetag-Checklisten und im Hortvertrag erhoben — sechs Formulare, ein Datenbestand. Die Checklisten ergänzen Seh-/Hörschwäche und therapeutische Maßnahmen samt Behandlungsgrund und -zeitraum. Struktur und Zugriffsstufen: `domains/grenzkarte.md`, „Gesundheitsmerkmal (9)".

### 7.3 Erhobene Felder — Fotoeinverständnis

`Zustimmung Mutter`, `Zustimmung Vater`, `Zustimmung Kind`, `Kind Mail`, `Kind Unterschrift Pfad`, `SignaturMutter`, `SignaturVater`, `SignaturKind`

**Ab 14 Jahren muss das Kind selbst mit unterschreiben.** Die private Adresse, an die sein Signaturlink geht, bleibt an der Zustimmungszeile und wandert nicht in die Stammdaten.

**Zugriffsanforderung aus dem Alltag:** Die Fotoerlaubnis müssen **alle Lehrkräfte, Hortmitarbeiter und das Sekretariat** nachschlagen können — sie ist die am breitesten gelesene Einwilligung im System und braucht eine Ansicht, die ohne Umweg beantwortet „darf dieses Kind fotografiert werden".

### 7.4 Erhobene Felder — SEPA-Mandat

`Weicht Kontoinhaber ab`, `Vorname`, `Nachname`, `Straße`, `Hausnummer`, `PLZ`, `Wohnort`, `E-Mail`, `Konto_Name`, `Konto_Nachname`, `IBAN`, `BIC`, `Kreditinstitut`, `Unterschrift`

Drei Festlegungen dazu:

- **Das Unterschriftsdatum ist wichtig** — gedeckt durch `children.mandate_signed_at` (`domains/stammdaten.md`, „Zahlungsverantwortliche").
- **Die BIC bleibt**, aber nur für **nicht-deutsche Konten**: Optigem verlangt sie. `payers.bic` ist damit nicht streichbar (`domains/stammdaten.md`, „Zahlungsverantwortliche").
- **Das SEPA-Mandat ist für alle Neuanmeldungen Pflicht, weil es an das Kind gebunden ist:** Verlässt das erste Kind die Schule, verfällt es auch für die noch eingeschriebenen Geschwister. Je Kind wird deshalb ausdrücklich ein eigenes Mandat eingesammelt — im Schema `children.mandate_reference`/`mandate_signed_at`, während die Bankverbindung bei der zahlenden Person bleibt (`domains/stammdaten.md`, „Zahlungsverantwortliche").

### 7.5 Sonderfälle

- Eltern schließen den Vertrag ab und **treten dann doch zurück oder kündigen**, bevor das Kind je an der Schule war. Kein Stammdaten-Fall: Das Eintrittsdatum wurde nie gesetzt, es ist ein Endstatus der Bewerbung.
- Das Sekretariat hat schon **individuelle Verträge** erstellt: Passagen gestrichen, weil Eltern das wollten, oder handschriftlich ergänzt. Jede Regel im System braucht deshalb einen benannten legitimen Ausweg, sonst wird sie umgangen statt eingehalten.

---

## 8. Hortvertrag und Betreuungsmodule

**Soll digitalisiert werden.** Heute Papier, ausgefüllt am Anmeldetag oder danach.

**Laufzeit:** gültig bis **Ende Klasse 4**, danach automatisch gekündigt — das Kind ist ab dann möglicherweise kein Schüler mehr. Ein Vertrag für **Klasse 5 gilt nur für Klasse 5**. Das Hortangebot endet mit Klasse 5.

**Externe Kinder:** Der Hort nimmt Kinder auf, die **weder Grund- noch Realschüler** sind. Ein Hortvertrag kann also ohne Einschreibung bestehen.

**Gesundheitsdaten:** Der Hort braucht sie ebenfalls, und der heutige Hortvertrag erhebt sie deshalb **selbst noch einmal** — mit demselben Bogen wie Grund- und Realschule. Beim Zusammenführen ist zu prüfen, dass für den Nachmittag nichts fehlt, was die Schulanmeldung nicht abfragt, und dass externe Hortkinder überhaupt einen Satz bekommen.

**Erhobene Felder:**

- Vor- und Nachname von Mutter und Vater
- Datum der Aufnahme in den Hort
- Vorname, Nachname, Geburtsdatum des Kindes
- Wohnadresse des Kindes
- Notfallnummer, erreichbar während der Betreuungszeit
- Unterschrift von Mutter und Vater
- Gesundheitsdatenbogen (wie Grund-/Realschule, siehe 7.2)
- Fotoeinverständnis (wie Grund-/Realschule, siehe 7.3)
- **Einwilligung zum Informationsaustausch** zwischen Hort und Grund- bzw. Realschule über den Entwicklungsstand, zur bestmöglichen Förderung
- Auswahl der Betreuungsmodule, siehe unten

**Betreuungsmodule.** Mehrere gleichzeitig buchbar, **je Modul werden die einzelnen Tage gewählt**:

| Modul | Zeit |
|---|---|
| Frühbetreuung | 7:00 bis Schulbeginn |
| Nachmittagsbetreuung 1 | Schulende bis 13:00 |
| Nachmittagsbetreuung 2 | Schulende bis 14:30, inkl. Hausaufgabenbegleitung, feste Abholzeit |
| Nachmittagsbetreuung 3 | Schulende bis 13:30, inkl. Hausaufgabenbegleitung, feste Abholzeit |
| Nachmittagsbetreuung 4 | Schulende bis 17:00, inkl. Hausaufgabenbegleitung, ab 15:30 flexible Abholzeit |
| Hort nach Mittagschule | nur Realschule Klasse 5, 15:00–17:00 |

Modul × Wochentag ist damit die Buchungseinheit, nicht das Modul allein. Eingezogen wird über dasselbe SEPA-Mandat wie das Schulgeld.

**Laufender Hort-Alltag bleibt draußen** (`fachdomaenen.md` Abschnitt 6): Der Hort führt eigene, sehr umfangreiche Excel-Dateien darüber, wer wann gebucht ist, und notiert dort auch Vorfälle und Verhalten.

---

## 9. Mensa

- Buchung läuft über das **Sekretariat**, gepflegt wird eine einzige Excel-Liste: welcher Schüler wann zum Essen kommt.
- Abgerechnet wird über die Buchhaltung mit dem **SEPA-Mandat aus der Schulanmeldung**.
- Die Essensberechtigung wird bei der Ausgabe **auf Papier** geprüft — bei den wenigen Kindern heute im Kopf merkbar.
- Es gibt ein **Anmeldeformular, das noch nicht vorliegt** und nachgereicht werden muss.

---

## 10. Ferienprogramm und Kochwerkstatt

**Ablauf:**

1. Ein Formular, in dem Eltern **mehrere Kinder auf einmal** anmelden (drei Kinder heißt nicht drei Formulare).
2. Aus den verfügbaren Terminen werden die gewünschten gewählt, dazu je Termin **Betreuungsende 14 oder 16 Uhr**.
3. Angaben daneben: ob es ein Kind der eigenen Schule ist, Notfallnummer, E-Mail, Einwilligung in Werbung per Mail, bei schulfremden Kindern die Adresse, dazu Freitext-Anmerkungen.
4. **Bezahlung beim Absenden.**
5. Buchungsbestätigung per Mail; bei schulfremden Kindern wird eine **Fotoeinverständnis-Erklärung mitgeschickt**, die ausgefüllt zurückkommen soll.

**Erhobene Felder (heutige Excel-Spalten):** `Wichtige Notizen`, `Notfall-Nummer`, `Clemens`, `Name`, `Vorname`, `Geburtstag`, je Angebotstag zwei Spalten (`Mo 26.10, 14:00` / `Mo 26.10, 16:00`, …), `E-Mail`, `Werbung per Mail`, `Adresse`, `PLZ`, `Wohnort`, `Bemerkung`

**Kapazität:** begrenzt pro Tag; die Anmeldung wird **dynamisch vor Programmbeginn geschlossen**, weil vorab eingekauft und geplant werden muss — auch dann, wenn rechnerisch noch Platz wäre.

**Stornierung:** läuft per Mail an den Hort, der seine Excel-Datei von Hand nachzieht.

**Offen:** Es gibt **keine Regel, was nach dem Ferienprogramm mit den Daten geschieht.** Schulfremde Kinder haben kein Austrittsdatum als Fristanker (`idea/06-dsgvo-organisatorisch.md`).

---

## 11. Putzdienst

Vollständig in `domains/putzdienst.md`; hier nur, was dort fehlt oder abweicht.

- **5+1 ist Pflicht für alle Familien**, ausgenommen **Mitarbeiterfamilien**. Die Menge gilt **pro Familie unabhängig von der Schulart**: ein Kind in der Grundschule und eines in der Realschule bleibt 5+1, nicht 2×(5+1).
- **Quereinsteiger** leisten anteilig; ab Jahreshälfte gilt **2+1** — die Hälfte von 5+1.
- **Erlass in Einzelfällen** (schwere Schicksalsschläge) — wird individuell geregelt, **darf nach außen nicht sichtbar sein** und nur von einem sehr kleinen Personenkreis ausgelöst werden können.
- **Zwei Freikäufe:** in der Buchungsphase **210 € komplett** für die ganze Jahrespflicht, im laufenden Betrieb **35 € je einzelnem Termin**, wenn eine Familie doch nicht kann — Letzteres zwingend **vor dem Termindatum**. Damit ersetzt der Einzel-Freikauf die Strafe, statt sie zu umgehen.
- **Anwesenheit** über Elternunterschriftenliste auf Papier. Erfasst wird **nur, ob jemand da war oder nicht** — der Putzdienst führt **keinen Stundennachweis**, weder auf Papier noch digital. Gezählt wird in Terminen (5+1), nicht in Stunden; Stundenzettel gibt es allein beim Elternbonus (Abschnitt 12).
- **Strafe bei Nichterscheinen: 45 €**, eingezogen über die Schulgeldabrechnung. Sie wird **immer verhängt**; wer die Berechtigung hat, kann sie danach aussetzen — ein festgehaltener Vorgang, keine unterlassene Forderung.

Modell und Herleitung: `domains/putzdienst.md`. Was das gebaute Schema für Einzel-Freikauf und Straf-Aussetzung noch nicht trägt, steht dort ebenfalls.

---

## 12. Elternbonus Elternmitarbeit

Zweite Anlage zum Schulvertrag neben der Putzdienstregelung. **Heute reiner Papierprozess über das Sekretariat.**

**Mechanik:**

- Jede Familie zahlt bei **einem** Kind **10 € pro Monat zusätzlich**, August ausgenommen — also **110 € im Schuljahr**.
- Zu leisten sind **15 Stunden bei einem Grundschüler**, **10 Stunden bei einem Realschüler**. **Nicht additiv** — der größere Wert entscheidet.
- Die im Schuljahr geleisteten Stunden werden **anteilig zurückgezahlt**: volle 110 € bei erreichten 15 bzw. 10 Stunden, sonst anteilig.
- **Mehrgeleistete Stunden verfallen.** **Zu spät abgegebene Stundenzettel ebenfalls.**
- Tätigkeiten sind sehr unterschiedlich, es gibt **keinen festen Schlüssel** — Mitarbeitsstunden werden dynamisch von der Schule oder Beauftragten aufgerufen.
- **Putzdienst zählt nicht** in dieses System.
- **Elternbeirat zu sein erfüllt automatisch die vollen Stunden.**

Der Stundenzettel gehört damit **allein hierher**: der Putzdienst kennt keinen, er zählt Termine (Abschnitt 11). Beide sind Anlagen desselben Schulvertrags und messen Verschiedenes. Scope-Einordnung: `fachdomaenen.md` Abschnitt 6, Domäne 11 — weiterhin ausdrücklich nicht v1.

---

## 13. Rechnungsfreigabe / Buchungsbelege

Läuft stabil, deshalb niedrige Migrationspriorität. Bestehender Code: `~/Documents/SPFX/bookingreceiptprocess/`.

1. Mitarbeiter reichen Rechnung oder Fahrtkosten samt Beleg über ein Formular ein; Sekretariat und Buchhaltung tun dasselbe für reguläre Rechnungen der Schule.
2. Beide wählen die **Führungskraft**, in deren Bereich die Ausgabe entstanden ist.
3. Die Führungskraft gibt frei, lehnt ab, korrigiert, **leitet weiter** oder **teilt den Beleg auf mehrere Bereiche auf**; bei Aufteilung muss jede beteiligte Führungskraft ihren Anteil annehmen.
4. Beim Annehmen werden **Projektnummer und Buchungskonto** vergeben.
5. Angenommene Belege gehen an die Buchhaltung. Bei Ablehnung bekommt der Einreicher eine Information mit Begründung.

Dateien und Daten liegen vollständig in **SharePoint**, kein Excel.

---

## 14. M365-Kontenverwaltung (heute Vis365)

Vollständig Handarbeit des zweiten Admins.

- **August:** Konten der neuen Schüler für das kommende Schuljahr anlegen.
- Mitarbeiter und Schüler, die gehen, werden von Hand gelöscht — **sofern es dem zweiten Admin mitgeteilt wird**.
- **Offboarding:** automatische Antwort einrichten, Passwort hart zurücksetzen, Konto nach einer Frist vollständig löschen.
- Die Information kommt meist aus Sekretariat oder Geschäftsführung — genau dort reißt der Faden (siehe Abschnitt 16).
- Getrennte Domains im gemeinsamen Tenant mit der KITA: Schüler `c-schule.de`, Schulmitarbeiter `clemens.schule`, KITA-Mitarbeiter `clemenskita.de`.

---

## 15. Schuljahreswechsel

- **Ende Juli:** ASV-BW-CSV-Import der neuen Schüler — deckt nicht alles ab, es bleibt viel Handarbeit.
- **Ende Juli:** Der zweite Admin legt neue Schüler an, löscht Abgänger, zieht alle Klassen auf die neue Stufe um (Gruppen umbenennen, Mailverteiler nachziehen).
- **August:** Sommerpause. Es läuft nur das Ferienprogramm des Horts und die Rechnungsbearbeitung.
- **Anfang September:** Terminkalender mit den Festen festlegen → daraus Putztermine planen → Putzdienst-Anmeldung freigeben.
- **Ende September:** Schulstatistik des Landes. ASV-BW muss dafür vollständig gepflegt sein, damit der Export alle relevanten Daten enthält.

---

## 16. Abgang und Schulwechsel

Sekretariat und Schulleitung erfahren es zuerst, ASV-BW wird gepflegt. Alles Weitere — Bescheinigungen, M365-Konto, Abmeldung bei Mensa, Hort und AGs, Optigem — läuft über Zuruf an hoffentlich die richtigen Personen, die hoffentlich wissen, was zu tun ist. **Kein definierter Prozess.**

---

## 17. DSGVO-Datenauskunft

- **Kein fixer Prozess definiert.**
- Herausgegeben wird in jedem Fall die **digitale Schülerakte** (SharePoint, geführt vom Sekretariat) mit allen Dokumenten zur Person: Schulvertrag, Gesundheitsdaten, Fotoeinverständnis und was im Lauf der Zeit dazukam.
- Der Rest ist offen.

---

## 18. KITA — Berührungspunkte

- KITA-Kinder wechseln gegebenenfalls in die eigene Grundschule. Da die KITA-Kinder nicht vorgehalten werden, ist das **wie eine externe Anmeldung** zu behandeln.
- Die **KITA-Anmeldung läuft über die Stadt**, nicht über die Schule.
- Geteilt werden: der **Office-365-Tenant** (getrennte Domains, siehe 14), **Räume und Ressourcen** vor Ort, und der **Belegprozess**. Sonst keine digitale Überschneidung.

---

## 19. Krankmeldung — wird nicht umgesetzt

**Die Schulleitung will das nicht.** Eltern schicken weiterhin selbst eine Mail an mehrere Empfänger. Domäne 10 ist deshalb gestrichen (`fachdomaenen.md` Abschnitt 6); die Nummer bleibt vergeben, damit die übrigen Domänen-Nummern stabil bleiben.

---

## 20. AGs

Zukunftsprojekt, nichts Konkretes bekannt.

---

## 21. Abweichungen zum gebauten Modell — alle entschieden

Keine offenen Widersprüche mehr. Was die Erhebung an Abweichungen zutage gefördert hat, ist beantwortet und eingearbeitet:

| Abweichung | Ergebnis |
|---|---|
| **SEPA-Mandat** | bestätigt: je Kind eines. Im Schema von `payers` nach `children` verlagert, vor dem Freeze und damit ohne Migration (`domains/stammdaten.md`) |
| **Quereinsteiger-Proration** | bestätigt: 2+1 ab Jahreshälfte. Formel rundet ab, mit Untergrenze 1 je Terminart (`domains/putzdienst.md`) |
| **Putzdienst-Freikauf** | zwei getrennte Vorgänge: komplett in der Buchungsphase, einzeln vor dem jeweiligen Termin |
| **Strafe** | wird immer verhängt, aussetzbar nur mit Berechtigung |
| **Stundennachweis** | gibt es im Putzdienst nicht — nur Anwesenheit; Stunden zählt allein der Elternbonus |

Alle fünf stehen auch im Schema: Stammdaten und Putzdienst sind gegen diese Erhebung nachgezogen und durch ihre Prüfskripte belegt.

---

## 22. Offene Fragen ohne Modellbezug

Die Fristen-gebundenen Punkte stehen in `TODO.md`, die entwurfsgebundenen in `domains/grenzkarte.md`, „Weiße Flecken". Übrig bleibt, was allein aus dieser Erhebung offen ist:

| Frage | Wen fragen | Spätestens vor |
|---|---|---|
| Ist der „Einschulungsuntersuchungsbericht" der Checkliste das interne Lehrerformular? | Sekretariat | Domäne 2/4 |
| Lassen sich die Lehrkräfte von Excel weg zur digitalen Bewertung bewegen? | Schulleitung | Domäne 2/4 |
| Welche Excel-Listen existieren darüber hinaus? | Verwaltung, Hausdienstverwaltung, Hort | laufend |
| Was im Jahreslauf regelmäßig vergessen wird — es sind „Kleinigkeiten", die Schmerzpunkte sind unbekannt | Sekretariat | offen |

---

## 23. Randbedingungen für jede Oberfläche

Zwei Beobachtungen, die kein Prozess sind, aber jeden Entwurf binden:

- **Die Schule biegt sich jeden Prozess zurecht, wo sie es kann.** Individuell geänderte Schulverträge (7.5) und der Umweg über das Quereinsteigerformular (3.4) sind dieselbe Bewegung. Jede harte Sperre braucht einen benannten legitimen Ausweg.
- **Das Sekretariat ist nicht IT-affin**, vergisst Abläufe regelmäßig, weiß sich oft nicht zu helfen und lässt Unfertiges eher liegen, als nachzufragen — und beschwert sich nicht bei denen, die etwas ändern könnten. Bedienführung muss durch den Vorgang **führen** statt ihn nur zu ermöglichen, und Fehlerzustände müssen aktiv melden statt auf Rückmeldung zu warten (`rules.md` Abschnitt 3).
