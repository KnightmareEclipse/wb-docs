# Prüfbericht — Schema gegen die Soll-Blöcke

Stand 2026-08-20. Geprüft wird `schema/` gegen `soll-prozesse/`, `soll-prozesse/hebel.md`,
`wb-docs/rules.md` (1, 3, 7) und `wb-docs/domains/grenzkarte.md`.

**Zwei unabhängige Läufe, ein Bericht.** Der zweite Lauf hat den ersten Bericht bis nach seinem
eigenen Urteil nicht gesehen. Jeder Fund trägt deshalb eine Herkunft:

- **(beide)** — in beiden Läufen unabhängig gefunden; das wiegt schwerer als ein einzelner Befund.
- **(Lauf 1)** / **(Lauf 2)** — nur dort gefunden. Der zweite Lauf hat die Funde des ersten
  nachgelesen und keinem widersprochen.

## Mechanischer Vorlauf

Podman/Postgres 17, leere Datenbank.

- Ladelauf in der vorgegebenen Reihenfolge (`stammdaten`, `querschnitt`, dann Rest):
  alle 14 Dateien Rückgabewert **0**. Beide Läufe.
- Alle 14 Prüfskripte gegen die **vollständige** Datenbank: alle Rückgabewert **0**. Beide Läufe.
- Zusätzlich im zweiten Lauf, gegen die vier Fallen aus dem Prompt: Jedes Prüfskript lief noch
  einmal mit instrumentierten Hilfsfunktionen (Kopie im Scratchpad, die Repo-Dateien blieben
  unberührt).
  - `expect_accept` mit `GET DIAGNOSTICS … ROW_COUNT` und Abbruch bei null Zeilen:
    **keine einzige Leerlauf-Probe** über alle 14 Skripte (236 `expect_reject`, 143
    `expect_accept`). Die Falle „Gegenprobe trifft null Zeilen" ist zu.
  - `expect_reject` mit ausgegebenem `SQLERRM`: je Probe steht jetzt fest, **welches** Constraint
    zugeschlagen hat. Vier Proben werden über ein `NOT NULL` abgewiesen — `employees.house_id`,
    `configured_values.valid_from`, `measles_proofs.measles_presentation_type_id`,
    `meal_subscriptions.terms_contract_text_id` —, und bei allen vier ist genau die Pflicht die
    Regel, die belegt werden soll. **Keine Probe wird aus dem falschen Grund abgewiesen.**
  - Achtung beim Nachstellen: `mensa-schema-check.sql` fängt als einziges Skript zusätzlich
    `exclusion_violation` — es hat als einziges eine `EXCLUDE`-Regel. Wer die Hilfsfunktion
    kopiert, muss das mitnehmen.
- Löschlauf über ein vollständig bestücktes Kind (Dokumente, Aktenordner, Mandat, Vertrag,
  Unterschrift): `DELETE FROM children` wird blockiert — wie beabsichtigt —, und die Kette geht
  auf, wenn `documents`, `child_file_folders`, `sepa_mandates` und `contracts` vorher fallen.
  Danach `families`, danach `persons`. **Die Reihenfolge steht in keiner Datei**; jede Tabelle
  nennt ihren Löschanker, die Abfolge über alle nennt keine. Das ist keine Schemafrage, aber der
  Lösch-Lauf (17) braucht sie, bevor er das erste Mal läuft.

Funde je Domäne unten. Diese Liste bringt sie in die Reihenfolge, in der ich sie angehen würde:
was im Betrieb bricht, vor dem, was nur unsauber ist.

## Nach Gewicht

Bricht im Betrieb oder kostet eine Migration

 1. **anmeldung** · `ix_contracts_running` greift im Regelfall nicht — zwei
    laufende Schul- oder Hortverträge je Kind gehen durch, und die Gegenprobe
    ist grün, weil sie den realen Fall nicht baut. **(beide)**
 2. **anmeldung** · Zielstufe wird gegen 1..10 statt gegen die Schulart geprüft;
    aus ihr werden mit der Freigabe Schulart und Stufe des Kindes. **(Lauf 1)**
 3. **querschnitt** · die Änderungsspur hat keinen erreichbaren Löschanker: die
    Cascades räumen die Zeilen weg, deren Schlüssel der Lauf bräuchte. **(Lauf 1)**
 4. **rechnungsfreigabe** · der Belegbetrag ist bei Fahrtkosten ableitbar und an
    nichts gebunden — 9.999,99 € über 1 km gehen durch. **(Lauf 1)**
 5. **rechnungsfreigabe** · die Pflichtbegründung der **Korrektur** hat keine
    Spalte, obwohl 12 sie zweimal verlangt — im einzigen Prozess, in dem eine
    Führungskraft einen fremden Betrag ändern darf. **(Lauf 2)**
 6. **putzdienst** · die eingescannte Unterschriftenliste hat keinen Ort; Block
    01 legt sie dreimal ab und löscht sie mit. **(beide)**
 7. **querschnitt** · die Unterschrift des Kindes ab 14 hat keinen Löschanker
    und blockiert danach das Löschen der Person. **(Lauf 1)**
 8. **anmeldung** · für die abgeschickte, aber nicht bezahlte Bewerbung gibt es
    keinen Ort und keine begründete Auslassung. **(Lauf 1)**
 9. **anmeldung** · `applications.ended_at` — der Löschanker der Tabelle mit der
    kürzesten Frist — ist an nichts gebunden: eine Bewerbung mit Endstatus und
    leerem Anker geht durch, wird nie gelöscht und sperrt zugleich jeden zweiten
    Anlauf desselben Kindes. **(Lauf 2)**
10. **rechnungsfreigabe** · die Meldegrenze (250 €) hat keinen Wert im System. **(beide)**

Steht falsch da, ohne im Betrieb zu brechen

11. **anmeldung** · `processing_note` und `class_placement_wish` — zwei
    Freitextfelder mit Personenbezug, die 07 und 15 ausschließen. **(Lauf 1)**
12. **gesundheit** · der Behandlungszeitraum fehlt, obwohl 08 ihn erhebt. **(beide)**
13. **mensa** · `meal_subscriptions.school_year` neben seinem eigenen Zeitraum,
    ungebunden. **(beide)**
14. **stammdaten** · `children.congregation` mit einem Zweck begründet, den 05
    ausdrücklich verneint — vor dem Vollimport zu entscheiden. **(Lauf 1)**
15. **stammdaten** · zwei erfundene Zitate an `fk_classes_teacher`, dazu eine
    Warnung vor einer Abweichung, die es nicht gibt. **(beide)**
16. **mensa** · zwei falsche Aussagen darüber, was 09 und 11 sagen. **(beide)**
17. **ferien** · ein erfundenes Zitat, ein daraus konstruierter Widerspruch und
    Beträge, die 10 als offen führt. **(Lauf 1)**
18. **anmeldung** · zwei falsche Zitate an `tuition_fees`, eines davon mit
    umgekehrter Aussage. **(Lauf 1)**
19. **alle** · fünf behauptete Antworten der Schule ohne Beleg im Repo, jeweils
    gegen ein noch offenes `[?]` im Block — dazu die drei Einzelstellen unter
    `klassenorganisation`, `selfservice` und `ags`. **(Lauf 1)**

Unsauber

20. **stammdaten** · die letzte Admin-Rolle aus hebel.md hat keinen Ort und
    keine begründete Auslassung. **(Lauf 1)**
21. **anmeldung** · der Anmerkungs-Freitext aus 06 hat keine Spalte. **(Lauf 1)**
22. **putzdienst** · „keinen Termin annehmen, an dem sie schon steht" trägt
    weder Constraint noch Auslassung. **(Lauf 1)**
23. **ferien** · `holiday_cost_coverage_codes` nennt einen Löschanker, der
    keiner ist. **(Lauf 1)**
24. **alle** / **stammdaten** · `expires_at` dreimal ableitbar gespeichert. **(Lauf 1)**
25. **querschnitt** · das Art.-7-Zitat an `consents` steht so nicht in
    grenzkarte.md. **(Lauf 1)**
