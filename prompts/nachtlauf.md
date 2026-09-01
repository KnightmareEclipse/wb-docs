# Nachtlauf — drei Warteschlangen in einer Nacht

Ein Lauf ohne Aufsicht, eine Session. `prompts/gemeinsam.md` gilt vollständig, samt „Ein Lauf ohne
Rückfrage" — hier steht nur, was diese Nacht zusätzlich braucht.

**Modell und Aufwand:** Claude Fable 5.1, `effort: high`. Lange autonome Läufe sind das, wofür es
gebaut ist; `xhigh` nur für die Backend-Kette, wenn sie hakt.

**Warum das hier gebraucht wird** — das gehört an den Anfang, weil es die Arbeit besser macht als
jede Schrittanweisung: Aus der Schule kommen gerade die Entscheidungen zurück, aus denen die
Fachdomänen entstehen. Der Entwurf am Morgen geht an einen Gestalter, der einen Tag lang darauf
schaut; die Backend-Kette bringt eine Domäne auf den Stand, den das Schema schon hat. Beides ist
Vorarbeit für einen Betrieb, der auf Papier und sechs Formularen läuft.

---

## Drei Warteschlangen, in dieser Reihenfolge

A hat morgens einen Leser, B nicht, C ist Zugabe. Scheitert eine, laufen die anderen trotzdem — sie
teilen kein Repo und keine Datei.

### A · Drei Entwürfe fürs Elternportal (`wb-elternportal`)

**Ziel:** Morgens liegen drei anklickbare Ansichten da, zu denen Corrado etwas sagen kann. Dieselben
drei Bildschirme je Variante, sonst ist nichts vergleichbar: die Startseite nach der Anmeldung, die
Buchungsstrecke des Putzdienstes ([01](../soll-prozesse/01-putzdienst.md)), die Ferienbuchung mit
mehreren Kindern ([10](../soll-prozesse/10-ferienprogramm.md)).

Der Rahmen, in dem du frei bist:

- **Eine Palette für alle drei** — die Werte aus TASK-151, unverändert. Sie sind gegen sechs Regeln
  gerechnet; eine über Nacht erfundene Farbe wirft diese Arbeit weg. Die Varianten unterscheiden
  sich in Layout, Dichte und Führung.
- **Keine neue Abhängigkeit.** React Aria und die Token stehen in `oberflaechen.md`.
- **Barrierefreiheit ist die Bauweise**, keine Zutat: WCAG 2.1 AA (TASK-118).
- **Nichts erfinden.** Texte, Beträge und Fristen stehen in den Blöcken und in `hebel.md`; was dort
  fehlt, steht sichtbar als `[Platzhalter]` in der Ansicht.
- **Name, Wortmarke und Adressen gehören nicht dir** — sie sind nach außen sichtbar (TASK-188).

Je Variante ein Commit und drei Zeilen, was sie anders macht. Drei Zeilen, kein Diff: Das ist, was
ein Gestalter liest.

### B · Die Gesundheits-Kette (`wb-backend`)

**Ziel:** Die Domäne steht auf dem Stand, den `schema/gesundheit-schema.sql` beschreibt, und die
Tests belegen es. Die Tickets **TASK-153, 154, 155, 156, 158, 159** tragen je ihren Auftrag; die
Reihenfolge ergibt sich aus ihnen.

- **Keine neue Alembic-Revision** — die Ursprungsrevision wird überschrieben (`CLAUDE.md`).
- **TASK-157 bleibt liegen.** Die Sichtkreise per RLS durchzusetzen ist ein Urteil, und Urteile
  fallen nicht nachts.
- **Ein Ticket, das blockiert, wird notiert und übersprungen** — Grund in die Implementation Notes,
  dann das nächste.

### C · Nur, wenn noch Nacht übrig ist

Erst anfangen, wenn B durch ist — nicht parallel, nicht angefangen und liegengelassen. In dieser
Reihenfolge, und jedes für sich abgeschlossen:

1. **Der Elternbonus-Umbau** — TASK-164, 165, 166. Dieselbe Form wie B: entschieden, mit Tests als
   Signal, und die Bestätigung fällt ersatzlos weg. Der Trigger für die Platzzahl gehört in TASK-165
   und ist der einzige Punkt, an dem es klemmen kann.
