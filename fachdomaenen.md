# Fachdomänen — Scope

Vor der ersten Fachdomäne (`CLAUDE.md`, „Nächster Schritt") klären, was Weltenbaum fachlich überhaupt abbilden soll — sonst trifft die erste Domäne Annahmen, die eine spätere wieder umwirft. Grundlage für die Domänen-Liste (jetzt + absehbar später) und die Auswahl der ersten Domäne.

Diese Datei trägt den **Scope**, `prozesse.md` den **Ist-Stand**: dort steht je Prozess der heutige Ablauf, das Werkzeug und die real erhobene Feldliste. Was hier je Domäne als Kurzbeschreibung steht, ist die Auswertung daraus.

## 1. Aktuelles Angebot der Schule

Christliche private Grund- und Realschule in Baden-Württemberg, Klasse 1–10, ca. 500 Schüler. Unterliegt den allgemeinen staatlichen Vorgaben, hat darüber hinaus eigene Besonderheiten. Aufnahme selektiv: Voranmeldung (bereits gebührenpflichtig) → Anmeldegespräch → Anmeldeprozess.

Angebote für Schüler/Eltern im laufenden Schulbetrieb:
- **Putzdienst:** Pflicht-Putztermine je Familie (regulär + Großputz), gegen Gebühr freikaufbar
- **Hort:** Ganztagesbetreuung Klasse 1–4 in sechs buchbaren Modulen von der Frühbetreuung ab 7:00 bis 17:00, optional gegen Aufpreis, Ausweitung angedacht. Ein eigenes Modul deckt Realschule Klasse 5 nach der Mittagschule ab; **mit Klasse 5 endet das Angebot**. Der Hort nimmt auch Kinder auf, die weder Grund- noch Realschüler sind (`prozesse.md` Abschnitt 8)
- **Hausaufgabenbetreuung:** nur als Bestandteil einzelner Hort-Nachmittagsmodule — welche eines tragen, sagt ein Häkchen am Modul und nicht die Uhrzeit, denn es gibt Module über Mittag ohne sie (`schema/anmeldung-schema.sql`); gesondert gebucht und berechnet wird sie nicht. Ein eigenständiges Realschul-Angebot (Lernbetreuung) gibt es nicht — mangels Interesse eingestellt
- **AGs:** einzelne Arbeitsgemeinschaften
- **Mensa:** Anmeldung je Wochentag als Schuljahres-Abo (Oktober–Juli, kündbar zum Halbjahr — Formular in `prozesse.md` Abschnitt 9), gebührenpflichtig, berechtigt zum Essen an den gebuchten Wochentagen; für Hortkinder folgt das Mittagessen automatisch aus Modulen mit Betreuung über 13 Uhr

Weitere Einrichtungen/Angebote:
- **KITA:** eigener Alltag nicht Teil des Scopes, aber KITA-Mitarbeiter brauchen bereichsübergreifend Zugriff auf mindestens einen Prozess (Buchungsbeleg-/Rechnungsfreigabeprozess)
- **Ferienprogramm** (über den Hort): in allen Ferien außer den Weihnachtsferien, wochenweise mit wechselndem Thema, offen für alle Kinder bis zu einem bestimmten Alter — **auch für schulfremde Personen offen**, nicht nur für die Kochwerkstatt. Es gibt bereits jetzt Kinder/Eltern, die das nutzen, ohne offiziell an der Grund- oder Realschule angemeldet zu sein.
- **Kochwerkstatt:** für Kinder, gedacht für 8 bis 13, auch für schulfremde offen
- Geplant: Ausweitung des außerschulischen Angebots allgemein

### Jahreskalender der Verwaltung

Der reale Betriebsrhythmus, an dem die Prozesse hängen — Grundlage für die Reihenfolge unten und für den Zeitpunkt des Jahreslaufs (`schema/stammdaten-schema.sql`).

| Monat | Was passiert |
|---|---|
| Oktober | Voranmeldung für das Folgejahr wird veröffentlicht (zu den Herbstferien); Putzdienst-Zyklus beginnt |
| Januar | Infoabend für die bereits angemeldeten Kinder, danach regelmäßig ein zweiter Anmeldeschub |
| Januar/Februar | Voranmeldung wird geschlossen — Zeitpunkt je Schule dynamisch gesetzt, teils erst im Juni |
| ab Februar | Anmeldegespräche, Aufnahmeentscheidung, Schulvertragsprozess |
| Ende Juli | ASV-BW-CSV-Import der neuen Schüler (deckt nicht alles ab, viel Handarbeit); M365: neue Konten anlegen, Abgänger löschen, Klassen/Gruppen/Verteiler umziehen |
| August | Sommerpause — nur Ferienprogramm im Hort und laufende Rechnungen |
| Anfang September | Terminkalender/Feste festlegen → Putztermine planen → Putzdienst-Anmeldung freigeben |
| Ende September | Schulstatistik des Landes — ASV-BW muss dafür vollständig gepflegt sein |

Ganzjährig und außerhalb dieses Rhythmus: Quereinsteiger-Anmeldung samt Schulvertrag, Ferienprogramm in allen Ferien außer Weihnachten, Mensa- und Hortbuchungen, Rechnungsfreigabe.

### Zeitliche Dringlichkeit (nächste 12 Monate)

Reihenfolge, in der die Prozesse im Jahresverlauf wieder akut werden:
1. **September — Elternputzdienst:** Buchungsfenster öffnet, gebucht wird für den Zeitraum Oktober–September des Folgejahres. Auswahl unter verfügbaren Terminen oder Freikauf gegen Gebühr; Personen ohne gebuchte Termine werden am Ende automatisch auf die restlichen freien Termine verteilt. Hat noch weitere Detailregeln, die später folgen. **Nächster fälliger Prozess.**
2. **bis Ende Oktober — Voranmeldung**
3. **ab spätestens Weihnachten — Ferienanmeldung**
4. **ab Februar — Anmeldeprozess + Anmeldegespräche** müssen stehen

## 2. Bestehende Software

- **ASV-BW:** amtliche Schulverwaltungssoftware, Pflicht für die jährliche Schulstatistik; für staatliche Schulen konzipiert, deckt daher nicht alle eigenen Besonderheiten ab
- **Optigem:** Buchhaltung
- **Untis** (Desktop; WebUntis gibt es an der Schule nicht): Noten, Stundenpläne etc. in der Realschule — dauerhaft out of scope, hier nicht im Detail betrachtet. Die Quereinsteiger-Checkliste führt unter „To do Lehrer" noch „WebUntis anmelden" — ein Punkt ohne Entsprechung, der mit der Ablösung der Checkliste wegfällt
- **Office 365:** zentrale Ablage für alles, was in keinem der drei genannten Tools abgebildet ist (Mail, Dateien, …)
- **Jotform:** Formulare
- **Fobizz:** KI-Werkzeuge für den Unterricht — out of scope; führt keine Stammdaten und berührt Weltenbaum nicht
- **AGFEO:** Telefonsoftware; dort liegt die Notfallnummer. Weltenbaum schreibt nie dorthin — offen ist allein, ob eine geänderte Nummer eine Aufgabe auslöst (`backlog/`)

## 3. Aktuelle Probleme

### Stand der Digitalisierung

Automatisiert sind Voranmeldung (Grundschule, Realschule, Quereinsteiger), Anmeldeprozess, Putzdienst und Ferienprogrammanmeldung — alle mit Excel als Datenbank, angebunden über zwei Werkzeuge:

1. Jotform-Formulare für alle sechs genannten Prozesse
2. Power Automate: schreibt Formulardaten automatisch in Excel-Listen, übernimmt Mailversand

Einzige Ausnahme ist die Rechnungsfreigabe: SPFx-Teams-App plus Power Automate, Daten in SharePoint statt Excel.

**Geprüft und verworfen:** SharePoint-Listen als feste Struktur, per Power Query nach Excel synchronisiert. Die Verwaltung bearbeitet Daten direkt in der Power-Query-Tabelle, ein Refresh überschreibt diese Änderungen wieder — der Weg scheidet damit für jede künftige Lösung aus, nicht nur für einen Anlauf.

Ergebnis: viele parallele Excel-Dateien pro Prozess, hoher Wartungsaufwand (z. B. bricht ein in Teams verschobener Datei-Link den Prozess, ohne dass die verschiebende Person das merkt), unsauberer/inkonsistenter Datenstand — unabhängig von ASV-BW, Optigem und Office 365.

- **Anmeldeprozess:** der am weitesten entwickelte — Power-Automate-HTTP-Trigger + Jotform simulieren Frontend und Backend, private (ungeteilte) Excel-Tabellen steuern den Prozess. Funktioniert, ist aber fragil.
- Manuelles Eingreifen ist nicht auf einzelne Prozesse beschränkt: Verwaltung oder Hort verursachen in allen Prozessen laufend Fehler, die manuell korrigiert werden müssen.
- Wo ein Prozess im Weg steht, wird er umgangen statt gemeldet: Eltern, die die Voranmeldung verpassen, laufen heute über das Quereinsteigerformular und landen damit in der falschen Liste; das Sekretariat hat schon individuelle Schulverträge mit gestrichenen oder handschriftlich ergänzten Passagen ausgestellt. Für jede künftige Regel heißt das: eine harte Sperre braucht einen benannten legitimen Ausweg (z. B. Einzel-Nachmeldelink über das Sekretariat), sonst wird sie umgangen statt eingehalten.

### Kein Prozess für alltägliche Datenänderungen

Der häufigste Vorgang überhaupt hat als einziger gar keine Automatisierung: Umzug, neue Telefonnummer oder E-Mail-Adresse, Namensänderung, Trennung oder neuer Sorgerechtsbeschluss, neuer Notfallkontakt kommen per Mail, Telefon oder persönlich ans Sekretariat. Je nach Änderung und Status der Familie muss sie danach in ASV-BW, Optigem und Excel nachgezogen werden, bei einer E-Mail zusätzlich in Office 365 — ohne dass irgendetwas prüft, ob das überall passiert ist. Änderungen gehen dabei verloren oder landen nur in einem System, und es fällt niemandem auf. Das ist der stärkste einzelne Treiber für das Zielbild in Abschnitt 4 und gehört zur Stammdaten-Domäne (Abschnitt 6), nicht zu einem der Formularprozesse.

**Zielbild dafür:** die Änderung passiert **zuerst in Weltenbaum**, und Weltenbaum erzeugt daraus eine Notiz, in welchem Fremdsystem sie noch nachzuziehen ist. Solange ASV-BW und Optigem keine Update-Schnittstelle haben (Abschnitt 4), bleibt das Nachziehen Handarbeit — aber es ist dann eine benannte, nachverfolgbare Aufgabe statt eines Vorgangs, an den sich jemand erinnern muss. Welche Änderung welches System betrifft, ist aus dem geänderten Feld ableitbar und damit kein Erfahrungswissen mehr.

Denselben Charakter hat der **Abgang eines Kindes**: Sekretariat und Schulleitung erfahren es zuerst, ASV-BW wird gepflegt, alles Weitere (Konto, Mensa, Hort, Optigem, Bescheinigungen) läuft über Zuruf an hoffentlich die richtigen Personen — ebenfalls kein definierter Prozess. Und die **regelmäßigen Elternmails** (Elternbriefe, Erinnerung an Elternabende, allgemeine Informationen) stößt das Sekretariat von Hand an; automatisiert sind nur die Mails der Formularprozesse.

### Wer welche Liste heute führt

Ansprechpartner je Migration — der Betreiber hat auf die meisten dieser Dateien selbst keinen Zugriff.

| Liste | geführt von |
|---|---|
| Hortliste, Ferienprogramm | Hort |
| Voranmeldung | Sekretariat + Schulleitung |
| Anmeldeprozess | Betreiber selbst |
| Kochwerkstatt | Hausdienstverwaltung |
| Mensaliste | Hausdienstverwaltung + Sekretariat |
| Gesundheitsdaten | Sekretariat |
| Digitale Schülerakte | Sekretariat (SharePoint, nicht Excel) |
| iPad-/Leihgeräteliste | Realschule, extern begleitet |

**Randbedingung für jede Oberfläche:** das Sekretariat ist nicht IT-affin, vergisst Abläufe regelmäßig und meldet Probleme nicht denen, die sie beheben könnten — Unfertiges bleibt eher liegen, als dass nachgefragt wird. Bedienführung muss deshalb durch den Vorgang führen statt ihn nur zu ermöglichen, und Fehlerzustände müssen aktiv nach außen melden statt auf eine Rückmeldung zu warten (`rules.md` Abschnitt 3).

### Datenflüsse zu ASV-BW / Optigem / Office 365

- **ASV-BW:** enthält die Stammdaten aller Schüler; neue Schüler werden nach abgeschlossenem Anmeldeprozess dort angelegt, spätere Änderungen laufen ebenfalls dort ein. Ob darüber hinaus weitere Daten dort geführt werden, ist unklar — die Dateneingabe erfolgt nicht selbst, sondern nur die Prozessautomatisierung drumherum.
- Daten, die ASV-BW nicht abbilden kann (z. B. Schulvertrag, Gesundheitsinformationen), liegen in Excel/SharePoint Teams.
- **Optigem:** Abrechnung aller Gebühren (Schulkosten, Mensa, Putzdienst-Freikauf, Ferienprogramm) sowie laufender Rechnungen/Ausgaben. Die Bankverbindung samt SEPA-Mandat wandert einmal von Hand dorthin, sobald die Verträge vorliegen — kein Import, kein laufender Abgleich; bis dahin ist Weltenbaum führend (`schema/stammdaten-schema.sql`).
- **Rechnungsfreigabe:** eigener, stabil laufender Prozess über eine Teams-App (SPFx) + SharePoint-Listen, PDFs in SharePoint, mit rudimentärer Rechteverwaltung.

## 4. Zielbild

- **Kurzfristig:** alle Prozesse, die aktuell über Excel-Listen laufen, auf eine echte Datenbank mit sauberen Frontends/Backends umziehen — Prozesse einfacher, effizienter, klar definiert; die Verwaltung soll alles Relevante selbst verwalten können, unabhängig von manueller Handarbeit außerhalb der Verwaltung selbst.
- **Mittelfristig:** auch die Microsoft-365-Kontenverwaltung abdecken (aktuell über Vis365, ein Tool des Microsoft-Vermittlers, mit Einschränkungen wie max. 2 Kontaktpersonen pro Kind).
- **Langfristig:** die Weltenbaum-Datenbank als einzige Quelle der Wahrheit für die Verwaltung. Aktueller Zustand: Eltern werden in ASV-BW und Optigem parallel gepflegt, Kinder in ASV-BW und Untis, Lehrer in allen drei Programmen, dazu alle Accounts (Lehrer/Personal/Schüler) separat in Office 365, Elternadressen und Klassen-Verteilerlisten ebenfalls dort (Eltern selbst haben keinen eigenen Account) — hoher doppelter Pflegeaufwand, unklar welcher Datenstand jeweils aktuell/korrekt ist.
- **Explizit nicht im Fokus:** der eigentliche Schulalltag (Noten, Stundenplan) — zu komplex, dafür bestehen mit Untis bereits gute Tools mit einer (kleinen) API.
- **Noch ungeklärt:** wie mit Optigem und ASV-BW umgegangen wird — beide haben aktuell keine nutzbare API. ASV-BW gilt als gesetzt (Pflicht-Schulstatistik, muss flexibel auf kurzfristige gesetzliche Vorgaben reagieren können). Neue Schüler lassen sich nur nach ASV-BW importieren; in Optigem müssen sie per Hand angelegt werden. Änderungen an bestehenden Datensätzen laufen in beiden Systemen ausschließlich manuell — kein Update-Import in keinem der beiden.
- **Vorerst:** Fokus liegt auf den Prozessen selbst — eine Ablösung/Anbindung von Optigem und ASV-BW ist nicht Teil des aktuellen Fokus. Der Weg neuer Datensätze nach ASV-BW ist ein **CSV-Export aus Weltenbaum, von Hand nachbearbeitet, dann in ASV-BW importiert**. Das ist kein Randdetail, sondern die Begründung für die Code-Spalten der Lookup-Tabellen (`schema/stammdaten-schema.sql`): der Export ist maschinell erzeugt und darf deshalb nicht auf frei umbenennbaren Bezeichnungen aufsetzen. Nach Optigem und für Änderungen an bestehenden Datensätzen bleibt es reine Handarbeit (kein Update-Import in beiden Systemen).

## 5. Nutzergruppen

Träger ist ein gemeinnütziger Verein. Hierarchie:
- **Vorstand:** nicht operativ, aber Entscheidungsmacht über das große Bild
- **Geschäftsführung:** operativer Kopf
- **Schulleitung und Bereichsleitungen** (je eine für Sekretariat, Hort, KITA, Grundschule, Realschule — bei Grundschule/Realschule zugleich der jeweilige Schulleiter): gleiche Ebene, unterhalb der Geschäftsführung
- **Übrige Mitarbeiter und Lehrer:** darunter, operative Nutzung teils bereichsübergreifend (KITA-Mitarbeiter z. B. im Buchungsbeleg-/Rechnungsfreigabeprozess, Abschnitt 1). Die **Hausdienstverwaltung** führt eigene Listen (Mensa gemeinsam mit dem Sekretariat, Kochwerkstatt allein) und ist damit eine eigene Nutzergruppe, auch ohne eigene Bereichsleitung

Konkrete Berechtigungen (wer darf/kann was) hängen vom jeweiligen Prozess ab und werden pro Fachdomäne separat geklärt.

**Schüler:** kein eigener Systemzugriff vorgesehen — durchgängig nur Datenobjekt, nie Akteur.

**Eltern:** interagieren aktuell ausschließlich passiv über Formulare (Ferienprogramm buchen, Voranmeldung, Putzdienst-Terminwahl, …). Ein Selfservice-Zugriff zur Korrektur eigener Stammdaten und eigener Kommunikationspräferenzen ist als nachrangiges Nice-to-have vorgesehen (Abschnitt 6, Domäne 8). Darüber hinausgehender Portalzugriff (z. B. Noten einsehen, Chat mit Lehrern) bleibt dauerhaft out of scope.

## 6. Domänen-Liste (jetzt + später)

Landkarte aus Abschnitt 1 (Kalender) und Abschnitt 4 (Zielbild), gegen die Prozesserhebung des Betreibers abgeglichen. Je Domäne steht dabei ihre **Stammdaten-Berührung**: was sie liest, was sie verändert, was sie neu erzeugt — die Schreib-Berührungen sind die, an denen sich das Schema entscheidet.

Grundlage, parallel zum ersten Punkt bearbeitet:
- **Stammdaten** (Kind, Erziehungsberechtigte, Familie, Kontakte) — eigenständige Fachdomäne, kein bloßes Nebenprodukt: jeder folgende Prozess baut direkt darauf auf. Kein eigenes Kalenderdatum, aber ohne sie kann Putzdienst nicht starten. Datenimport kommt komplett auf einmal (nicht schrittweise je Fachdomäne) — das Schema deckt deshalb von Anfang an den vollen Stammdaten-Kern der realen Datenquellen ab (Voranmeldeformulare und Vis365-Feldliste, `schema/stammdaten-schema.sql`), nicht nur Putzdienst-Minimalfelder. Details: `schema/stammdaten-schema.sql`.
  *Berührung:* Diese Domäne **ist** der Schreibpfad — die heute prozesslose alltägliche Datenänderung (Abschnitt 3) ist ihr eigentlicher Tagesbetrieb, nicht ein Nebenprodukt der Formularprozesse. Die Sekretariats-Oberfläche mit Vollzugriff auf alle Kind-Daten ist deshalb hoch priorisiert, bleibt aber nachrangig zu den terminlich gebundenen Prozessen unten.

Zeitkritisch, in Reihenfolge des Schuljahres:
1. **Putzdienst** (gebaut, `schema/putzdienst-schema.sql`) — Eltern wählen, tauschen oder kaufen sich frei, Verwaltung startet den Prozess und pflegt die Termine, Restzuordnung automatisch. Ziel: Schulanfang September 2026. → erste Fachdomäne (Abschnitt 7).
   *Berührung:* liest Familie, eingeschriebene Kinder samt Klassenstufe, den Beschäftigungszeitraum der Erziehungsberechtigten (Befreiung — geprüft gegen das Buchungsfenster des Zyklus, nicht gegen „heute" und nie auf `last_working_day IS NULL` verkürzt, `schema/putzdienst-schema.sql`) und die E-Mail aller natürlichen Personen der Familie, die von der Korrespondenz nicht abgewählt sind. Verändert und erzeugt **keine** Stammdaten — die einzige zeitkritische Domäne, die rein lesend ist.
2. **Voranmeldung** (gebaut, `schema/anmeldung-schema.sql`) — Erstkontakt/gebührenpflichtige Anmeldung, mündet ins Anmeldegespräch. Nicht nur für neue Familien: der Wechsel von der eigenen Grundschule in die eigene Realschule durchläuft denselben vollständigen Prozess, obwohl das Kind bereits in Stammdaten steht (`schema/stammdaten-schema.sql`). Für die Grundschule sind dagegen **alle** Bewerber extern — KITA-Kinder werden nicht vorgehalten. Grund- und Realschulformular sind feldgleich; das Quereinsteigerformular ist das Realschulformular plus Zielklasse und Zielschuljahr. **Feldgleich heißt dabei nicht bedeutungsgleich:** das Feld für die bisherige Einrichtung trägt bei der Realschule die abgebende Schule, bei der Grundschule den Kindergarten — mit entsprechend verschiedener Einwilligung daneben (`prozesse.md` Abschnitt 3.2). Fällig bis Ende Oktober 2026.
   *Berührung:* liest bei internen Übergängern die vollständige Kind- und Familienzeile. Verändert nichts. **Erzeugt** bei externen Bewerbern Person, Kind, Familie, Erziehungsberechtigte und Anschrift, und zwar **beim Absenden der Voranmeldung**, nicht erst bei der Aufnahme (`schema/anmeldung-schema.sql`): die Anmeldegebühr wird beim Absenden gezahlt, und Wartelisten-Rückfrage wie Vertragslink brauchen über Jahre eine Personenidentität. Dazu ein zweiter, bewerbungsseitiger Jahreslauf neben dem der Stammdaten: die Warteliste zieht jährlich eine Klassenstufe weiter (`grenzkarte.md`, „Bewerbung").
3. **Ferienanmeldung** (gebaut, `schema/ferien-schema.sql`; Ferienprogramm — die Kochwerkstatt gehört seit dem 01.09.2026 zur Akademie, Domäne 6) — Buchung durch Eltern, mehrere Kinder je Formular, gebucht wird je Tag und Betreuungsende (14 oder 16 Uhr), Bezahlung beim Absenden. Kapazität je Tag begrenzt, Anmeldeschluss dynamisch vor Programmbeginn (es muss vorab eingekauft/geplant werden). Erfasst außerdem eine Notfallnummer und, bei schulfremden Kindern, die Anschrift und die Gesundheitsangaben — die Programme sind interaktiv geworden, und bei einem fremden Kind gibt es keinen anderen Weg, auf dem der Bestand entstünde; bei einem Kind der Schule geben die Eltern den vorhandenen frei (`schema/gesundheit-schema.sql`). Stornierungen laufen heute per Mail an den Hort, der seine Excel-Liste von Hand nachzieht. Auch für schulfremde Personen. Fällig ab spätestens Weihnachten 2026.
   *Berührung:* liest, ob ein Kind eingeschrieben ist (das Formularfeld „Clemens-Kind" ist daraus ableitbar, kein eigenes Feld). Verändert nichts. **Erzeugt** schulfremde Kinder samt Familie, anmeldendem Elternteil und Notfallkontakt — bei Kostenübernahme durch das Jugendamt dagegen keinen Zahlungssatz, sondern einen `holiday_cost_coverage_codes`-Code (`grenzkarte.md`, Q3). Dabei zu beachten: der **Notfallkontakt braucht einen Namen, sobald er eine dritte Person ist** — die heutige Liste führt dort nur eine nackte Nummer, und ohne Namen scheitert seine `persons`-Zeile an `last_name NOT NULL`. Der Löschfrist-Anker `children.exit_date` bleibt bei diesen Kindern dauerhaft NULL (`dsgvo.md`).
4. **Anmeldeprozess, Anmeldegespräch und Schulvertrag** (gebaut, dieselbe Domäne wie 2) — vollständiger Aufnahmeprozess: Terminvergabe, Bewertung durch Lehrer samt Ranking und Notizen (Realschule zusätzlich mit bewerteten Testblättern), Aufnahme-/Warteliste-/Absageentscheidung, dann je ein persönlicher Link an Mutter und Vater. **Die Terminvergabe kehrt sich dabei um:** heute werden Termine zugeteilt und per Brief verteilt, und jede Verschiebung ist ein erheblicher Aufwand für das Sekretariat — künftig wählen die Eltern selbst aus einem angebotenen Raster. Das Raster selbst (Wochentage, Zeitfenster, Pause, Kinder je Stunde, Sondertermine) pflegt die Verwaltung als Daten, weil es sich immer wieder ändert; heutiger Stand in `prozesse.md` Abschnitt 5.1. Bei Quereinsteigern geht dem Gespräch eine Platzprüfung in der Zielklassenstufe voraus. Das Gespräch selbst erhebt **keine** Stammdaten, es gibt nur Informationen heraus. Der Vertragsteil danach: Platzannahme, Stammdatenbestätigung, Vertragsunterschrift (einfache elektronische Signatur), Gesundheitsdaten, Fotoeinverständnis, SEPA-Mandat — **Frist 14 Tage** für die Eltern, danach prüft das Sekretariat auf Vollständigkeit und die Schulleitung gibt frei und zeichnet gegen; erst dann geht die Bestätigungsmail mit dem abgeschlossenen Vertrag raus. Mündet in die Neuanlage in ASV-BW. Läuft für Quereinsteiger ganzjährig. Muss ab Februar 2027 stehen.
   *Berührung:* die schreibintensivste Domäne. **Verändert** Stammdaten durch Selbstauskunft — jeder Erziehungsberechtigte bestätigt oder korrigiert seine eigenen Daten, die des Kindes bestätigen beide (`schema/stammdaten-schema.sql`) — und setzt bei Aufnahme `children.entry_date` sowie `school_branch_id` und `grade_level` aus dem Ziel der Bewerbung; `class_id` setzt erst die Klassenbildung. **Erzeugt** je Kind eine `sepa_mandates`-Zeile mit IBAN/BIC und, bei abweichendem Kontoinhaber, dessen Anschrift und Mailadresse am Mandat selbst. Ab 14 Jahren muss beim Fotoeinverständnis zusätzlich das Kind selbst unterschreiben; die private Adresse, an die sein Signaturlink geht, bleibt an der Zustimmungszeile und wandert nicht nach `persons.email` (`schema/stammdaten-schema.sql`). Ihre eigenen Entitäten daneben — Bewerbung samt Bewertung, Vertragsvorgang, Betreuungsmodul und die vier signierten Dokumente — stehen in `grenzkarte.md`, Domäne 2/4.

Nicht terminlich getrieben, Priorität offen:
5. **Rechnungsfreigabe** (gebaut, `schema/rechnungsfreigabe-schema.sql`) — läuft bereits stabil über Teams-App/SharePoint (Abschnitt 3), daher niedrige Migrationspriorität. Ablauf: Mitarbeiter reichen Rechnung oder Fahrtkosten samt Beleg ein (Sekretariat/Buchhaltung ebenso für reguläre Rechnungen) und wählen die zuständige Führungskraft; die gibt frei, lehnt mit Begründung ab, korrigiert, leitet weiter oder **teilt den Beleg auf mehrere Bereiche auf** — dann muss jede beteiligte Führungskraft ihren Anteil annehmen. Beim Annehmen werden Projektnummer und Buchungskonto vergeben, danach geht der Beleg an die Buchhaltung. Bestehender SPFx-Code: `~/Documents/SPFX/bookingreceiptprocess/`.
   *Berührung:* liest Mitarbeitende — die Führungskraft wird je Beleg-Teil als Person gewählt, eine Bereichs-/Vorgesetztenstruktur darüber braucht die Domäne nicht (`grenzkarte.md`, Q4). Verändert und erzeugt keine Stammdaten.
6. **Mensa- und Akademie-Anmeldung** — Mensa ist gebaut (`schema/mensa-schema.sql`): das Küchenprofil je Kind und das eigenständige Schuljahres-Abo der Realschule samt seinen Wochentagen — eigene Tabellen, weil Beginn, Kündigung und Beitrag des Abos nicht denen eines Betreuungsmoduls folgen. Für Hortkinder folgt das Essen dagegen aus Modulen mit Betreuung über 13 Uhr und wird nirgends eigens angemeldet. Feldliste des Formulars und die heutige Papierprüfung der Essensberechtigung in `prozesse.md` Abschnitt 9. Die **Akademie** löst die AGs ab und ist entschieden (`soll-prozesse/21-akademie.md`): AG über das Schuljahr, Kurs an einem Nachmittag und Reihe über sechs Wochen sind ein Angebot mit einer Form, dazu Kategorien, begrenzte Plätze und eine Zielgruppe je Angebot; die Kochwerkstatt kommt aus Domäne 3 mit, und neben dem Kinder-Zweig steht der Erwachsenen-Zweig mit seinen Seminaren. Sie ist gebaut (`schema/akademie-schema.sql`). **Die beiden rechnen verschieden ab:** Beim Essen entsteht keine Zahlung, sondern nur die Erlaubnis, vom hinterlegten SEPA-Mandat abzubuchen (Q1), und abgerechnet wird über Optigem; bei der Akademie folgt der Weg dem Mandat — wer eines hat, wird eingezogen, wer keines hat, zahlt beim Absenden online (Q3).
   *Berührung:* rein lesend (Kind, Klasse). Verändert und erzeugt keine Stammdaten.
7. **M365-Kontenverwaltung** (gebaut, `schema/m365-schema.sql` — ohne eigene Tabellen, alles steht bereits an `employees`, `children` und `sync_tasks`; Ablösung/Ergänzung von Vis365) — mittelfristiges Ziel (Abschnitt 4), IT-Administration statt klassischer Schulprozess. Läuft heute Ende Juli vollständig von Hand durch den zweiten Admin; getrennte Domains je Gruppe (Schüler, Schulpersonal, KITA-Personal) im gemeinsamen Tenant mit der KITA. Offboarding hat eine feste Mechanik: automatische Antwort einrichten, Passwort hart zurücksetzen, Konto nach einer Frist vollständig löschen — die Information dazu kommt aus Sekretariat oder Geschäftsführung, und genau da reißt der Faden heute (siehe „Abgang" in Abschnitt 3).
   *Berührung:* liest Rufname, Name, Klasse, Geburtsdatum und bis zu zwei Erziehungsberechtigte mit Anrede/Name/E-Mail/Mobil — vollständig durch das Schema gedeckt (`schema/stammdaten-schema.sql`). **Verändert** `children.school_email` (Schulpostfach) — bewusst nicht `persons.email`, das die private Adresse und OTP-Identität bleibt (`schema/stammdaten-schema.sql`): sonst zöge das Offboarding einem ehemaligen Schüler, der später als Elternteil zurückkommt, seinen Zugang unter der Zeile weg. Abgänge erkennt sie an `children.exit_date`, das dafür verlässlich gesetzt sein muss.
8. **Eltern-Selfservice** (gebaut, `schema/selfservice-schema.sql` — ohne eigene Tabellen; eigene Stammdaten korrigieren, Kommunikationspräferenzen) — explizit nachrangig, erst nach Abschluss aller anderen hier gelisteten Domänen. Reduziert langfristig den Korrektur-Aufwand im Sekretariat, da Änderungen nicht mehr über Zuruf/Mail laufen müssen. Baut auf der Selbstauskunft-Mechanik aus Domäne 4 auf.
   *Berührung:* **verändert** die eigenen Personendaten der angemeldeten Person.
9. **Gesundheitsdaten** (gebaut, `schema/gesundheit-schema.sql`) — Allergien, Unverträglichkeiten, chronische Erkrankungen, Medikamentengabe samt Attest, Notfallmedikation, körperliche Einschränkungen, Zeckenentfernung. Besondere Kategorien nach Art. 9 DSGVO, heute in einer Excel-Liste beim Sekretariat. Erhoben wird der Satz **einmal je Kind** und von den Eltern selbst ausgefüllt — im Schulvertrag (Domäne 4), bei externen Hortkindern über den Hortvertrag, bei schulfremden Ferienkindern über ihre Buchung (Domäne 3). Freiwillig ist er **je Kategorie**: Die Eltern entscheiden für jede einzeln, ob und wie tief sie antworten, und „nicht beantwortet" ist von „nichts vorhanden" unterscheidbar festgehalten. Sichtbar wird er **je Angabe** an einen Sichtkreis — der Sportunterricht sieht den Handlungshinweis einer chronischen Erkrankung, nicht ihre Bezeichnung —, und im Notfall kommt jeder Mitarbeitende für jedes Kind an einen engen Ausschnitt, protokolliert statt genehmigt. Eine wiederkehrende Sammelaktion gibt es nicht; eine neue Frage erreicht nur die, die sie noch nicht beantwortet haben.
   *Berührung:* kein Eingriff in den Stammdaten-Kern, dieser liefert nur den Anker `children.child_id`. Struktur, Zugriffsstufen und die Nachweise daneben: `grenzkarte.md`, „Gesundheitsmerkmal (9)".
10. **Krankmeldung — gestrichen.** Die Schulleitung will sie nicht umgesetzt sehen; Eltern schicken weiterhin selbst eine Mail an mehrere Empfänger (`prozesse.md` Abschnitt 19). Die Nummer bleibt vergeben und wird nicht nachbesetzt, damit die Domänen-Nummern in den anderen Dateien stabil bleiben.
11. **Bonussystem Elternmitarbeit** (gebaut, `schema/elternbonus-schema.sql`) — zweite Anlage zum Schulvertrag neben der Putzdienstregelung, heute reiner Papierprozess über das Sekretariat. Mechanik (`prozesse.md` Abschnitt 12): jede Familie zahlt bei einem Kind 10 € im Monat zusätzlich, August ausgenommen — 110 € im Schuljahr, die anteilig zurückgezahlt werden, sobald Stunden geleistet sind. Pflicht sind 15 Stunden bei einem Grundschüler und 10 bei einem Realschüler, **nicht additiv**, der größere Wert entscheidet. Mehrstunden und zu spät abgegebene Stundenzettel verfallen; Elternbeirat erfüllt automatisch die volle Pflicht; einen festen Tätigkeitskatalog gibt es nicht, Anlässe ruft die Schule dynamisch auf. **Der Putzdienst zählt ausdrücklich nicht dazu** — zwei getrennte Stundenbestände, kein gemeinsamer Nachweis (`schema/putzdienst-schema.sql`). Künftig wandert auch der **Aufruf der Einsätze** hierher: Der Hausmeister schreibt sie im Portal aus, Eltern melden sich an, das System erinnert am Vortag — heute läuft das über eine Rundmail und eine fremde Umfrageplattform. **Bestätigt wird eine Stunde nicht**; was die Eltern eintragen, zählt.
12. **Klassenbildung** (gebaut, `schema/klassenbildung-schema.sql` — ohne eigene Tabellen) — für die neuen Klassen 1 und 5 sammelt die Verwaltung heute in einer Liste, welche Kinder zusammenkommen möchten, dazu Wohnort und Geschlechterverteilung, um ausgewogene Züge zu bilden; Klassenlehrer:in wird dabei mit festgelegt. Einmal jährlich, mündet in `children.class_id`. *Berührung:* liest Stammdaten, **schreibt** die Klassenzuteilung.
13. **Klassenorganisation** (gebaut, `schema/klassenorganisation-schema.sql`) — Elternvertretung und Stellvertretung je Klasse. *Berührung:* rein lesend, dazu die eigene Verknüpfung Erziehungsberechtigte:r↔Klasse. Klassenlehrer:in und Klassenzimmer stehen bereits als `classes.class_teacher_id` und `classes.room`, die Domäne bringt also nur die Elternvertretung mit (`grenzkarte.md`, „Elternvertretung").

Explizit **nicht** in dieser Liste, jeweils mit Grund:

- **KITA-Alltag** — die KITA-Anmeldung läuft über die Stadt, geteilt werden nur Räume/Ressourcen und der Belegprozess. Dauerhaft draußen (Abschnitt 1/4).
- **Schulalltag** (Noten, Stundenplan, Wahlpflichtfächer) — Untis deckt das ab. Dauerhaft draußen (Abschnitt 4).
- **Hort-Alltag** (Anwesenheit, gebuchte Betreuungszeiten je Tag, Mittagessen, Frühdienst) — der Hort führt dafür eigene, sehr umfangreiche Excel-Dateien; sich dort einzuarbeiten lohnt den Aufwand derzeit nicht. Betrifft ausdrücklich **nicht** das Ferienprogramm (Domäne 3, eigene Deadline) und nicht eine mögliche spätere Hortbuchung über dasselbe Portal wie Mensa.
- **Leihgeräte** (iPad-Liste der Realschule) — extern begleitet, kein eigener Bedarf.

**Entitäten und Zuständigkeiten je Domäne stehen in `grenzkarte.md`** — welche Entität es gibt, wem welche Tatsache gehört, und die fünf Querschnitts-Entitäten (Zustimmung, Dokument/Signatur, Zahlungsvorgang, Mitarbeiter/Bereichsstruktur, Nachzieh-Aufgabe), die in mehreren Domänen vorkommen und deshalb genau einmal gebaut werden. Diese Liste hier bleibt der Scope, die Grenzkarte trägt die Struktur.

**Bekannte Unbekannte:** die Verwaltung führt weitere Excel-Listen, auf die der Betreiber keinen Zugriff hat und deren Bestand niemand vollständig kennt. Die Liste oben ist damit belastbar für alles, was heute über Formulare oder benannte Listen läuft — nicht für alles, was existiert.

## 7. Erste Fachdomäne

**Putzdienst** — zeitlich dringendster Prozess (Abschnitt 1) und deshalb die erste. Produktiv geht er, wenn er fertig ist — **ausdrücklich ohne Abstriche bei Sicherheit und Automatisierung, um ein Datum zu halten** (`rules.md` §1–3); die Schule wartet, das ist billiger als ein Prozess, der auf echten Elterndaten nachgebessert wird. Prozessbeschreibung, Familie-Modell, Zyklus-Konfiguration und offene Punkte: `schema/putzdienst-schema.sql`.

**Der erste Zyklus kann weniger als der Block beschreibt.** Nicht als Abstrich an Sicherheit
oder Automatisierung — die stehen ganz —, sondern als Schnitt an den Vorgängen: Gebaut wird für
Zyklus eins, dass Eltern im Portal **buchen oder sich freikaufen**, der Solver zuteilt und die
Zuteilungsmail samt Erinnerungen hinausgeht. Tausch, Anwesenheit und Strafen bleiben in diesem einen
Jahr, wie sie heute laufen — Tausch über das Sekretariat, Anwesenheit auf Papier, Strafen von Hand.

**Der Freikauf im Anmeldefenster gehört ausdrücklich in Zyklus eins**, obwohl es ihn heute per
Überweisung gibt: Er ist keine spätere Ergänzung, sondern die zweite Hälfte derselben Handlung —
je Pflichttermin buchen **oder** freikaufen, beides im selben Fenster und in derselben Ansicht
(`soll-prozesse/01-putzdienst.md`, Schritt 3). Eine Strecke, die nur die eine Hälfte kann, stellt
die Familie vor eine Wahl, die sie im Portal gar nicht treffen kann. Damit hängt die
Sofortzahlung mit drin, und der Putzdienst ist die Domäne, die zuerst bezahlt
(`api/gemeinsam.md`, „Sofortzahlung").

Das Kriterium für den Rest war der Rückfallweg: Für Tausch, Anwesenheit und Strafen gibt es einen,
der heute gelebt wird und ohne Zutun der Eltern im Portal auskommt; für Buchung, Freikauf und
Zuteilung nicht. Was verschoben ist, trägt im Board die Marke `zweiter-zyklus` und liegt in „Ohne
Termin"; es fällt damit nicht weg, sondern wartet auf den zweiten Zyklus. Wer den Schnitt weiter
zurücknimmt, holt die restlichen Tickets nach `m-0` — die Reihenfolge steht, nur der Umfang war
die Entscheidung.

Zwei Folgen, die beim Bauen auffallen werden: Der Solver darf keiner Familie Termine zuteilen, die
ihre Pflichtzahl bereits freigekauft hat — der Freikauf senkt sie, und wer sich für alle freikauft,
steht in keiner Zuteilung und in keiner Mail dieses Prozesses. Und von den elf `configured_values`
hält nur die Strafe keinen Lauf an, solange sie außen vor bleibt; der Freikaufbetrag ist ab Zyklus
eins in Gebrauch, und die Fenster-offen-Mail nennt ihn samt dem Weg dorthin.

Kritischer Pfad bis dahin:

*Infrastruktur:*
- NAS-Backup-Bootstrap (`backlog/`) — muss vor echten Elterndaten laufen, nicht nachträglich
- Redirect-URI der bestehenden Entra-ID-App-Registrierung nachtragen (`runbook.md` Schritt 5, `backlog/`) — der Name steht fest, die Eintragung hängt am Tenant-Zugriff. Der interne Login wird zwingend gebraucht: die Verwaltung startet den Prozess und pflegt die Putztermine intern, kein reiner Eltern-Self-Service

*Auth/Zugriff für Eltern:*
- OTP-Fallback (gebaut, `wb-backend/app/routers/auth.py`) — offen bleibt allein die Application Access Policy auf das Absenderpostfach (`zugang.md`, `backlog/`): ohne sie sendet die Anwendung tenantweit, und der Pfad darf nicht live gehen
- Elternportal (`wb_portal_domain`, `oberflaechen.md`) erstmals aufsetzen — samt den beiden DNS-Records und dem Ausliefern durch den Reverse-Proxy

*Fachlich:*
- Stammdaten- und Putzdienst-Schema als Grundlage — beide stehen samt Prüfskript in `schema/`, Fachbeschreibungen `schema/stammdaten-schema.sql` und `schema/putzdienst-schema.sql`
- Restplatz-Solver und Erinnerungs-Lauf bauen (`schema/putzdienst-schema.sql` bzw. „Technischer Punkt") — der Mechanismus für Läufe ist entworfen (`container.md`), gebaut ist er nicht, und vor dem ersten Lauf stehen vier Schema-Marken (`backlog/`); das Modell des Solvers fehlt noch ganz
- **Nicht** auf dem kritischen Pfad: der Jahreslauf (`schema/stammdaten-schema.sql`). Er liegt Ende Juli, der für den ersten Zyklus maßgebliche ist damit schon von Hand in ASV-BW und M365 gelaufen — der Vollimport bringt den fortgeschriebenen Stand bereits mit. Der Weltenbaum-Job läuft erstmals Ende Juli 2027. Gesetzt sein müssen für September 2026 nur die Einzelfälle daneben (Wiederholer, Quereinsteiger, Zugwechsler), die ohnehin ein Mensch entscheidet

*Organisatorisch:*
- Zweiter Admin muss vor Produktivbetrieb aktiv sein, nicht vor Entwicklungsstart (`backlog/`)
