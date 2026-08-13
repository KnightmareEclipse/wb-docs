# Anmeldung — Fachdomäne (Voranmeldung, Anmeldegespräch, Schulvertrag)

Domäne 2/4 aus `fachdomaenen.md` Abschnitt 6 — **eine** Domäne in drei Phasen, weil dieselbe Bewerbung sie alle durchläuft. Tabellenschema: `domains/anmeldung-schema.sql`, belegt durch `domains/anmeldung-schema-check.sql` (Sollstand 51/51). Der heutige Ablauf samt Formularfeldern steht in `prozesse.md` Abschnitt 3–7; hier steht, was daraus im Datenmodell folgt.

Sie bringt außerdem die Querschnitts-Entitäten **Zustimmung (Q1)**, **Dokument/Signatur (Q2)** und **Nachzieh-Aufgabe (Q5)** mit und erweitert den **Zahlungsvorgang (Q3)** um die Anmeldegebühr — alle einmal gebaut, von allen späteren Domänen mitbenutzt (`domains/grenzkarte.md`).

## Die zwei Entscheidungen, aus denen der Rest folgt

**Die Personenzeilen entstehen bei der Voranmeldung, nicht erst bei der Aufnahme.** Drei Gründe, von denen jeder allein trägt:

- Personendaten haben genau ein Zuhause und werden nie kopiert (`domains/grenzkarte.md`, Regel 2). Eine Bewerbung mit eigenen Namens-, Geburts- und Adressfeldern wäre genau diese Kopie — und beim internen Übergang von der eigenen Grundschule in die eigene Realschule stünde dasselbe Kind zweimal da.
- Der OTP-Zugang, die jährliche Wartelisten-Rückfrage und die persönlichen Vertragslinks brauchen alle eine Personenidentität, und die Warteliste läuft über Jahre.
- Die Dublettenvermeidung ist eine **Auswahl** aus bekannten Personen, kein Abgleich (`TODO-SESSIONS.md`). Ohne frühe Personenzeilen gäbe es nichts auszuwählen.

Der Preis ist real: Bewerbungen, die nie zur Aufnahme führen, hinterlassen Personenzeilen. Sie brauchen dafür **keine eigene Spalte** — auffindbar sind sie als Kinder ohne Eintrittsdatum, deren sämtliche Bewerbungen in einem Endstatus stehen. Das Prüfskript zeigt beide Richtungen: solange eine Bewerbung offen ist, ist das Kind kein Kandidat.

**Die Zeilen entstehen beim Absenden, nicht nach der Zahlungsbestätigung.** Die Alternative hieße, den Formularinhalt bis zur Bestätigung zwischenzuparken — dieselben Personendaten an einem zweiten Ort mit eigener Aufbewahrung und eigenem Leserkreis. Ein abgebrochener Zahlungsvorgang hinterlässt stattdessen eine Bewerbung mit offener Zahlung, die derselbe Lösch-Job aufräumt.

## Anmeldefenster und Anmeldegebühr

Öffnung, Schließung und Gebühr der Voranmeldung sind Daten je Zweig × Schuljahr (`application_windows`), keine Konstanten — die Anmeldung wird real je Schule dynamisch geschlossen, teils blieb sie bis Juni offen, und Beträge gehören nach `rules.md` Abschnitt 3 in die Datenbank. Das Fenster trägt die gewünschte **harte Sperre** (`prozesse.md` Abschnitt 3.4): offen/zu prüft das Backend gegen diese Zeile, und der benannte legitime Ausweg ist der einzelne **Nachmeldelink des Sekretariats** in die reguläre Voranmeldung — ein Vorgang, kein Datenzustand. Der **Quereinstieg** läuft ganzjährig am Fenster vorbei und liest nur die Gebühr seines Zieljahrs.

## Bewerbung

