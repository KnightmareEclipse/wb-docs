# LogaHR — was Weltenbaum von einem Personalsystem braucht

Erste Einschätzung für die Geschäftsführung. Das HR-Tool der Schule wird **LogaHR** (P&I AG),
Einführung voraussichtlich ab Januar 2027. Diese Datei entscheidet drei Dinge: welche
Mitarbeiterangaben Weltenbaum überhaupt führt, in welche Richtung eine Schnittstelle zwischen beiden
liefe, und was LogaHR dafür liefern müsste. Der Bestand selbst steht in
`schema/stammdaten-schema.sql` und [Block 13](soll-prozesse/13-m365-konten.md) — hier steht die
Grenze und der Weg dorthin.

## Die Grenze steht zuerst, und sie ändert sich nicht

Weltenbaum führt je Mitarbeitendem **sechs Angaben** ([13](soll-prozesse/13-m365-konten.md)): Name,
Haus (Schule oder KITA), dienstliche Mailadresse, erster Arbeitstag, letzter Arbeitstag und die
Notiz, an wen die Post künftig geht. Daneben steht die Anmeldeidentität des Schulkontos, und in
einer eigenen Tabelle stehen die **Rollen** — vergeben in Weltenbaum, nicht importiert.

Kein Gehalt, kein Arbeitsvertrag, kein Stundenumfang, kein Urlaub, keine Krankheit, keine
Bewerbungsunterlagen. Die Personalverwaltung heißt so, führt hier aber diese sechs Angaben und keine
siebte.

**Eine Schnittstelle, die mehr liefert, als hier stehen darf, ist keine Erleichterung, sondern ein
Datenschutzproblem.** Sie erzeugt in Weltenbaum einen Bestand ohne Zweck und ohne Rechtsgrundlage
(`rules.md` Abschnitt 7). Gibt LogaHR nur ganze Datensätze aus, wird der Überschuss beim Übernehmen
verworfen und nicht „erst einmal mitgenommen" — ein Feld, das dasteht, wird irgendwann gelesen.

## Der tragende Wert: erster und letzter Arbeitstag

An ihnen hängt in Weltenbaum alles Weitere, und deshalb sind sie der eigentliche Gegenstand jeder
Schnittstellenfrage:

- Mit dem Ablauf des **letzten Arbeitstags enden alle Rollen von selbst**, ohne dass jemand sie
  entzieht. Er ist zugleich der Löschanker des Eintrags. Das ist der Faden, der heute reißt: Es gibt
  keinen Ort, an dem steht, dass jemand aufhört, also bleibt auch nichts sichtbar offen, und Konten
  stehen jahrelang weiter.
- Der **erste Arbeitstag** ist heute freiwillig, weil an ihm nichts hängt. Das ändert sich, sobald
  Weltenbaum das Konto selbst anlegt (TASK-212) — dann sagt er, *wann*.

Ein Personalsystem, das nur diese zwei Daten samt Name und Haus verlässlich hergibt, hat alles
geliefert, was gebraucht wird.

## Was LogaHR an Übergabewegen anbietet

Recherchestand 03.09.2026, öffentlich belegbar — mehr sagt der Hersteller ohne Vertriebsgespräch
nicht:

- **HR-Business Connector**: P&Is eigenes Data-Management-System, das „Fremddaten importiert,
  aufbereitet und zur Nachverarbeitung exportiert". Das ist der benannte Weg für Datei- und
  Batch-Übergaben in beide Richtungen.
- **Eventgesteuerte Architektur**: registrierte Ereignisse mit automatisierter Reaktion. Ob sie von
  außen abonnierbar ist oder nur innerhalb der Suite wirkt, sagt die öffentliche Darstellung nicht.
- **Fremdanbieter-Konnektoren** (IAM-Produkte) lesen und schreiben LOGA bidirektional und
  synchronisieren genau die Felder, um die es hier geht — Name, Abteilung, Funktion, Ein- und
  Austrittsdatum — nach Active Directory und Entra ID; erzeugte Mailadressen und Anmeldenamen
  schreiben sie zurück.
- **Datei-Export** ist der Weg, den Drittsysteme (Zeiterfassung) tatsächlich dokumentieren.

