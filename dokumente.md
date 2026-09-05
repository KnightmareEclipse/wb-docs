# Dokumente — Vorlage, Fassung, Urkunde

Umgesetzt in `wb-backend` (`app/services/anmeldung.py`, `app/services/graph.py`). **Wann** ein
Dokument entsteht und wer es unterschreibt, steht im Soll-Block des Vorgangs — er schlägt diese
Datei; **welche Spalte warum** so aussieht, in `schema/querschnitt-schema.sql` und
`schema/anmeldung-schema.sql`; wo die Dateien liegen, in `oberflaechen.md` und `grenzkarte.md`, Q2.
Hier steht allein der Mechanismus dazwischen: wie aus einer Word-Datei und Daten eine Urkunde wird,
und was eine neue Vertragsart kostet.

## Die Kette

Vier Stationen, und die Grenze zwischen Zwischenstand und Gültigkeit ist die ganze Konstruktion:

1. **Arbeitsfassung** — eine `.docx` in SharePoint, an der die Geschäftsführung schreibt, so oft sie
   will. **Das ist die Werkbank und bleibt es:** In der Datenbank wird an keiner Word-Datei
   gearbeitet. Nichts zeigt auf sie, sie hat keinen Gültigkeitstag. Ihre Graph-Kennung steht an
   `contract_text_kinds`. Der Weg über den Pfad ist einmalig: `GET /drives/{id}/root:/{pfad}` oder
   der kopierte Link über `GET /shares/{u!…}/driveItem` liefert die Element-Kennung, und nur die
   wird gespeichert.
2. **Stand einlesen** — die Datei über Graph holen, prüfen und als Kopie samt Prüfsumme in
   `contract_texts` ablegen. Sie ist damit **noch nicht gültig**: Solange ihr Gültigkeitstag in der
   Zukunft liegt, ist sie ein Zwischenstand und lässt sich durch einen neueren ersetzen, so oft
   nötig. **Genau darauf läuft die Vorschau** — der Vergleich gegen die geltende Fassung
   (`backlog/` TASK-259) lässt sich damit durchspielen, bevor irgendjemand ihn zu sehen bekommt.
3. **Einfrieren heißt: den Gültigkeitstag erreichen.** Es ist keine eigene Handlung, sondern die
   Folge einer Entscheidung — die Geschäftsführung setzt `valid_from`, und mit diesem Tag ist die
   Fassung unveränderlich. Vorher ändern kostet nichts, nachher gar nicht mehr. Eine Datei in
   SharePoint ließe sich so nicht festhalten: Sie bleibt bearbeitbar, und der Nachweis „welche
   Fassung galt" wäre lautlos wertlos.

   **Die Änderungsspur trägt die Bytes nie** — für `template_docx` steht dort die Prüfsumme statt
   des Werts, und ein Constraint erzwingt es (`schema/querschnitt-schema.sql`). Ein ersetzter
   Zwischenstand kostet damit keinen Plattenplatz in der Spur, sondern eine Zeile.
   **Zwei Dinge fallen an dieser Station leicht durchs Raster.** Die Änderungsspur darf die
   Dateibytes nicht mitschreiben — sie trägt für `template_docx` die Prüfsumme statt des Werts, und
   das gilt auch für das **Anlegen**, wo die Spur die ganze neue Zeile hält und ein Constraint, der
   an einer Spaltenkennung hängt, sie nicht sieht. Und die Bytes werden **nachgeladen**: Eine
   Leseroute über alle Fassungen zöge sonst jedes Mal jede Vorlage mit.
4. **Rendern** — Fassung plus Daten ergeben ein PDF. Eine Funktion, mehrere Aufrufer (unten).
5. **Urkunde** — das abgelegte PDF, seine Prüfsumme am Vorgang.

Jede Prüfsumme steht in der Form `sha256:<64 Hexstellen>` — festgelegt und nicht bloß Konvention,
weil die Änderungsspur sie liest. **Und eine Prüfsumme ohne Leser ist keine Gegenprobe:** Solange
kein Endpunkt sie ausliefert und kein Lauf sie gegen die Datei hält, ist die Zusage „jede spätere
Abweichung zeigt sich" (08) nicht gebaut.

