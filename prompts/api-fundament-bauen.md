# Prompt: die zwei Fundament-Domänen bauen

Ein Durchgang über `stammdaten` und `querschnitt`. Es gilt [`api-bauen.md`](api-bauen.md)
vollständig — der Plan als Spezifikation, die fünf Regeln, die Reihenfolge, die Gegenprobe, der
Beleg am Ende — und diese Datei wiederholt nichts davon. Sie trägt vier Dinge, die dort nicht
stehen: warum diese zwei einen gemeinsamen Lauf bekommen, was hier **nicht** zu bauen ist, was
zusätzlich zu lesen ist, und die Prüfung, die diesen Lauf von einem gewöhnlichen unterscheidet.

Gearbeitet wird **in einer `wb-backend`-Session**, nicht hier.

Kopieren, absenden. Effort `xhigh`, Thinking an. Vorher `git status` sauber, der Stack oben.

**Dieser Durchgang läuft ohne Rückfrage** — was das heißt, steht in [`gemeinsam.md`](gemeinsam.md).

---

## Warum diese zwei zusammen, und trotzdem nacheinander

Sie sind das Fundament in einem Sinn, den keine andere Domäne teilt: **`stammdaten` trägt die
Ownership-Bedingung, gegen die jede andere Route prüft**, und **`querschnitt` trägt die Zeilen, die
jede andere Route mitschreibt**. Wer eine der beiden allein baut, baut die Auflösung Sitzung →
handelnde Person → Familien ein zweites Mal oder schreibt die Aufgabe an der Schreibseite vorbei.

Die Portionierung aus [`api-bauen.md`](api-bauen.md) bleibt: **erst `stammdaten` ganz, dann
`querschnitt` ganz**, ein Commit je Domäne. Die Reihenfolge steht fest, weil der Querschnitt an
`persons`, `children` und `families` hängt und nicht umgekehrt.

**Eine Verschränkung durchbricht sie, und sie ist der Grund für diese Datei.** Sechs Routen aus
`api/stammdaten-api.md` schreiben Querschnittszeilen **in derselben Transaktion**:

| Route | schreibt zusätzlich |
|---|---|
| `PUT /children/{child_id}/departure` | die ganze Abgangsliste als `sync_tasks` |
| `DELETE /children/{child_id}/departure` | streicht die offenen davon |
| `PATCH /children/{child_id}` | die Nachzieh-Aufgaben je Fremdsystem |
| `PUT /children/{child_id}/class` | zwei Aufgaben, ASV-BW und M365 |
| `PUT /employees/{employee_id}/account`, `PUT /children/{child_id}/school-email` | haken eine offene M365-Aufgabe ab |
| `POST /employees` | die Aufgabe, das Konto anzulegen |

Daraus folgt die einzige Abweichung von der Reihenfolge: **Die Schreibseite der Aufgabe entsteht vor
`stammdaten`, ihre zwei Routen danach mit dem Querschnitt.** Sie geht in den ersten Commit, obwohl
sie dem Querschnitt gehört — sonst ist der erste Commit nicht lauffähig —, und der zweite nennt sie
nicht noch einmal. Wer sie erst mit dem Querschnitt baut, hat sie in `stammdaten` sechsmal von Hand
nachgebaut, und die sechs laufen beim ersten Fix auseinander.

Ergibt der zweite Durchgang, dass der erste falsch lag, **wird der erste geändert** — Code wie Plan,
und beides im selben Commit wie das, was ihn widerlegt.

## Was hier nicht zu bauen ist

**Die Schritte 1 und 2 aus [`api-bauen.md`](api-bauen.md) entfallen.** Beide Domänen haben ihre
Modelle, ihre Migration und ihre Tabellenrechte, und beide sind durch fünf Prüfzyklen gegangen. Es
entsteht in diesem Lauf **keine neue Tabelle und keine neue Spalte.**

**Wer hier eine Migration anfasst, ändert die Grundlage von zwölf anderen Domänen.** Die Ausnahme aus
[`api-bauen.md`](api-bauen.md) gilt unverändert — eine Route, die ohne die Änderung nicht baubar ist,
bekommt sie —, aber sie ist hier teurer als überall sonst, und `wb-docs/schema/` samt Prüfskript,
Kopfkommentar und `grenzkarte.md` wird im selben Lauf nachgezogen.

