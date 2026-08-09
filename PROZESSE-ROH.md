# Prozesse — Rohsammlung

**Arbeitsdatei, kein Dokumentationsstil.** Hier gelten die Regeln aus `CLAUDE.md` ausdrücklich *nicht*: Stichworte statt Sätze, Wiederholungen, Widersprüche, halbe Gedanken — alles willkommen. „Weiß ich nicht" und „müsste ich nachfragen" sind vollwertige Antworten und wertvoller als eine geratene. Lieber zu viel als zu wenig.

Zweck: den Stammdaten-Schema-Entwurf gegen die Prozesse absichern, die später damit arbeiten, statt ihn bei jedem neuen Prozessdetail nachzuziehen. Die Datei wird danach ausgewertet, ihre Ergebnisse wandern nach `fachdomaenen.md` und `domains/`, und dann wird sie gelöscht.

## Worauf es beim Auswerten ankommt

Für jeden Prozess sind drei Fragen entscheidend. Wenn du zu einem Prozess sonst nichts schreibst, dann diese:

1. **Liest** er Personendaten? Welche Felder braucht er?
2. **Verändert** er Personendaten? Welche Felder, wer löst es aus, wann im Jahr?
3. **Erzeugt** er neue Personen/Kinder/Familien? Woher kommen die Daten, wie erkennt man Dubletten, wie lange darf man sie behalten?

Dazu, wo du es weißt: Wer macht es heute? Womit (Excel, Jotform, Papier, Power Automate)? Was geht dabei regelmäßig schief?

---

## Alltägliche Datenänderungen

Vermutlich der häufigste „Prozess" überhaupt und bisher nirgends beschrieben. Wie läuft es heute, wenn sich etwas ändert?

- Familie zieht um
- Neue Telefonnummer, neue E-Mail-Adresse
- Namensänderung (Heirat, Scheidung, Einbürgerung)
- Eltern trennen sich / neuer Sorgerechtsbeschluss / ein Elternteil fällt weg
- Neues Geschwisterkind kommt an die Schule
- Neuer Notfallkontakt, neue Abholberechtigung

Für jedes: Wer meldet es wem (Zuruf, Mail, Formular)? Wer trägt es ein? Wird es an mehreren Stellen eingetragen (ASV-BW, Optigem, Excel, O365)? Wie oft kommt es vor? Merkt jemand, wenn es *nicht* eingetragen wird?

Aktuell kommen alle Änderungen entweder per Mail, Telefon oder persönlich ans Sekretariat angetragen. Hier gibt es kein offiziellen Prozess was bedeutet hier können aktuell Daten verloren gehen oder werden nicht an alle Stellen übertragen. Das ist ein großes Risiko, da je nach Änderung und ob schon aktive Eltern oder im Prozess muss in ASV-BW, Optigem oder in Excel eine Änderung vorgenommen werden und sofern eine E-Mail geändert wird auch noch in Office365 dazu. Das ist ein ganz großes Problem aktuell, dass hier kein einheitlicher Prozess existiert der auch garantiert, dass es in jedem System landet.

---

## Prozesse aus der bekannten Liste

Je Prozess: Ablauf von Anfang bis Ende, wer beteiligt ist, welche Daten hinein- und herauskommen. Reihenfolge egal, unvollständig ist in Ordnung.

### Voranmeldung

Besonders: Was steht auf dem Formular? Was passiert mit abgelehnten/nie fortgeführten Voranmeldungen? Wie unterscheidet ihr eine Voranmeldung fürs erste Kind einer neuen Familie von der eines Geschwisterkinds oder eines eigenen Grundschülers, der in die Realschule will?

