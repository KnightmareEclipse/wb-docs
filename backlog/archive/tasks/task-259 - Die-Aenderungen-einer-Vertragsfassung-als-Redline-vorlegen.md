---
id: TASK-259
title: Die Aenderungen einer Vertragsfassung als Redline vorlegen
status: To Do
assignee: []
created_date: '2026-09-04 23:17'
labels:
  - backend
  - anmeldung
milestone: m-5
dependencies: []
ordinal: 272000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus dem Gespraech mit der Geschaeftsfuehrung (04.09.2026): Aendert sich der Vertragstext, bekommen die Eltern **den Vertrag mit hervorgehobenen Aenderungen** vorgelegt — nicht eine Zusammenfassung daneben und kein zweites, gepflegtes Aenderungsdokument. Block 08 sah die Vorlage schon vor, ohne zu sagen, wie sie aussieht.

**Was an die Eltern geht, ist immer ein PDF** (Betreiber, 04.09.2026). Die Word-Datei mit den Markierungen ist Zwischenprodukt und verlaesst das Haus nicht.

**Die Kette, lokal am realen Schulvertrag geprueft (30 Seiten, 488 Bloecke):**

1. **Beide Fassungen mit den Daten dieser Familie rendern** (Betreiber, 04.09.2026: "ich haette schon gerne die korrekten Werte im Vertrag enthalten"). Entscheidend ist, dass **beide Seiten denselben Kontext** bekommen: Dann heben sich die Datenunterschiede auf, uebrig bleiben genau die Textaenderungen — und der Vertrag spricht die Familie mit ihrem Namen an statt mit "Ihrem Kind".

   **Damit entsteht der Vergleich je Familie und nicht je Fassungspaar.** Das ist teurer, aber gemessen unkritisch: **237 ms** je Familie bei kleiner Vorlage, rund **0,95 s** beim realen 30-Seiten-Vertrag — davon 0,72 s allein die Konvertierung. Fuenfhundert Vertraege sind damit ein Lauf von etwa acht Minuten, und ein einzelner Aufruf im Portal wartet knapp eine Sekunde. Der Engpass ist die Konvertierung (~1,4 Dokumente je Sekunde, `container.md`), nicht der Vergleich.

   Ein neutraler Kontext ("Ihrem Kind", "die Schule") bleibt der Rueckfallweg, wo es keine Familie gibt — etwa bei der Vorschau einer Arbeitsfassung durch die Geschaeftsfuehrung.
2. **Vergleichen** mit `docx-redline` (PyPI, MPL-2.0, `lxml` + `python-docx` — beides ueber `docxtpl` ohnehin im Stack). Erzeugt echte OOXML-Revisionsmarken. Gemessen: 0,05 s; Grafiken (10), Nummerierung (128) und Tabellen (4) bleiben unversehrt.
3. **Betonen** — den Revisionen zusaetzlich Zeichenformatierung mitgeben, weil Word die Autorenfarbe selbst vergibt und sie blass ist. 0,026 s.
4. **Als PDF rendern** ueber den Konverter im Container (TASK-258). 0,72 s.

Die ganze Kette liegt bei **0,09 bis 0,16 s** plus Konvertierung, auch bei 90 geaenderten Absaetzen — sie skaliert mit dem Dokument, nicht mit der Zahl der Unterschiede.

**Harte Aenderungen tragen**, geprueft: drei gestrichene Absaetze, zwei neue, einer verschoben, eine geloeschte Tabellenzeile — alle korrekt als Revision erkannt, die verschobene als Streichung plus Einfuegung.

## Der Haertetest, und was er gefunden hat

Geprueft am realen Vertrag mit **massiven** Struktureingriffen statt Textkosmetik: eine Tabelle geloescht, eine neue eingefuegt, einer bestehenden eine Spalte angehaengt, zehn Absaetze als Block verschoben, ein Bild aus dem Text entfernt, 120 Formatierungen gebrochen (Fettungen weg, Einrueckungen platt) — und **ein Bild ausgetauscht**.

