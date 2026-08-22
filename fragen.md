# Fragen an die Schule — was wen zu fragen ist

Sechzehn Fragen, die Weltenbaum nicht selbst beantworten kann, sortiert nach dem Gespräch, in das
sie gehören. Je Frage steht hier ihr **Wortlaut**, das **Kriterium**, an dem du erkennst, dass die
Antwort reicht, und **woran sie hängt**.

## Abgrenzung zu den Nachbardateien

| Datei | trägt |
|---|---|
| `[?]` im Soll-Block bzw. im Schema | die Frage an der Stelle, an der sie beißt — dort fällt auf, dass sie fehlt |
| `TODO.md` | **dass** sie zu klären ist, bis wann und mit welcher Folge |
| **hier** | **wie du sie stellst** und wann eine Antwort brauchbar ist |

Hier wird nichts entschieden und nichts festgelegt. Diese Datei bereitet ein Gespräch vor, mehr
nicht — was aus dem Gespräch zurückkommt, gehört woanders hin.

## Wenn eine Antwort da ist

Vier Stellen, in dieser Reihenfolge: **Soll-Block** (er ist die abgestimmte Fassung) → **Schema**,
wo die `[?]` damit fällt → `TODO.md` abhaken → hier streichen.

Eine beantwortete Frage ist damit immer ein Eingriff an vier Stellen. **Antworten sammeln und in
einem Zug einarbeiten** ist deshalb billiger als jede einzeln nachzuziehen. Beim Streichen wandern
die Zahlen mit: die im Vorspann und die in der Überschrift des Gesprächs.

---

## Datenschutzbeauftragte:r — ein Termin, acht Fragen

Sechs davon sind Löschfristen. **Ohne sie kann Block 17 (Lösch-Lauf) nicht geschrieben werden**, und
ohne Block 17 löscht Weltenbaum gar nichts — jede Aufbewahrungszusage im System ist bis dahin ein
Versprechen ohne Mechanik.

Der Satz, mit dem du in dieses Gespräch gehst, gilt für alle sechs: **Weltenbaum ersetzt ASV-BW und
Optigem nicht.** Die aufbewahrungspflichtige Führung bleibt dort; hier steht eine Arbeitskopie. Das
verkürzt die Fristen möglicherweise erheblich — entscheiden muss es trotzdem sie, geraten wird nicht.

### 1. Zweck der vier Voranmeldefelder — zusammen mit der Schulleitung

> „Auf der Voranmeldung erheben wir vier Angaben, für die bei uns kein Zweck festgehalten ist:
> Konfession, Beruf und Staatsangehörigkeit der Eltern und die Kirchengemeinde des Kindes. Welchen
> Zweck hat jede einzelne davon — und soll sie bleiben?"

**Brauchbar ist die Antwort, wenn** je Feld ein benannter Zweck dasteht oder ein klares Nein.
Konfession ist ein Datum nach Art. 9 DSGVO; „das hatten wir immer schon" trägt dafür nicht.

**Daran hängt:** Vor dem Vollimport ist ein Nein ein `DROP COLUMN`. Danach ist es eine Migration auf
echten und teils besonders geschützten Personendaten. **Deshalb vor dem Vollimport, nicht danach.**

**Die Kirchengemeinde gehört ausdrücklich nicht in diese Frist** — sie wird weiter erhoben, und ob
sie bleibt, wird erst einige Monate nach dem Import entschieden. Sie steht hier nur, damit klar ist,
dass sie bewusst draußen ist.

**An dieser Frage hängt zusätzlich die Werteliste `denominations`** — sie steht als einzige der
Wertelisten leer und bekommt keinen Anfangsbestand, solange der Zweck des Feldes nicht beschlossen
ist. Bleibt das Feld, ist die zweite Frage, welche Konfessionen darin auswählbar sein sollen; das
beantwortet dann das Sekretariat, nicht dieses Gespräch. Fällt das Feld, fällt die Liste mit ihm.

