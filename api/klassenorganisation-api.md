# Klassenorganisation — Routen

Aus [`16-elternvertretung.md`](../soll-prozesse/16-elternvertretung.md); es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht. **Geplant ist hier
die Elternvertretung und sonst nichts** — Klassenlehrkraft und Raum stehen in den Stammdaten
(`schema/stammdaten-schema.sql`), und ein Gremium über der Klasse gibt es nicht.

**Die Domäne trägt inzwischen mehr als eine Tabelle.** Zur Elternvertretung sind die zweite Achse
der Sichtbarkeit — Unterrichtsverteilung, Wahlmodul samt Gruppe und Mitgliedschaft — und das
Unterrichtsende je Klasse und Wochentag gekommen (`schema/klassenorganisation-schema.sql`, aus
[15](../soll-prozesse/15-klassenbildung.md)). **Routen haben sie noch keine:** Sie entstehen in
einem eigenen Durchgang, und der beginnt erst mit dem grünen Prüfbericht zum Schema. Bis dahin
gilt alles Folgende für `class_representatives`.

**Gegenprobe** (Elternvertretung): Die Ablauftabelle von 16 hat **2 Zeilen**; beide handeln im
System und beide tragen eine Route. Es gibt **4 Routen**; **2** nennen eine Ablaufzeile, **2** einen
Abschnitt des Blocks. Keine Abweichung.

## Die Regel, aus der die vier Routen folgen

**Das Amt ist ein Eintrag, kein Vorgang.** Kein Wahltag, kein Protokoll, keine Stimmenzahl, kein
Amtstitel, keine Höchstzahl — „mehr nicht". Daraus folgt jede Einschränkung unten, und was hier
fehlt, fehlt mit Absicht:

- **Kein Ende und keine Frist.** Das Amt „beginnt mit dem Eintrag und endet am 31. Juli von selbst,
  weil es am Schuljahr hängt und nicht weil ein Lauf es beendet". Es gibt deshalb keine Route, die
  ein Amt beendet — nur eine, die es **austrägt**.
- **Keine Prüfung, ob die Person noch ein Kind in dieser Klasse hat.** Weder beim Eintragen noch
  danach: „Wechselt ein Kind die Klasse oder geht es ab, endet das Amt nicht von selbst." Wer es
  beenden will, trägt aus.
- **Kein Schuljahr im Rumpf.** Es ist das laufende, gerechnet zum Zeitpunkt des Eintrags —
  „wer im Mai nachrückt, ist Vertreter dieses Schuljahres wie jeder andere". — Alternative: das Jahr
  mitgeben; Preis: ein Feld, das nur falsch ausgefüllt werden kann, für einen Fall, den der Block
  nicht kennt.

## Enge Rolle

**Keine.** Klasse, Schuljahr und eine Person — kein Art.-9-Feld, keine Bankverbindung. Die
Mailadressen der Vertretungsliste sind `persons.email` und stehen hinter keiner engeren Rolle; was
sie schützt, ist die Route, die sie liefert (unten), und nicht ein GRANT.

## Pfad

Eintragen und sehen hängen unter der Klasse (`/classes/{class_id}/representatives`), weil das Amt an
ihr hängt — denselben Anker trägt `GET /classes/{class_id}/roster`
([`stammdaten-api.md`](stammdaten-api.md)). Ausgetragen wird über die Kennung des Eintrags, nicht
über Klasse und Person: Die Zeile ist das Amt, und der Aufrufer hat sie gerade gelesen. Die
Jahresliste steht ohne Anker unter `/class-representatives`, weil sie keiner Klasse gehört.