Das sind die Felder die wir abfragen aktuell in der Grundschule abfragen:
kindVorname	kindNachname	kindGeschlecht	kindGeburtsort	kindGeburtsland	kindGeburtsdatum	kindMuttersprache	kindStaatsangehoerigkeit1	kindStaatsangehoerigkeit2	kindKonfession	kindKirchengemeinde	kindStrasse	kindHausnummer	kindWohnort	kindPLZ	kindTeilort	kindSchule	auskunftSchuleEinholen	vaterMutterInformiert	ausfuellendePerson	wahrgenommeneAngebote	interesseHort	erz1Art	erz1Geschlecht	erz1Vorname	erz1Nachname	erz1Konfession	erz1Beruf	erz1TelefonPrivat	erz1TelefonMobil	erz1Email	erz1Staatsangehoerigkeit	erz1Strasse	erz1Hausnummer	erz1PLZ	erz1Wohnort	erz1Teilort	erz2Art	erz2Geschlecht	erz2Vorname	erz2Nachname	erz2Konfession	erz2Beruf	erz2TelefonPrivat	erz2TelefonMobil	erz2Email   erz2Staatsangehoerigkeit	erz2Strasse	erz2Hausnummer	erz2PLZ	erz2Wohnort	erz2Teilort	Geschwister	Anmeldedatum

Das sind die Felder die wir abfragen aktuell in der Realschule:
kindVorname	kindNachname	Anmeldestatus	kindGeschlecht	kindGeburtsort	kindGeburtsland	kindGeburtsdatum	kindMuttersprache	kindStaatsangehoerigkeit1	kindStaatsangehoerigkeit2	kindKonfession	kindKirchengemeinde	kindStrasse	kindHausnummer	kindWohnort	kindPLZ	kindTeilort	kindSchule	auskunftSchuleEinholen	vaterMutterInformiert	ausfuellendePerson	wahrgenommeneAngebote	interesseHort	erz1Art	erz1Geschlecht	erz1Vorname	erz1Nachname	erz1Konfession	erz1Beruf	erz1TelefonPrivat	erz1TelefonMobil	erz1Email	erz1Staatsangehoerigkeit	erz1Strasse	erz1Hausnummer	erz1PLZ	erz1Wohnort	erz1Teilort	erz2Art	erz2Geschlecht	erz2Vorname	erz2Nachname	erz2Konfession	erz2Beruf	erz2TelefonPrivat	erz2TelefonMobil	erz2Email	erz2Staatsangehoerigkeit	erz2Strasse	erz2Hausnummer	erz2PLZ	erz2Wohnort	erz2Teilort	Geschwister	Anmeldedatum

Zum Prozessablauf muss man folgendes sagen:
- Wir veröffentlichen gegen Anfang der Herbstferien die Voranmeldung für Grund und Realschule für das folgende Schuljahr
- Hier bewerben sich alle potenziellen Interessenten, also auch ggf. Kinder die aktuell in der Grundschule sind und dann nächstes Jahr auf die Realschule bei uns wollen und natürlich auch externe Personen. Grundschule sind alle externe Personen, da wir KITA Kinder hier nicht sammeln!
- Bei der Anmeldung verlangen wir eine Anmeldegebühr, die direkt im Formular beim abschicken gezahlt wird.
- Gegen Januar gibt es einen Infoabend. Hier bekommen alle Eltern der bisher angemeldeten Kinder eine Mail mit dem Ereignis. Hier kommen dann oft auch noch einige Anmeldungen dazu nach dem Infoabend selbst.
- Je nach dem wie viele Anmeldungen wir bekommen, machen wir die Anmeldungen abhängig je nach Schule früher oder später zu. Das ist meist gegen Januar/Februar. Das muss aber dynamisch setzbar sein, da teilweise die Anmeldung auch noch weit bis in den Juni offen war.
- Oft verpassen Eltern die Voranmeldung und gehen aktuell dann über die Quereinsteiger und landen in den falschen Tabellen dadurch was ein großes Problem ist! Hier müsste man in meinen Augen hart bleiben und blockieren und ggf. einzelne Links rausgeben können über das Sekretariat, wo man sich dann individuell noch nachmelden kann in die Voranmeldung der entspechenden Schule ohne den Umweg über das Quereinsteigerformular zu machen.

### Quereinsteiger
- Hier Fragen wir die genau gleichen Felder wie bei der Realschule aber noch dazu fragen wir für welche Klasse und für welches Schuljahr sie sich bewerben.
- Hier gibt es ebenfalls eine Anmeldegebühr
- Die Anmeldungen werden direkt verarbeitet und es wird geschaut ob potenziell ein Platz in der entsprechenden Stufe verfügbar wäre und sofern das ist, gibt es ein Anmeldegespräch.