*Steht in* `schema/stammdaten-schema.sql:929` · `soll-prozesse/05-bewerbung.md:19` · `TODO.md`

### 2. Bewerbungen, die zu keiner Aufnahme geführt haben

> „Ein Kind bewirbt sich und bekommt eine Absage, oder es bleibt auf der Warteliste und kommt nie.
> Wie lange dürfen wir seine Bewerbung behalten?"

**Brauchbar ist die Antwort, wenn** sie eine Frist ab dem Tag nennt, an dem die Absage feststeht.

**Daran hängt:** Der Löschanker steht (`applications`, Endstatus), sein Ziel nicht. Betroffen sind
auch die Personenzeilen, die mit der Bewerbung entstanden sind — sonst wächst der Stammdatenbestand
mit Leuten, die nie an der Schule waren.

*Steht in* `schema/anmeldung-schema.sql:1041` · `soll-prozesse/05-bewerbung.md:35`

### 3. Ferienprogramm: Buchung und Kind

> „Ein Kind war einmal im Ferienprogramm — auch eines, das gar nicht bei uns zur Schule geht. Wie
> lange behalten wir seine Buchung und seine Daten nach dem letzten gebuchten Termin?"

**Brauchbar ist die Antwort, wenn** sie eine Frist ab dem letzten gebuchten Termin nennt.

**Daran hängt:** Ein schulfremdes Kind hat kein Austrittsdatum, an dem sonst gerechnet würde — bei
ihm ist der letzte Termin der einzige Anker, den es gibt.

*Steht in* `schema/ferien-schema.sql:481` · `soll-prozesse/10-ferienprogramm.md:37`

### 4. Vertrags- und Zahlungsdaten

> „Ein Kind verlässt die Schule. Wie lange behalten wir seinen Vertrag und die Bankverbindung, von
> der eingezogen wurde?"

**Brauchbar ist die Antwort, wenn** sie eine Frist ab dem bestätigten Ende nennt — und getrennt sagt,
ob für den Vertrag etwas anderes gilt als für das Mandat.

**Daran hängt:** Sie entscheidet, wann `sepa_mandates` mit dem Kind verschwindet. Ein abgelöstes
Mandat bleibt bis dahin als Beleg stehen.

*Steht in* `schema/stammdaten-schema.sql:946` · `soll-prozesse/03-irregulaerer-abgang.md:33`

### 5. Daten ausgeschiedener Mitarbeitender

> „Wie lange behalten wir die Daten eines Mitarbeiters, nachdem sein letzter Arbeitstag vorbei ist?"

**Brauchbar ist die Antwort, wenn** sie eine Frist ab dem letzten Arbeitstag nennt.

**Daran hängt:** Der Anker steht (`employees.last_working_day`), sein Ziel nicht. Was den Namen
anderswo trägt — ein freigegebener Beleg, eine bestätigte Mitarbeitsstunde — überlebt ihn ohnehin.

*Steht in* `schema/stammdaten-schema.sql:943` · `schema/m365-schema.sql:60` ·
`soll-prozesse/00-zugang-und-portal.md:34`

### 6. Versandte Mails an noch unbekannte Familien

> „Wir verschicken Mails an Leute, die wir noch gar nicht als Familie führen — etwa die Bestätigung
> einer Ferienbuchung. Von dieser Mail bleibt bei uns nur die Adresse stehen, an keiner Person
> hängend. Wie lange darf sie das?"

**Brauchbar ist die Antwort, wenn** sie eine Frist ab dem Versanddatum nennt.

**Daran hängt:** Diese Zeilen gehen mit keinem Cascade fort. Bis die Frist steht, räumt der Lösch-Lauf
sie überhaupt nicht — danach ist es eine `WHERE`-Bedingung und keine Migration. Die einzige der sechs
Fristen, die kein Soll-Block berührt.

