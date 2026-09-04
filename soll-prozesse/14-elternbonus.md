# 14. Elternbonus Elternmitarbeit

## Auslöser

Keiner: Die Pflicht hängt am Schulvertrag — eine Anlage neben der Putzdienstregelung
([08](08-schulvertrag.md)) — und läuft mit dem Schuljahr. Jede Familie zahlt zusätzlich zum
Schulgeld derzeit **10 € je Monat**, den August ausgenommen, im vollen Schuljahr also 110 €, und
holt sie sich über **Mitarbeitsstunden** zurück: derzeit 15 Stunden, wenn ein Grundschüler dabei
ist, sonst 10. Nicht additiv, der größere Wert entscheidet, und maßgeblich ist die höchste Zahl, die
im Schuljahr galt. Gezählt wird ganzjährig, gerechnet einmal, nach dem 31. Juli.

Der Bonus hängt an der [Familie](hebel.md#familie-und-kind): zwei Kinder bedeuten denselben Betrag
und dieselben Stunden wie eines. Er hängt dabei an eingeschriebenen Kindern — eine Familie mit
Bewerbung, Warteplatz oder nur einem externen Hortkind ([09](09-hortvertrag.md)) zahlt nichts,
leistet nichts und bekommt keine der Mails dieses Prozesses.

## Beteiligte

- **Ausschreiben dürfen sechs [Rollen](hebel.md#rollen)**, nicht jede und keine neue: Hausmeister
  (Baueinsatz), Lehrkraft (Begleitung des eigenen Ausflugs), Sekretariat (Schulfest, alles Übrige),
  Schulleitung, Hauswirtschaftsleitung (Küche und Kochwerkstatt) und Hortleitung (Aktionen des
  Horts). Wer Hände braucht, schreibt selbst aus, statt sie erst bei einer Stelle zu bestellen, die
  dann eine Rundmail schreibt. **Draußen bleiben die Rollen, die niemanden anzusprechen haben** —
  die schlichte Mitarbeitendenrolle, Küchenpersonal, Rechnungsfreigabe, Personalwesen — und die
  beiden KITA-Rollen, wie überall in diesem Block. Das kostet keine neue Rolle und keine Spalte: Wer
  eine Route aufrufen darf, steht in `api/elternbonus-api.md` wie bei jeder anderen; die Liste ist
  hier nur kürzer als „alle".
- Eltern melden sich zu einem Einsatz an und tragen ihre geleisteten Stunden selbst ein; jede sorgeberechtigte Person darf beides allein, gezählt wird für die Familie, gleich wer gearbeitet hat.
- **Niemand bestätigt eine Stunde.** Was die Eltern eintragen, zählt.
- Die Buchhaltung verrechnet die Rückzahlung mit dem Schulgeld und bekommt dafür eine
  [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail).
- Die Geschäftsführung pflegt Monatsbetrag und Pflichtstunden als
  [Werte im System](hebel.md#geld-und-fristen-im-system-alles-andere-fest).
- Das Sekretariat hat hier **keine laufende Arbeit**: es korrigiert, wo es klemmt, und trägt für die
  Familie ohne Portal stellvertretend ein.

Ausgelesen wird, welche Kinder eingeschrieben sind und in welcher Schulart
([04](04-schuljahreswechsel.md)), ab wann ([08](08-schulvertrag.md)) und bis wann
([03](03-irregulaerer-abgang.md)), wer eine [Mitarbeiterrolle](hebel.md#rollen) trägt und wer im
Schuljahr Elternvertreter war (16).

## Ablauf

| # | wer | tut was | danach steht fest |
|---|---|---|---|
| 1 | Die sechs Rollen oben | Schreiben einen **Einsatz** aus: Tag, Beginn, in einem Satz die Tätigkeit, dazu freiwillig ein paar Sätze, warum es ihn gibt, den Treffpunkt und was mitzubringen ist. Dazu zwei Angaben, die entscheiden, wer ihn überhaupt sieht und wie viele mitkommen können — **wen er anspricht** und, wo sie nötig ist, **wie viele Plätze** es gibt. Mehrere Einsätze sind mehrere Ausschreibungen, auch am selben Tag | wofür Hände gebraucht werden, wann, wo, und wer gefragt ist |
| 2 | Eltern | Sehen die Einsätze, die sie betreffen, und melden sich an oder wieder ab, bis der Einsatz beginnt. Ist eine Platzzahl gesetzt und erreicht, ist zu — **wer zuerst kommt**, und kein Nachrücken, dieselbe Regel wie beim Ferienprogramm ([10](10-ferienprogramm.md)). Wer sich abmeldet, gibt seinen Platz frei. Die Familie sieht, wie viele sich angemeldet haben, nicht wer | wer an diesem Tag zu erwarten ist |
| 3 | System, am Vortag | Mail an alle Angemeldeten: Tag, Beginn, Treffpunkt, Mitzubringendes. **Das ist der Punkt, an dem heute Einsätze vergessen werden** | dass niemand ihn übersehen hat, weil die Mail vier Wochen alt war |
| 4 | Eltern | Tragen eine geleistete Stunde ein, sobald sie geleistet ist: Datum, Stundenzahl in halben Stunden, in einem Satz die Tätigkeit. Kommt sie von einem ausgeschriebenen Einsatz, sind Datum und Tätigkeit vorausgefüllt und es bleibt die Stundenzahl. **Der Einsatz ist dabei kein Muss**: Was die Eltern unter sich regeln — der Fahrdienst der Grundschule vor allem — wird ohne Einsatz eingetragen, und das ist kein Sonderfall, sondern der häufigere Weg | dass diese Stunde zählt; sie zählt sofort |
| 5 | System, 1. Juni | Mail an jede Familie, deren Stunden noch nicht voll sind: Stand, was fehlt, was es wert ist, und dass am 31. Juli Schluss ist. Wer als voll gilt, ohne eine Stunde geleistet zu haben, bekommt sie nicht — Elternvertreter- und Mitarbeiterfamilien (Sonderfälle) | dass die Familie es wusste, bevor die Frist ablief |
| 6 | System, 1. August | Schließt das am 31. Juli beendete Schuljahr — nicht das gerade begonnene — und rechnet je Familie. Er rechnet dabei **vor dem [Jahreslauf](04-schuljahreswechsel.md)**, der am selben Tag die Stufen aufrückt: Sonst stünde ein Viertklässler, der in die eigene Realschule wechselt, schon als Realschüler da, und die Familie hätte für das vergangene Jahr 10 statt 15 Pflichtstunden. Zwei Läufe an einem Tag, und dieser ist der erste. Gerechnet wird: **je eingetragener Stunde ein Fünfzehntel bzw. ein Zehntel des vollen Jahresbetrags** — derzeit 7,33 € bzw. 11 € —, höchstens aber, was der Familie in diesem Schuljahr berechnet wurde. Legt die Jahresliste als **eine** Aufgabe bei der Buchhaltung an | was jede Familie geleistet hat und was ihr nach unserer Rechnung zusteht — der Deckel trägt Quereinsteiger und Abgänger ohne eigene Regel |
| 7 | Buchhaltung | Verrechnet die Beträge mit dem Schulgeld und hakt ab. **Maßgeblich ist ihre Abrechnung, nicht unsere Zahl**: Wir rechnen mit den Monaten, in denen ein Kind eingeschrieben war, und wissen nicht, was tatsächlich eingezogen wurde — unsere Zahl ist ein Vorschlag wie das Enddatum auf der Abgangsliste ([03](03-irregulaerer-abgang.md)) | die Rückzahlung ist übergeben und das Schuljahr abgeschlossen |

**Abgesagt wird von beiden Seiten.** Die Eltern melden sich ab, solange der Einsatz nicht begonnen
hat — ihr Platz ist damit wieder frei, und die Schule erfährt es an ihrer Liste, nicht per Mail.
Die Schule sagt den ganzen Einsatz ab und **gibt dabei einen Grund an, wenn sie einen hat**
(„Dauerregen angesagt"); alle Angemeldeten bekommen sofort eine Mail, und der Grund steht darin.
Genau dafür sammelt die heutige Umfrageliste Mailadressen von Hand ein — hier stehen sie schon.
Der abgesagte Einsatz bleibt stehen und ist der Beleg dafür, dass die Mail rausging.

## Was dabei erhoben wird

Je Eintrag Datum, Stundenzahl in halben Stunden und die Tätigkeit in einem Satz (alles Pflicht),
dazu der Einsatz, wo die Stunde von einem kommt — mehr nicht, insbesondere keine Kategorie und kein
Schlüssel: eine Stunde ist eine Stunde, gleich wobei.

Je Einsatz Tag, Beginn, Tätigkeit, freiwillig eine Beschreibung, Treffpunkt und was mitzubringen
ist, dazu wer sich angemeldet hat und — nach einer Absage — deren Grund. Die **Beschreibung** ist
das, was heute im Fließteil der Rundmail steht („damit die neuen Klassenzimmer im Herbst fertig
sind"); die meisten Einsätze erklären sich mit ihrer Tätigkeit und brauchen sie nicht.
**Kein Ende und keine Dauer am Einsatz**: Wie lange jemand bleibt, entscheidet sich vor Ort und steht
ohnehin in der Stunde, die er einträgt.

Dazu zwei Angaben, die den Einsatz zuschneiden:

- **Wen er anspricht.** Ohne Angabe alle Familien. Mit Angabe eine Liste, deren Einträge sich
  vereinigen und die zweierlei Form haben: eine **benannte Klasse** — „die 8a und die 8b" sind zwei
  Einträge — oder einen **Zuschnitt** aus Schulart und Stufenspanne: „die Realschule", „ab
  Klasse 7", „Klasse 5 bis 7". Beides nebeneinander geht auch: die ganze Grundschule und dazu die 8a.

  Die zwei Formen sind kein Komfort, sondern zwei verschiedene Zeitverhalten: Eine benannte Klasse
  bleibt, was sie ist; ein Zuschnitt gilt auch für Kinder, die später dazukommen. Wer „die ganze
  Realschule" als Liste ihrer Klassen aufzählte, hätte im nächsten Schuljahr eine Klasse zu wenig —
  genau der Fehler, den niemand bemerkt.
- **Wie viele Plätze** — freiwillig, denn meistens gibt es keine Grenze. Wo sie steht, ist sie
  **hart**: Wenn nur vier Personen mitfahren dürfen, ist der fünfte einer zu viel, und daran ändert
  auch der Zufall zweier gleichzeitiger Anmeldungen nichts. Beim Baueinsatz wäre eine Person mehr
  egal — die Regel richtet sich nach dem Fall, in dem sie zählt, und gilt dann überall.

Sichtbar für die Familie nach ihrer [Einsichtsstufe](hebel.md#einsichtsstufe), für Sekretariat und
Schulleitung. **Wer sich angemeldet hat, sieht der Hausmeister; die Eltern sehen nur die Zahl** — wer
sonst kommt, ist für die eigene Anmeldung keine nötige Angabe, und die heutige offene Namensliste
ist ein Zug der Umfrageplattform, keine Anforderung. Änderungen tragen die
[Änderungsspur](hebel.md#änderungsspur).

Die Eltern sehen jederzeit ihren Stand und was er voraussichtlich zurückbrächte; eine Mail je
Eintrag gibt es nicht.

Drei [Werte im System](hebel.md#geld-und-fristen-im-system-alles-andere-fest) gehören der Geschäftsführung: der
Monatsbetrag (derzeit 10 €) und die beiden Pflichtstundenzahlen (derzeit 15 und 10); sie ändert sie
mit Gültigkeit zum 1. August, damit keine mitten im Schuljahr greift. Was berechnet wurde, wird
nicht erhoben, sondern gezählt: **jeder Monat, in dem die Familie mindestens einen Tag ein
eingeschriebenes Kind hatte, den August ausgenommen.**

## Entscheidungen

**Keine, die je Stunde fällt.** Eine Bestätigung gibt es nicht: „Wir haben bisher den Eltern
vertraut und werden es weiterhin tun" — was eingetragen ist, zählt, niemand nimmt es ab, niemand
kann es ablehnen. Der Preis steht unten unter „Was heute schiefgeht".

Zu entscheiden bleibt allein, **welche Einsätze ausgeschrieben werden und für wen** — das tut, wer
sie anlegt, und ob eine Tätigkeit zählt, sagt er damit mit. Für alles, was ohne Ausschreibung
geleistet wird, entscheidet es niemand: Der Fahrdienst wird eingetragen wie jede andere Stunde.

Ob eine Tätigkeit überhaupt zählt, entscheidet also niemand nachträglich. Alles Übrige folgt aus
Schulart, Monaten und eingetragenen Stunden.

## Fristen und Termine

- Eingetragen wird bis zum **31. Juli**, für alle gleich und nirgends einstellbar; was später kommt
  oder liegen bleibt, zählt nicht — dieselbe Regel wie heute beim zu spät abgegebenen Stundenzettel,
  nur vorher sichtbar.
- Ein Einsatz nimmt Anmeldungen an, **bis er beginnt**; danach ist er vorbei und trägt nur noch
  seine Stunden.
- Für eine Familie, deren letztes Kind vorher abgeht, ist ihr Austrittsdatum die Frist: der Stand
  friert ein, der Betrag steht sofort fest und die Buchhaltung sieht ihn an ihrem Optigem-Punkt der
  Abgangsliste ([03](03-irregulaerer-abgang.md)).
- Mehrgeleistete Stunden verfallen ebenso und werden nicht ins nächste Schuljahr übernommen; das ist
  der Deckel aus Schritt 4.
- Die eine Aufgabe — das Verrechnen — hat wie jede
  [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) keine Frist und verfällt nicht.

## Mails und Schreiben

Drei an die Eltern, und nur die erste geht an alle:

- am **1. Juni** an jede Familie, deren Stunden noch nicht voll sind. Genau eine, es wird nicht
  nachgefasst, und wer voll ist, bekommt keine.
- **am Vortag** eines Einsatzes an seine Angemeldeten — die Erinnerung, die heute fehlt.
- **bei einer Absage** an seine Angemeldeten, sofort, mit dem Grund, wenn einer angegeben ist.

Keine Mail geht dagegen an die Schule, wenn sich jemand **abmeldet**: Wer ausgeschrieben hat, sieht
seine Anmeldeliste, und eine Mail je Abmeldung wäre dieselbe Sorte Lärm wie eine je Eintrag.

Die fertige Rechnung erzeugt keine eigene Mail — sie steht im Stand, den Betrag sehen die Eltern
zusätzlich auf der Schulgeldabrechnung. Eine neue Ausschreibung erzeugt **keine** Mail an alle
Eltern: Wer Hände anbietet, schaut ins Portal, und eine Rundmail je Einsatz wäre genau der Lärm, den
die heutige Sammelmail vermeidet. Nach innen keine eigene Mail: die Verrechnung läuft in der
Wochenmail mit. Für [unzustellbare Mails](hebel.md#unzustellbare-mail) gilt der gemeinsame Hebel.

## Dateien

Keine, die jemand unterschreibt; der Stundenzettel auf Papier entfällt. Es entsteht
die **Jahresliste** — je Familie eingetragene Stunden, berechnete Monate, vorgeschlagener
Rückzahlbetrag —, [frisch erzeugt](hebel.md#frisch-erzeugte-liste); wo ein Erlass den Betrag trägt,
steht sein Grund dabei, sonst sähe die Buchhaltung eine volle Rückzahlung ohne eine einzige Stunde
([16](16-elternvertretung.md)), sichtbar für Sekretariat, Schulleitung und Buchhaltung, die daran
ihre Aufgabe abarbeitet.

## Sonderfälle

- **Elternvertreter** haben mit dem Amt die vollen Stunden, ohne einen einzigen Eintrag; das Amt
  entsteht in [16](16-elternvertretung.md) und wird hier nur gelesen. Sie
  gelten damit für jeden Zweck als voll — also auch für die Mail am 1. Juni, die sie deshalb nicht
  bekommen.
- **Mitarbeiterfamilien sind ausgenommen** — kein Aufschlag, keine Stunden, keine Mails —, und zwar
  wie beim Putzdienst großzügig in beide Richtungen: Wer irgendwann im Schuljahr eine
  Mitarbeiterrolle **der Schule** trägt, ist für dieses ganze Schuljahr draußen — maßgeblich ist das
  Haus an seinem Eintrag ([13](13-m365-konten.md)) und nicht die Rolle allein: Die KITA ist hier ein
  eigener Betrieb, ihre Familien zahlen und leisten wie jede andere. Dieselbe
  Großzügigkeit wie beim Putzdienst, aber ohne dessen Stichtag: Dort hängt die Ausnahme am Tag der
  Zuteilung und das Sekretariat streicht von Hand nach ([01](01-putzdienst.md)), hier fällt beides
  weg, weil ohnehin erst am Jahresende gerechnet wird.
- Der [offizielle Umweg](hebel.md#der-offizielle-umweg): Das Sekretariat trägt Stunden
  stellvertretend ein — für die Familie ohne Portal wie für den Zettel, der zu spät auftaucht — und
  darf jedes Datum setzen, auch eines nach dem 31. Juli, solange die Jahresliste noch nicht
  übergeben ist.
- Eine abweichende Pflichtstundenzahl je Familie gibt es nicht; ein Härtefall wird über das
  Schulgeld erlassen und damit außerhalb.

`[?]` Ist der Text der Anlage anzupassen — Eintragung im Portal statt Zettel und Frist 31. Juli? —
Geschäftsführung.

## Was heute schiefgeht

Zwei Prozesse, beide von Hand. Die **Stunden**: Zettel gehen verloren oder kommen zu spät, niemand
weiß unterjährig, wo er steht, und am Jahresende rechnet das Sekretariat jede Familie von Hand
zusammen und fragt Ereignissen nach, die Monate zurückliegen.

Die **Einsätze**: Wer Hände braucht, meldet sich beim Hausmeister, der eine Mail an alle Eltern
schreibt und je Termin eine Liste auf einer fremden Umfrageplattform anlegt. Die Eltern tragen sich
dort ein und schicken ihm zusätzlich eine Mail, damit er ihre Adresse hat — für den Fall einer
Absage. **Eine Erinnerung gibt es nicht, und Termine wurden dadurch schon vergessen.** Wer sich
einträgt, steht mit Namen für alle anderen Eltern sichtbar in einer Liste außerhalb des Hauses.

Künftig steht beides an einem Ort: die Ausschreibung im Portal, die Adressen ohnehin da, die
Erinnerung am Vortag, die Absage mit einem Druck. Der Preis ist ehrlich zu nennen: **Ohne
Bestätigung trägt die Jahresliste ungeprüfte Zahlen**, und ob eine Stunde stattgefunden hat, sagt
niemand mehr. Das ist die bewusste Entscheidung — nicht das Modell hält sie zusammen, sondern das
Vertrauen.

## Fremdsysteme

**Optigem** (Buchhaltung): Der monatliche Aufschlag läuft dort im Schulgeld — wir erheben ihn nicht
und prüfen nicht, ob er bezahlt wurde —, und die Rückzahlung des Schuljahres ist **eine** Aufgabe
mit der Jahresliste, nicht eine je Familie. Sonst keine: ASV-BW und M365 geht der Bonus nichts an.

## Löschen

Wie beim Putzdienst ([01](01-putzdienst.md)): einmal jährlich zum Schuljahresanfang fällt nicht das
gerade vergangene Schuljahr, sondern das davor, Einträge und Jahresliste zusammen. Was in Optigem
gebucht ist, hängt an dessen eigenen Fristen.

## Gehört nicht dazu

- Die **Vermittlung dessen, was die Eltern unter sich regeln** — der Fahrdienst der Grundschule vor
  allem: wer wann welches Kind mitnimmt, Fahrgemeinschaften, Absprachen. Das klären die Eltern
  untereinander, und es abzubilden wäre ein eigener Vermittlungsprozess mit Zuordnungen, die
  niemand pflegt. Eingetragen wird die Stunde trotzdem.
- **Zuteilung und Warteschlange** am Einsatz: Der Putzdienst hat beides ([01](01-putzdienst.md)),
  weil dort jede Familie einen Termin haben *muss*. Hier meldet sich, wer kann; eine Platzzahl
  begrenzt höchstens, sie verteilt nicht, und ein Nachrücker wäre ein Vorgang für einen Fall, den
  niemand beschrieben hat.
- Ein **Bedarfsantrag** an eine Stelle, die dann ausschreibt: Wer Hände braucht, schreibt selbst
  aus. Ein Formular davor wäre genau der Umweg, den dieser Block abschafft.
- Eine **Rundmail je Ausschreibung**: Wer Hände anbietet, schaut ins Portal. Eine Mail je Einsatz
  wäre der Lärm, den die heutige Sammelmail vermeidet — die Erinnerung am Vortag geht dafür an die,
  die sich angemeldet haben.
- Der **Putzdienst** zählt nicht mit, er zählt Termine ([01](01-putzdienst.md)).
- Schulgeldabrechnung, Raten und Mahnungen: Optigem.
- Wer Elternvertreter ist: [16](16-elternvertretung.md).
- Ein Bewertungsschlüssel je Tätigkeit: gibt es nicht.
- AGs.

> **Vorgemerkt aus [14](14-elternbonus.md)**, für den Block, der daran anschließt: **Block 16** muss sagen, wer wann Elternvertreter war — dieser Block liest es und erlässt daran die vollen Stunden, ohne einen einzigen Eintrag; ohne Zeitraum ließe sich nicht sagen, für welches Schuljahr. Er muss außerdem sagen, ob das Amt an der Person hängt oder an einer Klasse: Der Bonus hängt an der Familie, und ein Klassenamt muss trotzdem eine benennen.