### Anmeldegespräch und Anmeldeprozess

Besonders: Welche Daten kommen dort neu dazu, welche werden korrigiert? Wer entscheidet die Aufnahme und woran hängt die Entscheidung? Was passiert zwischen Zusage und erstem Schultag?

- Vor den Anmeldegesprächen wird aktuell per Mail mit den Eltern ein Termin ausgemacht für das Anmeldegespräch, wo dann Kind + Eltern zu uns kommen und es werden sich die Kinder sowie Eltern angeschaut
- Das Anmeldegespräch wird von Lehrern abgehalten, wo verschiedene Lehrer (nicht alle) dann einzeln Kinder bewerten und dann ein Ranking erstellen, wie gut sie reinpassen würden bei uns oder halt nicht. Dazu gibt es Notizen
- In der Realschule müssen die Schüler auch Blätter lösen die bewertet werden.
- Beim Anmeldegespräch geben wir Informationen raus über den weiteren Ablauf sammeln aber keine weiteren Stammdaten ein

- Nachdem alle Gespräche rum sind, gibt es bestimmte Lehrer die final entscheiden welche Kinder genommen werden, welche wir auf die Warteliste setzen würden und welche wir ablehnen.
- Kinder die abgelehnt werden, bekommen die Eltern nur eine Mail mit der Absage und der Prozess ist abgeschlossen.
- Kinder die auf der Warteliste landen, bekommen die Elten eine Mail mit einem Link aktuell wo sie bestätigen sollen ob sie den Warteplatz annehmen wollen oder nicht. Bei Ablehnung werden die Kinder aus der Warteliste gestrichen. Bei Zusage bleiben die Kinder in der Warteliste und werden dann jedes Jahr mitgezogen in das nächste Schuljahr. Also ein Kind der Klasse 5 Warteliste wird im nächsten Schuljahr ein Kind der Klasse 6 Warteliste und so weiter. Hier wollen wir dann auch eine separate Mail rausschicken die erneut nachfragt, ob weiterhin das Interesse besteht an dem Wartelistenplatz oder nicht.
- Kinder die eine Zusage bekommen, bekommt die Mutter als auch der Vater eine separate Mail mit einem persönlichen Link ist für den Schulvertragprozess.

### Schulvertrag

Besonders: Wer unterschreibt (beide Sorgeberechtigten?), was hängt alles daran (SEPA-Mandat, Bonussystem, Putzdienstregelung), was passiert bei Änderungen mitten im Schuljahr? Gibt es einen eigenen Vertrag für die Realschule, wenn ein Kind von eurer Grundschule wechselt?


