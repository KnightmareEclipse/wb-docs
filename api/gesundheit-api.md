# Gesundheit — Routen

Aus [`08-schulvertrag.md`](../soll-prozesse/08-schulvertrag.md) (der Bestand entsteht),
[`09-hortvertrag.md`](../soll-prozesse/09-hortvertrag.md) (externe Kinder, Masernnachweis) und
[`06-anmeldetag.md`](../soll-prozesse/06-anmeldetag.md) (Masernnachweis regulärer Kinder); es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht. Das Modell steht
in `schema/gesundheit-schema.sql` (Dateikopf, „Warum eine Zeile je Feld und nicht je Merkmal") und
in `grenzkarte.md` („Zugriff, drei Bedingungen"); beides wird hier nicht wiederholt, nur angewandt.

**Diese Domäne hat keinen eigenen Ablauf.** Sie liefert die Routen, die andere Blöcke an ihrer
Stelle referenzieren, ohne sie zu bauen — [`anmeldung-api.md`](anmeldung-api.md) und
[`ferien-api.md`](ferien-api.md) haben das so vorgesehen.

**Gegenprobe:** Die berührten Ablauftabellen tragen **3 Zeilen**, die im System handeln: 06 Z5
(Masernnachweis regulärer Kinder), 08 Z2 (Gesundheitsangaben beantworten oder ablehnen), 09 Z3
(externes Kind: beides zum ersten Mal). Alle drei haben hier eine Route. Es gibt **8 Routen**; **4**
nennen eine dieser Zeilen, **4** einen Hebel oder Abschnitt der Karte (`grenzkarte.md` „Zugriff, je
Angabe", [15](../soll-prozesse/15-klassenbildung.md) „Hier entsteht, von welchen Kindern jemand
liest", das Gespräch mit der
Geschäftsführung vom 01.09.2026 für die Notfalleinsicht). Keine Abweichung.

## Zugriffsmodell

Sichtbarkeit ist ein **Schnitt aus drei Bedingungen**, und alle drei sind Zeilen:

1. **Trägt der Sichtkreis das Feld?** — `health_field_visibility`, je Paar aus Kategorie und Feld,
   samt `presence_only` für das Attest. **Der Notfallausschnitt steht dort nicht** und ist auch
   nicht dort einzutragen (`ck_health_field_visibility_emergency`): Er sieht jedes Feld jeder
   Kategorie, und eine Zeilenmenge dafür wäre eine Vollständigkeit, die niemand hält.
2. **Ist die Angabe dieser Instanz freigegeben?** — `health_trait_releases`, je Angabe und
   Sichtkreis. Der Notfallausschnitt übergeht sie ausdrücklich, die Küche erbt die Freigabe der
   Liste, auf der das Kind steht.
3. **Ist die aufrufende Person für dieses Kind zuständig?** — die zweite Achse
   (`schema/klassenorganisation-schema.sql`): Klassenleitung, Unterricht in seiner Klasse, oder eine
   Wahlmodulgruppe, in der es Mitglied ist.

Keine Route entscheidet in einer Fallunterscheidung, welches Feld sie ausliefert: **Jeder Sichtkreis
ist eine Sicht in der Datenbank, an eine eigene DB-Rolle vergeben**, und die Route liest durch die
Sicht ihrer Rolle. Ein Feld, das der Sichtkreis nicht trägt, kommt unter dieser Rolle gar nicht aus
der Datenbank.

Fünf Sichtkreise, und **welche Rolle welchen bekommt, steht nur hier**:

| Sichtkreis (`code`) | Wer | Worauf eingeschränkt (welche Kinder) | DB-Rolle |
|---|---|---|---|
| **volle Akte** (`full`) | `secretariat`; `school_management`; Erziehungsberechtigte | Sekretariat unbeschränkt; Schulleitung nur ihre Schulart; Eltern nur die eigene Familie | `backend_health` |
| **Schule** (`school`) | die Klassenlehrkraft (`classes.class_teacher_id`, keine `roles`-Zeile) und jede Rolle mit `teacher` | nur die Kinder, für die sie zuständig ist — zweite Achse | `backend_health_school` |
| **Betreuung** (`care`) | `day_care_staff`, `day_care_management` | nur Kinder mit laufendem Hortvertrag | `backend_health_care` |
| **Küche** (`kitchen`) | `canteen`, `domestic_services_management` | über die Tagesliste ([`mensa-api.md`](mensa-api.md)) und die Teilnehmerliste ([`ferien-api.md`](ferien-api.md)), nie am einzelnen Kind | `backend_kitchen` |
| **Notfall** (`emergency`) | jede Mitarbeiterrolle | **jedes Kind**, ohne Zuständigkeit — dafür protokolliert; und **jedes Feld**, ohne Freigabe | `backend_health_emergency` |

Was jeder Sichtkreis **enthält**, ist Konfiguration und steht begründet im Seed (`wb-backend`,
„value list seed", Abschnitt Gesundheit), nicht hier: Ein Feld dazu ist dort eine Zeile. Die Matrix
trägt seit dem groben Schnitt vom 02.09.2026 nur noch **zwei** echte Unterscheidungen — die Küche
auf Unverträglichkeit und Allergie, und das Attest als bloßes Vorliegen —; alles Übrige steht
Lehrkräften und Hort offen.

**`care` bleibt trotz derselben Felder ein eigener Sichtkreis**, und der Grund ist nicht die Matrix,
sondern die Freigabe: Schule und Hort sind zwei Instanzen desselben Bestands, die Eltern entscheiden
je Instanz, und derselbe Sichtkreis für beide könnte das nicht auseinanderhalten.

**Das Attest kommt für `school` und `care` nur als Vorliegen heraus** (`presence_only`): Die Sicht
liefert statt der `document_id`, ob eine hinterlegt ist. `full` behält es im Klartext — sonst könnte
das Sekretariat den Abgleich zwischen Elternangabe und Attest nicht führen, den der
Datenschutzbeauftragte am 02.09.2026 verlangt hat. Ein Prüfzustand entsteht daraus nicht: Weicht das
Attest ab, ändert das Sekretariat den Wert, und die Spur trägt die Änderungsspur.

`[A]` **Die Eltern lesen die volle Akte ihres Kindes**, nicht einen Sichtkreis: Sie haben jede
Zeile selbst geschrieben. — Alternative: ein eigener Sichtkreis `guardian`; Preis: eine Zeile je
Paar, die immer alle Paare enthält.

**Zwei Angaben liegen neben den Sichtkreisen**, weil sie am Bestand und nicht am Merkmal stehen:

- **Der handlungsrelevante Hinweis** (`child_health_action_notes`) steht **je Sichtkreis**, seit
  der Hort ihn ebenfalls braucht (Geschäftsführung, 04.09.2026): Die Klassenlehrkraft formuliert
  den für `school`, „den alle unterrichtenden Personen sehen" (`grenzkarte.md`), die Hortleitung
  den für `care`. Gelesen wird der eigene, dazu von `full` (Personal) und `emergency` jeder. **Der
  frühere Satz „nicht an den Hort — er unterrichtet nicht" ist damit überholt:** Der Hort hat das
  Kind stundenlang und oft draußen, und er hakt seine Tagesliste auf Papier ab, auf der genau
  dieser Satz als Marke erscheint ([09](../soll-prozesse/09-hortvertrag.md)). Nicht an die Eltern,
  und nicht von ihnen. — Alternative: ein Hinweis für beide Kreise; Preis: zwei Verfasser mit
  verschiedenem Alltag überschreiben einander lautlos, und für ein externes Hortkind bliebe er
  leer, weil es keine Klassenlehrkraft hat.
  `backend_health_note` ist eine *Schreib*beschränkung; `backend_runtime` liest die Tabelle
  tabellenweit.
- **Der Zustand je Kategorie** (`child_health_answers`: beantwortet, abgelehnt, nie gefragt) geht
  an jeden Sichtkreis für die Kategorien, von denen er mindestens ein Feld sieht. Er ist keine
  Angabe über das Kind, sondern darüber, ob eine vorliegt — und ohne ihn läse sich eine leere Liste
  als Entwarnung, „die eine Fehldeutung, die bei Art.-9-Daten wirklich schadet"
  (`schema/gesundheit-schema.sql`).

**Zuständig für ein Kind ist, wer es unterrichtet** — Klassenleitung
(`classes.class_teacher_id`), Unterricht in seiner Klasse (`class_teaching_assignments`) oder seine
Wahlmodulgruppe (`child_group_memberships`). Alle drei sind Ownership-Checks und keine `roles`-Zeile,
dieselbe Mechanik wie in [`klassenorganisation-api.md`](klassenorganisation-api.md). Eine Rangfolge
zwischen ihnen gibt es nicht mehr: Sie führen zum selben Sichtkreis und unterscheiden sich nur
darin, **welche** Kinder sie erreichen. **Fehlt jede Zuordnung, ist die Antwort `404`** — die
Fehlerrichtung ist „nichts", nicht „alles".

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

**Sechs**, und fünf davon sind Sichtkreise. `backend_runtime` hält auf den vier Datentabellen
nur die Schlüssel- und Zustandsspalten (`*_id`, `health_trait_type_id`, `health_field_id`,
`value_kind_code`, `answered_at`, `declined_at`, `created_*`) und das `INSERT`/`DELETE`; die fünf
Wertspalten von `health_trait_values` liest **keine** Rolle an der Tabelle — sie kommen allein
durch die Sichten heraus. Schreiben tut `backend_runtime`: Die Eltern tragen selbst ein, die engen
Rollen sind Lesegrenzen.

- **Je Sichtkreis eine Sicht** `health_values_<code>` (Kind, Antwort, Merkmal, Feld, die fünf
  Wertspalten), gefiltert über `health_field_visibility` auf den einen Sichtkreis, `SELECT` an die
  DB-Rolle aus der Tabelle oben. **`health_values_emergency` ist die Ausnahme und filtert nicht**:
  Sie liefert jedes Feld und reduziert allein die Dokumentwerte auf ihr Vorliegen — die zwei
  Auflagen vom 02.09.2026 in einer Sicht. Die übrigen vier entstehen aus **einer** Definition in der Migration,
  und die Vergabe an die Rolle ist ein `GRANT` — „wird über GRANTs vergeben"
  (`schema/gesundheit-schema.sql`). Die Sicht leert dabei die `document_id`, wo
  `health_field_visibility.presence_only` gesetzt ist, und liefert an ihrer Stelle nur, dass eine
  hinterlegt ist: RLS filtert Zeilen und keine Spalten, das muss also die Sicht tun. `[A]` Sichten
  je Sichtkreis, keine Policy: Die Zeilenfilterung per RLS ist TASK-157 und ein Urteil bei
  Tageslicht; bis dahin ist ein neuer Sichtkreis eine Zeile **und** eine Sicht. — Alternative: eine
  Sicht mit `scope_code`-Spalte und dem Sichtkreis als Parameter der Route; Preis: die Grenze läge
  im Anwendungscode, und dieselbe DB-Rolle könnte jeden Kreis lesen.
- **`backend_health_note`** — `SELECT`, `INSERT`, `UPDATE` auf `child_health_action_notes`,
  **kein `DELETE`**. Welche Zeile eine Rolle schreiben darf, entscheidet ihr Sichtkreis und nicht
  dieses GRANT: Die Hortleitung schreibt den für `care`, die Klassenlehrkraft den für `school`.
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
| `GET /children/{child_id}/health-record` — der Bestand: die vorgeschaltete Frage, je Kategorie ihr Zustand (`unasked`, `answered`, `declined`) und ihre Merkmale mit **genau den Feldern des Sichtkreises**, dazu Hinweis und (nur `full`, nur Personal) Masernnachweis | `grenzkarte.md` „Zugriff, drei Bedingungen"; [09](../soll-prozesse/09-hortvertrag.md) „Der Hort ist dabei eine eigene Instanz dieses einen Bestands"; [15](../soll-prozesse/15-klassenbildung.md) „Hier entsteht, von welchen Kindern jemand liest"; `grenzkarte.md` „schnell nachprüfbar" für den Masernnachweis | Erziehungsberechtigte; `secretariat`, `school_management`, `day_care_staff`, `day_care_management`, `teacher`; Klassenlehrkraft | wie die Tabelle oben, und zusätzlich die zwei Bedingungen aus dem Zugriffsmodell: nur Kinder, für die die Person zuständig ist, und je Angabe nur, was diesem Sichtkreis freigegeben ist — beides ausgenommen beim Notfallausschnitt, der über die eigene Route läuft. Die Kategorienliste der Antwort trägt nur Kategorien, von denen der Sichtkreis ein Feld sieht. **Drei Zustände sichtbar unterschieden:** `answered` mit leerer Merkmalsliste heißt „nichts vorhanden", `declined` heißt „will nicht sagen", `unasked` heißt „nie gefragt" — der Normalfall über Monate, weil der Bestand von Hand nachgetragen wird (`soll-prozesse/README.md`, „Nacharbeit"). Der Masernnachweis steht nur Personal der vollen Sicht offen | liest | die Sicht des Sichtkreises |
| `PUT /children/{child_id}/health-record` — die vorgeschaltete Frage: beantworten oder ausdrücklich ablehnen | [08](../soll-prozesse/08-schulvertrag.md) Z2, „ändern die Eltern danach jederzeit im Portal — hier, nicht in 02"; [09](../soll-prozesse/09-hortvertrag.md) Z3 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie, nach [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) **nur „voll"**. Setzt `answered_at` **oder** `declined_at`. **`beantwortet` ist der Abschluss der Erhebung und trägt die eine Regel, die die Datenbank nicht halten kann:** Jede aktive Kategorie muss eine Antwortzeile haben — beantwortet oder abgelehnt. Fehlt eine, antwortet die Route `400` und **nennt die Kategorie**; nichts wird geschrieben. Ablehnen ist jederzeit möglich und rührt vorhandene Zeilen nicht an. `[A]` Die Vollständigkeit heißt „jede Kategorie beantwortet", nicht „jedes Feld gefüllt": Die Tiefe je Merkmal wählen die Eltern selbst („selber entscheiden, wie tief"), eine Kategorie ohne Antwort dagegen ist eine vergessene Frage. — Alternative: je Feld eine Pflicht; Preis: ein `is_required` am Paar, und damit der Formularbaukasten, den das Schema ausdrücklich nicht baut | schreibt, `guardian:`/`entra:` | — |
| `PUT /children/{child_id}/health-record/answers/{trait_type_code}` — **eine Kategorie am Stück**: `declined`, oder `answered` mit der vollständigen Liste ihrer Merkmale, je Merkmal die Werte je Feld (`{feldcode: wert}`) | [08](../soll-prozesse/08-schulvertrag.md) Z2; [09](../soll-prozesse/09-hortvertrag.md) Z3; das Gespräch vom 01.09.2026 („je Kategorie freiwillig und in der Tiefe wählbar") | Erziehungsberechtigte (voll); `secretariat` (Umweg) | eigene Familie. Legt den Bestand an, wenn es ihn noch nicht gibt — noch unbeantwortet, der Abschluss ist die Route darüber. **Ersetzt** die Merkmale der Kategorie: Ein Merkmal mit `health_trait_id` bleibt dieselbe Zeile (die Änderungsspur trägt dann die Änderung, nicht Löschen und Neuanlage), eines ohne entsteht, eines, das im Rumpf fehlt, wird gelöscht — Zeile für Zeile, keine Massenoperation ([`gemeinsam.md`](gemeinsam.md#schreiben)). Was die Datenbank prüft, prüft die Route nicht noch einmal: Feld an der falschen Kategorie, Wert in der falschen Art, zweite Zeile einer Kategorie mit `allows_multiple = false`, leerer Text — jede dieser Verletzungen wird als `400` mit dem Feldnamen beantwortet, nicht als 500. **Ein Merkmal ohne einen einzigen Wert ist keines** und wird abgewiesen — die eine Regel, die kein CHECK sieht, weil ein fehlender Wert eine fehlende Zeile ist. `[A]` Der Fragensatz einer Kategorie wird am Stück geschrieben, nicht der Wert einzeln: Die Kategorie ist, was die Eltern als eine Frage sehen, und ein Abbruch nach der Hälfte darf keine halbe Allergie hinterlassen. — Alternative: `PUT` je Wert; Preis: die Vollständigkeit eines Merkmals ist dann nie prüfbar, und der Ablauf steht im Frontend | schreibt, `guardian:`/`entra:` | — |
| `PUT /children/{child_id}/health-note` — den handlungsrelevanten Hinweis setzen oder leeren | `grenzkarte.md` „Zugriff, drei Bedingungen" | Klassenlehrkraft der eigenen Klasse | nur die eigene Klasse; **kein Umweg** — der Hinweis ist ihre fachliche Einschätzung, keine Verwaltungsangabe | schreibt, `entra:` | `backend_health_note` |
| `POST /children/{child_id}/emergency-accesses` — die Notfalleinsicht: liefert den Notfallausschnitt **und schreibt dabei die Protokollzeile** | das Gespräch mit der Geschäftsführung vom 01.09.2026 („eine Taste bei dem Schüler"); `grenzkarte.md` „im Notfall" | **jede Mitarbeiterrolle** | **jedes Kind**, auch der anderen Schulart, auch ein externes Hortkind: Die Zuständigkeitsprüfung entfällt hier ausdrücklich, an ihre Stelle tritt `health_emergency_accesses`. Antwort: **jedes Feld jeder Kategorie** — das Attest davon als Vorliegen und nicht als Datei — mit ihren Zuständen je Kategorie, der Hinweis der Klassenlehrkraft, **und die Notfallkontakte der Familie** (`family_contacts.is_emergency_contact`, [02](../soll-prozesse/02-datenaenderung.md)) mit Telefonnummer — die vier Dinge aus `pruefberichte/fragen-datenschutz.txt`, Frage 5. Keine Eltern: „Eltern haben diesen Weg nicht" (`ck_health_emergency_accesses_created_by`). **Keine Begründung im Rumpf**, die Route nimmt keinen Rumpf an. `[A]` Der Notfallkontakt kommt mit, obwohl er den Stammdaten gehört: Wer im Notfall auf die Taste drückt, ruft danach an, und ein zweiter Aufruf einer Stammdaten-Route, den die Rolle vielleicht gar nicht darf, ist im einzigen Moment, der zählt, das falsche Bauteil. — Alternative: nur der Gesundheitsausschnitt; Preis: die Fachlehrkraft ohne Zuständigkeit kommt an die Nummer nicht heran | schreibt (das Protokoll) und liest, `entra:` | `backend_health_emergency` |
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
- **Der Erhebungsanlass** ist der Sichtkreis, an den freigegeben wird; was fehlt, ist der
  Anlassgeber — die Domäne der außerunterrichtlichen Veranstaltungen legt die Instanz an
  (`schema/gesundheit-schema.sql`, offene Fragen). Bis dahin fragt der Abschluss alle aktiven
  Kategorien.
- **Die zweite Achse steht** (`schema/klassenorganisation-schema.sql`), die **Policy dazu nicht**:
  Bis TASK-157 sie baut, filtert jede Sicht allein über den Sichtkreis, und Zuständigkeit wie
  Freigabe prüft die Route.
- **Die Freigabe je Instanz** (`child_health_releases`, `health_trait_releases`) hat noch **keine
  Schreibroute**: Sie entsteht im Durchgang, der auch die Oberfläche der zweiten Anmeldung trägt
  (TASK-163), und ist ohne die Policy ohnehin nur halb wirksam.
- **Das Notfallprotokoll hat keine Leseroute.** Wer es ansieht, steht fest — die Geschäftsführung,
  gemeldet je Betätigung —, und wie lange es bleibt auch: Es geht mit dem Kind
  (`schema/gesundheit-schema.sql`). Die Route dazu ist nicht geplant.
- **Die Betreuungsliste der Hortleitung** trägt weiterhin keinen Gesundheits-Ausschnitt (09).
- **Die Aufgabe aus dem fehlenden Masernnachweis** (`measles_report`) —
  [`anmeldung-api.md`](anmeldung-api.md), liest `measles_proofs` direkt.
- **Die Löschung** — kein eigener Lauf, der ganze Bestand hängt per Cascade am Kind (03).
- **Die Änderungsspur** — [`querschnitt-api.md`](querschnitt-api.md); die Wertspalten erreichen
  sie als `<protected>`, wie jede geschützte Spalte.

## Korrigiert an anderer Stelle

- [`ferien-api.md`](ferien-api.md): Die Teilnehmerliste liest den Sichtkreis `care` über
  `backend_health_care` statt „die Alltagsmerkmale über `backend_health_everyday`".
- `wb-backend`: `backend_health_class_lead` und `backend_health_sports` verschmelzen zu
  `backend_health_school`; der Sichtkreis `sports` und seine Seed-Zeilen entfallen, `full` bekommt
  eine Seed-Zeile für das Attest im Klartext, und jede Sichtbarkeitszeile trägt jetzt ihre Wertart.
- [`mensa-api.md`](mensa-api.md): `kitchen_health_traits` ist eine abgeleitete Sicht des
  Sichtkreises `kitchen`, und die Küche sieht, was dieser Sichtkreis trägt — Bezeichnung und
  Beachten von Unverträglichkeit und Allergie.

## Offene Fragen

Keine. Die Aufbewahrungsfrist des Bestands steht fest, die des Notfallprotokolls ebenso — beide in
`schema/gesundheit-schema.sql`.
