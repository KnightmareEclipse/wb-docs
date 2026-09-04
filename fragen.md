# Fragen an die Schule — was wen zu fragen ist

Zweiundzwanzig Fragen, die Weltenbaum nicht selbst beantworten kann, sortiert nach dem Gespräch, in
das sie gehören. **Sie stehen nur hier** — das Arbeitspapier in `pruefberichte/` trägt, was die
Mails gesagt haben und was wir daraus bauen, aber keine Frage mehr. Je Frage steht hier ihr **Wortlaut**, das **Kriterium**, an dem du erkennst, dass die
Antwort reicht, und **woran sie hängt**.

## Abgrenzung zu den Nachbardateien

| Datei | trägt |
|---|---|
| `[?]` im Soll-Block bzw. im Schema | die Frage an der Stelle, an der sie beißt — dort fällt auf, dass sie fehlt |
| `backlog/` | **dass** sie zu klären ist, bis wann und mit welcher Folge |
| **hier** | **wie du sie stellst** und wann eine Antwort brauchbar ist |

Hier wird nichts entschieden und nichts festgelegt. Diese Datei bereitet ein Gespräch vor, mehr
nicht — was aus dem Gespräch zurückkommt, gehört woanders hin.

## Wenn eine Antwort da ist

Vier Stellen, in dieser Reihenfolge: **Soll-Block** (er ist die abgestimmte Fassung) → **Schema**,
wo die `[?]` damit fällt → das Ticket in `backlog/` abhaken → hier streichen.

Eine beantwortete Frage ist damit immer ein Eingriff an vier Stellen. **Antworten sammeln und in
einem Zug einarbeiten** ist deshalb billiger als jede einzeln nachzuziehen. Beim Streichen wandern
die Zahlen mit: die im Vorspann und die in der Überschrift des Gesprächs.

---

## Datenschutzbeauftragte:r — vier Fragen