**Der Vergleich haelt.** 0,07 s, keine Ausnahme, keine Verluste: 10 eingefuegte und 10 geloeschte Absaetze (der verschobene Block), 3 eingefuegte und 2 geloeschte Tabellenzeilen, 35 Einfuegungen und 38 Streichungen. Die Redline traegt 5 Tabellen statt 4 — die geloeschte bleibt als geloescht sichtbar, die neue kommt dazu — und alle 10 Grafiken, auch die entfernte. Das PDF hat 31 Seiten, ist getaggt und traegt `de-DE`.

**Aber ein ausgetauschtes Bild wird nicht erkannt, und das ist der ernste Fund.** Wird `word/media/image1.png` durch ein anderes Bild gleichen Namens ersetzt — ein neues Logo etwa —, zeigt die Redline **das alte**. Nachgemessen ueber die Pruefsummen der Mediendateien: Original `db07c54c`, neue Fassung `b73154f4`, Redline `db07c54c`. Der Vergleich arbeitet auf Text und Struktur, nicht auf Medieninhalten; der Tausch verschwindet **still**, und die Redline sieht an dieser Stelle aus wie die alte Fassung.

**Die Abhilfe ist eine Gegenprobe, kein Umbau:** Vor dem Vergleich die Pruefsummen der Mediendateien beider Fassungen halten. Weichen sie ab, faellt das auf, bevor jemand eine Redline verschickt, die ein altes Logo zeigt. Dasselbe Muster wie ueberall sonst — laut scheitern statt still verlieren.

**Verworfen, mit Preis:** ein Vergleich auf `contract_texts.body`. Der Rohtext fuehrt **keine Tabellen** — eine Schulgelderhoehung waere darin unsichtbar gewesen. Ebenso verworfen: Docxodus/`python-redlines` (gleichwertiges Ergebnis, aber 70 MB Fremdbinary und 4,2 s statt 0,05 s) und `docx-revisions` (kann bestehende Revisionen lesen, aber nicht vergleichen).

## Wo dieses Ticket aufhoert

**Die Redline ist eine Ansicht und kein Vorgang.** Was danach kommt — vorlegen, zeichnen, abschliessen — ist TASK-234 (Routen fuer den Nachtrag); wen die Vorlage erreicht und wann der erste Durchgang laeuft, ist TASK-126. Dieses Ticket liefert das Blatt, nicht die Strecke.

**Unterschrieben wird nur, wo die Fassung Zustimmung verlangt** (`contract_texts.requires_consent`, 08): dann von **allen** Sorgeberechtigten, und es entsteht ein Nachtrag als Urkunde. Sonst genuegt die Kenntnisnahme. Die Redline sieht in beiden Faellen gleich aus — sie zeigt, was sich aendert, und sagt nichts darueber, was zu tun ist.

**Das SEPA-Mandat bleibt dabei unberuehrt** (Betreiber, 05.09.2026): Ein Nachtrag zum Vertragstext erneuert es nicht. Sein Wortlaut kommt von der Bank und haengt an keiner Vertragsfassung; ein neues Mandat entsteht nur, wenn die Familie ihre Bankverbindung aendert — und dann ersetzt es das alte, statt es zu aendern (09).

## Drei Ansichten, und nur zwei werden gerendert

Die Eltern sollen ihre bisherige Fassung, die Aenderungen und die neue Fassung sehen koennen — alle drei als PDF. Sie entstehen aber nicht auf demselben Weg:

| Ansicht | Herkunft |
|---|---|
| **Was ich unterschrieben habe** | die **abgelegte Urkunde** aus der Schuelerakte, unveraendert ausgeliefert |
| **Was sich aendert** | Redline, je Familie erzeugt, danach verworfen |
| **Die neue Fassung** | gerendert mit ihren Daten, danach verworfen |

**Die erste wird nicht neu gerendert, und das ist keine Sparsamkeit.** `dokumente.md` haelt fest: Mit der Gegenzeichnung sind die Signaturbilder abgeraeumt — ein zweiter Rendervorgang lieferte eine Urkunde **ohne Unterschriften**, die aussieht wie ein nie unterschriebener Vertrag. Die bisherige Fassung kommt deshalb aus der Ablage und nie aus dem Renderer.

**Der Empfaengerkreis folgt aus dem Bestand und braucht keine Regel:** `contracts.contract_text_id` traegt die Fassung, die beim Abschluss galt, `contract_amendments.contract_text_id` jede seither bestaetigte. Betroffen ist, wessen juengste bestaetigte Fassung aelter ist als die neue — wer ab dem 1. August unterschreibt, faellt von selbst heraus. Die Faustregel "ausser Jahrgang 1 und 5" waere sogar falsch: Wer im Januar zusagt und im August anfaengt, traegt die Januar-Fassung und gehoert in den Lauf.