26. **stammdaten** · fünf Zitate mit stiller Splice-Änderung. **(Lauf 1)**
27. **querschnitt** · das 09-Zitat an `sync_targets` ist umformuliert; das eigene
    Prüfskript zitiert dieselbe Stelle wörtlich richtig. **(Lauf 2)**
28. **elternbonus** · zwei Zitate an `parent_work_entries` still gekürzt. **(Lauf 2)**
29. **anmeldung** · „das vierte und jedes weitere" und „und alle weiteren" in
    Anführungszeichen, ohne Quelle. **(Lauf 1)**

## stammdaten

```
[F] stammdaten · Klasse 3 · fk_classes_teacher (Zeile 769–782) — **(beide)**
Der Kommentar zitiert zwei Sätze, die in keiner Quelle des Repos stehen: die
Schule habe „immer genau eine" geantwortet, und Block 15 nenne sie „im selben
Satz „normal"". Beide Zeichenfolgen kommen in keinem Block, in hebel.md, in
grenzkarte.md, in rules.md oder in prozesse.md vor. Darauf gestützt behauptet
derselbe Kommentar, „der Block sagt an dieser Stelle jetzt etwas anderes als das
Schema" — Block 15 sagt aber genau das, was gebaut ist: „die Klassenlehrkraft
(Pflicht, genau eine je Klasse … eine Doppelbesetzung wird nicht geführt)".
Der Kommentar warnt damit vor einer Abweichung, die es nicht gibt, und beziffert
eine Migration, die niemand braucht.
Vorschlag: die beiden Zitate durch den echten Satz aus 15 ersetzen und den
Absatz über den teuren Rückweg streichen.
```

```
[F] stammdaten · Klasse 3 / rules.md 7 · children.congregation (Zeile 430–437) und [?] am Dateiende — **(Lauf 1)**
Der Kommentar begründet die Kirchengemeinde mit einem Zweck: „Gelesen wird sie
in der Aufnahmeentscheidung (07): Über die Gemeinde ist ein Kind der Schule
womöglich schon bekannt", und das [?] am Dateiende sagt „Für die Kirchengemeinde
ist der Zweck benannt (Aufnahmeentscheidung, 07)". Block 07 nennt die
Kirchengemeinde mit keinem Wort; sein einziger einschlägiger Satz ist das
Gegenteil: „Die Grundlage dafür — Gespräch, Bewertung, Ranking — bleibt
vollständig außerhalb." Block 05 sagt es ausdrücklich: „die Kirchengemeinde ist
dabei das einzige Feld ganz ohne benannten Zweck". grenzkarte.md zählt sie unter
den weißen Flecken auf. Das wiegt, weil genau dieses Feld vor dem Vollimport zur
Entscheidung ansteht: Ein im Schema notierter Zweck lässt es die Prüfung
überstehen, die es streichen sollte.
Vorschlag: den Zweck-Satz streichen und im [?] den Wortlaut aus 05 übernehmen.
```

```
[F] stammdaten · Klasse 6 · login_codes.expires_at (ck_login_codes_expiry) — **(Lauf 1)**
`expires_at` ist vollständig aus `created_at` ableitbar — der CHECK erzwingt
`expires_at = created_at + interval '15 minutes'` und lässt keinen anderen Wert
zu. Damit steht dieselbe Tatsache zweimal, und der CHECK ist der Beleg dafür.
rules.md 1 erlaubt einen ableitbaren Wert nur, „wenn er ein Constraint tragen
muss, das sich über den Ableitungsweg nicht ausdrücken lässt" — hier trägt er
keines. Nebenwirkung, im Container nachgestellt: ein anwendungsseitig
gerechneter Zeitstempel, der um eine Sekunde von `now()` abweicht, wird
abgewiesen; die Spalte ist nur befüllbar, indem man die Ableitung nachbaut.
Vorschlag: Spalte und CHECK streichen, Ablauf als `created_at + interval
'15 minutes'` lesen.
```

```
[F] stammdaten · Klasse 1 · employee_roles — **(Lauf 1)**
hebel.md, „Rollen": „Die letzte Admin-Rolle lässt sich nicht entziehen, nur
übertragen." Block 13 hält den Hebel ausdrücklich am Leben („der Schutz in
hebel.md gilt dem Entziehen und nicht dem Ausscheiden"). Im Schema gibt es dafür
weder Spalte noch Constraint noch eine begründete Auslassung — die Tabelle
schweigt dazu. Die übrigen Zahlen aus hebel.md (15 Minuten, fünf Fehleingaben)
sind dagegen gebaut, die Auslassung ist hier also nicht Linie, sondern Lücke.
Vorschlag: einen Satz „bewusst KEINE Sperre gegen den letzten Admin, die
Anwendung weist das Entziehen ab" an `employee_roles` — oder den Trigger bauen.
```

```
[F] stammdaten · Klasse 3 · fünf Zitate mit stiller Splice-Änderung — **(Lauf 1)**
Fünf wörtliche Zitate sind gegenüber der Quelle verändert, ohne dass eine
Auslassung markiert ist: `phone_numbers` („… nachmittags für die Betreuung,
eine Regel statt zweier Nummern" — im Block steht dazwischen ein Verweis auf 09),
derselbe Kommentar zu grenzkarte.md („die Notfallnummer kein eigenes Feld" statt
„die Notfallnummer bekommt kein eigenes Feld"), `families` („die letzte
Mailadresse … lässt sich nur ersetzen" — der Block konjugiert „lassen sich",
weil er Mailadresse und Notfallnummer zusammen nennt), `family_contacts`
(„… Verhältnis zum Kind)" — die Klammer geht im Block weiter) und
`employee_roles` (00, eingeschobener Verweis auf die Änderungsspur entfällt).
Jedes für sich harmlos; zusammen ist es das Muster, das ein erfundenes Zitat
nicht mehr auffallen lässt.
Vorschlag: die fünf Stellen wörtlich nachziehen bzw. „…" setzen.
```

Angesehen, nicht als Fund gewertet · stammdaten

- Pflicht-Mailadresse je Familie und Pflicht-Notfallnummer stehen bewusst nicht
  als Constraint: beide greifen erst mit dem ersten Vertrag am Kind, ein CHECK
  bräuchte den Wert vor dem Zeitpunkt, an dem er entsteht. Begründet an
  `families` und `phone_numbers`, deckt sich mit 02 und 08. **(Lauf 2)**

- `employees.first_working_day` nullable, obwohl grenzkarte.md Q4 den
  Beschäftigungszeitraum „beidseitig nötig" nennt — Block 13 sagt jünger und
  ausdrücklich „Freiwillig sind zwei: der erste Arbeitstag, weil an ihm nichts
  hängt". Block schlägt Grenzkarte; das Schema folgt richtig.
- `sepa_mandates` ohne Unterschriftsspalten, obwohl 08 „der Tag der Unterschrift
  (Pflicht)" verlangt — die Unterschrift steht als Q2-Zeile in `signatures`
  (`sepa_mandate_id`, querschnitt), nachgeprüft und vorhanden.
- `ck_login_codes_expiry` fängt auch die Probe „Anmeldecode, der schon abgelaufen
  ist" ab; sie belegt keine zweite Regel, sondern dieselbe. Kein Fund, aber die
  Probe beweist weniger, als ihr Name sagt.
- Wechsel Klasse 4 → eigene Realschule in einem UPDATE (Schulart, beide Grenzen,
  Stufe, Klasse): geht durch, wie 04 und 08 es verlangen. Angegriffen, hält.
- Rücktritt nach der Freigabe mit `exit_date = entry_date` (08): geht durch.

## querschnitt

