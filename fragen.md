# Fragen an die Schule — was wen zu fragen ist

Fünfzehn Fragen, die Weltenbaum nicht selbst beantworten kann, sortiert nach dem Gespräch, in
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

## Datenschutzbeauftragte:r — drei Fragen

**Die sechs Löschfristen sind beantwortet** (02.09.2026) und stehen an ihren Ankern im Schema; was
hier bleibt, sind drei Reste; die vier Fragen aus dem Gespräch vom 02.09.2026 sind am 03.09.2026
von der Geschäftsführung beantwortet worden.

**Vier Dinge gehen mit, ohne Fragen zu sein.** Erstens, dass das **Protokoll der Notfalleinsicht mit
dem Kind geht**: Ein Vorfall 2026 an einem Kind, das 2031 abgeht, beginnt seine Frist 2031.
Zweitens, dass das **Freigabemodell je Angabe und Instanz** gebaut wird — mit der Möglichkeit, alles
in einer Handlung freizugeben; es ist strenger als die Vorgabe vom 02.09.2026 und deshalb eine
Mitteilung, keine Frage. Drittens, dass **Teilnehmer der Erwachsenen-Seminare dieselbe Frist tragen
wie schulfremde Kinder**. Und viertens: Erstens die Antwort auf seine Rückfrage, ob der
Lösch-Lauf ohne Datenleichen gebaut werden kann: ja — die Reihenfolge über alle Domänen steht als
achtstufige Kaskade im Kopf von `schema/querschnitt-schema.sql`, und ihr Prüfskript weist eine
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

---

## Geschäftsführung — sechs Fragen

Die Vertragstexte stehen hier nicht mehr: Sie werden künftig anhand dessen nachgezogen, **was im
Portal gebaut wird** — sie gehen keinem Ablauf mehr voraus und blockieren keine Domäne. Was daran zu
tun bleibt, ist eine Aufgabe und keine Frage: `backlog/`, TASK-042.

**Die ersten beiden sind Nachfragen, keine Entscheidungen** — sie standen schon in der letzten Mail
und blieben ohne Antwort. Eine davon hat eine Frist.

### 4. Akademie: die Kategorien und wer freigibt

> „Zwei Dinge fehlen mir noch zur Akademie. Welche **Kategorien** gibt es zum Start? Und: Anlegen
> darf jede und jeder Mitarbeitende, freigegeben werden muss trotzdem jedes Angebot, bevor es
> draußen steht — **welche Stelle gibt frei**? Du für jedes Angebot, oder die Leitung der Stelle, an
> der die anbietende Person hängt?"

**Brauchbar ist die Antwort, wenn** die Kategorien als Liste dastehen und die freigebende Stelle
benannt ist.

**Daran hängt:** Die Kategorie ist eine Werteliste und kostet nichts — sie darf auch später wachsen.
Die Freigabe dagegen entscheidet, wo der Wartezustand jedes Angebots sitzt: bei der
Geschäftsführung ein Nadelöhr, bei der jeweiligen Leitung ein kurzer Weg, aber mehrere Maßstäbe.

*Steht in* `soll-prozesse/21-akademie.md:52` · `soll-prozesse/21-akademie.md:90`

### 5. Stripe-Konto und Auftragsverarbeitungsvertrag

> „Ein Punkt aus der letzten Mail ist ohne Antwort geblieben: das **Stripe-Konto samt
> Auftragsverarbeitungsvertrag**. Ohne es kann im September niemand online freikaufen; wir hatten den
> **14.09.** als Frist notiert. Wer legt es an, und wann?"

**Brauchbar ist die Antwort, wenn** feststeht, wer das Konto anlegt und bis wann.

**Daran hängt:** `backlog/` TASK-034 — und welche Stripe-Gesellschaft Vertragspartner wird,
entscheidet, ob überhaupt ein Drittlandtransfer stattfindet (`verarbeitungsverzeichnis.md`).

**Die zweite Nachfrage ist erledigt:** Die Cyber-Versicherung hat am 03.09.2026 bestätigt, dass ihre
Bedingungen keine Verschlüsselung der Festplatten fordern (TASK-087).

*Steht in* `verarbeitungsverzeichnis.md` · `backlog/` TASK-034

### 6. Zieht der Mailversand mit meinCLEMENS mit?

> „Die Domain **meinclemens.schule** ist beauftragt. Soll die Absenderadresse künftig auch von dort
> kommen — und wie soll das Postfach heißen, aus dem die Mails gehen? Beides ist von außen sichtbar
> und zieht Arbeit nach sich: DNS, SPF, DKIM und DMARC hängen an der Absenderdomain, und die
> Verschärfung von DMARC auf `reject` kommt mit."

**Brauchbar ist die Antwort, wenn** feststeht, ob der Versand mitwandert, und wie das Postfach heißt.
Der Name der Domain selbst ist entschieden (03.09.2026) und nicht mehr Teil der Frage.

**Daran hängt:** `backlog/` TASK-188 und TASK-088; gekauft wird die Domain unter TASK-213.

*Steht in* `zugang.md` · `host.md`

### 7. AGFEO: Anlagentyp und der Weg hinein

> „Für die Telefonanlage brauchen wir den **Anlagentyp** und die verwendete Datenbank. Vorab eine
> Gegenfrage von uns: Das Dashboard bindet ODBC- und LDAP-Quellen ein — soll eine Telefonanlage
> **direkt** in der Weltenbaum-Datenbank lesen dürfen? Dort stehen Elterndaten, und ein Lesezugriff
> von außen ist keine Formatfrage."

