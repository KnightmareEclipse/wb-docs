# Querschnitt — Routen

Was in mehr als einer Domäne vorkommt und deshalb keiner gehört (`grenzkarte.md`, Regel 4):
Zustimmung (Q1), Dokument und Signatur (Q2), Zahlungsvorgang (Q3), Nachzieh-Aufgabe (Q5) und die
vier Hebel, die jede Domäne braucht — Änderungsspur, versandte Mail, Werte im System, Vertragstexte.
Q4 (Mitarbeitende) steht in [`stammdaten-api.md`](stammdaten-api.md). Es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht.

**Der Querschnitt hat keine eigene Ablauftabelle** — er hat keinen Prozess. Gezählt sind deshalb die
Zeilen fremder Blöcke, **deren Handlung dem Querschnitt gehört**, und die Hebel, die keine Zeile
haben.

**Gegenprobe:** **17 Ablaufzeilen aus 11 Blöcken** tragen eine Handlung dieser Datei; **alle 17**
haben hier eine Route. Es gibt **25 Routen**; **9** nennen eine Ablaufzeile, **16** einen Hebel oder
einen Abschnitt „Was dabei erhoben wird" — das ist die Bauform dieser Datei und kein Mangel: Ein
Hebel gilt für alle Prozesse und steht deshalb in keinem.

Die 17 Zeilen: [01](../soll-prozesse/01-putzdienst.md) Z3, Z7, Z12 ·
[02](../soll-prozesse/02-datenaenderung.md) Z4 · [03](../soll-prozesse/03-irregulaerer-abgang.md) Z3 ·
[04](../soll-prozesse/04-schuljahreswechsel.md) Z1, Z4 · [05](../soll-prozesse/05-bewerbung.md) Z4 ·
[06](../soll-prozesse/06-anmeldetag.md) Z5 · [08](../soll-prozesse/08-schulvertrag.md) Z2, Z5 ·
[09](../soll-prozesse/09-hortvertrag.md) Z3 · [10](../soll-prozesse/10-ferienprogramm.md) Z3, Z4 ·
[13](../soll-prozesse/13-m365-konten.md) Z4 · [14](../soll-prozesse/14-elternbonus.md) Z5 ·
[15](../soll-prozesse/15-klassenbildung.md) Z3.

**Vier davon tragen nur zur Hälfte hierher:** 06 Z5 (Unterlagen ja, Einstufung und Angaben zum Kind
nein), 08 Z2 (Fotoeinverständnis ja, Gesundheitsangaben und Mandat nein), 09 Z3 (die Einwilligung
zum Austausch ja, die Heimweg-Erlaubnis nein), 10 Z3 (das Fotoeinverständnis ja, Buchung und
Anmerkung nein). Die andere Hälfte gehört ihrer Domäne.

## Enge Rolle

**Keine, in dieser ganzen Datei.** Der Querschnitt trägt kein Art.-9-Feld und keine Bankverbindung:
Die Zustimmung *zu* den Gesundheitsangaben steht als Zeile in `consents`, die Angaben selbst in
`child_health_records`; das Mandat trägt die IBAN, nicht die Zahlung. Die Spalte steht trotzdem an
jeder Route, damit ihr Fehlen eine Aussage bleibt und keine Auslassung.

**Ein Gegenstück dazu, und es ist wichtig:** `change_log` hat für die Laufzeit-Rolle nur `SELECT`
und ein spaltenweises `INSERT` — **kein `UPDATE`, kein `DELETE`**. Keine Route dieser Datei kann eine
Spur ändern oder löschen, und keine soll es können.

## Wo die Grenze zur Fachdomäne läuft

Zwei Sätze, aus denen der Schnitt dieser Datei folgt:

- **Die generische Handlung gehört hierher, der Anlass seiner Domäne.** „Unterlage abhaken" steht in
  06, 08 und 09 — dreimal dieselbe Handlung, also eine Route hier. „Welche Unterlagen ein Ziel
  verlangt" steht allein in 06 und bleibt dort.
- **Eine Aufgabe entsteht nie über eine Route.** Sie entsteht als Seiteneffekt der Handlung oder des
  Laufs, der sie auslöst, in derselben Transaktion — der Umzug legt seine drei an, die
  Vertragsfreigabe ihre, der Monatslauf des Putzdiensts seine. Hier stehen nur die beiden Routen, die sie **lesen** und
  **schließen**.

