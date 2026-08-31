# Für den Termin beim Datenschutzbeauftragten — Mi 02.09.2026

Jürgen, das hier ist dein Blatt. Eine Vorfrage und vierzehn Punkte, je vier Zeilen: worum es geht,
**was im System wirklich gespeichert ist**, was du sagst, was du mir zurückbringst.

Die mittlere Zeile ist die wichtigste. Ohne sie entscheidet er über „die Schülerdaten" — also über
einen Bestand, den es bei uns gar nicht gibt, und dann fallen alle Fristen zu lang aus.

**Zwei Stellen hängen an dem, was wir am Dienstag entscheiden**, sie sind mit **⟨offen⟩** markiert.
Die trage ich nach unserem Gespräch nach, bevor du losgehst.

---

## Was Weltenbaum ist — die zwei Minuten am Anfang

> „Wir bauen eine Plattform für unsere eigenen Verwaltungsabläufe. Heute laufen die auf sechs
> Jotform-Formularen, einer Reihe Excel-Listen und Papier, und keines davon weiß vom anderen —
> eine Familie, die umzieht, meldet das an drei Stellen. Künftig gibt es einen Ort dafür.
>
> **Eltern** melden sich mit ihrer Mailadresse und einem Code an, der ihnen per Mail kommt — kein
> Passwort. Sie sehen ihre Putzdiensttermine, Verträge, Ferienbuchungen und Mitarbeitsstunden,
> unterschreiben dort und tragen einen Umzug selbst ein.
>
> **Mitarbeitende** melden sich mit ihrem Schulkonto an und sehen, was ihre Rolle hergibt: das
> Sekretariat den ganzen Bestand, die Klassenlehrkraft ihre Klasse, die Küche ihre Essensliste, die
> Buchhaltung ihre Zahlen. Das ist keine Einstellung, die jemand pflegt — es ist in die Anwendung
> gebaut.
>
> Abgebildet werden die Vorgänge, die wir ohnehin haben: Voranmeldung und Anmeldetag,
> Aufnahmeentscheidung, Schul- und Hortvertrag, Mensa, Ferienprogramm, Putzdienst, Elternmitarbeit,
> Datenänderungen, Abgang, Schuljahreswechsel, Klassen, Rechnungsfreigabe und die M365-Konten."

**Und im selben Atemzug, was es *nicht* ist** — das ist der Teil, der ihm Arbeit spart:

> „Es ist **keine Schulverwaltungssoftware**: ASV-BW bleibt, wie es ist. **Keine Buchhaltung**:
> Optigem bleibt. **Keine Personalverwaltung.** **Kein Klassenbuch** — Untis bleibt. Und es enthält
> **keine Noten, keine Bewertungen und keine Gesprächsnotizen** aus dem Aufnahmeverfahren; die
> bleiben bei den Lehrkräften und werden wie heute nach Abschluss vernichtet."

**Wo die Daten liegen** — falls er fragt, und er wird:

| | |
|---|---|
| Server | eigener virtueller Server bei der **Hetzner Online GmbH, Standort Falkenstein/Deutschland**. Kein Drittland-Transfer. AVV liegt vor; seine Anlage 1 nennt ausdrücklich die besonderen Kategorien nach Art. 9 |
| Anmeldung, Mailversand, Dateien | **Microsoft** — unser bestehender Tenant: Entra ID für die Mitarbeitendenanmeldung, Graph für den Mailversand, SharePoint für die Schülerakte. Vom Tenant-AVV gedeckt |
| Zahlungen | **Stripe** — Betrag und Zahlungsreferenz, **kein Name**; die Mailadresse tippt der Elternteil auf Stripes eigener Bezahlseite selbst ein. AVV wird mit dem Konto geschlossen |
| Überwachung | **healthchecks.io** — ein Lebenszeichen und ein Festplattenwert, nie ein Personendatum |
| Sicherung | unser **eigenes NAS** im Haus, verschlüsselt. Kein weiterer Dienstleister |

**Ein Eintrag nach Art. 30 liegt fertig vor** — Zwecke, Datenkategorien, Empfänger, Fristen,
Maßnahmen. Den bringe ich mit, sobald die Fristen unten stehen.

