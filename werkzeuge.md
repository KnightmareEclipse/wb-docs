# Werkzeuge — womit diese Doku gelesen und bearbeitet wird

Zwei Programme, beide quelloffen, beide auf dem eigenen Rechner. Sie halten keinen eigenen
Datenbestand: Was sie zeigen, sind die Dateien dieses Repos, und Git ist der einzige Weg zwischen
zwei Rechnern. **Keins von beiden startet von selbst** — nach jedem Neustart von Hand, wenn man sie
braucht.

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

Der Bau dauert rund zwanzig Sekunden und erzeugt statisches HTML unter `public/`. **Ein laufender
Dienst bleibt trotzdem nötig:** Quartz schreibt Verweise ohne `.html` (`./container`), und weder
`file://` noch ein einfacher Dateiserver löst die auf — beides zeigt statt der Seite einen 404.

**Vier Grenzen, die man kennen muss:**

- Die rund 30.000 Wörter in den `COMMENT`-Zeilen von `schema/*.sql` zeigt Quartz nicht — sie sind
  kein Markdown und bleiben Sache des Editors.
- Ein Pfad in Backticks (`` `grenzkarte.md` ``) bleibt Text; klickbar werden nur echte
  Markdown-Verweise.
- **`--serve` lauscht auf allen Schnittstellen**, und Quartz 5 kennt keinen Schalter dagegen. Die
  Zone `FedoraWorkstation` gibt 1025–65535/tcp frei, also liest jeder im selben Netz mit, solange
  der Dienst läuft. Preis der Alternativen: eine eigene firewalld-Regel für einen Dienst, der
  minutenweise läuft, oder ein selbst geschriebener Dateiserver, der die Verweise oben auflöst —
  beides teurer als der Dienst nach dem Lesen zu beenden. Backlog.md bindet dagegen an 127.0.0.1.
- Weil `content` aus dem Quartz-Verzeichnis heraus in dieses Repo zeigt, liest Quartz die
  Git-Historie nicht: Es warnt je Datei, dass die Daten ungenau sind, und zeigt Änderungsdaten aus
  dem Dateisystem. Kosmetisch, kein Fehler.

## Backlog.md starten

```
npm i -g backlog.md
backlog browser                          # → http://127.0.0.1:6420
backlog board                            # dasselbe im Terminal
```

Die Tickets liegen als `.md` in `backlog/` und damit im Git. Die Weboberfläche beschriftet ihre
Tastenkürzel mit Mac-Symbolen; auf Linux wirkt `Strg` genauso — `Strg+K` öffnet die Suche.

## Ein Ticket verweist, statt zu kopieren

Ein Ticket trägt die **Aufgabe**, die Abnahmekriterien und so viel Begründung, wie zum Anfangen
nötig ist. In `references:` steht der Pfad zu der Datei, die die Sache selbst entscheidet — das
`schema/*.sql`, der Soll-Block, die Architektur-Datei. Was dort steht, wird nicht abgeschrieben:
Sonst ändert sich beim Fertigwerden mehr als eine Datei, und die zweite läuft still hinterher.

Ein Ticket ohne solchen Verweis ist ein Fund. Es heißt, dass die Aufgabe nirgends verankert ist —
dann entsteht der Anker zuerst, nicht das Ticket.

Milestones sind die Termine, die in `fachdomaenen.md` und `soll-prozesse/README.md` ohnehin stehen —
keine erfundenen. Priorität trägt nur, was das Repo selbst so nennt.

## Verworfene Wege

- **Ein Ticketsystem mit eigener Datenbank** (Forgejo, Vikunja, Wekan, GitHub Issues): Preis — der
  Stand steht dann an zwei Orten, die auseinanderlaufen, und eine Session liest das Repo, nicht die
  Datenbank. Wo Fälligkeiten, Priorität und Verlauf wirklich verwaltet werden müssen, wäre es die
  richtige Wahl; für die Sicht auf den Stand ist es eine Kopie zu viel.
- **SilverBullet**: Kann Wiki und Aufgaben in einem Programm und indiziert jede Checkbox des
  Repos als abhakbare Aufgabe. Preis — es ist ein Editor: ein Klick an der falschen Stelle ändert
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
