# Stammdaten — Routen

Der Bestand, auf den jede andere Domäne zeigt: Person, Familie, Kind, Sorgeberechtigte,
Mitarbeitende, Klassen und der Zugang selbst. Aus
[00](../soll-prozesse/00-zugang-und-portal.md), [02](../soll-prozesse/02-datenaenderung.md),
[03](../soll-prozesse/03-irregulaerer-abgang.md), [04](../soll-prozesse/04-schuljahreswechsel.md),
[13](../soll-prozesse/13-m365-konten.md) und [15](../soll-prozesse/15-klassenbildung.md); es gilt
[`gemeinsam.md`](gemeinsam.md), und was dort steht, wiederholt diese Datei nicht.

**Drei Domänen ohne eigene Tabellen laufen hier mit** (`grenzkarte.md`): Eltern-Selfservice
(02), M365-Kontenverwaltung (13) und Klassenbildung (15). Ihre Routen gehören der Domäne, der die
Daten gehören — das ist diese. Ihre Dateien
([`selfservice-api.md`](selfservice-api.md), [`m365-api.md`](m365-api.md),
[`klassenbildung-api.md`](klassenbildung-api.md)) legen deshalb **keine Route an** und sagen je
Ablaufzeile, welche hier sie trägt — sie sind die Gegenprobe, nicht eine zweite Fassung.

**Gegenprobe:** Die sechs Blöcke haben zusammen **23 Ablaufzeilen**. **15** tragen eine Route hier,
**4** eine Route im [Querschnitt](querschnitt-api.md), **2** einen Lauf, **2** sind Seiteneffekt
einer anderen Route. Es gibt **45 Routen**; **37** nennen eine Ablaufzeile, **8** eine andere Stelle:

- `POST /auth/logout` — keine Zeile. Das Abmelden ist mechanisch nötig und nicht fachlich: Die
  Sitzung liegt in einem Cookie, das die Seite weder lesen noch löschen kann (`zugang.md`) — also
  muss der Server sie beenden.
- `GET /families/{family_id}` und `GET /children/{child_id}` — 02 „Mails und Schreiben" („was
  gespeichert ist, steht sofort in der eigenen Übersicht, und die ist die Bestätigung") bzw. „Was
  dabei erhoben wird". Der Ablauf nennt die Ansicht nirgends, obwohl sie die Bestätigung jeder
  Änderung ist.
- `PATCH /persons/{person_id}/guardian` — 02 „Was dabei erhoben wird" zusammen mit
  [05](../soll-prozesse/05-bewerbung.md): Beruf, Konfession und Staatsangehörigkeit werden dort
  erhoben und „ab dem Absenden auch dort gepflegt", also hier.
- `DELETE /children/{child_id}/departure` — 03 „Entscheidungen" („ob ein Abgang zurückgenommen
  wird"), keine Ablaufzeile.
- `PUT /children/{child_id}/enrolment` — 04 „Sonderfälle" („Sekretariat und Schulleitung setzen jede
  Stufe und jedes Datum von Hand, auch nach dem Lauf").
- `GET /employees` — 13 „Was dabei erhoben wird" („Sichtbar für Personalverwaltung,
  Geschäftsführung, Admins und das Sekretariat").
- `GET /classes/{class_id}/roster` — 15 „Dateien".

**Zwei Zeilen sind Seiteneffekt und bekommen keinen Endpunkt:** 02 Z3 (die Nachzieh-Aufgabe entsteht
in derselben Transaktion wie die Änderung, die sie auslöst) und 00 Z3 (die Meldung an die Admins
hängt an der Rollenauflösung jedes geschützten Aufrufs, nicht an einer Route — wer sie als Endpunkt
baute, machte aus einer Prüfung einen Auslöser).

## Pfad

**Kein Domänenpräfix.** Der Putzdienst adressiert seine Sachen unter `/cleaning/…`, weil sie ihm
gehören; hier heißen die Sachen `/persons`, `/families`, `/children`, `/employees`, `/classes` und
sind der Bestand selbst. `/cleaning/families/{family_id}` ist die Putzdienstseite einer Familie,
`/families/{family_id}` die Familie.

## Enge Rolle

**Eine, und sie ist eine Lesebeschränkung:** `denomination_id` und `congregation` an `children` sowie
`denomination_id` an `guardians` liegen hinter `backend_sensitive`
(`wb-backend`, `stammdaten_domain`-Migration). Geschrieben werden sie von der Laufzeit-Rolle wie
jede andere Spalte — „a protected column is a read restriction and nothing else", sonst stünde die
Änderungsspur mit unter der engen Rolle und hätte dort kein `INSERT`. Die Bankverbindung
(`sepa_mandates.iban`/`bic`, `backend_finance`) berührt **keine** Route dieser Domäne: das Mandat
gehört der Vertragsstrecke.

## Zwei Grenzen, die jede Route dieser Domäne einhält