**Was am Schema auffällt, steht schon.** Beide Pläne tragen einen Abschnitt „Am Schema aufgefallen"
mit neun Funden — darunter, dass `documents` je Kind und Typ nicht eindeutig ist und dass
`change_log` für die Laufzeit-Rolle kein `UPDATE` und kein `DELETE` hat. Sie sind gelesen und
entschieden; wer sie noch einmal meldet, meldet nichts.

## Was du zusätzlich liest

Zu dem, was [`api-bauen.md`](api-bauen.md) verlangt, kommen vier Punkte:

1. **Beide Pläne, und zwar zusammen** — `api/stammdaten-api.md` und `api/querschnitt-api.md`. Die
   Tabelle oben steht in beiden nur je zur Hälfte.
2. **`app/routers/auth.py` und `app/routers/payments.py`** — **sieben der 68 geplanten Routen sind
   gebaut**, fünf in `stammdaten` und zwei in `querschnitt`. Dieser Lauf fängt nicht bei null an: Er
   hält sie gegen den Plan und schließt jede Abweichung, im Code oder im Plan. `GET /health` steht in
   keinem Plan und gehört in keinen — es ist der Healthcheck des Containers (`container.md`).
3. **`app/routers/cleaning.py`** — die einzige gebaute Fachdomäne und damit die Form, an der diese
   abschreiben. `CLAUDE.md` §14 gilt dabei ungebremst, siehe unten.
4. **`app/db/changelog.py`, `app/db/base.py` und `app/core/security.py`** — `__change_anchor__`,
   `__protected_columns__`, `narrow_role()` und die Auflösung beider Türen. Hier und nirgends sonst
   entscheidet sich, ob die enge Rolle `backend_sensitive` an den zwei lesenden Stammdatenrouten
   greift, die Konfession und Kirchengemeinde zeigen.

Dazu die `value_list_seed`-Migration für die `code`s, die die Routen im Pfad und in der Rollenspalte
nennen (`roles`, `access_levels`, `sync_targets`, `consent_purposes`, `document_types`) — ein Code,
den es dort nicht gibt, ist ein Endpunkt, der nie antwortet.

## Fundament heißt nicht Framework

Der Satz, ohne den dieser Lauf das Gegenteil bewirkt: **`CLAUDE.md` §14 gilt hier ungebremst.** Weil
diese zwei Domänen das Fundament sind, sieht in ihnen alles nach einem gemeinsamen Baustein aus — und
genau deshalb ist die Grenze hier zu ziehen und nicht später.

**Zwei Verallgemeinerungen sind verlangt, und beide stehen im Plan:**