- Der Link pro Person führt zu der Wahl ob man den Schulplatz akzeptieren will oder nicht. Wenn einer nein sagt und der andere ja, wird das Sekretariat benachrichtigt und die lösen den Konflikt über Kontakt zu den Eltern, welche Entscheidung korrekt ist.
- Sofern man den Schulplatz akzeptriert wird man zu einem Formular geleitet, wo man die Stammdaten aus der Voranmeldung bestätigt. Hierbei bestätigt jeder seine eigenen Stammdaten. Also die Mutter ihre eigenen und der Vater seine eigenen und nicht die der anderen Person. Die Daten des Kindes werden von beiden bestätigt.
- Sofern die Stammdaten bestätigt sind gibt es einen Link mit dem Schulvertrag, dass sie diesen lesen können und unterschreiben diesen dann digital. Wir brauchen von beiden eine Unterschrift. Das ist aktuell eine EES
- EDanach wird gefragt ob man die Gesundheitsdaten beantworten will oder nicht. Wir speichern diese Felder aktuell ab: Einwilligung Mutter	Einwilligung Vater	Lebensmittelunverträglichkeit	Art der Lebensmittelunverträglichkeit	Allergien	Art der Allgerien	Chronisch krank	Art der chronischen Krankheit	Medikamente	Welche Medikamente?	Kind braucht Unterstützung	Kind braucht folgende Unterstützung	Attest für Medikamente	Erlaubnis für Unterstüzung	Akuter Notfall	Folgende Notfallmedikamente werden benötigt	Beschreibung Notfallsituation	Attest zur Notfallmedikation	Erlaubnis zur Verabreichung im Notfall	Körperliche Einschränkung	Art der körperlichen Einschränkung	Diese Tätigkeiten dürfen nicht ausgeführt werden	Attest zur Einschränkung	Zecken entfernen	SignaturMutter	SignaturVater
- Danach gibt es eine Fotoeinverständnis Erklärung, die man akzeptieren oder ablehnen kann: Zustimmung Mutter	Zustimmung Vater	Zustimmung Kind	Kind Mail	Kind Unterschrift Pfad	SignaturMutter	SignaturVater	SignaturKind
- Bei der Fotoeinversständniserklärung ist zu beachten, dass bei einem Kind ab 14 Jahren das Kind auch unterschreiben muss!
- Danach muss eine der beiden Personen das SEPA Mandat ausfüllen: Weicht Kontoinhaber ab	Vorname	Nachname	Straße	Hausnummer	PLZ	Wohnort	E-Mail	Konto_Name	Konto_Nachname	IBAN	BIC	Kreditinstitut	Unterschrift
- Danach ist der Prozess für die Eltern abgeschlossen, sofern beide geantwortet haben.
- Die Eltern haben 14 Tage um den Vertrag zu akzeptieren und alles auszufüllen. Sofern es Konflikte gibt mit der Zustimmung bei einem der Punkte oben, wird das Sekretariat aktiv und fragt aktiv nach was denn jetzt gelten soll.
- Sobald alle Konflikte gelöst sind, sofern welche existieren prüft das Sekretariat den Schulvertrag ob alles da ist, die Daten stimmen und bestätigen den Vertrag.
- Danach landet er bei der Schulleitung die ihn nochmals kontrolliert und freigibt. Dann wird die Unterschrift der Schulleitung aktiv unter den Vertrag gesetzt und die Eltern bekommen die Bestätigungsmail mit dem abgeschlossenen Schulvertrag

- Sonderfall: Es gibt immer wieder Eltern die den Vertrag abschließen aber dann doch zurücktreten oder den Vertrag kündigen bevor das Kind überhaupt bei uns war.
- Ebenfalls wird dieser Prozess für Quereinsteiger genutzt und muss das ganze Jahr über funktionieren


### Putzdienst

Steht großteils in `domains/putzdienst.md` — hier nur, was dort fehlt oder anders ist. Besonders die zwei offenen Vertragsfragen: Pflichtmenge „entsprechend der Schulart", und der schriftliche Stundennachweis.

- Die Pflichtmenge ist pro Familie unabhängig der Schulart. EIn Kind in der Real und Grunschule jeweils zu haben bedeutet auch nur 5+1 aktuell zu leisten und nicht 2*(5+1)!
- Der Stundenachweis wird aktuell in Excel gepflegt

### Ferienprogramm und Kochwerkstatt

Besonders: Was wird von schulfremden Kindern erfasst, und was passiert mit deren Daten nach den Ferien?

- Die Ferienanmeldung ist ein Formular, wo Eltern ihre Kinder anmelden können also mehr als ein Kind pro Formular, dass man bei 3 Kindern nicht 3 Fomrulare ausfüllen muss. So ist es aktuell zumindest gelöst.
- Im Formular gibt es die verfügbaren Termine zur Auswahl und man wählt die gewünschten Termine aus und ob eine Betreeung bis 14 oder 16 Uhr gewünscht ist.
- Danach muss man noch angegeben werden ob es ein Clemens Kind ist, eine notfallnummer, die Email ob man Werbung bekommen will und ggf. die Adresse sofern Schulfremd. Danzu kann man noch Anmerkungen machen.
- Hier mal die Excelliste die wir speichern: Wichtige Notizen	Notfall-Nummer	Clemens	Name	Vorname	Geburtstag	Mo 26.10, 14:00	Mo 26.10, 16:00	Di 27.10, 14:00	Di 27.10, 16:00	Mi 28.10, 14:00	Mi 28.10, 16:00	Do 29.10, 14:00	Do 29.10, 16:00	Fr 30.10, 14:00	Fr 30.10, 16:00	E-Mail	Werbung per Mail	Adresse	PLZ	Wohnort	Bemerkung