Wann die Fassung einfriert, sagt der Block: beim Schulvertrag mit der Zusage
(`soll-prozesse/08-schulvertrag.md`). Der Hortvertrag kennt keine Zusage, und wo dort eingefroren
wird, ist offen — das gehört in `09` entschieden und nicht hierher. Die *Daten* sind in keinem Fall
eingefroren: Korrekturen bis zur Freigabe sind erwünscht, und das Dokument entsteht aus dem Stand
der Freigabe.

## Die Vorlage

Word mit **Klartext-Platzhaltern**, gefüllt per `docxtpl`. Keine Inhaltssteuerelemente und keine
Formularfelder: Ein Text lässt sich nicht in eine Checkbox verwandeln, und wer ihn löscht,
hinterlässt ein sichtbares Loch statt einer unsichtbar kaputten Feldeigenschaft.

- **Booleans sind ein Tagpaar über denselben Wert.** Der dritte Zustand — nicht gefragt — fällt von
  allein an, beide leer. Die Filter liefern `X` und nicht `☒`: eine Kästchen-Glyphe braucht eine
  Schrift, die sie hat, sonst steht im PDF ein leeres Viereck.
- **Listen sind Schleifen, nie feste Steckplätze.** `family_guardians` kennt weder „Mutter" noch
  „Vater", sondern N Sorgeberechtigte mit einem Verhältnis. **Über wen die Schleife läuft, ist nicht
  die Familie, sondern der Kreis der erwarteten Unterzeichner** — er ist je Sorte verschieden, und
  wer nach seiner Einsichtsstufe nicht zeichnet, bekommt auch keine Zeile im Dokument (08); das Kind
  ab 14 dagegen braucht eine (08, 19). Feste Plätze verschlucken still jemanden, eine Schleife über
  alle Sorgeberechtigten druckt eine leere Zeile für den, der gar nicht erwartet wird.
- **Name, Verhältnis, Bild und Datum sind Felder eines Objekts.** Zwei parallele Listen mit Index
  wären der Weg, auf dem die falsche Unterschrift unter den falschen Namen gerät. Die Sortierung
  muss ausdrücklich sein, damit die Paarung reproduzierbar bleibt.
- **Jeder eingesetzte Wert wird escaped.** Ein `&` oder `<` aus einem Freitextfeld geht sonst roh
  ins Word-XML und macht die Datei ungültig — mitten in einer Freigabe, die daran zurückfällt.
- **Eine Unterlage, eine Datei** (08). Mitgeltende Anlagen werden nicht angeheftet: Sie gelten „in
  ihrer jeweils gültigen Fassung", angeheftet wären sie je Vertrag eingefroren. Welche einem
  Vertrag beiliegen, steht als Zuordnung im System (`schema/querschnitt-schema.sql`,
  `contract_kind_attachments`) — der Vertragstext verweist darauf, statt sie mitzuführen, und eine
  neue Fassung erzeugt von dort aus die Mitteilung an die betroffenen Familien.

## Der Kontext

**Vorab aus einer Deklaration gebaut, nicht bei Bedarf aufgelöst.** Was nicht deklariert ist,
existiert nicht. Dazu `jinja2.StrictUndefined`: Ein unbekannter Name wirft, statt leer zu rendern.

**Die Vorlage ist Leser der Daten, keine Quelle.** Aus ihr wird keine Eingabemaske abgeleitet — die
Felder gibt der Soll-Block vor (`CLAUDE.md`, Rangfolge), und die meisten Platzhalter zeigen auf
längst erhobene Daten. Die Feldliste einer Vorlage wird deshalb nur **gegen** die Deklaration
geprüft, nie aus ihr gewonnen.