- **Sie zeigt auf Kind und Familie**, statt Personendaten zu tragen. Was sie selbst trägt: Zielschuljahr und Zielklassenstufe, Anmeldedatum, ausfüllende Person, Bestätigung dass der andere Elternteil informiert ist, Teilnahme am Infoabend, wahrgenommene Angebote, Interesse an Betreuung, Status.
- **Mehrere Bewerbungen je Kind sind der Normalfall.** Der Wechsel von der eigenen Grundschule in die eigene Realschule ist eine zweite Bewerbung desselben Kindes, und eine abgelehnte Bewerbung kann im Folgejahr wiederholt werden. Eindeutig ist deshalb nur Kind × Zielschuljahr. Ein neuer Anlauf im **selben** Zieljahr ist keine zweite Zeile: das Sekretariat öffnet die bestehende per Status wieder — der benannte Ausweg; eine zweite Anmeldegebühr entsteht dabei nicht, und nach dem Lösch-Lauf zum 01.08. ist die Zeile für einen späten Quereinstieg ohnehin frei.
- **Die Schülerüberweisung ist ein Vorgangsschritt der Bewerbung** (erhalten, zurückgesendet — zwei Datumsfelder), keine Q5-Nachzieh-Aufgabe: sie zieht keine Weltenbaum-Änderung in ein Fremdsystem nach, und an zwei Orten geführt wäre derselbe Erledigt-Haken zweimal pflegbar (`domains/grenzkarte.md`, Q5).
- **Der Status trägt den gesamten Lebenslauf** und ersetzt drei naheliegende Zusatzentitäten: Warteliste, Absage und der Rücktritt vor dem ersten Schultag sind Ausprägungen desselben Feldes. Zwei nicht umbenennbare Kennzeichen hängen daran — `is_waitlist` steuert die jährliche Fortschreibung, `is_final` beendet das Verfahren und startet die Löschfrist. Beide dürfen sich nicht ändern, wenn jemand ein Label umbenennt; dieselbe Bauform wie `cleaning_duty_types.is_major`.
- **Die Warteliste hat keine Rangfolge.** Bei einem frei werdenden Platz entscheidet ein Mensch neu, und die Zahl der Wartenden ist klein. Die jährliche Fortschreibung ist ein UPDATE auf Zielschuljahr und Zielklassenstufe, kein neuer Datensatz.
- **Die jährliche Rückfrage steht als zwei Zeitpunkte daneben** (gefragt, bestätigt) und nicht als ein Kennzeichen: die ausbleibende Antwort ist selbst die Information. Mit nur einem Feld wäre „gefragt, keine Antwort" von „dieses Jahr nie gefragt" nicht zu unterscheiden — über mehrere Jahre genau der Fall, in dem eine Familie unbemerkt liegen bleibt. Die Fortschreibung leert beide, sie gelten also immer fürs aktuelle Zieljahr; bestätigt werden kann nur, was gefragt wurde (CHECK). Was die Familie antwortet, steht dagegen im Status: Ausschlagen ist ein Endstatus, kein leeres Feld.
- **Ein Freitextfeld der verwaltenden Spur**, nicht zwei: `processing_note` nimmt den Bearbeitungsstand der Warteliste **und** den „Freitext für zusätzliche Anmerkungen" der Sekretariats-Checkliste auf (`prozesse.md` Abschnitt 5.2). Beide gehören der Verwaltung — nicht in `assessment_notes`, das im engen Bewertungs-GRANT liegt und für sie standardmäßig unlesbar ist (siehe „Bewertung").
- **Die Unterlagenprüfung des Anmeldetags ist ein eigener Zeitpunkt** an der Bewerbung — der letzte Punkt der Sekretariats-Checkliste. Sie ist nicht `contracts.secretariat_checked_at`: das ist dieselbe Handlung Wochen später am fertigen Vertrag. Welche Unterlage fehlt, sagt das Dokument (siehe Q2); **dass** jemand durchgesehen hat, sagt nur diese Spalte.
- **Geschwister als Selbstauskunft**, ohne Namensliste: gebraucht werden nur, ob Geschwister an der Schule sind und wie viele es insgesamt sind. Bei externen Bewerbern gibt es noch keine Familie, aus der das folgen könnte; bei der Aufnahme löst es sich gegen `families` auf.
- **Quereinstieg ist ein Kennzeichen und keine Ableitung.** Er ist ein eigener Ablauf (ganzjährig, Platzprüfung vor dem Gespräch). Ableitbar wäre er nur über ein Merkmal „Eingangsklassenstufe" an `grade_levels` — dafür wird eine eingefrorene Stammdaten-Tabelle nicht aufgemacht. Sein **Hospitationszeitraum** (Quereinsteiger-Checkliste) steht als Von-bis-Datumspaar an der Bewerbung.
- **Die Platzprüfung bleibt eine menschliche Entscheidung — es gibt keine Klassenkapazität im Schema.** „Voll" ist an dieser Schule kein Zustand: die Zielmarke liegt heute bei 25 Kindern, in dringenden Fällen wird auch darüber hinaus aufgenommen. Verwaltung und Schulleitung entscheiden je Fall, und beim Quereinstieg wird ohnehin der direkte Kontakt gesucht. Eine Kapazitätsspalte träfe deshalb eine Aussage, die es nicht gibt, und würde als harte Grenze gelesen — sie ist die einzige der vier Kapazitäten im System (Gesprächsslot, Ferientag, Putztermin), die bewusst fehlt. Weltenbaum liefert nur den Ist-Stand: wie viele Kinder die Zielklassenstufe heute zählt.

