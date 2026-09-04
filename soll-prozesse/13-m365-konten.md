# 13. M365-Kontenverwaltung

## Auslöser

Jemand kommt oder geht:

- ein Kind wird eingeschrieben ([08](08-schulvertrag.md)) oder geht ab
  ([03](03-irregulaerer-abgang.md)),
- ein Mitarbeitender fängt an oder hört auf,
- eine Klasse entsteht ([15](15-klassenbildung.md)).

Ganzjährig, mit einer Spitze Ende Juli, wenn der ganze Jahrgang am Stück durchläuft
([04](04-schuljahreswechsel.md)). **Weltenbaum schreibt dabei nichts in den Tenant**
([00](00-zugang-und-portal.md)) und liest keine Gruppen: Dieser Block sagt, woraus die Handarbeit
des Admins entsteht und wann sie fällig ist — getan wird sie weiter von Hand in M365. Er ist deshalb
kein Ablauf im Portal, sondern der Ort, an dem ihr Anstoß entsteht.

## Beteiligte

- Der **Admin** arbeitet in beiden Systemen: In Weltenbaum sieht er seine
  [Aufgabenliste](hebel.md#nachzieh-aufgabe-und-wochenmail), in M365 legt er an, sperrt und löscht.
  Die Aufgabe hängt an der **Rolle** und nicht an einem Menschen — damit ist der „zweite Admin", von
  dem heute alles abhängt, kein Einzelner mehr, und Urlaub blockiert nichts.
- Ein- und Austritt trägt die **[Personalverwaltung](hebel.md#rollen)** ein, die neue Rolle dieses
  Blocks — **für beide Häuser, Schule wie KITA**: ein Bestand, ein Ablauf, und der Preis dafür ist
  benannt, nämlich dass die Schule die Personalangaben der KITA mitführt. Die **Geschäftsführung**
  darf dasselbe und fängt damit jeden Ausfall auf.
- **Rollen vergibt die Personalverwaltung nicht**: Das bleiben Admins und Geschäftsführung
  ([00](00-zugang-und-portal.md)), und es bleibt ein zweiter Handgriff nach dem Anlegen.
- Das **Sekretariat** sieht den Bestand wie sonst auch, **ändert hier aber nichts** — abweichend von
  der [Standardantwort](hebel.md#standardantworten), weil Personalangaben bei der Stelle bleiben,
  die sie führt.

Ausgelesen wird alles Weitere: wer für welches Schuljahr eingeschrieben ist
([08](08-schulvertrag.md)), wer abgeht ([03](03-irregulaerer-abgang.md)), welche Klassen es gibt
([15](15-klassenbildung.md)) und welche Mailadressen die Eltern führen
([02](02-datenaenderung.md)). **Die Eltern und die Kinder handeln hier nicht** — sie lesen nur eine
Angabe, die hier entsteht.

## Ablauf

| # | wer | tut was | danach steht fest |
|---|---|---|---|
| 1 | Personalverwaltung, Geschäftsführung | Legen einen **Mitarbeitenden** an — Name, Haus, auf Wunsch der erste Arbeitstag. Daraus entsteht die [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) beim Admin, das Konto anzulegen. Seine [Rollen](hebel.md#rollen) bekommt er getrennt davon ([00](00-zugang-und-portal.md)); bis dahin käme er nicht herein, und **genau das fängt 00 mit seiner Meldung an die Admins ab**, wenn ein Schulkonto ohne Rolle anklopft | dass es diese Person gibt, ab wann und in welchem Haus — und dass ihr Konto noch fehlt |
| 2 | Admin | Legt das Konto in der Domain an, die zu diesem Menschen gehört — Schüler, Schulmitarbeitende oder KITA —, und trägt die **Schuladresse** ein. Sie steht **am Menschen selbst und nicht an der Aufgabe**: Wo es eine [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) gibt, hakt ihr Eintrag sie ab; wo keine entsteht, weil der Jahrgang über die Jahresansicht läuft ([04](04-schuljahreswechsel.md)), trägt er sie ebendort ein — sonst hätten sechzig Kinder im August keinen Ort dafür. Für ein **Kind** derselbe Handgriff wie für einen Mitarbeitenden ([08](08-schulvertrag.md)), kein zweiter Weg daneben | mit welchem Konto diese Person hereinkommt, und wie ein Kind über die Schule erreichbar ist |
| 3 | Personalverwaltung, Geschäftsführung | Tragen den **letzten Arbeitstag** ein, sobald er feststeht — der Faden, der heute reißt. Mit seinem Ablauf **enden alle [Mitarbeiterrollen](hebel.md#rollen) von selbst**, ohne dass jemand sie entzieht: Er kommt nicht mehr herein, ist als Führungskraft nicht mehr wählbar, ein Beleg, der noch bei ihm liegt, trägt dort den Vermerk, dass seine Führungskraft ausgeschieden ist ([12](12-rechnungsfreigabe.md)), und er steht in keiner Aufgabenliste mehr — auch wenn sein Konto noch eine Weile steht | wann diese Person aufhört, und dass sie ab dann nichts mehr darf |
| 4 | Admin | Arbeitet die **Offboarding-Aufgabe** ab: Autoantwort einrichten, Passwort hart zurücksetzen. Für Kinder entsteht dieselbe Aufgabe aus [03](03-irregulaerer-abgang.md), für Gruppen und Verteiler aus [15](15-klassenbildung.md) — zum Schuljahreswechsel trägt beides die Jahresansicht ohne Aufgabe ([04](04-schuljahreswechsel.md)). **Ein Handgriff für Schüler wie Mitarbeitende** | dass an dieses Postfach niemand mehr kommt und die eingehende Post beantwortet wird |
| 5 | Admin | Löscht die Konten, deren Frist abgelaufen ist, aus der [frisch erzeugten Liste](hebel.md#frisch-erzeugte-liste) der **löschbaren Konten**. Das Löschen ist keine Aufgabe, sondern diese Liste: Ein ganzer Jahrgang stünde sonst im Januar als sechzig Zeilen in der Wochenmail, für Arbeit, bei der nichts kaputtgeht, wenn sie zwei Wochen später geschieht | nichts — die Liste wird kürzer, statt abgehakt zu werden |

## Was dabei erhoben wird

Neu ist der **Mitarbeitendeneintrag**: Name und Haus (Pflicht), die Schuladresse (Pflicht, vom
Admin) und der **letzte Arbeitstag**, sobald er feststeht (Pflicht — an ihm hängt alles Weitere).
Freiwillig sind zwei:

- der **erste Arbeitstag**, weil an ihm nichts hängt und ihn beim Import für die
  Bestandsmitarbeitenden ohnehin niemand mehr heraussucht,
- und **„an wen die Post künftig geht"**, woraus der Admin die Autoantwort baut — sonst ruft er wie
  heute an.

Sichtbar für **Personalverwaltung, Geschäftsführung, Admins und das Sekretariat**, **nicht für die
Schulleitung** — sie sieht im Rahmen ihrer Schulform
([Standardantwort](hebel.md#standardantworten)), und ein Mitarbeitender hat keine — und **nicht für
die KITA-Leitung**, auch nicht für ihr eigenes Haus: Der Preis eines Bestands für beide Häuser ist
offen benannt, das Schulsekretariat sieht die Ein- und Austritte der KITA und die KITA-Leitung sieht
keine.

Geändert wird von Personalverwaltung und Geschäftsführung — **außer der Schuladresse: die ändert
allein der Admin**, denn sie spiegelt den Tenant, und wer sie anderswo berichtigt, macht sie falsch
statt richtig; auch das weicht von der [Standardantwort](hebel.md#standardantworten) ab. Den Verlauf
trägt die [Änderungsspur](hebel.md#änderungsspur). **Mehr Personaldaten entstehen hier nicht** —
kein Vertrag, kein Stundenumfang, kein Gehalt. Der Eintrag ist zugleich die Antwort auf **„wer
arbeitet hier, und wer arbeitete hier in diesem Schuljahr"**: Genau das fragen
[01](01-putzdienst.md) und [14](14-elternbonus.md), wenn sie Mitarbeiterfamilien ausnehmen, und sie
lesen es an Rolle, Haus und letztem Arbeitstag — eine Rollenhistorie mit einem Entzugseintrag gibt
es dafür nicht, weil niemand entzieht.

Am **Kind** entsteht genau eine Angabe, seine **Schuladresse**, eingetragen und geändert allein vom
Admin, aus demselben Grund: sichtbar für Sekretariat, Schulleitung, Admins, auf der Klassenliste für
die Lehrkraft ([15](15-klassenbildung.md)) — **und für die Eltern im Portal**, denn sonst rufen sie
im Sekretariat an, um zu erfahren, wie ihr Kind erreichbar ist; sie ist die einzige Angabe, die
dieser Block einer Familie zeigt.

Ändert sich der Name eines Kindes, zieht der Admin Konto **und** Adresse in derselben Aufgabe nach,
die [02](02-datenaenderung.md) ohnehin erzeugt. Ein Konto bekommt **jedes eingeschriebene Kind
beider Schularten**, womit die offene Stelle in [08](08-schulvertrag.md) — „soweit die Schulart
eines vorsieht" — beantwortet ist.

## Entscheidungen

Zwei, beide von Menschen und beide außerhalb des Systems getroffen: **wer eingestellt wird und wer
geht**. Weltenbaum hält nur das Datum fest. Alles Übrige ist Ableitung:

- Wer eingeschrieben ist, bekommt ein Konto;
- wer abgeht, wird offgeboardet;
- welche Gruppe zu welcher Klasse gehört, sagt ihre Kennung ([15](15-klassenbildung.md)).

## Fristen und Termine

**Eine Frist und ein Fälligkeitstag.** Fällig ist die **Sperrung** am letzten Arbeitstag bzw. am
Abgangstag — eine Frist ist das nicht, es verfällt nichts, wenn sie später geschieht. Die Frist
gehört dem Konto: Es **wird sechs Monate danach gelöscht**, einheitlich für Schüler und
Mitarbeitende — eine Zahl, nicht zwei, weil niemand einen Unterschied benannt hat. Sie ist
[fest](hebel.md#geld-und-fristen-im-system-alles-andere-fest) und nirgends einstellbar.
[Aufgaben](hebel.md#nachzieh-aufgabe-und-wochenmail) haben wie überall keine Frist und verfallen
nicht.

## Mails und Schreiben

**Keine.** Die offenen Aufgaben laufen in der Wochenmail des Admins mit, das ist der einzige
Anstoß. Der ausscheidende Mitarbeitende bekommt aus Weltenbaum nichts; die Mail an die Familie eines
abgehenden Kindes gehört [03](03-irregulaerer-abgang.md), die Meldung eines Schulkontos ohne Rolle
gehört [00](00-zugang-und-portal.md).

## Dateien

Keine. Die Liste der löschbaren Konten ist eine [Ansicht](hebel.md#frisch-erzeugte-liste), sichtbar
für Admins, kein Dokument, und es unterschreibt niemand etwas.

## Sonderfälle

- Der [offizielle Umweg](hebel.md#der-offizielle-umweg) ist hier **nicht das Sekretariat**: Für die
  Handarbeit ist es der zweite Admin, weil die Aufgabe an der Rolle hängt; für Ein- und Austritt die
  Geschäftsführung.
- **Auch die letzte Admin-Rolle endet mit dem letzten Arbeitstag** — der Schutz in
  [`hebel.md`](hebel.md#rollen) gilt dem Entziehen und nicht dem Ausscheiden. Ausgesperrt ist das
  Haus deshalb nicht: Rollen vergibt die Geschäftsführung ebenso ([00](00-zugang-und-portal.md)),
  und sie hört nicht am selben Tag auf; ein Wächter wird dafür nicht gebaut.
- **KITA-Mitarbeitende laufen denselben Ablauf**, eingetragen von derselben Stelle und angelegt vom
  selben Admin — nur ihre Domain ist eine andere. Die KITA **handelt hier nicht**; sie kommt vor,
  ohne etwas zu tun.
- Ein **Mitarbeitender mit eigenem Kind an der Schule** ist eine Person mit zwei Anmeldewegen
  ([00](00-zugang-und-portal.md)): Sein letzter Arbeitstag beendet die Mitarbeiterrollen, der
  Elternweg bleibt, solange die Familie eine [laufende Verbindung](hebel.md#laufende-verbindung)
  hat.
- Wer sein Schulkonto nie genutzt hat, steht trotzdem im Bestand — genau deshalb entsteht der
  Eintrag beim Einstellen und nicht bei der ersten Anmeldung.

## Was heute schiefgeht

Die Kontenverwaltung ist vollständig Handarbeit **eines** Admins, und sie beginnt mit einem Zuruf,
der oft nicht kommt: Gelöscht wird, wer geht, *sofern es ihm mitgeteilt wird*. Es gibt keinen Ort,
an dem steht, dass jemand aufhört, also gibt es auch nichts, was sichtbar offen bleibt — Konten
stehen jahrelang weiter.

Künftig ist der letzte Arbeitstag ein Eintrag mit einer benannten Stelle davor und einer offenen
Aufgabe dahinter; erledigen muss sie weiter ein Mensch. Dazu entfällt die **Julihandarbeit**, alle
Klassengruppen umzubenennen — sie hängen an der unveränderlichen Kennung
([15](15-klassenbildung.md)).

## Fremdsysteme

**M365** ist hier das Fremdsystem und nicht die Nebensache: Konten für Schüler und Mitarbeitende,
Klassengruppen und Mailverteiler samt den Elternadressen, alles von Hand vom Admin, in drei
getrennten Domains im gemeinsamen Tenant mit der KITA — Schüler, Schulmitarbeitende,
KITA-Mitarbeitende. Weltenbaum schreibt in keine davon hinein und liest keine Gruppe. Je Person gibt
es dabei **eine** [Aufgabenart](hebel.md#nachzieh-aufgabe-und-wochenmail) und nicht zwei — die Art
ist das Ziel M365 und nicht der Anlass: Anlegen und Offboarding ersetzen einander, statt sich zu
verdoppeln ([15](15-klassenbildung.md)).

**ASV-BW und Optigem** geht dieser Block nichts an; ihre Aufgaben entstehen an denselben Stellen und
stehen dort. **SharePoint** bekommt nichts: Dateien legt Weltenbaum selbst ab
([08](08-schulvertrag.md), [12](12-rechnungsfreigabe.md)).

## Löschen

Das **Konto** im Tenant nach der Frist oben. Die **Schuladresse** am Kind hat dagegen keine eigene
Frist: Sie geht mit dem Kind (17) und bleibt stehen, auch wenn dessen Konto längst weg ist — sie
sagt dann, welches es war.

Der **Anker für den Lösch-Lauf** (17) ist der **letzte Arbeitstag** und nicht der Haken des Admins —
sonst hinge die Löschfrist einer Person daran, dass jemand eine Aufgabe abhakt.
Der **Mitarbeitendeneintrag** folgt ab diesem Tag dem Lösch-Lauf; wie lange er aufbewahrt wird, ist
die
offene Frage in [00](00-zugang-und-portal.md) und wird dort beantwortet, nicht hier ein zweites Mal
gestellt. Was seinen Namen anderswo trägt, überlebt ihn — ein von ihm freigegebener Beleg
([12](12-rechnungsfreigabe.md)).

## Gehört nicht dazu

- Das **Schreiben in den Tenant** — heute: keine Schnittstelle, kein Abgleich, keine gelesenen
  Gruppen; ihre Unordnung ist damit kein Vorprojekt ([00](00-zugang-und-portal.md)).
  **Ausgeschlossen ist es aber nicht mehr, nur zurückgestellt** (Geschäftsführung, 04.09.2026):
  Konten, Gruppen und Mailverteiler sollen künftig von hier aus entstehen, und langfristig gehört
  auch die Geräteverwaltung dazu — Weltenbaum ist die Plattform für alles, nicht eine neben anderen.
  Priorität hat es vorerst nicht, und deshalb steht hier weiterhin, was heute gilt und nicht, was
  einmal kommt. Der Weg bis dahin ist die
  [Nachzieh-Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail): **Weltenbaum sagt der zuständigen
  Stelle, dass etwas zu tun ist, statt es selbst zu tun** — das ist die Hälfte, an der heute der
  Faden reißt, und sie kostet keinen einzigen Grant. Was daran hängt, steht in `backlog/`.
- **Personalverwaltung im eigentlichen Sinn**: Verträge, Gehälter, Stundenkonten, Urlaub, Krankheit
  — die Rolle heißt so, führt hier aber sechs Angaben und keine siebte.
- Die **Rollenvergabe** selbst ([00](00-zugang-und-portal.md)) und was eine Rolle darf.
- **Klassenbildung** ([15](15-klassenbildung.md)) — hier steht nur, dass der Admin nachzieht.
- **Lizenzen, Passwortregeln, Zwei-Faktor-Pflicht, Geräte und SharePoint-Berechtigungen**: Sache des
  Tenants.
- Der **Lösch-Lauf** selbst (17): Dieser Block liefert ihm den Anker, mehr nicht.

> **Vorgemerkt aus [13](13-m365-konten.md)**, für den Block, der daran anschließt: **Block 17** bekommt von hier zwei Anker und muss beide bedienen — den **letzten Arbeitstag** eines Mitarbeitenden, ab dem sein Eintrag samt Rollen und letzter Anmeldung ([00](00-zugang-und-portal.md)) verfällt, und die **Schuladresse am Kind**, die keine eigene Frist hat, sondern mit dem Kind geht. Er muss außerdem sagen, ob er die Frage aus [00](00-zugang-und-portal.md) beantwortet, wie lange ein ausgeschiedener Mitarbeitender überhaupt aufbewahrt wird — ohne sie hat der Anker kein Ziel. Und er darf die **löschbaren Konten** nicht mitnehmen: Sie stehen im Tenant, nicht in Weltenbaum, und ihre sechs Monate laufen dort.
