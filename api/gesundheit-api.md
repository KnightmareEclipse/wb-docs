# Gesundheit — Routen

Aus [`08-schulvertrag.md`](../soll-prozesse/08-schulvertrag.md) (der Bestand entsteht),
[`09-hortvertrag.md`](../soll-prozesse/09-hortvertrag.md) (externe Kinder, Masernnachweis) und
[`06-anmeldetag.md`](../soll-prozesse/06-anmeldetag.md) (Masernnachweis regulärer Kinder); es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht.

**Diese Domäne hat keinen eigenen Ablauf.** Sie liefert die Routen, die andere Blöcke an ihrer
Stelle referenzieren, ohne sie zu bauen — [`anmeldung-api.md`](anmeldung-api.md) („Enge Rolle") und
[`ferien-api.md`](ferien-api.md) („Enge Rolle") haben das bereits so vorgesehen: „ihre Routen
entstehen mit dieser Domäne", „was das je Rolle ist, entscheidet die Gesundheits-Domäne".

**Gegenprobe:** Die berührten Ablauftabellen tragen **3 Zeilen**, die im System handeln: 06 Z5
(Masernnachweis regulärer Kinder), 08 Z2 (Gesundheitsangaben beantworten oder ablehnen), 09 Z3
(externes Kind: beides zum ersten Mal). Alle drei haben hier eine Route. Es gibt **7 Routen**; **3**
nennen eine dieser Zeilen, **4** einen Hebel oder Abschnitt der Karte
([`grenzkarte.md`](../grenzkarte.md) „Zugriff, zweistufig", [15](../soll-prozesse/15-klassenbildung.md)
„Zwei Einsichten"). Keine Abweichung.

## Zugriffsmodell

Der Bestand hat **vier** Sichten, keine deckungsgleich, alle über dieselbe Route ausgeliefert
(unten) und nie über eine Filterung im Anwendungscode:

| Sicht | Wer | Was | Träger |
|---|---|---|---|
| **Voll** | `secretariat`, `school_management` (eigene Schulart), Klassenlehrkraft (eigene Klasse) | alles: Merkmal, Beschreibung, Behandlungsgrund und -zeitraum, Attestlage, Erlaubnis | `backend_health` |
| **Alltag** | `day_care_staff`, `day_care_management` (betreute Kinder) | nur `is_everyday_relevant`-Merkmale — Unverträglichkeit, Allergie, Notfallmedikation samt Erlaubnis, Zeckenentfernung, ohne Diagnose, Behandlungsgrund oder Attestlage | `backend_health_everyday`, über die View `everyday_health_traits` |
| **Küche** | `canteen` | nur `is_kitchen_relevant` (Unverträglichkeit, Allergie) | bereits gebaut: `kitchen_health_traits` ([`mensa-api.md`](mensa-api.md)) |
| **Hinweis** | jede Rolle mit `teacher` | ausschließlich `child_health_records.action_note` | `backend_health_note` |

Die vier sind konzentrisch bis auf den Hinweis, der ein anderes Feld trägt und nicht dieselbe
Spalte enger sieht. `[A!]` **Der Hort bekommt die Alltags-Sicht, nicht die volle** —
[09](../soll-prozesse/09-hortvertrag.md) sagt es direkt: „Hortkräfte den Alltag, Sekretariat und
Schulleitung auch Diagnose und Attestlage". Das widerspricht zwei älteren Stellen: `grenzkarte.md`
„Zugriff, zweistufig" zählt den Hort noch zur vollen Sicht, und `ferien-api.md` hat vorsorglich
„der Hort sieht den vollen Satz (`backend_health`)" angenommen, bevor diese Domäne entschied. Der
Block ist jünger und schlägt beide (`CLAUDE.md`-Rangfolge, dieselbe Reihenfolge wie bei der
Kochwerkstatt-Korrektur). — Alternative: dem Hort die volle Sicht lassen; Preis: `health_traits`
über Diagnose und Behandlungsgrund läge damit einer Rolle offen, für die kein Block das begründet,
und genau das ist die Über-Offenlegung, die die Karte selbst als Grund für die zweite Spalte nennt.
`grenzkarte.md` und `ferien-api.md` sind mit dieser Datei korrigiert (unten).

**`teacher` ist keine neue Rolle** — sie steht bereits im `roles`-Seed und als `TEACHER_ROLE` in
`wb-backend/app/core/security.py`, gebaut für dieselbe Frage an `GET /children/{child_id}`
(`stammdaten-api.md`, „everyday_only"). Sie ist unbeschränkt über alle Kinder, weil es „eine
Zuordnung Lehrkraft↔Unterricht … nicht [gibt] — die lebt in Untis" (`glossar.md`) und der Hinweis
genau deshalb schmal gehalten ist. Diese Domäne nutzt die vorhandene Rolle, führt keine neue ein.

`[A]` **Die Klassenlehrkraft ist keine `roles`-Zeile, sondern ein Ownership-Check** über
`classes.class_teacher_id`: Wer als `employee` dort steht, sieht die Kinder dieser Klasse voll —
dieselbe Mechanik wie bei jeder anderen Eigentümerprüfung dieser Dateien, keine neue Rolle nötig.

**Was diese Domäne nicht selbst entscheidet:** Ob eine `school_management`- oder
`day_care_management`-Person überhaupt zu diesem Kind darf, prüft die Ownership-Spalte am Kind
(Schulart, laufender Hortvertrag) — dieselbe Prüfung wie in jeder anderen Domäne, hier nicht
wiederholt.

## Pfad

Alles hängt am Kind, nicht an der Familie: Der Bestand ist „ein Bestand je Kind, den heute sechs
Formulare getrennt erheben" (08), keine Angabe je Person. Drei Anker, nicht einer:

- `/children/{child_id}/health-record` — der Bestand: Status (beantwortet/abgelehnt) und die
  Merkmale in einer Antwort.
- `/children/{child_id}/health-note` — **eigener Pfad, nicht `.../health-record/action-note`**:
  anderer Autor (Klassenlehrkraft statt Eltern), andere enge Rolle (`backend_health_note` statt
  `backend_health`), eine eigene Handlung und kein Feld am Formular der Eltern. — Alternative:
  als Unterpfad des Bestands; Preis: eine Route, deren Berechtigung mitten im Pfad wechselt, wo
  jede andere Datei den Wechsel am Pfad selbst zeigt (`sepa-mandates` vs. `photo-consent-invitation`
  in `anmeldung-api.md`).
- `/children/{child_id}/measles-proof` — eigene Tabelle, eigener Anlass (§20 IfSG), eigener Autor
  (Sekretariat, nie die Eltern).

## Enge Rolle

**Drei.** `backend_health` und `backend_health_note` standen schon vor diesem Durchgang in der
Migration der Domäne — ihre Tabellen, Rollen und GRANTs entstanden mit dem übrigen Schema, bevor
diese Datei geschrieben war. `backend_health_everyday` ist neu und kommt mit dem Bau dazu, denn
erst diese Datei entscheidet, dass der Hort die schmalere Sicht bekommt (oben).

- **`backend_health`** — `SELECT` auf `health_traits` und auf `child_health_records.answered_at`/
  `declined_at`; **`INSERT`/`UPDATE`/`DELETE` bleiben bei `backend_runtime`**, denn die Eltern
  tragen selbst ein, und die enge Rolle ist eine Lese-Grenze für Diagnose und Attestlage, keine
  Schreib-Grenze — dieselbe Aufteilung wie bei `sepa_mandates.iban` in
  [`anmeldung-api.md`](anmeldung-api.md), nur mit vertauschten Seiten: dort hält die enge Rolle das
  `INSERT`, hier das `SELECT`. Das GRANT trägt die Schlüsselspalten (`child_health_record_id`,
  `health_trait_id`) — sie fehlten in der Migration, die vor diesem Durchgang schon stand, aus
  demselben Grund wie bei `backend_kitchen` beim Bau von Mensa (`mensa-api.md` „Am Schema
  aufgefallen"); dieser Durchgang zieht sie nach (unten).
- **`backend_health_note`** — `SELECT`, `INSERT`, `UPDATE` auf `child_health_records.action_note`
  und dessen Schlüssel; **kein `DELETE`** — ein aufgehobener Hinweis wird mit leerem Text
  überschrieben (`PUT /children/{child_id}/health-note`), nicht die Zeile gelöscht, denn sie trägt
  auch `answered_at`/`declined_at`. `action_note` selbst ist für `backend_runtime` **lesbar** —
  nur das Schreiben ist eng, und ein Lese-Filter dafür wäre die zweite Stelle, an der dieselbe
  Grenze steht.
- **`backend_health_everyday`** — `SELECT` auf der View `everyday_health_traits`
  (`child_id, health_trait_id, health_trait_type_id, description, needs_permission,
  is_emergency_medication, emergency_description, permission_granted_at, permission_declined_at`),
  gefiltert auf `is_everyday_relevant`. Nicht `backend_health` mit einer `WHERE`-Klausel im
  Anwendungscode: `backend_health` hat bereits das ganze Merkmal, und ein `if` auf ein Häkchen wäre
  „die zweite Stelle, an der derselbe Ausschnitt entschieden wird" — genau die Alternative, die
  `mensa-api.md` für die Küche schon verworfen hat, eine Grenze weiter außen. Die View entsteht in
  dieser Migration, nicht in der des Horts: Die Tabellen, über die sie geht, gehören hierher, und
  die Rolle existiert erst mit ihr.

## Der Bestand

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /children/{child_id}/health-record` — Status, Merkmale, Hinweis und (nur volle Sicht, nur Personal) der Masernnachweis in einer Antwort, je nach Rolle unterschiedlich weit | [`grenzkarte.md`](../grenzkarte.md) „Zugriff, zweistufig"; [09](../soll-prozesse/09-hortvertrag.md) „Hortkräfte den Alltag …"; [15](../soll-prozesse/15-klassenbildung.md) „Zwei Einsichten"; [`grenzkarte.md`](../grenzkarte.md) „schnell nachprüfbar" für den Masernnachweis | Erziehungsberechtigte; `secretariat`, `school_management`, `day_care_staff`, `day_care_management`, `teacher`; Klassenlehrkraft | eigene Familie; Schulleitung nur ihre Schulart; Hort nur Kinder mit laufendem Hortvertrag, und nur die Alltags-Merkmale; `teacher` unbeschränkt, aber nur den Hinweis; Klassenlehrkraft nur die eigene Klasse, dafür voll. Der Masernnachweis steht nur Personal der vollen Sicht zur Verfügung, den Eltern nicht — kein Block gibt ihnen dafür einen Anlass. **Eine Rolle ohne Nennung bekommt `404`, nicht `403`** ([`gemeinsam.md`](gemeinsam.md#fehler)) | liest | `backend_health`, `backend_health_everyday` |
| `PUT /children/{child_id}/health-record` — beantworten oder ausdrücklich ablehnen | [08](../soll-prozesse/08-schulvertrag.md) Z2, „ändern die Eltern danach jederzeit im Portal — hier, nicht in 02"; [09](../soll-prozesse/09-hortvertrag.md) Z3 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie, nach [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) **nur „voll"** — der Bestand ist keine „eigene Angabe" einer eingeschränkten Person, sondern eine des Kindes. Legt `child_health_records` beim ersten Mal an (`uq_child_health_records`); setzt `answered_at` **oder** `declined_at`, nie beides (`ck_child_health_records_answer`). **Jederzeit umschaltbar** — ein Wechsel von abgelehnt zu beantwortet rührt vorhandene Merkmale nicht an, dafür nennt kein Block einen Grund | schreibt, `guardian:`/`entra:` | — |
| `PUT /children/{child_id}/health-note` — den handlungsrelevanten Hinweis setzen oder leeren | [`grenzkarte.md`](../grenzkarte.md) „Zugriff, zweistufig" | Klassenlehrkraft der eigenen Klasse | nur die eigene Klasse (`classes.class_teacher_id`); **kein Umweg** — es gibt keine Rolle, die für die Klassenlehrkraft einspringt, und das ist gewollt: der Hinweis ist ihre fachliche Einschätzung, keine Verwaltungsangabe | schreibt, `entra:` | `backend_health_note` |
| `PUT /children/{child_id}/measles-proof` — Vorlagedatum und -art eintragen oder ersetzen | [06](../soll-prozesse/06-anmeldetag.md) Z5; [09](../soll-prozesse/09-hortvertrag.md) Z3 (externes Kind) | `secretariat` | unbeschränkt; **keine Elternroute** — kein Block lässt die Familie selbst eintragen, das Sekretariat sieht das Original. Eine Zeile je Kind (`uq_measles_proofs`), ein erneuter `PUT` ersetzt sie — „festgehalten wird nur, ob und wie er vorlag", eine Korrektur ist keine zweite Vorlage | schreibt, `entra:` | — |

## Die Merkmale

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /children/{child_id}/health-traits` — ein Merkmal eintragen: Art, Beschreibung, je nach Art Behandlungsgrund/-zeitraum, Selbstverabreichung, Notfallbeschreibung, Attestlage, Erlaubnis | [08](../soll-prozesse/08-schulvertrag.md) Z2; [09](../soll-prozesse/09-hortvertrag.md) Z3 | Erziehungsberechtigte (voll); `secretariat` (Umweg) | eigene Familie, nur wo `answered_at` gesetzt ist — **wer ablehnt, füllt die Strecke gar nicht erst aus**, dieselbe Regel wie bei `ck_contract_responses_review` (`anmeldung-api.md`). Die vier Flags der Art (`needs_permission` usw.) diktieren, welche Felder die Route annimmt (`fk_health_traits_type`); ein Feld außerhalb seiner Art wird abgewiesen, nicht stillschweigend verworfen. Kein zweites Notfallmedikament mit derselben Beschreibung (`ix_health_traits_unique`) | schreibt, `guardian:`/`entra:` | — |
| `PUT /children/{child_id}/health-traits/{health_trait_id}` — ein Merkmal ändern, samt Erlaubnis erteilen oder verweigern | [08](../soll-prozesse/08-schulvertrag.md) „ändern die Eltern danach jederzeit im Portal" | Erziehungsberechtigte (voll); `secretariat` (Umweg) | eigene Familie. **Die Erlaubnis hat keinen Anker neben sich** ([`hebel.md`](../soll-prozesse/hebel.md#drei-zustände-erteilt-verweigert-nicht-gefragt)) — sie steht am Merkmal selbst und wird mit demselben `PUT` gesetzt, kein zweiter Signaturweg: „ein mitten im Schuljahr ergänztes Notfallmedikament hat kein unterschriebenes Blatt" | schreibt, `guardian:`/`entra:` | — |
| `DELETE /children/{child_id}/health-traits/{health_trait_id}` — ein Merkmal entfernen, weil es nicht mehr zutrifft | [08](../soll-prozesse/08-schulvertrag.md) „ändern die Eltern danach jederzeit im Portal" | Erziehungsberechtigte (voll); `secretariat` (Umweg) | eigene Familie. **Löschen, nicht datieren** — „bei Art.-9-Daten wird ein nicht mehr zutreffendes Merkmal gelöscht statt datiert" (`schema/gesundheit-schema.sql`); der breit sichtbare Hinweis einer beendeten Sache stünde sonst weiter | schreibt, `guardian:`/`entra:` | — |

**Das Attest ist kein Upload dieser Datei.** `certificate_document_id` kommt über die generische
Dokumentablage (`PUT /documents`, [`stammdaten-api.md`](stammdaten-api.md)); diese Route trägt nur
die Referenz und den `has_certificate`-Haken, dessen `CHECK` ohne Dokument keine Referenz zulässt.

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Die Betreuungsliste der Hortleitung trägt bewusst keinen Gesundheits-Ausschnitt** — anders als
  bei Mensa und Ferien. [09](../soll-prozesse/09-hortvertrag.md) sagt es direkt: „Hortkräfte [sehen]
  von alldem nur die Betreuungsliste — was sie sonst über ein Kind sehen, steht in [02] und [08]
  **und nicht hier**". Die Alltags-Sicht dieser Domäne ist der eigene Zugriff dafür
  (`GET /children/{child_id}/health-record`); `anmeldung-api.md` (`GET /care/attendance-list`)
  braucht keine Ergänzung.
- **Eine künftige Klassenliste** (15, noch nicht geplant) — sie liest die volle Sicht wie die
  Klassenlehrkraft selbst; die Route dafür gehört [`klassenbildung-api.md`](klassenbildung-api.md),
  wenn es sie gibt, nicht dieser Datei — dieselbe Aufteilung wie bei `kitchen_health_traits`
  (`mensa-api.md`).
- **Die Aufgabe aus dem fehlenden Masernnachweis** (`measles_report`) — bereits gebaut,
  [`anmeldung-api.md`](anmeldung-api.md) Z. 223: sie liest `measles_proofs` direkt, ohne eine Route
  dieser Datei zu rufen.
- **Die Löschung** — kein eigener Lauf: Der ganze Bestand hängt per Cascade am Kind und geht mit dem
  Lösch-Lauf (17), „das letzte bestätigte Ende dieses Kindes" (03).
- **Die Änderungsspur** — [`querschnitt-api.md`](querschnitt-api.md).

## Korrigiert an anderer Stelle

Zwei Sätze, die diese Domäne widerlegt, jetzt nachgezogen statt offen gelassen:

- `grenzkarte.md` „Zugriff, zweistufig": „Den vollen Satz sehen Sekretariat, Klassenlehrer:in **und
  Hort**" wird „Den vollen Satz sehen Sekretariat und Klassenlehrer:in, der Hort die
  Alltags-Merkmale" — Begründung oben.
- `ferien-api.md`: „der Hort sieht den vollen Satz (`backend_health`)" wird „der Hort sieht die
  Alltagsmerkmale (`backend_health_everyday`)" — eine eigene Rolle statt der vollen, mit
  demselben Datei-Update nachgezogen.

## Am Schema aufgefallen

Zwei Stellen, beim Bau nachgezogen, nicht neu geplant:

- **`backend_health` fehlten die Schlüsselspalten.** Die Migration stand seit dem
  Gerüst-Durchgang vor dieser Domäne, mit `SELECT` nur auf die sensiblen Spalten von
  `health_traits` — ohne `health_trait_id`, `child_health_record_id`, `created_at`, `created_by`
  ließ sich unter der Rolle kein `WHERE` bilden, derselbe Fund wie bei `backend_kitchen`
  (`mensa-api.md`). Nachgezogen im GRANT.
- **`backend_health_note` brauchte den Schlüssel von `child_health_records` zusätzlich.** Ein
  `UPDATE … WHERE child_health_record_id = …` verlangt `SELECT` auf die Spalte der `WHERE`-Klausel,
  auch wenn `backend_runtime` sie längst tabellenweit lesen darf — `SET ROLE` erbt dessen Rechte
  nicht. Der generische Prüflauf (`tests/test_privileges.py`, „narrow role undercut") widerspricht
  dem zunächst zu Recht: Ohne Eintrag in `READ_HELPERS` sieht er in jedem so gegrenzten Schlüssel
  eine ausgehöhlte enge Rolle. Der Eintrag steht jetzt dort, mit derselben Begründung wie die beiden
  vorhandenen für `backend_cleaning_waiver`.

## Offene Fragen

Keine neuen. Die Aufbewahrungsfrist steht fest (`schema/gesundheit-schema.sql`, Dateikopf).