## Zwei Schulen und ein Kindergarten

Das Feld für die bisherige Einrichtung heißt auf beiden Voranmeldeformularen gleich, meint aber Verschiedenes (`prozesse.md` Abschnitt 3.2):

| | Formularfeld meint | landet in |
|---|---|---|
| Realschule, Quereinstieg | die abgebende Schule | `children.previous_school_id` samt `previous_school_consent_at` |
| Grundschule | den **Kindergarten** | `applications.kindergarten_id` samt `kindergarten_consent_at` |

Ein gemeinsamer Import beider Formulare in dieselbe Spalte wäre deshalb ein Fehler, der erst beim ersten Überweisungsvorgang aufflöge — dann stünde dort ein Kindergarten.

Die **örtlich zuständige Grundschule** erhebt die Voranmeldung heute gar nicht; sie steht nur auf der Anmeldetag-Checkliste. Künftig ist sie ein **zusätzliches** Feld des Grundschulformulars neben dem Kindergarten und landet in `children.previous_school_id` — dieselbe Spalte, dieselbe Rolle im Verfahren (Schülerüberweisung), andere Herkunft.

Die Kindergarten-Rücksprache-Erlaubnis steht bewusst an der **Bewerbung** und nicht am Kind: die abgebende Schule wird über den Anmeldetag hinaus gebraucht, der Kindergarten nicht.

## Schulpflicht, Kann-Kind, Zurückstellung

Die Einstufung wird **gespeichert und nicht bei jeder Anzeige neu gerechnet**: sie ist eine Entscheidung, kein Rechenergebnis — ein schulpflichtiges Kind kann zurückgestellt werden.

Die Stichtage, aus denen die Oberfläche sie *vorschlägt*, sind Daten und keine Konstanten (aktuell: wer bis zum 30.06. sechs wird, ist schulpflichtig; ab dem 01.07. Kann-Kind). Je Zielschuljahr eine Zeile — so gilt ein geänderter Stichtag nie rückwirkend für ein laufendes Verfahren.

## Anmeldetag und Gesprächstermin

Zwei Tabellen: der **Anmeldetag** trägt das Raster (Schulzweig, Datum, Zeitfenster, Mittagspause), der **Slot** ist das konkret buchbare Ziel mit eigener Kapazität.

- **Beides sind Daten, keine Konstanten.** Wochentage, Zeiten, Pause und Kinder je Stunde setzen die zuständigen Personen selbst, weil sie sich immer wieder ändern und die Sondertermine heute ohnehin niemand vollständig kennt. Der heutige Stand (Grundschule samstags, Realschule Donnerstag und Freitag, 08:00–16:00, Pause 12:00–13:00, 4–5 Kinder je Stunde) ist ein Ausgangswert.
- **Eigene Slot-Zeilen statt einer Berechnung aus dem Raster:** eine Buchung braucht ein stabiles Ziel, das auch dann noch dasselbe meint, wenn jemand die Pause verschiebt.
- **Die Kapazität ist hier eine harte Obergrenze** — anders als beim Putzdienst, wo sie berechnet wird und das Sekretariat sie überschreiten darf. Grund: hier sitzt eine Lehrkraft am Tisch, dort wird geputzt.