- Mit abschicken des Formular muss man die asugewählten Termine direkt bezahlen.
- Danach geht eine Mail raus mit der Buchungsbestätigung und sofern kein Clemens Kind wird eine Fotoeinverständnis mitgeschickt die man bitte ausfüllen soll
- Eltern stornieren öfters mal einen Termin und das gesamte Ferienprogramm. Das geht aber alles via E-Mail mit dem Hort, die dann ihre Exceldatei updaten (hoffentlich). Hier bin ich nicht involviert.

- Aktuell gibt es keine expliziten Regeln was nach dem Ferienprogramm mit den Daten passiert!

- Wichtig, das Ferienprogramm hat overall nur eine begrenzte Kapazität pro Tag und wir schließen die Anmeldung dynamisch vor dem eigentlichen Ferienprogramm, da man teilweise Sachen buchen muss und so nicht flexibel und spontan neue Kinder immer aufnehmen kann obwohl Platz wäre.

### Hort und Hausaufgabenbetreuung

- Hort und Hausaufgabenbetreuung kann man bei der Voranmeldung schon angeben ob Interesse besteht.
- Das wird im Anmeldegespräch nochmals nachgefragt und wird dann separat von den Eltern gebucht.
- Der Hort führt eine eigene Excelliste mit den Kindern, wer wann gebucht ist und notieren hier dann auch Informationen wenn irgendetwas passiert ist oder sich ein Kind daneben verhalten hat
- Mehr weiß ich vom Prozess leider nicht, lediglich, dass der Hort auch ein Frühdienst angebot hat, wo die Eltern vor der Schule ihr Kind abgeben können, bevor die Schule überhaupt angefangen hat.

### Mensa

- Mensa wird aktuell über das Sekretariat gebucht und in einer Excelliste gepflegt wer wann Essen kommt
- Wird dann über die Buchhaltung abgebucht mit dem SEPA Mandat was bei der Schulanmeldung ausgefüllt wird

### AGs

- Noch ein Zukunftprojekt. Nichts konkretes bekannt.

### Rechnungsfreigabe / Buchungsbelege

- Mitarbeiter reichen ihre Rechnungen oder Fahrtkosten in ein Formular ein mit angehangener Rechnung
- Sekretariat/Buchhaltung macht das gleiche für reguläre Rechnungen die die Schule bezahlen soll
- Beide müssen einen Vorgesetzten auswählen, in dessen Bereich die Ausgabe zustande gekommen ist
- Der Vorgesetzte gibt den Beleg frei oder nicht und kann diesen ggf. korrigieren oder an eine andere Führungskraft weiterleiten oder auf sogar mehrere Führungskräfte aufteilen, sofern geteilt werden soll mit mehreren Bereichen
- Bei Aufteilen, müssen die anderen Führungskräfte dann den Beleg akzeptieren!
- Beim akzeptieren muss man Projektnummer und Buchungskonto angeben für die Buchhaltung worauf gebucht werden soll
- Sofern ein Beleg akzeptiert wurde, geht der Beleg an die Buchhaltung zum buchen rüber
- Sofern abgelehnt bekommt die Person, wo die Beleg eingereicht hat eine Information mit dem Grund für die Ablehnung
- Dateien und Daten werden alle in SharePoint verwaltet, kein Excel!

- Code der SPFX Anwendung: /home/johannes/Documents/SPFX/bookingreceiptprocess/

### M365-Kontenverwaltung (heute Vis365)

Besonders: Wann wird ein Konto angelegt, wann gesperrt, wann gelöscht? Wer entscheidet das? Was passiert mit dem Schulpostfach eines Kindes beim Abgang?

