---
title: Weltenbaum
---

Konzept- und Architektur-Doku für die Schulprozesse der Clemens-Schule. Hier wird entschieden und
begründet; gebaut wird in `wb-vps` und `wb-backend`.

Diese Seite ist die Tür, nicht der Inhalt — **wer welche Frage entscheidet, steht einmal in
[CLAUDE.md](CLAUDE.md)**, und diese Liste schreibt es nicht ab. Vier Einstiege für Menschen:

- **[Der Arbeitsvorrat](backlog/tasks/)** — was offen ist, mit Reihenfolge und Abnahmekriterien.
  Bequemer über das Board unter `http://127.0.0.1:6420`.
- **[Die Soll-Prozesse](soll-prozesse/README.md)** — wie jeder Vorgang künftig läuft, ein Block je
  Prozess. Was für alle gilt, steht in [hebel.md](soll-prozesse/hebel.md).
- **[Die Fragen an die Schule](fragen.md)** — der Wortlaut, je Gesprächspartner, samt dem Kriterium,
  wann eine Antwort reicht.
- **[Die Grenzkarte](grenzkarte.md)** — wem welche Tatsache gehört, und was noch weiß ist.

Das Datenmodell liegt in `schema/`. Quartz zeigt die Begründungen dort **nicht** — sie stehen als
`COMMENT` in der `.sql` und bleiben Sache des Editors ([werkzeuge.md](werkzeuge.md)).
