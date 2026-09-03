# Folgenabschätzung nach Art. 35 DSGVO — Gesundheitsangaben

Die Bewertung zu **einem** Ausschnitt des Verfahrens: dem Bestand nach Art. 9, den Weltenbaum je
Kind führt. Beschrieben ist das Verfahren in `verarbeitungsverzeichnis.md` — Zwecke,
Datenkategorien, Empfänger, Fristen und Maßnahmen stehen dort und **werden hier nicht wiederholt**.
Diese Datei tut das, was der Art.-30-Eintrag nicht tut: Sie benennt, was den betroffenen Personen
passieren kann, und was dagegen steht.

Geschrieben vom Betreiber, **gegengelesen vom Datenschutzbeauftragten**.

`[?]` Gegenlesen und schriftlich bestätigen, dass die Bewertung trägt und keine Konsultation nach
Art. 36 nötig ist — Datenschutzbeauftragte:r.

## Warum sie fällig ist

Art. 35 Abs. 3 lit. b: umfangreiche Verarbeitung besonderer Kategorien. Der Gesundheitsbestand
entsteht **je Kind und für jedes Kind**, nicht im Einzelfall. Zwei Umstände verschärfen das, und
beide stehen in ErwG 75: Die betroffenen Personen sind **Kinder**, und sie können der Verarbeitung
nicht ausweichen, ohne die Schule zu verlassen.

**Der Rest des Verfahrens löst sie nicht aus.** Stammdaten, Putzdienst, Mensa, Rechnungsfreigabe,
Elternbonus und die Anmeldekette tragen keine besondere Kategorie und keine Bewertung eines
Menschen; sie dürfen vor dieser Folgenabschätzung produktiv gehen. Die Bewertung von
Entwicklungsstand und Verhalten in der **Hortakte** (`grenzkarte.md`, Q2) fällt dagegen darunter und
ist unten mitbewertet.

## Woran ihre Fälligkeit hängt

**Kein Kalendertag, sondern ein Zustand:** Kein Vorgang, der Gesundheitsangaben erhebt oder
freigibt, geht produktiv, bevor diese Datei steht und der Datenschutzbeauftragte sie bestätigt hat.
Das sind fünf — Schulvertrag ([08](soll-prozesse/08-schulvertrag.md)), Hortvertrag
([09](soll-prozesse/09-hortvertrag.md)), Ferienbuchung
([10](soll-prozesse/10-ferienprogramm.md)), Ausflug und Fahrt
([19](soll-prozesse/19-ausfluege-und-fahrten.md)) und Akademie ([21](soll-prozesse/21-akademie.md)).

Damit ist die Frage der Schule nach einer Deadline beantwortet, ohne eine zu erfinden: Der früheste
dieser fünf setzt sie. Ein Termin, der vor dem Stand der Entwicklung liegt, wäre keine Zusage,
sondern ein Datum.

## a) Beschreibung der Verarbeitung (Art. 35 Abs. 7 lit. a)

Der Verweis, nicht die Wiederholung: `verarbeitungsverzeichnis.md` für Zweck, Rechtsgrundlage,
Empfänger und Frist, `schema/gesundheit-schema.sql` für den Aufbau des Bestands und
`api/gesundheit-api.md` für die Wege, auf denen er gelesen wird.

Für die Bewertung tragen drei Eigenschaften, und nur sie:

- **Ein Bestand je Kind, nicht je Vertrag.** Wer ihn hat, gibt ihn für den nächsten Anlass frei,
  statt ihn erneut zu erheben — es gibt also keine zweite, veraltete Fassung derselben Angabe.
- **Die Sichtbarkeit läuft quer zur Angabe.** Eine chronische Erkrankung trägt Bezeichnung,
  Handlungshinweis, Attest und Zeitraum; der Sportunterricht sieht davon den Handlungshinweis und
  nicht die Bezeichnung. Das ist der Kern des Modells und zugleich der Ort jedes Risikos unten.
- **Der Notfall bricht die Sicht auf.** Wer eine Notfalleinsicht auslöst, sieht den vollen Satz
  eines Kindes, ohne dass ihn jemand freigibt.

## b) Notwendigkeit und Verhältnismäßigkeit (Art. 35 Abs. 7 lit. b)

