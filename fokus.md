# Fokus — der aktive Umfang

Diese Datei gilt, bis die drei Domänen produktiv laufen. Danach wird sie gelöscht, nicht
fortgeschrieben. Sie trägt keine Zahl und keine Ticketliste: Der Stand steht im Board, und was hier
stünde, wäre am nächsten Tag falsch.

## Die drei Domänen

1. **Stammdaten** — der Kern samt Vollimport, `schema/stammdaten-schema.sql`
2. **Putzdienst** — gebaut, inklusive beider Oberflächen; offen ist der Livegang, `schema/putzdienst-schema.sql`
3. **Voranmeldung** — Schema und Routen stehen, die Oberfläche fehlt, `schema/anmeldung-schema.sql`

Reihenfolge: 1 und 2 zusammen, 3 danach. Alles andere ruht.

## Was ruht

**Alles außer den dreien oben.** Was es gibt, sagt `schema/`; was davon ruht, ist die Differenz —
keine Liste hier, sie wäre am nächsten Tag falsch. Die ruhenden Schemata, Blöcke und API-Pläne
bleiben liegen; sie kosten nichts, solange niemand sie öffnet. Ihre Tickets stehen in
`backlog/archive/tasks/` und kommen von dort zurück, wenn ihre Domäne dran ist.

**Der Schulvertrag ist der erste, der zurückkommt** — er muss im März 2027 stehen. Das
Ferienprogramm wäre davor nützlich, ist aber nicht gesetzt.

## Was aktiv bleibt

Das Kriterium, nicht die Liste: **Was steht zwischen jetzt und „Stammdaten, Putzdienst und
Voranmeldung laufen produktiv"?** Alles andere gehört ins Archiv. Ein Ticket, das nur einer
ruhenden Domäne nützt, bleibt dort auch dann, wenn es klein ist.

Die aktuelle Liste erzeugt das Board:

```
backlog task list --plain
```

## Offene Anfragen

Gesammelt fragen, nicht einzeln nachlaufen — der Wortlaut steht in `fragen.md`. Wer noch aussteht,
zeigt das Board je Gesprächspartner:

```
backlog task list --plain -l wartet
```
