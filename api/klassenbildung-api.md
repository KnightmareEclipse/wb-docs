# Klassenbildung — keine eigene Route

Aus [`15-klassenbildung.md`](../soll-prozesse/15-klassenbildung.md); es gilt
[`gemeinsam.md`](gemeinsam.md). **Diese Datei legt keine Route an, und das ist ihr Ergebnis** —
dieselbe Aussage, die `schema/klassenbildung-schema.sql` ohne eine einzige `CREATE`-Anweisung macht:
Die Domäne schreibt genau eine Spalte, `children.class_id`, und die gehört den Stammdaten
(`grenzkarte.md`: „eine Oberfläche, keine Datendomäne"). Eine Route hier wäre eine zweite Fassung
einer gebauten.

**Gegenprobe:** Die Ablauftabelle hat **3 Zeilen**; alle drei handeln im System, alle drei haben
eine Route — **keine davon in dieser Datei**. Es gibt **0 Routen** hier, und **keine Abweichung**:
Auch die beiden Einsichten, die Block 15 der Klassenlehrkraft gibt, tragen je eine gebaute Route
anderswo (unten).

## Wo die drei Zeilen liegen

| Zeile | Handlung | Route | Datei |
|---|---|---|---|
| Z1 | Eine neu beginnende Klasse anlegen — Kennung, Klassenlehrkraft, Raum | `POST /classes` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z1 | Klassenlehrkraft oder Raum ändern — **nie die Kennung** | `PATCH /classes/{class_id}` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z1 | Welche Klassen es gibt, samt gerechneter Stufe und Anzeigename | `GET /classes` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z2 | Die Ansicht, aus der ein Mensch die Klasse setzt: alle Kinder einer künftigen Stufe mit Geschlecht, Wohnort, Geschwistern und bisheriger Klasse | `GET /classes/placement` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z2 | Ein Kind in eine Klasse setzen oder umsetzen — **dieselbe Handlung**, samt Aktenordner-Umzug | `PUT /children/{child_id}/class` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z3 | Die Nachzieh-Aufgaben für ASV-BW und M365 sehen und abhaken | `GET /tasks`, `PUT /tasks/{sync_task_id}` | [`querschnitt-api.md`](querschnitt-api.md) |

Z3 **legt keine Aufgabe an**: Sie entsteht als Seiteneffekt von `PUT /children/{child_id}/class`,
und zum Schuljahreswechsel gar nicht — dort trägt die Jahresansicht dieselbe Arbeit
([04](../soll-prozesse/04-schuljahreswechsel.md), `GET /school-years/{school_year}/rollover`).

## Und wo der Rest liegt

Alles, was Block 15 außerhalb seiner Ablauftabelle verlangt, steht ebenfalls schon:

- **Die Klassenliste** — `GET /classes/{class_id}/roster` ([`stammdaten-api.md`](stammdaten-api.md)),
  [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste), für Lehrkräfte, Sekretariat und
  Schulleitung.
- **Was die Eltern sehen** — `GET /families/{family_id}` ([`stammdaten-api.md`](stammdaten-api.md))
  trägt „Kinder samt Klasse, Klassenlehrkraft und Schuladresse". **Den Raum trägt sie nicht**, und
  das ist die Gegenprobe zu „den Raum nicht, er ist eine Notiz für den Betrieb".
- **Die Elternvertretung derselben Klasse** — `GET /classes/{class_id}/representatives`
  ([`klassenorganisation-api.md`](klassenorganisation-api.md)).
- **Die volle Gesundheitseinsicht der Klassenlehrkraft** — `GET /children/{child_id}/health-record`
  ([`gesundheit-api.md`](gesundheit-api.md)), als Ownership-Check über `classes.class_teacher_id`
  und nicht als Rolle. Gebaut.
- **Das Austrittsdatum der Kinder der eigenen Klasse** — die zweite der beiden Einsichten, „denn
  das Ende eines Kindes geht seine Klasse an und nicht das ganze Kollegium"
  ([03](../soll-prozesse/03-irregulaerer-abgang.md)). Sie hängt am Kind wie die erste und steht
  deshalb an `GET /children/{child_id}` ([`stammdaten-api.md`](stammdaten-api.md)), mit demselben
  Ownership-Check und ohne neue Rolle. **Nicht an der Klassenliste**, die bewusst nur trägt, „was
  die Lehrkraft im Alltag ohnehin sehen darf", und aus der ein abgegangenes Kind ohne Zutun
  herausfällt; **nicht an `GET /children/{child_id}/departure`**, die die Lehrkraft unter „Wer darf"
  nicht nennt. Gebaut.
- **Die Änderungsspur**, die hält, seit wann ein Kind in seiner Klasse sitzt —
  `GET /change-log?table_name=children&row_id=` ([`querschnitt-api.md`](querschnitt-api.md)). Das
  Schema führt den Zeitpunkt bewusst nicht als Spalte.
- **Der Wiederholer ohne passende Klasse** — er steht in `GET /classes/placement` seiner neuen Stufe
  und in `GET /school-years/{school_year}/rollover`; gesperrt wird nichts, erinnert wird an nichts.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **„Einen Zug auslaufen lassen" hat weder Route noch Spalte.** Block 15 nennt beim Zusammenlegen
  zweier Züge „zwei Griffe" — auslaufen lassen und die Kinder umsetzen —, aber nur der zweite ist
  eine Handlung: `classes` trägt kein `is_active` und kein Ende, und ausgelaufen heißt allein, dass
  die **gerechnete** Stufe über die Schulart hinausläuft. Ein leergeräumter Zug bleibt deshalb in
  `GET /classes` stehen, bis seine Kohorte durch ist — als wählbare Klasse ohne ein Kind darin. Der
  Preis ist gering und heute richtig getragen: Eine Spalte dafür wäre ein zweiter Endezeitpunkt
  neben dem gerechneten, und die Schulleitung, die den Zug leergeräumt hat, weiß, dass er leer ist.
  Fällt es je zur Last, ist es ein `ended_school_year` an `classes` und ein Filter in einer Route.
- **`classes.class_teacher_id` ist nullable, `POST /classes` verlangt sie trotzdem** — das steht in
  [`stammdaten-api.md`](stammdaten-api.md) und wird hier nur bestätigt: Leer bleibt sie allein beim
  Vollimport, wenn die Klassen aus ihrer rückgerechneten Kennung entstehen (`backlog/`). Solange sie
  leer ist, hat diese Klasse **niemanden**, der die beiden Einsichten oben trägt und der die
  Elternvertretung eintragen dürfte ([`klassenorganisation-api.md`](klassenorganisation-api.md)) —
  das Sekretariat springt dafür ein, und deshalb steht es dort neben ihr.

## Offene Fragen

**Keine.** Block 15 lässt für diese Domäne nichts offen, und das Schema trägt keine `[?]`.
