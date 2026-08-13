# Anmeldung — Fachdomäne (Voranmeldung, Anmeldegespräch, Schulvertrag)

Domäne 2/4 aus `fachdomaenen.md` Abschnitt 6 — **eine** Domäne in drei Phasen, weil dieselbe Bewerbung sie alle durchläuft. Tabellenschema: `domains/anmeldung-schema.sql`, belegt durch `domains/anmeldung-schema-check.sql` (Sollstand 59/59). Der heutige Ablauf samt Formularfeldern steht in `prozesse.md` Abschnitt 3–7; hier steht, was daraus im Datenmodell folgt.

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
- **Die Schülerüberweisung ist ein Vorgangsschritt der Bewerbung** und keine Q5-Nachzieh-Aufgabe: sie zieht keine Weltenbaum-Änderung in ein Fremdsystem nach, und an zwei Orten geführt wäre derselbe Erledigt-Haken zweimal pflegbar (`domains/grenzkarte.md`, Q5). **Drei Datumsfelder, weil der Ablauf drei Schritte hat:** die abgebende Schule wird informiert, daraufhin kommt die Überweisung, und ggf. geht sie zurück. Ohne den ersten wäre ein leeres Empfangsdatum zweideutig — noch nicht informiert (zu tun: informieren) oder noch keine Antwort (zu tun: nachfassen). Einen Anker daneben gibt es nicht, der Austausch läuft lange nach dem Anmeldetag.
- **Der Status trägt den gesamten Lebenslauf** und ersetzt drei naheliegende Zusatzentitäten: Warteliste, Absage und der Rücktritt vor dem ersten Schultag sind Ausprägungen desselben Feldes. Zwei nicht umbenennbare Kennzeichen hängen daran — `is_waitlist` steuert die jährliche Fortschreibung, `is_final` beendet das Verfahren und startet die Löschfrist. Beide dürfen sich nicht ändern, wenn jemand ein Label umbenennt; dieselbe Bauform wie `cleaning_duty_types.is_major`.
- **Die Warteliste hat keine Rangfolge.** Bei einem frei werdenden Platz entscheidet ein Mensch neu, und die Zahl der Wartenden ist klein. Die jährliche Fortschreibung ist ein UPDATE auf Zielschuljahr und Zielklassenstufe, kein neuer Datensatz.
- **Die jährliche Rückfrage steht als zwei Zeitpunkte daneben** (gefragt, bestätigt) und nicht als ein Kennzeichen: die ausbleibende Antwort ist selbst die Information. Mit nur einem Feld wäre „gefragt, keine Antwort" von „dieses Jahr nie gefragt" nicht zu unterscheiden — über mehrere Jahre genau der Fall, in dem eine Familie unbemerkt liegen bleibt. Die Fortschreibung leert beide, sie gelten also immer fürs aktuelle Zieljahr; bestätigt werden kann nur, was gefragt wurde (CHECK). Was die Familie antwortet, steht dagegen im Status: Ausschlagen ist ein Endstatus, kein leeres Feld.
- **Ein Freitextfeld der verwaltenden Spur**, nicht zwei: `processing_note` nimmt den Bearbeitungsstand der Warteliste **und** den „Freitext für zusätzliche Anmerkungen" der Sekretariats-Checkliste auf (`prozesse.md` Abschnitt 5.2). Beide gehören der Verwaltung — nicht in `assessment_notes`, das im engen Bewertungs-GRANT liegt und für sie standardmäßig unlesbar ist (siehe „Bewertung").
- **Die Unterlagenprüfung des Anmeldetags ist ein eigener Zeitpunkt** an der Bewerbung — der letzte Punkt der Sekretariats-Checkliste. Sie ist nicht `contracts.completeness_checked_at`: das ist dieselbe Handlung Wochen später am fertigen Vertrag. Welche Unterlage fehlt, sagt das Dokument (siehe Q2); **dass** jemand durchgesehen hat, sagt nur diese Spalte.
- **Geschwister als Selbstauskunft**, ohne Namensliste: gebraucht werden nur, ob Geschwister an der Schule sind und wie viele es insgesamt sind. Bei externen Bewerbern gibt es noch keine Familie, aus der das folgen könnte; bei der Aufnahme löst es sich gegen `families` auf.
- **Quereinstieg ist ein Kennzeichen und keine Ableitung.** Er ist ein eigener Ablauf (ganzjährig, Platzprüfung vor dem Gespräch). Ableitbar wäre er nur über ein Merkmal „Eingangsklassenstufe" an `grade_levels` — dafür wird eine eingefrorene Stammdaten-Tabelle nicht aufgemacht. Sein **Hospitationszeitraum** (Quereinsteiger-Checkliste) steht als Von-bis-Datumspaar an der Bewerbung.
- **Die Platzprüfung bleibt eine menschliche Entscheidung — es gibt keine Klassenkapazität im Schema.** „Voll" ist an dieser Schule kein Zustand: die Zielmarke liegt heute bei 25 Kindern, in dringenden Fällen wird auch darüber hinaus aufgenommen. Verwaltung und Schulleitung entscheiden je Fall, und beim Quereinstieg wird ohnehin der direkte Kontakt gesucht. Eine Kapazitätsspalte träfe deshalb eine Aussage, die es nicht gibt, und würde als harte Grenze gelesen. Weltenbaum liefert nur den Ist-Stand: wie viele Kinder die Zielklassenstufe heute zählt. **Zwei der Kapazitäten im System fehlen aus genau diesem Grund** — der Klassenplatz hier und der Hortplatz (siehe „Betreuungsmodule"); gebaut sind nur die drei, die real eine Zahl haben: Gesprächsslot, Ferientag und Putztermin.

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

