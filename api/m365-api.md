# M365-Kontenverwaltung — keine eigene Route

Aus [`13-m365-konten.md`](../soll-prozesse/13-m365-konten.md); es gilt
[`gemeinsam.md`](gemeinsam.md). **Diese Datei legt keine Route an, und das ist ihr Ergebnis** —
dieselbe Aussage, die `schema/m365-schema.sql` ohne eine einzige `CREATE`-Anweisung macht. Der Grund
steht im Block selbst: „Weltenbaum schreibt dabei nichts in den Tenant und liest keine Gruppen …
Er ist deshalb kein Ablauf im Portal, sondern der Ort, an dem ihr Anstoß entsteht." Was hier
entsteht, sind **Angaben an Menschen** — die gehören den Stammdaten — und **Aufgaben** — die gehören
dem Querschnitt.

**Gegenprobe:** Die Ablauftabelle hat **5 Zeilen**; alle fünf handeln im System, alle fünf haben
eine Route — **keine davon in dieser Datei**. Es gibt **0 Routen** hier, und **keine Abweichung**:
Der Bau der Stammdaten hat diese Domäne vollständig mitgenommen, weil ihr Auftrag dort schon
namentlich stand.

## Wo die fünf Zeilen liegen

| Zeile | Handlung | Route | Datei |
|---|---|---|---|
| Z1 | Einen Mitarbeitenden anlegen — Name, Haus, auf Wunsch der erste Arbeitstag; legt die M365-Aufgabe in derselben Transaktion an | `POST /employees` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z2 | Die Kennungen des Schulkontos eintragen — Schuladresse und Entra-Objekt-ID; hakt die offene Aufgabe ab | `PUT /employees/{employee_id}/account` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z2 | Dasselbe am Kind, „derselbe Handgriff … kein zweiter Weg daneben" | `PUT /children/{child_id}/school-email` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z3 | Den **letzten Arbeitstag** eintragen — der Faden, der heute reißt; legt die Offboarding-Aufgabe an | `PATCH /employees/{employee_id}` | [`stammdaten-api.md`](stammdaten-api.md) |
| Z4 | Die Offboarding-Aufgabe abarbeiten und abhaken | `GET /tasks`, `PUT /tasks/{sync_task_id}` | [`querschnitt-api.md`](querschnitt-api.md) |
| Z5 | Die löschbaren Konten sehen — [frisch erzeugt](../soll-prozesse/hebel.md#frisch-erzeugte-liste), Schüler und Mitarbeitende in einer Liste | `GET /m365/deletable-accounts` | [`stammdaten-api.md`](stammdaten-api.md) |

**Z5 ist bewusst keine Aufgabe**, sondern eine Liste: „Ein ganzer Jahrgang stünde sonst im Januar
als sechzig Zeilen in der Wochenmail, für Arbeit, bei der nichts kaputtgeht, wenn sie zwei Wochen
später geschieht." Sie wird kürzer, statt abgehakt zu werden.

## Die drei Abweichungen des Blocks, und wo sie eingelöst sind

Block 13 weicht dreimal von den [Standardantworten](../soll-prozesse/hebel.md#standardantworten) ab.
Jede Abweichung ist eine Rollenliste an einer gebauten Route — hier steht, an welcher, damit sie
nachprüfbar bleibt und nicht bei der nächsten Änderung verlorengeht:

| Abweichung | eingelöst an |
|---|---|
| Das **Sekretariat sieht, ändert aber nichts** — „Personalangaben bleiben bei der Stelle, die sie führt" | `GET /employees` nennt `secretariat`, `POST /employees` und `PATCH /employees/{employee_id}` nicht |
| Die **Schuladresse ändert allein der Admin**, auch nicht die Personalverwaltung — „sie spiegelt den Tenant, und wer sie anderswo berichtigt, macht sie falsch statt richtig" | `PUT /employees/{employee_id}/account` und `PUT /children/{child_id}/school-email` nennen `admin` und sonst niemanden |
| **Nicht die Schulleitung** — sie sieht im Rahmen ihrer Schulform, und ein Mitarbeitender hat keine — und **nicht die KITA-Leitung**, auch nicht für ihr eigenes Haus | `GET /employees` nennt beide nicht; der Preis eines Bestands für beide Häuser steht im Block |

## Was ohne Route gilt und trotzdem gebaut ist

- **„Mit dem letzten Arbeitstag enden alle Mitarbeiterrollen von selbst, ohne dass jemand sie
  entzieht"** — das ist keine Route und kein Lauf, sondern eine Bedingung der Rollenauflösung jedes
  geschützten Aufrufs ([`stammdaten-api.md`](stammdaten-api.md)). Daran hängen vier Wirkungen, die
  in vier Dateien stehen und alle dieselbe Spalte lesen: Er kommt nicht mehr herein (`zugang.md`),
  ist nicht mehr wählbar (`GET /employees/selectable`), sein Beleg trägt den Vermerk „ausgeschieden"
  ([`rechnungsfreigabe-api.md`](rechnungsfreigabe-api.md)) und er steht in keiner Aufgabenliste mehr.
  **Auch die letzte Admin-Rolle endet so** — der Schutz in
  [`hebel.md`](../soll-prozesse/hebel.md#rollen) gilt dem Entziehen und nicht dem Ausscheiden, und
  `PUT /employees/{employee_id}/roles` weist deshalb nur das Entziehen ab, nicht den Ablauf.
- **Die Meldung an die Admins, wenn ein Schulkonto ohne Rolle anklopft** (00 Z3), löst ein
  Ausgeschiedener **nicht** aus: „Er ist kein Neuzugang, sein Konto ist zu schließen"
  ([`stammdaten-api.md`](stammdaten-api.md)).
- **Die sechs Monate bis zur Kontenlöschung** haben keine Spalte und keinen Lauf. Sie sind fest, und
  die Liste rechnet sie über `employees.last_working_day` und `children.exit_date`.
- **Keine Mail, aus keinem Anlass.** Die offenen Aufgaben laufen in der Wochenmail des Admins mit,
  „das ist der einzige Anstoß".

## Der Tenant bleibt draußen — und das ist heute eine schärfere Aussage als beim Schema

Weltenbaum schreibt in keine der drei Domains, legt keine Gruppe an und liest keine. Was das
System an Microsoft Graph überhaupt tut, steht damit **vollständig außerhalb dieser Domäne**, und
inzwischen sind es drei Wege:

- **Mail senden** (`Mail.Send`) — der Anmeldecode und jede versandte Mail (`zugang.md`).
- **Eine Datei lesen** — `GET /documents/{document_id}/content`
  ([`querschnitt-api.md`](querschnitt-api.md)).
- **Eine Datei schreiben** — `POST /expense-claims`
  ([`rechnungsfreigabe-api.md`](rechnungsfreigabe-api.md)), der erste und bisher einzige.

**Keiner davon berührt Konten, Gruppen oder Verteiler**, und das ist die Zusage dieses Blocks: „ihre
Unordnung ist damit kein Vorprojekt" ([00](../soll-prozesse/00-zugang-und-portal.md)). Die Domäne,
die M365 im Namen trägt, ist die einzige, die Graph gar nicht anfasst.

## Am Schema aufgefallen

Kein Eingriff, das Schema führt `wb-backend`:

- **`employees.work_email` und `children.school_email` heißen verschieden und meinen dasselbe** —
  die Schuladresse. Das ist bewusst so (`schema/stammdaten-schema.sql`, Zeilenkommentar) und
  richtig, weil eine Dienstadresse und eine Schüleradresse in verschiedenen Domains liegen; für den
  Block ist es **eine** Angabe und **ein** Handgriff, und die beiden Routen sind deshalb Zwillinge
  und keine zwei Wege. Wer die eine ändert, ändert die andere mit.
- **Beide sind eindeutig** (`uq_employees_work_email`, `uq_children_school_email`), und das trägt
  mehr, als es scheint: Eine wiederverwendete Adresse eines Ausgeschiedenen wird abgewiesen, solange
  seine Zeile steht — der Lösch-Lauf (17) gibt sie frei, nicht der Admin.
- **`employees.last_working_day` ist nullable und trägt trotzdem alles.** Kein Constraint verlangt
  ihn, weil er erst feststeht, wenn jemand geht; die Pflicht aus dem Block („Pflicht, sobald er
  feststeht") ist deshalb keine Regel, die eine Gegenprobe abweisen könnte. Was daran hängt, hängt
  an seiner **Abwesenheit**: Wer keinen hat, arbeitet hier. Ein Vergessen sieht niemand — und das
  ist genau der Faden, der heute reißt und den dieser Block nur dadurch heilt, dass es jetzt eine
  benannte Stelle davor gibt.

## Offene Fragen

**Keine neue.** Die eine, die das Schema trägt, ist die aus
[00](../soll-prozesse/00-zugang-und-portal.md) und steht in `fragen.md` bei der
Datenschutzbeauftragten:

`[?]` Wie lange werden die Daten eines ausgeschiedenen Mitarbeitenden aufbewahrt? Der Anker steht
(`employees.last_working_day`), sein Ziel nicht — und ohne das Ziel hat der Lösch-Lauf (17) hier
nichts zu tun.