- Wird alles vom zweiten Admin gemacht per Hand
- Im August werden die neuen Schüler für das Schuljahr im September angelegt
- Mitarbeiter und Schüler die gehen oder fertig sind werden per Hand gelöscht, sofern es dem zweiten Admin mitgeteilt wird
- Für Konto die gelöscht werden, wird eine automatische Antwort eingerichtet, sollte eine Mail an die Person geschickt werden und das Passwort wird hardresettet und nach einer bestimmten Frist das Konto komplett gelöscht
- Meist kommen die Infos aus Sekretariat/Geschäftsführung an den zweiten Admin

### Schuljahreswechsel

Was passiert im Sekretariat tatsächlich zwischen Juli und September — Schritt für Schritt, auch das Banale.

- Ende Juli: ASV-BW wird ergänzt mit den neuen Schülern via einem CSV-Import und hier muss dann leider auch noch viel per Hand editiert werden, da der Import nicht alles abdeckt
- Ende Juli: Der zweite Admin bekommt die Aufgabe die neuen Schüler anzulegen, die abgehenden Schüler zu löschen, alles Klassen umzuziehen auf die neue Klassenstufe, also die passenden Gruppen umbenennen und die Emailverteiler
- August: Sommerpause => hier passiert quasi nichts. Der Hort hat Ferienprogramm und Rechnungen und so Sachen werden verarbeitet aber nichts großes
- Anfang September: Terminkalender wird definiert, wann Feste sind. Danach wird geplant wann Putztermine sind und dann wird die Anmeldung für die Putzdienste freigeben
- Ende September wird die Schulstatistik vom Bundesland abgefragt. Hier muss ASV-BW gepflegt und poliert werden, dass der Export alle relevanten Daten hat
- Rest was gemacht wird, betrifft uns nicht so wirklich

### Abgang und Schulwechsel

Besonders: Wer erfährt es wann? Was muss dann alles passieren (Bescheinigungen, Konto, Abmeldungen bei Mensa/Hort/AGs, Optigem)?

- Sekretariat und Schulleitung wären die ersten die es erfahren.
- ASV-BW wird gepflegt und alles relevante wird in die Wege geleitet in die entsprechenden Personen und hoffentlich werden alle relevanten Personen kontaktiert und die wissen dann hoffentlich was sie alles zu tun haben. Das ist kein definierter Prozess leider....

### DSGVO Datenauskunft

- Wir haben hier keinen fixen Prozess definiert
- Wir geben auf jeden Fall die digitale Schülerakte raus, wo wir alle Dokumente speichern zu der Person die die Verwaltung hat wie Schulvertrag, Gesundheitsdaten, Fotoeinverständnis, sonstige Dokumente die im Lauf der Zeit dazu kamen
- Rest ist offen.

### KITA

Nur der Berührungspunkt zur Schule: Was teilen KITA und Schule sich an Daten oder Prozessen? Wechseln KITA-Kinder in eure Grundschule, und wenn ja, wie?

- KITA-Kinder wechseln ggf. zu uns, aber da wir die Kinder der KITA nicht tracken ist es zu werten wie externe Anmeldungen für die Grundschule
- KITA Schulen teilen sich den Office 365 Tenant, haben aber getrennte Domains. Schüler haben c-schule.de. Mitartbeiter Schule clemens.schule und KITA Mitarbeiter clemenskita.de
- Raumbuchungen, Resourcen etc. werden geteilt. Das sind also physische Sachen vor Ort
- Belegprozess wird geteilt, sonst keine Überschneidung aktuell bei den digitalen Prozessen. Kitaanmeldung läuft über die Stadt nicht uns!


---

## Daten, die heute in Excel oder SharePoint liegen

`fachdomaenen.md` nennt beispielhaft Schulvertrag und **Gesundheitsinformationen** — Letztere sind besondere Kategorien nach Art. 9 DSGVO und kommen im Stammdaten-Schema bisher überhaupt nicht vor. Was liegt dort noch?

Denkanstöße: Allergien und Unverträglichkeiten, Medikamentengabe, chronische Erkrankungen, Foto-/Videoeinwilligung, Schwimmerlaubnis, Einwilligungen für Ausflüge und Klassenfahrten, Busfahrkarten, Förderbedarf/Nachteilsausgleich, Ermäßigungen und Sozialleistungen, Bonussystem Elternmitarbeit, Elternbeirat und Ämter, Schließfach-/Schlüsselvergabe, Leihgeräte.