- die Auflösung **Sitzung → handelnde Person → Familien**, an einer Stelle, samt der
  [Einsichtsstufe](../soll-prozesse/hebel.md#einsichtsstufe) ([`api/gemeinsam.md`](../api/gemeinsam.md));
- die **Schreibseite der Aufgabe**, weil eine Aufgabe nie über eine Route entsteht
  ([`api/querschnitt-api.md`](../api/querschnitt-api.md)).

Alles Übrige schreibt ab. Kein Basis-Router, keine gemeinsame Antwortform, kein Ownership-Dekorator
über drei Ressourcenarten: **Der zweite Fall darf abschreiben, erst der dritte darf
verallgemeinern** — und `cleaning.py` war der erste.

## Die Prüfung, und sie ist die halbe Arbeit

Nicht am Ende, sondern je Domäne, bevor du sie für fertig erklärst. Drei Durchgänge, jeder mechanisch
und keiner aus dem Gedächtnis.

### Gegen den gebauten Bestand

Je vorhandenem Endpunkt eine Zeile und genau eine von drei Antworten:

- **deckt die Planzeile** — Methode, Pfad, Rolle und Ownership-Bedingung stimmen überein;
- **weicht ab** — dann steht dabei, ob der Code oder der Plan geändert wird, und warum;
- **fehlt im Plan** — dann wird er in den Plan geschrieben, mit der Begründung, warum er dort fehlte.

Die Richtung zurück ist die Gegenprobe aus [`api-bauen.md`](api-bauen.md) und wird nicht ersetzt:
Jede Planzeile existiert danach im Router.

### Gegen die Transaktionsgrenze

Für **jede** Route, deren Plan „in einer Transaktion", „legt … an" oder „hakt … ab" sagt, ein Test,
der beweist, dass ein Abbruch **nichts** hinterlässt — nicht die halbe Abgangsliste, nicht die
Aufgabe ohne die Änderung, die sie auslöst. Das ist die Falle dieser zwei Domänen: Die Tabelle oben
zählt sieben solche Routen, und jede schreibt über die Domänengrenze.

`POST /payments/callback` ist der Grenzfall und braucht seinen eigenen Test: Die zweite Zustellung
desselben Ereignisses darf den Vorgang nicht ein zweites Mal anlegen **und muss trotzdem 2xx
antworten** — die Route fängt den Schlüsselfehler, rollt zurück und meldet Erfolg
([`api/gemeinsam.md`](../api/gemeinsam.md)).

### Gegen den Ownership-Check, von der anderen Seite

[`api-bauen.md`](api-bauen.md) verlangt je Route einen Test auf die Ownership-Bedingung. Hier kommt
die Gegenrichtung dazu, und sie ist die eigentliche Prüfung dieses Laufs: **Es gibt genau eine
Auflösung, und keine Route baut sie nach.** Zwei Belege, beide mechanisch:

- Je Ressourcenart ein Test, in dem ein Berechtigter eine fremde Id rät — `family_id`, `child_id`,
  `person_id`, `employee_id`, `phone_number_id`, `family_contact_id`, `sync_task_id`,
  `document_id` — und `404` bekommt, nicht `403`: „nicht gefunden" und „nicht erlaubt" antworten
  gleich, wo die Unterscheidung eine Auskunft wäre.
- Eine Suche über beide Router nach einer zweiten Stelle, die `family_guardians` selbst joint. Findet
  sie eine, ist die Auflösung zweimal gebaut, und die zweite Fassung ist die, die beim nächsten Fix
  stehen bleibt.

Dazu die eine Bedingung, die keine Query trägt und deshalb an der Route steht: **die letzte
Admin-Rolle lässt sich nicht entziehen** (`PUT /employees/{employee_id}/roles`). Sie zählt über alle
Zeilen und ist ausdrücklich kein Constraint (`schema/stammdaten-schema.sql`) — ohne ihren Test ist
sie nicht gebaut.

## Was du am Ende lieferst

Was [`api-bauen.md`](api-bauen.md) verlangt, je Domäne einmal, dazu je Domäne die drei Prüfungen als
drei Listen — Bestandsabgleich, Transaktionstests, Ownership-Belege —, jede Zeile mit ihrer
Entscheidung. Eine leere Liste schreibst du als leere Liste hin.

Dazu drei Dinge, die für diesen Lauf gelten:

- **Zwei Commits, ein Pull Request.** Gemeinsam ist der Lauf, nicht der Commit — aber ein Fundament,
  dessen zweite Hälfte noch offen ist, ist keines, und `ci` soll beide zusammen fahren.
- **Der Replay-Rhythmus im Bericht.** Die Datenbank wird in diesem Lauf mehrfach neu abgespielt; die
  lokale Personal-Anmeldung hängt an einer Zeile, die das nicht überlebt (`wb-backend/README.md`,
  „seed, work, test, seed"). Wer sie vergisst, sucht den Fehler in `security.py`.
- **Die dreizehn Prüfskripte mit ihrem Rückgabewert**, gegen die neu abgespielte Datenbank — auch
  wenn dieser Lauf keine Tabelle anfasst. Genau das ist die Aussage.

## Was nicht in diesen Durchgang gehört

Alles aus [`api-bauen.md`](api-bauen.md), dazu:

- **Keine dritte Domäne**, auch keine, die nur zwei Routen bräuchte. Die zwei hier tragen 68.
- **Keine Migration ohne blockierte Route**, siehe oben.
- **Keine Antwort auf eine offene `[?]`.** Beide Pläne führen fünf, alle an ihrer Stelle in den
  Blöcken; der Bau beantwortet keine davon und baut auch nichts auf Verdacht, das von einer abhinge.