**Die Prüfung muss bis in die Unterfelder reichen, und das naheliegende Werkzeug kann das nicht.**
`jinja2.meta.find_undeclared_variables` liefert nur die obersten Namen — gemessen: `{{ kind.nmae }}`
und `{{ gesundheit.hiv }}` erscheinen darin als `kind` und `gesundheit`. Wird die Freigabe nach
Namensräumen geschnitten, prüft ein Torwächter auf dieser Grundlage an Unterfeldern also gar nichts:
Der Tippfehler wirft erst mit `StrictUndefined` im Request der Freigabe, und ein Merkmal, das eine
Sorte nicht sehen darf, kommt durch, solange sein Namensraum freigegeben ist. Entweder sind die
freigegebenen Namen flach, oder die Prüfung läuft über den Syntaxbaum statt über diese Funktion.

**Die Freigabe der Vertragssorten spricht die Sprache, die es schon gibt:** Eine Vorlagensorte
deklariert einen **Sichtkreis**, keine Feldliste — `health_visibility_scopes` und
`health_field_visibility` samt `presence_only` sind gebaut und rollenweise über GRANTs vergeben. Der
strengere Maßstab ist der Leserkreis der Datei, nicht der der Zeile: Ein Feld, das ins Dokument
gerät, ist für jeden Leser dieses Dokumenttyps da.

**Wer den Sichtkreis einer Vertragssorte verbreitern kann, ist nicht dieselbe Person, die ihre
Vorlage schreibt** — sonst zöge sie Daten in ein Dokument, dessen Leserkreis sie selbst nicht
festlegt. Für die **Fahrt** gilt das ausdrücklich nicht: Dort wählt die Lehrkraft Fragensatz und
Leserkreis je Ausflug (`19`), und zwar aus einer bestehenden Feldliste an einen Kreis interner
Mitarbeitender. Die Trennung gilt also je Sorte und nicht als Hausregel; wo ein Block sie aufhebt,
tut er es benannt.

Aus den Daten kommen Werte und Zeilen, aus der Vorlage kommt jeder Satz. `{%p if %}` über denselben
Namensraum ist erwünscht: So schaltet die Geschäftsführung ganze Absätze, ohne dass deren Text im
Code landet.

## Klassen je Sorte

`contract_text_kinds.kind_class` sagt, was aus einer Sorte entsteht — nicht ableitbar, weil die
Anwendung beim Anzeigen wissen muss, ob sie eine Zustimmung festhält:

| Klasse | Beispiele | Was entsteht |
|---|---|---|
| `signed` | Schulvertrag, Betreuungsvertrag, SEPA-Mandat, Fotoeinverständnis | Urkunde je Vorgang, Prüfsumme, Unterschriftszeilen |
| `agreed` | Teilnahmebedingungen (10), Essensbedingungen (11), Stornobedingungen | keine Datei; der Vorgang merkt sich die Fassung. Ihr Wortlaut wird eingegeben, nicht aus einer Vorlage ausgelesen |
| `applies` | Betreuungsordnung, Infektionsschutz, Kleiderordnung, die Regeln zu Putzdienst und Elternmitarbeit — die Liste ist offen | nichts am Kind, keine Frist, keine Unterschrift — es gilt „die jeweils gültige Fassung" (09). Eine geänderte Fassung erreicht die Familie trotzdem: als **Mitteilung** (08) |

Arbeitsfassung und Dokumentart trägt allein `signed`.

**Zwei Sorten Paket, und sie unterscheiden sich an der Frist** (Geschäftsführung, 04.09.2026): Die
einen entstehen **je Kind** aus seinen Daten und gehen mit ihnen — Vertrag, SEPA-Mandat,
Fotoeinverständnis, Gesundheitsblatt. Die anderen sind die **allgemeinen Regeln**, die für alle
gleich gelten — Betreuungsordnung, Infektionsschutz, Kleiderordnung, die Regeln zu Putzdienst und
Elternmitarbeit **und weitere; die Liste ist offen und steht im Vertrag, nicht hier** (`backlog/`).
Sie tragen keine Personendaten, entstehen nicht je Kind und haben deshalb auch keine Frist am Kind;
sie werden **mitgegeben, aber nicht angeheftet** — angeheftet wären sie je Vertrag eingefroren, und
eine geänderte Fassung erreichte niemanden mehr.