## Q5 — Nachzieh-Aufgabe

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /tasks` — die offenen Aufgaben, je Zeile Ziel, Bezug, Text und seit wann sie offen ist | [`hebel.md`](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail) | jede Mitarbeiterrolle | **die Route zählt keine Rolle auf**: sie vergleicht `sync_targets.role_id` mit den Rollen des Aufrufers. Eine Ausnahme, und sie steht im Hebel: **das Sekretariat sieht alle offenen Aufgaben**, auch fremde — die Allsicht ist eine Ansicht, keine Mail. Listenroute, deshalb nie über den OTP-Pfad | liest | — |
| `PUT /tasks/{sync_task_id}` — abhaken als *erledigt* oder als *war nichts zu tun*; bei einem Vertragspunkt der Abgangsliste mit dem Enddatum, mit dem er bestätigt wird | [01](../soll-prozesse/01-putzdienst.md) Z12, [02](../soll-prozesse/02-datenaenderung.md) Z4, [03](../soll-prozesse/03-irregulaerer-abgang.md) Z3, [04](../soll-prozesse/04-schuljahreswechsel.md) Z1 und Z4, [13](../soll-prozesse/13-m365-konten.md) Z4, [14](../soll-prozesse/14-elternbonus.md) Z5, [15](../soll-prozesse/15-klassenbildung.md) Z3 | die Rolle des Ziels | nur die eigene Zielrolle, das Sekretariat nur für seine eigenen Ziele — **sehen und abhaken sind hier zweierlei**. Abhaken ist umkehrbar: „einen bestätigten Punkt nimmt zurück, wer ihn bestätigt hat" (03). `completed_at`, `outcome` und `completed_by` stehen zusammen oder gar nicht (`ck_sync_tasks_completed`); `confirmed_end_date` trägt allein ein Vertragspunkt | schreibt, `entra:` | — |

Die eine Aufgabe, die an einer **namentlich benannten Person** hängt, läuft nicht über diese
Routen: der Beleg bei seiner Führungskraft ist `expense_claims`
([12](../soll-prozesse/12-rechnungsfreigabe.md)). Sie ist eine Aufgabe im Sinne des Hebels und keine
`sync_tasks`-Zeile; ihre Routen gehören ihrer Domäne.

Eine Aufgabe **verweist** auf die Liste, die sie braucht — die Strafenliste des Monatslaufs
(`GET /cleaning/penalties`), die Jahresliste des Elternbonus, die Abgangsliste des Kindes. Der
Querschnitt baut keine davon.

## Q1 — Zustimmung

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /children/{child_id}/photo-consent` — darf dieses Kind fotografiert werden: **ein Ja oder Nein und sonst nichts** | [08](../soll-prozesse/08-schulvertrag.md) „Was dabei erhoben wird" | `teacher`, `day_care_staff`, `day_care_management`, `secretariat`, `school_management`, `executive_management`, `domestic_services_management` | unbeschränkt — **die am breitesten gelesene Antwort im System**. Gerechnet nach der einen Regel: **Ja nur, wenn alle erwarteten Personen erteilt haben** und keine widerrufen hat; ein Nein und ein noch offenes Feld wiegen gleich schwer, ab 14 zählt das Kind mit. Sie liefert **nicht** Zustelladresse, Widerrufsspur oder die Antwort je Person — dafür steht die Zeile darunter | liest | — |
| `GET /children/{child_id}/consents` — der Zustimmungssatz: je Zweck und Person Antwort, Zeitpunkt, Zustelladresse und Widerruf | [08](../soll-prozesse/08-schulvertrag.md), [09](../soll-prozesse/09-hortvertrag.md) „Was dabei erhoben wird" | `secretariat`, `school_management`, `day_care_management`, `executive_management`; Erziehungsberechtigte | Eltern nur die eigenen Kinder und darin nur, was ihre [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) zeigt; Schulleitung nur die eigene Schulform, Hortleitung nur die betreuten Kinder | liest | — |
| `PUT /children/{child_id}/consents/{purpose}` — erteilen oder ablehnen; ersetzt die vorhandene Antwort dieser Person | [08](../soll-prozesse/08-schulvertrag.md) Z2, [09](../soll-prozesse/09-hortvertrag.md) Z3, [10](../soll-prozesse/10-ferienprogramm.md) Z3 | Erziehungsberechtigte; `secretariat` (Umweg) | eigene Familie; nur Zwecke mit `requires_child`. **Ein Zeitpunkt und kein Boolean** (`ck_consents_answer`): die vergessene Frage darf nicht wie ein Nein aussehen. Die Zustelladresse wird festgehalten und **nicht aus `persons.email` abgeleitet** — zwei Sorgeberechtigte dürfen sich eine Mailbox teilen. Ab `self_consent_age` antwortet das Kind selbst mit, über einen Signaturlink und **keinen Zugang** | schreibt, `guardian:` / `entra:` | — |
| `DELETE /children/{child_id}/consents/{purpose}` — eine Erteilung widerrufen | [09](../soll-prozesse/09-hortvertrag.md), [10](../soll-prozesse/10-ferienprogramm.md) „Was dabei erhoben wird" | Erziehungsberechtigte; `secretariat` | die eigene Antwort, nie die des anderen. **Widerrufen wird eine Erteilung, nie eine Ablehnung** (`ck_consents_revocation`), und nie vor ihr (`ck_consents_revoked_after_granted`); die Zeile bleibt stehen und trägt `revoked_at` | schreibt, `guardian:` / `entra:` | — |
| `PUT /persons/{person_id}/consents/{purpose}` — dieselbe Handlung für einen Zweck ohne Kind, heute die Werbe-Einwilligung Ferienbetreuung | [10](../soll-prozesse/10-ferienprogramm.md) „Was dabei erhoben wird" | Erziehungsberechtigte; `secretariat` (Umweg) | die eigene Person; nur Zwecke ohne `requires_child` — welche das sind, sagt die Zweckzeile und nicht die Route (`fk_consents_purpose`, zusammengesetzt) | schreibt, `guardian:` / `entra:` | — |
| `DELETE /persons/{person_id}/consents/{purpose}` — sie widerrufen | [10](../soll-prozesse/10-ferienprogramm.md) „Was dabei erhoben wird" | Erziehungsberechtigte; `secretariat` | die eigene Antwort | schreibt, `guardian:` / `entra:` | — |