- **Familie, Kind und Sorgeberechtigte entstehen nicht hier.** Sie entstehen mit der ersten bezahlten
  Bewerbung (05), dem abgeschickten Hortantrag (09) oder der bezahlten Ferienbuchung (10) — „gepflegt
  werden sie danach in [02], nirgends sonst". Es gibt deshalb **kein** `POST /families`, `POST
  /children` und `POST /persons`. Die einzige Route, die eine Person anlegt, ist
  `POST /families/{family_id}/contacts`: ein Notfallkontakt ist eine `persons`-Zeile ohne jede
  Rollenzeile daneben.
- **Die Freigabe ist die Grenze, nicht eine Feldliste.** Bis zur Freigabe des ersten Vertrags am Kind
  ändern die Eltern die einmal erhobenen Angaben selbst, ab ihr allein das Sekretariat
  ([Sparsame Ansicht](../soll-prozesse/hebel.md#sparsame-ansicht)). Im Schema ist das
  `contracts.released_at` **oder** `children.entry_date` — die Einschreibung ist bei den Kindern des
  Vollimports, was sonst die Freigabe ist (`schema/selfservice-schema.sql`).

`[A!]` **Es gibt keine Suchroute und keine Bestandsliste** über alle Kinder oder alle Familien. Jede
Liste dieser Domäne hat ihren Anlass — Klassenliste, Jahresansicht, Klassenbildungsansicht, löschbare
Konten —, und keine Zeile verlangt eine Suche. — Alternative: `GET /children?q=`; Preis: eine Route,
die jede Rolle über den ganzen Bestand blättern lässt, für einen Bedarf, den kein Block benennt; sie
bekommt ihre Zeile mit dem Block, der sie verlangt.

**Die zwölf Wertelisten bekommen keine Pflegeroute.** Sie entstehen im Seed und wachsen über
eine Migration. — Alternative: je Liste eine Route für den Admin; Preis: zwölf Routen für Listen, die
seit dem Seed unverändert sind, und an fünf von ihnen — `access_levels`, `school_branches`,
`houses`, `roles`, `phone_types` — hängt Code oder eine Regel: Wer sie ändert, ändert Verhalten und
nicht eine Bezeichnung, und dafür ist eine Migration das richtige Werkzeug.
**Eine Liste wächst im Betrieb und bleibt hier ohne Route:** `previous_schools`. Ein Quereinsteiger
kommt von irgendeiner Schule in Deutschland, und eine Bewerbung an einem Deploy scheitern zu lassen
wäre absurd — aber welche Stelle eine abgebende Schule anlegt, sagt heute kein Block, auch
[05](../soll-prozesse/05-bewerbung.md) nicht. Sie bekommt ihre Route mit dem Anmeldungs-Plan; die
Randzeile unten hält sie fest.

## Zugang und Sitzung

Die **Personal-Tür hat keine Route**: Das Entra-Token kommt aus dem Tenant, das Backend prüft es nur
(`zugang.md`). Alles hier ist der OTP-Pfad, bis auf `GET /auth/roles`.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /auth/codes` — Anmeldecode an eine Mailadresse anfordern | [00](../soll-prozesse/00-zugang-und-portal.md) Z1 | niemand, ohne Anmeldung | keine — **das Feld antwortet auf jede Adresse gleich**; ob eine Adresse hinterlegt ist, entscheidet nicht über den Code, sondern über den Scope danach (`zugang.md`). Vier Grenzen: fünf je Adresse und Stunde, zwanzig je Absender, zehn an Unbekannte und sechzig insgesamt je Stunde | schreibt, `system:login` | — |
| `POST /auth/sessions` — Code einlösen, Sitzung eröffnen | [00](../soll-prozesse/00-zugang-und-portal.md) Z1 | niemand, ohne Anmeldung | 15 Minuten, einmal einlösbar, fünf Fehleingaben; setzt `persons.last_login_at` je Treffer. Der Wert liegt im `__Host-`-Cookie und **nie im Rumpf** | schreibt, `system:login` | — |
| `PUT /auth/identity` — als wer diese Sitzung weitermacht | [00](../soll-prozesse/00-zugang-und-portal.md) Z1 | Erziehungsberechtigte | nur ein Kandidat dieser Adresse; **Bedienführung, keine Sicherheitsgrenze** (`zugang.md`) — die Reichweite ändert sich nicht, der Aktor der Spur schon. Verschiebt die vorhandene Sitzung, statt eine zweite auszustellen | schreibt, `guardian:` | — |
| `GET /auth/session` — was das Cookie wert ist: Kandidaten, aktuelle Person, erreichbare Familien | [00](../soll-prozesse/00-zugang-und-portal.md) Z2 | Erziehungsberechtigte | die eigene Sitzung; ohne sie sähe jedes Neuladen wie ein Abmelden aus, weil das Cookie `HttpOnly` ist | liest | — |
| `GET /auth/roles` — die Rollen des angemeldeten Mitarbeitenden, frisch gelesen | [00](../soll-prozesse/00-zugang-und-portal.md) Z2 | jede Mitarbeiterrolle | die eigene Person; die Rollen stehen nicht im Token, sondern in `employee_roles` (`zugang.md`) | liest | — |
| `POST /auth/logout` — Sitzung beenden | keine Ablaufzeile (siehe Kopf) | niemand, ohne Anmeldung | antwortet gleich, ob die Sitzung noch lebt oder nicht; löscht das Cookie mit denselben Attributen, mit denen es gesetzt wurde | schreibt, `system:login` | — |