**Er hängt an einer Bewerbung oder an einem Kind, an genau einem von beidem** — derselbe Entweder-oder-Fremdschlüssel wie bei Dokument und Zahlung, und er trägt hier zugleich die Vertragsart: **Bewerbung heißt Schulvertrag, Kind heißt Hortvertrag.**

**Der Hortvertrag ist immer ein eigener Vorgang, für interne wie für externe Kinder** — drei Gründe, von denen jeder allein trägt:

- **Er entsteht später.** Am Anmeldetag wissen die Eltern regelmäßig noch nicht, welche Betreuung sie brauchen; erhoben wird dort nur das Interesse (`applications.interested_in_care`). An den Schulvertrag gehängt fände ein im Mai nachgereichter Hortvertrag dessen vier Zeitpunkte längst gesetzt — weder eigene Frist noch eigene Prüfung noch eigene Freigabe.
- **Er wird im laufenden Schuljahr geändert und gekündigt**, während der Schulvertrag steht: Modul-Anpassungen im September, zum Halbjahr und bei Stundenplanänderungen (`prozesse.md` Abschnitt 8). Ein gemeinsamer Vorgang müsste dafür jedes Mal wieder aufgemacht werden.
- **Der Hort nimmt Kinder auf, die weder Grund- noch Realschüler sind** — für sie gibt es gar keine Bewerbung.

Der Ablauf ist dadurch für interne und externe Kinder derselbe, und die eigene Bestätigung des Horts (Anschreiben + Welcome-Brief, `prozesse.md` Abschnitt 5.2) bekommt ihren eigenen `confirmation_sent_at`, statt mit der Aufnahmebestätigung um eine Spalte zu konkurrieren. Am Kind gibt es deshalb bewusst **kein** UNIQUE: ein Kind schließt über die Jahre mehrere Hortverträge, und welcher gilt, sagt die Laufzeit der Buchung.

**Vier Zeitpunkte statt eines Statusfeldes** — sie treten immer in dieser Reihenfolge ein, und „wann war das" ist die Frage, die im Nachhinein gestellt wird: Frist, Prüfung auf Vollständigkeit, Freigabe, Bestätigungsmail. Die Reihenfolge ist im Schema erzwungen, und zwar doppelt: der frühere Schritt muss stattgefunden haben **und** früher liegen. Eine Bestätigungsmail vor der Freigabe wäre genau der Fehler, der an dieser Schule niemandem auffiele — auch dann, wenn er erst durch eine nachträgliche Korrektur am Prüfzeitpunkt entsteht.

**Wer prüft und wer freigibt, hängt an der Vertragsart** — deshalb sind die beiden Spalten nach der Handlung benannt (`completeness_checked_at`, `released_at`) und nicht nach der Stelle:

| | prüft auf Vollständigkeit | gibt frei und zeichnet gegen |
|---|---|---|
| Schulvertrag | Verwaltung | Schulleitung des jeweiligen Zweigs |
| Hortvertrag | Hort | **Hortleitung** |