## Die vier Routen

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /classes/{class_id}/representatives` — eine gewählte Person an dieser Klasse eintragen | [16](../soll-prozesse/16-elternvertretung.md) Z1 | die Klassenlehrkraft dieser Klasse; `secretariat`, `school_management` | **Klassenlehrkraft heißt hier `classes.class_teacher_id`, nicht die Rolle `teacher`** — derselbe Ownership-Check wie in [`gesundheit-api.md`](gesundheit-api.md), und „die zweite Handlung, die aus der Klassenführung folgt und nicht aus der Rolle". Schulleitung nur ihre eigene Schulart. Eingetragen wird eine **sorgeberechtigte Person aus dem Bestand** — die Route nimmt eine `person_id` und keinen Namen; dass sie sorgeberechtigt ist, prüft sie gegen `family_guardians`, denn `fk_class_representatives_person` zeigt auf `persons` und ließe jede Person durch. Eine je Aufruf: „so viele, wie gewählt wurden" ist eine Menge von Aufrufen, keine Massenoperation ([`gemeinsam.md`](gemeinsam.md#schreiben)). Dieselbe Person zweimal an derselben Klasse und im selben Jahr weist `uq_class_representatives` ab; **in zwei Klassen ist ausdrücklich erlaubt** | schreibt, `entra:` | — |
| `DELETE /class-representatives/{class_representative_id}` — austragen, wer zurücktritt | [16](../soll-prozesse/16-elternvertretung.md) Z2 | wie oben | **Die Zeile geht weg, sie bekommt kein Ende** — das Schema trägt kein Datumsfeld, und wer im Amt war, steht in der [Änderungsspur](../soll-prozesse/hebel.md#änderungsspur). Nachrücken ist kein eigener Weg, sondern die Zeile darüber. Kein Zustand hindert das Austragen: Es gibt keinen | schreibt, `entra:` | — |
| `GET /classes/{class_id}/representatives` — wer in diesem Schuljahr für diese Klasse spricht: **Namen, kein Kontaktweg** | [16](../soll-prozesse/16-elternvertretung.md) „Was dabei erhoben wird" | `teacher`, `secretariat`, `school_management`, `executive_management`; Erziehungsberechtigte | Lehrkräfte unbeschränkt, wie bei der Klassenliste; Schulleitung ihre Schulart; **Eltern nur die Klasse eines eigenen Kindes** (`children.class_id` über die Familien des Tokens). **Diese Route trägt nie eine Adresse und nie eine Telefonnummer, für niemanden** — „das System verteilt keine Elternadressen an Eltern", und der sicherste Ort für diese Zusage ist die Route und nicht eine Fallunterscheidung nach Rolle. Wer die Adressen braucht, ruft die Zeile darunter | liest | — |
| `GET /class-representatives?school_year=` — die **Vertretungsliste** des Schuljahres: wer für welche Klasse spricht, **mit Mailadresse** | [16](../soll-prozesse/16-elternvertretung.md) „Dateien" | `secretariat`, `school_management` | [Frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) als Druckansicht — „daraus schreibt die Schule ihre Einladungen, wie heute aus einer Liste im Ordner". Schulleitung nur die Klassen ihrer Schulart. Listenroute, deshalb **nie über den OTP-Pfad**: Sie ist genau die Menge, die die Route darüber den Eltern vorenthält. Ohne Schuljahr das laufende | liest | — |

## Keine Läufe, keine Mail, kein Fremdsystem

Drei Aussagen, keine Auslassung ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

- **Kein Lauf.** Das Amt endet mit dem Schuljahr, weil das Schuljahr an der Zeile steht — nichts
  räumt auf, nichts läuft ab, nichts wird angemahnt. „Trägt in einem Schuljahr niemand etwas ein,
  hat die Klasse im System keine Vertretung."
- **Keine Mail, aus keinem Anlass.** „Wer gewählt wurde, weiß es aus dem Raum."
- **Kein Fremdsystem.** ASV-BW, Optigem und M365 kennen kein Elternamt, und ein Mailverteiler im
  Tenant entsteht dafür nicht — es gibt hier also auch keine
  [Nachzieh-Aufgabe](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail).

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Die wählbare sorgeberechtigte Person** — `GET /classes/{class_id}/selectable-guardians`
  ([`stammdaten-api.md`](stammdaten-api.md)). „Ausgewählt und nicht eingetippt" verlangt eine Liste
  der Sorgeberechtigten der Kinder dieser Klasse — Name und `person_id`, kein Kontaktweg.
  `GET /classes/{class_id}/roster` trägt die Kinder samt Abholberechtigten, aber keine wählbaren
  Sorgeberechtigten, und `GET /employees/selectable` ist das Gegenstück für Mitarbeitende. Sie
  gehört den Stammdaten, denen die Daten gehören.
- **Die Wirkung des Amts** — [14](../soll-prozesse/14-elternbonus.md) erlässt der Familie jedes
  Amtsträgers die vollen Mitarbeitsstunden und liest `class_representatives` dafür selbst
  ([`elternbonus-api.md`](elternbonus-api.md), Flag `full_via_representation`). Diese Domäne rechnet
  nichts und liefert keine Zahl; sie hält den Eintrag.
- **Die Klassen** — `GET /classes`, `POST /classes`, `PATCH /classes/{class_id}`
  ([`stammdaten-api.md`](stammdaten-api.md)). Diese Domäne liest sie und legt keine an.
- **Die Änderungsspur** — `GET /change-log?table_name=class_representatives&row_id=`
  ([`querschnitt-api.md`](querschnitt-api.md)). Sie ist hier nicht Beiwerk, sondern der einzige Ort,
  an dem ein ausgetragenes Amt noch steht.
- **Der Lösch-Lauf** (17) berührt diese Domäne nicht eigens: Der Eintrag geht mit der Person
  (`fk_class_representatives_person … ON DELETE CASCADE`) und mit der Klasse. Dasselbe gilt für die
  vier neuen Tabellen — die Mitgliedschaft geht mit dem Kind, die Unterrichtsverteilung mit dem
  Mitarbeitendeneintrag, und die Gruppe bleibt mit leerer Lehrkraft stehen, statt ihre Kinder
  mitzunehmen.
- **Die zweite Achse als Leseregel** — von welchen Kindern jemand liest, wenden
  [`gesundheit-api.md`](gesundheit-api.md) und jede weitere Domäne mit Kindbezug an; geführt werden
  die Zeilen hier, gepflegt hat sie noch keine Route.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **`fk_class_representatives_person` zeigt auf `persons`, nicht auf eine Sorgeberechtigten-Rolle.**
  Das ist richtig — eine eigene Fremdschlüsselspalte auf `family_guardians` bräuchte die Familie
  dazu, und das Amt hängt an der Klasse —, heißt aber, dass **die Route prüfen muss, was kein
  Constraint prüft**: dass die eingetragene Person überhaupt sorgeberechtigt ist. Ohne diese Prüfung
  ließe sich eine Lehrkraft als Elternvertreterin eintragen, und [14](../soll-prozesse/14-elternbonus.md)
  erließe der falschen Familie die Stunden.
- **`school_year` ist ein `smallint` ohne Bindung an `created_at`.** Anders als
  `ck_expense_claims_calendar_year` und `ck_parent_work_entries_school_year` hält hier nichts das
  Jahr an seinem Entstehen. Weil die Route es rechnet und nicht entgegennimmt, fällt das heute nicht
  auf; käme je ein Weg dazu, der es setzt, fehlt die Klammer.
- **`uq_class_representatives` steht auf (Klasse, Jahr, Person)** und lässt beliebig viele Personen
  je Klasse zu. Genau so gewollt — „eine Höchstzahl prüft niemand" —, und das Prüfskript weist die
  dritte Person ausdrücklich als *erlaubt* nach.

## Offene Fragen

**Keine.** Block 16 lässt nichts offen, und das Schema trägt keine `[?]` mehr: Wer die
Wahlmodulgruppe pflegt, steht seit dem 03.09.2026 — Klassenlehrkraft, Sekretariat und Schulleitung
([15](../soll-prozesse/15-klassenbildung.md)). Daran hängt der GRANT des Durchgangs, der die vier
neuen Tabellen bedient.