## Die Familie und ihre Angaben

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `GET /families/{family_id}` — die Ansicht der Familie: Kinder samt Klasse, Klassenlehrkraft und Schuladresse, Sorgeberechtigte, Kontaktdaten, Notfallkontakte und Abholberechtigte | [02](../soll-prozesse/02-datenaenderung.md) „Mails und Schreiben" | Erziehungsberechtigte; `secretariat`, `school_management`, `executive_management`, `accounting` | Eltern nur die eigenen Familien; Schulleitung nur, wenn ein Kind dieser Familie ihre Schulform trägt. **Die [sparsame Ansicht](../soll-prozesse/hebel.md#sparsame-ansicht) filtert hier**: Geburtsort, Muttersprache, Konfession, Kirchengemeinde und Beruf fallen für die Eltern mit der Freigabe des ersten Vertrags am Kind weg | liest | `backend_sensitive`, solange die Ansicht Konfession und Kirchengemeinde trägt |
| `GET /children/{child_id}` — der volle Satz eines Kindes | [02](../soll-prozesse/02-datenaenderung.md) „Was dabei erhoben wird", [15](../soll-prozesse/15-klassenbildung.md) „Was dabei erhoben wird" | `secretariat`, `school_management`, `executive_management`, `accounting`, `day_care_management`, `day_care_staff`, `teacher` | Schulleitung nur die eigene Schulform; Hort nur die betreuten Kinder; Lehrkraft nur Name, Klasse und die Alltagsangaben (`glossar.md`) — ein externes Hortkind gehört **keiner** Schulform und ist für keine Schulleitung sichtbar (09). **Dazu das Austrittsdatum, wenn der Aufrufer die Klassenlehrkraft dieses Kindes ist** (`classes.class_teacher_id`): die zweite der beiden Einsichten, die die Klasse trägt — „das Ende eines Kindes geht seine Klasse an und nicht das ganze Kollegium" (15) —, dieselbe Mechanik wie die erste in [`gesundheit-api.md`](gesundheit-api.md) und **keine neue Rolle**. Jede andere Lehrkraft sieht es nicht, und eine Vertretung erbt es nicht | liest | `backend_sensitive` für Konfession und Kirchengemeinde |
| `PUT /persons/{person_id}/address` — umziehen; ein Häkchen setzt dieselbe Anschrift für die Kinder mit, in einer Transaktion | [02](../soll-prozesse/02-datenaenderung.md) Z1 | Erziehungsberechtigte; `secretariat` (Umweg) | die eigene Person und die Personen der Kinder der eigenen Familien. **Ein Kind ist eine Person** — der Umzug allein des Kindes läuft über dieselbe Route mit seiner `person_id`, das Häkchen ist dann ohne Wirkung | schreibt, `guardian:` / `entra:` | — |
| `POST /persons/{person_id}/phone-numbers` — eine Nummer eintragen, samt Art, Bemerkung und ob sie tagsüber erreichbar ist | [02](../soll-prozesse/02-datenaenderung.md) Z1 | Erziehungsberechtigte; `secretariat` (Umweg) | die eigene Person, die Personen der eigenen Kinder und die eigenen Notfallkontakte | schreibt, `guardian:` / `entra:` | — |
| `PATCH /phone-numbers/{phone_number_id}` — eine Nummer ändern | [02](../soll-prozesse/02-datenaenderung.md) Z1 | Erziehungsberechtigte; `secretariat` | wie oben, über die Person der Nummer aufgelöst | schreibt, `guardian:` / `entra:` | — |
| `DELETE /phone-numbers/{phone_number_id}` — eine Nummer löschen | [02](../soll-prozesse/02-datenaenderung.md) Z1 | Erziehungsberechtigte; `secretariat` | **die letzte tagsüber erreichbare Nummer der Familie lässt sich nur ersetzen, nie löschen** — sobald ein Vertrag am Kind steht oder eine Ferienbuchung läuft; die Pflicht steht bewusst nicht als Constraint (`schema/stammdaten-schema.sql`) und liegt damit hier | schreibt, `guardian:` / `entra:` | — |
| `PUT /persons/{person_id}/email` — eine neue Mailadresse eintragen; schickt den [Bestätigungscode](../soll-prozesse/hebel.md#zugang-und-anmeldecode) dorthin und **ändert `persons.email` noch nicht** | [02](../soll-prozesse/02-datenaenderung.md) Z1 | Erziehungsberechtigte; `secretariat` (Umweg) | die eigene Person und die Personen der eigenen Kinder; bis zur Bestätigung steht die alte Adresse | schreibt, `guardian:` / `entra:` | — |
| `POST /persons/{person_id}/email/confirmation` — den Code einlösen; setzt die Adresse und schickt die Info an die bisherige | [02](../soll-prozesse/02-datenaenderung.md) Z1 | wie oben | dieselben 15 Minuten und fünf Fehleingaben wie beim Anmeldecode — ein Mechanismus für beides. **Die letzte Mailadresse der Familie lässt sich nur ersetzen, nie löschen** | schreibt, `guardian:` / `entra:` | — |
| `PATCH /persons/{person_id}/guardian` — Beruf, Konfession und Staatsangehörigkeit des Sorgeberechtigten | [02](../soll-prozesse/02-datenaenderung.md) „Was dabei erhoben wird", [05](../soll-prozesse/05-bewerbung.md) | Erziehungsberechtigte; `secretariat` | die eigene Person — **und nur, solange an keinem Kind der Familien dieser Person ein Vertrag freigegeben ist**; ab dann allein das Sekretariat. Die Zeile entsteht mit der ersten erhobenen Angabe, `uq_guardians_person` macht die Person zum Schlüssel | schreibt, `guardian:` / `entra:` | — |
| `PATCH /children/{child_id}` — Geburtsdatum, Geburtsort und -land, Muttersprache, Staatsangehörigkeit, zweite Staatsangehörigkeit, Konfession, Kirchengemeinde | [02](../soll-prozesse/02-datenaenderung.md) Z1 und Z2 | Erziehungsberechtigte; `secretariat`, `school_management` | Eltern nur bis zur Freigabe (siehe „Zwei Grenzen"); danach das Sekretariat, und **jede Änderung erzeugt die Nachzieh-Aufgaben in derselben Transaktion**. Name und Geschlecht stehen an `persons` und laufen über die Route darunter | schreibt, `guardian:` / `entra:` | — (Schreiben); `backend_sensitive`, wenn die Antwort den neuen Stand mitgibt |
| `POST /families/{family_id}/contacts` — Notfallkontakt oder Abholberechtigten anlegen: Person, Nummer und Verknüpfung in einer Transaktion | [02](../soll-prozesse/02-datenaenderung.md) Z1 | Erziehungsberechtigte; `secretariat` (Umweg) | die eigene Familie; mindestens eine der beiden Rollen muss gesetzt sein (`ck_family_contacts_role`) | schreibt, `guardian:` / `entra:` | — |
| `PATCH /families/{family_id}/contacts/{family_contact_id}` — Verhältnis und Rollen ändern | [02](../soll-prozesse/02-datenaenderung.md) Z1 | wie oben | wie oben; der Name der Person läuft über `PATCH /persons/{person_id}` | schreibt, `guardian:` / `entra:` | — |
| `DELETE /families/{family_id}/contacts/{family_contact_id}` — Kontakt entfernen | [02](../soll-prozesse/02-datenaenderung.md) Z1 | wie oben | nicht, wenn er die letzte tagsüber erreichbare Nummer trägt (siehe oben); die `persons`-Zeile bleibt stehen und geht mit dem Lösch-Lauf | schreibt, `guardian:` / `entra:` | — |

## Rechtelage

Alles hier ändert, **wer Rechte hat**. Es kommt von außen herein — per Mail, Telefon, Brief —, das
Sekretariat sieht den Nachweis an und trägt ein; im System gibt es dafür kein Formular und keinen
Antrag (02 Z2). Jede dieser Routen setzt deshalb `change_log.proof_seen_at`, wo ein Nachweis vorlag;
den Nachweis selbst nimmt keine Route entgegen.

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `PATCH /persons/{person_id}` — Anrede, Vor- und Nachname, Rufname, Geschlecht | [02](../soll-prozesse/02-datenaenderung.md) Z2 | `secretariat`, `school_management` | Schulleitung nur bei einem Kind ihrer Schulform in dieser Familie. Bei einem Kind zieht der Admin Konto **und** Schuladresse in derselben M365-Aufgabe nach (13) | schreibt, `entra:` | — |
| `POST /families/{family_id}/guardians` — eine sorgeberechtigte Person hinzufügen: vorhandene Person verknüpfen oder anlegen, samt Verhältnis und Einsichtsstufe | [02](../soll-prozesse/02-datenaenderung.md) Z2 | `secretariat` | unbeschränkt; `uq_family_guardians` hält je Familie eine Zeile je Person | schreibt, `entra:` | — |
| `PATCH /families/{family_id}/guardians/{person_id}` — Verhältnis zum Kind, Briefanschrift der Amtsvormundschaft, „wer in Briefe einzubeziehen ist" | [02](../soll-prozesse/02-datenaenderung.md) Z2, [06](../soll-prozesse/06-anmeldetag.md) Z5 | `secretariat` | unbeschränkt. `include_in_correspondence` steht **neben** der Einsichtsstufe und ersetzt sie nicht: die Stufe nimmt den Zugriff, das Häkchen nur die Post | schreibt, `entra:` | — |
| `DELETE /families/{family_id}/guardians/{person_id}` — Wegfall eines Elternteils | [02](../soll-prozesse/02-datenaenderung.md) Z2 | `secretariat` | nicht die letzte Sorgeberechtigung einer Familie; die `persons`- und `guardians`-Zeilen bleiben stehen — „ein Mensch behält seinen Beruf, wenn eine seiner Familien geht" | schreibt, `entra:` | — |
| `PUT /families/{family_id}/guardians/{person_id}/access-level` — die [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) setzen | [02](../soll-prozesse/02-datenaenderung.md) Z2 und „Sonderfälle" | `secretariat` | unbeschränkt, **auf Vorlage eines Beschlusses** — die einzige Route, für die der Nachweis Pflicht ist. Sie ist der eine Ort, an dem die Stufe entsteht; ausgewertet wird sie an einer anderen einen Stelle ([`gemeinsam.md`](gemeinsam.md#einsichtsstufe)) | schreibt, `entra:` | — |

## Abgang und Jahreswechsel

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `PUT /children/{child_id}/departure` — Austrittsdatum und Grund eintragen oder ändern; legt in derselben Transaktion die **Abgangsliste** an — je laufender Verbindung und je Fremdsystem einen Punkt — und schickt die Mail an alle Sorgeberechtigten | [03](../soll-prozesse/03-irregulaerer-abgang.md) Z1 und Z2 | `secretariat`, `school_management` | Schulleitung nur die eigene Schulform. Beides ist Pflicht oder beides leer (`ck_children_exit`); der Austritt darf vor dem Eintritt nicht liegen (`ck_children_exit_after_entry`). **Die offenen Putzdiensttermine stehen nur beim letzten Kind der Familie darauf**, die Ferienbuchung nie | schreibt, `entra:` | — |
| `DELETE /children/{child_id}/departure` — den Abgang zurücknehmen; streicht die noch offenen Punkte und schickt dieselbe Mail | [03](../soll-prozesse/03-irregulaerer-abgang.md) „Entscheidungen" | `secretariat`, `school_management` | **bestätigte Punkte bleiben stehen** — „einen bestätigten Punkt nimmt zurück, wer ihn bestätigt hat", und das ist der Querschnitt. **Der Punkt am Familienbezug geht nur, wenn danach kein Kind der Familie mehr ein Austrittsdatum trägt**: er gehört dem letzten abgehenden Kind und nicht diesem einen Abgang | schreibt, `entra:` | — |
| `GET /children/{child_id}/departure` — die Abgangsliste: je Punkt Zuständigkeit, Stand und, bei einem Vertragspunkt, bis wann er nach jetzigem Stand läuft | [03](../soll-prozesse/03-irregulaerer-abgang.md) Z2 | `secretariat`, `school_management`, `accounting`, `admin`, `day_care_management`; Erziehungsberechtigte | **die ganze Liste sieht das Sekretariat, jede andere Stelle nur ihre eigenen Punkte**; die Eltern sehen Austrittsdatum und die bestätigten Enden ihrer eigenen Verträge, den Grund nicht | liest | — |
| `PUT /children/{child_id}/repetition` — eintragen, wer seine Stufe wiederholt; ein leeres Schuljahr nimmt es zurück | [04](../soll-prozesse/04-schuljahreswechsel.md) Z1 | `secretariat`, `school_management` | nur bei einem eingeschriebenen Kind (`ck_children_repeats_needs_entry`); der Lauf am 1. August lässt genau die stehen, deren Wert das beginnende Schuljahr trägt | schreibt, `entra:` | — |
| `PUT /children/{child_id}/enrolment` — Schulart, Klassenstufe und Eintrittsdatum von Hand setzen | [04](../soll-prozesse/04-schuljahreswechsel.md) „Sonderfälle" | `secretariat`, `school_management` | Schulleitung nur ihre eigene Schulform. Die drei Spalten stehen zusammen oder gar nicht (`fk_children_branch MATCH FULL`), die Stufe muss in die Schulart passen (`ck_children_grade_level`), und eine Klasse setzt das Eintrittsdatum voraus. **Regulär setzt sie die Vertragsfreigabe** (08) — dies ist die Korrektur, nicht der Weg | schreibt, `entra:` | — |
| `GET /school-years/{school_year}/rollover` — die **Ansicht des Jahreswechsels**, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste): wer aufsteigt, wer neu kommt, wer geht, wer wiederholt. **„Was endet“ trägt sie nicht** — die Enden setzt der Jahreslauf, und sie gehören den Domänen, deren Verträge sie beenden (siehe „Was an den Rand stößt“); die vier Gruppen rechnen allein über `children` und den freigegebenen Vertrag. — Alternative: Hortvertrag, Module und Essensabo hier mitlesen; Preis: die Ansicht kennt die Endregeln dreier fremder Domänen, und die erste Änderung dort ändert eine Stammdatenroute | [04](../soll-prozesse/04-schuljahreswechsel.md) Z1 und Z3 | `secretariat`, `accounting`, `admin`, `school_management` | unbeschränkt (interne Liste, nie über OTP). Sie zeigt vor dem 1. August, was der Lauf vorhat, und danach, was er getan hat — **eine Ansicht für beides**, und sie bleibt das ganze Jahr abrufbar, weil die Buchhaltung sie beim Monatsabschluss braucht. Es entsteht keine Aufgabe und es wird nichts abgehakt | liest | — |

**Die Abgangsliste trägt heute die vier Punkte, die dieser Bestand kennt** — ASV-BW, Optigem,
M365 und die Bescheinigungen —, dazu beim letzten Kind der Familie die offenen Putzdiensttermine als
einen Punkt am Familienbezug. **Die Vertragspunkte** — Schulvertrag, Hortvertrag, Mensa — **entstehen
mit der Domäne, die den Vertrag führt**, und bringen ihre `sync_targets`-Zeile mit: welcher Vertrag
läuft und bis wann, weiß nur sie, und die Seed-Migration hält ausdrücklich fest, dass eine solche
Zeile mit dem Endpunkt entsteht, der sie auslöst. — Alternative: die drei Ziele hier anlegen und die
Verträge von hier aus lesen; Preis: die Kündigungsregel des Schulvertrags stünde im
Stammdaten-Router, und drei Codes, Namen und Rollen wären erfunden, die kein Block nennt. Genau das
ist der Riss, den „Auf Zukunftssicherheit“ 1 benennt — die Route ruft die Domänen ab, statt eine
Liste zu führen.

**`confirmed_end_date` bleibt am Abhaken (`PUT /tasks/{sync_task_id}`) entgegennehmbar, obwohl
heute kein Punkt ein Vertragspunkt ist:** ein optionales Feld, kein Mechanismus, und es trägt mit dem
ersten Vertragspunkt. — Alternative: es erst mit den Vertragspunkten aufnehmen; Preis: die
Querschnittsroute ändert sich ein zweites Mal, obwohl das Schema die Spalte längst trägt.

## Mitarbeitende und Rollen

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /employees` — einen Mitarbeitenden anlegen: Name, Haus, auf Wunsch der erste Arbeitstag; legt in derselben Transaktion die M365-Aufgabe beim Admin an | [13](../soll-prozesse/13-m365-konten.md) Z1 | `personnel`, `executive_management` | unbeschränkt, **für beide Häuser** — eine `employees`-Zeile setzt keine Beziehung zur Schule voraus (`grenzkarte.md`, Q4). Je Person eine Zeile (`uq_employees_person`) | schreibt, `entra:` | — |
| `PATCH /employees/{employee_id}` — Haus, erster und **letzter Arbeitstag**, „an wen die Post künftig geht"; der letzte Arbeitstag legt die Offboarding-Aufgabe an | [13](../soll-prozesse/13-m365-konten.md) Z1 und Z3 | `personnel`, `executive_management` | unbeschränkt; **nicht das Sekretariat**, abweichend von der [Standardantwort](../soll-prozesse/hebel.md#standardantworten). Mit dem Ablauf des letzten Arbeitstags enden alle Rollen von selbst — auch die letzte Admin-Rolle —, ohne dass jemand sie entzieht | schreibt, `entra:` | — |
| `PUT /employees/{employee_id}/account` — die Kennungen des Schulkontos: Schuladresse und Entra-Objekt-ID; hakt eine offene M365-Aufgabe im selben Zug ab | [13](../soll-prozesse/13-m365-konten.md) Z2 | `admin` | **allein der Admin** — sie spiegeln den Tenant, „wer sie anderswo berichtigt, macht sie falsch statt richtig". Beide sind eindeutig (`uq_employees_work_email`, `uq_employees_entra`) | schreibt, `entra:` | — |
| `PUT /children/{child_id}/school-email` — die Schuladresse des Kindes; hakt eine offene M365-Aufgabe im selben Zug ab | [13](../soll-prozesse/13-m365-konten.md) Z2 | `admin` | allein der Admin, aus demselben Grund; eindeutig (`uq_children_school_email`). **Wo keine Aufgabe entsteht**, weil der Jahrgang über die Jahresansicht läuft, trägt er sie ebendort ein — dieselbe Route | schreibt, `entra:` | — |
| `PUT /employees/{employee_id}/roles` — die Rollen dieses Mitarbeitenden setzen: die Menge wird geladen und abgeglichen, nie als Menge gelöscht ([`gemeinsam.md`](gemeinsam.md#schreiben)) | [00](../soll-prozesse/00-zugang-und-portal.md) Z4 | `admin`, `executive_management` | **die letzte Admin-Rolle lässt sich nicht entziehen, nur übertragen** — das weist diese Route ab, weil die Regel über alle Zeilen zählt und deshalb kein Constraint sein kann (`schema/stammdaten-schema.sql`). Eine zweiggebundene Rolle braucht ihren Zweig, eine zweigfreie darf keinen tragen (`ck_employee_roles_branch_bound`). **Es gilt sofort, auch mitten in einer laufenden Sitzung** | schreibt, `entra:` | — |
| `GET /employees` — der Mitarbeitendenbestand samt Rollen, Haus, Schuladresse und Arbeitstagen | [13](../soll-prozesse/13-m365-konten.md) „Was dabei erhoben wird" | `personnel`, `executive_management`, `admin`, `secretariat` | Listenroute, deshalb nie über den OTP-Pfad ([`gemeinsam.md`](gemeinsam.md)). **Nicht die Schulleitung** — sie sieht im Rahmen ihrer Schulform, und ein Mitarbeitender hat keine — und **nicht die KITA-Leitung**, auch nicht für ihr eigenes Haus | liest | — |
| `GET /employees/selectable` — die wählbaren Personen: Name und Rollen, keine Personalangaben | [14](../soll-prozesse/14-elternbonus.md) Z1, [12](../soll-prozesse/12-rechnungsfreigabe.md) Z1, [15](../soll-prozesse/15-klassenbildung.md) Z1 | jede Mitarbeiterrolle; Erziehungsberechtigte für die Wahl der bestätigenden Person | eine eigene Route und keine Erweiterung der Zeile darüber: **wer eine Person auswählen lassen will, braucht keine Personalangaben**. Der Aufrufer nennt die verlangte Rolle; beim Elternbonus fallen die beiden KITA-Rollen heraus (14) | liest | — |
| `GET /m365/deletable-accounts` — die Konten, deren sechs Monate abgelaufen sind, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste) | [13](../soll-prozesse/13-m365-konten.md) Z5 | `admin` | unbeschränkt; **Schüler und Mitarbeitende in einer Liste** — sie rechnet über `employees.last_working_day` und `children.exit_date`. Sie ist keine Aufgabe: „ein ganzer Jahrgang stünde sonst im Januar als sechzig Zeilen in der Wochenmail" | liest | — |

## Klassen

| Handlung | Herkunft | Wer darf | Worauf eingeschränkt | Schreibt/liest | Enge Rolle |
|---|---|---|---|---|---|
| `POST /classes` — eine neu beginnende Klasse anlegen: Schulart, Startschuljahr, Zug, Klassenlehrkraft, Raum | [15](../soll-prozesse/15-klassenbildung.md) Z1 | `school_management`, `secretariat` | Schulleitung nur ihre eigene Schulart. Die Kennung ist eindeutig (`uq_classes_key`) und **wird nie geändert** — Stufe und Anzeigename werden gerechnet, nicht gespeichert | schreibt, `entra:` | — |
| `PATCH /classes/{class_id}` — Klassenlehrkraft oder Raum ändern | [15](../soll-prozesse/15-klassenbildung.md) Z1, `hebel.md` „Ändern" | `school_management`, `secretariat` | **nicht die Kennung**: Schulart, Startschuljahr und Zug stehen fest, weil M365-Gruppe und Mailverteiler an ihnen hängen. Genau eine Klassenlehrkraft je Klasse, dieselbe darf mehrere führen | schreibt, `entra:` | — |
| `GET /classes` — welche Klassen es gibt, samt gerechneter Stufe und Anzeigename; ausgelaufene fallen heraus | [15](../soll-prozesse/15-klassenbildung.md) Z1 | `school_management`, `secretariat`, `teacher`, `admin`, `executive_management` | Listenroute, nie über OTP; eine Klasse, deren Stufe über die Schulart hinausliefe, taucht in keiner laufenden Ansicht mehr auf | liest | — |
| `PUT /children/{child_id}/class` — ein Kind in eine Klasse setzen oder umsetzen; **zieht den Aktenordner mit** und legt die Nachzieh-Aufgaben an. **Der Klassenordner wird über die Kennung unter der Bibliothekswurzel adressiert und angelegt, wo er fehlt** — `child_file_folders` trägt die Element-Kennung des Kindes und keinen Elternbezug, und ein Pfad, der nur einmal zum Auflösen dient, wird nirgends gespeichert (`grenzkarte.md` Q2). — Alternative: eine Spalte für den Klassenordner; Preis: ein zweiter Ablageanker, den kein Block verlangt, und eine Migration für einen Wert, den SharePoint schon führt. **Der Zug wird im Request abgewartet, nicht nachgereicht**: Scheitert er, fällt die Klassenzuordnung mit ihm zurück. — Alternative: ihn als Hintergrundaufgabe schicken; Preis: ein Ordner unter der alten Kohorte, den nichts meldet — genau der Fall, gegen den 15 „Dateien" den Zug überhaupt verlangt | [15](../soll-prozesse/15-klassenbildung.md) Z2 und Z3 | `school_management`, `secretariat` | Schulleitung nur ihre eigene Schulform. Zwei Bedingungen: das Kind ist eingeschrieben (`ck_children_class_needs_entry`) und die Klasse trägt seine Schulart (`fk_children_class`, zusammengesetzt). **Ein Klassenwechsel mitten im Jahr ist dieselbe Handlung** und erzeugt dieselbe Aufgabenart — eine offene wird ersetzt, nicht verdoppelt | schreibt, `entra:` | — |
| `GET /classes/{class_id}/roster` — die **Klassenliste** als Druckansicht, [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste): die eingeschriebenen Kinder mit Notfallnummer, Abholberechtigten, den Alltagsangaben zur Gesundheit, dem Fotoeinverständnis und der Schuladresse | [15](../soll-prozesse/15-klassenbildung.md) „Dateien" | `teacher`, `secretariat`, `school_management` | unbeschränkt für Lehrkräfte — **neue Einsicht entsteht durch die Liste nicht, sie liegt nur beieinander**: den vollen Gesundheitsbestand sieht die Klassenlehrkraft am Kind und nicht hier. Ein abgegangenes Kind fällt ohne Zutun heraus | liest | — **Beim Bau richtiggestellt:** `backend_health_note` ist eine *Schreib*beschränkung auf `child_health_records.action_note`; die Laufzeit-Rolle liest die Spalte tabellenweit (`wb-backend`, `gesundheit_domain`-Migration). Die Liste braucht deshalb keine enge Rolle |
| `GET /classes/placement` — die **Klassenbildungsansicht**: alle Kinder einer künftigen Stufe mit Geschlecht, Wohnort, Geschwistern und ihrer bisherigen Klasse | [15](../soll-prozesse/15-klassenbildung.md) Z2, `grenzkarte.md` „Klassenbildung" | `school_management`, `secretariat` | Schulleitung nur ihre eigene Schulart. **Kein Zusammensetzungswunsch** — Block 15 lässt ihn außerhalb, und das Schema trägt ihn nicht (`schema/klassenbildung-schema.sql`). Keine Kapazität: die Zahl wird gezeigt, nicht geprüft | liest | — |
| `GET /classes/{class_id}/selectable-guardians` — die wählbaren sorgeberechtigten Personen der Kinder dieser Klasse: Name und Kennung, **kein Kontaktweg** | [16](../soll-prozesse/16-elternvertretung.md) Z1 | die Klassenlehrkraft dieser Klasse (`classes.class_teacher_id`); `secretariat`, `school_management` | Das Gegenstück zu `GET /employees/selectable` für die andere Seite: Die Elternvertretung wird „ausgewählt und nicht eingetippt" ([`klassenorganisation-api.md`](klassenorganisation-api.md)), und ohne diese Route bliebe nur, sie einzutippen. **Eine eigene Route und keine Erweiterung des Rosters**: Der trägt die Kinder samt Abholberechtigten, hier stehen die Sorgeberechtigten, und wer eine Person wählen lassen will, braucht ihre Adresse nicht. Nur die Sorgeberechtigten der Kinder **dieser** Klasse, geprüft in der Query; Schulleitung nur ihre Schulart. Listenroute, nie über den OTP-Pfad | liest | — |

## Die vier Läufe

Keine Route, kein Endpunkt von außen ([`gemeinsam.md`](gemeinsam.md#was-keine-route-ist)):

| Lauf | Herkunft | Auslöser | Aktor |
|---|---|---|---|
| Die beiden Mails der Vorarbeit — ans Sekretariat, wer nicht aufsteigt, an die Geschäftsführung, die Preise des neuen Jahres zu prüfen; die zweite legt zugleich ihre Aufgabe an | [04](../soll-prozesse/04-schuljahreswechsel.md) Z1 | der 1. Juli, ein festes Datum; die ans Sekretariat genau einmal, es wird nicht nachgefasst | `system:rollover` |
| **Der Jahreslauf**: alles rückt eine Stufe auf, was im endenden Schuljahr eingeschrieben war (Wiederholer ausgenommen, Warteplätze mit); wer einen freigegebenen Schulvertrag für dieses Schuljahr hat, ist eingeschrieben; wer am Ende seiner Schulart steht und keinen hat, bekommt den 31. Juli als Austrittsdatum; die Klassenzuordnung des Schulartwechslers wird geleert; zum selben Tag enden Schulvertrag, Hortvertrag samt Modulen und Essensabo. Mails an alle Sorgeberechtigten abgehender Kinder und an jede Familie, deren Hortvertrag endet, ohne dass das Kind abgeht | [04](../soll-prozesse/04-schuljahreswechsel.md) Z2 | der 1. August, ein festes Datum. **Der Elternbonus-Lauf geht ihm voraus** (14) — sonst stünde der Wechsler in die eigene Realschule schon als Realschüler da | `system:rollover` |
| Die drei Erinnerungen zum Schulanfang als Aufgaben beim Sekretariat: Putzdienstjahr einrichten, Voranmeldung öffnen, Lösch-Lauf anstoßen | [04](../soll-prozesse/04-schuljahreswechsel.md) Z4 | der 1. September, ein festes Datum; im August wäre nichts davon zu erledigen | `system:rollover` |
| Abgelaufene Anmeldecodes räumen | `schema/stammdaten-schema.sql` | 24 Stunden nach `created_at`; nach 15 Minuten ist der Code tot, nach einer Stunde auch das Ratelimit, das ihn zählt | `system:cleanup` |

**Die Meldung an die Admins, wenn ein Schulkonto ohne Rolle anklopft** (00 Z3), ist weder Route noch
Lauf: Sie hängt an der Rollenauflösung jedes geschützten Aufrufs. Wessen letzter Arbeitstag
abgelaufen ist, löst sie **nicht** aus — er ist kein Neuzugang, sein Konto ist zu schließen.

## Was an den Rand stößt

Je eine Zeile, benannt und nicht mitgeplant:

- **Aufgabe abhaken** (`PUT /tasks/{sync_task_id}`), samt dem Enddatum eines Vertragspunkts der
  Abgangsliste, und der Aufgabenbestand selbst — [Querschnitt](querschnitt-api.md).
- **Die Änderungsspur ansehen**, darunter die Rollenhistorie für Admins und Geschäftsführung (00) —
  [Querschnitt](querschnitt-api.md).
- **Die Werte im System pflegen**, an denen 04 Z1 hängt — [Querschnitt](querschnitt-api.md).
- **Familie, Kind und Sorgeberechtigte anlegen** — Anmeldung ([05](../soll-prozesse/05-bewerbung.md),
  [09](../soll-prozesse/09-hortvertrag.md)) und Ferien ([10](../soll-prozesse/10-ferienprogramm.md)).
- **Das SEPA-Mandat** ausfüllen und ersetzen: die Tabelle steht in Stammdaten, die Handlung gehört
  der Vertragsstrecke ([08](../soll-prozesse/08-schulvertrag.md)) — Anmeldung.
- **Die Elternvertretung je Klasse** eintragen und austragen
  ([16](../soll-prozesse/16-elternvertretung.md)) — Klassenorganisation; sie liest `classes` von
  hier.
- **Die Liste der Kinder ohne nachgetragenen Bestand** (`soll-prozesse/README.md`) — sie zählt
  Gesundheitsangaben, Fotoeinverständnis, Notfallnummer, Mandat und Hortmodule und gehört damit der
  Vertragsstrecke, nicht diesem Bestand — Anmeldung.
- **Eine neue abgebende Schule anlegen** (`previous_schools`): Die Liste wächst im Betrieb, und kein
  Block sagt, wer sie pflegt — die Route gehört dorthin, wo die Bewerbung sie braucht
  ([05](../soll-prozesse/05-bewerbung.md)) — Anmeldung.
- **Die Enden, die der Jahreslauf setzt**, gehören den Domänen, deren Verträge sie beenden —
  Anmeldung ([09](../soll-prozesse/09-hortvertrag.md)) und Mensa
  ([11](../soll-prozesse/11-mensa.md)); der Lauf ruft sie, statt ihre Zeilen selbst zu kennen.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **`persons.nickname` hat keine Zeile in irgendeinem Block.** Die Spalte trägt den Rufname; keiner
  der sechs Blöcke erhebt ihn, und `prozesse.md` kennt ihn nicht. Er läuft hier in
  `PATCH /persons/{person_id}` mit (siehe „Festlegungen"), weil er sonst nur über den Import zu
  füllen wäre.
- **Die Anschrift vor einem Umzug steht in der Spur, aber nicht in einer Zeile.** `change_log` trägt
  an der Person `address_id` alt→neu — zwei Kennungen —, und *was* dort stand, trägt die
  `insert`-Zeile der alten `addresses`-Zeile. Beide zusammen beantworten „was vorher dastand"; die
  erste hängt an der Person, die zweite ist ankerlos (Stufe 8 des Lösch-Laufs) und verfällt nach der
  Frist ihrer eigenen Tabelle. **Laufen die zwei Fristen auseinander, bleibt ein Paar Kennungen
  übrig, das niemand mehr auflöst** — eine Bedingung an Block 17, keine Schemaänderung.
- **`employees.entra_object_id` hat keinen benannten Schreibpfad.** Block 13 zählt sechs Angaben am
  Mitarbeitendeneintrag auf, und diese ist ausdrücklich keine siebte, sondern die Anmeldeidentität —
  eingetragen wird sie trotzdem von jemandem.
- **`children` hat keine Spalte für die Anschrift.** Sie steht an `persons` über `children.person_id`
  — deshalb trägt `PUT /persons/{person_id}/address` beide Fälle und es gibt keine zweite Route am
  Kind.
- **Der Ownership-Check der Familie hängt an `family_guardians`, nicht an `guardians`.** Wer eine
  `guardians`-Zeile hat, aber in keiner Familie steht, erreicht nichts — das ist gewollt und der
  Grund, warum `POST /families/{family_id}/guardians` beide Zeilen anlegt.

## Die Prüfung

### Gegen das Schema, Spalte für Spalte

| Fund | Entscheidung |
|---|---|
| `persons.address_id` ist nullable, obwohl 02 und 05 die Anschrift „Pflicht" nennen | Die Route hält sie, nicht das Schema — dieselbe Tabelle trägt Mitarbeitende und Notfallkontakte, für die kein Block eine verlangt. `PUT /persons/{person_id}/address` verlangt alle vier Pflichtfelder, `POST /families/{family_id}/contacts` keines |
| `phone_numbers.reachable_daytime` hat den Vorgabewert `false` | `DELETE /phone-numbers/{id}` prüft gegen die Familie und nicht gegen die Person: die Pflicht aus 02 gilt je Familie, und eine nicht sorgeberechtigte Person genügt |
| `children.denomination_id` und `congregation` liegen hinter `backend_sensitive`, `guardians.denomination_id` ebenso | Jede lesende Route, die sie zeigt, nennt die enge Rolle; die schreibenden nicht — die Beschränkung ist eine Lesebeschränkung |
| `children` hat kein `SELECT` auf `denomination_id`/`congregation` für die Laufzeit-Rolle | `GET /children/{child_id}` und `GET /families/{family_id}` holen sie in einem `narrow_role`-Block derselben Transaktion, nicht über eine zweite Verbindung. **Beim Bau nachgezogen:** `backend_sensitive` bekam dabei `SELECT` auf die *Schlüsselspalte* (`children.child_id`, `guardians.person_id`) — ohne sie kann die enge Rolle keine Zeile benennen, und Postgres weist `WHERE child_id = …` mit „permission denied for table children“ ab (gemessen). Eine Ausweitung ist es nicht: gelesen werden weiterhin nur die zwei Art.-9-Spalten |
| `ck_children_enrolment` verlangt Schulart **und** Stufe, sobald ein Eintrittsdatum steht | `PUT /children/{child_id}/enrolment` nimmt die drei zusammen entgegen und nicht einzeln |
| `fk_children_branch` ist `MATCH FULL` über drei Spalten | Die Route setzt `first_grade_level` und `final_grade_level` aus der gewählten Schulart mit, statt sie entgegenzunehmen — sie sind mitgeführte Werte, keine Eingabe |
| `uq_employee_roles` ist `NULLS NOT DISTINCT` | `PUT /employees/{id}/roles` kann dieselbe zweigfreie Rolle nicht zweimal setzen; der Abgleich der Menge trifft das ohnehin |
| `login_codes.purpose` ist ein CHECK mit zwei Werten, keine Werteliste | Die beiden Routen setzen ihn fest (`login` bzw. `email_confirmation`); ein dritter Anlass wäre eine Migration und keine Zeile — benannt, nicht behoben |
| `login_sessions` hat keine Spalte für die Reichweite | `GET /auth/session` rechnet sie bei jedem Aufruf aus `email` über `persons` und `family_guardians`; das ist der Grund, warum es die Tabelle gibt |
| `sepa_mandates.account_holder_address_id` zeigt auf `addresses` | `PUT /persons/{person_id}/address` legt eine neue Zeile an und ändert keine bestehende — sonst zöge ein Umzug einen abgelösten Kontoinhaber mit um |
| `classes.class_teacher_id` ist nullable | `POST /classes` verlangt sie trotzdem („Pflicht, genau eine je Klasse"); leer bleibt sie allein beim Vollimport, wenn die Klassen aus ihrer rückgerechneten Kennung entstehen |
| `families` hat keine eigene Spalte | `GET /families/{family_id}` bezeichnet die Familie über ihre Kinder; ein Name entsteht dafür nicht |

### Gegen `api/putzdienst-api.md`

| Kollision | Entscheidung |
|---|---|
| `GET /cleaning/families/{family_id}` und `GET /families/{family_id}` | **bleibt dort.** Zwei Sachen unter demselben Pfadmuster: der Putzdienststand einer Familie und die Familie selbst. Keine der beiden liefert, was die andere liefert |
| „Anmeldung selbst (Code anfordern, Code einlösen, als wer man weitermacht)" steht dort am Rand | **wandert hierher** — `POST /auth/codes`, `POST /auth/sessions`, `PUT /auth/identity`. Die Randzeile dort wird durch den Verweis ersetzt |
| `GET /cleaning/cycles/{year}/families` liefert die Familien „mit Namen" | **bleibt dort.** Sie liest `persons`, ist aber die Zuteilungsliste des Putzdienstjahres und keine Stammdatenansicht |
| `PUT /cleaning/cycles/{year}/families/{family_id}/quota` prüft die Schulform der Schulleitung | **bleibt dort.** Dieselbe Bedingung steht hier an fünf Routen; sie ist der Hebel aus `hebel.md`, keine geteilte Route |
| „Abgangspunkt bestätigen (03 Z3)" steht dort am Rand als „Anmeldung/Abgang" | **ist dieselbe Route zweimal.** Die Handlung ist das Abhaken einer Q5-Aufgabe und gehört dem [Querschnitt](querschnitt-api.md); dass dabei die offenen Termine der Familie ohne Strafe verfallen, ist ein Seiteneffekt, den der Putzdienst umsetzt. Die Randzeile dort wird richtiggestellt |

### Auf Zukunftssicherheit

1. **Eine neue Fachdomäne hängt sich an**, sie bricht nichts: Sie liest über
   `GET /children/{child_id}`, `GET /families/{family_id}` und `GET /employees/selectable` und
   schreibt keine Stammdatenspalte. Ein Riss ist trotzdem benannt:
   `PUT /children/{child_id}/departure` legt die Abgangsliste an, und **welche Punkte darauf stehen,
   weiß nur die Domäne, die die Verbindung führt.** Die Route ruft die Domänen ab, statt eine Liste
   zu führen — täte sie das nicht, würde die Abgangsliste mit jeder neuen Domäne still
   unvollständig.
2. **Ein Feld an einer Tabelle kostet keine Route.** Vier Routen sind auf Felder geschnitten —
   `PUT /persons/{person_id}/address`, `PUT /employees/{id}/account`,
   `PUT /children/{id}/school-email`, `PUT /children/{id}/repetition` —, und jede trägt eine eigene
   Handlung mit eigener Rolle. Ein neues Feld an `persons` landet in `PATCH /persons/{person_id}`,
   eines an `children` in `PATCH /children/{child_id}`.
3. **Eine umbenannte Werteliste trägt.** Die Routen nennen `code`, nie `name`, und `code` ist die
   Verankerung. **Eine Verdrahtung bleibt und wird benannt:** die Sperre gegen den Entzug der letzten
   Admin-Rolle kennt den Code `admin`. Sie ist so verlangt (`hebel.md`, „Rollen") und ließe sich nur
   über ein weiteres Flag an `roles` lösen — ein Mechanismus für einen Fall.
4. **Eine neue oder gespaltene Rolle schreibt keine Bedingung um.** Der Ownership-Check ist überall
   eine Bedingung über Daten — die Familien der Sitzung, `employee_roles.school_branch_id` gegen
   `children.school_branch_id`, die betreuten Kinder —, nie eine Aufzählung von Rollen. Was eine neue
   Rolle kostet, ist ein Eintrag in der Spalte „Wer darf" jeder Route, die sie sehen soll; das ist
   nicht zu vermeiden und auch nicht zu bedauern: Wer eine Rolle vergibt, entscheidet damit, was sie
   sieht.
5. **Die Einsichtsstufe filtert an einer Stelle**, bei der Auflösung Sitzung → handelnde Person →
   Familien. Keine Route dieser Datei wertet sie ein zweites Mal aus. `PUT
   /families/{family_id}/guardians/{person_id}/access-level` ist der eine Ort, an dem sie entsteht.
6. **Zwei Vorgänge könnten zerfallen und tun es nicht:** Der Umzug mit Häkchen ist ausdrücklich „kein
   zweiter Vorgang" (02 Z1), und ein Notfallkontakt ohne Nummer trüge keinen Sachverhalt. Der Fall,
   der wirklich zerfällt, ist die Mailadresse — und sie ist **heute schon zwei**, weil ein Tippfehler
   den einzigen Kanal der Familie kostet.
7. **Ein verschwindendes Feld bricht keine Oberfläche**, es zeigt eines weniger. Der absehbare Fall
   ist benannt: Fällt der Zweckbeschluss für Konfession, Beruf, Staatsangehörigkeit und
   Kirchengemeinde negativ aus (`[?]` in 05), verschwinden vier Felder aus `GET /children/…`,
   `GET /families/…`, `PATCH /children/…` und `PATCH /persons/{id}/guardian` — und mit ihnen die enge
   Rolle an zwei Routen. Eine Versionierung entsteht dafür nicht.

## Festlegungen

Bestätigt und damit normaler Text; der verworfene Weg samt Preis bleibt stehen, weil er sonst als
Vorschlag wiederkommt. Die beiden `[A!]`-Marken unter „Zwei Grenzen" behalten ihre Marke auch
bestätigt: Ihr Wert ist, dass jeder Prüflauf den Schnitt wiedersieht (`prompts/gemeinsam.md`).

**Ein Umzug legt eine neue `addresses`-Zeile an und zeigt die betroffenen Personen darauf um;
eine bestehende Zeile wird nie geändert.** — Alternative: die Zeile ändern, wo alle darauf zeigenden
Personen umziehen; Preis: die Route müsste wissen, wer außer dem Antragsteller darauf zeigt, und ein
getrennt lebender Elternteil zöge still mit um. Was die neue Zeile kostet, ist die verwaiste alte —
und die räumt Stufe 7 des Lösch-Laufs, die ohnehin gebaut wird.

**Das Häkchen „gilt auch für die Kinder" umfasst die Kinder aller Familien dieser Person** — über
den OTP-Pfad die der *erreichbaren*: `family_guardians` trägt eine gesperrte Sorgeberechtigung
weiter, die die Reichweite der Sitzung nicht kennt, und das Häkchen darf dort nicht wieder
hereinführen. — Alternative: je Familie ein Häkchen; Preis: ein zweites Feld für den
Patchwork-Fall, den das Sekretariat mit derselben Route je Kind richtet.

**`PUT /employees/{employee_id}/account` trägt Schuladresse und Entra-Objekt-ID zusammen.** —
Alternative: die Objekt-ID als eigene Route; Preis: zwei Handgriffe für einen Kontovorgang, und die
Kennung, an der die Anmeldung hängt, hätte keinen benannten Schreibpfad.

**`PATCH /persons/{person_id}` trägt auch den Rufname**, obwohl kein Block ihn nennt. —
Alternative: die Spalte bleibt ohne Schreibpfad; Preis: eine Spalte, die nur der Import füllen kann,
und ein Kind, dessen Kurzform niemand mehr eintragen darf.

**`PUT /employees/{employee_id}/roles` setzt die ganze Menge.** — Alternative: je Rolle ein
`POST` und ein `DELETE`; Preis: „vergeben und entziehen" (00 Z4) wären zwei Routen für eine Handlung,
und die Sperre gegen den Entzug der letzten Admin-Rolle stünde an beiden.

**Die interne Oberfläche liest ihre Rollen über `GET /auth/roles`.** — Alternative: sie leitet
sie aus den `403`-Antworten ab; Preis: jede Ansicht baut sich aus Fehlschlägen auf, und ein Menü, das
erst beim Klick sagt, dass es nichts darf.

**Die Pflegeroute der Wertelisten** steht oben: Elf der zwölf tragen ohne; `previous_schools`
bekommt ihre mit dem Anmeldungs-Plan und steht dafür am Rand.

## Offene Fragen

Keine neue `[?]`. Die vier, die diese Domäne berühren, stehen schon an ihrer Stelle: der
Zweckbeschluss für Konfession, Beruf, Staatsangehörigkeit und Kirchengemeinde (05), die
Aufbewahrungsfrist eines ausgeschiedenen Mitarbeitenden (00), die für Vertrags- und Zahlungsdaten
(03) und die Bestätigung der Fremdsystem-Zuordnung (02).