*Steht in* `schema/querschnitt-schema.sql:924`

### 7. Was sonst noch aufbewahrungspflichtig ist

> „Außer Vertrag und Zahlungsdaten — gibt es an einem abgegangenen Kind noch etwas, das wir behalten
> müssen, und wie lange?"

**Brauchbar ist die Antwort, wenn** sie entweder eine Liste nennt oder ein klares Nein. Ein „ich
schau mal" lässt die Frage offen.

**Daran hängt:** Die Bestätigung, dass die sechs Fristen oben vollständig sind. Fehlt sie, weiß der
Lösch-Lauf nicht, ob er zu viel räumt.

*Steht in* `soll-prozesse/03-irregulaerer-abgang.md:33`

### 8. Wer den Lösch-Lauf anstößt — zusammen mit der Schulleitung

> „Der Lösch-Lauf läuft nicht von allein los. Wer drückt einmal im Jahr den Knopf, und wer bestätigt
> hinterher, dass er richtig gelaufen ist?"

**Brauchbar ist die Antwort, wenn** zwei Rollen benannt sind — auslösen und bestätigen, nicht
dieselbe Person.

**Daran hängt:** Ohne benannte Rolle ist der Lauf gebaut und wird nie ausgelöst.

*Steht in* `soll-prozesse/04-schuljahreswechsel.md:34`

---

## Geschäftsführung — vier Fragen

Drei davon sind **Vertragstexte**, und jeder ist Vorbedingung für seinen Prozess, nicht Beiwerk:
Solange der Text die alte Mechanik beschreibt, kann der digitale Ablauf nicht laufen, ohne dem zu
widersprechen, was die Eltern unterschrieben haben.

### 9. Betreuungsvertrag, drei Anpassungen — zusammen mit der Hortleitung

> „Bevor der Hortvertrag digital laufen kann, müssen drei Stellen im Text geändert werden. Machen
> wir das, und bis wann?"
>
> 1. Der Vertrag endet zum Ende der Klasse 4 bzw. 5 **ohne Kündigung** — heute verlangt er eine.
> 2. Die **Schriftform**: unterschrieben wird künftig im Portal, nicht auf Papier.
> 3. Die Zusage, dass die Angaben **ausschließlich den Betreuungskräften** bekannt werden — die
>    stimmt schon heute nicht.

**Brauchbar ist die Antwort, wenn** je Punkt ein Ja mit Termin dasteht. Gegen den Vertragsstand vom
11.12.2025 geprüft: alle drei stehen weiterhin aus.

**Daran hängt:** Domäne 2/4 — der digitale Hortvertrag.

*Steht in* `schema/anmeldung-schema.sql:1046` · `soll-prozesse/09-hortvertrag.md:28`

### 10. Essensbedingungen, zwei Anpassungen

> „Für die Mensa-Anmeldung müssen zwei Stellen im Text geändert werden: Anmeldung und Kündigung
> laufen künftig **im Portal statt mit Unterschrift**, und die **Lastschrift-Ermächtigung steht nicht
> mehr in diesem Text** — das Mandat kommt künftig aus dem Schulvertrag."

**Brauchbar ist die Antwort, wenn** beide Punkte ein Ja mit Termin haben.

**Daran hängt:** Domäne 6 — das Mensa-Abo.

*Steht in* `schema/mensa-schema.sql:218` · `soll-prozesse/11-mensa.md:27`

### 11. Anlage zum Elternbonus

> „Ist der Text der Anlage zur Elternmitarbeit anzupassen? Künftig trägt man die Stunden im Portal
> statt auf einem Zettel ein, die Frist ist der 31. Juli, und es zählen nur bestätigte Stunden."

**Brauchbar ist die Antwort, wenn** klar ist, ob der Text geändert wird — und wenn ja, wer ihn
schreibt.

**Daran hängt:** Domäne 11 — das Bonussystem. Ausdrücklich nicht v1, aber der Text geht dem Bau
voraus.