**Eine offene REST-API von P&I ist nicht öffentlich belegt.** Wer sie behauptet, hat sie aus dem
Datenblatt eines Konnektor-Anbieters und nicht von P&I.

`[?]` Welche Übergabewege enthält der Vertrag der Schule — Datei-Export, HR-Business Connector,
API? Und liefert LogaHR den letzten Arbeitstag, sobald er feststeht, oder erst, wenn er abgelaufen
ist? — Geschäftsführung, an den Anbieter weiterzugeben.

Ein fertiges IAM-Produkt als Zwischenstück leistet das Gewünschte sofort, ist aber ein weiterer
Dienstleister mit AVV und laufenden Kosten für ein Signal, das ein paar Mal im Jahr auftritt — es
fällt auf der Leiter durch (`rules.md` Abschnitte 1 und 4).

## Die Richtung

Zwei Richtungen, und sie widersprechen einander nicht:

- **Von LogaHR nach Weltenbaum** das Signal „dieser Mensch kommt" bzw. „dieser Mensch geht", samt
  Name, Haus und den zwei Daten. Mehr nicht.
- **Von Weltenbaum in den Tenant** das Anlegen des Kontos und die Zuordnung zu den Teams. Das ist
  die Richtung, die die Geschäftsführung am 03.09.2026 gesetzt hat, und sie steht mit ihrem Preis
  als eigener Durchgang (TASK-212): Wer Konten anlegen darf, darf den ganzen Tenant umbauen.

Weltenbaum ist damit **nicht** die führende Stelle für Personaldaten und wird es nicht — es ist die
Stelle, an der aus zwei Daten Zugänge und Rollen werden.

`[A]` Die dienstliche Mailadresse wird **nicht** nach LogaHR zurückgeschrieben. — Alternative: sie
zurückschreiben, wie es die IAM-Konnektoren tun. Preis: eine zweite, schreibende Richtung samt ihren
Rechten für eine Angabe, die im Tenant ohnehin steht und dort nachgeschlagen wird.

## Was LogaHR nicht liefern kann

**Die Rolle in Weltenbaum.** Sie ist keine Personalstammdatei-Angabe, sondern eine fachliche
Zuweisung: „Manche Rollen kann nur die Führungskraft beurteilen, nicht das Personalwesen"
(Geschäftsführung, 03.09.2026). Ein HR-System liefert Stellenbezeichnungen, und die sind nicht
dasselbe — vergeben werden Rollen weiter von Admins und Geschäftsführung, als zweiter Handgriff nach
dem Anlegen ([00](soll-prozesse/00-zugang-und-portal.md)).

Liefern **könnte** es die private Mailadresse, über die ein Eintretender vor seinem ersten Tag
erreichbar ist. Gebraucht wird sie nur, wenn er selbst ins Portal kommen soll, und das ist in
TASK-212 noch nicht entschieden.

## Die erste Ausbaustufe ist keine Schnittstelle

Ein- und Austritt trägt heute die Personalverwaltung von Hand ein
([13](soll-prozesse/13-m365-konten.md)). Bei der Zahl der Eintritte an diesem Haus spart ein
automatisierter Weg Minuten und kostet eine Abhängigkeit von einem System, das noch nicht eingeführt
ist. **Erst kommt LogaHR, dann die Frage nach der Schnittstelle** — beantwortbar ist sie ohnehin
erst, wenn feststeht, was im Vertrag enthalten ist.

Was sich sofort lohnt und keine Schnittstelle braucht: beim Anlegen der Bestandsmitarbeitenden
einmal eine Liste aus LogaHR ziehen — Name, Haus, erster und letzter Arbeitstag — statt sie
abzutippen.

## Quellen

- [P&I AG — Ökosystem](https://www.pi-ag.com/okosystem) (HR-Business Connector, eventgesteuerte
  Architektur)
- [Tools4ever — P&I Loga als IAM-Quelle](https://www.tools4ever.com/de/software/iam-identity-and-access-management-software/schnittstellen/pi-loga)
  (bidirektional, Ein-/Austrittsdaten nach Entra ID, Rückschreiben von Adresse und Anmeldename)
- [virtic — Datenexport an P&I LOGA](https://www.virtic.com/funktionen/schnittstellen/p-und-i-loga/)
  (dateibasierte Übergabe aus einem Drittsystem)
