# 1. Putzdienst

## Auslöser

Sekretariat startet gegen Anfang des neuen Schuljahres die Anmeldung für den Putzdienst. Das
Putzdienstjahr läuft von Oktober bis September, der Unterricht beginnt schon im September. Weil der
September noch zum alten Putzdienstjahr gehört, bekommt Termine in diesem Monat nur, wer planmäßig
auch im dann laufenden Schuljahr noch ein Kind an der Schule hat — das gilt beim Reservieren wie bei
der Zuteilung. Der Ablauf gilt für ein Putzdienstjahr und beginnt im nächsten von vorn; die Schritte
ab der Erinnerungsmail wiederholen sich für jeden einzelnen Termin.

> [!note]- Warum der Monat Puffer Absicht ist
> Dieser Monat Puffer ist Absicht: dort greifen noch die Termine des vorigen Putzdienstjahres, und
> Anmeldung und Zuteilung sind damit immer abgeschlossen, bevor der erste Putzdienst des neuen
> Jahres stattfindet.

## Beteiligte

- Eltern reservieren Termine, kaufen frei und tauschen untereinander.
- Das Sekretariat richtet das Jahr ein, gibt die automatische Zuteilung frei und trägt die
  Anwesenheit ein — verteilt wird maschinell.
- Putzdienstleitung sieht am eigentlichen Termin die Liste aller Eltern, die heute kommen.
- Buchhaltung bucht die Strafen aufs Schulgeld.
- Schulleitung und Geschäftsführung erlassen Termine und ziehen Strafen zurück.

