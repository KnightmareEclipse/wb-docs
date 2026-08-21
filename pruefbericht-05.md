# Prüfbericht — unabhängiger Gegenlauf

Lauf: 2026-08-20. Ladelauf in der vorgeschriebenen Reihenfolge (stammdaten → querschnitt →
Rest): alle 14 Dateien rc=0. Alle 14 Prüfskripte gegen die **vollständige** Datenbank:
alle rc=0.

Funde werden je Domäne angehängt, Sortierung nach Gewicht am Ende.

## stammdaten

```
[F1] stammdaten · Klasse 1 · login_codes
Block 02 sagt „nur eine neue Mailadresse gilt erst, wenn der Bestätigungscode
eingegeben ist", und dazu geht „eine Info an die bisherige Adresse, dass sie
ersetzt wurde" — die alte bleibt also bis zur Bestätigung in `persons.email`
stehen. Die neue hat damit bis dahin keinen Ort: `login_codes` (Zeile 851–880)
trägt sie als `email`, aber ohne jeden Bezug auf die Person, deren Adresse sie
werden soll; die Begründung „Bewusst KEIN Fremdschlüssel auf `persons`: der Code
bestätigt auch die Adresse einer Familie, die es im Bestand noch gar nicht gibt"
trägt für `purpose = 'login'` und gerade nicht für `'email_confirmation'`, wo die
Person immer existiert. In der Datenbank steht damit nirgends, wessen Adresse
gerade auf Bestätigung wartet.
Vorschlag: nullable `person_id` an `login_codes`, mit CHECK „bei
`email_confirmation` gesetzt, bei `login` leer".
```