---

## Womit du anfängst

Drei Sätze, bevor die erste Frage kommt. Sie kürzen das Gespräch erheblich ab:

1. **„Weltenbaum ersetzt weder ASV-BW noch Optigem."** Die aufbewahrungspflichtige Führung bleibt
   dort. Bei uns steht eine Arbeitskopie für die Abläufe, die wir digitalisieren.
2. **„Es ist keine Personalverwaltung."** Von Mitarbeitenden stehen dort nur Name, dienstliche
   Mailadresse, ob sie zur Schule oder zur KITA gehören, erster und letzter Arbeitstag und die
   Rolle im System. Kein Gehalt, kein Arbeitsvertrag, keine Bewerbungsunterlagen.
3. **„Zu jeder Frage sage ich dir, was genau gespeichert ist."** Steht unten bei jedem Punkt.

Und einer für dich: **Was er entscheidet, gilt** — auch wenn es teurer wird. Wir holen keine
Wunschantwort.

---

## Zuerst: trifft die schulrechtliche Aufbewahrungspflicht auch uns?

**Worum es geht:** Alle Fristen weiter unten hängen an dieser einen Antwort. Solange nicht feststeht,
wie lange ein Kind nach dem Abgang bleiben **muss**, ist jede einzelne Frist eine Vermutung.

**Im System:** die Stammdaten des Kindes und seiner Familie, mit dem Austrittsdatum als Anker. Die
aufbewahrungspflichtige Führung liegt in ASV-BW und Optigem — bei uns steht eine Arbeitskopie für
die Abläufe, die wir digitalisieren.

**Du fragst:** „Welche Aufbewahrungspflicht nach baden-württembergischem Schulrecht trifft uns, und
trifft sie unsere Arbeitskopie genauso wie die Führung in ASV-BW? Wenn die Pflicht dort hängt und
nicht bei uns, dürfen wir in Weltenbaum deutlich früher löschen — dann erübrigen sich die meisten
Fristen weiter unten."

**Du bringst zurück:** eine Aussage, ob die Pflicht die Arbeitskopie erfasst — und wenn ja, wie lange
ein Kind nach dem Abgang bleiben muss.

---

## 1 · Die vier Felder der Voranmeldung — *der eiligste Punkt, mit der Schulleitung*

**Worum es geht:** Wir erheben Konfession, Beruf und Staatsangehörigkeit der Eltern sowie die
Kirchengemeinde des Kindes. Für keines dieser vier Felder ist bei uns ein Zweck festgehalten.

**Im System:** vier Textangaben aus dem Voranmeldeformular, an den Eltern beziehungsweise am Kind.

**Du sagst:** „Die Religionszugehörigkeit zählt nach Art. 9 DSGVO zu den besonderen Kategorien. Das
heißt nicht, dass wir sie nicht erheben dürfen — es heißt, dass es dafür einen benannten Zweck und
eine Rechtsgrundlage braucht, und genau die ist bei uns nirgends festgehalten. Solange noch keine
echten Daten im System sind, ist ein Streichen ein Handgriff; danach ist es ein Eingriff in bereits
erhobene Personendaten."

**Du bringst zurück:** **Je Feld** einen benannten Zweck oder ein klares Nein. Vier Antworten, nicht
eine.

---

## 2 · Vier Fristen statt zwei — und die Fotoerlaubnis

**Worum es geht:** Du hast selbst vorgeschlagen, Schulvertrag, SEPA-Mandat, Fotoerlaubnis und
Gesundheitsdaten getrennt zu befristen. Das ist richtig. Der Haken steckt beim Foto.

**Im System:** der Schul- bzw. Betreuungsvertrag als PDF samt Unterschriften und der Angabe, wer wann
welche Fassung bestätigt hat; das SEPA-Mandat mit IBAN und Mandatsreferenz; die Fotoerlaubnis als Ja
oder Nein je Person mit Zeitpunkt; die Gesundheitsangaben am Kind. Was tatsächlich eingezogen wurde,
steht **nicht** im System — das bleibt in Optigem.

