# Anmeldung — Routen

Der lange Weg eines Kindes in die Schule: Bewerbung ([05](../soll-prozesse/05-bewerbung.md)),
Anmeldetag ([06](../soll-prozesse/06-anmeldetag.md)), Aufnahmeentscheidung
([07](../soll-prozesse/07-aufnahmeentscheidung.md)), Schulvertrag
([08](../soll-prozesse/08-schulvertrag.md)) — und der Hortvertrag
([09](../soll-prozesse/09-hortvertrag.md)), der derselbe Vertragsvorgang ist und deshalb dieselbe
Route trifft, wo er dasselbe tut. Was für jede Route gilt, steht in
[`gemeinsam.md`](gemeinsam.md) und wird hier nicht wiederholt.

**Gegenprobe:** **26 Ablaufzeilen aus 5 Blöcken** tragen eine Handlung im System; **24** haben hier
eine Route. Die zwei übrigen tragen stattdessen einen Satz, warum es keine gibt — beide beschreiben
dasselbe: ein Formular, das noch nichts anlegt ([05](../soll-prozesse/05-bewerbung.md) Z3,
[09](../soll-prozesse/09-hortvertrag.md) Z3). Es gibt **54 Routen**; **29** nennen eine Ablaufzeile,
**25** einen Hebel oder einen Abschnitt der Blöcke — die Wertelisten und die beiden Preistabellen
tragen davon allein zehn.

