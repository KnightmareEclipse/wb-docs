# Einzuarbeiten: die vier Mails und der Teams-Chat vom 02.09.2026

**Arbeitspapier.** Es ersetzt keine Datei — es sagt nur, was aus fünf Quellen noch nicht im Repo
steht, portioniert auf Sitzungen. Ein abgearbeiteter Punkt wird hier gestrichen; was er
hinterlässt, steht dann im Ticket, im Block oder im Schema. **Ist der letzte Punkt gestrichen, wird
die Datei gelöscht** — der Beleg ist dann das Ticket, nicht dieses Blatt.

**Quellenstand:** Postfach `johannes.nonnast@clemens.schule`, gesynct bis 03.09. 01:04. Alles
Ältere ist eingearbeitet (die Tickets 160–193 sind daraus entstanden). **Offen sind vier Mails und
ein Teams-Chat:**

| Kürzel | Uhrzeit | Betreff | Umfang |
|---|---|---|---|
| **[M1]** | 09:16 | Mitarbeiterdaten Schnittstelle HR-Tool | ein neues Thema |
| **[M2]** | 13:30 | AW: Digitalisierung & Automatisierung | Antworten auf die zehn Fragen, elf Beträge, drei Preislisten |
| **[M3]** | 19:00 | weitere Prozesse Listen & Gedanken/Fragen | fünf neue Themen |
| **[M4]** | 19:30 | **AW: Datenschutzbeauftragten Fragenkatalog** | **alle dreizehn Fragen beantwortet** |
| **[T]** | — | Teams-Chat: Fächer und Fachlehrkraft | die Fächerliste der Realschule, die Definition der Fachlehrkraft |

Drei Vorbehalte, die für alles Folgende gelten:

- Die Hort-Belegungsliste im Anhang von [M3] ist **nicht gelesen** und bleibt es.
- **[M4] markiert rot, was Jürgen am Montag noch thematisieren muss** — in der angekommenen
  HTML-Fassung ist keine Farbe mehr enthalten, sie lässt sich nicht rekonstruieren. **Vor dem
  Einarbeiten die Mail in Thunderbird öffnen und die roten Stellen hier nachtragen.** Was er selbst
  im Text als offen bezeichnet, steht unten bei DS3, DS12 und DS13.
- **[T] verweist auf einen farbigen Deputatsplan**, der als Foto vorliegt
  (`~/Downloads/Medien.jpg`, ausgewertet in A13). Er kodiert die Lehrkraft je Zelle als Farbe **ohne
  Legende** — benannt sind nur die sieben Klassenleitungen. Die Zuordnung Person→Fach→Klasse steht
  nirgends sonst, und aus dem Foto ist sie nicht vollständig lesbar.

---

## DS — Die Antworten des Datenschutzbeauftragten · [M4]

Der schwerste Teil, und der einzige, der bestehende Arbeit umwirft statt sie zu ergänzen. Zwei
Antworten drehen eine Prämisse um, auf der bereits Gebautes steht: **DS4** und **DS11**. Beide vor
den Fristen einarbeiten — sie ändern, *wie* gelöscht und angezeigt wird, die Fristen nur, *wann*.

**DS1. Die Aufbewahrungspflicht trifft die Arbeitskopie nicht — und trotzdem kippt die Prämisse.**
→ TASK-058, `grenzkarte.md`
Bestätigt: die Pflicht hängt an ASV-BW und Optigem, nicht bei uns. Aber es folgt nicht, was ich
angenommen hatte. Zwei Sätze schränken ein: **es gibt keinen Zwang, in der Kopie zu löschen, solange
das Original bleiben muss**, und bei einer teilweisen Löschung muss **gesichert sein, dass alles,
was als Original in der Schülerakte liegt — etwa der Schulvertrag —, dort erhalten bleibt**. Dazu
die ausdrückliche Empfehlung: **die Aufbewahrungspflicht lieber in unserer Datenbank erfüllen als in
ASV-BW**, weil wir die Datenbank in der Hand haben. Das ist die Umkehrung des Arguments, mit dem ich
in das Gespräch gegangen bin, und es macht die kurzen Fristen zu einer Möglichkeit statt zum
Ergebnis.