**Zwei Sorten passen heute in keine der drei, und das ist keine Feinheit:** Das **Gesundheitsblatt**
(`grenzkarte.md`; TASK-226) ist eine erzeugte Datei ohne eigene Unterschrift — es wird von den
Unterschriften unter dem Vertrag getragen (08). Die **Modulanlage** des Hortvertrags ist
unterschrieben, wird nach jeder Anpassung neu ausgefertigt und bleibt in der Akte (`09`), hat aber
weder `document_id` noch Prüfsumme an `care_module_agreements`. Dazu die **Erklärung zur
Klassenfahrt** (`19`): unterschrieben von allen Sorgeberechtigten und dem Kind, abgelegt in der
Akte — aber ihre Rahmenbedingungen schreibt die Lehrkraft je Fahrt in eigenen Worten, und damit käme
ein Satz aus den Daten statt aus der Vorlage. Solange das offen ist, entsteht für diese Sorten keine
Datei oder eine ohne Anker.

## Rendern: eine Funktion, mehrere Aufrufer

Die Renderfunktion nimmt **Bytes, nicht einen Ort** — es gibt keine zweite Renderstrecke:

| Aufruf | Bytes aus | Daten | Ergebnis |
|---|---|---|---|
| Vorschau der Arbeitsfassung | SharePoint | Beispieldaten | verworfen |
| Ansicht einer geltenden Fassung | Postgres | Beispieldaten | verworfen |
| Ansicht vor der Unterschrift | Postgres | echte Daten, nach Einsichtsstufe | verworfen |
| Ansicht einer geänderten Fassung | Postgres, **zwei** Fassungen | echte Daten, für beide dieselben | verworfen |
| Erzeugung der Urkunde | Postgres | echte Daten | abgelegt, Prüfsumme am Vorgang |

**Der fünfte ist der einzige, der zwei Fassungen zugleich braucht** (`backlog/` TASK-259): Beide
werden mit **denselben** Daten dieser Familie gefüllt, dann verglichen — so heben sich die
Datenunterschiede auf und übrig bleiben genau die Textänderungen, in der Sprache des eigenen
Vertrags statt in Platzhaltern. Was die Familie **bisher unterschrieben hat**, steht dabei nicht in
dieser Tabelle: Das ist die abgelegte Urkunde und kommt aus der Akte, nie aus dem Renderer — siehe
„Was einmal erzeugt ist, wird nicht neu erzeugt" weiter unten.

Der dritte Aufruf ist der, den 08 Z3 verlangt: Die Eltern lesen **das Dokument, das sie
unterschreiben** — nicht eine HTML-Zweitfassung des Texts, die ohne Gültigkeitstag und Prüfsumme
danebenstünde und doppelt gepflegt werden müsste. Der Vertragstext lebt an genau einer Stelle: in
der Word-Datei. `contract_texts.body` ist das nicht — er ist der ausgelesene Fließtext für
Volltextsuche und Fassungsvergleich, ohne Tabellen, Listenebenen und Grafiken.

**Was hinausgeht, ist ein PDF** (Betreiber, 04.09.2026) — an Eltern gibt keine Route eine `.docx`
heraus, auch nicht die Redline einer geänderten Fassung (`backlog/` TASK-259). Die Word-Datei ist
Zwischenprodukt: Sie trägt Platzhalter, ihre Formatierung hängt am Programm des Empfängers, und
Änderungsverfolgungen zeigt Word im Auslieferungszustand nur als Strich am Rand. Im PDF ist beides
festgelegt.

**Jeder dieser Aufrufe ist eine Route mit einer Rolle.** Wer den gefüllten Vertrag ansehen darf, ist
dieselbe Frage wie „wer unterschreibt" und nicht dieselbe wie „wer die Vorlage prüft": Ein
Sorgeberechtigter, dem seine Einsichtsstufe das Zeichnen genommen hat, liest ihn nicht mit
(`api/anmeldung-api.md`, `GET /contracts/{contract_id}/document`). Dieselbe Route liefert nach der
Freigabe die abgelegte Urkunde und rendert nichts mehr.