**Du sagst:** „Beim Foto möchten wir die Einwilligung so lange halten, wie es das Bildmaterial gibt,
auf das sie sich bezieht — ein einmal veröffentlichtes Foto verschwindet nicht mehr, und wir müssen
im Streitfall nachweisen können, dass die Einwilligung vorlag, Art. 7 Abs. 1. Mir ist aber klar,
dass ‚unbegrenzt' und ‚jederzeit widerrufbar' sich beißen: Nach Art. 7 Abs. 3 kann jemand jederzeit
widerrufen — dann ist die Einwilligung weg, der Nachweis, dass sie *bis dahin* galt, aber nicht. Ist
das die richtige Konstruktion, oder brauchen wir eine Frist ab dem letzten veröffentlichten Bild?"

**Du bringst zurück:** vier Fristen, je mit dem Tag, ab dem sie zählt — und beim Foto die Aussage, ob
„unbegrenzt" trägt.

---

## 3 · Gesundheitsdaten: ein Bestand für Schule und Hort ⟨offen⟩

**Worum es geht:** Heute fragen sechs Formulare dasselbe getrennt ab. Künftig gibt es **einen**
Gesundheitsbestand je Kind, und wer wie viel davon sieht, hängt an der Rolle.

**Im System:** je Kind Unverträglichkeiten, Allergien, Notfallmedikation samt Erlaubnis,
Zeckenentfernung und die weiteren Angaben — gestaffelt nach Einsicht:

- Klassenlehrkraft der eigenen Klasse, Sekretariat und Schulleitung sehen alles
- andere Lehrkräfte und die Hortkräfte sehen die Alltagsangaben
- die Küche sieht ausschließlich Unverträglichkeit und Allergie

Zu den Mitarbeitenden kommt das über die Klassen- bzw. Betreuungsliste, **nie per Mail und nie als
Export**.

**Du sagst:** „Der Hort erhebt nichts zum zweiten Mal, er liest denselben Bestand — abgestuft. Im Weg
steht nur ein Satz im Betreuungsvertrag, der zusagt, die Angaben würden ‚ausschließlich den
Betreuungskräften' bekannt. Der stimmt schon heute nicht und verbaut nebenbei der Klassenlehrkraft
die Einsicht; er muss ohnehin geändert werden."

**Du bringst zurück:** ob die abgestufte Einsicht so trägt — und ob die Weitergabe an die Hortkräfte
eine eigene Einwilligung braucht oder ob der geänderte Betreuungsvertrag sie deckt.

---

## 4 · Gesundheitsdaten externer Ferienkinder ⟨offen⟩

**Worum es geht:** Du meintest, wir erheben sie für externe Kinder auch. In meinem Modell tut das
Ferienprogramm das ausdrücklich nicht — wir klären am Dienstag, was stimmt.

**Im System, falls es sie gibt:** Art.-9-Daten von Kindern, die sonst **keinerlei** Bezug zur Schule
haben und für die es kein Austrittsdatum gibt, an dem sonst gerechnet würde.

**Du sagst, falls das Formular sie erhebt:** „Wir erheben Gesundheitsangaben auch von Kindern, die
gar nicht bei uns zur Schule gehen. Welche Frist gilt dafür, gerechnet ab dem letzten gebuchten
Termin?"

**Du bringst zurück:** eine eigene Frist — sie ist nicht dieselbe wie die der Buchung.

---

## 5 · Drei Fristen, die noch offen sind

**Worum es geht:** Drei Fälle aus meiner Mail vom 28.08., zu denen noch keine Antwort da ist.

