# Rechnungsfreigabe — Routen

Aus [`12-rechnungsfreigabe.md`](../soll-prozesse/12-rechnungsfreigabe.md); es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht. Es ist die Domäne,
die **kein Kind, keine Familie und keine Klasse** kennt — jeder Ownership-Check dieser Datei zählt
über Mitarbeitende, nie über `family_guardians`.

**Gegenprobe:** Die Ablauftabelle hat **4 Zeilen**; alle vier handeln im System und alle vier tragen
Routen dieser Datei. Es gibt **27 Routen**; **14** nennen eine Ablaufzeile, **13** einen Abschnitt
des Blocks. Keine Abweichung.

## Vier Abweichungen, die jede Route dieser Datei trägt

Sie stehen hier einmal, weil sie an jeder Zeile unten gälten:

- **Sehen:** nicht die [Standardantwort](../soll-prozesse/hebel.md#standardantworten). Ein Beleg ist
  sichtbar für seinen Einreicher, für **jede Führungskraft, die ihn hatte** (jede Zeile in
  `expense_claim_items`, auch die weitergeleitete), für `accounting` — auch solange er noch bei einer
  Führungskraft liegt — und für `executive_management`. **Sekretariat und Schulleitung haben hier
  keine Sonderstellung**: Sie sehen ihre eigenen Belege und die, die auf sie zeigen, sonst nichts.
- **Der Admin sieht hier nichts**, und dafür braucht es keine Ausnahme von
  [`gemeinsam.md`](gemeinsam.md#wer-darf-und-worauf-eingeschränkt): Er erbt die Rechte der
  Verwaltung, und die hat in dieser Domäne keine über ihre eigenen Belege hinaus. Was er erbt, ist
  damit sein eigener Beleg.
- **Ändern:** nur, wen der Ablauf nennt. Nach dem Absenden ändert der Einreicher nichts mehr — er
  zieht zurück und reicht die Kopie neu ein —, und das Sekretariat ändert hier nichts, weil es hier
  auch nichts sieht.
- **Der [offizielle Umweg](../soll-prozesse/hebel.md#der-offizielle-umweg) ist die
  Geschäftsführung, nicht das Sekretariat.** Die Bauform bleibt dieselbe wie überall — dieselbe
  Route, andere Rolle —, nur die Rolle ist eine andere: `executive_management` steht an jeder Route,
  die sonst eine Führungskraft ruft, und ist „hier immer auch Führungskraft … wählbar wie jede
  andere, ohne dass ihr jemand die Rolle geben müsste".

## Zwei Rollen, und keine Krücke mehr

`approver` und `executive_management` stehen hier **nebeneinander an jeder Route**, nicht
ineinander. Im heutigen Portal sind sie verschmolzen — `isManager` ist wahr, sobald jemand
`Geschäftsführung` trägt —, und das ist kein Entwurf, sondern ein Zwang: In der SharePoint-Rollenliste
lässt sich je Person sinnvoll nur **eine** Rolle vergeben, und die Geschäftsführung braucht beides,
den Manager-Blick und die Sicht auf alles.

**Der Zwang fällt weg.** `employee_roles` trägt mehrere Rollen je Person
([`hebel.md`](../soll-prozesse/hebel.md#rollen)), und die Geschäftsführung braucht hier trotzdem
keine zweite: Sie steht an jeder Entscheidungsroute ohnehin, ohne `approver` zu tragen (oben), und
`GET /expense-claims` gibt ihr den ganzen Bestand. Zwei Sichten, eine Rolle, kein Sonderfall im Code.

## Enge Rolle

**Eine, und nur für zwei Spalten:** `expense_claims.third_party_account_holder` und
`third_party_iban` liegen hinter `backend_expense_bank`, gebaut wie `backend_health_note`
(`wb-backend`, Gesundheits-Migration) — Spalten-GRANT, keine `if`-Abfrage
([`glossar.md`](../glossar.md), [`gemeinsam.md`](gemeinsam.md)).

Der Kreis dahinter ist **weiter als bei `sepa_mandates.iban`** und das ist kein Widerspruch: Dort
hält die Buchhaltung sie allein, hier gehört sie zum Beleg — „die Bankverbindung eingeschlossen,
ohne sie könnte niemand zahlen". Die Rolle trennt deshalb nicht Person von Person, sondern **Route
von Route**: `GET /expense-claims/{id}` und `POST /expense-claims` setzen sie, die Liste, die
Auswertungen und die Jahreszahlen nie. Ohne sie stünde eine IBAN in jeder Antwort, die einen Beleg
streift.

Alles Übrige — Betrag, Zweck, Projekt, Konto, Fahrtweg — trägt keine enge Rolle: kein Art.-9-Feld,
kein Kind.

## Pfad

`/expense-claims` ist der Beleg, `/expense-claim-items/{…}` sein Teil. **Der Teil hängt nicht unter
dem Beleg**, obwohl er ihm gehört: Weiterleiten und Aufteilen erzeugen Zeilen, die eine andere
Führungskraft anspricht, ohne den Beleg zu kennen, den sie nie gesehen hat — sie bekommt die Kennung
ihres Teils aus ihrer Warteschlange und ruft sie direkt. Die drei Wertelisten und die Vorlagen stehen
ohne Anker (`/payees`, `/cost-projects`, `/ledger-accounts`, `/claim-templates`), weil sie keinem
Beleg gehören.

## Die drei Wertelisten

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /payees` — die Empfängerliste zur Auswahl | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1 | jede Mitarbeiterrolle, die der Schule wie die der KITA | unbeschränkt — sie trägt Firmen, keine Personendaten der Schule. **Zusammengeführte Einträge fallen aus der Auswahl**, sind aber lesbar: `merged_into_payee_id` gesetzt heißt „gibt es noch, wird nicht mehr gewählt", und die Altbelege zeigen weiter darauf | liest | — |
| `POST /payees` — einen fehlenden Empfänger anlegen | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1 | jede Mitarbeiterrolle | unbeschränkt: „Jeder Einreicher darf einen anlegen, den er nicht findet — sonst hielte der Bäcker um die Ecke das Einreichen auf." Der Name ist eindeutig (`uq_payees_name`); ein zweiter Versuch mit demselben Namen bekommt die vorhandene Zeile und keinen Fehler, sonst legte jeder Tippfehler die Alternative nahe | schreibt, `entra:` | — |
| `PATCH /payees/{payee_id}` — einen Eintrag berichtigen **oder** ihn in einen anderen zusammenführen | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Was dabei erhoben wird" | `accounting` | „die Buchhaltung berichtigt einen Eintrag oder führt zwei zusammen, wenn doch ‚DB' neben ‚Deutsche Bahn' steht". Eine Zeile für beides, weil das GRANT genau die zwei Spalten trägt (`name`, `merged_into_payee_id`); ein Ziel, das selbst zusammengeführt ist, wird abgewiesen, sonst entstünde eine Kette. **Gelöscht wird nie** — „ein Eintrag bleibt, solange ein Beleg auf ihn verweist" | schreibt, `entra:` | — |
| `GET /cost-projects` — die Projekte zur Auswahl | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Entscheidungen" | jede Mitarbeiterrolle | unbeschränkt; standardmäßig nur `is_active`. Der Einreicher braucht sie, weil er „Projekt und Konto gleich mit angibt, soweit er sie kennt" | liest | — |
| `POST /cost-projects` — ein Projekt anlegen | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Entscheidungen" | `accounting`, `executive_management` | „Die Liste der Projekte und Buchungskonten pflegt die Buchhaltung; sie folgt dem Kontenrahmen in Optigem, weil dort gebucht wird" — der Kontenrahmen ist die Quelle, nicht diese Route. **Die Geschäftsführung steht daneben**, wie an jeder Stelle dieser Domäne, und aus demselben Grund: Fällt die Buchhaltung aus, hält sonst ein fehlendes Projekt jeden Beleg auf, der darauf zeigt | schreibt, `entra:` | — |
| `PATCH /cost-projects/{cost_project_id}` — Code oder Name richtigstellen, oder das Projekt stilllegen | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Was heute schiefgeht" | `accounting`, `executive_management` | Genau der Fall, an dem das heutige System scheitert: „vier Bezeichnungen enthalten Tippfehler und lassen sich nicht korrigieren, ohne die Altbelege abzuhängen". **Stilllegen statt löschen** (`is_active = false`): nimmt den Wert aus jeder Auswahl, lässt jede Zeile stehen, die schon darauf zeigt | schreibt, `entra:` | — |
| `GET /ledger-accounts` — die Buchungskonten zur Auswahl | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Entscheidungen" | jede Mitarbeiterrolle | wie bei den Projekten | liest | — |
| `POST /ledger-accounts` — ein Konto anlegen | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Entscheidungen" | `accounting`, `executive_management` | wie bei den Projekten | schreibt, `entra:` | — |
| `PATCH /ledger-accounts/{ledger_account_id}` — richtigstellen oder stilllegen | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Was heute schiefgeht" | `accounting`, `executive_management` | wie bei den Projekten | schreibt, `entra:` | — |

## Die Vorlagen

Eine Tabelle trägt beide Sorten, „welche es ist, sagt die Zahl ihrer Anteile"
(`schema/rechnungsfreigabe-schema.sql`) — **und daran hängt, wer sie anlegen darf**, denn die
Zuständigkeit folgt im Block genau dieser Grenze.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /claim-templates` — die Vorlagen samt ihren Anteilen | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1, „eine Buchungsvorlage füllt das Wiederkehrende vor" | jede Mitarbeiterrolle | unbeschränkt; ein Anteil heißt Buchungsvorlage, mehrere heißen Aufteilungsvorlage, und die Antwort sagt welches — der Einreicher wählt beide an derselben Stelle | liest | — |
| `POST /claim-templates` — eine Vorlage samt ihren Anteilen anlegen | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Entscheidungen" | `accounting` für **einen** Anteil, `executive_management` für **mehrere** | Die Rolle hängt an der Zahl der Anteile und nicht am Pfad: „die Buchhaltung die Buchungsvorlagen, weil ihr Projekte und Konten gehören, die Geschäftsführung die Aufteilungsvorlagen, weil deren Schlüssel die Freigabe der beteiligten Führungskräfte vorwegnimmt". Die Anteile müssen zusammen `10000` Basispunkte ergeben — das prüft die Route, weil eine Summe über mehrere Zeilen kein CHECK trägt; je Vorlage steht ein Projekt höchstens einmal (`uq_claim_template_shares`) | schreibt, `entra:` | — |
| `PUT /claim-templates/{claim_template_id}` — Name und Anteile neu setzen | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Entscheidungen" | wie oben, nach der Zahl der Anteile **nach** der Änderung | „Eine geänderte Vorlage gilt ab dem nächsten Beleg; laufende ändern sich nicht" — das trägt das Schema von selbst, weil der Beleg den Stand kopiert und nicht nachliest. Die Anteile werden geladen und abgeglichen, nie als Menge gelöscht ([`gemeinsam.md`](gemeinsam.md#schreiben)). Eine Buchungsvorlage kann so zur Aufteilungsvorlage werden — dann entscheidet die neue Zahl über die Rolle | schreibt, `entra:` | — |

## Der Beleg

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /expense-claims` — einreichen: Beleg, sein erster Teil, die Fahrtangaben und die Anhänge in **einer** Transaktion | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1 | jede Mitarbeiterrolle, die der Schule wie die der KITA | **Ein Vorgang, eine Route** ([`gemeinsam.md`](gemeinsam.md#schreiben)): „der Beleg entsteht mit dem Absenden oder gar nicht", genau das, was heute in einem Fehlerzustand endet. Die Sperre gegen die eigene Freigabe trägt `ck_expense_claim_items_self_approval` und nicht die Route. Bei `claim_type = 'invoice'` sind Empfänger, Betrag, Zweck, Zahlweg und **mindestens ein Anhang** Pflicht — das Letzte prüft die Route, das Schema kann es nicht; bei `travel` nach Strecke gibt es keinen, „weil es keinen gibt". Der Kilometersatz wird aus `configured_values` zum **Zeitpunkt des Einreichens** gelesen und in `travel_details.mileage_rate_cents` festgeschrieben — er **hat sich schon geändert** (0,25 € vor 0,30 €) und wird es wieder; eine spätere Änderung rechnet keine alte Fahrt um ([`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest)), und im Code steht er nirgends, anders als heute (`DEFAULT_MILEAGE_RATE` in `enums.ts`). Läuft der Beleg über eine Aufteilungsvorlage, entstehen ihre Teile **hier** und der Umlauf entfällt (unten). Gutschriften sind erlaubt, der Betrag darf negativ sein | schreibt, `entra:` | `backend_expense_bank` bei `payment_route = 'to_third_party'` |
| `POST /expense-claims/{expense_claim_id}/withdrawal` — zurückziehen | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1 | der Einreicher | **allein der Einreicher, und nur solange keine Führungskraft ihn oder einen seiner Teile freigegeben hat** — „eine getroffene Entscheidung fällt nicht dadurch weg, dass er es sich anders überlegt". Sonst `400`. `ck_expense_claims_end` lässt Rückzug, Buchung und Storno nur einzeln zu; ein zurückgezogener Beleg lebt nicht wieder auf | schreibt, `entra:` | — |
| `GET /expense-claims?state=&calendar_year=&payee_id=&cost_project_id=` — die Übersicht: **eine Liste für alle vier Sichten**, weil die Sichtbarkeitsregel oben sie ohnehin trennt | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Was dabei erhoben wird" | jede Mitarbeiterrolle | Der Einreicher sieht seine, die Führungskraft die, die auf sie zeigen, `accounting` und `executive_management` alle — **dieselbe Route liefert damit die Warteschlange, die Freigabeliste und die eigene Übersicht**. Eine Liste und nicht drei — die Sichtbarkeitsregel trennt sie ohnehin. — Alternative: je Sicht eine eigene Route (`/pending`, `/to-book`, `/mine`); Preis: dieselbe Ownership-Bedingung steht dreimal und läuft beim ersten Fix auseinander. Jede Zeile trägt, **wie lange sie schon wartet, gerechnet ab `last_action_at`** und nicht ab dem Einreichen, und ob die Führungskraft, bei der sie liegt, **ausgeschieden** ist (`employees.last_working_day`, [13](../soll-prozesse/13-m365-konten.md)) — „kein Ping, keine Aufgabe, keine Mail, nur die eine Angabe". Listenroute, deshalb nie über den OTP-Pfad; Eltern reichen hier ohnehin nie etwas ein. **Ohne Bankverbindung** | liest | — |
| `GET /expense-claims/{expense_claim_id}` — der einzelne Beleg: Angaben, Teile samt Entscheidung und Begründung, Anhänge, Fahrtangaben, Alter, **Dublettenhinweis** | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Was dabei erhoben wird" | der Kreis oben | Der Hinweis wird hier **gerechnet, nicht gespeichert** (`ix_expense_claims_duplicate`): Empfänger und Betrag eines anderen Belegs innerhalb von 30 Tagen; bei einer Fahrt nach Strecke, die keinen Empfänger trägt, Datum und Strecke. Er nennt den anderen Beleg mit Einreicher und Datum, **sperrt nichts** und schweigt, wenn beide über dieselbe Buchungsvorlage laufen. Die Führungskraft sieht ihn beim Entscheiden, die Buchhaltung ein zweites Mal — **eine Auswertung an einer Stelle, zwei Leser**, keine zweite Regel | liest | `backend_expense_bank` |
| `GET /expense-claims/travel-suggestions` — die eigenen letzten Strecken: Abfahrt, Ankunft, Kilometer | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1 | jede Mitarbeiterrolle | **nur die eigenen**: „eine gefahrene Strecke wird ihm aus seinen eigenen letzten vorgeschlagen". Wer fremde Strecken vorgeschlagen bekäme, erführe, wer wann wohin gefahren ist. Kein Bestand, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) aus `travel_details` über die eigenen Belege | liest | — |

## Die Entscheidung

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `PUT /expense-claim-items/{expense_claim_item_id}/decision` — freigeben (mit Projekt, Konto, „im Budget", freiwilliger Notiz) oder ablehnen (mit Pflichtbegründung) | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z2 | die gewählte Führungskraft; `executive_management` (Umweg) | **genau die Person, auf die der Teil zeigt**, per Ownership-Check über `employees.entra_object_id` gegen `approver_employee_id` — nicht per Rolle, dieselbe Mechanik wie die bestätigende Person in [`elternbonus-api.md`](elternbonus-api.md). Nur solange nichts entschieden ist (`ck_expense_claim_items_decision`); freigegeben heißt mit Projekt (`ck_expense_claim_items_approved`). **Eine Ablehnung trifft den ganzen Beleg** — „lehnt einer ab, ist der ganze Beleg abgelehnt, ein halb freigegebener Beleg ist keiner". **Die Belegnummer wird gezogen, wenn der letzte Teil freigegeben ist**, lückenlos je Kalenderjahr: in derselben Transaktion, unter einer Sperre auf das Jahr — eine Sequenz hätte Lücken, und `uq_expense_claims_number` hält nur die Eindeutigkeit. Ein abgelehnter Beleg bekommt keine, und ein **Teil** bekommt nie eine eigene — so hält es auch das heutige Portal, das sie nur für den Beleg ohne Vater zieht (`ClaimWorkflowService`, `!claimToUpdate.parentSubID`). Zum Einreicher zurück geht nichts | schreibt, `entra:` | — |
| `PATCH /expense-claim-items/{expense_claim_item_id}` — korrigieren: Angaben oder Betrag ändern, **Grund Pflicht** | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z2 | die gewählte Führungskraft; `executive_management` (Umweg) | Sie entscheidet nichts — „zwei Wege davor entscheiden nichts, sie ändern nur, worüber und wer entschieden wird" —, deshalb bleibt der Teil danach offen und wird freigegeben oder abgelehnt wie jeder andere. **Der Betrag ist mit korrigierbar, und zwar an jedem Beleg**: Ein Zahlendreher des Einreichers wird hier geradegezogen, statt ihn den Beleg neu einreichen zu lassen. Eine Betragsänderung zieht `expense_claims.amount_cents` mit; bei einer Fahrt korrigiert sie **Ticketbetrag oder Strecke** und nicht den Betrag, der folgt daraus (`ck_travel_details_amount`, zusammengesetzter Fremdschlüssel). **Am aufgeteilten Beleg trägt sie alle Teilbeträge mit, und die Entscheidungen der übrigen Teile fallen weg** — sie galten einer Summe, die es nicht mehr gibt; jede betroffene Führungskraft bekommt ihren Ping erneut. — Alternative: den Betrag am aufgeteilten Beleg sperren, sobald ein anderer Teil entschieden ist; Preis: genau der Weg „ablehnen und neu einreichen", den diese Route ersparen soll. **Anhänge lassen sich nie austauschen**, auch nicht hier: „wer den falschen angehängt hat, reicht neu ein" | schreibt, `entra:` | — |
| `POST /expense-claim-items/{expense_claim_item_id}/forwarding` — an genau eine andere Führungskraft weiterleiten, **Grund Pflicht** | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z2 | die gewählte Führungskraft; `executive_management` (Umweg) | **Eine Transaktion, zwei Zeilen**: die alte bekommt `forwarded_at` und bleibt als Spur stehen, die neue trägt die neue Führungskraft und ein frisches `last_action_at`. An genau eine, nie an mehrere — dafür ist Aufteilen da. Die Sperre gegen die eigene Freigabe gilt auch hier, „sonst käme der Beleg über den Umweg doch bei ihm an", und sie steht am Teil, weil jede Weiterleitung eine eigene Zeile erzeugt | schreibt, `entra:` | — |
| `POST /expense-claims/{expense_claim_id}/split` — aufteilen statt entscheiden: **mindestens zwei** Projekte, je Teil eine Führungskraft und ein Teilbetrag | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z3 | die Führungskraft, bei der er liegt; `executive_management` (Umweg) | **Die Teilbeträge müssen den Betrag genau treffen** — das prüft die Route, weil eine Summe über mehrere Zeilen kein CHECK trägt. Der offene Teil des Aufteilenden wird ersetzt, nicht ergänzt; jede beteiligte Führungskraft entscheidet danach über ihren Teil wie über einen eigenen Beleg. **Nicht für einen Beleg, der schon über eine Aufteilungsvorlage läuft** — dort steht der Schlüssel und der Umlauf ist entfallen. Was beim Runden übrig bleibt, fällt auf den größten Anteil und wird nicht gespeichert. Eine Freigabe, mehrere Buchungen — **eine** Zahlung mit einer Nummer | schreibt, `entra:` | — |

## Der Abschluss

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `PATCH /expense-claim-items/{expense_claim_item_id}/ledger-account` — das Buchungskonto berichtigen | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z4 | `accounting` | **Das Konto, nie das Projekt**: „Wohin gebucht wird, ist ihr Handwerk, wem die Ausgabe gehört, bleibt die Entscheidung der Führungskraft." Eine eigene Route und keine zweite Rolle an der Korrektur darüber, weil sie zu einer anderen Zeit und ohne Pflichtbegründung geschieht — und weil sie **vor** dem Deckblatt liegen muss, das das berichtigte Konto trägt. Nur zwischen Freigabe und Abschluss | schreibt, `entra:` | — |
| `PUT /expense-claims/{expense_claim_id}/booking` — abschließen: „abgehakt heißt gebucht" | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z4 | `accounting` | Nur ein Beleg, dessen **alle** Teile freigegeben sind. Setzt `booked_at`/`booked_by`; danach führt kein Weg zurück — „ein falsch gebuchter Beleg wird in Optigem berichtigt". **Keine Nachzieh-Aufgabe daneben**: „der freigegebene Beleg ist ihre Aufgabe" — diese Domäne legt keine `sync_tasks`-Zeile an und hat kein Ziel in `sync_targets` ([`querschnitt-api.md`](querschnitt-api.md)) | schreibt, `entra:` | — |
| `POST /expense-claims/{expense_claim_id}/void` — stornieren mit **Pflichtbegründung** | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z4 | `accounting` | „wenn er so nicht buchbar ist: der Beleg fehlt, ist unlesbar oder passt nicht zum Betrag" — die Buchbarkeit, nicht die Sache. **Ein Storno trifft bei einem aufgeteilten Beleg alle Teile**, weil es am Beleg steht und nicht am Teil (`voided_at`/`voided_reason`). Ein stornierter Beleg lebt nicht wieder auf | schreibt, `entra:` | — |

## Dateien und Auswertungen

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /expense-claim-attachments/{expense_claim_attachment_id}/content` — den angehängten Beleg ausliefern | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Dateien" | wer den Beleg daneben sehen darf | **dieselbe Regel wie für die Zeile, kein zweites Rechtesystem** — die Bauform von `GET /documents/{document_id}/content` ([`querschnitt-api.md`](querschnitt-api.md)), aber eine eigene Route, weil die Anhänge in `expense_claim_attachments` stehen und nicht in `documents` (Q2 trägt Dokumente mit Kindbezug, ein Kassenzettel hat keinen). Zwingend gebraucht: Die Führungskraft entscheidet über einen Beleg, den sie sehen muss, und hat keinen Zugriff auf die Bibliothek | liest | — |
| `GET /expense-claims/{expense_claim_id}/document` — die **eine PDF** aus allen Anhängen, mit Deckblatt | [12](../soll-prozesse/12-rechnungsfreigabe.md) Z4, „Dateien" | `accounting`, `executive_management` | [Frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) und **nirgends gespeichert**: „So trägt sie immer den letzten Stand, es gibt keine zweite Fassung, die jemand aufräumen müsste." **Für einen abgelehnten, stornierten oder zurückgezogenen Beleg entsteht sie nie** (`400`), bei einer Aufteilung genau einmal für den ganzen Beleg. Das Deckblatt trägt Belegnummer, Datum, Betrag, Empfänger, Einreicher und je Teil Projekt, Konto, Freigeber und Anteil — „damit sie in Optigem für sich steht und auch in zehn Jahren ohne Weltenbaum lesbar ist". Das ist eine **Datei** und keine Druckansicht: Sie wird abgelegt, also gilt der Weg aus [`oberflaechen.md`](../oberflaechen.md) — Vorlage plus Graph-Konvertierung —, nicht der Absatz „Liste" in [`gemeinsam.md`](gemeinsam.md#liste) | liest | — |
| `GET /expense-claims/statistics?start=&end=` — die Auswertungen: Summen je Projekt und Konto, häufigste Empfänger, gefahrene Kilometer, mittlere Liegezeit | [12](../soll-prozesse/12-rechnungsfreigabe.md) „Dateien" | jede Mitarbeiterrolle | „sichtbar für die, die die Belege ohnehin sehen" — **gerechnet über genau die Menge, die `GET /expense-claims` demselben Aufrufer zeigt**, und nicht über den ganzen Bestand: Sonst wäre die Summe je Projekt der Umweg, auf dem eine Führungskraft die Belege sieht, die ihr nie vorlagen. Für `accounting` und `executive_management` ist das der ganze Bestand. [Frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste), Listenroute, nie über den OTP-Pfad | liest | — |

## Der Teams-Ping

**Keine Route, und keine Mail.** „In diesem Block geht keine Mail raus"; der Anstoß ist ein Ping, der
auf den Beleg führt, und er hängt an der Handlung, die ihn auslöst — wie jede Mail dieses Systems
([`querschnitt-api.md`](querschnitt-api.md), „Es gibt keine Route, die eine Mail verschickt").

| Ping | ausgelöst von |
|---|---|
| an die gewählte Führungskraft, sobald ein Beleg bei ihr eingeht | `POST /expense-claims`, `POST …/forwarding`, `POST …/split` |
| an den Einreicher, sobald etwas anders ist als eingereicht — korrigiert, abgelehnt, storniert, mit der Begründung | `PATCH /expense-claim-items/{id}`, `PUT …/decision` (Ablehnung), `POST …/void` |
| an `executive_management` bei jeder Freigabe über der **Meldegrenze** | `PUT …/decision`, wenn der letzte Teil freigegeben ist |

Drei Regeln, die die Route mitprüft: Die Meldegrenze misst **am ganzen Beleg und nicht am Teil einer
Aufteilung**, es gilt der Wert **zur Freigabe** und nicht zum Einreichen, und **wer eine Handlung
selbst auslöst, bekommt dafür keinen Ping**. Die Buchhaltung bekommt keinen — „ein Ping geht an den,
der sonst nicht hinsähe, nie an eine Warteschlange, die ohnehin abgearbeitet wird". Freigabe und
Abschluss pingen den Einreicher nicht, sie stehen in seiner Übersicht.

## Keine Läufe

Diese Domäne hat **keinen einzigen** ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)), und das
ist eine Aussage: „Kein Beleg verfällt, keine Aufgabe verfällt, es wird nicht eskaliert", kein
Löschlauf („es verschwindet nichts von selbst"), keine Wochenmail. Sie ist damit die einzige der
vierzehn ohne Zeitgeber — der einzige Zeitbezug ist das Kalenderjahr der Einreichung, und das rechnet
`ck_expense_claims_calendar_year` aus `created_at`.

## Zwei Werte im System

Zwei Codes in `configured_values`, benannt nach demselben Muster wie `cleaning_buyout_cents`:
**`mileage_rate_cents`** (0,30 €, gelesen zum Einreichen) und **`expense_report_threshold_cents`**
(250 €, gelesen zur Freigabe). Sie sind Teil der Liste, die die Geschäftsführung einträgt (`backlog/`, TASK-051);
gepflegt werden sie über die vier Routen auf `/configured-values`
([`querschnitt-api.md`](querschnitt-api.md)), und die Eltern sehen sie nie — „die beiden Werte der
Rechnungsfreigabe sehen allein die, die dort arbeiten"
([`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest)).

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Die wählbare Führungskraft** — `GET /employees/selectable`
  ([`stammdaten-api.md`](stammdaten-api.md)) nennt [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1
  bereits als einen ihrer drei Anlässe. **Der `role_code`-Parameter wird wiederholbar**: Diese
  Domäne braucht `approver` **und** `executive_management` in einer Antwort — genau die Regel, nach
  der das heutige Portal seine Auswahl füllt (`Rolle eq 'Manager' or Rolle eq 'Geschäftsführung'`,
  dazu `Active`, in `RoleService.getManagerOptions`). `Active` fällt bei uns weg: Es ist
  `employees.last_working_day`, und die Route filtert ohnehin danach. — Alternative: zweimal rufen
  und im Frontend zusammenführen; Preis: die Regel, wer wählbar ist, steht dann in der Oberfläche.
- **Die Änderungsspur** — `GET /change-log` ([`querschnitt-api.md`](querschnitt-api.md)); sie folgt
  hier dem abweichenden Sehrecht oben und **nicht** dem Sekretariat, und das steht dort bereits.
- **Die Rollenvergabe** — `PUT /employees/{employee_id}/roles`
  ([`stammdaten-api.md`](stammdaten-api.md)): „Die Rollen liegen heute in einer eigenen Liste des
  Beleg-Portals; künftig gibt es die eine Rollenvergabe in Weltenbaum und keine zweite daneben."
  Diese Domäne legt keine an.
- **Das Austrittsdatum**, aus dem „ausgeschieden" folgt — `employees.last_working_day`
  ([13](../soll-prozesse/13-m365-konten.md), [`stammdaten-api.md`](stammdaten-api.md)). Es wird
  gelesen, nie gepflegt.
- **Kein Zahlungsvorgang.** Q3 wird nicht berührt: Ausgezahlt wird über Bank und Optigem, und eine
  Gutschrift ist hier ein negativer Betrag und keine `payments`-Zeile
  ([`querschnitt-api.md`](querschnitt-api.md), „Am Schema aufgefallen").
- **Der Lösch-Lauf** (17) muss diese Domäne **aussparen** — der Block sagt es ausdrücklich: „Hier
  läuft keine Frist ab, die etwas auslöst, und gelöscht wird nur, was die Geschäftsführung nach zehn
  Jahren selbst freigibt." Er trägt aber den Namen der ausgeschiedenen Person nach, bevor
  `fk_expense_claims_submitter` und `fk_expense_claim_items_approver` die Kennung auf `NULL` setzen.
- **Die Belegerkennung aus dem Foto** — „ein eigenes Vorhaben, kein Nebensatz hier"; heute trägt sie
  keine Spalte und keine Route.
- **Die Spendenbescheinigung** — sie wird außerhalb ausgestellt; der Beleg hält nur fest, ob eine
  gebraucht wird (`payment_route`).

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **`uq_expense_claim_attachments` verbietet, dass zwei Belege dieselbe Datei tragen.** Das ist
  richtig — eine Datei gehört einem Beleg —, heißt aber, dass die Kopie eines abgelehnten Belegs die
  Anhänge **physisch kopieren** muss (Graph-Kopie, neue Element-Kennung), statt auf dieselben zu
  zeigen. Die Kopie ist deshalb **keine eigene Route**, sondern
  `POST /expense-claims` mit `copied_from_expense_claim_id`: Die Angaben liest die Oberfläche aus
  `GET /expense-claims/{id}` und lässt sie ändern, und das Feld sagt der Route nur, welche Dateien
  sie mitkopiert. — Alternative: `POST /expense-claims/{id}/copy`; Preis: zwei Routen, die dasselbe
  anlegen, und die zweite kennt die Änderungen des Nutzers nicht.
- **`expense_claims.claim_number` ist nur je Kalenderjahr eindeutig, nicht lückenlos.** Das sagt der
  Kommentar dort selbst; die Lückenlosigkeit trägt allein die Route, und sie braucht dafür eine
  Sperre auf das Jahr. Ein gleichzeitiger Abbruch nach dem Ziehen der Nummer hinterlässt eine Lücke,
  die niemand mehr füllt — die Transaktion ist die einzige Klammer.
- **`ck_expense_claim_items_self_approval` greift nicht mehr, wenn der Mitarbeitendeneintrag des
  Einreichers fort ist.** Der Kommentar sagt es ausdrücklich. Für die Route heißt das: Ein Beleg,
  dessen Einreicher gegangen ist, könnte von dem freigegeben werden, der ihn eingereicht hat — nur
  gibt es den dann nicht mehr. Kein Fund, aber die Grenze der Regel.
- **Der Zahlweg ist ein CHECK und soll eine Werteliste werden.** `ck_expense_claims_route` zählt
  seine sechs Werte auf; ein siebter kostet heute eine Migration, und die Regel dieses Hauses ist
  seit Langem „Lookup-Tabelle statt CHECK". **Entschieden: er wird `payment_routes`** — und die
  Rechnung dafür steht hier, weil sie nicht klein ist: Zwei CHECKs greifen auf den Wert zu, und ein
  CHECK sieht keine zweite Tabelle. `ck_expense_claims_third_party` (Kontoinhaber und IBAN nur bei
  „an Dritte") und `ck_expense_claim_items_self_approval` (die Sperre gegen die eigene Freigabe,
  `payment_route <> 'to_me'`) brauchen deshalb je ein **Merkmal an der Werteliste**,
  `requires_bank_details` und `is_reimbursement`, das an der Belegzeile **mitgeführt** und von einem
  zusammengesetzten Fremdschlüssel an seiner Quelle gehalten wird — dieselbe Bauform, die diese
  Datei für Einreicher, Belegart und Betrag schon dreimal trägt (`rules.md` Abschnitt 1, Ausnahme).
  Der Preis ist damit: eine Tabelle, zwei mitgeführte Merkmale, zwei zusammengesetzte
  Fremdschlüssel und eine Migration, die die vorhandenen Spalten umhängt. Gekauft wird, dass ein
  siebter Zahlweg eine Zeile ist — angelegt von Buchhaltung oder Geschäftsführung, ohne dass jemand
  Code anfasst. — Alternative: beim CHECK bleiben; Preis: jede Änderung an einer Liste, die dem
  Kontenrahmen folgt, wartet auf einen Entwicklungslauf. Migration in `wb-backend`, danach
  `schema/rechnungsfreigabe-schema.sql` samt Prüfskript nachziehen (`backlog/`); **bis dahin steht
  im Schema der CHECK**, und diese Datei sagt hier, dass das der alte Stand ist.
- **`expense_claim_items.last_action_at` hat einen `DEFAULT`, aber kein `ON UPDATE`.** Jede
  schreibende Route dieser Datei muss ihn selbst neu stempeln; vergisst sie es, sagt die Übersicht
  ein falsches Alter, und kein Test sieht es von außen.
- **Die Anhänge brauchen eine eigene Bibliothek.** `expense_claim_attachments` zeigt auf
  `sharepoint_libraries`, und das Schema verlangt „eine eigene Site mit eigenen Rechten, getrennt
  von der Schülerakte". `[A!]` **Es sind damit drei und nicht zwei**: Belege, die App schreibt und
  liest, **niemand direkt** — auch nicht Sekretariat und Geschäftsführung, denn „Sekretariat und
  Schulleitung haben hier keine Sonderstellung", und in der Bibliothek der Akte sähen sie alles.
  Die Kinder-Bibliotheken führen einen Ordner je Kind, diese einen je Kalenderjahr — der Beleg
  kennt kein Kind. — Alternative: die Anhänge in die Akten-Bibliothek legen; Preis: genau diese
  Sonderstellung, gegen den Block. `grenzkarte.md` Q2, `oberflaechen.md` und TASK-053 tragen die
  dritte Bibliothek.
- **`POST /expense-claims` ist der erste schreibende Graph-Aufrufer des Systems.** Bisher nimmt das
  Backend die Element-Kennung entgegen und legt nichts ab
  ([`querschnitt-api.md`](querschnitt-api.md), `PUT /documents/{id}`); hier legt es die Datei selbst
  ab, weil „Weltenbaum die Datei gleich dort ablegt, wo sie bleibt" und der Einreicher ein Foto vom
  Telefon schickt und keinen Dateipicker öffnet. **Die Reihenfolge ist damit festgelegt**: erst
  hochladen, dann schreiben. Bricht die Transaktion danach ab, bleibt eine Datei ohne Zeile in der
  Bibliothek liegen — das ist der kleinere Schaden als ein Beleg ohne seinen Nachweis, und es ist
  derselbe Fall, den der heutige Fehlerzustand nur andersherum hat.

## Offene Fragen

**Keine.** Auch nicht, wer die Rolle `approver` trägt: Das ist keine Frage, sondern eine laufende
Rollenvergabe der Geschäftsführung — heute wie künftig. `glossar.md` hielt fest, dass „Vorstand und
die übrigen Bereichsleitungen keine Rolle im System haben, mit der Rechnungsfreigabe ist das neu zu
prüfen"; geprüft und beantwortet ist es damit so: Die Rolle gibt es, wer sie trägt, entscheidet die
Geschäftsführung über `PUT /employees/{employee_id}/roles`
([`stammdaten-api.md`](stammdaten-api.md)), und für welchen Bereich eine Führungskraft zuständig ist,
steht nirgends im System — „das Haus ist klein genug, dass jeder weiß, wen er wählt"
([12](../soll-prozesse/12-rechnungsfreigabe.md), „Gehört nicht dazu").