**„Verworfen" heißt hier wirklich „nie geschrieben".** Der Konverter nimmt **Bytes und gibt Bytes
zurück** (`container.md`): Was verworfen wird, hat nie eine Ablage gesehen. Das ist der Unterschied
zum früheren Weg über Graph, der ein *Element* konvertierte und keinen Rumpf — dort lud jeder
Aufruf die gefüllte `.docx` erst in eine Bibliothek, holte das PDF und entfernte sie wieder, und
das Entfernte lag danach in zwei Papierkörben, ohne Zeile und außerhalb des Lösch-Laufs. Bei der
Ansicht vor der Unterschrift war das ein vollständig gefüllter Vertragsentwurf je Aufruf, beim
Gesundheitsblatt mit Art.-9-Daten. Der Grund für den Umstieg ist damit nicht Bequemlichkeit,
sondern der Wegfall dieses Zwischenstands — dazu die Unabhängigkeit von Microsoft für den
Mechanismus und ein Renderweg, der ohne Tenant lokal läuft (`container.md`, samt Preis und
Messwerten).

**Alle Aufrufe laufen durch denselben Pfad**, samt PDF/UA-Nachbearbeitung: XMP-Metadatenstrom,
korrigiertes `/Lang` (Word schreibt `en`, und veraPDF meldet das nicht — ein Screenreader läse den
deutschen Vertrag sonst mit englischer Stimme), `Scope` an den `TH`-Zellen, Alternativtext an jedes
Bild. Eine Abkürzung für die Ansicht hieße: Die Eltern lesen ein nicht barrierefreies Dokument und
unterschreiben ein barrierefreies. **Die Prüfsumme wird über die Bytes gebildet, die abgelegt
werden** — also hinter der Nachbearbeitung, sonst beschreibt sie eine Datei, die es nicht gibt.

## Was einmal erzeugt ist, wird nicht neu erzeugt

Mit der Gegenzeichnung sind die Signaturbilder abgeräumt. Ein zweiter Rendervorgang lieferte damit
eine Urkunde **ohne Unterschriften**, die aussieht wie ein nie unterschriebener Vertrag. Das ist
eine Ablaufregel, kein `CHECK` — sie gehört in die Schreibschicht, mit einer Gegenprobe daneben, und
sie braucht **zwei** Sperren: gegen den zweiten Lauf bei gesetztem `document_id`, und gegen das
Überschreiben der Datei selbst. Ein Upload mit `conflictBehavior=replace` ersetzt sonst die Urkunde
an Ort und Stelle, und die Zusage aus `grenzkarte.md` hält nicht.

Dasselbe gilt für die Reihenfolge innerhalb der Freigabe: **Was ein Rollback nicht zurücknehmen
kann, geht zuletzt.** Ein über Graph gelöschtes Signaturbild kommt nicht wieder, wenn die
Transaktion danach scheitert — dann steht der Vertrag wieder offen, und seine Bilder sind fort.

## Wie eine neue Vertragsart entsteht

Drei Ebenen, und nur die erste ist wirklich frei von Bau:

- **Eine neue Fassung eines bestehenden Texts** ist eine Handlung der Geschäftsführung:
  Arbeitsfassung bearbeiten, „Fassung anlegen", fertig. Die Prüfung sagt Nein, nicht ein Mensch:
  Feldliste gegen die Freigabe, Probelauf mit Beispieldaten, veraPDF gegen PDF/UA-1 — auf **den
  Bytes, die gerade eingefroren werden**, nie im Vertrauen auf eine Vorschau von vorhin. Wo dieser
  Prüfer läuft, ist offen: veraPDF ist eine Java-Anwendung, und der Stack in `container.md` hat
  keine Laufzeit dafür. Das ist derselbe Punkt, an dem oben der Konverter im Container zur Debatte
  steht — beide Fragen werden zusammen entschieden oder gar nicht.
  Für eine Sorte **ohne** Arbeitsfassung (`agreed`, `applies`) gibt es diesen Weg nicht: Dort ist der
  eingegebene Text die Fassung, es wird nichts geholt, nichts gerendert und nichts geprüft — nur der
  Gültigkeitstag gesetzt.