| | Frist für | Im System steht | Zählt ab |
|---|---|---|---|
| a | eine Bewerbung, aus der nichts geworden ist | Name, Geburtsdatum, Anschrift des Kindes, gewünschte Schulart und Stufe, die Formularangaben, das Ergebnis (Zusage/Warteplatz/Absage) — **und die Elternzeilen, die dabei entstanden sind**. Keine Gesprächsnotizen, keine Bewertungen | dem Tag, an dem die Absage feststeht |
| b | eine Ferienbuchung, auch bei schulfremden Kindern | Name und Geburtsdatum des Kindes, bei schulfremden auch die Anschrift, eine Notfallnummer, die gebuchten Tage, die Zahlung | dem letzten gebuchten Termin |
| c | eine Mail an Leute, die wir nicht als Familie führen | **nur** die Mailadresse, der Anlass in einem Wort, der Versandzeitpunkt, ob zustellbar. Kein Mailtext | dem Versanddatum |
| d | einen Rücktritt vor dem ersten Schultag | der unterschriebene Vertrag samt Unterschriften — ein Rechtsdokument, auch wenn es niemand erfüllt hat | dem vereinbarten ersten Schultag |
| e | einen ersetzten Vertrag, dessen Nachfolger schon läuft | die alte Fassung als Beleg, dass sie bis dahin galt | dem Tag, an dem der neue freigegeben wurde |
| f | alles Übrige — Putzdienst, Elternmitarbeit, Mensa, Rechnungsfreigabe | Betriebsdaten ohne Bezug zu einer Akte | hier reicht die Bestätigung, dass darauf keine Aufbewahrungspflicht liegt |

**Du sagst zu a:** „Eure Arbeitshilfe zur Auskunft kennt schon die Kategorie ‚abgesagte Schüler,
deren Daten gelöscht wurden'. Es gibt also eine gelebte Praxis — nach welcher Frist?"

**Und eine Nachfrage, die zu Punkt 8 gehört:** Zeugnis, Grundschulempfehlung und Beobachtungsbogen —
liegen die im Ordner der Schülerakte oder tragen sie eine eigene Frist? Im Ordner deckt die längste
Frist sie mit ab; hängen sie am Kind, brauchen sie eine eigene.

**Du bringst zurück:** fünf Zahlen und eine Bestätigung.

---

## 6 · Datenauskunft: Frist und Zuschnitt

**Worum es geht:** Eure Arbeitshilfe vom 05.03.2026 ist gut und beschreibt den Ablauf lückenlos —
**sie nennt aber keine Frist.**

**Im System:** Weltenbaum kann alles, was zu einer Person oder einem Kind gehört, auf Knopfdruck
zusammenstellen. Es wird damit **eine weitere Zeile in eurer Tabelle**, kein Ersatz für sie: Vis365,
Optigem, ASV, AGFEO, Untis, Teams/Fobizz, die Postfächer und die Fotobestände bleiben Handarbeit
nach der Checkliste.

**Du fragst:** „Art. 12 Abs. 3 gibt uns einen Monat, verlängerbar um zwei. Setzen wir intern etwas
Kürzeres, und ab welchem Tag läuft die Frist — Eingang der Anfrage oder abgeschlossene
Identifizierung?"

**Du bringst zurück:** eine Frist. Und die Entscheidung, ob unser Auszug der Checkliste **beigelegt**
wird oder ob er die Positionen **ersetzt**, die heute per Screenshot aus Vis365 und ASV kommen.

---

## 7 · Datenpanne: was eure Arbeitsanweisung nicht abdeckt

**Worum es geht:** Eure Arbeitsanweisung vom 13.11.2023 ist gut und hat beim letzten Vorfall
funktioniert. Sie regelt aber nur den Weg im Haus: Mitarbeiter → Vorgesetzter → Geschäftsführer →
gegebenenfalls du. **Ein Adressat außerhalb kommt darin nicht vor.**

**Du fragst nach drei Dingen:**

1. **Art. 33** — die Meldung an die Aufsichtsbehörde binnen 72 Stunden, in Baden-Württemberg an den
   Landesbeauftragten. Wer entscheidet, ob gemeldet wird, und wer meldet?
2. **Art. 34** — die Benachrichtigung der Betroffenen, wenn ein hohes Risiko besteht.
3. **Art. 33 Abs. 5** — die Dokumentation **jedes** Vorfalls, auch dessen, den wir nicht melden.
   Wo wird sie geführt?

**Und einer, der uns eigen ist:** „Unsere Kette beginnt bei ‚Mitarbeiter meldet dem Vorgesetzten'.
Eine Panne im neuen System bemerkt womöglich zuerst unser Entwickler — der in dieser Kette keinen
Vorgesetzten hat. Der Weg muss auch von dort beginnen können."