**Notwendig** ist der Bestand, weil die Alternative bereits läuft und nachweislich versagt: Die
Angaben liegen heute auf sechs Formularen im Sekretariat (`prozesse.md`). Eine Lehrkraft auf einem
Ausflug erreicht sie dort nicht, und die Küche kocht gegen eine Liste, die niemand nachzieht. Der
Zweck ist nicht Verwaltung, sondern Handlungsfähigkeit im Alltag und im Notfall.

**Verhältnismäßig** ist er über vier Verzichte, die je an ihrer Stelle begründet sind und hier nur
als Bilanz stehen:

- Keine Diagnose an die unterrichtende Person, sondern der Handlungshinweis, den die Klassenlehrkraft
  daraus formuliert (`glossar.md`).
- **Keine Kopie des Masernnachweises** — festgehalten wird, dass und wie er vorgelegt wurde
  (`schema/gesundheit-schema.sql`).
- Kein Formularbaukasten und kein Feld auf Verdacht: Eine Kategorie entsteht als Datensatz, wenn ein
  Fall dafür vorliegt (`rules.md` Abschnitt 1).
- Die Küche liest einen eigenen, engeren Ausschnitt und nie den Art.-9-Bestand selbst
  (`api/mensa-api.md`).

**Die Freiwilligkeit ist der wunde Punkt und wird nicht schöngeredet.** Rechtsgrundlage der Merkmale
ist die Einwilligung (Art. 9 Abs. 2 lit. a) in einem Verhältnis, in dem die Eltern der Schule nicht
auf Augenhöhe gegenüberstehen. Getragen wird sie durch drei Eigenschaften: Die Angabe ist keine
Bedingung des Vertragsschlusses, das Ausbleiben einer Antwort ist von einer Ablehnung
unterscheidbar (`grenzkarte.md`, „Drei Zustände"), und der Widerruf ist jederzeit möglich. Der Preis
der Ablehnung wird benannt statt sanktioniert: Wer nichts angibt, über den weiß im Notfall niemand
etwas.

## c) Risiken und Abhilfen (Art. 35 Abs. 7 lit. c und d)

Neun, jedes mit seiner Abhilfe und deren Stand. **Was hier als Ticket steht, ist offen und gehört
damit zur Sperre oben** — die Abhilfe muss vor dem Livegang stehen, nicht die Absicht.

**R1 — Ein Merkmal erreicht die falsche Rolle im Kollegium.** Ein Kind wird über eine Diagnose
bekannt, die nur eine Person kennen musste; das trifft es sozial und ist nicht rückholbar.
*Abhilfe:* Der Sichtkreis hängt am Feld, nicht am Menschen (`health_field_visibility`, gebaut), und
er wird **in der Datenbank durchgesetzt** statt in der Antwort gefiltert — solange eine Rolle die
Zeile lesen darf, hilft kein Filter davor (TASK-157, offen).

**R2 — Die Notfalleinsicht wird zur Abkürzung.** Wer den vollen Satz sehen will, aber nicht darf,
klickt „Notfall". *Abhilfe:* Jede Einsicht wird protokolliert (`health_emergency_accesses`, gebaut);
das Protokoll geht mit dem Kind und nicht mit dem Zugriff, ein Vorfall bleibt also über Jahre
zuordenbar. Verhindert wird die Einsicht nicht — sie ist der Zweck des Bestands.
`[?]` Wie lange das Protokoll aufbewahrt wird — Datenschutzbeauftragte:r.

**R3 — Eine Freigabe für einen Anlass wirkt für alle.** Wer für einen Ausflug freigibt, gibt nicht
für den Alltag frei. *Abhilfe:* Die Freigabe gilt je Angabe und je Instanz, mit der Auflage, dass
sie sich in einer Handlung erteilen lässt (TASK-205, offen).

**R4 — Eine Angabe überlebt ihren Anlass.** Die Allergie, die für eine Fahrt erhoben wurde, steht
drei Jahre später noch im Alltagsbestand. *Abhilfe:* Erhebungsanlass mit Zweckende und Löschtermin je
Angabe (TASK-162, offen), dazu die Fristen im Art.-30-Eintrag und der laufende Lösch-Lauf mit
Vorwarnung und Einspruch (`soll-prozesse/hebel.md`, Block 17 als TASK-007 offen).

**R5 — Das Attest verlässt die Rechtegrenze der Datenbank.** Als Datei liegt es in SharePoint, wo
Sekretariat und Geschäftsführung Direktzugriff haben und Papierkorb und Versionsverlauf eine
Löschung überleben. *Abhilfe:* Der Sichtkreis sieht, **dass** ein Attest vorliegt, nicht die Datei
(TASK-206, offen); der Lösch-Lauf nimmt Papierkorb und Versionsverlauf mit (TASK-183, offen); die
Bibliotheksgrenze ist die Zugriffsgrenze (`grenzkarte.md`, Q2).

**R6 — Die Hortakte enthält eine Bewertung.** Absprachen, Verhalten und Beobachtungsbögen sind
ungenauer und folgenreicher als ein Merkmal, und ein Kind wächst aus ihnen heraus. *Abhilfe:* eigene
Bibliothek, gelesen allein vom Hort — auch das Sekretariat kommt nicht hinein (`grenzkarte.md`, Q2;
[09](soll-prozesse/09-hortvertrag.md)). Der Informationsaustausch zwischen Hort und Schule über den
Entwicklungsstand ist eine eigene Einwilligung und keine Nebenwirkung des Hortvertrags.

**R7 — Ein Einmalcode erreicht die falsche Person.** Wer den Code bekommt, sieht den Bestand der
Kinder dieser Familie. *Abhilfe:* Der Zugriff hängt an der Familie, die das Sekretariat von Hand
pflegt und nie ein Algorithmus herleitet (`glossar.md`); der Code geht an die hinterlegte Adresse und
verfällt nach 24 Stunden (`schema/stammdaten-schema.sql`); eine unzustellbare Mail läuft in einen
benannten Ablauf statt ins Leere (`soll-prozesse/hebel.md`).

**R8 — Der Bestand ist im Notfall nicht abrufbar.** Das ist ein Risiko für das Kind und nicht nur
für den Betrieb: Ein Notfallmedikament, das niemand nachschlagen kann, ist nicht vorhanden.
*Abhilfe:* der Störungsteil in `runbook.md`; die Klassenliste ist eine frisch erzeugte Liste und
damit ausdruckbar; die Notfallnummern liegen zusätzlich in der Telefonanlage (TASK-189, offen).

**R9 — Wer Root hat, sieht alles.** Kein technischer Mechanismus auf einer einzelnen VPS ändert
das. *Abhilfe:* keine — das ist die **Vertrauensgrenze** (`rules.md` Abschnitt 2), getragen von
Bus-Faktor- und Offboarding-Regeln, einem Credential je Person und der AVV mit Hetzner. Als
akzeptiertes Risiko benannt, nicht als gelöstes.

## Restrisiko und Ergebnis

Nach diesen Abhilfen bleibt kein Risiko, das für die betroffenen Personen ein **hohes** wäre:
R9 liegt innerhalb der Vertrauensgrenze und ist mit ihr abgewogen, R2 ist der bewusst offen
gelassene Weg, den der Zweck des Bestands verlangt, und R8 ist eine Verfügbarkeitsfrage mit
Papierausweg. **Eine vorherige Konsultation der Aufsichtsbehörde nach Art. 36 Abs. 1 ist damit nicht
erforderlich** — vorbehaltlich der Gegenzeichnung oben.

Der offene Punkt ist kein Restrisiko, sondern eine Bedingung: **Sechs der neun Abhilfen sind
Tickets.** Solange sie offen sind, ist die Sperre oben keine Formalie.

## Standpunkt der betroffenen Personen (Art. 35 Abs. 9)

`[A]` Der Standpunkt wird nicht gesondert eingeholt; die Vertragstexte und Formulare, aus denen die
Erhebung hervorgeht, gehen ohnehin an alle Eltern. — Alternative: den Elternbeirat einmal zum
Modell befragen. Preis: ein Termin und eine Rückfragerunde vor dem Livegang, dafür ein belegter
Standpunkt statt einer Begründung, warum keiner eingeholt wurde.

## Wann sie neu bewertet wird

An einem Ereignis, nicht an einem Datum: eine neue Merkmalskategorie, ein neuer Sichtkreis, ein
neuer Empfänger, eine geänderte Frist — oder eine Notfalleinsicht, die sich als Missbrauch
herausstellt. Wer eines davon ändert, öffnet diese Datei; wer sie nicht öffnen muss, hat nichts
geändert, das sie berührt.