**Die Klassenliste liest dieselbe Regel** ([15](../soll-prozesse/15-klassenbildung.md), „Dateien") —
gerechnet wird sie an einer Stelle und nicht zweimal; die Liste ruft dieselbe Auswertung, statt sie
nachzubauen.

Zwei Zwecke der Werteliste haben hier **keine** Route: `school_contract` und `health_data`. Die
Platzannahme steht als `contract_responses`, die Gesundheitsantwort als `child_health_records`; ihre
Zeilen in `consent_purposes` sind der Nachweis, dass die Frage gestellt wurde, und beide Handlungen
gehören der Anmeldung bzw. der Gesundheitsdomäne.

## Q2 — Dokument und Signatur

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /children/{child_id}/documents` — welche Unterlagen vorliegen, fehlen oder als nicht nötig festgestellt sind | [06](../soll-prozesse/06-anmeldetag.md) Z5, [08](../soll-prozesse/08-schulvertrag.md) Z4 | `secretariat`, `school_management`, `day_care_management`; Erziehungsberechtigte | Eltern sehen **ihre offenen Unterlagen** (06) und nichts weiter; Schulleitung nur die eigene Schulform. **Drei Stände, nicht zwei**: angefordert ohne Datei heißt „fehlt", `not_required_at` heißt „nicht nötig", keine Zeile heißt „nie verlangt" | liest | — |
| `POST /children/{child_id}/documents` — eine Unterlage anfordern | [06](../soll-prozesse/06-anmeldetag.md) Z5 | `secretariat`, `school_management` | unbeschränkt. Welche Unterlagen ein Ziel verlangt, **folgt aus dem Ziel und wird von niemandem gepflegt** — die Liste gehört der Anmeldung, diese Route legt die einzelne Zeile an. **Sie legt immer eine neue Zeile an und ersetzt nie eine**: `documents` ist bewusst nicht eindeutig je Kind und Typ, und keine Regel im Schema sagt, welche Zeile gemeint wäre — der Fund unter „Am Schema aufgefallen“ ist damit entschieden. — Alternative: die jüngste offene Zeile desselben Typs überschreiben; Preis: zwei angeforderte Atteste wären eines, und das Nachreichen des ersten löschte die Anforderung des zweiten. **Den Fehlgriff nimmt die Zeile darunter zurück** | schreibt, `entra:` | — |
| `PUT /documents/{document_id}` — die Ablage festhalten, die abgelegte Datei **ersetzen** oder die Unterlage als nicht nötig feststellen. **Sie ist auch der Änderungsweg**: Ein zweites Mal eingehendes Papier — ein berichtigtes Attest, eine neu eingescannte Seite — behält seine Zeile und bekommt hier die neue Graph-Kennung, `filed_at` wird neu gestempelt. Eine bereits abgelegte Unterlage lässt sich **nicht** als nicht nötig feststellen: `ck_documents_not_required` verböte es ohnehin, die Route weist es mit `400` ab statt mit einer abgebrochenen Transaktion. **Sie nimmt die Graph-Kennung entgegen, nicht die Datei**: Das Papier legt ein Mensch in die Bibliothek, die er ohnehin offen hat — „SharePoint ist keine Aufgabe“ (08) —, und diese Zeile hält fest, wo es gelandet ist. — Alternative: ein Upload durch das Backend; Preis: ein zweiter schreibender Graph-Weg samt Größengrenze, für eine Datei, die ohnehin in einem Ordner landet | [06](../soll-prozesse/06-anmeldetag.md) Z5, [08](../soll-prozesse/08-schulvertrag.md) Z4 | `secretariat`, `school_management` | „was vorliegt, war nötig" (`ck_documents_not_required`); Bibliothek und Graph-Kennung stehen zusammen oder gar nicht, und abgelegt heißt mit Zeitpunkt (`ck_documents_filed`). Die Kennung ist **nie ein Pfad** — sie überlebt Umbenennen und Verschieben | schreibt, `entra:` | — |
| `DELETE /documents/{document_id}` — eine Anforderung zurücknehmen, die so nicht hätte gestellt werden dürfen | [06](../soll-prozesse/06-anmeldetag.md) Z5 | `secretariat`, `school_management` | **allein die reine Anforderung**: `graph_item_id` und `not_required_at` müssen leer sein, sonst `400`. Eine abgelegte Unterlage geht diesen Weg nicht, und „nicht nötig" ist eine Feststellung und kein Versehen. Zwei offene Zeilen desselben Typs sind der Regelfall — welche gemeint ist, sagt der Aufrufer mit der Kennung | schreibt, `entra:` | — |
| `GET /documents/{document_id}/content` — die Datei ausliefern | [08](../soll-prozesse/08-schulvertrag.md) Z5, `grenzkarte.md` Q2 | wer die Zeile daneben sehen darf | **dieselbe Regel wie für die Zeile, kein zweites Rechtesystem.** Zwingend gebraucht von der Schulleitung, die den Vertrag ihres Zweigs vor der Freigabe lesen muss, und von der Hortleitung auf ihrer Seite — beide ohne Zugriff auf die Bibliothek (`glossar.md`) | liest | — |

**`GET /documents/{document_id}/content` ist der zweite Graph-Aufrufer des Systems** und der einzige
lesende: der erste ist der Mailausgang. Beide holen ihr App-Token an einer Stelle
(`wb-backend/app/services/graph.py`) — die Client-Credentials sind eine Tatsache, und eine zweite
Fassung davon wäre die, die beim Wechsel des Geheimnisses stehen bleibt.

**Woher die Element-Kennung kommt, ist eine Frage an die Oberfläche**: In SharePoint liest ein
Mensch sie nirgends ab, `wb-intern` reicht sie aus dem Dateipicker durch (`oberflaechen.md`). Das
Backend nimmt sie, wie sie kommt — ob sie auf etwas zeigt, zeigt sich beim ersten
`GET /documents/{document_id}/content`.

**Signaturen haben hier keine Route.** Unterschrieben wird in der Vertragsstrecke
([08](../soll-prozesse/08-schulvertrag.md), [09](../soll-prozesse/09-hortvertrag.md)); `signatures`
steht im Querschnitts-Schema, weil die Tabelle drei Domänen bedient, aber die Handlung „zeichnen"
gehört dem Vorgang, an dem sie hängt. **Der Aktenordner ebenso**: Er entsteht mit der
Vertragsfreigabe und zieht mit der Klasse um
([`stammdaten-api.md`](stammdaten-api.md), `PUT /children/{child_id}/class`).

## Q3 — Zahlungsvorgang

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /payments/callback` — der Rückruf des Zahlungsdienstes; legt Zahlung **und** Vorgang in einer Transaktion an | [01](../soll-prozesse/01-putzdienst.md) Z3 und Z7, [05](../soll-prozesse/05-bewerbung.md) Z4, [10](../soll-prozesse/10-ferienprogramm.md) Z4 | niemand, ohne Anmeldung | **die einzige Route ohne Anmeldung** — sie prüft stattdessen die Signatur des Dienstes. Drei Bedingungen, keine verhandelbar: Signaturprüfung, Idempotenz (Schlüsselfehler fangen, zurückrollen, 2xx antworten), und die Bedingung des Vorgangs **sperrend** erneut prüfen. Trägt sie nicht mehr, entstehen Zahlung **und** Aufgabe bei der Buchhaltung — ganz oder gar nicht. Form vollständig in [`gemeinsam.md`](gemeinsam.md#sofortzahlung) | schreibt, `system:payments` | — |
| `GET /payments?start=&end=` — der **Einzelnachweis** zu einer Sammelgutschrift, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) als Druckansicht: Zeitpunkt, Bruttobetrag, Familie, Anlass und die Referenz des Dienstes | [`hebel.md`](../soll-prozesse/hebel.md#sofortzahlung) | `accounting`, `executive_management` | Listenroute, deshalb nie über den OTP-Pfad. Bruttobeträge — was der Dienst an Gebühr einbehält, steht bei ihm. **Zugeordnet wird nichts von Hand**: Die Zahlung hat den Vorgang selbst angelegt, die Zuordnung wird nur ausgelesen. Eine leere Referenz ist die Marke einer von Hand bestätigten Zahlung; sie läuft in der Liste wie jede andere | liest | — |

Die **Eröffnung der Zahlungssitzung** ist keine Route dieser Datei: Der Elternteil ruft die Route
seines Vorgangs — `POST /cleaning/families/{family_id}/buyouts` und drei weitere —, und die eröffnet
die Sitzung, statt etwas anzulegen. Ein fünfter Anlass ist eine Spalte an `payments`, ein Summand in
`ck_payments_single_cause` und ein Zweig in dieser Route; das ist der einzige Punkt, an dem ein
Gelenk des Querschnitts eine Migration kostet, und er ist so gewollt (`grenzkarte.md`, Q3).

## Werte und Texte

Beide Tabellen folgen derselben Regel: Es gilt die Fassung, deren Gültigkeitstag zuletzt erreicht
wurde; ein noch nicht gültiger Eintrag lässt sich ändern oder zurücknehmen, ein bereits gültiger
nicht mehr. Die zweite Hälfte prüft die Anwendung, weil `now()` in keinem CHECK zulässig ist — sie
steht deshalb hier an drei Routen.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /configured-values` — die Werte im System, je Code der geltende und der angekündigte | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management`, `accounting`, `secretariat`, `school_management` | interne Route. **Die Eltern sehen einen Wert an dem Vorgang, der ihn braucht** — der Freikaufpreis steht in der Putzdienstansicht, die Gebühr am Anmeldeformular —, nie in einer Werteliste: die beiden Werte der Rechnungsfreigabe sehen „allein die, die dort arbeiten" | liest | — |
| `POST /configured-values` — einen Wert mit seinem Gültigkeitstag eintragen | [04](../soll-prozesse/04-schuljahreswechsel.md) Z1 | `executive_management` | unbeschränkt; je Code und Tag genau ein Eintrag (`uq_configured_values`). Der Aufschlag je Ferientermin und Modul gehört **nicht** hierher — ihn setzt die anbietende Stelle in ihrer Domäne (10) | schreibt, `entra:` | — |
| `PATCH /configured-values/{configured_value_id}` — einen angekündigten Wert ändern | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | **nur solange `valid_from` in der Zukunft liegt** | schreibt, `entra:` | — |
| `DELETE /configured-values/{configured_value_id}` — einen angekündigten Wert zurücknehmen | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | wie oben; ein bereits gültiger bleibt stehen, denn was berechnet oder bezahlt ist, bleibt bei seinem Betrag | schreibt, `entra:` | — |
| `GET /contract-texts` — die Vertragstexte, je Code die geltende und die angekündigte Fassung | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management`, `secretariat`, `school_management`, `day_care_management`; Erziehungsberechtigte | Die Eltern sehen den Text, den sie unterschreiben bzw. dem sie zustimmen — **die Fassung friert mit der Zusage ein** und steht danach am Vorgang (`contracts.contract_text_id`), nicht an dieser Route | liest | — |
| `POST /contract-texts` — eine neue Fassung mit ihrem Gültigkeitstag hochladen | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest), [08](../soll-prozesse/08-schulvertrag.md) „Dateien" | `executive_management` | **allein die Geschäftsführung** — „sie verantwortet die Verwaltung und besonders die Verträge" (`glossar.md`). Je Code und Tag eine Fassung (`uq_contract_texts`) | schreibt, `entra:` | — |
| `PATCH /contract-texts/{contract_text_id}` — eine angekündigte Fassung ändern | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | nur solange `valid_from` in der Zukunft liegt | schreibt, `entra:` | — |
| `DELETE /contract-texts/{contract_text_id}` — eine angekündigte Fassung zurücknehmen | [`hebel.md`](../soll-prozesse/hebel.md#geld-im-system-alles-andere-fest) | `executive_management` | wie oben | schreibt, `entra:` | — |

## Spur und Mail

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /change-log?table_name=&row_id=` — wer wann was geändert hat und was vorher dastand | [`hebel.md`](../soll-prozesse/hebel.md#änderungsspur), [00](../soll-prozesse/00-zugang-und-portal.md) „Was dabei erhoben wird" | `secretariat`; `admin` und `executive_management` für `employee_roles`; für einen Beleg der Kreis aus 12 | **Die Spur folgt dem Sehrecht an der Zeile, auf die sie zeigt** — sie ist keine eigene Berechtigung. Drei Ausprägungen: das Sekretariat sieht sie überall, die Rollenhistorie sehen zusätzlich Admins und Geschäftsführung (der einzige solche Fall), und die Rechnungsfreigabe regelt das Sehen abweichend — dort **nicht** das Sekretariat. Die Route liefert keine Menge ohne Bezug: Tabellenname und Schlüssel sind Pflicht | liest | — |
| `GET /outbound-emails/undeliverable` — die unzustellbaren Mails samt Adresse, Anlass und Grund | [`hebel.md`](../soll-prozesse/hebel.md#unzustellbare-mail) | `secretariat` | Listenroute, nie über OTP; sie zeigt die Familie, um die es geht. **Der Anmeldecode ist ausgenommen** — sein Fehlschlag ist eine Betriebsstörung und meldet sich beim Betreiber, nicht in dieser Liste (`container.md`) | liest | — |

**Es gibt keine Route, die eine Mail verschickt.** Jede Mail dieses Systems hängt an einer Handlung
oder an einem Lauf; `outbound_emails` entsteht dort und wird hier nur gelesen.

## Die zwei Läufe

Keine Route, kein Endpunkt von außen ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

| Lauf | Herkunft | Auslöser | Aktor |
|---|---|---|---|
| **Die Wochenmail**, je Stelle eine, mit ihren eigenen offenen Aufgaben — nicht mit allen, „sonst stünden dort die Belegfreigaben des ganzen Kollegiums". Die Rechnungsfreigabe läuft ausdrücklich **nicht** darin mit (12); 01 und 10 setzen ihre eigene Mail **neben** sie | [`hebel.md`](../soll-prozesse/hebel.md#nachzieh-aufgabe-und-wochenmail) | wöchentlich, ein festes Datum; sie geht nicht raus, wo eine Stelle nichts Offenes hat | `system:weekly` |
| Die **unzustellbaren Mails einsammeln** und `outbound_emails.undeliverable_at` setzen | [`hebel.md`](../soll-prozesse/hebel.md#unzustellbare-mail), `zugang.md` | täglich; aus dem Absenderpostfach wird bewusst nichts weitergeleitet, der Rückläufer liegt also dort | `system:bounces` |

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Unterschreiben** — Namenszug zeichnen, das Bild ablegen, es mit der Gegenzeichnung löschen, die
  Prüfsumme festhalten ([08](../soll-prozesse/08-schulvertrag.md) Z3,
  [09](../soll-prozesse/09-hortvertrag.md) Z4) — Anmeldung.
- **Der Signaturlink des Kindes ab 14** ([08](../soll-prozesse/08-schulvertrag.md)): ein Link, kein
  Zugang, und damit ein eigener Einstieg neben dem OTP-Pfad — Anmeldung.
- **Die Platzannahme** (`contract_responses`) und **die Gesundheitsantwort**
  (`child_health_records`), obwohl beide eine Zeile in `consent_purposes` haben — Anmeldung und
  Gesundheit.
- **Die Aufgabe bei einer namentlich benannten Person**: der Beleg bei seiner Führungskraft
  ([12](../soll-prozesse/12-rechnungsfreigabe.md)) und die Mitarbeitsstunde
  ([14](../soll-prozesse/14-elternbonus.md)) — Rechnungsfreigabe und Elternbonus.
- **Der Teams-Ping** der Rechnungsfreigabe: der einzige Anstoß, der nicht Mail und nicht Wochenmail
  ist ([12](../soll-prozesse/12-rechnungsfreigabe.md)) — Rechnungsfreigabe.
- **Die Zahlungssitzung eröffnen**, je Anlass an seiner eigenen Route — Putzdienst, Anmeldung,
  Ferien.
- **Die Aufgabenlisten, auf die eine Aufgabe verweist** — Strafenliste (01), Jahresliste (14),
  Abgangsliste ([`stammdaten-api.md`](stammdaten-api.md)).
- **Der Unterlagensatz, den ein Ziel verlangt** ([06](../soll-prozesse/06-anmeldetag.md)): Welche
  Stücke eine Bewerbung braucht, folgt aus Schulart und Klassenstufe, und die Domäne legt sie an.
  Sie braucht dafür ihre eigene Regel „je Ziel einmal" — `documents` ist bewusst nicht eindeutig,
  ein zweiter Aufruf legte den ganzen Satz daneben — Anmeldung.
- **Der Lösch-Lauf** (17), der `documents`, `child_file_folders` und die ankerlosen
  `change_log`-Zeilen mitnimmt: Er ist kein Endpunkt und hat noch keinen Block.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **`documents` ist nicht eindeutig je Kind und Typ.** Das ist richtig — zwei Atteste und zwei
  Modulanlagen desselben Kindes sind zwei Zeilen —, heißt aber, dass „die Geburtsurkunde dieses
  Kindes" keine adressierbare Sache ist. `POST /children/{child_id}/documents` muss deshalb
  entscheiden, ob sie eine Zeile ersetzt oder danebenlegt, und keine Regel im Schema hilft ihr dabei.
- **`sync_targets` hat keine Zeile für die Aufgaben, die auf eine benannte Person warten.** Die
  Seed-Datei sagt das ausdrücklich; die vier Fälle (12, 14, 09, 10) tragen ihre Aufgabe in der
  eigenen Tabelle. `GET /tasks` liefert sie deshalb **nicht** — wer alle seine offenen Punkte sehen
  will, ruft zwei Routen.
- **`change_log` hat kein `UPDATE` und kein `DELETE` für die Laufzeit-Rolle**, und der Lösch-Lauf
  braucht beides für die ankerlosen Zeilen (Stufe 8). Welche Rolle er benutzt, entscheidet Block 17
  mit der Frist — heute hat niemand das Recht.
- **`outbound_emails` hat keine Audit-Spalten** und trägt `sent_at` als einzigen Zeitpunkt. Wer eine
  Zeile als unzustellbar markiert, steht damit nirgends; der Lauf ist der einzige Schreiber, und
  das trägt, solange es dabei bleibt.
- **`consent_purposes.self_consent_age` steht an der Zweckzeile**, aber das Alter des Kindes rechnet
  die Anwendung aus `children.birth_date`. „Erwartet" ist damit eine Menge, die sich mit dem
  Geburtstag ändert — `GET /children/{child_id}/photo-consent` kann heute Ja und morgen Nein
  antworten, ohne dass jemand etwas eingetragen hat. Block 08 nennt genau diesen Fall und
  entscheidet ihn: „Das Fotoeinverständnis wird nicht nachgeholt, wenn ein Kind 14 wird."

## Die Prüfung

### Gegen das Schema, Spalte für Spalte

| Fund | Entscheidung |
|---|---|
| `consents` trägt zwei Zeitpunkte statt eines Ja/Nein (`ck_consents_answer`) | `PUT …/consents/{purpose}` nimmt eine Antwort entgegen und setzt genau einen der beiden; ein `null` gibt es nicht — die fehlende Zeile ist der dritte Zustand |
| `ix_consents_person_child_purpose` ist partiell auf `revoked_at IS NULL` | Eine widerrufene Zeile blockiert keine neue Antwort; `PUT` nach `DELETE` legt eine zweite Zeile an, statt die erste wiederzubeleben |
| `consents.delivery_address` ist nullable | Leer bleibt sie allein bei einer Antwort ohne Kanal — dem aus der Papierakte nachgetragenen Fotoeinverständnis des Vollimports. Die Route setzt sie immer; der Nachtrag ist kein Routenweg |
| `consents.child_id` kaskadiert, `person_id` ebenso | Beide Löschanker rechnen verschieden; die Route berührt das nicht, aber `GET /children/{child_id}/consents` darf keine Zeile eines gelöschten Elternteils erwarten |
| `documents.requested_at`, `graph_item_id`, `not_required_at` — `ck_documents_purpose` verlangt mindestens eines | `POST /children/{child_id}/documents` setzt `requested_at`, sonst entstünde eine Zeile, die nichts sagt |
| Die Laufzeit-Rolle hat `DELETE` auf `documents`, weil der Lösch-Lauf ihn braucht | `DELETE /documents/{document_id}` kommt deshalb ohne Migration aus; das Recht reicht weiter als die Route, die sich auf die reine Anforderung einschränkt |
| `payments.amount_cents` ist `> 0` | Eine Gutschrift läuft nicht über Q3; sie ist ein negativer Beleg der Rechnungsfreigabe (12) und berührt diese Tabelle nicht |
| `ck_payments_single_cause` lässt **höchstens** einen Anlass zu | Der Ausnahmefall ist gebaut, nicht geduldet: die Rückrufroute legt Zahlung und Aufgabe `payment_without_cause` zusammen an — ganz oder gar nicht |
| `uq_payments_payment_reference` ist ein schlichtes UNIQUE | Es greift nur für belegte Werte; eine von Hand bestätigte Zahlung trägt keine Referenz und ist deshalb **nicht** idempotenzgeschützt — siehe `[A!]` unten |
| `sync_tasks.completed_by` hat einen CHECK ohne `NULL`-Ausnahme (`ck_sync_tasks_completed_by`) | Der CHECK ist bei `NULL` unbekannt und damit erfüllt; die Route setzt ihn zusammen mit `completed_at` und `outcome` oder gar nicht |
| `sync_tasks` hat acht Bezüge und acht partielle Unique-Indizes | `PUT /tasks/{id}` braucht davon keinen — die Eindeutigkeit gilt dem Anlegen, und das ist Seiteneffekt anderer Routen |
| `configured_values.value` ist ein `integer` für Beträge **und** Stückzahlen | `POST /configured-values` kennt die Einheit nicht; welche gilt, sagt der Code. Die Route prüft den Code gegen die bekannte Liste, sonst entstünde ein Wert, den niemand liest |
| `contract_texts` hat kein Gültigkeits-Ende und keinen Freigabevermerk | Beides folgt aus der nächsten Fassung; `GET /contract-texts` rechnet es aus, statt es zu speichern |
| `change_log.proof_seen_at` hängt an der Änderung, nicht an der Zeile | Gesetzt wird er von den Rechtelage-Routen in [`stammdaten-api.md`](stammdaten-api.md); diese Datei liest ihn nur |

### Gegen `api/putzdienst-api.md`

| Kollision | Entscheidung |
|---|---|
| „Q5, Aufgabe abhaken (`erledigt` / `war nichts zu tun`) und der Bestand der Wochenmail" steht dort am Rand | **wandert hierher** — `GET /tasks` und `PUT /tasks/{sync_task_id}`. Die Randzeile dort wird durch den Verweis ersetzt |
| „`POST /payments/callback` samt Zahlungssitzung" steht dort am Rand | **wandert hierher**, die Sitzung nicht: Sie wird von der Domänenroute eröffnet, und `POST /cleaning/families/{family_id}/buyouts` tut das schon. Die Randzeile wird auf diese Datei gerichtet |
| „`configured_values` pflegen (`cleaning_buyout_cents`, `cleaning_penalty_cents`, Pflichtmenge)" steht dort am Rand | **wandert hierher.** Die Pflichtmenge ist dabei **keine** `configured_values`-Zeile: sie steht je Zyklus und Terminart am Putzdienstjahr (`POST /cleaning/cycles`) — die Randzeile dort ist an dieser Stelle zu eng gefasst und wird richtiggestellt |
| „Unzustellbare Mail sichtbar machen (`outbound_emails`)" steht dort am Rand | **wandert hierher** — `GET /outbound-emails/undeliverable` |
| „Das hausinterne Q5-Ziel steht (`in_house`)" | **bleibt dort** als Feststellung: Es ist eine Zeile in `sync_targets`, keine Route. Die drei Erinnerungen zum Schulanfang (04 Z4) nehmen **nicht** dieses Ziel, sondern je eines: `cleaning_year_setup`, `preregistration_opening`, `deletion_run`. `outcome` hängt an der Zeile — mit einer Sammelaufgabe ließe sich „war schon offen, nichts zu tun" für eine der drei nicht sagen, und die Wochenmail trüge wochenlang dieselbe Zeile, während zwei Drittel erledigt sind. `in_house` bleibt bei dem, wofür es angelegt wurde |
| `GET /cleaning/penalties?period=` ist die Liste **zu** einer Aufgabe | **bleibt dort.** Eine Aufgabe verweist auf die Liste ihrer Domäne; der Querschnitt baut keine — sonst stünde je Aufgabenart eine Liste hier und die Domäne wüsste nichts davon |

### Auf Zukunftssicherheit

1. **Eine neue Fachdomäne hängt sich an fünf Gelenke, ohne eine Route zu ändern:** eine Zeile in
   `sync_targets`, eine in `consent_purposes`, eine in `document_types`, ein Code in
   `configured_values`, ein Code in `contract_texts`. **Q3 ist die Ausnahme und wird benannt**: Ein
   fünfter Zahlungsanlass ist eine Spalte, ein Summand im CHECK und ein Zweig in
   `POST /payments/callback`. Das ist der Preis der referenziellen Integrität, den `grenzkarte.md`
   bewusst bezahlt — aber es heißt, dass genau dieses Gelenk seinen heutigen Nutzerkreis kennt.
2. **Ein Feld an einer Tabelle kostet keine Route.** Keine Route dieser Datei ist auf ein Feld
   geschnitten; `GET /outbound-emails/undeliverable` ist auf eine Bedingung geschnitten, und die ist
   der Hebel selbst.
3. **Eine umbenannte Werteliste trägt, und zwar mit Absicht:** `consent_purposes.code` steht im
   **Pfad**, `sync_targets.code`, `configured_values.code` und `contract_texts.code` sind ohnehin die
   Verankerung im Anwendungscode. Genau deshalb ist der `code` der Wert, der nie umbenannt wird, und
   der `name` der, der wandert — steht so an jeder der vier Tabellen.
4. **Eine neue oder gespaltene Rolle schreibt hier nichts um.** `GET /tasks` und
   `PUT /tasks/{sync_task_id}` zählen **keine** Rolle auf: Die zuständige steht an
   `sync_targets.role_id`. Eine gespaltene Rolle ist eine Zeile mehr, keine Routenänderung. Die acht
   Wert- und Textrouten zählen `executive_management` auf, weil `hebel.md` genau sie benennt — das
   ist die Ausnahme, und sie ist eine Entscheidung, keine Bequemlichkeit.
5. **Die Einsichtsstufe filtert an einer Stelle.** Zwei Routen hängen daran und werten sie trotzdem
   nicht selbst aus: Für einen gesperrten Elternteil ist die Familie leer, er kommt an
   `PUT /children/{child_id}/consents/{purpose}` gar nicht heran; „nur lesen" ruft die schreibende
   Route nicht. `GET /children/{child_id}/photo-consent` kennt sie nicht, weil sie nur interne Rollen
   erreicht.
6. **Ein Absenden, das zwei werden müsste, gibt es nicht — und der Fall, der zerfällt, ist schon
   gebaut.** `POST /payments/callback` **muss** eines bleiben: Zahlung und Vorgang in einer
   Transaktion, sonst ist das Geld da und der Vorgang nicht. Umgekehrt entsteht die Zahlung ohne
   Vorgang schon heute als zwei Zeilen in einer Transaktion — Zahlung plus Aufgabe.
7. **Ein verschwindendes Feld ist hier billiger als irgendwo sonst.**
   `GET /children/{child_id}/photo-consent` ist die am breitesten gelesene Antwort im System und
   trägt genau ein Ja/Nein; weniger geht nicht, und mehr steht bewusst in der Route daneben. Der
   teure Fall wäre umgekehrt: Wer dieser Antwort ein zweites Feld gäbe, hätte den Leserkreis der
   Zeile darunter auf alle Lehrkräfte ausgeweitet.

## Festlegungen

Bestätigt und damit normaler Text; der verworfene Weg samt Preis bleibt stehen, weil er sonst als
Vorschlag wiederkommt. Die `[A!]`-Marke behält ihre Marke auch bestätigt: Ihr Wert ist, dass jeder
Prüflauf den Schnitt wiedersieht (`prompts/gemeinsam.md`).

**Der Widerruf ist eine eigene Route (`DELETE`); eine Antwort zu ersetzen ist es nicht
(`PUT` ändert die Zeile).** — Alternative: der Widerruf ist ein `PUT` mit „abgelehnt"; Preis:
`consents.revoked_at` bliebe leer, und „hat widerrufen" wäre von „hat nie zugestimmt" nicht mehr zu
unterscheiden — genau die Unterscheidung, die Art. 7 Abs. 3 DSGVO verlangt und für die das Schema
die Spalte hat.

`[A!]` **Für die manuelle Bestätigung einer Zahlung durch die Buchhaltung entsteht keine Route.**
`payments.status` und die leere Referenz halten den Fall offen, aber **kein Block beschreibt die
Handlung** — weder 01 noch 05 noch 10 kennen einen zweiten Zahlweg; die Aussage steht allein in
`grenzkarte.md` Q3, und die schlägt kein Block. — Alternative: `POST /payments` für die Buchhaltung;
Preis: eine Route ohne Zeile in irgendeiner Ablauftabelle, dazu die Idempotenzlücke, die
`uq_payments_payment_reference` bei leerer Referenz offenlässt. Sie bekommt ihre Route mit dem Block,
der den zweiten Zahlweg beschreibt.

**Eine Aufgabe entsteht nie über eine Route**, immer als Seiteneffekt der Handlung **oder des
Laufs**, der sie auslöst — „Anwesenheitsliste drucken" (01 Z9) hat schon heute keine Änderung hinter
sich, wohl aber einen Auslöser. — Alternative: `POST /tasks` fürs Sekretariat; Preis: eine Aufgabe,
die auf gar nichts zeigt, also die allgemeine To-do-Liste, die `hebel.md` und `CLAUDE.md` beide
ausschließen („kein Netz gegen menschliches Vergessen"). **Der Aufstiegspfad kostet nichts:**
`sync_tasks` trägt jede Spalte, die eine solche Route bräuchte — kommt sie je, ist sie ein Endpunkt
und keine Migration.

**`GET /documents/{document_id}/content` liefert die Datei selbst aus**; die kurzlebige
Graph-Adresse verlässt das Backend nicht. — Alternative: eine `302`-Weiterleitung dorthin; Preis:
eine vorautorisierte Adresse in der Hand des Aufrufers, die weitergeben kann, wer sie hat — ein
zweiter, ungeprüfter Weg an der Zeile vorbei, und genau den schließt `grenzkarte.md` Q2 aus.

**`GET /configured-values` ist eine interne Route.** — Alternative: eine öffentliche
Werteliste; Preis: Kilometersatz und Meldegrenze der Rechnungsfreigabe stünden darin, die „allein
die sehen, die dort arbeiten" (`hebel.md`).

**Der Zweck steht als `code` im Pfad** (`/children/{child_id}/consents/photo`). — Alternative:
die Kennung der Zweckzeile; Preis: eine Adresse, die niemand lesen kann, für einen Wert, der nie
umbenannt wird.

**Der Lauf, der unzustellbare Mails einsammelt, liest das Absenderpostfach**, einmal täglich. —
Alternative: ein Webhook des Postfachs; Preis: ein zweiter Eingang von außen samt eigener Prüfung,
für eine Zeile, die einen Tag warten darf.

## Offene Fragen

Keine neue `[?]`. Die eine, die diese Datei berührt, steht schon an ihrer Stelle: Wie lange eine
versandte Mail stehen bleibt, die an keiner Person hängt (`schema/querschnitt-schema.sql`) —
Datenschutzbeauftragte.