2. **TASK-192** — Mandat und Fotoeinverständnis als eigene Dateien. Klein, entschieden, prüfbar.
3. **TASK-191** — die Voranmeldungen als Liste zum Herunterladen.

**Was nicht in die Nacht gehört, auch wenn Zeit bleibt:** ein neues Schema. Die Akademie
(TASK-176) ist eine ganze Domäne, und beim Schema kostet eine Lücke einen Abnahmezyklus statt eines
Refactorings (`CLAUDE.md`). Das wird bei Tageslicht entschieden.

---

## Wie du dabei arbeitest

Fünf Sätze, die für einen unbeaufsichtigten Lauf gelten und sonst nicht:

- **Du arbeitest autonom.** Niemand liest mit, niemand kann eine Frage beantworten. Bevor du eine
  Antwort beendest, sieh dir deinen letzten Absatz an: Ist er ein Plan, eine Frage, eine Liste
  nächster Schritte oder ein Versprechen („ich werde jetzt…"), dann tu die Arbeit jetzt, statt sie
  anzukündigen.
- **Kein Fortschritt ohne Beleg.** Bevor du schreibst, etwas sei fertig, prüfe die Behauptung gegen
  ein Werkzeugergebnis aus dieser Session. Was nicht belegt ist, wird als unbelegt benannt —
  scheitert ein Test, steht seine Ausgabe da.
- **Der Kontext reicht.** Hör nicht auf, fasse nicht zusammen und schlage keine neue Session vor,
  weil du glaubst, der Platz werde knapp.
- **Nichts aufräumen, was nicht beauftragt ist.** Keine Refaktorierung nebenbei, keine Abstraktion
  für einen Fall, den es nicht gibt, keine Fehlerbehandlung für Unmögliches.
- **Der Bericht am Morgen ist kein Weiterreden.** Er ist das Erste, was ich von der Nacht sehe:
  zuerst das Ergebnis in einem Satz, dann das Nötige, jeder Begriff so, als hätte ich ihn nie
  gehört. Die Abkürzungen, die du dir nachts gebaut hast, bleiben in der Nacht.

## Subagenten — hier ausdrücklich anders als sonst

`prompts/gemeinsam.md` sagt „Kein Subagent urteilt". **Für diesen Lauf gilt das nicht**, und der
Grund ist der Unterschied der Arbeit: Die Regel dort schützt das Prüfen von Prosa, wo ein
zusammengefasster Bericht den Satz verliert, gegen den das Zitat gehalten wird. Hier wird gegen
Tests und ein geschriebenes Abnahmekriterium geprüft — das Urteil ist grün oder rot und trägt seinen
Beleg mit.

- **Delegiere unabhängige Teilaufgaben und arbeite weiter, während sie laufen.** Die drei Varianten
  aus A sind drei solche Aufgaben; greif ein, wenn eine abdriftet oder ihr Zusammenhang fehlt.
- **Prüfen lässt du prüfen.** Nach jedem Ticket aus B schickst du einen Subagenten mit **frischem
  Kontext** gegen das Gebaute — die Abnahmekriterien des Tickets und `schema/gesundheit-schema.sql`
  in der Hand. Ein frischer Blick findet mehr als Selbstkritik: Du hast beim Bauen entschieden und
  wirst dieselbe Entscheidung beim Nachlesen wieder für richtig halten.
- **Bau dir eine Prüfmethode und lauf sie regelmäßig**, nicht erst am Ende.

Der große Prüflauf gegen die fertige Domäne bleibt trotzdem Tagarbeit in einer frischen Session
(`CLAUDE.md`) — was hier nachts läuft, ist die Gegenprobe je Ticket, nicht sein Ersatz.

## Wann Schluss ist

- Wenn C durch ist, oder die Nacht vorbei — **aber nie mitten in einem Ticket**. Lieber eines
  weniger angefangen als zwei halb fertig: Was morgens halb dasteht, kostet mich mehr Zeit als es
  gespart hat.
- Wenn ein Ticket **zweimal am selben Punkt** scheitert. Der dritte Versuch findet nichts Neues.
- **Kein Deploy, keine Produktiv-Datenbank, kein `push --force`.** Entwickelt wird lokal.

## Was morgens dasteht

Drei Ansichten mit dem Pfad zum Öffnen · die `[A]` als `A1, A2 …` · die `[?]` mit ihren Adressaten ·
je Ticket der grüne Testlauf oder der Satz, warum es liegen blieb.