## Offen: wie die Aenderungen sichtbar sind

**Das ist die eine Entscheidung, die dieses Ticket nicht selbst trifft.** Gemessen ist, dass jeder der Wege funktioniert und die Farben unveraendert im PDF ankommen (am Pixel nachgeprueft); was fehlt, ist die Wahl.

**Erstens der Mechanismus.** Word kennt zwei Wege fuer einen farbigen Hintergrund, und sie koennen Verschiedenes:

| | `w:highlight` (Textmarker) | `w:shd` (Schattierung) |
|---|---|---|
| Farben | nur 16 feste Namen | beliebiger RGB-Hexwert |
| Wirkung | knallig, wie ein echter Marker | flaechig, fein abstufbar |
| in Word | als Hervorhebung erkennbar, mit einem Griff entfernbar | Zeichenformatierung, bleibt beim Annehmen kleben |

Fuer ein Dokument, das nur vorgelegt und gelesen wird, spielt der letzte Unterschied keine Rolle. Er spielt eine, sobald aus einer Fassung die naechste Arbeitsfassung entstehen soll.

**Zweitens die Farben selbst.** Drei Varianten liegen vor: kraeftig (gruen/rot hinterlegt), gelb (beides gelb, Gestrichenes grau), und freie Werte ueber `w:shd`. Die Textfarbe (`w:color`) nimmt in jedem Fall freie Hexwerte.

**Drittens, wo die Wahl steht.** Heute ist es eine Tabelle im Code, eine Zeile je Variante. Ein Wert im System wuerde sie erst, wenn die Geschaeftsfuehrung sie selbst aendern koennen soll — danach hat bisher niemand gefragt, und eine Farbe, die einmal festgelegt und nie wieder angefasst wird, waere Vorsorge ohne Anlass.

**Was dabei nicht mehr zur Frage steht:** ob die Markierungen ueberhaupt ankommen. Weil an die Eltern ein PDF geht und keine `.docx`, ist die Formatierung eingebrannt — die Word-Einstellung "Simple Markup", die beim Empfaenger sonst alles verstecken kann, greift nicht.

**Haengt an TASK-263:** Der Vergleich braucht die Fassung als `.docx` in `template_docx`. Solange der Code sie als Fliesstext aus `body` rendert, gibt es nichts zu vergleichen, das Tabellen und Nummerierung traegt.

**Reifegrad, ehrlich:** `docx-redline` ist Version 1.0.2 vom 02.09.2026 und als Beta gekennzeichnet. Das ist das Risiko dieses Wegs; die Alternative Docxodus ist reifer, aber schwerer und langsamer.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Im Ergebnis steht kein Platzhalter und der richtige Name — als Gegenprobe
- [ ] #2 Der Vergleich wird mit den Daten der Familie erzeugt — beide Fassungen mit demselben Kontext, damit nur Textaenderungen uebrig bleiben
- [ ] #3 Grafiken, Nummerierung und Tabellen ueberstehen den Vergleich unveraendert — als Gegenprobe am realen Vertrag
- [ ] #4 Gestrichene, neue und verschobene Absaetze sowie geloeschte Tabellenzeilen werden als Revision erkannt
- [ ] #5 Was an die Eltern geht, ist ein PDF; die .docx verlaesst das Haus nicht
- [ ] #6 Der Empfaengerkreis folgt aus der Fassung am Vertrag und aus den bestaetigten Nachtraegen — keine Jahrgangsregel
- [ ] #8 Die bisherige Fassung kommt als abgelegte Urkunde aus der Akte und wird nie neu gerendert — sonst fehlten die Unterschriften
- [ ] #9 Ein ausgetauschtes Bild faellt auf: Die Pruefsummen der Mediendateien beider Fassungen werden vor dem Vergleich gehalten, Abweichung haelt an — als Gegenprobe
- [ ] #7 OFFEN: entschieden, wie die Aenderungen sichtbar sind — Mechanismus und Farben (siehe Beschreibung)
<!-- AC:END -->