Das Gespräch selbst erhebt **keine** Stammdaten; parallel dazu prüft das Sekretariat die Verwaltungssachen und gibt die Schulalltagsinfos heraus (`prozesse.md` Abschnitt 6).

## Bewertung

Festgehalten wird das **konsolidierte Ergebnis**, nicht eine Zeile je Lehrkraft: mehrere konkurrierende Urteile ohne definierten Sieger gibt es im realen Verfahren nicht. Vier Felder an der Bewerbung — Einschätzung („passt zur Schule": Zusage / Eher Ja / Eher Nein / Absage), eigenes Niveau, Rangnummer, Notizen.

**Zwei Niveau-Felder mit derselben Werteliste**, solange nicht bestätigt ist, dass es dasselbe ist: die amtliche **Grundschulempfehlung** der abgebenden Schule und die **eigene Einschätzung** aus Gespräch und Testblättern. Sind es zwei Namen für dieselbe Angabe, bleibt eine Spalte leer — der billigere Irrtum, denn ein Feld für zwei Sachverhalte verlöre gerade den interessanten Fall, dass beide auseinandergehen. Zu bestätigen mit Sekretariat und Realschulleitung.

Die **Rangnummer** ist nullable und wird nur für die Grenzfälle vergeben; klare Zusagen und klare Absagen brauchen keine. Nach der Entscheidung liest sie niemand mehr — sie bleibt als Beleg, wie entschieden wurde.

**Zugriff:** Diese vier Felder haben das engste Profil im System nach den Art.-9-Daten und bekommen ein eigenes Spalten-GRANT auf der Bewerbung — kein zweites Berechtigungssystem, dieselbe Bauform wie bei den Konfessionsspalten an `children`. Standardmäßig sind sie **nicht** breit sichtbar, umschaltbar bleibt es: die Lehrer-Checkliste bleibt zwingend Papier und wird nach dem Verfahren vernichtet, digital landet nur das konsolidierte Ergebnis. Dass Papier vernichtet werden muss, bleibt eine organisatorische Pflicht — Weltenbaum kann kein Papier löschen und darf nicht so tun, als sei mit der Löschfrist der Bewerbung alles erledigt.

## Schulvertrag und Hortvertrag

Der Vertragsvorgang ist eine eigene Zeile und keine Spaltengruppe an der Bewerbung: er hat einen eigenen Lebenslauf, von dem drei Stationen nach dem Absenden der Eltern liegen, und die meisten Bewerbungen erreichen ihn nie.

**Er hängt an einer Bewerbung oder an einem Kind, an genau einem von beidem** — derselbe Entweder-oder-Fremdschlüssel wie bei Dokument und Zahlung. Grund ist der Hortvertrag: der Hort nimmt Kinder auf, die weder Grund- noch Realschüler sind, für sie gibt es keine Bewerbung. Ihr Vertrag durchläuft trotzdem dieselben vier Stationen und braucht dieselbe Antwort je Erziehungsberechtigtem — ohne den zweiten Bezug hätte er weder Frist noch Prüfung noch Freigabe, und die Verwaltung stünde bei genau den Kindern ohne Ablauf da, deren Vertrag sonst niemand zweitprüft. Am Kind gibt es dabei bewusst **kein** UNIQUE: ein externes Hortkind, das Jahre später wiederkommt, schließt einen zweiten Vertrag, und welcher gilt, sagt die Laufzeit der Buchung.

**Vier Zeitpunkte statt eines Statusfeldes** — sie treten immer in dieser Reihenfolge ein, und „wann war das" ist die Frage, die im Nachhinein gestellt wird: Frist, Prüfung durch das Sekretariat, Freigabe durch die Schulleitung, Bestätigungsmail. Die Reihenfolge ist im Schema erzwungen: keine Freigabe ohne vorherige Prüfung, keine Bestätigung ohne Freigabe. Eine Bestätigungsmail vor der Freigabe wäre genau der Fehler, der an dieser Schule niemandem auffiele.

**Die Antwort steht je Erziehungsberechtigtem**, nicht am Vertrag. Mutter und Vater bekommen je einen eigenen persönlichen Link und können **unterschiedlich** antworten — sagt einer ja und der andere nein, wird das Sekretariat benachrichtigt und klärt telefonisch. Genau dieser Konflikt ist an einem einzelnen Vertragsfeld nicht darstellbar. Die Stammdatenbestätigung steht daneben mit zwei Zeitpunkten je Zeile: jeder bestätigt seine **eigenen** Daten, die des Kindes bestätigen beide.

Die **14-Tage-Frist** ist ein Datum und keine Dauer, weil das Sekretariat sie im Einzelfall verlängert. Sie ist bewusst kein Constraint: eine überschrittene Frist ist ein Zustand, den jemand sieht und bearbeitet, kein verbotener Datensatz.

## Betreuungsmodule (Hortvertrag)

- **Die Buchungseinheit ist Modul × Wochentag**, nicht das Modul allein: je Modul werden die einzelnen Tage gewählt. Deshalb eine Zeile je Tag statt sieben Boolean-Spalten.
- **Die Buchung hängt am Kind, nicht am Vertragsvorgang.** Der Vertragsbezug bleibt nullable und sagt nur, aus welchem Vorgang die Buchung entstanden ist — beim Schulkind aus dem Schulvertrag, beim externen Hortkind aus dessen eigenem, am Kind hängenden Hortvertrag (siehe „Schulvertrag und Hortvertrag"), beim Mensa-Abo aus gar keinem.
- **Der Gültigkeitszeitraum trägt Laufzeit, Kündigung und Angebotsende:** der reale Vertrag läuft ein Schuljahr und verlängert sich stillschweigend (`prozesse.md` Abschnitt 8); `valid_until` bleibt leer, solange nichts endet, und wird bei Kündigung oder Angebotsende gesetzt (das Hortangebot endet mit Klasse 5). Als Datum und nicht als Regel im Code, weil die Schule Fristen und Grenzen verschiebt.
- **Das Mittagessen ist ebenfalls eine Eigenschaft des Moduls** (`includes_lunch`): der Vertrag berechnet es für alle, die länger als 13 Uhr betreut werden — keine eigene Buchung. Das RS-Mensa-Abo bucht dieselbe Struktur als Katalogzeile „Mittagessen"; Küchenprofil und Tagesliste stehen in Domäne 6 (`domains/mensa.md`).
- Der Modulkatalog ist eine Werteliste (die sechs Betreuungsmodule plus die Katalogzeile „Mittagessen" der Mensa, `domains/mensa.md`). Die Zeitangabe steht als Text darin, weil der reale Katalog überwiegend bei „Schulende" beginnt und nicht zu einer Uhrzeit — und weil keine Abfrage sie auswertet.
- **Die Hausaufgabenbetreuung ist Bestandteil des Moduls** (`includes_homework`): die Nachmittagsbetreuungen 2–4 enthalten sie, Modul 1 (bis 13:00) nicht. Wer sie bekommt, entscheidet allein die Modulwahl — es gibt deshalb kein eigenes Interesse- oder Buchungsfeld dafür, und die Grobabfrage „Kernzeit / Nachmittag / Ganztags" der Anmeldetag-Checklisten wird digital durch die konkrete Modulbuchung ersetzt (bewusste Abweichung vom Papierablauf).

## Zustimmung (Q1) und Dokument/Signatur (Q2)

**Zustimmung** ist *Person × (optional) Kind × Zweck × Antwort (erteilt oder abgelehnt) × Zeitpunkt × Zustelladresse × Widerruf*. Drei Punkte, die leicht verloren gehen:

- **Die Ablehnung ist eine eigene Antwort, keine fehlende Zeile.** Das Fotoeinverständnis kann ausdrücklich abgelehnt werden (`prozesse.md` Abschnitt 7.1), und ohne Zeile wäre „abgelehnt" nicht von „noch nicht beantwortet" zu unterscheiden — für die Vollständigkeitsprüfung des Sekretariats dieselbe Unterscheidung zwischen entschieden und vergessen wie bei der Anwesenheitsliste des Putzdiensts. Widerrufen wird nur eine Erteilung; eine spätere Erteilung überschreibt die Ablehnung in derselben Zeile.

- **Die Zustelladresse gehört zwingend dazu** und ist nicht aus `persons.email` ableitbar: zwei Erziehungsberechtigte dürfen sich eine Mailbox teilen, und nur mit festgehaltener Adresse ist hinterher auswertbar, ob zwei Zustimmungen über dasselbe Postfach kamen. Das Prüfskript zeigt genau diesen Fall: zwei Personen, ein Postfach.
- **Die zustimmende Person ist nicht auf Erziehungsberechtigte eingeschränkt** — ab 14 Jahren muss das Kind beim Fotoeinverständnis selbst zustimmen.

Zustimmungen ohne Kind (Werbe-Einwilligung an den anmeldenden Elternteil) sind erlaubt und trotzdem gegen Doppelung geschützt: die Eindeutigkeit ist `NULLS NOT DISTINCT`, sonst ließe sich dieselbe kindlose Zustimmung beliebig oft anlegen.

**Dokument und Signatur** sind bewusst nicht mit Q1 verschmolzen: eine Zustimmung kann ohne Dokument existieren (Häkchen), und ein Dokument trägt oft mehrere Zustimmungen (ein Schulvertrag, zwei Unterschriften). Ein Dokument hängt an genau einem Bezug — Kind oder Bewerbung.

**Eine Dokumentzeile sagt zwei Dinge, einzeln oder zusammen: angefordert und vorgelegt.** Der Anmeldetag verlangt Unterlagen, die die Eltern nicht dabeihaben — „Beobachtungsbogen einholen; falls nicht mitgebracht, bekommen die Eltern einen Bogen" (`prozesse.md` Abschnitt 5.2). Ohne Anforderungszeile wäre „fehlt noch" das Fehlen einer Zeile und damit nicht von „nie verlangt" zu unterscheiden — dieselbe Unterscheidung zwischen entschieden und vergessen wie bei der abgelehnten Zustimmung. Wird nachgereicht, trägt dieselbe Zeile beides. Zwei Folgen: Vorlagepfad und Vorlagedatum gelten nur gemeinsam (CHECK, dieselbe Bauform wie beim Masernnachweis), und der Lösch-Job darf für eine Zeile ohne Pfad keine Datei in SharePoint suchen — es gibt keine.

**Die Dateien selbst bleiben in SharePoint**, Weltenbaum führt nur die Referenz (`domains/grenzkarte.md`, Q2). Zwei Folgen: das `pg_dump`-Backup deckt weiterhin den vollständigen Weltenbaum-Bestand ab, und der Lösch-Job muss die Datei dort mitentfernen — eine verwaiste Datei in SharePoint ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile, und sie fällt niemandem auf.

**Das Signaturniveau ist eine Spalte und keine Werteliste:** es gibt heute durchgängig genau eine Stufe (einfache elektronische Signatur), und eine Liste mit einer Zeile wäre ein Mechanismus ohne Bedarf.

## Zahlung (Q3)

Die Anmeldegebühr ist der dritte Stripe-Anlass und kommt als weitere Vorgangs-Spalte samt erweitertem Entweder-oder-CHECK an die bestehende `payments`-Tabelle — nicht als zweite Zahlungstabelle. Das Prüfskript belegt beides: die neue Zahlung entsteht, und der Putzdienst-Freikauf funktioniert unverändert weiter.

## Nachzieh-Aufgabe (Q5)

ASV-BW und Optigem haben keine Update-Schnittstelle — jede Weltenbaum-Änderung muss ein Mensch dort nachziehen, heute über Zuruf und Gedächtnis. `sync_targets`/`sync_tasks` machen daraus eine benannte Aufgabe mit Erledigt-Zeitpunkt; gespeichert wird nur, was sich nicht ableiten lässt (`domains/grenzkarte.md`, Q5). Hier gebaut, weil der erste reale Abnehmer die **Neuanlage in ASV-BW nach Vertragsabschluss** ist; die alltägliche Stammdaten-Änderung erzeugt später dieselben Aufgaben. Erzeugung und Abarbeitung sind Backend-Arbeit in `wb-backend` und ausdrücklich nicht Teil dieses Entwurfs.

## Löschung

**Der Anker ist ein fester Kalendertag, kein Fristablauf je Zeile:** gelöscht wird zum **01.08. des Jahres, in dem das Zielschuljahr beginnt** — also kurz bevor es losgeht. Gelöscht wird ausschließlich durch diesen Lauf: von Hand löscht niemand eine Bewerbung, frühestens die automatische Löschung räumt sie. Betroffen ist jede Bewerbung in einem **Endstatus** (`application_statuses.is_final`), und das sind zwei Fälle: die Absage der Schule und der **abgelehnte Platz**. Einen angebotenen Wartelistenplatz auszuschlagen zählt wie eine Absage und ist ein eigener Endstatus; wird er angenommen, bleibt die Familie im System.

Die Warteliste selbst wird **nicht** gelöscht: wer weiter wartet, steht in einem Wartelisten-Status (`is_waitlist`) und wird jährlich fortgeschrieben — genau dafür gibt es das Kennzeichen. Ein Endstatus tritt erst ein, wenn tatsächlich entschieden wurde.

Weil der Anker der Kalender ist und kein Ereignis, braucht `applications` **keinen** Zeitpunkt „final geworden am". Der einzige Ersatz wäre `updated_at` gewesen, und der springt bei jeder späteren Änderung weiter — die Aufbewahrungsuhr würde sich still zurücksetzen.

**Gelöscht wird alles, nicht nur die Bewerbung.** Kind, Erziehungsberechtigte und Familie gehen mit, sofern kein Geschwisterkind an der Schule bleibt; ist eines da, fällt nur die Kindzeile und Eltern samt Familie bleiben. Das ist derselbe Lauf und dieselbe Mechanik wie in `domains/stammdaten.md`, „Löschmechanik" — verwaiste Zeilen ohne verbleibende Verknüpfung haben keinen Verarbeitungszweck mehr.

Die Fremdschlüssel geben die **Reihenfolge** vor, statt sie dem Job zu überlassen: Dokumente (samt der Datei in SharePoint) und Vertragsvorgang blockieren die Bewerbung, die Bewerbung blockiert das Kind. Der Job arbeitet also von außen nach innen. Ein **Hortvertrag** hat keine Bewerbung über sich und blockiert das Kind direkt — er teilt dessen Frist, nicht die der Bewerbung.

**Die Zahlung geht mit.** Der Beleg der Anmeldegebühr bleibt nicht als vorgangslose Zeile stehen: Optigem ist für die Buchhaltung führend und zieht die Zahlung selbst aus Stripe (`fachdomaenen.md` Abschnitt 4) — Weltenbaum braucht sie nach dem Verfahren nicht mehr. Das hält den Entweder-oder-CHECK an `payments` unangetastet: eine Zahlung ohne Anlass gibt es nie, eine leere Vorgangsspalte ist immer ein Fehler und nie ein Zustand.

## Was diese Domäne nicht enthält

- **Gesundheitsdaten.** Der Schulvertrag erhebt den Satz, geführt wird er in Domäne 9 mit eigenem Zugriffsprofil. Hier stehen nur die Zustimmung (Q1) und das signierte Blatt (Q2).
- **Den Masernnachweis.** Er ist ein Gesundheitsdatum und braucht Vorlagedatum und Vorlageart in Domäne 9 — eine Kopie entsteht ausdrücklich nie.
- **Die Klassenzuteilung.** Sie setzt Domäne 12; hier steht nur der Zusammensetzungswunsch als Freitext, weil er im Anmeldeformular geäußert wird.

## Offene Punkte

- Mit Sekretariat und Realschulleitung zu bestätigen: sind Grundschulempfehlung und eigenes Niveau zwei Angaben oder zwei Namen für dieselbe (siehe „Bewertung")?
- Ist der „Einschulungsuntersuchungsbericht" der Anmeldetag-Checkliste das interne Lehrerformular (`prozesse.md` Abschnitt 22)?
- Löschfristen der übrigen Entitäten stehen aus (`TODO.md`).