Der Hortvertrag läuft damit vollständig über den Hort und an der Schulanmeldung vorbei — passend dazu, dass er am Kind hängt und nicht an der Bewerbung. Die Schulleitung ist hier gar nicht zuständig: sie ist je Zweig benannt (`glossar.md`), und ein externes Hortkind hat keinen. Beide Male sind es zwei verschiedene Stellen, und genau das ist die Zweitprüfung, die das Aufsetzen ohne eigene Rolle auskommen lässt (siehe unten).

**Die Antwort steht je Erziehungsberechtigtem**, nicht am Vertrag. Mutter und Vater bekommen je einen eigenen persönlichen Link und können **unterschiedlich** antworten — sagt einer ja und der andere nein, wird das Sekretariat benachrichtigt und klärt telefonisch. Genau dieser Konflikt ist an einem einzelnen Vertragsfeld nicht darstellbar. Die Stammdatenbestätigung steht daneben mit zwei Zeitpunkten je Zeile: jeder bestätigt seine **eigenen** Daten, die des Kindes bestätigen beide.

Die **14-Tage-Frist** ist ein Datum und keine Dauer, weil das Sekretariat sie im Einzelfall verlängert. Sie ist bewusst kein Constraint: eine überschrittene Frist ist ein Zustand, den jemand sieht und bearbeitet, kein verbotener Datensatz.

## Betreuungsmodule (Hortvertrag)