Die 26 Zeilen: [05](../soll-prozesse/05-bewerbung.md) Z1–Z4 ·
[06](../soll-prozesse/06-anmeldetag.md) Z1–Z6 · [07](../soll-prozesse/07-aufnahmeentscheidung.md)
Z1–Z4, Z6 · [08](../soll-prozesse/08-schulvertrag.md) Z1–Z5 ·
[09](../soll-prozesse/09-hortvertrag.md) Z1–Z6. Die beiden System-Zeilen
([05](../soll-prozesse/05-bewerbung.md) Z5, [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z5)
sind Läufe und stehen unten.

## Pfad

Drei Sachen tragen ihn, und alle drei stehen so in den Blöcken: die **Bewerbung**
(`/applications/…`), der **Anmeldetag** (`/admission-days/…`) und der **Vertrag**
(`/contracts/…`). Ein Hortvertrag ist ein `contracts`-Vorgang und hat deshalb keinen eigenen Pfad —
bis auf den einen, an dem er entsteht (`POST /care-contracts`), denn dort gibt es die Kennung noch
nicht, auf die er sich legen würde.

**Der Vertrag steht nicht unter dem Kind.** `/children/{child_id}/contracts` wäre der Pfad einer
Ansicht, nicht eines Vorgangs; die Vertragsstrecke läuft über die eine Kennung, die die Zusagemail
in die Hand gibt. Unter dem Kind steht allein, was ihm gehört und nicht dem Vorgang: das SEPA-Mandat
und der Signaturlink des Fotoeinverständnisses.

## Enge Rolle

Zwei Spaltenmengen dieser Domäne liegen hinter eigenen DB-Rollen, keine davon hinter einer
Anwendungsrolle:

- **`sepa_mandates.iban` und `.bic`** — `backend_finance`, die gebaute Rolle
  ([`stammdaten-api.md`](stammdaten-api.md)); „`backend_banking`" stand hier als zweiter Name für
  dieselbe Sache. Sie hat genau zwei Aufrufer: die Route, die das Mandat entgegennimmt, und die, mit
  der die Buchhaltung es nach Optigem trägt. Die Mandatsreferenz daneben braucht keinen GRANT
  (`glossar.md`). **Die entgegennehmende Route ist eine schreibende**, also hält die enge Rolle das
  `INSERT` und `backend_runtime` keines: `iban` ist NOT NULL, ein Mandat ohne Kontonummer gibt es
  nicht, und ein geteiltes `INSERT` wäre keine Grenze. Geändert wird keine der beiden Spalten je —
  „ein bestehendes wird nie geändert, sondern ersetzt" (08) — deshalb hat niemand `UPDATE` darauf.
- **`applications.assessed_level_id`** — die eigene Einschätzung der Lehrkräfte, „das engste
  Zugriffsprofil nach den Art.-9-Daten" (`schema/anmeldung-schema.sql`). Sie steht in der
  Bewerbungsliste und an der Bewerbung; **die Empfehlung der abgebenden Grundschule daneben nicht** —
  sie ist ein amtliches Dokument und keine Bewertung.

Beide werden in einem `narrow_role`-Block derselben Transaktion gelesen, und beide brauchen die
Schlüsselspalte im GRANT dazu — ohne sie kann die enge Rolle keine Zeile benennen
(`stammdaten-api.md`). **Beim Mandat kommt `created_at` hinzu**, und zwar aus demselben Grund eine
Ebene tiefer: Das `INSERT` liest den Server-Default über `RETURNING` zurück, und ein `RETURNING` ist
ein Lesen. Die Spalte ist ein Audit-Feld, das `backend_runtime` ohnehin sieht; eng bleibt, was die
Rolle trägt — die Bankverbindung.

**Die Gesundheitsangaben gehören nicht hierher.** Block [08](../soll-prozesse/08-schulvertrag.md)
erhebt sie, aber `child_health_records` und `measles_proofs` stehen in
`schema/gesundheit-schema.sql`, und ihre Routen stehen in [`gesundheit-api.md`](gesundheit-api.md).
Was diese hier davon braucht, ist der Stand: ob der Bestand beantwortet ist, weil die
Vollständigkeitsprüfung ihn sieht — gelesen direkt an `child_health_records`, ohne einen Aufruf
dorthin.

## Zwei Grenzen, die jede Route dieser Domäne einhält

- **Vor der bestätigten Zahlung entsteht nichts.** Kein Entwurf, keine Vormerkzeile, kein
  `pending` — „bis zur bestätigten Zahlung gibt es keine Bewerbung" (05 Z3, Z4). Das Formular hält
  seine Angaben in der Zahlungssitzung, und was ein Abbruch hinterlässt, ist nichts
  ([`gemeinsam.md`](gemeinsam.md#sofortzahlung)). Dasselbe gilt für den Hortantrag, der zwar nicht
  bezahlt wird, aber denselben Satz trägt (09 Z4): erst das Absenden macht daraus einen Antrag.
- **Die Freigabe ist die Grenze zwischen zwei Welten.** Davor gehören die Angaben der Familie, und
  sie richtet einen Dreher selbst (08 Z2); danach kennt kein Fremdsystem sie mehr als nur diese
  Datenbank, und ändern darf sie das Sekretariat ([02](../soll-prozesse/02-datenaenderung.md), über
  [`stammdaten-api.md`](stammdaten-api.md)). Dieselbe Grenze trennt Rücktritt von Abgang (08) und
  Bewerbung von Einschreibung.

`[A!]` **Schul- und Hortvertrag teilen sich jede Route, an der sie dasselbe tun** — Ansicht,
Unterschrift, Freigabe, Ende. Sie unterscheiden sich in Rolle und Rumpf, nicht im Pfad; das Schema
hält sie ohnehin in einer Tabelle, „eine zweite Vertragstabelle wäre eine Kopie"
(`grenzkarte.md`). — Alternative: `/school-contracts` und `/care-contracts` getrennt; Preis: die
Regel „mit der Gegenzeichnung entsteht das Dokument und verschwinden die Bilder" stünde zweimal und
liefe beim ersten Fix auseinander — genau das, was die eine Tabelle verhindert.

## Wer sich bewerben darf

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /enrolment-windows` — welche Voranmeldung für welches Ziel offen ist und bis wann | [05](../soll-prozesse/05-bewerbung.md) Z1 | jede Mitarbeiterrolle; Erziehungsberechtigte und **jeder ohne Anmeldung** | unbeschränkt: „sichtbar für die Eltern, sobald ein Datum steht" (05 Z1), und wer sich noch nicht beworben hat, hat keine Anmeldung. Sie trägt nur Ziel und Fenster, nie eine Zahl über die Bewerbungen darin | liest | — |
| `POST /enrolment-windows` — die Voranmeldung eines Ziels öffnen | [05](../soll-prozesse/05-bewerbung.md) Z1 | `secretariat` | unbeschränkt. Je Ziel eines (`uq_enrolment_windows`), und die Zielstufe muss es in dieser Schulart geben (`ck_enrolment_windows_grade_level`). **Ein Schließdatum ist nicht Pflicht** — „steht es noch nicht, bleibt sie offen, bis eines gesetzt wird" | schreibt, `entra:` | — |
| `PATCH /enrolment-windows/{enrolment_window_id}` — das Schließdatum setzen, vorziehen oder verschieben | [05](../soll-prozesse/05-bewerbung.md) „Fristen und Termine" | `secretariat` | unbeschränkt, **auch nachdem es verstrichen ist** — dann ist die Voranmeldung wieder offen, und der Regelfall „wir lassen sie bis Juni laufen" braucht keine einzelne Freischaltung. Einen zweiten Hebel fürs Vorziehen gibt es nicht | schreibt, `entra:` | — |
| `GET /admission/targets` — für welche Ziele diese Adresse eine Bewerbung anlegen darf, und welche schon läuft | [05](../soll-prozesse/05-bewerbung.md) Z2 | Erziehungsberechtigte | die eigene Anmeldung. **Die Frage wird an der bestätigten Adresse beantwortet und nicht im Browser**: offenes Fenster oder Freischaltung dieser Adresse, dazu die vorhandene Familie und eine für dieses Ziel laufende Bewerbung, damit „wer es erneut versucht, in ihr landet" statt das Formular umsonst auszufüllen | liest | — |
| `POST /application-unlocks` — eine verspätete Adresse für ein Ziel freischalten und ihr die gewöhnliche Einladung schicken | [05](../soll-prozesse/05-bewerbung.md) „Sonderfälle" | `secretariat` | unbeschränkt. Sie gilt **14 Tage** ab `created_at` und für alle Kinder dieser Adresse; die Frist ist fest und steht in keiner Spalte (`schema/anmeldung-schema.sql`). **Das ist der einzige Umweg dieses Blocks** — eine Bewerbung trägt das Sekretariat nie stellvertretend ein | schreibt, `entra:` | — |
| `GET /application-unlocks` — die erteilten Freischaltungen samt Adresse, Ziel und Urheber | [05](../soll-prozesse/05-bewerbung.md) „Was dabei erhoben wird" | `secretariat`, `school_management` | Listenroute, deshalb nie über den OTP-Pfad. Abgelaufene fallen heraus: „eine nicht genutzte Freischaltung verfällt nach 14 Tagen und nimmt die Adresse mit" — was die Route nicht mehr zeigt, räumt der Lösch-Lauf | liest | — |
| `POST /applications` — die Bewerbung absenden: Angaben übergeben, gegen Fenster und Freischaltung prüfen, die Zahlungssitzung eröffnen | [05](../soll-prozesse/05-bewerbung.md) Z4 | Erziehungsberechtigte | **die eigene Familie, wo es sie schon gibt**; kennt die Schule sie nicht, prüft allein die bestätigte Adresse. Sie legt **nichts** an — geprüft wird „vor der Zahlung, damit niemand zahlt und danach eine Absage bekommt", und zurück kommt die Adresse der Bezahlseite ([`gemeinsam.md`](gemeinsam.md#sofortzahlung)). Kein zweiter Anlauf bei laufender Bewerbung (`ix_applications_running`) | liest, eröffnet die Sitzung | — |
| `POST /admission/info-evening-invitations` — die Einladung zum Infoabend an alle laufenden Bewerbungen einer Schulart fürs kommende Schuljahr | [05](../soll-prozesse/05-bewerbung.md) „Mails und Schreiben" | `secretariat` | unbeschränkt. **Die einzige Mail, deren Text ganz ein Mensch schreibt** — Datum, Ort und Inhalt stehen im Rumpf und nirgends sonst; im System entsteht dazu kein Termin und keine Rückmeldung. Nur Bewerbungen **ohne Ergebnis**: Quereinsteiger fürs laufende Jahr und Warteplätze aus früheren Jahren fallen heraus | schreibt, `entra:` | — |

**Was `POST /applications` an den Zahlungsdienst übergibt**, ist der vollständige Formularinhalt als
Metadaten der Sitzung — die einzige Stelle im System, an der ein Vorgang zwischen zwei Aufrufen
außerhalb der Datenbank liegt, und der Grund steht in der Grenze oben. Er reist **als ein JSON über
mehrere Metadaten-Schlüssel**, weil ein Schlüssel bei Stripe 500 Zeichen fasst und ein Formular mehr
hat; die Grenze liegt damit bei rund 22 kB, und ein Formular darüber weist die Route ab, statt eine
halbe Sitzung zu eröffnen. Nachgetragen beim Bau. Angelegt wird alles beim
Rückruf: Bewerbung und, wo die Schule die Familie noch nicht kennt, Person, Kind, Familie und
Sorgeberechtigte. Der Rückruf selbst ist die eine Route des Querschnitts
([`querschnitt-api.md`](querschnitt-api.md)) und steht nicht hier.

**`POST /applications` legt die abgebende Schule und den Kindergarten an, wo sie in der Liste
fehlen** — sie kommen als Name und nicht als Kennung. Ein Quereinsteiger kommt von irgendeiner
Schule in Deutschland, und eine Bewerbung an einem Deploy scheitern zu lassen wäre absurd
(`stammdaten-api.md`, Rand). — Alternative: eine Pflegeroute fürs Sekretariat und eine Bewerbung,
die an der fehlenden Zeile abbricht; Preis: eine Familie kommt am Sonntagabend nicht weiter, und das
Sekretariat pflegt eine Liste, die es nicht kennt. Der Preis dieser Wahl ist die Dublette
(„Grundschule Musterstadt" neben „GS Musterstadt"); sie zusammenzuführen hat heute keinen Ort und
steht deshalb am Rand.

## Anmeldetag

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /admission-days` — einen Anmeldetag anlegen: Datum, Von–Bis, Pause, Ziel, Fensterlänge und Plätze je Fenster; **erzeugt die Zeitfenster in derselben Transaktion** | [06](../soll-prozesse/06-anmeldetag.md) Z1 | `secretariat`, `school_management` | Schulleitung nur ihre eigene Schulart. „Daraus erzeugt das System die Zeitfenster; einzeln angelegt wird keines" — die Pause fällt heraus, das Raster endet mit `ends_at_time`. **Der Sondertermin ist keine eigene Sorte**, sondern der kleinste Anmeldetag: ein Fenster, ein Platz | schreibt, `entra:` | — |
| `PATCH /admission-days/{admission_day_id}` — Raster und Zahlen ändern | [06](../soll-prozesse/06-anmeldetag.md) „Was dabei erhoben wird" | `secretariat`, `school_management` | **nur solange an diesem Tag niemand gebucht hat** — danach hingen gebuchte Termine an Zeiten, die es nicht mehr gibt; die Route weist es mit `400` ab. Danach bleiben zwei Griffe: die Plätze eines Fensters erhöhen und einzelne Familien umbuchen | schreibt, `entra:` | — |
| `POST /admission-days/{admission_day_id}/release` — den Tag zur Buchung freigeben | [06](../soll-prozesse/06-anmeldetag.md) Z2 | `secretariat`, `school_management` | unbeschränkt, **einmal** (`released_at`). Erst damit geht die Einladung raus — an alle Sorgeberechtigten jeder laufenden Bewerbung dieses Ziels **ohne Termin**, samt Mitbringliste. Vorher sieht keine Familie den Tag | schreibt, `entra:` | — |
| `POST /admission-days/{admission_day_id}/cancellation` — den Tag absagen | [06](../soll-prozesse/06-anmeldetag.md) „Mails und Schreiben" | `secretariat`, `school_management` | unbeschränkt. **Die Termine dieses Tages verfallen, und die Mail sagt, dass aus den übrigen freigegebenen Tagen neu zu buchen ist** — still umgebucht wird niemand. Ein bereits gelaufener Termin samt Spur bleibt stehen | schreibt, `entra:` | — |
| `PATCH /admission-day-slots/{admission_day_slot_id}` — die Plätze eines einzelnen Zeitfensters erhöhen | [06](../soll-prozesse/06-anmeldetag.md) „Was dabei erhoben wird" | `secretariat`, `school_management` | unbeschränkt; leer heißt, es gilt die Zahl des Tages (`places_override`). **Die Grenze ist hart** — anders als beim Putzdienst ist ein volles Fenster nicht buchbar —, und genau deshalb gibt es diesen Griff | schreibt, `entra:` | — |
| `GET /applications/{application_id}/admission-slots` — die buchbaren Zeitfenster dieser Bewerbung | [06](../soll-prozesse/06-anmeldetag.md) Z3 | Erziehungsberechtigte; `secretariat`, `school_management` | nur Kinder der eigenen Familien. **Aus allen freigegebenen Tagen ihres Ziels, nicht nur aus einem**; abgesagte Tage fallen heraus, volle Fenster stehen als besetzt darin, damit die Auswahl nicht schweigend schrumpft | liest | — |
| `PUT /applications/{application_id}/admission-slot` — ein Zeitfenster buchen oder umbuchen | [06](../soll-prozesse/06-anmeldetag.md) Z3 | Erziehungsberechtigte; `secretariat`, `school_management` | nur Kinder der eigenen Familien; **für die Eltern bis zum Beginn des eigenen Fensters**, fürs Sekretariat unbeschränkt ([offizieller Umweg](gemeinsam.md#der-offizielle-umweg)). Je Bewerbung genau ein Termin — „buchen mehrere Sorgeberechtigte verschieden, gilt schlicht die letzte Buchung". Das Fenster muss zum Ziel gehören (`fk_applications_admission_day`), und die Platzzahl prüft die Route sperrend: `ix_applications_slot` trägt die Abfrage, die Grenze selbst kein Constraint | schreibt, `guardian:`/`entra:` | — |
| `GET /admission-days/{admission_day_id}/schedule` — die **Tagesliste** als Druckansicht, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) | [06](../soll-prozesse/06-anmeldetag.md) Z4 | `secretariat`, `school_management` | Listenroute, nie über OTP. **Wer wann kommt, mehr nicht** — was das Sekretariat fragt und einträgt, steht an der Bewerbung und nicht auf dieser Liste. Die Lehrkräfte bekommen sie auf Papier und brauchen keinen Zugang | liest | — |
| `PATCH /applications/{application_id}/record` — die Verwaltungsspur: Einstufung, Empfehlungen, Angebote, Betreuungsbedarf, Infoabend, der eine Haken über das Erklärte, die Anmerkung — **und der Abschluss**, durchgeführt oder nicht erschienen | [06](../soll-prozesse/06-anmeldetag.md) Z5 und Z6 | `secretariat`, `school_management` | Schulleitung nur ihre eigene Schulart. Ohne gebuchtes Zeitfenster gibt es keine Spur (`ck_applications_record_needs_slot`); der Betreuungsumfang setzt das Interesse voraus (`ck_applications_care_need`). **Fehlende Unterlagen hindern den Abschluss nicht** — sie bleiben an der Bewerbung offen stehen. Die Einstufung schlägt das System nicht vor | schreibt, `entra:` | die eigene Einschätzung |

**Die Unterlagen laufen über den Querschnitt**, nicht über eine eigene Route dieser Domäne:
`POST /children/{child_id}/documents` fordert an, `PUT /documents/{document_id}` legt ab oder stellt
fest, dass sie entfällt ([`querschnitt-api.md`](querschnitt-api.md)). **Welche ein Ziel verlangt,
folgt aus dem Ziel** (06, „Was dabei erhoben wird") — und diese Domäne legt den Satz an: mit der
bestätigten Zahlung, je Ziel einmal. Der Masernnachweis ist ausdrücklich keine davon; er steht als
`measles_proofs` in der Gesundheitsdomäne, weil von ihm keine Kopie entsteht.

**Der Unterlagensatz entsteht mit der Bewerbung und nicht mit dem Anmeldetag.** Er hängt am
Ziel, das die Bewerbung trägt, und die Mitbringliste der Einladung liest ihn. — Alternative: ihn mit
der Freigabe des Anmeldetags anlegen; Preis: der Quereinsteiger hätte keinen, obwohl 08 „dieselbe
Liste, die dort nie geführt wurde" ausdrücklich einfordert.

**Eine Route für Durchgehen und Abschließen** (06 Z5 und Z6). Beides schreibt an dieselbe
Zeile, im selben Zeitfenster, durch dieselbe Person; der Abschluss ist ein Feld dieser Spur und kein
zweiter Vorgang. — Alternative: `POST /applications/{id}/record/completion` daneben; Preis: eine
Route, die nichts prüft, was die andere nicht schon prüft, und ein zweiter Ort für dieselbe
Ownership-Regel.

## Aufnahmeentscheidung und Warteliste

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /applications?branch=&year=&grade=&status=&ended=` — **die eine Liste**: Bewerbungsliste der Entscheidungsrunde, Warteliste, Arbeitsliste des Anmeldetags | [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z1, [06](../soll-prozesse/06-anmeldetag.md) „Dateien" | `school_management`, `secretariat` | Schulleitung nur ihre eigene Schulart; Listenroute, nie über OTP. [Frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) und **als Zeilen, nicht als Druckansicht**: Aus dieser Liste heraus wird entschieden (`PUT …/decision` je Zeile), also braucht die Oberfläche die Zeilen selbst und druckt ihren eigenen Bildschirm — anders als die Tagesliste, die niemand bedient. Nachgetragen beim Bau. **Drei Namen, eine Route**: die Filter machen den Unterschied, und die Runde entscheidet über alle Zielstufen hinweg. Je Zeile Spurstand, Geschwister an der eigenen Schule, Angebote, Betreuungsinteresse, die Ferienbuchung des Kindes und die Zahl der schon Zugesagten in der Zielstufe — **keine Kapazität**, eine Zahl ohne Grenze | liest | die eigene Einschätzung |
| `GET /applications/{application_id}` — die Bewerbung selbst | [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z1 | `school_management`, `secretariat`; Erziehungsberechtigte | Eltern sehen die ihres Kindes nach ihrer [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) — **Ergebnis und Fristende ja, Priorität und Position auf der Warteliste nie**: „sie ändert sich mit jedem Nachrücker, und das Sekretariat müsste jede Bewegung erklären". Nach der Freigabe des ersten Vertrags am Kind zeigt sie den Eltern die einmal erhobenen Angaben nicht mehr ([Sparsame Ansicht](../soll-prozesse/hebel.md#sparsame-ansicht)) | liest | die eigene Einschätzung |
| `PUT /applications/{application_id}/decision` — das Ergebnis eintragen: Zusage, Warteplatz samt Priorität oder Absage | [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z2 und Z6 | `school_management`, `secretariat` | Schulleitung nur ihre eigene Schulart. **Das Ergebnis steht still und ist beliebig oft änderbar; nach draußen geht davon nichts** (`decided_at` ohne `released_at`). Kein Grund, keine Notiz — dafür gibt es kein Feld. Die Priorität ist frei, Lücken und Doppelungen erlaubt. Auch die Umkehr einer Absage läuft hier und trägt die [Änderungsspur](../soll-prozesse/hebel.md#änderungsspur) | schreibt, `entra:` | — |
| `POST /applications/decisions/release` — die Ergebnisse **eines Ziels** freigeben, alle im selben Zug; beim Quereinstieg und beim Nachrücken eine Bewerbung | [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z3 und Z6 | `school_management`, `secretariat` | Schulleitung nur ihre eigene Schulart. „Keine Familie erfährt ihre Absage, während über die Zusagen noch geredet wird": Die Route lädt die entschiedenen Zeilen und schreibt sie einzeln ([`gemeinsam.md`](gemeinsam.md#schreiben)), in **einer** Transaktion samt Mails. Jede Zusage bekommt dabei ihr Fristende — 14 Tage — **und ihren Schulvertrag**, dessen Textfassung damit einfriert (08). Eine Absage beendet die Bewerbung, ein Warteplatz nicht (`application_statuses.keeps_connection`) | schreibt, `entra:` | — |
| `PUT /applications/{application_id}/deadline` — das Fristende verschieben | [07](../soll-prozesse/07-aufnahmeentscheidung.md) „Fristen und Termine" | `secretariat`, `school_management` | unbeschränkt, **beliebig oft, ohne Grund und auch nachdem die Frist verstrichen ist** — „dann läuft sie weiter, als wäre sie nie gerissen, und Kulanz ist ein Datum statt eines Sonderfalls". Die 14 Tage sind fest, das einzelne Ende ist es nicht | schreibt, `entra:` | — |
| `PUT /applications/{application_id}/waiting-confirmation` — den Warteplatz bestätigen | [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z4 | Erziehungsberechtigte; `secretariat`, `school_management` | nur Kinder der eigenen Familien; **eine sorgeberechtigte Person allein genügt**, und bestätigen mehrere verschieden, gilt die letzte Antwort. Sie bindet nichts und läuft nicht ab — die Liste zeigt nur, wann zuletzt bestätigt wurde | schreibt, `guardian:`/`entra:` | — |
| `POST /applications/{application_id}/withdrawal` — die Bewerbung beenden: Warteplatz aufgeben, laufende Bewerbung zurückziehen, Platz ablehnen, **oder vor der Freigabe zurücktreten** | [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z4, [08](../soll-prozesse/08-schulvertrag.md) „Sonderfälle" | Erziehungsberechtigte; `secretariat`, `school_management` | nur Kinder der eigenen Familien. **Wer beendet, beendet für alle** — anders als beim Bestätigen —, und zurücknehmen kann es danach nur das Sekretariat: mit der Verbindung endet der Zugang, durch den der andere widersprechen könnte. **Beenden löscht nichts.** Setzt Endstatus, `ended_at` und `ended_by` (`ck_applications_final_ended`), gibt einen gebuchten Termin frei und meldet ans Anmeldepostfach. Nach der Freigabe des Vertrags geht dieser Weg nicht mehr — dann ist es ein Abgang (`stammdaten-api.md`) | schreibt, `guardian:`/`entra:` | — |
| `DELETE /applications/{application_id}` — eine beendete Bewerbung von Hand löschen | [07](../soll-prozesse/07-aufnahmeentscheidung.md) „Löschen" | `secretariat` | **nur eine beendete** (`ended_at`), sonst `400`. „War sie die letzte Verbindung dieses Kindes, verschwinden mit ihr Kind und — wenn kein Geschwisterkind bleibt — auch Familie und Sorgeberechtigte"; **wer noch einen zweiten Anker trägt, bleibt stehen** — ein Sorgeberechtigter, der an der Schule arbeitet, ist eine Person. Der Lösch-Lauf (17) erfasst sie ohnehin; dies ist der Griff für „früher als er" | schreibt, `entra:` | — |

**Die Antwortfrist hat keinen eigenen Lauf.** Verstreicht sie, geschieht nichts von selbst: Die
Bewerbung steht als *Frist verstrichen* in der Liste — gerechnet aus `response_deadline_at` und
nicht gespeichert —, das Sekretariat bekommt die Meldung, und **erst die eingetragene Ablehnung
beendet sie** (`PUT …/decision` samt Freigabe). „Keine Mail an die Familie, wenn die Frist reißt."
Das ist derselbe Satz wie überall: Fristen sperren, sie löschen nicht.

## Der Vertrag — Schulvertrag wie Hortvertrag

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /contracts/{contract_id}` — der Stand der Strecke: wer angenommen, durchgesehen und unterschrieben hat, was noch fehlt, welche Fassung gilt | [08](../soll-prozesse/08-schulvertrag.md) Z2 und Z4, [09](../soll-prozesse/09-hortvertrag.md) Z4 | Erziehungsberechtigte; `secretariat`, `school_management`, `day_care_management`, `executive_management` | nur Kinder der eigenen Familien; Schulleitung nur ihre Schulart, **Hortleitung auch das externe Kind, das keine hat** ([`hebel.md`](../soll-prozesse/hebel.md#rollen)). „Niemand sieht, wie weit eine Familie ist" ist der Satz, den diese Route abschafft — sie ist die Antwort auf „woran hakt es" für beide Seiten | liest | — |
| `PUT /contracts/{contract_id}/responses/{person_id}` — den Platz annehmen oder ablehnen | [08](../soll-prozesse/08-schulvertrag.md) Z1 | Erziehungsberechtigte; `secretariat`, `school_management` | die eigene Person, das Sekretariat stellvertretend für jede. **Wo alle zustimmen müssen, zählt ein Widerspruch als Nein** — nicht die letzte Antwort —, und die Meldung geht ans Anmeldepostfach; geklärt wird am Telefon. Genau eine Antwort je Person (`uq_contract_responses`, `ck_contract_responses_answer`); **wer nach seiner Einsichtsstufe nur lesen darf oder gesperrt ist, wird nicht erwartet** und bekommt keine Zeile. Ablehnen ist dieselbe Handlung wie `POST /applications/{id}/withdrawal` und beendet die Bewerbung für alle | schreibt, `guardian:`/`entra:` | — |
| `PUT /contracts/{contract_id}/responses/{person_id}/data-review` — die Durchsicht bestätigen: **ein** Haken über die eigenen Angaben und die des Kindes | [08](../soll-prozesse/08-schulvertrag.md) Z2 | Erziehungsberechtigte; `secretariat`, `school_management` | die eigene Person. Nur wer angenommen hat (`ck_contract_responses_review`) — „wer ablehnt, füllt die Strecke gar nicht erst aus". **Der einzige Moment, in dem die Familie diese Angaben noch einmal vollständig vor sich hat**; was falsch ist, richtet sie im selben Zug über [`stammdaten-api.md`](stammdaten-api.md), und der Haken sagt nur, dass sie hingesehen hat | schreibt, `guardian:`/`entra:` | — |
| `POST /contracts/{contract_id}/signatures` — unterschreiben: Namenszug zeichnen | [08](../soll-prozesse/08-schulvertrag.md) Z3, [09](../soll-prozesse/09-hortvertrag.md) Z4 | Erziehungsberechtigte; `secretariat`, `school_management`, `day_care_management` | die eigene Person; das Sekretariat **bestätigt** eine Unterschrift stellvertretend ([offizieller Umweg](gemeinsam.md#der-offizielle-umweg)), gibt aber nie frei. **Wie viele nötig sind, entscheidet der Inhalt und nicht die Herkunft** (09): alle Sorgeberechtigten, wo der Vertrag den Bestand aus 08 zum ersten Mal füllt, sonst eine. Das Bild liegt als Graph-Kennung an der Unterschrift und verschwindet mit der Gegenzeichnung; die Fassung steht am Vertrag und nicht hier | schreibt, `guardian:`/`entra:` | — |
| `POST /contracts/{contract_id}/submission` — prüfen und der Schulleitung vorlegen | [08](../soll-prozesse/08-schulvertrag.md) Z4 | `secretariat` | unbeschränkt. **Fehlendes hindert das Vorlegen nicht** — es steht sichtbar offen, und ob es reicht, entscheidet ein Mensch. Setzt `completeness_checked_at` und legt die offene [Aufgabe](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail) bei der Schulleitung **dieser Schulart** an, die in der Wochenmail mitläuft, bis unterschrieben ist. **Nur der Schulvertrag** — „das Sekretariat prüft und legt hier nicht vor" (09) | schreibt, `entra:` | — |
| `POST /contracts/{contract_id}/release` — freigeben und für die Schule bzw. den Träger gegenzeichnen | [08](../soll-prozesse/08-schulvertrag.md) Z5, [09](../soll-prozesse/09-hortvertrag.md) Z5 | Schulvertrag: `school_management`, `executive_management`. Hortvertrag: `day_care_management`, `executive_management` | Schulleitung nur ihre eigene Schulart. **Das Sekretariat nie**, auch nicht vertretungsweise: „der Ausfall der Schulleitung wird durch die Geschäftsführung aufgefangen statt durch ein Augenpaar weniger". Der Hortvertrag trägt hier sein **Aufnahmedatum** (`ck_contracts_care_admission`), der Schulvertrag das **Eintrittsdatum**, das der 1. August ist, wo niemand einen anderen Tag einträgt. Ein *Nein* gibt es nicht als Eintrag — wer nicht freigibt, lässt die Aufgabe stehen | schreibt, `entra:` | — |
| `PUT /contracts/{contract_id}/end` — Enddatum und Grund eintragen | [09](../soll-prozesse/09-hortvertrag.md) Z6 | `day_care_management`, `executive_management`; `secretariat` | **Das System unterscheidet die Kündigungsarten nicht** — ein Enddatum und ein Grund in einem Satz, wie jeder Abgang; welche Art vorlag, steht in diesem Satz. Gerechnet und gesperrt wird nichts: die Hortleitung wendet die Frist an und trägt das Ergebnis ein. Beides steht zusammen oder gar nicht (`ck_contracts_end`). Die Bestätigung mit dem Enddatum geht raus — **außer** die Kündigung ist zugleich der Abgang des Kindes, dann trägt die Abgangsbestätigung es mit | schreibt, `entra:` | — |
| `POST /children/{child_id}/sepa-mandates` — das Mandat ausfüllen und unterschreiben; **ein bestehendes wird nie geändert, sondern ersetzt** | [08](../soll-prozesse/08-schulvertrag.md) „Was dabei erhoben wird" | Erziehungsberechtigte; `secretariat` | nur Kinder der eigenen Familien. **Eine sorgeberechtigte Person genügt**, die Widerspruchsregel greift hier nicht — „es gilt wie in 02 die letzte Handlung". Es gilt sofort, die Schule zeichnet nicht gegen, der Vertrag darunter bleibt unberührt, und das abgelöste Mandat bleibt mit seinem Unterschriftsdatum stehen (`superseded_at`). Die BIC nur bei einem nicht-deutschen Konto; weicht der Kontoinhaber ab, stehen Anschrift und Mailadresse am Mandat. **Erzeugt die Optigem-Aufgabe erneut**, gleich zu welchem Zeitpunkt | schreibt, `guardian:`/`entra:` | IBAN und BIC |
| `GET /children/{child_id}/sepa-mandates` — welches Mandat gilt und welche abgelöst wurden | [08](../soll-prozesse/08-schulvertrag.md) „Was dabei erhoben wird" | `accounting`, `secretariat`; Erziehungsberechtigte | Eltern sehen das eigene ohne Kontonummer; **die Buchhaltung ist der benannte Abnehmer der Bankverbindung** und trägt sie einmal von Hand nach Optigem (`glossar.md`). Sie sieht dafür alle Kinder samt Familienzugehörigkeit — das Schulgeld hängt daran, wer zu derselben Familie gehört | liest | IBAN und BIC |
| `POST /children/{child_id}/photo-consent-invitation` — den Signaturlink an das Kind ab 14 schicken, an seine eigene Adresse | [08](../soll-prozesse/08-schulvertrag.md) „Mails und Schreiben" | Erziehungsberechtigte; `secretariat` | nur Kinder der eigenen Familien, und nur wo `consent_purposes.self_consent_age` erreicht ist. **Die private Adresse bleibt an der Zustimmungszeile** (`consents.delivery_address`) und wandert nicht nach `persons.email` (`stammdaten-api.md`) | schreibt, `guardian:`/`entra:` | — |
| `GET /signature-links/{token}` — was hier zu unterschreiben ist | [08](../soll-prozesse/08-schulvertrag.md) „Beteiligte" | niemand, ohne Anmeldung | **ein Link, kein Zugang** — der einzige Einstieg neben OTP und Entra. Er zeigt den Zweck, das Kind und den Text, sonst nichts; ein verbrauchtes oder abgelaufenes Token antwortet wie ein unbekanntes | liest | — |
| `POST /signature-links/{token}/signature` — das Fotoeinverständnis zeichnen | [08](../soll-prozesse/08-schulvertrag.md) „Beteiligte" | niemand, ohne Anmeldung | dieselbe Marke, **einmal einlösbar**: verbraucht ist sie, sobald die `consents`-Zeile ihre Antwort trägt. Sie schreibt genau zwei Zeilen — die Zustimmung des Kindes und ihre Unterschrift (`signatures.child_id`) — und sonst nichts | schreibt, `guardian:` | — |

**Der Signaturlink trägt ein signiertes, kurzlebiges Token und keine Zeile.** Anker seines
Verbrauchs ist die `consents`-Zeile, die genau eine Antwort trägt; mehr hält der Link nicht fest. —
Alternative: eine Tabelle wie `login_sessions`; Preis: ein zweiter Sitzungsmechanismus samt
Lösch-Lauf für einen Link, der eine Zeile schreibt und dessen Verbrauch dort schon steht. Das
Argument gegen ein selbsttragendes Token bei `login_sessions` — „hätte seine Reichweite eingebacken"
(`schema/stammdaten-schema.sql`) — trägt hier nicht: Dieses Token hat genau eine Reichweite, und die
ist eine Zeile.

**`POST /contracts/{contract_id}/release` baut das Dokument im Request und räumt die
Signaturbilder im selben Griff.** Scheitert der Graph-Aufruf, fällt die Freigabe mit ihm zurück. —
Alternative: das Dokument als Hintergrundaufgabe bauen; Preis: eine Einschreibung ohne Vertrag, die
niemandem auffällt, und die Prüfsumme, die 08 verlangt, entstünde nach der Bestätigungsmail.
Dieselbe Wahl wie beim Aktenordner (`stammdaten-api.md`, `PUT /children/{child_id}/class`).

**Die Bibliothek darf ein verwaistes Signaturbild tragen.** Jede Route, die einen Namenszug
entgegennimmt, legt die PNG ab, bevor die `signatures`-Zeile steht, die sie benennt; bricht die
Transaktion danach ab, bleibt sie liegen und das Aufräumen der Gegenzeichnung findet sie nie — es
geht über die Zeile. Die Datenbank ist damit sauber und die Bibliothek nicht, und das ist der
hingenommene Preis. — Alternative: den Upload hinter den letzten Flush ziehen; Preis: drei Routen
mit zwei Schreibschritten je Unterschrift, und das Fenster wird kleiner statt zu, weil zwei Systeme
ohne gemeinsame Transaktion es behalten.

**Was die Freigabe des Schulvertrags außerdem tut**, in derselben Transaktion: Sie setzt
`children.entry_date`, `school_branch_id` und `grade_level` aus dem Ziel der Bewerbung, beendet die
Bewerbung mit dem Status *eingeschrieben* (ohne `ended_by` — sie beendet niemand), legt die
Schülerakte unter der Kohorte an ([`stammdaten-api.md`](stammdaten-api.md), Q2), schickt die
Aufnahmebestätigung mit dem Vertrag — und legt **nur beim unterjährigen Eintritt** je Fremdsystem
eine Aufgabe an, dazu die des Sekretariats für die anteilige Putzdienstpflicht und, wo es eine
abgebende Schule gibt, die Schülerüberweisung. Wer zum 1. August eintritt, bekommt keine: seine
Arbeit trägt die Jahresansicht (04).

## Hortvertrag

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /care/application-context` — was für einen Hortantrag schon dasteht: Kind, Sorgeberechtigte, Anschrift, ein laufender Antrag | [09](../soll-prozesse/09-hortvertrag.md) Z1 | Erziehungsberechtigte | die eigene Anmeldung. Sie antwortet **auch der Adresse, die die Schule nicht kennt** — dann ist die Antwort leer und das Formular beginnt bei null; ein externes Kind hat keine Bewerbung und keine Freischaltung, „keine Freischaltung, kein zweiter Zugangsweg". Ein laufender Antrag steht darin, damit „wer es erneut versucht, in ihm landet" | liest | — |
| `POST /care-contracts` — den Antrag absenden: Vertrag, Modulanlage samt Wochentagen, die Hort-eigenen Angaben und die Unterschriften **in einer Transaktion** — und, wo die Schule die Familie nicht kennt, Person, Kind, Familie und Sorgeberechtigte dazu | [09](../soll-prozesse/09-hortvertrag.md) Z4 | Erziehungsberechtigte; `secretariat`, `day_care_management` | die eigene Familie, wo es sie gibt. **Ein Vorgang, eine Route** — ein Abbruch nach der Hälfte hinterließe einen Zustand, den kein Block kennt. Je Kind nur ein laufender Vertrag (`ex_contracts_care_period`); die Heimweg-Erlaubnis ist Pflicht (`ck_contracts_care_home_alone`). Mit dem Absenden entsteht die [laufende Verbindung](../soll-prozesse/hebel.md#laufende-verbindung) — beim externen Kind die Rolle, die sonst die bezahlte Gebühr spielt — und die offene Aufgabe bei der Hortleitung; fehlt eine Unterschrift, holt die Mail sie | schreibt, `guardian:`/`entra:` | — |
| `POST /contracts/{contract_id}/module-agreements` — eine Anpassung beantragen und die neue Modulanlage unterschreiben | [09](../soll-prozesse/09-hortvertrag.md) Z6 | Erziehungsberechtigte; `secretariat`, `day_care_management` | nur Kinder der eigenen Familien; **eine Person genügt** — die Anlage rührt den Bestand aus 08 nicht an. Die beantragte Anlage steht unterschrieben neben der laufenden (`ix_care_module_agreements_running` greift erst mit der Freigabe). Drei Termine gelten, und die Route rechnet keinen aus: Erhöhung zum Monatswechsel mit 14 Tagen Vorlauf, Verringerung zum Schulhalbjahr, im September beides kostenfrei | schreibt, `guardian:`/`entra:` | — |
| `POST /care-module-agreements/{care_module_agreement_id}/release` — die Anpassung freigeben, ab wann sie gilt, und die Änderungsgebühr erlassen | [09](../soll-prozesse/09-hortvertrag.md) Z6 | `day_care_management`, `executive_management` | **Ab wann ein neuer Umfang gilt, trägt die Hortleitung ein — nicht der Antrag entscheidet das**; wer zu knapp vor dem Stichtag beantragt, fängt einen Monat später an. Setzt `valid_from` und schließt die vorige Anlage (`valid_until`); die vorigen bleiben in der Akte. Erlassen wird die Gebühr, „wenn eine Stundenplanänderung der Anlass ist" — der im Vertrag benannte Fall. Legt die Optigem-Aufgabe an — ihr Text trägt den ganzen Abrechnungsstand des Kindes, das Essen eingeschlossen ([`mensa-api.md`](mensa-api.md)) — und, wo die Gebühr bleibt, die **eigene** Einmalforderung daneben | schreibt, `entra:` | — |
| `POST /contracts/{contract_id}/termination` — die Kündigung erklären | [09](../soll-prozesse/09-hortvertrag.md) Z6 | Erziehungsberechtigte; `secretariat`, `day_care_management` | nur Kinder der eigenen Familien. **Wer kündigt, kündigt für alle**, wie beim Beenden einer Bewerbung. Sie wird eine offene Aufgabe bei der Hortleitung und sonst nichts — Enddatum und Grund trägt die Zeile darüber ein; **eine eigene Mail gibt es dafür nicht**. Formlos erklärte Kündigungen — Mail, Brief, persönlich — trägt das Sekretariat auf demselben Weg ein | schreibt, `guardian:`/`entra:` | — |
| `GET /care/attendance-list?day=` — die **Betreuungsliste**: wer heute in welchem Modul ist, mit Abholzeit und Heimweg-Erlaubnis, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) | [09](../soll-prozesse/09-hortvertrag.md) „Dateien" | `day_care_staff`, `day_care_management`, `secretariat` | Listenroute, nie über OTP. Sie ersetzt den Teil der Hort-Excel, der „wer ist gebucht" beantwortet — **nicht** den Alltag: wer wirklich da war, Krankmeldungen und Vorfälle bleiben außerhalb. Beim externen Kind steht seine Schule samt Jahrgang daneben, damit die Hortkraft weiß, wann es Schulschluss hat | liest | — |
| `GET /care/occupancy` — die **Belegung**: je Wochentag, wie viele Kinder bis wann da sind | [09](../soll-prozesse/09-hortvertrag.md) Z5 | `day_care_management`, `executive_management`, `secretariat` | Listenroute, nie über OTP. **Zahlen, keine Sperre** — eine Kapazität wird nirgends gepflegt und nirgends geprüft, und beide Entscheidungen dürfen anders ausgehen, als diese Zahlen nahelegen. Derselbe Bestand wie die Liste darüber, anders gezählt; eine zweite daneben gibt es nicht | liest | — |

**Die Aufgabe, die aus dem fehlenden Masernnachweis entsteht**, legt die Freigabe des Hortvertrags
an — beim Ziel `measles_report`, dessen Rolle das Sekretariat ist. Sie zieht nichts nach; sie hält
allein fest, dass die gesetzliche Meldung erledigt ist, und die Meldepflicht endet nicht mit der
Aufnahme. Abgehakt wird sie über den Querschnitt.

## Werte dieser Domäne

Zwei Preislisten und eine Modulliste stehen hier statt in `configured_values`, weil ihr Betrag je
Schulart bzw. je Modul und Tageszahl verschieden ist (`schema/querschnitt-schema.sql`). Für alle
drei gilt die Mechanik der [Werte im System](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest)
unverändert: ein Gültigkeitstag, kein Ende, und **ein noch nicht gültiger Wert lässt sich ändern
oder zurücknehmen, ein bereits gültiger nicht mehr**.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /care-modules` — die Module samt Zeit, Abholzeit, Schulart, Essen und den Beiträgen je Tageszahl | [09](../soll-prozesse/09-hortvertrag.md) Z2 | jede Mitarbeiterrolle; Erziehungsberechtigte | unbeschränkt: **der Monatsbeitrag steht als Summe daneben, bevor sie sich entscheiden**. Das Mittagessen kommt zuzüglich, wo ein Modul es trägt, und die Geschwisterermäßigung steht als Satz dabei — gerechnet wird sie hier nicht, angewendet in Optigem | liest | — |
| `POST /care-modules`, `PATCH /care-modules/{care_module_id}` — ein Modul anlegen oder ändern | [09](../soll-prozesse/09-hortvertrag.md) „Was dabei erhoben wird" | `executive_management` | unbeschränkt. „Werden gepflegt wie jeder Preis, nicht im Code". `includes_lunch` ist **ein Häkchen und keine Zeitregel**; eine Stufenbeschränkung ohne Schulart weist das Schema ab (`ck_care_modules_grade`). Ein Modul wird nie gelöscht, sondern inaktiv | schreibt, `entra:` | — |
| `POST /care-module-prices` — den Monatsbeitrag eines Moduls für eine Tageszahl ab einem Tag setzen | [09](../soll-prozesse/09-hortvertrag.md) „Was dabei erhoben wird" | `executive_management` | unbeschränkt; je Modul, Tageszahl und Gültigkeitstag einer (`uq_care_module_prices`). **Fünf Beträge je Modul, einer je Tageszahl** — der Nachlass steckt im Betrag und nicht in einer Regel | schreibt, `entra:` | — |
| `PATCH /care-module-prices/{care_module_price_id}`, `DELETE /…` — einen angekündigten Beitrag ändern oder zurücknehmen | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | **nur solange sein Gültigkeitstag nicht erreicht ist**, sonst `400`. Dieselbe Mechanik wie `configured-values` im [Querschnitt](querschnitt-api.md), und `now()` steht in keinem CHECK: die Regel prüft die Route | schreibt, `entra:` | — |
| `GET /tuition-fees` — die Schulgeld-Staffel je Schulart und Geschwisterrang | [08](../soll-prozesse/08-schulvertrag.md) „Dateien" | jede Mitarbeiterrolle; Erziehungsberechtigte | unbeschränkt — angekündigte Erhöhungen sind sichtbar, bevor eine Familie zusagt. **Die vollständige Staffel, nicht der eine Betrag, der auf diese Familie passt**: der Rang ändert sich, wenn ein Geschwister dazukommt | liest | — |
| `POST /tuition-fees` — einen Betrag der Staffel ab einem Tag setzen | [08](../soll-prozesse/08-schulvertrag.md) „Dateien" | `executive_management` | unbeschränkt; je Schulart, Rang und Tag einer (`uq_tuition_fees`). Vier Ränge, weil der vierte alle weiteren mitträgt (`ck_tuition_fees_rank`) | schreibt, `entra:` | — |
| `PATCH /tuition-fees/{tuition_fee_id}`, `DELETE /…` — einen angekündigten Betrag ändern oder zurücknehmen | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | wie bei den Modulbeiträgen: nur vor seinem Gültigkeitstag | schreibt, `entra:` | — |

**Der Vertragstext gehört dem Querschnitt** (`contract_texts`), auch wenn er je Schulart einer ist:
Er ist dieselbe Sache wie die Teilnahmebedingungen und die Betreuungsordnung, und die Route dafür
steht in [`querschnitt-api.md`](querschnitt-api.md). Diese Domäne liest ihn an zwei Stellen — beim
Einfrieren mit der Zusage und beim Bauen des Dokuments.

## Die Läufe

Keine Route, kein Endpunkt von außen ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

| Lauf | Herkunft | Auslöser | Aktor |
|---|---|---|---|
| **Die Meldung ans Anmeldepostfach**, eine Mail je Kind, und die Bestätigung an die Eltern | [05](../soll-prozesse/05-bewerbung.md) Z5 | die bestätigte Zahlung; sie hängt am Rückruf und nicht an einer Uhrzeit. **Beide gehen raus, nachdem die Transaktion des Rückrufs steht**, nicht in ihr: Die Sendeschicht schreibt ihre `outbound_emails`-Zeile in einer eigenen Transaktion und vor dem Versand, und eine Person, die es erst in der offenen Transaktion gibt, ist für sie nicht da — der Fremdschlüssel dieser Zeile sagt es. Nachgetragen beim Bau | `system:payments` |
| **Die Erinnerung an die Bewerbungen ohne Termin**, genau einmal, eine Woche vor dem frühesten Anmeldetag des Ziels | [06](../soll-prozesse/06-anmeldetag.md) „Mails und Schreiben" | ein gerechnetes Datum je Ziel; sie geht nicht raus, wo niemand ohne Termin ist | `system:admission` |
| **Die Erinnerung an den gebuchten Termin**, ein bis zwei Tage vorher, mit Zeit und Mitbringliste | [06](../soll-prozesse/06-anmeldetag.md) „Mails und Schreiben" | der gebuchte Termin; dieselbe Mechanik wie beim Putzdienst | `system:admission` |
| **Die Erinnerung drei Tage vor Fristende** an alle Sorgeberechtigten — „der einzige Vorgang, in dem Schweigen den Platz kostet" | [08](../soll-prozesse/08-schulvertrag.md) „Fristen und Termine" | `applications.response_deadline_at` minus drei Tage, genau einmal | `system:admission` |
| **Der Warteplatz rückt eine Stufe auf**, wo sein Zielschuljahr zum 31. Juli geendet hat, samt der jährlichen Rückfrage; am Ende der Schulart endet er stattdessen | [07](../soll-prozesse/07-aufnahmeentscheidung.md) Z5 | der 1. August, ein festes Datum — Teil des [Jahreslaufs](../soll-prozesse/04-schuljahreswechsel.md) | `system:rollover` |
| **Die Meldung ans Anmeldepostfach, wenn eine Frist verstreicht** | [07](../soll-prozesse/07-aufnahmeentscheidung.md) „Mails und Schreiben" | der Ablauf von `response_deadline_at`, genau einmal; **nach draußen geht davon nichts** | `system:admission` |

**Es gibt keinen Lauf, der eine Bewerbung schließt.** Der Jahreslauf rührt eine Zusage mit laufender
Frist nicht an, und eine Bewerbung ohne Ergebnis beendet er nicht: „sie steht weiter in der Liste
ihres Zielschuljahres, bis ein Mensch sie entscheidet oder löscht."

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Die Gesundheitsangaben** samt Masernnachweis, obwohl [08](../soll-prozesse/08-schulvertrag.md)
  und [09](../soll-prozesse/09-hortvertrag.md) sie erheben: `child_health_records` und
  `measles_proofs` stehen in `schema/gesundheit-schema.sql`, ihre Routen in
  [`gesundheit-api.md`](gesundheit-api.md) — eigene Aufrufe, keine Felder dieser Formulare.
- **Das Fotoeinverständnis** als Zustimmung und die Einwilligung zum Austausch zwischen Hort und
  Schule: beide sind Q1 und laufen über `PUT /children/{child_id}/consents/{purpose}` —
  [Querschnitt](querschnitt-api.md).
- **Die Unterlagen** — anfordern, ablegen, als nicht nötig feststellen —
  [Querschnitt](querschnitt-api.md); diese Domäne legt allein den Satz an, den ein Ziel verlangt.
- **Der Rückruf des Zahlungsdienstes**, der die Bewerbung anlegt —
  [Querschnitt](querschnitt-api.md), Q3.
- **Notfallnummer, Abholberechtigte und jede Korrektur an Kontaktdaten**, die in der Durchsicht
  auffällt — [02](../soll-prozesse/02-datenaenderung.md) über
  [`stammdaten-api.md`](stammdaten-api.md).
- **Der Abgang nach der Freigabe** samt Abgangsliste, auf der der Hortvertrag als Punkt steht —
  [03](../soll-prozesse/03-irregulaerer-abgang.md) über [`stammdaten-api.md`](stammdaten-api.md).
- **Das Zusammenführen zweier Einrichtungen**, die dieselbe Schule meinen: `previous_schools` und
  `kindergartens` wachsen über `POST /applications`, und kein Block sagt, wer eine Dublette räumt.
- **Das Mittagessen**, das aus einem gebuchten Modul über 13 Uhr folgt: es entsteht hier und wird in
  [11](../soll-prozesse/11-mensa.md) gelesen — Mensa.
- **Die Klasse**, in die ein eingeschriebenes Kind kommt, und der Aktenordner, der mit ihr umzieht —
  [15](../soll-prozesse/15-klassenbildung.md) über [`stammdaten-api.md`](stammdaten-api.md).
- **Die anteilige Putzdienstpflicht**, deren Aufgabe die Freigabe anlegt: gesetzt wird sie im
  [Putzdienst](putzdienst-api.md).

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **Der Signaturlink hat keine Tabelle.** `login_sessions` trägt den OTP-Pfad, `signatures` den
  fertigen Namenszug; zwischen Versand und Zeichnen steht nichts. Die Festlegung oben trägt es
  ohne Migration — kommt je eine Tabelle, ist sie eine.
- **`applications` trägt keine Spalte für „Frist verstrichen".** Der Zustand ist gerechnet
  (`response_deadline_at` in der Vergangenheit, kein Endstatus), und das ist richtig so: „dann läuft
  sie weiter, als wäre sie nie gerissen" wäre mit einer gespeicherten Marke ein zweiter Schreibweg.
- **`contracts.runs_until` ist nicht gerechnet.** 08 nennt „den 31. Juli des Schuljahres, in dem die
  Schulart endet", 09 „bis auf Weiteres" — die Route setzt es bei der Freigabe, und der Kommentar am
  Index sagt selbst, welcher Fall dabei nicht gefangen ist: zwei laufende Schulverträge mit
  verschiedenem `runs_until`, die keine Ablösung sind.
- **`care_module_agreements.valid_from` ist erst mit der Freigabe gesetzt**
  (`ck_care_module_agreements_released`). Eine beantragte Anlage trägt deshalb kein Datum, und die
  Ansicht der Eltern kann nicht sagen, ab wann die Anpassung gilt — sie sagt, dass sie beantragt
  ist. Das ist die Absicht des Blocks („nicht der Antrag entscheidet das") und keine Lücke.
- **`applications.ended_by` kennt nur `parents` und `school`.** Der Jahreslauf, der einen Warteplatz
  am Ende der Schulart beendet, ist keines von beidem und trägt `school` — der Lauf handelt für die
  Schule, und ein dritter Wert brächte eine Unterscheidung, die kein Block trifft.

## Die Prüfung

Drei Durchgänge, jeder mechanisch.

### Gegen das Schema, Spalte für Spalte

| Fund | Entscheidung |
|---|---|
| `applications.submitted_at` ist `NOT NULL` und trägt den Zahlungszeitpunkt | `POST /applications` legt nichts an; die Zeile entsteht im Rückruf, und dort steht der Zeitpunkt fest |
| `ix_applications_running` ist partiell auf `ended_at IS NULL` | Ein zweiter Anlauf nach Absage oder Rückzug ist eine neue Bewerbung und kostet die Gebühr erneut; die Route prüft gegen denselben Index, den sie später verletzt hätte |
| `ck_applications_final_ended` verlangt zu jedem Endstatus ein `ended_at` | **Wer den Endstatus setzt, setzt beides in einem Zug** — beim Bau ist das die *Entscheidung* und nicht die Freigabe: Eine Absage ist ein Endstatus, und der CHECK lässt sie keinen Moment ohne `ended_at` stehen. Nach draußen geht davon trotzdem nichts, denn die Elternansicht hängt an `released_at` und nicht am Status. Rückzug und Einschreibung setzen beides ebenso; bei der Einschreibung bleibt `ended_by` leer, weil sie niemand beendet |
| `ck_applications_record_needs_slot` bindet Spur und Anmerkung ans Zeitfenster | `PATCH …/record` weist die Spur ohne Termin mit `400` ab — „wer nie gebucht hat, hat auch keine Spur" |
| `applications.first_grade_level`/`final_grade_level` kommen aus `school_branches` | Die Route setzt sie nie aus dem Rumpf, sondern liest sie zur Schulart; `ck_applications_grade_level` hält die Zielstufe darin |
| `admission_day_slots.places_override` ist nullable | Leer heißt „die Zahl des Tages"; `PATCH` setzt sie nur, wo abgewichen wird, und die Buchungsroute rechnet beide Fälle gegen dieselbe Grenze |
| `contracts.contract_text_id` ist `NOT NULL` | Die Fassung friert mit der Zusage ein — deshalb legt die Freigabe der Entscheidung den Vertrag an und nicht die erste Elternhandlung daran |
| `ck_contracts_care_admission` verlangt das Aufnahmedatum erst zur Freigabe | `POST /care-contracts` kennt es noch nicht; `POST /contracts/{id}/release` trägt es ein, und ohne es rechnete `ex_contracts_care_period` als „seit jeher" |
| `ck_contracts_application` bindet die Bewerbung an den Typ | Ein Hortvertrag hat nie eine, ein Schulvertrag immer; dieselbe Route trennt daran, was sie verlangt |
| `ex_contracts_care_period` schließt überlappende Hortverträge aus | Der Klasse-5-Fall bleibt zulässig — der alte schließt zum 31. Juli, der neue nimmt zum 1. August auf; die Route rechnet nichts, sie schreibt und lässt den Constraint antworten |
| `uq_contract_responses` ist eine Zeile je Person und Vertrag | `PUT …/responses/{person_id}` ist deshalb ein `PUT` und kein `POST`: eine geänderte Antwort ist dieselbe Zeile |
| `ck_contract_responses_review` bindet die Durchsicht an die Annahme | Wer ablehnt, füllt die Strecke nicht aus; die Route weist die Durchsicht danach mit `400` ab |
| `sepa_mandates.superseded_at` markiert das abgelöste Mandat | `POST …/sepa-mandates` schreibt zwei Zeilen in einer Transaktion — die neue und den Stempel auf der alten; geändert wird nie eine |
| `uq_sepa_mandates_reference` ist ein schlichtes UNIQUE | Die Mandatsreferenz erzeugt die Route und nimmt sie nicht entgegen; sie ist kein Feld des Formulars |
| `ix_care_module_agreements_running` ist partiell auf `valid_until IS NULL` | Die beantragte Anlage steht unterschrieben neben der laufenden, weil sie noch kein `released_at` trägt — sonst gäbe es keinen Weg, eine Anpassung zu beantragen |
| `application_unlocks` trägt keine Ablaufspalte | Die 14 Tage rechnet die Route aus `created_at`; ein zweiter Ort für dieselbe Tatsache entstünde sonst |

### Gegen die beiden Fundament-Pläne

| Kollision | Entscheidung |
|---|---|
| „**Familie, Kind und Sorgeberechtigte entstehen nicht hier**" ([`stammdaten-api.md`](stammdaten-api.md)) | **bestätigt, und hier ist das „dort"**: `POST /applications` über den Rückruf und `POST /care-contracts` sind die beiden Wege, auf denen sie entstehen. Ein `POST /children` gibt es weiterhin nicht |
| „Das SEPA-Mandat ausfüllen und ersetzen — Anmeldung" (dort, Rand) | **wandert hierher** als `POST /children/{child_id}/sepa-mandates`. Die Tabelle bleibt in Stammdaten, die Handlung gehört der Vertragsstrecke |
| „Eine neue abgebende Schule anlegen (`previous_schools`) — Anmeldung" (dort, Rand) | **wandert hierher**, aber ohne eigene Route: `POST /applications` legt sie an, wo sie fehlt (Festlegung oben). Die Randzeile dort ist damit eingelöst |
| „Der Signaturlink des Kindes ab 14 — Anmeldung" ([`querschnitt-api.md`](querschnitt-api.md), Rand) | **wandert hierher**, drei Routen: die Einladung, die Ansicht und das Zeichnen |
| „Die Platzannahme (`contract_responses`) — Anmeldung" (dort, Rand) | **wandert hierher** als `PUT /contracts/{id}/responses/{person_id}`. Ihre Zeile in `consent_purposes` bleibt der Nachweis, dass die Frage gestellt wurde |
| „Der Unterlagensatz, den ein Ziel verlangt — Anmeldung" (dort, Rand) | **wandert hierher**: die Bewerbung legt ihn an, je Ziel einmal, und `POST /children/{child_id}/documents` bleibt die Handroute für alles Weitere |
| `GET /children/{child_id}/photo-consent` liefert Ja nur, wenn alle erwarteten Personen erteilt haben | **unverändert**; diese Domäne entscheidet allein, **wer erwartet wird** — ab 14 das Kind, und wer nach seiner Einsichtsstufe nicht unterschreibt, wird nicht erwartet |
| `PUT /children/{child_id}/enrolment` setzt Schulart, Stufe und Eintritt von Hand (dort) | **bleibt dort** und ist die Korrektur, nicht der Weg: regulär setzt sie `POST /contracts/{id}/release`. Die Randzeile dort sagt das bereits |

### Auf Zukunftssicherheit

1. **Die Domäne hat zwei Enden, die anderen gehören.** Vorn der Zahlungsrückruf, hinten die
   Einschreibung — beide schreiben in fremde Tabellen (`children`, `payments`), und beide tun es in
   der Transaktion dieser Domäne. Das ist die Bauform, die `hebel.md` verlangt („der Vorgang entsteht
   mit der bestätigten Zahlung"), und der Preis ist benannt: Wer eine dieser Regeln ändert, ändert
   eine Route hier und nicht dort.
2. **Der Hortvertrag ist der Beweis, dass der Vertragsvorgang trägt.** Er hat ein Augenpaar statt
   zweier, keine Antwortfrist, kein Sekretariat, das vorlegt, und keine Bewerbung — und trotzdem
   dieselben vier Routen. Käme ein dritter Vertrag (KITA), wäre er ein `contract_type` und keine
   Routenänderung.
3. **Eine Rolle mehr kostet hier nichts.** Wer wen sieht, hängt an der Schulart, an der Familie oder
   an der Hortzugehörigkeit; keine Route zählt Rollen auf, die nicht in
   [`hebel.md`](../soll-prozesse/hebel.md#rollen) stehen.
4. **Die Warteliste hat keine Mechanik, die veralten könnte.** Priorität, Nachrücken und „wer ist der
   Nächste" sind Menschenentscheidungen; das System sortiert und rechnet nichts. Ein späterer
   Automatismus wäre ein neuer Block und keine Änderung an diesen Routen.
5. **Ein verschwindendes Feld bricht keine Oberfläche.** Fällt der Zweckbeschluss für Konfession,
   Beruf und Staatsangehörigkeit negativ aus (`[?]` in 05), zeigt die Durchsicht vier Felder
   weniger; die Routen bleiben, wie sie sind.
6. **Die drei Termine der Anpassung sind Text und keine Rechnung.** Erhöhung, Verringerung und
   September stehen im Vertragstext, die Route prüft sie nicht — ändert der Träger sie, ändert sich
   der Text und keine Bedingung.
7. **Der Preis, den diese Domäne dauerhaft zahlt**, ist die Zahlungssitzung als einziger Ort eines
   halben Vorgangs. Sie ist bewusst gewählt (`gemeinsam.md`), und sie ist die eine Stelle, an der
   ein Fehler im Zahlungsdienst eine ausgefüllte Bewerbung kostet — nicht das Geld, aber die
   Tipparbeit.

## Festlegungen

Bestätigt und damit normaler Text; der verworfene Weg samt Preis bleibt stehen, weil er sonst als
Vorschlag wiederkommt. Die `[A!]`-Marke oben behält ihre Marke auch bestätigt
(`prompts/gemeinsam.md`).

**Die Freigabe der Entscheidungen legt den Schulvertrag an.** — Alternative: ihn mit der ersten
Elternhandlung entstehen lassen; Preis: `contracts.contract_text_id` ist `NOT NULL`, und die Fassung
fröre dann je Elternteil verschieden ein — genau der Fall, den 08 ausschreibt.

**Die Bewerbungsliste ist eine Route mit Filtern und nicht drei Routen.** — Alternative: je Name
eine; Preis: drei Ownership-Regeln für denselben Bestand, und die Arbeitsliste des Anmeldetags liefe
beim ersten Fix von der Bewerbungsliste weg.

**`POST /contracts/{contract_id}/submission` gibt es nur für den Schulvertrag.** — Alternative: sie
auch dem Hortvertrag geben; Preis: eine Prüfung, die kein Block verlangt, und ein zweites Augenpaar
dort, wo 09 ausdrücklich eines vorsieht.

**Der Betreuungsbedarf wird über `PATCH …/record` ergänzt und nicht neu erhoben.** — Alternative:
eine eigene Route am Anmeldetag; Preis: zwei Schreibwege auf dieselbe Spalte, und
`ck_applications_care_need` stünde an beiden.

## Offene Fragen

Keine neue `[?]`. Die vier, die diese Domäne berühren, stehen schon an ihrer Stelle: der
Zweckbeschluss für Konfession, Beruf und Staatsangehörigkeit (05), die Aufbewahrungsfrist für
Bewerbungen ohne Aufnahme (05) und für Vertrags- und Zahlungsdaten (03), der Inhalt des
Elternfragebogens (06) und die drei Anpassungen am Betreuungsvertragstext (09).