Angesehen, nicht als Fund gewertet
stammdaten · `employees.entra_object_id` sah nach einer siebten Angabe aus,
        die Block 13 („führt hier aber sechs Angaben und keine siebte")
        ausschließt; die sechs sind die Personalangaben, die Entra-Kennung ist
        die Anmeldeidentität und keine davon.
stammdaten · `employees.first_working_day` nullable, obwohl grenzkarte.md (Q4)
        den Beschäftigungszeitraum „beidseitig nötig" nennt; Block 13 stellt ihn
        ausdrücklich frei („weil an ihm nichts hängt"), und der Block schlägt die
        Karte.
stammdaten · fehlende `payers`-Tabelle sah nach einem Bruch der Grenzkarte (Q3)
        aus; Block 08 verlangt „Das abgelöste Mandat bleibt mit seinem
        Unterschriftsdatum stehen", was die Karte in ihrer Form nicht trägt —
        als `[A!]` benannt.
stammdaten · `persons.email` ohne UNIQUE sah nach einer fehlenden Regel aus;
        05 lässt zwei Sorgeberechtigte dieselbe Mailbox teilen.
stammdaten · alle 27 `expect_accept`-Proben schreiben wirklich (ROW_COUNT > 0),
        und jede der 39 `expect_reject`-Proben scheitert an dem Constraint, den
        ihr Name nennt — beides einzeln nachgemessen, nicht am Text abgelesen.

## querschnitt

```
[F2] querschnitt · Klasse 5 · contract_texts
`querschnitt-schema-check.sql` Zeile 658 behauptet die Regel „derselbe
Vertragstext zweimal zum selben Gültigkeitstag" und damit `uq_contract_texts
UNIQUE (code, valid_from)`. Zeile 147 legt die erste Fassung aber mit
`OVERRIDING SYSTEM VALUE ... (1, ...)` an; die Identity-Folge steht danach
weiter auf 1, und die Probe ohne Schlüssel scheitert schon an
`pk_contract_texts`. Nachgemessen: auf einer frischen Datenbank mit
`ALTER TABLE contract_texts DROP CONSTRAINT uq_contract_texts` wird dieselbe
Zeile weiterhin abgewiesen — die Probe belegt die Regel nicht, die sie nennt.
Es ist genau die Falle, die dasselbe Skript für `payees` in
rechnungsfreigabe-schema-check.sql Zeile 95–99 schon einmal benannt und dort
behoben hat.
Vorschlag: `contract_texts` wie dort ohne feste Schlüssel und ohne
OVERRIDING anlegen.

[F3] querschnitt · Klasse 3 · configured_values, Zeile 705
Das Schema zitiert hebel.md als „jederzeit änderbar und im System, nie im
Code"; hebel.md („Geld im System, alles andere fest") schreibt „ist jederzeit
änderbar und **steht** im System, nie im Code". Sinngemäß richtig, wörtlich
nicht.
Vorschlag: das Wort „steht" ins Zitat aufnehmen.
```

Angesehen, nicht als Fund gewertet
querschnitt · die sieben Löschstufen im Dateikopf gegen alle 25 blockierenden
        Fremdschlüssel (NO ACTION/RESTRICT) auf ihre Tabellen nachgerechnet:
        jede referenzierende Tabelle geht ihrer referenzierten voraus oder
        kaskadiert vorher weg (`contract_responses`, `signatures`,
        `family_guardians`, `family_contacts`); kein RESTRICT blockiert.
querschnitt · `signatures` am Vertragsvorgang statt am Dokument widerspricht
        grenzkarte.md Q2; Block 08 („Vor der Freigabe entsteht kein Dokument")
        gibt es her, und es ist als `[A!]` benannt.
querschnitt · `ix_consents_person_child_purpose` sah nach Klasse 2 aus (eine
        Ablehnung ließe sich nicht widerrufen und blockierte die spätere
        Erteilung); die Antwort wird laut Kommentar in derselben Zeile ersetzt,
        und das lassen `ck_consents_answer`/`ck_consents_revocation` zu.
querschnitt · `signature_level` mit `CHECK (= 'simple')` ist eine Spalte mit
        genau einem zulässigen Wert — Geschmack, kein Fund; die Begründung
        steht daneben.

## anmeldung

```
[F4] anmeldung · Klasse 1 · contracts
Block 09 macht das Aufnahmedatum zur Pflicht der Freigabe: „Gibt frei und
unterschreibt für den Träger und trägt dabei das Aufnahmedatum ein" (Schritt 5),
und „Das Aufnahmedatum trägt die Hortleitung bei der Freigabe ein, immer von
Hand und für jedes Kind einzeln". Im Schema hängt `contracts.admission_date` an
keinem Constraint: `ck_contracts_care_only` erlaubt es nur am Hortvertrag,
`ck_contracts_care_home_alone` sichert allein `may_walk_home_alone`. Ein
freigegebener Hortvertrag ohne Aufnahmedatum geht durch — nachgemessen —, und
`ex_contracts_care_period` rechnet ihn dann als `daterange(NULL, NULL)`, also
als „seit jeher und bis auf Weiteres": Der nächste, ordnungsgemäße Hortvertrag
desselben Kindes (Klasse-5-Fall aus 04, ab 01.08.) wird danach mit
`ex_contracts_care_period` abgewiesen, obwohl er sich mit nichts überschneidet.
Die drei Gegenproben zu „Je Kind ein laufender Hortvertrag" arbeiten selbst mit
`admission_date IS NULL` und belegen deshalb die Zeitraumregel nur schwach.
Vorschlag: CHECK „contract_type <> 'care' OR released_at IS NULL OR
admission_date IS NOT NULL".

[F5] anmeldung · Klasse 3 · Dateikopf, Zeile 42
Das Schema begründet die fehlende Notfallbetreuungs-Struktur mit dem Zitat „da
ist ein Notfall, und dann geht niemand erst ins Portal". Dieser Satz steht in
keinem Block, in hebel.md nicht und in grenzkarte.md nicht; Block 09 schreibt
„im Notfall geht niemand erst ins Portal". Die Entscheidung trägt, das Zitat
nicht.
Vorschlag: den Satz aus 09 wörtlich übernehmen.

[F6] anmeldung · Klasse 3 · care_module_prices, Zeile 271
Das Schema zitiert 09 als „Ermäßigungen dagegen nicht — die stehen als Satz
dabei"; Block 09 schreibt „und Ermäßigungen stehen nur als Satz dabei"
(Schritt 2). Sinngemäß richtig, wörtlich nicht.
Vorschlag: Wortlaut aus 09 übernehmen.
```

Angesehen, nicht als Fund gewertet
anmeldung · `care_interest` neben `care_need_level_id` sah nach zwei Orten für
        einen Sachverhalt aus (rules.md 1); 06 nennt sie „dieselbe Angabe …
        hier um den Umfang ergänzt", und `ck_applications_care_need` bindet
        beide aneinander — „kein Interesse" ist zudem nicht als fehlender
        Umfang darstellbar.
anmeldung · die harte Platzgrenze je Zeitfenster (06, „ein volles Zeitfenster
        ist nicht buchbar") steht nicht als Constraint; sie zählt über Zeilen
        und ist ohne Trigger nicht zu halten — als Auslassung benannt.
anmeldung · `ix_contracts_running` fängt zwei laufende Schulverträge mit
        verschiedenem `runs_until` nicht; das Schema benennt die Lücke selbst
        und den Grund (dem Schulvertrag fehlt ein Startdatum).
anmeldung · `waiting_priority` widerspricht grenzkarte.md („Die Warteliste
        selbst hat keine Rangfolge"); Block 07 vergibt sie ausdrücklich
        („Warteplatz samt Priorität"), der Block schlägt die Karte.

## putzdienst

```
[F7] putzdienst · Klasse 2 · cleaning_slot_buyouts / payments
Block 01 gibt dem Sekretariat zwei Griffe, die es im Betrieb regelmäßig
braucht: „Das Sekretariat darf jeden Termin einer Familie streichen oder
verschieben, auch einen selbst reservierten", und „Ebenso, wenn es einer
Familie Termine von Hand zuteilt oder streicht". Eine `cleaning_assignments`
-Zeile hat kein Absage-Feld, streichen heißt also löschen — und
`fk_cleaning_slot_buyouts_assignment` (ON DELETE CASCADE) nimmt den
Einzel-Freikauf mit, `fk_payments_cleaning_slot_buyout` (ON DELETE CASCADE) die
bestätigte Zahlung. Nachgemessen: nach dem Streichen eines freigekauften
Termins stehen null bestätigte Zahlungen. Damit ist eine geleistete
Sofortzahlung spurlos weg, obwohl 01 sagt „Zurücktreten kann man von einem
Freikauf nicht" und der Löschanker des Freikaufs der Zyklus ist, nicht die
einzelne Verwaltungshandlung.
Vorschlag: RESTRICT statt CASCADE auf `fk_cleaning_slot_buyouts_assignment`,
damit ein freigekaufter Termin nicht gestrichen, sondern nur verschoben wird.
```

Angesehen, nicht als Fund gewertet
putzdienst · die gemeinsame Pflichtmenge steht als Zeile je Zyklus statt mit
        `valid_from` wie die übrigen Werte im System (01: „Sie trägt diesen Tag
        als Gültigkeit ein"); der Zyklus trägt dieselbe Wirkung — „nie mitten
        im laufenden Jahr" — und die Abweichung ist begründet.
putzdienst · verkürzte Klammerzitate („(null Termine)", „(anteilig)") gegen 01
        gehalten: der Wortlaut innerhalb der Klammer stimmt, gekürzt ist nur
        der Nachsatz.
putzdienst · alle 32 `expect_reject`-Proben scheitern an dem Constraint, den
        ihr Name nennt; alle 14 `expect_accept`-Proben schreiben wirklich.

## ferien

```
[F8] ferien · Klasse 4 · holiday_cost_coverage_codes
Der Lösch-Lauf ist über alle Domänen als sieben Stufen aufgeschrieben
(querschnitt-schema.sql, Kopf, Zeile 31–88) — „die Abfolge über alle Domänen
nennt keine, und ohne sie kommt der Lauf beim ersten Versuch nicht durch".
`holiday_cost_coverage_codes` kommt darin nicht vor, ist aber die einzige
Nicht-Werteliste, die eine Stufe-1-Tabelle mit NO ACTION festhält
(`fk_holiday_bookings_coverage_code`) — nachgemessen über alle Fremdschlüssel
der siebzehn Stufen-Tabellen. Die Zeile trägt eine Mailadresse und den Satz, an
wen berechnet wird, also ein Personendatum; die Regel dafür steht allein in
ferien-schema.sql („der Lösch-Lauf räumt erst die Buchung, dann den Code"). Wer
den Lauf aus der Stufenliste baut, lässt die eingelösten Codes stehen.
Vorschlag: den Code als Nachsatz zu Stufe 1 in die Aufzählung aufnehmen.
```

Angesehen, nicht als Fund gewertet
ferien · `holiday_care_notes` je Kind UND Programm, obwohl 10 „je Kind eine
        Anmerkung" sagt; als `[A]` benannt, und der Block stellt sie
        ausdrücklich neben das, was „je Buchung" steht — je Kind allein hieße,
        die Notiz von vor drei Jahren steht auf der heutigen Teilnehmerliste.
ferien · `payments.amount_cents` neben `holiday_bookings.amount_cents` sah nach
        rules.md 1 aus; beide Quellen (10 und grenzkarte.md Q3) verlangen den
        Betrag, und der zusammengesetzte Fremdschlüssel bindet sie — genau die
        benannte Ausnahme.
ferien · das Zitat „Anlass × Betrag × Status × Zahlungsreferenz" lässt den
        Klammerzusatz der Grenzkarte („(Domäne + Vorgang)") weg; der Rest ist
        wörtlich, und der Zusatz ändert die Aussage nicht.

## gesundheit

```
[F9] gesundheit · Klasse 3 · drei Zitate
Drei wörtliche Zitate stehen so nicht in ihrer Quelle:
Zeile 42 — „nimmt es selbst" (08); Block 08 schreibt „bei Medikamenten dazu,
ob das Kind sie selbst nimmt". Die Formulierung ist erfunden.
Zeile 55 — „die Mensa sieht davon allein diese beiden Punkte —
Unverträglichkeit, Allergie —, den schmalsten Ausschnitt …" (11); Block 11
schreibt „die Mensa sieht davon allein diese beiden Punkte, den schmalsten
Ausschnitt …" — der Einschub stammt aus dem vorangehenden Satzteil und ist in
das Zitat hineingenommen worden.
Zeile 167 — „gar kein Dokument entsteht" (grenzkarte.md); dort steht „Es
entsteht also gar kein Dokument".
Vorschlag: alle drei auf den Wortlaut der Quelle bringen.
```

Angesehen, nicht als Fund gewertet
gesundheit · Zeckenentfernung und Behandlungszeitraum stehen gegen
        grenzkarte.md an `health_traits`; Block 08 zählt beide unter den
        Punkten dieses Bestands auf, der Block ist jünger — und
        querschnitt-schema.sql hält dieselbe Entscheidung an `consent_purposes`
        fest, also steht die Zeckenentfernung nicht an zwei Orten.
gesundheit · `has_certificate` neben `certificate_document_id` sah nach
        rules.md 1 aus; „ob ein Attest vorlag" (08) und „ob eines abgelegt ist"
        sind zwei Tatsachen — gezeigt und wieder mitgenommen ist der Regelfall.

## mensa

```
[F10] mensa · Klasse 1 · meal_subscriptions.starts_on
Block 11 nennt zwei Regeln für den Beginn: „Das Abo beginnt frühestens am
1. Oktober" und „Wer später anmeldet, beginnt zum nächsten Monatsersten" —
`starts_on` ist damit immer ein Monatserster und nie im August oder September.
Beides ließe sich als CHECK ausdrücken, beides fehlt, und anders als bei den
übrigen Auslassungen dieses Schemas („die Pflicht trägt die Anwendung", „die
harte Grenze trägt die Anwendung") steht daneben kein Satz, wer die Regel
sonst hält — der Kommentar an `starts_on` wiederholt sie nur.
Vorschlag: CHECK auf den Monatsersten, oder den Satz nachtragen, dass die
Anwendung sie hält.
```

Angesehen, nicht als Fund gewertet
mensa · eigene Tabellen statt der Betreuungsmodul-Struktur widersprechen
        grenzkarte.md („die eine Stelle, an der bewusst zusammengelegt wurde");
        Block 11 gibt dem Abo drei eigene Mechaniken, die das Modul nicht
        kennt — als `[A!]` benannt.
mensa · `ex_meal_subscriptions_period` lässt zwei Abos desselben Kindes im
        selben Schuljahr nacheinander zu; 11 verbietet nur das Nebeneinander
        und lässt die Neuanmeldung nach der Kündigung ausdrücklich zu.

## klassenorganisation

Kein Fund. Angesehen: `uq_class_representatives` gegen 16 („mehrere ohne
Rangfolge", „zwei Ämter in zwei Klassen" möglich) — trägt; die fehlende Prüfung
auf ein Kind in der Klasse ist wörtlich so verlangt.

## klassenbildung

Kein Fund. Die Datei legt nichts an; die vier Angaben der heutigen Liste stehen
nachweislich (`persons.address_id`, `persons.gender_id`, `children.family_id`,
`classes.class_teacher_id`), und der gestrichene Zusammensetzungswunsch ist ein
Fall von Klasse 7 mit Deckung: Block 15 („Die Gründe … bleiben außerhalb")
schlägt grenzkarte.md.

## m365

Kein Fund. Kontostatus und Offboarding-Schritt fehlen gegen grenzkarte.md,
Block 13 gibt beides her („Ein Handgriff für Schüler wie Mitarbeitende", die
Schuladresse als Beleg für das Konto).

## selfservice

Kein Fund. Die Ausweitung der Änderungsgrenze auf `children.entry_date` für die
Kinder des Vollimports geht über Block 02 hinaus, ist aber aus README und 08
belegt und im Kommentar benannt.

## ags

Kein Fund. Das Prüfskript belegt die Abwesenheit mechanisch (keine AG-Tabelle,
kein AG-Feld in einer fremden Tabelle) — das ist hier die einzige prüfbare
Aussage.

## elternbonus

```
[F11] elternbonus · Klasse 1 · configured_values
Block 14 nennt „Drei Werte im System gehören der Geschäftsführung: der
Monatsbetrag (derzeit 10 €) und die beiden Pflichtstundenzahlen (derzeit 15 und
10)", hebel.md führt sie ebenso auf („Elternbonus 10 € je Monat und Familie mit
15 bzw. 10 Pflichtstunden je Schuljahr"). elternbonus-schema.sql verweist dafür
auf `configured_values`. Deren Codeliste in querschnitt-schema.sql (Zeile
685–724) zählt acht Codes auf und schließt mit „Jeder von ihnen ist von der
Geschäftsführung änderbar" — die drei des Elternbonus fehlen darin, und
anderswo im Schema kommen sie auch nicht vor (über alle vierzehn Dateien
gegriffen). Es ist die einzige Lücke dieser Art: alle übrigen Werte aus
hebel.md haben entweder einen Code oder eine eigene Preistabelle.
Vorschlag: die drei Codes in die Aufzählung an `configured_values` aufnehmen.
```

Angesehen, nicht als Fund gewertet
elternbonus · `confirming_employee_name` neben `confirming_employee_id` darf
        laut `ck_parent_work_entries_confirmer` gleichzeitig stehen, obwohl der
        Kommentar „ein zweiter Ort für dieselbe Tatsache" ausschließt; ein XOR
        wäre hier nicht baubar — der Lösch-Lauf muss den Namen setzen, bevor er
        den Fremdschlüssel auf NULL setzt, und CHECKs lassen sich nicht
        aufschieben. Die Form ist die einzig mögliche, und das Schema sagt es.
elternbonus · `ck_parent_work_entries_school_year` sah nach Klasse 2 aus (der
        nachgereichte Zettel); 14 entscheidet ausdrücklich anders — „was später
        kommt oder liegen bleibt, zählt nicht".

## rechnungsfreigabe

```
[F12] rechnungsfreigabe · Klasse 5 · das Prüfskript läuft nur einmal
`rechnungsfreigabe-schema-check.sql` legt seine `payees` ohne feste Schlüssel an
(Zeile 101) und rechnet danach mit `payee_id = 1` und `= 2` (Zeilen 499, 503,
507 und im Belegteil). Identity-Folgen sind nicht transaktional: Nach dem
ROLLBACK steht die Folge weiter, der zweite Lauf bekommt 3 und 4, und das
Skript scheitert an `fk_expense_claims_payee`. Nachgemessen auf einer frischen
Datenbank: Lauf 1 rc=0, Lauf 2 rc=3; alle dreizehn übrigen Prüfskripte
überstehen beide Läufe. Das ist der Preis der Reparatur, mit der die
`pk_payees`-Falle (Zeile 95–99) geschlossen wurde — und es verstößt gegen
rules.md Abschnitt 3, „Jedes Skript ist idempotent — beliebig oft wiederholbar".
Wer den Lauf wiederholt, liest einen roten Schema-Befund, der keiner ist.
Vorschlag: die beiden `payees` mit `RETURNING` in Variablen nehmen, statt mit
1 und 2 zu rechnen.

[F13] rechnungsfreigabe · Klasse 3 · zwei Zitate
Zeile 144 — „Es verschwindet nichts von selbst … die Angaben zum Beleg bleiben
zehn Jahre in Weltenbaum, und was danach mit einem Jahrgang geschieht,
entscheidet die Geschäftsführung von Hand." Block 12 schreibt dazwischen „die
Anhänge in SharePoint,"; die drei Worte sind ohne Auslassungszeichen
herausgenommen, mitten im zitierten Satz.
Zeile 450 — „Sekretariat und Schulleitung sehen hier nur ihre eigenen Belege
und die, die auf sie zeigen" (12). Block 12 schreibt „Sekretariat und
Schulleitung haben hier keine Sonderstellung — abweichend von der
Standardantwort sehen sie nur ihre eigenen Belege und die, die auf sie zeigen";
Subjekt und Prädikat sind über den Einschub hinweg zusammengezogen und „hier"
ist eingefügt.
Vorschlag: beide auf den Wortlaut bringen bzw. die Auslassung kennzeichnen.
```

Angesehen, nicht als Fund gewertet
rechnungsfreigabe · `ix_expense_claims_duplicate` trägt nur die Hälfte des
        Dublettenhinweises (Empfänger und Betrag); der zweite Fall — „bei einer
        Fahrt nach Strecke … treten Datum und Strecke an seine Stelle" — steht
        als Daten in `travel_details` und ist damit rechenbar. Ein fehlender
        Index ist keine fehlende Regel.
rechnungsfreigabe · `ck_expense_claim_items_self_approval` gegen alle sechs
        Zahlwege durchgegangen: gesperrt ist genau „an mich" und jede Fahrt,
        offen bleibt, was nicht bei ihm ankommt — deckt sich mit 12.
rechnungsfreigabe · `expense_claim_attachments` statt einer Q2-Zeile
        widerspricht grenzkarte.md nicht: Q2 trägt Dokumente mit Kindbezug,
        und `documents.child_id` ist NOT NULL.

---

# Schluss

## Nach Gewicht

1. **[F4]** anmeldung — freigegebener Hortvertrag ohne Aufnahmedatum; der
   nächste ordnungsgemäße Vertrag desselben Kindes wird danach abgewiesen.
2. **[F7]** putzdienst — ein gestrichener Termin nimmt den bezahlten Freikauf
   und seine bestätigte Zahlung mit.
3. **[F2]** querschnitt — die Gegenprobe zu `uq_contract_texts` belegt die
   Regel nicht, die sie nennt.
4. **[F12]** rechnungsfreigabe — das Prüfskript ist nur beim ersten Lauf grün.
5. **[F1]** stammdaten — die auf Bestätigung wartende Mailadresse hat keinen
   Bezug zu ihrer Person.
6. **[F8]** ferien — `holiday_cost_coverage_codes` fehlt in der Stufenliste des
   Lösch-Laufs.
7. **[F11]** elternbonus — die drei Werte des Bonus fehlen in der Codeliste an
   `configured_values`.
8. **[F10]** mensa — die beiden Beginn-Regeln des Abos stehen weder als
   Constraint noch als benannte Auslassung.
9. **[F5]** anmeldung — ein Zitat, das in keinem Block steht.
10. **[F13]** rechnungsfreigabe — zwei Zitate mit stiller Auslassung bzw.
    zusammengezogenem Satz.
11. **[F9]** gesundheit — drei Zitate, eines davon erfunden, eines
    zusammengesetzt.
12. **[F6]** anmeldung — ein sinngemäßes Zitat aus 09.
13. **[F3]** querschnitt — ein sinngemäßes Zitat aus hebel.md.

Ohne Fund durchgekommen: **putzdienst** nur bis auf F7 — vollständig ohne Fund
sind **klassenorganisation**, **klassenbildung**, **m365**, **selfservice** und
**ags**.

## Alle `[A!]` über alle Domänen

| Marke | Domäne | Aussage | entscheidet ein Block sie? |
|---|---|---|---|
| mensa-schema.sql:12 | mensa | eigene Tabellen statt der Betreuungsmodul-Struktur | **ja** — 11 gibt dem Abo drei eigene Mechaniken (1. Oktober, 3. Januar, eigener Monatsbeitrag) und schließt Dokument und Unterschrift aus |
| querschnitt-schema.sql:11 | querschnitt | Q1–Q5 stehen in einer eigenen Datei | nein — kein Block spricht über Dateigrenzen; grenzkarte.md Regel 4 stützt es |
| querschnitt-schema.sql:273 | querschnitt | eine Signatur hängt am Vertragsvorgang, nicht am Dokument | **ja** — 08: „Vor der Freigabe entsteht kein Dokument" |
| querschnitt-schema.sql:805 | querschnitt | der Bezug der Änderungsspur ist Tabellenname plus Schlüssel als Text | nein — hebel.md verlangt nur einen Mechanismus, nicht seine Form |
| stammdaten-schema.sql:15 | stammdaten | kein `updated_at`/`updated_by` auf irgendeiner Tabelle | teilweise — hebel.md schließt einen zweiten Protokollmechanismus aus, sagt aber nichts über eine Bequemlichkeitsspalte |
| stammdaten-schema.sql:671 | stammdaten | das SEPA-Mandat als eigene Tabelle mit Historie statt `payers` | **ja** — 08: „Das abgelöste Mandat bleibt mit seinem Unterschriftsdatum stehen" |
| stammdaten-schema.sql:855 | stammdaten | der Anmeldecode bekommt eine Tabelle in Stammdaten | nein — hebel.md verlangt Ratelimit und Fehleingabenzähler, sagt aber nicht, wo sie stehen |

## Was mir zum Urteilen gefehlt hat

- Der **Betreuungsvertrag** und die **Preislisten** (Hort, Mensa, Ferien) liegen
  nicht im Repo. Die Zitate daraus — die Geschwisterermäßigung „Ab dem 2. Kind …
  10%", „Zuzüglich Mittagessen", die Notfallbetreuungs-Beträge in
  anmeldung-schema.sql — konnte ich nicht gegen ihre Quelle halten. Alle
  übrigen 524 Zitate über alle vierzehn Dateien habe ich maschinell gegen
  `soll-prozesse/`, `wb-docs/` und `prozesse.md` gehalten.
