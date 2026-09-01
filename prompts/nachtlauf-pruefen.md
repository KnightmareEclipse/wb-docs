# Nachtlauf prüfen — der Morgen danach

Eine **frische Session**, die den Lauf aus `prompts/nachtlauf.md` nicht mitgemacht hat.
`prompts/gemeinsam.md` gilt; hier urteilen **Subagenten nicht** — diese Session ist selbst der
frische Blick, den der Nachtlauf gebraucht hat. Suchen dürfen sie.

**Der Bericht der Nacht ist eine Behauptung, kein Beleg.** Lies ihn zuletzt, nicht zuerst: Was
tatsächlich geschehen ist, steht in Commits, Tests und Dateien. Wer mit dem Bericht anfängt, prüft
nur noch, ob die Welt zu ihm passt.

Die drei Repos: `wb-docs`, `wb-elternportal`, `wb-backend` unter
`~/Documents/projects/weltenbaum/`.

---

## 1 · Was wirklich passiert ist

Je Repo: die Commits seit dem letzten vor der Nacht, der Arbeitsbaum, die Tickets, deren Status sich
geändert hat. **Uncommittete Änderungen sind ein Fund**, kein Detail — der Auftrag verlangte einen
Commit je abgeschlossenem Vorgang; was lose herumliegt, ist abgebrochene Arbeit.

Daraus die Liste, gegen die alles Weitere läuft: **welches Ticket beansprucht, fertig zu sein.**

## 2 · Die Gegenprobe je Ticket

Für jedes Ticket, das auf `Done` steht:

- **Erfüllen die Abnahmekriterien sich wirklich**, oder sind sie nur abgehakt? Jedes Häkchen braucht
  eine Stelle im Code oder in der Datei, auf die du zeigen kannst.
- **Läuft der Test — und kann er rot werden?** Nimm bei zwei, drei Tests die Sicherung heraus: das
  geprüfte Verhalten kaputtmachen, laufen lassen, den roten Lauf sehen, zurücknehmen. Ein grüner
  Test belegt nichts, solange das nicht gezeigt ist (`CLAUDE.md`).
- **Deckt sich das Gebaute mit der Quelle**, die das Ticket nennt — dem Soll-Block, dem Schema, dem
  API-Plan? Nicht ungefähr: an der Stelle, um die es geht.

## 3 · Die drei Fallen einer unbeaufsichtigten Nacht

Gezielt danach suchen, sie melden sich nicht von selbst:

- **Erfundene Inhalte.** In den Entwürfen: jeder Betrag, jede Frist, jeder Vertragstext gegen
  `hebel.md` und den zugehörigen Block. Was dort nicht steht, muss als `[Platzhalter]` markiert
  sein — eine plausible erfundene Zahl ist der teuerste Fund, weil sie niemandem auffällt.
- **Stille Erweiterungen.** Eine neue Abhängigkeit in `package.json`, eine neue Alembic-Revision
  (verboten, `CLAUDE.md`), eine Refaktorierung, die kein Ticket verlangt hat, eine Datei, die
  niemand bestellt hat.
- **Halbe Arbeit als ganze gemeldet.** Ticket auf `Done`, aber ohne Abschlussnotiz; ein
  übersprungenes Ticket ohne notierten Grund; ein Commit, dessen Nachricht mehr behauptet als sein
  Diff hergibt.

## 4 · Laufen die Entwürfe?

Die drei Ansichten müssen sich öffnen lassen — bauen, starten, ansehen. Ein Entwurf, den Corrado
nicht aufbekommt, ist keiner. Dazu die drei Zeilen je Variante: Stehen sie da, und sagen sie
wirklich, was die Variante anders macht?

## 5 · Was liegen blieb

Die übersprungenen Tickets mit ihrem Grund, die `[?]` mit ihren Adressaten, die `[A]`, die jetzt
meine Entscheidung brauchen. Ein `[A]`, das durchgerutscht ist, ist der zweite teure Fund: Es sieht
aus wie eine getroffene Entscheidung.

---

## Was du lieferst

**Nicht reparieren, melden.** Ausnahme wie immer: was im selben Pfad nachweislich kaputt ist, darf
der Diff mitnehmen.

Am Ende drei Listen, je Eintrag eine Zeile:

- **Übernehmen** — belegt fertig, nichts zu tun.
- **Nacharbeiten** — was fehlt, mit dem Ticket, an dem es hängt.
- **Zurückrollen** — was nicht hätte entstehen dürfen, mit dem Commit.

Darunter der Satz, den ich wirklich brauche: **Was von der Nacht kann ich heute benutzen?**