Je Punkt reicht: Was ist es, wer pflegt es, wer darf es sehen, kommt es nach Weltenbaum oder bleibt es wo es ist?

Alles liegt in Excellisten, was keine Stammdaten sind oder Kontoinformationen und Belegprozess liegt in SharePoint. Rest liegt zu 100% verteilt in Excellisten worauf ich keinen Zugriff habe und auch keine Kontrolle was und wo oder wer Zugriff hat!

Also was ich nennen kann ist folgendes:

Hortliste -> Hort
Ferienprogramm -> Hort
Voranmeldung -> Sekretariat + Schulleitung
Anmeldeprozess -> ICH
Kochwerkstatt -> Hausdienstverwaltung
Digitale Schülerakte -> Sekretariat (SharePoint)
Gesundheitsdaten -> Sekretariat
Mensaliste -> Hausdienstverwaltung + Sekretariat
IPAD-Liste -> Irgendjemand aus der Realschule (Apfelwerk ist hier involviert irgendwie)


---

## Prozesse, die in keiner Liste stehen

Der wichtigste Abschnitt. `fachdomaenen.md` sagt selbst, dass die Domänen-Liste nur ein erster Entwurf ist. Erinnerungshilfen:

- Welche Jotform-Formulare gibt es? Welche Power-Automate-Flows laufen?
    - Ferienprogramm, Voranmeldung GS, RS und Quereinsteiger, Anmeldeprozess GS und RS, Putzdienst
    - Haben beide jeweils Jotform Formular und PowerAutomate Prozesse
    - Belegprozess (SPFX und PowerAutomate Prozesse)
- Welche Mails verschickt die Schule regelmäßig an Eltern — und wer stößt sie an?
    - Elternbriefe, Erinnerung Elternabend, Informationen (Sekretariat)
    - Prozesse (automatisch via PowerAutomate)
- Was macht das Sekretariat an einem normalen Dienstag, das wiederkehrend ist?
    - Kann ich nicht beantworten. Alltagssachen was man so macht und was halt rein kommt und an anstehenden Themen gibt. 
- Was passiert einmal im Jahr und wird deshalb leicht vergessen?
    - Unbekannt, kenne die Schmerkzpunkte nicht was vergessen wird. Es sind eher Kleinigkeiten die vergessen werden, das sehe ich zumindest immer wieder
- Wobei ruft jemand im Sekretariat an oder schreibt eine Mail, weil es kein Formular gibt?
    - Datenänderung, generelle Fragen, Krankmeldung
- Was läuft heute rein auf Papier?
    - Putzdienst (das was Vor Ort passiert also beim eigentlichen Putzdienst)
    - Mensa Essenausgabe wird per Papier geprüft vor Ort ob das Kind berechtigt. Sind wenige Kinder daher leicht merkbar im Kopf

---

## Jahreskalender

Falls es beim Erinnern hilft — was passiert wann? Monat für Monat, auch Kleinigkeiten.
Bitte befülle es selber, obens tehen die Daten!

| Monat | Was passiert |
|---|---|
| September |  |
| Oktober | |
| November | |
| Dezember | |
| Januar | |
| Februar | |
| März | |
| April | |
| Mai | |
| Juni | |
| Juli | |
| August | |

---

## Sonstiges

Alles, was oben nirgends passt.

- Die Clemes Schule bekommt jeden Prozess kaputt und biegt alles so hin wie sie es brauchen, sofern sie es können. Anekdote: Das Sekretariat hat teilweise individuelle Verträge erstellt, da Eltern bestimmte Passagen aus dem Schulvertrag streichen wollten und das haben sie dann gemacht oder haben per Hand Sachen hinzugefügt
- Das Sekretariat ist nicht IT affine und vergessen viele Sachen, wirklich sehr viele Sachen und wissen sich oft auch nicht helfen und anstatt zu googeln lassen sie es kaputt oder unfertig liegen oder gehen mir auf dem Geist mit banalen Fragen
- Wenn etwas nicht funktioniert wie sie es wollen beschweren sie sich aber nicht bei den Personen die etwas ändern können! 
