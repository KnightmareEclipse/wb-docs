# Werkzeuge — womit diese Doku gelesen und bearbeitet wird

Zwei Programme, beide quelloffen, beide lokal. Sie halten keinen eigenen Datenbestand: Was sie
zeigen, sind die Dateien dieses Repos, und Git ist der einzige Weg zwischen zwei Rechnern.

| Werkzeug | wozu | Lizenz |
|---|---|---|
| [Quartz](https://github.com/jackyzha0/quartz) | Lesen, suchen, verstehen — Wiki-Ansicht mit Volltextsuche, Graph und Backlinks | MIT |
| [Backlog.md](https://github.com/MrLesk/Backlog.md) | Arbeiten — Kanban-Board, Tickets abhaken, neue anlegen | MIT |

## Quartz starten

Quartz liegt **neben** diesem Repo, nicht darin — seine Abhängigkeiten wiegen 322 MB und haben in
einem Doku-Repo nichts verloren. Sein `content`-Ordner ist ein Symlink hierher:

```
git clone --depth 1 https://github.com/jackyzha0/quartz.git ../wb-quartz
cd ../wb-quartz && npm i
rm -rf content && ln -s ../wb-docs content
npx quartz build --serve --port 8080     # → http://127.0.0.1:8080
```

Der Bau dauert rund 15 Sekunden und erzeugt statisches HTML unter `public/`. Wer nur lesen will,
braucht danach keinen laufenden Dienst.

**Zwei Grenzen, die man kennen muss:** Die rund 30.000 Wörter in den `COMMENT`-Zeilen von
`schema/*.sql` zeigt Quartz nicht — sie sind kein Markdown und bleiben Sache des Editors. Und ein
Pfad in Backticks (`` `grenzkarte.md` ``) bleibt Text; klickbar werden nur echte Markdown-Verweise.

## Backlog.md starten

```
npm i -g backlog.md
backlog browser                          # → http://127.0.0.1:6420
backlog board                            # dasselbe im Terminal
```

Die Tickets liegen als `.md` in `backlog/` und damit im Git. Die Weboberfläche beschriftet ihre
Tastenkürzel mit Mac-Symbolen; auf Linux wirkt `Strg` genauso — `Strg+K` öffnet die Suche.

## Ein Ticket verweist, statt zu kopieren

Ein Ticket trägt die **Aufgabe** und in `references:` den Pfad zu der Datei, die die **Begründung**
trägt. Die Prosa bleibt in `TODO.md`, `TODO-SESSIONS.md` und den Soll-Blöcken und wird nie ins
Ticket übernommen. Damit gilt weiter, dass sich höchstens eine Datei ändert, wenn etwas fertig wird.

Milestones sind die Termine, die in `fachdomaenen.md` und `soll-prozesse/README.md` ohnehin stehen —
keine erfundenen. Priorität trägt nur, was das Repo selbst so nennt.

## Verworfene Wege

- **Ein Ticketsystem mit eigener Datenbank** (Forgejo, Vikunja, Wekan, GitHub Issues): Preis — der
  Stand steht dann an zwei Orten, die auseinanderlaufen, und eine Session liest das Repo, nicht die
  Datenbank. Wo Fälligkeiten, Priorität und Verlauf wirklich verwaltet werden müssen, wäre es die
  richtige Wahl; für die Sicht auf den Stand ist es eine Kopie zu viel.
- **SilverBullet**: Kann Wiki und Aufgaben in einem Programm und indiziert alle 187 Checkboxen des
  Repos als abhakbare Aufgaben. Preis — es ist ein Editor: ein Klick an der falschen Stelle ändert
  eine Datei, es liefert kein statisches HTML für Externe, und der Container muss laufen.
- **Obsidian mit Dataview**: die reichste Abfragesprache über genau diese Dateien. Preis — nicht
  quelloffen.
- **Material for MkDocs**: die beste Navigation der Kandidaten. Preis — Lebensende am 05.11.2026.
- **Zensical**, sein Nachfolger: Preis — Version 0.0.57, Alpha, und die Suchmaschine steht noch auf
  der Roadmap.
- **Ein selbst geschriebenes Dashboard**: Preis — Code, den nur dieses Projekt hat und den niemand
  pflegt, für eine Ansicht, die zwei fertige Programme mitbringen.

## Offen

Backlog.md schreibt `labels:`, Quartz liest `tags:` — deshalb steht ein Ticket noch nicht auf
derselben Tag-Seite wie die Doku, die es betrifft. Die Volltextsuche findet beide unabhängig davon.