**Die Löschfristen sind beantwortet** (02./04.09.2026) und stehen an ihren Ankern im Schema; was
hier bleibt, sind drei Reste. Die Frist der **Hortakte** hat am 04.09.2026 die Geschäftsführung
gesetzt — zwei Jahre —, nicht dieses Gespräch; sie sollte sie kennen, bevor sie in eine Prüfung
gerät. **Und die Fristen sind seither keine festen Zahlen mehr:** Sie stehen als Wert im System und
werden von der Geschäftsführung geändert
([hebel.md](soll-prozesse/hebel.md#geld-und-fristen-im-system-alles-andere-fest)) — wer künftig eine
Frist bewertet, bewertet einen Stand und keine Konstante.

**Eine Frage ist aus den Antworten selbst entstanden** und deshalb neu: Zu den Betriebsdaten kam
statt einer Frist eine Rückfrage zurück; die Antwort darauf steht längst im
Verarbeitungsverzeichnis und muss nur gegengezeichnet werden (4).

**Die Fotoerlaubnis steht nicht mehr hier.** Dass sie unbegrenzt bleibt, zieht die Stammdaten nicht
mit: Der Nachweis wandert beim Löschen in einen eigenen Bestand, das Kind geht wie jedes andere
(Geschäftsführung, 04.09.2026; `soll-prozesse/08`, `schema/querschnitt-schema.sql`).

**Vier Dinge gehen mit, ohne Fragen zu sein.** Erstens, dass das **Protokoll der Notfalleinsicht mit
dem Kind geht**: Ein Vorfall 2026 an einem Kind, das 2031 abgeht, beginnt seine Frist 2031.
Zweitens, dass das **Freigabemodell je Angabe und Instanz** gebaut wird — mit der Möglichkeit, alles
in einer Handlung freizugeben; es ist strenger als die Vorgabe vom 02.09.2026 und deshalb eine
Mitteilung, keine Frage. Drittens, dass **Teilnehmer der Erwachsenen-Seminare dieselbe Frist tragen
wie schulfremde Kinder**. Und viertens: Erstens die Antwort auf seine Rückfrage, ob der
Lösch-Lauf ohne Datenleichen gebaut werden kann: ja — die Reihenfolge über alle Domänen steht als
siebenstufige Kaskade im Kopf von `schema/querschnitt-schema.sql`, und ihr Prüfskript weist eine
verwaiste Zeile ab. Zweitens die Kenntnisnahme, dass ein Anhalten der Löschung **unbegrenzt
verlängerbar** ist, solange sein Grund trägt (Art. 17 Abs. 3 lit. e) — an die Stelle einer
Obergrenze tritt Sichtbarkeit: Jeder Fall trägt seinen Grund aus einer Werteliste, und die Liste
zeigt, seit wann er fällig ist und wie oft er geschoben wurde. Der Satz, mit dem dieses Gespräch geführt wurde, hat sich dabei nur
halb bewährt: Dass Weltenbaum ASV-BW und Optigem nicht ersetzt und hier eine Arbeitskopie steht, ist
bestätigt — die Aufbewahrungspflicht trifft sie nicht. **Kürzere Fristen folgen daraus aber nicht**:
Es gibt keinen Zwang, in der Kopie zu löschen, solange das Original bleiben muss, und die Empfehlung
lautet, die Aufbewahrung lieber hier zu erfüllen als in ASV-BW. Wer mit dem alten Satz in die
nächste Frage geht, bekommt deshalb eine Antwort auf ein Argument, das nicht mehr trägt.

### 1. Zweck der vier Voranmeldefelder — Schulleitung

> „Konfession, Beruf und Staatsangehörigkeit der Eltern und die Kirchengemeinde des Kindes stehen
> auf der Voranmeldung. Der Datenschutzbeauftragte sagt: kein Erlaubnistatbestand, also nur
> freiwillig und sichtbar freiwillig. Welchen Zweck hat jedes einzelne Feld — und soll es bleiben?"

**Brauchbar ist die Antwort, wenn** je Feld ein benannter Zweck dasteht oder ein klares Nein. Die
datenschutzrechtliche Hälfte ist erledigt und steht in `schema/stammdaten-schema.sql`; offen ist
allein die fachliche, und sie gehört der Schulleitung.

**Daran hängt:** Vor dem Vollimport ist ein Nein ein `DROP COLUMN`. Danach ist es eine Migration auf
echten und teils besonders geschützten Personendaten. **Deshalb vor dem Vollimport, nicht danach.**

**Die Kirchengemeinde gehört ausdrücklich nicht in diese Frist** — sie wird weiter erhoben, und ob
sie bleibt, wird erst einige Monate nach dem Import entschieden. Sie steht hier nur, damit klar ist,
dass sie bewusst draußen ist.

**An dieser Frage hängt zusätzlich die Werteliste `denominations`** — sie steht als einzige der
Wertelisten leer und bekommt keinen Anfangsbestand, solange der Zweck des Feldes nicht beschlossen
ist. Bleibt das Feld, ist die zweite Frage, welche Konfessionen darin auswählbar sein sollen; das
beantwortet dann das Sekretariat, nicht dieses Gespräch. Fällt das Feld, fällt die Liste mit ihm.

*Steht in* `schema/stammdaten-schema.sql` · `soll-prozesse/05-bewerbung.md:19` · `backlog/`

### 2. Wie lange ein ausgeschiedener Mitarbeitender stehen bleibt

> „Wie lange behalten wir die Daten eines Mitarbeiters, nachdem sein letzter Arbeitstag vorbei ist?
> Bei uns steht keine Personalakte — nur Name, dienstliche Mailadresse, Haus, erster und letzter
> Arbeitstag, die Rolle im System und ggf. eine Nachfolgenotiz. Kein Gehalt, kein Arbeitsvertrag,
> keine Bewerbungsunterlagen."

**Brauchbar ist die Antwort, wenn** sie eine Frist ab dem letzten Arbeitstag nennt. **Ohne den
Umfangssatz wird über die Personalakte entschieden** und damit über einen Bestand, den es hier nicht
gibt.

**Daran hängt:** Der Anker steht (`employees.last_working_day`), sein Ziel nicht. Die zweite Hälfte
dieser Frage ist beantwortet — Name und Mailadresse werden aus nachweispflichtigen Zusammenhängen
nicht aktiv entfernt —, die Frist für den Eintrag selbst fehlt.

*Steht in* `schema/stammdaten-schema.sql` · `schema/m365-schema.sql` ·
`soll-prozesse/00-zugang-und-portal.md:34`

### 3. Versandte Mails an noch unbekannte Familien

> „Wir verschicken Mails an Leute, die wir noch gar nicht als Familie führen — etwa die Bestätigung
> einer Ferienbuchung an Eltern, die vor dieser Buchung nirgends bei uns standen. Von dieser Mail
> bleibt bei uns die Adresse, der Anlass in einem Wort, der Versandzeitpunkt und ob sie zustellbar
> war. **Der Mailtext wird bewusst nicht gespeichert.** Wie lange darf die Adresse stehen?"

**Brauchbar ist die Antwort, wenn** sie eine Frist ab dem Versanddatum nennt.

**Beim ersten Anlauf kam sie nicht zustande** — „kann nicht bewertet werden, da wir Kontext nicht
verstehen. Wer sind die betroffenen Personen / warum kein Text". Beides steht deshalb jetzt in der
Frage selbst; ohne diese zwei Sätze wird sie wieder zurückgegeben.

**Daran hängt:** Diese Zeilen gehen mit keinem Cascade fort. Bis die Frist steht, räumt der
Lösch-Lauf sie überhaupt nicht — danach ist es eine `WHERE`-Bedingung und keine Migration.

*Steht in* `schema/querschnitt-schema.sql`

### 4. Die vier Fristen der Betriebsdaten gegenzeichnen

> „Zu den Betriebsdaten — Putzdienst, Elternmitarbeit, Mensa, Rechnungsfreigabe — haben Sie
> bestätigt, dass darauf keine Aufbewahrungspflicht liegt, und zurückgefragt, wie lange der Zugriff
> vorgesehen ist. Vorgesehen ist: **Putzdienst und Elternmitarbeit** Zyklusende plus ein Jahr,
> **Rückzahlung der Elternmitarbeit** drei Monate ab dem Abgang, **Mensa** bis zum letzten
> bestätigten Ende dieses Kindes, **Belege der Rechnungsfreigabe** zehn Jahre. Tragen Sie diese vier
> mit?"

**Brauchbar ist die Antwort, wenn** sie ein Ja trägt oder einen der vier Zeiträume korrigiert.

**Daran hängt:** `backlog/` TASK-245. Gebaut ist alles vier bereits; es geht allein um die
Gegenzeichnung im Verarbeitungsverzeichnis.

*Steht in* `verarbeitungsverzeichnis.md` · `backlog/` TASK-245

---

## Geschäftsführung — zwölf Fragen

Die Vertragstexte stehen hier nicht mehr: Sie werden künftig anhand dessen nachgezogen, **was im
Portal gebaut wird** — sie gehen keinem Ablauf mehr voraus und blockieren keine Domäne. Was daran zu
tun bleibt, ist eine Aufgabe und keine Frage: `backlog/`, TASK-042.

**Die ersten beiden sind Nachfragen, keine Entscheidungen** — sie standen schon in der letzten Mail
und blieben ohne Antwort. Eine davon hat eine Frist.

**Der öffentliche Teil des Portals steht hier nicht mehr.** Sein Umfang ist offen, aber er ist keine
Frage an die Geschäftsführung: Was Kalender und Kostenrechner am Ende tragen, entscheidet sich beim
Bauen und nicht in einem Termin. Der offene Punkt lebt als `backlog/` TASK-175 weiter — dort steht
er, und nur dort.

### 5. Stripe: welche Angaben fehlen dem Vorstand noch?

> „Das Stripe-Konto ist angelegt — es fehlen aber noch Angaben, und dort hängt es beim Vorstand.
> **Welche sind es, und wer beschafft sie?** Solange sie fehlen, kann im September niemand online
> freikaufen; wir hatten den **14.09.** notiert."

**Brauchbar ist die Antwort, wenn** benannt ist, welche Angaben fehlen und wer sie liefert — ein
Termin genügt nicht, solange niemand sagt, worauf gewartet wird.

**Daran hängt:** `backlog/` TASK-034. Und eine Sache entscheidet sich beim Ausfüllen mit, ohne dass
jemand sie als Frage stellt: **welche Stripe-Gesellschaft Vertragspartner wird.** Davon hängt ab, ob
überhaupt ein Drittlandtransfer stattfindet (`verarbeitungsverzeichnis.md`) — wer das Formular
abschickt, hat es entschieden.

**Die zweite Nachfrage ist erledigt:** Die Cyber-Versicherung hat am 03.09.2026 bestätigt, dass ihre
Bedingungen keine Verschlüsselung der Festplatten fordern (TASK-087).

*Steht in* `verarbeitungsverzeichnis.md` · `backlog/` TASK-034

### 6. Eine Absenderadresse für alles oder eine je Mailkategorie? — zwischen Corrado und Jürgen

> „Der Versand läuft künftig über **meinclemens.schule**, das ist entschieden. Offen ist nur noch,
> wie viele Absender es dahinter gibt: **eine Adresse für alles**, oder **eine je Mailkategorie** —
> Vorgangsmail, Schulinformation, Newsletter, und später womöglich Ferienprogramm und Akademie
> einzeln? Das ist von außen sichtbar und zieht Arbeit nach sich: Jede zusätzliche Absenderadresse
> ist ein Postfach mehr, das jemand anlegt und überwacht, und SPF, DKIM und DMARC hängen an ihr —
> die Verschärfung von DMARC auf `reject` kommt mit. Dafür trennt sie, was der Empfänger sonst nur
> am Betreff auseinanderhält, und ein Spamfilter, der den Newsletter aussortiert, nimmt die
> Vertragsfrist nicht mit."

**Brauchbar ist die Antwort, wenn** feststeht, ob es eine Adresse ist oder mehrere — und bei
mehreren, wie sie heißen. Die Zahl muss nicht endgültig sein: Eine weitere Adresse ist später ein
Wert und kein Bau, die **Struktur** dafür steht bereits.

**Daran hängt:** `backlog/` TASK-188 (AC #4) und TASK-088. Die Spalte für die Absenderadresse je
Mail steht schon leer da (`schema/querschnitt-schema.sql`, `outbound_emails.from_address`); leer
heißt „die eine, die der Versand ohnehin nimmt". Es wird also nichts gebaut, nur befüllt — aber die
Postfächer legt jemand an, und das ist der Teil mit dem Vorlauf.

*Steht in* `zugang.md` · `host.md` · `backlog/` TASK-188

### 7. AGFEO: Anlagentyp und der Weg hinein

> „Für die Telefonanlage brauchen wir den **Anlagentyp** und die verwendete Datenbank. Vorab eine
> Gegenfrage von uns: Das Dashboard bindet ODBC- und LDAP-Quellen ein — soll eine Telefonanlage
> **direkt** in der Weltenbaum-Datenbank lesen dürfen? Dort stehen Elterndaten, und ein Lesezugriff
> von außen ist keine Formatfrage."

**Brauchbar ist die Antwort, wenn** Anlagentyp und Datenbank benannt sind. Die Bewertung des
Zugriffs machen wir, sie gehört nicht in die Antwort.

**Daran hängt:** `backlog/` TASK-189.

*Steht in* `backlog/` TASK-189

### 8. Alumni: bekommt auch der irregulär Abgehende die Anfrage?

> „Die Alumni-Anfrage geht am 1. Juni hinaus, vor dem Abgang im Juli — an die Zehntklässler selbst
> und an die Sorgeberechtigten, deren letztes Kind geht. Wer **mitten im Jahr** abgeht, fällt aus
> diesem Rhythmus: Zum Umzug im November gibt es keinen Juni-Lauf, und drei Monate später ist die
> Adresse fort. Soll er trotzdem gefragt werden — dann bei seinem Abgang statt im Juni —, oder
> lassen wir ihn bewusst aus?"

**Brauchbar ist die Antwort, wenn** sie ein Ja oder ein Nein trägt. Ein Nein ist eine vollständige
Antwort und keine Lücke: Dann steht die Regel da, statt dass jemand den Fall später für vergessen
hält.

**Daran hängt:** `backlog/` TASK-208. Der Rest der Frage ist am 04.09.2026 beantwortet und steht in
[`soll-prozesse/04`](soll-prozesse/04-schuljahreswechsel.md): Zeitpunkt, Empfängerkreis, und dass
die Grundschulkinder nicht gefragt werden — mit zehn Jahren gäbe ein Elternteil die Antwort für sie
ab.

*Steht in* `soll-prozesse/04-schuljahreswechsel.md` · `backlog/` TASK-208

### 9. Notfallbetreuung: Ablehnung, nicht wahrgenommene Buchung — und die Uhrzeiten

> „Zur Notfallbetreuung sind noch drei Dinge offen. **Erstens:** Darf der Hort eine Notfallbetreuung
> überhaupt ablehnen? **Zweitens:** Wird eine gebuchte, aber nicht wahrgenommene berechnet?
> **Drittens, und das braucht die Hortleitung:** Bis wann kann im Portal gebucht werden? Der Schluss
> hängt am Fall — die Frühbetreuung endet früher als der Nachmittag desselben Tages. Wir brauchen je
> Fall-Art eine Uhrzeit; die 11:15 und 6:45 aus der Nachricht waren Beispiele."

**Brauchbar ist die Antwort, wenn** die ersten beiden ein Ja oder Nein tragen und je Fall-Art eine
Uhrzeit steht.

**Daran hängt:** `backlog/` TASK-214. Die Struktur trägt die ersten beiden schon: Buchung und
Vollzug sind zwei Zeitpunkte, eine Buchung ohne Vollzug ist genau die nicht wahrgenommene. Nur eine
**Ablehnung** wäre etwas Neues — heute ist ein Nein wie beim Hortvertrag kein Eintrag. Die Uhrzeiten
gehören als Wert in die Datenbank und nicht in den Code (`rules.md` Abschnitt 2).

**Der Nachweis am Telefonweg ist am 04.09.2026 beantwortet** und steht deshalb nicht mehr hier: Die
Familie sieht den Eintrag im Portal und meldet sich, bevor er auf einer Rechnung landet — keine
Bestätigungsmail, keine gezeichnete Tagesliste.

*Steht in* `soll-prozesse/09-hortvertrag.md` · `schema/anmeldung-schema.sql` · `backlog/` TASK-214

### 10. Notfallbetreuung: wovon wird bei einem Kind ohne Mandat eingezogen? — zusammen mit der Buchhaltung

> „Die Notfallbetreuung wird über die Hortrechnung abgerechnet: eine Sammelaufstellung zum
> Monatsende an die Buchhaltung, die sie im nächsten Zahlungslauf berücksichtigt. Der Zahlungslauf
> setzt aber ein SEPA-Mandat voraus, und die Notfallbetreuung steht ausdrücklich auch Kindern offen,
> die **keinen Betreuungsvertrag** haben — und damit unter Umständen kein Mandat. Wovon wird dort
> eingezogen: Rechnung auf Papier, Sofortzahlung im Portal wie bei der Ferienbuchung, oder gibt es
> den Fall praktisch nicht?"

**Brauchbar ist die Antwort, wenn** für das Kind ohne Mandat ein Weg benannt ist — auch „kommt nicht
vor" ist einer, dann steht es als Regel und nicht als Lücke.

**Daran hängt:** `backlog/` TASK-214. Die Sofortzahlung gilt heute für vier andere Vorgänge
(`soll-prozesse/hebel.md`); ein fünfter wäre eine Erweiterung dieser Liste, keine neue Mechanik.

*Steht in* `soll-prozesse/09-hortvertrag.md` · `backlog/` TASK-214

### 11. Die vollständige Liste der Anlagen zum Vertrag

> „Sie haben die **Kleiderordnung** und die **Regeln zu Putzdienst und Elternmitarbeit** als eigene
> Anlagen benannt und gesagt, dass es weitere gibt. Wir kennen aus dem Bestand noch Betreuungsordnung
> und Regelung zum Infektionsschutz. Können Sie die Liste aus dem heutigen Vertrag heraus
> vervollständigen — es sind die Blätter, die dort hinten dranhängen? Und zweitens: Wir wollen sie
> **nicht mehr ans erzeugte PDF heften**, sondern im Portal bereitstellen und im Vertragstext darauf
> verweisen. Steckten sie im PDF, wäre eine geänderte Betreuungsordnung je Vertrag eingefroren —
> genau das, was ‚in ihrer jeweils gültigen Fassung' ausschließt. Tragen Sie das mit?"

**Brauchbar ist die Antwort, wenn** die Liste vollständig ist und der Wegfall der angehefteten
Anlagen ein Ja oder Nein trägt.

**Daran hängt:** `backlog/` TASK-231 und TASK-226. Diese Anlagen tragen keine Personendaten,
entstehen nicht je Kind und haben keine Frist am Kind — die Zahl ändert daran nichts, sie ändert nur,
wann das Ticket fertig ist.

*Steht in* `dokumente.md` · `soll-prozesse/09-hortvertrag.md` · `backlog/` TASK-231

### 12. Das Vertragsupdate: wen erreicht es, und wann läuft der erste Durchgang?

> „Ändert sich der Vertragstext, legen wir die neue Fassung den laufenden Verträgen vor — bei einer
> wesentlichen Änderung als Nachtrag zum Unterschreiben, sonst zur Kenntnisnahme. Zwei Dinge fehlen
> uns dafür. **Erstens:** Wen erreicht eine Vorlage, und wen ausdrücklich nicht? Die Jahrgänge 1 und
> 5 haben gerade unterschrieben — bekommen die sie trotzdem? **Zweitens:** Wann läuft der erste
> Durchgang? Sie wollten ihn zum Schuljahresanfang; ein Elternportal gibt es dafür noch nicht."

**Brauchbar ist die Antwort, wenn** der Empfängerkreis samt Ausnahmen benannt ist und ein Termin
steht — auch „sobald das Portal läuft" ist einer.

**Daran hängt:** `backlog/` TASK-126 und daran TASK-234, die Routen für den Nachtrag. Ohne den
Empfängerkreis lässt sich das Vorlegen nicht planen: Es ist ein Lauf über fünfhundert Verträge und
keine Route je Familie.

*Steht in* `soll-prozesse/08-schulvertrag.md` · `backlog/` TASK-126

### 13. Der Wortlaut des SEPA-Mandats — zusammen mit der Buchhaltung

> „Das SEPA-Mandat wird künftig eine eigene Datei. Ihr Wortlaut ist von der Bank vorgegeben, und
> unsere Vorlage trägt ihn noch nicht — heute stünden dort nur Kontodaten, Referenz und Unterschrift,
> aber kein Mandatstext. Wer liefert ihn, und müssen Gläubiger-ID und Gläubigername darin stehen?
> **Zweitens:** Die Datei trägt die volle IBAN und liegt in der Schülerakte. Soll sie das, oder eine
> maskierte — dann belegt sie das Mandat allerdings nicht mehr."

**Brauchbar ist die Antwort, wenn** der Text vorliegt oder eine Quelle benannt ist, und die
IBAN-Frage ein Ja oder Nein trägt.

**Daran hängt:** `backlog/` TASK-196. Ohne den Wortlaut erzeugt das System eine Mandatsdatei, die
kein Mandat ist.

*Steht in* `soll-prozesse/08-schulvertrag.md` · `backlog/` TASK-196

### 14. Was eine Lehrkraft in der Schülerakte sehen darf

> „Lehrkräfte sollen auf die Schülerakte zugreifen können. Der Weg ist entschieden: **niemand
> bekommt dafür SharePoint-Rechte** — gelesen wird über meinCLEMENS, und dort gilt je Aufruf dieselbe
> Regel wie für die Daten daneben. Offen ist die fachliche Seite: **Welche Kategorien darf eine
> Lehrkraft sehen — und darf sie auch etwas ablegen oder nur lesen?** Zeugnis und Beobachtungsbogen
> sind etwas anderes als Vertrag und Gesundheitsblatt. **Zweitens:** Gibt die Schulleitung ihren
> heutigen Direktzugriff auf den Kohorten-Ordner ab und liest ebenfalls über das Portal?"

**Brauchbar ist die Antwort, wenn** die Kategorien als Positivliste benannt sind — was nicht
draufsteht, sieht sie nicht — und lesend von ablegend getrennt ist.

**Daran hängt:** `backlog/` TASK-184. Welche **Kinder** eine Lehrkraft sieht, ist schon beantwortet
(TASK-161); welche **Kategorien** es überhaupt gibt, hängt am Datenschutzbeauftragten (TASK-058.10).
Diese Frage ist die dritte Achse und die einzige, die der Schule gehört.

*Steht in* `grenzkarte.md` · `oberflaechen.md` · `backlog/` TASK-184

### 15. Wer welche Rolle vergeben darf — eine Bestätigung, keine offene Frage

> „Die Regel steht und ist bestätigt: **jede Führungskraft vergibt die Rollen ihres Bereichs**, das
> **Personalwesen alle übrigen**, und der **Admin jede**, damit niemand feststeckt. Was fehlt, ist
> die Zuordnung Bereich zu Rolle. Unser Vorschlag: Schulleitung → Lehrkraft; Hortleitung →
> Hortkraft; Hauswirtschaftsleitung → Mensa; KITA-Leitung → KITA-Mitarbeitende; Personalwesen →
> Mitarbeitende, Sekretariat, Buchhaltung, Personalverwaltung, Hausmeister, Führungskraft und die
> Leitungsrollen selbst. Der **Hausmeister steht bewusst nicht bei der Hauswirtschaftsleitung** —
> Küche ja, Haustechnik nein. Trägt der Zuschnitt so?"

**Brauchbar ist die Antwort, wenn** sie ein Ja trägt oder eine Zeile darin verschiebt.

**Daran hängt:** `backlog/` TASK-190. Die Zuordnung wird ein Wert im System und kein Code — eine
verschobene Zeile kostet später keinen Bau. Der Stellenwechsel braucht keinen eigenen Mechanismus:
Wer den Bereich wechselt, bekommt die Rolle von der neuen Führungskraft und verliert die alte.

*Steht in* `soll-prozesse/hebel.md` · `glossar.md` · `backlog/` TASK-190

### 16. Betreuungsvertragstext: drei Anpassungen — zusammen mit der Hortleitung

> „Der Betreuungsvertrag in der Fassung vom 11.12.2025 passt an drei Stellen nicht zu dem, was
> künftig läuft. **Erstens** endet die Betreuungsberechtigung mit dem Ende der Klasse 4 bzw. 5, ohne
> dass jemand kündigt — der Text sieht das nicht vor. **Zweitens** werden Abschluss, Änderung und
> Kündigung im Portal erklärt; der Text verlangt Schriftform. **Drittens** sagt er zu, die
> Gesundheitsangaben gelangten ausschließlich den Betreuungskräften zur Kenntnis — das stimmt schon
> heute nicht: Sekretariat und Schulleitung sehen sie, und die Klassenlehrkraft eines eigenen Kindes
> sieht sie vollständig. Wer ändert den Text, und bis wann?"

**Brauchbar ist die Antwort, wenn** je Punkt entweder „wird geändert" dasteht oder „bleibt so, und
dann gilt stattdessen …" — dazu ein Name und ein Termin.

**Daran hängt:** Alle drei sind gebaut, wie der Block sie beschreibt: Der Jahreslauf beendet die
Verträge ohne Kündigung ([04](soll-prozesse/04-schuljahreswechsel.md)), die Unterschrift im Portal
ist die einzige, die es gibt, und die Freigabe je Angabe an den Hort steht im Gesundheitsbestand.
Der dritte Punkt ist der einzige, bei dem der Text etwas zusagt, **was das System nicht halten
kann** — der lässt sich nicht durch Bauen auflösen.

*Steht in* `soll-prozesse/09-hortvertrag.md` · `schema/anmeldung-schema.sql`

---

## Sekretariat — vier Fragen

### 17. Zuordnung der Fremdsysteme — zusammen mit Buchhaltung und Admin

> „Wenn sich bei einem Kind oder einer Familie etwas ändert, muss das teilweise auch in ASV-BW,
> Optigem oder M365 nachgezogen werden. Wir haben eine Zuordnung erstellt, welche Änderung wohin
> läuft. Stimmt sie, und fehlt etwas? Und liegt in AGFEO eine Nummer, die mitziehen muss?"

**Brauchbar ist die Antwort, wenn** je System bestätigt ist, welche Änderungen dort ankommen müssen —
und was ergänzt gehört. Untis, Fobizz, Teams und der Fotobestand sind bereits draußen; offen ist
allein AGFEO, wo die Notfallnummer liegt.

**Daran hängt:** Wie viele Nachzieh-Aufgaben täglich entstehen. Sie korrigiert sich mit der Zeit
selbst: Häufen sich bei einem System Aufgaben, die als *war nichts zu tun* abgehakt werden, ist die
Zuordnung dort zu weit gefasst.

*Steht in* `soll-prozesse/02-datenaenderung.md:32`

### 18. Bescheinigungen beim Abgang

> „Wenn ein Kind die Schule verlässt — welche Papiere schreibt ihr routinemäßig? Abgangszeugnis,
> Schulbescheinigung für die neue Schule, Bestätigung der Abmeldung?"

**Brauchbar ist die Antwort, wenn** die Liste vollständig ist und je Papier klar ist, ob es immer
oder nur auf Anfrage entsteht.

**Daran hängt:** Was der Abgangsprozess anbietet und woran er erinnert.

*Steht in* `soll-prozesse/03-irregulaerer-abgang.md:25`

### 19. Aufgaben des Jahreswechsels — was tut das Sekretariat?

> „Der zweite Admin hat seinen Teil des Jahreswechsels aufgeschrieben: ASV-Export, Import nach
> Vis365, Teams und Elternverteiler nachziehen. Was tut ihr in dieser Zeit — jedes Jahr wieder, und
> ohne dass es irgendwo steht?"

**Brauchbar ist die Antwort, wenn** die wiederkehrenden Handgriffe benannt sind, die heute niemand
aufgeschrieben hat.

**Die Admin-Hälfte ist am 04.09.2026 beantwortet** und steht in `prozesse.md` Abschnitt 15. Zwei
Dinge daraus sind für diese Frage wichtig: **Klassen von Hand auf die neue Stufe umzuziehen entfällt
seit je** — die frühere Fassung dieser Frage behauptete das Gegenteil —, und der ASV-Export läuft in
einer Schleife aus Prüfen, Korrigieren und erneutem Export, die niemand zählt.

**Daran hängt:** Der Jahreswechsel steht künftig als Ansicht da statt als Zuruf — was in ihr fehlt,
bleibt Zuruf.

*Steht in* `soll-prozesse/04-schuljahreswechsel.md:30` · `prozesse.md` Abschnitt 15

### 20. Elternfragebogen der Grundschul-Checkliste — zusammen mit der Grundschulleitung

> „Beim Anmeldetag der Grundschule bekommen die Eltern einen Fragebogen auf Papier mit. Was steht
> darauf — und könnte er künftig vorab im Portal ausgefüllt werden?"

**Brauchbar ist die Antwort, wenn** die Feldliste vorliegt. Ohne sie ist nicht entscheidbar, ob
daraus ein Formular wird oder ob er Papier bleibt.

**Daran hängt:** Der Umfang von Domäne 2/4. Solange der Inhalt unbekannt ist, wird nichts dafür
gebaut.

*Steht in* `soll-prozesse/06-anmeldetag.md:20` · `grenzkarte.md`, Weiße Flecken

## Schulleitung — zwei Fragen

### 21. Unterrichtlicher und außerunterrichtlicher Ausflug — ein Unterschied oder zwei Wörter?

> „Für die Klassenfahrt gibt es eine mehrseitige Erklärung, die die Eltern unterschreiben —
> Einverständnis, Vollmacht, Kostenzusage, Belehrung. Für den Unterrichtsgang oder den Wandertag
> gibt es sie nicht, weil die Teilnahme dort Pflicht ist. Behandelt ihr die beiden wirklich
> verschieden, oder ist das nur ein Wort auf dem Papier? Konkret: Bekommen die Eltern vor einem
> Unterrichtsgang etwas zu unterschreiben, und muss jemand zustimmen, bevor er stattfindet?"

**Brauchbar ist die Antwort, wenn** feststeht, ob der unterrichtliche Ausflug ohne Anmeldung,
Unterschrift und Einwilligung auskommt — und ob die Ausflugspauschale beide Arten trägt oder nur
eine.

**Daran hängt:** Ob die beiden Arten ein Vorgang mit einer Unterscheidung bleiben oder zwei werden.
Steht am Ende doch bei jedem Ausflug eine Unterschrift, ist die Unterscheidung überflüssig und das
Schema trägt ein Feld, das nichts trennt. Steht sie nur bei der Fahrt, gilt der Schnitt aus dem
Block — und dann darf beim Unterrichtsgang **kein** leeres Einwilligungsfeld stehen, weil es
aussähe, als hätte jemand vergessen zu fragen.

*Steht in* `soll-prozesse/19-ausfluege-und-fahrten.md` (Kopf, die Tabelle der zwei Arten)

### 22. Geburtsurkunde: wie prüft das Sekretariat künftig?

> „Die Geburtsurkunde wird künftig nur noch **eingesehen** und nicht mehr kopiert — das ist
> entschieden. Offen ist der Ablauf: Wann wird sie vorgelegt, wer sieht sie an, und was wird
> festgehalten, damit später nachvollziehbar ist, dass sie vorlag?"

**Brauchbar ist die Antwort, wenn** feststeht, an welcher Stelle des Anmeldetags die Einsicht
passiert und welche Spur davon bleibt.

**Daran hängt:** `backlog/` TASK-054. Der Beschluss steht, die Umsetzung im Sekretariat nicht.

*Steht in* `soll-prozesse/06-anmeldetag.md` · `backlog/` TASK-054
