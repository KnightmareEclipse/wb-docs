# Routen-Prüfbericht: anmeldung — der offene Rest

Elf der zwölf Funde sind geschlossen (`wb-backend`, Commits `ANMELDUNG-R…`; R11 als
[TASK-145](../backlog/tasks/task-145%20-%20Die-Freigabe-Aufgabe-erreicht-jede-Schulleitung-statt-der-ihrer-Schulart.md),
weil er DDL braucht). Einer wartet auf eine Entscheidung.

[ANMELDUNG-R12] Klasse 6 · jede Route, die `_store_signature_image()` ruft
Das Bild geht nach SharePoint, bevor die Zeile steht, die es benennt. Bricht die Transaktion danach
ab — unbekannter Modulcode, verletzter CHECK —, bleibt die PNG in der Bibliothek liegen, und
`clear_signature_images()` findet sie nie, weil sie an keiner `signatures`-Zeile hängt. Die
Datenbank ist sauber, die Bibliothek nicht.
Gelesen, nicht gemessen.
Vorschlag: eine Zeile im Plan, dass die Bibliothek verwaiste Bilder tragen darf — oder den Upload
hinter den letzten Flush ziehen.

**Nicht in diesem Lauf geschlossen, und warum.** Kein Block entscheidet die Sache: 08 Z3 sagt nur,
dass das Bild mit der Gegenzeichnung verschwindet, und über eine Bibliothek, deren Aufräumen an
einer Datenbankzeile hängt, sagt keiner etwas. Beide Vorschläge tragen, und sie unterscheiden sich
in der Art: Der Plansatz ist wahr und kostet nichts, der Umbau verkleinert das Fenster, schließt es
aber nicht — zwei Systeme ohne gemeinsame Transaktion behalten es immer. Deshalb eine Frage und
keine Reparatur.
