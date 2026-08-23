# Prompt: eine Fachdomäne zur API planen

Gegenstück zu [`prompts/schema-bauen.md`](schema-bauen.md). Dort wird aus den Blöcken das
Datenmodell, hier werden aus denselben Blöcken die Routen. **Eine Domäne je Durchgang**, dieselbe
Portionierung wie beim Schema. Gebaut wird danach in `wb-backend` — dieser Lauf schreibt keinen
Code.

Kopieren, `DOMÄNE` ersetzen, absenden. Effort `high`, beim ersten Durchgang und bei einer Domäne mit
vielen Berührungspunkten `xhigh`; Thinking anlassen. Vorher `git status` sauber. Alles unter dem
Strich ist der Prompt.

---

Wir planen die API der Fachdomäne **DOMÄNE**. Ergebnis ist `api/DOMÄNE-api.md`: die Liste der
Routen, je Route wer sie rufen darf, worauf sie eingeschränkt ist und aus welcher Zeile welches
Blocks sie kommt. Nur diese Domäne. Kein Code, keine Pydantic-Modelle, kein OpenAPI-Dokument.

Es gelten [`gemeinsam.md`](gemeinsam.md) (die `[A]`-Marke, wie du fragst, wie du mit mir redest,
kein Subagent urteilt) und `CLAUDE.md`. Beides liest du zuerst und ich wiederhole es hier nicht.

## Die eine Regel, aus der der Rest folgt

**Eine Route entsteht aus einer Handlung, nie aus einer Tabelle.** Das Schema hat hundert
Tabellen; es hat nicht hundert Ressourcen. Wo du eine Route nicht auf eine Zeile in der
Ablauftabelle eines Blocks zurückführen kannst, gibt es sie nicht — und wo eine Zeile dort keine
Route hat, fehlt eine. Beides prüfst du am Ende in beide Richtungen.

Daraus folgt der häufigste Fehler, den dieser Prompt verhindern soll: **CRUD je Tabelle**. Ein
Hortvertrag entsteht nicht als `POST /contracts` plus `POST /care_module_agreements` plus fünfmal
`POST /care_module_bookings`, sondern als **ein** Absenden, das alles davon in einer Transaktion
anlegt — so, wie es in Block 09 als ein Schritt steht. Wer die Tabellen einzeln freilegt, verlagert
den Ablauf ins Frontend, und dann gibt es ihn zweimal.

## Was du vorher liest, und wozu

1. **Alle Blöcke in `soll-prozesse/`, die diese Domäne berühren** — vollständig. Die Ablauftabelle
   ist die Routenliste, die Spalte „danach steht fest" sagt, was die Route zurückgibt.
2. **`soll-prozesse/hebel.md`** — Rollen, Einsichtsstufe, sparsame Ansicht, Nachzieh-Aufgabe,
   Sofortzahlung, der offizielle Umweg. Jeder dieser Hebel schlägt auf jede Route durch, und ein
   Hebel, den die API je Route nachbaut statt einmal, ist der Anfang von zwei Fassungen.
3. **`schema/<domäne>-schema.sql` samt Kommentaren** — was gespeichert wird und warum. Die Route
   folgt daraus nicht, aber sie darf nichts versprechen, was dort nicht steht.