```
[F] querschnitt · Klasse 4 · signatures (Zeile 206–214, „Löschanker: geht mit dem Vertragsvorgang und damit mit dem Kind") — **(Lauf 1)**
Derselbe Kommentar nennt zwei Unterschriften, die zu keinem Vertragsvorgang
gehören — die des Kindes ab 14 unter seinem Fotoeinverständnis und die unter
einem SEPA-Mandat. Für die zweite trägt `fk_signatures_mandate` ON DELETE
CASCADE. Für die erste trägt nichts: `contract_id` und `sepa_mandate_id` sind
leer, `fk_signatures_person` steht auf NO ACTION, und der einzige Zeiger auf sie
ist `consents.signature_id` — die `consents`-Zeile kaskadiert aber mit dem Kind
weg. Im Container nachgestellt: nach `DELETE FROM children` steht die
Signaturzeile samt Zeitpunkt und Graph-Kennung des Namenszugs allein da, die
Zustimmung daneben ist fort, und `DELETE FROM persons` scheitert danach an
`fk_signatures_person`. Der Löschanker zeigt damit für den einen Fall ins Leere,
den der Kommentar selbst als Ausnahme benennt.
Vorschlag: `child_id` an `signatures` für die vertragslose Unterschrift, mit
demselben CASCADE wie an `consents` — oder `consents.signature_id` umdrehen und
die Signatur ON DELETE CASCADE an der Zustimmung hängen.
```

```
[F] querschnitt · Klasse 4 / rules.md 7 · change_log — **(Lauf 1)**
Löschanker laut Kommentar: „die Spur geht mit den Daten, auf die sie sich
bezieht" (02). Der Bezug ist `table_name` plus `row_id` als Text, ohne
Fremdschlüssel — das ist so gewollt ([A!]) und für sich kein Fund. Der Fund ist,
dass der Lösch-Lauf dorthin nicht kommt: Ein `DELETE FROM children` räumt über
CASCADE `consents`, `sync_tasks`, `child_health_records`, `child_meal_profiles`
und `measles_proofs` mit ab, ohne dass jemand ihre Schlüssel gesehen hat. Im
Container nachgestellt: die `change_log`-Zeile zu einer kaskadierten
`consents`-Zeile bleibt stehen und trägt `old_value = 'alt@x.org'` — ein
Personendatum in einer Zeile, die kein Anker mehr findet. Über zwanzig Tabellen
hängen so an der Spur.
Vorschlag: `child_id`/`person_id`/`family_id` als nullable Anker an `change_log`
(wie an `sync_tasks`), gesetzt von derselben Schreibschicht, die die Spur ohnehin
schreibt — oder die kaskadierenden Fremdschlüssel auf NO ACTION umstellen, damit
der Lauf jede Zeile sieht, die er löscht.
```

```
[F] querschnitt · Klasse 3 · consents (Zeile 379 und 425) und querschnitt-schema-check.sql (Zeile 203) — **(Lauf 1)**
Beide Stellen führen „der Zeitpunkt ist der Nachweis nach Art. 7 Abs. 1 DSGVO"
als Zitat aus grenzkarte.md, Q1 an. Dort steht: „der Boolean verlöre den
Zeitpunkt, den Art. 7 Abs. 1 DSGVO als Nachweis verlangt." Sinngleich, Wortlaut
anders — und im Prüfskript trägt der erfundene Satz die Begründung einer
Gegenprobe.
Vorschlag: den Satz aus der Grenzkarte übernehmen oder die Anführungszeichen
weglassen.
```

```
[F] querschnitt · Klasse 3 · sync_targets, Kommentar an `code` — **(Lauf 2)**
Der Kommentar begründet die zweite Aufgabenart bei demselben System mit der
Änderungsgebühr und zitiert dafür 09 als „darin nicht mitläuft … Sie wird
deshalb eine eigene Aufgabe". Block 09 schreibt „Die Änderungsgebühr **läuft
darin nicht mit**: …". Der zweite Halbsatz stimmt wörtlich, der erste ist
umformuliert. Bemerkenswert daran ist, dass dieselbe Stelle im eigenen
Prüfskript korrekt zitiert wird (querschnitt-schema-check.sql, Zeile 437) — die
falsche Fassung steht allein im Schema.
Vorschlag: den Wortlaut aus dem Prüfskript übernehmen.
```

Angesehen, nicht als Fund gewertet · querschnitt