**DS2. Die Folgenabschätzung nach Art. 35 ist fällig — vor dem Livegang mit Gesundheitsdaten.**
→ neues Ticket, hängt an TASK-114
Die übrigen Prozesse dürfen vorher starten. **Sie erwarten von mir eine Deadline** („Wir brauchen
Deadline, bis wann wir DSFA brauchen. Sind flexibel.") — siehe C8.

**DS3. Die vier Voranmeldefelder bleiben, aber nur als freiwillige.** → TASK-038, TASK-030
Wörtlich: „Wir haben keinen Erlaubnistatbestand, daher können die Felder nur als freiwillige Felder
stehen bleiben. Dies muss beim Ausfüllen ersichtlich sein." Damit ist das Schema entschieden — die
Spalten bleiben nullable, und das Formular muss die Freiwilligkeit **sichtbar** tragen, nicht bloß
im Kleingedruckten. Jürgen vermerkt „=> SL": mit der Schulleitung noch abzustimmen. Ob die Werteliste
`denominations` damit einen Anfangsbestand bekommt, ist weiterhin offen.

**DS4. Die Sichtbarkeit je einzelner Angabe trägt nicht.** → TASK-152 bis TASK-163, TASK-197,
TASK-200, `soll-prozesse/08`, `09`, `15`
Die Antwort auf mein Modell ist ein klares Nein mit Begründung: „wer definiert das! Wird so auch
nicht abgefragt." An seine Stelle tritt ein grober Schnitt:

- **Lehrkräfte und Hortmitarbeitende sehen alles — für ihre Schüler.**
- **Nur die Mensa wird reduziert**, auf Allergie und Lebensmittelunverträglichkeit.

Das ist weniger fein als das, was gerade gebaut wird, und es verschiebt die Last vom Kategorienschnitt
auf die Zuständigkeit („für ihre Schüler"). **Der ganze Umbau der Gesundheitsdomäne steht damit
unter neuen Vorzeichen** — vor jedem weiteren Schritt dort zu klären, was von den offenen Tickets
noch gilt. Die zweite Hälfte der Frage — ob der Hort eine eigene Einwilligung braucht oder die
Bestätigung der Eltern beim Hortvertrag reicht — **ist unbeantwortet geblieben**.

**DS5. Die Notfalleinsicht trägt — mit vier Auflagen.** → TASK-160, TASK-200
Ja zur Konstruktion. Dazu:
- Der Mitarbeitende **sieht alles**, nicht nur die vier Felder.
- Dass ein **Attest vorliegt, muss ersichtlich sein**; das Attest selbst muss nicht einsehbar sein.
- Das **Sekretariat prüft, ob Elternangaben und Attest übereinstimmen**, und hält gegebenenfalls
  Rücksprache mit den Eltern. Das ist ein neuer Vorgang, den es bisher nicht gibt.
- **Frist 1 h** — so notiert; ob damit die Dauer der Einsicht gemeint ist, ist auszulegen (C9).
- **Je Betätigung ein Protokolleintrag und eine Meldung an die Geschäftsführung.** Adressat und
  Takt sollen später anpassbar sein (nach der Anlaufzeit ein Monats- oder Quartalsbericht).

**DS6. Nachweisfrist nach einer Veranstaltung: vier Wochen.** → TASK-162, TASK-167, Block 19
Dazu ein Mechanismus, der ab hier fünfmal wiederkehrt (siehe DS-Muster unten): eine Woche vorher
eine Mail mit Löschhinweis an **Lehrkraft und Schulleitung**, mit hinterlegtem Prüfauftrag, ob es zu
Arztbesuchen, Unfällen oder medizinischen Ausnahmesituationen kam, die die Löschung verzögern
(drohender Rechtsstreit). Die **Schulleitung kann die Löschung für eine einzelne Person stoppen**;
geschieht das, geht eine Meldung an die Geschäftsführung. Zusätzlich: **wer die Daten sehen darf,
bestimmt die Lehrkraft** — sie benennt Verantwortlichen und Begleitperson, beides nur interne
Mitarbeitende, dazu die Schulleitung. **Das restliche Anmeldeformular samt Unterschrift: drei
Jahre.**

**DS7. Fremde Kinder in Ferienprogramm und Kursen: dieselben vier Wochen.** → TASK-167, Block 10
Gleicher Mechanismus, anderer Adressat: Vorwarnung an den Veranstaltungsverantwortlichen
(Hortleitung beziehungsweise Akademieverantwortliche), Stopp-Option dort, Meldung an die
Geschäftsführung.

**DS8. Die vier getrennten Fristen stehen.** → TASK-058.06, TASK-192, TASK-195
- **Schulvertrag: 5 Jahre nach Austritt.**
- **SEPA-Mandat: 2 Jahre nach Austritt.**
- **Gesundheitsangaben: 3 Monate** — mit Vorwarnung an Schulleitung beziehungsweise Hortleitung,
  Prüfauftrag und Stopp-Option wie in DS6. Der Bezugstag ist nicht genannt (C10).
- **Fotoerlaubnis: unbegrenzt**, und die Begründung trägt die Mechanik mit: Bei Widerruf muss die
  **Nutzung unterbunden und das Bildmaterial gegebenenfalls gelöscht werden können**, und es muss
  **ersichtlich bleiben, dass die Erlaubnis bis zu diesem Tag galt** — genau dafür wird sie
  unbegrenzt gehalten. Der von mir vermutete Widerspruch löst sich damit auf: unbegrenzt ist der
  Nachweis, nicht die Erlaubnis.

**DS9. Von den sechs weiteren Fristen sind vier gesetzt, zwei nicht.** → TASK-058.01 bis .09
- **Bewerbung ohne Aufnahme: 6 Monate.** Zwei Wochen vorher Löschankündigung an das Sekretariat mit
  der Option, nicht zu löschen; Meldung an die Geschäftsführung.
- **Ferienbuchung: 6 Monate.** Dasselbe, Adressat Hortleitung.
- **Rücktritt vor dem ersten Schultag: 5 Jahre, wie der Schulvertrag.**
- **Ersetzter Vertrag: die Fünfjahresfrist läuft erst ab Austritt** — für die Ursprungsfassung wie
  für jedes Update. Das ist strenger als gedacht: der alte Vertrag hängt am Austritt des Kindes,
  nicht an der Freigabe seines Nachfolgers.
- **Mail an Personen, die wir nicht als Familie führen: nicht bewertbar.** Wörtlich: „kann nicht
  bewertet werden, da wir Kontext nicht verstehen. Wer sind die betroffenen Personen / warum kein
  Text" — siehe C11.
- **Übrige Betriebsdaten: keine Aufbewahrungspflicht**, aber eine Einschränkung: aus der
  Elternmitarbeit entsteht eine Rückzahlung, die **noch drei Monate nach dem Schulwechsel abrufbar
  sein soll**. Und eine Rückfrage an mich, was das für den Löschzeitpunkt bedeutet (C12).

**DS10. Ausgeschiedene Mitarbeitende: der Name bleibt am Nachweis.** → TASK-058.07
„Name und Mailadresse wird nicht aktiv aus nachweispflichtigen Zusammenhängen entfernt." Damit ist
der zweite Teil meiner Frage beantwortet — der Nachweis bleibt vollständig. **Eine Frist für den
Mitarbeitenden-Eintrag selbst ist damit aber nicht genannt**, und die war der erste Teil.

**DS11. Der jährliche Lösch-Lauf mit zwei Rollen fällt weg.** → TASK-007, TASK-009, TASK-056,
TASK-183, TASK-194
Die Antwort dreht die Konstruktion um: „Aufgrund der Fristen müssen die Routinen regelmäßig laufen.
Es müsste eher so sein, dass das Löschen wie an vielen Stellen beschrieben gestoppt/unterbunden
werden kann." Statt eines Menschen, der einmal im Jahr auslöst, also **ein laufender Mechanismus mit
Vorwarnung und Einspruch**. Dazu die Rückfrage, ob ich das ohne Datenleichen abbilden kann — ohne
Zeilen, die stehen bleiben und niemandem mehr zuzuordnen sind, und ohne Löschungen, die anderes
mitreißen (C13). **Block 17 ist damit noch nicht geschrieben, aber schon anders zu schreiben.**

**DS12. Die Bildungskarte ist vertagt.** → TASK-170, überschreibt A6
„Die Frage kann erst nach Klärung des Ausflugsprozesses beantwortet werden. Es könnte eine Option
geben, die keine Info über Bildungskarte erforderlich macht." **Diese Mail ist eine halbe Stunde
jünger als [M2]** und hebt damit das dortige vorläufige „A" auf. Die Sichtbarkeit bleibt offen, bis
der Ausflugsprozess steht — und der hängt an den Unterlagen, die Montag kommen (D1).

**DS13. Die Geburtsurkunde wird künftig nur eingesehen.** → TASK-054
Ja zur bloßen Einsicht. Prüfprozess und Praktikabilität klärt Jürgen am Montag — der Beschluss steht,
die Umsetzung im Sekretariat nicht.

### Das Muster, das fünfmal wiederkehrt

DS6, DS7, DS8 und beide Fristen in DS9 beschreiben denselben Ablauf. Er gehört **einmal** nach
`soll-prozesse/hebel.md` und wird von den Blöcken genannt, nicht wiederholt:

> Vor Ablauf einer Frist geht eine **Vorwarnmail** an eine benannte Stelle — eine Woche vorher bei
> Gesundheitsangaben, zwei Wochen bei den übrigen. Sie trägt einen **Prüfauftrag**: ob ein Vorgang
> vorliegt, der die Löschung verzögert (Arztbesuch, Unfall, drohender Rechtsstreit). Die Stelle kann
> die Löschung **für eine einzelne Person stoppen**. Jeder Stopp geht als **Meldung an die
> Geschäftsführung**.

Das ist kein Detail an fünf Fristen, sondern der Kern des Lösch-Laufs: Er löscht nicht, er kündigt an
und löscht, was niemand aufhält.

---

## A — Antworten, die ein bestehendes Ticket schließen oder ändern

Kurze Läufe, alle aus [M2]. Jeder Punkt ist eine Entscheidung, die schon gefallen ist; einzutragen
ist sie nur noch.

**A1. Die fünf offenen Beträge sind bestätigt** → TASK-051
Alle mit `valid_from` **sofort**: `care_change_fee_cents` 20 €, `care_sibling_discount_basis_points`
10 %, `mileage_rate_cents` 0,30 €/km, `expense_report_threshold_cents` 250 €,
`parent_bonus_monthly_cents` 10 €. **Die Änderungsgebühr trägt eine Bedingung**, die kein Betrag
ist: sie fällt nur an, wenn *keine* Stundenplananpassung vorliegt und *kein* Zeitpunkt greift, zu
dem eine Anpassung kostenfrei möglich wäre. Das gehört in Block 09, nicht in den Wert.

**A2. Die drei Preislisten liegen vor** → TASK-050
- **Schulgeld, gültig ab 01.08.2026:** Grundschule 145 €, Realschule 150 €. Geschwister: 1. Kind
  (höchste Klassenstufe) keine Ermäßigung, 2. Kind −20 €, 3. Kind −40 €, ab dem 4. Kind
  beitragsfrei — je auf den Grundpreis der besuchten Schulart.
- **Mensa, gültig ab September 2026:** 1 Tag 21,50 € · 2 Tage 42,50 € · 3 Tage 63,50 € · 4 Tage
  84,50 € · 5 Tage 105,00 € je Monat, Tagesessen 5,90 € pro Fall. **Auf elf Monate kalkuliert, der
  August ist beitragsfrei** — das ist eine Regel und kein Preis.
- **Hort, gültig ab September 2026** (Spalte „Neue Preise"): Frühbetreuung 12 € · Nachmittag 1 (bis
  13:00) 12 € · Nachmittag 2 (bis 14:30) 1 Tag 27 €, 5 Tage 130 € · Nachmittag 3 (bis 15:30) 1 Tag
  37 €, 5 Tage 175 € · Nachmittag 4 (bis 17:00) 1 Tag 73 €, 2 Tage 126 €, 3 Tage 168 €, 4 Tage
  189 €, 5 Tage 210 € · Hort nach Mittagsschule (RS Klasse 5, 15:00–17:00) 1 Tag 23 €. Ferien:
  8–14 Uhr 22 €, 8–16 Uhr 28 € bei Selbstverpflegung.
  **Die Notfallbetreuung ist aus der Tabelle nicht eindeutig lesbar** — siehe E3.

**A3. Rollenvergabe bestätigt, mit einer Ausnahme** → TASK-190
Die Regel steht (Führungskraft vergibt ihren Bereich, Personalwesen den Rest, Admin alles). **Aber:
die Hauswirtschaftsleitung darf nicht mit der Haustechnik verknüpft sein.** Küche ja, Hausmeister
nein. Offen bleibt damit, wer die Hausmeister-Rolle vergibt — siehe C4.

**A4. meinCLEMENS wird nach außen sichtbar** → TASK-188
Der Name soll in der Portaladresse und im Mailabsender auftauchen. Zwei Rückfragen hängen daran,
die den Ticketumfang verdoppeln — siehe C1.

**A5. Bildungskarte: drei Korrekturen am notierten Ablauf** → TASK-170, TASK-171, TASK-172
- Leere oder abgelaufene Karte: die Kosten bleiben **nur dann** bei uns, wenn wir zu spät abrechnen
  und das Versäumnis bei uns liegt; sonst wird mit dem Guthaben verrechnet.
- Das **Schullandheim kann** über die Bildungskarte abgerechnet werden — es ist nicht ausgenommen.
- Das **Mittagessen kann teilweise** über die Bildungskarte abgerechnet werden. Das zieht die
  Mensa-Domäne in den Ablauf, die bisher nicht darin vorkommt.

**A6. Bildungskarte, wer sie sieht: hinfällig** → TASK-170
In [M2] stand ein vorläufiges „A" (dauerhaft am Kind, für Lehrkräfte sichtbar). **DS12 aus der
späteren Mail hebt das auf** — die Frage ist vertagt, bis der Ausflugsprozess steht. Nicht
einarbeiten.

**A7. Ausflugskonto: die Lehrkraft sieht den Stand ihrer Klasse (B)** → TASK-170, TASK-171
Für die Eltern**sicht** ist die Antwort ein weiches Nein („Bauchgefühl", begründet mit dem bisher
schlecht laufenden Prozess) — als Entscheidung notieren, nicht als Beschluss. Offen: wie der
eingezogene Pauschalbetrag ins System kommt (siehe C2).

**A8. Akademie-Freigabe: eine Person, noch nicht benannt** → TASK-179, TASK-180
Eine zentrale Person prüft Rahmen und Wording, nicht die jeweilige Leitung. Wer, klärt Jürgen mit
Corrado und Sabine. Ticket bleibt offen, aber die Struktur ist entschieden.

**A9. Schulvertragsupdate, wenn niemand bestätigt: A **und** B** → TASK-126
Erst Erinnerung, dann Sperre im Portal — und in beiden Fällen ein Hinweis ans Sekretariat, damit es
nachgehen kann. Begründung: ob ein Vertrag ohne bestätigte wesentliche Änderung weiterläuft, ist
eine Prüfung, kein Automatismus.

**A10. Elternbonus: die Mechanik ist bestätigt** → TASK-164 bis TASK-166
Elf Monate à 10 €, im zwölften Monat anteilig erstattet nach geleisteten Stunden (15 Grundschule,
10 Realschule). Das deckt sich mit dem Gebauten; einzutragen ist nur die Bestätigung. **DS9 hängt
eine Bedingung daran**: drei Monate nach dem Schulwechsel muss die Rückzahlung noch abrufbar sein.

**A11. Akademie-Struktur steht** → TASK-176 bis TASK-180
Zwei Zweige unter einem Dach: **Seminarangebote für Erwachsene** und **Kursangebote für Kinder und
Jugendliche**. Kategorien darunter werden später benannt. Für die Eltern soll das Wort womöglich
„Kursangebote/AGs" heißen statt „Akademie". **Der Erwachsenen-Zweig ist neu und nicht gebaut** —
siehe B1.

**A12. Die Fächer der Realschule und die Definition der Fachlehrkraft** · [T] → TASK-197, TASK-161
Damit ist beantwortet, was DS4 offenlässt: „für ihre Schüler" heißt Klassenleitung für die eigene
Klasse, Fachlehrkraft für die Klassen, in denen sie unterrichtet.

- **Pflichtbereich (17):** Religionslehre/Ethik, Deutsch, Englisch, Mathematik, Geschichte,
  Geographie, Gemeinschaftskunde, WBS, Physik, Chemie, Biologie, Musik, BK, Sport, Schwimmen,
  Reflexion BO, Medienbildung/Informatik.
- **Wahlpflichtbereich (3):** Technik, AES, Französisch. **Diese drei sind klassenübergreifend** —
  damit hat TASK-161 (Unterrichtsgruppen als zweite Achse der Sichtbarkeit) seine konkreten Gruppen
  und ist keine Vorsorge mehr.
- **Fachlehrkraft ist, wer in einer Klasse unterrichtet, ohne ihre Klassenleitung zu sein.** Das
  kann in jedem Pflichtfach vorkommen — **außer Religion: die liegt konzeptionell immer bei der
  Klassenleitung**, in Realschule wie Grundschule. Religion ist damit das einzige Fach, das nie
  eine Fachlehrkraft-Sicht erzeugt.
Das Ticket TASK-197 ist damit nicht mehr „Sichtkreis der Fachlehrkraft festlegen", sondern
„Unterrichtsverhältnis je Fach und Klasse führen" — heute steht dort `sports` stellvertretend für
alle Lehrkräfte ohne Klassenleitung, und genau diese Krücke fällt weg.

**A13. Die Grundschule: Fächer, Klassen und Klassenleitungen** · [T], `~/Downloads/Medien.jpg`
Aus der **Deputatsverteilung 2026/27** (V.1), einem Foto der ausgedruckten Tabelle.

- **Fächer (13):** Religionslehre, Deutsch, Deutsch Erzählkreis, Deutsch +, D (Förder/Vertiefung),
  Heimat- und Sachunterricht, Englisch, Mathematik, M (Förder/Vertiefung), Bildende Kunst/Text.Werk,
  Text.Werk, Musik, Sport. **Deutsch und Mathematik zerfallen in mehrere Zeilen** — Kernfach,
  Erzählkreis, Plus, Förder/Vertiefung. Ein Fach ist damit nicht die kleinste Einheit; das
  Unterrichtsverhältnis hängt an dieser feineren Zeile, sonst fällt Förderunterricht mit dem
  Kernfach zusammen.
- **Klassen (7):** 1a, 1b, 2a, 2b, 3a, 3b, 4 — die vierte Stufe ist einzügig.
- **Klassenleitungen:** 1a Laura · 1b Sara · 2a Silvie · 2b Jasmina · 3a Cordula · 3b Silvia ·
  4 Mike.
- Die Tabelle führt **Wochenstunden je Fach und Klasse** (Summe 177 bzw. 183) — ein Deputatsplan,
  keine Sichtbarkeitsregel. Für Weltenbaum ist nur die Zuordnung Person→Fach→Klasse interessant,
  nicht die Stundenzahl.
- **Religionslehre trägt in jeder Klasse die Farbe ihrer Klassenleitung** — die Regel aus A12
  bestätigt sich in der Tabelle. Umgekehrt zeigt Deutsch in der 2a, dass selbst ein Kernfach an eine
  Fachlehrkraft geht (dort Hanne, während Silvie die Klasse führt).
- **Die Farblegende fehlt** (C14). Ohne sie ist die Tabelle nicht auslesbar: Zwei Farben sind auf dem
  Foto kaum zu trennen, und Personen ohne Klassenleitung tauchen nur als Farbe auf.

**Nebenbefund für TASK-049:** Dieser Deputatsplan ist eine der „nebenher gepflegten Listen" — und
zwar diejenige, aus der das Unterrichtsverhältnis für TASK-161 und TASK-197 stammen müsste.

---

## B — Neue Themen, für die es noch kein Ticket gibt

Hier entstehen Tickets, teils Blöcke. Jeder Punkt ist eine eigene Sitzung wert.

**B1. Seminarangebote für Erwachsene** · [M2]
Die Akademie hat einen zweiten Zweig, der auf Teilnehmer zielt, die weder Kind noch Mitarbeitende
sind. Das Datenmodell kennt diese Person nicht: kein Kind, kein Vertrag, kein Portalzugang über eine
Familie. Zu klären ist, ob der Zweig zum Start dabei ist — ist er es, ist er kein Ableger des
Kursangebots, sondern ein eigener Personenkreis mit eigener Löschfrist.

**B2. Schnittstelle zum neuen HR-Tool** · [M1]
Das Tool kommt voraussichtlich ab Januar und bietet laut Jürgen Integrationsmöglichkeiten. Gefragt
ist eine erste Einschätzung: welche Mitarbeiterdaten Weltenbaum überhaupt braucht und was davon
automatisiert übernommen werden könnte. **Der Name des Tools fehlt** (siehe C6) — ohne ihn ist die
Einschätzung geraten. Was Weltenbaum heute an Mitarbeitenden führt, ist die halbe Antwort: Name,
dienstliche Mailadresse, Schule oder KITA, erster und letzter Arbeitstag, Rolle, Nachfolgenotiz.
Mehr braucht es nicht, und genau das ist zu sagen.

**B3. Notfallbetreuung als buchbarer Vorgang** · [M3]
Eltern sollen sie im Portal buchen können — **Hortkinder wie Nicht-Hortkinder**. Die Mitarbeitenden
haken ab beziehungsweise tragen nach. Für die Kinder, die unangekündigt in der Notbetreuung landen,
bleibt es bei Papier und Übertragung. Die Preise stehen in der Hortliste (A2), ihre Zuordnung ist
unklar (E3). Berührt Block 09 und die Mensa (Tagesessen 5,90 €).

**B4. Hort-Belegungsliste aus dem System** · [M3]
Jürgen fragt, ob die Belegungsliste mit ihren verschiedenen Sheets künftig erzeugt werden kann. Die
Datei ist bewusst ungelesen, damit ist die Frage nicht beantwortbar — es fehlt, welche Sheets es
gibt und welche Spalten darin stehen. Siehe C7.

**B5. Ferienprogramm: Warnung ab den letzten fünf Plätzen** · [M3]
Platzzahl je Termin und das automatische Schließen sind gebaut (`schema/ferien-schema.sql`, Block
10). Neu ist nur die Mail an die Hortleitung, sobald noch fünf Plätze frei sind. Kleines Ticket,
gehört zum Ferien-Lauf.

**B6. Sponsorenlauf** · [M3]
Ein Kind läuft Runden, Sponsoren aus dem persönlichen Umfeld zeichnen einen Betrag je Runde. Heute:
QR-Code, Liste, hinterher Spendenaufforderungsbrief. Gewünscht: die Sponsoren tragen sich selbst
ein, **ohne Zugang zu meinCLEMENS**. Buchhaltung braucht Person und Betrag, weil es
spendenbescheinigungsrelevant ist, und den Abgleich mit dem Spendeneingang. Das ist ein neuer
Prozess mit einem neuen Personenkreis (fremde Erwachsene ohne Vertragsverhältnis) — Erhebung,
Zweck, Frist und ein zugangsloser Schreibweg sind alle offen.

**B7. Alumni-Kommunikation** · [M3]
Mail-, Newsletter- und Einladungsversand, heute „mehr schlecht als recht" über Optigem. Neuer
Prozess, und zwar einer mit Einwilligung, Abmeldeweg und einem Bestand, der nach dem Abgang
ausdrücklich *nicht* gelöscht wird. Das verträgt sich nicht mit den Fristen aus DS8 und DS9 und
gehört deshalb vor dem Bauen zurück an den Datenschutzbeauftragten.

**B8. Die Folgenabschätzung nach Art. 35** · [M4] → hängt an TASK-114
Aus DS2: fällig vor dem Livegang mit Gesundheitsdaten, die übrigen Prozesse dürfen vorher starten.
Eigenes Ticket, mit der Deadline aus C8 als Fälligkeit.

**B9. Das Sekretariat prüft Attest gegen Elternangabe** · [M4] → hängt an TASK-160
Aus DS5: ein Vorgang, den es heute nicht gibt — Abgleich, Rücksprache mit den Eltern, und irgendwo
muss stehen, dass ein Attest vorliegt, ohne dass es einsehbar ist.

---

## C — Rückfragen, die eine Antwortmail brauchen

Sie kosten mich je zwei Sätze, aber ohne sie steht das jeweilige Ticket still. C8 bis C13 stammen
aus [M4] und sind die dringenderen: An ihnen hängt, ob die Fristen überhaupt gebaut werden können.

**C1. Absender und Domain von meinCLEMENS** · [M2] → TASK-188, TASK-088
Jürgen fragt zweierlei: kommt die Absendermail künftig auch von meinCLEMENS, und **kann die Domain
`meinCLEMENS.schule` heißen — das wäre ihnen lieber**. Eine zweite Domain ist kein Etikett: sie
braucht Beschaffung, DNS, SPF/DKIM/DMARC und zieht TASK-088 (DMARC auf `reject`) mit. Preis und
Aufwand gehören in die Antwort, die Wahl bleibt bei ihm.

**C2. Wie kommt der Pauschalbetrag ins System?** · [M2] → TASK-170
Jürgen fragt, ob der Betrag von der Buchhaltung kommen kann, zum Zeitpunkt der Erhebung. Antwort
gehört zum Ausflugskonto und ist Voraussetzung für dessen Bau.

**C3. Trennung der Eltern im laufenden Vertrag** · [M2] → neu, gehört zu Block 02/08
Wörtlich: ob berücksichtigt ist, dass es im laufenden Vertrag zu Trennungen kommt und dann
Änderungen vorgenommen werden können. Das ist keine Randfrage — es betrifft Sorgerecht,
Vertragspartnerschaft und wer künftig unterschreibt.

**C4. Wer vergibt die Hausmeister-Rolle?** · [M2] → TASK-190
Folgt direkt aus A3: die Hauswirtschaftsleitung soll es nicht sein.

**C5. AGFEO: Anlagentyp und der Weg hinein** · [M2] → TASK-189
Jürgen hat recherchiert und liefert: das Dashboard hat keine dokumentierte REST-API, bindet aber
ODBC- und LDAP-Quellen ein; gebraucht werden Name, Vorname, Firma, Telefon geschäftlich, Mobil,
optional Mail. Er fragt zurück nach Anlagentyp und Datenbank. **Vor der Antwort ist zu bewerten, ob
eine Telefonanlage direkt in der Weltenbaum-Datenbank lesen darf** — das ist ein Zugriff von außen
auf einen Bestand mit Elterndaten und keine Formatfrage.

**C6. Wie heißt das HR-Tool?** · [M1] → B2

**C7. Welche Sheets hat die Hort-Belegungsliste?** · [M3] → B4
Zu erfragen als Struktur, nicht als Datei: Sheet-Namen und Spaltenüberschriften genügen.

**C8. Bis wann brauchen wir die Folgenabschätzung?** · [M4] → DS2, B8
Sie sind flexibel und erwarten den Termin von mir. Er sollte am Livegang der Gesundheitsdaten
hängen, nicht am Kalender.

**C9. Was bedeutet „Frist 1 h" bei der Notfalleinsicht?** · [M4] → DS5
Vermutlich, wie lange die Einsicht offen bleibt — es könnte aber auch die Frist für die Meldung an
die Geschäftsführung sein. Zwei verschiedene Mechaniken, eine Zeile.

**C10. Ab welchem Tag laufen die drei Monate für die Gesundheitsangaben?** · [M4] → DS8
Ab Austritt, ab dem Ende des Erhebungsanlasses oder ab der letzten Änderung — das steht nicht dabei,
und die drei fallen weit auseinander.

**C11. Wer sind die Empfänger der Mails ohne Familie?** · [M4] → DS9c
Der Datenschutzbeauftragte kann die Frist nicht bewerten, weil ihm der Kontext fehlt: wer die
Betroffenen sind und warum kein Mailtext gespeichert wird. Beides ist in zwei Sätzen erklärt — es
sind Eltern, die eine Bestätigung bekommen, bevor sie überhaupt als Familie geführt werden.

**C12. Was heißt „drei Monate abrufbar" für den Löschzeitpunkt?** · [M4] → DS9f
Gegenfrage aus der Mail: keine Pflicht, aber es soll noch möglich sein, auf die Daten zuzugreifen —
wie lange, und was ist dafür vorgesehen? Zu beantworten für Putzdienst, Elternmitarbeit, Mensa und
Rechnungsfreigabe zusammen.

**C13. Kann der Lösch-Lauf ohne Datenleichen gebaut werden?** · [M4] → DS11
Die Frage ist an mich gerichtet und beantwortbar: keine verwaisten Zeilen, keine Löschung, die
anderes mitreißt. Genau dafür steht die achtstufige Reihenfolge im Kopf von
`schema/querschnitt-schema.sql`. Die Antwort ist ein Ja mit Verweis — und sie ist die Voraussetzung
dafür, dass der umgebaute Lauf beauftragt wird.

**C14. Die Farblegende des Deputatsplans** · [T] → A13, TASK-161, TASK-197
Der Plan kodiert die Lehrkraft je Zelle als Farbe, ohne Legende — sieben davon sind über die
Klassenleitungen benannt, alle übrigen nicht (Hanne kam nur auf Nachfrage heraus). Zu erbitten ist
nicht das Bild in besserer Auflösung, sondern **die Tabelle als Datei**: Klasse, Fach, Lehrkraft im
Klartext. Damit ließe sich das Unterrichtsverhältnis der Grundschule einmalig befüllen, statt es von
Hand nachzupflegen. Dasselbe für die Realschule, wo bisher nur die Fächerliste vorliegt.

**C15. Darf die Akademie-Freigabe später entfallen?** · [M2] → A8, TASK-179
Wörtlich: „Kann das später dann auch ohne Laufen, wenn wir hier die Aufbauarbeit abgeschlossen
haben?" Also ob die Prüfung durch eine zentrale Person eine Anlaufhilfe ist oder dauerhaft bleibt.
Das entscheidet, ob der Freigabeschritt eine abschaltbare Einstellung braucht oder fest verdrahtet
wird — ein Unterschied im Bau, nicht bloß im Ablauf.

---

## D — Blockiert

**D1. Die Ausflugsunterlagen kommen erst Montag (07.09.)** · [M2]
Die Excel lag Jürgen nur auf Papier von Mike und Daniela vor. Bis dahin bleiben **TASK-169** und
**TASK-171** stehen — und mit DS12 hängt jetzt auch die Sichtbarkeit der Bildungskarte daran.

**D2. Zwei Nachfragen sind unbeantwortet geblieben** · [M2] → TASK-034, TASK-087
Am Ende von [M2] standen zwei Punkte unter „nur nachhaken, keine Entscheidung" — **das
Stripe-Konto samt AVV, Frist 14.09.**, und die **Antwort der Cyber-Versicherung zur
Verschlüsselung**. Unter beiden steht ein leeres „ANTWORT:". Ohne das Stripe-Konto kann im
September niemand online freikaufen, und die Frist ist in elf Tagen. Beide beim nächsten Kontakt
zuerst stellen, sie sind je ein Satz.

**D3. Drei Punkte klärt Jürgen selbst am Montag** · [M4]
Die vier Voranmeldefelder mit der Schulleitung (DS3), der Prüfprozess zur Geburtsurkunde (DS13) und
was sonst rot markiert ist. **Die roten Stellen fehlen hier** — siehe den Vorbehalt oben.

---

## E — Funde beim Abgleich

**E1. Die Anmeldegebühr steht zweimal verschieden.**
TASK-051 nennt `contract_fee_cents` **90 €**, die Fragenmail an Jürgen nennt sie unter den
bestätigten Werten mit **100 €** — und er hat diesen Block als „nichts mehr zu tun" durchgewinkt.
Einer der beiden Werte ist falsch, und der bestätigte ist der jüngere. Vor dem Seed klären.

**E2. Die Pflichtstunden stehen im Ticket vertauscht.**
TASK-051 schreibt `parent_bonus_required_hours_primary` 10 und `_secondary` 15. Richtig ist
umgekehrt — Grundschule 15, Realschule 10, so steht es in
`schema/elternbonus-schema-check.sql:551` und so hat Jürgen es bestätigt („10RS/15GS"). Nur der
Ticket-Text ist falsch, das Schema ist richtig.

**E3. Die Notfallbetreuungspreise sind aus der Tabelle nicht eindeutig lesbar.**
In `26_Preisanpassungen Hort ab SJ26-27.xlsx` stehen für die Notfallbetreuung die Werte 8 / 8 / 12 /
16 / 20 in der Spalte, die anderswo mit „Stadt*" überschrieben ist — also der Vergleichsspalte, nicht
der eigenen. Daneben stehen in der ersten Spalte „20 € pro Fall" (Nachmittag bis 17 Uhr), „8 € pro
Fall" (eine Stunde innerhalb der Öffnungszeiten) und „20 € pro Fall" (halbe Stunde außerhalb).
Bevor das in `care_module_prices` landet, muss Jürgen die Zuordnung bestätigen — sonst steht ein
Fremdpreis in unserer Liste.

**E4. Der Jahresfreikauf von 210 € fehlt in der bestätigten Betragsliste.**
Block 01 rechnet ihn als Summe der offenen Pflichttermine
(`soll-prozesse/01-putzdienst.md:124`); in den elf Werten, die Jürgen gerade bestätigt hat, kommt er
nicht vor. Wenn er eine gerundete Pauschale sein soll und nicht das Rechenergebnis, fehlt ihm ein
eigener `configured_value`.

**E5. Zwei Antworten aus [M4] sind unvollständig geblieben.**
Zu DS4 fehlt die Hälfte: ob der Hort eine eigene Einwilligung braucht oder die Bestätigung der
Eltern beim Hortvertrag reicht. Zu DS10 fehlt die Frist für den Mitarbeitenden-Eintrag selbst —
beantwortet ist nur, was mit seinem Namen an den Nachweisen geschieht. Beides beim nächsten Kontakt
nachziehen, nicht als beantwortet abhaken.