4. **`idea/04-identitaet-zugriff.md`** und **`glossar.md`** — wer wie hereinkommt und wie die Rollen
   heißen. Die Rollen stehen inzwischen als Zeilen in `roles` (`wb-backend`, „value list seed"); die
   `code`-Spalte ist der Name, den eine Route nennt.
5. **`wb-backend/CLAUDE.md`** §3, §6, §7 und `wb-backend/README.md`, Abschnitt „Writing data" — die
   Form, in die dein Plan später gegossen wird. Für den Inhalt gilt sie nie.

**Punkt 1 bis 5 liest du selbst** — aus dem Grund, der in `gemeinsam.md` steht.

## Der erste Durchgang legt `api/gemeinsam.md` an

Existiert die Datei noch nicht, ist sie der erste Teil deiner Arbeit und der kleinere. Danach wird
sie nur noch gelesen. Sie trägt, was für **alle** Routen gilt, und genau einmal — dieselbe Mechanik
wie `soll-prozesse/hebel.md`, und eine Domänendatei schreibt nur, wo sie davon abweicht:

- **Wie ein Pfad aussieht** und woran er hängt: an der Sache, die der Block nennt, nicht an der
  Tabelle, in der sie landet.
- **Wie ein Fehler aussieht** — welcher Status wofür, und dass „nicht gefunden" und „nicht erlaubt"
  aus demselben Grund gleich antworten, wo eine Auskunft eine Auskunft wäre.
- **Wie eine Liste aussieht**, und dass eine [frisch erzeugte Liste](../soll-prozesse/hebel.md#frisch-erzeugte-liste)
  eine Route ist und kein Bestand.
- **Wie die Einsichtsstufe wirkt** — sie hängt an der Person und nicht am Feld, also filtert genau
  eine Stelle und nicht jede Route für sich.
- **Wie die Sofortzahlung läuft:** Der Vorgang entsteht mit der **bestätigten** Zahlung, nicht mit
  der Rückkehr des Browsers (`hebel.md`). Das ist eine Route, die der Zahlungsdienst ruft, und keine,
  die der Elternteil ruft — wer das verwechselt, verliert bei jedem Abbruch das Geld und den Vorgang.
- **Wie der [offizielle Umweg](../soll-prozesse/hebel.md#der-offizielle-umweg) aussieht:** Fast jede
  Elternroute hat ein Gegenstück, das das Sekretariat stellvertretend ruft. Ob das dieselbe Route mit
  anderer Rolle ist oder eine zweite, wird hier **einmal** entschieden und nicht je Domäne neu.

## Je Route sechs Angaben, und keine davon ist optional

| | |
|---|---|
| **Handlung** | Methode und Pfad, dazu ein Halbsatz, was sie tut |
| **Herkunft** | Block und Zeile der Ablauftabelle, aus der sie kommt — mit Link |
| **Wer darf** | die `code`s aus `roles`, oder „Erziehungsberechtigte" für den OTP-Pfad |
| **Worauf eingeschränkt** | der Ownership-Check als Bedingung, nicht als Wort: „nur Kinder der eigenen Familie", „nur die eigene Schulform" |
| **Schreibt oder liest** | und bei schreibend: welcher Aktor (`entra:`, `guardian:`, `system:`) |
| **Enge Rolle** | keine, oder welche — Art.-9-Spalten und die Bankverbindung liegen hinter eigenen DB-Rollen (`glossar.md`, `wb-backend/README.md`) |

**Der Ownership-Check ist keine Wiederholung der Rolle.** Eine korrekte Rollenprüfung allein lässt
jeden Elternteil die Kinder jeder Familie lesen, sobald er eine ID rät (`wb-backend/CLAUDE.md` §6).
Wo eine Route für eine Rolle wirklich unbeschränkt ist — Sekretariat, Geschäftsführung, Buchhaltung
sehen alle Kinder —, schreibst du das hin, statt die Spalte leer zu lassen.

## Sieben Fallen, jede in diesem Haus schon angelegt

1. **Eine Route schreibt an der Schreibschicht vorbei.** Es gibt keinen zweiten Weg in die
   Datenbank; Massenoperationen weist die Schicht ab. Eine Route, deren Plan „alle … auf einmal
   setzen" heißt, ist damit noch nicht gebaut, sondern noch nicht zu Ende gedacht.
2. **Ein Vorgang wird in seine Tabellen zerlegt.** Siehe oben. Prüf jede Route mit der Frage: Kann
   ein Abbruch nach der Hälfte einen Zustand hinterlassen, den kein Block kennt?
3. **Die sparsame Ansicht fehlt.** Was das Portal einer Familie nach der Freigabe des ersten
   Vertrags nicht mehr zeigt, darf die Route auch nicht mehr liefern (`hebel.md`) — sonst ist der
   Hebel eine Frontend-Verabredung und keine Grenze.
4. **Eine Bestätigung wird zur Auskunft.** Das Anmeldefeld antwortet auf jede Adresse gleich, der
   Dublettenabgleich meldet nie zurück, die Position auf der Warteliste sieht niemand. Prüf jede
   Antwort daraufhin, was sie einem verrät, der sie nicht bekommen sollte.
5. **Eine Q5-Aufgabe hat keine Route.** Abhaken ist eine Handlung, „erledigt" und „war nichts zu
   tun" sind zwei, und die Wochenmail liest denselben Bestand. Wer die Aufgaben nur entstehen lässt,
   baut eine Liste, die niemand schließen kann.
6. **Eine Route gibt es doppelt.** Zwei Blöcke beschreiben oft dieselbe Handlung aus zwei Sichten.
   Entscheide, welchem Block sie gehört, und verweise aus dem anderen.
7. **Eine Route für eine Domäne ohne Tabellen.** AGs, M365-Kontenverwaltung, Eltern-Selfservice und
   Klassenbildung haben keine eigenen Tabellen, und das ist ihr Ergebnis (`grenzkarte.md`). Was dort
   an Routen entsteht, gehört der Domäne, der die Daten gehören.

## Die Gegenprobe, und sie gehört zur Aufgabe

**In beide Richtungen, mechanisch, nicht aus dem Gedächtnis:**

1. Jede Zeile der Ablauftabelle jedes berührten Blocks, in der eine Partei **im System** handelt,
   hat eine Route. Zeilen, in denen ein Mensch außerhalb handelt, tragen stattdessen einen Satz,
   warum es keine gibt.
2. Jede Route nennt ihre Blockzeile. Eine ohne ist zu streichen oder zu begründen.

Zähl beides aus und schreib die zwei Zahlen in den Kopf der Datei. Weichen sie ab, steht darunter je
Abweichung eine Zeile.

## Was du am Ende lieferst

- **Die Datei** `api/DOMÄNE-api.md` (und beim ersten Durchgang `api/gemeinsam.md`), erst nach
  meinem OK angelegt — der Entwurf steht bis dahin in deiner Antwort.
- **Die zwei Zahlen der Gegenprobe** und die Abweichungen.
- **Die Annahmen** `A1, A2 …`, jede außerdem als `[A]`-Zeile an ihrer Stelle.
- **Die Fragen** `?1, ?2 …` mit Adressat, sofern der Wortlaut nach `fragen.md` gehört.
- **Was an den Rand stößt**: Routen, die eine andere Domäne bräuchte, in je einer Zeile — benannt,
  nicht mitgeplant.

Beim ersten Durchgang zusätzlich die Zeile für `api/` in der Tabelle „Wo was steht" in `CLAUDE.md`:
ein Verzeichnis, auf das nichts zeigt, wird nicht geöffnet.

## Was nicht in diesen Durchgang gehört

- **Code jeder Art** — Router, Pydantic-Modelle, Migrationen. Das ist der Auftrag danach.
- **Der Schnitt der Frontends.** Welche Oberfläche welche Route ruft, entscheidet dieser Plan nicht.
- **Eine Änderung am Schema.** Fällt dir dort etwas auf, wird es eine Zeile am Ende und kein Eingriff
  — das Schema führt inzwischen `wb-backend` (`CLAUDE.md`).