*Steht in* `schema/elternbonus-schema.sql:110` · `soll-prozesse/14-elternbonus.md:29`

### 12. Elternbonus in Optigem — zusammen mit der Buchhaltung

> „Wird der Elternbonus in Optigem als eigene Position geführt, damit der monatliche Aufschlag und
> die Rückzahlung dort getrennt sichtbar sind?"

**Brauchbar ist die Antwort, wenn** klar ist, ob eine eigene Position angelegt wird. Ein Nein ist
auch eine Antwort — dann läuft die Rückzahlung ununterscheidbar im Schulgeld mit.

**Daran hängt:** Nichts im Schema. Weltenbaum rechnet den Bonus nicht, es hält nur die bestätigten
Stunden — gebucht wird in Optigem.

*Steht in* `schema/elternbonus-schema.sql:113` · `soll-prozesse/14-elternbonus.md:29`

---

## Sekretariat — vier Fragen

### 13. Zuordnung der Fremdsysteme — zusammen mit Buchhaltung und Admin

> „Wenn sich bei einem Kind oder einer Familie etwas ändert, muss das teilweise auch in ASV-BW,
> Optigem oder M365 nachgezogen werden. Wir haben eine Zuordnung erstellt, welche Änderung wohin
> läuft. Stimmt sie, und fehlt etwas?"

**Brauchbar ist die Antwort, wenn** je System bestätigt ist, welche Änderungen dort ankommen müssen —
und was ergänzt gehört.

**Daran hängt:** Wie viele Nachzieh-Aufgaben täglich entstehen. Sie korrigiert sich mit der Zeit
selbst: Häufen sich bei einem System Aufgaben, die als *war nichts zu tun* abgehakt werden, ist die
Zuordnung dort zu weit gefasst.

*Steht in* `soll-prozesse/02-datenaenderung.md:32`

### 14. Bescheinigungen beim Abgang

> „Wenn ein Kind die Schule verlässt — welche Papiere schreibt ihr routinemäßig? Abgangszeugnis,
> Schulbescheinigung für die neue Schule, Bestätigung der Abmeldung?"

**Brauchbar ist die Antwort, wenn** die Liste vollständig ist und je Papier klar ist, ob es immer
oder nur auf Anfrage entsteht.

**Daran hängt:** Was der Abgangsprozess anbietet und woran er erinnert.

*Steht in* `soll-prozesse/03-irregulaerer-abgang.md:25`

### 15. Aufgaben des Jahreswechsels

> „Ende Juli zieht der zweite Admin alle Klassen von Hand auf die neue Stufe um, legt die Neuen an
> und löscht die Abgänger. Was tut ihr in dieser Zeit sonst noch, jedes Jahr wieder?"

**Brauchbar ist die Antwort, wenn** die wiederkehrenden Handgriffe benannt sind, die heute niemand
aufgeschrieben hat.

**Daran hängt:** Der Jahreswechsel steht künftig als Ansicht da statt als Zuruf — was in ihr fehlt,
bleibt Zuruf.

*Steht in* `soll-prozesse/04-schuljahreswechsel.md:30`

### 16. Elternfragebogen der Grundschul-Checkliste — zusammen mit der Grundschulleitung

> „Beim Anmeldetag der Grundschule bekommen die Eltern einen Fragebogen auf Papier mit. Was steht
> darauf — und könnte er künftig vorab im Portal ausgefüllt werden?"

**Brauchbar ist die Antwort, wenn** die Feldliste vorliegt. Ohne sie ist nicht entscheidbar, ob
daraus ein Formular wird oder ob er Papier bleibt.

**Daran hängt:** Der Umfang von Domäne 2/4. Solange der Inhalt unbekannt ist, wird nichts dafür
gebaut.

*Steht in* `soll-prozesse/06-anmeldetag.md:20` · `grenzkarte.md`, Weiße Flecken
