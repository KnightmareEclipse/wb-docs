# Eltern-Selfservice — keine eigene Route

Aus [`00-zugang-und-portal.md`](../soll-prozesse/00-zugang-und-portal.md) und
[`02-datenaenderung.md`](../soll-prozesse/02-datenaenderung.md); es gilt
[`gemeinsam.md`](gemeinsam.md). **Diese Datei legt keine Route an, und das ist ihr Ergebnis** —
dieselbe Aussage wie in `schema/selfservice-schema.sql`. Sie ist damit die dritte Domäne ohne
eigene Route, aber aus einem anderen Grund als
[`klassenbildung-api.md`](klassenbildung-api.md) und [`m365-api.md`](m365-api.md): Jene sind
Oberflächen **auf einer** fremden Struktur; der Selfservice ist die Oberfläche **auf fünf** —
Kontaktdaten, Familienkontakte, Kindstammdaten, Einsichtsstufe und der Zugang selbst. Er hat keinen
eigenen Vorgang, sondern ist die Elternseite jedes anderen.

**Gegenprobe über zwei Blöcke:** Sie haben zusammen **8 Ablaufzeilen**; **6** tragen eine Route,
**2** nicht — und beide aus demselben benannten Grund (unten). Es gibt **0 Routen** hier. Keine
Abweichung: Der Bau der Stammdaten hat auch diese Domäne vollständig mitgenommen.

## Wo die acht Zeilen liegen

| Zeile | Handlung | Route | Datei |
|---|---|---|---|
| 00 Z1 | Anmelden: Code anfordern, Code einlösen, und bei geteilter Adresse wählen, als wer man weitermacht | `POST /auth/codes`, `POST /auth/sessions`, `PUT /auth/identity` | [`stammdaten-api.md`](stammdaten-api.md) |
| 00 Z2 | Welcher Satz Rollen gilt — der Anmeldeweg entscheidet, „nie beides gleichzeitig", und gelesen wird bei jedem Aufruf frisch | `GET /auth/session`, `GET /auth/roles` | [`stammdaten-api.md`](stammdaten-api.md) |
| 00 Z3 | Wer keine Rolle trägt, kommt nicht hinein; ein Schulkonto ohne Rolle meldet sich bei den Admins | **keine** — siehe unten | — |
| 00 Z4 | Mitarbeiterrollen vergeben und entziehen, sofort wirksam | `PUT /employees/{employee_id}/roles` | [`stammdaten-api.md`](stammdaten-api.md) |
| 02 Z1 | Die eigenen und die gemeinsamen Angaben ändern: Anschrift samt Häkchen für die Kinder, Telefon, Mailadresse mit Bestätigungscode, Notfallkontakte und Abholberechtigte | `PUT /persons/{person_id}/address`, `POST /persons/{person_id}/phone-numbers` samt `PATCH`/`DELETE /phone-numbers/{phone_number_id}`, `PUT /persons/{person_id}/email` samt `POST /persons/{person_id}/email/confirmation`, `POST /families/{family_id}/contacts` samt `PATCH`/`DELETE /families/{family_id}/contacts/{family_contact_id}` | [`stammdaten-api.md`](stammdaten-api.md) |
| 02 Z2 | Die Rechtelage und die Stammdaten des Kindes: Sorgerecht, Wegfall eines Elternteils, Name, Einsichtsstufe, die einmal erhobenen Angaben | `PATCH /persons/{person_id}/guardian`, `POST`/`PATCH`/`DELETE /families/{family_id}/guardians/{person_id}`, `PUT …/access-level`, `PATCH /children/{child_id}`, `PATCH /persons/{person_id}` | [`stammdaten-api.md`](stammdaten-api.md) |
| 02 Z3 | Je betroffenem Fremdsystem entsteht eine Nachzieh-Aufgabe | **keine** — siehe unten | — |
| 02 Z4 | Die Aufgabe abhaken, „erledigt" oder „war nichts zu tun" | `GET /tasks`, `PUT /tasks/{sync_task_id}` | [`querschnitt-api.md`](querschnitt-api.md) |

## Die zwei Zeilen ohne Route, und warum keine fehlt

Beide sind **Zeilen, in denen „System" handelt** — und ein System ruft keine Route:

- **00 Z3** hängt an der Rollenauflösung jedes geschützten Aufrufs und ist deshalb weder Route noch
  Lauf ([`stammdaten-api.md`](stammdaten-api.md)). Sie trägt dort auch die Unterscheidung, die
  leicht verlorengeht: Ein **Ausgeschiedener** bekommt denselben Hinweis, aber die Admins keine Mail
  — „sein Konto ist zu schließen und nicht er hereinzulassen".
- **02 Z3** ist ein Seiteneffekt: Jede schreibende Route oben legt ihre Nachzieh-Aufgaben **in
  derselben Transaktion** an. Eine eigene Route dafür wäre der zweite Weg, auf dem eine Aufgabe
  entstünde, und der erste, auf dem sie ohne ihre Änderung entstehen könnte.