**Du bringst zurück:** einen Namen für die Meldung und einen Ort für die Dokumentation.

---

## 8 · Die digitale Schülerakte in SharePoint

**Worum es geht:** Zu jedem Kind gehört ein Ordner, in den das Sekretariat ablegt, was anfällt.

**Im System:** nur der **Ordner** und ein Verweis darauf am Kind. Was drinliegt, weiß das System
nicht — dort wird von Hand abgelegt. Befristen lässt sich deshalb der Ordner als Ganzes, nicht sein
Inhalt Stück für Stück. Ein vergessener Ordner in SharePoint ist genauso ein Verstoß wie eine
vergessene Zeile in der Datenbank.

**Du fragst:** „Reicht es, wenn wir für den ganzen Ordner die **längste** der Fristen ansetzen? Wenn
ja, sparen wir uns Unterordner je Dokumentart — die kosten, dass jemand beim Ablegen jedes Mal den
richtigen treffen muss, und ein falsch abgelegtes Dokument wird zu früh oder nie gelöscht."

**Du bringst zurück:** ein Ja zur längsten Frist, oder die Liste der Dokumentarten, die eigene
Ordner brauchen.

---

## 9 · Wer den Lösch-Lauf anstößt und wer ihn bestätigt

**Worum es geht:** Du hast entschieden, dass ein Mensch ihn anstößt statt eines Automatismus — das
steht. Offen sind die Rollen, und die wolltest du mit ihm klären.

**Im System:** ein Lauf einmal im Jahr, der abgelaufene Fristen räumt — in der Datenbank **und** in
SharePoint, sonst bliebe die Datei stehen.

**Du fragst:** „Welche zwei Rollen? Einer stößt an, ein anderer bestätigt hinterher, dass er richtig
gelaufen ist — nicht dieselbe Person."

**Du bringst zurück:** zwei benannte Rollen.

---

## 10 · Ausgeschiedene Mitarbeitende

**Worum es geht:** Deine Antwort war „Nur Name — sonst nix!". Die Frist selbst fehlt noch.

**Im System:** keine Personalakte. Name, dienstliche Mailadresse, Schule oder KITA, erster und
letzter Arbeitstag, die Rolle, gegebenenfalls eine Notiz zur Nachfolge.

**Du fragst zweierlei:** „Erstens: Wie lange behalten wir das nach dem letzten Arbeitstag? Und
zweitens: Sein Name hängt auch an Dingen, die er bestätigt hat — ein freigegebener Beleg, eine
geführte Klasse. Bleiben diese Nachweise stehen, wenn sein Eintrag verschwindet, oder muss der Name
dort mit weg?"

**Du bringst zurück:** eine Frist und eine Aussage zu den Nachweisen.

---

## 11 · Die Geburtsurkunde

**Worum es geht:** Du hast selbst geschrieben, rein datenschutzrechtlich wärt ihr mit Einsicht statt
Kopie besser dran. Es fehlt nur der Beschluss.

**Im System heute:** ein Scan in der Schülerakte. **Künftig, wenn er zustimmt:** nur der Vermerk,
dass sie vorlag — wie beim Masernnachweis, wo wir uns schon dagegen entschieden haben.

**Du fragst:** „Spricht etwas dagegen, dass das Sekretariat das Original am Anmeldetag sieht und nur
abhakt?"

---

## 12 · Bildungskartenkinder und die Hortakte — zwei neue Bestände

**12a · Bildungskarte.** Ihr führt eine Liste der Kinder mit Bildungskarte, weil bei jedem Ausflug
und jedem Schullandheim sofort gemeldet werden muss.

> **Wichtig für deinen Wortlaut:** Das ist **kein** Art.-9-Datum. Es ist ein **Sozialdatum** —
> Bildungs- und Teilhabepaket nach § 28 SGB II, Sozialgeheimnis nach § 35 SGB I. Sag nicht „Art. 9",
> sonst redest du an ihm vorbei. Die Folge ist dieselbe: so eng wie möglich halten.

