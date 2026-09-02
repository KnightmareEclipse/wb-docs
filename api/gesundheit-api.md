# Gesundheit — Routen

Aus [`08-schulvertrag.md`](../soll-prozesse/08-schulvertrag.md) (der Bestand entsteht),
[`09-hortvertrag.md`](../soll-prozesse/09-hortvertrag.md) (externe Kinder, Masernnachweis) und
[`06-anmeldetag.md`](../soll-prozesse/06-anmeldetag.md) (Masernnachweis regulärer Kinder); es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht. Das Modell steht
in `schema/gesundheit-schema.sql` (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und
in `grenzkarte.md` („Zugriff, je Angabe"); beides wird hier nicht wiederholt, nur angewandt.

**Diese Domäne hat keinen eigenen Ablauf.** Sie liefert die Routen, die andere Blöcke an ihrer
Stelle referenzieren, ohne sie zu bauen — [`anmeldung-api.md`](anmeldung-api.md) und
[`ferien-api.md`](ferien-api.md) haben das so vorgesehen.

**Gegenprobe:** Die berührten Ablauftabellen tragen **3 Zeilen**, die im System handeln: 06 Z5
(Masernnachweis regulärer Kinder), 08 Z2 (Gesundheitsangaben beantworten oder ablehnen), 09 Z3
(externes Kind: beides zum ersten Mal). Alle drei haben hier eine Route. Es gibt **8 Routen**; **4**
nennen eine dieser Zeilen, **4** einen Hebel oder Abschnitt der Karte (`grenzkarte.md` „Zugriff, je
Angabe", [15](../soll-prozesse/15-klassenbildung.md) „Zwei Einsichten", das Gespräch mit der
Geschäftsführung vom 01.09.2026 für die Notfalleinsicht). Keine Abweichung.

## Zugriffsmodell

Sichtbarkeit hängt am **Paar aus Kategorie und Feld**, vergeben an einen **Sichtkreis**
(`health_field_visibility`). Sichtkreise überschneiden sich, ohne einander zu enthalten — es gibt
keine Stufen mehr, und keine Route entscheidet in einer Fallunterscheidung, welches Feld sie
ausliefert: **Jeder Sichtkreis ist eine Sicht in der Datenbank, an eine eigene DB-Rolle vergeben**,
und die Route liest durch die Sicht ihrer Rolle. Ein Feld, das der Sichtkreis nicht trägt, kommt
unter dieser Rolle gar nicht aus der Datenbank.

Sechs Sichtkreise, und **welche Rolle welchen bekommt, steht nur hier**:

| Sichtkreis (`code`) | Wer | Worauf eingeschränkt (welche Kinder) | DB-Rolle |
|---|---|---|---|
| **volle Akte** (`full`) | `secretariat`; `school_management`; Erziehungsberechtigte | Sekretariat unbeschränkt; Schulleitung nur ihre Schulart; Eltern nur die eigene Familie | `backend_health` |
| **Klassenleitung** (`class_lead`) | die Klassenlehrkraft (`classes.class_teacher_id`, keine `roles`-Zeile) | nur die Kinder der eigenen Klasse | `backend_health_class_lead` |
| **Betreuung** (`care`) | `day_care_staff`, `day_care_management` | nur Kinder mit laufendem Hortvertrag | `backend_health_care` |
| **Sport** (`sports`) | jede Rolle mit `teacher`, die für dieses Kind nicht Klassenlehrkraft ist | unbeschränkt über alle Kinder | `backend_health_sports` |
| **Küche** (`kitchen`) | `canteen`, `domestic_services_management` | über die Tagesliste ([`mensa-api.md`](mensa-api.md)) und die Teilnehmerliste ([`ferien-api.md`](ferien-api.md)), nie am einzelnen Kind | `backend_kitchen` |
| **Notfall** (`emergency`) | jede Mitarbeiterrolle | **jedes Kind**, ohne Zuständigkeit — dafür protokolliert | `backend_health_emergency` |

Was jeder Sichtkreis **enthält**, ist Konfiguration und steht begründet im Seed (`wb-backend`,
„value list seed", Abschnitt Gesundheit), nicht hier: Ein Feld dazu ist dort eine Zeile.

`[A]` **Sport steht für den Fachunterricht insgesamt.** Die einzige Fachlehrkraft, die ein Block
nennt, ist die des Sportunterrichts (`grenzkarte.md`), und bis die zweite Achse steht — Wahlmodul,
AG, Begleitung einer Veranstaltung (`backlog/`) — ist jede Lehrkraft ohne Klassenleitung für jedes
Kind Fachlehrkraft. Der Sichtkreis trägt deshalb die Handlungshinweise („Beachten") und Erlaubnisse,
nicht die Bezeichnungen. — Alternative: ein siebter Sichtkreis `teaching` mit der Alltagsliste aus
08 Z. 95 (Unverträglichkeit, Allergie, Notfallmedikation, Zeckenentfernung samt Bezeichnung); Preis:
genau die Stufe, die TASK-152 aus den Blöcken nimmt, lebte als Sichtkreis weiter, und die
Fachlehrkraft sähe Diagnosenamen, für die kein Block einen Grund nennt.

`[A]` **Die Eltern lesen die volle Akte ihres Kindes**, nicht einen Sichtkreis: Sie haben jede
Zeile selbst geschrieben. — Alternative: ein eigener Sichtkreis `guardian`; Preis: eine Zeile je
Paar, die immer alle Paare enthält.

**Zwei Angaben liegen neben den Sichtkreisen**, weil sie am Bestand und nicht am Merkmal stehen:

- **Der handlungsrelevante Hinweis** (`child_health_records.action_note`), von der
  Klassenlehrkraft formuliert, „den alle unterrichtenden Personen sehen" (`grenzkarte.md`): geht an
  `full` (Personal), `class_lead`, `sports` und `emergency`. Nicht an den Hort — er unterrichtet
  nicht — und nicht an die Eltern. — Alternative: ihn im Portal mitliefern; Preis: die fachliche
  Einschätzung der Klassenlehrkraft wird ein Feld, das sie der Familie gegenüber begründen muss.
  `backend_health_note` ist eine *Schreib*beschränkung; `backend_runtime` liest die Spalte
  tabellenweit.
- **Der Zustand je Kategorie** (`child_health_answers`: beantwortet, abgelehnt, nie gefragt) geht
  an jeden Sichtkreis für die Kategorien, von denen er mindestens ein Feld sieht. Er ist keine
  Angabe über das Kind, sondern darüber, ob eine vorliegt — und ohne ihn läse sich eine leere Liste
  als Entwarnung, „die eine Fehldeutung, die bei Art.-9-Daten wirklich schadet"
  (`schema/gesundheit-schema.sql`).

**Die Klassenlehrkraft ist keine `roles`-Zeile, sondern ein Ownership-Check** über
`classes.class_teacher_id` — dieselbe Mechanik wie in [`klassenorganisation-api.md`](klassenorganisation-api.md).
`class_lead` vor `sports`: Wer für dieses Kind die Klasse führt, bekommt den weiteren Kreis, und es
gibt keinen Fall, in dem der engere gewinnen soll.

**Was diese Domäne nicht selbst entscheidet:** Ob eine `school_management`- oder
`day_care_management`-Person überhaupt zu diesem Kind darf, prüft die Ownership-Spalte am Kind —
dieselbe Prüfung wie in jeder anderen Domäne. **Eine Rolle ohne Sichtkreis bekommt `404`, nicht
`403`** ([`gemeinsam.md`](gemeinsam.md#fehler)): `accounting` und `executive_management` erreichen
jedes Kind und sehen hier nichts.

## Pfad

Alles hängt am Kind, nicht an der Familie: Der Bestand ist „ein Bestand je Kind" (08). Vier Anker:

- `/children/{child_id}/health-record` — der Bestand: die vorgeschaltete Frage und alle Kategorien
  in einer Antwort; darunter `/answers/{trait_type_code}` für die Antwort einer Kategorie.
- `/children/{child_id}/health-note` — **eigener Pfad**: anderer Autor (Klassenlehrkraft statt
  Eltern), andere enge Rolle, eine eigene Handlung.
- `/children/{child_id}/emergency-accesses` — die Notfalleinsicht: eine Handlung, die eine
  Protokollzeile hinterlässt, deshalb `POST` und kein `GET` mit Nebenwirkung.
- `/children/{child_id}/measles-proof` — eigene Tabelle, eigener Anlass (§20 IfSG), eigener Autor.

Dazu ein Anker ohne Kind: `/health-questionnaire`, der Fragensatz — Kategorien, Felder, Wertarten
—, ohne den kein Formular weiß, was es fragt.

## Enge Rolle

**Sieben**, und sechs davon sind Sichtkreise. `backend_runtime` hält auf den vier Datentabellen
nur die Schlüssel- und Zustandsspalten (`*_id`, `health_trait_type_id`, `health_field_id`,
`value_kind_code`, `answered_at`, `declined_at`, `created_*`) und das `INSERT`/`DELETE`; die fünf
Wertspalten von `health_trait_values` liest **keine** Rolle an der Tabelle — sie kommen allein
durch die Sichten heraus. Schreiben tut `backend_runtime`: Die Eltern tragen selbst ein, die engen
Rollen sind Lesegrenzen.

- **Je Sichtkreis eine Sicht** `health_values_<code>` (Kind, Antwort, Merkmal, Feld, die fünf
  Wertspalten), gefiltert über `health_field_visibility` auf den einen Sichtkreis, `SELECT` an die
  DB-Rolle aus der Tabelle oben. Alle sechs entstehen aus **einer** Definition in der Migration,
  und die Vergabe an die Rolle ist ein `GRANT` — „wird über GRANTs vergeben"
  (`schema/gesundheit-schema.sql`). `[A]` Sichten je Sichtkreis, keine Policy: Die Zeilenfilterung
  per RLS ist TASK-157 und ein Urteil bei Tageslicht; bis dahin ist ein neuer Sichtkreis eine Zeile
  **und** eine Sicht. — Alternative: eine Sicht mit `scope_code`-Spalte und dem Sichtkreis als
  Parameter der Route; Preis: die Grenze läge im Anwendungscode, und dieselbe DB-Rolle könnte jeden
  Kreis lesen.
- **`backend_health_note`** — unverändert: `SELECT`, `INSERT`, `UPDATE` auf
  `child_health_records.action_note` samt Schlüssel, **kein `DELETE`**.
- **`backend_kitchen`** bekommt statt `kitchen_health_traits` die Sicht `health_values_kitchen`;
  `kitchen_health_traits` und `everyday_health_traits` bleiben als **abgeleitete Sichten** mit
  ihrer alten Form (`child_id, description`) stehen, damit Tagesliste und Teilnehmerliste
  unverändert lesen — `description` ist dort „Bezeichnung — Beachten" aus den Feldern, die der
  Kreis sieht. `[A]` Sie fallen mit TASK-157, wenn Mensa und Ferien auf die Policy umziehen. —
  Alternative: beide Router jetzt umbauen; Preis: zwei Domänen samt Tests in einem Durchgang, der
  dieser nicht ist.

## Der Bestand

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /health-questionnaire` — der Fragensatz: aktive Kategorien mit `allows_multiple`, je Kategorie ihre aktiven Felder mit Wertart | [08](../soll-prozesse/08-schulvertrag.md) Z2 — ohne die Fragen kein Formular | jede angemeldete Person | unbeschränkt; keine Personendaten | liest | — |
| `GET /children/{child_id}/health-record` — der Bestand: die vorgeschaltete Frage, je Kategorie ihr Zustand (`unasked`, `answered`, `declined`) und ihre Merkmale mit **genau den Feldern des Sichtkreises**, dazu Hinweis und (nur `full`, nur Personal) Masernnachweis | `grenzkarte.md` „Zugriff, je Angabe"; [09](../soll-prozesse/09-hortvertrag.md) „Hortkräfte den Alltag …"; [15](../soll-prozesse/15-klassenbildung.md) „Zwei Einsichten"; `grenzkarte.md` „schnell nachprüfbar" für den Masernnachweis | Erziehungsberechtigte; `secretariat`, `school_management`, `day_care_staff`, `day_care_management`, `teacher`; Klassenlehrkraft | wie die Tabelle oben; die Kategorienliste der Antwort trägt nur Kategorien, von denen der Sichtkreis ein Feld sieht. **Drei Zustände sichtbar unterschieden:** `answered` mit leerer Merkmalsliste heißt „nichts vorhanden", `declined` heißt „will nicht sagen", `unasked` heißt „nie gefragt" — der Normalfall über Monate, weil der Bestand von Hand nachgetragen wird (`soll-prozesse/README.md`, „Nacharbeit"). Der Masernnachweis steht nur Personal der vollen Sicht offen | liest | die Sicht des Sichtkreises |
| `PUT /children/{child_id}/health-record` — die vorgeschaltete Frage: beantworten oder ausdrücklich ablehnen | [08](../soll-prozesse/08-schulvertrag.md) Z2, „ändern die Eltern danach jederzeit im Portal — hier, nicht in 02"; [09](../soll-prozesse/09-hortvertrag.md) Z3 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie, nach [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) **nur „voll"**. Setzt `answered_at` **oder** `declined_at`. **`beantwortet` ist der Abschluss der Erhebung und trägt die eine Regel, die die Datenbank nicht halten kann:** Jede aktive Kategorie muss eine Antwortzeile haben — beantwortet oder abgelehnt. Fehlt eine, antwortet die Route `400` und **nennt die Kategorie**; nichts wird geschrieben. Ablehnen ist jederzeit möglich und rührt vorhandene Zeilen nicht an. `[A]` Die Vollständigkeit heißt „jede Kategorie beantwortet", nicht „jedes Feld gefüllt": Die Tiefe je Merkmal wählen die Eltern selbst („selber entscheiden, wie tief"), eine Kategorie ohne Antwort dagegen ist eine vergessene Frage. — Alternative: je Feld eine Pflicht; Preis: ein `is_required` am Paar, und damit der Formularbaukasten, den das Schema ausdrücklich nicht baut | schreibt, `guardian:`/`entra:` | — |
| `PUT /children/{child_id}/health-record/answers/{trait_type_code}` — **eine Kategorie am Stück**: `declined`, oder `answered` mit der vollständigen Liste ihrer Merkmale, je Merkmal die Werte je Feld (`{feldcode: wert}`) | [08](../soll-prozesse/08-schulvertrag.md) Z2; [09](../soll-prozesse/09-hortvertrag.md) Z3; das Gespräch vom 01.09.2026 („je Kategorie freiwillig und in der Tiefe wählbar") | Erziehungsberechtigte (voll); `secretariat` (Umweg) | eigene Familie. Legt den Bestand an, wenn es ihn noch nicht gibt — noch unbeantwortet, der Abschluss ist die Route darüber. **Ersetzt** die Merkmale der Kategorie: Ein Merkmal mit `health_trait_id` bleibt dieselbe Zeile (die Änderungsspur trägt dann die Änderung, nicht Löschen und Neuanlage), eines ohne entsteht, eines, das im Rumpf fehlt, wird gelöscht — Zeile für Zeile, keine Massenoperation ([`gemeinsam.md`](gemeinsam.md#schreiben)). Was die Datenbank prüft, prüft die Route nicht noch einmal: Feld an der falschen Kategorie, Wert in der falschen Art, zweite Zeile einer Kategorie mit `allows_multiple = false`, leerer Text — jede dieser Verletzungen wird als `400` mit dem Feldnamen beantwortet, nicht als 500. **Ein Merkmal ohne einen einzigen Wert ist keines** und wird abgewiesen — die eine Regel, die kein CHECK sieht, weil ein fehlender Wert eine fehlende Zeile ist. `[A]` Der Fragensatz einer Kategorie wird am Stück geschrieben, nicht der Wert einzeln: Die Kategorie ist, was die Eltern als eine Frage sehen, und ein Abbruch nach der Hälfte darf keine halbe Allergie hinterlassen. — Alternative: `PUT` je Wert; Preis: die Vollständigkeit eines Merkmals ist dann nie prüfbar, und der Ablauf steht im Frontend | schreibt, `guardian:`/`entra:` | — |
| `PUT /children/{child_id}/health-note` — den handlungsrelevanten Hinweis setzen oder leeren | `grenzkarte.md` „Zugriff, je Angabe" | Klassenlehrkraft der eigenen Klasse | nur die eigene Klasse; **kein Umweg** — der Hinweis ist ihre fachliche Einschätzung, keine Verwaltungsangabe | schreibt, `entra:` | `backend_health_note` |
| `POST /children/{child_id}/emergency-accesses` — die Notfalleinsicht: liefert den Notfallausschnitt **und schreibt dabei die Protokollzeile** | das Gespräch mit der Geschäftsführung vom 01.09.2026 („eine Taste bei dem Schüler"); `grenzkarte.md` „im Notfall" | **jede Mitarbeiterrolle** | **jedes Kind**, auch der anderen Schulart, auch ein externes Hortkind: Die Zuständigkeitsprüfung entfällt hier ausdrücklich, an ihre Stelle tritt `health_emergency_accesses`. Antwort: die Felder des Sichtkreises `emergency` mit ihren Zuständen je Kategorie, der Hinweis der Klassenlehrkraft, **und die Notfallkontakte der Familie** (`family_contacts.is_emergency_contact`, [02](../soll-prozesse/02-datenaenderung.md)) mit Telefonnummer — die vier Dinge aus `pruefberichte/fragen-datenschutz.txt`, Frage 5. Keine Eltern: „Eltern haben diesen Weg nicht" (`ck_health_emergency_accesses_created_by`). **Keine Begründung im Rumpf**, die Route nimmt keinen Rumpf an. `[A]` Der Notfallkontakt kommt mit, obwohl er den Stammdaten gehört: Wer im Notfall auf die Taste drückt, ruft danach an, und ein zweiter Aufruf einer Stammdaten-Route, den die Rolle vielleicht gar nicht darf, ist im einzigen Moment, der zählt, das falsche Bauteil. — Alternative: nur der Gesundheitsausschnitt; Preis: die Fachlehrkraft ohne Zuständigkeit kommt an die Nummer nicht heran | schreibt (das Protokoll) und liest, `entra:` | `backend_health_emergency` |
| `PUT /children/{child_id}/measles-proof` — Vorlagedatum und -art eintragen oder ersetzen | [06](../soll-prozesse/06-anmeldetag.md) Z5; [09](../soll-prozesse/09-hortvertrag.md) Z3 (externes Kind) | `secretariat` | unbeschränkt; **keine Elternroute** — kein Block lässt die Familie selbst eintragen. Eine Zeile je Kind (`uq_measles_proofs`), ein erneuter `PUT` ersetzt sie | schreibt, `entra:` | — |

**Das Attest ist kein Upload dieser Datei.** Ein Feld der Wertart `document` trägt die
`document_id` aus der generischen Dokumentablage (`PUT /documents`,
[`stammdaten-api.md`](stammdaten-api.md)); die Route prüft, dass das Dokument diesem Kind gehört.

**Die Erlaubnis („darf die Schule handeln") ist ein Feld der Wertart `bool`** und wird mit
derselben Kategorie-Route gesetzt — kein zweiter Signaturweg, „ein mitten im Schuljahr ergänztes
Notfallmedikament hat kein unterschriebenes Blatt" (`hebel.md`). Erteilt und verweigert sind der
Wert, „nicht gefragt" ist die fehlende Zeile (`schema/gesundheit-schema.sql`).

**Löschen, nicht datieren:** Ein Merkmal, das nicht mehr zutrifft, fehlt in der nächsten
Kategorie-Antwort und wird damit gelöscht — „bei Art.-9-Daten wird ein nicht mehr zutreffendes
Merkmal gelöscht statt datiert".

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Die Konfiguration selbst** — Kategorien, Felder, Zuordnungen, Sichtkreise — hat keine Route:
  Kein Block nennt eine Stelle, die sie im Betrieb pflegt; sie kommt als Seed (TASK-158) und
  ändert sich mit einer Migration.
- **Die Freigabe des Bestands für ein Ferienprogramm** (10) ist eine Ferien-Route
  ([`ferien-api.md`](ferien-api.md)); was die Betreuung dann sieht, ist der Sichtkreis `care`.
- **Der Erhebungsanlass** — welche Kategorie aus welchem Vorgang stammt, samt eigener Frist — ist
  nicht gebaut (`schema/gesundheit-schema.sql`, offene Fragen); bis dahin fragt der Abschluss alle
  aktiven Kategorien.
- **Die zweite Achse** — von welchen Kindern eine Fachlehrkraft liest — bleibt bei Klasse,
  Betreuungsvertrag und Familie (TASK-157).
- **Wer das Notfallprotokoll ansieht und wie lange es bleibt** — beim Datenschutzbeauftragten
  (`pruefberichte/fragen-datenschutz.txt`, Frage 5); bis dahin hat es keine Leseroute.
- **Die Betreuungsliste der Hortleitung** trägt weiterhin keinen Gesundheits-Ausschnitt (09).
- **Die Aufgabe aus dem fehlenden Masernnachweis** (`measles_report`) —
  [`anmeldung-api.md`](anmeldung-api.md), liest `measles_proofs` direkt.
- **Die Löschung** — kein eigener Lauf, der ganze Bestand hängt per Cascade am Kind (03).
- **Die Änderungsspur** — [`querschnitt-api.md`](querschnitt-api.md); die Wertspalten erreichen
  sie als `<protected>`, wie jede geschützte Spalte.

## Korrigiert an anderer Stelle

- [`ferien-api.md`](ferien-api.md): Die Teilnehmerliste liest den Sichtkreis `care` über
  `backend_health_care` statt „die Alltagsmerkmale über `backend_health_everyday`".
- [`mensa-api.md`](mensa-api.md): `kitchen_health_traits` ist eine abgeleitete Sicht des
  Sichtkreises `kitchen`, und die Küche sieht, was dieser Sichtkreis trägt — Bezeichnung und
  Beachten von Unverträglichkeit und Allergie.

## Offene Fragen

Keine neuen. Die Aufbewahrungsfrist des Bestands steht fest (`schema/gesundheit-schema.sql`,
Dateikopf); die des Notfallprotokolls liegt beim Datenschutzbeauftragten (dort, offene Fragen).