- **Eine neue Dokumentsorte** ist ein **Griff in der internen Oberfläche**, keine Migration: Sorte,
  Dokumentart und Aktenkategorie entstehen zusammen, dazu die Vorlage. Das folgt `rules.md` §2 —
  organisatorische Werte werden über die Verwaltungsoberfläche gepflegt und erzwingen keinen
  Codetouch. Was heute noch fehlt, steht als Ticket in `backlog/`: die Aktenkategorie an der Sorte
  und der Griff selbst; bis dahin ist auch diese Ebene ein Bau, und die Datei landet im falschen
  Unterordner — nicht mit falscher Frist, die trägt ihr Vorgang, sondern am falschen Platz in der
  Akte.

  **Ein Griff und nicht drei Pflegeseiten.** Drei getrennte Wertelisten-Masken ließen eine halbe
  Sorte zu — eine Sorte ohne Dokumentart, eine Kategorie ohne Bestand. Dieselbe Bauform wie
  `POST /care-contracts`: „Ein Vorgang, eine Route — ein Abbruch nach der Hälfte hinterließe einen
  Zustand, den kein Block kennt" (`api/anmeldung-api.md`).

  **Drei Regeln begrenzen ihn, und jede hat ihre Präzedenz:**
  1. **Was im Anwendungscode verankert ist, erreicht der Griff nicht.** `school_contract`,
     `care_contract`, `sepa_mandate` und `photo_consent` stehen dort; wer sie umbenennt oder
     deaktiviert, bricht die Erzeugung still. Dieselbe Auslassung wie bei `consent_purposes`, wo
     „zwei Zwecke der Werteliste **keine** Route haben" (`api/querschnitt-api.md`).
  2. **Der `code` wandert nie, der `name` schon** — beim Anlegen frei, danach fest. Steht so an
     jeder Werteliste, die eine Verankerung trägt.
  3. **Die Klasse ist fest, sobald das erste Dokument dieser Sorte entstanden ist.** `kind_class`
     entscheidet, *ob* eine Datei entsteht; eine nachträgliche Änderung deutet bestehende Zeilen um.

  **Kein generischer Werteliste-Editor daneben.** `sync_targets`, `consent_purposes` und
  `retention_subjects` tragen Zuständigkeiten und Löschfristen — eine falsche Zeile dort ist eine
  Aufgabe, die niemanden erreicht, oder eine Frist, die nicht abläuft. Der Griff bleibt auf
  Dokumentsorten geschnitten. — Alternative: eine Pflegemaske über alle Wertelisten; Preis: der
  Baukasten unten durch die Hintertür, ohne dass jemand ihn beschlossen hätte.
- **Eine neue Vertragsart** — ein dritter `contract_type` — ist eine Migration: Der CHECK und sieben
  weitere Constraints an `contracts` nennen `school` und `care` wörtlich, weil sie strukturell
  entscheiden, welche Spalten Pflicht sind und wer gegenzeichnet.

**Ein Baukasten, in dem ein Mensch ganze Vertragsprozesse anlegt, wird bewusst nicht gebaut.** Der
Verzicht auf einen Formularbaukasten ist einer der vier Verzichte, mit denen `folgenabschaetzung.md`
die Verhältnismäßigkeit der Art.-9-Verarbeitung begründet; dazu beschreibt der Art.-30-Eintrag *ein*
Verfahren mit bestimmten Datenkategorien. Ein ohne Entwickler angelegter Prozess wäre eine neue
Verarbeitung — zu dokumentieren, nicht zu konfigurieren. Und die Constraints, die heute sagen, was
ein Vorgang haben muss, wären dann Konfiguration: Eine Regel, die erst die Konfiguration setzt, hat
keine Gegenprobe, und ohne die gilt sie als nicht gebaut (`CLAUDE.md`).