**Brauchbar ist die Antwort, wenn** Anlagentyp und Datenbank benannt sind. Die Bewertung des
Zugriffs machen wir, sie gehört nicht in die Antwort.

**Daran hängt:** `backlog/` TASK-189.

*Steht in* `backlog/` TASK-189

### 8. Notfallbetreuung: welche Preise sind unsere?

> „In der Hort-Preisliste stehen für die **Notfallbetreuung** die Werte 8 / 8 / 12 / 16 / 20 in
> derselben Spalte, die anderswo mit ‚Stadt*' überschrieben ist — also in der Vergleichsspalte.
> Daneben steht in der ersten Spalte ‚20 € pro Fall' für den Nachmittag bis 17 Uhr, ‚8 € pro Fall'
> für eine Stunde innerhalb der Öffnungszeiten und ‚20 € pro Fall' für eine halbe Stunde außerhalb.
> Welche Werte sind unsere?"

**Brauchbar ist die Antwort, wenn** je Fall ein Betrag zugeordnet ist.

**Daran hängt:** Die Notfallbetreuung passt ohnehin nicht in die Preistabelle der Betreuungsmodule —
die kennt nur einen Monatsbeitrag je Zahl der Wochentage, „pro Fall" hat dort keinen Platz. Ohne die
Zuordnung stünde außerdem ein Fremdpreis in unserer Liste.

*Steht in* `schema/anmeldung-schema.sql` · `backlog/` TASK-050

### 9. Wie erfahren wir, wer Alumni werden will?

> „Für den Alumni-Verteiler brauchen wir eine Einwilligung: Name und Mailadresse dürfen bleiben, bis
> widersprochen wird. Offen ist, **wann und wie wir fragen** — beim Abgang im Portal, mit den letzten
> Papieren, oder später per Mail an die zuletzt bekannte Adresse? Und fragen wir die Eltern oder das
> Kind, wenn es volljährig ist?"

**Brauchbar ist die Antwort, wenn** ein Zeitpunkt im Abgangsvorgang benannt ist und feststeht, wer
gefragt wird.

**Daran hängt:** `backlog/` TASK-208 baut die Einwilligung; ohne den Zeitpunkt hat sie keinen
Auslöser. Und es gibt eine Kollision zu bedenken: Wer erst **nach** dem Abgang gefragt werden soll,
muss bis dahin erreichbar sein — die Adresse fällt aber drei Monate nach dem Austritt.

*Steht in* `soll-prozesse/03-irregulaerer-abgang.md` · `backlog/` TASK-208

---

## Sekretariat — vier Fragen

### 10. Zuordnung der Fremdsysteme — zusammen mit Buchhaltung und Admin

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

### 11. Bescheinigungen beim Abgang

> „Wenn ein Kind die Schule verlässt — welche Papiere schreibt ihr routinemäßig? Abgangszeugnis,
> Schulbescheinigung für die neue Schule, Bestätigung der Abmeldung?"

**Brauchbar ist die Antwort, wenn** die Liste vollständig ist und je Papier klar ist, ob es immer
oder nur auf Anfrage entsteht.

**Daran hängt:** Was der Abgangsprozess anbietet und woran er erinnert.

*Steht in* `soll-prozesse/03-irregulaerer-abgang.md:25`

### 12. Aufgaben des Jahreswechsels

> „Ende Juli zieht der zweite Admin alle Klassen von Hand auf die neue Stufe um, legt die Neuen an
> und löscht die Abgänger. Was tut ihr in dieser Zeit sonst noch, jedes Jahr wieder?"

**Brauchbar ist die Antwort, wenn** die wiederkehrenden Handgriffe benannt sind, die heute niemand
aufgeschrieben hat.

**Daran hängt:** Der Jahreswechsel steht künftig als Ansicht da statt als Zuruf — was in ihr fehlt,
bleibt Zuruf.

*Steht in* `soll-prozesse/04-schuljahreswechsel.md:30`

### 13. Elternfragebogen der Grundschul-Checkliste — zusammen mit der Grundschulleitung

> „Beim Anmeldetag der Grundschule bekommen die Eltern einen Fragebogen auf Papier mit. Was steht
> darauf — und könnte er künftig vorab im Portal ausgefüllt werden?"

**Brauchbar ist die Antwort, wenn** die Feldliste vorliegt. Ohne sie ist nicht entscheidbar, ob
daraus ein Formular wird oder ob er Papier bleibt.

**Daran hängt:** Der Umfang von Domäne 2/4. Solange der Inhalt unbekannt ist, wird nichts dafür
gebaut.

*Steht in* `soll-prozesse/06-anmeldetag.md:20` · `grenzkarte.md`, Weiße Flecken

## Schulleitung — zwei Fragen

### 14. Unterrichtlicher und außerunterrichtlicher Ausflug — ein Unterschied oder zwei Wörter?

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

### 15. Geburtsurkunde: wie prüft das Sekretariat künftig?

> „Die Geburtsurkunde wird künftig nur noch **eingesehen** und nicht mehr kopiert — das ist
> entschieden. Offen ist der Ablauf: Wann wird sie vorgelegt, wer sieht sie an, und was wird
> festgehalten, damit später nachvollziehbar ist, dass sie vorlag?"

**Brauchbar ist die Antwort, wenn** feststeht, an welcher Stelle des Anmeldetags die Einsicht
passiert und welche Spur davon bleibt.

**Daran hängt:** `backlog/` TASK-054. Der Beschluss steht, die Umsetzung im Sekretariat nicht.

*Steht in* `soll-prozesse/06-anmeldetag.md` · `backlog/` TASK-054