**Du fragst:** „Wie eng muss der Leserkreis sein? Heute soll es für jede Lehrkraft sichtbar sein —
damit ist für das ganze Kollegium erkennbar, welche Familien Sozialleistungen beziehen. Ginge auch:
Die Information erscheint nur der Lehrkraft, die gerade einen Ausflug anlegt, als Aufgabe."

**12b · Hortakte und Verhaltensdokumentation.** Der Hort führt eine Betreuungsakte, in der
Absprachen und Verhalten dokumentiert werden, künftig wieder mit Beobachtungsbögen — und sie soll
auch für externe Hortkinder möglich sein.

**Du sagst:** „Das ist der heikelste Bestand, den wir haben — heikler als die Gesundheitsangaben,
weil er eine Bewertung enthält und weil Eltern ihn bei einer Auskunft sehen dürfen."

**Du bringst zurück:** wie eng der Leserkreis sein muss, ob Eltern ihn vollständig zu sehen bekommen,
und welche Frist er trägt — bei einem externen Hortkind gerechnet ab dem letzten Betreuungstag, denn
ein Austrittsdatum hat es nicht.

---

## 13 · Unsere Rechtsgrundlagen — bestätigen oder verwerfen

**Worum es geht:** Unser Verzeichnis nach Art. 30 trägt zu jedem Zweck eine Rechtsgrundlage. Neun
davon sind **meine Annahme** und nicht seine Aussage. Er ist der Erste, der sie prüft.

**Im System:** Anbahnung und Durchführung des Schul- bzw. Betreuungsvertrags (Art. 6 Abs. 1 lit. b)
für Stammdaten, Putzdienst, Anmeldung, Ferien, Mensa, Klassen und Konten; berechtigtes Interesse
(lit. f) gegenüber Eltern beim Elternbonus; für die Gesundheitsangaben die Einwilligung (Art. 9
Abs. 2 lit. a), für den Masernnachweis § 20 IfSG.

**Du fragst:** „Tragen diese Grundlagen? Bei den Gesundheitsangaben habe ich einen Zweifel: Auf eine
Einwilligung gestützt kann ein Elternteil sie jederzeit widerrufen — dann müsste die Allergieangabe
verschwinden, während die Klassenlehrkraft sie im Alltag braucht. Ist dafür eine andere Grundlage
die richtige?"

**Du bringst zurück:** ein Ja zu den übrigen und eine Aussage zu den Gesundheitsangaben.

---

## 14 · Braucht das eine Datenschutz-Folgenabschätzung?

**Worum es geht:** Art. 35 verlangt sie unter anderem bei umfangreicher Verarbeitung besonderer
Kategorien. Wir haben Gesundheitsangaben zu jedem Kind, dazu kommen die Bildungskarte und die
Verhaltensdokumentation des Horts.

**Im System:** ein Bestand über die Kinder der Schule und des Horts, mit abgestufter Sichtbarkeit je
Rolle. Keine Profilbildung, keine automatisierte Entscheidung, keine Beobachtung öffentlicher
Bereiche.

**Du fragst:** „Siehst du hier eine Folgenabschätzung nach Art. 35 fällig? Falls ja, sag es jetzt —
dann planen wir sie ein, statt sie kurz vor dem Start zu entdecken. Und fallen wir in die Muss-Liste
des Landesbeauftragten?"

**Du bringst zurück:** ein Ja oder Nein. Bei Ja: wer sie schreibt und bis wann.

---

## Wenn die Zeit nicht reicht

Diese Reihenfolge, und den Rest schriftlich nachreichen lassen:

1. **Die Vorfrage** (schulrechtliche Aufbewahrungspflicht) — sie kürzt alles Folgende ab.
2. **Punkt 1** (die vier Felder) — daran hängt der Zeitpunkt des Datenimports.
3. **Punkt 2 und Punkt 5** (die Fristen) — ohne sie löscht das System gar nichts.
4. **Punkt 14** (Folgenabschätzung) — ein Ja verschiebt den Zeitplan, das willst du früh wissen.
5. **Punkt 3** (Gesundheitsdaten Schule/Hort) — daran hängt der Betreuungsvertrag.
6. **Punkt 13** (Rechtsgrundlagen) — schriftlich nachreichbar, aber vor dem Import fällig.

Alles Übrige kann eine Mail werden.