Der Bau ist ohnehin nicht das Langsame daran. Eine neue Vertragsart braucht einen Soll-Block, einen
Eintrag im Verarbeitungsverzeichnis und eine Fristantwort des Datenschutzbeauftragten — drei Dinge,
die länger dauern als die Migration.

**Was einen neuen Sichtkreis einführt, öffnet die Folgenabschätzung** — sie verlangt das
ausdrücklich für jede neue Merkmalskategorie, jeden neuen Sichtkreis, jeden neuen Empfänger und jede
geänderte Frist.

## Fristen

**Ein Vorgang erzeugt mehrere Unterlagen, und jede geht mit den Daten, aus denen sie entstand**
(Geschäftsführung, 04.09.2026). Die Datei hat **keine eigene Frist** — das Vertrags-PDF geht mit dem
Vertrag, das Mandat mit dem Mandat, das Gesundheitsblatt mit dem Gesundheitsbestand, und der läuft
kürzer als der Vertrag. Das ist der ganze Grund, aus dem der heutige Sammelvertrag aufgeteilt wird:
Ein Bündel trägt für alles darin die längste Frist, und aus ihm ist nichts einzeln zu löschen.

**Für eine erzeugte Datei ist die Aktenkategorie deshalb der Unterordner und nicht die Uhr.** Sie
geht mit ihrem Vorgang: Der Vertrag hält sein Dokument fest, das Mandat seines, die Zustimmung ihres
— der Lösch-Lauf räumt sie in dieser Reihenfolge, und die Kategorie sagt nur, wohin die Datei kam.
Wer die Frist an der erzeugten Datei ein zweites Mal führte, hätte zwei Uhren für dieselbe Löschung.

**Umgekehrt bei dem, was ein Mensch in die Akte legt:** Zeugnis, Beobachtungsbogen, Schriftwechsel
hängen an keinem Vorgang — für sie ist die Kategorie die einzige Uhr, und genau dafür trägt
`child_file_categories` ihren `retention_subject_id`. Beide Wege enden im selben Bestand; die Frage
ist nur, ob ein Vorgang dazwischensteht.

**Wozu es die Datei dann überhaupt gibt**, wo die Daten ohnehin in der Datenbank stehen: Sie ist die
formatierte Fassung — in der Schülerakte liegt etwas, das man ansehen kann, ohne die Oberfläche zu
bedienen, und die Eltern sehen darin, was sie angegeben haben. Sie ist der Beleg über den Stand, die
Datenbank bleibt die Quelle.

Jede erzeugte Datei hängt an der Frist ihres Bestands, und der Bestand ist nicht immer der des
Kindes: Die Erklärung zur Klassenfahrt rechnet ab dem Ende der Fahrt und nicht ab dem Austritt
(`19`). Welcher Anker für Vertrag und Mandat gilt und wie er beim externen Hortkind läuft, steht in
`08`, `09` und `03` — nicht hier; die beiden Stellen in `09`, die sich darüber widersprechen, sind
dort zu klären.

Die Fassungen selbst haben **keinen Löschanker**: Sie tragen keine Personendaten und überleben jeden
Vertrag, der auf sie zeigt — sie beantworten „welcher Wortlaut galt am 1. September".

**Dass sie wirklich keine tragen, ist eine Prüfung und keine Annahme.** Eine `.docx` führt Autor und
zuletzt ändernde Person in `docProps/core.xml`, dazu möglicherweise Kommentare und
Änderungsverfolgung. Die heutigen Vorlagen im Bau sind unauffällig — gemessen, sie tragen
`python-docx` als Autor und sonst nichts. Die künftige Arbeitsfassung ist dagegen eine in Word
gepflegte Datei, und die trägt einen Namen. **Das Einfrieren räumt die Eigenschaften deshalb ab**;
sonst steht ein Mitarbeitendenname unbefristet in einer Zeile, die bewusst keine Frist hat.

Eine erreichte Fassung wird nie geändert, eine angekündigte schon.
