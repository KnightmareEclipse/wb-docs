# 0. Zugang und Portal

## Auslöser

Jeder andere Prozess fängt damit an, dass jemand das Portal aufruft. Der Zugang selbst entsteht
durch keine eigene Handlung:

- Eltern haben ihn, sobald ein Kind der Familie eine
  [laufende Verbindung](hebel.md#laufende-verbindung) hat.
- Mitarbeitende, sobald sie ein Schulkonto und eine Rolle haben.

Kein Registrieren, kein Antrag. Eine Regel für alle Fälle: Bewerber, Wartelisten-Eltern, Eltern von
Hortkindern ohne Einschreibung und Eltern eines Kindes, das nur im Ferienprogramm gebucht ist
([10](10-ferienprogramm.md)), unterscheiden sich darin, *was* sie sehen, nicht darin, *ob* sie
hereinkommen. Wessen Verbindungen alle beendet sind, kommt nicht mehr herein — wann das eintritt,
entscheidet der jeweilige Prozess und nicht dieser.

## Beteiligte

Eltern und Mitarbeitende melden sich an. Wer welche [Rolle](hebel.md#rollen) trägt, ist dort
geregelt; hier steht, was daraus für den Zugang folgt. Vergeben werden sie **in Weltenbaum**: M365
beantwortet allein „wer ist das", Weltenbaum „was darf er". Die Gruppen im Tenant werden nicht
gelesen — ihre Unordnung ist damit kein Vorprojekt, und Weltenbaum schreibt nie in die
M365-Verwaltung hinein.

Die Rollenliste steht vollständig, auch wo eine Rolle vorerst nichts tun kann:

- Führungskraft, KITA und KITA-Leitung hängen an der Rechnungsfreigabe
  ([12](12-rechnungsfreigabe.md)).
- Die **Mensa** an der Essensanmeldung ([11](11-mensa.md)).
- Die **Personalverwaltung** an der Kontenverwaltung ([13](13-m365-konten.md)).
- Die schlichte Rolle **Mitarbeitende** trägt, wer nichts Spezielleres hat — ohne sie käme nicht
  herein, wer nur einen Beleg einzureichen hat ([12](12-rechnungsfreigabe.md)).
- Der **Hausmeister** hat heute genau einen Anlass im System, künftig mehr: die
  **Elternmitarbeit** ([14](14-elternbonus.md)). Ausschreiben darf er sie aber nicht als Einziger:
  Das dürfen sechs Rollen, weil die Klassenlehrkraft die Begleitung ihres Ausflugs selbst
  ausschreibt und die Hortleitung ihre Aktionen. Die Stunden bestätigt niemand.
  Die Putzdienstleitung ist er dabei ausdrücklich nicht, das ist eine eigene Person ohne Rolle
  ([01](01-putzdienst.md)).

Sie werden trotzdem beim ersten Import gleich mit vergeben, damit niemand sie hinterher nachpflegen
muss. Die allererste Admin-Rolle setzt niemand über das Portal — sie wird bei der Einrichtung
gesetzt, sonst käme nie jemand herein. Dieser Block beantwortet nur, wer hereinkommt und mit welcher
Rolle.

## Ablauf

| # | wer | tut was | danach steht fest |
|---|---|---|---|
| 1 | Eltern, Mitarbeitende | Melden sich am Portal an: Eltern geben ihre Mailadresse ein und bekommen den [Anmeldecode](hebel.md#zugang-und-anmeldecode) dorthin; Mitarbeitende nehmen ihr vorhandenes Schulkonto. Das Feld antwortet auf jede Adresse gleich — der Code sei unterwegs, dazu die Absenderadresse und der Hinweis, im Spam-Ordner nachzusehen; ob eine Adresse hinterlegt ist, verrät es nicht. Gehört eine Adresse mehreren Sorgeberechtigten, wählt man nach der Eingabe des Codes, als wer man weitermacht | wer da ist, und über welchen Weg er hereingekommen ist |
| 2 | System | Der Anmeldeweg legt fest, welcher Satz Rollen gilt: über die Mailadresse die Elternrolle aus der Sorgeberechtigung, über das Schulkonto die in Weltenbaum hinterlegten Mitarbeiterrollen — nie beides gleichzeitig, der Weg entscheidet, welcher Hut aufliegt. Die Rollen selbst liest das System bei jedem Aufruf frisch, nicht einmalig beim Anmelden | was diese Person gerade sehen und ändern darf |
| 3 | System | Wer keine Rolle trägt, kommt nicht hinein und bekommt den Hinweis, an wen er sich wendet. Meldet sich jemand mit einem gültigen Schulkonto ohne Rolle an — der neue Mitarbeitende, dessen Rolle noch fehlt, oder der, den niemand eingetragen hat ([13](13-m365-konten.md)) —, geht darüber eine Mail an die Admins. **Wessen letzter Arbeitstag dagegen abgelaufen ist, ist kein Neuzugang**: Er bekommt denselben Hinweis, die Admins aber keine Mail — sein Konto ist zu schließen und nicht er hereinzulassen | dass ein fehlender Zugang gemeldet ist, statt still zu scheitern |
| 4 | Admins, Geschäftsführung | Vergeben und entziehen Mitarbeiterrollen im Portal. Es gilt sofort, auch mitten in einer laufenden Sitzung | wer welche Rolle trägt, seit wann und durch wen |

## Was dabei erhoben wird

Zum Anmelden dient die Mailadresse, die die Eltern in [02](02-datenaenderung.md) ohnehin pflegen,
bzw. das Schulkonto aus M365; beides wird hier nicht zusätzlich erhoben. Eigen ist nur zweierlei:

- Je Mitarbeitendem seine Rollen, samt wer sie wann vergeben oder entzogen hat
  ([Änderungsspur](hebel.md#änderungsspur)), sichtbar für Admins und Geschäftsführung.
- Je Person die letzte Anmeldung: daran sieht das Sekretariat, welche Familie das Portal überhaupt
  nutzt und wen es weiter per Telefon betreuen muss.

## Entscheidungen

Eine: wer welche Mitarbeiterrolle bekommt. Sie treffen Admins und Geschäftsführung gemeinsam — zwei
Stellen, damit Urlaub oder Krankheit keine Rollenänderung blockiert. Alles Übrige ist Ableitung.

## Fristen und Termine

Die des [Anmeldecodes](hebel.md#zugang-und-anmeldecode). Rollen wirken ohne Frist sofort. Sonst
keine.

> [!note]- Warum der Code begrenzt ist
> Die Gründe dafür: Sechs Ziffern ließen sich in einer Viertelstunde sonst durchprobieren, und ohne
> Begrenzung je Stunde ließe sich ein fremdes Postfach volllaufen lassen.

## Mails und Schreiben

Zwei Anlässe:

- Der Code — beim Anmelden wie beim Bestätigen einer neuen Adresse, ein Mechanismus für beides und
  kein zweiter daneben.
- Die Meldung an die Admins, wenn ein Schulkonto ohne Rolle anklopft.

Keine Willkommensmail, keine Bestätigung, keine Nachricht über eine neue Rolle — wer eine bekommt,
merkt es daran, dass er hereinkommt.

**Was das Portal überhaupt verschickt, zerfällt in drei Sorten**, und die Sorte entscheidet, ob ein
Abmeldelink darunter steht. Sie gilt für jede Person, die eine Mail bekommt — auch für die mit
laufendem Vertrag, nicht erst für Ehemalige:

| Sorte | abwählbar | Beispiele |
|---|---|---|
| **Vorgangsmail** | nein | Fristende, Zusage, Rechnung, Einladung zum Elternabend |
| **Schulinformation** | ja, aber **einer je Familie muss sie bekommen** | Rundschreiben, Termine, Schuljahresbeginn |
| **Newsletter** | ja, ohne Untergrenze | Ehemalige, Förderkreis, Interessenten — und später einzeln für Ferienprogramm oder Akademie |

Die Vorgangsmail trägt keinen Abmeldelink, weil sie nicht auf einer Einwilligung steht, sondern auf
dem Vertrag: Wer sich vom Elternabend abmelden könnte, bekäme die nächste Vertragsfrist auch nicht
mehr. Bei der **Schulinformation** greift die Untergrenze — sie hat zwei Folgen, die niemanden
überraschen sollen: Ein alleiniger Sorgeberechtigter kann nicht abwählen, und scheidet der zweite
aus, wird der Verbliebene wieder eingeschaltet, ohne dass ihn jemand fragt. Ein **neues Thema ist
eine Zeile** und kein Bau; die feinere Aufteilung kommt, wenn jemand sie braucht, und nicht auf
Verdacht.

Abgewählt wird im Portal oder über den Link in der Mail selbst. **Der Widerspruch löscht nichts**,
er setzt einen Zeitpunkt: Sonst wäre später nicht belegbar, dass ab diesem Tag nichts mehr
geschrieben wurde, und die Adresse käme beim nächsten Import zurück.

### Die Ehemaligen

**Drei Kreise, drei Themen, ein Bauteil** — jedes ist ein Newsletter-Thema wie jedes andere und
kostet eine Zeile: das **ehemalige Kind**, das **Elternteil**, dessen letztes Kind gegangen ist, und
der **ehemalige Mitarbeitende**. Sie bekommen Verschiedenes zu lesen und werden deshalb getrennt
geführt, nicht in einem Verteiler mit einer Filterregel.

Wer zustimmt, bekommt neben seiner Einwilligung eine **Zugehörigkeit**: welcher der drei Kreise,
und bei Kind und Mitarbeitendem das **Jahr des Weggangs** — beim Kind dazu der Schulzweig, denn ein
Jahrgangstreffen ist „Realschule 2026" und nicht „2026". **Eltern tragen keinen Jahrgang:** Ihr
letztes Kind ging in einem bestimmten Jahr, ein früheres vielleicht vier Jahre davor, und eine Zahl,
die nichts benennt, ist schlechter als keine.

**Warum das neben der Person steht und nicht darin** — der Fall, an dem jede andere Form bricht:
Ein Ehemaliger bringt Jahre später sein **eigenes Kind** an die Schule. Dann ist er wieder ein
vollständiges Elternteil mit Familie und Vertrag, seine eigene Kindzeile von damals ist längst
gelöscht, und in einer „reduzierten" Personenzeile wäre sein Jahrgang nicht unterzubringen — an
dieser Person ist nichts zu reduzieren. Dieselbe Person kann außerdem als Kind gegangen und Jahre
später als Mitarbeitende ausgeschieden sein: **zwei Zugehörigkeiten, zwei Jahre, die beide
stimmen.**

**Alles unter Zustimmung, und die Zugehörigkeit entsteht nicht ohne sie.** Ein Bestand über
Ehemalige, die nie zugestimmt haben, wäre eine Adressliste ohne Rechtsgrundlage. Der Widerruf nimmt
die Zugehörigkeit wieder mit; was den Widerspruch belegt, bleibt an der Einwilligung stehen.

**Was der Bestand nicht trägt:** keinen Abschluss, keine Note, keine Klassenlehrkraft, keinen Grund
des Ausscheidens und nichts aus dem Mitarbeitendeneintrag. Der Zweck ist der Verteiler und das
Jahrgangstreffen; wer daraus eine Ehemaligen-Akte machte, bräuchte eine zweite Rechtsgrundlage.

`[A]` Der ehemalige Mitarbeitende wird **beim Ausscheiden** gefragt, wie das Kind im Juni vor dem
Abgang ([04](04-schuljahreswechsel.md)). — Alternative: gar nicht aktiv fragen, sondern nur auf
Zuruf eintragen; Preis: Nach dem letzten Arbeitstag ist die dienstliche Adresse fort und die private
stand nie im System.

## Dateien

Keine.

## Sonderfälle

- Mitarbeitende mit eigenem Kind an der Schule haben **zwei Anmeldewege**, dienstlich über das
  Schulkonto und privat über ihre private Mailadresse. Im System sind sie trotzdem **eine** Person:
  getrennt sind die Wege, nicht die Identität, und der genutzte Weg entscheidet, welche Rollen in
  dieser Sitzung gelten.
- Teilen sich Mutter und Vater eine Mailadresse, teilen sie sich damit auch den Zugang — nach
  Eingabe des Codes wird gewählt, als wer man weitermacht; eine Trennung zwischen zwei Personen, die
  dasselbe Postfach lesen, gibt es nicht, und wer sie will, hinterlegt eine eigene Adresse.
- Wer gar keine Mailadresse hat, hat keinen eigenen Zugang; es gilt der
  [offizielle Umweg](hebel.md#der-offizielle-umweg) — außer beim Bewerben, das ohne eigene
  Mailadresse nicht geht ([05](05-bewerbung.md)).
- Eltern, die die Schule noch nicht kennt, kommen über das offene Bewerbungsformular herein — oder,
  wenn sie nur Betreuung wollen, über das ebenso offene Hortformular ([09](09-hortvertrag.md)), das
  keine Freischaltung und keine Gebühr kennt, oder über eine Ferienbuchung
  ([10](10-ferienprogramm.md)): bevor dort irgendetwas entsteht, bestätigen sie ihre Mailadresse mit
  demselben Code — eine vertippte Adresse ist der häufigste Fehler überhaupt, und danach ist die
  Familie für uns nicht erreichbar. Ist die Voranmeldung geschlossen, kommen sie denselben Weg
  herein, sobald das Sekretariat ihre Adresse für ein Ziel freischaltet — einen zweiten Zugangsweg
  gibt es dafür nicht ([05](05-bewerbung.md)). Geben sie dabei eine bereits hinterlegte Adresse an,
  entsteht kein zweiter Datensatz.
- Alle Mitarbeitenden haben ein Schulkonto, aber nicht alle nutzen es — wer es zum ersten Mal
  braucht, klärt das mit dem Admin; das ist ein M365-Thema und kein Vorgang in Weltenbaum.
- KITA-Konten melden sich am selben Portal an, Schülerkonten kommen nicht herein.

## Was heute schiefgeht

Es gibt keinen gemeinsamen Ort. Jeder Vorgang hat sein eigenes Jotform-Formular, seine eigene
Excel-Datei, seinen eigenen SharePoint-Ordner, und keine Familie kann irgendwo nachsehen, wie ihr
Stand ist. Berechtigungen hängen an SharePoint-Ordnern und am Gedächtnis, und ein Zugang endet nur,
wenn jemand daran denkt. Künftig steht an einer Stelle, wer welche Rolle hat und wer sie ihm gegeben
hat.

## Fremdsysteme

M365 dient allein der Anmeldung der Mitarbeitenden. Weltenbaum liest keine Gruppen und schreibt
nichts in den Tenant — die Kontenverwaltung selbst bleibt, wo sie ist; das Einzige, was hinausgeht,
ist die Benachrichtigung nach Teams, mit der die Rechnungsfreigabe eine Führungskraft anstößt
([12](12-rechnungsfreigabe.md)). Die KITA braucht Zugang ausschließlich dafür.

## Löschen

Kein eigener Vorgang:

- Der Zugang der Eltern endet mit der letzten
  [laufenden Verbindung](hebel.md#laufende-verbindung) der Familie — Absage, Abgang oder gekündigter
  Vertrag.
- Der eines Mitarbeitenden mit dem Ablauf seines **letzten Arbeitstags**
  ([13](13-m365-konten.md)) — die Rollen enden von selbst, und die Anmeldung läuft ins Leere, noch
  bevor der Admin das Konto sperrt.

**Der Anker für einen Mitarbeitenden ist genau dieser Tag** und nicht der Haken des Admins: Sonst
hinge die Löschfrist einer Person daran, dass jemand eine Aufgabe abhakt. Ab ihm rechnet der
Lösch-Lauf (17), und Rollen wie letzte Anmeldung gehen mit der Person. Ein Sorgeberechtigter, der
zugleich Mitarbeitender ist, ist trotzdem **eine** Person und verschwindet erst, wenn beide Anker
erreicht sind. Was seinen Namen anderswo trägt, überlebt ihn: ein von ihm freigegebener Beleg
([12](12-rechnungsfreigabe.md)) folgt seiner eigenen Frist.

Name und dienstliche Mailadresse werden **nicht aktiv aus nachweispflichtigen Zusammenhängen
entfernt** (02.09.2026): Eine abgenommene Mitarbeitsstunde, ein freigegebener Beleg und eine
geführte Klasse behalten ihren Urheber, auch wenn der Eintrag selbst geht. `[?]` Wie lange der
Eintrag steht, ist damit noch nicht beantwortet — Datenschutzbeauftragte

## Gehört nicht dazu

- Was eine Rolle sehen und ändern darf: steht im jeweiligen Prozess, nicht hier.
- Wie eine Bewerbung abläuft und was sie erhebt: [05](05-bewerbung.md) — hier steht nur, dass sie
  ohne Zugang beginnt und einen erzeugt.
- Das Anlegen und Offboarding der M365-Konten selbst ([13](13-m365-konten.md)), samt dem Eintrag,
  mit dem ein Mitarbeitender dort entsteht.
- Konten für Kinder und Schüler.
- Der Signaturlink ab 14 beim Fotoeinverständnis ([08](08-schulvertrag.md)) — ein Link, kein Zugang.
- Passwortregeln und Zwei-Faktor-Pflicht: Sache des Tenants.