## Was diese Domäne ausmacht, steht in drei fremden Sätzen

Sie hat keinen eigenen Ablauf, aber drei Grenzen, und jede ist **an genau einer Stelle** gebaut —
das ist ihr eigentlicher Inhalt:

- **Die Freigabe ist die Grenze, keine Feldliste.** Bis zur Freigabe des ersten Vertrags am Kind
  ändern die Eltern die einmal erhobenen Angaben selbst, ab ihr allein das Sekretariat. Im Schema
  ist das `contracts.released_at` **oder** `children.entry_date` — „die Einschreibung ist bei den
  Kindern des Vollimports, was sonst die Freigabe ist"
  ([`stammdaten-api.md`](stammdaten-api.md), „Zwei Grenzen").
- **Die Einsichtsstufe wirkt an einer Stelle**, bei der Auflösung Token → Person → Familien, und
  keine Route filtert sie ein zweites Mal ([`gemeinsam.md`](gemeinsam.md#einsichtsstufe)). Entstehen
  tut sie ebenfalls an genau einer: `PUT /families/{family_id}/guardians/{person_id}/access-level`,
  „die einzige Route, für die der Nachweis Pflicht ist".
- **Die sparsame Ansicht** ist keine Frontend-Verabredung: `GET /families/{family_id}` liefert
  Geburtsort, Muttersprache, Konfession, Kirchengemeinde und Beruf den Eltern nach der Freigabe
  **nicht mehr** ([`stammdaten-api.md`](stammdaten-api.md)). Dass die Eltern ihr Kind über die
  Familie lesen und nicht über `GET /children/{child_id}` — das dort keine Erziehungsberechtigten
  nennt — ist die Bauform dieser Zusage und kein Zufall.

## Was hier bewusst nicht entsteht

- **Kein Antrag und kein Formular** für eine Rechteänderung: „Im System gibt es für beides kein
  Formular und keinen Antrag" (02). Der Nachweis kommt außerhalb an, ein Mensch sieht ihn an, und
  **dass einer vorlag, trägt die [Änderungsspur](../soll-prozesse/hebel.md#änderungsspur)** und kein
  eigenes Feld.
- **Kein Zustand „hat Zugang"** je Familie. Er folgt aus den
  [laufenden Verbindungen](../soll-prozesse/hebel.md#laufende-verbindung), und jede davon steht in
  ihrer eigenen Domäne — „wann das eintritt, entscheidet der jeweilige Prozess und nicht dieser".
- **Keine Bestätigungsmail** für selbst Eingetragenes
  ([Standardantwort](../soll-prozesse/hebel.md#standardantworten)): Was gespeichert ist, steht sofort
  in der eigenen Übersicht, und die ist die Bestätigung. Die einzige Mail dieses Weges ist der
  Anmelde- bzw. Bestätigungscode, und der ist derselbe Mechanismus für beides.
- **Keine Suchroute und keine Bestandsliste** über Kinder oder Familien — das `[A!]` in
  [`stammdaten-api.md`](stammdaten-api.md), und es gilt hier ungebremst: Ein Elternzugang, hinter
  dem nur der eigene laufende Vorgang liegt, ist kein lohnendes Ziel
  ([Sparsame Ansicht](../soll-prozesse/hebel.md#sparsame-ansicht)).

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **Die Einsichtsstufe ist eine Werteliste und keine CHECK-Liste**, und der Grund steht im Schema:
  Sie entscheidet über keine andere Spalte derselben Zeile. Daraus folgt für die API eine Zusage,
  die sonst niemand aufschreibt: **Ein vierter Grad derselben Achse kostet keine Route** — eine
  Zeile in `access_levels` und die eine Stelle, die sie auswertet. Ein Beschluss, der je Bereich
  oder je Kind unterscheidet, wäre dagegen eine **zweite Achse** und damit die Feldliste, die
  [`hebel.md`](../soll-prozesse/hebel.md#einsichtsstufe) ausschließt — er kostet eine eigene
  Struktur und mehr als eine Route.
- **`persons.last_login_at` hat keine Route, die ihn liest.** Er wird beim Anmelden gesetzt und
  gehört dem Lösch-Lauf (17) als Anker; heute sieht ihn niemand. Das ist richtig — eine Anzeige
  „zuletzt angemeldet" verlangt kein Block —, aber es heißt, dass die Spalte bis zu Block 17
  ausschließlich schreibend benutzt wird.

## Offene Fragen

**Keine.** Beide Blöcke lassen für diese Domäne nichts offen; das Schema hält ausdrücklich fest,
dass ein vierter Fall der Einsichtsstufe heute nicht benennbar ist und deshalb nichts auf Vorrat
gebaut wird.
