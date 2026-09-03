# 18. DSGVO-Auskunft

## Auslöser

Eine betroffene Person verlangt Auskunft nach Art. 15 DSGVO: Sorgeberechtigte für sich und ihr
Kind, ein Kind selbst `[?]` ab welchem Alter es allein antwortet, statt über die Sorgeberechtigten
— Schulleitung und Datenschutzbeauftragte, oder Mitarbeitende für die eigenen Daten. Jederzeit,
formlos, per Anruf oder Mail ans Sekretariat.

Einen Auskunfts-Knopf im Portal gibt es nicht: Der Vorgang ist selten und braucht Identitätsprüfung
und Urteilsvermögen, also genau die Ausnahme, die nicht automatisiert wird.

## Beteiligte

Die anfragende Person handelt nicht im System. Das Sekretariat prüft Identität und stellt
zusammen; bei Mitarbeitenden-Anfragen zieht es Admin oder Geschäftsführung für den M365- und
Employees-Anteil hinzu, ohne dass dafür eine eigene Zuständigkeit entsteht. Bei Zweifel an Umfang
oder Identität zieht das Sekretariat Schulleitung bzw. Datenschutzbeauftragte:n hinzu.

Ausgelesen wird der gesamte Bestand zur Person über `persons.person_id` bzw. `children.child_id`,
unabhängig von der [sparsamen Ansicht](hebel.md#sparsame-ansicht) — eine Auskunft zeigt immer
alles.

## Ablauf

| # | wer | tut was | danach steht fest |
|---|---|---|---|
| 1 | Sekretariat | Nimmt die Anfrage entgegen, prüft die Identität über die bekannte Kontaktadresse — bei Zweifel wird ein Ausweis verlangt — und trägt Anfrage- sowie Fristdatum ein | dass die anfragende Person echt ist, und ab wann die Frist läuft |
| 2 | Sekretariat, ggf. Admin | Stellt den Weltenbaum-Bestand zusammen und ergänzt ihn um die Schülerakte (SharePoint) sowie, soweit die Person dort geführt wird, ASV-BW, Optigem und M365 | die vollständige Auskunft, nicht nur der Weltenbaum-Ausschnitt |
| 2a | Hortleitung | Steuert die **Hortakte** bei, wenn das Kind eine hat ([09](09-hortvertrag.md)): Das Sekretariat sieht sie nicht und kann sie nicht selbst holen, es fordert sie als [Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail) an. Sie gehört zur Auskunft — sie enthält eine Bewertung, und genau die dürfen Eltern sehen | dass auch der Bestand des Horts in der Auskunft steht |
| 3 | Sekretariat | Schickt die Auskunft, trägt das Antwortdatum ein | dass die Frist eingehalten wurde, belegt |

## Was dabei erhoben wird

Je Anfrage: wer, wann, wofür (Kind oder Mitarbeitende:r), wann beantwortet (Pflicht) — als Beleg
der Rechenschaftspflicht (Art. 5 Abs. 2 DSGVO), kein eigener Bestand über die Person hinaus.
Sichtbar für Sekretariat, Schulleitung, Geschäftsführung.

## Entscheidungen

Ob eine Anfrage eine förmliche Auskunft ist oder eine einfache Korrektur, die in
[02](02-datenaenderung.md) läuft, entscheidet das Sekretariat, im Zweifel mit Schulleitung bzw.
Datenschutzbeauftragte:r.

## Fristen und Termine

Ein Monat ab Eingang (Art. 12 Abs. 3 DSGVO), bei Umfang verlängerbar um zwei weitere Monate mit
begründeter Zwischennachricht innerhalb des ersten Monats. Verstreicht die Frist, ist das eine
meldepflichtige Verletzung — kein Mechanismus dahinter, das Sekretariat trägt die Frist wie jede
andere harte.

## Mails und Schreiben

Die Auskunft selbst, einmalig, mit dem gesamten Bestand; bei Verlängerung zusätzlich die
Zwischennachricht. Sonst keine.

## Dateien

Der Anfragen-Log (wer, wann, wofür, beantwortet wann). Die verschickte Auskunft selbst wird nicht
gesondert abgelegt — sie ist aus dem gespeicherten Bestand jederzeit neu erzeugbar.

**Weltenbaum sagt nur, wo es Dateien gibt** — welche Unterlagen zu dieser Person liegen und in
welcher Akte. Das Herausholen und die endgültige Zusammenstellung macht ein Mensch, wie Schritt 2 es
beschreibt; es gibt dafür keinen Knopf und keinen Export. Damit ist auch der **Versionsverlauf** eines
fortgeschriebenen Dokuments — die Hortakte ist eines ([09](09-hortvertrag.md)) — keine Frage an das
System: Er gehört zum Bestand (`grenzkarte.md`, Q2), und wer die Akte herausgibt, entscheidet beim
Zusammenstellen, was davon mitgeht.

## Sonderfälle

Endet der Zugang der anfragenden Person bereits, ändert das am Ablauf nichts: Der Kanal war immer
Anruf oder Mail ([03](03-irregulaerer-abgang.md)). Der
[offizielle Umweg](hebel.md#der-offizielle-umweg) gilt hier nicht gesondert — es gibt keine Sperre,
die zu umgehen wäre.

## Was heute schiefgeht

Herausgegeben wird bisher nur die Schülerakte aus SharePoint; was in Excel-Listen liegt, kennt
niemand vollständig, der Datenbankbestand ist gar nicht einsammelbar. Mit Weltenbaum ist der eigene
Bestand erstmals in einem Zugriff zusammenstellbar.

## Fremdsysteme

Sekretariat prüft ergänzend ASV-BW, Optigem, SharePoint, M365 — Weltenbaum deckt nur den eigenen
Bestand ab und ersetzt sie nicht (`repos.md`).

## Löschen

Der Anfragen-Log folgt keiner eigenen Frist aus diesem Block. `[?]` Wie lange er als
Rechenschafts-Beleg steht — Datenschutzbeauftragte, gehört in den Lösch-Lauf (17). Die
Personendaten selbst folgen unverändert ihrer eigenen Löschfrist (17); eine Auskunft verlängert sie
nicht.

## Gehört nicht dazu

- Berichtigung falscher Angaben: [02](02-datenaenderung.md).
- Löschung: (17).
- Datenübertragbarkeit (Art. 20) und Widerspruch (Art. 21): heute keine erkennbare automatisierte
  Verarbeitung, die sie auslöst.
- Auskunft an Dritte (Jugendamt, Polizei, Gericht): andere Rechtsgrundlage, kein Auskunftsrecht der
  betroffenen Person, läuft außerhalb.