- **Die Buchungseinheit ist Modul × Wochentag**, nicht das Modul allein: je Modul werden die einzelnen Tage gewählt. Deshalb eine Zeile je Tag statt sieben Boolean-Spalten.
- **Die Buchung hängt am Kind, nicht am Vertragsvorgang.** Der Vertragsbezug bleibt nullable und sagt nur, aus welchem Vorgang die Buchung entstanden ist — bei Betreuungsmodulen aus dem Hortvertrag des Kindes, den internes wie externes Kind gleichermaßen für sich schließt (siehe „Schulvertrag und Hortvertrag"), beim Mensa-Abo aus gar keinem.
- **Der Gültigkeitszeitraum trägt Laufzeit, Kündigung und Angebotsende:** der reale Vertrag läuft ein Schuljahr und verlängert sich stillschweigend (`prozesse.md` Abschnitt 8); `valid_until` bleibt leer, solange nichts endet, und wird bei Kündigung oder Angebotsende gesetzt. Als Datum und nicht als Regel im Code, weil die Schule Fristen und Grenzen verschiebt. **Das Angebotsende setzt der Jahreslauf** (`domains/stammdaten.md`, „Schuljahreswechsel"): Die Hort-Module gelten für Klasse 1–4, „Hort nach Mittagschule" nur für Realschule Klasse 5 — läuft eine Kohorte darüber hinaus, beendet er die betroffenen Buchungen. Ohne diesen Schritt bliebe ein Kind nach dem Wechsel in Klasse 5 auf Hort- und Küchenliste stehen.
- **Höchstens eine offene Buchung je Kind und Modul** (partieller Unique-Index): Eine Modul-Anpassung ist real „alte Buchung beenden, neue anlegen" — bleibt das `valid_until` der alten dabei leer, wären zwei Buchungen gleichzeitig aktiv und das Kind stünde doppelt auf der Küchen-Tagesliste. Der Index erzwingt die Reihenfolge und trägt damit die Zusage, dass die Laufzeit sagt, welcher Vertrag gilt.
- **Das Mittagessen ist ebenfalls eine Eigenschaft des Moduls** (`includes_lunch`): der Vertrag berechnet es für alle, die länger als 13 Uhr betreut werden — keine eigene Buchung. Das RS-Mensa-Abo bucht dieselbe Struktur als Katalogzeile „Mittagessen"; Küchenprofil und Tagesliste stehen in Domäne 6 (`domains/mensa.md`).
- Der Modulkatalog ist eine Werteliste (die sechs Betreuungsmodule plus die Katalogzeile „Mittagessen" der Mensa, `domains/mensa.md`). Die Zeitangabe steht als Text darin, weil der reale Katalog überwiegend bei „Schulende" beginnt und nicht zu einer Uhrzeit — und weil keine Abfrage sie auswertet.
- **Keine Platzkapazität am Modul — entschieden, nicht offen.** Die Anmeldetag-Checklisten weisen zwar auf „begrenzte Plätze" hin, aber die Grenze ist keine Zahl: sie hängt am Personal, das je Tag unterschiedlich ist, und die Leitung entscheidet je Fall, wann voll ist. Eine Kapazitätsspalte behauptete eine harte Grenze, die es bewusst nicht gibt — derselbe Fall wie bei der Klassenkapazität oben, und aus demselben Grund. Der Hinweis an die Eltern bleibt mündlich.
- **Die Hausaufgabenbetreuung ist Bestandteil des Moduls** (`includes_homework`): die Nachmittagsbetreuungen 2–4 enthalten sie, Modul 1 (bis 13:00) nicht. Wer sie bekommt, entscheidet allein die Modulwahl — es gibt deshalb kein eigenes Interesse- oder Buchungsfeld dafür, und die Grobabfrage „Kernzeit / Nachmittag / Ganztags" der Anmeldetag-Checklisten wird digital durch die konkrete Modulbuchung ersetzt (bewusste Abweichung vom Papierablauf).

## Zustimmung (Q1) und Dokument/Signatur (Q2)

**Zustimmung** ist *Person × (optional) Kind × Zweck × Antwort (erteilt oder abgelehnt) × Zeitpunkt × Zustelladresse × Widerruf*. Drei Punkte, die leicht verloren gehen:

- **Die Ablehnung ist eine eigene Antwort, keine fehlende Zeile.** Das Fotoeinverständnis kann ausdrücklich abgelehnt werden (`prozesse.md` Abschnitt 7.1), und ohne Zeile wäre „abgelehnt" nicht von „noch nicht beantwortet" zu unterscheiden — für die Vollständigkeitsprüfung des Sekretariats dieselbe Unterscheidung zwischen entschieden und vergessen wie bei der Anwesenheitsliste des Putzdiensts. Widerrufen wird nur eine Erteilung; eine spätere Erteilung überschreibt die Ablehnung in derselben Zeile.

- **Die Zustelladresse gehört zwingend dazu** und ist nicht aus `persons.email` ableitbar: zwei Erziehungsberechtigte dürfen sich eine Mailbox teilen, und nur mit festgehaltener Adresse ist hinterher auswertbar, ob zwei Zustimmungen über dasselbe Postfach kamen. Das Prüfskript zeigt genau diesen Fall: zwei Personen, ein Postfach.
- **Die zustimmende Person ist nicht auf Erziehungsberechtigte eingeschränkt** — ab 14 Jahren muss das Kind beim Fotoeinverständnis selbst zustimmen.

Zustimmungen ohne Kind (Werbe-Einwilligung an den anmeldenden Elternteil) sind erlaubt und trotzdem gegen Doppelung geschützt: die Eindeutigkeit ist `NULLS NOT DISTINCT`, sonst ließe sich dieselbe kindlose Zustimmung beliebig oft anlegen.

**Dokument und Signatur** sind bewusst nicht mit Q1 verschmolzen: eine Zustimmung kann ohne Dokument existieren (Häkchen), und ein Dokument trägt oft mehrere Zustimmungen (ein Schulvertrag, zwei Unterschriften). Ein Dokument hängt an genau einem Bezug — Kind oder Bewerbung.

**Eine Dokumentzeile sagt zwei Dinge, einzeln oder zusammen: angefordert und vorgelegt.** Der Anmeldetag verlangt Unterlagen, die die Eltern nicht dabeihaben — „Beobachtungsbogen einholen; falls nicht mitgebracht, bekommen die Eltern einen Bogen" (`prozesse.md` Abschnitt 5.2). Ohne Anforderungszeile wäre „fehlt noch" das Fehlen einer Zeile und damit nicht von „nie verlangt" zu unterscheiden — dieselbe Unterscheidung zwischen entschieden und vergessen wie bei der abgelehnten Zustimmung. Wird nachgereicht, trägt dieselbe Zeile beides. Zwei Folgen: Vorlagepfad und Vorlagedatum gelten nur gemeinsam (CHECK, dieselbe Bauform wie beim Masernnachweis), und der Lösch-Job darf für eine Zeile ohne Pfad keine Datei in SharePoint suchen — es gibt keine.

## Wo die Dateien liegen

**Die Dateien selbst bleiben in SharePoint**, Weltenbaum führt nur die Referenz (`domains/grenzkarte.md`, Q2). Zwei Folgen: das `pg_dump`-Backup deckt weiterhin den vollständigen Weltenbaum-Bestand ab, und der Lösch-Job muss die Datei dort mitentfernen — eine verwaiste Datei in SharePoint ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile, und sie fällt niemandem auf.

- **Zwei Ebenen:** eine Dokumentzeile nur für Unterlagen, die ein Prozess liest — die vier signierten und die am Anmeldetag angeforderten. Alles Übrige der Akte liegt im **Aktenordner des Kindes** (`child_file_folders`) ohne Zeile; über ihn erreicht der Lösch-Job auch, was Weltenbaum nie gesehen hat.
- **Die Referenz ist die Graph-Kennung** — Bibliothek plus Element, nie ein Pfad, beide nur gemeinsam gültig (CHECK). Umbenennen und Verschieben brechen sie nicht; der Zug- oder Zweigwechsel eines Kindes wird damit ein reiner SharePoint-Vorgang.
- **Zwei Bibliotheken, zwei Rollen:** die von Weltenbaum erzeugten Unterlagen sind für Menschen nur lesbar, die Schülerakte beschreibt das Sekretariat wie bisher. Direktzugriff haben allein Verwaltung und Geschäftsführung — jede feinere Sicht (Zweig, Klasse, Kind) läuft über Weltenbaum, das dieselbe Regel prüft wie für die Zeile. Deshalb braucht die **Freigabe** einen Ausgabe-Endpunkt: Schulleitung wie Hortleitung müssen den Vertrag lesen, den sie gegenzeichnen, ohne Zugriff auf die Bibliothek zu bekommen.

**Das Signaturniveau ist eine Spalte und keine Werteliste:** es gibt heute durchgängig genau eine Stufe (einfache elektronische Signatur), und eine Liste mit einer Zeile wäre ein Mechanismus ohne Bedarf.

## Vorlagen und erzeugte Dokumente

Die Schule liefert Vorlagen als **Word-Datei** — ausfüllbare PDF-Formulare entstehen dort nicht. Der Weg ist danach gewählt und nicht umgekehrt:

- **Die Vorlage bleibt eine `.docx`**, bearbeitet in Word wie bisher. Hineingeschrieben werden nur Platzhalter (`{{ kind_vorname }}`); gefüllt wird sie im Backend mit `docxtpl` (LGPL-2.1, Abhängigkeiten `python-docx` und `jinja2`, weder Word noch LibreOffice nötig) — in-process wie der Solver des Putzdiensts, kein Dienst, kein Drittanbieter.
- **PDF über Graph:** `content?format=pdf` auf der abgelegten Datei, in der M365-Lizenz enthalten. Kein Konverter im Container. Vor der Festlegung einmal mit dem echten Schulvertrag prüfen, ob das Layout trägt.
- **Verworfen:** der Power-Automate-Baustein „Populate a Word template" (Premium-Konnektor, eigene Lizenz) und SharePoint Premium/Syntex (0,15 $ je erzeugtem Dokument) — beide verstoßen gegen `rules.md` Abschnitt 4. Eine HTML-Vorlage wäre technisch sauberer, nimmt der Schule aber die Bearbeitbarkeit und scheitert genau daran.
- **Keine Word-Steuerelemente, auch nicht für Kästchen.** Eine Checkbox als Steuerelement trägt keinen Namen, den eine Vorlagen-Engine greifen könnte — sie müsste einzeln benannt werden, und das passiert im Alltag nicht. Wo ein Kästchen stehen soll, steht deshalb ein Platzhalter, der als ☒ oder ☐ gerendert wird: im PDF nicht zu unterscheiden, im Word normaler Text, und **der Platzhalter ist zugleich sein eigener Name** — sichtbar im Dokument statt in einem Eigenschaften-Dialog.
- **Die Vorlage kommt über Weltenbaum in die Bibliothek, nicht an ihr vorbei.** Sie liegt bei den erzeugten Unterlagen — dort, wo Menschen nur lesen — in einem eigenen Ordner, weil sie als einzige Datei dieser Bibliothek keinen Personenbezug hat und den Lösch-Job nichts angeht. Ändern heißt deshalb: herunterladen, in Word bearbeiten, über Weltenbaum wieder hochladen. Der Umweg ist der Zweck: der Upload ist das Prüftor (siehe nächster Punkt), und direkt in SharePoint bearbeitet liefe es ins Leere.
- **Vorschau mit Mockdaten:** Beim Hochladen zeigt Weltenbaum die erkannten Platzhalter **und rendert die Vorlage mit Beispieldaten**, damit sofort sichtbar ist, wie das Ergebnis aussieht. Ohne diesen Schritt fällt ein Fehler erst am ersten echten Vertrag auf — während ein Elternteil auf seinen Vertrag wartet. Eine Vorlage mit echten Steuerelementen wird abgewiesen.
- **Hochladen darf allein die Geschäftsführung.** Sie verantwortet die Verwaltung und besonders die Verträge; das Sekretariat liest die Vorlage, ändert sie aber nicht. Eine Rolle am Endpunkt, kein Spalten-GRANT — der Unterschied zu den fünf Fällen in `domains/stammdaten.md`, „Datensichtbarkeit".
- **Das Erzeugnis ist unveränderlich.** Es liegt in derselben Bibliothek und ist für Sekretariat und Geschäftsführung nur lesbar — niemand ändert oder löscht einen unterschriebenen Vertrag nachträglich. Der benannte Ausweg für den Einzelfall greift eine Stufe früher: die erzeugte Datei darf das Sekretariat **vor** dem Versand anpassen (`prozesse.md` Abschnitt 7.5); dafür muss niemand an die Vorlage.

### Wenn mitten im Vorgang ein Fehler auffällt

Ein Tippfehler im Namen ist der Regelfall, nicht der Ausnahmefall — die **Stammdatenbestätigung ist genau der Schritt, der ihn fangen soll** (`prozesse.md` Abschnitt 7.1). Weil Mutter und Vater asynchron arbeiten, fällt er trotzdem manchmal erst auf, wenn eine Unterschrift schon steht. Korrigiert wird nie die Datei von Hand, sondern es wird **neu erzeugt** — und zwar in dieselbe Zeile:

- **Vor Abschluss gilt das auch dann, wenn schon jemand unterschrieben hat.** Die geleisteten Unterschriften bleiben stehen; einen zweiten kompletten Signaturlauf für einen fehlenden Buchstaben verlangt das Verfahren niemandem ab. Tragfähig ist das, weil nichts verloren geht: **SharePoints Versionierung hält die unterschriebene Fassung als Dateiversion vor**, und `created_on` samt Audit-Spalten hält fest, wann neu erzeugt wurde.
- **Die Grenze ist die Vorlagenfassung** (`documents.template_version`). Neu erzeugt wird aus **derselben** Fassung, aus der die Zeile entstanden ist — dann können sich ausschließlich Platzhalter unterscheiden, und der Vertragstext unter einer bestehenden Unterschrift bleibt derselbe. Hat die Geschäftsführung inzwischen eine neue Vorlage hochgeladen, ist es kein Tippfehler mehr, sondern ein anderer Vertrag: dann neue Dokumentzeile und beide unterschreiben erneut.
- **Die Reihenfolge der Eltern ist dabei gleichgültig** — vorher wie nachher. `contract_responses` ist eine Zeile je Person ohne Rangfolge, und eine Signatur hängt an Dokument × Person; wer zuerst antwortet oder zeichnet, spielt nirgends eine Rolle. Kein Ablauf darf daraus einen erzwingen.

**Vor Abschluss bleibt der Vertragsvorgang unberührt** — genau dafür ist er eine eigene Zeile. Frist, Prüfung und Freigabe werden nicht neu aufgesetzt, weil ein Buchstabe falsch war.

### Nach der Gegenzeichnung: ein neuer Vertrag, kein überschriebener

Fällt erst nach der Freigabe auf, dass wesentliche Angaben fehlen, wird **ein neuer Vertragsvorgang aufgesetzt** und der alte bleibt stehen. Nicht aus Vorsicht, sondern weil beides sonst verloren ginge: der alte Vorgang ist der Beleg, wie damals entschieden wurde, und ein nachträglich verändertes Dokument trüge Unterschriften unter einem Text, den so niemand gezeichnet hat.

- **Mehrere Verträge je Bewerbung sind deshalb zulässig** — `contracts.application_id` trägt bewusst kein UNIQUE mehr, ebenso wenig `child_id` (dort waren mehrere Hortverträge über die Jahre ohnehin vorgesehen).
- **Es gilt der Vertrag mit dem jüngsten `confirmation_sent_at`.** Abgeleitet, kein „ist aktuell"-Kennzeichen — das wäre ein zweiter Ort für dieselbe Tatsache. Ein noch laufender Neuvorgang ändert damit nichts: bis er abgeschlossen ist, bleibt der zuletzt bestätigte der gültige, und das ist die richtige Aussage.
- **Höchstens ein offener Vorgang je Bezug** (partielle Unique-Indizes). Zwei gleichzeitig laufende Vertragsstrecken wären keine Historie, sondern ein Fehler — die Eltern bekämen zwei Links und niemand wüsste, welcher zählt.
- **Ein abgeschlossener Vertrag wird von einer späteren Vorlage nie berührt.** Muss dort doch etwas erzeugt werden, geschieht das aus *seiner* Fassung. Eine neue Vorlage gilt für neue Verträge.
- **Aufsetzen darf ihn, wer den Vorgang führt — es braucht dafür keine eigene Rolle.** Der erste Vertrag hat ohnehin keinen eigenen Auslöser: er folgt aus der Zusage, und die trifft die Aufnahmeentscheidung. Beim zweiten trägt die Absicherung die Struktur statt einer Berechtigung: gültig wird er erst mit dem Abschluss, und der setzt die **Freigabe durch die zuständige Leitung** zwingend voraus (`contracts_confirmation_after_release_check`). Die führende Stelle kann ihn also aufsetzen, wirksam macht ihn ein anderer — die Zweitprüfung ist eingebaut. Eine Rolle davorzusetzen sicherte dieselbe Zusage ein zweites Mal (`rules.md` Abschnitt 2) und sperrte ausgerechnet die Stelle aus, die den Fehler bemerkt und die Arbeit macht.

**In SharePoint bleibt das sichtbar, ohne dass Weltenbaum etwas dafür modelliert:** die erzeugte Bibliothek führt denselben Ordner je Kind, die Dateien tragen ihr Abschlussdatum im Namen. Wer den Ordner öffnet, sieht alle Verträge dieses Kindes nebeneinander in zeitlicher Folge; welcher gilt, steht in der Datenbank und ergibt sich aus dem jüngsten Abschluss. Eine Zeile hat dort ohnehin **jede** Datei — die Bibliothek trägt nichts, was Weltenbaum nicht selbst erzeugt hat.

**Das Dokument entsteht mit dem Start des Vertragsvorgangs**, nicht erst beim Unterschreiben: die Eltern müssen den Vertrag lesen können, bevor sie ihn zeichnen (`prozesse.md` Abschnitt 7.1, Schritt 3). Genau deshalb gibt es den Korrekturweg oben — ein früh erzeugtes Dokument kann veralten, und das ist eingeplant statt vermieden.
- **Fehlt beim Erzeugen ein erwarteter Platzhalter, scheitert es hart** statt still ein leeres Feld zu produzieren (`rules.md` Abschnitt 3).
- **Keine Vorlagenverwaltung und keine Versionshistorie.** Die Vorlage liegt versioniert in SharePoint und heißt wie der `document_types.code` — die Zuordnung folgt aus dem Namen, es braucht keine Tabelle und keine Spalte. **Welche Fassung galt, steht im erzeugten PDF**: es ist die Vorlage vom Tag X, ausgefüllt und unterschrieben. Das trägt auch den individuell geänderten Vertrag (`prozesse.md` Abschnitt 7.5) — die erzeugte Datei darf das Sekretariat vor dem Versand anpassen, unterschrieben wird, was daraus wurde.

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

Vor dem Dokument stehen dabei **zwei weitere Stufen**, die leicht übersehen werden, weil sie quer zur Vorgangskette liegen: eine Zustimmung zeigt auf die Signatur, die sie belegt, und eine Signatur auf ihr Dokument — beide mit `ON DELETE RESTRICT`. Die vollständige Kette lautet deshalb **Zahlung → Zustimmung → Signatur → Dokument (samt Datei) → Vertragsvorgang → Bewerbung → Kind**. Wer beim Dokument anfängt, bricht mit einer Fremdschlüssel-Verletzung ab.

**Vor dem Kind steht mehr als die Bewerbung.** Am Kind hängen weitere Zeilen mit `ON DELETE RESTRICT`, die kein Bewerbungsschritt räumt und die jeder Bewerber mitbringt, der den Anmeldetag erreicht hat: der **Aktenordner** (`child_file_folders` — die Geburtsurkunden-Kopie ist Pflichtpunkt aller vier Checklisten, also hat praktisch jeder einen), **Gesundheitsmerkmale** und **Masernnachweis** aus Domäne 9 (beide werden am Anmeldetag erhoben, nicht erst mit dem Vertrag) und das **Küchenprofil**. Sie sind vor dem Kind zu räumen, der Aktenordner samt seinem SharePoint-Ordner zuletzt — er trägt genau die Dateien, die keine Zeile nennt. Die vollständige Liste der Kindzeilen-Blocker steht in `domains/stammdaten.md`, „Löschmechanik".

**Einen Vertragsvorgang zu löschen ist nie ein einzelner Befehl** — und fachlich nur in zwei Fällen vorgesehen: eine Fehlanlage vor der ersten Unterschrift, und der Lösch-Lauf nach Ablauf der Frist. Ein abgeschlossener Vertrag eines eingeschriebenen Kindes wird nicht gelöscht; er ist die Grundlage des Schulverhältnisses und des Einzugs, und ein Austritt ist `children.exit_date`.

**Ein bereits abgeschlossener Vertrag geht auch beim Rücktritt nicht mit** (`confirmation_sent_at` gesetzt): der Lauf zum 01.08. nimmt diese Bewerbungen aus und rührt sie nicht an. Ein unterschriebener und gegengezeichneter Vertrag ist ein Rechtsdokument, auch wenn ihn niemand erfüllt hat — wie lange er bleibt, entscheidet die Aufbewahrungsfrist und nicht dieser Lauf (`TODO.md`). Beim Rücktritt **ohne** abgeschlossenen Vertrag ist von Hand nichts zu tun: der Bewerbungsstatus trägt ihn, und der Lauf räumt den offenen Vorgang samt Bewerbung.

Zwei Dinge bremsen dabei absichtlich. Die **Antworten der Eltern** fallen mit dem Vorgang (`CASCADE`) — ohne ihn sagen sie nichts. Die **Betreuungsbuchungen** blockieren ihn dagegen (`RESTRICT`): ein laufender Hortvertrag verschwindet nicht unter seinen Buchungen weg, sie sind vorher zu beenden. Und das **unterschriebene Dokument hängt nicht am Vorgang**, sondern am Kind bzw. an der Bewerbung — es fällt nicht mit, sondern wird über die Kette unten geräumt. Das ist gewollt: der Vorgang ist der Ablauf, das Dokument der Nachweis, und beide haben verschiedene Fristen.

**Eine Person kann den Lauf überdauern, ohne ihn zu blockieren.** Sechs Tabellen der Prozessdomänen zeigen mit `RESTRICT` auf `persons` — `consents`, `signatures`, `applications.filled_by_person_id`, `contract_responses`, `program_registrations` und `program_bookings.adult_person_id`. Räumt der Lauf die Bewerbung samt Anhang, fallen die ersten vier mit; hängt an derselben Person aber noch eine **Ferienprogramm-Anmeldung** mit eigener, bisher ungeregelter Frist (`domains/ferien.md`), bleibt ihre Zeile stehen. Das ist richtig so und kein Fehlschlag: sie ist dann nicht verwaist, sondern von einer anderen Domäne gehalten, und fällt in deren Lauf.

**Die Zahlung geht mit.** Der Beleg der Anmeldegebühr bleibt nicht als vorgangslose Zeile stehen: Optigem ist für die Buchhaltung führend und zieht die Zahlung selbst aus Stripe (`fachdomaenen.md` Abschnitt 4) — Weltenbaum braucht sie nach dem Verfahren nicht mehr. Das hält den Entweder-oder-CHECK an `payments` unangetastet: eine Zahlung ohne Anlass gibt es nie, eine leere Vorgangsspalte ist immer ein Fehler und nie ein Zustand.

## Was diese Domäne nicht enthält

- **Gesundheitsdaten.** Der Schulvertrag erhebt den Satz, geführt wird er in Domäne 9 mit eigenem Zugriffsprofil. Hier stehen nur die Zustimmung (Q1) und das signierte Blatt (Q2).
- **Den Masernnachweis.** Er ist ein Gesundheitsdatum und braucht Vorlagedatum und Vorlageart in Domäne 9 — eine Kopie entsteht ausdrücklich nie.
- **Die Klassenzuteilung.** Sie setzt Domäne 12; hier steht nur der Zusammensetzungswunsch als Freitext, weil er im Anmeldeformular geäußert wird.

## Offene Punkte

- Mit Sekretariat und Realschulleitung zu bestätigen: sind Grundschulempfehlung und eigenes Niveau zwei Angaben oder zwei Namen für dieselbe (siehe „Bewertung")?
- Ist der „Einschulungsuntersuchungsbericht" der Anmeldetag-Checkliste das interne Lehrerformular (`prozesse.md` Abschnitt 22)?
- Löschfristen der übrigen Entitäten stehen aus (`TODO.md`).
