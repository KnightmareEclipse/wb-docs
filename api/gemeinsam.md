# Gemeinsam — was für jede Route gilt

Gegenstück zu [`soll-prozesse/hebel.md`](../soll-prozesse/hebel.md): Was hier steht, gilt für
**alle** Routen und steht genau einmal. Eine Domänendatei schreibt nur, wo sie abweicht.

Der Plan entsteht hier, gebaut wird in `wb-backend`; die Form dort (`CLAUDE.md` §3, §6, §7,
`README.md`, „Writing data") ist Vorgabe für den Bau, nie für den Inhalt.

## Pfad

An der Sache, die der Block nennt, nicht an der Tabelle, in der sie landet: `/cleaning/cycles`,
nicht `/cleaning_cycles`. Kleinschreibung, Bindestrich, Mehrzahl für eine Menge. Der Pfadname folgt
dem englischen Bezeichner des Schemas — dieselbe Sprachregel wie dort.

`[A]` Kein Versionssegment im Pfad. — Alternative: `/v1/…` von Anfang an; Preis: ein Präfix, das
heute nichts trennt, und der zweite Satz Pfade, sobald jemand es ernst nimmt. Ein Bruch bekommt
später einen neuen Pfad an der Stelle, an der er bricht.

Ein Vorgang, der einer Familie gehört, trägt sie im Pfad (`/cleaning/families/{family_id}/…`) — auch
für die Eltern selbst, die sie aus ihrem Token ableiten könnten. Das ist die Bauform des
[offiziellen Umwegs](#der-offizielle-umweg) und die Voraussetzung des Ownership-Checks unten.

## Wer darf, und worauf eingeschränkt

Zwei Prüfungen, nie eine (`idea/04-identitaet-zugriff.md`, `wb-backend/CLAUDE.md` §6):

- **Rolle je Route** — die `code`s aus `roles`, für Eltern der OTP-Scope.
- **Ownership je Datensatz** — in der Query, nicht davor. Eine korrekte Rollenprüfung allein lässt
  jeden Elternteil die Familie jeder anderen lesen, sobald er eine ID rät.

`family_id` aus dem Pfad wird gegen die Familien des Tokens geprüft (`family_guardians` →
`families`), nie übernommen. **Die Familienauswahl in der Oberfläche ist Bedienführung, keine
Sicherheitsgrenze** (`idea/04-identitaet-zugriff.md`) — bei Patchwork umfasst der Scope alle
Familien der Person, und die Route prüft gegen diese Menge.

Listen- und Exportrouten kennen keinen Ownership-Check und gehen deshalb **nie** über den OTP-Pfad
(`idea/04-identitaet-zugriff.md`, „Bulk-Zugriff"): Sie stehen ausschließlich internen Rollen offen.

## Einsichtsstufe

Sie hängt an der Person, nicht am Feld (`hebel.md`), und wirkt deshalb an **einer** Stelle: bei der
Auflösung Token → handelnde Person → Familien. Keine Route filtert sie ein zweites Mal.

`[A]` **gesperrt** sieht keinen Vorgang der Familie und handelt in keinem — für ihn ist die Familie
leer, nicht verboten; **nur lesen** sieht jede Ansicht, ruft aber keine schreibende Route. —
Alternative: die Stufe je Route auswerten; Preis: sie steht dann an dreißig Stellen und fehlt an
einer.

## Fehler

| Status | Wofür |
|---|---|
| `400` | Die Anfrage passt nicht zum Zustand: Fenster geschlossen, Frist abgelaufen, Platz weg |
| `403` | Die Rolle darf diese Handlung nicht — nur, wo die Existenz der Sache ohnehin bekannt ist |
| `404` | Gibt es nicht **oder** gehört nicht dir |
| `409` | Zwei gleichzeitige Schreiber auf dieselbe Sache |
| `422` | Der Rumpf ist unlesbar (FastAPI-Vorgabe, nicht selbst gebaut) |

**„Nicht gefunden" und „nicht erlaubt" antworten gleich**, wo die Unterscheidung eine Auskunft wäre:
Wer eine fremde `family_id` rät, erfährt aus `403` statt `404`, dass es sie gibt. Dasselbe Prinzip
trägt schon das Anmeldefeld, das auf jede Adresse gleich antwortet
([`hebel.md`](../soll-prozesse/hebel.md#zugang-und-anmeldecode)).

## Liste

Eine Liste liefert ihren vollständigen Bestand. `[A]` Keine Seitenzahl, kein Cursor. — Alternative:
Paginierung von Anfang an; Preis: jede Liste bekommt zwei Parameter und jeder Aufrufer eine
Schleife, für Bestände in der Größe eines Putzdienstjahres.

Eine [frisch erzeugte Liste](../soll-prozesse/hebel.md#frisch-erzeugte-liste) ist eine **Route**,
kein Bestand: `GET`, immer aus dem aktuellen Stand gerechnet, nirgends gespeichert, nichts
aufzuräumen. Wer sie ausdruckt, hält Papier in der Hand, das ab dem Druck veralten darf — maßgeblich
ist der Bildschirm.

## Schreiben

Jede schreibende Route läuft durch die Schreibschicht (`wb-backend/README.md`, „Writing data"): eine
Transaktion je Anfrage, `app.actor` darin gesetzt, `change_log` aus den Session-Events. Daraus folgt
für den Plan, nicht erst für den Bau:

- **Der Aktor steht je Route**, in der Form der `created_by`-CHECKs des Schemas: `entra:` für eine
  Mitarbeiterrolle, `guardian:` für den OTP-Pfad, `system:` für einen Lauf.
- **Keine Massenoperation.** Die Schicht weist `update()`/`delete()` über eine Menge ab. Eine Route,
  die „alle … auf einmal setzen" heißt, lädt die Zeilen und ändert sie einzeln — oder ist noch nicht
  zu Ende gedacht.
- **Ein Vorgang ist eine Route.** Was ein Block als einen Schritt beschreibt, entsteht in einer
  Transaktion, auch wenn es fünf Tabellen berührt. Wer die Tabellen einzeln freilegt, verlagert den
  Ablauf ins Frontend, und dann gibt es ihn zweimal.

## Sofortzahlung

Drei Vorgänge werden sofort bezahlt ([`hebel.md`](../soll-prozesse/hebel.md#sofortzahlung)). Der Weg
ist für alle drei derselbe und steht deshalb hier:

1. **Der Elternteil ruft die Route seines Vorgangs**, nicht eine Zahlungsroute. Sie legt nichts an,
   sondern prüft und eröffnet die Zahlungssitzung; zurück kommt die Adresse, zu der die Oberfläche
   weiterschickt.
2. **Der Zahlungsdienst ruft die Bestätigungsroute** — `POST /payments/callback`, eine für alle drei
   Anlässe. Sie ist der einzige Ort, an dem `payments` und der bezahlte Vorgang entstehen, in
   **einer** Transaktion, Aktor `system:payments`.

**Der Vorgang entsteht mit der bestätigten Zahlung, nicht mit der Rückkehr des Browsers.** Wer das
verwechselt, verliert bei jedem Abbruch das Geld und den Vorgang. Die Rückkehr-Adresse zeigt deshalb
auf eine Ansicht, die den Stand liest, und löst nichts aus.

`[A]` Zwischen Schritt 1 und 2 steht **nichts in der Datenbank**; was gekauft wird, trägt die
Zahlungssitzung als Metadaten. — Alternative: eine Vormerkzeile mit Status `pending`; Preis: ein
Zustand, den kein Block kennt, plus ein Lauf, der ihn aufräumt — und `hebel.md` zählt abschließend
auf, was von selbst verfällt.

## Der offizielle Umweg

`[A]` **Dieselbe Route, andere Rolle** — keine zweite Route je Elternhandlung. — Alternative: je
Elternroute ein Sekretariats-Gegenstück; Preis: jede Regel steht zweimal und läuft beim ersten Fix
auseinander.

Das trägt, weil die Familie ohnehin im Pfad steht: Für den Elternteil prüft der Ownership-Check sie
gegen sein Token, für das Sekretariat entfällt der Check. Was sich außer der Rolle unterscheidet —
Fristen, die für die Eltern gelten und für das Sekretariat nicht, eine Mail, die nur beim
stellvertretenden Eintrag rausgeht —, steht als Bedingung an der Route und nicht in einem zweiten
Pfad. Die beiden Ausnahmen des Hebels gelten unverändert: keine Bewerbung stellvertretend, und
**keine Freigabe, für die jemand zeichnet**.

## Was keine Route ist

Ein **Lauf** ist keine Route: Was zu einem Zeitpunkt von selbst geschieht — eine Mail, wenn ein
Fenster aufgeht, die Zuteilung, wenn es schließt, der Monatslauf am 1. —, hat keinen Aufrufer und
bekommt keinen Endpunkt, der ihn von außen auslösbar machte. Er läuft unter `system:<job>` und steht
in der Domänendatei als Zeile mit seinem Auslöser, damit die Gegenprobe ihn sieht.