- `payments.status` ist aus `confirmed_at` ableitbar, und `ck_payments_confirmed`
  erzwingt genau das — dieselbe Bauform wie `login_codes.expires_at` oben.
  Anders als dort nennt grenzkarte.md Q3 den Status ausdrücklich als eigenes
  Element der Form („Anlass × Betrag × Status × Zahlungsreferenz"), und der CHECK
  bindet ihn an seine Quelle. Kein Fund, aber die Grenze zur Doppelung.
- Zustimmung von Nein auf Ja ändern: `ix_consents_person_child_purpose` weist eine
  zweite Zeile ab, das UPDATE derselben Zeile geht aber durch — der Weg, den
  grenzkarte.md Q1 für den geklärten Widerspruch verlangt, ist offen.
- `documents`/`child_file_folders` ohne CASCADE auf `children`: sieht nach einem
  blockierten Lösch-Lauf aus, ist aber gewollt und begründet („eine verwaiste
  Datei in SharePoint ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile")
  und im Prüfskript belegt.
- `signatures` ohne Spalte für die bestätigte Fassung: 08 friert die Fassung mit
  der Zusage ein, sie steht je Vertrag an `contracts.contract_text_id`. Trägt.

## anmeldung

```
[F] anmeldung · Klasse 1 und 5 · ix_contracts_running (Zeile 770–773) — **(beide)**
Der partielle Index trägt „Je Kind ein laufender Hortvertrag, nie zwei
nebeneinander" (09), feuert aber nur `WHERE released_at IS NOT NULL AND end_date
IS NULL AND runs_until IS NULL`. Nach Block 08 führt jeder Schulvertrag
„bis wann er nach jetzigem Stand läuft — der 31. Juli des Schuljahres, in dem die
Schulart endet" mit, nach Block 09 jeder Hortvertrag „im ersten Jahr der
31. Juli". `runs_until` ist damit im Regelfall gesetzt, und der Index greift
gerade dann nicht. Im Container nachgestellt: zwei freigegebene Hortverträge
desselben Kindes mit `runs_until = 2027-07-31` gehen durch, ebenso zwei
freigegebene Schulverträge. Die Gegenprobe „09 — zweiter laufender Hortvertrag
desselben Kindes" (anmeldung-schema-check.sql, Zeile 430) legt ihre Verträge
ohne `runs_until` an und ist deshalb grün, ohne den realen Fall zu berühren.
Vorschlag: `runs_until` aus der Index-Bedingung nehmen und die drei im Kommentar
genannten Überlappungsfälle stattdessen über `end_date` bzw. den Vertragstyp
abgrenzen.
```

```
[F] anmeldung · Klasse 1 · applications / kein Ort für die unbezahlte Bewerbung — **(Lauf 1)**
05, „Löschen": „abgeschickte, aber nie bezahlte Angaben verschwinden nach einem
Tag, und auch diese Zahl ist fest", und hebel.md führt sie unter den
kurzlebigen Marken, die von selbst verfallen. Im Schema gibt es dafür keine
Tabelle, keine Spalte und keine begründete Auslassung: `applications.submitted_at`
ist NOT NULL und trägt ausdrücklich den Zeitpunkt der bestätigten Zahlung, und
`payments.application_id` setzt eine `applications`-Zeile voraus — eine offene
Zahlung zu einer noch nicht entstandenen Bewerbung lässt sich gar nicht anlegen.
Die vollständigen Angaben zu Kind und Sorgeberechtigten müssten damit einen Tag
lang irgendwo liegen, wo der Entwurf sie nicht vorsieht.
Vorschlag: entweder eine kurzlebige Tabelle `application_drafts` wie
`login_codes` — oder ein Satz an `applications`, dass die Angaben bis zur
Zahlung ausschließlich im Prozessspeicher der Anwendung liegen.
```

```
[F] anmeldung · Klasse 7 · applications.processing_note (Zeile 573) und applications.class_placement_wish (Zeile 576) — **(Lauf 1)**
Beide Spalten stehen allein auf grenzkarte.md, und beide Blöcke sind jünger und
sagen das Gegenteil. Block 07, Schritt 2: „Ein Grund wird nicht eingetragen und
eine Notiz auch nicht — dafür gibt es kein Feld, auch kein stillgelegtes"; sein
„Was dabei erhoben wird" kennt keinen Bearbeitungsstand-Freitext. Block 15:
„Die Gründe — Freundschaften, Förderbedarf, Ausgewogenheit — bleiben außerhalb
wie das Ranking in 07", und sein „Was dabei erhoben wird" kennt keinen Wunsch.
Der Dateikopf desselben Schemas zieht für Geschwister, Hospitationszeitraum und
Schulpflicht-Stichtag genau diese Konsequenz („Alle drei stehen so in
grenzkarte.md und werden vom jüngeren Block überstimmt") — für diese zwei nicht.
Es sind zwei Freitextfelder mit Personenbezug an der Bewerbung (rules.md 7).
Vorschlag: beide streichen oder je einen Blocksatz nachtragen, der sie hergibt.
```

```
[F] anmeldung · Klasse 2 · applications.target_grade_level, admission_days, enrolment_windows — **(Lauf 1)**
`ck_applications_grade_level CHECK (target_grade_level BETWEEN 1 AND 10)` prüft
die Stufe gegen eine feste Zahl statt gegen die Schulart; `admission_days` und
`enrolment_windows` prüfen sie gar nicht. Im Container nachgestellt: eine
Bewerbung für die Grundschule mit Zielstufe 9 und ein Anmeldetag Grundschule
Zielstufe 9 gehen beide durch. Das ist genau der Fehler, den `children`
inzwischen behoben hat und den der Kommentar dort benennt: „Vorher stand statt
ihrer 1..10 hart im CHECK — eine Zahl, die keine Schulart hergibt, ging damit
durch." Aus dem Ziel der Bewerbung werden mit der Freigabe Schulart und Stufe
des Kindes (08); die Stufe kommt dort also aus einer Quelle, die sie nie geprüft
hat.
Vorschlag: `first_grade_level`/`final_grade_level` mitführen und per
zusammengesetztem Fremdschlüssel auf `uq_school_branches_grades` binden, wie bei
`children`.
```

```
[F] anmeldung · Klasse 3 · tuition_fees (Zeile 268 und 277) — **(Lauf 1)**
Zwei Zitate, die so nicht in ihrer Quelle stehen, und beide tragen die Begründung
der Tabelle. Erstens hebel.md: „Dazu die beiden größten Beträge, das Schulgeld je
Schulform — Grundschule und Realschule kosten verschieden — und der Hortbeitrag."
hebel.md sagt heute: „Dazu die beiden größten Beträge, das Schulgeld und der
Hortbeitrag; beide Preislisten liegen inzwischen vor." Der Einschub, der die
eigene Tabelle begründet, ist nicht mehr da. Zweitens Block 08: das Schema
zitiert „das Schulgeld darin ist der Betrag, der ab dem Eintrittsdatum gilt,
nicht der am Tag der Unterschrift geltende" — der Block schreibt „das Schulgeld
darin ist die vollständige Staffel, die ab dem Eintrittsdatum gilt … und nicht
der eine Betrag, der auf diese Familie gerade passt". Das Zitat sagt genau das,
was der Block ausschließt; die Prosa daneben sagt es dann richtig.
Vorschlag: beide Zitate durch den heutigen Wortlaut ersetzen.
```

```
[F] anmeldung · Klasse 1 · applications / Anmerkungs-Freitext aus 06 — **(Lauf 1)**
Block 06, „Was dabei erhoben wird", schließt mit „Dazu ein Freitext für
Anmerkungen (freiwillig)". Dafür gibt es keine Spalte und keine begründete
Auslassung. `processing_note` ist es nicht — sie ist im Schema dem
Bearbeitungsstand der Warteliste aus grenzkarte.md zugeordnet, nicht der
Verwaltungsspur.
Vorschlag: entweder `record_note` an `applications`, oder `processing_note`
ausdrücklich beiden Zwecken zuweisen.
```

```
[F] anmeldung · Klasse 3 · tuition_fees, sibling_rank (Zeile 297 und 322) — **(Lauf 1)**
„das vierte und jedes weitere" und „und alle weiteren" stehen als Zitate im
Kommentar; beide Zeichenfolgen kommen in keinem Block, in hebel.md und in
grenzkarte.md vor. Gemeint ist 08 bzw. hebel.md: „ab dem vierten Kind
beitragsfrei". Für sich harmlos, aber es sind zwei weitere Stellen, an denen
eigene Formulierung wie Beleg aussieht.
Vorschlag: Anführungszeichen weglassen.
```

```
[F] anmeldung · Klasse 4 · applications.ended_at gegen application_statuses.is_final — **(Lauf 2)**
`ended_at` ist der Löschanker der Tabelle mit der kürzesten Frist („die Frist
beginnt mit dem hier gesetzten Ende", 07 — und 05: „Eigene, kürzere Löschfrist
als Stammdaten") und zugleich die einzige Bedingung von
`ix_applications_running`. Gebunden ist er an nichts: `is_final` steht allein an
`application_statuses`, wird nicht an der Bewerbung mitgeführt und hängt an
keinem zusammengesetzten Fremdschlüssel — anders als die vier anderen Flags
derselben Bauform in denselben Dateien (`school_branches` an `children`, `roles`
an `employee_roles`, `consent_purposes` an `consents`, `health_trait_types` an
`health_traits`). Im Container nachgestellt: eine Bewerbung mit einem Status,
dessen `is_final` wahr ist, und leerem `ended_at` geht durch. Zwei Folgen aus
derselben Zeile: der Lösch-Lauf erreicht die abgesagte Bewerbung nie, und
`ix_applications_running` sperrt gleichzeitig jeden zweiten Anlauf desselben
Kindes für dasselbe Ziel — den 05 ausdrücklich vorsieht („nach Absage oder
Rückzug ist der zweite Anlauf eine neue Bewerbung").
Vorschlag: `is_final` an `applications` mitführen und per zusammengesetztem
Fremdschlüssel binden, dazu `CHECK (NOT is_final OR ended_at IS NOT NULL)`.
```

Angesehen, nicht als Fund gewertet · anmeldung

- Zwei Spalten für die bisherige Einrichtung (`children.previous_school_id` und
  `applications.local_school_id`) sahen nach einem Sachverhalt an zwei Orten aus.
  Block 05 entscheidet ausdrücklich anders: „Das sind zwei Einrichtungen mit zwei
  verschiedenen Rollen im Verfahren, keine Alternative zueinander." Trägt.
- `ck_contracts_care_home_alone` verlangt am Hortvertrag eine Antwort, obwohl der
  Vorgang mehrstufig ist — die Zeile entsteht laut 09 aber erst mit dem
  abgeschickten, vollständigen Antrag. Hält.
- Kein Feld für Bewertung je Lehrkraft, Absagegrund, Hospitationszeitraum,
  Geschwister-Selbstauskunft und Schulpflicht-Stichtag: alle fünf sind in ihrem
  Block ausdrücklich ausgeschlossen, der Dateikopf führt sie auf. Richtig so.

## putzdienst

```
[F] putzdienst · Klasse 1 und 3 · cleaning_slots (Zeile 112–119) und die Schlussnotiz der Datei — **(beide)**
Der Kommentar an `attendance_recorded_at` sagt: „Bewusst KEINE eingescannte
Unterschriftenliste: Die Schule hat entschieden, dass sie nicht abgelegt wird —
das Papier bleibt im Ordner", und die Schlussnotiz wiederholt es als „die einzige
Dateifrage dieser Domäne". Block 01 sagt das Gegenteil, an drei Stellen:
Schritt 11 „trägt … ein, wer da war, und legt die eingescannte Liste dazu";
Dateien „Unterschrieben kommt sie zurück und wird eingescannt beim Termin
abgelegt — sie ist der Beleg dafür, wer da war, und lesen darf sie das
Sekretariat"; Löschen „Die eingescannten Anwesenheitslisten gehen mit". Eine
Entscheidung der Schule, die das aufhebt, steht in keiner Quelle dieses Repos —
nicht im Block, nicht in der README, nicht in hebel.md oder grenzkarte.md. Ob
die Schule so geantwortet hat, kann dieser Lauf nicht wissen; er kann nur sehen,
dass Block und Schema sich widersprechen und der Block, der vorgeht, nicht
mitgezogen wurde. Solange er so steht, fehlt der Beleg, auf den sich eine Strafe
stützt, und seine Löschzusage („Die eingescannten Anwesenheitslisten gehen mit")
hat nichts, worauf sie zeigt.
Vorschlag: `attendance_sheet_library_id`/`attendance_sheet_item_id` an
`cleaning_slots`, wie an `documents` — oder den Satz durch einen Blockverweis
ersetzen, der die Auslassung wirklich trägt.
```

```
[F] putzdienst · Klasse 1 · cleaning_swap_acceptances — **(Lauf 1)**
Block 01, Schritt 8: „eine Familie kann keinen Termin annehmen, an dem sie schon
steht". Die Tabelle kennt keine Familie — nur Angebot, Zieltermin und Terminart
— und weder Constraint noch begründete Auslassung erwähnt die Regel. Die
Nachbarregeln desselben Satzes sind dagegen gebaut: „nur gegen einen bestehenden
Termin derselben Art" trägt der zusammengesetzte Fremdschlüssel, „je Termin nur
ein Angebot" trägt `uq_cleaning_swap_offers`. Läuft der Tausch durch, steht die
Familie doppelt am selben Termin — was `uq_cleaning_assignments` dann abweist,
mitten im Tauschvorgang.
Vorschlag: ein Satz, dass die Anwendung das vor dem Ankreuzen prüft — oder die
Familie an der Annahme mitführen und gegen `cleaning_assignments` prüfen.
```

Angesehen, nicht als Fund gewertet · putzdienst

- Die Mitarbeiter-Befreiung liest laut `houses` (stammdaten) das Haus, während
  grenzkarte.md Q4 sagt, sie frage „nach der Zeile, nicht nach dem Arbeitgeber".
  Block 01 entscheidet jünger und ausdrücklich: „erkennbar an einer
  Mitarbeiterrolle und am Haus *Schule* an seinem Eintrag (13); die KITA ist ein
  eigener Betrieb und zählt nicht mit". Schema folgt dem Block, richtig so.
- Die Septemberregel (wer am Ende seiner Schulart steht, bekommt keinen
  Septembertermin) trägt keine Spalte — sie ist eine Abfrage über Stufe und
  Schulart zum Zeitpunkt der Zuteilung, wie 01 sie beschreibt. Kein Fund.
- Kein Betrag an `cleaning_buyouts`: er steht in der Zahlung und der Preis in
  `configured_values`. Trägt, und der Kommentar sagt warum.
- Die Freikauf-Frist („drei Tage vor genau diesem Putzdienst") ohne eigene Spalte:
  01 nennt sie fest und nirgends einstellbar, sie folgt aus `cleaning_slots.starts_at`.
  Der Kommentar sagt das ausdrücklich. Kein Fund. **(Lauf 2)**

## ferien

```
[F] ferien · Klasse 3 · holiday_module_prices (Zeile 92–108) — **(Lauf 1)**
Der Kommentar zitiert Block 10 mit „Die Ferienwoche hat eigene Beträge und ist
keine gerechnete Summe von fünf Tagen" und schließt daraus: „Der Blocksatz
stimmt damit heute nicht: die Woche IST gerade eine gerechnete Summe." Der Block
sagt aber genau das schon selbst: „Die Ferienwoche trägt eigene Beträge, auch
wenn sie derzeit gerade das Fünffache des Tagessatzes sind: Der Betrag steht je
Modul und ist keine Regel, die multipliziert." Das Zitat ist erfunden, und der
Widerspruch, den es erzeugt, existiert nur gegenüber dem erfundenen Wortlaut.
Im selben Absatz stehen außerdem konkrete Beträge (22 / 28 / 110 / 140 € sowie
30 € Kursgebühr) als „Antwort der Schule"; Block 10 führt sie unverändert als
offene Frage: „Die Beträge selbst lagen der Erhebung nie vor — Geschäftsführung."
Vorschlag: den Blocksatz wörtlich übernehmen, den Widerspruchsabsatz streichen
und die Beträge als noch offen kennzeichnen, bis ein Block sie trägt.
```

```
[F] ferien · Klasse 4 · holiday_cost_coverage_codes — **(Lauf 1)**
Der Kommentar nennt als Löschanker „er verfällt von selbst (hebel.md, „Kein
Vorgang läuft ab")". hebel.md meint damit, dass die Marke ungültig wird, nicht
dass die Zeile verschwindet. Die Zeile trägt aber eine Mailadresse und den Satz,
an wen berechnet wird — beides Personenbezug —, und `expires_at` löscht nichts.
Wird der Code eingelöst, hält ihn `holiday_bookings.holiday_cost_coverage_code_id`
zusätzlich fest (NO ACTION), sodass er die Buchung überdauert, ohne dass ein
Lauf ihn findet. `login_codes` löst dasselbe Problem ausdrücklich mit einer [A]
(„nach 24 Stunden gelöscht"); hier fehlt sie.
Vorschlag: eine [A] wie bei `login_codes` — nicht eingelöste Codes nach Ablauf
löschen, eingelöste mit ihrer Buchung.
```

Angesehen, nicht als Fund gewertet · ferien

- `fk_payments_holiday_booking` zusammengesetzt über `amount_cents` sah nach
  Klasse 2 aus. Er trägt genau, dass Betrag der Buchung und Betrag der Zahlung
  nicht auseinanderlaufen, und greift bei den drei übrigen Anlässen nicht
  (MATCH SIMPLE, `holiday_booking_id` leer). Trägt. **(Lauf 2)**
- `ix_holiday_bookings_active` nur über nicht stornierte Buchungen: ein voller
  UNIQUE hätte genau den Weg gesperrt, den 10 für den Modulwechsel vorsieht
  („stornieren und neu buchen"). Richtig so. **(Lauf 2)**

- `fk_payments_holiday_booking` über (booking_id, amount_cents) sah nach einem
  Sachverhalt an zwei Orten aus. Beide Quellen verlangen den Betrag — 10 an der
  Buchung, grenzkarte.md Q3 an der Zahlung —, und der zusammengesetzte
  Fremdschlüssel ist genau die Ausnahme aus rules.md 1. Trägt.
- `allows_external_children` unterscheidet heute nichts, weil beide Terminarten
  auf wahr stehen. Der Kommentar sagt das selbst und begründet die Spalte mit
  der ausdrücklichen Prüfung in 10. Kein Fund.
- Keine Bilder, keine Bibliothek für die Ausschreibung: 10 verweist sie
  ausdrücklich auf die Webseite. Richtig weggelassen.

## gesundheit

```
[F] gesundheit · Klasse 7 · health_traits, Behandlungszeitraum (Dateikopf, Zeile 12–14) — **(beide)**
Der Dateikopf lässt den Behandlungszeitraum weg mit der Begründung „obwohl die
Checklisten ihn erheben" und einem Satz aus grenzkarte.md. Er steht aber nicht
nur auf den Checklisten: Block 08 führt ihn in „Was dabei erhoben wird" auf —
„therapeutische Maßnahme samt Grund und Zeitraum". Der Block ist jünger als die
Karte und schlägt sie; genau diese Reihenfolge wendet dieselbe Datei zwanzig
Zeilen weiter für die Zeckenentfernung selbst an („Der Block ist jünger und
schlägt die Karte"). Der Grund ist gebaut (`treatment_reason`), der Zeitraum
nicht, und der Kommentar nennt die Blockstelle nicht, gegen die er entscheidet.
Vorschlag: entweder `treatment_from`/`treatment_until` mit demselben
`has_treatment_reason`-Flag — oder den Satz aus 08 zitieren und daneben
begründen, warum er hier nicht gilt.
```

Angesehen, nicht als Fund gewertet · gesundheit

- Die Zeckenentfernung steht als Merkmalsart statt als Q1-Zweck, gegen
  grenzkarte.md. Block 08 zählt sie unter den Punkten des Bestands auf und unter
  dem, was Lehrkräfte und Hort sehen. Block schlägt Karte; richtig entschieden
  und ausdrücklich notiert.
- Drei Sichtstufen über `is_everyday_relevant`/`is_kitchen_relevant` statt zweier:
  Block 11 verlangt sie ausdrücklich („die Mensa sieht davon allein diese beiden
  Punkte"), und `ck_health_trait_types_kitchen` hält die engere in der weiteren.
  Trägt.
- `measles_proofs` ohne den Stand „nicht nötig", den 06 für die Unterlagenliste
  kennt: Für den Masernnachweis gibt es ihn faktisch nicht (§20 IfSG gilt für
  alle), und 09 verlangt allein, dass ein Fehlen sichtbar bleibt. Angesehen,
  nicht als Fund gewertet.

## mensa

```
[F] mensa · Klasse 3 · Dateikopf (Zeile 30) und meal_prices (Zeile 57) — **(beide)**
Zwei Aussagen über die Blöcke, die beide nicht stimmen, und beide begründen eine
Bauentscheidung. Erstens Dateikopf: „Block 09 und 11 sagen noch, es stecke im
Modulpreis; die Schule hat das mit dem Vertrag beantwortet." Block 09 sagt das
Gegenteil, wörtlich: „Das Mittagessen wird zuzüglich berechnet und steckt nicht
im Modulpreis"; Block 11 ebenso: „Berechnet wird es trotzdem, und zwar nach
derselben Staffel". Zweitens `meal_prices`: „Der Block kennt dafür eine einzige
Zahl (derzeit 20 €) und rechnet sie mal der Zahl der Tage." Block 11 führt die
vollständige Staffel — „21,50 € für einen Wochentag, 42,50 € für zwei, 63,50 €
für drei, 84,50 € für vier und 105 € für fünf, je Monat" — und sagt ausdrücklich
„gestaffelt und nicht gerechnet". Die gebaute Struktur ist in beiden Fällen
richtig; falsch ist, was über die Quelle behauptet wird — und das ist die Art
Satz, die beim nächsten Zyklus dazu führt, dass jemand die Blöcke „nachzieht".
Vorschlag: beide Absätze durch den heutigen Wortlaut aus 09 und 11 ersetzen.
```

```
[F] mensa · Klasse 6 · meal_subscriptions.school_year — **(beide)**
Das Schuljahr steht neben `starts_on` und `ends_on` und folgt vollständig aus
ihnen — genau das, was der Kopf von stammdaten-schema.sql als Linie setzt: „eine
Schuljahrestabelle gibt es nicht, das Jahr folgt aus dem Datum (Block 04)". Hier
wird es zusätzlich gespeichert, und nichts bindet es an seine Quelle: kein
CHECK, kein zusammengesetzter Fremdschlüssel. Im Container nachgestellt: ein Abo
vom 1.10.2026 bis 31.7.2027 mit `school_year = 2019` geht durch. rules.md 1
erlaubt einen ableitbaren Wert nur, wenn er ein Constraint trägt, „und dann per
zusammengesetztem Fremdschlüssel an sein Original gebunden".
Vorschlag: Spalte streichen und aus `starts_on` lesen — oder einen CHECK setzen,
der sie an `starts_on` bindet.
```

Angesehen, nicht als Fund gewertet · mensa

- `meal_subscriptions.starts_on` ohne CHECK auf „Monatserster / frühestens
  1. Oktober": 11 gibt Sekretariat und Schulleitung ausdrücklich das Recht,
  „jedes Datum stellvertretend" zu setzen — ein harter CHECK bräche den
  offiziellen Umweg. Kein Fund. **(Lauf 2)**
- `ex_meal_subscriptions_period` statt `UNIQUE (child_id, school_year)`: trägt
  „nie zwei nebeneinander" und lässt trotzdem das zweite Abo nach der
  Januar-Kündigung zu, das 11 vorsieht. Angegriffen, hält. **(Lauf 2)**

- Eigene Tabellen statt der Betreuungsmodul-Struktur, gegen die eine Stelle, an
  der grenzkarte.md ausdrücklich „bewusst zusammengelegt" hat. Der [A!] nennt
  drei Mechaniken aus Block 11, die das Modul nicht kennt — 1. Oktober,
  3. Januar/31. Januar, eigener Monatsbeitrag —, und die stehen dort wirklich.
  Block schlägt Karte; trägt.
- `ex_meal_subscriptions_period` und `ex_meal_subscription_days_period` als
  EXCLUDE statt UNIQUE: die Regeln sind Überschneidungsregeln, ein UNIQUE trüge
  sie nicht. Angegriffen mit überlappenden Zeiträumen, hält.

## elternbonus

```
[F] elternbonus · Klasse 3 · parent_work_entries, Kommentare an `school_year` und `confirming_employee_id` — **(Lauf 2)**
Zwei Zitate aus Block 14 sind still gekürzt, ohne dass die Kürzung markiert ist.
Erstens: „Mehrgeleistete Stunden verfallen und werden nicht ins nächste
Schuljahr übernommen" — der Block schreibt „Mehrgeleistete Stunden verfallen
**ebenso** und werden …". Zweitens: „Genau die gewählte Person bestätigt oder
lehnt ab; niemand sonst kann ihn abnehmen" — dazwischen steht im Block „niemand
sonst bekommt den Eintrag in seine Aufgabe, und". Beide Male stimmt die Aussage;
beide Male sieht eigene Kürzung wie Wortlaut aus. Dieselbe Klasse wie die fünf
Splice-Stellen unter `stammdaten`, hier zweimal.
Vorschlag: Auslassungszeichen setzen oder wörtlich übernehmen.
```

Sonst kein Fund: die Domäne trägt, was 14 verlangt.

Angesehen, nicht als Fund gewertet · elternbonus

- `parent_work_entries.school_year` steht neben `worked_on` und ist daraus
  ableitbar — anders als bei `meal_subscriptions` hält `ck_parent_work_entries_school_year`
  es aber an sein Datum gebunden. Genau die Ausnahme aus rules.md 1; trägt.
- `confirming_employee_name` als zweiter Ort für den Namen: er entsteht erst,
  wenn der Mitarbeitendeneintrag geht, und der CHECK erzwingt die Reihenfolge
  (der Lösch-Lauf muss ihn setzen, sonst scheitert das SET NULL). 00 und 13
  verlangen genau das: „Was seinen Namen anderswo trägt, überlebt ihn."
- Kein Feld für eine abweichende Pflichtstundenzahl je Familie, anders als beim
  Putzdienst: 14 schließt es ausdrücklich aus. Richtig weggelassen.

## klassenorganisation

```
[F] klassenorganisation · Klasse 3 · Schlussnotiz der Datei — **(Lauf 1)**
„Die Schule hat die Frage beantwortet, geführt wird allein die Elternvertretung
je Klasse und Schuljahr." Block 16 stellt die Frage unverändert: „`[?]` Gibt es
über die Klassenvertretung hinaus ein Gremium — Gesamtelternbeirat, Vorsitz,
Schulkonferenz —, dessen Besetzung im System stehen müsste? — Schulleitung."
Gebaut ist deswegen nichts Falsches; falsch ist, dass die Datei die Frage als
erledigt führt, während der Block sie noch stellt. Gehört zum Muster am Ende
dieses Berichts.
Vorschlag: die Notiz auf „offen laut 16" zurücknehmen oder den Block nachziehen.
```

Angesehen, nicht als Fund gewertet · klassenorganisation

- Keine Trennung in Vertretung und Stellvertretung, obwohl grenzkarte.md
  „Elternvertreter:in und Stellvertretung" nennt: 16 ist jünger und sagt
  „mehrere ohne Rangfolge" und „kein Amtstitel". Block schlägt Karte, das Schema
  folgt richtig — es benennt die Abweichung nur nicht als solche. **(Lauf 2)**

- Kein Amtstitel, kein Wahltag, keine Höchstzahl: 16 zählt alle drei
  ausdrücklich unter „mehr nicht" auf. Richtig weggelassen.
- Das Amt endet nicht mit dem Klassenwechsel des Kindes — 16 verlangt genau das
  („endet das Amt nicht von selbst"). Kein Constraint, und richtig so.

## m365

Kein Fund. Die Datei legt keine Tabelle an; alle sechs Angaben des
Mitarbeitendeneintrags, die Schuladresse am Kind, die Aufgabenart M365 und der
Löschanker `employees.last_working_day` stehen nachweislich in stammdaten und
querschnitt. Dass grenzkarte.md „Kontostatus, Offboarding-Schritt" führt und
Block 13 sie nicht hergibt, ist die richtige Rangfolge und benannt.

## klassenbildung

Kein Fund in dieser Datei — mit einem Vorbehalt: Ihre vierte Begründung stützt
sich auf `applications.class_placement_wish`, und diese Spalte steht oben unter
den Funden zu `anmeldung` (Klasse 7). Fällt sie, verliert diese Datei einen
ihrer fünf Belege; die übrigen vier stehen.

## selfservice

```
[F] selfservice · Klasse 3 · Schlussnotiz der Datei — **(Lauf 1)**
„Die drei Einsichtsstufen genügen den Beschlüssen, die die Schule erreichen —
bestätigt auf Nachfrage." Block 02 führt die Frage unverändert als offen:
„`[?]` Genügen die drei Stufen den Beschlüssen, die uns erreichen? —
Schulleitung und Datenschutzbeauftragte." Gehört zum Muster am Ende dieses
Berichts.
Vorschlag: Notiz zurücknehmen oder Block 02 nachziehen.
```

Angesehen, nicht als Fund gewertet · selfservice

- Die Änderungsgrenze ist im Schema `contracts.released_at` **oder**
  `children.entry_date`, während 02 allein die Freigabe nennt. Der Zusatz trägt
  die Kinder des Vollimports, für die 08 ausdrücklich sagt, dass diese Strecke
  bei ihnen nie lief. Kein Fund.

## ags

```
[F] ags · Klasse 3 · Zeile 17 und Schlussnotiz — **(Lauf 1)**
Zwei Stellen ohne Beleg. Erstens ein Satz in Anführungszeichen ohne Quelle:
„Nachrüsten ist ausdrücklich der vorgesehene Weg, nicht der Notnagel." Die
Zeichenfolge steht in keinem Block, in hebel.md, grenzkarte.md, rules.md und
prozesse.md nicht. Zweitens die Schlussnotiz „Auf Nachfrage bestätigt: Die AGs
bleiben ein Zukunftsprojekt", während grenzkarte.md sie unter den weißen Flecken
mit „nichts Konkretes bekannt" und Fälligkeit „offen" führt. Gebaut ist hier
nichts, der Schaden ist entsprechend klein — aber es ist dieselbe Bauform wie
bei den schwereren Fällen oben.
Vorschlag: Anführungszeichen weglassen, Notiz auf „offen" zurücknehmen.

Nachtrag aus Lauf 2: Die Zeichenfolge existiert doch, aber nicht in einer Quelle,
die etwas entscheidet — sie steht in `wb-docs/domains/stammdaten-schema.sql`,
Zeile 60, dem Vorentwurf. Der „schlägt gar nichts"; als Beleg taugt er nicht.
Damit bleibt der Fund stehen und die Ursache ist benannt.
```

## rechnungsfreigabe

```
[F] rechnungsfreigabe · Klasse 6 · expense_claims.amount_cents gegen travel_details — **(Lauf 1)**
Bei Fahrtkosten ist der Belegbetrag vollständig ableitbar: entweder
`ticket_amount_cents` oder `distance_km × mileage_rate_cents` — Block 12 sagt es
so („entweder Ticketbetrag samt Beleg oder die Strecke, die mit dem
Kilometersatz multipliziert wird"). Er steht trotzdem zusätzlich an
`expense_claims`, und nichts bindet ihn an seine Quelle: kein CHECK, kein
zusammengesetzter Fremdschlüssel. Im Container nachgestellt: ein Beleg über
9.999,99 € mit 1 km zu 0,30 € geht durch, und beide Zahlen stehen nebeneinander
in derselben Datenbank. Das ist der einzige Prozess, in dem Geld an
Mitarbeitende geht; dieselbe Datei sichert die Selbstfreigabe deshalb mit einem
mitgeführten Schlüssel ab (`fk_expense_claim_items_submitter_claim`) — der
Betrag bleibt daneben ungebunden. rules.md 1 verlangt für einen zusätzlich
gespeicherten ableitbaren Wert genau diese Bindung.
Vorschlag: `amount_cents` in `travel_details` mitführen und per
zusammengesetztem Fremdschlüssel an `expense_claims` binden, wie es
`fk_payments_holiday_booking` in ferien-schema.sql vormacht.
```

```
[F] rechnungsfreigabe · Klasse 1 · Meldegrenze — **(beide)**
Block 12: „Zwei Werte im System gehören der Geschäftsführung, beide mit
Gültigkeitsdatum: der Kilometersatz, derzeit 0,30 € je km, und die Meldegrenze,
derzeit 250 €, gemessen am ganzen Beleg und nicht am Teil einer Aufteilung."
Der Kilometersatz steht als `mileage_rate_cents` in der Code-Liste an
`configured_values` (querschnitt-schema.sql). Die Meldegrenze steht dort nicht,
und im ganzen Schema kommt sie nicht vor — weder als Code noch als Spalte noch
als begründete Auslassung. Ohne sie hat die Regel „liegt der Betrag über der
Meldegrenze, erfährt die Geschäftsführung die Freigabe" keinen Wert, gegen den
sie prüft, und der Wert landet als Konstante im Code — genau das, was rules.md 3
für organisatorische Werte ausschließt.
Vorschlag: einen Code `expense_report_threshold_cents` in die Liste an
`configured_values` aufnehmen.
```

```
[F] rechnungsfreigabe · Klasse 1 · expense_claim_items / Begründung der Korrektur — **(Lauf 2)**
Block 12 verlangt sie zweimal. Schritt 2: „**korrigieren** (Angaben oder Betrag
ändern, **Grund Pflicht**)". Und „Was dabei erhoben wird": „jede **Korrektur**,
Ablehnung und Stornierung trägt eine **Pflichtbegründung**." Gebaut sind drei
Begründungsfelder — `rejected_reason` und `forwarded_reason` am Teil,
`voided_reason` am Beleg. Für die Korrektur gibt es keines, keinen CHECK und
keine Gegenprobe. Der Kommentar über `rejected_at` behauptet dabei das Gegenteil
seiner eigenen Datei: „Ablehnung, Korrektur und Weiterleitung tragen je eine
Pflichtbegründung" — `grep -in korrig` über `rechnungsfreigabe-schema.sql`
findet genau diese eine Zeile und sonst nichts. `change_log` trägt Alt- und
Neuwert und den Urheber, aber kein Grundfeld; die Spur kann die Begründung also
auch nicht auffangen.
Das wiegt, weil es die einzige Stelle im Haus ist, an der jemand einen fremden
Betrag ändern darf, ohne dass der Einreicher zustimmt — „Zum Einreicher zurück
geht nichts". Ohne Grund steht danach ein anderer Betrag da, und niemand weiß
warum.
Vorschlag: `corrected_at`/`corrected_reason` am Teil, gekoppelt wie
`rejected_at`/`rejected_reason` — oder die Begründung ausdrücklich der
Änderungsspur zuweisen und dort ein Grundfeld ergänzen.
```

Angesehen, nicht als Fund gewertet · rechnungsfreigabe

- `ck_expense_claim_items_self_approval` sah nach einer Regel aus, die sich über
  das Weiterleiten umgehen ließe. Sie steht am Teil und nicht am Beleg, greift
  also für jede weitergeleitete Zeile neu. Angegriffen mit einer Selbstfreigabe
  der eigenen Fahrtkostenerstattung: sauber abgewiesen.
- Kein Format-CHECK auf `third_party_iban`, während `sepa_mandates.iban` einen
  trägt. Kein Blocksatz verlangt ihn hier, und die Buchhaltung liest ihn.
  Angesehen, nicht als Fund gewertet — aber es ist dieselbe Angabe in zwei
  Strenggraden.
- Der Dublettenhinweis hat einen Index für den Fall „Empfänger und Betrag",
  keinen für „Datum und Strecke". Beides ist eine Abfrage, keine Regel; kein
  Fund.
- `expense_claim_attachments` statt einer Q2-Zeile: Q2 trägt Dokumente mit
  Kindbezug, und 12 verlangt eine eigene Site mit eigenen Rechten. Trägt.
- `ck_expense_claim_items_self_approval` gegen den ganzen Zahlweg-Satz aus 12
  gelesen: gesperrt ist genau „gleiche Person **und** (Fahrtkosten **oder** an
  mich)". Spende, „an Dritte", „an die Firma" und „wird abgebucht" bleiben offen —
  dort geht das Geld nicht an ihn. Deckt sich mit dem Block. **(Lauf 2)**

## Über alle Domänen

```
[F] alle · Klasse 6 · expires_at an drei kurzlebigen Marken — **(Lauf 1)**
`login_codes.expires_at` (stammdaten), `application_unlocks.expires_at`
(anmeldung) und `holiday_cost_coverage_codes.expires_at` (ferien) tragen jeweils
einen CHECK, der die Spalte exakt auf `created_at + interval '15 minutes'` bzw.
`+ interval '14 days'` festnagelt. Dreimal dieselbe Bauform, dreimal derselbe
Sachverhalt an zwei Orten: Die Frist ist nach hebel.md und 05/10 „fest und
nirgends einstellbar", der gespeicherte Zeitpunkt trägt also kein Constraint,
das der Ableitungsweg nicht ausdrückte (rules.md 1). Der Einzelfall steht oben
unter `stammdaten`; hier steht er, weil er dreimal vorkommt und beim nächsten
Code-Typ ein viertes Mal entstünde.
Vorschlag: alle drei Spalten streichen und die Frist beim Lesen rechnen.
```

```
[F] alle · Klasse 3 · fünf behauptete Antworten der Schule ohne Beleg im Repo — **(Lauf 1)**
An fünf Stellen schließt ein Kommentar eine Frage, die ihr Block unverändert
offen führt — jedes Mal mit „Auf Nachfrage bestätigt", „Die Schule hat
entschieden" oder „seit der Antwort der Schule":

  putzdienst-schema.sql:112   eingescannte Liste wird nicht abgelegt  ↔  01 legt sie dreimal ab
  ferien-schema.sql:39/94     Kochwerkstatt offen; Beträge liegen vor ↔  10: beide `[?]` offen
  selfservice-schema.sql:57   drei Einsichtsstufen genügen           ↔  02: `[?]` offen
  klassenorganisation:53      kein Gremium über der Klasse           ↔  16: `[?]` offen
  ags-schema.sql:35           AGs bleiben Zukunftsprojekt            ↔  grenzkarte.md: „offen"

Dazu `anmeldung-schema.sql:543` („Die Schule hat bestätigt, dass es zwei
verschiedene Dinge sind") gegen den weißen Fleck in grenzkarte.md, der die Frage
noch stellt. Ob die Schule geantwortet hat, kann dieser Lauf nicht wissen — er
sieht nur, dass die Belegstelle fehlt und die Blöcke nicht mitgezogen wurden.
Solange das so bleibt, ist jedes dieser sechs `[?]` doppelt geführt: offen im
Block, geschlossen im Schema. Der teuerste Fall davon ist der erste, er steht
oben unter `putzdienst`.
Vorschlag: die Antworten in den jeweiligen Block schreiben und das `[?]` dort
schließen; das Schema verweist danach auf den Block statt auf ein Gespräch.
```

## Die `[A!]`-Marken

Sieben Stück, je eine Zeile — Domäne, Aussage, ob ein Block sie entscheidet.
Beide Läufe haben sie unabhängig aufgenommen und kommen zum selben Ergebnis.

- **stammdaten** · kein `updated_at`/`updated_by` auf irgendeiner Tabelle, die
  Änderungsspur trägt es. Kein Block entscheidet das; hebel.md verlangt einen
  Mechanismus, rules.md 1 verbietet den zweiten. Zu Recht offen.
- **stammdaten** · das SEPA-Mandat als eigene Tabelle mit Historie statt einer
  `payers`-Zeile. **Block 08 entscheidet es** („Das abgelöste Mandat bleibt mit
  seinem Unterschriftsdatum stehen"), und die Marke nennt ihn selbst — sie hält
  nur den Preis gegenüber grenzkarte.md Q3 fest. Kein Fund.
- **stammdaten** · der Anmeldecode bekommt eine Tabelle in Stammdaten. hebel.md
  nennt die fünf Zahlen, ohne einen Ort zu bestimmen. Zu Recht offen.
- **querschnitt** · Q1–Q5 in einer eigenen Datei statt in der ersten Domäne, die
  sie braucht. Kein Block entscheidet den Dateischnitt; grenzkarte.md Regel 4
  stützt ihn. Zu Recht offen.
- **querschnitt** · eine Signatur hängt am Vertragsvorgang, nicht am Dokument.
  **Block 08 entscheidet es** („Vor der Freigabe entsteht kein Dokument"), und
  die Marke nennt ihn. Kein Fund — an ihr hängt aber der Löschanker-Fund oben.
- **querschnitt** · der Bezug der Änderungsspur ist Tabellenname plus Schlüssel
  als Text, ohne Fremdschlüssel. Kein Block entscheidet das. Zu Recht offen —
  und genau an dieser Marke hängt der zweite Löschanker-Fund oben.
- **mensa** · eigene Tabellen statt der Betreuungsmodul-Struktur, gegen die eine
  Stelle, an der grenzkarte.md ausdrücklich zusammengelegt hat. **Block 11
  entscheidet es** mit drei eigenen Mechaniken, und die Marke zählt sie auf.
  Kein Fund.

Keine der sieben lässt etwas offen, das ein Block längst entscheidet — in beiden Läufen
übereinstimmend. Drei von ihnen (`sepa_mandates`, `signatures`, mensa) sind keine offenen
Fragen, sondern Entscheidungen mit benanntem Preis; die Marke hält dort den Verzicht fest,
nicht eine Lücke.

## Ohne Fund durchgekommen

`m365` und `klassenbildung` — zwei Domänen ohne Fund; `klassenbildung` mit dem
Vorbehalt, dass eine ihrer fünf Begründungen an `applications.class_placement_wish`
hängt. `elternbonus` stand nach Lauf 1 hier und ist mit dem Zitat-Fund aus Lauf 2
herausgefallen; inhaltlich trägt die Domäne, was 14 verlangt.

`ferien` hat der zweite Lauf unabhängig ohne Fund abgeschlossen — jede Zusage aus
„Was dabei erhoben wird" hat eine Spalte oder eine begründete Auslassung. Die beiden
Funde dort stammen allein aus Lauf 1, sind nachgelesen und bestätigt.