Im System arbeiten Eltern, Sekretariat, Schulleitung und Geschäftsführung sowie die Buchhaltung, die
ihre Strafen als gewohnte [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) für Optigem bekommt
wie in jedem anderen Block. Allein die Putzdienstleitung bekommt Papier und braucht dafür keinen
Zugang. Die **Putzdienstleitung ist eine eigene Person**, die sich allein um den Elternputzdienst
kümmert: keine [Rolle](hebel.md#rollen) in Weltenbaum und nicht der Hausmeister. Dass die
Buchhaltung anderswo im System arbeitet, ändert daran nichts.

Der Putzdienst hängt an der Familie, nicht am Kind: zwei Kinder an der Schule bedeuten genauso viele
Termine wie eines. Die Pflichtzahl hängt dabei an eingeschriebenen Kindern — eine Familie, die erst
eine Bewerbung laufen hat, schuldet null und bekommt damit auch keine der Mails dieses Prozesses.
[Familie](hebel.md#familie-und-kind) heißt dabei wie überall die Eltern, nicht der Haushalt: eine
Familie, eine Pflichtmenge.

Wer zu einer Familie gehört, wer an der Schule arbeitet — erkennbar an einer
[Mitarbeiterrolle](hebel.md#rollen) und am Haus *Schule* an seinem Eintrag
([13](13-m365-konten.md)); die KITA ist ein eigener Betrieb und zählt nicht mit — und wessen Kinder
zum Schuljahresende planmäßig alle gehen, wird an anderer Stelle festgelegt; dieser Prozess liest es
nur aus und trägt nichts davon selbst ein. Planmäßig gehen heißt dabei schlicht: am Ende ihrer
Schulart stehen, Klasse 4 oder Klasse 10 ([04](04-schuljahreswechsel.md)). Gefragt wird nach der
Stufe im Moment des Reservierens und Zuteilens, nicht nach einem Austrittsdatum, das es dann noch
nicht gibt.

> [!note]- Wer dabei durchs Raster fällt
> Ein Wiederholer fällt damit durchs Raster, und ebenso der Viertklässler, der später in die eigene
> Realschule wechselt: Ob sie im September noch da sind, entscheidet sich erst lange nachdem die
> Septembertermine verteilt waren — sie bekommen keinen, obwohl sie bleiben. Wissen könnten wir es
> zu diesem Zeitpunkt nicht, und eine Sonderregel dafür wäre teurer als der fehlende Termin.

Reservieren, freikaufen und tauschen darf jede sorgeberechtigte Person allein — eine reicht, die
andere muss nicht zustimmen. Die Geschäftsführung pflegt die Preise für Freikauf und Strafe.

## Ablauf

| # | wer | tut was | danach steht fest |
|---|---|---|---|
| 1 | Sekretariat | Richtet das Putzdienstjahr ein: legt die **Putzdiensttermine** einzeln an — „Termin" heißt in diesem Block immer einer von ihnen und nie ein Ferientermin ([10](10-ferienprogramm.md)) —, je Termin ein frei gewählter Startzeitpunkt (Datum und Uhrzeit), kein fester Wochentag, kein Raster, dazu die Art (regulärer Putzdienst oder Großputz), ein Hinweistext für besondere Termine („an diesem Termin wird ausschließlich im Garten gearbeitet") und die Platzzahl — die steht als Standard je Art einmal für das ganze Jahr und wird nur an dem Termin überschrieben, an dem wirklich weniger gebraucht werden, etwa bei reiner Gartenarbeit. Dazu das Anmeldefenster. Bevor es aufgeht, sieht das Sekretariat die Familien, die im vergangenen Jahr eine abweichende Pflichtzahl hatten, und entscheidet je Familie, ob sie im neuen Jahr weiter gilt — Härtefälle laufen oft über mehrere Jahre, die anteilige Zahl eines Quereinsteigers gilt nur für sein Eintrittsjahr | welche Termine es gibt, wann die Eltern jeweils da sein sollen, was sie dort erwartet, wie viele Plätze offen sind, wann Eltern selbst wählen dürfen und wer wie viele Termine schuldet |
| 2 | System | Mail an die Eltern, dass das Anmeldefenster offen ist — mit der Anzahl der Pflichttermine, die genau diese Familie schuldet, den Preisen und dem Datum, bis wann selbst gewählt werden kann. Wer null Termine schuldet, bekommt sie nicht | jede Familie weiß, dass sie jetzt selbst wählen kann und was sie sonst erwartet |
| 3 | Eltern | Erledigen ihre Pflichttermine, derzeit 5 reguläre + 1 Großputz: je Pflichttermin entweder einen Termin reservieren oder sich freikaufen — auch gleich alle auf einmal, ohne einen einzigen zu buchen. Bei der Auswahl sehen sie zu jedem Termin Startzeitpunkt, Art und Hinweistext — vor der Zusage, nicht erst vor Ort. Solange das Anmeldefenster offen ist, können sie eine Reservierung noch ändern — Termin freigeben, anderen nehmen | welche Familie an welchem Termin eingeteilt ist, wer sich freigekauft hat, und dass sie wusste, worauf sie sich einlässt |
| 4 | System | Schließt das Anmeldefenster zum festgelegten Zeitpunkt und verteilt die noch offenen Pflichttermine automatisch, je Art getrennt: jede Familie bekommt ihre volle Anzahl regulärer Termine und ihren Großputz, keine Familie zweimal am selben Termin und die Termine einer Familie möglichst über das Jahr verteilt. Ein Mindestabstand wird nicht zugesichert — auch wer selbst reserviert, kann seine Termine hintereinander legen. Die Platzzahl je Termin hält der Algorithmus möglichst ein, darf sie aber überschreiten, wenn eine Familie sonst nicht vollzählig würde; vollzählig geht vor Platzzahl. Reservierungen rührt er nicht an | reservieren kann ab jetzt niemand mehr, und jede Familie hat exakt so viele Termine je Art, wie sie in diesem Putzdienstjahr leisten muss |
| 5 | Sekretariat | Sieht die fertige Zuteilung als Gesamtbild durch — samt der Termine, an denen die Platzzahl überschritten wurde — und entscheidet, ob das Bild so trägt. Wenn ja: freigeben. Wenn nein: einzelne automatisch zugeteilte Familien von Hand verschieben und dann freigeben; selbst reservierte Termine bleiben dabei stehen. Ohne Freigabe erfährt keine Familie ihre Termine | die Zuteilung gilt |
| 6 | System | Mail mit den endgültigen Terminen an jede Familie, die Termine hat — auch an die, die selbst reserviert haben | jede Familie kennt ihre Termine für das ganze Putzdienstjahr |
| 7 | Eltern | Kaufen sich von jedem ihrer Termine frei — zugeteilt oder selbst reserviert —, bis zu dessen Freikauf-Frist. Der Termin fällt bei dieser Familie weg und ihre Pflichtzahl sinkt um eins; ein Ersatztermin wird nicht zugeteilt, und der frei gewordene Platz bleibt offen und wird nicht nachbesetzt | Eltern erscheinen an dem Tag nicht zum Putzdienst und zahlen dafür auch keine Strafe |
| 8 | Eltern | Tauschen Termine direkt untereinander, ohne das Sekretariat: Eine Familie stellt einen ihrer Termine zum Tausch und hakt in der Liste der angebotenen Termine derselben Art alle an, die sie dafür nehmen würde. Akzeptieren sich zwei Angebote gegenseitig, tauscht das System sofort — weil beide Seiten vorher angekreuzt haben, was sie wollen, ist keine Rückfrage nötig. Sichtbar sind dabei nur Startzeitpunkt und Art des angebotenen Termins, keine Namen und keine Kontaktdaten. Getauscht wird eins zu eins, nur gegen einen bestehenden Termin derselben Art, und eine Familie kann keinen Termin annehmen, an dem sie schon steht; weil eins zu eins getauscht wird, bleibt die Zahl der Familien je Termin gleich. Eine Familie darf mehrere ihrer Termine gleichzeitig anbieten, je Termin aber nur ein Angebot. Ein Angebot läuft bis zur Freikauf-Frist seines eigenen Termins und verfällt dann von selbst | beide Familien haben einen Termin, den sie sich selbst ausgesucht haben. Erscheint an einem getauschten Termin niemand, zahlt die neue Familie die Strafe; die ursprüngliche ist raus |
| 9 | System, Sekretariat | Erinnert die Eltern des nächsten Termins zweimal, jeweils mit Startzeitpunkt, Art und Hinweistext: einmal sobald der vorige Putzdienst gelaufen ist — bis zum nächsten sind es meist rund sechs Wochen, außer es liegen Ferien dazwischen — und einmal ein bis zwei Tage vorher. Beim ersten Termin des Jahres übernimmt die Zuteilungsmail die erste Erinnerung. Zur zweiten Erinnerung wird beim Sekretariat die [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) offen, die Liste zu drucken, dazu eine eigene Mail, weil sie noch in derselben Woche fällig ist: es erzeugt die PDF-Liste mit allen Eltern dieses Termins per Knopfdruck — sie entsteht immer frisch und ist damit auf dem letzten Stand —, druckt sie aus und legt sie ins Fach der Putzdienstleitung | Eltern wissen erneut, wann sie kommen müssen und was sie erwartet (z. B. reine Gartenarbeit); die Putzdienstleitung weiß, wer kommt und wie viele, und kann grob planen |
| 10 | Eltern, Putzdienstleitung | Eltern kommen zur Schule am Putzdiensttermin, unterschreiben die Anwesenheitsliste der Putzdienstleitung, bekommen mitgeteilt was sie jetzt putzen müssen und putzen | wer da war, steht unterschrieben auf Papier |
| 11 | Sekretariat | Trägt ein paar Tage nach dem Termin anhand der unterschriebenen Liste ein, wer da war, und legt die eingescannte Liste dazu. Bis das passiert ist, steht der Termin für Sekretariat und Eltern sichtbar auf „noch nicht ausgewertet", mit dem Hinweis, dass daraus noch eine Strafe werden kann — nicht auf „alle waren da" | wer abwesend war und eine Strafe zahlen muss, und dass dieser Termin überhaupt geprüft wurde |
| 12 | System, Buchhaltung | System legt am 1. jedes Monats alle bis dahin ausgewerteten Strafen als **eine** [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) bei der Buchhaltung an — je Monatslauf eine, mit der Liste daran, und sie läuft in der Wochenmail mit; eine eigene Mail gibt es dafür nicht. Was am 1. noch nicht ausgewertet ist, geht am 1. des Folgemonats mit. Die Buchhaltung rechnet die Strafzahlung der Familie auf das Schulgeld auf; auf welches Kind sie dort gebucht wird, entscheidet sie selbst — bei uns hängt die Strafe an der Familie | die Strafe ist übergeben und für das Sekretariat nicht mehr korrigierbar — nur Schulleitung und Geschäftsführung können sie noch zurückziehen —, und dieser Termin ist komplett abgeschlossen |

## Was dabei erhoben wird

Je Termin:

- Der Startzeitpunkt (Pflicht) — wann die Eltern da sein sollen, mehr nicht; wie lange ein
  Putzdienst ungefähr dauert, steht im Schulvertrag und wird hier nicht festgehalten.
- Die Art (regulärer Putzdienst oder Großputz, Pflicht).
- Die Platzzahl (Pflicht, aber als Standard je Art einmal gesetzt und nur am einzelnen Termin
  überschrieben, wo weniger gebraucht werden; änderbar durch das Sekretariat bis zur Zuteilung,
  danach bewirkt eine Änderung nichts mehr. Sie ist eine Obergrenze, kein Soll, das gefüllt werden
  müsste — durch Freikäufe bleiben Plätze offen, und das ist in Ordnung; ein frei werdender Platz
  wird nie nachbesetzt — die einzige Zahl, die zählt, ist die der Termine, die eine Familie noch
  leisten muss).
- Ein Hinweistext für besondere Termine (freiwillig).

Der Hinweistext trägt, was an diesem Termin anders ist — heute reine Gartenarbeit, künftig ggf.
andere Sonderarbeiten, die kein Putzen sind; eine eigene Terminart wird daraus nicht, ein
Gartentermin ist ein regulärer Putzdienst oder ein Großputz und zählt auch so. Alles für alle Eltern
sichtbar, ändern darf nur das Sekretariat — auch nachdem Eltern reserviert haben.

Von den Eltern:

- Welche Termine sie reservieren — im offenen Anmeldefenster noch änderbar.
- Ob sie sich freikaufen.
- Welche ihrer Termine sie zum Tausch stellen und welche angebotenen sie dafür annehmen würden.
- Wer am Termin da war.

Strafen werden je Familie geführt, nicht je Kind. Wie viele Putzdienste eine Familie im Jahr
schuldet: derzeit 5 reguläre + 1 Großputz, so im Schulvertrag. Zwei Zahlen, die nicht verwechselt
werden dürfen:

- Die **gemeinsame** — künftig sind es vielleicht nicht mehr 5+1 — ändert die Geschäftsführung nur
  zum Beginn eines Putzdienstjahres: Sie trägt diesen Tag als
  [Gültigkeit](hebel.md#geld-im-system-alles-andere-fest) ein, damit sie nie mitten im laufenden
  Jahr greift.
- Die **abweichende Zahl je Familie** dagegen gilt sofort, auch mitten im Jahr — ein
  Schicksalsschlag im Februar muss die Pflicht dieses Jahres senken können und nicht die des
  nächsten. Sie gilt für ein Putzdienstjahr und wird nicht stillschweigend ins nächste übernommen;
  was bestehen bleiben soll, entscheidet das Sekretariat beim Einrichten des neuen Jahres.

Eltern sehen ihre eigenen Termine und ihren Stand: was geleistet ist, was noch offen ist, was sie
freigekauft haben — und bei einem gerade gelaufenen Termin, dass er noch nicht ausgewertet wurde,
damit eine spätere Strafe niemanden überrascht. Eine verhängte Strafe und ihr Rückzug stehen
ebenfalls in dieser Übersicht. Jede Änderung an den Terminen einer Familie — Tausch, Streichung,
Verschiebung, Absage — ist dort sichtbar, sobald sie eingetragen ist, und taucht in der nächsten
Erinnerungsmail entsprechend auf. Wer sonst an einem Termin eingeteilt ist, wird ihnen nicht
angezeigt.

Gepflegt werden zwei Preise, [beide im System](hebel.md#geld-im-system-alles-andere-fest): Freikauf
eines einzelnen Termins und Strafe bei Abwesenheit. Einen eigenen Jahrespreis gibt es nicht — der
Freikauf des ganzen Jahres ist die Summe der offenen Pflichttermine, bei 5+1 also derzeit 210 €, und
passt sich mit, wenn sich Preis oder Pflichtzahl ändern.

## Entscheidungen

Die Zuteilung selbst nicht: wer reserviert hat fixe Termine, und Anwesenheit ist schwarz/weiß — wer
nicht da war, zahlt. Menschliche Entscheidungen:

- Sekretariat setzt die Platzzahl — als Standard je Art, am einzelnen Termin nur wo nötig — und
  beurteilt die fertige Zuteilung als Gesamtbild — trägt sie so, auch mit überschrittenen
  Platzzahlen? — statt Familie für Familie.
- Ein Tausch braucht keine Entscheidung mehr: er kommt zustande, sobald sich zwei Angebote
  gegenseitig akzeptieren.
- Das Sekretariat darf eine eingetragene Anwesenheit korrigieren, solange die Strafe noch nicht im
  Monatslauf an die Buchhaltung gegangen ist; danach geht es nur noch über den Rückzug durch
  Schulleitung oder Geschäftsführung.
- Schulleitung und Geschäftsführung erlassen Termine bei Härtefällen und können eine verhängte
  Strafe wieder zurückziehen; den Rückzug tragen sie selbst ein. Ein Widerspruch der Eltern läuft
  außerhalb dieses Prozesses.
- Das Sekretariat darf jeden Termin einer Familie streichen oder verschieben, auch einen selbst
  reservierten — nur die automatische Zuteilung selbst rührt Reservierungen nicht an.

Alles Übrige — Termine, Anmeldefenster, Platzzahlen, Zuteilung, Anwesenheit — liegt beim
Sekretariat; die übrigen Fristen sind fest und werden von niemandem gesetzt.

## Fristen und Termine

- Anmeldefenster für Putzdienstreservierung, wer verpasst bekommt automatisch Termine zugeordnet.
- Freikauf geht das ganze Jahr über und gilt immer für einen Pflichttermin: hängt daran schon ein
  konkreter Termin — zugeteilt oder selbst reserviert —, fällt der weg, ohne dass ein Ersatztermin
  nachrückt, und die Frist ist fest: drei Tage vor genau diesem Putzdienst, für alle Termine gleich
  und nirgends einstellbar. Drei Tage, weil die zweite Erinnerung ein bis zwei Tage vorher rausgeht
  und dann die Anwesenheitsliste gedruckt wird — eine freigekaufte Familie soll nicht mehr auf dem
  Papier stehen. Hängt noch kein Termin am Freikauf, gibt es keine Frist; im Anmeldefenster kann
  eine Familie sich deshalb auch gleich für alle Pflichttermine freikaufen, ohne einen einzigen zu
  buchen. Wer die drei Tage verpasst, muss zum Putzdienst kommen oder Strafe zahlen. Zurücktreten
  kann man von einem Freikauf nicht.
- Ein Tauschangebot läuft bis zur Freikauf-Frist seines eigenen Termins und verfällt dann ohne
  weiteres Zutun — aufgeräumt werden muss nichts, ein Angebot ist ein Zustand am Termin und kein
  eigener Vorgang. Wer bis dahin keinen Tauschpartner findet, behält seinen Termin; weil die
  Erinnerungsmail danach rausgeht und den Termin nennt, den die Familie tatsächlich hat, kann sich
  niemand auf einen Tausch verlassen, der nie zustande kam. Ein schon gelaufener Termin wird nicht
  mehr getauscht, sondern über die Anwesenheit korrigiert.
- Die Anwesenheit wird erst ein paar Tage nach dem Termin ausgewertet; wer zu spät kommt, fällt
  dabei nicht auf.
- Die Strafen gehen am 1. jedes Monats an die Buchhaltung — ein festes Datum, kein gerechnetes: was
  dann noch nicht ausgewertet ist, geht am 1. des Folgemonats mit, und bis dahin kann das
  Sekretariat korrigieren. Dass eine Strafe dadurch erst eine Periode später ins Schulgeld läuft,
  nehmen wir für die einfache Regel in Kauf; Strafzahlungen sind ohnehin selten.

## Mails und Schreiben

Zwei feste Anlässe rund um die Buchung:

- Eine Mail, sobald das Anmeldefenster offen ist.
- Nach der automatischen Zuteilung eine Mail mit den endgültigen Terminen — auch an die, die selbst
  reserviert haben.

Eine Bestätigungsmail nach Reservierung oder Freikauf gibt es nicht: was gebucht ist, steht sofort
in der Terminübersicht, und die ist die Bestätigung.

Dazu zwei feste Erinnerungen je Putzdienst an die Eltern, die an diesem Termin dran sind, mit
Startzeitpunkt, Art und dem Hinweistext des Termins:

- Die erste, sobald der vorige Putzdienst gelaufen ist — das sind meist rund sechs Wochen Vorlauf,
  außer es liegen Ferien dazwischen.
- Die zweite ein bis zwei Tage vorher.

Beim ersten Termin des Jahres steht die Zuteilungsmail an der Stelle der ersten. Nichts davon wird
konfiguriert, es hängt am vorigen Termin und am Termin selbst.

Mails zum Putzdienst gehen nur an Familien, die überhaupt Termine schulden — wer null hat, bekommt
keine. Alle Mails gehen an alle Sorgeberechtigten der Familie. Eine Mailadresse je Familie ist
Pflicht, damit keine Familie ohne Kanal ist; ein zweiter Sorgeberechtigter ohne eigene Adresse
bekommt entsprechend nichts. Für [unzustellbare Mails](hebel.md#unzustellbare-mail) gilt der
gemeinsame Hebel.

Ändert das Sekretariat einen bereits belegten Termin (Startzeitpunkt, Art, Hinweis) oder sagt ihn
ab, geht das an die eingetragenen Eltern raus. Ebenso, wenn es einer Familie Termine von Hand
zuteilt oder streicht — die Familie bekommt dann ihre aktuelle Terminliste; das ist der Weg, auf dem
Quereinsteiger überhaupt von ihren Terminen erfahren, denn die Zuteilungsmail ist zu diesem
Zeitpunkt längst raus. Verfallen Termine dagegen durch einen Abgang, trägt das die
Abgangsbestätigung und nicht eine eigene Terminliste.

Ein zustande gekommener Tausch geht als Mail an beide Familien, jeweils mit dem Termin, den sie
jetzt haben; verfällt ein Angebot ungenutzt, gibt es dafür keine eigene Mail — der Stand steht in
der Terminübersicht und die Erinnerung nennt den tatsächlichen Termin.

Bei den manuellen Schritten entsteht statt einer eigenen Erinnerung je eine offene
[Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) bei der zuständigen Person, sobald sie dran ist
— Zuteilung freigeben, Anwesenheit eintragen, Anwesenheitsliste ausdrucken —, und sie läuft in der
Wochenmail mit, bis sie abgehakt ist; ein zweiter Erinnerungsweg daneben wird dafür nicht gebaut.
Eine **eigene Mail** bekommt allein die Aufgabe, die Anwesenheitsliste zu drucken: Sie ist ein bis
zwei Tage vor dem Termin fällig, und dafür ist die Wochenmail zu grob — dieselbe Ausnahme wie beim
erklärten Storno im Ferienprogramm ([10](10-ferienprogramm.md)).

Dass eine Strafe zurückgezogen wurde, erfahren Eltern und Buchhaltung außerhalb dieses Prozesses per
Mail; im System sehen die Eltern es in ihrer Terminübersicht.

## Dateien

Es entsteht die Putzdienstliste pro Termin zum unterschreiben; darauf stehen Startzeitpunkt, Art und
Hinweistext, damit die Putzdienstleitung dieselbe Ansage vor sich hat wie die Eltern in der Mail.
Das Sekretariat erzeugt sie per Knopfdruck und druckt sie aus — eine [frisch erzeugte
Liste](hebel.md#frisch-erzeugte-liste). Unterschrieben kommt sie zurück und wird eingescannt beim
Termin abgelegt — sie ist der Beleg dafür, wer da war, und lesen darf sie das Sekretariat.

## Sonderfälle

Fast alles läuft über denselben Hebel: die Pflichtzahl dieser Familie wird abweichend gesetzt, und
das Sekretariat streicht oder verschiebt die betroffenen Termine. So werden behandelt:

- Schwere Schicksalsschläge im Leben der Familie (Reduzierung oder ganzer Erlass, jederzeit im
  laufenden Jahr und sofort wirksam — entscheiden dürfen das Schulleitung und Geschäftsführung,
  eintragen können sie es selbst, bei einer Reduzierung auch das Sekretariat, das die entfallenden
  Termine in Absprache mit der Familie löscht).
- Mitarbeitende der Schule mit eigenem Kind an der Schule (null Termine, und zwar in beide
  Richtungen großzügig: wer zum Zeitpunkt der automatischen Zuteilung an der Schule arbeitet, hat
  null für dieses Jahr, auch wenn er später im Jahr geht — und wer erst danach anfängt, dem streicht
  das Sekretariat die noch offenen).
- Quereinsteiger, die mitten im Jahr kommen (anteilig — wie viele es sind und welche Termine sie
  bekommen, legt allein das Sekretariat von Hand fest; die
  [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) dazu entsteht mit der Einschreibung,
  [08](08-schulvertrag.md), damit sie nicht davon abhängt, dass jemand die neue Familie bemerkt).
- Familien, deren letztes Kind gekündigt wird (die restlichen Termine stehen als Punkt auf der
  Abgangsliste und verfallen ohne Strafe, sobald das Sekretariat sie dort bestätigt).

Beim planmäßigen Abgang bleibt dagegen nichts übrig, das verfallen müsste: wer am Ende seiner
Schulart steht, bekommt von vornherein keine Termine im September. Ein Termin kann nachträglich
dazukommen, verschoben oder abgesagt werden (Wetter bei Gartenarbeit, Schulfest, Bauarbeiten) — das
geht dann zu Lasten der Schule, nicht der Eltern: das Sekretariat kann die betroffenen Familien
einem anderen Termin zuordnen oder ihnen den Termin erlassen. Wer aus der Familie erscheint, prüfen
wir nicht: auf der Liste steht am Ende eine Unterschrift, und wir verlassen uns auf die Ehrlichkeit
der Eltern.

## Was heute schiefgeht

- Übersicht, wer wann genau kommen muss, und das Tauschen von Terminen über das Sekretariat mit
  falscher Zuordnung von Eltern und Terminen — künftig tragen die Eltern jeden Tausch selbst ein
  statt ihn zuzurufen, und danach ist eindeutig, wer an diesem Termin steht und wer im Fall der
  Abwesenheit zahlt.
- Kollision mit Schulfesten — künftig setzt das Sekretariat jeden Termin einzeln und kann ihn um
  Schulfeste herumlegen, statt einem festen Wochenrhythmus zu folgen.
- Eltern erfahren erst vor Ort, dass es an diesem Termin gar nicht ums Putzen geht, sondern um den
  Garten — künftig steht das schon bei der Reservierung im Hinweistext.

## Fremdsysteme

Strafzahlung muss in Optigem gepflegt werden. Wird eine Strafe zurückgezogen, die dort schon gebucht
ist, halten wir den Rückzug nur fest — korrigiert wird er in Optigem. Wir sind keine
Buchhaltungssoftware. Der Freikauf dagegen ist eine [Sofortzahlung](hebel.md#sofortzahlung) und geht
die Buchhaltung nichts an.

## Löschen

Gelöscht wird einmal jährlich zum Schuljahresanfang, und zwar nicht das gerade vergangene
Putzdienstjahr, sondern das davor: im September 2026 fällt 2024/25. Die eingescannten
Anwesenheitslisten gehen mit. Das gilt für die Daten hier; was in Optigem gebucht ist, hängt an
dessen eigenen Fristen und bleibt davon unberührt.

## Gehört nicht dazu

- Wer putzt was exakt am Putzdienst.
- Die digitale Anwesenheitserfassung, bei der Eltern sich vor Ort selbst einscannen und die
  Papierliste entfällt: gewolltes Ziel, aber ausdrücklich zweite Iteration — erst wenn der Rest
  steht.
