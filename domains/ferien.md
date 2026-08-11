# Ferienanmeldung — Fachdomäne (Ferienprogramm, Kochwerkstatt)

Domäne 3 aus `fachdomaenen.md` Abschnitt 6. Tabellenschema: `domains/ferien-schema.sql`, belegt durch `domains/ferien-schema-check.sql` (Sollstand 9/9). Der heutige Ablauf samt Excel-Spalten steht in `prozesse.md` Abschnitt 10.

Die kleinste der drei gebauten Prozessdomänen — und die mit der unangenehmsten Eigenschaft: **sie legt Personen an, die mit der Schule sonst nichts zu tun haben.**

## Das schulfremde Kind ist der schwierige Fall, nicht der Randfall

Das Ferienprogramm steht ausdrücklich auch Kindern offen, die weder an der Grund- noch an der Realschule sind. Sie bekommen eine vollständige `children`-Zeile samt Familie, anmeldendem Elternteil und Notfallkontakt (`domains/stammdaten.md`, „Familie") — ohne Familienzugehörigkeit gäbe es weder eine Verknüpfung zum anmeldenden Elternteil noch einen OTP-Zugang für ihn.

Daraus folgt das Löschproblem: **`children.exit_date` bleibt bei ihnen dauerhaft leer** und taugt deshalb nicht als Fristanker (`idea/06-dsgvo-organisatorisch.md`). Der Anker ist stattdessen das **Programm**: ist es vorbei und hat das Kind keinen anderen Bezug zur Schule, fällt es mit der Frist der Buchung. Das Prüfskript zeigt beide Richtungen — solange das Programm läuft, ist das Kind kein Kandidat; danach wird es einer. Auch das braucht keine eigene Spalte.

**„Clemens-Kind" wird nicht gespeichert.** Die Frage des heutigen Formulars ist aus dem Stammdaten-Prädikat „eingeschrieben" ableitbar und wäre als Spalte ein zweiter, veraltender Ort.

## Programm und Angebotstag

- Ein **Programm** ist ein konkretes Angebot in einem konkreten Zeitraum — die Herbstferien 2026, nicht „das Ferienprogramm" allgemein. Kochwerkstatt und Ferienprogramm teilen sich die Tabelle, weil sie sich in nichts unterscheiden, was das Schema sieht.
- **Der Anmeldeschluss ist Pflicht**, nicht optional: die Anmeldung wird ausdrücklich vor Programmbeginn geschlossen, weil vorab eingekauft und geplant werden muss — auch dann, wenn rechnerisch noch Platz wäre. Ein Programm ohne Anmeldeschluss gibt es nicht, und das Schema lässt keines zu.
- **Die Kapazität hängt am Tag, nicht am Programm.** Genau so ist sie real formuliert; eine Programmsumme ließe zu, dass alle Kinder am selben Tag erscheinen. Anders als beim Putzdienst ist sie eine harte Obergrenze und kein berechneter Richtwert: es geht um Aufsicht und eingekauftes Material, nicht um gleichmäßige Verteilung.
- Der **Preis je Tag** steht am Programm, die gezahlte Summe an der Zahlung — dieselbe Trennung wie beim Putzdienst: was gezahlt wurde, muss auch dann noch stimmen, wenn der Preis später korrigiert wird.

## Ein Vorgang, mehrere Kinder, mehrere Tage

Der **Anmeldevorgang** ist eine eigene Entität, weil die Zahlung an ihm hängt: bei drei Kindern füllt niemand drei Formulare aus und bezahlt dreimal. Ohne ihn müsste jede einzelne Tagesbuchung ihre eigene Zahlung tragen, und Q3 verlangt genau einen Vorgang je Zahlung.

Die **Buchung** ist dann Kind × Angebotstag × Betreuungsende. Das Betreuungsende (real 14:00 oder 16:00) ist eine Uhrzeit und keine Werteliste — das sind Zeitpunkte, keine benannten Kategorien, und welche Enden ein Tag anbietet, ist Bedienführung.

**Storno setzt einen Zeitpunkt, statt die Zeile zu löschen.** Zwei Gründe: dasselbe Kind darf an einem Tag nur einmal gebucht sein, und eine gelöschte Zeile würde die Wiederanmeldung gegen diese Regel laufen lassen; und die Tageskapazität muss ehrlich rechnen — eine stornierte Buchung darf keinen Platz mehr belegen. Das Prüfskript zeigt genau diese Zählung.

Stornos laufen heute per Mail an den Hort, der seine Excel-Liste von Hand nachzieht. Was daraus finanziell folgt, entscheidet die Buchhaltung außerhalb von Weltenbaum — es gibt hier weder Stornogebühr noch Rückerstattung.

## Was aus Stammdaten kommt und hier nicht steht

- **Die Notfallnummer** ist eine Kontaktverknüpfung in Stammdaten, kein Feld dieser Domäne. Zu beachten: der Kontakt **braucht einen Namen**, sobald er eine dritte Person ist — die heutige Excel-Liste führt dort nur eine nackte Nummer, und ohne Namen scheitert seine `persons`-Zeile.
- **Die Werbe-Einwilligung** ist eine Zustimmung (Q1) und keine Spalte am Vorgang: sie überlebt ihn, ist widerrufbar und wird später wieder geprüft — genau die Eigenschaften, für die Q1 gebaut wurde.
- **Das Fotoeinverständnis** wird bei schulfremden Kindern nachgereicht, ist aber dieselbe Zustimmung (Q1) und dasselbe Dokument (Q2) wie überall sonst.
- **Die Anschrift** steht in Stammdaten und wird nur bei schulfremden Kindern überhaupt erhoben.

Der freie Text des Formulars („Wichtige Notizen", „Bemerkung") steht dagegen **an der Buchung** — eine Notiz zu einem Vorgang, nicht zu einer Person, und damit die eine Sorte Freitext, die in diesem Projekt erlaubt ist (`domains/stammdaten.md`, „Felder").

## Zahlung (Q3)

Die Ferienbuchung ist der **vierte und letzte** der in `domains/grenzkarte.md` benannten Stripe-Anlässe. Damit ist die Liste vollständig: Putzdienst-Komplettfreikauf, Putzdienst-Einzelfreikauf, Anmeldegebühr, Ferienbuchung. Der regulär über Stripe zahlende Elternteil bekommt dabei **keine** `payers`-Zeile — sie hätte keinen einzigen Nutzlast-Wert; eine entsteht nur bei Kostenübernahme durch das Jugendamt.

## Offene Punkte

- Was nach dem Programm mit den Daten schulfremder Kinder geschieht, ist bis heute nicht geregelt (`prozesse.md` Abschnitt 10). Das Schema trägt den Anker, die **Frist** muss die Schulleitung bzw. die/der Datenschutzbeauftragte setzen (`TODO.md`).
- Die Kochwerkstatt läuft heute über die Hausdienstverwaltung und ist nicht im Detail erhoben; sie passt in dieselbe Struktur, solange sich das nicht als falsch herausstellt.
